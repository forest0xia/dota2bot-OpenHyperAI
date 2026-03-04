--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ArrayFilter(self, callbackfn, thisArg)
    local result = {}
    local len = 0
    for i = 1, #self do
        if callbackfn(thisArg, self[i], i - 1, self) then
            len = len + 1
            result[len] = self[i]
        end
    end
    return result
end

local function __TS__StringIncludes(self, searchString, position)
    if not position then
        position = 1
    else
        position = position + 1
    end
    local index = string.find(self, searchString, position, true)
    return index ~= nil
end
-- End of Lua Library inline imports
local ____exports = {}
local updateGameStateCache, updateLocationStateCache, updateUnitStateCache, presence_adjust, pingTimeDelta, StartToPushTime, BOT_MODE_DESIRE_EXTRA_LOW, hEnemyAncient, PUSH_CACHE_TTL, gameStateCache, locationStateCache, unitStateCache, BASE_ANC_RADIUS
local jmz = require(GetScriptDirectory().."/FunLib/jmz_func")
local ____dota = require(GetScriptDirectory().."/ts_libs/dota/index")
local Barracks = ____dota.Barracks
local BotMode = ____dota.BotMode
local BotModeDesire = ____dota.BotModeDesire
local DamageType = ____dota.DamageType
local Lane = ____dota.Lane
local Tower = ____dota.Tower
local UnitType = ____dota.UnitType
local ____utils = require(GetScriptDirectory().."/FunLib/utils")
local IsValidUnit = ____utils.IsValidUnit
local ____global_cache = require(GetScriptDirectory().."/FunLib/global_cache")
local getGlobalGameState = ____global_cache.getGlobalGameState
local getGlobalLocationState = ____global_cache.getGlobalLocationState
local getCachedAlliesNearLoc = ____global_cache.getCachedAlliesNearLoc
local getCachedEnemiesNearLoc = ____global_cache.getCachedEnemiesNearLoc
local autoCleanupCache = ____global_cache.autoCleanupCache
local getCachedData = ____global_cache.getCachedData
function updateGameStateCache()
    local now = DotaTime()
    if gameStateCache and now - gameStateCache.lastUpdate < PUSH_CACHE_TTL then
        return gameStateCache
    end
    local team = GetTeam()
    local enemyTeam = GetOpposingTeam()
    local currentTime = DotaTime()
    local gameMode = GetGameMode()
    local adjustedTime = gameMode == 23 and currentTime * 2 or currentTime
    gameStateCache = {
        lastUpdate = now,
        currentTime = adjustedTime,
        gameMode = gameMode,
        team = team,
        enemyTeam = enemyTeam,
        ourAncient = GetAncient(team),
        enemyAncient = GetAncient(enemyTeam),
        aliveAllyCount = jmz.GetNumOfAliveHeroes(false),
        aliveEnemyCount = jmz.GetNumOfAliveHeroes(true),
        aliveAllyCoreCount = jmz.GetAliveCoreCount(false),
        aliveEnemyCoreCount = jmz.GetAliveCoreCount(true),
        teamNetworth = (jmz.GetInventoryNetworth()),
        enemyNetworth = select(
            2,
            jmz.GetInventoryNetworth()
        ),
        averageLevel = jmz.GetAverageLevel(false),
        hasAegis = jmz.DoesTeamHaveAegis(),
        isEarlyGame = jmz.IsEarlyGame(),
        isMidGame = jmz.IsMidGame(),
        isLateGame = jmz.IsLateGame(),
        isLaningPhase = jmz.IsInLaningPhase()
    }
    return gameStateCache
end
function updateLocationStateCache()
    local now = DotaTime()
    if locationStateCache and now - locationStateCache.lastUpdate < PUSH_CACHE_TTL then
        return locationStateCache
    end
    local team = GetTeam()
    locationStateCache = {
        lastUpdate = now,
        laneFronts = {
            [Lane.Top] = GetLaneFrontLocation(team, Lane.Top, 0),
            [Lane.Mid] = GetLaneFrontLocation(team, Lane.Mid, 0),
            [Lane.Bot] = GetLaneFrontLocation(team, Lane.Bot, 0)
        },
        teamFountain = jmz.GetTeamFountain(),
        enemyFountain = jmz.GetTeamFountain(),
        roshanLocation = jmz.GetCurrentRoshanLocation(),
        tormentorLocation = jmz.GetTormentorLocation(team),
        tormentorWaitingLocation = jmz.GetTormentorWaitingLocation(team)
    }
    return locationStateCache
end
function updateUnitStateCache()
    local now = DotaTime()
    if unitStateCache and now - unitStateCache.lastUpdate < PUSH_CACHE_TTL then
        return unitStateCache
    end
    unitStateCache = {
        lastUpdate = now,
        enemyBuildings = GetUnitList(UnitType.EnemyBuildings),
        alliedHeroes = GetUnitList(UnitType.AlliedHeroes),
        enemyHeroes = __TS__ArrayFilter(
            GetUnitList(UnitType.Enemies),
            function(____, u) return jmz.IsValidHero(u) end
        ),
        alliedCreeps = GetUnitList(UnitType.AlliedCreeps),
        enemyCreeps = __TS__ArrayFilter(
            GetUnitList(UnitType.Enemies),
            function(____, u) return u:IsCreep() or u:IsAncientCreep() end
        )
    }
    return unitStateCache
