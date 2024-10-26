local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local Defend = {}
local pingTimeDelta = 5
local nInRangeAlly, nInRangeEnemy, weAreStronger, distanceToLane
local defDurationHoldTime = 6 -- once trying to def, hold the state for longer period.
local defDurationCacheTime = {}

function Defend.GetDefendDesire(bot, lane)
	if bot.laneToDefend == nil then bot.laneToDefend = lane end
	if bot.DefendLaneDesire == nil then bot.DefendLaneDesire = {0, 0, 0} end
	weAreStronger = false

	local laneFrontLocation = GetLaneFrontLocation( bot:GetTeam(), lane, 0 )
	distanceToLane = GetUnitToLocationDistance(bot, laneFrontLocation)
	nInRangeAlly = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)
	nInRangeEnemy = J.GetLastSeenEnemiesNearLoc( bot:GetLocation(), 2200 )

	bot.DefendLaneDesire[lane] = Defend.GetDefendDesireHelper(bot, lane)
	local defendDesire = bot.DefendLaneDesire[lane]

	if not defDurationCacheTime[bot:GetPlayerID()]
	or not defDurationCacheTime[bot:GetPlayerID()][lane]
	then
		defDurationCacheTime[bot:GetPlayerID()] = { [lane] = { } }
	end
	if not defDurationCacheTime[bot:GetPlayerID()][lane].time
	or defDurationCacheTime[bot:GetPlayerID()][lane].time + defDurationHoldTime <= DotaTime()
	or defDurationCacheTime[bot:GetPlayerID()][lane].desire < defendDesire
	then
		defDurationCacheTime[bot:GetPlayerID()][lane].time = DotaTime()
		defDurationCacheTime[bot:GetPlayerID()][lane].desire = defendDesire
	end
	if defDurationCacheTime[bot:GetPlayerID()][lane].time + defDurationHoldTime > DotaTime() then
		defendDesire = defDurationCacheTime[bot:GetPlayerID()][lane].desire
	end

	if (distanceToLane < 2000 and #nInRangeEnemy > #nInRangeAlly) and not weAreStronger then
		-- 1. if we are not stronger, most likely defend == feed
		-- 2. we dont want to get stuck in defend mode too much because other modes are also important after bots arrive the location.
		defendDesire = RemapValClamped(defendDesire, 0, 1.5, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH)
	end

	-- local mostDesireLane, desire = J.GetMostDefendLaneDesire()
	-- bot.laneToDefend = mostDesireLane
	-- if mostDesireLane ~= lane then
	-- 	return defendDesire * 0.8
	-- end
	return defendDesire
end

function Defend.GetDefendDesireHelper(bot, lane)
	-- 如果在打高地 就别撤退去干别的

	if J.Utils.IsTeamPushingSecondTierOrHighGround(bot) then
		return BOT_MODE_DESIRE_NONE
	end

	local nEnemyAroundAncient = Defend.GetEnemiesAroundAncient(2200)
	local nSearchRange = 2200
	local team = GetTeam()
	weAreStronger = J.WeAreStronger(bot, 2200)
	if nEnemyAroundAncient > 0
	then
		nSearchRange = 880
	end

	nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nSearchRange)
	if #nInRangeEnemy > 0 and GetUnitToLocationDistance(bot, GetLaneFrontLocation(team, lane, 0)) < 1200
	or (bot:GetAssignedLane() ~= lane and J.GetPosition(bot) == 1 and DotaTime() < 12 * 60) -- reduce carry feeds
	or (J.IsDoingRoshan(bot) and #J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), 2800) >= 3)
	or (J.IsDoingTormentor(bot) and #J.GetAlliesNearLoc(J.GetTormentorLocation(team), 900) >= 2 and nEnemyAroundAncient == 0)
	then
		return BOT_MODE_DESIRE_NONE
	end

	if DotaTime() < 10 * 60
	and J.IsCore(bot)
	and bot:GetAssignedLane() ~= lane
	and GetUnitToLocationDistance(bot, GetLaneFrontLocation(team, lane, 0)) > 4400
	then
		local tpScoll = J.GetItem2(bot, 'item_tpscroll')
		if not J.CanCastAbility(tpScoll) or J.GetMP(bot) < 0.45 then
			return BOT_MODE_DESIRE_NONE
		end
	end

	local furthestBuilding = Defend.GetFurthestBuildingOnLane(lane)
	if J.CanBeAttacked(furthestBuilding) and furthestBuilding ~= GetAncient(team)
	then
		local isOnlyCreeps = Defend.IsOnlyCreepsAroundBuilding(furthestBuilding)

		if (J.IsTier1(furthestBuilding) and J.GetHP(furthestBuilding) <= 0.2
			or J.IsTier2(furthestBuilding) and J.GetHP(furthestBuilding) <= 0.2)
		and not isOnlyCreeps
		then
			return BOT_MODE_DESIRE_NONE
		end

		if (J.IsTier1(furthestBuilding) or J.IsTier2(furthestBuilding))
		and isOnlyCreeps
		and J.IsCore(bot) and GetUnitToUnitDistance(bot, furthestBuilding) > 2200
		then
			return BOT_MODE_DESIRE_NONE
		end
	end

	local nDefendDesire = 0

	local botLevel = bot:GetLevel()
	if J.GetPosition(bot) == 1 and botLevel < 8
	or J.GetPosition(bot) == 2 and botLevel < 6
	or J.GetPosition(bot) == 3 and botLevel < 6
	or J.GetPosition(bot) == 4 and botLevel < 5
	or J.GetPosition(bot) == 5 and botLevel < 5
	then
		return BOT_MODE_DESIRE_NONE
	end

	-- if pinged by bots or players to defend.
	local ping = J.Utils.IsPingedByAnyPlayer(bot, pingTimeDelta, nil, nil)
	if ping ~= nil then
		local isPinged, pingedLane = J.IsPingCloseToValidTower(team, ping)
		if isPinged and lane == pingedLane
		then
			nDefendDesire = 0.96
			if not weAreStronger and GetUnitToLocationDistance(bot, ping.location) < 1600 then
				nDefendDesire = nDefendDesire / 2
			end
			bot.laneToDefend = lane
			return nDefendDesire
		end
	end

	bot.laneToDefend = lane
	local mul = Defend.GetEnemyAmountMul(lane)
	return Clamp(GetDefendLaneDesire(lane) * mul, 0.1, 0.96)
end

function Defend.DefendThink(bot, lane)
    if J.CanNotUseAction(bot) then return end

	local attackRange = bot:GetAttackRange()
	local vDefendLane = GetLaneFrontLocation(GetTeam(), lane, 0)
	local nSearchRange = attackRange < 900 and 900 or math.min(attackRange, 1600)

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nEnemyHeroes_real = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)

	if J.IsValidHero(nEnemyHeroes_real[1]) and J.IsInRange(bot, nEnemyHeroes_real[1], nSearchRange)
	then
		bot:Action_AttackUnit(nEnemyHeroes_real[1], true)
		return
	elseif J.IsValidHero(nEnemyHeroes[1]) and J.IsInRange(bot, nEnemyHeroes[1], nSearchRange)
	then
		bot:Action_AttackUnit(nEnemyHeroes[1], true)
		return
	end

	local nEnemyLaneCreeps = bot:GetNearbyCreeps(900, true)
	if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps > 0
	then
		local targetCreep = nil
		local attackDMG = 0
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if J.IsValid(creep)
			and J.CanBeAttacked(creep)
			and creep:GetAttackDamage() > attackDMG
			then
				attackDMG = creep:GetAttackDamage()
				targetCreep = creep
			end

			if targetCreep ~= nil
			then
				bot:Action_AttackUnit(creep, true)
				return
			end
		end
	end

	bot:Action_MoveToLocation(vDefendLane + J.RandomForwardVector(1200))
end

function Defend.GetFurthestBuildingOnLane(lane)
	local bot = GetBot()
	local FurthestBuilding = nil

	if lane == LANE_TOP then
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_TOP_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 0.5, 1)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_TOP_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_TOP_3)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1.5, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_TOP_MELEE)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_TOP_RANGED)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5
		end

		FurthestBuilding = GetAncient(bot:GetTeam())
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 3
		end
	end

	if lane == LANE_MID then
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_MID_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 0.5, 1)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_MID_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_MID_3)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1.5, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_MID_MELEE)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_MID_RANGED)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5
		end

		FurthestBuilding = GetAncient(bot:GetTeam())
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 3
		end
	end

	if lane == LANE_BOT then
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BOT_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 0.5, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BOT_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BOT_3)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1.5, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_BOT_MELEE)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_BOT_RANGED)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5
		end

		FurthestBuilding = GetAncient(bot:GetTeam())
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 3
		end
	end

	return nil, 1
