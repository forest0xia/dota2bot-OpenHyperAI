local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sOutfitType   = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
                        ['t25'] = {10, 0},
                        ['t20'] = {10, 0},
                        ['t15'] = {10, 0},
                        ['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
                        {1,2,2,1,2,6,2,1,1,3,3,6,3,3,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sUtility = {"item_crimson_guard", "item_pipe", "item_lotus_orb"}
local sCrimsonPipeLotus = sUtility[RandomInt(1, #sUtility)]

local tOutFitList = {}

tOutFitList['outfit_carry'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",
    "item_ring_of_protection",

    "item_helm_of_iron_will",
    "item_phase_boots",
    "item_magic_wand",
    "item_veil_of_discord",
    "item_blink",
    "item_eternal_shroud",--
    "item_shivas_guard",--
    sCrimsonPipeLotus,
    "item_aghanims_shard",
    "item_kaya_and_sange",--
    "item_heart",--
    "item_overwhelming_blink",--
    "item_travel_boots_2",--
    "item_moon_shard",
    "item_ultimate_scepter",
    "item_recipe_ultimate_scepter_2",
}

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
    "item_quelling_blade",
    "item_ring_of_protection",
    "item_helm_of_iron_will",
    "item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )
	Minion.MinionThink(hMinionUnit)
end

local HoofStomp     = bot:GetAbilityByName('centaur_hoof_stomp')
local DoubleEdge    = bot:GetAbilityByName('centaur_double_edge')
-- local Retaliate     = bot:GetAbilityByName('centaur_return')
local WorkHorse     = bot:GetAbilityByName('centaur_work_horse')
local HitchARide    = bot:GetAbilityByName('centaur_mount')
local Stampede      = bot:GetAbilityByName('centaur_stampede')

local HoofStompDesire
local DoubleEdgeDesire, DoubleEdgeTarget
local WorkHorseDesire, HitchARideTarget
local StampedeDesire

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    StampedeDesire = X.ConsiderStampede()
    if StampedeDesire > 0
    then
        bot:Action_UseAbility(Stampede)
        return
    end

    WorkHorseDesire, HitchARideTarget = X.ConsiderWorkHorse()
    if WorkHorseDesire > 0
    then
        if HitchARideTarget == nil
        then
            bot:Action_UseAbility(WorkHorse)
        else
            bot:Action_UseAbility(WorkHorse)
            if HitchARide:IsFullyCastable()
            then
                bot:Action_UseAbilityOnEntity(HitchARide, HitchARideTarget)
            end
        end

        return
    end

    HoofStompDesire = X.ConsiderHoofStomp()
    if HoofStompDesire > 0
    then
        bot:Action_UseAbility(HoofStomp)
        return
    end

    DoubleEdgeDesire, DoubleEdgeTarget = X.ConsiderDoubleEdge()
    if DoubleEdgeDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DoubleEdge, DoubleEdgeTarget)
        return
    end
end

function X.ConsiderHoofStomp()
    if not HoofStomp:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = HoofStomp:GetSpecialValueInt("radius")
	local nDamage = HoofStomp:GetSpecialValueInt("stomp_damage")
    local nWindUpTime = 0.5
    local botTarget = J.GetProperTarget(bot)
    local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if (enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero))
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nRadius - 50)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsValidTarget(botTarget)
    and J.CanCastOnNonMagicImmune(botTarget)
    and J.IsInRange(bot, botTarget, nRadius - 120)
    and J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_MAGICAL)
    then
        return BOT_ACTION_DESIRE_MODERATE
    end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 120)
        and not J.IsDisabled(botTarget)
		then
            if Stampede:IsTrained()
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

    if J.IsRetreating(bot)
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(enemyHero, 2.0 + nWindUpTime)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, botTarget, nRadius - 100)
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsDoingRoshan(bot)
	then
		local botAttackTarget = bot:GetAttackTarget()

		if J.IsRoshan(botAttackTarget)
        and J.CanCastOnMagicImmune(botAttackTarget)
        and J.IsInRange(bot, botAttackTarget, nRadius)
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
	local nCastRange = DoubleEdge:GetCastRange()
    local nAttackRange = bot:GetAttackRange()
    local nStrengthDamageMul = DoubleEdge:GetSpecialValueInt("strength_damage") / 100
	local nDamage = DoubleEdge:GetSpecialValueInt("edge_damage") + (nStrength * nStrengthDamageMul)
	local botTarget = J.GetProperTarget(bot)

	if J.IsValidTarget(botTarget)
    and J.CanCastOnNonMagicImmune(botTarget)
    and J.IsInRange(bot, botTarget, nCastRange + nAttackRange)
    and J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_MAGICAL)
    and bot:GetHealth() > nDamage * 1.2
	then
		return BOT_ACTION_DESIRE_HIGH, botTarget
	end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + nAttackRange)
        and not botTarget:HasModifier("modifier_abaddon_borrowed_time")
        and bot:GetHealth() > nDamage * 1.5
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsDoingRoshan(bot)
	then
		local botAttackTarget = bot:GetAttackTarget()

		if J.IsRoshan(botAttackTarget)
        and J.CanCastOnMagicImmune(botAttackTarget)
        and J.IsInRange(bot, botAttackTarget, nCastRange + nAttackRange)
        and bot:GetHealth() > nDamage * 1.5
		then
			return BOT_ACTION_DESIRE_HIGH, botAttackTarget
		end
	end

    if J.IsFarming(bot)
	then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange + nAttackRange)
		if nNeutralCreeps ~= nil and #nNeutralCreeps >= 1
        then
            if J.GetHP(bot) > 0.3
            and bot:GetHealth() > nDamage * 1.5
            and J.GetHP(nNeutralCreeps[1]) > 0.47
            then
                return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
            end
        end
	end

    if J.IsLaning(bot) or J.IsPushing(bot) or J.IsDefending(bot)
	then
        local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + nAttackRange, true)
		if nLaneCreeps ~= nil and #nLaneCreeps >= 1
        then
            if J.GetHP(bot) > 0.5
            and bot:GetHealth() > nDamage * 1.5
            and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.5
            and J.GetHP(nLaneCreeps[1]) > 0.47
            then
                if nDamage >= nLaneCreeps[1]:GetHealth()
                then
                    return BOT_ACTION_DESIRE_HIGH, nLaneCreeps[1]
                else
                    return BOT_ACTION_DESIRE_MODERATE, nLaneCreeps[1]
                end
            end
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

        if nTeamFightLocation ~= nil
        then
            if J.GetLocationToLocationDistance(bot:GetLocation(), nTeamFightLocation) < 600
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nEnemyHeroes = bot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
        local nAllyHeroes = bot:GetNearbyHeroes(700, false, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
        and nAllyHeroes ~= nil and #nAllyHeroes >= 1
        and J.IsValidTarget(nEnemyHeroes[1])
        and J.IsInRange(bot, nEnemyHeroes[1], bot:GetAttackRange() * 2)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(700, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
		then
            if not J.WeAreStronger(bot, 700)
            then
                return BOT_ACTION_DESIRE_LOW
            else
                return BOT_ACTION_DESIRE_VERYLOW
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

    local nCastRange = HitchARide:GetCastRange()

    if J.IsInTeamFight(bot, 1200)
	then
        local nTeamFightLocation = J.GetTeamFightLocation(bot)

        if nTeamFightLocation ~= nil
        then
            if J.GetLocationToLocationDistance(bot:GetLocation(), nTeamFightLocation) < 600
            then
                local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

                for _, allyHero in pairs(nAllyHeroes)
                do
                    if allyHero:WasRecentlyDamagedByAnyHero(1)
                    and J.GetHP(allyHero) < 0.5
                    then
                        return BOT_ACTION_DESIRE_HIGH, allyHero
                    end
                end

                return BOT_ACTION_DESIRE_HIGH, nil
            end
        end
	end

    if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(700, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
		then
            local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

            for _, allyHero in pairs(nAllyHeroes)
            do
                if allyHero:WasRecentlyDamagedByAnyHero(1)
                and J.GetHP(allyHero) < 0.33
                then
                    return BOT_ACTION_DESIRE_MODERATE, allyHero
                end
            end

            if not J.WeAreStronger(bot, 700)
            then
                return BOT_ACTION_DESIRE_LOW, nil
            else
                return BOT_ACTION_DESIRE_VERYLOW, nil
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X