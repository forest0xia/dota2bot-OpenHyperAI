local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local botName = bot:GetUnitName()
local botTarget, nEnemyHeroes, nAllyHeroes, nEnemyTowers, nEnemyCreeps, nAllyCreeps
local MaxTrackingDistance = 3000

function X.OnStart() end
function X.OnEnd() end

function X.GetDesire()
    if not bot:IsAlive() or J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() then return BOT_ACTION_DESIRE_NONE end

	if bot:GetActiveMode() == BOT_MODE_ATTACK then
		botTarget = bot:GetTarget()
		if botTarget == nil
		or botTarget:IsNull()
		or not J.CanBeAttacked(botTarget)
		or not J.IsInRange(botTarget, bot, MaxTrackingDistance) then
			bot:SetTarget(nil)
			-- print('Clear assigned attack target')
			return BOT_ACTION_DESIRE_NONE
		end
	end

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)
	nEnemyCreeps = bot:GetNearbyCreeps(800, true)
	
	-- sync with nearby ally's target if any
	if nAllyHeroes ~= nil and #nAllyHeroes >= 2 then
		local ally = nAllyHeroes[2]
		if J.IsInRange(ally, bot, 1600) and J.IsGoingOnSomeone(ally) then
			bot:SetTarget(J.GetProperTarget(ally))
			return ally:GetActiveModeDesire()
		end
	end
	-- if nEnemyHeroes == nil or #nEnemyHeroes == 0 then
	-- 	nEnemyHeroes = J.GetNearbyHeroes(bot, 1400, true)
	-- end

	if J.GetModifierTime(bot, "modifier_muerta_pierce_the_veil") > 0.5
	then
		return BOT_MODE_DESIRE_VERYHIGH
	end

	-- going on killing a target
	if J.IsGoingOnSomeone(bot)
	then
		botTarget = J.GetProperTarget(bot)
		if botTarget ~= nil and J.IsInRange(botTarget, bot, MaxTrackingDistance) then
			return RemapValClamped(J.GetHP(bot), 0, 1, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_VERYHIGH )
		end
	end

	-- has an enemy hero nearby in attack range
	if #nEnemyHeroes >= 1
	and J.IsValidHero(nEnemyHeroes[1])
	and J.IsInRange(nEnemyHeroes[1], bot, bot:GetAttackRange())
	and J.CanBeAttacked(nEnemyHeroes[1]) then
		bot:SetTarget(nEnemyHeroes[1])
		return RemapValClamped(J.GetHP(bot), 0, 1, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_VERYHIGH )
	end

	-- time to direct attack any hp creeps
	if #nEnemyCreeps > 0 then
		if J.IsInLaningPhase() then
			if not J.IsCore(bot) and #nAllyHeroes > 1 then
				return BOT_ACTION_DESIRE_NONE
			end
		end
		return RemapValClamped(J.GetHP(bot), 0, 1, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_VERYHIGH )
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.Think()
	-- if nEnemyTowers ~= nil and #nEnemyTowers >= 1 then
	-- 	bot:Action_ClearActions(false)
	-- 	bot:ActionPush_MoveToLocation(J.GetTeamFountain())
	-- end

	-- has a target already
	botTarget = J.GetProperTarget(bot)
	if botTarget ~= nil and botTarget:IsAlive() and J.IsInRange(botTarget, bot, MaxTrackingDistance) then
		local distance = GetUnitToUnitDistance(bot, botTarget)
		if distance <= bot:GetAttackRange() then
			bot:Action_AttackUnit(botTarget, true)
			return
		else
			bot:Action_MoveToUnit(botTarget)
			return
		end
	end


    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)
	nEnemyTowers = bot:GetNearbyTowers(800, true)

	ChooseAndAttackEnemyHero(nEnemyHeroes)
	if bot:GetTarget() == nil then
		LastHitCreeps()
	end

	if bot:GetTarget() == nil then
		local units = GetUnitList(UNIT_LIST_ENEMIES)
		for _, unit in pairs(units) do
			if GetUnitToUnitDistance(bot, unit) <= 600 then
				bot:Action_AttackUnit(botTarget, true)
				return
			end
		end
	end
end

function ChooseAndAttackEnemyHero(hEnemyList)
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, bot:GetAttackRange(), true, true )
	if nInAttackRangeWeakestEnemyHero ~= nil then
		bot:SetTarget(nInAttackRangeWeakestEnemyHero)
		bot:Action_AttackUnit(nInAttackRangeWeakestEnemyHero, true)
		return
	end

    for _, enemyHero in pairs(hEnemyList)
    do
        if J.IsValidHero(enemyHero)
		and J.CanBeAttacked(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
        then
			if J.IsValidHero(enemyHero)
			and J.IsInRange(bot, enemyHero, bot:GetAttackRange())
			then
				bot:SetTarget(enemyHero)
				bot:Action_AttackUnit(enemyHero, true)
				break
			end
        end
    end
end

function LastHitCreeps()
	nAllyCreeps = bot:GetNearbyCreeps(800, false)
	nEnemyCreeps = bot:GetNearbyCreeps(800, true)

	local hitCreep = GetBestLastHitCreep(nEnemyCreeps)
	if J.IsValid(hitCreep)
	then
		local nLanePartner = J.GetLanePartner(bot)
		if nLanePartner == nil
		or J.IsCore(bot)
		or (not J.IsCore(bot)
			and J.IsCore(nLanePartner)
			and (not nLanePartner:IsAlive()
				or not J.IsInRange(bot, nLanePartner, 800)))
		then
			bot:SetTarget(hitCreep)
			bot:Action_AttackUnit(hitCreep, true)
			return
		end
	end

	local denyCreep = GetBestDenyCreep(nAllyCreeps)
	if J.IsValid(denyCreep)
	then
		bot:SetTarget(denyCreep)
		bot:Action_AttackUnit(denyCreep, true)
		return
	end
end

function GetBestLastHitCreep(hCreepList)
	for _, creep in pairs(hCreepList)
	do
		if J.IsValid(creep) and J.CanBeAttacked(creep)
		then
			local nAttackDelayTime = J.GetAttackProDelayTime(bot, creep)
			if J.WillKillTarget(creep, bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL, nAttackDelayTime)
			or not (J.IsLaning( bot ) or J.IsInLaningPhase())
			then
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

return X