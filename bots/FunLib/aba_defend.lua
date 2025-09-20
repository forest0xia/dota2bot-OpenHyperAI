--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__StringIncludes(self, searchString, position)
    if not position then
        position = 1
    else
        position = position + 1
    end
    local index = string.find(self, searchString, position, true)
    return index ~= nil
end

local function __TS__ArraySome(self, callbackfn, thisArg)
    for i = 1, #self do
        if callbackfn(thisArg, self[i], i - 1, self) then
            return true
        end
    end
    return false
end
-- End of Lua Library inline imports
local ____exports = {}
local _q, _keyLoc, _recentHeroCountNear, IsValidBuildingTarget, IsBaseThreatActive, WeightedEnemiesAroundLocation, GetThreatenedLane, GetClosestAllyPos, IsThereNoTeammateTravelBootsDefender, GetHighGroundEdgeWaitPoint, ConsiderPingedDefend, okLoc, Localization, PING_DELTA, MAX_DESIRE_CAP, BASE_THREAT_RADIUS, BASE_THREAT_HOLD, CACHE_ENEMY_AROUND_LOC_HZ, CACHE_LASTSEEN_WINDOW, nTeam, currentTime, defendLoc, aliveAllyHeroes, weAreStronger, nInRangeAlly, nInRangeEnemy, _threatLaneSticky, distanceToLane, baseThreatUntil, fTraveBootsDefendTime, _cacheEnemyAroundLoc
local jmz = require(GetScriptDirectory().."/FunLib/jmz_func")
local ____dota = require(GetScriptDirectory().."/ts_libs/dota/index")
local Barracks = ____dota.Barracks
local BotActionDesire = ____dota.BotActionDesire
local BotMode = ____dota.BotMode
local BotModeDesire = ____dota.BotModeDesire
local Lane = ____dota.Lane
local Tower = ____dota.Tower
local UnitType = ____dota.UnitType
local ____native_2Doperators = require(GetScriptDirectory().."/ts_libs/utils/native-operators")
local add = ____native_2Doperators.add
local ____utils = require(GetScriptDirectory().."/FunLib/utils")
local GetLocationToLocationDistance = ____utils.GetLocationToLocationDistance
function _q(v)
    return v and (tostring(math.floor(v.x / 200) * 200) .. ":") .. tostring(math.floor(v.y / 200) * 200) or "0:0"
end
function _keyLoc(v, r)
    return (_q(v) .. "|") .. tostring(math.floor(r or 0))
end
function _recentHeroCountNear(loc, r, window)
    if window == nil then
        window = CACHE_LASTSEEN_WINDOW
    end
    local cnt = 0
    for ____, id in ipairs(GetTeamPlayers(GetOpposingTeam())) do
        do
            local __continue7
            repeat
                if not IsHeroAlive(id) then
                    __continue7 = true
                    break
                end
                local info = GetHeroLastSeenInfo(id)
                if info and info[1] and info[1].time_since_seen <= window and GetLocationToLocationDistance(info[1].location, loc) <= r then
                    cnt = cnt + 1
                end
                __continue7 = true
            until true
            if not __continue7 then
                break
            end
        end
    end
    return cnt
end
function IsValidBuildingTarget(unit)
    return unit ~= nil and unit:IsAlive() and unit:IsBuilding()
end
function IsBaseThreatActive()
    return DotaTime() < (baseThreatUntil or -1)
end
function WeightedEnemiesAroundLocation(vLoc, nRadius)
    local now = DotaTime()
    local key = _keyLoc(vLoc, nRadius)
    local c = _cacheEnemyAroundLoc[key]
    if c and now - c.t <= CACHE_ENEMY_AROUND_LOC_HZ then
        return c.count
    end
    local count = 0
    for ____, unit in ipairs(GetUnitList(UnitType.Enemies)) do
        if jmz.IsValid(unit) and GetUnitToLocationDistance(unit, vLoc) <= nRadius then
            local name = unit:GetUnitName()
            if jmz.IsValidHero(unit) and not jmz.IsSuspiciousIllusion(unit) then
                count = count + (jmz.IsCore(unit) and 1 or 0.5)
            elseif ({string.find(name, "upgraded_mega")}) ~= nil then
                count = count + 0.6
            elseif ({string.find(name, "upgraded")}) ~= nil then
                count = count + 0.4
            elseif ({string.find(name, "siege")}) ~= nil and ({string.find(name, "upgraded")}) == nil then
                count = count + 0.5
            elseif ({string.find(name, "warlock_golem")}) ~= nil or ({string.find(name, "lone_druid_bear")}) ~= nil then
                count = count + 1
            elseif unit:IsCreep() or unit:IsAncientCreep() or unit:IsDominated() or unit:HasModifier("modifier_chen_holy_persuasion") or unit:HasModifier("modifier_dominated") then
                count = count + 0.2
            end
        end
    end
    count = math.floor(count)
    _cacheEnemyAroundLoc[key] = {t = now, count = count}
    return count
