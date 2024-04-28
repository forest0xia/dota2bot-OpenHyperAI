local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,2,3,3,3,6,3,2,2,2,6,1,1,1,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

local sUtility = {"item_crimson_guard", "item_pipe", "item_lotus_orb"}
local sCrimsonPipeLotus = sUtility[RandomInt(1, #sUtility)]

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mid'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_tank'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_double_bracer",
    "item_boots",
    "item_magic_wand",
    "item_hand_of_midas",
    "item_radiance",--
    "item_aghanims_shard",
    "item_travel_boots",
    "item_black_king_bar",--
    sCrimsonPipeLotus,--
    "item_octarine_core",--
    "item_refresher",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_priest'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mage'] = sRoleItemsBuyList['outfit_carry']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_quelling_blade",
    "item_bracer",
    "item_magic_wand",
    "item_hand_of_midas",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local ThunderClap       = bot:GetAbilityByName('brewmaster_thunder_clap')
local CinderBrew        = bot:GetAbilityByName('brewmaster_cinder_brew')
local DrunkenBrawler    = bot:GetAbilityByName('brewmaster_drunken_brawler')
local PrimalCompanion   = bot:GetAbilityByName('brewmaster_primal_companion')
local PrimalSplit       = bot:GetAbilityByName('brewmaster_primal_split')

local ThunderClapDesire
local CinderBrewDesire, CinderBrewLocation
local DrunkenBrawlerDesire, ActionType
local PrimalCompanionDesire
local PrimalSplitDesire

if bot.drunkenBrawlerState == nil and DotaTime() < 0 then bot.drunkenBrawlerState = 1 end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    CinderBrewDesire, CinderBrewLocation = X.ConsiderCinderBrew()
    if CinderBrewDesire > 0
    then
        bot:Action_UseAbilityOnLocation(CinderBrew, CinderBrewLocation)
        return
    end

    ThunderClapDesire = X.ConsiderThunderClap()
    if ThunderClapDesire > 0
    then
        bot:Action_UseAbility(ThunderClap)
        return
    end

    PrimalSplitDesire = X.ConsiderPrimalSplit()
    if PrimalSplitDesire > 0
    then
        bot:Action_UseAbility(PrimalSplit)
        return
    end

    DrunkenBrawlerDesire, ActionType = X.ConsiderDrunkenBrawler()
    if DrunkenBrawlerDesire > 0
    and DotaTime() > 0
    then
        if ActionType ~= nil
        then
            local curr = bot.drunkenBrawlerState
            local state = 1
            local steps = 0

            if ActionType == 'engage'
            then
                if bot.drunkenBrawlerState == 4 then return end
                state = 4
            elseif ActionType == 'retreat'
            then
                if bot.drunkenBrawlerState == 2 then return end
                state = 2
            elseif ActionType == 'farming'
            then
                if bot.drunkenBrawlerState == 3 then return end
                state = 3
            elseif ActionType == 'weak'
            then
                if bot.drunkenBrawlerState == 1 then return end
                state = 1
            end

            steps = ((state - curr) + 4) % 4
            if steps > 0
            then
                for _ = 1, steps
                do
                    bot:Action_UseAbility(DrunkenBrawler)
                    bot.drunkenBrawlerState = bot.drunkenBrawlerState + 1
                    if bot.drunkenBrawlerState > 4 then bot.drunkenBrawlerState = 1 end
                end
                return
            end
        end
    end
end

function X.ConsiderThunderClap()
    if not ThunderClap:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = ThunderClap:GetSpecialValueInt('radius')
    local nDamage = ThunderClap:GetSpecialValueInt('damage')
    local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    if J.IsValidTarget(botTarget)
    and J.CanCastOnNonMagicImmune(botTarget)
    and J.IsInRange(bot, botTarget, nRadius - 100)
    and J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_MAGICAL)
    then
        return BOT_ACTION_DESIRE_ABSOLUTE
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 100)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(enemyHero, 2.0)
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
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsPushing(bot)
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

		if nLaneCreeps ~= nil and #nLaneCreeps >= 4
        and nMana > 0.65
        then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

    if J.IsFarming(bot)
	then
		local nNeutralCreps = bot:GetNearbyNeutralCreeps(nRadius)

		if nNeutralCreps ~= nil and #nNeutralCreps >= 3
        and nMana > 0.65
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCinderBrew()
    if not CinderBrew:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nRadius = CinderBrew:GetSpecialValueInt('radius')
    local nCastRange = CinderBrew:GetCastRange()
    local nCastPoint = CinderBrew:GetCastPoint()
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not botTarget:HasModifier('modifier_brewmaster_cinder_brew')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
        end
	end

	if J.IsRetreating(bot)
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(enemyHero, 2.0)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and not enemyHero:HasModifier('modifier_brewmaster_cinder_brew')
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
			end
		end
	end

	if J.IsDoingRoshan(bot)
	then
		local botAttackTarget = bot:GetAttackTarget()

		if J.IsRoshan(botAttackTarget)
        and J.CanCastOnMagicImmune(botAttackTarget)
        and J.IsInRange(bot, botAttackTarget, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, botAttackTarget:GetLocation()
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

        if nLocationAoE.count >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsFarming(bot)
	then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
		local nNeutralCreps = bot:GetNearbyNeutralCreeps(nRadius)

		if nNeutralCreps ~= nil and #nNeutralCreps >= 3
        and nLocationAoE.count >= 3
        and nMana > 0.65
        then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderDrunkenBrawler()
    if not DrunkenBrawler:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    if J.GetHP(bot) < 0.33
    then
        return BOT_ACTION_DESIRE_HIGH, 'weak'
    end

    if J.IsGoingOnSomeone(bot)
    then
        return BOT_ACTION_DESIRE_HIGH, 'engage'
    end

    if J.IsLaning(bot) or J.IsFarming(bot)
    then
        return BOT_ACTION_DESIRE_HIGH, 'farming'
    end

    if J.IsRetreating(bot)
    or not J.WeAreStronger(bot, 1200)
    then
        return BOT_ACTION_DESIRE_HIGH, 'retreat'
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderPrimalSplit()
    if not PrimalSplit:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nAllyHeroes = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
    local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

    if nAllyHeroes ~= nil and #nAllyHeroes == 0
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.GetHP(bot) < 0.33
    and nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
    and nAllyHeroes ~= nil and #nAllyHeroes == 0
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 800)
		then
			local nTargetAllyHeroes = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

			if nTargetAllyHeroes ~= nil and nAllyHeroes ~= nil
            and #nTargetAllyHeroes >= 1 and #nAllyHeroes >= 1
            then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

    if J.IsRetreating(bot)
	then
		if nEnemyHeroes ~= nil and nAllyHeroes ~= nil
        and #nEnemyHeroes >= 1
        and #nAllyHeroes <= 1
        then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

    if J.IsInTeamFight(bot, 1200)
	then
		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
		then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

return X