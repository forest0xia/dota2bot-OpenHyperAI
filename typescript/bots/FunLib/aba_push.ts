import * as jmz from "bots/FunLib/jmz_func";
// eslint-disable-next-line @typescript-eslint/no-var-requires
import Customize = require("bots/Customize/general");
import { Barracks, BotMode, BotModeDesire, DamageType, Lane, Tower, Unit, UnitType, Vector } from "bots/ts_libs/dota";

Customize.ThinkLess = Customize.Enable ? Customize.ThinkLess : 1;

/**
 * Tunables / thresholds
 * (kept from Lua; comments preserved)
 */
const pingTimeDelta = 5;
const StartToPushTime = 16 * 60; // after X mins, start considering to push.
const BOT_MODE_DESIRE_EXTRA_LOW = 0.02;

/** Module-scoped state (cache-ish). Keep small and intentional. */
let hEnemyAncient: Unit | null = null;

/**
 * === Objective selection stability (anti-thrash) ===
 * (kept from Lua; comments preserved)
 */
const OBJECTIVE_STICKY_TIME = 1.2; // seconds to keep current target before reconsidering
const SWITCH_SCORE_MARGIN = 0.25; // how much better (lower) the new score must be to switch
const OBJECTIVE_LEASH_RANGE = 2600; // max distance from bot to consider high-ground objectives

// Barracks ≈ 200 from T3, T4 ≈ 800 from barracks; favor inner-ring first
// Lower score is better. Priority: Barracks (melee>ranged) < T3 < T4 < Fillers
const SCORE_BARRACKS_MELEE = 0;
const SCORE_BARRACKS_RANGED = 0.1;
const SCORE_T3 = 0.5;
const SCORE_T4 = 1.8;
// const SCORE_FILLER = 1.9;

const BASE_ANC_RADIUS = 2200;

/**
 * Add per-bot, per-lane objective memory
 * Example: ObjectiveState[playerID][lane] = { target=hUnit, lockUntil=GameTime() }
 */
type LaneState = { target?: Unit | null; lockUntil?: number };
const ObjectiveState: Record<number, Partial<Record<Lane, LaneState>>> = {};

/* -----------------------------------------------------------------------------
 * Desire front-door
 * ---------------------------------------------------------------------------*/
export function GetPushDesire(bot: Unit, lane: Lane): BotModeDesire {
    // 0) quick invalid checks
    if (bot.IsInvulnerable() || !bot.IsHero() || !bot.IsAlive() || !bot.GetUnitName().includes("hero") || bot.IsIllusion()) {
        return BotModeDesire.None;
    }

    if (bot.GetLevel() < 3) {
        return BotModeDesire.None;
    }

    // 1) very small cache by bot+lane for stability
    // const cacheKey = `PushDesire:${bot.GetPlayerID()}:${lane ?? -1}`;
    // const cachedVar = jmz.Utils.GetCachedVars(cacheKey, 0.6);
    // if (cachedVar != null) {
    //     (bot as any).pushDesire = cachedVar;
    //     return cachedVar;
    // }

    // 2) compute and publish
    const res = GetPushDesireHelper(bot, lane);
    // jmz.Utils.SetCachedVars(cacheKey, res);
    (bot as any).pushDesire = res;
    return res;
}

/* -----------------------------------------------------------------------------
 * Desire core
 * ---------------------------------------------------------------------------*/
