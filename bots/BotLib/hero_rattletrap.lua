local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
                        {--pos4
                            ['t25'] = {10, 0},
                            ['t20'] = {10, 0},
                            ['t15'] = {0, 10},
                            ['t10'] = {10, 0},
                        },
                        {--pos5
                            ['t25'] = {10, 0},
                            ['t20'] = {0, 10},
                            ['t15'] = {10, 0},
                            ['t10'] = {0, 10},
                        }
}

local tAllAbilityBuildList = {
                        {1,2,1,3,1,6,1,2,2,2,6,3,3,3,6},--pos4
                        {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6},--pos5
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_4"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
elseif sRole == "pos_5"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sGlimmerSolarCrest = RandomInt(1, 2) == 2 and "item_glimmer_cape" or "item_solar_crest"
local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_wind_lace",

    "item_boots",
    "item_magic_wand",
    "item_tranquil_boots",
    "item_urn_of_shadows",
    "item_force_staff",--
    "item_spirit_vessel",--
    sGlimmerSolarCrest,--
    "item_aghanims_shard",
    "item_boots_of_bearing",-- 
    "item_shivas_guard",--
    "item_heavens_halberd",--
    "item_ultimate_scepter",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_wind_lace",

    "item_boots",
    "item_magic_wand",
    "item_arcane_boots",
    "item_urn_of_shadows",
    "item_force_staff",--
    "item_spirit_vessel",--
    sGlimmerSolarCrest,--
    "item_aghanims_shard",
    "item_guardian_greaves",-- 
    "item_shivas_guard",--
    "item_heavens_halberd",--
    "item_ultimate_scepter",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos4SellList = {
    "item_magic_wand",
}

Pos5SellList = {
    "item_magic_wand",
}

X['sSellList'] = {}

if sRole == "pos_4"
then
    X['sSellList'] = Pos4SellList
elseif sRole == "pos_5"
then
    X['sSellList'] = Pos5SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local BatteryAssault    = bot:GetAbilityByName('rattletrap_battery_assault')
local PowerCogs         = bot:GetAbilityByName('rattletrap_power_cogs')
local RocketFlare       = bot:GetAbilityByName('rattletrap_rocket_flare')
local Jetpack           = bot:GetAbilityByName('rattletrap_jetpack')
local Overclocking      = bot:GetAbilityByName('rattletrap_overclocking')
local Hookshot          = bot:GetAbilityByName('rattletrap_hookshot')

local BatteryAssaultDesire
local PowerCogsDesire
local RocketFlareDesire, RocketFlareLocation
local JetpackDesire
local OverclockingDesire
local HookshotDesire, HookshotTarget

local cogsTime = -1
local ScoutRoshanTime = -1

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    OverclockingDesire = X.ConsiderOverclocking()
    if OverclockingDesire > 0
    then
        bot:Action_UseAbility(Overclocking)
        return
    end

    HookshotDesire, HookshotTarget = X.ConsiderHookshot()
    if HookshotDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Hookshot, HookshotTarget)
        return
    end

    PowerCogsDesire = X.ConsiderPowerCogs()
    if PowerCogsDesire > 0
    then
        bot:Action_UseAbility(PowerCogs)
        cogsTime = DotaTime()
        return
    end

    BatteryAssaultDesire = X.ConsiderBatteryAssault()
    if BatteryAssaultDesire > 0
    then
        bot:Action_UseAbility(BatteryAssault)
        return
    end

    RocketFlareDesire, RocketFlareLocation = X.ConsiderRocketFlare()
    if RocketFlareDesire > 0
    then
        bot:Action_UseAbilityOnLocation(RocketFlare, RocketFlareLocation)
        return
    end

    JetpackDesire = X.ConsiderJetpack()
    if JetpackDesire > 0
    then
        bot:Action_UseAbility(Jetpack)
        return
    end
end

