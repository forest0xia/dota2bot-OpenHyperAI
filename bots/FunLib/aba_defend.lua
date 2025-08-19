local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local okLoc, Localization = pcall(require, GetScriptDirectory()..'/FunLib/localization')
if not okLoc then Localization = { Get = function(_) return 'Defend here!' end } end

local Defend = {}

-- == Tunables ==
local PING_DELTA                 = 5.0
local SEARCH_RANGE_DEFAULT       = 1600
local CLOSE_RANGE                = 1200
local MAX_DESIRE_CAP             = 0.98

-- Base threat (Ancient defense)
local BASE_THREAT_RADIUS         = 2600
local BASE_LEASH_OUTBOUND        = 1200
local BASE_THREAT_HOLD           = 4.0

-- Perf: cache intervals (seconds)
local CACHE_ENEMY_AROUND_LOC_HZ  = 0.35    -- cache for weighted enemy scans around a location
local CACHE_SHOULD_DEFEND_HZ     = 0.50    -- cache ShouldDefend result per-building/loc
local CACHE_LASTSEEN_WINDOW      = 5.0     -- seconds for hero last-seen proximity checks

-- == State ==
local nTeam                      = GetTeam()
local currentTime                = 0
local defendLoc                  = nil
local aliveAllyHeroes            = 0
local weAreStronger              = false
local nInRangeAlly               = {}
local nInRangeEnemy              = {}
local distanceToLane             = { [LANE_TOP] = 0, [LANE_MID] = 0, [LANE_BOT] = 0 }

Defend._baseThreatUntil          = -1        -- sticky base-threat end time

-- Travel Boots defender coordination
local fTraveBootsDefendTime      = 0

-- == Perf caches ==
local _cacheEnemyAroundLoc = {}  -- key -> {t, count}

-- small utils (keep GC low)
local function _q(v)  return (v and (math.floor(v.x/200)*200 .. ':' .. math.floor(v.y/200)*200)) or '0:0' end
local function _keyLoc(v, r) return _q(v) .. '|' .. tostring(math.floor(r or 0)) end

-- == Small helpers ==
local function IsValidBuildingTarget(unit)
    return unit ~= nil and unit:IsAlive() and unit:IsBuilding() and unit:CanBeSeen()
end

local function IsBaseThreatActive()
    return DotaTime() < (Defend._baseThreatUntil or -1)
end

-- If any enemy units (weighted) are around location; cached
local function WeightedEnemiesAroundLocation(vLoc, nRadius)
    local now = DotaTime()
    local key = _keyLoc(vLoc, nRadius)
    local c = _cacheEnemyAroundLoc[key]
    if c and now - c.t <= CACHE_ENEMY_AROUND_LOC_HZ then
        return c.count
    end

    local count = 0
    local ulist = GetUnitList(UNIT_LIST_ENEMIES)
    for i = 1, #ulist do
        local unit = ulist[i]
        if J.IsValid(unit) and GetUnitToLocationDistance(unit, vLoc) <= nRadius then
            local name = unit:GetUnitName()
            if J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) then
                count = count + (J.IsCore(unit) and 1 or 0.5)
            elseif string.find(name, 'upgraded_mega') then
                count = count + 0.6
            elseif string.find(name, 'upgraded') then
                count = count + 0.4
            elseif string.find(name, 'siege') and not string.find(name, 'upgraded') then
                count = count + 0.5
            elseif string.find(name, 'warlock_golem') or string.find(name, 'lone_druid_bear') then
                count = count + 1
            elseif unit:IsCreep() or unit:IsAncientCreep() or unit:IsDominated()
                or unit:HasModifier('modifier_chen_holy_persuasion') or unit:HasModifier('modifier_dominated') then
                count = count + 0.2
            end
        end
    end

    count = math.floor(count)
    _cacheEnemyAroundLoc[key] = { t = now, count = count }
    return count
end

-- Grid size for rounding (smaller = less chance of collisions)
local BUILDING_KEY_GRID = 128

