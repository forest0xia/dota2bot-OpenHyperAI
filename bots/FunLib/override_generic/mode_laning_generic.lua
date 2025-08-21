local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local LowHealthThreshold = 0.4
local safeAmountFromFront = 300

function X.OnStart() end
function X.OnEnd() end

local nEnemyTowers, nEnemyCreeps, assignedLane, tangoDesire, tangoTarget, tangoSlot

function X.GetDesire()

	tangoDesire, tangoTarget = ConsiderTango()
	if tangoDesire > 0 then
		return BOT_MODE_DESIRE_ABSOLUTE
	end

	if not assignedLane then assignedLane = GetBotTargetLane() end
	-- local vLaneFront = GetLaneFrontLocation(GetTeam(), assignedLane, 400)
	-- local laneFrontEnemies = J.GetLastSeenEnemiesNearLoc(vLaneFront, 1200)
	-- if #laneFrontEnemies >= 2 then
	-- 	local hAllyList = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_NONE )
	-- 	if #laneFrontEnemies > #hAllyList then
	-- 		return 0.22
	-- 	end
	-- end

	if GetGameMode() == GAMEMODE_1V1MID or GetGameMode() == GAMEMODE_MO then return 1 end

	local currentTime = DotaTime()
	local botLV = bot:GetLevel()

	if GetGameMode() == 23 then currentTime = currentTime * 1.65 end
	if currentTime <= 10 then return 0.268 end
	if currentTime <= 9 * 60 and botLV <= 7 then return 0.446 end
	if currentTime <= 12 * 60 and botLV <= 11 then return 0.369 end
	if botLV <= 15 and J.GetCoresAverageNetworth() < 12000 then return 0.228 end

	return BOT_MODE_DESIRE_VERYLOW

end

function GetHarassTarget(hEnemyList)
	for _, enemyHero in pairs(hEnemyList) do
		if J.IsValidHero(enemyHero)
		and J.CanBeAttacked(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			return enemyHero
		end
	end

	return nil
end

function GetBotTargetLane()
	-- assignedLane = bot:GetAssignedLane()
	if assignedLane then return assignedLane end

	if GetTeam() == TEAM_RADIANT then
		if J.GetPosition(bot) == 2 then
			assignedLane = LANE_MID
		end
		if J.GetPosition(bot) == 1 or J.GetPosition(bot) == 5 then
			assignedLane = LANE_BOT
		end
		if J.GetPosition(bot) == 3 or J.GetPosition(bot) == 4 then
			assignedLane = LANE_TOP
		end
	else
		if J.GetPosition(bot) == 2 then
			assignedLane = LANE_MID
		end
		if J.GetPosition(bot) == 1 or J.GetPosition(bot) == 5 then
			assignedLane = LANE_TOP
		end
		if J.GetPosition(bot) == 3 or J.GetPosition(bot) == 4 then
			assignedLane = LANE_BOT
		end
	end
	return assignedLane
end

function X.Think()
    if not bot:IsAlive() or J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() or bot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end

	if tangoDesire and tangoDesire > 0 and tangoTarget then
		local hItem = bot:GetItemInSlot( tangoSlot )
		bot:Action_UseAbilityOnTree( hItem, tangoTarget )
		return
	end

	-- harass
	local curTarget = bot:GetTarget()
	if not J.Utils.IsValidUnit(curTarget) or curTarget:IsHero() or not J.IsAttacking(bot) then
		local tEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)
		local tEnemyHeroes = bot:GetNearbyHeroes(bot:GetAttackRange() + 200, true, BOT_MODE_NONE)
		if #tEnemyLaneCreeps <= 1 then
			local harassTarget = GetHarassTarget(tEnemyHeroes)
			if J.IsValidHero(harassTarget) then
				bot:Action_AttackUnit(harassTarget, true)
				return
			end
		end
	end
end

function ConsiderTango()
	tangoDesire = 0
	tangoSlot = J.FindItemSlotNotInNonbackpack(bot, "item_tango")
	if tangoSlot < 0 then
		tangoSlot = J.FindItemSlotNotInNonbackpack(bot, "item_tango_single")
	end
	if tangoSlot >= 0
	and bot:OriginalGetMaxHealth() - bot:OriginalGetHealth() > 250
	and J.GetHP(bot) > 0.15
	and not J.IsAttacking(bot)
	and not bot:WasRecentlyDamagedByAnyHero(2)
	and not bot:HasModifier('modifier_tango_heal') then
		local trees = bot:GetNearbyTrees( 800 )
		local targetTree = trees[1]
		local nearEnemyList = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE )
		local nearestEnemy = nearEnemyList[1]
		local nearTowerList = bot:GetNearbyTowers( 1400, true )
		local nearestTower = nearTowerList[1]
		if targetTree ~= nil
		then
			local targetTreeLoc = GetTreeLocation( targetTree )
			if IsLocationVisible( targetTreeLoc )
				and IsLocationPassable( targetTreeLoc )
				-- and ( #nearEnemyList == 0 or not J.IsInRange( bot, nearestEnemy, 800 ) )
				and ( #nearEnemyList == 0 or GetUnitToLocationDistance( bot, targetTreeLoc ) * 1.6 < GetUnitToUnitDistance( bot, nearestEnemy ) )
				and ( #nearTowerList == 0 or GetUnitToLocationDistance( nearestTower, targetTreeLoc ) > 920 )
			then
				return BOT_ACTION_DESIRE_HIGH, targetTree
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE
end

return X