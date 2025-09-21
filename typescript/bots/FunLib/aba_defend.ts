// let TS accept these Lua globals
declare function GetScriptDirectory(): string;

import * as jmz from "bots/FunLib/jmz_func";
// Avoid static resolution; mirror Lua's pcall(require(...))
let [okLoc, Localization] = pcall(require, GetScriptDirectory() + "/FunLib/localization");
if (!okLoc) Localization = { Get: (_: string) => "Defend here!" };

// eslint-disable-next-line @typescript-eslint/no-var-requires
import Customize = require("bots/Customize/general");

import { Barracks, BotActionDesire, BotMode, BotModeDesire, Lane, Team, Tower, Unit, UnitType, Vector } from "bots/ts_libs/dota";
import { add } from "bots/ts_libs/utils/native-operators";
import { GetLocationToLocationDistance } from "./utils";

Customize.ThinkLess = Customize.Enable ? Customize.ThinkLess : 1;

// == Tunables ==
const PING_DELTA = 5.0;
const SEARCH_RANGE_DEFAULT = 1600;
// const CLOSE_RANGE = 1200;
const MAX_DESIRE_CAP = 0.98;

// Base threat (Ancient defense)
const BASE_THREAT_RADIUS = 2600;
const BASE_LEASH_OUTBOUND = 1200;
const BASE_THREAT_HOLD = 4.0;

// Perf: cache intervals (seconds)
const CACHE_ENEMY_AROUND_LOC_HZ = 0.35; // cache for weighted enemy scans around a location
const CACHE_LASTSEEN_WINDOW = 5.0; // seconds for hero last-seen proximity checks

// == State ==
const nTeam = GetTeam();
// let currentTime = 0; // Now using cached value
let defendLoc: Vector = GetLaneFrontLocation(GetTeam(), Lane.Mid, 0);
// let aliveAllyHeroes = 0; // Now using cached value
let weAreStronger = false;
let nInRangeAlly: Unit[] = [];
let nInRangeEnemy: Unit[] = [];
let _threatLaneSticky: { lane: Lane; until: number } = { lane: Lane.Mid, until: -1 };

const distanceToLane: Record<Lane, number> = {
    [Lane.Top]: 0,
    [Lane.Mid]: 0,
    [Lane.Bot]: 0,
};

// sticky base-threat window
let baseThreatUntil = -1;

// Travel Boots defender coordination
let fTraveBootsDefendTime = 0;

// == Perf caches ==
type EnemyAroundLocCache = { t: number; count: number };
const _cacheEnemyAroundLoc: Record<string, EnemyAroundLocCache> = {};

/** Performance cache - avoid redundant calculations between GetDefendDesire (300ms) and Think (every frame) */
type CachedDefendGameState = {
    lastUpdate: number;
    currentTime: number;
    gameMode: number;
    team: Team;
    enemyTeam: Team;
    ourAncient: Unit | null;
    enemyAncient: Unit | null;
    aliveAllyCount: number;
    aliveEnemyCount: number;
    isLaningPhase: boolean;
    isEarlyGame: boolean;
    isMidGame: boolean;
    isLateGame: boolean;
    teamFountain: Vector;
    teamFountainTpPoint: Vector;
};

type CachedDefendLocationState = {
    lastUpdate: number;
    laneFronts: Record<Lane, Vector>;
    enemyLaneFronts: Record<Lane, Vector>;
    highGroundEdgeWaitPoints: Record<Lane, Vector>;
};

type CachedDefendUnitState = {
    lastUpdate: number;
    enemyBuildings: Unit[];
    alliedHeroes: Unit[];
    enemyHeroes: Unit[];
    alliedCreeps: Unit[];
    enemyCreeps: Unit[];
    teamMembers: Unit[];
};

const DEFEND_CACHE_TTL = 0.5; // 500ms cache TTL - increased for better performance
const DEFEND_THINK_INTERVAL = 1 / 30; // Limit Think methods to 30 FPS max
let defendGameStateCache: CachedDefendGameState | null = null;
let defendLocationStateCache: CachedDefendLocationState | null = null;
let defendUnitStateCache: CachedDefendUnitState | null = null;

/** Update defend game state cache if needed */
function updateDefendGameStateCache(): CachedDefendGameState {
    const now = DotaTime();
    if (defendGameStateCache && now - defendGameStateCache.lastUpdate < DEFEND_CACHE_TTL) {
        return defendGameStateCache;
    }

    const team = GetTeam();
    const enemyTeam = GetOpposingTeam();
    const currentTime = DotaTime();
    const gameMode = GetGameMode();

    // Adjust time for turbo mode
    const adjustedTime = gameMode === 23 ? currentTime * 1.65 : currentTime;

    defendGameStateCache = {
        lastUpdate: now,
        currentTime: adjustedTime,
        gameMode,
        team,
        enemyTeam,
        ourAncient: GetAncient(team),
        enemyAncient: GetAncient(enemyTeam),
        aliveAllyCount: jmz.GetNumOfAliveHeroes(false),
        aliveEnemyCount: jmz.GetNumOfAliveHeroes(true),
        isLaningPhase: jmz.IsInLaningPhase(),
        isEarlyGame: jmz.IsEarlyGame(),
        isMidGame: jmz.IsMidGame(),
        isLateGame: jmz.IsLateGame(),
        teamFountain: jmz.GetTeamFountain(),
        teamFountainTpPoint: jmz.Utils.GetTeamFountainTpPoint(),
    };

    return defendGameStateCache;
}

/** Update defend location state cache if needed */
function updateDefendLocationStateCache(): CachedDefendLocationState {
    const now = DotaTime();
    if (defendLocationStateCache && now - defendLocationStateCache.lastUpdate < DEFEND_CACHE_TTL) {
        return defendLocationStateCache;
    }

    const team = GetTeam();
    const enemyTeam = GetOpposingTeam();

    defendLocationStateCache = {
        lastUpdate: now,
        laneFronts: {
            [Lane.Top]: GetLaneFrontLocation(team, Lane.Top, 0),
            [Lane.Mid]: GetLaneFrontLocation(team, Lane.Mid, 0),
            [Lane.Bot]: GetLaneFrontLocation(team, Lane.Bot, 0),
        },
        enemyLaneFronts: {
            [Lane.Top]: GetLaneFrontLocation(enemyTeam, Lane.Top, 0),
            [Lane.Mid]: GetLaneFrontLocation(enemyTeam, Lane.Mid, 0),
            [Lane.Bot]: GetLaneFrontLocation(enemyTeam, Lane.Bot, 0),
        },
        highGroundEdgeWaitPoints: {
            [Lane.Top]: GetHighGroundEdgeWaitPoint(team, Lane.Top),
            [Lane.Mid]: GetHighGroundEdgeWaitPoint(team, Lane.Mid),
            [Lane.Bot]: GetHighGroundEdgeWaitPoint(team, Lane.Bot),
        },
    };

    return defendLocationStateCache;
}

