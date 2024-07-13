local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,1,3,2,3,6,3,1,1,1,2,6,2,2,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_circlet",
    "item_gauntlets",

    "item_bottle",
    "item_bracer",
    "item_boots",
    "item_magic_wand",
    "item_power_treads",
    "item_echo_sabre",
    "item_ultimate_scepter",
    "item_manta",--
    "item_black_king_bar",--
    "item_travel_boots",
    "item_greater_crit",--
    "item_sheepstick",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
    "item_travel_boots_2",--
	"item_orchid",
    "item_bloodthorn",--
    "item_aghanims_shard",
}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_double_branches",
    "item_circlet",
    "item_gauntlets",
    
    "item_bracer",
    "item_boots",
    "item_magic_wand",
    "item_power_treads",
    "item_echo_sabre",
    "item_ultimate_scepter",
    "item_manta",--
    "item_black_king_bar",--
    "item_travel_boots",
    "item_greater_crit",--
    "item_sheepstick",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
    "item_travel_boots_2",--
	"item_orchid",--
    "item_bloodthorn",--
    "item_aghanims_shard",
}

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_bottle",
    "item_magic_wand",
    "item_bracer",
    "item_echo_sabre",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

local AetherRemnant = bot:GetAbilityByName( "void_spirit_aether_remnant" )
local Dissimilate   = bot:GetAbilityByName( "void_spirit_dissimilate" )
local ResonantPulse = bot:GetAbilityByName( "void_spirit_resonant_pulse" )
local AstralStep    = bot:GetAbilityByName( "void_spirit_astral_step" )

local AetherRemnantDesire, AetherRemnantLocation
local DissimilateDesire
local ResonantPulseDesire
local AstralStepDesire, AstralStepLocation

-- local QuadComboDesire, QuadComboLocation
-- local AstralStepCastPoint = 0
-- local AetherRemnantActivationTime = 0
-- local DissimilateDuration = 0

local RemnantCastTime = -100

function X.SkillsComplement()
    if J.CanNotUseAbility(bot)
	or bot:NumQueuedActions() > 0
	then
		return
	end

	-- QuadComboDesire, QuadComboLocation = X.ConsiderQuadCombo()
	-- if QuadComboDesire > 0
	-- then
	-- 	bot:Action_ClearActions(false)
	-- 	bot:ActionQueue_UseAbilityOnLocation(AstralStep, QuadComboLocation)
	-- 	bot:ActionQueue_Delay(AstralStepCastPoint)
	-- 	bot:ActionQueue_UseAbilityOnLocation(AetherRemnant, QuadComboLocation)
	-- 	bot:ActionQueue_Delay(AetherRemnantActivationTime)
	-- 	bot:ActionQueue_UseAbility(Dissimilate)
	-- 	bot:ActionQueue_Delay(DissimilateDuration)
	-- 	bot:ActionQueue_UseAbility(ResonantPulse)
	-- 	return
	-- end

	AstralStepDesire, AstralStepLocation = X.ConsiderAstralStep()
    if AstralStepDesire > 0
    then
        bot:Action_UseAbilityOnLocation(AstralStep, AstralStepLocation)
        RemnantCastTime = DotaTime()
    end

	AetherRemnantDesire, AetherRemnantLocation = X.ConsiderAetherRemnant()
    if AetherRemnantDesire > 0
    then
        bot:Action_UseAbilityOnLocation(AetherRemnant, AetherRemnantLocation)
    end

	DissimilateDesire = X.ConsiderDissimilate()
    if DissimilateDesire > 0
    then
        bot:Action_UseAbility(Dissimilate)
    end

	ResonantPulseDesire = X.ConsiderResonantPulse()
    if ResonantPulseDesire > 0
    then
        bot:Action_UseAbility(ResonantPulse)
    end
end

