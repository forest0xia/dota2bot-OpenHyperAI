local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,2,1,6,1,2,2,3,6,3,3,3,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_double_circlet",

    "item_bottle",
    "item_soul_ring",
    "item_magic_wand",
    "item_blink",
    "item_shivas_guard",--
    "item_ethereal_blade",--
    "item_black_king_bar",--
    "item_overwhelming_blink",--
    "item_sheepstick",--
    "item_sphere",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_5']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_circlet",
    "item_magic_wand",
    "item_bottle",
    "item_soul_ring",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Laser                 = bot:GetAbilityByName('tinker_laser')
local HeatSeekingMissile    = bot:GetAbilityByName('tinker_heat_seeking_missile')
local DefenseMatrix         = bot:GetAbilityByName('tinker_defense_matrix')
local WarpFlare             = bot:GetAbilityByName('tinker_warp_grenade')
local KeenConveyance        = bot:GetAbilityByName('tinker_keen_teleport')
local Rearm                 = bot:GetAbilityByName('tinker_rearm')

local LaserDesire, LaserTarget
local HeatSeekingMissileDesire
local DefenseMatrixDesire, DefenseMatrixTarget
local WarpFlareDesire, WarpFlareTarget
local KeenConveyanceDesire, KeenConveyanceTargetLocation
local RearmDesire

local botTarget

local Blink = nil
local BlinkLocation

local SoulRing = nil
local ShivasGuard = nil
local EtherealBlade = nil
local ScytheOfVyse = nil

local ComboDesire, ComboTarget
local ClearCreepsDesire, ClearCreepsTarget

if bot.healInBase == nil then bot.healInBase = false end
if bot.shouldBlink == nil then bot.shouldBlink = false end

