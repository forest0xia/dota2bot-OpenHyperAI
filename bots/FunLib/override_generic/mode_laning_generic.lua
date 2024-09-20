local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local LowHealthThreshold = 0.4
local safeAmountFromFront = 300

function X.OnStart() end
function X.OnEnd() end

local nEnemyTowers, nEnemyCreeps, assignedLane

function X.GetDesire()
	assignedLane = GetBotTargetLane()
	local vLaneFront = GetLaneFrontLocation(GetTeam(), assignedLane, 400)
	local laneFrontEnemies = J.GetLastSeenEnemiesNearLoc(vLaneFront, 1200)
	if #laneFrontEnemies >= 2 then
		local hAllyList = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_NONE )
		if #laneFrontEnemies > hAllyList then
			return 0.22
		end
	end

	if GetGameMode() == GAMEMODE_1V1MID or GetGameMode() == GAMEMODE_MO then return 1 end

	local currentTime = DotaTime()
	local botLV = bot:GetLevel()

	if currentTime <= 10 then return 0.268 end
	if currentTime <= 9 * 60 and botLV <= 7 then return 0.446 end
	if currentTime <= 12 * 60 and botLV <= 11 then return 0.369 end
	if botLV <= 17 then return 0.228 end

	return 0

end

function GetBotTargetLane()
	assignedLane = bot:GetAssignedLane()
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

	GetBotTargetLane()
	local AttackRange = bot:GetAttackRange()

	-- print('Bug laning think, '..botName..', assignedLane='..tostring(assignedLane)..', pos='..J.GetPosition(bot))

	local safeAmountWithAttackRange = -AttackRange - safeAmountFromFront
	local vLaneFront = GetLaneFrontLocation(GetTeam(), assignedLane, safeAmountWithAttackRange)

	nEnemyTowers = bot:GetNearbyTowers(1000, true )
	nEnemyCreeps = bot:GetNearbyCreeps(400, true)

	if (#nEnemyTowers >= 1 and J.IsInRange(bot, nEnemyTowers[1], 800))
	or (#nEnemyCreeps >= 2 and bot:WasRecentlyDamagedByCreep(2) )
	or bot:WasRecentlyDamagedByTower(2) then
		if bot:GetLevel() < 5 then
			vLaneFront = GetLaneFrontLocation(GetTeam(), assignedLane, RemapValClamped(J.GetHP(bot), 0, 1, -1000 + safeAmountWithAttackRange, safeAmountWithAttackRange))
			bot:Action_MoveToLocation(vLaneFront)
			return
		end
	end

	if J.GetHP(bot) > LowHealthThreshold
	then
		bot:Action_MoveToLocation(vLaneFront + RandomVector(240))
		return
	else
		vLaneFront = GetLaneFrontLocation(GetTeam(), assignedLane, RemapValClamped(J.GetHP(bot), 0, 1, -1000 + safeAmountWithAttackRange, safeAmountWithAttackRange))
		bot:Action_MoveToLocation(vLaneFront)
		return
	end
end

return X