/** @noResolution */
import * as jmz from "bots/FunLib/jmz_func";
import {
    Barracks,
    BotActionDesire,
    BotMode,
    BotModeDesire,
    Lane,
    Tower,
    Unit,
    UnitType,
    Vector,
} from "bots/ts_libs/dota";
import {
    GameStates,
    IsPingedByAnyPlayer,
    IsValidHero,
    HighGroundTowers,
} from "bots/FunLib/utils";
import { add } from "bots/ts_libs/utils/native-operators";

const furthestBuildings = {
    [Lane.Top]: {
        towers: [
            { id: Tower.Top1, mulMax: 0.5, mulMin: 1 },
            { id: Tower.Top2, mulMax: 1, mulMin: 2 },
            { id: Tower.Top3, mulMax: 1.5, mulMin: 2 },
        ],
        barracks: [Barracks.TopMelee, Barracks.TopRanged],
    },
    [Lane.Bot]: {
        towers: [
            { id: Tower.Bot1, mulMax: 0.5, mulMin: 1 },
            { id: Tower.Bot2, mulMax: 1, mulMin: 2 },
            { id: Tower.Bot3, mulMax: 1.5, mulMin: 2 },
        ],
        barracks: [Barracks.BotMelee, Barracks.BotRanged],
    },
    [Lane.Mid]: {
        towers: [
            { id: Tower.Mid1, mulMax: 0.5, mulMin: 1 },
            { id: Tower.Mid2, mulMax: 1, mulMin: 2 },
            { id: Tower.Mid3, mulMax: 1.5, mulMin: 2 },
        ],
        barracks: [Barracks.MidMelee, Barracks.MidRanged],
    },
};

const PING_TIME_DELTA = 5;
const TELEPORT_SLOT = 15;
const ENEMY_SEARCH_RANGE = 1400;

export function GetDefendDesire(bot: Unit, lane: Lane): number {
    if (bot.DefendLaneDesire == null) {
        bot.DefendLaneDesire = [0, 0, 0];
    }

    bot.DefendLaneDesire[lane] = GetDefendDesireHelper(bot, lane);
    const [mostDesiredLane, _] = jmz.GetMostDefendLaneDesire();
    bot.laneToDefend = mostDesiredLane;
    if (mostDesiredLane !== lane) {
        return bot.DefendLaneDesire[lane] * 0.8;
    }
    return bot.DefendLaneDesire[lane];
}

