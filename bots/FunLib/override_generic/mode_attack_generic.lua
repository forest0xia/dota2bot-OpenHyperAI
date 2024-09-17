local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local botName = bot:GetUnitName()
local botTarget, nEnemyHeroes, nAllyHeroes, nEnemyTowers, nAllyTowers, nEnemyCreeps, nAllyCreeps, nAttackRange, nAttackDamage, timeToAttack, attackSpeed
local MaxTrackingDistance = 3000
local attackDeltaDistance = 600

function X.OnStart() end
function X.OnEnd() end

function X.GetDesire()
    if not bot:IsAlive() or J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() or bot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end

	botTarget = bot:GetTarget()
	if bot:GetActiveMode() == BOT_MODE_ATTACK then
		if not J.IsValid(botTarget)
		or not J.CanBeAttacked(botTarget)
		or not J.IsInRange(bot, botTarget, MaxTrackingDistance) then
			bot:SetTarget(nil)
			return BOT_ACTION_DESIRE_NONE
		end
	end

	if J.IsValid(botTarget) and botTarget:IsCreep() and bot:GetActiveMode() == BOT_MODE_ATTACK then
		return bot:GetActiveModeDesire()
	end

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1200, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1200, false)
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

	if J.GetModifierTime(bot, "modifier_muerta_pierce_the_veil") > 0.5
	then
		return BOT_MODE_DESIRE_VERYHIGH
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
		bot:SetTarget(nEnemyHeroes[1])
		return GetDesireBasedOnHp(nEnemyHeroes[1])
	end

	-- has an enemy hero nearby in attack range + some delta distance
	if #nEnemyHeroes >= 1
	and J.IsValidHero(nEnemyHeroes[1])
	and J.IsInRange(nEnemyHeroes[1], bot, nAttackRange + attackDeltaDistance)
	and J.CanBeAttacked(nEnemyHeroes[1]) then
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
				bot:SetTarget(nEnemyHeroesNearAlly[1])
				return GetDesireBasedOnHp(nEnemyHeroesNearAlly[1])
			end
		end
	end

	-- time to direct attack any creeps
	if #nEnemyCreeps > 0 then
		if J.IsInLaningPhase() then
			if not J.IsCore(bot) and #nAllyHeroes > 1 then
				return BOT_ACTION_DESIRE_NONE
			end
		end
		return GetDesireBasedOnHp(nil)
	end

	return BOT_ACTION_DESIRE_NONE
end

function GetDesireBasedOnHp(target)
	-- check if can/already hit by creeps
	if target ~= nil
	and J.IsInLaningPhase()
	and bot:WasRecentlyDamagedByCreep(2)
	and #nEnemyCreeps >= 3
	and J.GetHP(bot) < J.GetHP(target) then
		return BOT_ACTION_DESIRE_NONE
	end

	-- check if can be hit by tower
	if #nEnemyTowers >= 1 then
		if bot:GetLevel() < 5 then
			return BOT_ACTION_DESIRE_NONE
		end
	end
	return RemapValClamped(J.GetHP(bot), 0, 1, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_ABSOLUTE )
end

function X.Think()
	-- try last hitting creeps
	if J.IsInLaningPhase() and LastHitCreeps() > 0 then
		return
	end

	-- has a target already
	botTarget = J.GetProperTarget(bot)
	if J.IsValidHero(botTarget) and J.IsInRange(botTarget, bot, MaxTrackingDistance) then
		local distance = GetUnitToUnitDistance(bot, botTarget)
		if distance <= nAttackRange + attackDeltaDistance then
			bot:Action_AttackUnit(botTarget, true)
            MoveAfterAttack(botTarget)
			return
		else
			bot:Action_MoveToUnit(botTarget)
			return
		end
	end

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)

	botTarget = ChooseAndAttackEnemyHero(nEnemyHeroes)

	-- if again no direct target, try hitting any unit
	if bot:GetTarget() == nil then
		-- don't hit high hp creeps during laning time in the lane.
		if J.IsInLaningPhase() then
			local vLaneFront = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
			if GetUnitToLocationDistance(bot, vLaneFront) < 700 then
				return
			end
		end

		local units = GetUnitList(UNIT_LIST_ENEMIES)
		for _, unit in pairs(units) do
			if J.Utils.IsValidUnit(unit)
			and GetUnitToUnitDistance(bot, unit) <= nAttackRange + attackDeltaDistance then
				bot:Action_AttackUnit(unit, true)
				MoveAfterAttack(botTarget)
				return
			end
		end
	end
end

function ChooseAndAttackEnemyHero(hEnemyList)
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, nAttackRange + attackDeltaDistance, true, true )
	if nInAttackRangeWeakestEnemyHero ~= nil then
		bot:SetTarget(nInAttackRangeWeakestEnemyHero)
		bot:Action_AttackUnit(nInAttackRangeWeakestEnemyHero, true)
		MoveAfterAttack(botTarget)
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
				bot:Action_AttackUnit(enemyHero, true)
				MoveAfterAttack(botTarget)
				return enemyHero
			end
        end
    end
	return nil
