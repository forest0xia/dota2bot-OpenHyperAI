local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
                        ['t25'] = {0, 10},
                        ['t20'] = {10, 0},
                        ['t15'] = {0, 10},
                        ['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
                        {2,1,2,3,2,6,2,1,1,1,6,3,3,3,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sUtility = {"item_crimson_guard", "item_pipe", "item_lotus_orb", "item_heavens_halberd"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_bracer",
    "item_phase_boots",
    "item_magic_wand",
    "item_soul_ring",
    "item_echo_sabre",
    "item_desolator",--
    "item_aghanims_shard",
    "item_black_king_bar",--
    nUtility,--
    "item_assault",--
    "item_harpoon",--
    "item_abyssal_blade",--
    "item_ultimate_scepter",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_quelling_blade",
    "item_bracer",
    "item_phase_boots",
    "item_magic_wand",
    "item_soul_ring",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )
	Minion.MinionThink(hMinionUnit)
end

local Starbreaker       = bot:GetAbilityByName('dawnbreaker_fire_wreath')
local CelestialHammer   = bot:GetAbilityByName('dawnbreaker_celestial_hammer')
local Converge          = bot:GetAbilityByName('dawnbreaker_converge')
-- local Luminosity        = bot:GetAbilityByName('dawnbreaker_luminosity')
local SolarGuardian     = bot:GetAbilityByName('dawnbreaker_solar_guardian')

local CelestialHammerCastRangeTalent = bot:GetAbilityByName('special_bonus_unique_dawnbreaker_celestial_hammer_cast_range')

local StarbreakerDesire, StarbreakerLocation
local CelestialHammerDesire, CelestialHammerLocation
local ConvergeDesire
local SolarGuardianDesire, SolarGuardianLocation

local BlackKingBar
local ShouldBKB = false

local ConvergeHammerLocation = nil
local CelestialHammerTime = -1
local IsHammerCastedWhenRetreatingToEnemy = false

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    CelestialHammerDesire, CelestialHammerLocation = X.ConsiderCelestialHammer()
    if CelestialHammerDesire > 0
    then
        local nSpeed = CelestialHammer:GetSpecialValueInt('projectile_speed')
        ConvergeHammerLocation = CelestialHammerLocation

        if CelestialHammerCastRangeTalent:IsTrained()
        then
            nSpeed = nSpeed * (1 + (CelestialHammerCastRangeTalent:GetSpecialValueInt('value') / 100))
        end

        bot:Action_UseAbilityOnLocation(CelestialHammer, CelestialHammerLocation)
        CelestialHammerTime = DotaTime() + CelestialHammer:GetCastPoint() + (GetUnitToLocationDistance(bot, CelestialHammerLocation) / nSpeed)
        return
    end

    ConvergeDesire = X.ConsiderConverge()
    if ConvergeDesire > 0
    then
        bot:Action_UseAbility(Converge)
        return
    end

    StarbreakerDesire, StarbreakerLocation = X.ConsiderStarBreaker()
    if StarbreakerDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Starbreaker, StarbreakerLocation)
        return
    end

    SolarGuardianDesire, SolarGuardianLocation = X.ConsiderSolarGuardian()
    if SolarGuardianDesire > 0
    then
        if  CanBKB()
        and ShouldBKB
        then
            bot:Action_UseAbility(BlackKingBar)
            ShouldBKB = false
        end

        bot:Action_UseAbilityOnLocation(SolarGuardian, SolarGuardianLocation)
        return
    end
end

function X.ConsiderStarBreaker()
    if not Starbreaker:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nRadius = Starbreaker:GetSpecialValueInt('swipe_radius')
    local nComboDuration = Starbreaker:GetSpecialValueFloat('duration')
	local nCastPoint = Starbreaker:GetCastPoint()
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local nDamage = bot:GetAttackDamage()
                    + Starbreaker:GetSpecialValueInt('swipe_damage')
                    + Starbreaker:GetSpecialValueInt('smash_damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
	do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nRadius)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
        then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
            and J.IsInRange(bot, enemyHero, nRadius)
            and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nComboDuration + nCastPoint)
            end
        end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nRadius, nRadius, nComboDuration + nCastPoint, 0)

		if  nLocationAoE.count >= 2
        and not IsTargetLocInBigUlt(nLocationAoE.targetloc)
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nRadius * 2, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nRadius * 1.5, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nComboDuration + nCastPoint)
		end
	end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(300)
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nRadius, nRadius, 0, 0)

        if  nNeutralCreeps ~= nil and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
                                    or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep() and nLocationAoE.count >= 3))
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nRadius, nRadius, 0, 0)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nLocationAoE.count >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if  J.IsLaning(bot)
	and nMana > 0.4
	then
        local creepCount = 0
        local loc = nil
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep))
			and creep:GetHealth() <= nDamage
			then
                loc = creep:GetLocation()
                creepCount = creepCount + 1
			end
		end

        if  creepCount >= 2
        and loc ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, loc
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderCelestialHammer()
    if not CelestialHammer:IsFullyCastable()
    -- or bot:HasModifier('modifier_starbreaker_fire_wreath_caster')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = CelestialHammer:GetSpecialValueInt('range')
	local nCastPoint = CelestialHammer:GetCastPoint()
    local nSpeed = CelestialHammer:GetSpecialValueInt('projectile_speed')
    local nDamage = CelestialHammer:GetSpecialValueInt('hammer_damage')
    local nMana = bot:GetMana() / bot:GetMaxMana()

    if CelestialHammerCastRangeTalent:IsTrained()
    then
        nCastRange = nCastRange * (1 + (CelestialHammerCastRangeTalent:GetSpecialValueInt('value') / 100))
        nSpeed = nSpeed * (1 + (CelestialHammerCastRangeTalent:GetSpecialValueInt('value') / 100))
    end

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        then
            local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsInRange(bot, botTarget, 300)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and ((#nInRangeEnemy > #nInRangeAlly)
            or J.GetHP(bot) < 0.7 and bot:WasRecentlyDamagedByAnyHero(2))
        and J.IsValidHero(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
		and not J.IsRealInvisible(bot)
		then
            local nDelay = (GetUnitToUnitDistance(bot, nInRangeEnemy[1]) / nSpeed) + nCastPoint

            if GetUnitToUnitDistance(bot, nInRangeEnemy[1]) > 600
            then
                IsHammerCastedWhenRetreatingToEnemy = true
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetExtrapolatedLocation(nDelay)
            else
                IsHammerCastedWhenRetreatingToEnemy = false
                local loc = J.GetEscapeLoc()
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
            end
		end
	end

    if  J.IsLaning(bot)
    and nMana > 0.75
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        for _, creep in pairs(nEnemyLaneCreeps)
        do
            if  J.IsValid(creep)
            and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep))
            and creep:GetHealth() <= nDamage
            then
                local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

                if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 600
                then
                    return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderConverge()
    if not Converge:IsFullyCastable()
    or Converge:IsHidden()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = CelestialHammer:GetSpecialValueInt('range')
    local nSpeed = CelestialHammer:GetSpecialValueInt('projectile_speed')
    local botTarget = J.GetProperTarget(bot)

    if CelestialHammerCastRangeTalent:IsTrained()
    then
        nCastRange = nCastRange * (1 + (CelestialHammerCastRangeTalent:GetSpecialValueInt('value') / 100))
        nSpeed = nSpeed * (1 + (CelestialHammerCastRangeTalent:GetSpecialValueInt('value') / 100))
    end

    if  J.IsGoingOnSomeone(bot)
    and ConvergeHammerLocation ~= nil
    then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsInRange(bot, botTarget, 300)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(600, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            and GetUnitToLocationDistance(botTarget, ConvergeHammerLocation) < GetUnitToLocationDistance(bot, ConvergeHammerLocation)
            and DotaTime() >= CelestialHammerTime
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
    end

    if  J.IsRetreating(bot)
    and not IsHammerCastedWhenRetreatingToEnemy
    then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and ((#nInRangeEnemy > #nInRangeAlly)
            or J.GetHP(bot) and bot:WasRecentlyDamagedByAnyHero(2))
        and J.IsValidHero(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
		and not J.IsRealInvisible(bot)
		then
            local loc = J.GetEscapeLoc()
            if  bot:IsFacingLocation(loc, 30)
            and DotaTime() >= CelestialHammerTime
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSolarGuardian()
    if not SolarGuardian:IsFullyCastable()
    -- or bot:HasModifier('modifier_starbreaker_fire_wreath_caster')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nChannelTime = SolarGuardian:GetChannelTime()
	local nRadius = SolarGuardian:GetSpecialValueInt('radius')
    local nAirTime = SolarGuardian:GetSpecialValueFloat('airtime_duration')
    local nCastPoint = SolarGuardian:GetCastPoint()
    local nTeamFightLocation = J.GetTeamFightLocation(bot)

    local nTotalCastTime = nChannelTime + nAirTime + nCastPoint

    if nTeamFightLocation ~= nil
    then
        local nAllyList = J.GetAlliesNearLoc(nTeamFightLocation, nRadius)

        if nAllyList ~= nil and #nAllyList >= 1
        then
            local nNeabyEnemyNearAllyList = nAllyList[#nAllyList]:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

            if  not IsTargetLocInBigUlt(nTeamFightLocation)
            and (nNeabyEnemyNearAllyList ~= nil and #nNeabyEnemyNearAllyList >= 1)
            then
                local aLocationAoE = bot:FindAoELocation(false, true, nTeamFightLocation, GetUnitToLocationDistance(bot, nTeamFightLocation), nRadius, nTotalCastTime, 0)
                local eLocationAoE = bot:FindAoELocation(true, true, nTeamFightLocation, GetUnitToLocationDistance(bot, nTeamFightLocation), nRadius, nTotalCastTime, 0)
                local nInRangeEnemy = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

                if  aLocationAoE.count >= 1 and eLocationAoE.count >= 1
                then
                    if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                    and not bot:IsMagicImmune()
                    then
                        ShouldBKB = true
                    end

                    return BOT_ACTION_DESIRE_HIGH, aLocationAoE.targetloc
                end
            end
        end
    end

    local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
    if (J.IsRetreating(bot) and bot:DistanceFromFountain() > 1600 and J.GetHP(bot) < 0.33)
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if  bot:WasRecentlyDamagedByHero(enemyHero, 2.0)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsRealInvisible(bot)
			then
                local nAllyHeroes = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
                local furthestAlly = nil

                for i = 1, 5
                do
                    local ally = GetTeamMember(i)
                    local dist = 0

                    if  ally ~= nil
                    and ally:IsAlive()
                    and GetUnitToUnitDistance(bot, ally) > dist
                    then
                        dist = GetUnitToUnitDistance(bot, ally)
                        furthestAlly = ally
                    end
                end

				if  nAllyHeroes ~= nil
				and (#nAllyHeroes <= 1 and #nEnemyHeroes >= 3)
                and furthestAlly ~= nil and GetUnitToUnitDistance(bot, furthestAlly) > 2500
                and bot:IsMagicImmune()
				then
					return BOT_ACTION_DESIRE_MODERATE, furthestAlly:GetLocation()
				end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

-- Helper Func
function IsTargetLocInBigUlt(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if  J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 450
		and enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			return true
		end
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
	then
        BlackKingBar = bkb
        return true
	end

    return false
end

return X