export function GetPushDesireHelper(bot: Unit, lane: Lane): BotModeDesire {
    // Keep the intent: avoid pushing too early or when other team jobs override.
    if ((bot as any).laneToPush == null) (bot as any).laneToPush = lane;

    let nMaxDesire = 0.82;
    const nSearchRange = 2000;
    const botActiveMode = bot.GetActiveMode();
    const nModeDesire = bot.GetActiveModeDesire();
    const bMyLane = bot.GetAssignedLane() === lane;
    const isMidOrEarlyGame = jmz.IsEarlyGame() || jmz.IsMidGame();

    hEnemyAncient = GetAncient(GetOpposingTeam());

    // Current, LOCAL threat picture around the bot (not reused across Think)
    const alliesHere = jmz.GetAlliesNearLoc(bot.GetLocation(), 1600);
    const enemiesHere = jmz.GetEnemiesNearLoc(bot.GetLocation(), 1600);

    // --- Strong base-defense gate for push ---
    const team = GetTeam();
    const ourAncient = GetAncient(team);
    const enemiesAtAncient = jmz.Utils.CountEnemyHeroesNear(ourAncient.GetLocation(), BASE_ANC_RADIUS);
    // If Ancient under direct pressure → strongly deprioritize pushes
    if (enemiesAtAncient >= 1) return BotModeDesire.ExtraLow;

    // Sync lane selection with hard bot modes
    if (botActiveMode === BotMode.PushTowerTop) {
        (bot as any).laneToPush = Lane.Top;
    } else if (botActiveMode === BotMode.PushTowerMid) {
        (bot as any).laneToPush = Lane.Mid;
    } else if (botActiveMode === BotMode.PushTowerBot) {
        (bot as any).laneToPush = Lane.Bot;
    }

    // Do not push too early (Turbo is faster-time environment)
    let currentTime = DotaTime();
    if (GetGameMode() === 23) {
        currentTime = currentTime * 2;
    }

    // Ignore push if someone just pinged "defend" recently
    (jmz.Utils as any)["GameStates"] = (jmz.Utils as any)["GameStates"] || {};
    (jmz.Utils as any)["GameStates"]["defendPings"] = (jmz.Utils as any)["GameStates"]["defendPings"] || { pingedTime: GameTime() };
    if (GameTime() - (jmz.Utils as any)["GameStates"]["defendPings"].pingedTime <= 5.0) {
        return BotModeDesire.None;
    }

    // Early laning rules & neutral objectives that override pushing
    if (
        (!bMyLane && jmz.IsCore(bot) && jmz.IsInLaningPhase()) ||
        (jmz.IsDoingRoshan(bot) && jmz.GetAlliesNearLoc(jmz.GetCurrentRoshanLocation(), 2800).length >= 3) ||
        (isMidOrEarlyGame &&
            (jmz.GetAlliesNearLoc(jmz.GetTormentorLocation(team), 1600).length >= 3 || jmz.GetAlliesNearLoc(jmz.GetTormentorWaitingLocation(team), 2500).length >= 3))
    ) {
        return BOT_MODE_DESIRE_EXTRA_LOW as BotModeDesire;
    }

    // If a team member is still very low level, hold pushes entirely
    for (let i = 1; i <= GetTeamPlayers(team).length; i++) {
        const member = GetTeamMember(i);
        if (member !== null && member.GetLevel() < 6) {
            return BotModeDesire.None;
        }
    }

    // Human opponents → delay high-commit pushes before a certain time
    const [nH] = jmz.Utils.NumHumanBotPlayersInTeam(GetOpposingTeam());
    if (nH > 0 && currentTime <= StartToPushTime) {
        return BOT_MODE_DESIRE_EXTRA_LOW as BotModeDesire;
    }

    // If we are actively defending, cap the max desire slightly lower
    if (jmz.IsDefending(bot) && nModeDesire >= 0.8) {
        nMaxDesire = 0.75;
    }

    // Respect allied "attack here" human ping on a tower if it matches lane
    const [human, humanPing] = jmz.GetHumanPing();
    if (human !== null && humanPing !== null && !humanPing.normal_ping && DotaTime() > 0) {
        const [isPinged, pingedLane] = jmz.IsPingCloseToValidTower(GetOpposingTeam(), humanPing, 700, 5.0);
        if (isPinged && lane === pingedLane && GameTime() < humanPing.time + pingTimeDelta) {
            return 0.9 as BotModeDesire;
        }
    }

    // If we're off doing Tormentor far from enemy ancient, lower desire
    if (hEnemyAncient && hEnemyAncient !== null) {
        if (jmz.IsDoingTormentor(bot) && GetUnitToUnitDistance(bot, hEnemyAncient) > 4000) {
            return BOT_MODE_DESIRE_EXTRA_LOW as BotModeDesire;
        }
    }

    // Team state snapshot (used for several gates below)
    const aAliveCount = jmz.GetNumOfAliveHeroes(false);
    const eAliveCount = jmz.GetNumOfAliveHeroes(true);
    const aAliveCoreCount = jmz.GetAliveCoreCount(false);
    const eAliveCoreCount = jmz.GetAliveCoreCount(true);

    const hAncient = GetAncient(team);
    let nPushDesire = GetPushLaneDesire(lane);
    //   const allyKills = jmz.GetNumOfTeamTotalKills(false) + 1;
    //   const enemyKills = jmz.GetNumOfTeamTotalKills(true) + 1;
    //   const teamKillsRatio = allyKills / enemyKills; // (not used later but retained)

    // If enemies are at our ancient and we have few allies nearby → cap desire
    const teamAncientLoc = hAncient.GetLocation();
    const nEffAlliesNearAncient = jmz.GetAlliesNearLoc(teamAncientLoc, 4500).length + jmz.Utils.GetAllyIdsInTpToLocation(teamAncientLoc, 4500).length;
    const nEnemiesAroundAncient = jmz.GetEnemiesAroundLoc(teamAncientLoc, 4500);
    if (nEnemiesAroundAncient > 0 && nEffAlliesNearAncient < 1) {
        nMaxDesire = 0.65;
    }

    // If outnumbered in *local* area, desire is very low (avoid feed)
    if (alliesHere.length < enemiesHere.length && aAliveCount < eAliveCount) {
        return BotModeDesire.VeryLow;
    }

    // If critical items/spells are cooling down near the push location → be cautious
    const vEnemyLaneFrontLocation = GetLaneFrontLocation(GetOpposingTeam(), lane, 0);
    const waitForSpells = ShouldWaitForImportantItemsSpells(vEnemyLaneFrontLocation);
    if (waitForSpells && eAliveCount >= aAliveCount && eAliveCoreCount >= aAliveCoreCount) {
        nMaxDesire = Math.min(nMaxDesire, 0.5);
    }

    // If already targeting a building that is backdoored, kill desire immediately
    const botTarget = bot.GetAttackTarget();
    if (jmz.IsValidBuilding(botTarget) && !botTarget!.GetUnitName().includes("tower1") && !botTarget!.GetUnitName().includes("tower2")) {
        if (HasBackdoorProtect(botTarget!)) {
            return BOT_MODE_DESIRE_EXTRA_LOW as BotModeDesire;
        }
    }

    // If close to enemy Ancient and it is hittable, prioritize it proportionally to HP
    if (
        hEnemyAncient &&
        GetUnitToUnitDistance(bot, hEnemyAncient) < nSearchRange * 0.5 &&
        jmz.CanBeAttacked(hEnemyAncient) &&
        !bot.WasRecentlyDamagedByAnyHero(1) &&
        jmz.GetHP(bot) > 0.5 &&
        !HasBackdoorProtect(hEnemyAncient)
    ) {
        bot.SetTarget(hEnemyAncient);
        bot.Action_AttackUnit(hEnemyAncient, true);
        return RemapValClamped(jmz.GetHP(bot), 0, 0.5, BotModeDesire.None, 0.98) as BotModeDesire;
    }

    // Decide which lane to push; consider mid early, ally proximity, etc.
    const pushLane = WhichLaneToPush(bot, lane);
    const isCurrentLanePushLane = pushLane === lane;

    // non-cores join the chosen lane; cores prefer chosen lane late, but can push earlier.
    if ((!jmz.IsCore(bot) && isCurrentLanePushLane) || (jmz.IsCore(bot) && ((jmz.IsLateGame() && isCurrentLanePushLane) || isMidOrEarlyGame))) {
        const allowNumbers = eAliveCount === 0 || aAliveCoreCount >= eAliveCoreCount || (aAliveCoreCount >= 1 && aAliveCount >= eAliveCount + 2);

        if (allowNumbers) {
            if (jmz.DoesTeamHaveAegis()) {
                nPushDesire = nPushDesire + 0.3;
            }

            if (aAliveCount >= eAliveCount && jmz.GetAverageLevel(team) >= 12) {
                const [teamNetworth, enemyNetworth] = jmz.GetInventoryNetworth();
                nPushDesire = nPushDesire + RemapValClamped(teamNetworth - enemyNetworth, 5000, 15000, 0.0, 1.0);
            }

            return RemapValClamped(nPushDesire * jmz.GetHP(bot), 0, 1, 0, nMaxDesire) as BotModeDesire;
        }
    }

    // Default: prefer mid as the soft fallback
    return lane === Lane.Mid ? BotModeDesire.VeryLow : (BOT_MODE_DESIRE_EXTRA_LOW as BotModeDesire);
}

