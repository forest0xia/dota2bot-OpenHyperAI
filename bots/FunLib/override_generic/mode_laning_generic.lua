local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local botName = bot:GetUnitName()

function X.OnStart() end
function X.OnEnd() end

-- function X.GetDesire()
-- end

function X.Think()
    if not bot:IsAlive() or J.CanNotUseAction(bot) then return end

	local AttackRange = bot:GetAttackRange()
	local LowHealthThreshold = 0.35
	local RetreatThreshold = 0.15

	local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local nAllyHeroes = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

	if (J.GetHP(bot) < RetreatThreshold and nEnemyHeroes ~= nil and #nEnemyHeroes > 0)
	or (bot:WasRecentlyDamagedByAnyHero(2) and (bot:GetAttackTarget() ~= nil and not (bot:GetAttackTarget()):IsHero()))
	or (J.GetHP(bot) < RetreatThreshold and (bot:WasRecentlyDamagedByCreep(2) or bot:WasRecentlyDamagedByTower(2)))
	then
		bot:Action_MoveToLocation(J.GetTeamFountain() + RandomVector(600))
		return
	end

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

	local vLaneFront = GetLaneFrontLocation(GetTeam(), assignedLane, -AttackRange - 100)
	local vEnemyLaneFront = GetLaneFrontLocation(GetOpposingTeam(), assignedLane, -AttackRange - 100)
	local nEnemyLaneAmount = 1 - GetLaneFrontAmount(GetOpposingTeam(), assignedLane, true)

	if J.GetDistance(vLaneFront, vEnemyLaneFront) <= 100
	and nEnemyLaneAmount > 0
	then
		vLaneFront = vEnemyLaneFront
	end

	if J.GetHP(bot) > LowHealthThreshold
	then
		bot:Action_MoveToLocation(vLaneFront + RandomVector(300))
	else
		vLaneFront = GetLaneFrontLocation(GetTeam(), assignedLane, -RemapValClamped(J.GetHP(bot), 0, 1, 1200, AttackRange))
		bot:Action_MoveToLocation(vLaneFront)
	end
end

return X