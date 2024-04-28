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
						{3,1,3,1,3,6,3,2,2,2,2,6,1,1,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['outfit_mid'] = {
    "item_tango",
    "item_double_branches",
    "item_mantle",
    "item_circlet",
    "item_faerie_fire",

    "item_bottle",
    "item_null_talisman",
    "item_arcane_boots",
    "item_magic_wand",
    "item_cyclone",
    "item_kaya_and_sange",--
    "item_eternal_shroud",--
    "item_shivas_guard",--
    "item_black_king_bar",--
    "item_aghanims_shard",
    "item_travel_boots",
    "item_wind_waker",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_tank'] = sRoleItemsBuyList['outfit_mid']

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_mid']

sRoleItemsBuyList['outfit_priest'] = sRoleItemsBuyList['outfit_mid']

sRoleItemsBuyList['outfit_mage'] = sRoleItemsBuyList['outfit_mid']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_bottle",
    "item_null_talisman",
    "item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end
end

local SplitEarth        = bot:GetAbilityByName('leshrac_split_earth')
local DiabolicEdict     = bot:GetAbilityByName('leshrac_diabolic_edict')
local LightningStorm    = bot:GetAbilityByName('leshrac_lightning_storm')
local Nihilism          = bot:GetAbilityByName('leshrac_greater_lightning_storm')
local PulseNova         = bot:GetAbilityByName('leshrac_pulse_nova')

local SplitEarthDesire, SplitEarthLocation
local DiabolicEdictDesire
local LightningStormDesire, LightningStormTarget
local NihilismDesire
local PulseNovaDesire

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    PulseNovaDesire = X.ConsiderPulseNova()
    if PulseNovaDesire > 0
    then
        bot:Action_UseAbility(PulseNova)
        return
    end

    LightningStormDesire, LightningStormTarget = X.ConsiderLightningStorm()
    if LightningStormDesire > 0
    then
        bot:Action_UseAbilityOnEntity(LightningStorm, LightningStormTarget)
        return
    end

    SplitEarthDesire, SplitEarthLocation = X.ConsiderSplitEarth()
    if SplitEarthDesire > 0
    then
        bot:Action_UseAbilityOnLocation(SplitEarth, SplitEarthLocation)
        return
    end

    DiabolicEdictDesire = X.ConsiderDiabolicEdict()
    if DiabolicEdictDesire > 0
    then
        bot:Action_UseAbility(DiabolicEdict)
        return
    end

    NihilismDesire = X.ConsiderNihilism()
    if NihilismDesire > 0
    then
        bot:Action_UseAbility(Nihilism)
        return
    end
end

function X.ConsiderSplitEarth()
    if not SplitEarth:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, SplitEarth:GetCastRange())
    local nCastPoint = SplitEarth:GetCastPoint()
    local nRadius = SplitEarth:GetSpecialValueInt('radius')
    local nDelay = SplitEarth:GetSpecialValueFloat('delay')
    local nDamage = SplitEarth:GetAbilityDamage()
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local nAbilityLevel = SplitEarth:GetLevel()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint)
            end
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nDelay, 0)

        if nLocationAoE.count >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange + 200, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay + nCastPoint)
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByAnyHero(2.5)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange - 100)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetExtrapolatedLocation(nDelay + nCastPoint)
        end
    end

    if J.IsFarming(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius / 1.5, nDelay + nCastPoint, 0)
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)

        if  nNeutralCreeps ~= nil
        and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
            or (#nNeutralCreeps >= 2
                and nNeutralCreeps[1]:IsAncientCreep()
                and nLocationAoE.count >= 2))
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nLocationAoE.count >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nDelay + nCastPoint, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nLocationAoE.count >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nDelay + nCastPoint, 0)
        if nLocationAoE.count >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if  J.IsLaning(bot)
    and nAbilityLevel >= 2
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

        if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        then
            local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius / 1.5, nDelay + nCastPoint, 0)
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and nLocationAoE.count >= 3
            and nMana > (SplitEarth:GetManaCost() / bot:GetMaxMana())
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        for _, creep in pairs(nEnemyLaneCreeps)
		do
            local lowHealthCreepCount = 0
            local creepList = {}

            if  J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                lowHealthCreepCount = lowHealthCreepCount + 1
                table.insert(creepList, creep)
            end

            if  lowHealthCreepCount >= 3
            and nMana > 0.39
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
            end
		end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2.1)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], 400)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_leshrac_lightning_storm_slow')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(nDelay + nCastPoint)
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderDiabolicEdict()
    if not DiabolicEdict:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = DiabolicEdict:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(nRadius + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nRadius + 200, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if  J.IsFarming(bot)
    and not bot:HasModifier('modifier_leshrac_pulse_nova')
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
        if  nNeutralCreeps ~= nil
        and ((#nNeutralCreeps >= 3)
            or (#nNeutralCreeps >= 2
                and nNeutralCreeps[1]:IsAncientCreep()))
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and not bot:HasModifier('modifier_leshrac_pulse_nova')
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        local nEnemyTowers = bot:GetNearbyTowers(nRadius, true)
        if nEnemyTowers ~= nil and #nEnemyTowers >= 1
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderLightningStorm()
    if not LightningStorm:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, LightningStorm:GetCastRange())
    local nDamage = LightningStorm:GetSpecialValueInt('damage')
    local nJumpDist = LightningStorm:GetSpecialValueInt('radius')
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    if J.IsInTeamFight(bot)
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        local weakestTarget = J.GetWeakestUnit(nInRangeEnemy)

        if weakestTarget ~= nil
        then
            local nWeakestNearbyAlly = weakestTarget:GetNearbyHeroes(nJumpDist, false, BOT_MODE_NONE)
            if nWeakestNearbyAlly ~= nil and #nWeakestNearbyAlly >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, weakestTarget
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange + 200, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and bot:IsFacingLocation(botTarget:GetLocation(), 30)
        and not botTarget:IsFacingLocation(bot:GetLocation(), 45)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.67 and bot:WasRecentlyDamagedByAnyHero(2.5)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange - 50)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
        end
    end

    if  J.IsFarming(bot)
    and nMana > 0.31
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
        if  nNeutralCreeps ~= nil
        and ((#nNeutralCreeps >= 3)
            or (#nNeutralCreeps >= 2
                and nNeutralCreeps[1]:IsAncientCreep()))
        then
            local nCreepNearbyAlly = nNeutralCreeps[1]:GetNearbyLaneCreeps(nJumpDist, false)
            if nCreepNearbyAlly ~= nil and #nCreepNearbyAlly >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
            end
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        then
            local nCreepNearbyAlly = nEnemyLaneCreeps[1]:GetNearbyLaneCreeps(nJumpDist, false)
            if nCreepNearbyAlly ~= nil and #nCreepNearbyAlly >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
            end
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            local nCreepNearbyAlly = nEnemyLaneCreeps[1]:GetNearbyLaneCreeps(nJumpDist, false)
            if nCreepNearbyAlly ~= nil and #nCreepNearbyAlly >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
            end
        end
    end

    if  J.IsLaning(bot)
    and nMana > 0.21
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)
        if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        then
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            then
                local nCreepNearbyAlly = nEnemyLaneCreeps[1]:GetNearbyLaneCreeps(nJumpDist, false)
                if nCreepNearbyAlly ~= nil and #nCreepNearbyAlly >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
                end
            end
        end

		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
			then
				nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

				if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
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
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2.1)
        and not allyHero:IsIllusion()
        and nMana > 0.21
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], nJumpDist)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderPulseNova()
    if not PulseNova:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = PulseNova:GetSpecialValueInt('radius')
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
	then
		local nInRangeEnemy = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

        if  (nMana < 0.3 or nInRangeEnemy ~= nil and #nInRangeEnemy == 0)
        and bot:HasModifier('modifier_leshrac_pulse_nova')
        then
            return BOT_ACTION_DESIRE_HIGH
        end

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nRadius + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nRadius + 200, true, BOT_MODE_NONE)

        if  (nMana < 0.3 or nInRangeEnemy ~= nil and #nInRangeEnemy == 0)
        and bot:HasModifier('modifier_leshrac_pulse_nova')
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius + 125)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if  (nMana < 0.29 or (nNeutralCreeps ~= nil and #nNeutralCreeps == 0))
        and bot:HasModifier('modifier_leshrac_pulse_nova')
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if  nNeutralCreeps ~= nil
        and ((#nNeutralCreeps >= 3)
            or (#nNeutralCreeps >= 2
                and nNeutralCreeps[1]:IsAncientCreep()))
        and not bot:HasModifier('modifier_leshrac_diabolic_edict')
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if  (nMana < 0.29 or (nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps == 0))
        and bot:HasModifier('modifier_leshrac_pulse_nova')
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and not bot:HasModifier('modifier_leshrac_diabolic_edict')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if  (nMana < 0.31 or nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps == 0)
        and bot:HasModifier('modifier_leshrac_pulse_nova')
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and not bot:HasModifier('modifier_leshrac_diabolic_edict')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if  J.IsRetreating(bot)
    and bot:HasModifier('modifier_leshrac_pulse_nova')
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderNihilism()
    if not Nihilism:IsTrained()
    or not Nihilism:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = Nihilism:GetSpecialValueInt('radius')

    if  J.IsWithoutTarget(bot)
    and J.GetAttackProjectileDamageByRange(bot, 1200) >= bot:GetHealth()
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsRetreating( bot )
	then
		local nInRangeEnemy = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if  bot:WasRecentlyDamagedByAnyHero(2.2)
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

return X