/* -----------------------------------------------------------------------------
 * Lane selection helpers
 * ---------------------------------------------------------------------------*/

/** Ally presence should make a lane cheaper (more attractive) */
function presence_adjust(score: number, loc: Vector): number {
    const allies = jmz.GetAlliesNearLoc(loc, 1600).length;
    // pull toward lanes with allies; 0.25 is mild and safe
    return score / (1 + 0.25 * allies);
}

function UnitIsValidObjective(u: Unit | null): u is Unit {
    return !!u && jmz.IsValidBuilding(u) && jmz.CanBeAttacked(u) && !HasBackdoorProtect(u) && !UnitIsFiller(u);
}

function UnitIsBarracks(u: Unit): boolean {
    const n = u ? u.GetUnitName() : "";
    return n.includes("rax");
}
function UnitIsMeleeBarracks(u: Unit): boolean {
    return UnitIsBarracks(u) && !!u && u.GetUnitName().includes("melee");
}
function UnitIsRangedBarracks(u: Unit): boolean {
    return UnitIsBarracks(u) && !!u && u.GetUnitName().includes("ranged");
}
function UnitIsT3(u: Unit): boolean {
    return u === GetTower(GetOpposingTeam(), Tower.Top3) || u === GetTower(GetOpposingTeam(), Tower.Mid3) || u === GetTower(GetOpposingTeam(), Tower.Bot3);
}
function UnitIsT4(u: Unit): boolean {
    return (
        u === GetTower(GetOpposingTeam(), Tower.Base1) || u === GetTower(GetOpposingTeam(), Tower.Base2) || GetUnitToUnitDistance(u, GetAncient(GetOpposingTeam())) < 500
    );
}
function UnitIsFiller(u: Unit): boolean {
    // Fillers/other inner-base buildings, exclude barracks/towers
    return jmz.IsValidBuilding(u) && !UnitIsBarracks(u) && !UnitIsT3(u) && !UnitIsT4(u);
}

/**
 * Compute a score for an objective; lower is better.
 * Base priority + mild distance terms; prefer closer to the bot and to approach targetLoc.
 */