end

function LastHitCreeps()
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
			bot:Action_AttackUnit(hitCreep, false)
			return 1
		end
	end

	local denyCreep = GetBestDenyCreep(nAllyCreeps)
	if J.IsValid(denyCreep)
	then
		bot:SetTarget(denyCreep)
		bot:Action_AttackUnit(denyCreep, false)
		return 1
	end
	return 0
end


function GetBestLastHitCreep(hCreepList)
    local bestCreep = nil
    local minHealth = 10000
    for _, creep in pairs(hCreepList) do
        if J.IsValid(creep)
		and J.IsInRange(bot, creep, nAttackRange + attackDeltaDistance)
		and J.CanBeAttacked(creep) then
            local distance = GetUnitToUnitDistance(bot, creep)
            -- Determine if the bot is ranged
            if bot:GetAttackProjectileSpeed() > 0 then
                local projectileSpeed = bot:GetAttackProjectileSpeed()
                timeToAttack = timeToAttack + (distance / projectileSpeed)
            end

            -- Predict creep health at that time
            local predictedHealth = PredictCreepHealth(true, creep, timeToAttack)

            -- If we can kill the creep
            if predictedHealth <= nAttackDamage then
                if predictedHealth < minHealth then
                    minHealth = predictedHealth
                    bestCreep = creep
                end
            end
        end
    end
    return bestCreep
end

function GetBestDenyCreep(hCreepList)
    local bestCreep = nil
    local minHealth = 10000
    for _, creep in pairs(hCreepList) do
        if J.IsValid(creep)
        and J.GetHP(creep) < 0.49
		and J.IsInRange(bot, creep, nAttackRange + attackDeltaDistance)
        and J.CanBeAttacked(creep) then
            local distance = GetUnitToUnitDistance(bot, creep)
            -- Determine if the bot is ranged
            if bot:GetAttackProjectileSpeed() > 0 then
                local projectileSpeed = bot:GetAttackProjectileSpeed()
                timeToAttack = timeToAttack + (distance / projectileSpeed)
            end

            -- Predict creep health at that time
            local predictedHealth = PredictCreepHealth(false, creep, timeToAttack)

            -- If we can deny the creep
            if predictedHealth <= nAttackDamage then
                if predictedHealth < minHealth then
                    minHealth = predictedHealth
                    bestCreep = creep
                end
            end
        end
    end
    return bestCreep
end

-- Predicts the creep's health after a certain time, accounting for allied damage and incoming projectiles
function PredictCreepHealth(bEnemyCreep, creep, time)
    local currentHealth = creep:GetHealth()
    local damagePerSecond = GetCreepIncomingDamagePerSecond(bEnemyCreep, creep)
    local predictedHealth = currentHealth - (damagePerSecond * time)
    return predictedHealth
end

-- Calculates the damage per second the creep is taking from allied units and projectiles
function GetCreepIncomingDamagePerSecond(bEnemyCreep, creep)
    local totalDPS = 0

    local enemies = bEnemyCreep == true and nEnemyCreeps or nAllyCreeps
    local towers = bEnemyCreep == true and nEnemyTowers or nAllyTowers
    local heroes = bEnemyCreep == true and nEnemyHeroes or nAllyHeroes

    -- Damage from allied creeps
    if enemies then
        for _, allyCreep in pairs(enemies) do
            if J.Utils.IsValidUnit(allyCreep) and allyCreep:GetAttackTarget() == creep then
                totalDPS = totalDPS + allyCreep:GetAttackDamage() / allyCreep:GetSecondsPerAttack()
            end
        end
    end

    -- Damage from allied towers
    if towers then
        for _, tower in pairs(towers) do
            if J.Utils.IsValidUnit(tower) and tower:GetAttackTarget() == creep then
                totalDPS = totalDPS + tower:GetAttackDamage() / tower:GetSecondsPerAttack()
            end
        end
    end

    -- Damage from allied heroes
    if heroes then
        for _, hero in pairs(heroes) do
            if J.IsValidHero(hero) and hero:GetAttackTarget() == creep then
                totalDPS = totalDPS + hero:GetAttackDamage() / hero:GetSecondsPerAttack()
            end
        end
    end

    -- Damage from incoming projectiles
    totalDPS = totalDPS + GetIncomingProjectileDamage(creep)

    return totalDPS
end

-- Calculates the damage from incoming projectiles that will hit the creep before our attack lands
function GetIncomingProjectileDamage(creep)
    local totalDamage = 0
    local projectiles = creep:GetIncomingTrackingProjectiles()
    for _, projectile in pairs(projectiles) do
		if projectile.is_attack then
			projectile.moveSpeed = projectile.caster:GetAttackSpeed() -- assume a speed
			projectile.damage = projectile.caster:GetAttackDamage() -- assume a speed
			local timeToHit = GetUnitToLocationDistance(creep, projectile.location) / projectile.moveSpeed
			if timeToHit <= 0.5 then -- Only consider projectiles that will hit soon
				totalDamage = totalDamage + projectile.damage
			end
		end
    end
    return totalDamage
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