export function GetDefendDesireHelper(bot: Unit, lane: Lane): BotModeDesire {
    let defendDesire = 0;
    const enemiesInRange = jmz.GetLastSeenEnemiesNearLoc(
        bot.GetLocation(),
        2200
    );
    const team = bot.GetTeam(); // Was GetTeam() previously, I think it should be better to use bot.GetTeam() here
    const botPosition = jmz.GetPosition(bot);
    if (
        enemiesInRange.length > 0 &&
        GetUnitToLocationDistance(bot, GetLaneFrontLocation(team, lane, 0)) <
            1000
    ) {
        return BotModeDesire.None;
    }
    if (
        // Reduce carry feeds
        bot.GetAssignedLane() !== lane &&
        botPosition == 1 &&
        jmz.IsInLaningPhase()
    ) {
        return BotModeDesire.None;
    }
    if (
        (jmz.IsDoingRoshan(bot) &&
            jmz.GetAlliesNearLoc(bot.GetLocation(), 2800).length >= 3) ||
        (jmz.IsDoingTormentor(bot) &&
            jmz.GetAlliesNearLoc(jmz.GetTormentorLocation(team), 900).length >=
                2 &&
            jmz.GetEnemiesAroundAncient(bot, 2200) > 0)
    ) {
        return BotModeDesire.None;
    }

    const botLevel = bot.GetLevel();
    if (
        (botPosition === 1 && botLevel < 8) ||
        (botPosition === 2 && botLevel < 6) ||
        (botPosition === 3 && botLevel < 6) ||
        (botPosition === 4 && botLevel < 5) ||
        (botPosition === 5 && botLevel < 5)
    ) {
        return BotModeDesire.None;
    }
    // Pinged by bots or players to defend
    const ping = IsPingedByAnyPlayer(bot, PING_TIME_DELTA, null, null);
    if (ping !== null) {
        const [isPinged, pingedLane] = jmz.IsPingCloseToValidTower(team, ping);
        if (isPinged && pingedLane === lane) {
            return 0.92;
        }
    }

    // -- 判断是否要提醒回防
    GameStates.defendPings = GameStates.defendPings || {
        pingedTime: GameTime(),
    };
    if (GameTime() - GameStates.defendPings.pingedTime > PING_TIME_DELTA) {
        let enemyIsPushingBase = false;
        let defendLocation: Vector | null = null;
        for (const towerId of HighGroundTowers) {
            const tower = GetTower(team, towerId);
            if (
                tower !== null &&
                tower.GetHealth() / tower.GetMaxHealth() < 0.8 &&
                jmz.GetLastSeenEnemiesNearLoc(tower.GetLocation(), 1200)
                    .length >= 1
            ) {
                defendLocation = tower.GetLocation();
                enemyIsPushingBase = true;
            }
        }
        if (
            !enemyIsPushingBase &&
            jmz.GetLastSeenEnemiesNearLoc(GetAncient(team).GetLocation(), 1200)
                .length >= 1
        ) {
            defendLocation = GetAncient(team).GetLocation();
            enemyIsPushingBase = true;
        }

        if (defendLocation !== null && enemyIsPushingBase) {
            const saferLocation = add(
                jmz.AdjustLocationWithOffsetTowardsFountain(
                    defendLocation,
                    850
                ),
                RandomVector(50)
            );
            enemyIsPushingBase = false;
            const defendingAllies = jmz.GetAlliesNearLoc(saferLocation, 2500);
            if (defendingAllies.length < jmz.GetNumOfAliveHeroes(false)) {
                GameStates.defendPings.pingedTime = GameTime();
                bot.ActionImmediate_Chat("Please come defending", false);
                bot.ActionImmediate_Ping(
                    saferLocation.x,
                    saferLocation.y,
                    false
                );
            }
            defendDesire = 0.966;
        }
    }
    const enemiesAroundAncient = jmz.GetEnemiesAroundAncient(bot, 2200);
    let ancientDefendDesire = BotModeDesire.Absolute;
    const midTowerDestroyed = GetTower(team, Tower.Mid3) === null;
    const laneTowersDestroyed =
        GetTower(team, Tower.Top3) === null &&
        GetTower(team, Tower.Bot3) === null;
    if (
        enemiesAroundAncient >= 1 &&
        (midTowerDestroyed || laneTowersDestroyed) &&
        lane === Lane.Mid
    ) {
        defendDesire += ancientDefendDesire;
    } else if (defendDesire !== 0.966) {
        // TODO: Refactor, if condition seems really hacky

        const multiplier = GetEnemyAmountMul(lane);
        defendDesire = Clamp(GetDefendLaneDesire(lane), 0.1, 1) * multiplier;
    }
    return RemapValClamped(
        jmz.GetHP(bot),
        1,
        0,
        Clamp(defendDesire, 0, 1.25),
        BotActionDesire.None
    );
}

