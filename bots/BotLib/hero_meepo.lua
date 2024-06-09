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
						{2,3,6,1,2,2,2,3,3,6,3,1,1,1,6,6},--pos1,2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_wraith_band",
    "item_boots",
    "item_magic_wand",
    "item_power_treads",
    "item_diffusal_blade",
    "item_blink",
    "item_ultimate_scepter",
    "item_aghanims_shard",
    "item_disperser",--
    "item_skadi",--
    "item_basher",
    "item_sheepstick",--
    "item_ultimate_scepter_2",
    "item_abyssal_blade",--
    "item_swift_blink",--
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_wraith_band",
    "item_boots",
    "item_magic_wand",
    "item_power_treads",
    "item_diffusal_blade",
    "item_blink",
    "item_ultimate_scepter",
    "item_aghanims_shard",
    "item_disperser",--
    "item_skadi",--
    "item_sheepstick",--
    "item_ultimate_scepter_2",
    "item_nullifier",--
    "item_swift_blink",--
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_quelling_blade",
    "item_wraith_band",
    "item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local EarthBind         = bot:GetAbilityByName('meepo_earthbind')
local Poof              = bot:GetAbilityByName('meepo_poof')
-- local Ransack           = bot:GetAbilityByName('meepo_ransack')
local Dig               = bot:GetAbilityByName('meepo_petrify')
local MegaMeepo         = bot:GetAbilityByName('meepo_megameepo')
local MegaMeepoFling    = bot:GetAbilityByName('meepo_megameepo_fling')
-- local DivideWeStand     = bot:GetAbilityByName('meepo_divided_we_stand')

local EarthBindDesire, EarthBindLocation
local PoofDesire, PoofTarget
local DigDesire
local MegaMeepoDesire
local MegaMeepoFlingDesire, MegaMeepoFlingFlingTarget

local Meepos = {}

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    Meepos = J.GetMeepos()

    PoofDesire, PoofTarget = X.ConsiderPoof()
    if PoofDesire > 0
    then
        J.SetQueuePtToINT(bot, true)
        bot:Action_UseAbilityOnEntity(Poof, PoofTarget)
        return
    end

    DigDesire = X.ConsiderDig()
    if DigDesire > 0
    then
        bot:Action_UseAbility(Dig)
        return
    end

    MegaMeepoDesire = X.ConsiderMegaMeepo()
    if MegaMeepoDesire > 0
    then
        bot:Action_UseAbility(MegaMeepo)
        return
    end

    EarthBindDesire, EarthBindLocation = X.ConsiderEarthBind()
    if EarthBindDesire > 0
    then
        J.SetQueuePtToINT(bot, true)
        bot:Action_UseAbilityOnLocation(EarthBind, EarthBindLocation)
        return
    end

    MegaMeepoFlingDesire, MegaMeepoFlingFlingTarget = X.ConsiderMegaMeepoFling()
    if MegaMeepoFlingDesire > 0
    then
        bot:Action_UseAbilityOnEntity(MegaMeepoFling, MegaMeepoFlingFlingTarget)
        return
    end
end

