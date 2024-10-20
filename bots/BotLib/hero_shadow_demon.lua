local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos4,5
                        ['t25'] = {10, 0},
                        ['t20'] = {10, 0},
                        ['t15'] = {10, 0},
                        ['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,1,3,1,3,6,3,1,1,2,6,2,2,2,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local nRandItem = RandomInt(1, 2) == 1 and "item_glimmer_cape" or "item_force_staff"

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",

    "item_magic_wand",
    "item_arcane_boots",
    "item_aether_lens",--
    "item_blink",
    nRandItem,--
    "item_guardian_greaves",--
    "item_ultimate_scepter",
    "item_aeon_disk",--
    "item_octarine_core",--
    "item_ultimate_scepter_2",
    "item_arcane_blink",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",
	"item_enchanted_mango",
	"item_blood_grenade",

	"item_magic_wand",
	"item_boots",
	"item_tranquil_boots",
	"item_glimmer_cape",--
    "item_pipe",--
	-- "item_aether_lens",--
	"item_aghanims_shard",
	"item_force_staff",--
	"item_boots_of_bearing",--
	"item_cyclone",
    "item_lotus_orb",--
	"item_gungir",--
	"item_wind_waker",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_crystal_maiden_outfit",
--		"item_glimmer_cape",
    "item_aghanims_shard",
    "item_ultimate_scepter",
    "item_force_staff",
    "item_maelstrom",
	"item_gungir",--
    "item_cyclone",
	"item_hurricane_pike",--
    "item_sheepstick",--
    "item_wind_waker",--
    "item_moon_shard",
    "item_octarine_core",--
    "item_ultimate_scepter_2",
    "item_ethereal_blade",--
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_cyclone",
	"item_magic_wand",

	"item_ultimate_scepter",
	"item_magic_wand",
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Disruption            = bot:GetAbilityByName('shadow_demon_disruption')
local Disseminate           = bot:GetAbilityByName('shadow_demon_disseminate')
local ShadowPoison          = bot:GetAbilityByName('shadow_demon_shadow_poison')
local ShadowPoisonRelease   = bot:GetAbilityByName('shadow_demon_shadow_poison_release')
local DemonicCleanse        = bot:GetAbilityByName('shadow_demon_demonic_cleanse')
local DemonicPurge          = bot:GetAbilityByName('shadow_demon_demonic_purge')

local DisruptionDesire, DisruptionTarget
local DisseminateDesire, DisseminateTarget
local ShadowPoisonDesire, ShadowPoisonLocation
local ShadowPoisonReleaseDesire
local DemonicCleanseDesire, DemonicCleanseTarget
local DemonicPurgeDesire, DemonicPurgeTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    DisruptionDesire, DisruptionTarget = X.ConsiderDisruption()
    if DisruptionDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Disruption, DisruptionTarget)
        return
    end

    DemonicCleanseDesire, DemonicCleanseTarget = X.ConsiderDemonicCleanse()
    if DemonicCleanseDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DemonicCleanse, DemonicCleanseTarget)
        return
    end

    DemonicPurgeDesire, DemonicPurgeTarget = X.ConsiderDemonicPurge()
    if DemonicPurgeDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DemonicPurge, DemonicPurgeTarget)
        return
    end

    DisseminateDesire, DisseminateTarget = X.ConsiderDisseminate()
    if DisseminateDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Disseminate, DisseminateTarget)
        return
    end

    ShadowPoisonDesire, ShadowPoisonLocation = X.ConsiderShadowPoison()
    if ShadowPoisonDesire > 0
    then
        bot:Action_UseAbilityOnLocation(ShadowPoison, ShadowPoisonLocation)
        return
    end

    ShadowPoisonReleaseDesire = X.ConsiderShadowPoisonRelease()
    if ShadowPoisonReleaseDesire > 0
    then
        bot:Action_UseAbility(ShadowPoisonRelease)
        return
    end
end

