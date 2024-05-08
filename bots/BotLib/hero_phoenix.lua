local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos4,5
                        ['t25'] = {0, 10},
                        ['t20'] = {0, 10},
                        ['t15'] = {10, 0},
                        ['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,1,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",

    "item_boots",
    "item_magic_wand",
    "item_tranquil_boots",
    "item_veil_of_discord",
    "item_aghanims_shard",
    "item_shivas_guard",--
    "item_force_staff",--
    "item_boots_of_bearing",--
    "item_cyclone",
    "item_refresher",--
    "item_sheepstick",--
    "item_wind_waker",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",

    "item_boots",
    "item_magic_wand",
    "item_arcane_boots",
    "item_veil_of_discord",
    "item_aghanims_shard",
    "item_force_staff",--
    "item_shivas_guard",--
    "item_guardian_greaves",--
    "item_cyclone",
    "item_refresher",--
    "item_sheepstick",--
    "item_wind_waker",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_4']

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
else
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

local IcarusDive        = bot:GetAbilityByName('phoenix_icarus_dive')
local IcarusDiveStop    = bot:GetAbilityByName('phoenix_icarus_dive_stop')
local FireSpirits       = bot:GetAbilityByName('phoenix_fire_spirits')
local FireSpiritsLaunch = bot:GetAbilityByName('phoenix_launch_fire_spirit')
local SunRay            = bot:GetAbilityByName('phoenix_sun_ray')
local SunRayStop        = bot:GetAbilityByName('phoenix_sun_ray_stop')
local ToggleMovement    = bot:GetAbilityByName('phoenix_sun_ray_toggle_move')
local Supernova         = bot:GetAbilityByName('phoenix_supernova')

local IcarusDiveDesire, IcarusDiveLocation
local IcarusDiveStopDesire
local FireSpiritsDesire
local FireSpiritsLaunchDesire, FireSpiritsLaunchLocation
local SunRayDesire, SunRayLocation
local SunRayStopDesire
local ToggleMovementDesire, State
local SupernovaDesire, SupernovaTarget

local IcarusDiveTime = -1
local IcarusDiveDuration = 2

local FireSpiritsLaunchTime = 0
local RetreatTeamFight = false

if bot.targetSunRay == nil then bot.targetSunRay = bot end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    FireSpiritsDesire = X.ConsiderFireSpirits()
    if FireSpiritsDesire > 0
    then
        bot:Action_UseAbility(FireSpirits)
        return
    end

    FireSpiritsLaunchDesire, FireSpiritsLaunchLocation, ETA = X.ConsiderFireSpiritsLaunch()
    if FireSpiritsLaunchDesire > 0
    then
        bot:Action_UseAbilityOnLocation(FireSpiritsLaunch, FireSpiritsLaunchLocation)
        FireSpiritsLaunchTime = DotaTime()
        return
    end

    SupernovaDesire, SupernovaTarget, AllyCast = X.ConsiderSupernova()
    if SupernovaDesire > 0
    then
        if  bot:HasScepter()
        and AllyCast
        then
            bot:Action_UseAbilityOnEntity(Supernova, SupernovaTarget)
        else
            bot:Action_UseAbility(Supernova)
        end

        return
    end

    IcarusDiveDesire, IcarusDiveLocation = X.ConsiderIcarusDive()
    if IcarusDiveDesire > 0
    then
        bot:Action_UseAbilityOnLocation(IcarusDive, IcarusDiveLocation)
        IcarusDiveTime = DotaTime()
        return
    end

    IcarusDiveStopDesire = X.ConsiderIcarusDiveStop()
    if IcarusDiveStopDesire > 0
    then
        bot:Action_UseAbility(IcarusDiveStop)
        return
    end

    SunRayDesire, SunRayLocation = X.ConsiderSunRay()
    if SunRayDesire > 0
    then
        bot:Action_UseAbilityOnLocation(SunRay, SunRayLocation)
        return
    end

    SunRayStopDesire = X.ConsiderSunRayStop()
    if SunRayStopDesire > 0
    then
        bot:Action_UseAbility(SunRayStop)
        return
    end

    ToggleMovementDesire, State = X.ConsiderToggleMovement()
    if ToggleMovementDesire > 0
    then
		if State == 'on'
        then
			if not ToggleMovement:GetToggleState()
            then
				bot:Action_UseAbility(ToggleMovement)
			end
		else
			if ToggleMovement:GetToggleState()
            then
				bot:Action_UseAbility(ToggleMovement)
			end
		end

        return
    end
end

function X.ConsiderIcarusDive()
    if IcarusDive:IsHidden()
    or not IcarusDive:IsFullyCastable()
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nDiveLength = IcarusDive:GetSpecialValueInt('dash_length')
	local nDiveWidth = IcarusDive:GetSpecialValueInt('dash_width')
    local nHealthCost = (IcarusDive:GetSpecialValueInt('hp_cost_perc') / 100) * bot:GetHealth()
	local nDamage = IcarusDive:GetSpecialValueInt('damage_per_second') * IcarusDive:GetSpecialValueFloat('burn_duration')
    local nHealth = (bot:GetHealth() - nHealthCost) / bot:GetMaxHealth()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nDiveLength, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not J.IsLocationInChrono(enemyHero:GetLocation())
        and not J.IsLocationInBlackHole(enemyHero:GetLocation())
        and nHealth > 0.4
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
    end

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(bot, loc, nDiveLength)
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nDiveLength, nDiveWidth / 1.5, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 600)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            RetreatTeamFight = true
            local loc = J.GetEscapeLoc()
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nDiveLength)
        end

		if  nLocationAoE.count >= 2
        and not J.IsLocationInChrono(nLocationAoE.targetloc)
        and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
        and nHealth > 0.3
        then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nDiveLength)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsLocationInChrono(botTarget:GetLocation())
        and not J.IsLocationInBlackHole(botTarget:GetLocation())
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and nHealth > 0.3
        then
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly + 1
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.88 and bot:WasRecentlyDamagedByAnyHero(1.8)))
            and nHealth > 0.15
            then
                local loc = J.GetEscapeLoc()
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nDiveLength)
            end
        end

        if  J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByTower(1.5)
        and nHealth > 0.2
        then
            local loc = J.GetEscapeLoc()
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nDiveLength)
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderIcarusDiveStop()
    if IcarusDiveStop:IsHidden()
    or not IcarusDiveStop:IsFullyCastable()
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local botTarget = J.GetProperTarget(bot)

    if RetreatTeamFight
    then
        if DotaTime() > (IcarusDiveTime + (IcarusDiveDuration / 2))
        then
            RetreatTeamFight = false
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        then
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            and #nTargetInRangeAlly <= 1
            and DotaTime() > (IcarusDiveTime + (IcarusDiveDuration / 2))
            then
                local nTargetInRangeTower = botTarget:GetNearbyHeroes(700, false, BOT_MODE_NONE)
                local nTargetInRangeEnemy = botTarget:GetNearbyHeroes(700, true, BOT_MODE_NONE)

                if J.IsInLaningPhase()
                then
                    if  nTargetInRangeTower ~= nil and #nTargetInRangeAlly == 0
                    and nTargetInRangeEnemy ~= nil and #nTargetInRangeEnemy >= 1
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                else
                    if nTargetInRangeEnemy ~= nil and #nTargetInRangeEnemy >= 1
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end
            end
        end
    end

    if J.IsRetreating(bot)
    then
        if DotaTime() > (IcarusDiveTime + (IcarusDiveDuration / 2))
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderFireSpirits()
    if FireSpirits:IsHidden()
    or not FireSpirits:IsFullyCastable()
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    or bot:HasModifier('modifier_phoenix_fire_spirit_count')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = FireSpirits:GetCastRange()
	local nRadius = FireSpirits:GetSpecialValueInt('radius')
    local nHealthCost = (FireSpirits:GetSpecialValueInt('hp_cost_perc') / 100) * bot:GetHealth()
	local nDamage = FireSpirits:GetSpecialValueInt('damage_per_second') * FireSpirits:GetSpecialValueFloat('duration')
    local nHealth = (bot:GetHealth() - nHealthCost) / bot:GetMaxHealth()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nHealth > 0.4
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if  #nInRangeEnemy >= 2
        and not J.DoesSomeoneHaveModifier(nInRangeEnemy, 'modifier_phoenix_fire_spirit_burn')
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsLocationInChrono(botTarget:GetLocation())
        and not J.IsLocationInBlackHole(botTarget:GetLocation())
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
        and nHealth > 0.3
        then
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if  (J.IsPushing(bot) or J.IsDefending(bot))
    and not J.IsThereCoreNearby(1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nLocationAoE.count >= 4
        and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        and J.GetMP(bot) > 0.42
        and nHealth > 0.5
        and not J.DoesSomeoneHaveModifier(nEnemyLaneCreeps, 'modifier_phoenix_fire_spirit_burn')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if  J.IsFarming(bot)
    and J.GetMP(bot) > 0.42
    and nHealth > 0.5
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
        if  nNeutralCreeps ~= nil
        and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
            or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep() and nLocationAoE.count >= 2))
        and not J.DoesSomeoneHaveModifier(nNeutralCreeps, 'modifier_phoenix_fire_spirit_burn')
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nLocationAoE.count >= 3
        and not J.DoesSomeoneHaveModifier(nEnemyLaneCreeps, 'modifier_phoenix_fire_spirit_burn')
        and not J.IsThereCoreNearby(1200)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and nHealth > 0.6
        and not botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        and nHealth > 0.7
        and not botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderFireSpiritsLaunch()
    if FireSpiritsLaunch:IsHidden()
    or not FireSpiritsLaunch:IsFullyCastable()
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = FireSpirits:GetCastRange()
	local nRadius = FireSpirits:GetSpecialValueInt('radius')
    local nSpeed = FireSpirits:GetSpecialValueInt('spirit_speed')
    local nDuration = FireSpirits:GetSpecialValueFloat('burn_duration')
	local nDamage = FireSpirits:GetSpecialValueInt('damage_per_second') * nDuration
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local eta = GetUnitToUnitDistance(bot, enemyHero) / nSpeed

            if  DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and enemyHero:HasModifier('modifier_phoenix_fire_spirit_burn')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(eta)
            end
        end
    end

    if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if  #nInRangeEnemy >= 2
        then
            local eta = GetUnitToLocationDistance(bot, nLocationAoE.targetloc) / nSpeed

            if  DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and not J.DoesSomeoneHaveModifier(nInRangeEnemy, 'modifier_phoenix_fire_spirit_burn')
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
		end
	end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsLocationInChrono(botTarget:GetLocation())
        and not J.IsLocationInBlackHole(botTarget:GetLocation())
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                local eta = GetUnitToUnitDistance(bot, botTarget) / nSpeed

                if  DotaTime() > FireSpiritsLaunchTime + eta + 0.25
                and botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(eta)
                end
            end
        end
    end

    if  (J.IsPushing(bot) or J.IsDefending(bot))
    and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
    and not J.IsThereCoreNearby(1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nLocationAoE.count >= 4
        and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        and not J.DoesSomeoneHaveModifier(nEnemyLaneCreeps, 'modifier_phoenix_fire_spirit_burn')
        then
            local eta = GetUnitToLocationDistance(bot, nLocationAoE.targetloc) / nSpeed

            if  DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and not J.DoesSomeoneHaveModifier(nEnemyLaneCreeps, 'modifier_phoenix_fire_spirit_burn')
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    if nEnemyHeroes ~= nil and #nEnemyHeroes == 0
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
        if  nNeutralCreeps ~= nil
        and (#nNeutralCreeps >= 2 and nLocationAoE.count >= 2)
        and not J.DoesSomeoneHaveModifier(nNeutralCreeps, 'modifier_phoenix_fire_spirit_burn')
        then
            local eta = GetUnitToLocationDistance(bot, nLocationAoE.targetloc) / nSpeed

            if  DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and not J.DoesSomeoneHaveModifier(nNeutralCreeps, 'modifier_phoenix_fire_spirit_burn')
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nLocationAoE.count >= 3
        and not J.DoesSomeoneHaveModifier(nEnemyLaneCreeps, 'modifier_phoenix_fire_spirit_burn')
        and not J.IsThereCoreNearby(1200)
        then
            local eta = GetUnitToLocationDistance(bot, nLocationAoE.targetloc) / nSpeed

            if  DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and not J.DoesSomeoneHaveModifier(nEnemyLaneCreeps, 'modifier_phoenix_fire_spirit_burn')
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    if J.IsInLaningPhase()
    then
        local strongestEnemy = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

        if  J.IsValidTarget(strongestEnemy)
        and J.CanCastOnNonMagicImmune(strongestEnemy)
        and not J.IsSuspiciousIllusion(strongestEnemy)
        and not strongestEnemy:HasModifier('modifier_abaddon_borrowed_time')
        and not strongestEnemy:HasModifier('modifier_dazzle_shallow_grave')
        and not strongestEnemy:HasModifier('modifier_necrolyte_reapers_scythe')
        and not strongestEnemy:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            local eta = GetUnitToUnitDistance(bot, strongestEnemy) / nSpeed

            if  DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and strongestEnemy:HasModifier('modifier_phoenix_fire_spirit_burn')
            then
                return BOT_ACTION_DESIRE_HIGH, strongestEnemy:GetExtrapolatedLocation(eta)
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            local eta = GetUnitToUnitDistance(bot, botTarget) / nSpeed

            if  DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            local eta = GetUnitToUnitDistance(bot, botTarget) / nSpeed

            if  DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

local sunRayTarget = nil
function X.ConsiderSunRay()
    if SunRay:IsHidden()
    or not SunRay:IsFullyCastable()
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_sun_ray')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, SunRay:GetCastRange())
	if nCastRange > 1600 then nCastRange = 1600 end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
        local weakestEnemy = J.GetVulnerableWeakestUnit(bot, true, true, nCastRange)

        if  J.IsValidTarget(weakestEnemy)
        and J.CanCastOnNonMagicImmune(weakestEnemy)
        and J.IsInRange(bot, weakestEnemy, nCastRange)
        and bot:IsFacingLocation(weakestEnemy:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(weakestEnemy)
        and not weakestEnemy:HasModifier('modifier_abaddon_borrowed_time')
        and not weakestEnemy:HasModifier('modifier_dazzle_shallow_grave')
        and not weakestEnemy:HasModifier('modifier_necrolyte_reapers_scythe')
        and J.GetHP(bot) > 0.4
        then
            local nTargetInRangeAlly = weakestEnemy:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                bot.targetSunRay = weakestEnemy
                sunRayTarget = weakestEnemy
                return BOT_ACTION_DESIRE_HIGH, weakestEnemy:GetLocation()
            end
        end

        nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if  J.IsValidHero(allyHero)
            and J.IsCore(allyHero)
            and J.GetHP(allyHero) < 0.5
            and allyHero:WasRecentlyDamagedByAnyHero(1.2)
            and bot:IsFacingLocation(allyHero:GetLocation(), 30)
            and not allyHero:IsIllusion()
            then
                bot.targetSunRay = allyHero
                return BOT_ACTION_DESIRE_HIGH, allyHero:GetLocation()
            end
        end
    end

    bot.targetSunRay = nil

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderSunRayStop()
    if SunRayStop:IsHidden()
    or not SunRayStop:IsFullyCastable()
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or not bot:HasModifier('modifier_phoenix_sun_ray')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = J.GetProperCastRange(false, bot, SunRay:GetCastRange())
	if nCastRange > 1600 then nCastRange = 1600 end

	local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_ATTACK)
	local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

	if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
    and (#nInRangeAlly < #nInRangeEnemy
        or #nInRangeEnemy == 0
        or (J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByAnyHero(1.7)))
        or J.GetHP(bot) < 0.35
    then
		return BOT_ACTION_DESIRE_HIGH
	end

    if  J.IsValidTarget(botTarget)
    and not bot:IsFacingLocation(botTarget:GetLocation(), 60)
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderToggleMovement()
    if ToggleMovement:IsHidden()
    or not ToggleMovement:IsFullyCastable()
    or not bot:HasModifier('modifier_phoenix_sun_ray')
    then
        return BOT_ACTION_DESIRE_NONE, ''
    end

    if J.IsGoingOnSomeone(bot)
	then
		if sunRayTarget ~= nil
		then
            if GetUnitToUnitDistance(bot, sunRayTarget) > bot:GetAttackRange()
            then
                return BOT_ACTION_DESIRE_MODERATE, 'on'
            else
                return BOT_ACTION_DESIRE_MODERATE, 'off'
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE, ''
end

function X.ConsiderSupernova()
    if Supernova:IsHidden()
    or not Supernova:IsFullyCastable()
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    then
        return BOT_ACTION_DESIRE_NONE, nil, false
    end

	local nCastRange = Supernova:GetSpecialValueInt('cast_range_tooltip_scepter')
	local nRadius = Supernova:GetSpecialValueInt('aura_radius')

    if J.IsInTeamFight(bot, 1200)
	then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), (nRadius / 2) + 250)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            if bot:HasScepter()
            then
                local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)

                for _, allyHero in pairs(nInRangeAlly)
                do
                    if J.IsRetreating(allyHero)
                    or (J.GetHP(allyHero) < 0.33
                        and allyHero:WasRecentlyDamagedByAnyHero(1.5))
                    then
                        return BOT_ACTION_DESIRE_HIGH, allyHero, true
                    end
                end
            else
                return BOT_ACTION_DESIRE_HIGH, nil, false
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil, false
end

return X