function X.ConsiderBatteryAssault()
    if not BatteryAssault:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius    = BatteryAssault:GetSpecialValueInt('radius')

    local nAllyHeroes = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and J.IsCore(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.5)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nRadius)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.5
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nRadius)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
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
        local nEnemyCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        if nEnemyCreeps ~= nil and #nEnemyCreeps >= 3
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderPowerCogs()
    if  not PowerCogs:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = PowerCogs:GetSpecialValueInt('cogs_radius')
	local nDuration = PowerCogs:GetSpecialValueFloat('duration')

	if DotaTime() < cogsTime + nDuration
    then
		return BOT_ACTION_DESIRE_NONE
	end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 25)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.5
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and J.IsInRange(bot, enemyHero, nRadius + 200)
            and not J.IsInRange(bot, enemyHero, nRadius)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderRocketFlare()
    if not RocketFlare:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastPoint = RocketFlare:GetCastPoint()
	local nRadius = RocketFlare:GetSpecialValueInt('radius')
    local nDamage = RocketFlare:GetSpecialValueInt('damage')
	local nCastRange = 1600
    local RoshanLocation = J.GetCurrentRoshanLocation()
    local nTeamFightLocation = J.GetTeamFightLocation(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidTarget(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
        end
    end

    if nTeamFightLocation ~= nil
    then
        if GetUnitToLocationDistance(bot, nTeamFightLocation) > bot:GetCurrentVisionRange()
        then
            return BOT_ACTION_DESIRE_HIGH, nTeamFightLocation
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetCurrentVisionRange())
        and J.IsChasingTarget(bot, botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)
                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                else
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
                end
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, enemyHero, nRadius)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);

		if nLocationAoE.count >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end

		nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
		if nLocationAoE.count >= 4 and #nEnemyLanecreeps >= 4
		then
			return BOT_ACTION_DESIRE_MODERATE, J.GetCenterOfUnits(nEnemyLanecreeps)
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end

        if  GetUnitToLocationDistance(bot, RoshanLocation) > 1600
        and DotaTime() > ScoutRoshanTime + 15
        and J.GetManaAfter(RocketFlare:GetManaCost()) * bot:GetMana() > Hookshot:GetManaCost()
        then
            ScoutRoshanTime = DotaTime()
            return BOT_ACTION_DESIRE_HIGH, RoshanLocation
        end
    end

    if J.IsDoingTormentor(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderHookshot()
    if not Hookshot:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastPoint = Hookshot:GetCastPoint()
	local nCastRange = J.GetProperCastRange(false, bot, Hookshot:GetCastRange())
	local nRadius = Hookshot:GetSpecialValueInt('stun_radius')
	local nSpeed = Hookshot:GetSpecialValueInt('speed')

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidTarget(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and GetUnitToLocationDistance(enemyHero, J.GetEnemyFountain()) > 1000
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
                local eta = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
                local targetLoc = enemyHero:GetExtrapolatedLocation(eta)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                and not J.IsAllyHeroBetweenMeAndTarget(bot, enemyHero, targetLoc, nRadius)
                and not J.IsCreepBetweenMeAndTarget(bot, enemyHero, targetLoc, nRadius)
                and not J.IsLocationInChrono(targetLoc)
                and not J.IsLocationInArena(targetLoc, 800)
                then
                    if #nInRangeAlly == 0 and #nTargetInRangeAlly == 0
                    then
                        if  bot:GetEstimatedDamageToTarget(true, enemyHero, 5, DAMAGE_TYPE_ALL) > enemyHero:GetHealth()
                        and PowerCogs:IsFullyCastable()
                        and BatteryAssault:IsFullyCastable()
                        then
                            bot:SetTarget(enemyHero)
                            return BOT_ACTION_DESIRE_HIGH, targetLoc
                        end
                    else
                        if #nInRangeAlly >= 1
                        then
                            bot:SetTarget(enemyHero)
                            return BOT_ACTION_DESIRE_HIGH, targetLoc
                        end
                    end
                end
            end
        end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.75
	then
        local nAllyHeroes = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    for _, allyHero in pairs(nAllyHeroes)
                    do
                        if  J.IsValidHero(allyHero)
                        and bot:DistanceFromFountain() > 1600
                        and allyHero:DistanceFromFountain() > 1600
                        and bot:DistanceFromFountain() > allyHero:DistanceFromFountain()
                        and GetUnitToUnitDistance(bot, allyHero) > 1200
                        and not J.IsNotSelf(bot, allyHero)
                        then
                            local eta = (GetUnitToUnitDistance(bot, allyHero) / nSpeed) + nCastPoint
                            local targetLoc = allyHero:GetExtrapolatedLocation(eta)

                            if  not J.IsHeroBetweenMeAndTarget(bot, allyHero, targetLoc, nRadius)
                            and not J.IsCreepBetweenMeAndTarget(bot, allyHero, targetLoc, nRadius)
                            and not J.IsLocationInChrono(targetLoc)
                            and not J.IsLocationInArena(targetLoc, 800)
                            then
                                return BOT_ACTION_DESIRE_HIGH, targetLoc
                            end
                        end
                    end
                end
            end
        end

        local nNeutralCamps = GetNeutralSpawners()
		local escapeLoc = J.GetEscapeLoc()
		local targetLoc = GetUnitToLocationDistance(bot, escapeLoc)

		for _, camp in pairs(nNeutralCamps)
        do
			local campDist = J.GetDistance(camp.location, escapeLoc)

			if  campDist < targetLoc
			and GetUnitToLocationDistance(bot, camp.location) > 700
			then
				if  not J.IsHeroBetweenMeAndLocation(bot, camp.location, nRadius)
				and not J.IsCreepBetweenMeAndLocation(bot, camp.location, nRadius)
                and not J.IsLocationInChrono(camp.location)
                and not J.IsLocationInArena(camp.location, 800)
				then
					return BOT_ACTION_DESIRE_HIGH, camp.location
				end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderJetpack()
    if not Jetpack:IsTrained()
    or not Jetpack:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.5
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, 800)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2.5))
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderOverclocking()
    if not Overclocking:IsTrained()
    or not Overclocking:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X