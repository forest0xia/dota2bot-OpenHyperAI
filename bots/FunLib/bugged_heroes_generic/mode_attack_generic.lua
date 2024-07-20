local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
-- local botName = bot:GetUnitName()
local botTarget, nEnemyHeroes, nAllyHeroes, nEnemyTowers

function X.OnStart() end
function X.OnEnd() end

function X.GetDesire()
	if nAllyHeroes ~= nil and #nAllyHeroes >= 2 then
		local ally = nAllyHeroes[2]
		if GetUnitToUnitDistance(ally, bot) < 1000 and J.IsGoingOnSomeone(ally) then
			return ally:GetActiveModeDesire()
		end
	end

	-- if nEnemyHeroes == nil or #nEnemyHeroes == 0 then
	-- 	nEnemyHeroes = J.GetNearbyHeroes(bot, 1400, true)
	-- end

	if J.GetModifierTime(bot, "modifier_muerta_pierce_the_veil") > 0.5 then
		return BOT_ACTION_DESIRE_HIGH
	end

	if nEnemyHeroes ~= nil and nEnemyHeroes >= 1 and J.WeAreStronger(bot, 1400) and (nEnemyTowers == nil or #nEnemyTowers < 1) then
		return BOT_ACTION_DESIRE_HIGH
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.Think()
    if not bot:IsAlive() or J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() then return end
	if nEnemyTowers ~= nil and #nEnemyTowers >= 1 then
		bot:Action_ClearActions(false)
		bot:ActionPush_MoveToLocation(J.GetTeamFountain())
	end

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1400, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1400, false)
	nEnemyTowers = bot:GetNearbyTowers(800, true)

	if nAllyHeroes[2] ~= nil then botTarget = J.GetProperTarget(nAllyHeroes[2]) end
	if botTarget ~= nil then bot:SetTarget(botTarget) end
	botTarget = J.GetProperTarget(bot)

	if (botTarget ~= nil and botTarget:IsAlive())
	then
		local distance = GetUnitToUnitDistance(bot, botTarget)
		if (distance < 600) then
			bot:Action_AttackUnit(botTarget, true)
			return
		else
			bot:Action_MoveToUnit(botTarget)
			return
		end
	end

	local weakestEnemy = J.GetWeakestUnit(nEnemyHeroes)
	if (bot:GetTarget() == nil and weakestEnemy ~= nil)
	then
		bot:SetTarget(weakestEnemy)

		local distance = GetUnitToUnitDistance(bot, weakestEnemy)
		if (distance < 600) then
			bot:Action_AttackUnit(weakestEnemy, true)
			return
		else
			bot:Action_MoveToUnit(weakestEnemy)
			return
		end
	end
	
	local units = GetUnitList(UNIT_LIST_ENEMIES)
	for _, unit in pairs(units) do
		if GetUnitToUnitDistance(bot, unit) <= 600 then
			bot:Action_AttackUnit(botTarget, true)
			return
		end
	end

end

return X