/** Update defend unit state cache if needed */
function updateDefendUnitStateCache(): CachedDefendUnitState {
    const now = DotaTime();
    if (defendUnitStateCache && now - defendUnitStateCache.lastUpdate < DEFEND_CACHE_TTL) {
        return defendUnitStateCache;
    }

    const teamMembers: Unit[] = [];
    for (let i = 1; i <= GetTeamPlayers(GetTeam()).length; i++) {
        const member = GetTeamMember(i);
        if (member !== null) {
            teamMembers.push(member);
        }
    }

    defendUnitStateCache = {
        lastUpdate: now,
        enemyBuildings: GetUnitList(UnitType.EnemyBuildings),
        alliedHeroes: GetUnitList(UnitType.AlliedHeroes),
        enemyHeroes: GetUnitList(UnitType.Enemies).filter(u => jmz.IsValidHero(u)),
        alliedCreeps: GetUnitList(UnitType.AlliedCreeps),
        enemyCreeps: GetUnitList(UnitType.Enemies).filter(u => u.IsCreep() || u.IsAncientCreep()),
        teamMembers,
    };

    return defendUnitStateCache;
}

// small utils (keep GC low)
function _q(v: Vector | null | undefined): string {
    return v ? `${math.floor(v.x / 200) * 200}:${math.floor(v.y / 200) * 200}` : "0:0";
}
function _keyLoc(v: Vector, r?: number) {
    return `${_q(v)}|${tostring(math.floor(r || 0))}`;
}

function _recentHeroCountNear(loc: Vector, r: number, window = CACHE_LASTSEEN_WINDOW): number {
    const gameState = updateDefendGameStateCache();
    let cnt = 0;
    for (const id of GetTeamPlayers(gameState.enemyTeam)) {
        if (!IsHeroAlive(id)) continue;
        const info = GetHeroLastSeenInfo(id);
        // NOTE: TS index 0 → Lua index 1
        if (info && info[0] && info[0].time_since_seen <= window && GetLocationToLocationDistance(info[0].location, loc) <= r) {
            cnt += 1;
        }
    }
    return cnt;
}

// == Small helpers ==
function IsValidBuildingTarget(unit: Unit | null): unit is Unit {
    return unit !== null && unit.IsAlive() && unit.IsBuilding();
}
function IsBaseThreatActive(): boolean {
    return DotaTime() < (baseThreatUntil || -1);
}

// If any enemy units (weighted) are around location; cached
function WeightedEnemiesAroundLocation(vLoc: Vector, nRadius: number): number {
    const now = DotaTime();
    const key = _keyLoc(vLoc, nRadius);
    const c = _cacheEnemyAroundLoc[key];
    if (c && now - c.t <= CACHE_ENEMY_AROUND_LOC_HZ) return c.count;

    const unitState = updateDefendUnitStateCache();
    let count = 0;
    for (const unit of unitState.enemyHeroes) {
        if (jmz.IsValid(unit) && GetUnitToLocationDistance(unit, vLoc) <= nRadius) {
            const name = unit.GetUnitName();
            if (jmz.IsValidHero(unit) && !jmz.IsSuspiciousIllusion(unit)) {
                count += jmz.IsCore(unit) ? 1 : 0.5;
            } else if (string.find(name, "upgraded_mega") !== null) {
                count += 0.6;
            } else if (string.find(name, "upgraded") !== null) {
                count += 0.4;
            } else if (string.find(name, "siege") !== null && string.find(name, "upgraded") === null) {
                count += 0.5;
            } else if (string.find(name, "warlock_golem") !== null || string.find(name, "lone_druid_bear") !== null) {
                count += 1;
            } else if (
                unit.IsCreep() ||
                unit.IsAncientCreep() ||
                unit.IsDominated() ||
                unit.HasModifier("modifier_chen_holy_persuasion") ||
                unit.HasModifier("modifier_dominated")
            ) {
                count += 0.2;
            }
        }
    }

    count = math.floor(count);
    _cacheEnemyAroundLoc[key] = { t: now, count };
    return count;
}

function GetThreatenedLane(): Lane {
    const lanes: Lane[] = [Lane.Top, Lane.Mid, Lane.Bot];
    let bestLane = lanes[0];
    let bestScore = -1;

    for (const ln of lanes) {
        const [bld, _urgent, tier] = GetFurthestBuildingOnLane(ln);
        // for tier >=3, use lane HG edge; for t1/2, use the building
        const anchor = IsValidBuildingTarget(bld) && tier < 3 ? bld.GetLocation() : GetHighGroundEdgeWaitPoint(nTeam, ln);

        // Hero-first scoring
        const enemyHeroCnt = _recentHeroCountNear(anchor, 1800);
        let score = enemyHeroCnt * 10; // heroes dominate the score

        if (enemyHeroCnt === 0) {
            // don’t let creeps fully tie heroes; smaller radius + cap
            const creepEq = math.min(WeightedEnemiesAroundLocation(anchor, 1200) * 0.4, 0.9);
            score += creepEq;
        }

        if (score > bestScore) {
            bestScore = score;
            bestLane = ln;
        }
    }

    // short stickiness to avoid oscillation
    if (DotaTime() <= _threatLaneSticky.until) {
        return _threatLaneSticky.lane;
    }
    _threatLaneSticky = { lane: bestLane, until: DotaTime() + 1.8 };
    return bestLane;
}

