local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local Defend = {}

function Defend.GetDefendDesire(bot, lane)
	if bot.laneToDefend == nil then bot.laneToDefend = lane end

    if J.IsInLaningPhase()
    then
        if J.IsCore(bot) then return 0 end
        if bot:GetLevel() < 6 then return 0.1 end
    end

	if J.GetHP(bot) < 0.3
	then
		return 0.25
	end

	local nDefendDesire = 0
	local mul = Defend.GetEnemyAmountMul(lane)
	local nEnemies = J.GetEnemiesAroundAncient()

	if  nEnemies ~= nil and #nEnemies >= 1
	and (GetTower(GetTeam(), TOWER_MID_3) == nil
		or (GetTower(GetTeam(), TOWER_TOP_3) == nil
			and GetTower(GetTeam(), TOWER_MID_3) == nil
			and GetTower(GetTeam(), TOWER_BOT_3) == nil))
	and lane == LANE_MID
	then
		nDefendDesire = 1
	else
		nDefendDesire = GetDefendLaneDesire(lane) * mul[lane]
	end

	bot.laneToDefend = lane
	return Clamp(nDefendDesire, 0, 0.9)
end

function Defend.WhichLaneToDefend(lane)

	local mul = Defend.GetEnemyAmountMul(lane)

	local laneAmountEnemyTop = (1 - GetLaneFrontAmount(GetOpposingTeam(), LANE_TOP, true))
	local laneAmountEnemyMid = (1 - GetLaneFrontAmount(GetOpposingTeam(), LANE_MID, true))
	local laneAmountEnemyBot = (1 - GetLaneFrontAmount(GetOpposingTeam(), LANE_BOT, true))

	local laneAmountTop = GetLaneFrontAmount(GetTeam(), LANE_TOP, true)
    local laneAmountMid = GetLaneFrontAmount(GetTeam(), LANE_MID, true)
    local laneAmountBot = GetLaneFrontAmount(GetTeam(), LANE_BOT, true)

	local nEnemyLaneFrontLoc = GetLaneFrontLocation(GetOpposingTeam(), lane, 0)
	if J.GetLocationToLocationDistance(nEnemyLaneFrontLoc, GetAncient(GetTeam()):GetLocation()) < 1600
	or (1 - GetLaneFrontAmount(GetOpposingTeam(), lane, true)) >= 0.8
	then
		return lane
	end

	if laneAmountEnemyTop == 0 then laneAmountEnemyTop = 0.1 end
	if laneAmountEnemyMid == 0 then laneAmountEnemyMid = 0.1 end
	if laneAmountEnemyBot == 0 then laneAmountEnemyBot = 0.1 end

	if laneAmountTop == 0 then laneAmountTop = 0.1 end
	if laneAmountMid == 0 then laneAmountMid = 0.1 end
	if laneAmountBot == 0 then laneAmountBot = 0.1 end

	laneAmountTop = laneAmountTop * laneAmountEnemyTop * mul[LANE_TOP]
	laneAmountMid = laneAmountMid * laneAmountEnemyMid * mul[LANE_MID]
	laneAmountBot = laneAmountBot * laneAmountEnemyBot * mul[LANE_BOT]

    if laneAmountTop < laneAmountBot
    and laneAmountTop < laneAmountMid
    then
        return LANE_TOP
    end

    if laneAmountBot < laneAmountTop
    and laneAmountBot < laneAmountMid
    then
        return LANE_BOT
    end

    if laneAmountMid < laneAmountTop
    and laneAmountMid < laneAmountBot
    then
        return LANE_MID
    end

    return nil
end

function Defend.TeamDefendLane()

    local team = GetTeam()

    if GetTower(team, TOWER_MID_1) ~= nil then
        return LANE_MID
    end
    if GetTower(team, TOWER_BOT_1) ~= nil then
        return LANE_BOT
    end
    if GetTower(team, TOWER_TOP_1) ~= nil then
        return LANE_TOP
    end

    if GetTower(team, TOWER_MID_2) ~= nil then
        return LANE_MID
    end
    if GetTower(team, TOWER_BOT_2) ~= nil then
        return LANE_BOT
    end
    if GetTower(team, TOWER_TOP_2) ~= nil then
        return LANE_TOP
    end

    if GetTower(team, TOWER_MID_3) ~= nil
    or GetBarracks(team, BARRACKS_MID_MELEE) ~= nil
    or GetBarracks(team, BARRACKS_MID_RANGED) ~= nil then
        return LANE_MID
    end

    if GetTower(team, TOWER_BOT_3) ~= nil 
    or GetBarracks(team, BARRACKS_BOT_MELEE) ~= nil
    or GetBarracks(team, BARRACKS_BOT_RANGED) ~= nil then
        return LANE_BOT
    end

    if GetTower(team, TOWER_TOP_3) ~= nil
    or GetBarracks(team, BARRACKS_TOP_MELEE) ~= nil
    or GetBarracks(team, BARRACKS_TOP_RANGED) ~= nil then
        return LANE_TOP
    end

    return LANE_MID
