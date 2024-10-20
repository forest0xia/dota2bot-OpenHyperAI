local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

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

local sUtility = {"item_crimson_guard", "item_pipe"} --, "item_lotus_orb"}
local sCrimsonPipeLotus = sUtility[RandomInt(1, #sUtility)]

sRoleItemsBuyList['pos_1'] = {
	"item_bristleback_outfit",
    "item_hand_of_midas",
    "item_radiance",--
	"item_heavens_halberd",--
	"item_black_king_bar",--
	"item_travel_boots",
	"item_abyssal_blade",--
	"item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_heart",--
	"item_moon_shard",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_magic_wand",
    "item_double_bracer",
    "item_boots",
    "item_hand_of_midas",
    "item_radiance",--
    "item_aghanims_shard",
    "item_travel_boots",
    "item_black_king_bar",--
    sCrimsonPipeLotus,--
    "item_octarine_core",--
    "item_ultimate_scepter_2",
    "item_refresher",--
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_magic_wand",
    "item_double_bracer",
    "item_boots",
    "item_radiance",--
    "item_pipe",--
    "item_black_king_bar",--
    sCrimsonPipeLotus,--
    "item_aghanims_shard",
    "item_travel_boots",
    "item_shivas_guard",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_4'] = {
	'item_priest_outfit',
	"item_hand_of_midas",
	"item_mekansm",
	"item_glimmer_cape",--
	"item_guardian_greaves",--
    "item_aghanims_shard",
	"item_assault",--
	"item_heavens_halberd",--
    "item_shivas_guard",--
    "item_refresher",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
	'item_priest_outfit',
	"item_hand_of_midas",
	"item_mekansm",
	"item_glimmer_cape",--
	"item_pipe",--
    "item_aghanims_shard",
	"item_assault",--
	"item_heavens_halberd",--
    "item_shivas_guard",--
    "item_refresher",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_heavens_halberd",
	"item_quelling_blade",

	"item_abyssal_blade",
	"item_magic_wand",

	"item_assault",
	"item_ancient_janggo",
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
	if J.CanNotUseAbility(bot) then return end

    CinderBrewDesire, CinderBrewLocation = X.ConsiderCinderBrew()
    if CinderBrewDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(CinderBrew, CinderBrewLocation)
        return
    end

    ThunderClapDesire = X.ConsiderThunderClap()
    if ThunderClapDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbility(ThunderClap)
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
                    bot:ActionQueue_UseAbility(DrunkenBrawler)
                    bot.drunkenBrawlerState = bot.drunkenBrawlerState + 1
                    if bot.drunkenBrawlerState > 4 then bot.drunkenBrawlerState = 1 end
                end
                return
            end
        end
    end

    PrimalCompanionDesire = X.ConsiderPrimalCompanion()
    if PrimalCompanionDesire > 0
    then
        bot:Action_UseAbility(PrimalSplit)
        return
    end
end

function X.ConsiderThunderClap()
    if not J.CanCastAbility(ThunderClap)
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = ThunderClap:GetSpecialValueInt('radius')
    local nDamage = ThunderClap:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nRadius - 75)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 75)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
	then
        if J.IsValidHero(nEnemyHeroes[1])
        and bot:WasRecentlyDamagedByAnyHero(1.5)
        and J.IsInRange(bot, nEnemyHeroes[1], nRadius)
        and J.IsChasingTarget(nEnemyHeroes[1], bot)
        and not J.IsDisabled(nEnemyHeroes[1])
        and not nEnemyHeroes[1]:HasModifier('modifier_brewmaster_cinder_brew')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        and J.GetMP(bot) > 0.4
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
            if nNeutralCreeps ~= nil
            and J.IsValid(nNeutralCreeps[1])
            and ((#nNeutralCreeps >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and J.CanBeAttacked(nEnemyLaneCreeps[1])
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsLaning(bot)
	then
        local canKill = 0
        local creepList = {}

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if J.IsValid(creep)
            and J.CanBeAttacked(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
			then
				if J.IsValidHero(nEnemyHeroes[1])
                and GetUnitToUnitDistance(nEnemyHeroes[1], creep) < 500
                and J.GetMP(bot) > 0.35
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end

            if J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                canKill = canKill + 1
                table.insert(creepList, creep)
            end
		end

        if canKill >= 2
        and J.GetMP(bot) > 0.33
        and nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if J.IsInLaningPhase()
        then
            local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)
            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
            and J.GetManaAfter(ThunderClap:GetManaCost()) > 0.5
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
        and not botTarget:IsDisarmed()
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCinderBrew()
    if not J.CanCastAbility(CinderBrew)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nRadius = CinderBrew:GetSpecialValueInt('radius')
    local nCastRange = J.GetProperCastRange(false, bot, CinderBrew:GetCastRange())
    local nCastPoint = CinderBrew:GetCastPoint()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)

	if J.IsInTeamFight(bot, 1200)
	then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + nRadius)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_brewmaster_cinder_brew')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nTargetLoc = botTarget:GetLocation()
            if not J.IsInRange(bot, botTarget, nCastRange)
            then
                nTargetLoc = J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
            else
                if J.IsChasingTarget(bot, botTarget) then nTargetLoc = J.GetCorrectLoc(botTarget, nCastPoint) end
            end

            return BOT_ACTION_DESIRE_HIGH, nTargetLoc
		end
	end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
	then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if J.IsValidHero(enemyHero)
            and bot:WasRecentlyDamagedByHero(enemyHero, 2)
            and J.IsInRange(bot, enemyHero, nRadius)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:HasModifier('modifier_brewmaster_cinder_brew')
            then
                return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + enemyHero:GetLocation()) / 2
            end
        end
    end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        and not J.IsRunning(nEnemyLaneCreeps[1])
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end

        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        if nLocationAoE.count >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        and J.GetMP(bot) > 0.45
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(600)
            if nNeutralCreeps ~= nil
            and J.IsValid(nNeutralCreeps[1])
            and ((#nNeutralCreeps >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
            end

            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and J.CanBeAttacked(nEnemyLaneCreeps[1])
            and not J.IsRunning(nEnemyLaneCreeps[1])
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
        end
    end

    if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
        and not botTarget:IsInvulnerable()
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderDrunkenBrawler()
    if not J.CanCastAbility(DrunkenBrawler)
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
    and (bot:WasRecentlyDamagedByAnyHero(3))
    and not J.IsRealInvisible(bot)
    then
        return BOT_ACTION_DESIRE_HIGH, 'retreat'
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderPrimalCompanion()
    if not bot:HasScepter()
    or not J.CanCastAbility(PrimalCompanion)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local _, PrimalSplit = J.HasAbility(bot, 'brewmaster_primal_split')
    local nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
    local botTarget = J.GetProperTarget(bot)

    if PrimalSplit ~= nil and (PrimalSplit:IsFullyCastable() or PrimalSplit:GetCooldownTimeRemaining() < 5)
    then
        return BOT_ACTION_DESIRE_NONE
    end

	if J.IsInTeamFight(bot, 1200)
	then
        if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
        then
			return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and not botTarget:IsAttackImmune()
        and J.IsInRange(bot, botTarget, 600)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsMeepoClone(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not J.IsLocationInChrono(botTarget:GetLocation())
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderPrimalSplit()
    if not J.CanCastAbility(PrimalSplit)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
    local botTarget = J.GetProperTarget(bot)

    if nAllyHeroes ~= nil and #nAllyHeroes == 0
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.GetHP(bot) < 0.33
    and nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
    and nAllyHeroes ~= nil and #nAllyHeroes == 0
    then
        return BOT_ACTION_DESIRE_HIGH
    end

	if J.IsInTeamFight(bot, 1200)
	then
        if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
        then
			return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and not botTarget:IsAttackImmune()
        and J.IsInRange(bot, botTarget, 888)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsMeepoClone(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not J.IsLocationInChrono(botTarget:GetLocation())
		then
            if nAllyHeroes ~= nil and nEnemyHeroes ~= nil
            and (#nAllyHeroes >= #nEnemyHeroes or J.WeAreStronger(bot, 1200))
            and J.IsCore(botTarget)
            and not (#nAllyHeroes >= 2 and #nEnemyHeroes <= 1)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
	then
		if nEnemyHeroes ~= nil and nAllyHeroes ~= nil
        and #nEnemyHeroes >= 3 and #nAllyHeroes <= 1
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

return X