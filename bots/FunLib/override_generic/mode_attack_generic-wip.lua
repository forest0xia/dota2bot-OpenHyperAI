local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local botTarget, nEnemyHeroes, nAllyHeroes, nEnemyTowers, nEnemyCreeps, nAllyCreeps, nAttackRange
local MaxTrackingDistance = 3000
local attackDeltaDistance = 200

function X.OnStart() end
function X.OnEnd() end

function X.GetDesire()
    if not bot:IsAlive() or J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() or bot:IsDisarmed() then
        return BOT_ACTION_DESIRE_NONE
    end

    if bot:GetActiveMode() == BOT_MODE_ATTACK then
        botTarget = bot:GetTarget()
        if not J.IsValidHero(botTarget)
        or not J.CanBeAttacked(botTarget)
        or not J.IsInRange(bot, botTarget, MaxTrackingDistance)
        or bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE then
            bot:SetTarget(nil)
            return BOT_ACTION_DESIRE_NONE
        end
    end

    -- Update attack range
    nAttackRange = bot:GetAttackRange() + attackDeltaDistance

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)
    nEnemyTowers = bot:GetNearbyTowers(1000, true )
    nEnemyCreeps = bot:GetNearbyCreeps(1000, true)

    if J.GetModifierTime(bot, "modifier_muerta_pierce_the_veil") > 0.5 then
        return BOT_MODE_DESIRE_VERYHIGH
    end

    -- Going on killing a target
    if J.IsGoingOnSomeone(bot) then
        botTarget = J.GetProperTarget(bot)
        if J.IsValidHero(botTarget)
        and J.IsInRange(botTarget, bot, MaxTrackingDistance) then
            return GetDesireBasedOnHp(botTarget)
        end
    end

    if not J.IsInLaningPhase() then
        if J.WeAreStronger(bot, 1200) then
            bot:SetTarget(nEnemyHeroes[1])
            return GetDesireBasedOnHp(nEnemyHeroes[1])
        end

        -- Attack nearby enemy heroes
        if #nEnemyHeroes >= 1
        and J.IsValidHero(nEnemyHeroes[1])
        and J.IsInRange(nEnemyHeroes[1], bot, nAttackRange + attackDeltaDistance)
        and J.CanBeAttacked(nEnemyHeroes[1]) then
            bot:SetTarget(nEnemyHeroes[1])
            return GetDesireBasedOnHp(nEnemyHeroes[1])
        end

    end

    -- Assist nearby allies in combat
    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if J.IsValidHero(allyHero)
        and J.IsInRange(allyHero, bot, MaxTrackingDistance)
        and not allyHero:IsIllusion() then
            local nEnemyHeroesNearAlly = J.GetNearbyHeroes(allyHero, 800, true)
            if #nEnemyHeroesNearAlly > 0
            and J.IsValidHero(nEnemyHeroesNearAlly[1])
            and not J.IsSuspiciousIllusion(nEnemyHeroesNearAlly[1]) then
                bot:SetTarget(nEnemyHeroesNearAlly[1])
                return GetDesireBasedOnHp(nEnemyHeroesNearAlly[1])
            end
        end
    end

    -- Time to last hit creeps
    local lastHitDesire = LastHitCreeps()
    if lastHitDesire > 0 then
        return lastHitDesire
    end

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
    -- Avoid attacking if under heavy creep damage
    if target ~= nil
    and J.IsInLaningPhase()
    and bot:WasRecentlyDamagedByCreep(2)
    and #nEnemyCreeps >= 3
    and J.GetHP(bot) < J.GetHP(target) then
        return BOT_ACTION_DESIRE_NONE
    end

    -- Avoid attacking under enemy tower when low level
    if #nEnemyTowers >= 1 then
        if bot:GetLevel() < 5 then
            return BOT_ACTION_DESIRE_NONE
        end
    end
    return RemapValClamped(J.GetHP(bot), 0, 1, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_ABSOLUTE)
