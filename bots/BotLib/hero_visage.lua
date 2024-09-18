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
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,1,1,3,1,6,1,3,3,3,6,2,2,2,6},--pos2,3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

local sUtility = {"item_pipe", "item_crimson_guard"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_double_circlet",
    "item_enchanted_mango",

    "item_bottle",
    "item_double_bracer",
    "item_magic_wand",
    "item_boots",
    "item_vladmir",--
    "item_orchid",
    "item_ancient_janggo",
    "item_ultimate_scepter",
    "item_bloodthorn",--
    "item_boots_of_bearing",--
    "item_assault",--
    "item_black_king_bar",--
    "item_sheepstick",--
    "item_ultimate_scepter_2",
    "item_aghanims_shard",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_double_circlet",
    "item_enchanted_mango",

    "item_double_bracer",
    "item_magic_wand",
    "item_boots",
    "item_vladmir",--
    "item_orchid",
    "item_ancient_janggo",
    "item_ultimate_scepter",
    nUtility,--
    "item_boots_of_bearing",--
    "item_assault",--
    "item_black_king_bar",--
    "item_ultimate_scepter_2",
    "item_bloodthorn",--
    "item_aghanims_shard",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local GraveChill        = bot:GetAbilityByName('visage_grave_chill')
local SoulAssumption    = bot:GetAbilityByName('visage_soul_assumption')
local GravekeepersCloak = bot:GetAbilityByName('visage_gravekeepers_cloak')
local SilentAsTheGrave  = bot:GetAbilityByName('visage_silent_as_the_grave')
local SummonFamiliars   = bot:GetAbilityByName('visage_summon_familiars')

local GraveChillDesire, GraveChillTarget
local SoulAssumptionDesire, SoulAssumptionTarget
local GravekeepersCloakDesire
local SilentAsTheGraveDesire
local SummonFamiliarsDesire

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    GraveChillDesire, GraveChillTarget = X.ConsiderGraveChill()
    if GraveChillDesire > 0
    then
        bot:Action_UseAbilityOnEntity(GraveChill, GraveChillTarget)
        return
    end

    SoulAssumptionDesire, SoulAssumptionTarget = X.ConsiderSoulAssumption()
    if SoulAssumptionDesire > 0
    then
        bot:Action_UseAbilityOnEntity(SoulAssumption, SoulAssumptionTarget)
        return
    end

    GravekeepersCloakDesire = X.ConsiderGravekeepersCloak()
    if GravekeepersCloakDesire > 0
    then
        bot:Action_UseAbility(GravekeepersCloak)
        return
    end

    SilentAsTheGraveDesire = X.ConsiderSilentAsTheGrave()
    if SilentAsTheGraveDesire > 0
    then
        bot:Action_UseAbility(SilentAsTheGrave)
        return
    end

    -- Bugged. New facet in 7.36 modified the ability so Action_UseAbility only toggle the ability not using it, whoever there is no other api to cast this ability now.
    SummonFamiliarsDesire = X.ConsiderSummonFamiliars()
    if SummonFamiliarsDesire > 0
    then
        bot:Action_UseAbility(SummonFamiliars)
        return
    end
end

function X.ConsiderGraveChill()
    if not GraveChill:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, GraveChill:GetCastRange())

	if J.IsGoingOnSomeone(bot)
	then
        local target = nil
        local atkSpd = 0
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidTarget(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)
                local currAtkSpd = enemyHero:GetAttackSpeed()

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                and currAtkSpd > atkSpd
                then
                    atkSpd = currAtkSpd
                    target = enemyHero
                end
            end
        end

        if target ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, target
        end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
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
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSoulAssumption()
    if not SoulAssumption:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local Stacks = 0
	for i = 0, bot:NumModifiers()
	do
		if bot:GetModifierName(i) == 'modifier_visage_soul_assumption'
        then
			Stacks = bot:GetModifierStackCount(i)
			break
		end
	end

	local nCastRange = J.GetProperCastRange(false, bot, SoulAssumption:GetCastRange())
	local nStackLimit = SoulAssumption:GetSpecialValueInt('stack_limit')
	local nBaseDamage = SoulAssumption:GetSpecialValueInt('soul_base_damage')
	local nChargeDamage = SoulAssumption:GetSpecialValueInt('soul_charge_damage')
	local nTotalDamage = nBaseDamage + (Stacks * nChargeDamage)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nTotalDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
        local target = nil
        local hp = 20000
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidTarget(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            and Stacks == nStackLimit
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)
                local currHP = enemyHero:GetHealth()

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                and hp < currHP
                then
                    hp = currHP
                    target = enemyHero
                end
            end
        end

        if target ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, target
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and Stacks == nStackLimit
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and Stacks == nStackLimit
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderGravekeepersCloak()
    if GravekeepersCloak:IsPassive()
    or not GravekeepersCloak:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.GetHP(bot) < 0.49
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

local lastSummonCheckTime = 0
local deltaSummonCheckTime = 20
function X.ConsiderSummonFamiliars()
    if not SummonFamiliars:IsFullyCastable() or (DotaTime() - lastSummonCheckTime <= deltaSummonCheckTime)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    lastSummonCheckTime = DotaTime()
    local nFamiliarCount = SummonFamiliars:GetSpecialValueInt('familiar_count')
    local nCurrFamiliar = 0

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
        if string.find(unit:GetUnitName(), 'npc_dota_visage_familiar')
        then
			nCurrFamiliar = nCurrFamiliar + 1
		end
	end

	if nFamiliarCount > nCurrFamiliar
    then
		return BOT_ACTION_DESIRE_HIGH
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSilentAsTheGrave()
    if not SilentAsTheGrave:IsTrained()
    or not SilentAsTheGrave:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local roshanLoc = J.GetCurrentRoshanLocation()
    local tormentorLoc = J.GetTormentorLocation(GetTeam())

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 1200)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2.5))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if GetUnitToLocationDistance(bot, roshanLoc) > 3200
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if GetUnitToLocationDistance(bot, tormentorLoc) > 3200
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X