function X.ConsiderDisruption()
    if not Disruption:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Disruption:GetCastRange())
    local nDuration = Disruption:GetSpecialValueFloat('disruption_duration')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and (enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero))
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        if J.IsValidHero(allyHero)
        and not allyHero:IsIllusion()
        and not allyHero:HasModifier('modifier_obsidian_destroyer_astral_imprisonment_prison')
        then
            if allyHero:HasModifier('modifier_enigma_black_hole_pull')
            or allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or allyHero:HasModifier('modifier_legion_commander_duel')
            or allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
        end

        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and not allyHero:IsIllusion()
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], 400)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsRunning(allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
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

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.CanCastOnTargetAdvanced(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
        and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1000, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.75 and bot:WasRecentlyDamagedByAnyHero(2)))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
        end
    end

    if J.IsInTeamFight(bot, 1200)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if J.IsValidHero(allyHero)
            and not allyHero:IsIllusion()
            then
                if allyHero:HasModifier('modifier_enigma_black_hole_pull')
                or allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                or allyHero:HasModifier('modifier_legion_commander_duel')
                or allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                or J.GetHP(allyHero) < 0.33
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end
        end

        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

        if strongestTarget == nil
        then
            strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, true, nDuration)
        end

		if J.IsValidTarget(strongestTarget)
        and J.CanCastOnNonMagicImmune(strongestTarget)
        and J.CanCastOnTargetAdvanced(strongestTarget)
        and J.IsInRange(bot, strongestTarget, nCastRange)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.IsDisabled(strongestTarget)
        and not J.IsTaunted(strongestTarget)
        and not strongestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not strongestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not strongestTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not strongestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not strongestTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            return BOT_ACTION_DESIRE_HIGH, strongestTarget
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

		if J.IsValidTarget(strongestTarget)
        and J.CanCastOnNonMagicImmune(strongestTarget)
        and J.CanCastOnTargetAdvanced(strongestTarget)
        and J.IsInRange(bot, strongestTarget, nCastRange + 150)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.IsDisabled(strongestTarget)
		then
            local nTargetInRangeAlly = J.GetNearbyHeroes(strongestTarget, 1200, false, BOT_MODE_NONE)
            local nTargetInRangeEnemy = J.GetNearbyHeroes(strongestTarget, 1200, true, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil and nTargetInRangeEnemy ~= nil
            and #nTargetInRangeAlly >= #nTargetInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, strongestTarget
            end
		end
	end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        then
            if J.GetHP(bot) < 0.2
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end

            local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
            for _, allyHero in pairs(nInRangeAlly)
            do
                if J.IsValidHero(allyHero)
                and J.GetHP(allyHero) < 0.3
                and not allyHero:IsIllusion()
                and not allyHero:HasModifier('modifier_abaddon_borrowed_time')
                and not allyHero:HasModifier('modifier_dazzle_shallow_grave')
                and not allyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
                and not allyHero:HasModifier('modifier_obsidian_destroyer_astral_imprisonment_prison')
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDisseminate()
    if not Disseminate:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Disseminate:GetCastRange())
	local nRadius = Disseminate:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
		then
			if J.IsValidHero(nInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nInRangeEnemy[1])
			then
				return  BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			if J.GetAroundTargetEnemyUnitCount(botTarget, nRadius) >= 3
            then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end
		end
	end

    if J.IsRetreating(bot)
	then
		botTarget = J.GetVulnerableWeakestUnit(bot, true, true, nCastRange - 100)

		if J.IsValidHero(botTarget)
        and J.GetUnitAllyCountAroundEnemyTarget(botTarget, nRadius ) >= 3
        then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderShadowPoisonRelease()
    if not ShadowPoisonRelease:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local multiplier = {1, 2, 4, 8, 16}
    for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
        and J.IsInRange(enemyHero, bot, 3000)
		and not J.IsSuspiciousIllusion(enemyHero)
        then
            local spCount = J.GetModifierCount( enemyHero, "modifier_shadow_demon_shadow_poison" )
            local nDamage = ShadowPoison:GetSpecialValueFloat("stack_damage")
            if spCount >= 5
            or (spCount > 0 and J.CanKillTarget( enemyHero, nDamage * spCount * multiplier[spCount], DAMAGE_TYPE_MAGICAL ))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderShadowPoison()
    if not ShadowPoison:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, ShadowPoison:GetCastRange())
	local nCastPoint = ShadowPoison:GetCastPoint()
    local nSpeed = ShadowPoison:GetSpecialValueInt('speed')
    local nDuration = ShadowPoison:GetDuration()
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_graves')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            if J.IsInRange(bot, botTarget, (nCastRange / 2) - 150)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            else
                local eta = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(eta)
            end
		end
	end

	if J.IsDefending(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end
	end

    if J.IsLaning(bot)
	then
		local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

		if J.IsValidTarget(strongestTarget)
        and J.CanCastOnNonMagicImmune(strongestTarget)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not strongestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not strongestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and J.GetMP(bot) > 0.65
		then
            if J.IsInRange(bot, strongestTarget, (nCastRange / 2) - 150)
            then
                return BOT_ACTION_DESIRE_HIGH, strongestTarget:GetLocation()
            else
                local eta = (GetUnitToUnitDistance(bot, strongestTarget) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, strongestTarget:GetExtrapolatedLocation(eta)
            end
		end

        if not J.IsInLaningPhase()
        then
            local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
            if #nInRangeAlly <= 1 and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderDemonicPurge()
    if not DemonicPurge:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = DemonicPurge:GetCastRange()
    local nDuration = DemonicPurge:GetDuration()

    if J.IsInTeamFight(bot, 1200)
	then
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange + 200)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidTarget(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not J.IsTaunted(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_doom_bringer_doom')
            and not enemyHero:HasModifier('modifier_legion_commander_duel')
            and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and bot:HasScepter()
            then
                if enemyHero:GetUnitName() == 'npc_dota_hero_bristleback'
                or enemyHero:GetUnitName() == 'npc_dota_hero_huskar'
                or enemyHero:GetUnitName() == 'npc_dota_hero_tidehunter'
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end

		if J.IsValidTarget(strongestTarget)
        and J.CanCastOnNonMagicImmune(strongestTarget)
        and J.CanCastOnTargetAdvanced(strongestTarget)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.IsDisabled(strongestTarget)
        and not J.IsTaunted(strongestTarget)
        and not strongestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not strongestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not strongestTarget:HasModifier('modifier_doom_bringer_doom')
        and not strongestTarget:HasModifier('modifier_legion_commander_duel')
        and not strongestTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not strongestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            return BOT_ACTION_DESIRE_HIGH, strongestTarget
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

		if J.IsValidTarget(strongestTarget)
        and J.CanCastOnNonMagicImmune(strongestTarget)
        and J.CanCastOnTargetAdvanced(strongestTarget)
        and J.IsInRange(bot, strongestTarget, nCastRange + 150)
        -- and J.IsCore(strongestTarget)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.IsDisabled(strongestTarget)
		then
            local nTargetInRangeAlly = J.GetNearbyHeroes(strongestTarget, 1200, false, BOT_MODE_NONE)
            local nInRangeAlly = J.GetNearbyHeroes(strongestTarget, 1200, true, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            and (#nInRangeAlly == 1 or #nInRangeAlly == 2)
            and #nTargetInRangeAlly <= 1
            then
                return BOT_ACTION_DESIRE_HIGH, strongestTarget
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDemonicCleanse()
    if not DemonicCleanse:IsTrained()
    or not DemonicCleanse:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, DemonicCleanse:GetCastRange())

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeAlly = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange + 200)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if J.IsValidHero(allyHero)
            and J.IsDisabled(allyHero)
            and J.IsTaunted(allyHero)
            and not J.IsSuspiciousIllusion(allyHero)
            and not allyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not allyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not allyHero:HasModifier('modifier_doom_bringer_doom')
            and not allyHero:HasModifier('modifier_legion_commander_duel')
            and not allyHero:HasModifier('modifier_enigma_black_hole_pull')
            and not allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X