end

function X.Think()
    if bot.lastAttackFrameProcessTime == nil then bot.lastAttackFrameProcessTime = DotaTime() end
    if DotaTime() - bot.lastAttackFrameProcessTime < bot.frameProcessTime then return end
    bot.lastAttackFrameProcessTime = DotaTime()

    -- if J.Utils.HasActionTypeInQueue(bot, BOT_ACTION_TYPE_ATTACK) then return end

    -- if J.IsInLaningPhase() then
    --     if LastHitCreeps() then
    --         return
    --     end
    -- end

    -- Has a target already
    botTarget = J.GetProperTarget(bot)

    if J.Utils.IsValidUnit(botTarget) and J.IsInRange(botTarget, bot, MaxTrackingDistance) then
        local distance = GetUnitToUnitDistance(bot, botTarget)
        if distance <= nAttackRange then
            bot:ActionQueue_AttackUnit(botTarget, true)
            -- Improved attack-move behavior
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

    -- If again no direct target, try hitting any unit
    if botTarget == nil then
        -- Don't hit high HP creeps during laning phase in the lane.
        if J.IsInLaningPhase() then
            local vLaneFront = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
            if GetUnitToLocationDistance(bot, vLaneFront) < 700 then
                return
            end
        end

        local units = GetUnitList(UNIT_LIST_ENEMY_CREEPS)
        for _, unit in pairs(units) do
            if J.Utils.IsValidUnit(unit)
            and GetUnitToUnitDistance(bot, unit) <= nAttackRange then
                bot:ActionQueue_AttackUnit(unit, true)
                return
            end
        end
    end
end

function ChooseAndAttackEnemyHero(hEnemyList)
    local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit(bot, nAttackRange, true, true)
    if nInAttackRangeWeakestEnemyHero ~= nil then
        bot:SetTarget(nInAttackRangeWeakestEnemyHero)
        bot:ActionQueue_AttackUnit(nInAttackRangeWeakestEnemyHero, true)
        -- Improved attack-move behavior
        MoveAfterAttack(nInAttackRangeWeakestEnemyHero)
        return nInAttackRangeWeakestEnemyHero
    end

    for _, enemyHero in pairs(hEnemyList) do
        if J.IsValidHero(enemyHero)
        and J.CanBeAttacked(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero) then
            if J.IsInRange(bot, enemyHero, nAttackRange) then
                bot:SetTarget(enemyHero)
                bot:ActionQueue_AttackUnit(enemyHero, true)
                -- Improved attack-move behavior
                MoveAfterAttack(enemyHero)
                return enemyHero
            end
        end
    end
    return nil
end

