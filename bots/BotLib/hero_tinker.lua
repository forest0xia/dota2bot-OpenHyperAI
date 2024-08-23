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

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_double_circlet",

    "item_bottle",
    "item_soul_ring",
    "item_magic_wand",
    "item_blink",
	"item_kaya_and_sange",--
	"item_angels_demise",--
    "item_shivas_guard",--
    "item_ethereal_blade",--
	"item_ultimate_scepter",
    "item_ultimate_scepter_2",
    "item_moon_shard",
    "item_sheepstick",--
    "item_overwhelming_blink",--
    "item_aghanims_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_double_circlet",

    "item_soul_ring",
    "item_magic_wand",
    "item_blink",
	"item_kaya_and_sange",--
	"item_angels_demise",--
    "item_shivas_guard",--
    "item_ethereal_blade",--
	"item_ultimate_scepter",
    "item_ultimate_scepter_2",
    "item_moon_shard",
    "item_sheepstick",--
    "item_overwhelming_blink",--
    "item_aghanims_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_5']

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

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
    Minion.MinionThink(hMinionUnit, bot)
end

local Laser                 = bot:GetAbilityByName('tinker_laser')
-- local HeatSeekingMissile    = bot:GetAbilityByName('tinker_heat_seeking_missile')
local MarchOfTheMachines    = bot:GetAbilityByName('tinker_march_of_the_machines')
local DefenseMatrix         = bot:GetAbilityByName('tinker_defense_matrix')
local WarpFlare             = bot:GetAbilityByName('tinker_warp_grenade')
local KeenConveyance        = bot:GetAbilityByName('tinker_keen_teleport')
local Rearm                 = bot:GetAbilityByName('tinker_rearm')

local LaserDesire, LaserTarget
-- local HeatSeekingMissileDesire
local MarchOfTheMachinesDesire, MarchOfTheMachinesLocation
local DefenseMatrixDesire, DefenseMatrixTarget
local WarpFlareDesire, WarpFlareTarget
local KeenConveyanceDesire, KeenConveyanceTargetLocation
local KeenConveyanceCastTime = DotaTime()
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
    if J.GetMP(bot) > 0.8
    or bot:HasModifier('modifier_fountain_invulnerability')
    then
        bot.healInBase = false
    end

    if J.CanNotUseAbility(bot)
    or Rearm ~= nil and Rearm:IsInAbilityPhase()
    or KeenConveyance ~= nil and KeenConveyance:IsInAbilityPhase()
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
                if Rearm ~= nil and Rearm:GetManaCost() > bot:GetMana()
                or J.GetHP(bot) < 0.35
                then
                    bot.healInBase = true
                end
            else
                if J.GetMP(bot) < 0.3
                or (J.GetHP(bot) < 0.35 and J.GetMP(bot) < 0.5)
                then
                    bot.healInBase = true
                end
            end
        end
    end

    DefenseMatrixDesire, DefenseMatrixTarget = X.ConsiderDefenseMatrix()
    if DefenseMatrixDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DefenseMatrix, DefenseMatrixTarget)
        return
    end

    MarchOfTheMachinesDesire, MarchOfTheMachinesLocation = X.ConsiderMarchOfTheMachines()
    if MarchOfTheMachinesDesire > 0
    then
        bot:Action_UseAbilityOnLocation(MarchOfTheMachines, MarchOfTheMachinesLocation)
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

        KeenConveyanceCastTime = DotaTime()
        return
    end

end