// Closest ally role among a list to given location
function GetClosestAllyPos(tPosList: number[], vLocation: Vector): number {
    let bestPos: number | null = null;
    let bestDist = math.huge;
    for (let i = 1; i <= 5; i++) {
        const m = GetTeamMember(i);
        if (jmz.IsValidHero(m)) {
            const p = jmz.GetPosition(m);
            for (let j = 1; j <= tPosList.length; j++) {
                if (p === tPosList[j]) {
                    const d = GetUnitToLocationDistance(m, vLocation);
                    if (d < bestDist) {
                        bestDist = d;
                        bestPos = p;
                    }
                }
            }
        }
    }
    return bestPos ?? tPosList[0];
}

// == Core building selection ==
// Returns: furthestBuilding, urgencyMultiplier, tier (1..4)
export function GetFurthestBuildingOnLane(lane: Lane): [Unit | any, number, number] {
    const cacheKey = `FurthestBuildingOnLane:${nTeam}:${lane ?? -1}`;
    const cachedVar = jmz.Utils.GetCachedVars(cacheKey, 1);
    if (cachedVar != null) {
        return cachedVar;
    }

    const res = GetFurthestBuildingOnLaneHelper(lane);
    jmz.Utils.SetCachedVars(cacheKey, res);
    return res;
}

// Returns: furthestBuilding, urgencyMultiplier, tier (1..4)
export function GetFurthestBuildingOnLaneHelper(lane: Lane): [Unit | any, number, number] {
    const team = nTeam;
    let b: Unit | null;

    function hpMul(u: Unit, lo: number, hi: number, mlo: number, mhi: number) {
        const nHealth = u.GetHealth() / u.GetMaxHealth();
        return RemapValClamped(nHealth, lo, hi, mlo, mhi);
    }

    if (lane === Lane.Top) {
        b = GetTower(team, Tower.Top1);
        if (IsValidBuildingTarget(b)) return [b, hpMul(b, 0.25, 1, 0.5, 1), 1];
        b = GetTower(team, Tower.Top2);
        if (IsValidBuildingTarget(b)) return [b, hpMul(b, 0.25, 1, 1.0, 2), 2];
        b = GetTower(team, Tower.Top3);
        if (IsValidBuildingTarget(b)) return [b, hpMul(b, 0.25, 1, 1.5, 2), 3];
        b = GetBarracks(team, Barracks.TopMelee);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetBarracks(team, Barracks.TopRanged);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetTower(team, Tower.Base1);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetTower(team, Tower.Base2);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetAncient(team);
        if (IsValidBuildingTarget(b)) return [b, 3.0, 4];
    } else if (lane === Lane.Mid) {
        b = GetTower(team, Tower.Mid1);
        if (IsValidBuildingTarget(b)) return [b, hpMul(b, 0.25, 1, 0.5, 1), 1];
        b = GetTower(team, Tower.Mid2);
        if (IsValidBuildingTarget(b)) return [b, hpMul(b, 0.25, 1, 1.0, 2), 2];
        b = GetTower(team, Tower.Mid3);
        if (IsValidBuildingTarget(b)) return [b, hpMul(b, 0.25, 1, 1.5, 2), 3];
        b = GetBarracks(team, Barracks.MidMelee);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetBarracks(team, Barracks.MidRanged);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetTower(team, Tower.Base1);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetTower(team, Tower.Base2);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetAncient(team);
        if (IsValidBuildingTarget(b)) return [b, 3.0, 4];
    } else {
        b = GetTower(team, Tower.Bot1);
        if (IsValidBuildingTarget(b)) return [b, hpMul(b, 0.25, 1, 0.5, 1), 1];
        b = GetTower(team, Tower.Bot2);
        if (IsValidBuildingTarget(b)) return [b, hpMul(b, 0.25, 1, 1.0, 2), 2];
        b = GetTower(team, Tower.Bot3);
        if (IsValidBuildingTarget(b)) return [b, hpMul(b, 0.25, 1, 1.5, 2), 3];
        b = GetBarracks(team, Barracks.BotMelee);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetBarracks(team, Barracks.BotRanged);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetTower(team, Tower.Base1);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetTower(team, Tower.Base2);
        if (IsValidBuildingTarget(b)) return [b, 2.5, 3];
        b = GetAncient(team);
        if (IsValidBuildingTarget(b)) return [b, 3.0, 4];
    }

    return [null as any, 1.0, 0];
}

// Travel Boots defender dedupe
function IsThereNoTeammateTravelBootsDefender(bot: Unit): boolean {
    const unitState = updateDefendUnitStateCache();
    for (const m of unitState.teamMembers) {
        if (bot !== m && jmz.IsValidHero(m) && (m as any).travel_boots_defender === true) {
            return false;
        }
    }
    return true;
}

// Compute a “high-ground edge” wait point a bit outside the T3 toward lane
function GetHighGroundEdgeWaitPoint(team: Team, lane: Lane): Vector {
    const t3 = lane === Lane.Top ? GetTower(team, Tower.Top3) : lane === Lane.Mid ? GetTower(team, Tower.Mid3) : GetTower(team, Tower.Bot3);

    // try lane rax if T3 is gone
    const raxM =
        lane === Lane.Top ? GetBarracks(team, Barracks.TopMelee) : lane === Lane.Mid ? GetBarracks(team, Barracks.MidMelee) : GetBarracks(team, Barracks.BotMelee);
    const raxR =
        lane === Lane.Top ? GetBarracks(team, Barracks.TopRanged) : lane === Lane.Mid ? GetBarracks(team, Barracks.MidRanged) : GetBarracks(team, Barracks.BotRanged);

    const anc = GetAncient(team);

    // choose a lane HG anchor: T3 > any rax > last-resort fallback
    const anchorBuilding = (jmz.IsValidBuilding(t3) ? t3 : jmz.IsValidBuilding(raxM) ? raxM : jmz.IsValidBuilding(raxR) ? raxR : undefined) as Unit | undefined;

    if (anchorBuilding && jmz.IsValidBuilding(anc)) {
        const t = anchorBuilding.GetLocation();
        const a = (anc as Unit).GetLocation();
        const dir = Vector(a.x - t.x, a.y - t.y, 0);
        const len = math.max(1, math.sqrt(dir.x * dir.x + dir.y * dir.y));
        return Vector(t.x + (dir.x / len) * 250, t.y + (dir.y / len) * 250, 0);
    }

    // safer fallback: deeper inside base so HG hero clumps get counted
    return jmz.AdjustLocationWithOffsetTowardsFountain(GetLaneFrontLocation(team, lane, 0), 600);
}