function X.SkillsComplement()
    if J.CanNotUseAbility(bot)
    or Rearm:IsInAbilityPhase()
    or KeenConveyance:IsInAbilityPhase()
    or bot:HasModifier('modifier_tinker_rearm')
    or bot:HasModifier('modifier_teleporting')
    then
        return
    end

    botTarget = J.GetProperTarget(bot)

    if  not J.IsGoingOnSomeone(bot)
    and not J.IsDoingRoshan(bot)
    and not J.IsDoingTormentor(bot)
    then
        if not bot.healInBase
        then
            if J.IsInLaningPhase()
            then
                if Rearm:GetManaCost() > bot:GetMana()
                or J.GetHP(bot) < 0.35
                then
                    bot.healInBase = true
                end
            else
                if J.GetMP(bot) < 0.3
                or J.GetHP(bot) < 0.35
                then
                    bot.healInBase = true
                end
            end
        else
            if J.GetMP(bot) > 0.8
            then
                bot.healInBase = false
            end
        end
    end

    DefenseMatrixDesire, DefenseMatrixTarget = X.ConsiderDefenseMatrix()
    if DefenseMatrixDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DefenseMatrix, DefenseMatrixTarget)
        return
    end

    ComboDesire, ComboTarget, ComboFlag = X.ConsiderCombos()
    if  ComboDesire > 0
    and ComboFlag > 0
    then
        bot:Action_ClearActions(false)
        SoulRing = J.GetItem('item_soul_ring')
        if SoulRing ~= nil and SoulRing:IsFullyCastable()
        then
            bot:ActionQueue_UseAbility(SoulRing)
        end

        -- Will do more later..
        if ComboFlag == 1
        then
            bot:ActionQueue_UseAbility(HeatSeekingMissile)
            bot:ActionQueue_Delay(1.2)
            bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
            bot:ActionQueue_Delay(0.1)
            bot:ActionQueue_UseAbilityOnEntity(Laser, ComboTarget)
            bot:ActionQueue_Delay(0.5)
            bot:ActionQueue_UseAbility(Rearm)
            bot:ActionQueue_Delay(Rearm:GetChannelTime())
            bot:ActionQueue_UseAbilityOnLocation(Blink, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), Laser:GetCastRange()))
        elseif ComboFlag == 2
        then
            bot:ActionQueue_UseAbility(HeatSeekingMissile)
            bot:ActionQueue_Delay(1.2)
            bot:ActionQueue_UseAbility(ShivasGuard)
            bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
            bot:ActionQueue_Delay(0.1)
            bot:ActionQueue_UseAbilityOnEntity(Laser, ComboTarget)
            bot:ActionQueue_Delay(0.5)
            bot:ActionQueue_UseAbility(Rearm)
            bot:ActionQueue_Delay(Rearm:GetChannelTime())
            bot:ActionQueue_UseAbilityOnLocation(Blink, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), Laser:GetCastRange()))
        elseif ComboFlag == 3
        then
            bot:ActionQueue_UseAbility(HeatSeekingMissile)
            bot:ActionQueue_Delay(1.2)
            bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
            bot:ActionQueue_Delay(0.1)
            bot:ActionQueue_UseAbilityOnEntity(ScytheOfVyse, ComboTarget)
            bot:ActionQueue_UseAbilityOnEntity(Laser, ComboTarget)
            bot:ActionQueue_Delay(0.5)
            bot:ActionQueue_UseAbility(Rearm)
            bot:ActionQueue_Delay(Rearm:GetChannelTime())
            bot:ActionQueue_UseAbilityOnLocation(Blink, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), Laser:GetCastRange()))
        elseif ComboFlag == 4
        then
            bot:ActionQueue_UseAbility(HeatSeekingMissile)
            bot:ActionQueue_Delay(1.2)
            bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
            bot:ActionQueue_Delay(0.1)
            bot:ActionQueue_UseAbilityOnEntity(EtherealBlade, ComboTarget)
            bot:ActionQueue_UseAbilityOnEntity(Laser, ComboTarget)
            bot:ActionQueue_Delay(0.5)
            bot:ActionQueue_UseAbility(Rearm)
            bot:ActionQueue_Delay(Rearm:GetChannelTime())
            bot:ActionQueue_UseAbilityOnLocation(Blink, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), Laser:GetCastRange()))
        elseif ComboFlag == 5
        then
            bot:ActionQueue_UseAbility(HeatSeekingMissile)
            bot:ActionQueue_Delay(1.2)
            bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
            bot:ActionQueue_Delay(0.1)
            bot:ActionQueue_UseAbilityOnEntity(ScytheOfVyse, ComboTarget)
            bot:ActionQueue_UseAbilityOnEntity(EtherealBlade, ComboTarget)
            bot:ActionQueue_UseAbilityOnEntity(Laser, ComboTarget)
            bot:ActionQueue_Delay(0.5)
            bot:ActionQueue_UseAbility(Rearm)
            bot:ActionQueue_Delay(Rearm:GetChannelTime())
            bot:ActionQueue_UseAbilityOnLocation(Blink, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), Laser:GetCastRange()))
        end

        return
    end

    ClearCreepsDesire, ClearCreepsTarget, CreepClearFlag = X.ConsiderClearCreeps()
    if  ClearCreepsDesire > 0
    and CreepClearFlag > 0
    then
        bot:Action_ClearActions(false)
        if  J.HasItem(bot, 'item_soul_ring')
        and SoulRing ~= nil and SoulRing:IsFullyCastable()
        then
            bot:ActionQueue_UseAbility(SoulRing)
        end

        if CreepClearFlag == 1
        then
            if  not J.IsInRange(bot, ClearCreepsTarget, Laser:GetCastRange())
            and Blink ~= nil and Blink:GetName() ~= 'item_overwhelming_blink'
            then
                bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
                bot:ActionQueue_Delay(0.1)
            else
                if Blink ~= nil and Blink:GetName() == 'item_overwhelming_blink'
                then
                    bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
                    bot:ActionQueue_Delay(0.1)
                end
            end

            bot:ActionQueue_UseAbilityOnEntity(Laser, ClearCreepsTarget)
            bot:ActionQueue_Delay(0.5)
            bot:ActionQueue_UseAbility(Rearm)
            bot:ActionQueue_Delay(Rearm:GetChannelTime())
            bot:ActionQueue_UseAbilityOnLocation(Blink, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), Laser:GetCastRange()))
        elseif CreepClearFlag == 2
        then
            if  not J.IsInRange(bot, ClearCreepsTarget, Laser:GetCastRange())
            and Blink ~= nil and Blink:GetName() ~= 'item_overwhelming_blink'
            then
                bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
                bot:ActionQueue_Delay(0.1)
            else
                if Blink ~= nil and Blink:GetName() == 'item_overwhelming_blink'
                then
                    bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
                    bot:ActionQueue_Delay(0.1)
                end
            end

            bot:ActionQueue_UseAbility(ShivasGuard)
            bot:ActionQueue_UseAbilityOnEntity(Laser, ClearCreepsTarget)
            bot:ActionQueue_Delay(0.5)
            bot:ActionQueue_UseAbility(Rearm)
            bot:ActionQueue_Delay(Rearm:GetChannelTime())
            bot:ActionQueue_UseAbilityOnLocation(Blink, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), Laser:GetCastRange()))
        end

        return
    end

    BlinkDesire = X.ConsiderBlink()
    if BlinkDesire > 0
    then
        bot:Action_ClearActions(false)
        bot:Action_UseAbilityOnLocation(Blink, BlinkLocation)
        return
    end

    HeatSeekingMissileDesire = X.ConsiderHeatSeekingMissile()
    if HeatSeekingMissileDesire > 0
    then
        bot:Action_UseAbility(HeatSeekingMissile)
        return
    end

    LaserDesire, LaserTarget = X.ConsiderLaser()
    if LaserDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Laser, LaserTarget)
        return
    end

    WarpFlareDesire, WarpFlareTarget = X.ConsiderWarpFlare()
    if WarpFlareDesire > 0
    then
        bot:ActionQueue_UseAbilityOnEntity(WarpFlare, WarpFlareTarget)
        return
    end

    RearmDesire = X.ConsiderRearm()
    if RearmDesire > 0
    then
        bot:Action_UseAbility(Rearm)
        return
    end

    KeenConveyanceDesire, KeenConveyanceTargetLocation, Type = X.ConsiderKeenConveyance()
    if KeenConveyanceDesire > 0
    then
        if Type == 'unit'
        then
            bot:Action_UseAbilityOnEntity(KeenConveyance, KeenConveyanceTargetLocation)
        else
            bot:Action_UseAbilityOnLocation(KeenConveyance, KeenConveyanceTargetLocation)
        end

        return
    end

    ShivasGuardDesire = X.ConsiderShivasGuard()
    if ShivasGuardDesire > 0
    then
        bot:Action_UseAbility(ShivasGuard)
        return
    end

    SoulRingDesire = X.ConsiderSoulRing()
    if SoulRingDesire > 0
    then
        bot:Action_UseAbility(SoulRing)
        return
    end
