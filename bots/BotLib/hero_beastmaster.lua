local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

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

local sRoleItemsBuyList = {}

local sCrimsonPipe = RandomInt(1, 2) == 1 and "item_crimson_guard" or "item_pipe"

sRoleItemsBuyList['pos_1'] = {
	"item_bristleback_outfit",
	"item_heavens_halberd",--
	"item_black_king_bar",--
    "item_blink",
	"item_travel_boots",
	"item_abyssal_blade",--
	"item_aghanims_shard",
	"item_overwhelming_blink",--
    "item_refresher",--
	"item_moon_shard",
    "item_ultimate_scepter_2",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = {
	"item_tank_outfit",
    sCrimsonPipe,--
	"item_aghanims_shard",
	"item_heavens_halberd",
	"item_blink",
	"item_travel_boots",
	"item_assault",--
	"item_heart",--
	"item_overwhelming_blink",--
	"item_moon_shard",
    "item_ultimate_scepter_2",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_power_treads",
	"item_quelling_blade",

	"item_assault",
	"item_magic_wand",
	
	"item_abyssal_blade",
	
	"item_ancient_janggo",
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

local BlackKingBar

local Blink
local BlinkLocation

local BlinkRoarDesire, BlinkRoarTarget

if bot.shouldBlink == nil then bot.shouldBlink = false end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    BlinkRoarDesire, BlinkRoarTarget = X.ConsiderBlinkRoar()
    if BlinkRoarDesire > 0
    then
        bot:Action_ClearActions(false)

        if CanBKB()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
            bot:ActionQueue_Delay(0.1)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbilityOnEntity(PrimalRoar, BlinkRoarTarget)
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

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
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
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
        end
    end

    if J.IsInTeamFight(bot, nCastRange)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if nLocationAoE.count >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
            if  realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end
		end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.57 and bot:WasRecentlyDamagedByAnyHero(2.7)))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetExtrapolatedLocation(nCastPoint)
            end
        end
    end

    if (J.IsPushing(bot) or J.IsDefending(bot))
	then
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

        if nLocationAoE.count >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end

        nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
		if nLocationAoE.count >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

    if J.IsFarming(bot)
    then
        local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(800, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), 800, nRadius, 0, 0)

        if J.IsAttacking(bot)
        then
            if  nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 3
            and nLocationAoE.count >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end

            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(600)
            if  nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
                or (#nNeutralCreeps >= 2 and nLocationAoE.count >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            and nMana > 0.27
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    if J.IsLaning(bot)
	then
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			-- if  J.IsValid(creep)
			-- and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			-- and creep:GetHealth() <= nDamage
			-- then
			-- 	local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

			-- 	if  nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
            --     and J.GetMP(bot) > 0.33
			-- 	then
			-- 		return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
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
        and J.GetMP(bot) > 0.25
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderCallOfTheWildBoar()
	if not CallOfTheWildBoar:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE
	end

    local nAttackRange = bot:GetAttackRange()
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 800)
        and not J.IsInRange(bot, botTarget, nAttackRange)
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if (J.IsPushing(bot) or J.IsDefending(bot))
	then
        if J.IsAttacking(bot)
        then
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(700, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            local nEnemyTowers = bot:GetNearbyTowers(700, true)
            if  nEnemyTowers ~= nil and #nEnemyTowers > 0
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if  J.IsFarming(bot)
    and J.GetMP(bot) > 0.33
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nAttackRange + 75)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nAttackRange + 75, true)

        if J.IsAttacking(bot)
        then
            if nNeutralCreeps ~= nil
                and (#nNeutralCreeps >= 3
                    or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
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

    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 500, 500, 0, 0)

        if nLocationAoE.count >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, 500)
            if  realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 450)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 800, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 450)
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.57 and bot:WasRecentlyDamagedByAnyHero(2.7)))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
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
    local nDamage = PrimalRoar:GetSpecialValueInt('damage')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and J.IsRunning(enemyHero)
            and bot:IsFacingLocation(enemyHero:GetLocation(), 30)
            and not enemyHero:IsFacingLocation(bot:GetLocation(), 30)
            and not WildAxes:IsFullyCastable()
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

	if J.IsInTeamFight(bot, 1200)
	then
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

        if strongestTarget == nil
        then
            strongestTarget = J.GetStrongestUnit(1199, bot, true, true, nDuration)
        end

        if  J.IsValidTarget(strongestTarget)
        and J.CanCastOnMagicImmune(strongestTarget)
        and J.CanCastOnTargetAdvanced(strongestTarget)
        and J.GetHP(strongestTarget) > 0.5
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.IsDisabled(strongestTarget)
        and not J.IsTaunted(strongestTarget)
        and not strongestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not strongestTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not strongestTarget:HasModifier('modifier_legion_commander_duel')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
			return BOT_ACTION_DESIRE_HIGH, strongestTarget
		end
	end

    if  J.IsGoingOnSomeone(bot)
    and not CanDoBlinkRoar()
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)

        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidTarget(enemyHero)
            and J.CanCastOnMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.GetHP(enemyHero) > 0.5
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not J.IsTaunted(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_legion_commander_duel')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 800, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBlinkRoar()
    if CanDoBlinkRoar()
    then
        local nDuration = PrimalRoar:GetSpecialValueInt('duration')

        if J.IsGoingOnSomeone(bot)
        then
            local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
            local strongestTarget = J.GetStrongestUnit(1199, bot, true, false, nDuration)

            if strongestTarget == nil
            then
                strongestTarget = J.GetStrongestUnit(1199, bot, true, true, nDuration)
            end

            if  J.IsValidTarget(strongestTarget)
            and J.CanCastOnNonMagicImmune(strongestTarget)
            and J.CanCastOnTargetAdvanced(strongestTarget)
            and J.IsInRange(bot, strongestTarget, 1199)
            and J.GetHP(strongestTarget) > 0.5
            and not J.IsSuspiciousIllusion(strongestTarget)
            and not J.IsDisabled(strongestTarget)
            and not J.IsTaunted(strongestTarget)
            and not strongestTarget:HasModifier('modifier_abaddon_borrowed_time')
            and not strongestTarget:HasModifier('modifier_dazzle_shallow_grave')
            and not strongestTarget:HasModifier('modifier_enigma_black_hole_pull')
            and not strongestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not strongestTarget:HasModifier('modifier_legion_commander_duel')
            and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nTargetInRangeAlly = J.GetNearbyHeroes(strongestTarget, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                then
                    bot.shouldBlink = true
                    BlinkLocation = strongestTarget:GetLocation()
                    return BOT_ACTION_DESIRE_HIGH, strongestTarget
                end
            end
        end
    end

    bot.shouldBlink = false
    return BOT_ACTION_DESIRE_NONE, nil
end

function CanDoBlinkRoar()
    if  PrimalRoar:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = PrimalRoar:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end

function HasBlink()
    local blink = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if  item ~= nil
        and (item:GetName() == "item_blink" or item:GetName() == "item_overwhelming_blink" or item:GetName() == "item_arcane_blink" or item:GetName() == "item_swift_blink")
        then
			blink = item
			break
		end
	end

    if  blink ~= nil
    and blink:IsFullyCastable()
	then
        Blink = blink
        return true
	end

    return false
end

function CanBKB()
    local bkb = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if  item ~= nil
        and item:GetName() == "item_black_king_bar"
        then
			bkb = item
			break
		end
	end

    if  bkb ~= nil
    and bkb:IsFullyCastable()
    and bot:GetMana() >= 75
	then
        BlackKingBar = bkb
        return true
	end

    return false
end

return X