function ObjectiveScore(bot: Unit, u: Unit | null, targetLoc?: Vector | null): number {
    if (!UnitIsValidObjective(u)) return Number.POSITIVE_INFINITY;

    const base =
        (UnitIsMeleeBarracks(u) && SCORE_BARRACKS_MELEE) ||
        (UnitIsRangedBarracks(u) && SCORE_BARRACKS_RANGED) ||
        (UnitIsT3(u) && SCORE_T3) ||
        // (UnitIsFiller(u) && SCORE_FILLER) ||
        (UnitIsT4(u) && SCORE_T4) ||
        2.0; // anything unknown → worst

    const dBot = GetUnitToUnitDistance(bot, u);
    if (dBot > OBJECTIVE_LEASH_RANGE) return Number.POSITIVE_INFINITY;

    // Distance nudges (kept light so priority dominates)
    const d1 = dBot / 2000.0; // 0 .. ~1.3
    const d2 = targetLoc ? GetUnitToLocationDistance(u, targetLoc) / 2500.0 : 0;

    return base + 0.35 * d1 + 0.2 * d2;
}

/** Decide whether to keep current target or switch to a better one */
function SelectOrStickHGTarget(bot: Unit, lane: Lane, targetLoc?: Vector | null): Unit | null {
    const pid = bot.GetPlayerID();
    ObjectiveState[pid] = ObjectiveState[pid] || {};
    ObjectiveState[pid][lane] = ObjectiveState[pid][lane] || {};

    const state = ObjectiveState[pid][lane] as LaneState;
    const now = GameTime();
    const current = state.target || null;
    const currentScore = current ? ObjectiveScore(bot, current, targetLoc) : Number.POSITIVE_INFINITY;

    // Respect stickiness if current is valid
    if (current && UnitIsValidObjective(current) && now < (state.lockUntil ?? 0)) {
        return current;
    }

    // Scan candidates
    let best: Unit | null = null;
    let bestScore = Number.POSITIVE_INFINITY;
    for (const b of GetUnitList(UnitType.EnemyBuildings)) {
        const sc = ObjectiveScore(bot, b, targetLoc);
        if (sc < bestScore) {
            best = b;
            bestScore = sc;
        }
    }

    // Only switch if clearly better
    if (current && UnitIsValidObjective(current)) {
        if (best && bestScore + SWITCH_SCORE_MARGIN < currentScore) {
            state.target = best;
            state.lockUntil = now + OBJECTIVE_STICKY_TIME;
            return best;
        } else {
            state.lockUntil = now + 0.6;
            return current;
        }
    }

    // Adopt best if nothing valid
    if (best) {
        state.target = best;
        state.lockUntil = now + OBJECTIVE_STICKY_TIME;
        return best;
    }

    state.target = null;
    state.lockUntil = undefined;
    return null;
}

export function WhichLaneToPush(_bot: Unit, _lane: Lane): Lane {
    //   print("WhichLaneToPush for: ", bot.GetUnitName(), lane);

    // Score smaller = better
    let topLaneScore = 0;
    let midLaneScore = 0;
    let botLaneScore = 0;

    const vTop = GetLaneFrontLocation(GetTeam(), Lane.Top, 0);
    const vMid = GetLaneFrontLocation(GetTeam(), Lane.Mid, 0);
    const vBot = GetLaneFrontLocation(GetTeam(), Lane.Bot, 0);

    // Prefer lanes closer to humans/cores; de-prioritize supports’ solo pushes
    for (let i = 1; i <= GetTeamPlayers(GetTeam()).length; i++) {
        const member = GetTeamMember(i);
        if (jmz.IsValidHero(member)) {
            let topDist = GetUnitToLocationDistance(member, vTop);
            let midDist = GetUnitToLocationDistance(member, vMid);
            let botDist = GetUnitToLocationDistance(member, vBot);

            if (jmz.IsCore(member) && member && !member.IsBot()) {
                topDist *= 0.2;
                midDist *= 0.2;
                botDist *= 0.2;
            } else if (!jmz.IsCore(member)) {
                topDist *= 1.5;
                midDist *= 1.5;
                botDist *= 1.5;
            }

            topLaneScore += topDist;
            midLaneScore += midDist;
            botLaneScore += botDist;
        }
    }

    // Enemy last seen / incoming TPs near their lane fronts → inflate that lane score
    let countTop = 0,
        countMid = 0,
        countBot = 0;

    for (const id of GetTeamPlayers(GetOpposingTeam())) {
        if (IsHeroAlive(id)) {
            const info = GetHeroLastSeenInfo(id);
            if (info && info !== null) {
                const dInfo = info[0];
                if (dInfo && dInfo !== null) {
                    if (jmz.GetDistance(vTop, dInfo.location) <= 1600) countTop++;
                    else if (jmz.GetDistance(vMid, dInfo.location) <= 1600) countMid++;
                    else if (jmz.GetDistance(vBot, dInfo.location) <= 1600) countBot++;
                }
            }
        }
    }

    const hTeleports = GetIncomingTeleports();
    for (const tp of hTeleports) {
        if (tp && IsEnemyTP(tp.playerid)) {
            if (jmz.GetDistance(vTop, tp.location) <= 1600) countTop++;
            else if (jmz.GetDistance(vMid, tp.location) <= 1600) countMid++;
            else if (jmz.GetDistance(vBot, tp.location) <= 1600) countBot++;
        }
    }

    topLaneScore *= 0.05 * countTop + 1;
    midLaneScore *= 0.05 * countMid + 1;
    botLaneScore *= 0.05 * countBot + 1;

    // Prefer lanes with lower-tier outer buildings first. Start mid slightly.
    const topTier = GetLaneBuildingTier(Lane.Top);
    const midTier = GetLaneBuildingTier(Lane.Mid);
    const botTier = GetLaneBuildingTier(Lane.Bot);

    if (midTier < topTier && midTier < botTier) {
        midLaneScore *= 0.5;
        if (!jmz.Utils.IsAnyBarracksOnLaneAlive(false, Lane.Mid)) midLaneScore *= 0.5;
    } else if (topTier < midTier && topTier < botTier) {
        topLaneScore *= 0.5;
        if (!jmz.Utils.IsAnyBarracksOnLaneAlive(false, Lane.Top)) topLaneScore *= 0.5;
    } else if (botTier < topTier && botTier < midTier) {
        botLaneScore *= 0.5;
        if (!jmz.Utils.IsAnyBarracksOnLaneAlive(false, Lane.Bot)) botLaneScore *= 0.5;
    }

    // Pull toward lanes where allies already are
    topLaneScore = presence_adjust(topLaneScore, vTop);
    midLaneScore = presence_adjust(midLaneScore, vMid);
    botLaneScore = presence_adjust(botLaneScore, vBot);

    if (topLaneScore < midLaneScore && topLaneScore < botLaneScore) return Lane.Top;
    if (midLaneScore < topLaneScore && midLaneScore < botLaneScore) return Lane.Mid;
    if (botLaneScore < topLaneScore && botLaneScore < midLaneScore) return Lane.Bot;

    return Lane.Mid;
}