end

function X.ConsiderLaser()
    if not Laser:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Laser:GetCastRange())
    local nDamage = Laser:GetSpecialValueInt('laser_damage')
    local nRadius = Laser:GetSpecialValueInt('radius_explosion')

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PURE)
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

	if  J.IsGoingOnSomeone(bot)
    and (not CanDoCombo1()
        and not CanDoCombo2()
        and not CanDoCombo3()
        and not CanDoCombo4()
        and not CanDoCombo5())
	then
        if  J.IsValidHero(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not botTarget:HasModifier('modifier_item_blade_mail_reflect')
        and not botTarget:HasModifier('modifier_item_sphere_target')
        then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), 1200, nRadius, 0, 0)
        if J.IsAttacking(bot)
        then
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)
            if  nEnemyLaneCreeps ~= nil
            and #nEnemyLaneCreeps >= 2 and nLocationAoE.count >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
            end
        end
    end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        then
            local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), 1200, nRadius, 0, 0)
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1000)

            if  nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 2 and nLocationAoE.count >= 2) or (#nNeutralCreeps == 1 and nNeutralCreeps[1]:IsAncientCreep() and nLocationAoE.count >= 1))
            then
                return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)
            if  nEnemyLaneCreeps ~= nil
            and #nEnemyLaneCreeps >= 2 and nLocationAoE.count >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
            end
        end
    end

    if J.IsLaning(bot)
	then
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
            and J.CanBeAttacked(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
			then
				if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) < 600
                and J.GetMP(bot) > 0.3
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end

            if  J.IsValid(creep)
            and J.CanBeAttacked(creep)
            then
                creepList = J.GetCreepListAroundTargetCanKill(creep, nRadius, nDamage, true, false, true)

                if  #creepList >= 2
                and J.GetMP(bot) > 0.25
                then
                    return BOT_ACTION_DESIRE_HIGH, creep
                end
            end
		end

        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.IsInLaningPhase(bot)
        then
            local nAllyTowers = bot:GetNearbyTowers(1600, false)
            if  nAllyTowers ~= nil and #nAllyTowers >= 1
            and J.IsValidBuilding(nAllyTowers[1])
            and J.IsValidHero(nInRangeEnemy[1])
            and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
            and J.GetManaAfter(Laser:GetManaCost()) > 0.5
            and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
            and not nInRangeEnemy[1]:HasModifier('modifier_abaddon_borrowed_time')
            and not nInRangeEnemy[1]:HasModifier('modifier_dazzle_shallow_grave')
            and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            and not nInRangeEnemy[1]:HasModifier('modifier_templar_assassin_refraction_absorb')
            and not nInRangeEnemy[1]:HasModifier('modifier_item_blade_mail_reflect')
            and not nInRangeEnemy[1]:HasModifier('modifier_item_sphere_target')
            and GetUnitToUnitDistance(nInRangeEnemy[1], nAllyTowers[1]) < 680
            and nAllyTowers[1]:GetAttackTarget() == nInRangeEnemy[1]
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_roshan_spell_block')
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