end

function Defend.ShouldGoDefend(bot, lane)
	local nLaneEnemyCount = Defend.GetEnemyCountInLane(lane, true)
	local pos = J.GetPosition(bot)

	if nLaneEnemyCount == 1
	then
		if pos == 2
        or pos == 4
        then
			return true
		end
	elseif nLaneEnemyCount == 2
	then
		if pos == 2
        or pos == 3
        or pos == 5
        then
			return true
		end
	elseif nLaneEnemyCount == 3
	then
		if pos == 2
        or pos == 3
        or pos == 4
        or pos == 5
        then
			return true
		end
	elseif nLaneEnemyCount >= 4
	then
		return true
	end

	if nLaneEnemyCount == 0
	then
		for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
		do
			if  J.IsValidHero(allyHero)
			and J.IsNotSelf(bot, allyHero)
			and not allyHero:IsIllusion()
			then
				local nMode = allyHero:GetActiveMode()

				if pos == 1
				then
					if J.GetPosition(allyHero) == 2
					or J.GetPosition(allyHero) == 3
					then
						if (nMode == BOT_MODE_DEFEND_TOWER_TOP
							and lane == LANE_TOP)
						or (nMode == BOT_MODE_DEFEND_TOWER_MID
							and lane == LANE_MID)
						or (nMode == BOT_MODE_DEFEND_TOWER_BOT
							and lane == LANE_BOT)
						then
							return false
						end
					end
				end

				if pos == 2
				then
					if J.GetPosition(allyHero) == 1
					or J.GetPosition(allyHero) == 3
					then
						if (nMode == BOT_MODE_DEFEND_TOWER_TOP
							and lane == LANE_TOP)
						or (nMode == BOT_MODE_DEFEND_TOWER_MID
							and lane == LANE_MID)
						or (nMode == BOT_MODE_DEFEND_TOWER_BOT
							and lane == LANE_BOT)
						then
							return false
						end
					end
				end

				if pos == 3
				then
					if J.GetPosition(allyHero) == 1
					or J.GetPosition(allyHero) == 2
					then
						if (nMode == BOT_MODE_DEFEND_TOWER_TOP
							and lane == LANE_TOP)
						or (nMode == BOT_MODE_DEFEND_TOWER_MID
							and lane == LANE_MID)
						or (nMode == BOT_MODE_DEFEND_TOWER_BOT
							and lane == LANE_BOT)
						then
							return false
						end
					end
				end
			end
		end
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
	local Enemies = Defend.GetEnemyCountInLane(lane, true)
	local _, urgent = Defend.GetFurthestBuildingOnLane(lane)

	local mulTop = 1
	local mulMid = 1
	local mulBot = 1

	if lane == LANE_TOP then
		if Enemies == 1 then
			mulTop = 1.1
		elseif Enemies == 2 then
			mulTop = 1.2
		elseif Enemies == 3 then
			mulTop = 1.3
		elseif Enemies > 3 then
			mulTop = 1.5
		end
		mulTop = mulTop * urgent
	elseif lane == LANE_MID then
		if Enemies == 1 then
			mulMid = 1.1
		elseif Enemies == 2 then
			mulMid = 1.2
		elseif Enemies == 3 then
			mulMid = 1.3
		elseif Enemies > 3 then
			mulMid = 1.5
		end
		mulMid = mulMid * urgent
	elseif lane == LANE_BOT then
		if Enemies == 1 then
			mulBot = 1.1
		elseif Enemies == 2 then
			mulBot = 1.2
		elseif Enemies == 3 then
			mulBot = 1.3
		elseif Enemies > 3 then
			mulBot = 1.5
		end
		mulBot = mulBot * urgent
	end

	return {mulTop, mulMid, mulBot}
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
		local distance = GetUnitToLocationDistance(enemy, laneFrontLoc)

		if isHero
		then
			if  distance < 1600
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

	return #units
end

function Defend.DefendThink(bot, lane)

    if bot:IsChanneling() or bot:IsUsingAbility() then
        return
    end

	if Defend.ShouldGoDefend(bot, lane)
    then
		-- if J.HasItem(bot, "item_tpscroll") then
		-- 	print("BOT TRYING TO TP DO DEFEND")
		-- 	bot:Action_UseAbilityOnLocation( "item_tpscroll", GetLaneFrontLocation(GetTeam(), lane, -100))
		-- else
		-- 	print("BOT TRYING DEFEND")
		-- 	bot:ActionPush_MoveToLocation(GetLaneFrontLocation(GetTeam(), lane, 0))
		-- end

		local enemies = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
		if enemies ~= nil and #enemies > 0
		and J.WeAreStronger(bot, 1600)
		then
			return bot:ActionPush_AttackUnit(enemies[1], false)
		end

		local creeps = bot:GetNearbyLaneCreeps(1600, true);
		if creeps ~= nil and #creeps > 0 then
			return bot:ActionPush_AttackUnit(creeps[1], false)
		end
    end
end

return Defend