local function _bkey_from_loc(u)
    local v = u and u:GetLocation()
    if not v then return '0:0' end
    local gx = math.floor(v.x / BUILDING_KEY_GRID) * BUILDING_KEY_GRID
    local gy = math.floor(v.y / BUILDING_KEY_GRID) * BUILDING_KEY_GRID
    return tostring(gx) .. ':' .. tostring(gy)
end

local function GetThreatenedLane()
    local team = nTeam
    local lanes = {LANE_TOP, LANE_MID, LANE_BOT}
    local bestLane, bestScore = LANE_MID, -1
    for _, ln in ipairs(lanes) do
        local bld = Defend.GetFurthestBuildingOnLane(ln)
        local anchor = (IsValidBuildingTarget(bld) and bld:GetLocation()) or GetLaneFrontLocation(team, ln, 0)
        local score = WeightedEnemiesAroundLocation(anchor, 2000)
        if score > bestScore then bestScore, bestLane = score, ln end
    end
    return bestLane
end

-- Closest ally role among a list to given location
local function GetClosestAllyPos(tPosList, vLocation)
    local bestPos, bestDist = nil, math.huge
    for i = 1, 5 do
        local m = GetTeamMember(i)
        if J.IsValidHero(m) then
            local p = J.GetPosition(m)
            for j = 1, #tPosList do
                if p == tPosList[j] then
                    local d = GetUnitToLocationDistance(m, vLocation)
                    if d < bestDist then
                        bestDist = d
                        bestPos = p
                    end
                end
            end
        end
    end
    return bestPos or tPosList[1]
end

-- == Core building selection ==
-- Returns: furthestBuilding, urgencyMultiplier, tier (1..4)
function Defend.GetFurthestBuildingOnLane(lane)
    local team = nTeam
    local b
    local function hpMul(u, lo, hi, mlo, mhi)
        local nHealth = u:GetHealth() / u:GetMaxHealth()
        return RemapValClamped(nHealth, lo, hi, mlo, mhi)
    end

    if lane == LANE_TOP then
        b = GetTower(team, TOWER_TOP_1);  if IsValidBuildingTarget(b) then return b, hpMul(b, 0.25, 1, 1.0, 3), 1 end
        b = GetTower(team, TOWER_TOP_2);  if IsValidBuildingTarget(b) then return b, hpMul(b, 0.25, 1, 1.0, 2), 2 end
        b = GetTower(team, TOWER_TOP_3);  if IsValidBuildingTarget(b) then return b, hpMul(b, 0.25, 1, 1.5, 2), 3 end
        b = GetBarracks(team, BARRACKS_TOP_MELEE);  if IsValidBuildingTarget(b) then return b, 2.5, 3 end
        b = GetBarracks(team, BARRACKS_TOP_RANGED); if IsValidBuildingTarget(b) then return b, 2.5, 3 end
        b = GetTower(team, TOWER_BASE_1); if IsValidBuildingTarget(b) then return GetAncient(team), 2.5, 3 end
        b = GetTower(team, TOWER_BASE_2); if IsValidBuildingTarget(b) then return GetAncient(team), 2.5, 3 end
        b = GetAncient(team);             if IsValidBuildingTarget(b) then return b, 3.0, 4 end
    elseif lane == LANE_MID then
        b = GetTower(team, TOWER_MID_1);  if IsValidBuildingTarget(b) then return b, hpMul(b, 0.25, 1, 1.0, 3), 1 end
        b = GetTower(team, TOWER_MID_2);  if IsValidBuildingTarget(b) then return b, hpMul(b, 0.25, 1, 1.0, 2), 2 end
        b = GetTower(team, TOWER_MID_3);  if IsValidBuildingTarget(b) then return b, hpMul(b, 0.25, 1, 1.5, 2), 3 end
        b = GetBarracks(team, BARRACKS_MID_MELEE);  if IsValidBuildingTarget(b) then return b, 2.5, 3 end
        b = GetBarracks(team, BARRACKS_MID_RANGED); if IsValidBuildingTarget(b) then return b, 2.5, 3 end
        b = GetTower(team, TOWER_BASE_1); if IsValidBuildingTarget(b) then return GetAncient(team), 2.5, 3 end
        b = GetTower(team, TOWER_BASE_2); if IsValidBuildingTarget(b) then return GetAncient(team), 2.5, 3 end
        b = GetAncient(team);             if IsValidBuildingTarget(b) then return b, 3.0, 4 end
    else
        b = GetTower(team, TOWER_BOT_1);  if IsValidBuildingTarget(b) then return b, hpMul(b, 0.25, 1, 1.0, 3), 1 end
        b = GetTower(team, TOWER_BOT_2);  if IsValidBuildingTarget(b) then return b, hpMul(b, 0.25, 1, 1.0, 2), 2 end
        b = GetTower(team, TOWER_BOT_3);  if IsValidBuildingTarget(b) then return b, hpMul(b, 0.25, 1, 1.5, 2), 3 end
        b = GetBarracks(team, BARRACKS_BOT_MELEE);  if IsValidBuildingTarget(b) then return b, 2.5, 3 end
        b = GetBarracks(team, BARRACKS_BOT_RANGED); if IsValidBuildingTarget(b) then return b, 2.5, 3 end
        b = GetTower(team, TOWER_BASE_1); if IsValidBuildingTarget(b) then return GetAncient(team), 2.5, 3 end
        b = GetTower(team, TOWER_BASE_2); if IsValidBuildingTarget(b) then return GetAncient(team), 2.5, 3 end
        b = GetAncient(team);             if IsValidBuildingTarget(b) then return b, 3.0, 4 end
    end

    return nil, 1.0, 0
