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
    "item_ultimate_scepter_2",
    "item_refresher",--
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
	"item_tank_outfit",
    sCrimsonPipeLotus,--
	"item_aghanims_shard",
	"item_heavens_halberd",
	"item_black_king_bar",--
	"item_travel_boots",
	"item_assault",--
    "item_shivas_guard",--
    "item_ultimate_scepter_2",
	"item_refresher",--
	"item_moon_shard",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

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
        if ActionType ~= nil and bot.drunkenBrawlerState ~= nil
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
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius - 75, true, BOT_MODE_NONE)
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
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 75)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
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
        and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_brewmaster_cinder_brew')
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

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsFarming(bot)
    then
        if  J.IsAttacking(bot)
        and J.GetMP(bot) > 0.4
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
            if  nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsLaning(bot)
	then
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			-- if  J.IsValid(creep)
			-- and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			-- and creep:GetHealth() <= nDamage
			-- then
			-- 	local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

			-- 	if  nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
            --     and J.GetMP(bot) > 0.35
			-- 	then
			-- 		return BOT_ACTION_DESIRE_HIGH
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
        and J.GetMP(bot) > 0.33
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if J.IsInLaningPhase()
        then
            nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)
            if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
            and J.GetMP(bot) > 0.5
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
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

function X.ConsiderCinderBrew()
    if not CinderBrew:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nRadius = CinderBrew:GetSpecialValueInt('radius')
    local nCastRange = CinderBrew:GetCastRange()
    local nCastPoint = CinderBrew:GetCastPoint()
    local botTarget = J.GetProperTarget(bot)

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
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_brewmaster_cinder_brew')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_brewmaster_cinder_brew')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (bot:WasRecentlyDamagedByAnyHero(1.5)))
            then
		        return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
            end
        end
    end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
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
        if  J.IsAttacking(bot)
        and J.GetMP(bot) > 0.45
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
        end
    end

    if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
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

    local nAllyHeroes = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
    local botTarget = J.GetProperTarget(bot)

    if nAllyHeroes ~= nil and #nAllyHeroes == 0
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if  J.GetHP(bot) < 0.33
    and nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
    and nAllyHeroes ~= nil and #nAllyHeroes == 0
    then
        return BOT_ACTION_DESIRE_HIGH
    end

	if J.IsInTeamFight(bot, 1200)
	then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
			return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetCurrentVisionRange())
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsMeepoClone(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not J.IsLocationInChrono(botTarget:GetLocation())
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            -- and J.IsCore(botTarget)
            and not (#nInRangeAlly >= 2 and #nInRangeEnemy <= 1)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if J.IsRetreating(bot)
	then
		if  nEnemyHeroes ~= nil and nAllyHeroes ~= nil
        and #nEnemyHeroes >= 3 and #nAllyHeroes <= 1
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

return X