/* -----------------------------------------------------------------------------
 * Think loop
 * ---------------------------------------------------------------------------*/
let fNextMovementTime = 0;

export function PushThink(bot: Unit, lane: Lane): void {
    // 0) baseline action gates
    if (jmz.CanNotUseAction(bot)) return;
    if (jmz.Utils.IsBotThinkingMeaningfulAction(bot, Customize.ThinkLess, "push")) return;

    // 1) Always compute a fresh local threat picture FROM THE BOT
    const alliesHere = jmz.GetAlliesNearLoc(bot.GetLocation(), 1600);
    const enemiesHere = jmz.GetEnemiesNearLoc(bot.GetLocation(), 1600);

    // 2) Build a lane-front offset depending on our HP and attack range
    const botAttackRange = bot.GetAttackRange();
    let fDeltaFromFront =
        Math.min(jmz.GetHP(bot), 0.7) * 800 -
        500 + // healthier → stand a bit closer
        RemapValClamped(botAttackRange, 300, 700, 0, -300); // longer range → stand further back
    fDeltaFromFront = Math.max(Math.min(fDeltaFromFront, 250), -600);

    // 3) Basic tower & creep context to make hit-tower decisions safer
    const nEnemyTowers = bot.GetNearbyTowers(1200, true);
    const nAllyCreeps = bot.GetNearbyLaneCreeps(1200, false);

    // 4) If outnumbered locally OR our intended target near lane-front is backdoored,
    //    then pull the lane-front delta back substantially to avoid feeding.
    if (alliesHere.length < enemiesHere.length || IsAnyTargetBackdooredAt(bot, lane)) {
        let longestRange = 0;
        for (const enemyHero of enemiesHere) {
            if (jmz.IsValidHero(enemyHero) && !jmz.IsSuspiciousIllusion(enemyHero)) {
                const r = enemyHero.GetAttackRange();
                if (r > longestRange) longestRange = r;
            }
        }
        fDeltaFromFront = Math.max(-450, -120 - 0.35 * longestRange);
    }

    // 5) Compute our approach waypoint for this lane
    const targetLoc = GetLaneFrontLocation(GetTeam(), lane, fDeltaFromFront);

    // 6) If the nearest enemy tower is shooting (or just shot) us → kite back
    if (
        jmz.IsValidBuilding(nEnemyTowers[0]) &&
        (nEnemyTowers[0].GetAttackTarget() === bot || (nEnemyTowers[0].GetAttackTarget() !== bot && bot.WasRecentlyDamagedByTower(nAllyCreeps.length <= 2 ? 4.0 : 2.0)))
    ) {
        const nDamage = nEnemyTowers[0].GetAttackDamage() * nEnemyTowers[0].GetAttackSpeed() * 5.0 - bot.GetHealthRegen() * 5.0;
        if (bot.GetActualIncomingDamage(nDamage, DamageType.Physical) / bot.GetHealth() > 0.15 || nAllyCreeps.length > 2) {
            const retreat = Math.min(fDeltaFromFront - 200, -600);
            bot.Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), lane, retreat));
            return;
        }
    }

    // 7) Ancient-endgame logic: if we’re in range and it’s hittable, do it
    hEnemyAncient = hEnemyAncient || GetAncient(GetOpposingTeam());
    const alliesNearAncient = hEnemyAncient && jmz.GetAlliesNearLoc(hEnemyAncient.GetLocation(), 1600);
    if (
        hEnemyAncient &&
        GetUnitToUnitDistance(bot, hEnemyAncient) < 1000 &&
        jmz.CanBeAttacked(hEnemyAncient) &&
        !HasBackdoorProtect(hEnemyAncient) &&
        (GetAllyHeroesAttackingUnit(hEnemyAncient).length >= 3 ||
            GetAllyCreepsAttackingUnit(hEnemyAncient).length >= 4 ||
            hEnemyAncient.GetHealthRegen() < 20 ||
            (alliesNearAncient?.length ?? 0) >= 4)
    ) {
        bot.Action_AttackUnit(hEnemyAncient, true);
        return;
    }

    // 8) Find attackable creeps to thin out while we approach (prefer those not under tower)
    let nRange = Math.min(700 + botAttackRange, 1600);
    if (hEnemyAncient && GetUnitToUnitDistance(bot, hEnemyAncient) < 2600) {
        // bump the search radius when we’re near high ground / base
        nRange = 1600;
    }

    let nCreeps = bot.GetNearbyLaneCreeps(nRange, true);
    if (GetUnitToLocationDistance(bot, targetLoc) <= 1200) {
        // if we're *already* near the approach point, include all creeps
        nCreeps = bot.GetNearbyCreeps(nRange, true);
    }
    nCreeps = GetSpecialUnitsNearby(bot, nCreeps, nRange);

    const vTeamFountain = jmz.GetTeamFountain();
    const bTowerNearby = jmz.IsValidBuilding(nEnemyTowers[0]); // only consider creeps "in front" of tower
    for (const creep of nCreeps) {
        if (
            jmz.IsValid(creep) &&
            jmz.CanBeAttacked(creep) &&
            (!bTowerNearby || (bTowerNearby && GetUnitToLocationDistance(creep, vTeamFountain) < GetUnitToLocationDistance(nEnemyTowers[0], vTeamFountain))) &&
            !jmz.IsTormentor(creep) &&
            !jmz.IsRoshan(creep)
        ) {
            bot.Action_AttackUnit(creep, true);
            return;
        }
    }

    // 9) High-ground building priorities: barracks → towers → fillers
    // Unified high-ground objective selection with stickiness (prevents thrash)
    const hgTarget = SelectOrStickHGTarget(bot, lane, targetLoc);
    if (hgTarget) {
        if (jmz.IsInRange(bot, hgTarget, botAttackRange + 150)) {
            bot.Action_AttackUnit(hgTarget, true);
        } else {
            bot.Action_MoveToLocation(hgTarget.GetLocation());
        }
        return;
    }

    // 10) Movement fallback: path to approach point, then do small attack-move jitter to hold space
    if (GetUnitToLocationDistance(bot, targetLoc) > 500) {
        bot.Action_MoveToLocation(targetLoc);
        return;
    } else {
        if (DotaTime() >= fNextMovementTime) {
            bot.Action_AttackMove(jmz.GetRandomLocationWithinDist(targetLoc, 0, 400));
            fNextMovementTime = DotaTime() + RandomFloat(0.05, 0.3);
            return;
        }
    }
}

