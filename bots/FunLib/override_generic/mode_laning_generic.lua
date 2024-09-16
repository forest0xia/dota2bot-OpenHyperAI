local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local LowHealthThreshold = 0.4
local safeAmountFromFront = 300

function X.OnStart() end
function X.OnEnd() end

local nEnemyTowers, nEnemyCreeps


function X.Think()
    if not bot:IsAlive() or J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() or bot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end

	local AttackRange = bot:GetAttackRange()

	local assignedLane = bot:GetAssignedLane()
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