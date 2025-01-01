local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						{--pos2
                            ['t25'] = {10, 0},
                            ['t20'] = {0, 10},
                            ['t15'] = {0, 10},
                            ['t10'] = {10, 0},
                        },--pos3
                        {
                            ['t25'] = {10, 0},
                            ['t20'] = {10, 0},
                            ['t15'] = {0, 10},
                            ['t10'] = {10, 0},
                        }
}

local tAllAbilityBuildList = {
						{2,3,1,2,1,6,2,2,1,1,6,3,3,3,6},--pos2
                        {1,2,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_2"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
else
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_quelling_blade",

    "item_bottle",
    "item_phase_boots",
    "item_magic_wand",
    "item_blade_mail",
    "item_radiance",--
    "item_black_king_bar",--
    "item_blink",
    "item_veil_of_discord",
    "item_shivas_guard",--
    "item_heart",--
    "item_travel_boots",
    "item_overwhelming_blink",--
    "item_moon_shard",
    "item_travel_boots_2",--
    "item_aghanims_shard",
    "item_ultimate_scepter",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",
    "item_magic_stick",

    "item_bracer",
    "item_magic_wand",
    "item_phase_boots",
    "item_blade_mail",
    "item_radiance",--
    "item_veil_of_discord",
    "item_crimson_guard",--
    "item_black_king_bar",--
    "item_lotus_orb",--
    "item_shivas_guard",--
    "item_travel_boots",
    "item_moon_shard",
    "item_aghanims_shard",
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = {
	'item_priest_outfit',
	"item_mekansm",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
	"item_lotus_orb",
	"item_gungir",--
	--"item_holy_locket",
	"item_sheepstick",
	"item_mystic_staff",
    "item_moon_shard",
	"item_ultimate_scepter_2",
	"item_shivas_guard",
}

sRoleItemsBuyList['pos_5'] = {
	'item_mage_outfit',
	"item_glimmer_cape",

    "item_pavise",
	"item_pipe",--
    "item_solar_crest",--
	"item_lotus_orb",--
	"item_aghanims_shard",
	"item_spirit_vessel",--
	"item_shivas_guard",--
	"item_mystic_staff",
	"item_ultimate_scepter_2",
    "item_moon_shard",
	"item_sheepstick",--
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_vanguard",
	"item_quelling_blade",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Onslaught         = bot:GetAbilityByName('primal_beast_onslaught') -- Q 突
local Trample           = bot:GetAbilityByName('primal_beast_trample') -- W 踏
local Uproar            = bot:GetAbilityByName('primal_beast_uproar') -- E 咤
local RockThrow         = bot:GetAbilityByName('primal_beast_rock_throw') -- D 砸
local Pulverize         = bot:GetAbilityByName('primal_beast_pulverize') -- R 捶
local BeginOnslaught    = bot:GetAbilityByName('primal_beast_onslaught_release')

local botTarget, nEnemyHeroes, nInRangeAlly
local OnslaughtDesire, OnslaughtLocation
local BeginOnslaughtDesire
local TrampleDesire
local UproarDesire
local RockThrowDesire, RockThrowLocation
local PulverizeDesire, PulverizeTarget

local OnslaughtStartTime = 0
local OnslaughtETA = 0

function X.SkillsComplement()

    botTarget = J.GetProperTarget(bot)
	nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
	nInRangeAlly = J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_NONE)

    if not bot:HasModifier('modifier_primal_beast_trample') then
        bot.trample_status = {'', 0, nil}
    end

    if J.CanNotUseAbility(bot)
    or bot:HasModifier('modifier_prevent_taunts')
    or bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable')
    or bot:HasModifier('modifier_primal_beast_trample')
    or bot:HasModifier('modifier_primal_beast_pulverize_self')
    then
        return
    end

    UproarDesire = X.ConsiderUproar()
    if UproarDesire > 0
    then
        bot:Action_UseAbility(Uproar)
        return
    end

    PulverizeDesire, PulverizeTarget = X.ConsiderPulverize()
    if PulverizeDesire > 0
    then
        if J.CanBlackKingBar(bot) and bot.BlackKingBar ~= nil then
            bot:Action_ClearActions(false)
            bot:ActionQueue_UseAbility(bot.BlackKingBar)
            bot:ActionQueue_UseAbilityOnEntity(Pulverize, PulverizeTarget)
            return
        end

        bot:Action_UseAbilityOnEntity(Pulverize, PulverizeTarget)
        return
    end

    TrampleDesire = X.ConsiderTrample()
    if TrampleDesire > 0
    then
        bot:Action_UseAbility(Trample)
        return
    end

    BeginOnslaughtDesire = X.ConsiderBeginOnslaughtDesire()
    if BeginOnslaughtDesire > 0
    then
        bot:Action_UseAbility(BeginOnslaught)
        OnslaughtETA = 0
        return
    end

    OnslaughtDesire, OnslaughtLocation = X.ConsiderOnslaught()
    if OnslaughtDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Onslaught, OnslaughtLocation)
        bot.onslaught_location = OnslaughtLocation
        OnslaughtStartTime = DotaTime()
        return
    end

    RockThrowDesire, RockThrowLocation = X.ConsiderRockThrow()
    if RockThrowDesire > 0
    then
        bot:Action_UseAbilityOnLocation(RockThrow, RockThrowLocation)
        return
    end
end

-- can be a feed spell
function X.ConsiderOnslaught()
    if not J.CanCastAbility(Onslaught)
    or bot:IsRooted()
    or bot:HasModifier('modifier_bloodseeker_rupture')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nDistance = Onslaught:GetSpecialValueInt('max_distance')
    local nRadius = Onslaught:GetSpecialValueInt('knockback_distance')
    local nChannelTime = Onslaught:GetSpecialValueFloat('chargeup_time')

    -- only tp
    for _, enemyHero in pairs(nEnemyHeroes) do
        if J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, 600)
        and J.CanCastOnNonMagicImmune(enemyHero) then
            local tInRangeAlly = J.GetAlliesNearLoc(enemyHero:GetLocation(), 1200)
            local tInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), 1200)
            if #tInRangeAlly >= #tInRangeEnemy and enemyHero:HasModifier('modifier_teleporting') then
                local dist = GetUnitToUnitDistance(bot, enemyHero)
                OnslaughtETA = RemapValClamped(dist, 100, nDistance, 0.3, nChannelTime)
                bot.onslaught_status = {'engage', botTarget}
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end
        end
    end

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidHero(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nDistance)
        and not J.IsEnemyBlackHoleInLocation(botTarget:GetLocation())
        and not J.IsEnemyChronosphereInLocation(botTarget:GetLocation())
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local tInRangeAlly = J.GetAlliesNearLoc(botTarget:GetLocation(), 1200)
            local tInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)
            if #tInRangeAlly >= #tInRangeEnemy then
                local dist = GetUnitToUnitDistance(bot, botTarget)
                OnslaughtETA = RemapValClamped(dist, 100, nDistance, 0.3, nChannelTime)
                bot.onslaught_status = {'engage', botTarget}
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:WasRecentlyDamagedByAnyHero(4)
    and bot:GetActiveModeDesire() > 0.7
    then
        if J.IsValidHero(nEnemyHeroes[1])
        and ((not J.WeAreStronger(bot, 1200) and J.GetHP(bot) < 0.75)
            or J.IsChasingTarget(nEnemyHeroes[1], bot))
        then
            local dist = RemapValClamped(GetUnitToUnitDistance(bot, nEnemyHeroes[1]), 600, 1200, nChannelTime * 0.6, nChannelTime)
            OnslaughtETA = RemapValClamped(dist, 100, nDistance, 0.3, nChannelTime)
            bot.onslaught_status = {'retreat', J.GetTeamFountain()}
            return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain()
        end
    end

    if J.IsFarming(bot) or (J.IsPushing(bot) and #nInRangeAlly <= 1) or (J.IsDefending(bot) and #nEnemyHeroes == 0) then
        local nCreeps = bot:GetNearbyCreeps(800, true)
        if J.IsValid(nCreeps[1])
        and J.GetMP(bot) > 0.5
        and not J.IsRunning(nCreeps[1])
        and J.CanBeAttacked(nCreeps[1])
        and J.IsAttacking(bot)
        then
            local nLocationAoE = bot:FindAoELocation(true, false, nCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
            if ((#nCreeps >= 4 and nLocationAoE.count >= 4) and not J.HasItem(bot, 'item_radiance'))
            or (#nCreeps >= 2 and nLocationAoE.count >= 2 and nCreeps[1]:IsAncientCreep())
            then
                local dist = GetUnitToLocationDistance(bot, nLocationAoE.targetloc)
                OnslaughtETA = RemapValClamped(dist, 100, nDistance, 0.3, nChannelTime)
                bot.onslaught_status = {'farm', nLocationAoE.targetloc}
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderBeginOnslaughtDesire()
    if not J.CanCastAbility(BeginOnslaught)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if DotaTime() >= OnslaughtStartTime + OnslaughtETA then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTrample()
    if not Trample:IsFullyCastable()
    or bot:IsRooted()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = Trample:GetSpecialValueInt('effect_radius')
    local nDuration = Trample:GetSpecialValueFloat('duration')
    local nBaseDamage = Trample:GetSpecialValueInt('base_damage')

    local nEnemyTowers = bot:GetNearbyTowers(1600, true)

    if J.IsGoingOnSomeone(bot)
	then
        if J.IsValidHero(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        then
            bot.trample_status = {'engaging', botTarget:GetLocation(), botTarget}
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:WasRecentlyDamagedByAnyHero(3)
    then
        if J.IsValidHero(nEnemyHeroes[1])
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        then
            bot.trample_status = {'retreating', J.GetTeamFountain(), nil}
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    local nCreeps = bot:GetNearbyCreeps(800, true)
    local nAllyHeroes = J.GetAlliesNearLoc(bot:GetLocation(), 800)

    if (J.IsFarming(bot) or (J.IsPushing(bot) and #nAllyHeroes <= 1) or J.IsDefending(bot)) and J.GetManaAfter(Trample:GetManaCost()) > 0.35 then
        if J.IsValid(nCreeps[1])
        and ((#nCreeps >= 3 and not J.HasItem(bot, 'item_radiance')) or #nCreeps >= 2 and nCreeps[1]:IsAncientCreep())
        and not J.IsRunning(nCreeps[1])
        and J.CanBeAttacked(nCreeps[1])
        and J.IsAttacking(bot)
        then
            bot.trample_status = {'farming', 0, nil}
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsLaning(bot) and #nEnemyHeroes == 0 then
        if #nCreeps >= 3
        and J.IsValid(nCreeps[1])
        and not J.IsRunning(nCreeps[1])
        and J.CanBeAttacked(nCreeps[1])
        and J.IsAttacking(bot)
        then
            if #nEnemyTowers == 0
            or J.IsValidBuilding(nEnemyTowers[1]) and GetUnitToUnitDistance(nCreeps[1], nEnemyTowers[1]) > 900 then
                bot.trample_status = {'laning', 0, nil}
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    for _, enemyHero in pairs(nEnemyHeroes) do
        if J.IsValidHero(enemyHero)
        and not enemyHero:IsInvulnerable()
        and J.IsInRange(bot, enemyHero, nRadius)
        and J.CanKillTarget(enemyHero, nBaseDamage * nDuration, DAMAGE_TYPE_PHYSICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        then
            bot.trample_status = {'engaging', enemyHero:GetLocation(), enemyHero}
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingRoshan(bot) then
        if J.IsRoshan(botTarget)
        and not botTarget:IsAttackImmune()
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            bot.trample_status = {'miniboss', botTarget:GetLocation(), botTarget}
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot) then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            bot.trample_status = {'miniboss', botTarget:GetLocation(), botTarget}
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderUproar()
    if not J.CanCastAbility(Uproar)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = Uproar:GetSpecialValueInt('radius')
    local nStacks = J.GetModifierCount(bot, 'modifier_primal_beast_uproar')

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            if nStacks >= 4
            or J.IsChasingTarget(bot, botTarget) and nStacks >= 2
            or J.GetHP(bot) < 0.5 and nStacks >= 3
            or J.GetHP(bot) < 0.25 and nStacks >= 1
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:WasRecentlyDamagedByAnyHero(3)
    then
        if J.IsValidTarget(nEnemyHeroes[1])
        and J.IsInRange(bot, nEnemyHeroes[1], nRadius)
        and (J.IsChasingTarget(nEnemyHeroes[1], bot) or J.GetHP(bot) < 0.5)
        and not J.IsDisabled(nEnemyHeroes[1])
        and nStacks >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderRockThrow()
    if not J.CanCastAbility(RockThrow)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, RockThrow:GetCastRange())
    local nCastPoint = RockThrow:GetCastPoint()
    local nRadius = RockThrow:GetSpecialValueInt('impact_radius')
    local nMaxTime = RockThrow:GetSpecialValueFloat('max_travel_time')
    local nMinDistance = RockThrow:GetSpecialValueInt('min_range')
    local nDamage = RockThrow:GetSpecialValueInt('base_damage')

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsInRange(bot, enemyHero, nMinDistance)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if enemyHero:IsChanneling() then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end

            if J.WillKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL, nCastPoint + nMaxTime)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(enemyHero, nCastPoint + nMaxTime)
            end
        end
    end

    if J.IsInTeamFight(bot, 1200) then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
        if #nInRangeEnemy >= 2 then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderPulverize()
    if not J.CanCastAbility(Pulverize)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Pulverize:GetCastRange())
    local nBonusDamagePerHit = Pulverize:GetSpecialValueInt('bonus_damage_per_hit')
    local nDamage = Pulverize:GetSpecialValueInt('damage') + nBonusDamagePerHit * 3
    local nDuration = Pulverize:GetSpecialValueFloat('channel_time')

    for _, enemyHero in pairs(nEnemyHeroes) do
        if J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange * 2)
        and J.CanCastOnMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        then
            if enemyHero:IsChanneling() and not J.IsInLaningPhase() then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if J.CanKillTarget(enemyHero, nDamage * nDuration, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange * 2)
        and J.CanCastOnMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        then
            if J.IsInLaningPhase() and not J.IsInTeamFight(bot, 1600) then
                local nAllyHeroes = J.GetAlliesNearLoc(botTarget:GetLocation(), 800)
                if botTarget:GetHealth() <= J.GetTotalEstimatedDamageToTarget(nAllyHeroes, botTarget)
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                end
            else
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X