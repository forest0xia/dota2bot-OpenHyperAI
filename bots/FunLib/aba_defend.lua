local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local Defend = {}
local pingTimeDelta = 5

local nTeam = GetTeam()
local hTowerTable = {
	[LANE_TOP] = {
		[1] = GetTower(nTeam, TOWER_TOP_1),
		[2] = GetTower(nTeam, TOWER_TOP_2),
		[3] = GetTower(nTeam, TOWER_TOP_3),
	},
	[LANE_MID] = {
		[1] = GetTower(nTeam, TOWER_MID_1),
		[2] = GetTower(nTeam, TOWER_MID_2),
		[3] = GetTower(nTeam, TOWER_MID_3),
	},
	[LANE_BOT] = {
		[1] = GetTower(nTeam, TOWER_BOT_1),
		[2] = GetTower(nTeam, TOWER_BOT_2),
		[3] = GetTower(nTeam, TOWER_BOT_3),
	},
}

function Defend.GetDefendDesire(bot, lane)
	if bot.laneToDefend == nil then bot.laneToDefend = lane end

	local hTeamAncient = GetAncient(GetTeam())
	local nEnemyAroundAncient = Defend.GetEnemiesAroundLocation(hTeamAncient:GetLocation(), 3000)
	local botPosition = J.GetPosition(bot)
	local botActiveMode = bot:GetActiveMode()
	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1400)
	local bMyLane = bot:GetAssignedLane() == lane

	if botActiveMode == BOT_MODE_DEFEND_TOWER_TOP then
		bot.laneToDefend = LANE_TOP
	elseif botActiveMode == BOT_MODE_DEFEND_TOWER_MID then
		bot.laneToDefend = LANE_MID
	elseif botActiveMode == BOT_MODE_DEFEND_TOWER_BOT then
		bot.laneToDefend = LANE_BOT
	end

	if #nInRangeEnemy > 0 --and GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), lane, 0)) < 1200
	or (not bMyLane and botPosition == 1 and J.IsInLaningPhase()) -- reduce carry feeds
	or (J.IsDoingRoshan(bot) and #J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), 2800) >= 3)
	or (J.IsDoingTormentor(bot) and ((#J.GetAlliesNearLoc(J.GetTormentorLocation(GetTeam()), 1600) >= 2) or #J.GetAlliesNearLoc(J.GetTormentorWaitingLocation(GetTeam()), 2500) >= 2) and nEnemyAroundAncient == 0)
	then
		return BOT_MODE_DESIRE_NONE
	end

	local botLevel = bot:GetLevel()

	if not bMyLane then
		if botPosition == 1 and botLevel < 8
		or botPosition == 2 and botLevel < 6
		or botPosition == 3 and botLevel < 7
		or botPosition == 4 and botLevel < 4
		or botPosition == 5 and botLevel < 5
		then
			return BOT_MODE_DESIRE_NONE
		end
	end

	local human, humanPing = J.GetHumanPing()
	if human ~= nil and humanPing ~= nil and not humanPing.normal_ping and DotaTime() > 0 then
		local isPinged, pingedLane = J.IsPingCloseToValidTower(GetTeam(), humanPing, 700, 5.0)
		if isPinged and lane == pingedLane and GameTime() < humanPing.time + pingTimeDelta then
			return 0.9
		end
	end

	local furthestBuilding = Defend.GetFurthestBuildingOnLane(bot, lane)

	if nEnemyAroundAncient > 0 and lane == LANE_MID
	and nEnemyAroundAncient >= 2
	and (  furthestBuilding == hTeamAncient
		or furthestBuilding == GetTower(nTeam, TOWER_BASE_1)
		or furthestBuilding == GetTower(nTeam, TOWER_BASE_2))
	then
		return BOT_MODE_DESIRE_VERYHIGH
	end

	local nDesire = GetDefendLaneDesire(lane)
	local hTier1Tower = hTowerTable[lane][1]
	local hTier2Tower = hTowerTable[lane][2]
	local hTier3Tower = hTowerTable[lane][3]

	if 	   not J.IsValidBuilding(hTier3Tower) then
		return Clamp(nDesire * 5, 0, 0.9)
	elseif not J.IsValidBuilding(hTier2Tower) then
		return Clamp(nDesire * 3, 0, 0.9)
	elseif J.IsValidBuilding(hTier1Tower) and Defend.ShouldDefend(bot, furthestBuilding, 1600)
	then
		return Clamp(nDesire, 0, 0.9)
	elseif J.IsValidBuilding(hTier2Tower) and Defend.ShouldDefend(bot, furthestBuilding, 1600)
	then
		return Clamp(nDesire * 2, 0, 0.9)
	end

	return 0
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

local fTraveBootsDefendTime = 0
function Defend.ShouldDefend(bot, hBuilding, nRadius)
	local nEnemyHeroNearbyCount = 0
	for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil then
					if GetUnitToLocationDistance(hBuilding, dInfo.location) <= 1600
					and dInfo.time_since_seen <= 5.0
					then
						nEnemyHeroNearbyCount = nEnemyHeroNearbyCount + 1
					end
				end
			end
		end
	end

	local nEnemyCreepNearbyCount = 0
	local unitList = GetUnitList(UNIT_LIST_ENEMIES)
	for _, unit in pairs(unitList) do
		if J.IsValid(unit) and GetUnitToUnitDistance(hBuilding, unit) <= nRadius then
			local sUnitName = unit:GetUnitName()
			if string.find(sUnitName, 'siege') and not string.find(sUnitName, 'upgraded')
			then
				nEnemyCreepNearbyCount = nEnemyCreepNearbyCount + 0.5
			elseif string.find(sUnitName, 'upgraded_mega')
			then
				nEnemyCreepNearbyCount = nEnemyCreepNearbyCount + 0.6
			elseif string.find(sUnitName, 'upgraded')
			then
				nEnemyCreepNearbyCount = nEnemyCreepNearbyCount + 0.4
			elseif string.find(sUnitName, 'warlock_golem')
				or string.find(sUnitName, 'shadow_shaman_ward') and bot:GetAttackDamage() >= 500
			then
				nEnemyCreepNearbyCount = nEnemyCreepNearbyCount + 1
			elseif string.find(sUnitName, 'lone_druid_bear')
			then
				nEnemyHeroNearbyCount = nEnemyHeroNearbyCount + 1
			elseif unit:IsCreep()
				or unit:IsAncientCreep()
				or unit:IsDominated()
				or unit:HasModifier('modifier_chen_holy_persuasion')
				or unit:HasModifier('modifier_dominated')
			then
				nEnemyCreepNearbyCount = nEnemyCreepNearbyCount + 0.2
			end
		end
	end

	nEnemyHeroNearbyCount = math.floor(nEnemyHeroNearbyCount)
	nEnemyCreepNearbyCount = math.floor(nEnemyCreepNearbyCount)

	local botPosition J.GetPosition(bot)
	local nEnemyNearbyCount = nEnemyHeroNearbyCount + nEnemyCreepNearbyCount

	if nEnemyNearbyCount == 1 then
		if (botPosition == 2)
		or (botPosition == Defend.GetClosestAlly({4, 5}, hBuilding:GetLocation()))
		then
			return true
		end
	elseif nEnemyNearbyCount == 2 then
		if (botPosition == 2)
		or (botPosition == 3)
		or (botPosition == Defend.GetClosestAlly({4, 5}, hBuilding:GetLocation()))
		or (botPosition == 1 and GetUnitToUnitDistance(bot, hBuilding) <= 3200)
		then
			return true
		end
	elseif nEnemyNearbyCount == 3 then
		if (botPosition == 2)
		or (botPosition == 3)
		or (botPosition == 4)
		or (botPosition == 5)
		or (botPosition == 1 and GetUnitToUnitDistance(bot, hBuilding) <= 3200)
		then
			return true
		end
	elseif nEnemyNearbyCount >= 4 then
		return true
	end

	if bot.travel_boots_defender == nil then bot.travel_boots_defender = false end

	if DotaTime() - fTraveBootsDefendTime < 20.0 then
		bot.travel_boots_defender = false
	end

	local function IsThereNoTeammateTravelBootsDefender()
		for i = 1, 5 do
			local member = GetTeamMember(i)
			if bot ~= member and J.IsValidHero(member) and member.travel_boots_defender == true then
				return false
			end
		end

		return true
	end

	if (bot:GetUnitName() == 'npc_dota_hero_tinker'
		and bot:GetLevel() >= 6
		and J.CanCastAbility(bot:GetAbilityByName('tinker_keen_teleport'))
		and IsThereNoTeammateTravelBootsDefender())
	then
		bot.travel_boots_defender = true
		fTraveBootsDefendTime = DotaTime()
		return true
	end

	local hItem = J.GetItem2(bot, 'item_travel_boots') or J.GetItem2(bot, 'item_travel_boots_2')
	if J.CanCastAbility(hItem) and IsThereNoTeammateTravelBootsDefender() then
		bot.travel_boots_defender = true
		fTraveBootsDefendTime = DotaTime()
		return true
	end

	if botPosition == Defend.GetClosestAlly({2,3}, hBuilding:GetLocation()) then
		return true
	end

	return false
end

function Defend.GetFurthestBuildingOnLane(bot, lane)
	local botTeam = GetTeam()
	local FurthestBuilding = nil

	if lane == LANE_TOP then
		FurthestBuilding = GetTower(botTeam, TOWER_TOP_1)
		if J.IsValidBuilding(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 0.5, 1)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(botTeam, TOWER_TOP_2)
		if J.IsValidBuilding(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(botTeam, TOWER_TOP_3)
		if J.IsValidBuilding(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1.5, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetBarracks(botTeam, BARRACKS_TOP_MELEE)
		if J.IsValidBuilding(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetBarracks(botTeam, BARRACKS_TOP_RANGED)
		if J.IsValidBuilding(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetAncient(botTeam)
		if J.IsValidBuilding(FurthestBuilding) then
			return GetAncient(botTeam), 3
		end
	end

	if lane == LANE_MID then
		FurthestBuilding = GetTower(botTeam, TOWER_MID_1)
		if J.IsValidBuilding(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 0.5, 1)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(botTeam, TOWER_MID_2)
		if J.IsValidBuilding(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(botTeam, TOWER_MID_3)
		if J.IsValidBuilding(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1.5, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetBarracks(botTeam, BARRACKS_MID_MELEE)
		if J.IsValidBuilding(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetBarracks(botTeam, BARRACKS_MID_RANGED)
		if J.IsValidBuilding(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetTower(botTeam, TOWER_BASE_1)
		if J.IsValidBuilding(FurthestBuilding) then
			return GetAncient(botTeam), 2.5
		end

		FurthestBuilding = GetTower(botTeam, TOWER_BASE_2)
		if J.IsValidBuilding(FurthestBuilding) then
			return GetAncient(botTeam), 2.5
		end

		FurthestBuilding = GetAncient(botTeam)
		if J.IsValidBuilding(FurthestBuilding) then
			return GetAncient(botTeam), 3
		end
	end

	if lane == LANE_BOT then
		FurthestBuilding = GetTower(botTeam, TOWER_BOT_1)
		if J.IsValidBuilding(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 0.5, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(botTeam, TOWER_BOT_2)
		if J.IsValidBuilding(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetTower(botTeam, TOWER_BOT_3)
		if J.IsValidBuilding(FurthestBuilding)
		then
			local nHealth = FurthestBuilding:GetHealth() / FurthestBuilding:GetMaxHealth()
			local mul = RemapValClamped(nHealth, 0.25, 1, 1.5, 2)
			return FurthestBuilding, mul
		end

		FurthestBuilding = GetBarracks(botTeam, BARRACKS_BOT_MELEE)
		if J.IsValidBuilding(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetBarracks(botTeam, BARRACKS_BOT_RANGED)
		if J.IsValidBuilding(FurthestBuilding) then
			return FurthestBuilding, 2.5
		end

		FurthestBuilding = GetAncient(botTeam)
		if J.IsValidBuilding(FurthestBuilding) then
			return GetAncient(botTeam), 3
		end
	end

	return nil, 1
end

function Defend.GetEnemyAmountMul(lane)
	local count = Defend.GetEnemyCountInLane(lane, 1600)
	local _, urgentNum = Defend.GetFurthestBuildingOnLane(lane)
	return RemapValClamped(count, 1, 3, 1, 2) * urgentNum
end

function Defend.GetEnemyCountInLane(lane, nRadius)
	local nUnitCount = 0
	local furthestBuilding = Defend.GetFurthestBuildingOnLane(lane)

	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
		if J.IsValid(unit)
		and J.IsValidBuilding(furthestBuilding)
		and GetUnitToUnitDistance(unit, furthestBuilding) <= nRadius
		then
			local unitName = unit:GetUnitName()
			if J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) then
				nUnitCount = nUnitCount + 1
			elseif string.find(unitName, 'siege') and not string.find(unitName, 'upgraded') then
				nUnitCount = nUnitCount + 0.5
			elseif string.find(unitName, 'upgraded') then
				nUnitCount = nUnitCount + 0.5
			elseif string.find(unitName, 'warlock_golem') then
				nUnitCount = nUnitCount + 1
			elseif string.find(unitName, 'lone_druid_bear') then
				nUnitCount = nUnitCount + 1
			elseif unit:IsCreep() then
				nUnitCount = nUnitCount + 0.2
			end
		end
	end

	return nUnitCount
end

function Defend.IsOnlyCreepsAroundBuilding(hBuilding, nRadius)
	local creepCount = 0
	local heroCount = 0

	for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
				and J.GetDistance(hBuilding:GetLocation(), dInfo.location) <= nRadius
				and dInfo.time_since_seen < 3.0
				then
					heroCount = heroCount + 1
				end
			end
		end
	end

	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
	do
		if J.IsValid(unit)
		and GetUnitToUnitDistance(hBuilding, unit) <= nRadius
		then
			if unit:IsCreep()
			or unit:IsAncientCreep()
			or unit:HasModifier('modifier_chen_holy_persuasion')
			or unit:HasModifier('modifier_dominated')
			then
				creepCount = creepCount + 1
			end

			if string.find(unit:GetUnitName(), 'warlock_golem')
			or string.find(unit:GetUnitName(), 'lone_druid_bear') then
				heroCount = heroCount + 1
			end
		end
	end

	return creepCount > 0 and heroCount == 0
end

function Defend.GetEnemiesAroundLocation(vLocation, nRadius)
	local nUnitCount = 0

	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
		if J.IsValid(unit) and GetUnitToLocationDistance(unit, vLocation) <= nRadius then
			local sUnitName = unit:GetUnitName()

			if J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) then
				if not J.IsCore(unit) then
					nUnitCount = nUnitCount + 0.5
				else
					nUnitCount = nUnitCount + 1
				end
			elseif string.find(sUnitName, 'upgraded_mega') then
				nUnitCount = nUnitCount + 0.6
			elseif string.find(sUnitName, 'upgraded') then
				nUnitCount = nUnitCount + 0.4
			elseif string.find(sUnitName, 'warlock_golem') then
				nUnitCount = nUnitCount + 1
			elseif string.find(sUnitName, 'lone_druid_bear') then
				nUnitCount = nUnitCount + 1
			elseif unit:IsCreep()
				or unit:IsAncientCreep()
				or unit:IsDominated()
				or unit:HasModifier('modifier_chen_holy_persuasion')
				or unit:HasModifier('modifier_dominated')
			then
				nUnitCount = nUnitCount + 0.2
			end
		end
	end

	return math.floor(nUnitCount)
end

function Defend.IsImportantBuilding(hBuilding)
	if hBuilding == GetTower(GetTeam(), TOWER_TOP_1)
	or hBuilding == GetTower(GetTeam(), TOWER_MID_1)
	or hBuilding == GetTower(GetTeam(), TOWER_BOT_1)
	or hBuilding == GetTower(GetTeam(), TOWER_TOP_2)
	or hBuilding == GetTower(GetTeam(), TOWER_MID_2)
	or hBuilding == GetTower(GetTeam(), TOWER_BOT_2)
	then
		return false
	end

	return true
end

function Defend.GetClosestAlly(tPosList, vLocation)
	local pos = nil
	local allyDistance = math.huge
	for i = 1, 5 do
		local member = GetTeamMember(i)
		if J.IsValidHero(member) then
			local memberPosition = J.GetPosition(member)
			for j = 1, #tPosList do
				if memberPosition == tPosList[j] then
					local memberDistance = GetUnitToLocationDistance(member, vLocation)
					if memberDistance < allyDistance then
						pos = memberPosition
						allyDistance = memberDistance
					end
				end
			end
		end
	end

	return pos or tPosList[1]
end

return Defend