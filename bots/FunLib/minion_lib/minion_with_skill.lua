local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local U = require(GetScriptDirectory()..'/FunLib/minion_lib/utils')
local I = dofile(GetScriptDirectory()..'/FunLib/minion_lib/illusions')

local X = {}

X.ConsiderSpellUsage = {}

local bot

local botHP, botTarget
local thisMinionHP, nAllyHeroes, nEnemyHeroes

function X.Think(ownerBot, hMinionUnit)
    bot = ownerBot

	if U.CanNotUseAbility(hMinionUnit) then I.Think(bot, hMinionUnit) return end
	if hMinionUnit.abilities == nil then U.InitiateAbility(hMinionUnit) end
    if #hMinionUnit.abilities <= 0 then I.Think(bot, hMinionUnit) return end

	for i = 1, #hMinionUnit.abilities
	do
        local ability = hMinionUnit:GetAbilityByName(hMinionUnit.abilities[i]:GetName())
		if J.CanCastAbility(ability)
		then
            botTarget = J.GetProperTarget(bot)
            thisMinionHP = J.GetHP(hMinionUnit)
            nAllyHeroes = hMinionUnit:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
            nEnemyHeroes = hMinionUnit:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

            local considerFunc = X.ConsiderSpellUsage[ability:GetName()] or X.ConsiderSpellUsage['default']
            hMinionUnit.cast_desire, hMinionUnit.cast_target, hMinionUnit.cast_type = considerFunc(hMinionUnit, ability)
            if hMinionUnit.cast_desire > 0
            then
                if hMinionUnit.cast_type == 'unit'
                then
                    hMinionUnit:Action_UseAbilityOnEntity(ability, hMinionUnit.cast_target)
                    return
                elseif hMinionUnit.cast_type == 'point'
                then
                    hMinionUnit:Action_UseAbilityOnLocation(ability, hMinionUnit.cast_target)
                    return
                elseif hMinionUnit.cast_type == 'none'
                then
                    hMinionUnit:Action_UseAbility(ability)
                    return
                end
            end

            if J.CheckBitfieldFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
			then
                hMinionUnit.cast_desire, hMinionUnit.cast_target = X.ConsiderUnitTarget(hMinionUnit, ability)
                if hMinionUnit.cast_desire > 0
                then
                    hMinionUnit:Action_UseAbilityOnEntity(ability, hMinionUnit.cast_target)
                    return
                end
            end
		end
	end

    -- Attack, Move
    -- TODO: Personalize for select minions.
	I.Think(bot, hMinionUnit)
end

function X.ConsiderUnitTarget(hMinionUnit, ability)
	local nCastRange = ability:GetCastRange()

    -- break linken
    for _, enemyHero in pairs(nEnemyHeroes) do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(hMinionUnit, enemyHero, nCastRange)
        -- and (enemyHero:HasModifier('modifier_item_sphere_target') or enemyHero:HasModifier('modifier_mirror_shield_delay'))
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
        end
    end

	return BOT_ACTION_DESIRE_NONE, nil
end

-- Cast Spells

X.ConsiderSpellUsage['default'] = function (hMinionUnit, ability)
    print("[WARN] No function for the usage of ability: " .. ability:GetName() .. ', for unit owned by: ' .. bot:GetUnitName())
    return 0, nil, nil
end