end

function Defend.IsValidBuildingTarget(unit)
	return unit ~= nil 
	and unit:IsAlive() 
	and unit:IsBuilding()
	and unit:CanBeSeen()
end

function Defend.GetEnemyAmountMul(lane)
	local count = Defend.GetEnemyCountInLane(lane, 1600)
	local _, urgentNum = Defend.GetFurthestBuildingOnLane(lane)
	return RemapValClamped(count, 1, 3, 1, 2) * urgentNum
end

function Defend.GetEnemyCountInLane(lane, nRadius)
	local nUnitCount = 0
	local furthestBuilding = Defend.GetFurthestBuildingOnLane(lane)

	for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
				and J.IsValidBuilding(furthestBuilding)
				and GetUnitToLocationDistance(furthestBuilding, dInfo.location) <= nRadius
				and dInfo.time_since_seen < 3.0
				then
					nUnitCount = nUnitCount + 1
				end
			end
		end
	end

	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
	do
		if J.IsValid(unit)
		and J.IsValidBuilding(furthestBuilding)
		and GetUnitToUnitDistance(unit, furthestBuilding) <= nRadius
		then
			local unitName = unit:GetUnitName()
			if string.find(unitName, 'siege') and not string.find(unitName, 'upgraded') then
				nUnitCount = nUnitCount + 0.5
			elseif string.find(unitName, 'upgraded') then
				nUnitCount = nUnitCount + 1
			elseif string.find(unitName, 'warlock_golem') then
				nUnitCount = nUnitCount + 1
			elseif string.find(unitName, 'lone_druid_bear') then
				nUnitCount = nUnitCount + 1
			elseif string.find(unitName, 'shadow_shaman_ward') then
				nUnitCount = nUnitCount + 1
			end
		end
	end

	return nUnitCount
