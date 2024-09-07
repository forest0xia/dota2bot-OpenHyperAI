local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local R             = dofile( GetScriptDirectory()..'/FunLib/rubick_utility' )
local SPL           = dofile( GetScriptDirectory()..'/FunLib/spell_prob_list' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos4,5
                        ['t25'] = {10, 0},
                        ['t20'] = {0, 10},
                        ['t15'] = {0, 10},
                        ['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,1,2,3,2,6,2,3,3,3,1,6,1,1,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",

    "item_bottle",
    "item_boots",
    "item_magic_wand",
    "item_dagon_2",
    "item_travel_boots",
    "item_aghanims_shard",
    "item_cyclone",
    "item_ultimate_scepter",
    "item_octarine_core",--
    "item_dagon_5",--
    "item_ultimate_scepter_2",
    "item_shivas_guard",
    "item_travel_boots_2",--
    "item_ethereal_blade",--
    "item_wind_waker",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_magic_stick",

    "item_boots",
    "item_magic_wand",
    "item_tranquil_boots",
    "item_aether_lens",
    "item_blink",
    "item_ancient_janggo",
    "item_aghanims_shard",
    "item_force_staff",--
    "item_boots_of_bearing",--
    "item_ultimate_scepter",
    "item_octarine_core",--
    "item_cyclone",
    "item_ethereal_blade",--
    "item_wind_waker",--
    "item_arcane_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_4'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_magic_stick",

    "item_boots",
    "item_magic_wand",
    "item_arcane_boots",
    "item_aether_lens",
    "item_blink",
    "item_mekansm",
    "item_aghanims_shard",
    "item_force_staff",--
    "item_guardian_greaves",--
    "item_ultimate_scepter",
    "item_octarine_core",--
    "item_cyclone",
    "item_ethereal_blade",--
    "item_wind_waker",--
    "item_arcane_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}
sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",

    "item_boots",
    "item_magic_wand",
    "item_dagon_2",
    "item_travel_boots",
    "item_aghanims_shard",
    "item_cyclone",
    "item_ultimate_scepter",
    "item_octarine_core",--
    "item_dagon_5",--
    "item_ultimate_scepter_2",
    "item_shivas_guard",
    "item_travel_boots_2",--
    "item_ethereal_blade",--
    "item_wind_waker",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_magic_stick",
    "item_ring_of_protection",

    "item_helm_of_iron_will",
    "item_boots",
    "item_magic_wand",
    "item_phase_boots",
    "item_veil_of_discord",
    "item_eternal_shroud",--
    "item_ultimate_scepter",
    "item_blink",
    "item_shivas_guard",--
    "item_black_king_bar",--
    "item_travel_boots",
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--
    "item_aghanims_shard",
    "item_moon_shard",
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
	
	"item_power_treads",
	"item_quelling_blade",

	"item_lotus_orb",
	"item_quelling_blade",

	"item_assault",
	"item_magic_wand",
	
	"item_travel_boots",
	"item_magic_wand",

	"item_assault",
	"item_ancient_janggo",
	
	"item_vladmir",
	"item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
    Minion.MinionThink(hMinionUnit, bot)
end

local Telekinesis       = bot:GetAbilityByName('rubick_telekinesis')
local TelekinesisLand   = bot:GetAbilityByName('rubick_telekinesis_land')
local FadeBolt          = bot:GetAbilityByName('rubick_fade_bolt')
-- local ArcaneSupremacy   = bot:GetAbilityByName('rubick_null_field')
local StolenSpell1      = bot:GetAbilityByName('rubick_empty1')
local StolenSpell2      = bot:GetAbilityByName('rubick_empty2')
local SpellSteal        = bot:GetAbilityByName('rubick_spell_steal')

local TelekinesisDesire, TelekinesisTarget
local TelekinesisLandDesire, TelekinesisLandLocation
local FadeBoltDesire, FadeBoltTarget
local SpellStealDesire, SpellStealTarget

local botTarget

if bot.shouldBlink == nil then bot.shouldBlink = false end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    -- if Rubick is in good health condition and is casting an ability with some enmey still nearby, don't consider any other spells.
    if J.GetHP(bot) > 0.3
    and not J.IsRetreating(bot)
    and (bot:IsChanneling()
    or bot:IsUsingAbility()
    or bot:IsCastingAbility())
    then
        local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 300, true, BOT_MODE_NONE)
        if nEnemyHeroes ~= nil and #nEnemyHeroes > 0 then
            return
        end
    end

    botTarget = J.GetProperTarget(bot)
    StolenSpell1 = bot:GetAbilityInSlot(3)
    StolenSpell2 = bot:GetAbilityInSlot(4)

    -- consider using whatever it has first
    X.ConsiderStolenSpell1()
    X.ConsiderStolenSpell2()

    -- consdier stealing
    SpellStealDesire, SpellStealTarget = X.ConsiderSpellSteal()
    if SpellStealDesire > 0
    then
        bot:Action_UseAbilityOnEntity(SpellSteal, SpellStealTarget)
        return
    end

    TelekinesisDesire, TelekinesisTarget = X.ConsiderTelekinesis()
    if TelekinesisDesire > 0
    then
        bot.teleTarget = TelekinesisTarget
        bot:Action_UseAbilityOnEntity(Telekinesis, TelekinesisTarget)
        return
    end

    TelekinesisLandDesire, TelekinesisLandLocation = X.ConsiderTelekinesisLand()
    if TelekinesisLandDesire > 0
    then
        bot:Action_UseAbilityOnLocation(TelekinesisLand, TelekinesisLandLocation)
        bot.isChannelLand = false
        bot.isSaveUltLand= false
        bot.isEngagingLand = false
        bot.isRetreatLand = false
        bot.isSaveAllyLand = false
        return
    end

    FadeBoltDesire, FadeBoltTarget = X.ConsiderFadeBolt()
    if FadeBoltDesire > 0
    then
        bot:Action_UseAbilityOnEntity(FadeBolt, FadeBoltTarget)
        return
    end
end

function X.ConsiderTelekinesis()
    if Telekinesis:IsHidden()
    or not Telekinesis:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Telekinesis:GetCastRange())

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 300, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                bot.isChannelLand = true
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if  J.IsValidHero(allyHero)
            and J.IsCore(allyHero)
            and not J.IsSuspiciousIllusion(allyHero)
            and not allyHero:IsInvulnerable()
            and not allyHero:IsAttackImmune()
            and not allyHero:HasModifier('modifier_furion_sprout_damage')
            and not allyHero:HasModifier('modifier_legion_commander_duel')
            and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                if allyHero:HasModifier('modifier_enigma_black_hole_pull')
                or allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                then
                    bot.isSaveUltLand = true
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end
        end

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + 150)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_furion_sprout_damage')
        and not botTarget:HasModifier('modifier_legion_commander_duel')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            nInRangeAlly =  J.GetAlliesNearLoc(botTarget:GetLocation(), 1200)
            nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            and not (#nInRangeEnemy == 0 and #nInRangeAlly >= #nInRangeEnemy + 2)
            then
                bot.isEngagingLand = true
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
		end
	end

    if J.IsRetreating(bot)
	then
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:HasModifier('modifier_furion_sprout_damage')
			then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and (#nTargetInRangeAlly > #nInRangeAlly
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    bot.isRetreatLand = true
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
			end
		end
	end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_furion_sprout_damage')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                bot.isSaveAllyLand = true
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

	if J.IsDoingRoshan(bot)
	then
        -- Remove Spell Block
		if  J.IsRoshan(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and botTarget:HasModifier('modifier_roshan_spell_block')
		then
			return BOT_ACTION_DESIRE_LOW, botTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderTelekinesisLand()
    if TelekinesisLand:IsHidden()
    or not TelekinesisLand:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nDistance = TelekinesisLand:GetSpecialValueInt('radius')
    local nTalent8 = bot:GetAbilityByName('special_bonus_unique_rubick_8')
    if nTalent8:IsTrained()
    then
        nDistance = nDistance + nTalent8:GetSpecialValueInt('value')
    end

    local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
    local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

    if  J.IsValidHero(botTarget)
    and not J.IsSuspiciousIllusion(botTarget)
    then
        nInRangeAlly = J.GetAlliesNearLoc(botTarget:GetLocation(), 1200)
        nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)
    end

    if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
    and bot.teleTarget ~= nil
    then
        if  bot.isChannelLand ~= nil
        and bot.isChannelLand == true
        then
            if #nInRangeAlly >= #nInRangeEnemy
            then
                if J.IsInRange(bot, bot.teleTarget, nDistance)
                then
                    return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
                end

                if not J.IsInRange(bot, bot.teleTarget, nDistance)
                then
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, bot:GetLocation(), nDistance)
                end
            end

            if #nInRangeEnemy > #nInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetEnemyFountain(), nDistance)
            end
        end

        if  bot.isSaveUltLand ~= nil
        and bot.isSaveUltLand == true
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nDistance)
        end

        if  bot.isEngagingLand ~= nil
        and bot.isEngagingLand == true
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end

        if  bot.isRetreatLand ~= nil
        and bot.isRetreatLand == true
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetEnemyFountain(), nDistance)
        end

        if  bot.isSaveAllyLand ~= nil
        and bot.isSaveAllyLand == true
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nDistance)
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFadeBolt()
    if not FadeBolt:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, FadeBolt:GetCastRange())
    local nDamage = FadeBolt:GetSpecialValueInt('damage')
    local nRadius = FadeBolt:GetSpecialValueInt('radius')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_rubick_telekinesis')
        then
            if J.IsInEtherealForm(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
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
            and J.IsAttacking(nAllyInRangeEnemy[1])
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_rubick_telekinesis')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange)
        local target = nil
        local hp = 100000

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_rubick_telekinesis')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                local nTargetInRangeAlly = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)
                local currHP = enemyHero:GetHealth()

                if  nTargetInRangeAlly ~= nil and #nTargetInRangeAlly >= 1
                and currHP < hp
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
        and not botTarget:HasModifier('modifier_rubick_telekinesis')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and J.IsAttacking(enemyHero)
            and not J.IsInRange(bot, enemyHero, 300)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
        end
    end

    if  J.IsLaning(bot)
    and not J.IsThereCoreNearby(800)
	then
        local creepList = {}
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
            and J.CanBeAttacked(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
            and J.GetMP(bot) > 0.3
			then
				if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) < 500
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end

            if  J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                table.insert(creepList, creep)
            end
		end

        if  J.GetMP(bot) > 0.3
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and #creepList >= 2
        and J.CanBeAttacked(creepList[1])
        then
            return BOT_ACTION_DESIRE_HIGH, creepList[1]
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not botTarget:HasModifier('modifier_roshan_spell_block')
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

function X.ConsiderStolenSpell1()
    if StolenSpell1:GetName() == 'rubick_empty1'
    or not StolenSpell1:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_HIGH, 0, ''
    end

    R.ConsiderStolenSpell(StolenSpell1)

    return BOT_ACTION_DESIRE_HIGH, 0, ''
end

function X.ConsiderStolenSpell2()
    if StolenSpell2:GetName() == 'rubick_empty2'
    or not StolenSpell2:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_HIGH, 0, ''
    end

    R.ConsiderStolenSpell(StolenSpell2)

    return BOT_ACTION_DESIRE_HIGH, 0, ''
end

function X.ConsiderSpellSteal()
    if not SpellSteal:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, SpellSteal:GetCastRange())

    local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange + 300)
    for _, enemyHero in pairs(nInRangeEnemy)
    do
        -- print("Rubick considering spell steal on an enemy...")
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        -- and X.ShouldStealSpellFrom(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsMeepoClone(enemyHero)
        then
            -- print("Rubick considering spell steal on a valid target enemy...")
            if enemyHero:IsUsingAbility()
            or enemyHero:IsCastingAbility()
            or J.IsCastingUltimateAbility(enemyHero)
            then
                -- print("Rubick considering spell steal on a valid target enemy that casted an ability...")
                local ss1Weight = SPL.GetSpellReplaceWeight(StolenSpell1) * 100
                local ranInt = RandomInt(1, 70)
                -- print("Rubick considering spell steal on a valid target enemy that casted an ability: weight="..ss1Weight..", random int="..ranInt)
                
                if bot:HasScepter()
                then
                    local ss2Weight = SPL.GetSpellReplaceWeight(StolenSpell2) * 100

                    if ss1Weight * 100 >= ranInt
                    and ss2Weight * 100 >= RandomInt(1, 70)
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemyHero
                    end

                    if ss2Weight * 100 >= ranInt
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemyHero
                    end
                else
                    if ss1Weight * 100 >= ranInt
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemyHero
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ShouldStealSpellFrom(hero)
    local HeroNames = {
        ['npc_dota_hero_abaddon'] = true,
        ['npc_dota_hero_abyssal_underlord'] = true,
        ['npc_dota_hero_alchemist'] = true,
        ['npc_dota_hero_ancient_apparition'] = true,
        ['npc_dota_hero_antimage'] = true,
        ['npc_dota_hero_arc_warden'] = true,
        ['npc_dota_hero_axe'] = true,
        ['npc_dota_hero_bane'] = true,
        ['npc_dota_hero_batrider'] = true,
        ['npc_dota_hero_beastmaster'] = true,
        ['npc_dota_hero_bloodseeker'] = true,
        ['npc_dota_hero_bounty_hunter'] = true,
        ['npc_dota_hero_brewmaster'] = true,
        ['npc_dota_hero_bristleback'] = true,
        ['npc_dota_hero_broodmother'] = true,
        ['npc_dota_hero_centaur'] = true,
        ['npc_dota_hero_chaos_knight'] = true,
        ['npc_dota_hero_chen'] = true,
        ['npc_dota_hero_clinkz'] = true,
        ['npc_dota_hero_crystal_maiden'] = true,
        -- ['npc_dota_hero_dark_seer'] = true,
        -- ['npc_dota_hero_dark_willow'] = false,
        -- ['npc_dota_hero_dawnbreaker'] = false,
        -- ['npc_dota_hero_dazzle'] = false,
        -- ['npc_dota_hero_disruptor'] = true,
        -- ['npc_dota_hero_death_prophet'] = false,
        -- ['npc_dota_hero_doom_bringer'] = false,
        -- ['npc_dota_hero_dragon_knight'] = true,
        -- ['npc_dota_hero_drow_ranger'] = ,
        -- ['npc_dota_hero_earth_spirit'] = ,
        -- ['npc_dota_hero_earthshaker'] = ,
        -- ['npc_dota_hero_elder_titan'] = ,
        -- ['npc_dota_hero_ember_spirit'] = ,
        -- ['npc_dota_hero_enchantress'] = ,
        -- ['npc_dota_hero_enigma'] = ,
        -- ['npc_dota_hero_faceless_void'] = ,
        -- ['npc_dota_hero_furion'] = ,
        -- ['npc_dota_hero_grimstroke'] = ,
        -- ['npc_dota_hero_gyrocopter'] = ,
        -- ['npc_dota_hero_hoodwink'] = ,
        -- ['npc_dota_hero_huskar'] = ,
        -- ['npc_dota_hero_invoker'] = ,
        -- ['npc_dota_hero_jakiro'] = ,
        -- ['npc_dota_hero_juggernaut'] = ,
        -- ['npc_dota_hero_keeper_of_the_light'] = ,
        -- ['npc_dota_hero_kunkka'] = ,
        -- ['npc_dota_hero_legion_commander'] = ,
        -- ['npc_dota_hero_leshrac'] = ,
        -- ['npc_dota_hero_lich'] = ,
        -- ['npc_dota_hero_life_stealer'] = ,
        -- ['npc_dota_hero_lina'] = ,
        -- ['npc_dota_hero_lion'] = ,
        -- ['npc_dota_hero_lone_druid'] = ,
        -- ['npc_dota_hero_luna'] = ,
        -- ['npc_dota_hero_lycan'] = ,
        -- ['npc_dota_hero_magnataur'] = ,
        -- ['npc_dota_hero_marci'] = ,
        -- ['npc_dota_hero_mars'] = ,
        -- ['npc_dota_hero_medusa'] = ,
        -- ['npc_dota_hero_meepo'] = ,
        -- ['npc_dota_hero_mirana'] = ,
        -- ['npc_dota_hero_morphling'] = ,
        -- ['npc_dota_hero_monkey_king'] = ,
        -- ['npc_dota_hero_naga_siren'] = ,
        -- ['npc_dota_hero_necrolyte'] = ,
        -- ['npc_dota_hero_nevermore'] = ,
        -- ['npc_dota_hero_night_stalker'] = ,
        -- ['npc_dota_hero_nyx_assassin'] = ,
        -- ['npc_dota_hero_obsidian_destroyer'] = ,
        -- ['npc_dota_hero_ogre_magi'] = ,
        -- ['npc_dota_hero_omniknight'] = ,
        -- ['npc_dota_hero_oracle'] = ,
        -- ['npc_dota_hero_pangolier'] = ,
        -- ['npc_dota_hero_phantom_lancer'] = ,
        -- ['npc_dota_hero_phantom_assassin'] = ,
        -- ['npc_dota_hero_phoenix'] = ,
        -- ['npc_dota_hero_primal_beast'] = ,
        -- ['npc_dota_hero_puck'] = ,
        -- ['npc_dota_hero_pudge'] = ,
        -- ['npc_dota_hero_pugna'] = ,
        -- ['npc_dota_hero_queenofpain'] = ,
        -- ['npc_dota_hero_rattletrap'] = ,
        -- ['npc_dota_hero_razor'] = ,
        -- ['npc_dota_hero_riki'] = ,
        -- ['npc_dota_hero_rubick'] = ,
        -- ['npc_dota_hero_sand_king'] = ,
        -- ['npc_dota_hero_shadow_demon'] = ,
        -- ['npc_dota_hero_shadow_shaman'] = ,
        -- ['npc_dota_hero_shredder'] = ,
        -- ['npc_dota_hero_silencer'] = ,
        -- ['npc_dota_hero_skeleton_king'] = ,
        -- ['npc_dota_hero_skywrath_mage'] = ,
        -- ['npc_dota_hero_slardar'] = ,
        -- ['npc_dota_hero_slark'] = ,
        -- ["npc_dota_hero_snapfire"] = ,
        -- ['npc_dota_hero_sniper'] = ,
        -- ['npc_dota_hero_spectre'] = ,
        -- ['npc_dota_hero_spirit_breaker'] = ,
        -- ['npc_dota_hero_storm_spirit'] = ,
        -- ['npc_dota_hero_sven'] = ,
        -- ['npc_dota_hero_techies'] = ,
        -- ['npc_dota_hero_terrorblade'] = ,
        -- ['npc_dota_hero_templar_assassin'] = ,
        -- ['npc_dota_hero_tidehunter'] = ,
        -- ['npc_dota_hero_tinker'] = ,
        -- ['npc_dota_hero_tiny'] = ,
        -- ['npc_dota_hero_treant'] = ,
        -- ['npc_dota_hero_troll_warlord'] = ,
        -- ['npc_dota_hero_tusk'] = ,
        -- ['npc_dota_hero_undying'] = ,
        -- ['npc_dota_hero_ursa'] = ,
        -- ['npc_dota_hero_vengefulspirit'] = ,
        -- ['npc_dota_hero_venomancer'] = ,
        -- ['npc_dota_hero_viper'] = ,
        -- ['npc_dota_hero_visage'] = ,
        -- ['npc_dota_hero_void_spirit'] = ,
        -- ['npc_dota_hero_warlock'] = ,
        -- ['npc_dota_hero_weaver'] = ,
        -- ['npc_dota_hero_windrunner'] = ,
        -- ['npc_dota_hero_winter_wyvern'] = ,
        -- ['npc_dota_hero_wisp'] = ,
        -- ['npc_dota_hero_witch_doctor'] = ,
        -- ['npc_dota_hero_zuus'] = ,
    }

    return HeroNames[hero:GetUnitName()]
end

return X