end

-- Travel Boots defender dedupe
local function IsThereNoTeammateTravelBootsDefender(bot)
    for i = 1, 5 do
        local m = GetTeamMember(i)
        if bot ~= m and J.IsValidHero(m) and m.travel_boots_defender == true then
            return false
        end
    end
    return true
end

-- Role-aware defend decision (cached)
function Defend.ShouldDefend(bot, hBuilding, nRadius)
    if not IsValidBuildingTarget(hBuilding) then return false end

    -- Count enemies near building (recent seen heroes + weighted creeps)
    local enemyHeroNearby = 0
    for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
        if IsHeroAlive(id) then
            local info = GetHeroLastSeenInfo(id)
            if info ~= nil then
                local d = info[1]
                if d ~= nil and d.time_since_seen <= CACHE_LASTSEEN_WINDOW
                    and GetUnitToLocationDistance(hBuilding, d.location) <= 1600 then
                    enemyHeroNearby = enemyHeroNearby + 1
                end
            end
        end
    end

    local creepWeights = 0
    local ulist = GetUnitList(UNIT_LIST_ENEMIES)
    for i = 1, #ulist do
        local unit = ulist[i]
        if J.IsValid(unit) and GetUnitToUnitDistance(hBuilding, unit) <= nRadius then
            local name = unit:GetUnitName()
            if string.find(name, 'siege') and not string.find(name, 'upgraded') then
                creepWeights = creepWeights + 0.5
            elseif string.find(name, 'upgraded_mega') then
                creepWeights = creepWeights + 0.6
            elseif string.find(name, 'upgraded') then
                creepWeights = creepWeights + 0.4
            elseif string.find(name, 'warlock_golem') or string.find(name, 'shadow_shaman_ward') then
                creepWeights = creepWeights + 1.0
            elseif string.find(name, 'lone_druid_bear') then
                enemyHeroNearby = enemyHeroNearby + 1
            elseif unit:IsCreep() or unit:IsAncientCreep() or unit:IsDominated()
                or unit:HasModifier('modifier_chen_holy_persuasion') or unit:HasModifier('modifier_dominated') then
                creepWeights = creepWeights + 0.2
            end
        end
    end

    local nNearby = enemyHeroNearby + math.floor(creepWeights)
    local pos = J.GetPosition(bot)

    local result = false
    if nNearby == 1 then
        if (pos == 2) or (pos == GetClosestAllyPos({4,5}, hBuilding:GetLocation())) then
            result = true
        end
    elseif nNearby == 2 then
        if (pos == 2) or (pos == 3) or (pos == GetClosestAllyPos({4,5}, hBuilding:GetLocation()))
            or (pos == 1 and GetUnitToUnitDistance(bot, hBuilding) <= 3200) then
            result = true
        end
    elseif nNearby == 3 then
        if (pos == 2) or (pos == 3) or (pos == 4) or (pos == 5)
            or (pos == 1 and GetUnitToUnitDistance(bot, hBuilding) <= 3200) then
            result = true
        end
    elseif nNearby >= 4 then
        result = true
    end

    -- Travel Boots/Tinker escalation (one defender at a time)
    if not result then
        if DotaTime() - fTraveBootsDefendTime >= 20.0 then
            bot.travel_boots_defender = false
        end
        if (bot:GetUnitName() == 'npc_dota_hero_tinker'
            and bot:GetLevel() >= 6
            and J.CanCastAbility(bot:GetAbilityByName('tinker_keen_teleport'))
            and IsThereNoTeammateTravelBootsDefender(bot))
        then
            bot.travel_boots_defender = true
            fTraveBootsDefendTime = DotaTime()
            result = true
        else
            local boots = J.GetItem2(bot, 'item_travel_boots') or J.GetItem2(bot, 'item_travel_boots_2')
            if J.CanCastAbility(boots) and IsThereNoTeammateTravelBootsDefender(bot) then
                bot.travel_boots_defender = true
                fTraveBootsDefendTime = DotaTime()
                result = true
            end
        end

        if not result and pos == GetClosestAllyPos({2,3}, hBuilding:GetLocation()) then
            result = true
        end
    end

    return result
