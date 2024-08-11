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
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,1,2,2,2,6,2,1,1,1,6,3,3,3,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {

	"item_crystal_maiden_outfit",
	"item_force_staff",
	"item_hand_of_midas",
	"item_ultimate_scepter",
	"item_aghanims_shard",
	"item_orchid",
	"item_black_king_bar",--
	"item_hurricane_pike",--
	"item_travel_boots",
	"item_ultimate_scepter_2",
	"item_bloodthorn",--
	"item_travel_boots_2",--
	"item_mystic_staff",--
	"item_sheepstick",--

}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = {
    "item_blood_grenade",

	'item_priest_outfit',
	"item_mekansm",
	"item_glimmer_cape",--
	"item_aghanims_shard",
	"item_guardian_greaves",--
	"item_spirit_vessel",--
	--"item_holy_locket",
	"item_ultimate_scepter",
	"item_sheepstick",--
	"item_mystic_staff",--
	"item_ultimate_scepter_2",
	"item_shivas_guard",--

}

sRoleItemsBuyList['pos_5'] = {

	"item_mage_outfit",
	"item_ancient_janggo",
	"item_glimmer_cape",--
	"item_boots_of_bearing",--
	"item_pipe",--
	--"item_holy_locket",
	"item_ultimate_scepter",
	"item_aghanims_shard",
	"item_mystic_staff",--
	"item_ultimate_scepter_2",
	"item_sheepstick",--
	"item_cyclone",
    "item_wind_waker",--
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos4SellList = {
	"item_magic_wand",
}

Pos5SellList = {
	"item_magic_wand",
}

X['sSellList'] = {
	"item_magic_wand",
	"item_ultimate_scepter",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end
end

local ColdFeet          = bot:GetAbilityByName('ancient_apparition_cold_feet')
local IceVortex         = bot:GetAbilityByName('ancient_apparition_ice_vortex')
local ChillingTouch     = bot:GetAbilityByName('ancient_apparition_chilling_touch')
local IceBlast          = bot:GetAbilityByName('ancient_apparition_ice_blast')
local IceBlastRelease   = bot:GetAbilityByName('ancient_apparition_ice_blast_release')

local ColdFeetAoETalent = bot:GetAbilityByName('special_bonus_unique_ancient_apparition_7')

local ColdFeetDesire, ColdFeetTarget
local IceVortexDesire, IceVortextLocation
local ChillingTouchDesire, ChillingTouchTarget
local IceBlastDesire, IceBlastLocation
local IceBlastReleaseDesire

local IceBlastReleaseLocation

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    IceBlastReleaseDesire = X.ConsiderIceBlastRelease()
    if IceBlastReleaseDesire > 0
    then
        bot:Action_UseAbility(IceBlastRelease)
        return
    end

    IceBlastDesire, IceBlastLocation = X.ConsiderIceBlast()
    if IceBlastDesire > 0
    then
        bot:Action_UseAbilityOnLocation(IceBlast, IceBlastLocation)
        IceBlastReleaseLocation = IceBlastLocation
        return
    end

    IceVortexDesire, IceVortextLocation = X.ConsiderIceVortex()
    if IceVortexDesire > 0
    then
        bot:Action_UseAbilityOnLocation(IceVortex, IceVortextLocation)
        return
    end

    ColdFeetDesire, ColdFeetTarget = X.ConsiderColdFeet()
    if ColdFeetDesire > 0
    then
        if ColdFeetAoETalent:IsTrained()
        then
            local nAoERadius = 450
            local nCastRange = J.GetProperCastRange(false, bot, ColdFeet:GetCastRange())
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nAoERadius, 0, 0)

            if nLocationAoE.count >= 2
            then
                bot:Action_UseAbilityOnLocation(ColdFeet, nLocationAoE.targetLoc)
            else
                bot:Action_UseAbilityOnEntity(ColdFeet, ColdFeetTarget)
            end
        else
            bot:Action_UseAbilityOnEntity(ColdFeet, ColdFeetTarget)
        end

        return
    end

    ChillingTouchDesire, ChillingTouchTarget = X.ConsiderChillingTouch()
    if ChillingTouchDesire > 0
    then
        bot:Action_UseAbilityOnEntity(ChillingTouch, ChillingTouchTarget)
        return
    end
end

function X.ConsiderColdFeet()
    if not ColdFeet:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, ColdFeet:GetCastRange())
    local botTarget = J.GetProperTarget(bot)

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.5)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
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
        and not botTarget:HasModifier('modifier_cold_feet')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if (#nInRangeAlly > #nInRangeEnemy
                    or bot:WasRecentlyDamagedByHero(enemyHero, 1.5))
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_cold_feet')
                and not enemyHero:HasModifier('modifier_ice_vortex')
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
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_cold_feet')
        and not botTarget:HasModifier('modifier_ice_vortex')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_cold_feet')
        and not botTarget:HasModifier('modifier_ice_vortex')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderIceVortex()
    if not IceVortex:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, IceVortex:GetCastRange())
    local nRadius = IceVortex:GetSpecialValueInt('radius')
    local nCastPoint = IceVortex:GetCastPoint()
    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy
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
        and not botTarget:HasModifier('modifier_ice_vortex')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

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

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if (#nInRangeAlly > #nInRangeEnemy
                    or bot:WasRecentlyDamagedByHero(enemyHero, 1.5))
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_cold_feet')
                and not enemyHero:HasModifier('modifier_ice_vortex')
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
                end
            end
        end
    end

    if  (J.IsDefending(bot) or J.IsPushing(bot))
    and not J.IsThereCoreNearby(1000)
	then
		local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if  nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 4
        and nLocationAoE.count >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        if nLocationAoE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderChillingTouch()
    if not ChillingTouch:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, ChillingTouch:GetCastRange()) + ChillingTouch:GetSpecialValueInt('attack_range_bonus')
    local nDamage = ChillingTouch:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
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

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.5)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
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
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if (#nInRangeAlly > #nInRangeEnemy
                    or bot:WasRecentlyDamagedByHero(enemyHero, 1.2))
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
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
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderIceBlast()
    if not IceBlast:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nMinRadius = IceBlast:GetSpecialValueInt('radius_min')
    local nGrowSpeed = IceBlast:GetSpecialValueInt('radius_grow')
    local nMaxRadius = IceBlast:GetSpecialValueInt('radius_max')

    if J.IsInTeamFight(bot, 1600)
    then
        local nTeamFightLocation = J.GetTeamFightLocation(bot)

        if nTeamFightLocation ~= nil
        then
            local dist = GetUnitToLocationDistance(bot, nTeamFightLocation)
            local nRadius = math.min(nMinRadius + (dist * nGrowSpeed), nMaxRadius)
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1600, nRadius, 0, 0)
            local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)

    if nTeamFightLocation ~= nil
    then
        local dist = GetUnitToLocationDistance(bot, nTeamFightLocation)
        local nRadius = math.min(nMinRadius + (dist * nGrowSpeed), nMaxRadius)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nTeamFightLocation, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nTeamFightLocation
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderIceBlastRelease()
    if IceBlastRelease:IsHidden()
    or not IceBlastRelease:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nProjectiles = GetLinearProjectiles()

    for _, p in pairs(nProjectiles)
	do
		if p ~= nil and p.ability:GetName() == "ancient_apparition_ice_blast"
        then
			if  IceBlastReleaseLocation ~= nil
            and J.GetLocationToLocationDistance(IceBlastReleaseLocation, p.location) < 100
            then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

return X