local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,2,2,2,6,2,3,3,3,1,6,1,1,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sUtility = {"item_pipe", "item_lotus_orb", "item_heavens_halberd", "item_crimson_guard"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_double_circlet",

    "item_bracer",
    "item_wraith_band",
    "item_magic_wand",
    "item_power_treads",
    "item_blink",
    "item_echo_sabre",
    "item_black_king_bar",--
    "item_harpoon",--
    nUtility,--
    "item_sheepstick",--
    "item_aghanims_shard",
    "item_travel_boots",
    "item_arcane_blink",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_circlet",
    "item_bracer",
    "item_wraith_band",
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

local Shockwave         = bot:GetAbilityByName('magnataur_shockwave')
local Empower           = bot:GetAbilityByName('magnataur_empower')
local Skewer            = bot:GetAbilityByName('magnataur_skewer')
local HornToss          = bot:GetAbilityByName('magnataur_horn_toss')
local ReversePolarity   = bot:GetAbilityByName('magnataur_reverse_polarity')

local ShockwaveDesire, ShockwaveLocation
local EmpowerDesire, EmpowerTarget
local SkewerDesire, SkewerLocation
local HornTossDesire
local ReversePolarityDesire

local Blink
local BlinkLocation

local BlinkRPDesire

local BlinkSkewerDesire
local BlinkRPSkewerDesire

if bot.shouldBlink == nil then bot.shouldBlink = false end

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    BlinkRPSkewerDesire = X.ConsiderBlinkRPSkewer()
    if BlinkRPSkewerDesire > 0
    then
        bot:Action_ClearActions(false)

        if CanBKB()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbility(ReversePolarity)
        bot:ActionQueue_Delay(0.3)

        SkewerDesire, SkewerLocation = X.ConsiderSkewer2()
        if SkewerDesire > 0
        then
            bot:ActionQueue_UseAbilityOnLocation(Skewer, SkewerLocation)
        end

        return
    end

    BlinkSkewerDesire = X.ConsiderBlinkForSkewer()
    if BlinkSkewerDesire > 0
    then
        bot:Action_ClearActions(false)

        if CanBKB()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
        bot:ActionQueue_Delay(0.1)

        SkewerDesire, SkewerLocation = X.ConsiderSkewer2()
        if SkewerDesire > 0
        then
            bot:ActionQueue_UseAbilityOnLocation(Skewer, SkewerLocation)
        end

        return
    end

    BlinkRPDesire = X.ConsiderBlinkRP()
    if BlinkRPDesire > 0
    then
        bot:Action_ClearActions(false)

        if CanBKB()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbility(ReversePolarity)
        return
    end

    BlinkHornTossSkewerDesire = X.ConsiderBlinkForHornTossSkewer()
    if BlinkHornTossSkewerDesire > 0
    then
        bot:Action_ClearActions(false)

        if CanBKB()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)

        HornTossDesire = X.ConsiderHornToss()
        if HornTossDesire > 0
        then
            bot:ActionQueue_UseAbility(HornToss)
            return
        end

        bot:ActionQueue_Delay(0.6)

        SkewerDesire, SkewerLocation = X.ConsiderSkewer2()
        if SkewerDesire > 0
        then
            bot:ActionQueue_UseAbilityOnLocation(Skewer, SkewerLocation)
        end

        return
    end

    ReversePolarityDesire = X.ConsiderReversePolarity()
    if ReversePolarityDesire > 0
    then
        bot:Action_UseAbility(ReversePolarity)
        return
    end

    HornTossDesire = X.ConsiderHornToss()
    if HornTossDesire > 0
    then
        bot:Action_UseAbility(HornToss)
        return
    end

    SkewerDesire, SkewerLocation = X.ConsiderSkewer()
    if SkewerDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Skewer, SkewerLocation)
        return
    end

    ShockwaveDesire, ShockwaveLocation = X.ConsiderShockwave()
    if ShockwaveDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Shockwave, ShockwaveLocation)
        return
    end

    EmpowerDesire, EmpowerTarget = X.ConsiderEmpower()
    if EmpowerDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Empower, EmpowerTarget)
        return
    end
end