/* -----------------------------------------------------------------------------
 * High-ground cross-lane clearing
 * ---------------------------------------------------------------------------*/
export function TryClearingOtherLaneHighGround(_bot: Unit, vLocation: Vector): Unit | null {
    //   print("TryClearingOtherLaneHighGround for: ", bot.GetUnitName(), vLocation);

    const unitList = GetUnitList(UnitType.EnemyBuildings);

    function IsValid(building: Unit | null): building is Unit {
        return jmz.IsValidBuilding(building) && jmz.CanBeAttacked(building!) && !HasBackdoorProtect(building!);
    }

    // Prefer closest barracks first
    let hBarrackTarget: Unit | null = null;
    let best = Number.POSITIVE_INFINITY;
    for (const barrack of unitList) {
        if (
            IsValid(barrack) &&
            (barrack === GetBarracks(GetOpposingTeam(), Barracks.TopMelee) ||
                barrack === GetBarracks(GetOpposingTeam(), Barracks.TopRanged) ||
                barrack === GetBarracks(GetOpposingTeam(), Barracks.MidMelee) ||
                barrack === GetBarracks(GetOpposingTeam(), Barracks.MidRanged) ||
                barrack === GetBarracks(GetOpposingTeam(), Barracks.BotMelee) ||
                barrack === GetBarracks(GetOpposingTeam(), Barracks.BotRanged))
        ) {
            const d = GetUnitToLocationDistance(barrack, vLocation);
            if (d < best) {
                hBarrackTarget = barrack;
                best = d;
            }
        }
    }
    if (hBarrackTarget) return hBarrackTarget;

    // Then closest T3 tower
    let hTowerTarget: Unit | null = null;
    best = Number.POSITIVE_INFINITY;
    for (const tower of unitList) {
        if (
            IsValid(tower) &&
            (tower === GetTower(GetOpposingTeam(), Tower.Top3) || tower === GetTower(GetOpposingTeam(), Tower.Mid3) || tower === GetTower(GetOpposingTeam(), Tower.Bot3))
        ) {
            const d = GetUnitToLocationDistance(tower, vLocation);
            if (d < best) {
                hTowerTarget = tower;
                best = d;
            }
        }
    }
    if (hTowerTarget) return hTowerTarget;

    return null;
}

/* -----------------------------------------------------------------------------
 * Utility helpers (validation, backdoor checks, etc.)
 * ---------------------------------------------------------------------------*/

