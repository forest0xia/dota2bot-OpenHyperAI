local ____lualib = require("lualib_bundle")
local __TS__ArrayReduce = ____lualib.__TS__ArrayReduce
local ____exports = {}
local furthestBuildings, PING_TIME_DELTA
local jmz = require("bots.FunLib.jmz_func")
local ____dota = require("bots.ts_libs.dota.index")
local BotActionDesire = ____dota.BotActionDesire
local BotMode = ____dota.BotMode
local BotModeDesire = ____dota.BotModeDesire
local BotScriptEnums = ____dota.BotScriptEnums
local Lane = ____dota.Lane
local UnitType = ____dota.UnitType
local ____utils = require("bots.FunLib.utils")
local GameStates = ____utils.GameStates
local IsPingedByAnyPlayer = ____utils.IsPingedByAnyPlayer
local IsValidHero = ____utils.IsValidHero
local ____native_2Doperators = require("bots.ts_libs.utils.native-operators")
local add = ____native_2Doperators.add
function ____exports.GetDefendDesireHelper(bot, lane)
    local defendDesire = 0
    local enemiesInRange = jmz.GetLastSeenEnemiesNearLoc(
        bot:GetLocation(),
        2200
    )
    local team = bot:GetTeam()
    local botPosition = jmz.GetPosition(bot)
    if #enemiesInRange > 0 and GetUnitToLocationDistance(
        bot,
        GetLaneFrontLocation(team, lane, 0)
    ) < 1000 then
        return BotModeDesire.None
    end
    if bot:GetAssignedLane() ~= lane and botPosition == 1 and jmz.IsInLaningPhase() then
        return BotModeDesire.None
    end
    if jmz.IsDoingRoshan(bot) and #jmz.GetAlliesNearLoc(
        bot:GetLocation(),
        2800
    ) >= 3 or jmz.IsDoingTormentor(bot) and #jmz.GetAlliesNearLoc(
        jmz.GetTormentorLocation(team),
        900
    ) >= 2 and #jmz.GetEnemiesAroundAncient() > 0 then
        return BotModeDesire.None
    end
    local botLevel = bot:GetLevel()
    if botPosition == 1 and botLevel < 8 or botPosition == 2 and botLevel < 6 or botPosition == 3 and botLevel < 6 or botPosition == 4 and botLevel < 5 or botPosition == 5 and botLevel < 5 then
        return BotModeDesire.None
    end
    local ping = IsPingedByAnyPlayer(bot, PING_TIME_DELTA, nil, nil)
    if ping ~= nil then
        local isPinged, pingedLane = jmz.IsPingCloseToValidTower(team, ping)
        if isPinged and pingedLane == lane then
            return 0.92
        end
    end
    GameStates.defendPings = GameStates.defendPings or ({pingedTime = GameTime()})
    if GameTime() - GameStates.defendPings.pingedTime > PING_TIME_DELTA then
        local highGroundTowers = {
            TOWER_TOP_3,
            TOWER_MID_3,
            TOWER_BOT_3,
            TOWER_BASE_1,
            TOWER_BASE_2
        }
        local enemyIsPushingBase = false
        local defendLocation = nil
        for ____, towerId in ipairs(highGroundTowers) do
            local tower = GetTower(team, towerId)
            if tower ~= nil and tower:GetHealth() / tower:GetMaxHealth() < 0.8 and #jmz.GetLastSeenEnemiesNearLoc(
                tower:GetLocation(),
                1200
            ) >= 1 then
                defendLocation = tower:GetLocation()
                enemyIsPushingBase = true
            end
        end
        if not enemyIsPushingBase and #jmz.GetLastSeenEnemiesNearLoc(
            GetAncient(team):GetLocation(),
            1200
        ) >= 1 then
            defendLocation = GetAncient(team):GetLocation()
            enemyIsPushingBase = true
        end
        if defendLocation ~= nil and enemyIsPushingBase then
            local saferLocation = add(
                jmz.AdjustLocationWithOffsetTowardsFountain(defendLocation, 850),
                RandomVector(50)
            )
            enemyIsPushingBase = false
            local defendingAllies = jmz.GetAlliesNearLoc(saferLocation, 2500)
            if #defendingAllies < jmz.GetNumOfAliveHeroes(false) then
                GameStates.defendPings.pingedTime = GameTime()
                bot:ActionImmediate_Chat("Please come defending", false)
                bot:ActionImmediate_Ping(saferLocation.x, saferLocation.y, false)
            end
            defendDesire = 0.966
        end
    end
    local enemiesAroundAncient = jmz.GetEnemiesAroundAncient()
    local ancientDefendDesire = BotModeDesire.Absolute
    local midTowerDestroyed = GetTower(team, TOWER_MID_3) == nil
    local laneTowersDestroyed = GetTower(team, TOWER_TOP_3) == nil and GetTower(team, TOWER_BOT_3) == nil
    if #enemiesAroundAncient >= 1 and (midTowerDestroyed or laneTowersDestroyed) and lane == Lane.Mid then
        defendDesire = defendDesire + ancientDefendDesire
    elseif defendDesire ~= 0.966 then
        local multiplier = ____exports.GetEnemyAmountMul(lane)
        defendDesire = Clamp(
            GetDefendLaneDesire(lane),
            0.1,
            1
        ) * multiplier
    end
    return RemapValClamped(
        jmz.GetHP(bot),
        1,
        0,
        Clamp(defendDesire, 0, 1.25),
        BotActionDesire.None
    )
