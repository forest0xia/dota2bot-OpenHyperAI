local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
    {--pos1
        ['t25'] = {10, 0},
        ['t20'] = {10, 0},
        ['t15'] = {10, 0},
        ['t10'] = {0, 10},
    },
    {--pos3
        ['t25'] = {10, 0},
        ['t20'] = {10, 0},
        ['t15'] = {10, 0},
        ['t10'] = {0, 10},
    }
}

local tAllAbilityBuildList = {
    {1,3,2,2,2,6,2,3,3,3,1,6,1,1,6},--pos1
    {1,3,3,2,3,6,3,2,2,2,6,1,1,1,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_1"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
else
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_faerie_fire",
    "item_branches",
    "item_branches",
    "item_quelling_blade",
    "item_circlet",

    "item_phase_boots",
    "item_magic_wand",
    "item_soul_ring",
    "item_echo_sabre",
    "item_basher",
    "item_greater_crit",--
    "item_black_king_bar",--
    "item_monkey_king_bar",--
    "item_abyssal_blade",--
    "item_satanic",--
    "item_ultimate_scepter",
    "item_moon_shard",
    "item_travel_boots",
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_3'] = {
	"item_tank_outfit",
	"item_crimson_guard",--
    "item_basher",
	"item_heavens_halberd",--
	"item_travel_boots",
    "item_monkey_king_bar",--
	"item_assault",--
	-- "item_sheepstick",--
	"item_aghanims_shard",
	"item_ultimate_scepter",
    "item_abyssal_blade",--
	"item_moon_shard",
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
	-- "item_octarine_core",--
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = {
	'item_priest_outfit',
	"item_hand_of_midas",
	"item_mekansm",
	"item_glimmer_cape",--
	"item_guardian_greaves",--
    "item_basher",
    "item_monkey_king_bar",--
	"item_assault",--
	"item_heavens_halberd",--
	"item_aghanims_shard",
    "item_abyssal_blade",--
	"item_ultimate_scepter",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_5'] = {
	'item_priest_outfit',
	"item_hand_of_midas",
	"item_mekansm",
	"item_glimmer_cape",--
	"item_pipe",--
    "item_basher",
    "item_monkey_king_bar",--
	"item_assault",--
	"item_heavens_halberd",--
	"item_aghanims_shard",
    "item_abyssal_blade",--
	"item_ultimate_scepter",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then
    X['sBuyList'], X['sSellList'] = { 'PvN_marci' }, {}
end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

    if Minion.IsValidUnit( hMinionUnit )
    then
        if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
        then
            Minion.IllusionThink( hMinionUnit )
        end
    end

end

local Dispose          = bot:GetAbilityByName( "marci_grapple" )
local Rebound          = bot:GetAbilityByName( "marci_companion_run" )
local Sidekick         = bot:GetAbilityByName( "marci_guardian" )
local Unleash          = bot:GetAbilityByName( "marci_unleash" )

local DisposeDesire, DisposeTaret
local ReboundDesire, ReboundTarget
local SidekickDesire, SidekickTarget
local UnleashDesire

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    DisposeDesire, DisposeTaret = X.ConsiderDispose()
    if DisposeDesire > 0
    then
        bot:Action_UseAbilityOnEntity( Dispose, DisposeTaret )
        return
    end

    ReboundDesire, ReboundTarget = X.ConsiderRebound()
    if ReboundDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Rebound, ReboundTarget)
        return
    end

    SidekickDesire, SidekickTarget = X.ConsiderSidekick()
    if SidekickDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Sidekick, SidekickTarget)
        return
    end

    UnleashDesire = X.ConsiderUnleash()
    if UnleashDesire > 0
    then
        bot:Action_UseAbility(Unleash)
        return
    end
end

function X.ConsiderDispose()
    if not Dispose:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = Dispose:GetCastRange() + 200
    local nDamage = Dispose:GetSpecialValueInt('impact_damage')
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

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.68 and bot:WasRecentlyDamagedByAnyHero(1.9)))
        then
            nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and bot:IsFacingLocation(J.GetEscapeLoc(), 30)
                and bot:IsFacingLocation(enemyHero:GetLocation(), 15)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not J.IsTaunted(enemyHero)
                and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
                and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
                and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
                and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderRebound()
    if not Rebound:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = 600 -- Rebound:GetSpecialValueInt('jump_range') + 300

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot, nRadius, false, BOT_MODE_NONE)
        for _, ally in pairs(nInRangeAlly)
        do
            if ally ~= bot
            and J.IsValidTarget(ally)
            and J.IsInRange(bot, ally, nRadius)
            and not J.IsSuspiciousIllusion(ally)
            and not ally:IsMagicImmune()
            then
                return BOT_ACTION_DESIRE_HIGH, ally
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSidekick()
    if not Sidekick:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = Sidekick:GetCastRange() + 300
    local nDuration = Sidekick:GetSpecialValueInt('duration')

    if J.IsGoingOnSomeone(bot)
    or J.IsInTeamFight(bot, 1000)
    or J.IsDefending(bot)
    or J.IsPushing(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot, nCastRange, false, BOT_MODE_NONE)
        for _, ally in pairs(nInRangeAlly)
        do
            if ally ~= bot
            and J.IsValidTarget(ally)
            and J.IsInRange(bot, ally, nCastRange)
            and not J.IsSuspiciousIllusion(ally)
            and not ally:IsMagicImmune()
            then
                return BOT_ACTION_DESIRE_HIGH, ally
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderUnleash()
    if not Unleash:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
    or J.IsInTeamFight(bot, 1000)
    then
        if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 600)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_aphotic_shield')
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X
