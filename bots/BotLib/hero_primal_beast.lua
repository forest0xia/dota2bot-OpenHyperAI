local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						{--pos2
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {10, 0},
                            ['t10'] = {10, 0},
                        },--pos3
                        {
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {0, 10},
                            ['t10'] = {10, 0},
                        }
}

local tAllAbilityBuildList = {
						{2,3,1,2,1,6,2,2,1,1,6,3,3,3,6},--pos2
                        {1,2,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_2"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
else
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sUtility = {"item_pipe", "item_lotus_orb", "item_crimson_guard"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_quelling_blade",
    "item_double_branches",

    "item_bracer",
    "item_bottle",
    "item_boots",
    "item_magic_wand",
    "item_phase_boots",
    "item_blink",
    "item_shivas_guard",--
    "item_black_king_bar",--
    "item_ultimate_scepter",
    "item_heart",--
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_travel_boots",
    "item_travel_boots_2",--
    "item_moon_shard",
    "item_aghanims_shard",
    "item_kaya_and_sange",--
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
    nUtility,--
    "item_black_king_bar",--
    "item_travel_boots",
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--
    "item_aghanims_shard",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = {
	'item_priest_outfit',
	"item_mekansm",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
	"item_lotus_orb",
	"item_gungir",--
	--"item_holy_locket",
	"item_sheepstick",
	"item_mystic_staff",
	"item_ultimate_scepter_2",
	"item_shivas_guard",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
	'item_mage_outfit',
	"item_glimmer_cape",

    "item_pavise",
    "item_solar_crest",--
	"item_lotus_orb",--
	"item_pipe",--
	
	"item_aghanims_shard",
	"item_spirit_vessel",--
	"item_shivas_guard",--
	"item_mystic_staff",
	"item_ultimate_scepter_2",
    "item_moon_shard",
	"item_sheepstick",--
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
    Minion.MinionThink(hMinionUnit, bot)
end

local Onslaught         = bot:GetAbilityByName('primal_beast_onslaught') -- Q 突
local Trample           = bot:GetAbilityByName('primal_beast_trample') -- W 踏
local Uproar            = bot:GetAbilityByName('primal_beast_uproar') -- E 咤
local RockThrow         = bot:GetAbilityByName('primal_beast_rock_throw') -- D 砸
local Pulverize         = bot:GetAbilityByName('primal_beast_pulverize') -- R 捶

local nTrampleRadius    = Trample:GetSpecialValueInt('effect_radius')
local nUproarRadius    = Trample:GetSpecialValueInt('radius')

local QDesire, QLocation
local WDesire
local EDesire
local DDesire, DLocation
local RDesire, RTarget
local botTarget

local nOnslaughtSpeed = Onslaught:GetSpecialValueInt('charge_speed')
local maxOnslaughtDistance = Onslaught:GetSpecialValueInt('max_distance')
local nAssumeOnSlaughtDistance = 1500
local nOnslaughtDamage = 200
local nAssumeOnslaughtDelay = 0.8  -- max_charge_time = 1.7, assume we will use ~half of the time

local nRockThrowCastRange = RockThrow:GetCastRange() -- 1800
local nRockThrowMinRange = RockThrow:GetSpecialValueInt('min_range')
local nRockThrowCastPoint = RockThrow:GetCastPoint()
local nRockThrowSpeed = 1200
local nRockThrowRadius = RockThrow:GetSpecialValueInt('impact_radius') + RockThrow:GetSpecialValueInt('fragment_impact_radius')

local nPulverizeCastRange
local nPulverizeDuration
local nPulverizeDamage

local chargedTime
local chargedDistance
local distanceToTarget
local nEnemyHeroes
local nInRangeAlly
local bysideEnemeyHeroes

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    if bot:HasModifier('modifier_primal_beast_pulverize_self')
    or bot:IsCastingAbility()
    or bot:IsUsingAbility()
    or bot:IsChanneling() then return end

    botTarget = J.GetProperTarget(bot)
	nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
	nInRangeAlly = J.GetNearbyHeroes(bot,1600, false, BOT_MODE_NONE)

    bysideEnemeyHeroes = J.GetNearbyHeroes(bot,nTrampleRadius, true, BOT_MODE_NONE)

    X.ConsiderStopQ()

	QDesire, QLocation = X.ConsiderQ()
    if QDesire > 0
	then
        bot:Action_ClearActions(false)
		bot:Action_UseAbilityOnLocation(Onslaught, QLocation)
		return
	end

	WDesire = X.ConsiderW()
    if WDesire > 0
	then
        bot:Action_ClearActions(false)
		bot:Action_UseAbility(Trample)
		return
	end

	EDesire = X.ConsiderE()
    if EDesire > 0
	then
        bot:Action_ClearActions(false)
		bot:Action_UseAbility(Uproar)
		return
	end

	DDesire, DLocation = X.ConsiderD()
    if DDesire > 0
	then
        bot:Action_ClearActions(false)
		bot:Action_UseAbilityOnLocation(RockThrow, DLocation)
		return
	end

	RDesire, RTarget = X.ConsiderR()
    if RDesire > 0
	then
        bot:Action_ClearActions(false)
		bot:Action_UseAbilityOnEntity(Pulverize, RTarget)
		return
	end


end

function X.ConsiderQ()
    if not Onslaught:IsFullyCastable() or bot:IsRooted()
	then
		return BOT_ACTION_DESIRE_NONE, 0, false
	end

	nOnslaughtDamage = Onslaught:GetSpecialValueInt('knockback_damage') + 200

    -- 打断技能
	for _, enemyHero in pairs(nEnemyHeroes)
	do
        botTarget = enemyHero
		if botTarget:IsChanneling() or J.IsCastingUltimateAbility(botTarget)
		and not J.IsSuspiciousIllusion(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), true
		end
	end

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nAssumeOnSlaughtDistance)
	end

	-- 击杀
    local target = J.GetCanBeKilledUnit(nEnemyHeroes, nOnslaughtDamage, DAMAGE_TYPE_MAGICAL, false)
    if target ~= nil
    and not J.IsSuspiciousIllusion(target)
    then
        botTarget = target
        local loc = J.GetCorrectLoc(botTarget, (GetUnitToUnitDistance(bot, botTarget) / nOnslaughtSpeed) + nAssumeOnslaughtDelay)
        return BOT_ACTION_DESIRE_HIGH, loc
    end

    -- gank
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nAssumeOnSlaughtDistance)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
		then
			local loc = J.GetCorrectLoc(botTarget, nAssumeOnslaughtDelay)
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), false
		end
	end

    -- retreat
	if J.IsRetreating(bot) and (J.GetHP(bot) < 0.5 or (nInRangeAlly ~= nil and nEnemyHeroes ~= nil and #nEnemyHeroes > #nInRangeAlly))
	then
		return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain(), false
	end

	return BOT_ACTION_DESIRE_NONE, 0, false
end

function X.ConsiderStopQ()
    if bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable')
    and J.IsValidTarget(botTarget) then
        chargedTime = 1.7 - J.GetModifierTime(bot, 'modifier_primal_beast_onslaught_movement_adjustable')
        if chargedTime >= 0.3 then
            distanceToTarget = GetUnitToUnitDistance(bot, botTarget)
            
            local loc = J.GetCorrectLoc(botTarget, (distanceToTarget / nOnslaughtSpeed) + 0.1)
            chargedDistance = maxOnslaughtDistance * (chargedTime / 1.7)
    
            if J.GetLocationToLocationDistance(bot:GetLocation(), loc) <= chargedDistance then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderW()
    if not Trample:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.IsGoingOnSomeone(bot)
    then
        for _, enemyHero in pairs(bysideEnemeyHeroes)
        do
            if J.IsValidHero(enemyHero)
            and (J.CanCastOnNonMagicImmune(enemyHero) or #bysideEnemeyHeroes >= 2)
            and J.IsInRange(bot, enemyHero, nTrampleRadius)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.HasMovableUndyingModifier(enemyHero, 0.1)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsRetreating(bot)
    then
        for _, enemyHero in pairs(bysideEnemeyHeroes)
        do
            if J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nTrampleRadius)
            and (J.CanCastOnNonMagicImmune(enemyHero) or #bysideEnemeyHeroes >= 2)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.HasMovableUndyingModifier(enemyHero, 0.1)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nTrampleRadius, true)

        if nEnemyLaneCreeps ~= nil
        then
            if #nEnemyLaneCreeps >= 1
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.2
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nTrampleRadius)
        if nNeutralCreeps ~= nil
        then
            if #nNeutralCreeps >= 1
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.35
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if J.GetHP(bot) < 0.35
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nTrampleRadius, true)
        if nEnemyLaneCreeps ~= nil
        then
            if #nEnemyLaneCreeps >= 1
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.2
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if J.GetHP(bot) < 0.2
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsLaning(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nTrampleRadius, true)

        if nEnemyLaneCreeps ~= nil
        and bysideEnemeyHeroes ~= nil and #bysideEnemeyHeroes <= 2
        then
            if #nEnemyLaneCreeps >= 1
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nTrampleRadius)
        and J.IsAttacking(bot)
        then
            if J.GetHP(bot) > 0.4
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nTrampleRadius)
        and J.IsAttacking(bot)
        then
            if J.GetHP(bot) > 0.4
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderE()
    if not Uproar:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot) or J.IsInTeamFight(bot, 1000))
    and bot:WasRecentlyDamagedByAnyHero(2.2)
    then
        local nModifierCount = J.GetModifierCount( bot, 'modifier_primal_beast_uproar' )
        if J.GetHP(bot) > 0.5 and nModifierCount > 3
        or J.GetHP(bot) < 0.5 and nModifierCount > 2
        or J.GetHP(bot) < 0.3 and nModifierCount >= 1
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderD()
    if not RockThrow:IsTrained() or RockThrow:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if #nEnemyHeroes >= 2
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nRockThrowCastRange, nRockThrowRadius, 0, 0)
        if nLocationAoE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    -- 打断技能
	for _, enemyHero in pairs(nEnemyHeroes)
	do
        botTarget = enemyHero
		if botTarget:IsChanneling() or J.IsCastingUltimateAbility(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderR()
    if not Pulverize:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    nPulverizeCastRange = J.GetProperCastRange(false, bot, Pulverize:GetCastRange())
    nPulverizeDuration = Pulverize:GetSpecialValueFloat('channel_time')
    nPulverizeDamage = Pulverize:GetSpecialValueInt('damage') * 3.3 -- hit 3 times with extra dmg each hit

    if J.IsGoingOnSomeone(bot)
	then
        local strongestTarget = J.GetStrongestUnit(nPulverizeCastRange, bot, true, true, 5)

		if  J.IsValidTarget(strongestTarget)
		and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.HasMovableUndyingModifier(strongestTarget, 0.1)
		then
            return BOT_ACTION_DESIRE_HIGH, strongestTarget
		end
	end

    if J.IsRetreating(bot)
    then
        local weakestTarget = J.GetAttackableWeakestUnit(bot, nPulverizeCastRange, true, true)

		if  J.IsValidTarget(weakestTarget)
		and not J.IsSuspiciousIllusion(weakestTarget)
        and not J.HasMovableUndyingModifier(weakestTarget, 0.1)
		then
            if  nInRangeAlly ~= nil and nEnemyHeroes ~= nil
            and #nEnemyHeroes > #nInRangeAlly
            and bot:WasRecentlyDamagedByAnyHero(2)
            then
                return BOT_ACTION_DESIRE_HIGH, weakestTarget
            end
		end
    end

    
	for _, enemyHero in pairs(nEnemyHeroes)
	do
        botTarget = enemyHero

        -- get the kill
        if J.IsValidHero(botTarget)
        and J.WillKillTarget(botTarget, nPulverizeDamage, DAMAGE_TYPE_MAGICAL, 0)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.HasMovableUndyingModifier(botTarget, 0.1)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end

        -- 打断技能
		if botTarget:IsChanneling() or J.IsCastingUltimateAbility(botTarget)
		and not J.IsSuspiciousIllusion(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X