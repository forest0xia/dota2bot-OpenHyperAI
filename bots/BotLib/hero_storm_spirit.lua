-- Credit goes to Furious Puppy for Bot Experiment

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sOutfitType = J.Item.GetOutfitType( bot )

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

local tOutFitList = {}

tOutFitList['outfit_mid'] = {
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

tOutFitList['outfit_tank'] = tOutFitList['outfit_mid']

tOutFitList['outfit_carry'] = tOutFitList['outfit_mid'] 

tOutFitList['outfit_priest'] = tOutFitList['outfit_mid']

tOutFitList['outfit_mage'] = tOutFitList['outfit_mid']

X['sBuyList'] = tOutFitList[sOutfitType]

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

local OverloadDesire = 0

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    BallLightningDesire, BallLightningLoc = X.ConsiderBallLightning()
    if (BallLightningDesire > 0)
	then
		bot:Action_UseAbilityOnLocation(BallLightning, BallLightningLoc)
		return
	end

	ElectricVortexDesire, ElectricVortexTarget = X.ConsiderElectricVortex()
	if (ElectricVortexDesire > 0)
	then
		if bot:HasScepter() then
			bot:Action_UseAbility(ElectricVortex)
			return
		else
			bot:Action_UseAbilityOnEntity(ElectricVortex, ElectricVortexTarget)
			return
		end
	end

	OverloadDesire = X.ConsiderOverload()
	if (OverloadDesire > 0)
	then
		bot:Action_UseAbility(Overload)
		return
	end

	StaticRemnantDesire = X.ConsiderStaticRemnant()
	if (StaticRemnantDesire > 0)
	then
		bot:Action_UseAbility(StaticRemnant)
		return
	end
end

function X.ConsiderStaticRemnant()
	if (not StaticRemnant:IsFullyCastable()) then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = StaticRemnant:GetSpecialValueInt("static_remnant_radius")
	local nDamage = StaticRemnant:GetSpecialValueInt("static_remnant_damage")
	local manaCost = StaticRemnant:GetManaCost()
	local aRange = bot:GetAttackRange()

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
		for _, npcEnemy in pairs(nEnemyHeroes)
		do
			if (bot:WasRecentlyDamagedByHero(npcEnemy, 2.0))
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius + aRange, true, BOT_MODE_NONE)
		if (nEnemyHeroes ~= nil and #nEnemyHeroes > 0) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsFarming(bot) and J.CanSpamSpell(bot, manaCost)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius + aRange)
		if (nNeutralCreeps ~= nil and #nNeutralCreeps > 1)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsLaning(bot) and J.CanSpamSpell(bot, manaCost)
	then
		local botTarget = bot:GetTarget()
		if J.IsValidTarget(botTarget)
		and J.IsInRange(botTarget, bot, nRadius + aRange)
		and nDamage >= botTarget:GetHealth()
		then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end

	if (J.IsDefending(bot) or J.IsPushing(bot)) and J.CanSpamSpell(bot, manaCost)
	then
		local nEnemyCreeps = bot:GetNearbyLaneCreeps(nRadius + aRange, true)
		if (nEnemyCreeps ~= nil and #nEnemyCreeps >= 2)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = bot:GetTarget()
		if J.IsValidTarget(botTarget) and J.IsInRange(botTarget, bot, nRadius + aRange)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderElectricVortex()
	if (not ElectricVortex:IsFullyCastable()) then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = ElectricVortex:GetCastRange()
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

	if bot:HasScepter() then
		nCastRange = 475
	end

	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero(npcEnemy)
		then
			if npcEnemy:IsChanneling()
			and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end

			if J.IsCastingUltimateAbility(npcEnemy)
			and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	if J.IsInTeamFight(bot, 1200) and bot:HasScepter()
	then
		if nInRangeEnemyList ~= nil and #nInRangeEnemyList >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nil
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = bot:GetTarget()
		if J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange - 100)
		and not J.IsDisabled(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
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
	local nInRangeEnemyList = bot:GetNearbyHeroes(nActivationRadius, true, BOT_MODE_NONE)
	local nInRangeAllyList = bot:GetNearbyHeroes(nActivationRadius, false, BOT_MODE_ATTACK)

	if J.IsInTeamFight(bot, 1200) and bot:HasScepter()
	then
		if (nInRangeEnemyList ~= nil and #nInRangeEnemyList >= 1)
		and (nInRangeAllyList ~= nil and #nInRangeAllyList >= 1)
		then
			return BOT_ACTION_DESIRE_HIGH, nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBallLightning()
	if (not BallLightning:IsFullyCastable() or BallLightning:IsInAbilityPhase() or bot:HasModifier("modifier_storm_spirit_ball_lightning") or bot:IsRooted() or bot:IsSilenced())
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastPoint = BallLightning:GetCastPoint()
	local nInBonusEnemyList = J.GetAroundEnemyHeroList(1200)
	local nAllyHeroes = bot:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK)

	local nRDamage = StaticRemnant:GetSpecialValueInt("static_remnant_damage")
	local nODamage = Overload:GetSpecialValueInt("overload_damage")

	local botTarget = bot:GetTarget()

	if J.IsLaning(bot)
	then
		if (nAllyHeroes ~= nil and nAllyHeroes > 0 and #nInBonusEnemyList == 1)
		or J.WillMixedDamageKillTarget(botTarget, bot:GetAttackDamage(), nRDamage + nODamage, 0, nCastPoint)
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		return BOT_ACTION_DESIRE_LOW
	end

	if J.IsGoingOnSomeone(bot)
	and GetUnitToUnitDistance(bot, botTarget) > bot:GetAttackRange()
	and not botTarget:HasModifier("modifier_black_king_bar_immune")
	and nAllyHeroes ~= nil and #nAllyHeroes >= #nInBonusEnemyList
	then
		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 1200)
		and J.CanCastOnNonMagicImmune(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
		end
	end

	if J.IsRetreating(bot)
	then
		for _, npcEnemy in pairs(nInBonusEnemyList)
		do
			if J.IsValid(npcEnemy)
			and (bot:WasRecentlyDamagedByHero(npcEnemy, 2.0) or #nInBonusEnemyList >= 2)
			then
				local loc = J.GetEscapeLoc()
				return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, RandomInt(600, 1000))
			end
		end
	end

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, 600)
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

return X