export function DefendThink(bot: Unit, lane: Lane) {
    if (!jmz.CanNotUseAction(bot)) {
        return;
    }

    const laneFrontLocation = GetLaneFrontLocation(bot.GetTeam(), lane, 0);
    const teleports = bot.GetItemInSlot(TELEPORT_SLOT);
    const saferLocation = jmz.AdjustLocationWithOffsetTowardsFountain(
        laneFrontLocation,
        260
    );
    const bestTeleportLocation = jmz.GetNearbyLocationToTp(saferLocation);
    const distanceToLane = GetUnitToLocationDistance(bot, laneFrontLocation);
    if (distanceToLane > 3500 && !bot.WasRecentlyDamagedByAnyHero(2)) {
        if (teleports === null) {
            bot.Action_MoveToLocation(add(saferLocation, RandomVector(30)));
            return;
        }
        bot.Action_UseAbilityOnLocation(
            teleports,
            add(bestTeleportLocation, RandomVector(30))
        );
        return;
    }

    if (
        distanceToLane > 2000 &&
        distanceToLane <= 3000 &&
        !bot.WasRecentlyDamagedByAnyHero(3)
    ) {
        bot.Action_MoveToLocation(add(saferLocation, RandomVector(30)));
    } else if (distanceToLane <= 2000 && bot.GetTarget() === null) {
        const nearbyHeroes = jmz.GetHeroesNearLocation(
            true,
            laneFrontLocation,
            1300
        );
        for (const enemy of nearbyHeroes) {
            if (IsValidHero(enemy)) {
                bot.SetTarget(enemy);
                return;
            }
        }
    }

    if (distanceToLane < ENEMY_SEARCH_RANGE) {
        const attackRange = bot.GetAttackRange();
        const enemySearchRange =
            (attackRange < 600 && 600) ||
            math.min(attackRange + 100, ENEMY_SEARCH_RANGE);
        const enemiesInRange = bot.GetNearbyHeroes(
            enemySearchRange,
            true,
            BotMode.None
        );
        // Changed from
        // if J.IsValidHero(nInRangeEnemy[1])
        // then
        // 	bot:SetTarget( nInRangeEnemy[1] )
        // 	return
        // end
        for (const enemy of enemiesInRange) {
            if (IsValidHero(enemy)) {
                bot.SetTarget(enemy);
                return;
            }
        }

        const nearbyLaneCreeps = bot.GetNearbyCreeps(900, true);
        if (nearbyLaneCreeps.length > 0) {
            let targetCreep = nearbyLaneCreeps.reduce(
                (prev: Unit | null, current) => {
                    const attack = prev ? prev.GetAttackDamage() : 0;
                    if (
                        jmz.IsValid(current) &&
                        jmz.CanBeAttacked(current) &&
                        current.GetAttackDamage() > attack
                    ) {
                        return current;
                    }
                    return prev;
                },
                null
            );
            if (targetCreep !== null) {
                bot.Action_AttackUnit(targetCreep, true);
                return;
            }
        }
    }
    bot.Action_MoveToLocation(add(saferLocation, RandomVector(75)));
}

export function GetFurthestBuildingOnLane(
    lane: Lane
): LuaMultiReturn<[Unit, number] | [null, number]> {
    const bot = GetBot();
    const team = bot.GetTeam();
    const laneBuilding = furthestBuildings[lane];
    for (const towerConfig of laneBuilding.towers) {
        const tower = GetTower(team, towerConfig.id);
        if (!IsValidBuildingTarget(tower)) {
            continue;
        }
        const health = tower.GetHealth() / tower.GetMaxHealth();
        return $multi(
            tower,
            RemapValClamped(
                health,
                0.25,
                1,
                towerConfig.mulMin,
                towerConfig.mulMax
            )
        );
    }
    for (const barracksId of laneBuilding.barracks) {
        const barracks = GetBarracks(team, barracksId);
        if (!IsValidBuildingTarget(barracks)) {
            continue;
        }
        return $multi(barracks, 2.5);
    }

    const ancient = GetAncient(team);
    if (IsValidBuildingTarget(ancient)) {
        return $multi(ancient, 3);
    }

    return $multi(null, 1);
}

export function IsValidBuildingTarget(unit: Unit | null): unit is Unit {
    return (
        unit !== null && unit.IsAlive() && unit.IsBuilding() && unit.CanBeSeen()
    );
}

export function GetEnemyAmountMul(lane: Lane) {
    const heroCount = GetEnemyCountInLane(lane, true);
    const creepCount = GetEnemyCountInLane(lane, false);
    const [_, urgency] = GetFurthestBuildingOnLane(lane);
    return (
        RemapValClamped(heroCount, 1, 3, 1, 2) *
        RemapValClamped(creepCount, 1, 5, 1, 1.25) *
        urgency
    );
}

export function GetEnemyCountInLane(lane: Lane, isHero: boolean): number {
    const laneFront = GetLaneFrontLocation(GetTeam(), lane, 0);
    const units = isHero
        ? GetUnitList(UnitType.EnemyHeroes)
        : GetUnitList(UnitType.EnemyCreeps);

    return units.reduce((count, unit) => {
        if (!jmz.IsValid(unit)) {
            return count;
        }
        const distance = GetUnitToLocationDistance(unit, laneFront);
        if (distance < 1300 && !(isHero && jmz.IsSuspiciousIllusion(unit))) {
            return count + 1;
        }
        return count;
    }, 0);
}

export function OnEnd(bot: Unit, lane: Lane) {
    if (bot.DefendLaneDesire === null) {
        return;
    }
    bot.DefendLaneDesire[lane] = 0;
}
