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
						{1,3,2,1,1,6,1,3,3,3,6,2,2,2,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
	"item_crystal_maiden_outfit",
	"item_falcon_blade",
    "item_witch_blade",
    "item_kaya_and_sange",--
	"item_devastator",--
    "item_black_king_bar",--
    "item_ultimate_scepter",
    "item_shivas_guard",--
    "item_aghanims_shard",
    "item_sheepstick",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--
}

sRoleItemsBuyList['pos_3'] = {
	"item_crystal_maiden_outfit",
	"item_falcon_blade",
    "item_witch_blade",
    "item_kaya_and_sange",--
	"item_devastator",--
    "item_black_king_bar",--
    "item_ultimate_scepter",
    "item_shivas_guard",--
    "item_aghanims_shard",
    "item_sheepstick",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",
	"item_enchanted_mango",
	"item_enchanted_mango",
	"item_blood_grenade",

	"item_magic_wand",
	"item_arcane_boots",
	"item_glimmer_cape",--
	"item_guardian_greaves",--
	"item_orchid",
    "item_shivas_guard",--
    "item_kaya_and_sange",--
	"item_aghanims_shard",
	"item_sheepstick",--
	"item_moon_shard",
	"item_bloodthorn",--
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_5'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",
	"item_enchanted_mango",
	"item_enchanted_mango",
	"item_blood_grenade",

	"item_magic_wand",
	"item_arcane_boots",
	"item_orchid",
	"item_glimmer_cape",--
    "item_pavise",
	"item_pipe",
    "item_solar_crest",--
	"item_aghanims_shard",
    "item_shivas_guard",--
	"item_sheepstick",--
	"item_moon_shard",
	"item_bloodthorn",--
	"item_ultimate_scepter_2",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_shivas_guard",
	"item_magic_wand",

	"item_cyclone",
	"item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end
end

local StaticRemnant 	= bot:GetAbilityByName( "storm_spirit_static_remnant" )
local ElectricVortex 	= bot:GetAbilityByName( "storm_spirit_electric_vortex" )
local Overload 			= bot:GetAbilityByName( "storm_spirit_overload" )
local BallLightning 	= bot:GetAbilityByName( "storm_spirit_ball_lightning" )

local StaticRemnantDesire, StaticRemnantLocation
local ElectricVortexDesire, ElectricVortexTarget
local OverloadDesire
local BallLightningDesire, BallLightningLoc

local BallVortexDesire, BallVortexLocation, eta
local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end
	botTarget = J.GetProperTarget(bot)

	BallVortexDesire, BallVortexLocation, eta = X.ConsiderBallVortex()
	if BallVortexDesire > 0
	then
		bot:Action_ClearActions(false)
		bot:ActionQueue_UseAbilityOnLocation(BallLightning, BallVortexLocation)
		bot:ActionQueue_Delay(eta)
		bot:ActionQueue_UseAbility(ElectricVortex)
		return
	end

    BallLightningDesire, BallLightningLoc = X.ConsiderBallLightning()
    if BallLightningDesire > 0
	then
		bot:Action_UseAbilityOnLocation(BallLightning, BallLightningLoc)
		return
	end

	ElectricVortexDesire, ElectricVortexTarget = X.ConsiderElectricVortex()
	if ElectricVortexDesire > 0
	then
		if bot:HasScepter() and string.find(GetBot():GetUnitName(), 'storm_spirit')
		then
			bot:Action_UseAbility(ElectricVortex)
			return
		else
			if J.CanCastAbility(StaticRemnant)
			and StaticRemnant:GetManaCost() + ElectricVortex:GetManaCost() > bot:GetMana() + 150
			then
				J.SetQueuePtToINT(bot, true)
				bot:ActionQueue_UseAbilityOnEntity(ElectricVortex, ElectricVortexTarget)
				bot:ActionQueue_Delay(0.3 + 0.77)
				bot:ActionQueue_UseAbility(StaticRemnant)
				return
			else
				bot:Action_UseAbilityOnEntity(ElectricVortex, ElectricVortexTarget)
				return
			end
		end
	end

	StaticRemnantDesire, StaticRemnantLocation = X.ConsiderStaticRemnant()
	if StaticRemnantDesire > 0
	then
		J.SetQueuePtToINT(bot, true)
		bot:ActionQueue_UseAbilityOnLocation(StaticRemnant, StaticRemnantLocation)
		return
	end

	OverloadDesire = X.ConsiderOverload()
	if OverloadDesire > 0
	then
		bot:Action_UseAbility(Overload)
		return
	end
end

function X.ConsiderStaticRemnant()
	if not J.CanCastAbility(StaticRemnant)
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = 800
	local nRadius = StaticRemnant:GetSpecialValueInt('static_remnant_radius')
	local nAbilityLevel = StaticRemnant:GetLevel()
	local nManaAfter = J.GetManaAfter(StaticRemnant:GetManaCost())
	local nDamage = StaticRemnant:GetSpecialValueInt('static_remnant_damage')
	local nAttackRange = bot:GetAttackRange()

	local nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange)
		and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
		and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_oracle_false_promise')
		and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			local bChasingTarget = J.IsChasingTarget(bot, enemyHero)
			if not bChasingTarget or (bChasingTarget and J.IsInRange(bot, enemyHero, nAttackRange)) then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			local bChasingTarget = J.IsChasingTarget(bot, botTarget)
			if not bChasingTarget or (bChasingTarget and J.IsInRange(bot, botTarget, nAttackRange)) then
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
			end
		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
		for _, enemyHero in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero)
			and J.IsInRange(bot, enemyHero, nCastRange)
			and J.CanCastOnNonMagicImmune(enemyHero)
			then
				local bTargetChasing = J.IsChasingTarget(enemyHero, bot)
				if (bTargetChasing and #nAllyHeroes < #nEnemyHeroes and J.GetHP(bot) < 0.75) or (J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByHero(enemyHero, 3.0)) then
					return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
				end
			end
		end
	end

	local nEnemyCreeps = bot:GetNearbyCreeps(1200, true)
	if  J.IsFarming(bot)
	and nAbilityLevel >= 2
	and nManaAfter > 0.25
	and J.IsAttacking(bot)
	then
		if J.CanBeAttacked(nEnemyCreeps[1]) and not J.IsRunning(nEnemyCreeps[1]) then
			local nLocationAoE = bot:FindAoELocation(true, false, nEnemyCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
			if nLocationAoE.count >= 2 or (nLocationAoE.count == 1 and nEnemyCreeps[1]:IsAncientCreep()) then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
		end
	end

	if (J.IsPushing(bot) or J.IsDefending(bot)) and nManaAfter > 0.25 then
		if J.CanBeAttacked(nEnemyCreeps[1]) and not J.IsRunning(nEnemyCreeps[1]) then
			local nLocationAoE = bot:FindAoELocation(true, false, nEnemyCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
			if nLocationAoE.count >= 3 then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
		end
	end

	if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

	local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage)
	if J.IsInLaningPhase() then
		if nLocationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	else
		if nLocationAoE.count >= 3 then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderElectricVortex()
	if not J.CanCastAbility(ElectricVortex)
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, ElectricVortex:GetCastRange())
	local hasScepter = bot:HasScepter()
	local nRadius = hasScepter and 475 or 0

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and (hasScepter or J.CanCastOnTargetAdvanced(enemyHero))
		then
			if enemyHero:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end
		end
	end

	if  J.IsInTeamFight(bot, 1200)
	and bot:HasScepter()
	then
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

		if #nInRangeEnemy >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nil
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and (hasScepter or J.CanCastOnTargetAdvanced(botTarget))
		and not J.IsDisabled(botTarget)
		then
			if hasScepter
			then
				if J.IsInRange(bot, botTarget, nRadius)
				then
					return BOT_ACTION_DESIRE_HIGH, nil
				end
			else
				if J.IsInRange(bot, botTarget, nCastRange)
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderOverload()
	if not J.CanCastAbility(Overload)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nActivationRadius = 750

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nActivationRadius, false, BOT_MODE_NONE)

		if #nInRangeAlly >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBallLightning()
	if not J.CanCastAbility(BallLightning)
	or BallLightning ~= nil and BallLightning:IsInAbilityPhase()
	or bot:IsRooted()
	or bot:HasModifier("modifier_storm_spirit_ball_lightning")
	or bot:HasModifier('modifier_bloodseeker_rupture')
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastPoint = BallLightning:GetCastPoint()
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local nSpeed = BallLightning:GetSpecialValueInt('ball_lightning_move_speed')
	local botAttackRange = bot:GetAttackRange()
	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if J.IsStuck(bot)
	or J.IsStunProjectileIncoming(bot, botAttackRange)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, 600)
	end

	if  J.IsGoingOnSomeone(bot)
	and nMana > 0.15
	then
		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 1400)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.CanBeAttacked(botTarget)
		and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and J.WeAreStronger(bot, 1400)
		then
			local distance = GetUnitToUnitDistance(bot, botTarget)
			if distance > botAttackRange or not bot:HasModifier('modifier_storm_spirit_overload') then
				local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
				return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, nDelay)
			end
		end
	end

	if J.IsRetreating(bot)
	and not J.IsRealInvisible(bot)
	then
		if J.IsValidHero(nEnemyHeroes[1])
		and J.IsInRange(bot, nEnemyHeroes[1], 600)
		and (J.IsChasingTarget(nEnemyHeroes[1], bot) or J.GetHP(bot) < 0.5 or not J.WeAreStronger(bot, 1200))
		and bot:WasRecentlyDamagedByAnyHero(5)
		then
			local loc = J.GetTeamFountain()
			local dist = 1400 * (1 - J.GetHP(bot))

			if dist < 700 then dist = 700 end

			return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, dist)
		end
	end

	-- if  J.IsFarming(bot)
	-- and J.IsAttacking(bot)
	-- and nMana > 0.7
	-- then
	-- 	local nCreeps = bot:GetNearbyCreeps(900, true)

	-- 	if J.CanBeAttacked(nCreeps[1])
	-- 	and not J.IsRunning(nCreeps[1])
	-- 	and (#nCreeps >= 2 or #nCreeps == 1 and nCreeps[1]:IsAncientCreep())
	-- 	and GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nCreeps)) > 300
	-- 	then
	-- 		return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nCreeps)
	-- 	end
	-- end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderBallVortex()
	if X.CanDoBallVortex()
	then
		local nRadius = 475
		local nCastPoint = BallLightning:GetCastPoint()
		local nSpeed = BallLightning:GetSpecialValueInt('ball_lightning_move_speed')

		local nTeamFightLocation = J.GetTeamFightLocation(bot)

		if  J.IsInTeamFight(bot, 1200)
		and nTeamFightLocation ~= nil
		and GetUnitToLocationDistance(bot, nTeamFightLocation) <= 1200
		then
			local nDelay = (GetUnitToLocationDistance(bot, nTeamFightLocation) / nSpeed) + nCastPoint
			local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1200, nRadius, nDelay, 0)
			local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

			if #nInRangeEnemy >= 2
			and not J.IsLocationInChrono(nLocationAoE.targetloc)
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, nDelay
			end
		end
    end

	return BOT_ACTION_DESIRE_NONE, 0, 0
