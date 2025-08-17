local bot = GetBot()
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )

local clearMode = false
local botName = bot:GetUnitName()

if bot.isInLanePhase == nil then bot.isInLanePhase = false end

function GetDesire()

	local currentTime = DotaTime()
	local botActiveMode = bot:GetActiveMode()
	local botActiveModeDesire = bot:GetActiveMode()
	local botAssignedLane = bot:GetAssignedLane()

	if currentTime < 0
	or not bot:IsAlive()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local bCore = J.IsCore(bot)
	local botLevel = bot:GetLevel()
	local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

	if (currentTime <= 9 * 60 and botLevel <= 7)
	or (botAssignedLane == LANE_MID and currentTime <= 6 * 60)
	then
		bot.isInLanePhase = true
		return 0.446
	end

	local nTower = TOWER_TOP_1
	if botAssignedLane == LANE_MID then
		nTower = TOWER_MID_1
	elseif botAssignedLane == LANE_BOT then
		nTower = TOWER_BOT_1
	end

	-- try stay in lane to get the farming item
	if bot.sItemBuyList and not string.find(botName, 'lone_druid') and GetTower(GetTeam(), nTower) ~= nil then
		local bHaveEarlyFarmingItem = false
		local sItemName = ''
		for i = 1, #bot.sItemBuyList do
			if bot.sItemBuyList[i] == 'item_maelstrom'
			or bot.sItemBuyList[i] == 'item_mjollnir'
			or bot.sItemBuyList[i] == 'item_bfury'
			then
				if i <= (#bot.sItemBuyList / 2) then
					sItemName = bot.sItemBuyList[i]
					bHaveEarlyFarmingItem = true
					break
				end
			end
		end

		if bHaveEarlyFarmingItem and not J.HasItemInInventory(sItemName) then
			bot.isInLanePhase = true
			return BOT_MODE_DESIRE_LOW
		end
	end

	bot.isInLanePhase = false

	if currentTime <= 12 * 60 and botLevel <= 11 then
		return 0.369
	end

	return BOT_MODE_DESIRE_VERYLOW
end

if Utils.BuggyHeroesDueToValveTooLazy[botName]
then

function GetBestLastHitCreep(hCreepList)
	local attackDamage = bot:GetAttackDamage()

	if bot:GetItemSlotType(bot:FindItemSlot("item_quelling_blade")) == ITEM_SLOT_TYPE_MAIN then
		if bot:GetAttackRange() > 310 or bot:GetUnitName() == "npc_dota_hero_templar_assassin" then
			attackDamage = attackDamage + 4
		else
			attackDamage = attackDamage + 8
		end
	end

	for _, creep in pairs(hCreepList) do
		if J.IsValid(creep) and J.CanBeAttacked(creep) then
			local nDelay = J.GetAttackProDelayTime(bot, creep)
			if J.WillKillTarget(creep, attackDamage, DAMAGE_TYPE_PHYSICAL, nDelay) then
				return creep
			end
		end
	end

	return nil
end

function GetBestDenyCreep(hCreepList)
	for _, creep in pairs(hCreepList)
	do
		if J.IsValid(creep)
		and J.GetHP(creep) < 0.49
		and J.CanBeAttacked(creep)
		and creep:GetHealth() <= bot:GetAttackDamage()
		then
			return creep
		end
	end

	return nil
end

function GetHarassTarget(hEnemyList)
	for _, enemyHero in pairs(hEnemyList) do
		if J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, bot:GetAttackRange() + 150)
		and J.CanBeAttacked(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			return enemyHero
		end
	end

	return nil
end

local fNextMovementTime = 0
function Think()
	if J.CanNotUseAction(bot) then
		return
	end

	local botAttackRange = bot:GetAttackRange()
	local botAssignedLane = bot:GetAssignedLane()
	local nAllyCreeps = bot:GetNearbyLaneCreeps(1200, false)
	local nEnemyCreeps = bot:GetNearbyLaneCreeps(1200, true)
	local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local tEnemyTowers = bot:GetNearbyTowers(1200, true)

	local nFurthestEnemyAttackRange = GetFurthestEnemyAttackRange()

	if (bot:WasRecentlyDamagedByAnyHero(2.0) and #J.GetHeroesTargetingUnit(tEnemyHeroes, bot) >= 1)
	or (J.IsValidBuilding(tEnemyTowers[1]) and tEnemyTowers[1]:GetAttackTarget() == bot)
	or (bot:WasRecentlyDamagedByCreep(2.0) and not (bot:HasModifier('modifier_tower_aura') or bot:HasModifier('modifier_tower_aura_bonus')) and #nAllyCreeps > 0) then
		local safeLoc = GetLaneFrontLocation(GetTeam(), botAssignedLane, -1200)
		bot:Action_MoveToLocation(safeLoc)
		return
	end

	if bot:WasRecentlyDamagedByTower(1.0) and #nEnemyCreeps > 0 then
		if DropTowerAggro(bot, nEnemyCreeps) then
			return
		end
	end

	if J.IsValidBuilding(tEnemyTowers[1]) then
		local dist = GetUnitToUnitDistance(bot, tEnemyTowers[1])
		if dist < 800 and #nEnemyCreeps < 3 then
			bot:Action_MoveToLocation(J.VectorAway(bot:GetLocation(), tEnemyTowers[1]:GetLocation(), 800))
			return
		end
	end

	local hitCreep = GetBestLastHitCreep(nEnemyCreeps)
	if J.IsValid(hitCreep) then
		local nLanePartner = J.GetLanePartner(bot)
		if nLanePartner == nil
		or J.IsCore(bot)
		or (not J.IsCore(bot)
			and J.IsCore(nLanePartner)
			and (not nLanePartner:IsAlive()
				or not J.IsInRange(bot, nLanePartner, 800)))
		then
			if GetUnitToUnitDistance(bot, hitCreep) > botAttackRange then
				bot:Action_MoveToUnit(hitCreep)
				return
			else
				bot:Action_AttackUnit(hitCreep, true)
				return
			end
		end
	end

	local denyCreep = GetBestDenyCreep(nAllyCreeps)
	if J.IsValid(denyCreep) then
		bot:Action_AttackUnit(denyCreep, true)
		return
	end

	-- support harass (later ie. willow, hoodwink etc); don't strong creep aggro
	nEnemyCreeps = bot:GetNearbyLaneCreeps(600, true)
	if #nEnemyCreeps <= 1 and not J.IsCore(bot) then
		local harassTarget = GetHarassTarget(tEnemyHeroes)
		if J.IsValidHero(harassTarget) then
			bot:Action_AttackUnit(harassTarget, true)
			return
		end
	end

	local fLaneFrontAmount = GetLaneFrontAmount(GetTeam(), botAssignedLane, false)
	local fLaneFrontAmount_enemy = GetLaneFrontAmount(GetOpposingTeam(), botAssignedLane, false)
	if nFurthestEnemyAttackRange == 0 then
		nFurthestEnemyAttackRange = Max(botAttackRange, 330)
	end

	local target_loc = GetLaneFrontLocation(GetTeam(), botAssignedLane, -nFurthestEnemyAttackRange)
	if fLaneFrontAmount_enemy < fLaneFrontAmount then
		target_loc = GetLaneFrontLocation(GetOpposingTeam(), botAssignedLane, -nFurthestEnemyAttackRange)
	end

	if DotaTime() >= fNextMovementTime then
		bot:Action_MoveToLocation(target_loc + RandomVector(300))
		fNextMovementTime = DotaTime() + RandomFloat(0.05, 0.2)
	end
end

function GetFurthestEnemyAttackRange()
	local attackRange = 0
	local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	for _, enemy in pairs(nInRangeEnemy) do
		if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) then
			local enemyAttackRange = enemy:GetAttackRange()
			if enemyAttackRange > attackRange then
				attackRange = enemyAttackRange
			end
		end
	end

	return attackRange
end

function DropTowerAggro(hUnit, nearbyCrepsAlly)
	if J.IsValid(hUnit) then
		local nearbyTowers = hUnit:GetNearbyTowers(750, true)
		if #nearbyCrepsAlly > 0 and #nearbyTowers == 1 then
			for _, creep in pairs(nearbyCrepsAlly) do
				if J.IsValid(creep) and GetUnitToUnitDistance(creep, nearbyTowers[1]) < 700 then
					hUnit:Action_AttackUnit(creep, true)
					return true
				end
			end
		end
	end

	return false
end

end