end
function GetThreatenedLane()
    local lanes = {Lane.Top, Lane.Mid, Lane.Bot}
    local bestLane = lanes[1]
    local bestScore = -1
    for ____, ln in ipairs(lanes) do
        local bld, _urgent, tier = unpack(____exports.GetFurthestBuildingOnLane(ln))
        local anchor = IsValidBuildingTarget(bld) and tier < 3 and bld:GetLocation() or GetHighGroundEdgeWaitPoint(nTeam, ln)
        local enemyHeroCnt = _recentHeroCountNear(anchor, 1800)
        local score = enemyHeroCnt * 10
        if enemyHeroCnt == 0 then
            local creepEq = math.min(
                WeightedEnemiesAroundLocation(anchor, 1200) * 0.4,
                0.9
            )
            score = score + creepEq
        end
        if score > bestScore then
            bestScore = score
            bestLane = ln
        end
    end
    if DotaTime() <= _threatLaneSticky["until"] then
        return _threatLaneSticky.lane
    end
    _threatLaneSticky = {
        lane = bestLane,
        ["until"] = DotaTime() + 1.8
    }
    return bestLane
end
function GetClosestAllyPos(tPosList, vLocation)
    local bestPos = nil
    local bestDist = math.huge
    do
        local i = 1
        while i <= 5 do
            local m = GetTeamMember(i)
            if jmz.IsValidHero(m) then
                local p = jmz.GetPosition(m)
                do
                    local j = 1
                    while j <= #tPosList do
                        if p == tPosList[j + 1] then
                            local d = GetUnitToLocationDistance(m, vLocation)
                            if d < bestDist then
                                bestDist = d
                                bestPos = p
                            end
                        end
                        j = j + 1
                    end
                end
            end
            i = i + 1
        end
    end
    return bestPos or tPosList[1]
end
function ____exports.GetFurthestBuildingOnLane(lane)
    local cacheKey = (("FurthestBuildingOnLane:" .. tostring(nTeam)) .. ":") .. tostring(lane or -1)
    local cachedVar = jmz.Utils.GetCachedVars(cacheKey, 1)
    if cachedVar ~= nil then
        return cachedVar
    end
    local res = ____exports.GetFurthestBuildingOnLaneHelper(lane)
    jmz.Utils.SetCachedVars(cacheKey, res)
    return res
end
function ____exports.GetFurthestBuildingOnLaneHelper(lane)
    local team = nTeam
    local b
    local function hpMul(u, lo, hi, mlo, mhi)
        local nHealth = u:GetHealth() / u:GetMaxHealth()
        return RemapValClamped(
            nHealth,
            lo,
            hi,
            mlo,
            mhi
        )
    end
    if lane == Lane.Top then
        b = GetTower(team, Tower.Top1)
        if IsValidBuildingTarget(b) then
            return {
                b,
                hpMul(
                    b,
                    0.25,
                    1,
                    0.5,
                    1
                ),
                1
            }
        end
        b = GetTower(team, Tower.Top2)
        if IsValidBuildingTarget(b) then
            return {
                b,
                hpMul(
                    b,
                    0.25,
                    1,
                    1,
                    2
                ),
                2
            }
        end
        b = GetTower(team, Tower.Top3)
        if IsValidBuildingTarget(b) then
            return {
                b,
                hpMul(
                    b,
                    0.25,
                    1,
                    1.5,
                    2
                ),
                3
            }
        end
        b = GetBarracks(team, Barracks.TopMelee)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetBarracks(team, Barracks.TopRanged)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetTower(team, Tower.Base1)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetTower(team, Tower.Base2)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetAncient(team)
        if IsValidBuildingTarget(b) then
            return {b, 3, 4}
        end
    elseif lane == Lane.Mid then
        b = GetTower(team, Tower.Mid1)
        if IsValidBuildingTarget(b) then
            return {
                b,
                hpMul(
                    b,
                    0.25,
                    1,
                    0.5,
                    1
                ),
                1
            }
        end
        b = GetTower(team, Tower.Mid2)
        if IsValidBuildingTarget(b) then
            return {
                b,
                hpMul(
                    b,
                    0.25,
                    1,
                    1,
                    2
                ),
                2
            }
        end
        b = GetTower(team, Tower.Mid3)
        if IsValidBuildingTarget(b) then
            return {
                b,
                hpMul(
                    b,
                    0.25,
                    1,
                    1.5,
                    2
                ),
                3
            }
        end
        b = GetBarracks(team, Barracks.MidMelee)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetBarracks(team, Barracks.MidRanged)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetTower(team, Tower.Base1)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetTower(team, Tower.Base2)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetAncient(team)
        if IsValidBuildingTarget(b) then
            return {b, 3, 4}
        end
    else
        b = GetTower(team, Tower.Bot1)
        if IsValidBuildingTarget(b) then
            return {
                b,
                hpMul(
                    b,
                    0.25,
                    1,
                    0.5,
                    1
                ),
                1
            }
        end
        b = GetTower(team, Tower.Bot2)
        if IsValidBuildingTarget(b) then
            return {
                b,
                hpMul(
                    b,
                    0.25,
                    1,
                    1,
                    2
                ),
                2
            }
        end
        b = GetTower(team, Tower.Bot3)
        if IsValidBuildingTarget(b) then
            return {
                b,
                hpMul(
                    b,
                    0.25,
                    1,
                    1.5,
                    2
                ),
                3
            }
        end
        b = GetBarracks(team, Barracks.BotMelee)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetBarracks(team, Barracks.BotRanged)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetTower(team, Tower.Base1)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetTower(team, Tower.Base2)
        if IsValidBuildingTarget(b) then
            return {b, 2.5, 3}
        end
        b = GetAncient(team)
        if IsValidBuildingTarget(b) then
            return {b, 3, 4}
        end
    end
    return {nil, 1, 0}