function X.ConsiderShockwave()
    if not Shockwave:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, Shockwave:GetCastRange())
	local nCastPoint = Shockwave:GetCastPoint()
    local nRadius = Shockwave:GetSpecialValueInt('shock_width')
	local nDamage = Shockwave:GetSpecialValueInt('shock_damage')
	local nSpeed = Shockwave:GetSpecialValueInt('shock_speed')
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange - 200)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
        end
	end

	if (J.IsDefending(bot) or J.IsPushing(bot))
	then
		local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(nCastRange - 200, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange - 200, nRadius, 0, 0)

		if  nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 4
        and nLocationAoE.count >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange - 200, nRadius, 0, 0)
        if nLocationAoE.count >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsFarming(bot)
    then
        local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(800, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), 800, nRadius, 0, 0)

        if J.IsAttacking(bot)
        then
            if  nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 3
            and nLocationAoE.count >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end

            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(600)
            if  nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
                or (#nNeutralCreeps >= 2 and nLocationAoE.count >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            and nMana > 0.27
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    if  J.IsLaning(bot)
    and nMana > 0.39
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
			then
				local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

				if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
				then
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
				end
			end
		end
	end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, nCastRange, true, BOT_MODE_NONE)

        if  J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2.1)
        and not allyHero:IsIllusion()
        and nMana > 0.48
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], 400)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsRunning(allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            then
                local nDelay = (GetUnitToUnitDistance(bot, nAllyInRangeEnemy[1]) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(nDelay + nCastPoint)
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderEmpower()
    if not Empower:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Empower:GetCastRange())
	local nAttackRange = bot:GetAttackRange()
    local botTarget = J.GetProperTarget(bot)

    local buffAllyUnit = nil
	local nMaxDamage = 0
    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
	do
		if  J.IsValidHero(allyHero)
        and J.IsCore(allyHero)
        and not allyHero:IsIllusion()
        and not J.IsDisabled(allyHero)
        and not J.IsWithoutTarget(allyHero)
        and not allyHero:HasModifier('modifier_magnataur_empower')
        and (allyHero:GetAttackDamage() * allyHero:GetAttackSpeed()) > nMaxDamage
		then
			buffAllyUnit = allyHero
			nMaxDamage = allyHero:GetAttackDamage() * allyHero:GetAttackSpeed()
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanBeAttacked(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
            if buffAllyUnit ~= nil
            then
                if  buffAllyUnit == bot
                and J.IsInRange(bot, botTarget, 500)
                then
                    return BOT_ACTION_DESIRE_HIGH, buffAllyUnit
                end

                if  buffAllyUnit ~= bot
                and J.IsInRange(buffAllyUnit, botTarget, buffAllyUnit:GetAttackRange() + 100)
                and J.IsInRange(bot, buffAllyUnit, nCastRange)
                then
                    return BOT_ACTION_DESIRE_HIGH, buffAllyUnit
                end
            end
		end
	end

	if  (J.IsPushing(bot) or J.IsDefending(bot))
    and not bot:HasModifier('modifier_magnataur_empower')
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
			return BOT_ACTION_DESIRE_HIGH, bot
		end

		local nEnemyTowers = bot:GetNearbyTowers(700, true)
		if  nEnemyTowers ~= nil and #nEnemyTowers > 0
        and buffAllyUnit ~= nil
        then
            if buffAllyUnit == bot
            then
                return BOT_ACTION_DESIRE_HIGH, buffAllyUnit
            end

            if  buffAllyUnit ~= bot
            and J.IsInRange(buffAllyUnit, nEnemyTowers[1], buffAllyUnit:GetAttackRange() + 100)
            and J.IsInRange(bot, buffAllyUnit, nCastRange)
            then
                return BOT_ACTION_DESIRE_HIGH, buffAllyUnit
            end
		end
	end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nAttackRange)

        if nNeutralCreeps ~= nil
            and (#nNeutralCreeps >= 3
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
    end

    if J.IsLaning(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
    end

	if  J.IsDoingRoshan(bot)
    and buffAllyUnit ~= nil
	then
		if  J.IsRoshan(botTarget)
		and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(buffAllyUnit)
		then
			return BOT_ACTION_DESIRE_HIGH, buffAllyUnit
		end
	end

    if  J.IsDoingTormentor(bot)
    and buffAllyUnit ~= nil
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(buffAllyUnit)
        then
            return BOT_ACTION_DESIRE_HIGH, buffAllyUnit
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSkewer()
    if not Skewer:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nDist = Skewer:GetSpecialValueInt('range')
	local nCastPoint = Skewer:GetCastPoint()
	local nSpeed = Skewer:GetSpecialValueInt('skewer_speed')
    local nRadius = Skewer:GetSpecialValueInt('skewer_radius')
    local botTarget = J.GetProperTarget(bot)

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nDist)
	end

	if  J.IsGoingOnSomeone(bot)
    and (not CanDoBlinkSkewer() or not CanDoBlinkRPSkewer() or not CanDoBlinkHornTossSkewer())
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            if  J.IsEnemyBetweenMeAndLocation(bot, J.GetEscapeLoc(), nDist)
            and J.IsInRange(bot, botTarget, nRadius)
            then
                if #nInRangeAlly >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, nInRangeAlly[#nInRangeAlly]:GetLocation(), nDist)
                else
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetEscapeLoc(), nDist)
                end
            end

            if  J.IsRunning(bot)
            and J.IsRunning(botTarget)
            and J.IsInRange(bot, botTarget, nDist)
            and bot:IsFacingLocation(botTarget:GetLocation(), 30)
            and not botTarget:IsFacingLocation(bot:GetLocation(), 30)
            then
                local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
            end
        end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,600, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.68 and bot:WasRecentlyDamagedByAnyHero(1.9)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 575)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
        then
            local loc = J.GetEscapeLoc()
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nDist)
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderReversePolarity()
    if not ReversePolarity:IsFullyCastable()
    or bot:HasModifier('modifier_magnataur_skewer_movement')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = ReversePolarity:GetSpecialValueInt('pull_radius')
	local nDamage = ReversePolarity:GetSpecialValueInt('polarity_damage')

    if  J.IsInTeamFight(bot, 1200)
    and (not CanDoBlinkRP() or not CanDoBlinkRPSkewer())
	then
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

            if  realEnemyCount ~= nil and #realEnemyCount >= 2
            and not J.IsLocationInChrono(nInRangeEnemy[1]:GetLocation())
            and not J.IsLocationInBlackHole(nInRangeEnemy[1]:GetLocation())
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByAnyHero(1.6)))
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nRadius)
                and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not J.IsTaunted(enemyHero)
                and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
                and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
                and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
                and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderHornToss()
    if not HornToss:IsTrained()
    or not HornToss:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = HornToss:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)

    if  J.IsGoingOnSomeone(bot)
    and not CanDoBlinkHornTossSkewer()
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and bot:IsFacingLocation(botTarget:GetLocation(), 15)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_legion_commander_duel')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.61 and bot:WasRecentlyDamagedByAnyHero(2)))
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nRadius)
                and J.IsEnemyBetweenMeAndLocation(bot, J.GetEscapeLoc(), nRadius)
                and not J.IsSuspiciousIllusion(enemyHero)
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBlinkRP()
    if CanDoBlinkRP()
    then
        local nCastRange = 1199
        local nCastPoint = Skewer:GetCastPoint() + ReversePolarity:GetCastPoint()
        local nRadius = ReversePolarity:GetSpecialValueInt('pull_radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

            if nLocationAoE.count >= 2
            then
                local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

                if  realEnemyCount ~= nil and #realEnemyCount >= 2
                and not J.IsLocationInChrono(nLocationAoE.targetloc)
                and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
                then
                    BlinkLocation = nLocationAoE.targetloc
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkRP()
    if  ReversePolarity:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = ReversePolarity:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

function X.ConsiderBlinkForSkewer()
    if CanDoBlinkSkewer()
    then
        local botTarget = J.GetProperTarget(bot)

        if J.IsGoingOnSomeone(bot)
        then
            local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

            if  J.IsValidTarget(botTarget)
            and J.CanCastOnNonMagicImmune(botTarget)
            and J.IsInRange(bot, botTarget, 1199)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
            and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and nInRangeAlly ~= nil and nInRangeEnemy
            and #nInRangeAlly >= #nInRangeEnemy
            then
                BlinkLocation = botTarget:GetLocation()
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSkewer2()
    local nRadius = Skewer:GetSpecialValueInt('skewer_radius')
    local nDist = Skewer:GetSpecialValueInt('range')

    local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
    local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)
    local nInRangeEnemy2 = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nInRangeEnemy2)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
        and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            if  J.IsEnemyBetweenMeAndLocation(bot, J.GetEscapeLoc(), nDist)
            and J.IsInRange(bot, enemyHero, nRadius)
            then
                if #nInRangeAlly >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, nInRangeAlly[#nInRangeAlly]:GetLocation(), nDist)
                else
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetEscapeLoc(), nDist)
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkSkewer()
    if  Skewer:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = Skewer:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