-- Tornado
X.ConsiderSpellUsage['enraged_wildkin_tornado'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and not J.IsChasingTarget(bot, botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), 'point'
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Hurricane
X.ConsiderSpellUsage['enraged_wildkin_hurricane'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and not J.IsChasingTarget(bot, botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Thunder Clap
X.ConsiderSpellUsage['polar_furbolg_ursa_warrior_thunder_clap'] = function (hMinionUnit, ability)
    local nRadius = ability:GetSpecialValueInt('radius')

    for _, enemyHero in pairs(nEnemyHeroes) do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(hMinionUnit, enemyHero, nRadius)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nRadius, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, nil, 'none'
        end
    end

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nRadius)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            return BOT_ACTION_DESIRE_HIGH, nil, 'none'
        end
    end

    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
        for _, enemy in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.CanCastOnNonMagicImmune(enemy)
            and J.IsChasingTarget(enemy, bot)
            and J.IsInRange(hMinionUnit, enemy, nRadius)
            and not J.IsDisabled(enemy)
            then
                return BOT_ACTION_DESIRE_HIGH, nil, 'none'
            end
        end
    end

    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and not allyHero:IsIllusion()
        then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            if  J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(hMinionUnit, nAllyInRangeEnemy[1], nRadius)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nil, 'none'
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

X.ConsiderSpellUsage['ogre_bruiser_ogre_smash'] = function (hMinionUnit, ability)
    return BOT_ACTION_DESIRE_NONE, nil, ''
end

X.ConsiderSpellUsage['ogre_magi_frost_armor'] = function (hMinionUnit, ability)
    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Ensnare
X.ConsiderSpellUsage['dark_troll_warlord_ensnare'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()

    for _, enemyHero in pairs(nEnemyHeroes) do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.IsInRange(hMinionUnit, enemyHero, nCastRange)
        and (enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero))
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
        end
    end

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
        end
	end

    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
        for _, enemy in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.CanCastOnNonMagicImmune(enemy)
            and J.CanCastOnTargetAdvanced(enemy)
            and J.IsChasingTarget(enemy, bot)
            and J.IsInRange(hMinionUnit, enemy, nCastRange)
            and not J.IsDisabled(enemy)
            then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'unit'
            end
        end
    end

    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and not allyHero:IsIllusion()
        then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            if  J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(hMinionUnit, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1], 'unit'
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Raise Dead
X.ConsiderSpellUsage['dark_troll_warlord_raise_dead'] = function (hMinionUnit, ability)

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidTarget(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, 700)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            return BOT_ACTION_DESIRE_HIGH, nil, 'none'
        end
	end

    if J.IsPushing(bot) then
        if J.IsValidBuilding(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, 700)
        and J.CanBeAttacked(botTarget) then
            return BOT_ACTION_DESIRE_HIGH, nil, 'none'
        end
    end

    if J.IsDoingTormentor(bot) then
        if J.IsTormentor(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, 800)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, nil, 'none'
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Hurl Boulder
X.ConsiderSpellUsage['mud_golem_hurl_boulder'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()

    for _, enemyHero in pairs(nEnemyHeroes) do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.IsInRange(hMinionUnit, enemyHero, nCastRange)
        and (enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero))
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
        end
    end

    if J.IsGoingOnSomeone(bot) then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and J.IsChasingTarget(bot, botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
        end
    end

    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
        for _, enemy in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.CanCastOnNonMagicImmune(enemy)
            and J.CanCastOnTargetAdvanced(enemy)
            and J.IsChasingTarget(enemy, bot)
            and J.IsInRange(hMinionUnit, enemy, nCastRange)
            and not J.IsDisabled(enemy)
            then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'unit'
            end
        end
    end

    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and not allyHero:IsIllusion()
        then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            if  J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(hMinionUnit, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1], 'unit'
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Slam
X.ConsiderSpellUsage['big_thunder_lizard_slam'] = function (hMinionUnit, ability)
    local nRadius = ability:GetSpecialValueInt('radius')

    if J.IsGoingOnSomeone(bot) then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nRadius)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nInRangeEnemy = J.GetEnemiesNearLoc(hMinionUnit:GetLocation(), nRadius)
            if #nInRangeEnemy >= 1 then
                return BOT_ACTION_DESIRE_HIGH, nil, 'none'
            end
        end
    end

    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
        for _, enemy in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.CanCastOnNonMagicImmune(enemy)
            and J.IsChasingTarget(enemy, bot)
            and J.IsInRange(hMinionUnit, enemy, nRadius)
            and not J.IsDisabled(enemy)
            then
                return BOT_ACTION_DESIRE_HIGH, nil, 'none'
            end
        end
    end

    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and not allyHero:IsIllusion()
        then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            if  J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(hMinionUnit, nAllyInRangeEnemy[1], nRadius)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nil, 'none'
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Frenzy
X.ConsiderSpellUsage['big_thunder_lizard_frenzy'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()

    local target = nil
    local targetDamage = 0

    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and not allyHero:IsIllusion()
        and J.IsInRange(hMinionUnit, allyHero, nCastRange)
        then
            if J.IsGoingOnSomeone(allyHero)
            or (J.IsDoingRoshan(allyHero) and J.IsRoshan(allyHero:GetAttackTarget()) and J.IsAttacking(allyHero) and J.GetHP(allyHero:GetAttackTarget()) > 0.4)
            or (J.IsDoingTormentor(allyHero) and J.IsTormentor(allyHero:GetAttackTarget()) and J.IsAttacking(allyHero) and J.GetHP(allyHero:GetAttackTarget()) > 0.4)
            then
                local allyHeroDamage = allyHero:GetAttackDamage() * allyHero:GetAttackSpeed()
                if allyHeroDamage > targetDamage then
                    target = allyHero
                    targetDamage = allyHeroDamage
                end
            end
        end
    end

    if target ~= nil then
        return BOT_ACTION_DESIRE_HIGH, target, 'unit'
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Incendiary Bomb
X.ConsiderSpellUsage['ice_shaman_incendiary_bomb'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()

    if J.IsGoingOnSomeone(bot) then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and J.GetHP(botTarget) > 0.4
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
        end
    end

    if J.IsPushing(bot) then
        if J.IsValidBuilding(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, 700)
        and J.GetHP(botTarget) > 0.35
        and J.CanBeAttacked(botTarget) then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Fireball
X.ConsiderSpellUsage['black_dragon_fireball'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()
    local nRadius = ability:GetSpecialValueInt('radius')

    if J.IsGoingOnSomeone(bot) then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nLocationAoE = hMinionUnit:FindAoELocation(true, true, botTarget:GetLocation(), 0, nRadius, 0, 0)
            if nLocationAoE.count >= 1 then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, 'point'
            end
        end
    end

    local nLocationAoE = hMinionUnit:FindAoELocation(true, true, hMinionUnit:GetLocation(), nCastRange, nRadius, 0, 0)
    local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
    if #nInRangeEnemy >= 2 then
        return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, 'point'
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Seed Shot
X.ConsiderSpellUsage['warpine_raider_seed_shot'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()
    local nDamage = ability:GetSpecialValueInt('damage')
    local nBounceRange = ability:GetSpecialValueInt('bounce_range')

    for _, enemyHero in pairs(nEnemyHeroes) do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(hMinionUnit, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
        end
    end

    if J.IsGoingOnSomeone(bot) then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and J.IsChasingTarget(bot, botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nLocationAoE = hMinionUnit:FindAoELocation(true, true, botTarget:GetLocation(), 0, nBounceRange, 0, 0)
            if nLocationAoE.count >= 2 then
                return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
            end

            nLocationAoE = hMinionUnit:FindAoELocation(true, false, botTarget:GetLocation(), 0, nBounceRange, 0, 0)
            if nLocationAoE.count >= 2 then
                return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
            end
        end
    end

    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
        for _, enemy in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.CanCastOnNonMagicImmune(enemy)
            and J.CanCastOnTargetAdvanced(enemy)
            and J.IsChasingTarget(enemy, bot)
            and J.IsInRange(hMinionUnit, enemy, nCastRange)
            and not J.IsDisabled(enemy)
            then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'unit'
            end
        end
    end

    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and not allyHero:IsIllusion()
        then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            if  J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(hMinionUnit, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1], 'unit'
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Vex
X.ConsiderSpellUsage['fel_beast_haunt'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()

    if J.IsGoingOnSomeone(bot)
    and J.IsInRange(bot, hMinionUnit, 1600)
    then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
        end
    end

    if J.IsRetreating(bot)
    and J.IsInRange(bot, hMinionUnit, 1600)
    then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(hMinionUnit, enemyHero, nCastRange)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Take Off
X.ConsiderSpellUsage['harpy_scout_take_off'] = function (hMinionUnit, ability)
    if J.IsStuck(hMinionUnit)
    then
        if ability:GetToggleState() == false
        then
            return BOT_ACTION_DESIRE_HIGH, nil, 'none'
        else
            return BOT_ACTION_DESIRE_NONE, nil, 'none'
        end
    end

    if ability:GetToggleState() == true
    then
        return BOT_ACTION_DESIRE_HIGH, nil, 'none'
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Chain Lightning
X.ConsiderSpellUsage['harpy_storm_chain_lightning'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()
    local nDamage = ability:GetSpecialValueInt('initial_damage')
    local nJumpDist = ability:GetSpecialValueInt('jump_range')

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(hMinionUnit, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
        end
    end

    if J.IsGoingOnSomeone(bot)
    and J.IsInRange(bot, hMinionUnit, 1600)
    then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
        end
    end

    if J.IsRetreating(bot)
    and J.IsInRange(bot, hMinionUnit, 1600)
    then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(hMinionUnit, enemyHero, nCastRange)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsDisabled(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
            end
        end
    end

    if J.IsFarming(bot)
    and J.IsInRange(bot, hMinionUnit, 1600)
    then
        local nCreeps = bot:GetNearbyCreeps(1600, true)
        if  nCreeps ~= nil
        and ((#nCreeps >= 3)
            or (#nCreeps >= 2 and nCreeps[1]:IsAncientCreep()))
        and J.IsAttacking(bot)
        then
            for _, creep in pairs(nCreeps)
            do
                if  J.IsValid(creep)
                and J.CanBeAttacked(creep)
                then
                    local nCreepCountAround = J.GetNearbyAroundLocationUnitCount(true, false, nJumpDist, creep:GetLocation())
                    if nCreepCountAround >= 2
                    then
                        return BOT_ACTION_DESIRE_HIGH, creep, 'unit'
                    end
                end
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        -- Remove Spell Block
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit'
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Mana Burn
X.ConsiderSpellUsage['satyr_soulstealer_mana_burn'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()

    for _, enemyHero in pairs(nEnemyHeroes) do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(hMinionUnit, enemyHero, nCastRange + 300)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.GetMP(enemyHero) > 0.5
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Purge
X.ConsiderSpellUsage['satyr_trickster_purge'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()

    for _, ally in pairs(nAllyHeroes) do
        if J.IsValidHero(ally)
        and J.IsInRange(hMinionUnit, ally, nCastRange + 300)
        and not ally:IsIllusion()
        and J.IsDisabled(ally)
        then
            return BOT_ACTION_DESIRE_HIGH, ally, 'unit'
        end
    end

    for _, enemyHero in pairs(nEnemyHeroes) do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(hMinionUnit, enemyHero, nCastRange + 300)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        then
            if enemyHero:HasModifier('modifier_flask_healing')
            or enemyHero:HasModifier('modifier_clarity_potion')
            or enemyHero:HasModifier('modifier_item_pavise_shield')
            or enemyHero:HasModifier('modifier_item_solar_crest_armor_addition')
            or enemyHero:HasModifier('modifier_disperser_movespeed_buff')
            -- more
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Shockwave
X.ConsiderSpellUsage['satyr_hellcaller_shockwave'] = function (hMinionUnit, ability)
    local nCastRange = ability:GetCastRange()
    local nCastPoint = ability:GetCastPoint()
    local nSpeed = ability:GetSpecialValueInt('speed')
    local nDamage = ability:GetSpecialValueInt('#AbilityDamage')

    for _, enemyHero in pairs(nEnemyHeroes) do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(hMinionUnit, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local eta = (GetUnitToUnitDistance(hMinionUnit, enemyHero) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(hMinionUnit, eta), 'point'
        end
    end

    if J.IsGoingOnSomeone(bot) and J.IsInRange(bot, hMinionUnit, 1300) then
        local nLocationAoE = hMinionUnit:FindAoELocation(true, true, hMinionUnit:GetLocation(), nCastRange, 200, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, 200)
        if #nInRangeEnemy >= 1 then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, 'point'
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- Intimidate
X.ConsiderSpellUsage['giant_wolf_intimidate'] = function (hMinionUnit, ability)
    local nRadius = ability:GetSpecialValueInt('radius')

    if J.IsGoingOnSomeone(bot) then
        for _, enemyHero in pairs(nEnemyHeroes) do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(hMinionUnit, enemyHero, nRadius)
            and J.CanBeAttacked(enemyHero)
            and not J.IsChasingTarget(bot, enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nil, 'none'
            end
        end
    end

    local nInRangeEnemy = J.GetEnemiesNearLoc(hMinionUnit:GetLocation(), nRadius)
    if #nInRangeEnemy >= 2 then
        return BOT_ACTION_DESIRE_HIGH, nil, 'none'
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

-- War Stomp
X.ConsiderSpellUsage['centaur_khan_war_stomp'] = function (hMinionUnit, ability)
    local nRadius = ability:GetSpecialValueInt('radius')

    if J.IsGoingOnSomeone(bot) then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(hMinionUnit, botTarget, nRadius)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            return BOT_ACTION_DESIRE_HIGH, nil, 'none'
        end
    end

    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
        for _, enemy in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.CanCastOnNonMagicImmune(enemy)
            and J.IsChasingTarget(enemy, bot)
            and J.IsInRange(hMinionUnit, enemy, nRadius)
            and not J.IsDisabled(enemy)
            then
                return BOT_ACTION_DESIRE_HIGH, nil, 'none'
            end
        end
    end

    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and not J.IsRealInvisible(allyHero)
        and not allyHero:IsIllusion()
        then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            if  J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(hMinionUnit, nAllyInRangeEnemy[1], nRadius)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nil, 'none'
            end
        end
    end

    local nInRangeEnemy = J.GetEnemiesNearLoc(hMinionUnit:GetLocation(), nRadius)
    if #nInRangeEnemy >= 2 then
        return BOT_ACTION_DESIRE_HIGH, nil, 'none'
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

return X