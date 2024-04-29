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
    "item_tango",
	"item_double_branches",
	"item_faerie_fire",

	"item_bottle",
	"item_boots",
    "item_magic_wand",
	"item_falcon_blade",
    "item_power_treads",
    "item_witch_blade",
    "item_kaya_and_sange",--
	"item_devastator",--
    "item_black_king_bar",--
    "item_ultimate_scepter",
    "item_shivas_guard",--
    "item_aghanims_shard",
    "item_sheepstick",--
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
	"item_double_branches",
	"item_faerie_fire",

	"item_boots",
    "item_magic_wand",
	"item_falcon_blade",
    "item_power_treads",
    "item_witch_blade",
    "item_kaya_and_sange",--
	"item_devastator",--
    "item_black_king_bar",--
    "item_ultimate_scepter",
    "item_shivas_guard",--
    "item_aghanims_shard",
    "item_sheepstick",--
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3'] 

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_bottle",
	"item_falcon_blade",
    "item_magic_wand",
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

local StaticRemnant 	= bot:GetAbilityByName( "storm_spirit_static_remnant" )
local ElectricVortex 	= bot:GetAbilityByName( "storm_spirit_electric_vortex" )
local Overload 			= bot:GetAbilityByName( "storm_spirit_overload" )
local BallLightning 	= bot:GetAbilityByName( "storm_spirit_ball_lightning" )

local StaticRemnantDesire
local ElectricVortexDesire, ElectricVortexTarget
local OverloadDesire
local BallLightningDesire, BallLightningLoc

local BallVortexDesire, BallVortexLocation, eta

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

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
		if bot:HasScepter()
		then
			bot:Action_UseAbility(ElectricVortex)
			return
		else
			bot:Action_UseAbilityOnEntity(ElectricVortex, ElectricVortexTarget)
			return
		end
	end

	OverloadDesire = X.ConsiderOverload()
	if OverloadDesire > 0
	then
		bot:Action_UseAbility(Overload)
		return
	end

	StaticRemnantDesire = X.ConsiderStaticRemnant()
	if StaticRemnantDesire > 0
	then
		bot:Action_UseAbility(StaticRemnant)
		return
	end
end

function X.ConsiderStaticRemnant()
	if not StaticRemnant:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = StaticRemnant:GetSpecialValueInt('static_remnant_radius')
	local nAbilityLevel = StaticRemnant:GetLevel()
	local nManaCost = StaticRemnant:GetManaCost()
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local nAttackRange = bot:GetAttackRange()
	local botTarget = J.GetProperTarget(bot)

	local nOverloadDamage = 0
	if Overload:IsTrained()
	then
		nOverloadDamage = Overload:GetSpecialValueInt('overload_damage') + (1 + bot:GetSpellAmp())
	end

	local nEnemyHeroes = bot:GetNearbyHeroes(nAttackRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nAttackRange)
		and J.CanKillTarget(enemyHero, nOverloadDamage, DAMAGE_TYPE_MAGICAL)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_oracle_false_promise')
		and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			bot:SetTarget(enemyHero)
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nAttackRange)
		and not J.IsSuspiciousIllusion(botTarget)
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
		local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and J.IsValidHero(nInRangeEnemy[1])
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) < 0.5 and J.IsInRange(bot, nInRangeEnemy[1], nAttackRange)))
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  J.IsFarming(bot)
	and nAbilityLevel >= 2
	and nMana > 0.44
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nAttackRange)

		if nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  J.IsLaning(bot)
	and J.AllowedToSpam(bot, nManaCost)
	and Overload:IsTrained()
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nAttackRange, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep))
			and creep:GetHealth() <= nOverloadDamage
			then
				local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

				if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
				then
					bot:SetTarget(creep)
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

	if  (J.IsDefending(bot) or J.IsPushing(bot))
	and nAbilityLevel >= 3
	and nMana > 0.5
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nAttackRange, true)

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
	if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
	and nAbilityLevel >= 2
	and nMana > 0.5
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderElectricVortex()
	if not ElectricVortex:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = ElectricVortex:GetCastRange()
	local nRadius = bot:HasScepter() and 475 or 0
	local nCastPoint = ElectricVortex:GetCastPoint()
	local botTarget = J.GetProperTarget(bot)

	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end
		end
	end

	if  J.IsInTeamFight(bot, 1200)
	and bot:HasScepter()
	and not CanDoBallVortex()
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nRadius, nRadius, nCastPoint, 0)

		if nLocationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nil
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeAlly >= #nInRangeEnemy)
			or (#nInRangeEnemy > #nInRangeAlly and J.WeAreStronger(bot, 1000)))
		then
			if  bot:HasScepter()
			and J.IsInRange(bot, botTarget, nRadius)
			then
				return BOT_ACTION_DESIRE_HIGH, nil
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
	if not Overload:IsTrained()
	or not Overload:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nActivationRadius = 750

	if  J.IsInTeamFight(bot, 1200)
	and bot:HasScepter()
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nActivationRadius, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(nActivationRadius, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy
		and #nInRangeAlly >= 2 and #nInRangeEnemy >= 1
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBallLightning()
	if not BallLightning:IsFullyCastable()
	or BallLightning:IsInAbilityPhase()
	or bot:IsRooted()
	or bot:HasModifier("modifier_storm_spirit_ball_lightning")
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastPoint = BallLightning:GetCastPoint()
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local nSpeed = BallLightning:GetSpecialValueInt('ball_lightning_move_speed')
	local botTarget = J.GetProperTarget(bot)

	if J.IsStuck(bot)
	or J.IsStunProjectileIncoming(bot, bot:GetAttackRange())
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, bot:GetAttackRange())
	end

	if  J.IsGoingOnSomeone(bot)
	and not CanDoBallVortex()
	and nMana > 0.15
	then
		local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 1000)
		and J.CanCastOnNonMagicImmune(botTarget)
		and GetUnitToUnitDistance(bot, botTarget) > bot:GetAttackRange()
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
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
		local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
		local nInRangeEnemy = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByAnyHero(2)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], 600)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		then
			local loc = J.GetEscapeLoc()
			local dist = 1200 * (1 - J.GetHP(bot))

			if dist < 600 then dist = 600 end

			return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, dist)
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderBallVortex()
	if CanDoBallVortex()
	then
		local nRadius = 475
		local nCastPoint = BallLightning:GetCastPoint() + ElectricVortex:GetCastPoint()
		local nSpeed = BallLightning:GetSpecialValueInt('ball_lightning_move_speed')

		local nTeamFightLocation = J.GetTeamFightLocation(bot)

		if  J.IsInTeamFight(bot, 1200)
		and nTeamFightLocation ~= nil
		and GetUnitToLocationDistance(bot, nTeamFightLocation) <= 1200
		then
			local nDelay = (GetUnitToLocationDistance(bot, nTeamFightLocation) / nSpeed) + nCastPoint
			local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1000, nRadius, nDelay, 0)

			if  nLocationAoE.count >= 2
			and not IsTargetLocInBigUlt(nLocationAoE.targetloc)
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, nDelay
			end
		end
    end

	return BOT_ACTION_DESIRE_NONE, 0, 0
end

function CanDoBallVortex()
	if  ElectricVortex:IsFullyCastable()
	and bot:HasScepter()
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

function IsTargetLocInBigUlt(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if  J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 450
		and (enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			or enemyHero:HasModifier('modifier_enigma_black_hole_pull'))
		then
			return true
		end
	end

	return false
end

return X