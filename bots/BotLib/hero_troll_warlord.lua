local X = {}
local bDebugMode = ( 1 == 10 )
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
						-- {2,1,4,2,2,6,2,1,1,1,6,4,4,4,6},--pos1, errored in 7.37
						{2,5,4,2,2,6,2,5,5,5,6,4,4,4,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_magic_wand",
    "item_wraith_band",
    "item_phase_boots",
    "item_bfury",--
    "item_yasha",
    "item_black_king_bar",--
    "item_sange_and_yasha",--
    "item_aghanims_shard",
    "item_satanic",--
    "item_moon_shard",
    "item_abyssal_blade",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

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

local BattleStance          = bot:GetAbilityInSlot(0)
local BerserkersRage        = bot:GetAbilityByName('troll_warlord_berserkers_rage')
local WhirlingAxesRanged    = bot:GetAbilityByName('troll_warlord_whirling_axes_ranged')
local WhirlingAxesMelee     = bot:GetAbilityByName('troll_warlord_whirling_axes_melee')
-- local Fervor                = bot:GetAbilityByName('troll_warlord_fervor')
local BattleTrance          = bot:GetAbilityByName('troll_warlord_battle_trance')

local BerserkersRageDesire
local WhirlingAxesRangedDesire, WhirlingAxesRangedLocation
local WhirlingAxesMeleeDesire
local BattleTranceDesire

local botTarget

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    BattleTranceDesire = X.ConsiderBattleTrance()
    if BattleTranceDesire > 0
    then
        bot:Action_UseAbility(BattleTrance)
        return
    end

    if BattleStance:IsFullyCastable() and BattleStance:IsTrained() then
        BerserkersRage = BattleStance
    end

    BerserkersRageDesire = X.ConsiderBerserkersRage(BerserkersRage)
    if BerserkersRageDesire > 0
    then
        bot:Action_UseAbility(BerserkersRage)
        return
    end

    WhirlingAxesRangedDesire, WhirlingAxesRangedLocation = X.ConsiderWhirlingAxesRanged()
    if WhirlingAxesRangedDesire > 0
    then
        bot:Action_UseAbilityOnLocation(WhirlingAxesRanged, WhirlingAxesRangedLocation)
        return
    end

    WhirlingAxesMeleeDesire = X.ConsiderWhirlingAxesMelee()
    if WhirlingAxesMeleeDesire > 0
    then
        bot:Action_UseAbility(WhirlingAxesMelee)
        return
    end
end

function X.ConsiderBerserkersRage(BerserkersRage)
    if not BerserkersRage:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nBonusRange = BerserkersRage:GetSpecialValueInt('bonus_range')
    local nBonusMS = BerserkersRage:GetSpecialValueInt('bonus_move_speed')
	local nEnemyHeroes = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
		then
            if J.IsChasingTarget(bot, botTarget)
            and not J.IsLocationInChrono(botTarget:GetLocation())
            then
                if BerserkersRage:GetToggleState() == false
                then
                    return BOT_ACTION_DESIRE_HIGH
                else
                    return BOT_ACTION_DESIRE_NONE
                end
            else
                if J.IsAttacking(bot)
                and J.IsInRange(bot, botTarget, 150)
                and BerserkersRage:GetToggleState() == false
                and not J.IsChasingTarget(botTarget)
                then
                    if BerserkersRage:GetToggleState() == false
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    else
                        return BOT_ACTION_DESIRE_NONE
                    end
                end
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (bot:WasRecentlyDamagedByAnyHero(1.5)))
            then
                if nInRangeEnemy[1]:GetCurrentMovementSpeed() > bot:GetCurrentMovementSpeed()
                and nInRangeEnemy[1]:GetCurrentMovementSpeed() < bot:GetCurrentMovementSpeed() + nBonusMS
                then
                    if BerserkersRage:GetToggleState() == false
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    else
                        return BOT_ACTION_DESIRE_NONE
                    end
                end

            end
        end
    end

	if J.IsPushing(bot)
	then
		if nEnemyHeroes ~= nil and #nEnemyHeroes == 0
        then
            if BerserkersRage:GetToggleState() == false
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                return BOT_ACTION_DESIRE_NONE
            end
        else
            if BerserkersRage:GetToggleState() == true
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                return BOT_ACTION_DESIRE_NONE
            end
        end
	end

    if J.IsFarming(bot)
	then
        if BerserkersRage:GetToggleState() == false
        then
            return BOT_ACTION_DESIRE_HIGH
        else
            return BOT_ACTION_DESIRE_NONE
        end
	end

	if J.IsLaning(bot)
    then
		local enemyRange = 0

		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if J.IsValidHero(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and enemyHero:GetAttackRange() > enemyRange
            then
                enemyRange = enemyHero:GetAttackRange()
            end
		end

		if enemyRange < 324
        then
            if BerserkersRage:GetToggleState() == false
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                return BOT_ACTION_DESIRE_NONE
            end
        end

		if enemyRange > 324
        then
            if BerserkersRage:GetToggleState() == true
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                return BOT_ACTION_DESIRE_NONE
            end
		end
	end

    if BerserkersRage:GetToggleState() == false
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderWhirlingAxesRanged()
    if not WhirlingAxesRanged:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, WhirlingAxesRanged:GetCastRange())
    local nCastPoint = WhirlingAxesRanged:GetCastPoint()
    local nRadius = WhirlingAxesRanged:GetSpecialValueInt('axe_width')
    local nSpeed = WhirlingAxesRanged:GetSpecialValueInt('axe_speed')
    local nDamage = WhirlingAxesRanged:GetSpecialValueInt('axe_damage')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local eta = (GetUnitToUnitDistance(bot, enemyHero)/ nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(eta)
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                local eta = (GetUnitToUnitDistance(bot, botTarget)/ nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(eta)
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and J.IsAttacking(bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
        and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not nInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
        and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or bot:WasRecentlyDamagedByAnyHero(1.5))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
            end
        end

        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end
        end
	end

	if J.IsPushing(bot)
	then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nLocationAoE.count >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        if nLocationAoE.count >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsFarming(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep() and nLocationAoE.count >= 2))
            and J.GetMP(bot) > 0.3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and nLocationAoE.count >= 3
            and J.GetMP(bot) > 0.3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
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
			-- if J.IsValid(creep)
			-- and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			-- and creep:GetHealth() <= nDamage
			-- then
			-- 	local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

			-- 	if nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
            --     and J.GetMP(bot) > 0.3
            --     and J.CanBeAttacked(creep)
			-- 	then
			-- 		return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
			-- 	end
			-- end

            if J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                canKill = canKill + 1
                table.insert(creepList, creep)
            end
		end

        if canKill >= 2
        and J.GetMP(bot) > 0.25
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.CanBeAttacked(creepList[1])
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
        end

        if nInRangeEnemy ~= nil and #nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsAttacking(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.GetMP(bot) > 0.5
        and J.GetHP(bot) < J.GetHP(nInRangeEnemy[1])
        and nInRangeEnemy[1]:GetAttackTarget() == bot
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderWhirlingAxesMelee()
    if not WhirlingAxesMelee:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = WhirlingAxesRanged:GetSpecialValueInt('max_range')
    local nDamage = WhirlingAxesRanged:GetSpecialValueInt('damage')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
        and not nInRangeEnemy[1]:HasModifier('modifier_troll_warlord_whirling_axes_slow')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or bot:WasRecentlyDamagedByAnyHero(1.5))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end

        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

	if J.IsPushing(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            and J.GetMP(bot) > 0.3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and J.GetMP(bot) > 0.3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
        end
    end

    if J.IsLaning(bot)
	then
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
            if J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                canKill = canKill + 1
                table.insert(creepList, creep)
            end
		end

        if canKill >= 2
        and J.GetMP(bot) > 0.25
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.CanBeAttacked(creepList[1])
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if nInRangeEnemy ~= nil and #nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsAttacking(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.GetMP(bot) > 0.5
        and J.GetHP(bot) < J.GetHP(nInRangeEnemy[1])
        and nInRangeEnemy[1]:GetAttackTarget() == bot
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBattleTrance()
    if not BattleTrance:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	--团战
	if J.IsInTeamFight( bot, 1200 )
    and J.IsValidTarget(botTarget)
	then
        local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)
        if J.GetHP(bot) < 0.4
        and #nInRangeEnemy >= #nInRangeAlly then
            return BOT_ACTION_DESIRE_MODERATE
        end
	end

    local nDuration = BattleTrance:GetSpecialValueInt('trance_duration')

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, 600)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not botTarget:HasModifier('modifier_item_blade_mail_reflect')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)
            local nDamage = bot:GetEstimatedDamageToTarget(false, botTarget, nDuration, DAMAGE_TYPE_PHYSICAL)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            and not (#nInRangeAlly >= #nInRangeEnemy + 2)
            and nDamage >= botTarget:GetHealth()
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end

        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 600)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.GetHP(bot) < 0.3
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsAttacking(bot)
        and not J.IsLocationInChrono(nInRangeEnemy[1]:GetLocation())
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsDoingRoshan(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,600, false, BOT_MODE_NONE)

        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and nInRangeAlly ~= nil and #nInRangeAlly >= 2
        and J.IsAttacking(nInRangeAlly[1])
        and J.IsAttacking(nInRangeAlly[2])
        and DotaTime() < 35 * 60
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and J.GetHP(bot) < 0.35
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsRetreating(bot) then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 500)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.GetHP(bot) < 0.3
        and J.IsValidHero(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 35)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X