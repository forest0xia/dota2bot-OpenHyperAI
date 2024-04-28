local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sOutfitType = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,3,2,2,2,2,6,3,3,6,1,1,1,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {
	"item_tango",
    "item_double_branches",
	"item_quelling_blade",
	"item_slippers",
	"item_circlet",
	
    "item_wraith_band",
    "item_power_treads",
    "item_magic_wand",
    "item_dragon_lance",
    "item_manta",--
    "item_skadi",--
    "item_black_king_bar",--
    "item_greater_crit",--
    "item_butterfly",--
    "item_hurricane_pike",--
    "item_moon_shard",
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
	"item_quelling_blade",
    "item_wraith_band",
    "item_power_treads",
    "item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		if hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

local Reflection    = bot:GetAbilityByName( "terrorblade_reflection" )
local ConjureImage  = bot:GetAbilityByName( "terrorblade_conjure_image" )
local Metamorphosis = bot:GetAbilityByName( "terrorblade_metamorphosis" )
local Sunder        = bot:GetAbilityByName( "terrorblade_sunder" )
local DemonZeal     = bot:GetAbilityByName( "terrorblade_demon_zeal" )
local TerrorWave    = bot:GetAbilityByName( "terrorblade_terror_wave" )


local ReflectionDesire
local ConjureImageDesire
local MetamorphosisDesire
local SunderDesire
local DemonZealDesire
local TerrorWaveDesire

function X.SkillsComplement()

    if J.CanNotUseAbility(bot) then return end

	SunderDesire, SunderTarget = X.ConsiderSunder()
    if (SunderDesire > 0)
	then
		bot:Action_UseAbilityOnEntity(Sunder, SunderTarget)
		return
	end

	ReflectionDesire, ReflectionLoc = X.ConsiderReflection()
	if (ReflectionDesire > 0)
	then
		bot:Action_UseAbilityOnLocation(Reflection, ReflectionLoc)
		return
	end

	ConjureImageDesire = X.ConsiderConjureImage()
	if (ConjureImageDesire > 0)
	then
		bot:Action_UseAbility(ConjureImage)
		return
	end

	TerrorWaveDesire = X.ConsiderTerrorWave()
    if (TerrorWaveDesire > 0)
	then
		bot:Action_UseAbility(TerrorWave)
		return
	end

	MetamorphosisDesire = X.ConsiderMetamorphosis()
	if (MetamorphosisDesire > 0)
	then
        bot:Action_UseAbility(Metamorphosis)
		return
	end

    DemonZealDesire = X.ConsiderDemonZeal()
	if (DemonZealDesire > 0)
	then
		bot:Action_UseAbility(DemonZeal)
		return
	end
end

function X.ConsiderReflection()
	if not Reflection:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nRadius      = Reflection:GetSpecialValueInt('range')
	local nCastRange   = bot:GetAttackRange()
	local nCastPoint   = Reflection:GetCastPoint( )
	local nManaCost    = Reflection:GetManaCost( )
	local nAttackRange = bot:GetAttackRange( )

	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		for _, npcEnemy in pairs(tableNearbyEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(npcEnemy, 2.0)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation()
			end
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if locationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()

		if J.IsValidTarget(npcTarget)
		and J.CanCastOnNonMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderConjureImage()
	if not ConjureImage:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = 800
	local nRange = 1200

	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nRange, true, BOT_MODE_NONE)

		for _, npcEnemy in pairs(tableNearbyEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(npcEnemy, 2.0)
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	if J.IsDefending(bot) or J.IsPushing(bot)
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( nRange, true );
		local tableNearbyEnemyTowers = bot:GetNearbyTowers( nRange, true );

		if (tableNearbyEnemyCreeps ~= nil or tableNearbyEnemyTowers ~= nil)
		and bot:GetMana() / bot:GetMaxMana() > 0.5
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()

		if  J.IsValidTarget(npcTarget)
		and J.IsInRange( npcTarget, bot, nRange)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsLaning(bot)
	then
		local npcTarget = bot:GetTarget()

		if  J.IsValidTarget(npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsFarming(bot)
	then
        local npcTarget = bot:GetTarget()

		if  J.IsValidTarget(npcTarget)
		then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderMetamorphosis()
	if not Metamorphosis:IsFullyCastable()
	or bot:HasModifier('modifier_terrorblade_metamorphosis_transform')
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = bot:GetAttackRange() + Metamorphosis:GetSpecialValueInt("bonus_range")

	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2)
		then
			print("TEAMFIGHT")
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()
        local enemy = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if enemy ~= nil and (#enemy == 1 or #enemy == 2)
        and J.IsValidTarget(npcTarget)
		and J.IsInRange( npcTarget, bot, nRadius)
		and J.IsCore(npcTarget)
		then
			print("GOING SOMEONE")
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSunder()
	if not Sunder:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = Sunder:GetCastRange()

	if J.IsRetreating(bot)
	and bot:GetHealth() / bot:GetMaxHealth() < 0.35
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		local sunderTarget = J.GetMostHPPercent(tableNearbyEnemyHeroes, true)

		if sunderTarget ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, sunderTarget
		end
	end

	if J.IsInTeamFight(bot, 1200)
	and bot:GetHealth() / bot:GetMaxHealth() < 0.35
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		local sunderTarget = J.GetMostHPPercent(tableNearbyEnemyHeroes, true)

		if sunderTarget ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, sunderTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderDemonZeal()
    if not DemonZeal:IsTrained()
	or not DemonZeal:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

    local healthCost = bot:GetHealth() * 0.20
    local nRadius = bot:GetAttackRange() + Metamorphosis:GetSpecialValueInt("bonus_range")

    if J.IsInTeamFight(bot, 1200)
	then
		if bot:GetHealth() > (bot:GetHealth() - healthCost)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()

		if J.IsValidTarget(npcTarget)
		and J.IsInRange( npcTarget, bot, nRadius)
        and bot:GetHealth() > (bot:GetHealth() - healthCost)
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTerrorWave()
	if not bot:HasScepter()
    or not TerrorWave:IsFullyCastable()
	or bot:HasModifier('modifier_terrorblade_metamorphosis_transform')
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = bot:GetAttackRange() + Metamorphosis:GetSpecialValueInt("bonus_range")

	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()
        local enemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

		if enemy ~= nil and (#enemy == 1 or #enemy == 2)
        and J.IsValidTarget(npcTarget)
		and J.IsInRange( npcTarget, bot, nRadius)
		and J.IsCore(npcTarget)
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X