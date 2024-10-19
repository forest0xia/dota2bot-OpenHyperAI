local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local Defend = {}
local pingTimeDelta = 5
local highgroundTowers = {
	TOWER_TOP_3,
	TOWER_MID_3,
	TOWER_BOT_3,
	TOWER_BASE_1,
	TOWER_BASE_2
}
local nInRangeAlly, nInRangeEnemy, weAreStronger, distanceToLane
local defDurationHoldTime = 6 -- once trying to def, hold the state for longer period.
local defDurationCacheTime = {}

function Defend.GetDefendDesire(bot, lane)

	-- 如果在打高地 就别撤退去干别的
	nInRangeAlly = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)
	nInRangeEnemy = J.GetLastSeenEnemiesNearLoc( bot:GetLocation(), 2200 )

	if J.Utils.IsTeamPushingSecondTierOrHighGround(bot) then
		return BOT_MODE_DESIRE_NONE
	end

	if bot.DefendLaneDesire == nil then bot.DefendLaneDesire = {0, 0, 0} end
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

	if (distanceToLane < 2000 and #nInRangeEnemy > #nInRangeAlly) or not weAreStronger then
		-- 1. if we are not stronger, most likely defend == feed
		-- 2. we dont want to get stuck in defend mode too much because other modes are also important after bots arrive the location.
		defendDesire = RemapValClamped(defendDesire, 0, 1.5, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH)
	end

	local mostDesireLane, desire = J.GetMostDefendLaneDesire()
	bot.laneToDefend = mostDesireLane
	if mostDesireLane ~= lane then
		return defendDesire * 0.8
	end
	return defendDesire
end

function Defend.GetDefendDesireHelper(bot, lane)

	local nDefendDesire = 0
	weAreStronger = J.WeAreStronger(bot, 2200)
	local team = GetTeam()
	distanceToLane = GetUnitToLocationDistance(bot, GetLaneFrontLocation(team, lane, 0))

	if #nInRangeEnemy > 0 then
		nDefendDesire = RemapValClamped(J.GetHP(bot), 1, 0, BOT_ACTION_DESIRE_VERYHIGH, BOT_ACTION_DESIRE_NONE)
		return nDefendDesire
	end

	if bot:WasRecentlyDamagedByAnyHero(2) and distanceToLane > 2000 -- far from the defend lane and probably currently in a fight.
	or (bot:GetAssignedLane() ~= lane and J.GetPosition(bot) == 1 and J.IsInLaningPhase()) -- reduce carry feeds
	or (J.IsDoingRoshan(bot) and #J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), 2800) >= 3)
	or (J.IsDoingTormentor(bot) and #J.GetAlliesNearLoc(J.GetTormentorLocation(team), 900) >= 2 and #J.GetEnemiesAroundAncient() == 0)
	then
		return BOT_MODE_DESIRE_NONE
	end

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
			nDefendDesire = 0.92
			if not weAreStronger and GetUnitToLocationDistance(bot, ping.location) < 1800 then
				return nDefendDesire / 2
			end
			return nDefendDesire
		end
	end

	-- 判断是否要提醒回防
	J.Utils['GameStates']['defendPings'] = J.Utils['GameStates']['defendPings'] ~= nil and J.Utils['GameStates']['defendPings'] or { pingedTime = GameTime() }
	if GameTime() - J.Utils['GameStates']['defendPings'].pingedTime > pingTimeDelta then

		local enemeyPushingBase = false
		local nDefendLoc

		local barrack = J.Utils.IsAnyBarrackAttackByEnemyHero()
		if barrack ~= nil then
			nDefendLoc = barrack:GetLocation()
			enemeyPushingBase = true
		end

		if not enemeyPushingBase then
			for _, t in pairs( highgroundTowers )
			do
				local tower = GetTower( team, t )
				if tower ~= nil and tower:GetHealth()/tower:GetMaxHealth() < 0.8
				and #J.GetLastSeenEnemiesNearLoc( tower:GetLocation(), 1200 ) >= 1
				then
					nDefendLoc = tower:GetLocation()
					enemeyPushingBase = true
				end
			end
		end
		if not enemeyPushingBase and #J.GetLastSeenEnemiesNearLoc( GetAncient(team):GetLocation(), 1200 ) >= 1 then
			nDefendLoc = GetAncient(team):GetLocation() -- GetLaneFrontLocation(team, nDefendLane, 100)
			enemeyPushingBase = true
		end

		if nDefendLoc ~= nil and enemeyPushingBase then
			local saferLoc = J.AdjustLocationWithOffsetTowardsFountain(nDefendLoc, 850) + RandomVector(50)

			enemeyPushingBase = false
			local nDefendAllies = J.GetAlliesNearLoc(saferLoc, 2500);
			if #nDefendAllies < J.GetNumOfAliveHeroes(false) then
				J.Utils['GameStates']['defendPings'].pingedTime = GameTime()
				bot:ActionImmediate_Chat("Please come defending", false)
				bot:ActionImmediate_Ping(saferLoc.x, saferLoc.y, false)
			end

			nDefendDesire = 0.966
		end
	end

	local mul = Defend.GetEnemyAmountMul(lane)
	local nEnemies = J.GetEnemiesAroundAncient()

	local defAcientDesire = BOT_MODE_DESIRE_ABSOLUTE
	if nEnemies >= 1
	and (GetTower(team, TOWER_MID_3) == nil
		or (GetTower(team, TOWER_TOP_3) == nil
			and GetTower(team, TOWER_MID_3) == nil
			and GetTower(team, TOWER_BOT_3) == nil))
	and lane == LANE_MID
	then
		nDefendDesire = nDefendDesire + defAcientDesire
	elseif nDefendDesire ~= 0.966 then
		nDefendDesire = Clamp(GetDefendLaneDesire(lane), 0.1, 1) * mul
	end

	return RemapValClamped(J.GetHP(bot), 1, 0, Clamp(nDefendDesire, 0, 1.25), BOT_ACTION_DESIRE_NONE)
end

local nTpSolt = 15
local enemySearchRange = 1400

function Defend.DefendThink(bot, lane)
    if J.CanNotUseAction(bot) then return end

	local vDefendLane = GetLaneFrontLocation(GetTeam(), lane, 0)

	local attackRange = bot:GetAttackRange()
	local nSearchRange = attackRange < 600 and 600 or math.min(attackRange + 100, enemySearchRange)

	local tps = bot:GetItemInSlot(nTpSolt)
	local saferLoc = J.AdjustLocationWithOffsetTowardsFountain(vDefendLane, 260)
	local bestTpLoc = J.GetNearbyLocationToTp(saferLoc)
	local distance = GetUnitToLocationDistance(bot, vDefendLane)
	if distance > 3500 then
		if tps ~= nil and tps:IsFullyCastable() then
			bot:Action_UseAbilityOnLocation(tps, bestTpLoc + RandomVector(30))
			return
		else
			bot:Action_MoveToLocation(saferLoc + RandomVector(30));
			return
		end
	elseif distance > 2000 and distance <= 3500 then
		bot:Action_AttackMove(saferLoc + RandomVector(30));
	elseif distance <= 2000 and bot:GetTarget() == nil then
		local hNearbyEnemyHeroList = J.GetHeroesNearLocation( true, vDefendLane, 1300 )
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if J.IsValidHero(npcEnemy)
			then
				bot:SetTarget( npcEnemy )
                bot:Action_AttackUnit( npcEnemy, false )
				return
			end
		end
	end

	if distance < enemySearchRange then
		local nInRangeEnemy = bot:GetNearbyHeroes(nSearchRange, true, BOT_MODE_NONE)
		
		if J.IsValidHero(nInRangeEnemy[1])
		then
			bot:SetTarget( nInRangeEnemy[1] )
            bot:Action_AttackUnit( nInRangeEnemy[1], false )
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
	end
	bot:Action_AttackMove(saferLoc + RandomVector(75))
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
	local nHeroCount = Defend.GetEnemyCountInLane(lane, true)
	local nCreepCount = Defend.GetEnemyCountInLane(lane, false)
	local _, urgent = Defend.GetFurthestBuildingOnLane(lane)
	return RemapValClamped(nHeroCount, 1, 3, 1, 2) * RemapValClamped(nCreepCount, 1, 5, 1, 1.25) * urgent
end

function Defend.GetEnemyCountInLane(lane, isHero)
	local units = {}
	local laneFrontLoc = GetLaneFrontLocation(GetTeam(), lane, 0)
	local unitList = nil

	if isHero
	then
		unitList = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	else
		unitList = GetUnitList(UNIT_LIST_ENEMY_CREEPS)
	end

	for _, enemy in pairs(unitList)
	do
		if J.IsValid(enemy)
		then
			local distance = GetUnitToLocationDistance(enemy, laneFrontLoc)

			if isHero
			then
				if distance < 1300
				and not J.IsSuspiciousIllusion(enemy)
				then
					table.insert(units, enemy)
				end
			else
				if distance < 1300
				then
					table.insert(units, enemy)
				end
			end
		end
	end

	return #units
end

function Defend.OnEnd(bot, lane)
	bot.DefendLaneDesire[lane] = 0
end

return Defend