function X.ConsiderHeatSeekingMissile()
    if not HeatSeekingMissile:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = HeatSeekingMissile:GetSpecialValueInt('radius')
	local nDamage = HeatSeekingMissile:GetSpecialValueInt('damage')

    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:IsMagicImmune()
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	if  J.IsGoingOnSomeone(bot)
    and (not CanDoCombo1()
        and not CanDoCombo2()
        and not CanDoCombo3()
        and not CanDoCombo4()
        and not CanDoCombo5())
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if #nInRangeEnemy == 0
                then
                    if  not botTarget:IsMagicImmune()
                    and not J.IsSuspiciousIllusion(botTarget)
                    and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
                    and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
                    and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
                    and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                else
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not enemyHero:IsMagicImmune()
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
	end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)
        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsLaning(bot)
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.IsInLaningPhase(bot)
        then
            local nAllyTowers = bot:GetNearbyTowers(1600, false)
            if  nAllyTowers ~= nil and #nAllyTowers >= 1
            and J.IsValidBuilding(nAllyTowers[1])
            and J.IsValidHero(nInRangeEnemy[1])
            and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
            and J.GetManaAfter(HeatSeekingMissile:GetManaCost()) > 0.4
            and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
            and not nInRangeEnemy[1]:IsMagicImmune()
            and not nInRangeEnemy[1]:HasModifier('modifier_abaddon_borrowed_time')
            and not nInRangeEnemy[1]:HasModifier('modifier_dazzle_shallow_grave')
            and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            and not nInRangeEnemy[1]:HasModifier('modifier_templar_assassin_refraction_absorb')
            and not nInRangeEnemy[1]:HasModifier('modifier_item_blade_mail_reflect')
            and not nInRangeEnemy[1]:HasModifier('modifier_item_sphere_target')
            and GetUnitToUnitDistance(nInRangeEnemy[1], nAllyTowers[1]) < 680
            and nAllyTowers[1]:GetAttackTarget() == nInRangeEnemy[1]
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDefenseMatrix()
    if not DefenseMatrix:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, DefenseMatrix:GetCastRange())

	if J.IsGoingOnSomeone(bot)
    then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetCurrentVisionRange())
        and not bot:HasModifier('modifier_tinker_defense_matrix')
        then
            return BOT_ACTION_DESIRE_HIGH, bot
	    end
    end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and bot:WasRecentlyDamagedByAnyHero(0.5)
            and not bot:HasModifier('modifier_tinker_defense_matrix')
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
	end

    if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
    then
        if  (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            if  J.GetHP(bot) < 0.5
            and not bot:HasModifier('modifier_abaddon_aphotic_shield')
            and not bot:HasModifier('modifier_tinker_defense_matrix')
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end

            local target = nil
            local hp = 0
            local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
            for _, allyHero in pairs(nInRangeAlly)
            do
                if  J.IsValidHero(allyHero)
                and not J.IsSuspiciousIllusion(allyHero)
                and not allyHero:HasModifier('modifier_abaddon_aphotic_shield')
                and not allyHero:HasModifier('modifier_tinker_defense_matrix')
                and hp < allyHero:GetHealth()
                then
                    hp = allyHero:GetHealth()
                    target = allyHero
                end
            end

            if target ~= nil
            then
                return BOT_ACTION_DESIRE_HIGH, target
            end
        end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
	do
        if  J.IsValidHero(allyHero)
        and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
        and (allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or allyHero:HasModifier('modifier_enigma_black_hole_pull')
            or allyHero:HasModifier('modifier_legion_commander_duel'))
        then
            return BOT_ACTION_DESIRE_HIGH, allyHero
        end

        if  J.IsValidHero(allyHero)
        and J.IsDisabled(allyHero)
        and not allyHero:IsMagicImmune()
		and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
        then
            return BOT_ACTION_DESIRE_HIGH, allyHero
        end

		if  J.IsValidHero(allyHero)
        and not allyHero:HasModifier('modifier_abaddon_aphotic_shield')
        and not allyHero:HasModifier('modifier_item_solar_crest_armor_addition')
		and not allyHero:IsMagicImmune()
		and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
        and J.IsNotSelf(bot, allyHero)
		then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(800, true, BOT_MODE_NONE)

            if  J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.6)
            and not allyHero:IsIllusion()
            then
                if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
                and J.IsValidHero(nAllyInRangeEnemy[1])
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
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end

			if J.IsGoingOnSomeone(allyHero)
			then
				local allyTarget = allyHero:GetAttackTarget()

				if  J.IsValidHero(allyTarget)
				and J.IsInRange(allyHero, allyTarget, allyHero:GetAttackRange())
                and not J.IsSuspiciousIllusion(allyTarget)
                and not allyTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not allyTarget:HasModifier('modifier_enigma_black_hole_pull')
                and not allyTarget:HasModifier('modifier_necrolyte_reapers_scythe')
				then
                    local nAllInRangeAlly = allyHero:GetNearbyHeroes(800, false, BOT_MODE_NONE)
                    local nTargetInRangeAlly = allyTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE)

                    if  nAllInRangeAlly ~= nil and  nTargetInRangeAlly ~= nil
                    and #nAllInRangeAlly >= #nTargetInRangeAlly
                    then
                        return BOT_ACTION_DESIRE_HIGH, allyHero
                    end
				end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderKeenConveyance()
    if not KeenConveyance:IsFullyCastable()
    or (bot.healInBase and GetUnitToLocationDistance(bot, J.GetTeamFountain()) < 1000)
    then
        return BOT_ACTION_DESIRE_NONE, nil, ''
    end

    local RoshanLocation = J.GetCurrentRoshanLocation()
    local TormentorLocation = J.GetTormentorLocation(GetTeam())
    local nAbilityLevel = KeenConveyance:GetLevel()
    local nMode = bot:GetActiveMode()
    local nChannelTime = KeenConveyance:GetChannelTime()
    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), bot:GetCurrentVisionRange())

    if  bot.healInBase
    and GetUnitToLocationDistance(bot, J.GetTeamFountain()) > 3200
    and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
    then
        if J.IsInLaningPhase()
        then
            if GetLaneFrontAmount(GetTeam(), LANE_MID, true) < 0.28
            then
                if bot:GetHealth() > J.GetTotalEstimatedDamageToTarget(nEnemyHeroes, bot)
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain(), 'loc'
                end
            end
        end

        return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain(), 'loc'
    end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if  nTeamFightLocation ~= nil
    and J.GetMP(bot) > 0.65
    and not J.IsRetreating(bot)
    then
        if GetUnitToLocationDistance(bot, nTeamFightLocation) > 4100
        then
            if nAbilityLevel <= 2
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetNearbyLocationToTp(nTeamFightLocation), 'loc'
            else
                local nInRangeAlly = J.GetAlliesNearLoc(nTeamFightLocation, 1000)
                if nInRangeAlly ~= nil and #nInRangeAlly >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, nInRangeAlly[1], 'unit'
                end
            end
        end
    end

    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if  J.IsValidHero(allyHero)
        and J.IsGoingOnSomeone(allyHero)
        and J.GetMP(bot) > 0.65
        and GetUnitToUnitDistance(bot, allyHero) > 3200
        and bot:GetLevel() >= 6
        and not J.IsSuspiciousIllusion(allyHero)
        then
            local allyTarget = allyHero:GetAttackTarget()

            if  J.IsValidTarget(allyTarget)
            and J.IsInRange(allyHero, allyTarget, 1000)
            and not J.IsSuspiciousIllusion(allyTarget)
            then
                local nAllyInRangeAlly = allyTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = allyTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nAllyInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nAllyInRangeAlly >= #nTargetInRangeAlly
                and #nAllyInRangeAlly >= 1
                then
                    if nAbilityLevel <= 2
                    then
                        if GetUnitToLocationDistance(allyHero, J.GetNearbyLocationToTp(allyTarget:GetExtrapolatedLocation(nChannelTime))) < 1000
                        then
                            bot:SetTarget(allyTarget)
                            return BOT_ACTION_DESIRE_HIGH, J.GetNearbyLocationToTp(allyTarget:GetExtrapolatedLocation(nChannelTime)), 'loc'
                        end
                    else
                        bot:SetTarget(allyTarget)
                        return BOT_ACTION_DESIRE_HIGH, allyHero, 'unit'
                    end
                end
            end
        end
    end

    if  J.IsLaning(bot)
    and J.IsInLaningPhase()
    then
        local botAmount = GetAmountAlongLane(LANE_MID, bot:GetLocation())
        local laneFront = GetLaneFrontAmount(GetTeam(), LANE_MID, false)
        if botAmount.distance > 4100
        or botAmount.amount < laneFront / 5
        then
            return BOT_ACTION_DESIRE_HIGH, GetLaneFrontLocation(GetTeam(), LANE_MID, -300), 'loc'
        end
    end

    if  J.IsPushing(bot)
    and bot:GetActiveModeDesire() > 0.5
    and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
    then
        local nPushLane = LANE_MID
		if nMode == BOT_MODE_PUSH_TOWER_TOP then nPushLane = LANE_TOP end
		if nMode == BOT_MODE_PUSH_TOWER_BOT then nPushLane = LANE_BOT end

		local botAmount = GetAmountAlongLane(nPushLane, bot:GetLocation())
		local laneFront = GetLaneFrontAmount(GetTeam(), nPushLane, false)
		if botAmount.distance > 3200
		or botAmount.amount < laneFront / 5
		then
            if nAbilityLevel == 3
            then
                local nInRangeAlly = J.GetAlliesNearLoc(GetLaneFrontLocation(GetTeam(), nPushLane, 0), 1600)
                if  nInRangeAlly ~= nil and #nInRangeAlly >= 1
                and GetUnitToUnitDistance(bot, nInRangeAlly[1]) > 3200
                then
                    return BOT_ACTION_DESIRE_HIGH, nInRangeAlly[1], 'unit'
                end
            end

            local loc = J.GetPushTPLocation(nPushLane)
            if loc ~= nil
            then
                if GetUnitToLocationDistance(bot, loc) > 3200
                then
                    return BOT_ACTION_DESIRE_HIGH, loc, 'loc'
                end
            end
		end
    end

    if  J.IsDefending(bot)
    and bot:GetActiveModeDesire() > 0.5
    and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
	then
		local nDefendLane = LANE_MID
		if nMode == BOT_MODE_DEFEND_TOWER_TOP then nDefendLane = LANE_TOP end
		if nMode == BOT_MODE_DEFEND_TOWER_BOT then nDefendLane = LANE_BOT end

		local botAmount = GetAmountAlongLane(nDefendLane, bot:GetLocation())
		local laneFront = GetLaneFrontAmount(GetTeam(), nDefendLane, false)
		if botAmount.distance > 3200
		or botAmount.amount < laneFront / 5
		then
			if GetUnitToLocationDistance(bot, J.GetDefendTPLocation(nDefendLane)) > 3200
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetDefendTPLocation(nDefendLane), 'loc'
            end
		end
	end

    if J.IsFarming(bot)
    then
        local mostFarmDesireLane, mostFarmDesire = J.GetMostFarmLaneDesire()

        if mostFarmDesire > 0.1
        then
            local farmTpLoc = GetLaneFrontLocation(GetTeam(), mostFarmDesireLane, 0)
            local bestTpLoc = J.GetNearbyLocationToTp(farmTpLoc)

            if  bestTpLoc ~= nil and farmTpLoc ~= nil
            and J.IsLocHaveTower(2000, false, farmTpLoc)
            and GetUnitToLocationDistance( bot, bestTpLoc) > 3200
            then
                return BOT_ACTION_DESIRE_HIGH, farmTpLoc, 'loc'
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        local nInRangeAlly = J.GetAlliesNearLoc(RoshanLocation, 800)
        if  nInRangeAlly ~= nil and #nInRangeAlly >= 1
        and GetUnitToLocationDistance(bot, RoshanLocation) > 3800
        and GetUnitToLocationDistance(bot, J.GetNearbyLocationToTp(RoshanLocation)) > 3800
        then
            if nAbilityLevel <= 2
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetNearbyLocationToTp(RoshanLocation), 'loc'
            else
                return BOT_ACTION_DESIRE_HIGH, nInRangeAlly[1], 'unit'
            end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        local nInRangeAlly = J.GetAlliesNearLoc(TormentorLocation, 800)
        if  nInRangeAlly ~= nil and #nInRangeAlly >= 2
        and GetUnitToLocationDistance(bot, TormentorLocation) > 3800
        and GetUnitToLocationDistance(bot, J.GetNearbyLocationToTp(TormentorLocation)) > 3800
        then
            if nAbilityLevel <= 2
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetNearbyLocationToTp(TormentorLocation), 'loc'
            else
                return BOT_ACTION_DESIRE_HIGH, nInRangeAlly[1], 'unit'
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, ''
end