function LastHitCreeps()
    nAllyCreeps = bot:GetNearbyCreeps(nAttackRange, false)
    nEnemyCreeps = bot:GetNearbyCreeps(nAttackRange, true)

    local hitCreep = GetBestLastHitCreep(nEnemyCreeps)
    if J.IsValid(hitCreep) then
        local nLanePartner = J.GetLanePartner(bot)
        if nLanePartner == nil
        or J.IsCore(bot)
        or (not J.IsCore(bot)
            and J.IsCore(nLanePartner)
            and (not nLanePartner:IsAlive()
                or not J.IsInRange(bot, nLanePartner, 800))) then
            bot:SetTarget(hitCreep)
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    local denyCreep = GetBestDenyCreep(nAllyCreeps)
    if J.IsValid(denyCreep) then
        bot:SetTarget(denyCreep)
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function GetBestLastHitCreep(hCreepList)
    local bestCreep = nil
    local minHealth = 10000
    for _, creep in pairs(hCreepList) do
        if J.IsValid(creep) and J.CanBeAttacked(creep) then
            -- Calculate the time until the attack lands
            local attackPoint = bot:GetAttackPoint()
            local distance = GetUnitToUnitDistance(bot, creep)
            local attackSpeed = bot:GetAttackSpeed()
            local timeToAttack = attackPoint / attackSpeed

            -- Determine if the bot is ranged
            if bot:GetAttackProjectileSpeed() > 0 then
                local projectileSpeed = bot:GetAttackProjectileSpeed()
                timeToAttack = timeToAttack + (distance / projectileSpeed)
            end

            -- Predict creep health at that time
            local predictedHealth = PredictCreepHealth(creep, timeToAttack)

            -- If we can kill the creep
            if predictedHealth <= bot:GetAttackDamage() then
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
        and J.CanBeAttacked(creep) then
            -- Calculate the time until the attack lands
            local attackPoint = bot:GetAttackPoint()
            local distance = GetUnitToUnitDistance(bot, creep)
            local attackSpeed = bot:GetAttackSpeed()
            local timeToAttack = attackPoint / attackSpeed

            -- Determine if the bot is ranged
            if bot:GetAttackProjectileSpeed() > 0 then
                local projectileSpeed = bot:GetAttackProjectileSpeed()
                timeToAttack = timeToAttack + (distance / projectileSpeed)
            end

            -- Predict creep health at that time
            local predictedHealth = PredictCreepHealth(creep, timeToAttack)

            -- If we can deny the creep
            if predictedHealth <= bot:GetAttackDamage() then
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
function PredictCreepHealth(creep, time)
    local currentHealth = creep:GetHealth()
    local damagePerSecond = GetCreepIncomingDamagePerSecond(creep)
    local predictedHealth = currentHealth - (damagePerSecond * time)
    return predictedHealth
end

-- Calculates the damage per second the creep is taking from allied units and projectiles
function GetCreepIncomingDamagePerSecond(creep)
    local totalDPS = 0

    local enemies = creep:GetNearbyLaneCreeps(800, true)
    local towers = creep:GetNearbyTowers(800, true)
    local heroes = creep:GetNearbyHeroes(800, true, BOT_MODE_NONE)

    -- Damage from allied creeps
    if enemies then
        for _, allyCreep in pairs(enemies) do
            if allyCreep:IsAlive() and allyCreep:GetAttackTarget() == creep then
                totalDPS = totalDPS + allyCreep:GetAttackDamage() / allyCreep:GetSecondsPerAttack()
            end
        end
    end

    -- Damage from allied towers
    if towers then
        for _, tower in pairs(towers) do
            if tower:IsAlive() and tower:GetAttackTarget() == creep then
                totalDPS = totalDPS + tower:GetAttackDamage() / tower:GetSecondsPerAttack()
            end
        end
    end

    -- Damage from allied heroes
    if heroes then
        for _, hero in pairs(heroes) do
            if hero:IsAlive() and hero:GetAttackTarget() == creep then
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
        local timeToHit = GetUnitToLocationDistance(creep, projectile.location) / projectile.moveSpeed
        if timeToHit <= 0.5 then -- Only consider projectiles that will hit soon
            totalDamage = totalDamage + projectile.damage
        end
    end
    return totalDamage
end

-- Improved attack-move function based on the situation
function MoveAfterAttack(target)
    if not J.IsValidHero(target) then return end

    local botHP = J.GetHP(bot)
    local targetHP = J.GetHP(target)

    if (botHP > targetHP and #nAllyHeroes >= #nEnemyHeroes)
    or J.WeAreStronger(bot, 1000) then
        -- Situation is good, move towards the enemy
        local targetPos = target:GetExtrapolatedLocation(1.0)
        bot:ActionQueue_MoveToLocation(targetPos)
    else
        -- Situation is bad, move away from the enemy
        local retreatPosition = J.Utils.GetOffsetLocationTowardsTargetLocation(bot:GetLocation(), J.GetTeamFountain(), 200) + RandomVector(100)
        bot:ActionQueue_MoveToLocation(retreatPosition)
    end
end

return X