end

-- Ping teammates to defend (rate-limited; role-aware)
local function ConsiderPingedDefend(bot, desire, building, tier, nEffAllies, nEnemies)
    if J.IsInLaningPhase() or aliveAllyHeroes == 0 then return end
    if not IsValidBuildingTarget(building) then return end
    if tier < 2 or desire <= 0.5 then return end
    if not Defend.ShouldDefend(bot, building, 1600) then return end

    J.Utils['GameStates'] = J.Utils['GameStates'] or {}
    J.Utils['GameStates']['defendPings'] = J.Utils['GameStates']['defendPings'] or { pingedTime = GameTime() }

    if nEffAllies >= 1 and nEffAllies >= nEnemies then return end
    if GameTime() - J.Utils['GameStates']['defendPings'].pingedTime <= 6.0 then return end

    local saferLoc = J.AdjustLocationWithOffsetTowardsFountain(building:GetLocation(), 850) + RandomVector(50)
    local retreaters = J.GetRetreatingAlliesNearLoc(saferLoc, 1600)
    if #retreaters == 0 then
        bot:ActionImmediate_Chat(Localization.Get('say_come_def'), false)
        bot:ActionImmediate_Ping(saferLoc.x, saferLoc.y, false)
        J.Utils['GameStates']['defendPings'].pingedTime = GameTime()
    end
end

function Defend.GetDefendDesire(bot, lane)
    local cacheKey = ('DefendDesire:%d:%d'):format(bot:GetPlayerID(), lane or -1)
    local cachedVar = J.Utils.GetCachedVars(cacheKey, 0.6)
    if cachedVar ~= nil then return cachedVar end
	local res = Defend.GetDefendDesireHelper(bot, lane)
	J.Utils.SetCachedVars(cacheKey, res)
	bot.defendDesire = res
	return res
end