end
function IsThereNoTeammateTravelBootsDefender(bot)
    do
        local i = 1
        while i <= 5 do
            local m = GetTeamMember(i)
            if bot ~= m and jmz.IsValidHero(m) and m.travel_boots_defender == true then
                return false
            end
            i = i + 1
        end
    end
    return true
end
function GetHighGroundEdgeWaitPoint(team, lane)
    local ____temp_3
    if lane == Lane.Top then
        ____temp_3 = GetTower(team, Tower.Top3)
    else
        local ____temp_2
        if lane == Lane.Mid then
            ____temp_2 = GetTower(team, Tower.Mid3)
        else
            ____temp_2 = GetTower(team, Tower.Bot3)
        end
        ____temp_3 = ____temp_2
    end
    local t3 = ____temp_3
    local ____temp_5
    if lane == Lane.Top then
        ____temp_5 = GetBarracks(team, Barracks.TopMelee)
    else
        local ____temp_4
        if lane == Lane.Mid then
            ____temp_4 = GetBarracks(team, Barracks.MidMelee)
        else
            ____temp_4 = GetBarracks(team, Barracks.BotMelee)
        end
        ____temp_5 = ____temp_4
    end
    local raxM = ____temp_5
    local ____temp_7
    if lane == Lane.Top then
        ____temp_7 = GetBarracks(team, Barracks.TopRanged)
    else
        local ____temp_6
        if lane == Lane.Mid then
            ____temp_6 = GetBarracks(team, Barracks.MidRanged)
        else
            ____temp_6 = GetBarracks(team, Barracks.BotRanged)
        end
        ____temp_7 = ____temp_6
    end
    local raxR = ____temp_7
    local anc = GetAncient(team)
    local ____jmz_IsValidBuilding_result_10
    if jmz.IsValidBuilding(t3) then
        ____jmz_IsValidBuilding_result_10 = t3
    else
        local ____jmz_IsValidBuilding_result_9
        if jmz.IsValidBuilding(raxM) then
            ____jmz_IsValidBuilding_result_9 = raxM
        else
            local ____jmz_IsValidBuilding_result_8
            if jmz.IsValidBuilding(raxR) then
                ____jmz_IsValidBuilding_result_8 = raxR
            else
                ____jmz_IsValidBuilding_result_8 = nil
            end
            ____jmz_IsValidBuilding_result_9 = ____jmz_IsValidBuilding_result_8
        end
        ____jmz_IsValidBuilding_result_10 = ____jmz_IsValidBuilding_result_9
    end
    local anchorBuilding = ____jmz_IsValidBuilding_result_10
    if anchorBuilding and jmz.IsValidBuilding(anc) then
        local t = anchorBuilding:GetLocation()
        local a = anc:GetLocation()
        local dir = Vector(a.x - t.x, a.y - t.y, 0)
        local len = math.max(
            1,
            math.sqrt(dir.x * dir.x + dir.y * dir.y)
        )
        return Vector(t.x + dir.x / len * 250, t.y + dir.y / len * 250, 0)
    end
    return jmz.AdjustLocationWithOffsetTowardsFountain(
        GetLaneFrontLocation(team, lane, 0),
        600
    )
