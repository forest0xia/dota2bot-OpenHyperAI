local bot
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local HoofStomp
local DoubleEdge
local WorkHorse
local HitchARide
local Stampede

local botTarget

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

    if abilityName == 'centaur_mount'
    then
        HitchARide = ability
        HitchARideDesire, HitchARideTarget = X.ConsiderHitchARide()
        if HitchARideDesire > 0
        then
            bot:Action_UseAbilityOnEntity(HitchARide, HitchARideTarget)
            return
        end
    end

    if abilityName == 'centaur_work_horse'
    then
        WorkHorse = ability
        WorkHorseDesire, HitchARideTarget = X.ConsiderWorkHorse()
        if WorkHorseDesire > 0
        then
            bot:Action_UseAbility(WorkHorse)
            return
        end
    end

    if abilityName == 'centaur_stampede'
    then
        Stampede = ability
        StampedeDesire = X.ConsiderStampede()
        if StampedeDesire > 0
        then
            bot:Action_UseAbility(Stampede)
            return
        end
    end

    if abilityName == 'centaur_hoof_stomp'
    then
        HoofStomp = ability
        HoofStompDesire = X.ConsiderHoofStomp()
        if HoofStompDesire > 0
        then
            bot:Action_UseAbility(HoofStomp)
            return
        end
    end

    if abilityName == 'centaur_double_edge'
    then
        DoubleEdge = ability
        DoubleEdgeDesire, DoubleEdgeTarget = X.ConsiderDoubleEdge()
        if DoubleEdgeDesire > 0
        then
            bot:Action_UseAbilityOnEntity(DoubleEdge, DoubleEdgeTarget)
            return
        end
    end
end

function X.ConsiderHoofStomp()
    if not HoofStomp:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = HoofStomp:GetSpecialValueInt('radius')
	local nDamage = HoofStomp:GetSpecialValueInt('stomp_damage')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 100)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if  Stampede:IsTrained()
                and Stampede:IsFullyCastable()
                then
                    if bot:GetMana() - HoofStomp:GetManaCost() > Stampede:GetManaCost()
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                else
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (bot:WasRecentlyDamagedByAnyHero(1.5)))
            then
		        return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        and not J.IsDisabled(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDoubleEdge()
	if not DoubleEdge:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, 0
	end

    local nStrength = bot:GetAttributeValue(ATTRIBUTE_STRENGTH)
	local nCastRange = J.GetProperCastRange(false, bot, DoubleEdge:GetCastRange())
    local nAttackRange = bot:GetAttackRange()
    local nStrengthDamageMul = DoubleEdge:GetSpecialValueInt("strength_damage") / 100
	local nDamage = DoubleEdge:GetSpecialValueInt("edge_damage") + (nStrength * nStrengthDamageMul)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + nAttackRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and bot:GetHealth() > nDamage * 1.2
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange * 2)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and bot:GetHealth() > nDamage * 1.5
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
		end
	end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange * 2, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        and J.IsAttacking(bot)
        and bot:GetHealth() > nDamage * 1.5
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.5
        and J.GetHP(nEnemyLaneCreeps[1]) > 0.33
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
        end
    end

    if J.IsFarming(bot)
    then
        if  J.IsAttacking(bot)
        and J.GetHP(bot) > 0.3
        and bot:GetHealth() > nDamage * 1.5
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.3
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange * 2)
            if  nNeutralCreeps ~= nil and #nNeutralCreeps >= 1
            and J.GetHP(nNeutralCreeps[1]) > 0.33
            then
                return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange * 2, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and J.CanBeAttacked(nEnemyLaneCreeps[1])
            and J.GetHP(nEnemyLaneCreeps[1]) > 0.33
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
            end
        end
    end

    if J.IsLaning(bot)
	then
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange * 2, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			-- if  J.IsValid(creep)
			-- and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			-- and creep:GetHealth() <= nDamage
			-- then
			-- 	local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

			-- 	if  nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
            --     and J.CanBeAttacked(creep)
            --     and J.GetHP(bot) > 0.3
            --     and bot:GetHealth() > nDamage * 1.5
            --     and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.3
			-- 	then
			-- 		return BOT_ACTION_DESIRE_HIGH, creep
			-- 	end
			-- end

            if  J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                canKill = canKill + 1
                table.insert(creepList, creep)
            end
		end

        if  canKill >= 2
        and J.CanBeAttacked(creepList[1])
        and J.GetHP(bot) > 0.3
        and bot:GetHealth() > nDamage * 1.5
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.3
        then
            return BOT_ACTION_DESIRE_HIGH, creepList[1]
        end

        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange + 75)
        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.IsValidTarget(nInRangeEnemy[1])
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.65
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
        end
	end

    if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange * 2)
        and J.IsAttacking(bot)
        and bot:GetHealth() > nDamage * 1.5
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange * 2)
        and J.IsAttacking(bot)
        and bot:GetHealth() > nDamage * 1.5
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.45
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderStampede()
	if not Stampede:IsFullyCastable()
    or bot:HasModifier('modifier_centaur_cart')
    or bot:HasModifier('modifier_centaur_stampede')
    then
		return BOT_ACTION_DESIRE_NONE
	end

    if J.IsInTeamFight(bot, 1200)
	then
        local nTeamFightLocation = J.GetTeamFightLocation(bot)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and nTeamFightLocation ~= nil
        then
            if J.GetLocationToLocationDistance(bot:GetLocation(), nTeamFightLocation) < 600
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and #nTargetInRangeAlly > #nInRangeAlly
            and #nTargetInRangeAlly >= 2
            and #nInRangeAlly <= 1
            and J.GetHP(bot) < 0.5
            then
		        return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderWorkHorse()
    if not WorkHorse:IsTrained()
    or not WorkHorse:IsFullyCastable()
    or bot:HasModifier('modifier_centaur_stampede')
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    if J.IsInTeamFight(bot, 1200)
	then
        local nTeamFightLocation = J.GetTeamFightLocation(bot)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and nTeamFightLocation ~= nil
        then
            if J.GetLocationToLocationDistance(bot:GetLocation(), nTeamFightLocation) < 600
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and #nTargetInRangeAlly > #nInRangeAlly
            and #nTargetInRangeAlly >= 2
            and #nInRangeAlly <= 1
            and J.GetHP(bot) < 0.5
            then
		        return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderHitchARide()
    if HitchARide:IsHidden()
    or not HitchARide:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, HitchARide:GetCastRange())

    if J.IsGoingOnSomeone(bot)
    or J.IsInTeamFight(bot, 1200)
    then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if  J.IsValidHero(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.1)
            and J.GetHP(allyHero) < 0.5
            and not allyHero:IsIllusion()
            and not allyHero:HasModifier('modifier_arc_warden_tempest_double')
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if  J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.1)
            and not allyHero:IsIllusion()
            and not allyHero:HasModifier('modifier_arc_warden_tempest_double')
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X