function X.ConsiderLaser()
    if not J.CanCastAbility(Laser)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Laser:GetCastRange())
    local nDamage = Laser:GetSpecialValueInt('laser_damage')
    local nRadius = Laser:GetSpecialValueInt('radius_explosion')
    local nManaCost = Laser:GetManaCost()

    local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PURE)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

	if  J.IsGoingOnSomeone(bot)
    -- and (not CanDoCombo1()
    --     and not CanDoCombo2()
    --     and not CanDoCombo3()
    --     and not CanDoCombo4()
    --     and not CanDoCombo5())
	then
        local target = nil
        local dmg = 0

        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsMeepoClone(enemyHero)
            then
                local currDMG = enemyHero:GetAttackDamage() * enemyHero:GetAttackSpeed()
                if dmg < currDMG
                then
                    dmg = currDMG
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
    and not J.IsRealInvisible(bot)
	then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and not J.IsInRange(bot, enemyHero, nCastRange / 2.5)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and (bot:WasRecentlyDamagedByHero(enemyHero, 3.5) or J.GetHP(bot) < 0.4)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
	end

    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

    if (J.IsPushing(bot) or J.IsDefending(bot))
    and J.GetMP(bot) > 0.35
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        if J.IsAttacking(bot)
        then
            if J.CanBeAttacked(nEnemyLaneCreeps[1])
            and not J.IsRunning(nEnemyLaneCreeps[1])
            and #nEnemyLaneCreeps >= 2 and nLocationAoE.count >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
            end
        end
    end

    if J.IsFarming(bot)
    and J.GetMP(bot) > 0.3
    then
        if J.IsAttacking(bot)
        then
            local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), 1200, nRadius, 0, 0)
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1000)

            if J.IsValid(nNeutralCreeps[1])
            and ((#nNeutralCreeps >= 2 and nLocationAoE.count >= 2) or (#nNeutralCreeps == 1 and (nNeutralCreeps[1]:IsAncientCreep() or J.GetHP(nNeutralCreeps[1]) > 0.5)))
            then
                return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
            end

            if J.CanBeAttacked(nEnemyLaneCreeps[1])
            and not J.IsRunning(nEnemyLaneCreeps[1])
            and #nEnemyLaneCreeps >= 2 and nLocationAoE.count >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
            end
        end
    end

    if J.IsLaning(bot)
    and (J.IsCore(bot) or not J.IsCore(bot) and not J.IsThereCoreNearby(1200))
	then
        local creepList = {}

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
            and J.IsInRange(bot, creep, nCastRange)
            and J.CanBeAttacked(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
			then
				if J.IsValidHero(nEnemyHeroes[1])
                and GetUnitToUnitDistance(creep, nEnemyHeroes[1]) < 600
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

        if J.IsValidHero(nEnemyHeroes[1])
        and J.IsInLaningPhase(bot)
        then
            local nAllyTowers = bot:GetNearbyTowers(1600, false)
            if  nAllyTowers ~= nil and #nAllyTowers >= 1
            and J.IsValidBuilding(nAllyTowers[1])
            and J.IsInRange(bot, nEnemyHeroes[1], nCastRange)
            and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
            and J.CanCastOnTargetAdvanced(nEnemyHeroes[1])
            and J.GetManaAfter(nManaCost) > 0.45
            and not nEnemyHeroes[1]:HasModifier('modifier_abaddon_borrowed_time')
            and not nEnemyHeroes[1]:HasModifier('modifier_dazzle_shallow_grave')
            and not nEnemyHeroes[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            and not nEnemyHeroes[1]:HasModifier('modifier_templar_assassin_refraction_absorb')
            and GetUnitToUnitDistance(nEnemyHeroes[1], nAllyTowers[1]) < 600
            and nAllyTowers[1]:GetAttackTarget() == nEnemyHeroes[1]
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
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

function X.ConsiderMarchOfTheMachines()
    if not J.CanCastAbility(MarchOfTheMachines)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, MarchOfTheMachines:GetCastRange())
    local nCastPoint = MarchOfTheMachines:GetCastPoint()
    local nDistance = MarchOfTheMachines:GetSpecialValueInt('distance')
    local nRadius = MarchOfTheMachines:GetSpecialValueInt('radius')
    local nDuration = MarchOfTheMachines:GetSpecialValueInt('duration')
    local nDamage = MarchOfTheMachines:GetSpecialValueInt('damage')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nDistance)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage * nDuration, DAMAGE_TYPE_MAGICAL)
        and not J.IsChasingTarget(enemyHero, bot)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, enemyHero:GetLocation(), nCastRange)
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
        local nLocationAoE__A = bot:FindAoELocation(false, true, bot:GetLocation(), nDistance / 2, nRadius, 0, 0)
        local nLocationAoE__E = bot:FindAoELocation(true, true, bot:GetLocation(), nDistance / 2, nRadius, 0, 0)
        if not J.IsCore(bot)
        then
            if nLocationAoE__A.count > 0
            and J.GetDistance(nLocationAoE__A.targetloc, nLocationAoE__E.targetloc) <= nDistance
            then
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, nLocationAoE__A.targetloc, nCastRange)
            end
        end

        if #nEnemyHeroes <= 1
        and J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nDistance)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
		end

        if nLocationAoE__E.count > 0
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, nLocationAoE__E.targetloc, nCastRange)
        end
	end

    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)

    if (J.IsPushing(bot) or J.IsDefending(bot))
    and J.GetMP(bot) > 0.35
    then
        if #nEnemyLaneCreeps >= 2
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nEnemyLaneCreeps), nCastRange)
        end

        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nDistance / 2, nRadius, nCastPoint, 0)
        if nLocationAoE.count >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, nLocationAoE.targetloc, nCastRange)
        end
    end

    if J.IsFarming(bot)
    and J.GetMP(bot) > 0.3
    then
        if J.IsAttacking(bot)
        then
            local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), 1200, nRadius, 0, 0)
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1000)

            if J.CanBeAttacked(nNeutralCreeps[1])
            and ((#nNeutralCreeps >= 2 and nLocationAoE.count >= 2)
                or (#nNeutralCreeps == 1 and (nNeutralCreeps[1]:IsAncientCreep() or J.GetHP(nNeutralCreeps[1]) > 0.5)))
            then
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nNeutralCreeps), nCastRange)
            end

            if #nEnemyLaneCreeps >= 2
            and J.CanBeAttacked(nEnemyLaneCreeps[1])
            then
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nEnemyLaneCreeps), nCastRange)
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nDistance)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nDistance)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderDefenseMatrix()
    if not J.CanCastAbility(DefenseMatrix)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, DefenseMatrix:GetCastRange())

    local nAllyHeroes = J.GetNearbyHeroes(bot,1600, false, BOT_MODE_NONE)
    local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

	if J.IsGoingOnSomeone(bot)
    then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetCurrentVisionRange())
        and bot:WasRecentlyDamagedByAnyHero(2.5)
        and not bot:IsInvulnerable()
        and not bot:IsAttackImmune()
        and not bot:HasModifier('modifier_tinker_defense_matrix')
        then
            return BOT_ACTION_DESIRE_HIGH, bot
	    end
    end

	if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
	then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and (J.IsChasingTarget(enemyHero, bot)
                or (J.IsAttacking(enemyHero) and enemyHero:GetAttackTarget() == bot))
            and bot:WasRecentlyDamagedByAnyHero(2.5)
            and (not J.IsSuspiciousIllusion(enemyHero) or J.GetHP(bot) < 0.55)
            and not bot:HasModifier('modifier_tinker_defense_matrix')
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
	end

    if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
    then
        if  (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, 800)
        and J.IsAttacking(bot)
        then
            if  J.GetHP(bot) < 0.5
            and not bot:HasModifier('modifier_abaddon_aphotic_shield')
            and not bot:HasModifier('modifier_tinker_defense_matrix')
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end

            local target = nil
            local hp = 99999
            for _, allyHero in pairs(nAllyHeroes)
            do
                if  J.IsValidHero(allyHero)
                and J.IsInRange(bot, allyHero, nCastRange)
                and not allyHero:IsAttackImmune()
                and not allyHero:IsInvulnerable()
                and not J.IsSuspiciousIllusion(allyHero)
                and not allyHero:HasModifier('modifier_abaddon_aphotic_shield')
                and not allyHero:HasModifier('modifier_tinker_defense_matrix')
                and hp > allyHero:GetHealth()
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

    nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
	do
        if  J.IsValidHero(allyHero)
        and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
        and not allyHero:HasModifier('modifier_tinker_defense_matrix')
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
        and not allyHero:HasModifier('modifier_tinker_defense_matrix')
        then
            return BOT_ACTION_DESIRE_HIGH, allyHero
        end

		if  J.IsValidHero(allyHero)
        and not allyHero:HasModifier('modifier_abaddon_aphotic_shield')
        and not allyHero:HasModifier('modifier_item_solar_crest_armor_addition')
        and not allyHero:HasModifier('modifier_tinker_defense_matrix')
		and not allyHero:IsMagicImmune()
		and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
        and J.IsNotSelf(bot, allyHero)
		then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

            if  J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(3)
            and not allyHero:IsIllusion()
            then
                if J.IsValidHero(nAllyInRangeEnemy[1])
                and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
                and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
                and not J.IsDisabled(nAllyInRangeEnemy[1])
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
                    return BOT_ACTION_DESIRE_HIGH, allyHero
				end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

