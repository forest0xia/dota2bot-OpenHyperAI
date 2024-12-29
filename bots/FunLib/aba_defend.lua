local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )

local Defend = {}
local pingTimeDelta = 5
local nInRangeAlly, nInRangeEnemy, weAreStronger
local distanceToLane = {[1] = 0, [2] = 0, [3] = 0}
local defDurationHoldTime = 5 -- once trying to def, hold the state for longer period.
local defDurationCacheTime = {}
local defendLoc = nil
local nEnemyUnitsAroundAncient = 0

local nEffctiveAllyHeroesNearPingedDefendLoc = nil
local lEnemyHeroesAroundLoc = 0
local aliveAllyHeroes = 0
local botTarget = nil
local currentTime = DotaTime()
local maxDesire = 0.98

function Defend.GetDefendDesire(bot, lane)
	if bot.laneToDefend == nil then bot.laneToDefend = lane end
	if bot.DefendLaneDesire == nil then bot.DefendLaneDesire = {0, 0, 0} end

	currentTime = DotaTime()
	if GetGameMode() == 23 then currentTime = currentTime * 1.65 end

	weAreStronger = false
	defendLoc = GetLaneFrontLocation( bot:GetTeam(), lane, 0 )
	distanceToLane[lane] = GetUnitToLocationDistance(bot, defendLoc)
	nInRangeAlly = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)
	nInRangeEnemy = J.GetLastSeenEnemiesNearLoc( bot:GetLocation(), 1600)

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

	local nSearchRange = 2200
	local team = bot:GetTeam()
	local laneFront = GetLaneFrontLocation(team, lane, 0)
	local ancient = GetAncient(team)
	local attackRange = bot:GetAttackRange()
	botTarget = J.GetProperTarget(bot);
	defendLoc = laneFront
	weAreStronger = J.WeAreStronger(bot, nSearchRange)

	nEnemyUnitsAroundAncient = J.GetEnemiesAroundLoc(ancient:GetLocation(), 1500)

	local nDefendAllyHeroes = J.GetAlliesNearLoc(defendLoc, nSearchRange)
	nEffctiveAllyHeroesNearPingedDefendLoc = #nDefendAllyHeroes + #J.Utils.GetAllyIdsInTpToLocation(defendLoc, nSearchRange)
	lEnemyHeroesAroundLoc = J.GetLastSeenEnemiesNearLoc(defendLoc, nSearchRange)
	aliveAllyHeroes = J.GetNumOfAliveHeroes(false)

	if nEnemyUnitsAroundAncient > 0
	then

		nSearchRange = 1500
		local ancientHp = J.GetHP(ancient)

		defendLoc = ancient:GetLocation()
		nDefendAllyHeroes = J.GetAlliesNearLoc(defendLoc, nSearchRange)
		nEffctiveAllyHeroesNearPingedDefendLoc = #nDefendAllyHeroes + #J.Utils.GetAllyIdsInTpToLocation(defendLoc, nSearchRange)
		lEnemyHeroesAroundLoc = J.GetLastSeenEnemiesNearLoc(defendLoc, nSearchRange)

		if #lEnemyHeroesAroundLoc == 0 and (J.IsAnyAllyDefending(bot, lane) or nEffctiveAllyHeroesNearPingedDefendLoc >= 1) then
			return BOT_MODE_DESIRE_NONE
		end
		if (#nDefendAllyHeroes < nEnemyUnitsAroundAncient + 1
		or ancientHp < 0.95
		or (nEffctiveAllyHeroesNearPingedDefendLoc < aliveAllyHeroes and nEffctiveAllyHeroesNearPingedDefendLoc <= #lEnemyHeroesAroundLoc + 1 )
		or (#lEnemyHeroesAroundLoc >= 3 and nEffctiveAllyHeroesNearPingedDefendLoc < aliveAllyHeroes))
		and J.GetLocationToLocationDistance(defendLoc, laneFront) < nSearchRange
		and #J.GetNearbyHeroes(bot, math.max(attackRange + 100, 1000), true, BOT_MODE_NONE) <= 0
		and ((#nInRangeEnemy <= 1 and not (J.IsValidHero(botTarget) and J.GetHP(botTarget) < 0.3)) or not bot:WasRecentlyDamagedByAnyHero(2)) then
			print("Ancient is in danger for team " .. team)
			local desire = RemapValClamped(J.GetHP(bot), 0.1, 0.5, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_ABSOLUTE)
			ConsiderPingedDefend(bot, desire, ancient, 4)
			return desire
		end
	end

	local distanceToDefendLoc = GetUnitToLocationDistance(bot, defendLoc)
	local tpScoll = J.Utils.GetItemFromFullInventory(bot, 'item_tpscroll')

	if #nInRangeEnemy > 0 and distanceToDefendLoc < 1200
	or bot:GetLevel() < 3
	or (bot:GetAssignedLane() ~= lane and ((J.GetPosition(bot) == 1 and currentTime < 8 * 60) or (J.GetPosition(bot) == 2 and currentTime < 6 * 60))) -- reduce carry feeds
	or (J.IsDoingRoshan(bot) and #J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), 2800) >= 3)
	or (J.IsDoingTormentor(bot) and #J.GetAlliesNearLoc(J.GetTormentorLocation(team), 900) >= 2 and nEnemyUnitsAroundAncient == 0)
	then
		return BOT_MODE_DESIRE_NONE
	end

	local furthestBuilding, urgentNum, nBuildingfTier = Defend.GetFurthestBuildingOnLane(lane)
	if J.CanBeAttacked(furthestBuilding) and furthestBuilding ~= GetAncient(team)
	then
		if (nBuildingfTier == 1 and J.GetHP(furthestBuilding) <= 0.15)
			or (nBuildingfTier == 2 and J.GetHP(furthestBuilding) <= 0.1)
		then
			return BOT_MODE_DESIRE_NONE
		end
	end

	if (currentTime < 6 * 60 and bot:GetNetWorth() < 7000)
	and J.IsCore(bot)
	and bot:GetAssignedLane() ~= lane
	and distanceToDefendLoc > nSearchRange * 2
	and nBuildingfTier < 2
	then
		if not J.CanCastAbility(tpScoll) or J.GetMP(bot) < 0.45 then
			return BOT_MODE_DESIRE_NONE
		end
	end

	local nDefendDesire = 0

	local botLevel = bot:GetLevel()
	if bot:GetAssignedLane() ~= lane and (J.GetPosition(bot) == 1 and botLevel < 6
	or J.GetPosition(bot) == 2 and botLevel < 6
	or J.GetPosition(bot) == 3 and botLevel < 5
	or J.GetPosition(bot) == 4 and botLevel < 4
	or J.GetPosition(bot) == 5 and botLevel < 4)
	then
		return BOT_MODE_DESIRE_NONE
	end

	-- if pinged by bots or players to defend.
	local ping = J.Utils.IsPingedByAnyPlayer(bot, pingTimeDelta, nil, nil)
	if ping ~= nil then
		local isPinged, pingedLane = J.IsPingCloseToValidTower(team, ping)
		if isPinged and lane == pingedLane
		and (#lEnemyHeroesAroundLoc >= 3 or nEffctiveAllyHeroesNearPingedDefendLoc <= #lEnemyHeroesAroundLoc)
		then
			nDefendDesire = 0.88
			if not weAreStronger and GetUnitToLocationDistance(bot, ping.location) < 1800 then
				nDefendDesire = nDefendDesire / 2
			end
			bot.laneToDefend = lane
			return nDefendDesire
		end
	end

	if #lEnemyHeroesAroundLoc == 0 and J.IsAnyAllyDefending(bot, lane) then
		return BOT_MODE_DESIRE_NONE
	end
	if #lEnemyHeroesAroundLoc == 1
	and (nEffctiveAllyHeroesNearPingedDefendLoc > #lEnemyHeroesAroundLoc
		or (J.IsAnyAllyDefending(bot, lane) and J.GetAverageLevel(false) >= J.GetAverageLevel(true)))
	then
		return BOT_MODE_DESIRE_NONE
	end

	bot.laneToDefend = lane
	local nUnitsAroundBuilding = J.GetEnemiesAroundLoc(furthestBuilding:GetLocation(), nSearchRange)
	local lCloseEnemyHeroesAroundLoc = J.GetLastSeenEnemiesNearLoc(furthestBuilding:GetLocation(), 1200)
	local urgentMultipler = RemapValClamped(nUnitsAroundBuilding * urgentNum, 1, 15, 0, 2)

	if nBuildingfTier >= 3 and nEffctiveAllyHeroesNearPingedDefendLoc <= #lEnemyHeroesAroundLoc then
		maxDesire = 1
	end
	nDefendDesire = RemapValClamped(J.GetHP(bot), 0.75, 0.2, RemapValClamped(GetDefendLaneDesire(lane) * urgentMultipler, 0, 1, BOT_ACTION_DESIRE_NONE, maxDesire), BOT_ACTION_DESIRE_LOW)
	ConsiderPingedDefend(bot, nDefendDesire, furthestBuilding, nBuildingfTier)

	if (distanceToDefendLoc and distanceToDefendLoc < 1600 and #nInRangeEnemy > #nInRangeAlly) and not weAreStronger then
		-- 1. if we are not stronger, most likely defend == feed
		-- 2. we dont want to get stuck in defend mode too much because other modes are also important after bots arrive the location.
		nDefendDesire = RemapValClamped(nDefendDesire, 0, 1, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH)
	end

	if J.IsValidHero(botTarget) and J.GetHP(botTarget) < 0.6 and J.GetHP(bot) > J.GetHP(botTarget) and GetUnitToUnitDistance(bot, botTarget) < 1500 then
		nDefendDesire = nDefendDesire * 0.4
	end

	if not J.CanCastAbility(tpScoll) and distanceToDefendLoc > 4000
	then
		if #lCloseEnemyHeroesAroundLoc == 0 or bot:WasRecentlyDamagedByAnyHero(2) then
			nDefendDesire = nDefendDesire * 0.5
		end
		nDefendDesire = RemapValClamped(distanceToDefendLoc/4000, 0, 2, nDefendDesire, BOT_ACTION_DESIRE_VERYLOW)
	end

	return nDefendDesire
end

function ConsiderPingedDefend(bot, desire, building, tier)
	-- 判断是否要提醒回防
	if J.IsInLaningPhase() or aliveAllyHeroes == 0 then return 0 end

	J.Utils['GameStates']['defendPings'] = J.Utils['GameStates']['defendPings'] ~= nil and J.Utils['GameStates']['defendPings'] or { pingedTime = GameTime() }
	if Defend.IsValidBuildingTarget(building) and tier >= 2
	and desire > 0.5
	and (GameTime() - J.Utils['GameStates']['defendPings'].pingedTime > 6)
	and nEffctiveAllyHeroesNearPingedDefendLoc < 1 -- 避免人多打起来了还一直ping
	-- and (nEffctiveAllyHeroesNearPingedDefendLoc <= #lEnemyHeroesAroundLoc and nEffctiveAllyHeroesNearPingedDefendLoc < aliveAllyHeroes)
	then
		local saferLoc = J.AdjustLocationWithOffsetTowardsFountain(building:GetLocation(), 850) + RandomVector(50)
		local reteatAllies = J.GetRetreatingAlliesNearLoc( saferLoc, 1600 )
		if #reteatAllies <= 0 then
			bot:ActionImmediate_Chat(Localization.Get('say_come_def'), false)
			bot:ActionImmediate_Ping(saferLoc.x, saferLoc.y, false)
			J.Utils['GameStates']['defendPings'].pingedTime = GameTime()
		end
	end
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

	if nEnemyUnitsAroundAncient > 0 then
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
			return FurthestBuilding, mul, 1
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_TOP_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1, 2)
			return FurthestBuilding, mul, 2
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_TOP_3)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1.5, 2)
			return FurthestBuilding, mul, 3
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_TOP_MELEE)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5, 3
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_TOP_RANGED)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5, 3
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5, 3
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5, 3
		end

		FurthestBuilding = GetAncient(bot:GetTeam())
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 3, 4
		end
	end

	if lane == LANE_MID then
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_MID_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 0.5, 1)
			return FurthestBuilding, mul, 1
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_MID_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1, 2)
			return FurthestBuilding, mul, 2
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_MID_3)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1.5, 2)
			return FurthestBuilding, mul, 3
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_MID_MELEE)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5, 3
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_MID_RANGED)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5, 3
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5, 3
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5, 3
		end

		FurthestBuilding = GetAncient(bot:GetTeam())
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 3, 4
		end
	end

	if lane == LANE_BOT then
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BOT_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 0.5, 2)
			return FurthestBuilding, mul, 1
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BOT_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1, 2)
			return FurthestBuilding, mul, 2
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BOT_3)
		if Defend.IsValidBuildingTarget(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1.5, 2)
			return FurthestBuilding, mul, 3
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_BOT_MELEE)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5, 3
		end

		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_BOT_RANGED)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding, 2.5, 3
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_1)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5, 3
		end

		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_2)
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 2.5, 3
		end

		FurthestBuilding = GetAncient(bot:GetTeam())
		if Defend.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam()), 3, 4
		end
	end

	return nil, 1, 0
end

function Defend.IsValidBuildingTarget(unit)
	return unit ~= nil
	and unit:IsAlive()
	and unit:IsBuilding()
	and unit:CanBeSeen()
end

function Defend.OnEnd() end

return Defend