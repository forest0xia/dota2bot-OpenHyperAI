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

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_quelling_blade",

    "item_bottle",
    "item_phase_boots",
    "item_magic_wand",
    "item_blade_mail",
    "item_radiance",--
    "item_black_king_bar",--
    "item_blink",
    "item_veil_of_discord",
    "item_shivas_guard",--
    "item_heart",--
    "item_travel_boots",
    "item_overwhelming_blink",--
    "item_travel_boots_2",--
    "item_aghanims_shard",
    "item_moon_shard",
    "item_ultimate_scepter",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",
    "item_magic_stick",

    "item_bracer",
    "item_magic_wand",
    "item_phase_boots",
    "item_blade_mail",
    "item_radiance",--
    "item_veil_of_discord",
    "item_crimson_guard",--
    "item_black_king_bar",--
    "item_lotus_orb",--
    "item_shivas_guard",--
    "item_travel_boots",
    "item_aghanims_shard",
    "item_travel_boots_2",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
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
	"item_pipe",--
    "item_solar_crest",--
	"item_lotus_orb",--
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

	"item_vanguard",
	"item_quelling_blade",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
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
	nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
	nInRangeAlly = J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_NONE)

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

	-- retreat
	if J.IsRetreating(bot) and (J.GetHP(bot) < 0.6 or (nInRangeAlly ~= nil and nEnemyHeroes ~= nil and #nEnemyHeroes > #nInRangeAlly))
	then
		return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain(), false
	end

	if J.GetHP(bot) < 0.66 then
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
    or bot:IsRooted()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = Trample:GetSpecialValueInt('effect_radius')
    local nDuration = Trample:GetSpecialValueFloat('duration')
    local nBaseDamage = Trample:GetSpecialValueInt('base_damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local nEnemyTowers = bot:GetNearbyTowers(1600, true)

    if J.IsGoingOnSomeone(bot)
	then
        if J.IsValidHero(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        then
            bot.trample_status = {'engaging', botTarget:GetLocation(), botTarget}
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:WasRecentlyDamagedByAnyHero(3)
    then
        if J.IsValidHero(nEnemyHeroes[1])
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        then
            bot.trample_status = {'retreating', J.GetTeamFountain(), nil}
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    local nCreeps = bot:GetNearbyCreeps(800, true)
    local nAllyHeroes = J.GetAlliesNearLoc(bot:GetLocation(), 800)

    if (J.IsFarming(bot) or (J.IsPushing(bot) and #nAllyHeroes <= 1) or J.IsDefending(bot)) and J.GetManaAfter(Trample:GetManaCost()) > 0.35 then
        if J.IsValid(nCreeps[1])
        and ((#nCreeps >= 3 and not J.HasItem(bot, 'item_radiance')) or #nCreeps >= 2 and nCreeps[1]:IsAncientCreep())
        and not J.IsRunning(nCreeps[1])
        and J.CanBeAttacked(nCreeps[1])
        and J.IsAttacking(bot)
        then
            bot.trample_status = {'farming', 0, nil}
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsLaning(bot) and #nEnemyHeroes == 0 then
        if #nCreeps >= 3
        and J.IsValid(nCreeps[1])
        and not J.IsRunning(nCreeps[1])
        and J.CanBeAttacked(nCreeps[1])
        and J.IsAttacking(bot)
        then
            if #nEnemyTowers == 0
            or J.IsValidBuilding(nEnemyTowers[1]) and GetUnitToUnitDistance(nCreeps[1], nEnemyTowers[1]) > 900 then
                bot.trample_status = {'laning', 0, nil}
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    for _, enemyHero in pairs(nEnemyHeroes) do
        if J.IsValidHero(enemyHero)
        and not enemyHero:IsInvulnerable()
        and J.IsInRange(bot, enemyHero, nRadius)
        and J.CanKillTarget(enemyHero, nBaseDamage * nDuration, DAMAGE_TYPE_PHYSICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        then
            bot.trample_status = {'engaging', enemyHero:GetLocation(), enemyHero}
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingRoshan(bot) then
        if J.IsRoshan(botTarget)
        and not botTarget:IsAttackImmune()
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            bot.trample_status = {'miniboss', botTarget:GetLocation(), botTarget}
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot) then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            bot.trample_status = {'miniboss', botTarget:GetLocation(), botTarget}
            return BOT_ACTION_DESIRE_HIGH
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

		if J.IsValidTarget(strongestTarget)
		and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.HasMovableUndyingModifier(strongestTarget, 0.1)
		then
            return BOT_ACTION_DESIRE_HIGH, strongestTarget
		end
	end

    if J.IsRetreating(bot)
    then
        local weakestTarget = J.GetAttackableWeakestUnit(bot, nPulverizeCastRange, true, true)

		if J.IsValidTarget(weakestTarget)
		and not J.IsSuspiciousIllusion(weakestTarget)
        and not J.HasMovableUndyingModifier(weakestTarget, 0.1)
        and J.GetHP(bot) > 0.3
		then
            if nInRangeAlly ~= nil and nEnemyHeroes ~= nil
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
        if J.IsRoshan(botTarget)
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