local tpDelta = 7
function X.ConsiderKeenConveyance()
    if not J.CanCastAbility(KeenConveyance)
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

    if J.IsInTeamFight(bot, 1200)
    and not J.IsRetreating(bot)
    then
        return BOT_ACTION_DESIRE_NONE, 0, ''
    end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if  nTeamFightLocation ~= nil
    and J.GetMP(bot) > 0.65
    and not J.IsRetreating(bot)
    and not J.IsInLaningPhase()
    then
        local nInRangeAlly = J.GetAlliesNearLoc(nTeamFightLocation, 1200)

        if GetUnitToLocationDistance(bot, nTeamFightLocation) > 4100
        then
            if nAbilityLevel <= 2
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetNearbyLocationToTp(nTeamFightLocation), 'loc'
            else
                return BOT_ACTION_DESIRE_HIGH, nInRangeAlly[1], 'unit'
            end
        end
    end

    if DotaTime() < KeenConveyanceCastTime + tpDelta
    then
        return BOT_ACTION_DESIRE_NONE, 0, ''
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

    local aveDist = {0,0,0}
    local pushCount = {0,0,0}
    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if  J.IsValidHero(allyHero)
        and bot ~= allyHero
        and not J.IsSuspiciousIllusion(allyHero)
        and not J.IsMeepoClone(allyHero)
        then
            if  allyHero:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
            and bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
            then
                pushCount[1] = pushCount[1] + 1
                aveDist[1] = aveDist[1] + GetUnitToLocationDistance(allyHero, GetLaneFrontLocation(GetTeam(), LANE_TOP, 0))
            end

            if  allyHero:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
            and bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
            then
                pushCount[2] = pushCount[2] + 1
                aveDist[2] = aveDist[2] + GetUnitToLocationDistance(allyHero, GetLaneFrontLocation(GetTeam(), LANE_MID, 0))
            end

            if  allyHero:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
            and bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
            then
                pushCount[3] = pushCount[3] + 1
                aveDist[3] = aveDist[3] + GetUnitToLocationDistance(allyHero, GetLaneFrontLocation(GetTeam(), LANE_BOT, 0))
            end
        end
    end

    if pushCount[1] ~= nil and pushCount[1] >= 3 and (aveDist[1] / pushCount[1]) <= 1200
    then
        if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), LANE_TOP, 0)) > 4000
        then
            if nAbilityLevel == 3
            then
                return BOT_ACTION_DESIRE_HIGH, GetLaneFrontLocation(GetTeam(), LANE_TOP, 0), 'loc'
            else
                local tpLoc = J.GetPushTPLocation(LANE_TOP)
                if tpLoc then return BOT_ACTION_DESIRE_HIGH, tpLoc, 'loc' end
            end
        end
    elseif pushCount[2] ~= nil and pushCount[2] >= 3 and (aveDist[2] / pushCount[2]) <= 1200
    then
        if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), LANE_MID, 0)) > 4000
        then
            if nAbilityLevel == 3
            then
                return BOT_ACTION_DESIRE_HIGH, GetLaneFrontLocation(GetTeam(), LANE_MID, 0), 'loc'
            else
                local tpLoc = J.GetPushTPLocation(LANE_MID)
                if tpLoc then return BOT_ACTION_DESIRE_HIGH, tpLoc, 'loc' end
            end
        end
    elseif pushCount[3] ~= nil and pushCount[3] >= 3 and (aveDist[3] / pushCount[3]) <= 1200
    then
        if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), LANE_BOT, 0)) > 4000
        then
            if nAbilityLevel == 3
            then
                return BOT_ACTION_DESIRE_HIGH, GetLaneFrontLocation(GetTeam(), LANE_BOT, 0), 'loc'
            else
                local tpLoc = J.GetPushTPLocation(LANE_BOT)
                if tpLoc then return BOT_ACTION_DESIRE_HIGH, tpLoc, 'loc' end
            end
        end
    end

    if  J.IsDefending(bot)
    and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
    and not J.IsInLaningPhase()
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
        local farmLane, mostFarmDesire = J.GetMostFarmLaneDesire()

        if mostFarmDesire > 0.75
        then
            local farmTpLoc = GetLaneFrontLocation(GetTeam(), farmLane, 0)
            local bestTpLoc = J.GetNearbyLocationToTp(farmTpLoc)

            if  bestTpLoc ~= nil and farmTpLoc ~= nil
            and GetUnitToLocationDistance( bot, bestTpLoc) > 4000
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
    if not J.CanCastAbility(Rearm)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nChannelTime = Rearm:GetChannelTime()

    local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
    if  bot.healInBase
    and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
    and KeenConveyance ~= nil and KeenConveyance:IsTrained() and KeenConveyance:GetCooldownTimeRemaining() > nChannelTime
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if Laser ~= nil and Laser:IsTrained() and Laser:GetCooldownTimeRemaining() > nChannelTime
    or MarchOfTheMachines ~= nil and MarchOfTheMachines:IsTrained() and MarchOfTheMachines:GetCooldownTimeRemaining() > nChannelTime
    then
        return BOT_ACTION_DESIRE_HIGH
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 1500)
        and (MarchOfTheMachines:GetCooldownTimeRemaining() > nChannelTime
            or not J.CanBlinkDagger(GetBot()))
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        -- if  GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0)) > 4000
        -- and KeenConveyance ~= nil and KeenConveyance:IsTrained() and KeenConveyance:GetCooldownTimeRemaining() > 5
        -- then
        --     return BOT_ACTION_DESIRE_HIGH
        -- end

        if #nEnemyLaneCreeps >= 2
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1600, 900, 0, 0)
        if nLocationAoE.count > 0
        and GetUnitToLocationDistance(bot, nLocationAoE.targetloc) > 880
        and MarchOfTheMachines ~= nil and MarchOfTheMachines:GetCooldownTimeRemaining() > nChannelTime
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
            and (Laser ~= nil and Laser:GetCooldownTimeRemaining() > nChannelTime
                or MarchOfTheMachines ~= nil and MarchOfTheMachines:GetCooldownTimeRemaining() > nChannelTime)
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
            and J.GetMP(bot) > 0.25
            and (Laser ~= nil and Laser:GetCooldownTimeRemaining() > nChannelTime
                or MarchOfTheMachines ~= nil and MarchOfTheMachines:GetCooldownTimeRemaining() > nChannelTime)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 800)
        and J.IsAttacking(bot)
        and (DefenseMatrix ~= nil and DefenseMatrix:GetCooldownTimeRemaining() > nChannelTime
            or MarchOfTheMachines ~= nil and MarchOfTheMachines:GetCooldownTimeRemaining() > nChannelTime)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 800)
        and J.IsAttacking(bot)
        and (DefenseMatrix ~= nil and DefenseMatrix:GetCooldownTimeRemaining() > nChannelTime
            or MarchOfTheMachines ~= nil and MarchOfTheMachines:GetCooldownTimeRemaining() > nChannelTime)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderWarpFlare()
    if not J.CanCastAbility(WarpFlare)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, WarpFlare:GetCastRange())

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
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
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

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
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1199, true, BOT_MODE_NONE)
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
        local nInRangeEnemy = J.GetNearbyHeroes(bot,500, true, BOT_MODE_NONE)
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