function X.ConsiderRearm()
    if not Rearm:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
    if  bot.healInBase
    and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
    and KeenConveyance:IsTrained() and KeenConveyance:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if Laser:IsTrained() and Laser:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
    then
        return BOT_ACTION_DESIRE_HIGH
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 1500)
        and (HeatSeekingMissile:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
            or Blink ~= nil and not Blink:IsFullyCastable())
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    if  J.IsPushing(bot)
    and bot:GetActiveModeDesire() > 0.5
    then
        if  GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0)) > 4000
        and KeenConveyance:IsTrained() and KeenConveyance:GetCooldownTimeRemaining() > 5
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if Laser:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1500, 1500, 0, 0)
        nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, 1500)
        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and HeatSeekingMissile:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if  J.IsDefending(bot)
    and bot:GetActiveModeDesire() > 0.5
    then
        if  GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToDefend, 0)) > 3800
        and KeenConveyance:IsTrained() and KeenConveyance:GetCooldownTimeRemaining() > 5
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if Laser:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1500, 1500, 0, 0)
        nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, 1500)
        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and HeatSeekingMissile:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(800)
            if  nNeutralCreeps ~= nil
            and (#nNeutralCreeps >= 2 or (#nNeutralCreeps >= 1 and nNeutralCreeps[1]:IsAncientCreep()))
            and J.GetMP(bot) > 0.25
            and Laser:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
            and J.GetMP(bot) > 0.25
            and Laser:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and DefenseMatrix:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and DefenseMatrix:GetCooldownTimeRemaining() > Rearm:GetChannelTime()
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderWarpFlare()
    if not WarpFlare:IsTrained()
    or not WarpFlare:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, WarpFlare:GetCastRange())

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

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
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeEnemy > #nInRangeAlly
        then
            local target = nil
            local dmg = 0

            nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange)
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if  J.IsValidHero(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
                and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    local currDmg = enemyHero:GetEstimatedDamageToTarget(true, bot, 5, DAMAGE_TYPE_ALL)
                    if currDmg > dmg
                    then
                        dmg = currDmg
                        target = enemyHero
                    end
                end
            end

            if target ~= nil
            then
                return BOT_ACTION_DESIRE_HIGH, target
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

---------
-- Combos
---------
function X.ConsiderCombos()
    local ComboFlag = 0

    if CanDoCombo5()
    then
        ComboFlag = 5
    elseif CanDoCombo4()
    then
        ComboFlag = 4
    elseif CanDoCombo3()
    then
        ComboFlag = 3
    elseif CanDoCombo2()
    then
        ComboFlag = 2
    elseif CanDoCombo1()
    then
        ComboFlag = 1
    end

    if J.IsGoingOnSomeone(bot)
    then
        local target = nil
        local hp = 20000
        local nInRangeEnemy = bot:GetNearbyHeroes(1199, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:IsMagicImmune()
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                and hp > enemyHero:GetHealth()
                then
                    hp = enemyHero:GetHealth()
                    target = enemyHero
                end
            end
        end

        if target ~= nil
        then
            bot.shouldBlink = true
            BlinkLocation = J.GetRandomLocationWithinDist(target:GetLocation(), Laser:GetCastRange() * 0.7, Laser:GetCastRange())
            return BOT_ACTION_DESIRE_HIGH, target, ComboFlag
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, 0
end

function CanDoCombo1()
    if  HasBlink()
    and Laser:IsFullyCastable()
    and HeatSeekingMissile:IsFullyCastable()
    then
        local nManaCost = Laser:GetManaCost()
                        + HeatSeekingMissile:GetManaCost()
                        + Rearm:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

function CanDoCombo2()
    if  HasBlink()
    and Laser:IsFullyCastable()
    and HeatSeekingMissile:IsFullyCastable()
    then
        ShivasGuard = J.GetItem('item_shivas_guard')
        if ShivasGuard ~= nil and ShivasGuard:IsFullyCastable()
        then
            local nManaCost = Laser:GetManaCost()
                            + HeatSeekingMissile:GetManaCost()
                            + Rearm:GetManaCost()
                            + 75

            if bot:GetMana() >= nManaCost
            then
                bot.shouldBlink = true
                return true
            end
        end
    end

    bot.shouldBlink = false
    return false
end

function CanDoCombo3()
    if  HasBlink()
    and Laser:IsFullyCastable()
    and HeatSeekingMissile:IsFullyCastable()
    then
        ScytheOfVyse = J.GetItem('item_sheepstick')
        if ScytheOfVyse ~= nil and ScytheOfVyse:IsFullyCastable()
        then
            local nManaCost = Laser:GetManaCost()
                            + HeatSeekingMissile:GetManaCost()
                            + Rearm:GetManaCost()
                            + 250

            if bot:GetMana() >= nManaCost
            then
                bot.shouldBlink = true
                return true
            end
        end
    end

    bot.shouldBlink = false
    return false
end

function CanDoCombo4()
    if  HasBlink()
    and Laser:IsFullyCastable()
    and HeatSeekingMissile:IsFullyCastable()
    then
        EtherealBlade = J.GetItem('item_ethereal_blade')
        if EtherealBlade ~= nil and EtherealBlade:IsFullyCastable()
        then
            local nManaCost = Laser:GetManaCost()
                            + HeatSeekingMissile:GetManaCost()
                            + Rearm:GetManaCost()
                            + 100

            if bot:GetMana() >= nManaCost
            then
                bot.shouldBlink = true
                return true
            end
        end
    end

    bot.shouldBlink = false
    return false
end

function CanDoCombo5()
    if  HasBlink()
    and Laser:IsFullyCastable()
    and HeatSeekingMissile:IsFullyCastable()
    then
        ScytheOfVyse = J.GetItem('item_sheepstick')
        EtherealBlade = J.GetItem('item_ethereal_blade')
        if  EtherealBlade ~= nil and EtherealBlade:IsFullyCastable()
        and ScytheOfVyse ~= nil and ScytheOfVyse:IsFullyCastable()
        then
            local nManaCost = Laser:GetManaCost()
                            + HeatSeekingMissile:GetManaCost()
                            + Rearm:GetManaCost()
                            + 250
                            + 100

            if bot:GetMana() >= nManaCost
            then
                bot.shouldBlink = true
                return true
            end
        end
    end

    bot.shouldBlink = false
    return false
end

-- Clear Creeps
function X.ConsiderClearCreeps()
    local ClearCreepFlag = 0

    if CanClearCreeps2()
    then
        ClearCreepFlag = 2
    elseif CanClearCreeps1()
    then
        ClearCreepFlag = 1
    end

    local nCastRange = 1199

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local target = nil
        local range = 1000
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        for _, creep in pairs(nEnemyLaneCreeps)
        do
            if  J.IsValid(creep)
            and J.CanBeAttacked(creep)
            and range > creep:GetAttackRange()
            then
                range = creep:GetAttackRange()
                target = creep
            end
        end

        if target ~= nil
        then
            local nInRangeEnemy = J.GetEnemiesNearLoc(target:GetLocation(), 1600)
            local nEnemyTowers = bot:GetNearbyTowers(1600, true)

            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
            and nEnemyTowers ~= nil
                and (#nEnemyTowers == 0 or (#nEnemyTowers >= 1 and GetUnitToLocationDistance(nEnemyTowers[1], J.GetCenterOfUnits(nEnemyLaneCreeps)) > 750))
            then
                BlinkLocation = J.GetCenterOfUnits(nEnemyLaneCreeps)
                return BOT_ACTION_DESIRE_HIGH, target, ClearCreepFlag
            end
        end
    end

    if J.IsFarming(bot)
    then
        local target = nil
        local range = 1000
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        then
            for _, creep in pairs(nEnemyLaneCreeps)
            do
                if  J.IsValid(creep)
                and J.CanBeAttacked(creep)
                and range > creep:GetAttackRange()
                then
                    range = creep:GetAttackRange()
                    target = creep
                end
            end

            if target ~= nil
            then
                local nInRangeEnemy = J.GetEnemiesNearLoc(target:GetLocation(), 1600)
                local nEnemyTowers = bot:GetNearbyTowers(1600, true)

                if  nInRangeEnemy ~= nil and #nInRangeEnemy == 0
                and GetUnitToLocationDistance(nEnemyTowers[1], J.GetCenterOfUnits(nEnemyLaneCreeps)) > 750
                and nEnemyTowers ~= nil
                    and (#nEnemyTowers == 0 or (#nEnemyTowers >= 1 and GetUnitToLocationDistance(nEnemyTowers[1], J.GetCenterOfUnits(nEnemyLaneCreeps)) > 750))
                then
                    BlinkLocation = J.GetCenterOfUnits(nEnemyLaneCreeps)
                    return BOT_ACTION_DESIRE_HIGH, target, ClearCreepFlag
                end
            end
        end

        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(800)
        if nNeutralCreeps ~= nil and (#nNeutralCreeps >= 2 or #nNeutralCreeps == 1 and nNeutralCreeps[1]:IsAncientCreep())
        then
            for _, creep in pairs(nNeutralCreeps)
            do
                if  J.IsValid(creep)
                and J.CanBeAttacked(creep)
                and range < creep:GetAttackRange()
                then
                    range = creep:GetAttackRange()
                    target = creep
                end
            end

            if target ~= nil
            then
                local nInRangeEnemy = J.GetEnemiesNearLoc(target:GetLocation(), 1600)
                if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
                then
                    BlinkLocation = J.GetCenterOfUnits(nNeutralCreeps)
                    return BOT_ACTION_DESIRE_HIGH, target, ClearCreepFlag
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, 0
end

function CanClearCreeps1()
    if  HasBlink()
    and Laser:IsFullyCastable()
    then
        local nManaCost = Laser:GetManaCost()
                        + Rearm:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end

function CanClearCreeps2()
    if  HasBlink()
    and Laser:IsFullyCastable()
    then
        ShivasGuard = J.GetItem('item_shivas_guard')
        local nManaCost = Laser:GetManaCost()
                        + Rearm:GetManaCost()
                        + 75

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end

--------
-- Items
--------

-- Blink Dagger
function X.ConsiderBlink()
    if HasBlink()
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(500, true, BOT_MODE_NONE)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            BlinkLocation = J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), 1199)
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
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

-- Soul Ring
function X.ConsiderSoulRing()
    if not Rearm:IsTrained()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    SoulRing = J.GetItem('item_soul_ring')
    if SoulRing ~= nil and SoulRing:IsFullyCastable()
    then
        if  J.GetHP(bot) > 0.3
        and J.GetMP(bot) < 0.8
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

-- Shiva's Guard
function X.ConsiderShivasGuard()
    if not Rearm:IsTrained()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    ShivasGuard = J.GetItem('item_shivas_guard')
    if  ShivasGuard ~= nil and ShivasGuard:IsFullyCastable()
    then
        if  J.IsGoingOnSomeone(bot)
        and not CanDoCombo2()
        then
            if  J.IsValidTarget(botTarget)
            and J.IsInRange(bot, botTarget, 900)
            and not J.IsSuspiciousIllusion(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X