// Role-aware defend decision (cached)
export function ShouldDefend(bot: Unit, hBuilding: Unit | null, nRadius: number): boolean {
    if (!IsValidBuildingTarget(hBuilding)) return false;
    // const cacheKey = `ShouldDefend:${bot.GetPlayerID()}:${hBuilding.GetLocation() ?? -1}:${nRadius}`;
    // const cachedVar = jmz.Utils.GetCachedVars(cacheKey, 0.6);
    // if (cachedVar != null) {
    //     return cachedVar;
    // }

    // Count enemies near building (recent seen heroes + weighted creeps)
    const gameState = updateDefendGameStateCache();
    let enemyHeroNearby = 0;
    for (const id of GetTeamPlayers(gameState.enemyTeam)) {
        if (IsHeroAlive(id)) {
            const info = GetHeroLastSeenInfo(id);
            if (info != null) {
                const d = info[0]; // TS 0-index
                if (d != null && d.time_since_seen <= CACHE_LASTSEEN_WINDOW && GetUnitToLocationDistance(hBuilding, d.location) <= 1600) {
                    enemyHeroNearby = enemyHeroNearby + 1;
                }
            }
        }
    }

    const unitState = updateDefendUnitStateCache();
    let creepWeights = 0;
    for (const unit of unitState.enemyCreeps) {
        if (jmz.IsValid(unit) && GetUnitToUnitDistance(hBuilding, unit) <= nRadius) {
            const name = unit.GetUnitName();
            if (string.find(name, "siege") !== null && string.find(name, "upgraded") === null) {
                creepWeights += 0.5;
            } else if (string.find(name, "upgraded_mega") !== null) {
                creepWeights += 0.6;
            } else if (string.find(name, "upgraded") !== null) {
                creepWeights += 0.4;
            } else if (string.find(name, "warlock_golem") !== null || string.find(name, "shadow_shaman_ward") !== null) {
                creepWeights += 1.0;
            } else if (string.find(name, "lone_druid_bear") !== null) {
                enemyHeroNearby = enemyHeroNearby + 1;
            } else if (
                unit.IsCreep() ||
                unit.IsAncientCreep() ||
                unit.IsDominated() ||
                unit.HasModifier("modifier_chen_holy_persuasion") ||
                unit.HasModifier("modifier_dominated")
            ) {
                creepWeights += 0.2;
            }
        }
    }

    const nNearby = enemyHeroNearby + math.floor(creepWeights);
    const pos = jmz.GetPosition(bot);

    let result = false;
    if (nNearby === 1) {
        if (pos === 2 || pos === GetClosestAllyPos([4, 5], hBuilding.GetLocation())) {
            result = true;
        }
    } else if (nNearby === 2) {
        if (pos === 2 || pos === 3 || pos === GetClosestAllyPos([4, 5], hBuilding.GetLocation()) || (pos === 1 && GetUnitToUnitDistance(bot, hBuilding) <= 3200)) {
            result = true;
        }
    } else if (nNearby === 3) {
        if (pos === 2 || pos === 3 || pos === 4 || pos === 5 || (pos === 1 && GetUnitToUnitDistance(bot, hBuilding) <= 3200)) {
            result = true;
        }
    } else if (nNearby >= 4) {
        result = true;
    }

    // Travel Boots/Tinker escalation (one defender at a time)
    if (!result) {
        if (DotaTime() - fTraveBootsDefendTime >= 20.0) {
            (bot as any).travel_boots_defender = false;
        }
        if (
            bot.GetUnitName() === "npc_dota_hero_tinker" &&
            bot.GetLevel() >= 6 &&
            jmz.CanCastAbility(bot.GetAbilityByName("tinker_keen_teleport")) &&
            IsThereNoTeammateTravelBootsDefender(bot)
        ) {
            (bot as any).travel_boots_defender = true;
            fTraveBootsDefendTime = DotaTime();
            result = true;
        } else {
            const boots = jmz.GetItem2(bot, "item_travel_boots") || jmz.GetItem2(bot, "item_travel_boots_2");
            if (jmz.CanCastAbility(boots) && IsThereNoTeammateTravelBootsDefender(bot)) {
                (bot as any).travel_boots_defender = true;
                fTraveBootsDefendTime = DotaTime();
                result = true;
            }
        }

        if (!result && pos === GetClosestAllyPos([2, 3], hBuilding.GetLocation())) {
            result = true;
        }
    }

    const underFire = bot.WasRecentlyDamagedByAnyHero(5);
    if (underFire && result) {
        // Only the closest appropriate role should commit while under fire
        const closestPos = GetClosestAllyPos([2, 3, 4, 5], hBuilding.GetLocation());
        if (jmz.GetPosition(bot) !== closestPos) {
            return false;
        }
    }

    // jmz.Utils.SetCachedVars(cacheKey, result);
    return result;
}

// Ping teammates to defend (rate-limited; role-aware)
function ConsiderPingedDefend(bot: Unit, lane: Lane, desire: number, building: Unit | null, tier: number, nEffAllies: number, nEnemies: number) {
    const gameState = updateDefendGameStateCache();
    if (gameState.isLaningPhase || gameState.aliveAllyCount === 0) return;
    if (!IsValidBuildingTarget(building)) return;
    if (tier < 2 || desire <= 0.5) return;
    if (!ShouldDefend(bot, building, 1600)) return;

    (jmz.Utils as any)["GameStates"] = (jmz.Utils as any)["GameStates"] || {};
    (jmz.Utils as any)["GameStates"]["defendPings"] = (jmz.Utils as any)["GameStates"]["defendPings"] || { pingedTime: GameTime() };
    const defendPings = (jmz.Utils as any)["GameStates"]["defendPings"];

    if (nEffAllies >= 1 && nEffAllies >= nEnemies) return;
    if (GameTime() - defendPings.pingedTime <= 6.0) return;

    const saferLoc = add(jmz.AdjustLocationWithOffsetTowardsFountain(building.GetLocation(), 850), RandomVector(50));

    const retreaters = jmz.GetRetreatingAlliesNearLoc(saferLoc, 1600);
    if (retreaters.length === 0) {
        bot.ActionImmediate_Chat(Localization.Get("say_come_def"), false);
        bot.ActionImmediate_Ping(saferLoc.x, saferLoc.y, false);
        defendPings.pingedTime = GameTime();
        defendPings.lane = lane;
    }
}