function X.ConsiderAetherRemnant()
    if not AetherRemnant:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = AetherRemnant:GetSpecialValueInt('radius')
	local nActivationDelay = AetherRemnant:GetSpecialValueFloat('activation_delay')
	local nDamage = AetherRemnant:GetSpecialValueInt('impact_damage')
	local nCastRange = AetherRemnant:GetCastRange()
	local botTarget = J.GetProperTarget(bot)

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidTarget(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			if enemyHero:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
			end

			if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nActivationDelay)
			end
		end
	end

	if  J.IsGoingOnSomeone(bot)
	-- and not CanQuadCombo()
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not J.IsInRange(bot, botTarget, nRadius)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		and not botTarget:HasModifier('modifier_legion_commander_duel')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nActivationDelay)
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByAnyHero(2)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderDissimilate()
    if not Dissimilate:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = Dissimilate:GetSpecialValueInt('first_ring_distance_offset')
	local botTarget = J.GetProperTarget(bot)

	if J.IsStunProjectileIncoming(bot, 600)
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if  J.IsGoingOnSomeone(bot)
	-- and not CanQuadCombo()
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius * 1.5, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if  J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and not J.IsInRange(bot, botTarget, bot:GetAttackRange() + 50)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius * 1.5, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) < 0.65 and bot:WasRecentlyDamagedByAnyHero(2)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], bot:GetAttackRange() + 50)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		and not J.IsRealInvisible(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderResonantPulse()
    if not ResonantPulse:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = ResonantPulse:GetSpecialValueInt('radius')
	local nDamage = ResonantPulse:GetSpecialValueInt('damage')
	local nManaCost = ResonantPulse:GetManaCost()
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local botTarget = J.GetProperTarget(bot)

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidTarget(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nRadius)
		and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
		and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  J.IsGoingOnSomeone(bot)
	-- and not CanQuadCombo()
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 150, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if  J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_aphotic_shield')
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 150, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) < 0.65 and bot:WasRecentlyDamagedByAnyHero(1.5)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		and not J.IsRealInvisible(bot)
		and not bot:HasModifier('modifier_void_spirit_resonant_pulse_physical_buff')
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  J.IsPushing(bot) or J.IsDefending(bot)
	and not bot:HasModifier('modifier_void_spirit_resonant_pulse_physical_buff')
	then
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius + 200, true, BOT_MODE_NONE)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

		if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
		and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  J.IsFarming(bot)
	and nMana > 0.38
	and not bot:HasModifier('modifier_void_spirit_resonant_pulse_physical_buff')
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)

		if nNeutralCreeps ~= nil and #nNeutralCreeps >= 3
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  J.IsLaning(bot)
	and nMana > 0.33
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep))
			and creep:GetHealth() <= nDamage
			then
				local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

				if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderAstralStep()
	if not AstralStep:IsFullyCastable()
	or bot:IsRooted()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = AstralStep:GetSpecialValueInt('max_travel_distance')
	local nCastPoint = AstralStep:GetCastPoint()
	local nDamage = AstralStep:GetSpecialValueInt('pop_damage')
	local botTarget = J.GetProperTarget(bot)

	if DotaTime() < RemnantCastTime + nCastPoint
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	if  J.IsStuck(bot)
	and not bot:HasModifier('modifier_void_spirit_astral_step_caster')
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
	end

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidTarget(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
		end
	end

	if  J.IsGoingOnSomeone(bot)
	-- and not CanQuadCombo()
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and not J.IsInRange(bot, botTarget, bot:GetAttackRange() + 100)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 150, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) < 0.65 and bot:WasRecentlyDamagedByAnyHero(2)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], nCastRange - 75)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		and not bot:HasModifier('modifier_void_spirit_astral_step_caster')
		then
			local loc = J.GetEscapeLoc()
			return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

-- function X.ConsiderQuadCombo()
-- 	if CanQuadCombo()
-- 	then
-- 		local nCastRange = AstralStep:GetSpecialValueInt('max_travel_distance')
-- 		local nCastPoint = AstralStep:GetCastPoint()
-- 		local botTarget = bot:GetAttackTarget()

-- 		AstralStepCastPoint = AstralStep:GetCastPoint()
-- 		AetherRemnantActivationTime = AetherRemnant:GetSpecialValueFloat('activation_delay')
-- 		DissimilateDuration = Dissimilate:GetSpecialValueFloat('phase_duration')

-- 		if J.IsGoingOnSomeone(bot)
-- 		then
-- 			local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
-- 			local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

-- 			if  J.IsValidHero(botTarget)
-- 			and J.CanCastOnNonMagicImmune(botTarget)
-- 			and not J.IsInRange(bot, botTarget, bot:GetAttackRange() + 100)
-- 			and not J.IsSuspiciousIllusion(botTarget)
-- 			and not J.IsDisabled(botTarget)
-- 			and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
-- 			and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
-- 			and #nInRangeAlly >= #nInRangeEnemy
-- 			then
-- 				return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
-- 			end
-- 		end
-- 	end

-- 	return BOT_ACTION_DESIRE_NONE
-- end

-- function CanQuadCombo()
-- 	if  AetherRemnant:IsFullyCastable()
--     and Dissimilate:IsFullyCastable()
-- 	and ResonantPulse:IsFullyCastable()
-- 	and AstralStep:IsFullyCastable()
--     then
--         local nManaCost = AetherRemnant:GetManaCost()
-- 						+ Dissimilate:GetManaCost()
-- 						+ ResonantPulse:GetManaCost()
-- 						+ AstralStep:GetManaCost()

--         if bot:GetMana() >= nManaCost
--         then
--             return true
--         end
--     end

--     return false
-- end

return X