end
function ____exports.ShouldDefend(bot, hBuilding, nRadius)
    if not IsValidBuildingTarget(hBuilding) then
        return false
    end
    local enemyHeroNearby = 0
    for ____, id in ipairs(GetTeamPlayers(GetOpposingTeam())) do
        if IsHeroAlive(id) then
            local info = GetHeroLastSeenInfo(id)
            if info ~= nil then
                local d = info[1]
                if d ~= nil and d.time_since_seen <= CACHE_LASTSEEN_WINDOW and GetUnitToLocationDistance(hBuilding, d.location) <= 1600 then
                    enemyHeroNearby = enemyHeroNearby + 1
                end
            end
        end
    end
    local creepWeights = 0
    for ____, unit in ipairs(GetUnitList(UnitType.Enemies)) do
        if jmz.IsValid(unit) and GetUnitToUnitDistance(hBuilding, unit) <= nRadius then
            local name = unit:GetUnitName()
            if ({string.find(name, "siege")}) ~= nil and ({string.find(name, "upgraded")}) == nil then
                creepWeights = creepWeights + 0.5
            elseif ({string.find(name, "upgraded_mega")}) ~= nil then
                creepWeights = creepWeights + 0.6
            elseif ({string.find(name, "upgraded")}) ~= nil then
                creepWeights = creepWeights + 0.4
            elseif ({string.find(name, "warlock_golem")}) ~= nil or ({string.find(name, "shadow_shaman_ward")}) ~= nil then
                creepWeights = creepWeights + 1
            elseif ({string.find(name, "lone_druid_bear")}) ~= nil then
                enemyHeroNearby = enemyHeroNearby + 1
            elseif unit:IsCreep() or unit:IsAncientCreep() or unit:IsDominated() or unit:HasModifier("modifier_chen_holy_persuasion") or unit:HasModifier("modifier_dominated") then
                creepWeights = creepWeights + 0.2
            end
        end
    end
    local nNearby = enemyHeroNearby + math.floor(creepWeights)
    local pos = jmz.GetPosition(bot)
    local result = false
    if nNearby == 1 then
        if pos == 2 or pos == GetClosestAllyPos(
            {4, 5},
            hBuilding:GetLocation()
        ) then
            result = true
        end
    elseif nNearby == 2 then
        if pos == 2 or pos == 3 or pos == GetClosestAllyPos(
            {4, 5},
            hBuilding:GetLocation()
        ) or pos == 1 and GetUnitToUnitDistance(bot, hBuilding) <= 3200 then
            result = true
        end
    elseif nNearby == 3 then
        if pos == 2 or pos == 3 or pos == 4 or pos == 5 or pos == 1 and GetUnitToUnitDistance(bot, hBuilding) <= 3200 then
            result = true
        end
    elseif nNearby >= 4 then
        result = true
    end
    if not result then
        if DotaTime() - fTraveBootsDefendTime >= 20 then
            bot.travel_boots_defender = false
        end
        if bot:GetUnitName() == "npc_dota_hero_tinker" and bot:GetLevel() >= 6 and jmz.CanCastAbility(bot:GetAbilityByName("tinker_keen_teleport")) and IsThereNoTeammateTravelBootsDefender(bot) then
            bot.travel_boots_defender = true
            fTraveBootsDefendTime = DotaTime()
            result = true
        else
            local boots = jmz.GetItem2(bot, "item_travel_boots") or jmz.GetItem2(bot, "item_travel_boots_2")
            if jmz.CanCastAbility(boots) and IsThereNoTeammateTravelBootsDefender(bot) then
                bot.travel_boots_defender = true
                fTraveBootsDefendTime = DotaTime()
                result = true
            end
        end
        if not result and pos == GetClosestAllyPos(
            {2, 3},
            hBuilding:GetLocation()
        ) then
            result = true
        end
    end
    local underFire = bot:WasRecentlyDamagedByAnyHero(5)
    if underFire and result then
        local closestPos = GetClosestAllyPos(
            {2, 3, 4, 5},
            hBuilding:GetLocation()
        )
        if jmz.GetPosition(bot) ~= closestPos then
            return false
        end
    end
    return result
end
function ConsiderPingedDefend(bot, lane, desire, building, tier, nEffAllies, nEnemies)
    if jmz.IsInLaningPhase() or aliveAllyHeroes == 0 then
        return
    end
    if not IsValidBuildingTarget(building) then
        return
    end
    if tier < 2 or desire <= 0.5 then
        return
    end
    if not ____exports.ShouldDefend(bot, building, 1600) then
        return
    end
    jmz.Utils.GameStates = jmz.Utils.GameStates or ({})
    jmz.Utils.GameStates.defendPings = jmz.Utils.GameStates.defendPings or ({pingedTime = GameTime()})
    local defendPings = jmz.Utils.GameStates.defendPings
    if nEffAllies >= 1 and nEffAllies >= nEnemies then
        return
    end
    if GameTime() - defendPings.pingedTime <= 6 then
        return
    end
    local saferLoc = add(
        jmz.AdjustLocationWithOffsetTowardsFountain(
            building:GetLocation(),
            850
        ),
        RandomVector(50)
    )
    local retreaters = jmz.GetRetreatingAlliesNearLoc(saferLoc, 1600)
    if #retreaters == 0 then
        bot:ActionImmediate_Chat(
            Localization.Get("say_come_def"),
            false
        )
        bot:ActionImmediate_Ping(saferLoc.x, saferLoc.y, false)
        defendPings.pingedTime = GameTime()
        defendPings.lane = lane
    end