end
function ____exports.GetFurthestBuildingOnLane(lane)
    local bot = GetBot()
    local team = bot:GetTeam()
    local laneBuilding = furthestBuildings[lane]
    for ____, towerConfig in ipairs(laneBuilding.towers) do
        do
            local __continue39
            repeat
                local tower = GetTower(team, towerConfig.id)
                if not ____exports.IsValidBuildingTarget(tower) then
                    __continue39 = true
                    break
                end
                local health = tower:GetHealth() / tower:GetMaxHealth()
                return tower, RemapValClamped(
                    health,
                    0.25,
                    1,
                    towerConfig.mulMin,
                    towerConfig.mulMax
                )
            until true
            if not __continue39 then
                break
            end
        end
    end
    for ____, barracksId in ipairs(laneBuilding.barracks) do
        do
            local __continue42
            repeat
                local barracks = GetBarracks(team, barracksId)
                if not ____exports.IsValidBuildingTarget(barracks) then
                    __continue42 = true
                    break
                end
                return barracks, 2.5
            until true
            if not __continue42 then
                break
            end
        end
    end
    local ancient = GetAncient(team)
    if ____exports.IsValidBuildingTarget(ancient) then
        return ancient, 3
    end
    return nil, 1
end
function ____exports.IsValidBuildingTarget(unit)
    return unit ~= nil and unit:IsAlive() and unit:IsBuilding() and unit:CanBeSeen()
end
function ____exports.GetEnemyAmountMul(lane)
    local heroCount = ____exports.GetEnemyCountInLane(lane, true)
    local creepCount = ____exports.GetEnemyCountInLane(lane, false)
    local _, urgency = ____exports.GetFurthestBuildingOnLane(lane)
    return RemapValClamped(
        heroCount,
        1,
        3,
        1,
        2
    ) * RemapValClamped(
        creepCount,
        1,
        5,
        1,
        1.25
    ) * urgency
end
function ____exports.GetEnemyCountInLane(lane, isHero)
    local laneFront = GetLaneFrontLocation(
        GetTeam(),
        lane,
        0
    )
    local units = isHero and GetUnitList(UnitType.EnemyHeroes) or GetUnitList(UnitType.EnemyCreeps)
    return __TS__ArrayReduce(
        units,
        function(____, count, unit)
            if not jmz.IsValid(unit) then
                return count
            end
            local distance = GetUnitToLocationDistance(unit, laneFront)
            if distance < 1300 and not (isHero and jmz.IsSuspiciousIllusion(unit)) then
                return count + 1
            end
            return count
        end,
        0
    )