export function CanBeAttacked(building: Unit | null): boolean {
    return !!building && building.CanBeSeen() && !building.IsInvulnerable();
}

export function IsEnemyTP(nID: number): boolean {
    for (const id of GetTeamPlayers(GetOpposingTeam())) {
        if (id === nID) return true;
    }
    return false;
}

/** Estimate if staying in a tower’s zone is too dangerous over fDuration seconds */
export function IsInDangerWithinTower(hUnit: Unit, fThreshold: number, fDuration: number): boolean {
    let totalDamage = 0;
    for (const enemy of GetUnitList(UnitType.Enemies)) {
        if (jmz.IsValid(enemy) && jmz.IsInRange(hUnit, enemy, 1600) && (enemy.GetAttackTarget() === hUnit || jmz.IsChasingTarget(enemy, hUnit))) {
            totalDamage += hUnit.GetActualIncomingDamage(enemy.GetAttackDamage() * enemy.GetAttackSpeed() * fDuration, DamageType.Physical);
        }
    }
    return (totalDamage / hUnit.GetHealth()) * 1.2 > fThreshold;
}

/** Include micro-summons & dominated units into "nearby creeps" for push thinning */
export function GetSpecialUnitsNearby(bot: Unit, hUnitList: Unit[], nRadius: number): Unit[] {
    const hCreepList: Unit[] = [...hUnitList];

    for (const unit of GetUnitList(UnitType.Enemies)) {
        if (unit && unit.CanBeSeen() && jmz.IsInRange(bot, unit, nRadius)) {
            const s = unit.GetUnitName();
            if (
                s.includes("invoker_forge_spirit") ||
                s.includes("lycan_wolf") ||
                s.includes("eidolon") ||
                s.includes("beastmaster_boar") ||
                s.includes("beastmaster_greater_boar") ||
                s.includes("furion_treant") ||
                s.includes("broodmother_spiderling") ||
                s.includes("skeleton_warrior") ||
                s.includes("warlock_golem") ||
                unit.HasModifier("modifier_dominated") ||
                unit.HasModifier("modifier_chen_holy_persuasion")
            ) {
                hCreepList.push(unit);
            }
        }
    }

    return hCreepList;
}

export function IsHealthyInsideFountain(hUnit: Unit): boolean {
    return hUnit.HasModifier("modifier_fountain_aura_buff") && jmz.GetHP(hUnit) > 0.9 && jmz.GetMP(hUnit) > 0.85;
}

export function GetAllyHeroesAttackingUnit(hUnit: Unit): Unit[] {
    const out: Unit[] = [];
    for (const ally of GetUnitList(UnitType.AlliedHeroes)) {
        if (jmz.IsValidHero(ally) && !jmz.IsSuspiciousIllusion(ally) && !jmz.IsMeepoClone(ally) && ally.GetAttackTarget() === hUnit) {
            out.push(ally);
        }
    }
    return out;
}

export function GetAllyCreepsAttackingUnit(hUnit: Unit): Unit[] {
    const out: Unit[] = [];
    for (const creep of GetUnitList(UnitType.AlliedCreeps)) {
        if (jmz.IsValid(creep) && creep.GetAttackTarget() === hUnit) {
            out.push(creep);
        }
    }
    return out;
}

/** Returns 1..4 for the highest structure on that lane that is still alive on the enemy team */
export function GetLaneBuildingTier(nLane: Lane): number {
    if (nLane === Lane.Top) {
        if (GetTower(GetOpposingTeam(), Tower.Top1) !== null) return 1;
        else if (GetTower(GetOpposingTeam(), Tower.Top2) !== null) return 2;
        else if (
            GetTower(GetOpposingTeam(), Tower.Top3) !== null ||
            GetBarracks(GetOpposingTeam(), Barracks.TopMelee) !== null ||
            GetBarracks(GetOpposingTeam(), Barracks.TopRanged) !== null
        )
            return 3;
        else return 4;
    } else if (nLane === Lane.Mid) {
        if (GetTower(GetOpposingTeam(), Tower.Mid1) !== null) return 1;
        else if (GetTower(GetOpposingTeam(), Tower.Mid2) !== null) return 2;
        else if (
            GetTower(GetOpposingTeam(), Tower.Mid3) !== null ||
            GetBarracks(GetOpposingTeam(), Barracks.MidMelee) !== null ||
            GetBarracks(GetOpposingTeam(), Barracks.MidRanged) !== null
        )
            return 3;
        else return 4;
    } else if (nLane === Lane.Bot) {
        if (GetTower(GetOpposingTeam(), Tower.Bot1) !== null) return 1;
        else if (GetTower(GetOpposingTeam(), Tower.Bot2) !== null) return 2;
        else if (
            GetTower(GetOpposingTeam(), Tower.Bot3) !== null ||
            GetBarracks(GetOpposingTeam(), Barracks.BotMelee) !== null ||
            GetBarracks(GetOpposingTeam(), Barracks.BotRanged) !== null
        )
            return 3;
        else return 4;
    }
    return 1;
}

