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
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{3,1,3,2,3,6,3,2,2,2,6,1,1,1,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_quelling_blade",
	"item_circlet",

    "item_phase_boots",
    "item_magic_wand",
	"item_diffusal_blade",
    -- "item_bfury",--
    "item_blink",
    "item_basher",
    "item_black_king_bar",--
    "item_abyssal_blade",--
    "item_ultimate_scepter",
	"item_disperser",--
    "item_satanic",--
    "item_swift_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
    "item_travel_boots",
    "item_aghanims_shard",
    "item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_circlet",
    "item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)

	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

local Earthshock    = bot:GetAbilityByName( "ursa_earthshock" )
local Overpower     = bot:GetAbilityByName( "ursa_overpower" )
local Enrage        = bot:GetAbilityByName( "ursa_enrage" )

local EarthshockDesire
local OverpowerDesire
local EnrageDesire

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

	EnrageDesire = X.ConsiderEnrage()
    if EnrageDesire > 0
	then
		bot:Action_UseAbility(Enrage)
		return
	end

	OverpowerDesire = X.ConsiderOverpower()
	if OverpowerDesire > 0
	then
		bot:Action_UseAbility(Overpower)
		return
	end

	EarthshockDesire = X.ConsiderEarthshock()
	if EarthshockDesire > 0
	then
		bot:Action_UseAbility(Earthshock)
		return
	end
end

function X.ConsiderEarthshock()
	if not Earthshock:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = Earthshock:GetSpecialValueInt('shock_radius')
	local nLeapDuration = Earthshock:GetSpecialValueInt('hop_duration')
	local nDamage = Earthshock:GetAbilityDamage()
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local botTarget = J.GetProperTarget(bot)

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)
	local nEnemyTowers = bot:GetNearbyTowers(nRadius * 2, true)

	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nRadius)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
		and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			if bot:IsFacingLocation(enemyHero:GetExtrapolatedLocation(nLeapDuration), 15)
			then
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, nRadius + 100, true, BOT_MODE_NONE)

				if  nTargetInRangeAlly ~= nil and #nTargetInRangeAlly <= 1
				and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not bot:HasModifier('modifier_ursa_earthshock_move')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			if bot:IsFacingLocation(botTarget:GetExtrapolatedLocation(nLeapDuration), 15)
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius * 2.5, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius * 2, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) < 0.55 and bot:WasRecentlyDamagedByAnyHero(2.5)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		and not J.IsRealInvisible(bot)
		then
			if bot:IsFacingLocation(J.GetEscapeLoc(), 30)
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if  J.IsLaning(bot)
	and nEnemyHeroes ~= nil and nEnemyTowers ~= nil
	and #nEnemyHeroes == 0 and #nEnemyTowers == 0
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and J.CanBeAttacked(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep))
			and bot:IsFacingLocation(creep:GetLocation(), 15)
			then
				if J.WillKillTarget(creep, nDamage, DAMAGE_TYPE_PHYSICAL, 0.25)
				then
					bot:SetTarget(creep)
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end

		if  nMana > 0.89
		and bot:DistanceFromFountain() > 100
		and bot:DistanceFromFountain() < 6000
		then
			local nLane = bot:GetAssignedLane()
			local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(), nLane, 0)
			local nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocation)

			if nDistFromLane > 1600
			then
				local loc = J.Site.GetXUnitsTowardsLocation(bot, nLaneFrontLocation, nRadius)

				if  IsLocationPassable(loc)
				and bot:IsFacingLocation(loc, 30)
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderOverpower()
	if not Overpower:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nAttackRange = bot:GetAttackRange()
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nAttackRange * 3, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nAttackRange * 2, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, nAttackRange * 2)
		and bot:IsFacingLocation(botTarget:GetLocation(), 30)
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

	if  J.IsPushing(bot)
	and nMana > 0.45
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nAttackRange, true)
		local nEnemyTowers = bot:GetNearbyTowers(600, true)

		if (nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3)
		or (nEnemyTowers ~= nil and #nEnemyTowers >= 1)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  J.IsFarming(bot)
	and nMana > 0.25
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(400)

		if nCreeps ~= nil and #nCreeps >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderEnrage()
	if not Enrage:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nAttackRange = bot:GetAttackRange()
	local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,600, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, nAttackRange + 75)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
		and not bot:IsMagicImmune()
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			if  bot:WasRecentlyDamagedByAnyHero(1)
			and J.GetHP(bot) < 0.75
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,600, true, BOT_MODE_NONE)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and ((#nInRangeEnemy > #nInRangeAlly)
			or (J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByAnyHero(1.5)))
		and J.IsValidHero(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], nAttackRange + 100)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		and not bot:IsMagicImmune()
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  J.IsFarming(bot)
	and J.GetHP(bot) < 0.25
	then
		if  J.IsValid(botTarget)
		and botTarget:IsCreep()
		and J.IsInRange(bot, botTarget, nAttackRange)
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if  J.IsDoingRoshan(bot)
	and J.GetHP(bot) < 0.33
	then
		if J.IsRoshan(botTarget)
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X