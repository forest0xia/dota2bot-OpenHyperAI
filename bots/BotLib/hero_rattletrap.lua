local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sOutfitType   = J.Item.GetOutfitType( bot )

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

if sOutfitType == "outfit_priest"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
elseif sOutfitType == "outfit_mage"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sGlimmerSolarCrest = RandomInt(1, 2) == 2 and "item_glimmer_cape" or "item_solar_crest"
local tOutFitList = {}

tOutFitList['outfit_carry'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = {
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
    "item_recipe_ultimate_scepter_2",
    "item_moon_shard",
}

tOutFitList['outfit_mage'] = {
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
    "item_recipe_ultimate_scepter_2",
    "item_moon_shard",
}

X['sBuyList'] = tOutFitList[sOutfitType]

Pos4SellList = {
    "item_magic_wand",
}

Pos5SellList = {
    "item_magic_wand",
}

X['sSellList'] = {}

if sOutfitType == "outfit_priest"
then
    X['sSellList'] = Pos4SellList
elseif sOutfitType == "outfit_mage"
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

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

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
        local allyTarget = allyHero:GetTarget()

        if allyHero:WasRecentlyDamagedByAnyHero(2)
        and J.IsValidTarget(allyTarget)
        and J.CanCastOnNonMagicImmune(allyTarget)
        and J.IsRetreating(allyHero)
        and J.IsInRange(bot, allyHero, nRadius)
        and not J.IsSuspiciousIllusion(allyTarget)
        then
            if J.GetHP(allyHero) < 0.5
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                return BOT_ACTION_DESIRE_MODERATE
            end
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)
        local nAllyHeroes2 = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
		then
            if nAllyHeroes2 ~= nil and #nAllyHeroes2 >= 1
            then
                if J.GetHP(botTarget) < 0.5
                then
                    return BOT_ACTION_DESIRE_HIGH
                else
                    return BOT_ACTION_DESIRE_LOW
                end
            end
		end
	end

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nEnemyHeroes)
        do
			if bot:WasRecentlyDamagedByAnyHero(2.5)
            and J.IsValidTarget(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
			then
                if J.GetHP(bot) < 0.44
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        local botAttackTarget = bot:GetAttackTarget()

        if J.IsRoshan(botAttackTarget)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nRadius, nRadius, 0, 0)

        if not J.IsThereCoreNearby(800)
        then
            if nLocationAoE.count >= 4
            then
                return BOT_ACTION_DESIRE_HIGH
            end
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
    local insideRadius = 70

	if DotaTime() < cogsTime + nDuration
    then
		return BOT_ACTION_DESIRE_NONE
	end

    if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)
        local nAllyHeroes = bot:GetNearbyHeroes(700, false, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, nRadius - insideRadius)
        and not J.IsSuspiciousIllusion(botTarget)
		then
			if nAllyHeroes ~= nil and #nAllyHeroes >= 1
            then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nAllyHeroes = bot:GetNearbyHeroes(700, false, BOT_MODE_NONE)
        local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if  (nAllyHeroes ~= nil and #nAllyHeroes <= 1)
        and (nEnemyHeroes ~= nil and #nEnemyHeroes >= 1)
        then
			if bot:WasRecentlyDamagedByAnyHero(2)
            and J.IsInRange(bot, nEnemyHeroes[1], nRadius + 20)
            and not J.IsSuspiciousIllusion(nEnemyHeroes[1])
            then
                if J.GetHP(bot) < 0.33
                then
                    return BOT_ACTION_DESIRE_VERYHIGH
                else
                    return BOT_ACTION_DESIRE_MODERATE
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

    local timeOfDay = J.CheckTimeOfDay()
    local roshanRadiantLoc  = Vector(7625, -7511, 1092)
    local roshanDireLoc     = Vector(-7549, 7562, 1107)

    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    then
        return BOT_ACTION_DESIRE_HIGH, nTeamFightLocation
    end

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidTarget(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            return BOT_ACTION_DESIRE_ABSOLUTE, enemyHero:GetLocation()
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
		end
	end

    if J.IsRetreating(bot)
	then
        if J.GetHP(bot) < 0.2
        and bot:WasRecentlyDamagedByAnyHero(2)
        then
            local botTarget = J.GetProperTarget(bot)

            if J.IsValidTarget(botTarget)
            and J.CanCastOnNonMagicImmune(botTarget)
            and not J.IsSuspiciousIllusion(botTarget)
            then
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end
        end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);

		if nLocationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end

		nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
		if nLocationAoE.count >= 4 and #nEnemyLanecreeps >= 4
		then
			return BOT_ACTION_DESIRE_MODERATE, nLocationAoE.targetloc
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if timeOfDay == 'day'
        and GetUnitToLocationDistance(bot, roshanRadiantLoc) > 1600
        then
            return BOT_ACTION_DESIRE_HIGH, roshanRadiantLoc
        elseif timeOfDay == 'night'
        and GetUnitToLocationDistance(bot, roshanDireLoc) > 1600
        then
            return BOT_ACTION_DESIRE_HIGH, roshanDireLoc
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
		local botTarget = J.GetProperTarget(bot)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
		then
			local dist = GetUnitToUnitDistance(bot, botTarget)
			local targetLoc = botTarget:GetExtrapolatedLocation(nCastPoint + (dist / nSpeed))

			if  not J.IsAllyHeroBetweenMeAndTarget(bot, botTarget, targetLoc, nRadius)
			and not J.IsCreepBetweenMeAndTarget(bot, botTarget, targetLoc, nRadius)
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_RETREAT)
		local botBaseDist = bot:DistanceFromFountain()

		for _, allyHero in pairs(nAllyHeroes)
        do
			if J.IsValidTarget(allyHero)
            and J.CanCastOnMagicImmune(allyHero)
            and bot:WasRecentlyDamagedByAnyHero(2)
            and allyHero:DistanceFromFountain() < botBaseDist
            and GetUnitToUnitDistance(bot, allyHero) > nCastRange
			and not J.IsNotSelf(bot, allyHero)
			then
				local dist = GetUnitToUnitDistance(bot, allyHero)
				local targetLoc = allyHero:GetExtrapolatedLocation(nCastPoint + (dist / nSpeed))

				if  not J.IsHeroBetweenMeAndTarget(bot, allyHero, targetLoc, nRadius)
				and not J.IsCreepBetweenMeAndTarget(bot, allyHero, targetLoc, nRadius)
				then
					return BOT_ACTION_DESIRE_HIGH, targetLoc
				end
			end
		end

        local nNeutralCamps = GetNeutralSpawners()
		local escapeLoc = J.GetEscapeLoc()
		local targetLoc = GetUnitToLocationDistance(bot, escapeLoc)

		for _, camp in pairs(nNeutralCamps)
        do
			local campDist = J.GetDistance(camp.location, targetLoc)

			if campDist < targetLoc
			and GetUnitToLocationDistance(bot, camp.location) > 700
			then
				if  not J.IsHeroBetweenMeAndLocation(bot, camp.location, nRadius)
				and not J.IsCreepBetweenMeAndLocation(bot, camp.location, nRadius)
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
    and not Jetpack:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nAllyHeroes = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
    local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

    if J.IsRetreating(bot)
    then
        if  nAllyHeroes ~= nil and nEnemyHeroes ~= nil
        and #nAllyHeroes >= 1 and #nEnemyHeroes >= 1
        and not J.WeAreStronger(bot, 1200)
        and bot:WasRecentlyDamagedByAnyHero(1)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderOverclocking()
    if not Overclocking:IsTrained()
    and not Overclocking:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

    if J.IsInTeamFight(bot, 1200)
    then
        if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
        and J.WeAreStronger(bot, 1200)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X