function Defend.GetDefendDesireHelper(bot, lane)
    if bot:IsIllusion() then return BOT_MODE_DESIRE_NONE end
    if bot.laneToDefend == nil then bot.laneToDefend = lane end
    if bot.DefendLaneDesire == nil then bot.DefendLaneDesire = {0,0,0} end

    currentTime = DotaTime()
    if GetGameMode() == 23 then currentTime = currentTime * 1.65 end

    local team    = nTeam
    local ancient = GetAncient(team)

    defendLoc = GetLaneFrontLocation(team, lane, 0)

    -- Base threat detection (sticky)
    local enemiesAtAncient = WeightedEnemiesAroundLocation(ancient:GetLocation(), BASE_THREAT_RADIUS)
    if enemiesAtAncient >= 2 then
        Defend._baseThreatUntil = DotaTime() + BASE_THREAT_HOLD
    end

    if IsBaseThreatActive() then
        -- defend near Ancient but only on the threatened lane
        local threatenedLane = GetThreatenedLane()
        defendLoc = J.AdjustLocationWithOffsetTowardsFountain(ancient:GetLocation(), 300)
        if lane ~= threatenedLane then
            return BOT_MODE_DESIRE_NONE
        end
    else
        -- Opportunistically use enemy lanefront ONLY if not in base threat
        if J.Utils.GetLocationToLocationDistance(J.Utils.GetTeamFountainTpPoint(), defendLoc) < 3000 then
            local enemyLaneFront = GetLaneFrontLocation(GetOpposingTeam(), lane, 0)
            local eNear = J.GetLastSeenEnemiesNearLoc(enemyLaneFront, 1600)
            local aNear = J.GetAlliesNearLoc(enemyLaneFront, 1600)
            if GetUnitToLocationDistance(bot, enemyLaneFront) > bot:GetAttackRange() and #eNear <= #aNear + 1 then
                defendLoc = enemyLaneFront
                bot:Action_AttackMove(defendLoc)
            end
        end
    end

    distanceToLane[lane] = GetUnitToLocationDistance(bot, defendLoc)
    nInRangeAlly  = J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_NONE)
    nInRangeEnemy = J.GetLastSeenEnemiesNearLoc(bot:GetLocation(), 1600)

    weAreStronger     = J.WeAreStronger(bot, 2500)
    aliveAllyHeroes   = J.GetNumOfAliveHeroes(false)

    -- Bail-outs to avoid feed / conflicts
    local pos     = J.GetPosition(bot)
    local bMyLane = (bot:GetAssignedLane() == lane)
    if #nInRangeEnemy > 0
        or (not bMyLane and pos == 1 and J.IsInLaningPhase()) -- keep carry safe early
        or (J.IsDoingRoshan(bot) and #J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), 2800) >= 3)
        or (J.IsDoingTormentor(bot) and (#J.GetAlliesNearLoc(J.GetTormentorLocation(team), 1600) >= 2
            or #J.GetAlliesNearLoc(J.GetTormentorWaitingLocation(team), 2500) >= 2) and enemiesAtAncient == 0)
    then
        return BOT_MODE_DESIRE_NONE
    end

    -- Human priority ping
    local human, humanPing = J.GetHumanPing()
    if human and humanPing and not humanPing.normal_ping and DotaTime() > 0 then
        local isPinged, pingedLane = J.IsPingCloseToValidTower(team, humanPing, 700, 5.0)
        if isPinged and lane == pingedLane and GameTime() < humanPing.time + PING_DELTA then
            bot.laneToDefend = lane
            return 0.9
        end
    end

    -- Compute desire anchored on furthest building
    local furthestBuilding, urgentMul, buildingTier = Defend.GetFurthestBuildingOnLane(lane)
    if not IsValidBuildingTarget(furthestBuilding) then
        return BOT_MODE_DESIRE_NONE
    end

    -- Use ShouldDefend to gate/dampen
    local shouldDef = Defend.ShouldDefend(bot, furthestBuilding, 1600)
    if not shouldDef then
        local dist = distanceToLane[lane]
        local tp   = J.Utils.GetItemFromFullInventory(bot, 'item_tpscroll')
        local nearEnemiesAtBuilding = J.GetLastSeenEnemiesNearLoc(furthestBuilding:GetLocation(), 1200)
        if (not J.CanCastAbility(tp) and dist and dist > 4000 and #nearEnemiesAtBuilding == 0)
            or (#nearEnemiesAtBuilding == 0 and #J.GetAlliesNearLoc(furthestBuilding:GetLocation(), 1600) >= 1) then
            return BOT_MODE_DESIRE_NONE
        end
    end

    local nDefendDesire = GetDefendLaneDesire(lane)

    -- Avoid dogpile if enemies absent & allies/core already covering
    local nDefendAllies = J.GetAlliesNearLoc(defendLoc, 2500)
    local nEffAllies    = #nDefendAllies + #J.Utils.GetAllyIdsInTpToLocation(defendLoc, 2500)
    local lEnemies      = J.GetLastSeenEnemiesNearLoc(defendLoc, 2500)
    if #lEnemies == 0 and (J.IsAnyAllyDefending(bot, lane) or J.IsCore(bot)) then
        return BOT_MODE_DESIRE_NONE
    end
    if #lEnemies == 1 and (nEffAllies > #lEnemies
        or (J.IsAnyAllyDefending(bot, lane) and J.GetAverageLevel(false) >= J.GetAverageLevel(true))) then
        return BOT_MODE_DESIRE_NONE
    end

    -- Cap & floor via ShouldDefend & tier
    local capBoost  = shouldDef and 0.1 or 0.0
    local maxDesire = ((buildingTier >= 3 and nEffAllies >= #lEnemies) and 1.0 or MAX_DESIRE_CAP) + capBoost
    maxDesire       = math.min(maxDesire, 1.0)
    local baseFloor = shouldDef and BOT_ACTION_DESIRE_VERYLOW or BOT_ACTION_DESIRE_NONE

    nDefendDesire = RemapValClamped(
        J.GetHP(bot), 0.75, 0.20,
        RemapValClamped(nDefendDesire * urgentMul, 0, 1, baseFloor, maxDesire),
        BOT_ACTION_DESIRE_LOW
    )

    -- Be cautious if outnumbered near destination and not stronger
    local dist = distanceToLane[lane]
    if dist and dist < 1600 and #nInRangeEnemy > #nInRangeAlly and not weAreStronger then
        nDefendDesire = RemapValClamped(nDefendDesire, 0, 1, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH)
    end

    -- Don’t abandon defend for a low-HP chase
    local botTarget = J.GetProperTarget(bot)
    if J.IsValidHero(botTarget) and J.GetHP(botTarget) < 0.6 and J.GetHP(bot) > J.GetHP(botTarget)
        and GetUnitToUnitDistance(bot, botTarget) < 1500 then
        nDefendDesire = nDefendDesire * 0.4
    end

    -- TP/distance sanity
    local tp = J.Utils.GetItemFromFullInventory(bot, 'item_tpscroll')
    if not J.CanCastAbility(tp) and dist and dist > 4000 then
        local nearEnemies = J.GetLastSeenEnemiesNearLoc(furthestBuilding:GetLocation(), 1200)
        if #nearEnemies == 0 or bot:WasRecentlyDamagedByAnyHero(2) then
            nDefendDesire = nDefendDesire * 0.5
        end
        nDefendDesire = RemapValClamped((dist/4000), 0, 2, nDefendDesire, BOT_ACTION_DESIRE_VERYLOW)
    end

    -- Don’t throw bodies at doomed low-HP T1/T2
    if IsValidBuildingTarget(furthestBuilding) and furthestBuilding ~= ancient then
        local hp = J.GetHP(furthestBuilding)
        if (buildingTier == 1 and hp <= 0.15) or (buildingTier == 2 and hp <= 0.10) then
            return BOT_MODE_DESIRE_NONE
        end
    end

    -- Ask for help if needed
    ConsiderPingedDefend(bot, nDefendDesire, furthestBuilding, buildingTier, nEffAllies, #lEnemies)

    if nDefendDesire > 0.9 then
        J.Utils.GameStates = J.Utils.GameStates or {}
        J.Utils.GameStates['recentDefendTime'] = DotaTime()
    end

    bot.laneToDefend = lane
    return nDefendDesire
end

-- == ACTION LOOP ==
function Defend.DefendThink(bot, lane)
    if J.CanNotUseAction(bot) then return end

    -- Base-defense leash: anchor near Ancient, don't drift out
    if IsBaseThreatActive() then
        local ancient = GetAncient(nTeam)
        local anchor  = J.AdjustLocationWithOffsetTowardsFountain(ancient:GetLocation(), 200)

        local toAnc  = GetUnitToUnitDistance(bot, ancient)
        if toAnc > BASE_LEASH_OUTBOUND then
            bot:Action_MoveToLocation(anchor + J.RandomForwardVector(250))
            return
        end

        local nSearchRange = 1400
        local enemiesNear  = J.GetEnemiesNearLoc(ancient:GetLocation(), nSearchRange)
        if J.IsValidHero(enemiesNear[1]) and J.IsInRange(bot, enemiesNear[1], nSearchRange) then
            bot:Action_AttackUnit(enemiesNear[1], true); return
        end

        bot:Action_AttackMove(anchor + J.RandomForwardVector(300))
        return
    end

    -- Normal defend movement/targeting
    local attackRange  = bot:GetAttackRange()
    local nSearchRange = (attackRange < 900 and 900) or math.min(attackRange, SEARCH_RANGE_DEFAULT)
    if not defendLoc then defendLoc = GetLaneFrontLocation(nTeam, lane, 0) end

    local bld, _, _ = Defend.GetFurthestBuildingOnLane(lane)
    local hub = (IsValidBuildingTarget(bld) and bld:GetLocation()) or defendLoc or GetLaneFrontLocation(nTeam, lane, 0)

    -- Prefer nearest valid enemy hero within range (cheap local queries first)
    local enemiesAtHub = J.GetEnemiesNearLoc(hub, SEARCH_RANGE_DEFAULT)
    if J.IsValidHero(enemiesAtHub[1]) and J.IsInRange(bot, enemiesAtHub[1], nSearchRange) then
        bot:Action_AttackUnit(enemiesAtHub[1], true); return
    end

    local nEnemyHeroes = bot:GetNearbyHeroes(SEARCH_RANGE_DEFAULT, true, BOT_MODE_NONE)
    if J.IsValidHero(nEnemyHeroes[1]) and J.IsInRange(bot, nEnemyHeroes[1], nSearchRange) then
        bot:Action_AttackUnit(nEnemyHeroes[1], true); return
    end

    -- Otherwise, clear strongest creep (avoid full scans)
    local creeps = bot:GetNearbyCreeps(900, true)
    if creeps and #creeps > 0 and (enemiesAtHub == nil or #enemiesAtHub == 0) then
        local best, bestDmg = nil, -1
        for i = 1, #creeps do
            local c = creeps[i]
            if J.IsValid(c) and J.CanBeAttacked(c) then
                local dmg = c:GetAttackDamage()
                if dmg > bestDmg then best, bestDmg = c, dmg end
            end
        end
        if best then bot:Action_AttackUnit(best, true); return end
    end

    -- Move with small jitter; prefer assertive move if ShouldDefend says we're the responder
    if bld and Defend.ShouldDefend(bot, bld, 1600) then
        bot:Action_AttackMove(hub + J.RandomForwardVector(300)); return
    end

    local dist = distanceToLane[lane] or GetUnitToLocationDistance(bot, hub)
    if (weAreStronger or #nInRangeAlly >= #nInRangeEnemy) and dist < SEARCH_RANGE_DEFAULT then
        bot:Action_AttackMove(hub + J.RandomForwardVector(300))
    elseif dist > SEARCH_RANGE_DEFAULT * 1.7 then
        bot:Action_MoveToLocation(hub + J.RandomForwardVector(300))
    else
        bot:Action_MoveToLocation(hub + J.RandomForwardVector(1000))
    end
end

function Defend.OnEnd()
end

return Defend