export function ShouldWaitForImportantItemsSpells(vLocation: Vector): boolean {
    if (jmz.IsMidGame() || jmz.IsLateGame()) {
        if (jmz.Utils.HasTeamMemberWithCriticalItemInCooldown(vLocation)) return true;
        if (jmz.Utils.HasTeamMemberWithCriticalSpellInCooldown(vLocation)) return true;
    }
    return false;
}

export function HasBackdoorProtect(target: Unit): boolean {
    return (
        target.HasModifier("modifier_fountain_glyph") ||
        target.HasModifier("modifier_backdoor_protection") ||
        target.HasModifier("modifier_backdoor_protection_in_base") ||
        target.HasModifier("modifier_backdoor_protection_active")
    );
}

/* -----------------------------------------------------------------------------
 * New targeted helpers to reduce thrash/jitter
 * ---------------------------------------------------------------------------*/

/**
 * Returns true if the *nearest* intended target around the enemy lane-front
 * is currently backdoored/glyphed.
 */
export function IsAnyTargetBackdooredAt(_bot: Unit, lane: Lane): boolean {
    const lf = GetLaneFrontLocation(GetTeam(), lane, 0);
    let nearest: Unit | null = null;
    let best = Number.POSITIVE_INFINITY;
    for (const b of GetUnitList(UnitType.EnemyBuildings)) {
        if (jmz.IsValidBuilding(b)) {
            const d = GetUnitToLocationDistance(b, lf);
            if (d < best) {
                nearest = b;
                best = d;
            }
        }
    }
    return !!(nearest && HasBackdoorProtect(nearest));
}

/**
 * Picks best high-ground objective with strict priority:
 *   1) Barracks: melee > ranged (closest of each class)
 *   2) Tier-3 towers (closest)
 *   3) Fillers/others (closest)
 * Radius is the max distance from the bot; tie-breaker favors closer to targetLoc.
 */
export function FindBestHGTarget(bot: Unit, radius: number, targetLoc?: Vector | null): Unit | null {
    const isBarracks = (u: Unit) => u.GetUnitName().includes("rax");
    const isMeleeBarracks = (u: Unit) => u.GetUnitName().includes("melee");
    const isRangedBarracks = (u: Unit) => u.GetUnitName().includes("ranged");
    const isT3Tower = (u: Unit) =>
        u === GetTower(GetOpposingTeam(), Tower.Top3) || u === GetTower(GetOpposingTeam(), Tower.Mid3) || u === GetTower(GetOpposingTeam(), Tower.Bot3);
    const isT4Tower = (u: Unit) => u === GetTower(GetOpposingTeam(), Tower.Base1) || u === GetTower(GetOpposingTeam(), Tower.Base2);

    let bestMelee: Unit | null = null,
        bestMeleeD = Number.POSITIVE_INFINITY;
    let bestRanged: Unit | null = null,
        bestRangedD = Number.POSITIVE_INFINITY;
    let bestT3: Unit | null = null,
        bestT3D = Number.POSITIVE_INFINITY;
    let bestT4: Unit | null = null,
        bestT4D = Number.POSITIVE_INFINITY;
    let bestOther: Unit | null = null,
        bestOtherD = Number.POSITIVE_INFINITY;

    for (const b of GetUnitList(UnitType.EnemyBuildings)) {
        if (jmz.IsValidBuilding(b) && jmz.CanBeAttacked(b) && !HasBackdoorProtect(b)) {
            const dBot = GetUnitToUnitDistance(bot, b);
            if (dBot <= radius) {
                // prefer closer to our approach point when bot-distance is similar
                const dLoc = targetLoc ? GetUnitToLocationDistance(b, targetLoc) : 0;

                if (isBarracks(b)) {
                    if (isMeleeBarracks(b)) {
                        if (dBot < bestMeleeD || (dBot === bestMeleeD && dLoc < (bestMelee ? GetUnitToLocationDistance(bestMelee, targetLoc!) : dLoc))) {
                            bestMelee = b;
                            bestMeleeD = dBot;
                        }
                    } else if (isRangedBarracks(b)) {
                        if (dBot < bestRangedD || (dBot === bestRangedD && dLoc < (bestRanged ? GetUnitToLocationDistance(bestRanged, targetLoc!) : dLoc))) {
                            bestRanged = b;
                            bestRangedD = dBot;
                        }
                    }
                } else if (isT3Tower(b)) {
                    if (dBot < bestT3D || (dBot === bestT3D && dLoc < (bestT3 ? GetUnitToLocationDistance(bestT3, targetLoc!) : dLoc))) {
                        bestT3 = b;
                        bestT3D = dBot;
                    }
                } else if (isT4Tower(b)) {
                    if (dBot < bestT4D || (dBot === bestT4D && dLoc < (bestT4 ? GetUnitToLocationDistance(bestT4, targetLoc!) : dLoc))) {
                        bestT4 = b;
                        bestT4D = dBot;
                    }
                } else {
                    if (dBot < bestOtherD || (dBot === bestOtherD && dLoc < (bestOther ? GetUnitToLocationDistance(bestOther, targetLoc!) : dLoc))) {
                        bestOther = b;
                        bestOtherD = dBot;
                    }
                }
            }
        }
    }

    return bestMelee || bestRanged || bestT3 || bestOther;
}
