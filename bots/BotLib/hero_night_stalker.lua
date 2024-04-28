local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,1,3,3,3,6,2,2,2,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sUtility = {"item_pipe", "item_lotus_orb", "item_heavens_halberd", "item_crimson_guard"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mid'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_tank'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",
    "item_double_gauntlets",

    "item_double_bracer",
    "item_phase_boots",
    "item_magic_wand",
    "item_echo_sabre",
    "item_blink",
    "item_aghanims_shard",
    "item_black_king_bar",--
    nUtility,--
    "item_basher",
    "item_assault",--
    "item_abyssal_blade",--
    "item_travel_boots",
    "item_overwhelming_blink",--
    "item_travel_boots_2",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['outfit_priest'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mage'] = sRoleItemsBuyList['outfit_carry']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_quelling_blade",
    "item_bracer",
    "item_magic_wand",
    "item_echo_sabre",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Void              = bot:GetAbilityByName('night_stalker_void')
local CripplingFear     = bot:GetAbilityByName('night_stalker_crippling_fear')
local HunterInTheNight  = bot:GetAbilityByName('night_stalker_hunter_in_the_night')
local DarkAscension     = bot:GetAbilityByName('night_stalker_darkness')

local VoidDesire, VoidTarget
local CripplingFearDesire
local HunterInTheNightDesire, HunterInTheNightTarget
local DarkAscensionDesire

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    DarkAscensionDesire = X.ConsiderDarkAscension()
    if DarkAscensionDesire > 0
    then
        bot:Action_UseAbility(DarkAscension)
        return
    end

    CripplingFearDesire = X.ConsiderCripplingFear()
    if CripplingFearDesire > 0
    then
        bot:Action_UseAbility(CripplingFear)
        return
    end

    VoidDesire, VoidTarget = X.ConsiderVoid()
    if VoidDesire > 0
    then
        if bot:HasScepter()
        then
            bot:Action_UseAbilityOnLocation(Void, VoidTarget)
        else
            bot:Action_UseAbilityOnEntity(Void, VoidTarget)
        end

        return
    end

    HunterInTheNightDesire, HunterInTheNightTarget = X.ConsiderHunterInTheNight()
    if HunterInTheNightDesire > 0
    then
        bot:Action_UseAbilityOnEntity(HunterInTheNight, HunterInTheNightTarget)
        return
    end
end

function X.ConsiderVoid()
    if not Void:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = Void:GetCastRange()
    local nCastPoint = Void:GetCastPoint()
    local nRadius = 450
    local nDamage = Void:GetSpecialValueInt('damage')
    local nDuration = Void:GetSpecialValueFloat('duration_day')
    local timeOfDay = J.CheckTimeOfDay()
    local botTarget = J.GetProperTarget(bot)

    if timeOfDay == 'night'
    then
        nDuration = Void:GetSpecialValueFloat('duration_night')
    end

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if  enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            and timeOfDay == 'night'
            then
                if bot:HasScepter()
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                else
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                if bot:HasScepter()
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
                else
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

	if J.IsInTeamFight(bot, 1200)
	then
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

        if bot:HasScepter()
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        else
            if strongestTarget == nil
            then
                strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, true, nDuration)
            end

            if  J.IsValidTarget(strongestTarget)
            and J.CanCastOnNonMagicImmune(strongestTarget)
            and not J.IsSuspiciousIllusion(strongestTarget)
            and not J.IsDisabled(strongestTarget)
            and not J.IsTaunted(strongestTarget)
            and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, strongestTarget
            end
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                if  bot:HasScepter()
                and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
                and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not botTarget:HasModifier('modifier_legion_commander_duel')
                and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
                else
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                end
            end
        end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(800, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.52 and bot:WasRecentlyDamagedByAnyHero(2)))
            then
                if bot:HasScepter()
                then
                    return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetExtrapolatedLocation(nCastPoint)
                else
                    return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
                end
            end
        end
    end

    if J.IsLaning(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
			then
				local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

				if  nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
                and J.GetMP(bot) > 0.33
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            if bot:HasScepter()
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            else
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            if bot:HasScepter()
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            else
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2.1)
        and not allyHero:IsIllusion()
        and J.GetMP(bot) > 0.5
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], 400)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsRunning(allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            then
                if bot:HasScepter()
                then
                    return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetLocation()
                else
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderCripplingFear()
    if not CripplingFear:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = CripplingFear:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
	then
        local realEnemyCount = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius * 2)

        if realEnemyCount ~= nil and #realEnemyCount >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius + 150)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        then
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if  J.IsAttacking(bot)
        and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if  J.IsFarming(bot)
    and J.GetMP(bot) > 0.25
    then
        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
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

function X.ConsiderHunterInTheNight()
    if HunterInTheNight:IsPassive()
    or not HunterInTheNight:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = HunterInTheNight:GetSpecialValueInt('shard_cast_range')
    local timeOfDay = J.CheckTimeOfDay()

    if J.IsFarming(bot)
    then
        local nCreeps = bot:GetNearbyCreeps(nCastRange, true)
        if nCreeps ~= nil and #nCreeps >= 1
        then
            if  J.IsValid(nCreeps[1])
            and (not nCreeps[1]:IsAncientCreep()
                or (timeOfDay == 'night' and nCreeps[1]:IsAncientCreep()))
            and (J.GetHP(bot) < 0.65 or J.GetMP(bot) < 0.5)
            then
                return BOT_ACTION_DESIRE_HIGH, nCreeps[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDarkAscension()
    if not DarkAscension:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
    then
        local realEnemyCount = J.GetEnemiesNearLoc(bot:GetLocation(), 1000)

        if realEnemyCount ~= nil and #realEnemyCount >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 600)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_legion_commander_duel')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X