function X.ConsiderEarthBind()
    if not EarthBind:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, EarthBind:GetCastRange())
    local nCastPoint = EarthBind:GetCastPoint()
	local nRadius = EarthBind:GetSpecialValueInt('radius')
	local nSpeed = EarthBind:GetSpecialValueInt('speed')
    local nModeDesire = bot:GetActiveModeDesire()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and (enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero))
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        if nLocationAoE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_meepo_earthbind')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
        end
	end

    if  J.IsRetreating(bot)
    and nModeDesire > BOT_ACTION_DESIRE_HIGH
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.62 and bot:WasRecentlyDamagedByAnyHero(2)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_meepo_earthbind')
        then
            local nDelay = (GetUnitToUnitDistance(bot, nInRangeEnemy[1]) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetExtrapolatedLocation(nDelay)
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, nCastRange, true, BOT_MODE_NONE)

        if  J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2.1)
        and not allyHero:IsIllusion()
        and J.GetMP(bot) > 0.48
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
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_meepo_earthbind')
            then
                local nDelay = (GetUnitToUnitDistance(bot, nAllyInRangeEnemy[1]) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(nDelay + nCastPoint)
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderPoof()
    if not Poof:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nRadius = Poof:GetSpecialValueInt('radius')
	local nDamage = Poof:GetAbilityDamage()

    for _, meepo in pairs(Meepos)
    do
        local mTarget = meepo:GetAttackTarget()

        if J.IsGoingOnSomeone(meepo)
        then
            local nInRangeAlly = J.GetNearbyHeroes(meepo, 1000, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(meepo, 800, true, BOT_MODE_NONE)

            if  J.IsValidTarget(mTarget)
            and J.IsInRange(meepo, mTarget, 800)
            and not J.IsRetreating(bot)
            and not J.IsSuspiciousIllusion(mTarget)
            and nInRangeAlly ~= nil and nInRangeEnemy
            and #nInRangeAlly >= #nInRangeEnemy
            and GetUnitToUnitDistance(bot, meepo) > 1600
            then
                return BOT_ACTION_DESIRE_HIGH, meepo
            end
        end

        if  J.IsLaning(bot)
        and J.IsLaning(meepo)
        and meepo ~= bot
        then
            local laneFrontLoc = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)

            if  GetUnitToLocationDistance(bot, laneFrontLoc) > 1600
            and GetUnitToLocationDistance(meepo, laneFrontLoc) < 600
            then
                return BOT_ACTION_DESIRE_HIGH, meepo
            end
        end

        if J.IsDoingRoshan(meepo)
        then
            local nInRangeEnemy = J.GetNearbyHeroes(meepo, 800, true, BOT_MODE_NONE)

            if  J.IsRoshan(mTarget)
            and J.IsInRange(meepo, mTarget, 400)
            and J.GetHP(mTarget) > 0.33
            and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
            then
                return BOT_ACTION_DESIRE_HIGH, meepo
            end
        end

        if J.IsDoingTormentor(meepo)
        then
            local nInRangeEnemy = J.GetNearbyHeroes(meepo, 800, true, BOT_MODE_NONE)

            if  J.IsTormentor(mTarget)
            and J.IsInRange(meepo, mTarget, 400)
            and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
            then
                return BOT_ACTION_DESIRE_HIGH, meepo
            end
        end

        if  J.GetHP(bot) < 0.3
        and J.IsRetreating(bot)
        and meepo ~= bot
        and meepo:DistanceFromFountain() < 500
        then
            return BOT_ACTION_DESIRE_HIGH, meepo
        end
    end

	if  J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.8 and bot:WasRecentlyDamagedByAnyHero(1.3)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 1000)
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        then
            local targetMeepo = nil
            local dist = 0

            for _, meepo in pairs(Meepos)
            do
                if GetUnitToUnitDistance(bot, meepo) > dist
                then
                    targetMeepo = meepo
                    dist = GetUnitToUnitDistance(bot, meepo)
                end
            end

            if targetMeepo ~= nil and targetMeepo ~= bot
            then
                return BOT_ACTION_DESIRE_HIGH, targetMeepo
            end
        end
	end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        then
            local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(nRadius, true)
            if  nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 3
            and J.GetMP(bot) > 0.33
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end

            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
            if  nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
            and J.GetMP(bot) > 0.26
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
    end

    if  J.IsLaning(bot)
    and J.GetMP(bot) > 0.29
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        local canKillCreepsCount = 0

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
			then
                canKillCreepsCount = canKillCreepsCount + 1
			end
		end

        if canKillCreepsCount >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end

        local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius / 2.1, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            and J.GetMP(bot) > 0.76
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
			then
				nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

				if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
                and J.GetHP(bot) > 0.5 and not bot:WasRecentlyDamagedByAnyHero(2.7)
				then
					return BOT_ACTION_DESIRE_HIGH, bot
				end
			end
		end
	end

	if (J.IsDefending(bot) or J.IsPushing(bot))
	then
		local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(nRadius, true)
		if  nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end

	if  J.GetHP(bot)
    and not J.IsRetreating(bot)
    then
		for _, meepo in pairs(Meepos)
        do
            local nInRangeAlly = J.GetNearbyHeroes(meepo, 800, false, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(meepo, 1200, true, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and ((#Meepos >= #nInRangeEnemy)
                or (#nInRangeAlly >= #nInRangeEnemy))
            and GetUnitToUnitDistance(bot, meepo) > 1600
            and meepo:WasRecentlyDamagedByAnyHero(1.1)
            then
				return BOT_ACTION_DESIRE_HIGH, meepo
			end
		end
	end

	if  J.GetHP(bot)
    and not J.IsRetreating(bot)
    then
		for _, meepo in pairs(Meepos)
        do
            local nInRangeAlly = J.GetNearbyHeroes(meepo, 800, false, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(meepo, 324, true, BOT_MODE_NONE)

			if  nInRangeEnemy ~= nil
            and J.GetHP(bot) - J.GetHP(meepo) > 0.2
            then
				if  J.IsValidHero(nInRangeEnemy[1])
                and ((#Meepos >= #nInRangeEnemy)
                    or (#nInRangeAlly >= #nInRangeEnemy))
                and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
                and not J.IsLaning(meepo)
                then
					return BOT_ACTION_DESIRE_HIGH, meepo
				end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDig()
    if not Dig:IsTrained()
    or not Dig:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.GetHP(bot) < 0.49
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderMegaMeepo()
    if not MegaMeepo:IsTrained()
    or not MegaMeepo:IsFullyCastable()
    or bot:HasModifier('modifier_meepo_petrify')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = 600

    if J.IsGoingOnSomeone(bot)
    then
        local count = 0

        for _, meepo in pairs(Meepos)
        do

            if  meepo:WasRecentlyDamagedByAnyHero(1.2)
            and J.IsMeepoClone(meepo)
            and J.IsInRange(bot, meepo, nRadius)
            and not meepo:HasModifier('modifier_meepo_petrify')
            then
                count = count + 1
            end
        end

        if count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderMegaMeepoFling()
    if MegaMeepoFling:IsHidden()
    or not MegaMeepoFling:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = MegaMeepoFling:GetCastRange()
    local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
    local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

    if  J.IsGoingOnSomeone(bot)
    then
        local weakestTarget = J.GetAttackableWeakestUnit(bot, nCastRange, true, true)

        if  weakestTarget ~= nil
        and bot:WasRecentlyDamagedByAnyHero(3.1)
        and not J.IsMeepoClone(bot)
        and not weakestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            return BOT_ACTION_DESIRE_HIGH, weakestTarget
        end
    end

    local nCreeps = bot:GetNearbyCreeps(nCastRange, true)
    if  nCreeps ~= nil and #nCreeps >= 1
    and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
    then
        if  J.IsValid(nCreeps[1])
        and not J.IsMeepoClone(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, nCreeps[1]
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X