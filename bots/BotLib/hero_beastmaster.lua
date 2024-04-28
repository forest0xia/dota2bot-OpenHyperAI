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
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,2,1,1,6,1,2,2,4,6,4,4,4,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

local sCrimsonPipe = RandomInt(1, 2) == 1 and "item_crimson_guard" or "item_pipe"

tOutFitList['outfit_carry'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = {
    "item_tango",
    "item_double_branches",
    "item_circlet",
    "item_circlet",

    "item_magic_wand",
    "item_ring_of_basilius",
    "item_arcane_boots",
    "item_helm_of_the_overlord",--
    "item_black_king_bar",--
    "item_blink",
    "item_aghanims_shard",
    sCrimsonPipe,--
    "item_refresher",--
    "item_overwhelming_blink",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
    "item_circlet",
    "item_magic_wand",
    "item_arcane_boots",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )
	Minion.MinionThink(hMinionUnit)
end

local WildAxes          = bot:GetAbilityByName('beastmaster_wild_axes')
local CallOfTheWildBoar = bot:GetAbilityByName('beastmaster_call_of_the_wild_boar')
local CallOfTheWildHawk = bot:GetAbilityByName('beastmaster_call_of_the_wild_hawk')
-- local InnerBeast        = bot:GetAbilityByName('beastmaster_inner_beast')
-- local DrumsOfSlom        = bot:GetAbilityByName('beastmaster_drums_of_slom')
local PrimalRoar        = bot:GetAbilityByName('beastmaster_primal_roar')

local WildAxesDesire, WildAxesLocation
local CallOfTheWildBoarDesire
local CallOfTheWildHawkDesire
local PrimalRoarDesire, PrimalRoarTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    or bot:IsInvisible()
    then
        return
    end

    PrimalRoarDesire, PrimalRoarTarget = X.ConsiderPrimalRoar()
    if PrimalRoarDesire > 0
    then
        bot:Action_UseAbilityOnEntity(PrimalRoar, PrimalRoarTarget)
        return
    end

    CallOfTheWildBoarDesire = X.ConsiderCallOfTheWildBoar()
    if CallOfTheWildBoarDesire > 0
    then
        bot:Action_UseAbility(CallOfTheWildBoar)
        return
    end

    CallOfTheWildHawkDesire = X.ConsiderCallOfTheWildHawk()
    if CallOfTheWildHawkDesire > 0
    then
        bot:Action_UseAbility(CallOfTheWildHawk)
        return
    end

    WildAxesDesire, WildAxesLocation = X.ConsiderWildAxes()
    if WildAxesDesire > 0
    then
        bot:Action_UseAbilityOnLocation(WildAxes, WildAxesLocation)
        return
    end
end

function X.ConsiderWildAxes()
    if not WildAxes:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = WildAxes:GetCastRange()
    local nCastPoint = WildAxes:GetCastPoint()
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local nRadius = WildAxes:GetSpecialValueInt('radius')
    local nDamage = WildAxes:GetSpecialValueInt('axe_damage')
    local botTarget = J.GetProperTarget(bot)

    if J.IsValidTarget(botTarget)
    and J.CanCastOnNonMagicImmune(botTarget)
    and J.IsInRange(botTarget, bot, nCastRange)
    and J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_MAGICAL)
    then
        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(botTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, botTarget:GetExtrapolatedLocation(nCastPoint)
		end
	end

    if J.IsInTeamFight(bot, nCastRange)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if nLocationAoE.count >= 2
        then
			local botTeamFightTarget = J.GetVulnerableUnitNearLoc(bot, true, true, nCastRange, nRadius, nLocationAoE.targetloc)

			if botTeamFightTarget ~= nil
            then
				return BOT_ACTION_DESIRE_HIGH, botTeamFightTarget:GetLocation()
			end
		end
	end

    if J.IsRetreating(bot)
	then
		local botWeakestTarget = J.GetVulnerableWeakestUnit(bot, true, true, nCastRange - nRadius)

		if botWeakestTarget ~= nil
        and bot:WasRecentlyDamagedByHero(botWeakestTarget, 2.0)
        and J.CanCastOnNonMagicImmune(botWeakestTarget)
        and J.IsInRange(bot, botWeakestTarget, nCastRange)
        then
			return BOT_ACTION_DESIRE_HIGH, botWeakestTarget:GetLocation()
		end
	end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    and nMana > 0.5
	then
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nLocationAoEE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

        if nLocationAoEE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoEE.targetloc
        end

		if nLocationAoE.count >= 3
        then
			local botPushDefTarget = J.GetVulnerableUnitNearLoc(bot, false, true, nCastRange, nRadius, nLocationAoE.targetloc)

			if botPushDefTarget ~= nil then
				return BOT_ACTION_DESIRE_HIGH, botPushDefTarget:GetLocation()
			end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        local botAttackTarget = bot:GetAttackTarget()

        if J.IsRoshan(botAttackTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        then
            return BOT_ACTION_DESIRE_HIGH, botAttackTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderCallOfTheWildBoar()
	if not CallOfTheWildBoar:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE
	end

    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
    and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

		if nEnemyHeroes ~=nil and #nEnemyHeroes > 0
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot)
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)

		if nLaneCreeps ~=nil and #nLaneCreeps > 0
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsFarming(bot)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1000)

		if nNeutralCreeps ~=nil and #nNeutralCreeps > 0
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCallOfTheWildHawk()
    if not CallOfTheWildHawk:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE
	end

    local nEnemyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsInTeamFight(bot, 1200)
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsRetreating(bot)
    and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		if nEnemyHeroes ~=nil and #nEnemyHeroes >= 1
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderPrimalRoar()
	if not PrimalRoar:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, PrimalRoar:GetCastRange())
    local nDuration = PrimalRoar:GetSpecialValueInt('duration')

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes) do
        if enemyHero:IsChanneling()
        or J.IsCastingUltimateAbility(enemyHero)
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

	if J.IsRetreating(bot)
    and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local botWeakestTarget = J.GetVulnerableWeakestUnit(bot, true, true, nCastRange)

		if J.IsValidTarget(botWeakestTarget)
        and J.IsInRange(bot, botWeakestTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botWeakestTarget)
        then
			return BOT_ACTION_DESIRE_HIGH, botWeakestTarget
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local botStrongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

		if J.IsValidTarget(botStrongestTarget)
        and J.IsInRange(bot, botStrongestTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botStrongestTarget)
        and J.GetHP(botStrongestTarget) > 0.45
        then
			return BOT_ACTION_DESIRE_HIGH, botStrongestTarget
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = bot:GetTarget()

		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and J.GetHP(botTarget) > 0.45
		then
            if J.IsCore(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            else
                return BOT_ACTION_DESIRE_LOW, botTarget
            end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

return X