// --- Panic hint: lane-gated floor without early returns ---
type PanicHint = { active: boolean; floor: number; forceLoc?: Vector };

export function GetDefendDesire(bot: Unit, lane: Lane): BotModeDesire {
    // 0) quick invalid checks
    if (bot.IsInvulnerable() || !bot.IsHero() || !bot.IsAlive() || !bot.GetUnitName().includes("hero") || bot.IsIllusion()) {
        return BotModeDesire.None;
    }

    // (pre) compute dynamic TTL and include threatened lane in key when base/HG pressure is present
    // const baseThreatNow = IsBaseThreatActive();
    // const enemiesOnHGNow = jmz.Utils.CountEnemyHeroesOnHighGround(nTeam);
    // const threatenedLaneNow = baseThreatNow || enemiesOnHGNow >= 1 ? GetThreatenedLane() : lane;

    // const cacheTTL = baseThreatNow || enemiesOnHGNow >= 1 ? 0.2 : 0.6;
    // const cacheKey = `DefendDesire:${bot.GetPlayerID()}:${lane ?? -1}:${threatenedLaneNow}`;

    // const cachedVar = jmz.Utils.GetCachedVars(cacheKey, cacheTTL);
    // if (cachedVar != null) {
    //     (bot as any).defendDesire = cachedVar;
    //     return cachedVar;
    // }

    // 2) compute and publish
    const res = GetDefendDesireHelper(bot, lane);
    // jmz.Utils.SetCachedVars(cacheKey, res);
    (bot as any).defendDesire = res;
    return res;
}

