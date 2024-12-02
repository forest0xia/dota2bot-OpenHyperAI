local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local Defend = {}
local pingTimeDelta = 5
local nInRangeAlly, nInRangeEnemy, weAreStronger
local distanceToLane = {[1] = 0, [2] = 0, [3] = 0}
local defDurationHoldTime = 5 -- once trying to def, hold the state for longer period.
local defDurationCacheTime = {}
local defendLoc = nil
local nEnemyAroundAncient = 0

function Defend.GetDefendDesire(bot, lane)
	if bot.laneToDefend == nil then bot.laneToDefend = lane end
	if bot.DefendLaneDesire == nil then bot.DefendLaneDesire = {0, 0, 0} end
	weAreStronger = false

	defendLoc = GetLaneFrontLocation( bot:GetTeam(), lane, 0 )
	distanceToLane[lane] = GetUnitToLocationDistance(bot, defendLoc)
	nInRangeAlly = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)
	nInRangeEnemy = J.GetLastSeenEnemiesNearLoc( bot:GetLocation(), 2200 )

	bot.DefendLaneDesire[lane] = Defend.GetDefendDesireHelper(bot, lane)
	local defendDesire = bot.DefendLaneDesire[lane]

	-- if not defDurationCacheTime[bot:GetPlayerID()]
	-- or not defDurationCacheTime[bot:GetPlayerID()][lane]
	-- then
	-- 	defDurationCacheTime[bot:GetPlayerID()] = { [lane] = { } }
	-- end
	-- if not defDurationCacheTime[bot:GetPlayerID()][lane].time
	-- or defDurationCacheTime[bot:GetPlayerID()][lane].time + defDurationHoldTime <= DotaTime()
	-- or defDurationCacheTime[bot:GetPlayerID()][lane].desire < defendDesire
	-- then
	-- 	defDurationCacheTime[bot:GetPlayerID()][lane].time = DotaTime()
	-- 	defDurationCacheTime[bot:GetPlayerID()][lane].desire = defendDesire
	-- end
	-- if defDurationCacheTime[bot:GetPlayerID()][lane].time + defDurationHoldTime > DotaTime() then
	-- 	defendDesire = defDurationCacheTime[bot:GetPlayerID()][lane].desire
	-- end

	if (distanceToLane[lane] and distanceToLane[lane] < 1600 and #nInRangeEnemy > #nInRangeAlly) and not weAreStronger then
		-- 1. if we are not stronger, most likely defend == feed
		-- 2. we dont want to get stuck in defend mode too much because other modes are also important after bots arrive the location.
		defendDesire = RemapValClamped(defendDesire, 0, 1.5, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH)
	end

	if bot:WasRecentlyDamagedByAnyHero(2) and distanceToLane[lane] > 3000 then
		defendDesire = defendDesire * 0.5
	end

	-- local mostDesireLane, desire = J.GetMostDefendLaneDesire()
	-- bot.laneToDefend = mostDesireLane
	-- if mostDesireLane ~= lane then
	-- 	return defendDesire * 0.8
	-- end
	if defendDesire > 0.9 then
		J.Utils.GameStates['recentDefendTime'] = DotaTime()
	end
	return defendDesire
end

function Defend.GetDefendDesireHelper(bot, lane)
	-- 如果在打高地 就别撤退去干别的
	if J.Utils.IsTeamPushingSecondTierOrHighGround(bot) then
		return BOT_MODE_DESIRE_NONE
	end

	nEnemyAroundAncient = Defend.GetEnemiesAroundAncient(1600)
	local nSearchRange = 2200
	local team = GetTeam()
	local laneFront = GetLaneFrontLocation(team, lane, 0)

	defendLoc = laneFront
	weAreStronger = J.WeAreStronger(bot, 2200)
	nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nSearchRange)

	if nEnemyAroundAncient > 0
	then
		nSearchRange = 1000
		local ancient = GetAncient(GetTeam())
		defendLoc = ancient:GetLocation()

		local nDefendAllies = J.GetAlliesNearLoc(defendLoc, 2500)
		if #nDefendAllies < nEnemyAroundAncient
		and (#nInRangeEnemy <= 1 or not bot:WasRecentlyDamagedByAnyHero(2)) then
			return BOT_ACTION_DESIRE_ABSOLUTE * 0.98
		end
	end

	if #nInRangeEnemy > 0 and GetUnitToLocationDistance(bot, defendLoc) < 1200
	or bot:GetLevel() < 3
	or (bot:GetAssignedLane() ~= lane and ((J.GetPosition(bot) == 1 and DotaTime() < 12 * 60) or (J.GetPosition(bot) == 2 and DotaTime() < 7 * 60))) -- reduce carry feeds
	or (J.IsDoingRoshan(bot) and #J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), 2800) >= 3)
	or (J.IsDoingTormentor(bot) and #J.GetAlliesNearLoc(J.GetTormentorLocation(team), 900) >= 2 and nEnemyAroundAncient == 0)
	then
		return BOT_MODE_DESIRE_NONE
	end

	if DotaTime() < 7 * 60
	and J.IsCore(bot)
	and bot:GetAssignedLane() ~= lane
	and GetUnitToLocationDistance(bot, defendLoc) > 4400
	then
		local tpScoll = J.GetItem2(bot, 'item_tpscroll')
		if not J.CanCastAbility(tpScoll) or J.GetMP(bot) < 0.45 then
			return BOT_MODE_DESIRE_NONE
		end
	end

	local furthestBuilding = Defend.GetFurthestBuildingOnLane(lane)
	if J.CanBeAttacked(furthestBuilding) and furthestBuilding ~= GetAncient(team)
	then
		local heroesAroundBuilding = Defend.CountWeightedHeroes(furthestBuilding, 1600)
		local unitsAroundBuilding = Defend.CountWeightedUnits(furthestBuilding, 1600)

		if (J.IsTier1(furthestBuilding) and J.GetHP(furthestBuilding) <= 0.2
			or J.IsTier2(furthestBuilding) and J.GetHP(furthestBuilding) <= 0.2)
		and heroesAroundBuilding > 0
		then
			return BOT_MODE_DESIRE_NONE
		end

		if (J.IsTier1(furthestBuilding) or J.IsTier2(furthestBuilding))
		and unitsAroundBuilding > 0 and heroesAroundBuilding == 0
		and J.IsCore(bot) and GetUnitToUnitDistance(bot, furthestBuilding) > 2200
		then
			return BOT_MODE_DESIRE_NONE
		end
	end

	local nDefendDesire = 0

	local botLevel = bot:GetLevel()
	if J.GetPosition(bot) == 1 and botLevel < 6
	or J.GetPosition(bot) == 2 and botLevel < 6
	or J.GetPosition(bot) == 3 and botLevel < 5
	or J.GetPosition(bot) == 4 and botLevel < 4
	or J.GetPosition(bot) == 5 and botLevel < 4
	then
		return BOT_MODE_DESIRE_NONE
	end

	local nDistance = 2100
	local nNearEnemies = J.GetEnemiesNearLoc(defendLoc, nDistance)
	local nH, _ = J.Utils.NumHumanBotPlayersInTeam(GetOpposingTeam())
	if nH > 0 or nNearEnemies == 0 then
		local nDefendAllies = J.GetAlliesNearLoc(defendLoc, nDistance)
		local nEffctiveAlliesNearPingedDefendLoc = #nDefendAllies + #J.Utils.GetAllyIdsInTpToLocation(defendLoc, nDistance)
		if nEffctiveAlliesNearPingedDefendLoc > #nNearEnemies
		and #nNearEnemies < 3
		and GetUnitToLocationDistance(bot, defendLoc) > 3000 then
			return BOT_MODE_DESIRE_NONE
		end
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
	return RemapValClamped(J.GetHP(bot), 0.75, 0, Clamp(GetDefendLaneDesire(lane) * mul, 0.1, 0.96), BOT_ACTION_DESIRE_NONE)
end

function Defend.DefendThink(bot, lane)
    if J.CanNotUseAction(bot) then return end

	local attackRange = bot:GetAttackRange()
	if not defendLoc then
		defendLoc = GetLaneFrontLocation(GetTeam(), lane, 0)
	end
	local nAttackSearchRange = attackRange < 900 and 900 or math.min(attackRange, 1600)

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nEnemyHeroes_real = J.GetEnemiesNearLoc(defendLoc, 1600)

	if nEnemyAroundAncient > 0 then
		local ancient = GetAncient(GetTeam())
		if GetUnitToLocationDistance(ancient, defendLoc) < 100 then
			if GetUnitToUnitDistance(bot, ancient) > 2500 then
				bot:Action_MoveToLocation(defendLoc + J.RandomForwardVector(300))
				return
			end
		end
	end

	if J.IsValidHero(nEnemyHeroes_real[1]) and J.IsInRange(bot, nEnemyHeroes_real[1], nAttackSearchRange)
	then
		bot:Action_AttackUnit(nEnemyHeroes_real[1], true)
		return
	elseif J.IsValidHero(nEnemyHeroes[1]) and J.IsInRange(bot, nEnemyHeroes[1], nAttackSearchRange)
	then
		bot:Action_AttackUnit(nEnemyHeroes[1], true)
		return
	end

	local nEnemyLaneCreeps = bot:GetNearbyCreeps(900, true)
	if (nEnemyHeroes_real == nil or #nEnemyHeroes_real <= 0)
	and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps > 0
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

	if (weAreStronger or #nInRangeAlly >= #nEnemyHeroes_real) and distanceToLane[lane] and  distanceToLane[lane] < 1600 then
		bot:Action_AttackMove(defendLoc + J.RandomForwardVector(300))
	elseif distanceToLane[lane] and distanceToLane[lane] > 1600 then
		bot:Action_MoveToLocation(defendLoc + J.RandomForwardVector(300))
	end
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

	nUnitCount = nUnitCount + Defend.CountWeightedHeroes(furthestBuilding, nRadius)
	nUnitCount = nUnitCount + Defend.CountWeightedUnits(furthestBuilding, nRadius)

	return nUnitCount
end

function Defend.CountWeightedHeroes(building, nRadius)
	local nUnitCount = 0
	local isBuildingAncient = building == GetAncient(GetBot():GetTeam())
	for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
				and J.IsValidBuilding(building)
				and GetUnitToLocationDistance(building, dInfo.location) <= nRadius
				and dInfo.time_since_seen < 3.0
				then
					nUnitCount = nUnitCount + 1
					if isBuildingAncient then
						nUnitCount = nUnitCount + 1 -- Increase weight for critical defense.
					end
				end
			end
		end
	end
	return nUnitCount
end

function Defend.CountWeightedUnits(building, nRadius)
	local nUnitCount = 0
	local isBuildingAncient = building == GetAncient(GetBot():GetTeam())
	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
	do
		if J.IsValid(unit)
		and J.IsValidBuilding(building)
		and GetUnitToUnitDistance(unit, building) <= nRadius
		then
			local unitName = unit:GetUnitName()
			if unit:IsCreep()
			or unit:IsAncientCreep()
			or unit:HasModifier('modifier_chen_holy_persuasion')
			or unit:HasModifier('modifier_dominated')
			then
				nUnitCount = nUnitCount + 1.5
			elseif string.find(unitName, 'siege') and not string.find(unitName, 'upgraded') then
				nUnitCount = nUnitCount + 0.6
			elseif string.find(unitName, 'upgraded') then
				nUnitCount = nUnitCount + 1
			elseif string.find(unitName, 'warlock_golem') then
				nUnitCount = nUnitCount + 2
			elseif string.find(unitName, 'lone_druid_bear') then
				nUnitCount = nUnitCount + 2.5
			elseif string.find(unitName, 'shadow_shaman_ward') then
				nUnitCount = nUnitCount + 1.5
			elseif J.IsSuspiciousIllusion(unit) then
				if unit:HasModifier('modifier_arc_warden_tempest_double')
				or string.find(unit:GetUnitName(), 'chaos_knight')
				or string.find(unit:GetUnitName(), 'naga_siren') then
					nUnitCount = nUnitCount + 1
				end
			else
				nUnitCount = nUnitCount + 0.3
			end
			if isBuildingAncient then
				nUnitCount = nUnitCount + 1 -- Increase weight for critical defense.
			end
		end
	end
	return nUnitCount
end

function Defend.OnEnd()
end

function Defend.GetEnemiesAroundAncient(nRadius)
	local nUnitCount = 0
	local ancient = GetAncient(GetTeam())
	nUnitCount = nUnitCount + Defend.CountWeightedHeroes(ancient, nRadius)
	nUnitCount = nUnitCount + Defend.CountWeightedUnits(ancient, nRadius)

	return nUnitCount
end

return Defend