end
function ____exports.GetPushDesireHelper(bot, lane)
    if bot.laneToPush == nil then
        bot.laneToPush = lane
    end
    autoCleanupCache()
    local gameState = getGlobalGameState()
    local locationState = getGlobalLocationState()
    local nMaxDesire = 0.82
    local nSearchRange = 2000
    local botActiveMode = bot:GetActiveMode()
    local nModeDesire = bot:GetActiveModeDesire()
    local bMyLane = bot:GetAssignedLane() == lane
    local isMidOrEarlyGame = gameState.isEarlyGame or gameState.isMidGame
    hEnemyAncient = gameState.enemyAncient
    local alliesHere = getCachedAlliesNearLoc(
        bot:GetLocation(),
        1600
    )
    local enemiesHere = getCachedEnemiesNearLoc(
        bot:GetLocation(),
        1600
    )
    local team = gameState.team
    local ourAncient = gameState.ourAncient
    local enemiesAtAncient = jmz.Utils.CountEnemyHeroesNear(
        ourAncient:GetLocation(),
        BASE_ANC_RADIUS
    )
    if enemiesAtAncient >= 1 then
        return BotModeDesire.ExtraLow
    end
    if botActiveMode == BotMode.PushTowerTop then
        bot.laneToPush = Lane.Top
    elseif botActiveMode == BotMode.PushTowerMid then
        bot.laneToPush = Lane.Mid
    elseif botActiveMode == BotMode.PushTowerBot then
        bot.laneToPush = Lane.Bot
    end
    local currentTime = gameState.currentTime
    jmz.Utils.GameStates = jmz.Utils.GameStates or ({})
    jmz.Utils.GameStates.defendPings = jmz.Utils.GameStates.defendPings or ({pingedTime = GameTime()})
    if GameTime() - jmz.Utils.GameStates.defendPings.pingedTime <= 5 then
        return BotModeDesire.None
    end
    if not bMyLane and jmz.IsCore(bot) and gameState.isLaningPhase or jmz.IsDoingRoshan(bot) and #jmz.GetAlliesNearLoc(locationState.roshanLocation, 2800) >= 3 or isMidOrEarlyGame and (#jmz.GetAlliesNearLoc(locationState.tormentorLocation, 1600) >= 3 or #jmz.GetAlliesNearLoc(locationState.tormentorWaitingLocation, 2500) >= 3) then
        return BOT_MODE_DESIRE_EXTRA_LOW
    end
    do
        local i = 1
        while i <= #GetTeamPlayers(team) do
            local member = GetTeamMember(i)
            if member ~= nil and member:GetLevel() < 6 then
                return BotModeDesire.None
            end
            i = i + 1
        end
    end
    local nH = jmz.Utils.NumHumanBotPlayersInTeam(GetOpposingTeam())
    if nH > 0 and currentTime <= StartToPushTime then
        return BOT_MODE_DESIRE_EXTRA_LOW
    end
    if jmz.IsDefending(bot) and nModeDesire >= 0.8 then
        nMaxDesire = 0.75
    end
    local human, humanPing = jmz.GetHumanPing()
    if human ~= nil and humanPing ~= nil and not humanPing.normal_ping and DotaTime() > 0 then
        local isPinged, pingedLane = jmz.IsPingCloseToValidTower(
            GetOpposingTeam(),
            humanPing,
            700,
            5
        )
        if isPinged and lane == pingedLane and GameTime() < humanPing.time + pingTimeDelta then
            return 0.9
        end
    end
    if hEnemyAncient and hEnemyAncient ~= nil then
        if jmz.IsDoingTormentor(bot) and GetUnitToUnitDistance(bot, hEnemyAncient) > 4000 then
            return BOT_MODE_DESIRE_EXTRA_LOW
        end
    end
    local aAliveCount = gameState.aliveAllyCount
    local eAliveCount = gameState.aliveEnemyCount
    local aAliveCoreCount = gameState.aliveAllyCoreCount
    local eAliveCoreCount = gameState.aliveEnemyCoreCount
    local hAncient = gameState.ourAncient
    local nPushDesire = 0.5
    local teamAncientLoc = hAncient:GetLocation()
    local nEffAlliesNearAncient = #jmz.GetAlliesNearLoc(teamAncientLoc, 4500) + #jmz.Utils.GetAllyIdsInTpToLocation(teamAncientLoc, 4500)
    local nEnemiesAroundAncient = jmz.GetEnemiesAroundLoc(teamAncientLoc, 4500)
    if nEnemiesAroundAncient > 0 and nEffAlliesNearAncient < 1 then
        nMaxDesire = 0.65
    end
    local networthAdvantage = gameState.teamNetworth - gameState.enemyNetworth
    local enemyAverageLevel = jmz.GetAverageLevel(true)
    local levelAdvantage = gameState.averageLevel - enemyAverageLevel
    local hasSignificantAdvantage = networthAdvantage > 15000 or levelAdvantage > 2
    if #alliesHere < #enemiesHere and #alliesHere <= eAliveCount - 1 and aAliveCount < eAliveCount then
        if hasSignificantAdvantage and #alliesHere >= #enemiesHere - 1 then
            nMaxDesire = math.min(nMaxDesire, 0.6)
        else
            return BotModeDesire.VeryLow
        end
    end
    local vEnemyLaneFrontLocation = GetLaneFrontLocation(gameState.enemyTeam, lane, 0)
    local waitForSpells = ____exports.ShouldWaitForImportantItemsSpells(vEnemyLaneFrontLocation)
    if waitForSpells and eAliveCount >= aAliveCount and eAliveCoreCount >= aAliveCoreCount then
        nMaxDesire = math.min(nMaxDesire, 0.5)
    end
    local botTarget = bot:GetAttackTarget()
    if jmz.IsValidBuilding(botTarget) and not __TS__StringIncludes(
        botTarget:GetUnitName(),
        "tower1"
    ) and not __TS__StringIncludes(
        botTarget:GetUnitName(),
        "tower2"
    ) then
        if ____exports.HasBackdoorProtect(botTarget) then
            return BOT_MODE_DESIRE_EXTRA_LOW
        end
    end
    if hEnemyAncient and GetUnitToUnitDistance(bot, hEnemyAncient) < nSearchRange * 0.5 and jmz.CanBeAttacked(hEnemyAncient) and not bot:WasRecentlyDamagedByAnyHero(1) and jmz.GetHP(bot) > 0.5 and not ____exports.HasBackdoorProtect(hEnemyAncient) then
        bot:SetTarget(hEnemyAncient)
        bot:Action_AttackUnit(hEnemyAncient, true)
        return RemapValClamped(
            jmz.GetHP(bot),
            0,
            0.5,
            BotModeDesire.None,
            0.98
        )
    end
    local pushLane = ____exports.WhichLaneToPush(bot, lane)
    local isCurrentLanePushLane = pushLane == lane
    if not jmz.IsCore(bot) and isCurrentLanePushLane or jmz.IsCore(bot) and (jmz.IsLateGame() and isCurrentLanePushLane or isMidOrEarlyGame) then
        local allowNumbers = eAliveCount == 0 or aAliveCoreCount >= eAliveCoreCount or aAliveCoreCount >= 1 and aAliveCount >= eAliveCount + 2 or networthAdvantage > 8000 and aAliveCount >= eAliveCount - 1 or levelAdvantage > 2 and aAliveCount >= eAliveCount - 1
        if allowNumbers then
            if gameState.hasAegis then
                nPushDesire = nPushDesire + 0.3
            end
            if aAliveCount >= eAliveCount - 1 then
                local networthBonus = RemapValClamped(
                    networthAdvantage,
                    3000,
                    20000,
                    0,
                    1.5
                )
                nPushDesire = nPushDesire + networthBonus
            end
            if levelAdvantage > 0 then
                local levelBonus = RemapValClamped(
                    levelAdvantage,
                    0,
                    8,
                    0,
                    0.8
                )
                nPushDesire = nPushDesire + levelBonus
            end
            if aAliveCount > eAliveCount then
                local groupBonus = RemapValClamped(
                    aAliveCount - eAliveCount,
                    1,
                    3,
                    0.1,
                    0.4
                )
                nPushDesire = nPushDesire + groupBonus
            end
            return RemapValClamped(
                nPushDesire * jmz.GetHP(bot),
                0,
                1,
                0,
                nMaxDesire
            )
        end
    end
    return lane == Lane.Mid and BotModeDesire.VeryLow or BOT_MODE_DESIRE_EXTRA_LOW