end
furthestBuildings = {[Lane.Top] = {towers = {{id = TOWER_TOP_1, mulMax = 0.5, mulMin = 1}, {id = TOWER_TOP_2, mulMax = 1, mulMin = 2}, {id = TOWER_TOP_3, mulMax = 1.5, mulMin = 2}}, barracks = {BARRACKS_TOP_MELEE, BARRACKS_TOP_RANGED}}, [Lane.Bot] = {towers = {{id = TOWER_BOT_1, mulMax = 0.5, mulMin = 1}, {id = TOWER_BOT_2, mulMax = 1, mulMin = 2}, {id = TOWER_BOT_3, mulMax = 1.5, mulMin = 2}}, barracks = {BARRACKS_BOT_MELEE, BARRACKS_BOT_RANGED}}, [Lane.Mid] = {towers = {{id = TOWER_MID_1, mulMax = 0.5, mulMin = 1}, {id = TOWER_MID_2, mulMax = 1, mulMin = 2}, {id = TOWER_MID_3, mulMax = 1.5, mulMin = 2}}, barracks = {BARRACKS_MID_MELEE, BARRACKS_MID_RANGED}}}
PING_TIME_DELTA = 5
local TELEPORT_SLOT = 15
local ENEMY_SEARCH_RANGE = 1400
function ____exports.GetDefendDesire(bot, lane)
    if bot.DefendLaneDesire == nil then
        bot.DefendLaneDesire = {0, 0, 0}
    end
    bot.DefendLaneDesire[lane + 1] = ____exports.GetDefendDesireHelper(bot, lane)
    local mostDesiredLane, _ = jmz.GetMostDefendLaneDesire()
    bot.laneToDefend = mostDesiredLane
    if mostDesiredLane ~= lane then
        return bot.DefendLaneDesire[lane + 1] * 0.8
    end
    return bot.DefendLaneDesire[lane + 1]
end
function ____exports.DefendThink(bot, lane)
    if not jmz.CanNotUseAction(bot) then
        return
    end
    local laneFrontLocation = GetLaneFrontLocation(
        bot:GetTeam(),
        lane,
        0
    )
    local teleports = bot:GetItemInSlot(TELEPORT_SLOT)
    local saferLocation = jmz.AdjustLocationWithOffsetTowardsFountain(laneFrontLocation, 260)
    local bestTeleportLocation = jmz.GetNearbyLocationToTp(saferLocation)
    local distanceToLane = GetUnitToLocationDistance(bot, laneFrontLocation)
    if distanceToLane > 3500 and not bot:WasRecentlyDamagedByAnyHero(2) then
        if teleports == nil then
            bot:Action_MoveToLocation(add(
                saferLocation,
                RandomVector(30)
            ))
            return
        end
        bot:Action_UseAbilityOnLocation(
            teleports,
            add(
                bestTeleportLocation,
                RandomVector(30)
            )
        )
        return
    end
    if distanceToLane > 2000 and distanceToLane <= 3000 and not bot:WasRecentlyDamagedByAnyHero(3) then
        bot:Action_MoveToLocation(add(
            saferLocation,
            RandomVector(30)
        ))
    elseif distanceToLane <= 2000 and bot:GetTarget() == nil then
        local nearbyHeroes = jmz.GetHeroesNearLocation(true, laneFrontLocation, 1300)
        for ____, enemy in ipairs(nearbyHeroes) do
            if IsValidHero(enemy) then
                bot:SetTarget(enemy)
                return
            end
        end
    end
    if distanceToLane < ENEMY_SEARCH_RANGE then
        local attackRange = bot:GetAttackRange()
        local enemySearchRange = attackRange < 600 and 600 or math.min(attackRange + 100, ENEMY_SEARCH_RANGE)
        local enemiesInRange = bot:GetNearbyHeroes(enemySearchRange, true, BotMode.None)
        for ____, enemy in ipairs(enemiesInRange) do
            if IsValidHero(enemy) then
                bot:SetTarget(enemy)
                return
            end
        end
        local nearbyLaneCreeps = bot:GetNearbyCreeps(900, true)
        if #nearbyLaneCreeps > 0 then
            local targetCreep = __TS__ArrayReduce(
                nearbyLaneCreeps,
                function(____, prev, current)
                    local attack = prev and prev:GetAttackDamage() or 0
                    if jmz.IsValid(current) and jmz.CanBeAttacked(current) and current:GetAttackDamage() > attack then
                        return current
                    end
                    return prev
                end,
                nil
            )
            if targetCreep ~= nil then
                bot:Action_AttackUnit(targetCreep, true)
                return
            end
        end
    end
    bot:Action_MoveToLocation(add(
        saferLocation,
        RandomVector(75)
    ))
end
function ____exports.OnEnd(bot, lane)
    if bot.DefendLaneDesire == nil then
        return
    end
    bot.DefendLaneDesire[lane + 1] = 0
end
return ____exports
