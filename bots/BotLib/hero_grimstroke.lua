local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos4,5
                        ['t25'] = {0, 10},
                        ['t20'] = {10, 0},
                        ['t15'] = {10, 0},
                        ['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,3,2,3,6,3,2,2,2,6,1,1,1,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_mage_outfit",
	"item_shadow_amulet",
	"item_shivas_guard",
	"item_cyclone",
	"item_glimmer_cape",
    "item_ultimate_scepter",
	"item_sheepstick",
    "item_aghanims_shard",
	"item_bloodthorn",
	"item_wind_waker",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = {
	"item_tango",
	"item_double_branches",
	"item_faerie_fire",
	"item_circlet",

	"item_boots",
	"item_ring_of_basilius",
	"item_arcane_boots",
	"item_magic_wand",
	"item_shivas_guard",--
	"item_rod_of_atos",
	"item_gungir",--
	"item_cyclone",
	"item_eternal_shroud",--
	"item_black_king_bar",--
	"item_aghanims_shard",
	'item_heavens_halberd',--
    "item_wind_waker",
	"item_refresher",--
    "item_travel_boots",
    "item_travel_boots_2",--
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_4'] = {
    "item_blood_grenade",
	"item_priest_outfit",
	"item_mekansm",
	"item_glimmer_cape",
	"item_guardian_greaves",
    "item_ultimate_scepter",
	"item_spirit_vessel",
--	"item_wraith_pact",
	"item_shivas_guard",
	"item_sheepstick",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_5'] = {
    "item_blood_grenade",
	"item_mage_outfit",
	"item_ancient_janggo",
	"item_glimmer_cape",
	"item_boots_of_bearing",
	"item_pipe",
    "item_ultimate_scepter",
	"item_spirit_vessel",
--	"item_wraith_pact",
	"item_shivas_guard",
	"item_sheepstick",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

	"item_ultimate_scepter",
	"item_magic_wand",

	"item_cyclone",
	"item_magic_wand",

	"item_shivas_guard",
	'item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
    Minion.MinionThink(hMinionUnit, bot)
end

local StrokeOfFate      = bot:GetAbilityByName('grimstroke_dark_artistry')
local PhantomsEmbrace   = bot:GetAbilityByName('grimstroke_ink_creature')
local InkSwell          = bot:GetAbilityByName('grimstroke_spirit_walk')
local InkExplosion      = bot:GetAbilityByName('grimstroke_return')
local DarkPortrait      = bot:GetAbilityByName('grimstroke_dark_portrait')
local SoulBind          = bot:GetAbilityByName('grimstroke_soul_chain')

local StrokeOfFateDesire, StrokeOfFateLocation
local PhantomsEmbraceDesire, PhantomsEmbraceTarget
local InkSwellDesire, InkSwellTarget
local InkExplosionDesire
local DarkPortraitDesire, DarkPortraitTarget
local SoulBindDesire, SoulBindTarget

local InkSwellCastTime = -1

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    InkSwellDesire, InkSwellTarget = X.ConsiderInkSwell()
    if InkSwellDesire > 0
    then
        bot:Action_UseAbilityOnEntity(InkSwell, InkSwellTarget)
        InkSwellCastTime = DotaTime()
        return
    end

    InkExplosionDesire = X.ConsiderInkExplosion()
    if InkExplosionDesire > 0
    then
        bot:Action_UseAbility(InkExplosion)
        return
    end

    SoulBindDesire, SoulBindTarget = X.ConsiderSoulBind()
    if SoulBindDesire > 0
    then
        bot:Action_UseAbilityOnEntity(SoulBind, SoulBindTarget)
        return
    end

    PhantomsEmbraceDesire, PhantomsEmbraceTarget = X.ConsiderPhantomsEmbrace()
    if PhantomsEmbraceDesire > 0
    then
        bot:Action_UseAbilityOnEntity(PhantomsEmbrace, PhantomsEmbraceTarget)
        return
    end

    StrokeOfFateDesire, StrokeOfFateLocation = X.ConsiderStrokeOfFate()
    if StrokeOfFateDesire > 0
    then
        bot:Action_UseAbilityOnLocation(StrokeOfFate, StrokeOfFateLocation)
        return
    end

    DarkPortraitDesire, DarkPortraitTarget = X.ConsiderDarkPortrait()
    if DarkPortraitDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DarkPortrait, DarkPortraitTarget)
        return
    end
end

function X.ConsiderStrokeOfFate()
    if not StrokeOfFate:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, StrokeOfFate:GetCastRange())
	local nCastPoint = StrokeOfFate:GetCastPoint()
	local nRadius = StrokeOfFate:GetSpecialValueInt('end_radius')
	local nSpeed = StrokeOfFate:GetSpecialValueInt('projectile_speed')
    local nDamage = StrokeOfFate:GetSpecialValueInt('damage')
    local nAbilityLevel = StrokeOfFate:GetLevel()

	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
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
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and (#nInRangeAlly >= #nInRangeEnemy or J.WeAreStronger(bot, 1600))
            then
                local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)

                if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
                and not J.IsRunning(botTarget)
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                else
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
                end
            end
		end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and (#nInRangeEnemy > #nInRangeAlly or not J.WeAreStronger(bot, 1600))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and not J.IsInRange(bot, nInRangeEnemy[1], 300)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
        end
    end

	if  (J.IsPushing(bot) or J.IsDefending(bot))
    and J.GetManaAfter(StrokeOfFate:GetManaCost()) > 0.4
    and nAbilityLevel >= 3
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
		if nLocationAoE.count >= 2
        then
            local weakTarget = J.GetVulnerableUnitNearLoc(bot, true, true, nCastRange, nRadius, nLocationAoE.targetloc)
            if weakTarget ~= nil
            then
                local nDelay = (GetUnitToUnitDistance(bot, weakTarget) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, weakTarget:GetExtrapolatedLocation(nDelay)
            end
		end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
        and not J.IsRunning(nEnemyLaneCreeps[1])
        and not J.IsThereCoreNearby(1000)
        then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
		end
	end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:GetActiveModeDesire() >= 0.5
        and not allyHero:IsIllusion()
        then
            if  J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nDelay = (GetUnitToUnitDistance(bot, nAllyInRangeEnemy[1]) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(nDelay)
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.GetHP(botTarget) < 0.5
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderPhantomsEmbrace()
    if not PhantomsEmbrace:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, PhantomsEmbrace:GetCastRange())
    local nDuration = PhantomsEmbrace:GetSpecialValueInt('latch_duration')
    local nDamagePerSec = PhantomsEmbrace:GetSpecialValueInt('damage_per_second')
    local nRendDamage = PhantomsEmbrace:GetSpecialValueInt('pop_damage')

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nDamagePerSec * nDuration + nRendDamage, DAMAGE_TYPE_PHYSICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not StrokeOfFate:IsFullyCastable()
		then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
		end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and (#nInRangeAlly >= #nInRangeEnemy or J.WeAreStronger(bot, 1600))
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
        if  J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.CanCastOnTargetAdvanced(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly or not J.WeAreStronger(bot, 1200))
                or bot:WasRecentlyDamagedByAnyHero(1))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
        end
	end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderInkSwell()
    if not InkSwell:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, InkSwell:GetCastRange())
	local nRadius = InkSwell:GetSpecialValueInt('radius')

    local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and enemyHero:IsChanneling()
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
		then
            return BOT_ACTION_DESIRE_HIGH, bot
		end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nInRangeAllyEnemy = allyHero:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and not J.IsSuspiciousIllusion(allyHero)
        then
            for _, allyEnemyHero in pairs(nInRangeAllyEnemy)
            do
                if  J.IsValidHero(allyEnemyHero)
                and J.CanCastOnNonMagicImmune(allyEnemyHero)
                and allyEnemyHero:IsChanneling()
                and not J.IsSuspiciousIllusion(allyEnemyHero)
                and not J.IsDisabled(allyEnemyHero)
                and not allyEnemyHero:HasModifier('modifier_enigma_black_hole_pull')
                and not allyEnemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not allyEnemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end
        end
    end

    local dist = 1600
    local targetAlly = nil

    for _, allyHero in pairs(nAllyHeroes)
    do
        if  J.IsValidHero(allyHero)
        and J.IsValidTarget(botTarget)
        and not J.IsSuspiciousIllusion(allyHero)
        and GetUnitToUnitDistance(allyHero, botTarget) < dist
        then
            targetAlly = allyHero
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and (#nInRangeAlly >= #nInRangeEnemy or J.WeAreStronger(bot, 1600))
            and targetAlly ~= nil
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(targetAlly:GetLocation(), nRadius)
                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, targetAlly
                end
            end
        end
    end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.75
    and not StrokeOfFate:IsFullyCastable()
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
        if  J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly or not J.WeAreStronger(bot, 1600))
                or bot:WasRecentlyDamagedByAnyHero(1) and J.GetHP(bot) < 0.75)
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderInkExplosion()
    if InkExplosion:IsHidden()
    or not InkExplosion:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = InkSwell:GetSpecialValueInt('radius')
    local nDuration = InkSwell:GetSpecialValueInt('buff_duration')

    if DotaTime() < InkSwellCastTime + nDuration
    then
        local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and enemyHero:IsChanneling()
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and bot:HasModifier('modifier_grimstroke_spirit_walk_buff')
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end

        for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
        do
            local nInRangeAllyEnemy = allyHero:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
            if J.IsValidHero(allyHero)
            then
                for _, allyEnemyHero in pairs(nInRangeAllyEnemy)
                do
                    if  J.IsValidHero(allyEnemyHero)
                    and J.CanCastOnNonMagicImmune(allyEnemyHero)
                    and allyEnemyHero:IsChanneling()
                    and not J.IsSuspiciousIllusion(allyEnemyHero)
                    and not J.IsDisabled(allyEnemyHero)
                    and allyHero:HasModifier('modifier_grimstroke_spirit_walk_buff')
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSoulBind()
    if not SoulBind:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nRadius = SoulBind:GetSpecialValueInt('chain_latch_radius')
    local nDuration = SoulBind:GetSpecialValueInt('chain_duration')

    if J.IsGoingOnSomeone(bot)
    then
        local strongestTarget = J.GetStrongestUnit(1200, bot, true, true, nDuration)
        if strongestTarget == nil
        then
            strongestTarget = J.GetStrongestUnit(1200, bot, true, false, nDuration)
        end

        if  J.IsValidHero(strongestTarget)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not strongestTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not strongestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nInRangeAlly = strongestTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            local nInRangeEnemy = strongestTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
            local nTargetInRangeAlly = J.GetEnemiesNearLoc(strongestTarget:GetLocation(), nRadius)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and (#nInRangeAlly >= #nInRangeEnemy or J.WeAreStronger(bot, 1600))
            and nTargetInRangeAlly ~= nil and #nTargetInRangeAlly >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, strongestTarget
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDarkPortrait()
    if not DarkPortrait:IsTrained()
    or not DarkPortrait:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    if J.IsGoingOnSomeone(bot)
    then
        local strongestTarget = J.GetStrongestUnit(1600, bot, true, true, 5)
        if strongestTarget == nil
        then
            strongestTarget = J.GetStrongestUnit(1600, bot, true, false, 5)
        end

        if  J.IsValidHero(strongestTarget)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.IsDisabled(strongestTarget)
        and not strongestTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not strongestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nInRangeAlly = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            local nInRangeEnemy = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and (#nInRangeAlly >= #nInRangeEnemy or J.WeAreStronger(bot, 1600))
            then
                return BOT_ACTION_DESIRE_HIGH, strongestTarget
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X