end
function presence_adjust(score, loc)
    local allies = #jmz.GetAlliesNearLoc(loc, 1600)
    return score / (1 + 0.25 * allies)
end
function ____exports.WhichLaneToPush(_bot, _lane)
    local locationState = updateLocationStateCache()
    local gameState = updateGameStateCache()
    local topLaneScore = 0
    local midLaneScore = 0
    local botLaneScore = 0
    local vTop = locationState.laneFronts[Lane.Top]
    local vMid = locationState.laneFronts[Lane.Mid]
    local vBot = locationState.laneFronts[Lane.Bot]
    local teamMembers = GetUnitList(UnitType.AlliedHeroes)
    for ____, member in ipairs(teamMembers) do
        if jmz.IsValidHero(member) then
            local topDist = GetUnitToLocationDistance(member, vTop)
            local midDist = GetUnitToLocationDistance(member, vMid)
            local botDist = GetUnitToLocationDistance(member, vBot)
            if jmz.IsCore(member) and member and not member:IsBot() then
                topDist = topDist * 0.2
                midDist = midDist * 0.2
                botDist = botDist * 0.2
            elseif not jmz.IsCore(member) then
                topDist = topDist * 1.5
                midDist = midDist * 1.5
                botDist = botDist * 1.5
            end
            topLaneScore = topLaneScore + topDist
            midLaneScore = midLaneScore + midDist
            botLaneScore = botLaneScore + botDist
        end
    end
    local countTop = 0
    local countMid = 0
    local countBot = 0
    for ____, id in ipairs(GetTeamPlayers(gameState.enemyTeam)) do
        if IsHeroAlive(id) then
            local info = GetHeroLastSeenInfo(id)
            if info and info ~= nil then
                local dInfo = info[1]
                if dInfo and dInfo ~= nil then
                    if jmz.GetDistance(vTop, dInfo.location) <= 1600 then
                        countTop = countTop + 1
                    elseif jmz.GetDistance(vMid, dInfo.location) <= 1600 then
                        countMid = countMid + 1
                    elseif jmz.GetDistance(vBot, dInfo.location) <= 1600 then
                        countBot = countBot + 1
                    end
                end
            end
        end
    end
    local hTeleports = GetIncomingTeleports()
    for ____, tp in ipairs(hTeleports) do
        if tp and ____exports.IsEnemyTP(tp.playerid) then
            if jmz.GetDistance(vTop, tp.location) <= 1600 then
                countTop = countTop + 1
            elseif jmz.GetDistance(vMid, tp.location) <= 1600 then
                countMid = countMid + 1
            elseif jmz.GetDistance(vBot, tp.location) <= 1600 then
                countBot = countBot + 1
            end
        end
    end
    topLaneScore = topLaneScore * (0.05 * countTop + 1)
    midLaneScore = midLaneScore * (0.05 * countMid + 1)
    botLaneScore = botLaneScore * (0.05 * countBot + 1)
    local topTier = ____exports.GetLaneBuildingTier(Lane.Top)
    local midTier = ____exports.GetLaneBuildingTier(Lane.Mid)
    local botTier = ____exports.GetLaneBuildingTier(Lane.Bot)
    if midTier < topTier and midTier < botTier then
        midLaneScore = midLaneScore * 0.5
        if not jmz.Utils.IsAnyBarracksOnLaneAlive(false, Lane.Mid) then
            midLaneScore = midLaneScore * 0.5
        end
    elseif topTier < midTier and topTier < botTier then
        topLaneScore = topLaneScore * 0.5
        if not jmz.Utils.IsAnyBarracksOnLaneAlive(false, Lane.Top) then
            topLaneScore = topLaneScore * 0.5
        end
    elseif botTier < topTier and botTier < midTier then
        botLaneScore = botLaneScore * 0.5
        if not jmz.Utils.IsAnyBarracksOnLaneAlive(false, Lane.Bot) then
            botLaneScore = botLaneScore * 0.5
        end
    end
    topLaneScore = presence_adjust(topLaneScore, vTop)
    midLaneScore = presence_adjust(midLaneScore, vMid)
    botLaneScore = presence_adjust(botLaneScore, vBot)
    if topLaneScore < midLaneScore and topLaneScore < botLaneScore then
        return Lane.Top
    end
    if midLaneScore < topLaneScore and midLaneScore < botLaneScore then
        return Lane.Mid
    end
    if botLaneScore < topLaneScore and botLaneScore < midLaneScore then
        return Lane.Bot
    end
    return Lane.Mid
