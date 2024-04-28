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
						{2,1,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mid'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_tank'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_priest'] = {
    "item_double_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_blood_grenade",

    "item_tranquil_boots",
    "item_magic_wand",
    "item_force_staff",--
    "item_solar_crest",--
    "item_glimmer_cape",--
    "item_boots_of_bearing",--
    "item_sheepstick",--
    "item_wind_waker",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_mage'] = {
    "item_double_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_blood_grenade",

    "item_arcane_boots",
    "item_magic_wand",
    "item_force_staff",--
    "item_solar_crest",--
    "item_glimmer_cape",--
    "item_guardian_greaves",--
    "item_sheepstick",--
    "item_wind_waker",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos4SellList = {
	"item_magic_wand",
}

Pos5SellList = {
	"item_magic_wand",
}

X['sSellList'] = {}

if sRole == "outfit_priest"
then
    X['sSellList'] = Pos4SellList
elseif sRole == "outfit_mage"
then
    X['sSellList'] = Pos5SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )
	if Minion.IsValidUnit( hMinionUnit )
	then
		if hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end
end

local ThunderStrike = bot:GetAbilityByName('disruptor_thunder_strike')
local Glimpse       = bot:GetAbilityByName('disruptor_glimpse')
local KineticField  = bot:GetAbilityByName('disruptor_kinetic_field')
local StaticStorm   = bot:GetAbilityByName('disruptor_static_storm')

local ThunderStrikeDesire, ThunderStrikeTarget
local GlimpseDesire, GlimpseTarget
local KineticFieldDesire, KineticFieldLocation
local StaticStormDesire, StaticStormLocation

local KineticStormDesire, KineticStormLocation

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    or bot:IsInvisible()
    then
        return
    end

    KineticStormDesire, KineticStormLocation = X.ConsiderKineticStorm()
    if KineticStormDesire > 0
    then
        bot:Action_ClearActions(false)
        bot:ActionQueue_UseAbilityOnLocation(StaticStorm, KineticStormLocation)
        bot:ActionQueue_UseAbilityOnLocation(KineticField, KineticStormLocation)
        return
    end

    ThunderStrikeDesire, ThunderStrikeTarget = X.ConsiderThunderStrike()
    if ThunderStrikeDesire > 0
    then
        bot:Action_UseAbilityOnEntity(ThunderStrike, ThunderStrikeTarget)
        return
    end

    GlimpseDesire, GlimpseTarget = X.ConsiderGlimpse()
    if GlimpseDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Glimpse, GlimpseTarget)
        return
    end

    KineticFieldDesire, KineticFieldLocation = X.ConsiderKineticField()
    if KineticFieldDesire > 0
    then
        bot:Action_UseAbilityOnLocation(KineticField, KineticFieldLocation)
        return
    end

    StaticStormDesire, StaticStormLocation = X.ConsiderStaticStorm()
    if StaticStormDesire > 0
    then
        bot:Action_UseAbilityOnLocation(StaticStorm, StaticStormLocation)
        return
    end
end