end

function Defend.IsOnlyCreepsAroundBuilding(furthestBuilding)
	local creepCount = 0
	local heroCount = 0
	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
	do
		if J.IsValid(unit)
		and GetUnitToUnitDistance(furthestBuilding, unit) <= 1600
		then
			if unit:IsCreep()
			or unit:IsAncientCreep()
			or unit:HasModifier('modifier_chen_holy_persuasion')
			or unit:HasModifier('modifier_dominated')
			then
				creepCount = creepCount + 1
			end

			local isIllusion = J.IsSuspiciousIllusion(unit)

			if unit:IsHero()
			and (not isIllusion
				or isIllusion and unit:HasModifier('modifier_arc_warden_tempest_double')
				or isIllusion and string.find(unit:GetUnitName(), 'chaos_knight')
				or isIllusion and string.find(unit:GetUnitName(), 'naga_siren')
			)
			then
				heroCount = heroCount + 1
			end

			if string.find(unit:GetUnitName(), 'warlock_golem')
			or string.find(unit:GetUnitName(), 'lone_druid_bear') then
				heroCount = heroCount + 1
			end
		end
	end

	return creepCount > 0 and heroCount == 0
end

function Defend.OnEnd()
end

function Defend.GetEnemiesAroundAncient(nRadius)
	local nUnitCount = 0

	for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
				and GetUnitToLocationDistance(GetAncient(GetTeam()), dInfo.location) <= nRadius
				and dInfo.time_since_seen < 3.0
				then
					nUnitCount = nUnitCount + 1
				end
			end
		end
	end

	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
	do
		if J.IsValid(unit)
		and GetUnitToUnitDistance(unit, GetAncient(GetTeam())) <= nRadius
		then
			local unitName = unit:GetUnitName()
			if unit:IsCreep() then
				nUnitCount = nUnitCount + 0.5
			elseif string.find(unitName, 'upgraded') then
				nUnitCount = nUnitCount + 1
			elseif string.find(unitName, 'warlock_golem') then
				nUnitCount = nUnitCount + 1.5
			elseif string.find(unitName, 'lone_druid_bear') then
				nUnitCount = nUnitCount + 2
			elseif string.find(unitName, 'shadow_shaman_ward') then
				nUnitCount = nUnitCount + 1.5
			end
		end
	end

	return nUnitCount
end

return Defend