end
function ____exports.IsEnemyTP(nID)
    local gameState = updateGameStateCache()
    for ____, id in ipairs(GetTeamPlayers(gameState.enemyTeam)) do
        if id == nID then
            return true
        end
    end
    return false
end
--- Include micro-summons & dominated units into "nearby creeps" for push thinning
function ____exports.GetSpecialUnitsNearby(bot, hUnitList, nRadius)
    local unitState = updateUnitStateCache()
    local hCreepList = {unpack(hUnitList)}
    for ____, unit in ipairs(unitState.enemyHeroes) do
        if IsValidUnit(unit) and jmz.IsInRange(bot, unit, nRadius) then
            local s = unit:GetUnitName()
            if __TS__StringIncludes(s, "invoker_forge_spirit") or __TS__StringIncludes(s, "lycan_wolf") or __TS__StringIncludes(s, "eidolon") or __TS__StringIncludes(s, "beastmaster_boar") or __TS__StringIncludes(s, "beastmaster_greater_boar") or __TS__StringIncludes(s, "furion_treant") or __TS__StringIncludes(s, "broodmother_spiderling") or __TS__StringIncludes(s, "skeleton_warrior") or __TS__StringIncludes(s, "warlock_golem") or unit:HasModifier("modifier_dominated") or unit:HasModifier("modifier_chen_holy_persuasion") then
                hCreepList[#hCreepList + 1] = unit
            end
        end
    end
    return hCreepList
end
function ____exports.GetAllyHeroesAttackingUnit(hUnit)
    local unitState = updateUnitStateCache()
    local out = {}
    for ____, ally in ipairs(unitState.alliedHeroes) do
        if jmz.IsValidHero(ally) and not jmz.IsSuspiciousIllusion(ally) and not jmz.IsMeepoClone(ally) and ally:GetAttackTarget() == hUnit then
            out[#out + 1] = ally
        end
    end
    return out
end
function ____exports.GetAllyCreepsAttackingUnit(hUnit)
    local unitState = updateUnitStateCache()
    local out = {}
    for ____, creep in ipairs(unitState.alliedCreeps) do
        if jmz.IsValid(creep) and creep:GetAttackTarget() == hUnit then
            out[#out + 1] = creep
        end
    end
    return out
end
--- Returns 1..4 for the highest structure on that lane that is still alive on the enemy team
function ____exports.GetLaneBuildingTier(nLane)
    local gameState = updateGameStateCache()
    local enemyTeam = gameState.enemyTeam
    if nLane == Lane.Top then
        if GetTower(enemyTeam, Tower.Top1) ~= nil then
            return 1
        elseif GetTower(enemyTeam, Tower.Top2) ~= nil then
            return 2
        elseif GetTower(enemyTeam, Tower.Top3) ~= nil or GetBarracks(enemyTeam, Barracks.TopMelee) ~= nil or GetBarracks(enemyTeam, Barracks.TopRanged) ~= nil then
            return 3
        else
            return 4
        end
    elseif nLane == Lane.Mid then
        if GetTower(enemyTeam, Tower.Mid1) ~= nil then
            return 1
        elseif GetTower(enemyTeam, Tower.Mid2) ~= nil then
            return 2
        elseif GetTower(enemyTeam, Tower.Mid3) ~= nil or GetBarracks(enemyTeam, Barracks.MidMelee) ~= nil or GetBarracks(enemyTeam, Barracks.MidRanged) ~= nil then
            return 3
        else
            return 4
        end
    elseif nLane == Lane.Bot then
        if GetTower(enemyTeam, Tower.Bot1) ~= nil then
            return 1
        elseif GetTower(enemyTeam, Tower.Bot2) ~= nil then
            return 2
        elseif GetTower(enemyTeam, Tower.Bot3) ~= nil or GetBarracks(enemyTeam, Barracks.BotMelee) ~= nil or GetBarracks(enemyTeam, Barracks.BotRanged) ~= nil then
            return 3
        else
            return 4
        end
    end
    return 1
end
function ____exports.ShouldWaitForImportantItemsSpells(vLocation)
    local gameState = updateGameStateCache()
    if gameState.isMidGame or gameState.isLateGame then
        if jmz.Utils.HasTeamMemberWithCriticalItemInCooldown(vLocation) then
            return true
        end
        if jmz.Utils.HasTeamMemberWithCriticalSpellInCooldown(vLocation) then
            return true
        end
    end
    return false
end
function ____exports.HasBackdoorProtect(target)
    return target:HasModifier("modifier_fountain_glyph") or target:HasModifier("modifier_backdoor_protection") or target:HasModifier("modifier_backdoor_protection_in_base") or target:HasModifier("modifier_backdoor_protection_active")
end
--- Returns true if the *nearest* intended target around the enemy lane-front
-- is currently backdoored/glyphed.
function ____exports.IsAnyTargetBackdooredAt(_bot, lane)
    local locationState = updateLocationStateCache()
    local unitState = updateUnitStateCache()
    local lf = locationState.laneFronts[lane]
    local nearest = nil
    local best = math.huge
    for ____, b in ipairs(unitState.enemyBuildings) do
        if jmz.IsValidBuilding(b) then
            local d = GetUnitToLocationDistance(b, lf)
            if d < best then
                nearest = b
                best = d
            end
        end
    end
    return not not (nearest and ____exports.HasBackdoorProtect(nearest))
end
local Customize = require(GetScriptDirectory().."/Customize/general")
local ____Customize_1 = Customize
local ____Customize_Enable_0
if Customize.Enable then
    ____Customize_Enable_0 = Customize.ThinkLess
else
    ____Customize_Enable_0 = 1
end
____Customize_1.ThinkLess = ____Customize_Enable_0
pingTimeDelta = 5
StartToPushTime = 16 * 60
BOT_MODE_DESIRE_EXTRA_LOW = 0.02
hEnemyAncient = nil
PUSH_CACHE_TTL = 0.5
local BOT_CACHE_TTL = 0.2
local THINK_INTERVAL = 1 / 30
gameStateCache = nil
locationStateCache = nil
unitStateCache = nil
local botStateCache = {}
--- Update bot state cache if needed
local function updateBotStateCache(bot, targetLoc)
    local now = DotaTime()
    local botId = bot:GetPlayerID()
    local cached = botStateCache[botId]
    if cached and now - cached.lastUpdate < BOT_CACHE_TTL then
        return cached
    end
    local location = bot:GetLocation()
    local attackRange = bot:GetAttackRange()
    local gameState = updateGameStateCache()
    botStateCache[botId] = {
        lastUpdate = now,
        botId = botId,
        attackRange = attackRange,
        location = location,
        hp = jmz.GetHP(bot),
        mp = jmz.GetMP(bot),
        nearbyTowers = bot:GetNearbyTowers(1200, true),
        nearbyLaneCreeps = bot:GetNearbyLaneCreeps(1200, false),
        nearbyCreeps = bot:GetNearbyCreeps(1600, true),
        attackTarget = bot:GetAttackTarget(),
        distanceToAncient = gameState.enemyAncient and GetUnitToUnitDistance(bot, gameState.enemyAncient) or math.huge,
        distanceToTargetLoc = targetLoc and GetUnitToLocationDistance(bot, targetLoc) or 0
    }
    return botStateCache[botId]
end
--- === Objective selection stability (anti-thrash) ===
-- (kept from Lua; comments preserved)
local OBJECTIVE_STICKY_TIME = 1.2
local SWITCH_SCORE_MARGIN = 0.25
local OBJECTIVE_LEASH_RANGE = 2600
local SCORE_BARRACKS_MELEE = 0
local SCORE_BARRACKS_RANGED = 0.1
local SCORE_T3 = 0.5
local SCORE_T4 = 1.8
BASE_ANC_RADIUS = 2200
local ObjectiveState = {}
function ____exports.GetPushDesire(bot, lane)
    if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not __TS__StringIncludes(
        bot:GetUnitName(),
        "hero"
    ) or bot:IsIllusion() then
        return BotModeDesire.None
    end
    if bot:GetLevel() < 3 then
        return BotModeDesire.None
    end
    local res = ____exports.GetPushDesireHelper(bot, lane)
    bot.pushDesire = res
    return res
end
local function UnitIsValidObjective(u)
    return not not u and jmz.IsValidBuilding(u) and jmz.CanBeAttacked(u)
end
local function UnitIsBarracks(u)
    local n = u ~= nil and u:GetUnitName() or ""
    return __TS__StringIncludes(n, "rax")
end
local function UnitIsMeleeBarracks(u)
    return UnitIsBarracks(u) and not not u and __TS__StringIncludes(
        u:GetUnitName(),
        "melee"
    )
end
local function UnitIsRangedBarracks(u)
    return UnitIsBarracks(u) and not not u and __TS__StringIncludes(
        u:GetUnitName(),
        "ranged"
    )
end
local function UnitIsT3(u)
    return u == GetTower(
        GetOpposingTeam(),
        Tower.Top3
    ) or u == GetTower(
        GetOpposingTeam(),
        Tower.Mid3
    ) or u == GetTower(
        GetOpposingTeam(),
        Tower.Bot3
    )
end
local function UnitIsT4(u)
    return u == GetTower(
        GetOpposingTeam(),
        Tower.Base1
    ) or u == GetTower(
        GetOpposingTeam(),
        Tower.Base2
    ) or GetUnitToUnitDistance(
        u,
        GetAncient(GetOpposingTeam())
    ) < 500
end
--- Compute a score for an objective; lower is better.
-- Base priority + mild distance terms; prefer closer to the bot and to approach targetLoc.
local function ObjectiveScore(bot, u, targetLoc)
    if not UnitIsValidObjective(u) then
        return math.huge
    end
    local base = UnitIsMeleeBarracks(u) and SCORE_BARRACKS_MELEE or UnitIsRangedBarracks(u) and SCORE_BARRACKS_RANGED or UnitIsT3(u) and SCORE_T3 or UnitIsT4(u) and SCORE_T4 or 2
    local dBot = GetUnitToUnitDistance(bot, u)
    if dBot > OBJECTIVE_LEASH_RANGE then
        return math.huge
    end
    local d1 = dBot / 2000
    local d2 = targetLoc and GetUnitToLocationDistance(u, targetLoc) / 2500 or 0
    return base + 0.35 * d1 + 0.2 * d2
end
--- Decide whether to keep current target or switch to a better one
local function SelectOrStickHGTarget(bot, lane, targetLoc)
    local pid = bot:GetPlayerID()
    ObjectiveState[pid] = ObjectiveState[pid] or ({})
    ObjectiveState[pid][lane] = ObjectiveState[pid][lane] or ({})
    local state = ObjectiveState[pid][lane]
    local now = GameTime()
    local current = state.target or nil
    if current and now < (state.lockUntil or 0) then
        return current
    end
    local currentScore = current and ObjectiveScore(bot, current, targetLoc) or math.huge
    local unitState = updateUnitStateCache()
    local best = nil
    local bestScore = math.huge
    for ____, b in ipairs(unitState.enemyBuildings) do
        local sc = ObjectiveScore(bot, b, targetLoc)
        if sc < bestScore then
            best = b
            bestScore = sc
        end
    end
    if current and UnitIsValidObjective(current) then
        if best and bestScore + SWITCH_SCORE_MARGIN < currentScore then
            state.target = best
            state.lockUntil = now + OBJECTIVE_STICKY_TIME
            return best
        else
            state.lockUntil = now + 0.6
            return current
        end
    end
    if best then
        state.target = best
        state.lockUntil = now + OBJECTIVE_STICKY_TIME
        return best
    end
    state.target = nil
    state.lockUntil = nil
    return nil
end
local fNextMovementTime = 0
local lastThinkTime = 0
local lastAction = nil
function ____exports.PushThink(bot, lane)
    local now = DotaTime()
    if now - lastThinkTime < THINK_INTERVAL then
        if lastAction and now - lastAction.time < 2 then
            repeat
                local ____switch96 = lastAction.type
                local ____cond96 = ____switch96 == "attack"
                if ____cond96 then
                    if lastAction.target and type(lastAction.target) == "table" and lastAction.target.GetLocation ~= nil then
                        bot:Action_AttackUnit(lastAction.target, true)
                    end
                    break
                end
                ____cond96 = ____cond96 or ____switch96 == "move"
                if ____cond96 then
                    if lastAction.target and type(lastAction.target) == "table" and lastAction.target.x ~= nil then
                        bot:Action_MoveToLocation(lastAction.target)
                    end
                    break
                end
                ____cond96 = ____cond96 or ____switch96 == "attackMove"
                if ____cond96 then
                    if lastAction.target and type(lastAction.target) == "table" and lastAction.target.x ~= nil then
                        bot:Action_AttackMove(lastAction.target)
                    end
                    break
                end
            until true
        end
        return
    end
    lastThinkTime = now
    if jmz.CanNotUseAction(bot) then
        return
    end
    if jmz.Utils.IsBotThinkingMeaningfulAction(bot, Customize.ThinkLess, "push") then
        return
    end
    autoCleanupCache()
    local gameState = getGlobalGameState()
    local locationState = getGlobalLocationState()
    local botState = updateBotStateCache(bot)
    local botLocation = botState.location
    local alliesHere = getCachedAlliesNearLoc(botLocation, 1600)
    local enemiesHere = getCachedEnemiesNearLoc(botLocation, 1600)
    local botAttackRange = botState.attackRange
    local botHp = botState.hp
    local fDeltaFromFront = math.min(botHp, 0.7) * 800 - 500 + RemapValClamped(
        botAttackRange,
        300,
        700,
        0,
        -300
    )
    fDeltaFromFront = math.max(
        math.min(fDeltaFromFront, 250),
        -200
    )
    local nEnemyTowers = botState.nearbyTowers
    local nAllyCreeps = botState.nearbyLaneCreeps
    if #alliesHere < #enemiesHere or ____exports.IsAnyTargetBackdooredAt(bot, lane) then
        local longestRange = 0
        for ____, enemyHero in ipairs(enemiesHere) do
            if jmz.IsValidHero(enemyHero) and not jmz.IsSuspiciousIllusion(enemyHero) then
                local r = enemyHero:GetAttackRange()
                if r > longestRange then
                    longestRange = r
                end
            end
        end
        local gameState = getGlobalGameState()
        local networthAdvantage = gameState.teamNetworth - gameState.enemyNetworth
        local enemyAverageLevel = jmz.GetAverageLevel(true)
        local levelAdvantage = gameState.averageLevel - enemyAverageLevel
        local hasTeamAdvantage = networthAdvantage > 5000 or levelAdvantage > 1
        if #enemiesHere >= #alliesHere + 1 or botHp < 0.3 then
            if hasTeamAdvantage and botHp > 0.4 then
                fDeltaFromFront = math.max(-200, -80 - 0.25 * longestRange)
            else
                fDeltaFromFront = math.max(-300, -120 - 0.35 * longestRange)
            end
        else
            if hasTeamAdvantage and botHp > 0.5 then
                fDeltaFromFront = math.max(-50, -20 - 0.1 * longestRange)
            else
                fDeltaFromFront = math.max(-100, -50 - 0.2 * longestRange)
            end
        end
    end
    local targetLoc = GetLaneFrontLocation(gameState.team, lane, fDeltaFromFront)
    if not botState.distanceToTargetLoc or math.abs(botState.distanceToTargetLoc - GetUnitToLocationDistance(bot, targetLoc)) > 50 then
        updateBotStateCache(bot, targetLoc)
    end
    if jmz.IsValidBuilding(nEnemyTowers[1]) and (nEnemyTowers[1]:GetAttackTarget() == bot or nEnemyTowers[1]:GetAttackTarget() ~= bot and bot:WasRecentlyDamagedByTower(#nAllyCreeps <= 2 and 4 or 2)) then
        local nDamage = nEnemyTowers[1]:GetAttackDamage() * nEnemyTowers[1]:GetAttackSpeed() * 5 - bot:GetHealthRegen() * 5
        if bot:GetActualIncomingDamage(nDamage, DamageType.Physical) / bot:GetHealth() > 0.15 or #nAllyCreeps > 2 then
            local retreat = math.min(fDeltaFromFront - 200, -300)
            local retreatLoc = GetLaneFrontLocation(gameState.team, lane, retreat)
            lastAction = {type = "move", target = retreatLoc, time = now}
            bot:Action_MoveToLocation(retreatLoc)
            return
        end
    end
    hEnemyAncient = gameState.enemyAncient
    local alliesNearAncient = hEnemyAncient and jmz.GetAlliesNearLoc(
        hEnemyAncient:GetLocation(),
        1600
    )
    if hEnemyAncient and botState.distanceToAncient < 1000 and jmz.CanBeAttacked(hEnemyAncient) and not ____exports.HasBackdoorProtect(hEnemyAncient) and (#____exports.GetAllyHeroesAttackingUnit(hEnemyAncient) >= 3 or #____exports.GetAllyCreepsAttackingUnit(hEnemyAncient) >= 4 or hEnemyAncient:GetHealthRegen() < 20 or (alliesNearAncient and #alliesNearAncient or 0) >= 4) then
        lastAction = {type = "attack", target = hEnemyAncient, time = now}
        bot:Action_AttackUnit(hEnemyAncient, true)
        return
    end
    local nRange = math.min(700 + botAttackRange, 1600)
    if hEnemyAncient and botState.distanceToAncient < 2600 then
        nRange = 1600
    end
    local nCreeps = botState.nearbyCreeps
    local creepCacheKey = (("specialCreeps_" .. tostring(bot:GetPlayerID())) .. "_") .. tostring(math.floor(now * 5))
    nCreeps = getCachedData(
        creepCacheKey,
        0.2,
        function() return ____exports.GetSpecialUnitsNearby(bot, nCreeps, nRange) end
    )
    local vTeamFountain = locationState.teamFountain
    local bTowerNearby = jmz.IsValidBuilding(nEnemyTowers[1])
    local towerDistanceToFountain = bTowerNearby and GetUnitToLocationDistance(nEnemyTowers[1], vTeamFountain) or 0
    for ____, creep in ipairs(nCreeps) do
        do
            local __continue119
            repeat
                if not jmz.IsValid(creep) or not jmz.CanBeAttacked(creep) then
                    __continue119 = true
                    break
                end
                if jmz.IsTormentor(creep) or jmz.IsRoshan(creep) then
                    __continue119 = true
                    break
                end
                if bTowerNearby and GetUnitToLocationDistance(creep, vTeamFountain) >= towerDistanceToFountain then
                    __continue119 = true
                    break
                end
                lastAction = {type = "attack", target = creep, time = now}
                bot:Action_AttackUnit(creep, true)
                return
            until true
            if not __continue119 then
                break
            end
        end
    end
    local hgTarget = SelectOrStickHGTarget(bot, lane, targetLoc)
    if hgTarget then
        if jmz.IsInRange(bot, hgTarget, botAttackRange + 150) then
            lastAction = {type = "attack", target = hgTarget, time = now}
            bot:Action_AttackUnit(hgTarget, true)
        else
            lastAction = {
                type = "move",
                target = hgTarget:GetLocation(),
                time = now
            }
            bot:Action_MoveToLocation(hgTarget:GetLocation())
        end
        return
    end
    if botState.distanceToTargetLoc > 500 then
        lastAction = {type = "move", target = targetLoc, time = now}
        bot:Action_MoveToLocation(targetLoc)
        return
    else
        if DotaTime() >= fNextMovementTime then
            local attackMoveLoc = jmz.GetRandomLocationWithinDist(targetLoc, 0, 400)
            lastAction = {type = "attackMove", target = attackMoveLoc, time = now}
            bot:Action_AttackMove(attackMoveLoc)
            fNextMovementTime = DotaTime() + RandomFloat(0.05, 0.3)
            return
        end
    end
end
function ____exports.TryClearingOtherLaneHighGround(_bot, vLocation)
    local gameState = updateGameStateCache()
    local unitState = updateUnitStateCache()
    local unitList = unitState.enemyBuildings
    local function IsValid(building)
        return jmz.IsValidBuilding(building) and jmz.CanBeAttacked(building) and not ____exports.HasBackdoorProtect(building)
    end
    local hBarrackTarget = nil
    local best = math.huge
    for ____, barrack in ipairs(unitList) do
        if IsValid(barrack) and (barrack == GetBarracks(gameState.enemyTeam, Barracks.TopMelee) or barrack == GetBarracks(gameState.enemyTeam, Barracks.TopRanged) or barrack == GetBarracks(gameState.enemyTeam, Barracks.MidMelee) or barrack == GetBarracks(gameState.enemyTeam, Barracks.MidRanged) or barrack == GetBarracks(gameState.enemyTeam, Barracks.BotMelee) or barrack == GetBarracks(gameState.enemyTeam, Barracks.BotRanged)) then
            local d = GetUnitToLocationDistance(barrack, vLocation)
            if d < best then
                hBarrackTarget = barrack
                best = d
            end
        end
    end
    if hBarrackTarget then
        return hBarrackTarget
    end
    local hTowerTarget = nil
    best = math.huge
    for ____, tower in ipairs(unitList) do
        if IsValid(tower) and (tower == GetTower(gameState.enemyTeam, Tower.Top3) or tower == GetTower(gameState.enemyTeam, Tower.Mid3) or tower == GetTower(gameState.enemyTeam, Tower.Bot3)) then
            local d = GetUnitToLocationDistance(tower, vLocation)
            if d < best then
                hTowerTarget = tower
                best = d
            end
        end
    end
    if hTowerTarget then
        return hTowerTarget
    end
    return nil
end
function ____exports.CanBeAttacked(building)
    return not not building and building:CanBeSeen() and not building:IsInvulnerable()
end
--- Estimate if staying in a tower's zone is too dangerous over fDuration seconds
function ____exports.IsInDangerWithinTower(hUnit, fThreshold, fDuration)
    local unitState = updateUnitStateCache()
    local totalDamage = 0
    for ____, enemy in ipairs(unitState.enemyHeroes) do
        if jmz.IsValid(enemy) and jmz.IsInRange(hUnit, enemy, 1600) and (enemy:GetAttackTarget() == hUnit or jmz.IsChasingTarget(enemy, hUnit)) then
            totalDamage = totalDamage + hUnit:GetActualIncomingDamage(
                enemy:GetAttackDamage() * enemy:GetAttackSpeed() * fDuration,
                DamageType.Physical
            )
        end
    end
    return totalDamage / hUnit:GetHealth() * 1.2 > fThreshold
end
function ____exports.IsHealthyInsideFountain(hUnit)
    return hUnit:HasModifier("modifier_fountain_aura_buff") and jmz.GetHP(hUnit) > 0.9 and jmz.GetMP(hUnit) > 0.85
end
--- Picks best high-ground objective with strict priority:
--   1) Barracks: melee > ranged (closest of each class)
--   2) Tier-3 towers (closest)
--   3) Fillers/others (closest)
-- Radius is the max distance from the bot; tie-breaker favors closer to targetLoc.
function ____exports.FindBestHGTarget(bot, radius, targetLoc)
    local gameState = updateGameStateCache()
    local unitState = updateUnitStateCache()
    local function isBarracks(u)
        return __TS__StringIncludes(
            u:GetUnitName(),
            "rax"
        )
    end
    local function isMeleeBarracks(u)
        return __TS__StringIncludes(
            u:GetUnitName(),
            "melee"
        )
    end
    local function isRangedBarracks(u)
        return __TS__StringIncludes(
            u:GetUnitName(),
            "ranged"
        )
    end
    local function isT3Tower(u)
        return u == GetTower(gameState.enemyTeam, Tower.Top3) or u == GetTower(gameState.enemyTeam, Tower.Mid3) or u == GetTower(gameState.enemyTeam, Tower.Bot3)
    end
    local function isT4Tower(u)
        return u == GetTower(gameState.enemyTeam, Tower.Base1) or u == GetTower(gameState.enemyTeam, Tower.Base2)
    end
    local bestMelee = nil
    local bestMeleeD = math.huge
    local bestRanged = nil
    local bestRangedD = math.huge
    local bestT3 = nil
    local bestT3D = math.huge
    local bestT4 = nil
    local bestT4D = math.huge
    local bestOther = nil
    local bestOtherD = math.huge
    for ____, b in ipairs(unitState.enemyBuildings) do
        if jmz.IsValidBuilding(b) and jmz.CanBeAttacked(b) and not ____exports.HasBackdoorProtect(b) then
            local dBot = GetUnitToUnitDistance(bot, b)
            if dBot <= radius then
                local dLoc = targetLoc and GetUnitToLocationDistance(b, targetLoc) or 0
                if isBarracks(b) then
                    if isMeleeBarracks(b) then
                        if dBot < bestMeleeD or dBot == bestMeleeD and dLoc < (bestMelee and GetUnitToLocationDistance(bestMelee, targetLoc) or dLoc) then
                            bestMelee = b
                            bestMeleeD = dBot
                        end
                    elseif isRangedBarracks(b) then
                        if dBot < bestRangedD or dBot == bestRangedD and dLoc < (bestRanged and GetUnitToLocationDistance(bestRanged, targetLoc) or dLoc) then
                            bestRanged = b
                            bestRangedD = dBot
                        end
                    end
                elseif isT3Tower(b) then
                    if dBot < bestT3D or dBot == bestT3D and dLoc < (bestT3 and GetUnitToLocationDistance(bestT3, targetLoc) or dLoc) then
                        bestT3 = b
                        bestT3D = dBot
                    end
                elseif isT4Tower(b) then
                    if dBot < bestT4D or dBot == bestT4D and dLoc < (bestT4 and GetUnitToLocationDistance(bestT4, targetLoc) or dLoc) then
                        bestT4 = b
                        bestT4D = dBot
                    end
                else
                    if dBot < bestOtherD or dBot == bestOtherD and dLoc < (bestOther and GetUnitToLocationDistance(bestOther, targetLoc) or dLoc) then
                        bestOther = b
                        bestOtherD = dBot
                    end
                end
            end
        end
    end
    return bestMelee or bestRanged or bestT3 or bestOther
end
return ____exports