export function GetDefendDesireHelper(bot: Unit, lane: Lane): BotModeDesire {
    if ((bot as any).laneToDefend == null) (bot as any).laneToDefend = lane;
    if ((bot as any).DefendLaneDesire == null) (bot as any).DefendLaneDesire = [0, 0, 0];

    // Update caches
    const gameState = updateDefendGameStateCache();
    const locationState = updateDefendLocationStateCache();
    // const unitState = updateDefendUnitStateCache(); // Not used in this function

    // currentTime = gameState.currentTime; // Using cached value directly
    const team = gameState.team;
    const ancient = gameState.ourAncient;

    defendLoc = locationState.laneFronts[lane];
    const distanceToDefendLoc = GetUnitToLocationDistance(bot, defendLoc);

    // -- 如果不在当前线上，且等级低，不防守
    const botLevel = bot.GetLevel();
    if (
        bot.GetAssignedLane() !== lane &&
        distanceToDefendLoc > 3000 &&
        ((jmz.GetPosition(bot) === 1 && botLevel < 6) ||
            (jmz.GetPosition(bot) === 2 && botLevel < 6) ||
            (jmz.GetPosition(bot) === 3 && botLevel < 5) ||
            (jmz.GetPosition(bot) === 4 && botLevel < 4) ||
            (jmz.GetPosition(bot) === 5 && botLevel < 4))
    ) {
        return BotModeDesire.None;
    }

    // -- 如果等级低，不防守
    if (botLevel < 3) {
        return BotModeDesire.None;
    }

    const recentlyHit = bot.WasRecentlyDamagedByAnyHero(5) || bot.WasRecentlyDamagedByTower(5);

    // --- Base-first policy ---
    const threatenedLane = GetThreatenedLane();

    // Panic hint (no early return): HG pressure or ancient poke
    let panic: PanicHint = { active: false, floor: 0 };

    // Count enemies around Ancient & on our high ground
    const enemiesAtAncient = ancient ? jmz.Utils.CountEnemyHeroesNear(ancient.GetLocation(), 2200) : 0;
    const enemiesOnHG = jmz.Utils.CountEnemyHeroesOnHighGround(gameState.team);

    // If more than 1 enemy hero on our high ground → force everyone to defend the threatened lane
    if (enemiesOnHG >= 2 && !recentlyHit) {
        if (lane !== threatenedLane) return BotModeDesire.VeryLow;
        baseThreatUntil = DotaTime() + BASE_THREAT_HOLD;
        panic = { active: true, floor: 0.96, forceLoc: ancient ? jmz.AdjustLocationWithOffsetTowardsFountain(ancient.GetLocation(), 300) : defendLoc };
        (bot as any).laneToDefend = lane;
    }

    // If Ancient under attack → ensure at least one support goes (lane-gated)
    if (enemiesAtAncient >= 1) {
        if (lane !== threatenedLane) return BotModeDesire.VeryLow;

        if (ancient) {
            const defenders = jmz.GetAlliesNearLoc(ancient.GetLocation(), 1600);
            const anyThere = defenders.some(a => jmz.IsValidHero(a));
            if (!anyThere) {
                const pos = jmz.GetPosition(bot);
                const isSupport = pos === 4 || pos === 5;
                const closestSupportPos = GetClosestAllyPos([4, 5], ancient.GetLocation());
                if (isSupport && pos === closestSupportPos) {
                    panic = { active: true, floor: math.max(panic.floor, 0.94), forceLoc: jmz.AdjustLocationWithOffsetTowardsFountain(ancient.GetLocation(), 300) };
                    (bot as any).laneToDefend = lane;
                }
            }
        }
    }

    // Base threat detection (sticky): heroes start, creeps can only extend
    const isBaseThreatActive = IsBaseThreatActive();
    if (ancient) {
        const heroesNearAncient = jmz.Utils.CountEnemyHeroesNear(ancient.GetLocation(), BASE_THREAT_RADIUS);
        if (heroesNearAncient >= 1) {
            baseThreatUntil = DotaTime() + BASE_THREAT_HOLD;
        } else if (isBaseThreatActive) {
            const creepWeight = WeightedEnemiesAroundLocation(ancient.GetLocation(), BASE_THREAT_RADIUS);
            if (creepWeight >= 2) {
                baseThreatUntil = DotaTime() + 1.5; // small top-up only
            }
        }
    }

    // If panic wants to force a safer anchor, do it before distance-dependent math
    if (panic.active && panic.forceLoc) {
        defendLoc = panic.forceLoc;
    } else if (isBaseThreatActive && ancient) {
        defendLoc = jmz.AdjustLocationWithOffsetTowardsFountain(ancient.GetLocation(), 300);
    }

    if (isBaseThreatActive) {
        // defend near Ancient but only on the threatened lane
        if (lane !== threatenedLane) {
            return BotModeDesire.VeryLow;
        }
    } else {
        // Opportunistically use enemy lanefront ONLY if not in base threat
        if (jmz.Utils.GetLocationToLocationDistance(gameState.teamFountainTpPoint, defendLoc) < 3000) {
            const enemyLaneFront = locationState.enemyLaneFronts[lane];
            const eNear = jmz.GetLastSeenEnemiesNearLoc(enemyLaneFront, 1600);
            const aNear = jmz.GetAlliesNearLoc(enemyLaneFront, 1600);
            if (GetUnitToLocationDistance(bot, enemyLaneFront) > bot.GetAttackRange() && eNear.length <= aNear.length + 1) {
                defendLoc = enemyLaneFront;
                bot.Action_AttackMove(defendLoc);
            }
        }
    }

    distanceToLane[lane] = GetUnitToLocationDistance(bot, defendLoc);
    nInRangeAlly = jmz.GetNearbyHeroes(bot, 1600, false, BotMode.None);
    nInRangeEnemy = jmz.GetLastSeenEnemiesNearLoc(bot.GetLocation(), 1600);

    weAreStronger = jmz.WeAreStronger(bot, 2500);
    // aliveAllyHeroes = gameState.aliveAllyCount; // Using cached value directly

    // Bail-outs to avoid feed / conflicts
    const pos = jmz.GetPosition(bot);
    const bMyLane = bot.GetAssignedLane() === lane;
    if (
        nInRangeEnemy.length > 0 ||
        (!bMyLane && pos === 1 && gameState.isLaningPhase) || // keep carry safe early
        (jmz.IsDoingRoshan(bot) && jmz.GetAlliesNearLoc(jmz.GetCurrentRoshanLocation(), 2800).length >= 3) ||
        (jmz.IsDoingTormentor(bot) &&
            (jmz.GetAlliesNearLoc(jmz.GetTormentorLocation(team), 1600).length >= 2 || jmz.GetAlliesNearLoc(jmz.GetTormentorWaitingLocation(team), 2500).length >= 2) &&
            enemiesAtAncient === 0)
    ) {
        return BotModeDesire.VeryLow;
    }

    // Human priority ping (use a hint floor instead of early-return)
    let pingFloor = 0;
    const [human, humanPing] = jmz.GetHumanPing();
    if (human && humanPing && !humanPing.normal_ping && DotaTime() > 0) {
        const [isPinged, pingedLane] = jmz.IsPingCloseToValidTower(gameState.team, humanPing, 800, 5.0);
        if (isPinged && lane === pingedLane && GameTime() < humanPing.time + PING_DELTA) {
            (bot as any).laneToDefend = lane;
            pingFloor = 0.95;
        }
    }

    // Compute desire anchored on furthest building
    const [furthestBuilding, urgentMul, buildingTier] = GetFurthestBuildingOnLane(lane);
    if (!IsValidBuildingTarget(furthestBuilding)) {
        return BotModeDesire.None;
    }

    // Use ShouldDefend to gate/dampen
    const shouldDef = ShouldDefend(bot, furthestBuilding, 1600);
    if (!shouldDef) {
        const dist = distanceToLane[lane];
        const tp = jmz.Utils.GetItemFromFullInventory(bot, "item_tpscroll");
        const nearEnemiesAtBuilding = jmz.GetLastSeenEnemiesNearLoc(furthestBuilding.GetLocation(), 1200);
        if (
            (!jmz.CanCastAbility(tp) && dist && dist > 4000 && nearEnemiesAtBuilding.length === 0) ||
            (nearEnemiesAtBuilding.length === 0 && jmz.GetAlliesNearLoc(furthestBuilding.GetLocation(), 1600).length >= 1)
        ) {
            return BotModeDesire.VeryLow;
        }
    }

    let nDefendDesire = GetDefendLaneDesire(lane);

    // Avoid dogpile if enemies absent & allies/core already covering
    const hub = IsValidBuildingTarget(furthestBuilding) ? furthestBuilding.GetLocation() : GetLaneFrontLocation(nTeam, lane, 0);

    // Use hub (not defendLoc) for these two gates:
    const lEnemies = jmz.GetLastSeenEnemiesNearLoc(hub, 2500);
    const nDefendAllies = jmz.GetAlliesNearLoc(hub, 2500);
    const nEffAllies = nDefendAllies.length + jmz.Utils.GetAllyIdsInTpToLocation(hub, 2500).length;

    if (lEnemies.length === 0 && (jmz.IsAnyAllyDefending(bot, lane) || jmz.IsCore(bot))) {
        return BotModeDesire.VeryLow;
    }
    if (lEnemies.length === 1 && (nEffAllies > lEnemies.length || (jmz.IsAnyAllyDefending(bot, lane) && jmz.GetAverageLevel(false) >= jmz.GetAverageLevel(true)))) {
        return BotModeDesire.VeryLow;
    }

    // Cap & floor via ShouldDefend & tier
    const capBoost = shouldDef ? 0.1 : 0.0;
    let maxDesire = (buildingTier >= 3 && nEffAllies >= lEnemies.length ? 1.0 : MAX_DESIRE_CAP) + capBoost;
    maxDesire = math.min(maxDesire, 1.0);
    const baseFloor = shouldDef ? BotActionDesire.Low : BotActionDesire.VeryLow;

    nDefendDesire = RemapValClamped(jmz.GetHP(bot), 0.75, 0.2, RemapValClamped(nDefendDesire * urgentMul, 0, 1, baseFloor, maxDesire), BotActionDesire.Low);

    // Be cautious if outnumbered near destination and not stronger
    {
        const dist = distanceToLane[lane];
        if (dist && dist < 1600 && nInRangeEnemy.length > nInRangeAlly.length && !weAreStronger) {
            nDefendDesire = RemapValClamped(nDefendDesire, 0, 1, BotActionDesire.VeryLow, BotActionDesire.High);
        }
    }

    // Don’t abandon defend for a low-HP chase
    const botTarget = jmz.GetProperTarget(bot);
    if (jmz.IsValidHero(botTarget) && jmz.GetHP(botTarget) < 0.6 && jmz.GetHP(bot) > jmz.GetHP(botTarget) && GetUnitToUnitDistance(bot, botTarget) < 1500) {
        nDefendDesire = nDefendDesire * 0.4;
    }

    // TP/distance sanity
    {
        const tp = jmz.Utils.GetItemFromFullInventory(bot, "item_tpscroll");
        const dist = distanceToLane[lane];
        if (!jmz.CanCastAbility(tp) && dist && dist > 4000) {
            const nearEnemies = jmz.GetLastSeenEnemiesNearLoc(furthestBuilding.GetLocation(), 1200);
            if (nearEnemies.length === 0 || bot.WasRecentlyDamagedByAnyHero(2)) {
                nDefendDesire = nDefendDesire * 0.5;
            }
            nDefendDesire = RemapValClamped(dist / 4000, 0, 2, nDefendDesire, BotActionDesire.VeryLow);
        }
    }

    // Don’t throw bodies at doomed low-HP T1/T2
    if (IsValidBuildingTarget(furthestBuilding) && furthestBuilding !== ancient) {
        const hp = jmz.GetHP(furthestBuilding);
        if ((buildingTier === 1 && hp <= 0.15) || (buildingTier === 2 && hp <= 0.1)) {
            return BotModeDesire.None;
        }
    }

    // Apply floors (panic/ping) after all dampeners
    if (panic.active) nDefendDesire = math.max(nDefendDesire, panic.floor);
    if (pingFloor > 0) nDefendDesire = math.max(nDefendDesire, pingFloor);

    // Ask for help if needed
    ConsiderPingedDefend(bot, lane, nDefendDesire, furthestBuilding, buildingTier, nEffAllies, lEnemies.length);

    if (recentlyHit) {
        // Cut desire and favor regrouping when outnumbered
        nDefendDesire = nDefendDesire * 0.4;
        if (nInRangeEnemy.length >= nInRangeAlly.length && !weAreStronger) {
            nDefendDesire = math.min(nDefendDesire, BotActionDesire.Low);
        }
    }

    if (nDefendDesire > 0.7) {
        (jmz.Utils as any).GameStates = (jmz.Utils as any).GameStates || {};
        (jmz.Utils as any).GameStates["recentDefendTime"] = DotaTime();
        (bot as any).laneToDefend = lane;
    }

    return nDefendDesire as BotModeDesire;
}