function X.ConsiderThunderStrike()
    if not ThunderStrike:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, ThunderStrike:GetCastRange())
    local nRadius = ThunderStrike:GetSpecialValueInt('radius')
	local nDamage = 4 * ThunderStrike:GetAbilityDamage()
    local nLevel = ThunderStrike:GetLevel()
	local botTarget = bot:GetTarget()

	if  J.IsValidTarget(botTarget)
    and J.CanCastOnNonMagicImmune(botTarget)
    and J.IsInRange(bot, botTarget, nCastRange + 200)
    and J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_MAGICAL)
    and not J.IsSuspiciousIllusion(botTarget)
    and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
	then
		return BOT_ACTION_DESIRE_HIGH, botTarget
	end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + 100)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		then
            return BOT_ACTION_DESIRE_MODERATE, botTarget
		end
	end

    if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        local nAllyHeroes = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)

		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if  J.IsValidHero(enemyHero)
            and bot:WasRecentlyDamagedByHero(enemyHero, 2.0)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
			then
                if  nAllyHeroes ~= nil
                and #nAllyHeroes < #nEnemyHeroes
                and #nEnemyHeroes >= 2
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
			end
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

        if  nLocationAoE.count >= 3
        and not J.IsThereCoreNearby(800)
        and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nLevel >= 3
        then
            return BOT_ACTION_DESIRE_MODERATE, nEnemyLaneCreeps[2]
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderGlimpse()
    if not Glimpse:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = Glimpse:GetCastRange()
	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if (enemyHero:IsChanneling()
		or (bot:GetActiveMode() == BOT_MODE_ATTACK
            and (nAllyHeroes ~= nil and #nAllyHeroes <= 3 and #nEnemyHeroes <= 2)
            and bot:IsFacingLocation(enemyHero:GetLocation(), 30)
            and enemyHero:IsFacingLocation(J.GetEnemyFountain(), 30)))
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
			return BOT_ACTION_DESIRE_HIGH, enemyHero
		end
	end

	if J.IsRetreating(bot)
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if  bot:WasRecentlyDamagedByHero(enemyHero, 2.0)
			and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsRealInvisible(bot)
			then
				return BOT_ACTION_DESIRE_MODERATE, enemyHero
			end
		end
	end

    for _, allyHero in pairs(nAllyHeroes)
    do
        if  J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        then
            if  nEnemyHeroes ~= nil
            and (#nEnemyHeroes >= 2 or (J.GetHP(allyHero) < 0.3 and #nEnemyHeroes == 1))
            and #nAllyHeroes <= 1
            and not J.IsSuspiciousIllusion(nEnemyHeroes[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderKineticField()
    if not KineticField:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nRadius = KineticField:GetSpecialValueInt( "radius" )
	local nCastRange = KineticField:GetCastRange()
	local nCastPoint = KineticField:GetCastPoint()

	if  J.IsInTeamFight(bot, 1200)
    and not CanCastKineticStorm()
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if nLocationAoE.count >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local botTarget = bot:GetTarget()
        local nAllyHeroes = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
        local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange + 100, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and bot:IsFacingLocation(botTarget:GetLocation(), 30)
        and botTarget:IsFacingLocation(J.GetEnemyFountain(), 30)
		then
            if  nAllyHeroes ~= nil and nEnemyHeroes ~= nil
            and #nAllyHeroes >= #nEnemyHeroes
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nAllyHeroes = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
		local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  bot:WasRecentlyDamagedByAnyHero(2.0)
        and (nEnemyHeroes ~= nil and nAllyHeroes ~= nil)
        and #nEnemyHeroes >= 2
        then
            return BOT_ACTION_DESIRE_MODERATE, bot:GetLocation()
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderStaticStorm()
	if not StaticStorm:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = StaticStorm:GetSpecialValueInt('radius')
	local nCastRange = StaticStorm:GetCastRange()

	if  J.IsInTeamFight(bot, 1200)
    and not CanCastKineticStorm()
	then
        local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius / 2, 0, 0)

		if nLocationAoE.count >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                local isChronod = false
                for _, enemyHero in pairs(nEnemyHeroes)
                do
                    if  J.IsValidHero(enemyHero)
                    and GetUnitToLocationDistance(enemyHero, nLocationAoE.targetloc) <= 150
                    and enemyHero:HasModifier('modifier_faceless_void_chronosphere')
                    and not J.IsSuspiciousIllusion(enemyHero)
                    then
                        isChronod = true
                        break
                    end
                end

                if not isChronod
                then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderKineticStorm()
    if CanCastKineticStorm()
    then
        local nRadius = KineticField:GetSpecialValueInt( "radius" )
	    local nCastRange = KineticField:GetCastRange()

        if J.IsInTeamFight(bot, 1200)
        then
            local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

            if nLocationAoE.count >= 2
            then
                local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

                if realEnemyCount ~= nil and #realEnemyCount >= 2
                then
                    local isChronod = false
                    for _, enemyHero in pairs(nEnemyHeroes)
                    do
                        if  J.IsValidHero(enemyHero)
                        and GetUnitToLocationDistance(enemyHero, nLocationAoE.targetloc) <= 150
                        and enemyHero:HasModifier('modifier_faceless_void_chronosphere')
                        and not J.IsSuspiciousIllusion(enemyHero)
                        then
                            isChronod = true
                            break
                        end
                    end

                    if not isChronod
                    then
                        return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function CanCastKineticStorm()
    if  KineticField:IsFullyCastable()
    and StaticStorm:IsFullyCastable()
    then
        local manaCost = KineticField:GetManaCost() + StaticStorm:GetManaCost()

        if bot:GetMana() >= manaCost
        then
            return true
        end
    end

    return false
end

return X