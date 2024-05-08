-- Credit goes to Furious Puppy for Bot Experiment

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,2,2,2,6,2,1,1,1,6,3,3,3,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sUtility = {"item_crimson_guard", "item_pipe", "item_lotus_orb"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
	"item_circlet",
	"item_gauntlets",

    "item_magic_wand",
	"item_bracer",
	"item_helm_of_iron_will",
	"item_ring_of_basilius",
    "item_arcane_boots",
	"item_veil_of_discord",
	"item_blink",
    "item_eternal_shroud",--
    "item_kaya_and_sange",--
	"item_shivas_guard",--
    nUtility,--
	"item_travel_boots",
    "item_arcane_blink",--
	"item_travel_boots_2",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_moon_shard"
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3'] 

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_magic_wand",
	"item_bracer",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end
end

local WhirlingDeath 	= bot:GetAbilityByName( 'shredder_whirling_death' )
local TimberChain 		= bot:GetAbilityByName( 'shredder_timber_chain' )
local ReactiveArmor     = bot:GetAbilityByName( 'shredder_reactive_armor' )
local Chakram 			= bot:GetAbilityByName( 'shredder_chakram' )
local ChakramReturn 	= bot:GetAbilityByName( 'shredder_return_chakram' )
local Chakram2 			= bot:GetAbilityByName( 'shredder_chakram_2' )
local ChakramReturn2 	= bot:GetAbilityByName( 'shredder_return_chakram_2' )
local Flamethrower 		= bot:GetAbilityByName( 'shredder_flamethrower' )

local WhirlingDeathDesire
local TimberChainDesire, TreeLocation
local ReactiveArmorDesire
local ChakramDesire, ChakramLocation
local ChakramReturnDesire
local Chakram2Desire, Chakram2Loc
local ChakramReturn2Desire
local FlamethrowerDesire
local ClosingDesire, CloseTargetLocation

local eta1 = 0
local eta2 = 0

local Chakram1Location
local Chakram1ETA = 0
local Chakram1CastTime = 0

local Chakram2Location
local Chakram2ETA = 0
local Chakram2CastTime = 0

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

	ChakramReturnDesire = X.ConsiderChakramReturn()
	if ChakramReturnDesire > 0
	then
		bot:Action_UseAbility(ChakramReturn)
		Chakram1Location = bot:GetLocation()
		return
	end

	ChakramReturn2Desire = X.ConsiderChakramReturn2()
	if ChakramReturn2Desire > 0
	then
		bot:Action_UseAbility(ChakramReturn2)
		Chakram2Location = bot:GetLocation()
		return
	end

	ChakramDesire, ChakramLocation, eta1 = X.ConsiderChakram()
	if ChakramDesire > 0
	then
		bot:Action_UseAbilityOnLocation(Chakram, ChakramLocation)
		Chakram1Location = ChakramLocation
		Chakram1CastTime = DotaTime()
		Chakram1ETA = eta1
		return
	end

	Chakram2Desire, Chakram2Loc, eta2 = X.ConsiderChakram2()
	if Chakram2Desire > 0
	then
		bot:Action_UseAbilityOnLocation(Chakram2, Chakram2Loc)
		Chakram2Location = Chakram2Loc
		Chakram2CastTime = DotaTime()
		Chakram2ETA = eta2
		return
	end

	TimberChainDesire, TreeLocation = X.ConsiderTimberChain()
	if TimberChainDesire > 0
	then
		bot:Action_UseAbilityOnLocation(TimberChain, TreeLocation)
		return
	end

	WhirlingDeathDesire = X.ConsiderWhirlingDeath()
	if WhirlingDeathDesire > 0
	then
        bot:Action_UseAbility(WhirlingDeath)
		return
	end

	ReactiveArmorDesire = X.ConsiderReactiveArmor()
	if ReactiveArmorDesire > 0
	then
        bot:Action_UseAbility(ReactiveArmor)
		return
	end

	FlamethrowerDesire = X.ConsiderFlamethrower()
	if FlamethrowerDesire > 0
	then
		bot:Action_UseAbility(Flamethrower)
		return
	end

	ClosingDesire, CloseTargetLocation = X.ConsiderClosing()
	if ClosingDesire > 0
	then
		bot:Action_MoveToLocation(CloseTargetLocation)
		return
	end
end

function X.ConsiderWhirlingDeath()
	if not WhirlingDeath:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = WhirlingDeath:GetSpecialValueInt('whirling_radius')
	local nDamage = WhirlingDeath:GetSpecialValueInt('whirling_damage') * (1 + bot:GetSpellAmp())
	local nManaCost = WhirlingDeath:GetManaCost()
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local botTarget = J.GetProperTarget(bot)

	local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nRadius)
		and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PURE)
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

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(700, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_aphotic_shield')
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(700, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) and bot:WasRecentlyDamagedByAnyHero(3)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not nInRangeEnemy[1]:HasModifier('modifier_abaddon_aphotic_shield')
		and not nInRangeEnemy[1]:HasModifier('modifier_abaddon_borrowed_time')
		and not nInRangeEnemy[1]:HasModifier('modifier_dazzle_shallow_grave')
		and not nInRangeEnemy[1]:HasModifier('modifier_oracle_false_promise_timer')
		and not nInRangeEnemy[1]:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
		and nMana > 0.2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsFarming(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)

		if  nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
			or (nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4)
		and nMana > 0.33
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  J.IsLaning(bot)
	and J.IsAllowedToSpam(bot, nManaCost)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

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
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTimberChain()
	if not TimberChain:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastPoint = TimberChain:GetCastPoint()
	local nRadius = TimberChain:GetSpecialValueInt('chain_radius')
	local nSpeed = TimberChain:GetSpecialValueInt('speed')
	local nCastRange = J.GetProperCastRange(false, bot, TimberChain:GetCastRange())
	local nDamage = TimberChain:GetSpecialValueInt('damage') * (1 + bot:GetSpellAmp())
	local nWhirlingDamage = WhirlingDeath:GetSpecialValueInt('whirling_damage') * (1 + bot:GetSpellAmp())
	local botTarget = J.GetProperTarget(bot)

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not AreTreesBetween(botTarget:GetLocation(), nRadius)
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
			local nTargetTree = GetBestTree(botTarget:GetExtrapolatedLocation(nDelay), botTarget, nCastRange, nRadius)

			if nTargetTree ~= nil
			then
				if  bot:GetLevel() < 6
				and WhirlingDeath:IsTrained()
				and not J.CanKillTarget(botTarget, nDamage + nWhirlingDamage, DAMAGE_TYPE_PURE)
				then
					return BOT_ACTION_DESIRE_LOW, GetTreeLocation(nTargetTree)
				end

				return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(nTargetTree)
			end
		end
	end

	if  J.IsRetreating(bot)
	and bot:DistanceFromFountain() > 600
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) and bot:WasRecentlyDamagedByAnyHero(3)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], 500)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		then
			local nTargetTree = GetBestRetreatTree(nCastRange)

			if nTargetTree ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetTree
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderReactiveArmor()
	if not ReactiveArmor:IsFullyCastable()
	or ReactiveArmor:IsPassive()
	or not bot:HasScepter()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(600, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, 500)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and (#nInRangeAlly >= #nInRangeEnemy
			or J.GetHP(bot) < 0.51)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeEnemy = bot:GetNearbyHeroes(600, true, BOT_MODE_NONE)

		if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
		and J.GetHP(bot) < 0.51
		and bot:WasRecentlyDamagedByAnyHero(1.5)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderChakram()
	if not Chakram:IsFullyCastable()
	or Chakram:IsHidden()
	then
		return BOT_ACTION_DESIRE_NONE, 0, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, Chakram:GetCastRange())
	local nCastPoint = Chakram:GetCastPoint()
	local nRadius = Chakram:GetSpecialValueFloat('radius')
	local nSpeed = Chakram:GetSpecialValueFloat('speed')
	local nManaCost = Chakram:GetManaCost()
	local nDamage = Chakram:GetSpecialValueInt('pass_damage') * (1 + bot:GetSpellAmp())
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_aphotic_shield')
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			local loc = GetUltLoc(botTarget, nManaCost, nCastRange, nSpeed)

			if loc ~= nil
			then
				local nDelay = (GetUnitToLocationDistance(bot, loc) / nSpeed) + nCastPoint
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay), nDelay
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) and bot:WasRecentlyDamagedByAnyHero(3)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], 500)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		then
			local nDelay = (GetUnitToUnitDistance(bot, nInRangeEnemy[1]) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetExtrapolatedLocation(nDelay), nDelay
		end
	end

	if J.IsDefending(bot) or J.IsPushing(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if  nLocationAoE.count >= 4
		and nMana > 0.33
		then
			local e = (GetUnitToLocationDistance(bot, nLocationAoE.targetloc) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, e
		end
	end

	if J.IsFarming(bot)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if  nNeutralCreeps ~= nil and #nNeutralCreeps >= 3
		and nLocationAoE.count >= 3
		and nMana > 0.45
		then
			local e = (GetUnitToLocationDistance(bot, nLocationAoE.targetloc) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, e
		end
	end

	if J.IsLaning(bot)
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
					local e = (GetUnitToUnitDistance(bot, creep) / nSpeed) + nCastPoint
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation(), e
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0, 0
end

function X.ConsiderChakramReturn()
	if (Chakram1Location == 0 or Chakram1Location == nil)
	or not ChakramReturn:IsFullyCastable()
	or ChakramReturn:IsHidden()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if DotaTime() < Chakram1CastTime + Chakram1ETA
	or StillTraveling(1)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = J.GetProperCastRange(false, bot, Chakram:GetCastRange())
	local nRadius = Chakram:GetSpecialValueFloat('radius')
	local nMana = bot:GetMana() / bot:GetMaxMana()

	local unitCount = 0
	local nNearbyCreeps = bot:GetNearbyCreeps(nCastRange, true)
	for _, c in pairs(nNearbyCreeps)
	do
		if GetUnitToLocationDistance(c, Chakram1Location) <= nRadius
		then
			unitCount = unitCount + 1
		end
	end

	if nMana < 0.15
	or GetUnitToLocationDistance(bot, Chakram1Location) > 1600
	or unitCount == 0
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsRetreating(bot)
	or J.IsGoingOnSomeone(bot)
	then
		local nUnits = 0
		local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if GetUnitToLocationDistance(enemyHero, Chakram1Location) <= nRadius
			then
				nUnits = nUnits + 1
			end
		end

		if nUnits == 0
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderChakram2()
	if not Chakram2:IsFullyCastable()
	or Chakram2:IsHidden()
	then
		return BOT_ACTION_DESIRE_NONE, 0, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, Chakram2:GetCastRange())
	local nCastPoint = Chakram2:GetCastPoint()
	local nRadius = Chakram2:GetSpecialValueFloat('radius')
	local nSpeed = Chakram2:GetSpecialValueFloat('speed')
	local nManaCost = Chakram2:GetManaCost()
	local nDamage = Chakram2:GetSpecialValueInt('pass_damage') * (1 + bot:GetSpellAmp())
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_aphotic_shield')
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			local loc = GetUltLoc(botTarget, nManaCost, nCastRange, nSpeed)

			if loc ~= nil
			then
				local nDelay = (GetUnitToLocationDistance(bot, loc) / nSpeed) + nCastPoint
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay), nDelay
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) and bot:WasRecentlyDamagedByAnyHero(3)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], 500)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		then
			local nDelay = (GetUnitToUnitDistance(bot, nInRangeEnemy[1]) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetExtrapolatedLocation(nDelay), nDelay
		end
	end

	if J.IsDefending(bot) or J.IsPushing(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if  nLocationAoE.count >= 4
		and nMana > 0.33
		then
			local e = (GetUnitToLocationDistance(bot, nLocationAoE.targetloc) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, e
		end
	end

	if J.IsFarming(bot)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if  nNeutralCreeps ~= nil and #nNeutralCreeps >= 3
		and nLocationAoE.count >= 3
		and nMana > 0.45
		then
			local e = (GetUnitToLocationDistance(bot, nLocationAoE.targetloc) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, e
		end
	end

	if J.IsLaning(bot)
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
					local e = (GetUnitToUnitDistance(bot, creep) / nSpeed) + nCastPoint
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation(), e
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0, 0
end

function X.ConsiderChakramReturn2()
	if (Chakram2Location == 0 or Chakram2Location == nil)
	or not ChakramReturn2:IsFullyCastable()
	or ChakramReturn2:IsHidden()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if DotaTime() < Chakram2CastTime + Chakram2ETA
	or StillTraveling(2)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = J.GetProperCastRange(false, bot, Chakram:GetCastRange())
	local nRadius = Chakram:GetSpecialValueFloat('radius')
	local nMana = bot:GetMana() / bot:GetMaxMana()

	local unitCount = 0
	local nNearbyCreeps = bot:GetNearbyCreeps(nCastRange, true)
	for _, c in pairs(nNearbyCreeps)
	do
		if GetUnitToLocationDistance(c, Chakram2Location) <= nRadius
		then
			unitCount = unitCount + 1
		end
	end

	if nMana < 0.15
	or GetUnitToLocationDistance(bot, Chakram2Location) > 1600
	or unitCount == 0
	then
		return BOT_ACTION_DESIRE_MODERATE
	end

	if J.IsRetreating(bot)
	or J.IsGoingOnSomeone(bot)
	then
		local nUnits = 0
		local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if GetUnitToLocationDistance(enemyHero, Chakram2Location) <= nRadius
			then
				nUnits = nUnits + 1
			end
		end

		if nUnits == 0
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderClosing()
	if not bot:HasModifier('modifier_shredder_chakram_disarm')
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(600, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, 500)
		and not J.IsSuspiciousIllusion(botTarget)
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFlamethrower()
	if not Flamethrower:IsTrained()
	or not Flamethrower:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nFrontRange = Flamethrower:GetSpecialValueInt('length')
	local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nFrontRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nFrontRange)
		and bot:IsFacingLocation(botTarget:GetLocation(), 30)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_aphotic_shield')
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

-- HELPER FUNCS
function AreTreesBetween(loc, r)
	local nTrees = bot:GetNearbyTrees(GetUnitToLocationDistance(bot, loc))

	for _, tree in pairs(nTrees)
	do
		local x = GetTreeLocation(tree)
		local y = bot:GetLocation()
		local z = loc

		if x ~= y
		then
			local a = 1
			local b = 1
			local c = 0

			if x.x - y.x == 0
			then
				b = 0
				c = -x.x
			else
				a = -(x.y - y.y) / (x.x - y.x)
				c = -(x.y + x.x * a)
			end

			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b))

			if  d <= r
			and GetUnitToLocationDistance(bot,loc) > J.GetDistance(x, loc) + 50
			then
				return true
			end
		end
	end

	return false
end

function VectorTowards(s, t, d)
	local f = t - s

	f = f / J.GetDistance(f, Vector(0, 0))

	return s + (f * d)
end

function GetBestRetreatTree(nCastRange)
	local nTrees = bot:GetNearbyTrees(nCastRange)
	local dest = VectorTowards(bot:GetLocation(), J.GetTeamFountain(), 1000)

	local bestRetreatTree = nil
	local maxDist = 0

	for _, tree in pairs(nTrees)
	do
		local nTreeLoc = GetTreeLocation(tree)

		if  not AreTreesBetween(nTreeLoc, 100)
		and GetUnitToLocationDistance(bot, nTreeLoc) > maxDist
		and GetUnitToLocationDistance(bot, nTreeLoc) < nCastRange
		and J.GetDistance(nTreeLoc, dest) < 880
		then
			maxDist = GetUnitToLocationDistance(bot, nTreeLoc)
			bestRetreatTree = loc
		end
	end

	if  bestRetreatTree ~= nil
	and maxDist > bot:GetAttackRange()
	then
		return bestRetreatTree
	end

	return bestRetreatTree
end

function GetBestTree(enemyLoc, enemy, nCastRange, hitRadios)
	local bestTree = nil
	local nTrees = bot:GetNearbyTrees(nCastRange)
	local dist = 10000

	for _, tree in pairs(nTrees)
	do
		local x = GetTreeLocation(tree)
		local y = bot:GetLocation()
		local z = enemyLoc

		if x ~= y
		then
			local a = 1
			local b = 1
			local c = 0

			if x.x - y.x == 0
			then
				b = 0
				c = -x.x
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end

			local d = math.abs((a * z.x + b * z.y + c) / math.sqrt(a * a + b * b))
			if  d <= hitRadios
			and dist > GetUnitToLocationDistance(enemy, x)
			and (GetUnitToLocationDistance(enemy, x) <= GetUnitToLocationDistance(bot, x))
			then
				bestTree = tree
				dist = GetUnitToLocationDistance(enemy, x)
			end
		end
	end

	return bestTree
end

function GetUltLoc(target, nManaCost, nCastRange, s)
	local v = target:GetVelocity()
	local sv = J.GetDistance(Vector(0,0), v)
	if sv > 800
	then
		v = (v / sv) * target:GetCurrentMovementSpeed()
	end

	local x= bot:GetLocation()
	local y= target:GetLocation()

	local a = v.x * v.x + v.y * v.y - s * s
	local b = -2 * (v.x * (x.x - y.x) + v.y * (x.y - y.y))
	local c = (x.x - y.x) * (x.x - y.x) + (x.y - y.y) * (x.y - y.y)

	local t = math.max((-b + math.sqrt(b * b - 4 * a * c)) / (2 * a), (-b - math.sqrt(b * b - 4 * a * c)) / (2 * a))
	local dest = (t + 0.35) * v + y

	if GetUnitToLocationDistance(bot, dest) > nCastRange
	or bot:GetMana() < 100 + nManaCost
	then
		return nil
	end

	if target:GetMovementDirectionStability() < 0.4
	or not bot:IsFacingLocation(target:GetLocation(), 60)
	then
		dest = VectorTowards(y, J.GetEnemyFountain(), 180)
	end

	if J.IsDisabled(target)
	then
		dest = target:GetLocation()
	end

	return dest
end

function StillTraveling(cType)
	local proj = GetLinearProjectiles()
	for _, p in pairs(proj)
	do
		if  p ~= nil
		and ((cType == 1 and p.ability:GetName() == 'shredder_chakram')
			or (cType == 2 and p.ability:GetName() == 'shredder_chakram_2'))
		then
			return true
		end
	end

	return false
end

return X