end
function ____exports.GetDefendDesireHelper(bot, lane)
    if bot.laneToDefend == nil then
        bot.laneToDefend = lane
    end
    if bot.DefendLaneDesire == nil then
        bot.DefendLaneDesire = {0, 0, 0}
    end
    currentTime = DotaTime()
    if GetGameMode() == 23 then
        currentTime = currentTime * 1.65
    end
    local team = nTeam
    local ancient = GetAncient(team)
    defendLoc = GetLaneFrontLocation(team, lane, 0)
    local distanceToDefendLoc = GetUnitToLocationDistance(bot, defendLoc)
    local botLevel = bot:GetLevel()
    if bot:GetAssignedLane() ~= lane and distanceToDefendLoc > 3000 and (jmz.GetPosition(bot) == 1 and botLevel < 6 or jmz.GetPosition(bot) == 2 and botLevel < 6 or jmz.GetPosition(bot) == 3 and botLevel < 5 or jmz.GetPosition(bot) == 4 and botLevel < 4 or jmz.GetPosition(bot) == 5 and botLevel < 4) then
        return BotModeDesire.None
    end
    if botLevel < 3 then
        return BotModeDesire.None
    end
    local recentlyHit = bot:WasRecentlyDamagedByAnyHero(5) or bot:WasRecentlyDamagedByTower(5)
    local threatenedLane = GetThreatenedLane()
    local panic = {active = false, floor = 0}
    local enemiesAtAncient = jmz.Utils.CountEnemyHeroesNear(
        ancient:GetLocation(),
        2200
    )
    local enemiesOnHG = jmz.Utils.CountEnemyHeroesOnHighGround(nTeam)
    if enemiesOnHG >= 2 and not recentlyHit then
        if lane ~= threatenedLane then
            return BotModeDesire.VeryLow
        end
        baseThreatUntil = DotaTime() + BASE_THREAT_HOLD
        panic = {
            active = true,
            floor = 0.96,
            forceLoc = jmz.AdjustLocationWithOffsetTowardsFountain(
                ancient:GetLocation(),
                300
            )
        }
        bot.laneToDefend = lane
    end
    if enemiesAtAncient >= 1 then
        if lane ~= threatenedLane then
            return BotModeDesire.VeryLow
        end
        local defenders = jmz.GetAlliesNearLoc(
            ancient:GetLocation(),
            1600
        )
        local anyThere = __TS__ArraySome(
            defenders,
            function(____, a) return jmz.IsValidHero(a) end
        )
        if not anyThere then
            local pos = jmz.GetPosition(bot)
            local isSupport = pos == 4 or pos == 5
            local closestSupportPos = GetClosestAllyPos(
                {4, 5},
                ancient:GetLocation()
            )
            if isSupport and pos == closestSupportPos then
                panic = {
                    active = true,
                    floor = math.max(panic.floor, 0.94),
                    forceLoc = jmz.AdjustLocationWithOffsetTowardsFountain(
                        ancient:GetLocation(),
                        300
                    )
                }
                bot.laneToDefend = lane
            end
        end
    end
    local isBaseThreatActive = IsBaseThreatActive()
    local heroesNearAncient = jmz.Utils.CountEnemyHeroesNear(
        ancient:GetLocation(),
        BASE_THREAT_RADIUS
    )
    if heroesNearAncient >= 1 then
        baseThreatUntil = DotaTime() + BASE_THREAT_HOLD
    elseif isBaseThreatActive then
        local creepWeight = WeightedEnemiesAroundLocation(
            ancient:GetLocation(),
            BASE_THREAT_RADIUS
        )
        if creepWeight >= 2 then
            baseThreatUntil = DotaTime() + 1.5
        end
    end
    if panic.active and panic.forceLoc then
        defendLoc = panic.forceLoc
    elseif isBaseThreatActive then
        defendLoc = jmz.AdjustLocationWithOffsetTowardsFountain(
            ancient:GetLocation(),
            300
        )
    end
    if isBaseThreatActive then
        if lane ~= threatenedLane then
            return BotModeDesire.VeryLow
        end
    else
        if jmz.Utils.GetLocationToLocationDistance(
            jmz.Utils.GetTeamFountainTpPoint(),
            defendLoc
        ) < 3000 then
            local enemyLaneFront = GetLaneFrontLocation(
                GetOpposingTeam(),
                lane,
                0
            )
            local eNear = jmz.GetLastSeenEnemiesNearLoc(enemyLaneFront, 1600)
            local aNear = jmz.GetAlliesNearLoc(enemyLaneFront, 1600)
            if GetUnitToLocationDistance(bot, enemyLaneFront) > bot:GetAttackRange() and #eNear <= #aNear + 1 then
                defendLoc = enemyLaneFront
                bot:Action_AttackMove(defendLoc)
            end
        end
    end
    distanceToLane[lane] = GetUnitToLocationDistance(bot, defendLoc)
    nInRangeAlly = jmz.GetNearbyHeroes(bot, 1600, false, BotMode.None)
    nInRangeEnemy = jmz.GetLastSeenEnemiesNearLoc(
        bot:GetLocation(),
        1600
    )
    weAreStronger = jmz.WeAreStronger(bot, 2500)
    aliveAllyHeroes = jmz.GetNumOfAliveHeroes(false)
    local pos = jmz.GetPosition(bot)
    local bMyLane = bot:GetAssignedLane() == lane
    if #nInRangeEnemy > 0 or not bMyLane and pos == 1 and jmz.IsInLaningPhase() or jmz.IsDoingRoshan(bot) and #jmz.GetAlliesNearLoc(
        jmz.GetCurrentRoshanLocation(),
        2800
    ) >= 3 or jmz.IsDoingTormentor(bot) and (#jmz.GetAlliesNearLoc(
        jmz.GetTormentorLocation(team),
        1600
    ) >= 2 or #jmz.GetAlliesNearLoc(
        jmz.GetTormentorWaitingLocation(team),
        2500
    ) >= 2) and enemiesAtAncient == 0 then
        return BotModeDesire.VeryLow
    end
    local pingFloor = 0
    local human, humanPing = jmz.GetHumanPing()
    if human and humanPing and not humanPing.normal_ping and DotaTime() > 0 then
        local isPinged, pingedLane = jmz.IsPingCloseToValidTower(team, humanPing, 800, 5)
        if isPinged and lane == pingedLane and GameTime() < humanPing.time + PING_DELTA then
            bot.laneToDefend = lane
            pingFloor = 0.95
        end
    end
    local furthestBuilding, urgentMul, buildingTier = unpack(____exports.GetFurthestBuildingOnLane(lane))
    if not IsValidBuildingTarget(furthestBuilding) then
        return BotModeDesire.None
    end
    local shouldDef = ____exports.ShouldDefend(bot, furthestBuilding, 1600)
    if not shouldDef then
        local dist = distanceToLane[lane]
        local tp = jmz.Utils.GetItemFromFullInventory(bot, "item_tpscroll")
        local nearEnemiesAtBuilding = jmz.GetLastSeenEnemiesNearLoc(
            furthestBuilding:GetLocation(),
            1200
        )
        if not jmz.CanCastAbility(tp) and dist and dist > 4000 and #nearEnemiesAtBuilding == 0 or #nearEnemiesAtBuilding == 0 and #jmz.GetAlliesNearLoc(
            furthestBuilding:GetLocation(),
            1600
        ) >= 1 then
            return BotModeDesire.VeryLow
        end
    end
    local nDefendDesire = GetDefendLaneDesire(lane)
    local hub = IsValidBuildingTarget(furthestBuilding) and furthestBuilding:GetLocation() or GetLaneFrontLocation(nTeam, lane, 0)
    local lEnemies = jmz.GetLastSeenEnemiesNearLoc(hub, 2500)
    local nDefendAllies = jmz.GetAlliesNearLoc(hub, 2500)
    local nEffAllies = #nDefendAllies + #jmz.Utils.GetAllyIdsInTpToLocation(hub, 2500)
    if #lEnemies == 0 and (jmz.IsAnyAllyDefending(bot, lane) or jmz.IsCore(bot)) then
        return BotModeDesire.VeryLow
    end
    if #lEnemies == 1 and (nEffAllies > #lEnemies or jmz.IsAnyAllyDefending(bot, lane) and jmz.GetAverageLevel(GetTeam()) >= jmz.GetAverageLevel(GetOpposingTeam())) then
        return BotModeDesire.VeryLow
    end
    local capBoost = shouldDef and 0.1 or 0
    local maxDesire = (buildingTier >= 3 and nEffAllies >= #lEnemies and 1 or MAX_DESIRE_CAP) + capBoost
    maxDesire = math.min(maxDesire, 1)
    local baseFloor = shouldDef and BotActionDesire.Low or BotActionDesire.VeryLow
    nDefendDesire = RemapValClamped(
        jmz.GetHP(bot),
        0.75,
        0.2,
        RemapValClamped(
            nDefendDesire * urgentMul,
            0,
            1,
            baseFloor,
            maxDesire
        ),
        BotActionDesire.Low
    )
    do
        local dist = distanceToLane[lane]
        if dist and dist < 1600 and #nInRangeEnemy > #nInRangeAlly and not weAreStronger then
            nDefendDesire = RemapValClamped(
                nDefendDesire,
                0,
                1,
                BotActionDesire.VeryLow,
                BotActionDesire.High
            )
        end
    end
    local botTarget = jmz.GetProperTarget(bot)
    if jmz.IsValidHero(botTarget) and jmz.GetHP(botTarget) < 0.6 and jmz.GetHP(bot) > jmz.GetHP(botTarget) and GetUnitToUnitDistance(bot, botTarget) < 1500 then
        nDefendDesire = nDefendDesire * 0.4
    end
    do
        local tp = jmz.Utils.GetItemFromFullInventory(bot, "item_tpscroll")
        local dist = distanceToLane[lane]
        if not jmz.CanCastAbility(tp) and dist and dist > 4000 then
            local nearEnemies = jmz.GetLastSeenEnemiesNearLoc(
                furthestBuilding:GetLocation(),
                1200
            )
            if #nearEnemies == 0 or bot:WasRecentlyDamagedByAnyHero(2) then
                nDefendDesire = nDefendDesire * 0.5
            end
            nDefendDesire = RemapValClamped(
                dist / 4000,
                0,
                2,
                nDefendDesire,
                BotActionDesire.VeryLow
            )
        end
    end
    if IsValidBuildingTarget(furthestBuilding) and furthestBuilding ~= ancient then
        local hp = jmz.GetHP(furthestBuilding)
        if buildingTier == 1 and hp <= 0.15 or buildingTier == 2 and hp <= 0.1 then
            return BotModeDesire.None
        end
    end
    if panic.active then
        nDefendDesire = math.max(nDefendDesire, panic.floor)
    end
    if pingFloor > 0 then
        nDefendDesire = math.max(nDefendDesire, pingFloor)
    end
    ConsiderPingedDefend(
        bot,
        lane,
        nDefendDesire,
        furthestBuilding,
        buildingTier,
        nEffAllies,
        #lEnemies
    )
    if recentlyHit then
        nDefendDesire = nDefendDesire * 0.4
        if #nInRangeEnemy >= #nInRangeAlly and not weAreStronger then
            nDefendDesire = math.min(nDefendDesire, BotActionDesire.Low)
        end
    end
    if nDefendDesire > 0.7 then
        jmz.Utils.GameStates = jmz.Utils.GameStates or ({})
        jmz.Utils.GameStates.recentDefendTime = DotaTime()
        bot.laneToDefend = lane
    end
    return nDefendDesire
end
okLoc, Localization = pcall(
    require,
    GetScriptDirectory() .. "/FunLib/localization"
)
if not okLoc then
    Localization = {Get = function(_) return "Defend here!" end}
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
PING_DELTA = 5
local SEARCH_RANGE_DEFAULT = 1600
MAX_DESIRE_CAP = 0.98
BASE_THREAT_RADIUS = 2600
local BASE_LEASH_OUTBOUND = 1200
BASE_THREAT_HOLD = 4
CACHE_ENEMY_AROUND_LOC_HZ = 0.35
CACHE_LASTSEEN_WINDOW = 5
nTeam = GetTeam()
currentTime = 0
defendLoc = GetLaneFrontLocation(
    GetTeam(),
    Lane.Mid,
    0
)
aliveAllyHeroes = 0
weAreStronger = false
nInRangeAlly = {}
nInRangeEnemy = {}
_threatLaneSticky = {lane = Lane.Mid, ["until"] = -1}
distanceToLane = {[Lane.Top] = 0, [Lane.Mid] = 0, [Lane.Bot] = 0}
baseThreatUntil = -1
fTraveBootsDefendTime = 0
_cacheEnemyAroundLoc = {}
function ____exports.GetDefendDesire(bot, lane)
    if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not __TS__StringIncludes(
        bot:GetUnitName(),
        "hero"
    ) or bot:IsIllusion() then
        return BotModeDesire.None
    end
    local res = ____exports.GetDefendDesireHelper(bot, lane)
    bot.defendDesire = res
    return res
end
function ____exports.DefendThink(bot, lane)
    if jmz.CanNotUseAction(bot) then
        return
    end
    if jmz.Utils.IsBotThinkingMeaningfulAction(bot, Customize.ThinkLess, "defend") then
        return
    end
    local pathEnemies = jmz.GetLastSeenEnemiesNearLoc(
        bot:GetLocation(),
        1600
    )
    if bot:WasRecentlyDamagedByAnyHero(5) and #pathEnemies > #nInRangeEnemy then
        local safe = jmz.AdjustLocationWithOffsetTowardsFountain(
            bot:GetLocation(),
            700
        )
        bot:Action_MoveToLocation(add(
            safe,
            jmz.RandomForwardVector(120)
        ))
        return
    end
    if IsBaseThreatActive() then
        local ancient = GetAncient(nTeam)
        local anchor = jmz.AdjustLocationWithOffsetTowardsFountain(
            ancient:GetLocation(),
            200
        )
        local toAnc = GetUnitToUnitDistance(bot, ancient)
        if toAnc > BASE_LEASH_OUTBOUND then
            bot:Action_MoveToLocation(add(
                anchor,
                jmz.RandomForwardVector(250)
            ))
            return
        end
        local nSearchRange = 1400
        local enemiesNear = jmz.GetEnemiesNearLoc(
            ancient:GetLocation(),
            nSearchRange
        )
        if jmz.IsValidHero(enemiesNear[1]) and jmz.IsInRange(bot, enemiesNear[1], nSearchRange) then
            bot:Action_AttackUnit(enemiesNear[1], true)
            return
        end
        bot:Action_AttackMove(add(
            anchor,
            jmz.RandomForwardVector(300)
        ))
        return
    end
    local attackRange = bot:GetAttackRange()
    local nSearchRange = attackRange < 900 and 900 or math.min(attackRange, SEARCH_RANGE_DEFAULT)
    if not defendLoc then
        defendLoc = GetLaneFrontLocation(nTeam, lane, 0)
    end
    local bld, _, buildingTier = unpack(____exports.GetFurthestBuildingOnLane(lane))
    local hub = defendLoc
    if IsValidBuildingTarget(bld) then
        hub = bld:GetLocation()
    end
    if not hub then
        hub = GetLaneFrontLocation(nTeam, lane, 0)
    end
    if buildingTier >= 3 then
        local edgeInside = GetHighGroundEdgeWaitPoint(nTeam, lane)
        local enemyAtHG = jmz.Utils.CountEnemyHeroesOnHighGround(nTeam)
        local nearEdgeEnemies = jmz.GetLastSeenEnemiesNearLoc(edgeInside, 1200)
        local nearEdgeAllies = jmz.GetAlliesNearLoc(edgeInside, 1400)
        if enemyAtHG == 0 and #nearEdgeEnemies > 0 and #nearEdgeAllies >= #nearEdgeEnemies + 1 then
            bot:Action_AttackMove(add(
                edgeInside,
                jmz.RandomForwardVector(120)
            ))
        else
            local deeper = jmz.AdjustLocationWithOffsetTowardsFountain(edgeInside, 200)
            bot:Action_AttackMove(add(
                deeper,
                jmz.RandomForwardVector(120)
            ))
        end
        return
    end
    local enemiesAtHub = jmz.GetEnemiesNearLoc(hub, SEARCH_RANGE_DEFAULT)
    if jmz.IsValidHero(enemiesAtHub[1]) and jmz.IsInRange(bot, enemiesAtHub[1], nSearchRange) then
        bot:Action_AttackUnit(enemiesAtHub[1], true)
        return
    end
    local nEnemyHeroes = bot:GetNearbyHeroes(SEARCH_RANGE_DEFAULT, true, BotMode.None)
    if jmz.IsValidHero(nEnemyHeroes[1]) and jmz.IsInRange(bot, nEnemyHeroes[1], nSearchRange) then
        bot:Action_AttackUnit(nEnemyHeroes[1], true)
        return
    end
    local creeps = bot:GetNearbyCreeps(900, true)
    if creeps and #creeps > 0 and (not enemiesAtHub or #enemiesAtHub == 0) then
        local best = nil
        local bestDmg = -1
        do
            local i = 1
            while i <= #creeps do
                local c = creeps[i + 1]
                if jmz.IsValid(c) and jmz.CanBeAttacked(c) then
                    local dmg = c:GetAttackDamage()
                    if dmg > bestDmg then
                        best = c
                        bestDmg = dmg
                    end
                end
                i = i + 1
            end
        end
        if best then
            bot:Action_AttackUnit(best, true)
            return
        end
    end
    if bld and ____exports.ShouldDefend(bot, bld, 1600) then
        bot:Action_AttackMove(add(
            hub,
            jmz.RandomForwardVector(300)
        ))
        return
    end
    local dist = distanceToLane[lane] or GetUnitToLocationDistance(bot, hub)
    if (weAreStronger or #nInRangeAlly >= #nInRangeEnemy) and dist < SEARCH_RANGE_DEFAULT then
        bot:Action_AttackMove(add(
            hub,
            jmz.RandomForwardVector(300)
        ))
    elseif dist > SEARCH_RANGE_DEFAULT * 1.7 then
        bot:Action_MoveToLocation(add(
            hub,
            jmz.RandomForwardVector(300)
        ))
    else
        bot:Action_MoveToLocation(add(
            hub,
            jmz.RandomForwardVector(1000)
        ))
    end
end
function ____exports.OnEnd()
end
return ____exports