function X.ConsiderBlinkRPSkewer()
    if CanDoBlinkRPSkewer()
    then
        local nCastRange = 1199
        local nCastPoint = Skewer:GetCastPoint() + ReversePolarity:GetCastPoint()
        local nRPRadius = ReversePolarity:GetSpecialValueInt('pull_radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRPRadius, nCastPoint, 0)

            if nLocationAoE.count >= 2
            then
                BlinkLocation = nLocationAoE.targetloc
                local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRPRadius)

                if  realEnemyCount ~= nil and #realEnemyCount >= 2
                and not J.IsLocationInChrono(nLocationAoE.targetloc)
                and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkRPSkewer()
    if  Skewer:IsFullyCastable()
    and ReversePolarity:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = Skewer:GetManaCost() + ReversePolarity:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

function X.ConsiderBlinkForHornTossSkewer()
    if CanDoBlinkHornTossSkewer()
    then
        local botTarget = J.GetProperTarget(bot)

        if J.IsGoingOnSomeone(bot)
        then
            local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

            if  J.IsValidTarget(botTarget)
            and J.CanCastOnNonMagicImmune(botTarget)
            and J.IsInRange(bot, botTarget, 1199)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
            and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not botTarget:HasModifier('modifier_legion_commander_duel')
            and nInRangeAlly ~= nil and nInRangeEnemy
            and #nInRangeAlly >= #nInRangeEnemy
            then
                BlinkLocation = botTarget:GetLocation()
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkHornTossSkewer()
    if  (HornToss:IsTrained() and HornToss:IsFullyCastable())
    and Skewer:IsFullyCastable()
    and ReversePolarity:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = Skewer:GetManaCost() + ReversePolarity:GetManaCost() + HornToss:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
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

function CanBKB()
    local bkb = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if  item ~= nil
        and item:GetName() == "item_black_king_bar"
        then
			bkb = item
			break
		end
	end

    if  bkb ~= nil
    and bkb:IsFullyCastable()
    and bot:GetMana() >= 75
	then
        BlackKingBar = bkb
        return true
	end

    return false
end

return X