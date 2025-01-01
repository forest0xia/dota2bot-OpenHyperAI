local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local botName = bot:GetUnitName()
local botTarget, nEnemyHeroes, nAllyHeroes, nEnemyTowers, nAllyTowers, nEnemyCreeps, nAllyCreeps, nAttackRange, nAttackDamage, timeToAttack, attackSpeed
local MaxTrackingDistance = 4000
local attackDeltaDistance = 600
local maxDesire = BOT_ACTION_DESIRE_ABSOLUTE

function X.OnStart() end
function X.OnEnd() end

function X.GetDesire()
    if not bot:IsAlive() or J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() or bot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end

	botTarget = bot:GetTarget()
	if J.IsAttacking(bot) then
		if not J.IsValid(botTarget)
		or not J.CanBeAttacked(botTarget)
		or not J.IsInRange(bot, botTarget, MaxTrackingDistance) then
			bot:SetTarget(nil)
			return BOT_ACTION_DESIRE_NONE
		end
	end

	-- if J.IsValid(botTarget) and botTarget:IsCreep() and J.IsAttacking(bot) then
	-- 	return bot:GetActiveModeDesire()
	-- end

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)
	nEnemyTowers = bot:GetNearbyTowers(900, true )
	nAllyTowers = bot:GetNearbyTowers(900, false )
	nEnemyCreeps = bot:GetNearbyLaneCreeps(700, true)
	nAllyCreeps = bot:GetNearbyLaneCreeps(700, false)
	nAttackRange = bot:GetAttackRange()
	nAttackDamage = bot:GetAttackDamage()

	-- Calculate the time until the attack lands
	local attackPoint = bot:GetAttackPoint() + 0.05
	attackSpeed = bot:GetAttackSpeed()
	timeToAttack = attackPoint -- / attackSpeed

	if (J.GetModifierTime(bot, "modifier_muerta_pierce_the_veil_buff") > 1
	or bot:HasModifier("modifier_marci_unleash"))
	and J.GetHP(bot) > 0.5
	and #nEnemyHeroes >= 1
	then
		return BOT_MODE_DESIRE_VERYHIGH * 1.1
	end

	if bot.isBear then
		local hero = J.Utils.GetLoneDruid(bot).hero
		botTarget = J.GetProperTarget(hero)
		if J.Utils.IsValidUnit(botTarget)
		and J.IsInRange(botTarget, bot, MaxTrackingDistance)
		then
			if bot:GetTarget() ~= botTarget then
				bot:SetTarget(botTarget)
			end
			return GetDesireBasedOnHp(botTarget)
		end
		local nInRangeAlly = J.GetAlliesNearLoc(hero:GetLocation(), 1200)
		local nInRangeEnemy = J.GetEnemiesNearLoc(hero:GetLocation(), 1600)

		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidHero(enemyHero)
			and GetUnitToUnitDistance(enemyHero, hero) < 1600
			and GetUnitToUnitDistance(enemyHero, bot) < 2500
			and (#nInRangeAlly + 1 >= #nInRangeEnemy)
			then
				if (enemyHero:GetAttackTarget() == hero or J.IsChasingTarget(enemyHero, hero))
				or hero:WasRecentlyDamagedByHero(enemyHero, 2.5)
				then
					if bot:GetTarget() ~= enemyHero then
						bot:SetTarget(enemyHero)
						return GetDesireBasedOnHp(enemyHero)
					end
				end
			end
		end
		if (#nEnemyHeroes <= #nAllyHeroes or J.WeAreStronger(bot, 1200))
		and J.IsValidHero(nEnemyHeroes[1])
		and J.IsInRange(nEnemyHeroes[1], bot, nAttackRange + 100)
		and #nEnemyTowers == 0
		and J.GetHP(bot) > 0.85
		and J.CanBeAttacked(nEnemyHeroes[1]) then
			if bot:GetTarget() ~= nEnemyHeroes[1] then
				bot:SetTarget(nEnemyHeroes[1])
				return GetDesireBasedOnHp(nEnemyHeroes[1])
			end
		end
	end

	-- going on killing a target
	if J.IsGoingOnSomeone(bot)
	then
		botTarget = J.GetProperTarget(bot)
		if J.IsValidHero(botTarget)
		and J.IsInRange(botTarget, bot, MaxTrackingDistance) then
			return GetDesireBasedOnHp(botTarget)
		end
	end

	if J.WeAreStronger(bot, 1200) and (#nEnemyCreeps > 0 or #nEnemyHeroes > 0) then
		botTarget = nEnemyHeroes[1]
		bot:SetTarget(nEnemyHeroes[1])
		return GetDesireBasedOnHp(nEnemyHeroes[1])
	end

	-- has an enemy hero nearby in attack range + some delta distance
	if (#nEnemyHeroes <= #nAllyHeroes or J.WeAreStronger(bot, 1200))
	and J.IsValidHero(nEnemyHeroes[1])
	and J.IsInRange(nEnemyHeroes[1], bot, nAttackRange + attackDeltaDistance)
	and J.CanBeAttacked(nEnemyHeroes[1]) then
		botTarget = nEnemyHeroes[1]
		bot:SetTarget(nEnemyHeroes[1])
		return GetDesireBasedOnHp(nEnemyHeroes[1])
	end

	-- check if any near allies are in or about to be in a fight.
	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and J.IsInRange(allyHero, bot, MaxTrackingDistance)
		-- and not J.IsInRange(allyHero, bot, 800)
		and not allyHero:IsIllusion()
		then
			local nEnemyHeroesNearAlly = J.GetNearbyHeroes(allyHero, 800, true)
			if #nEnemyHeroesNearAlly > 0
			and J.IsValidHero(nEnemyHeroesNearAlly[1])
			and not J.IsSuspiciousIllusion(nEnemyHeroesNearAlly[1]) then
				botTarget = nEnemyHeroesNearAlly[1]
				bot:SetTarget(nEnemyHeroesNearAlly[1])
				return GetDesireBasedOnHp(nEnemyHeroesNearAlly[1])
			end
		end
	end

	-- time to direct attack any creeps
	if #nEnemyCreeps > 0 then
		if J.IsInLaningPhase() then
			-- humble in laning.
			return BOT_ACTION_DESIRE_NONE
		end
		return GetDesireBasedOnHp(nil)
	end

	return BOT_ACTION_DESIRE_NONE
end

function GetDesireBasedOnHp(target)
	-- dont use attack mode on creeps in laning phase
	if J.IsInLaningPhase()
	and bot:GetTarget()
	and not bot:GetTarget():IsHero() then
		return BOT_ACTION_DESIRE_NONE
	end

	if J.Utils.IsValidUnit(target) then
		if J.IsValidHero(target) and J.GetModifierTime( target, "modifier_item_blade_mail_reflect" ) > 0.2
		and J.IsInRange(bot, target, bot:GetAttackRange())
		and ((#nEnemyHeroes == 1 and bot:GetHealth() - target:GetHealth() < 250)
			or (#nEnemyHeroes >=2 and bot:GetHealth() - target:GetHealth() < 400))
		then
			return BOT_ACTION_DESIRE_NONE
		end
	end

	-- check if can be hit by tower
	if #nEnemyTowers >= 1 then
		if bot:GetLevel() < 5
		and J.IsInRange(bot, nEnemyTowers[1], 750) then
			return BOT_ACTION_DESIRE_NONE
		end
	end

	-- if bot.isBear then
	-- 	maxDesire = maxDesire * 1.5
	-- end
	local clampedDesire = RemapValClamped(J.GetHP(bot), 0, 0.9, BOT_ACTION_DESIRE_NONE, maxDesire )

	return clampedDesire
end

function X.Think()
	-- has a target already
	botTarget = bot:GetTarget()
	if J.Utils.IsValidUnit(botTarget) and J.IsInRange(botTarget, bot, MaxTrackingDistance) then
		bot:Action_AttackUnit(botTarget, false)
		MoveAfterAttack(botTarget)
		return
	end

	botTarget = ChooseAndAttackEnemyHero(nEnemyHeroes)

	J.ConsiderTarget()
	botTarget = J.GetProperTarget(bot)
	-- if again no direct target, try hitting any unit
	if bot:GetTarget() == nil then
		if J.IsInLaningPhase() then
			local vLaneFront = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
			bot:ActionQueue_AttackMove(vLaneFront)
			return
		end

		local units = GetUnitList(UNIT_LIST_ENEMIES)
		for _, unit in pairs(units) do
			if J.Utils.IsValidUnit(unit)
			and GetUnitToUnitDistance(bot, unit) <= nAttackRange + attackDeltaDistance then
				bot:Action_AttackUnit(unit, false)
				MoveAfterAttack(unit)
				return
			end
		end
	else
		bot:Action_AttackUnit(botTarget, false)
		MoveAfterAttack(botTarget)
		return
	end
end

function ChooseAndAttackEnemyHero(hEnemyList)
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, nAttackRange + attackDeltaDistance, true, true )
	if nInAttackRangeWeakestEnemyHero ~= nil then
		bot:SetTarget(nInAttackRangeWeakestEnemyHero)
		bot:Action_AttackUnit(nInAttackRangeWeakestEnemyHero, false)
		MoveAfterAttack(nInAttackRangeWeakestEnemyHero)
		return nInAttackRangeWeakestEnemyHero
	end

    for _, enemyHero in pairs(hEnemyList)
    do
        if J.IsValidHero(enemyHero)
		and J.CanBeAttacked(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
        then
			if J.IsInRange(bot, enemyHero, nAttackRange + attackDeltaDistance)
			then
				bot:SetTarget(enemyHero)
				bot:Action_AttackUnit(enemyHero, false)
				MoveAfterAttack(enemyHero)
				return enemyHero
			end
        end
    end
	return nil
end

-- Improved attack-move function based on the situation
function MoveAfterAttack(target)
    -- if not J.IsValidHero(target) then return end

    -- local botHP = J.GetHP(bot)
    -- local targetHP = J.GetHP(target)

    -- if (botHP > targetHP and #nAllyHeroes >= #nEnemyHeroes)
    -- or J.WeAreStronger(bot, 1000) then
    --     -- Situation is good, move towards the enemy
    --     local targetPos = target:GetExtrapolatedLocation(1.0)
	-- 	bot:ActionQueue_Delay(timeToAttack + 0.2)
    --     bot:ActionQueue_MoveToLocation(targetPos)
    -- else
    --     -- Situation is bad, move away from the enemy
    --     local retreatPosition = J.Utils.GetOffsetLocationTowardsTargetLocation(bot:GetLocation(), J.GetTeamFountain(), 200) + RandomVector(100)
	-- 	bot:ActionQueue_Delay(timeToAttack + 0.2)
    --     bot:ActionQueue_MoveToLocation(retreatPosition)
    -- end
end

return X