end

function X.CanDoBallVortex()
	if  J.CanCastAbility(ElectricVortex)
	and J.CanCastAbility(BallLightning)
	and string.find(GetBot():GetUnitName(), 'storm_spirit')
	and bot:HasScepter()
	and not bot:HasModifier('modifier_bloodseeker_rupture')
    then
		if J.IsInTeamFight(bot, 1200)
		then
			local nMana = bot:GetMaxMana()
			local nActivationManaCost = BallLightning:GetSpecialValueInt('ball_lightning_initial_mana_base')
			local nActivationInitManaPercentage = BallLightning:GetSpecialValueFloat('ball_lightning_initial_mana_percentage') / 100

			local nTeamFightLocation = J.GetTeamFightLocation(bot)

			if  nTeamFightLocation ~= nil
			and GetUnitToLocationDistance(bot, nTeamFightLocation) <= 1200
			then
				local totalDist = GetUnitToLocationDistance(bot, nTeamFightLocation)

				local nBofLCost = nActivationManaCost
								+ nActivationInitManaPercentage * nMana
								+ ((10 + 0.0065 * nMana) * (totalDist / 100))

				local nManaCost = nBofLCost + ElectricVortex:GetManaCost()

				if  bot:GetMana() >= nManaCost
				then
					return true
				end
			end
		end
    end

	return false
end

return X