let lastDefendThinkTime = 0;
let lastDefendAction: { type: string; target?: Unit | Vector; time: number } | null = null;

export function DefendThink(bot: Unit, lane: Lane) {
    // Frame rate limiting for performance
    const now = DotaTime();
    if (now - lastDefendThinkTime < DEFEND_THINK_INTERVAL) {
        // Continue last action to prevent idle bots
        if (lastDefendAction && now - lastDefendAction.time < 2.0) {
            switch (lastDefendAction.type) {
                case "attack":
                    if (lastDefendAction.target && typeof lastDefendAction.target === "object" && "GetLocation" in lastDefendAction.target) {
                        bot.Action_AttackUnit(lastDefendAction.target as Unit, true);
                    }
                    break;
                case "move":
                    if (lastDefendAction.target && typeof lastDefendAction.target === "object" && "x" in lastDefendAction.target) {
                        bot.Action_MoveToLocation(lastDefendAction.target as Vector);
                    }
                    break;
                case "attackMove":
                    if (lastDefendAction.target && typeof lastDefendAction.target === "object" && "x" in lastDefendAction.target) {
                        bot.Action_AttackMove(lastDefendAction.target as Vector);
                    }
                    break;
            }
        }
        return;
    }
    lastDefendThinkTime = now;

    if (jmz.CanNotUseAction(bot)) return;
    if (jmz.Utils.IsBotThinkingMeaningfulAction(bot, Customize.ThinkLess, "defend")) return;

    // a small don't-walk-through-fire guard - use cached enemies when possible
    const botLocation = bot.GetLocation();
    const pathCacheKey = `pathEnemies_${bot.GetPlayerID()}_${Math.floor(now * 2)}`; // 500ms cache
    let pathEnemies: Unit[];
    if (!(bot as any)[pathCacheKey]) {
        pathEnemies = jmz.GetLastSeenEnemiesNearLoc(botLocation, 1600);
        (bot as any)[pathCacheKey] = pathEnemies;
        // Clean old cache entries
        Object.keys(bot).forEach(key => {
            if (key.startsWith("pathEnemies_") && key !== pathCacheKey) {
                delete (bot as any)[key];
            }
        });
    } else {
        pathEnemies = (bot as any)[pathCacheKey];
    }

    if (bot.WasRecentlyDamagedByAnyHero(5) && pathEnemies.length > nInRangeEnemy.length) {
        // step back toward fountain a bit, then re-eval next tick
        const safe = jmz.AdjustLocationWithOffsetTowardsFountain(bot.GetLocation(), 700);
        bot.Action_MoveToLocation(add(safe, jmz.RandomForwardVector(120)));
        return;
    }

    // Base-defense leash: anchor near Ancient, don't drift out
    if (IsBaseThreatActive()) {
        const ancient = GetAncient(nTeam);
        const anchor = jmz.AdjustLocationWithOffsetTowardsFountain(ancient.GetLocation(), 200);

        const toAnc = GetUnitToUnitDistance(bot, ancient);
        if (toAnc > BASE_LEASH_OUTBOUND) {
            const moveLoc = add(anchor, jmz.RandomForwardVector(250));
            lastDefendAction = { type: "move", target: moveLoc, time: now };
            bot.Action_MoveToLocation(moveLoc);
            return;
        }

        const nSearchRange = 1400;
        const ancientLoc = ancient.GetLocation();
        // Use a simpler cache approach for Lua compatibility
        const enemiesCacheKey = `ancientEnemies_${Math.floor(now * 5)}`;
        let enemiesNear: Unit[];
        if (!(jmz.Utils as any)[enemiesCacheKey]) {
            enemiesNear = jmz.GetEnemiesNearLoc(ancientLoc, nSearchRange);
            (jmz.Utils as any)[enemiesCacheKey] = enemiesNear;
            // Clean old cache entries
            const utils = jmz.Utils as any;
            Object.keys(utils).forEach(key => {
                if (typeof key === "string" && key.startsWith("ancientEnemies_") && key !== enemiesCacheKey) {
                    delete utils[key];
                }
            });
        } else {
            enemiesNear = (jmz.Utils as any)[enemiesCacheKey];
        }

        if (jmz.IsValidHero(enemiesNear[0]) && jmz.IsInRange(bot, enemiesNear[0], nSearchRange)) {
            lastDefendAction = { type: "attack", target: enemiesNear[0], time: now };
            bot.Action_AttackUnit(enemiesNear[0], true);
            return;
        }

        const attackMoveLoc = add(anchor, jmz.RandomForwardVector(300));
        lastDefendAction = { type: "attackMove", target: attackMoveLoc, time: now };
        bot.Action_AttackMove(attackMoveLoc);
        return;
    }

    // Normal defend movement/targeting
    const attackRange = bot.GetAttackRange();
    const nSearchRange = (attackRange < 900 && 900) || math.min(attackRange, SEARCH_RANGE_DEFAULT);
    if (!defendLoc) defendLoc = GetLaneFrontLocation(nTeam, lane, 0);

    const [bld, _, buildingTier] = GetFurthestBuildingOnLane(lane);
    let hub = defendLoc;
    if (IsValidBuildingTarget(bld)) hub = bld.GetLocation();
    if (!hub) hub = GetLaneFrontLocation(nTeam, lane, 0);

    // If we are defending tier ≥3 lane hold the edge of the high ground
    if (buildingTier >= 3) {
        const edgeInside = GetHighGroundEdgeWaitPoint(nTeam, lane);
        const enemyAtHG = jmz.Utils.CountEnemyHeroesOnHighGround(nTeam); // 0/1/2+
        const nearEdgeEnemies = jmz.GetLastSeenEnemiesNearLoc(edgeInside, 1200);
        const nearEdgeAllies = jmz.GetAlliesNearLoc(edgeInside, 1400);

        // Default: hold just inside HG. Only step out if we have clear numbers.
        if (enemyAtHG === 0 && nearEdgeEnemies.length > 0 && nearEdgeAllies.length >= nearEdgeEnemies.length + 1) {
            const attackMoveLoc = add(edgeInside, jmz.RandomForwardVector(120));
            lastDefendAction = { type: "attackMove", target: attackMoveLoc, time: now };
            bot.Action_AttackMove(attackMoveLoc);
        } else {
            // tuck slightly deeper if contested or alone
            const deeper = jmz.AdjustLocationWithOffsetTowardsFountain(edgeInside, 200);
            const attackMoveLoc = add(deeper, jmz.RandomForwardVector(120));
            lastDefendAction = { type: "attackMove", target: attackMoveLoc, time: now };
            bot.Action_AttackMove(attackMoveLoc);
        }
        return;
    }

    // Prefer nearest valid enemy hero within range (cheap local queries first)
    const enemiesAtHub = jmz.GetEnemiesNearLoc(hub, SEARCH_RANGE_DEFAULT);
    if (jmz.IsValidHero(enemiesAtHub[0]) && jmz.IsInRange(bot, enemiesAtHub[0], nSearchRange)) {
        lastDefendAction = { type: "attack", target: enemiesAtHub[0], time: now };
        bot.Action_AttackUnit(enemiesAtHub[0], true);
        return;
    }

    const nEnemyHeroes = bot.GetNearbyHeroes(SEARCH_RANGE_DEFAULT, true, BotMode.None);
    if (jmz.IsValidHero(nEnemyHeroes[0]) && jmz.IsInRange(bot, nEnemyHeroes[0], nSearchRange)) {
        lastDefendAction = { type: "attack", target: nEnemyHeroes[0], time: now };
        bot.Action_AttackUnit(nEnemyHeroes[0], true);
        return;
    }

    // Otherwise, clear strongest creep (avoid full scans)
    const creeps = bot.GetNearbyCreeps(900, true);
    if (creeps && creeps.length > 0 && (!enemiesAtHub || enemiesAtHub.length === 0)) {
        let best: Unit | null = null;
        let bestDmg = -1;
        for (let i = 1; i <= creeps.length; i++) {
            const c = creeps[i];
            if (jmz.IsValid(c) && jmz.CanBeAttacked(c)) {
                const dmg = c.GetAttackDamage();
                if (dmg > bestDmg) {
                    best = c;
                    bestDmg = dmg;
                }
            }
        }
        if (best) {
            lastDefendAction = { type: "attack", target: best, time: now };
            bot.Action_AttackUnit(best, true);
            return;
        }
    }

    // Move with small jitter; prefer assertive move if ShouldDefend says we're the responder
    if (bld && ShouldDefend(bot, bld, 1600)) {
        const attackMoveLoc = add(hub, jmz.RandomForwardVector(300));
        lastDefendAction = { type: "attackMove", target: attackMoveLoc, time: now };
        bot.Action_AttackMove(attackMoveLoc);
        return;
    }

    const dist = distanceToLane[lane] || GetUnitToLocationDistance(bot, hub);
    if ((weAreStronger || nInRangeAlly.length >= nInRangeEnemy.length) && dist < SEARCH_RANGE_DEFAULT) {
        const attackMoveLoc = add(hub, jmz.RandomForwardVector(300));
        lastDefendAction = { type: "attackMove", target: attackMoveLoc, time: now };
        bot.Action_AttackMove(attackMoveLoc);
    } else if (dist > SEARCH_RANGE_DEFAULT * 1.7) {
        const moveLoc = add(hub, jmz.RandomForwardVector(300));
        lastDefendAction = { type: "move", target: moveLoc, time: now };
        bot.Action_MoveToLocation(moveLoc);
    } else {
        const moveLoc = add(hub, jmz.RandomForwardVector(1000));
        lastDefendAction = { type: "move", target: moveLoc, time: now };
        bot.Action_MoveToLocation(moveLoc);
    }
}

export function OnEnd() {
    // no-op
}
