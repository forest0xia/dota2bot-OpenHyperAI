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
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,2,2,3,2,6,2,1,1,1,1,3,3,6,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_mid'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_quelling_blade",

	"item_bottle",
	"item_boots",
    "item_phase_boots",
    "item_magic_wand",
	"item_mage_slayer",
    "item_maelstrom",
	"item_kaya_and_sange",--
    "item_black_king_bar",--
    "item_shivas_guard",--
    "item_ultimate_scepter",
    "item_gungir",--
    "item_travel_boots",
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_octarine_core",--
    "item_travel_boots_2",--
}

tOutFitList['outfit_tank'] = tOutFitList['outfit_mid']

tOutFitList['outfit_carry'] = tOutFitList['outfit_mid'] 

tOutFitList['outfit_priest'] = tOutFitList['outfit_mid']

tOutFitList['outfit_mage'] = tOutFitList['outfit_mid']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
    "item_quelling_blade",
	"item_bottle",
    "item_magic_wand",
	"item_mage_slayer"
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

local SearingChains 		= bot:GetAbilityByName( "ember_spirit_searing_chains" )
local SleightOfFist 		= bot:GetAbilityByName( "ember_spirit_sleight_of_fist" )
local FlameGuard 			= bot:GetAbilityByName( "ember_spirit_flame_guard" )
local ActivateFireRemnant 	= bot:GetAbilityByName( "ember_spirit_activate_fire_remnant" )
local FireRemnant 			= bot:GetAbilityByName( "ember_spirit_fire_remnant" )

local SearingChainsDesire = 0
local SleightOfFistDesire = 0
local FlameGuardDesire = 0
local ActivateFireRemnantDesire = 0
local FireRemnantDesire = 0

local remnantLoc = Vector(0, 0, 0)
local remnantCastTime = -100
local remnantCastGap  = 0.2

function X.SkillsComplement()
    if bot:IsUsingAbility() or bot:IsChanneling() or bot:IsSilenced() then return end

    SearingChainsDesire           			= X.ConsiderSearingChains()
    SleightOfFistDesire, SoFLoc 			= X.ConsiderSleightOfFist()
    FlameGuardDesire           				= X.ConsiderFlameGuard()
    ActivateFireRemnantDesire, ARemnantLoc 	= X.ConsiderActivateFireRemnant()
    FireRemnantDesire, FireRemnantLoc		= X.ConsiderFireRemnant()

	if ( SleightOfFistDesire > 0 )
	then
		bot:Action_UseAbilityOnLocation( SleightOfFist, SoFLoc )
		return
	end

	if ( SearingChainsDesire > 0 )
	then
		bot:Action_UseAbility( SearingChains )
		return
	end

    if ( FireRemnantDesire > 0 )
	then
		bot:Action_UseAbilityOnLocation( FireRemnant, FireRemnantLoc )
		remnantCastTime = DotaTime()
		remnantLoc = FireRemnantLoc
		return
	end

	if ( ActivateFireRemnantDesire > 0 )
	then
		bot:Action_UseAbilityOnLocation( ActivateFireRemnant, ARemnantLoc )
		return
	end

	if ( FlameGuardDesire > 0 )
	then
		bot:Action_UseAbility( FlameGuard )
		return
	end
end

function X.ConsiderSearingChains()
	if (not SearingChains:IsFullyCastable()) then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius   = SearingChains:GetSpecialValueInt("radius")
	local nDamage   = SearingChains:GetSpecialValueInt("total_damage_tooltip")
	local nManaCost = SearingChains:GetManaCost()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList(nRadius)
	local nInBonusEnemyList = J.GetAroundEnemyHeroList(nRadius + 200)
	local botTarget = J.GetProperTarget(bot)

	for _,npcEnemy in pairs(nInBonusEnemyList)
	do
		if J.IsValid(npcEnemy)
		and J.CanCastOnNonMagicImmune(npcEnemy)
		and npcEnemy:IsChanneling()
		and npcEnemy:HasModifier('modifier_teleporting')
	   then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.IsInRange(botTarget, bot, nRadius)
		and J.CanCastOnNonMagicImmune(botTarget )
		and J.CanCastOnTargetAdvanced(botTarget)
		and not J.IsDisabled( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
			then
				if npcEnemy:HasModifier('modifier_item_glimmer_cape')
				or npcEnemy:HasModifier('modifier_invisible')
				or npcEnemy:HasModifier('modifier_item_shadow_amulet_fade')
				then
					if J.CanCastOnNonMagicImmune(npcEnemy)
					and J.CanCastOnTargetAdvanced(npcEnemy)
					and not npcEnemy:HasModifier('modifier_item_dustofappearance')
					and not npcEnemy:HasModifier('modifier_slardar_amplify_damage')
					and not npcEnemy:HasModifier('modifier_bloodseeker_thirst_vision')
					and not npcEnemy:HasModifier('modifier_sniper_assassinate')
					and not npcEnemy:HasModifier('modifier_bounty_hunter_track')
					then
						return BOT_ACTION_DESIRE_HIGH
					end
				end
			end
		end
	end

	if J.IsRetreating(bot)
	and bot:WasRecentlyDamagedByAnyHero(1)
	then
		for _, npcEnemy in pairs(nInRangeEnemyList)
		do
			if J.IsValid(npcEnemy)
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and not J.IsDisabled( npcEnemy )
			and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSleightOfFist()
	if (not SleightOfFist:IsFullyCastable()) then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius    = SleightOfFist:GetSpecialValueInt('radius')
	local nCastRange = SleightOfFist:GetCastRange()
	local nCastPoint = SleightOfFist:GetCastPoint()
	local nManaCost  = SleightOfFist:GetManaCost()
	local nDamage    = bot:GetAttackDamage() + SleightOfFist:GetSpecialValueInt('bonus_hero_damage')
	local nInRangeEnemyList = J.GetAroundEnemyHeroList(nRadius)
	local nInBonusEnemyList = J.GetAroundEnemyHeroList(nRadius + 200)

	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nCastRange + nRadius / 2, true, BOT_MODE_NONE)

	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
		do
			if J.IsValid(npcEnemy)
			and bot:WasRecentlyDamagedByHero(npcEnemy, 2.0)
			and J.CanCastOnMagicImmune(npcEnemy)
			then
				if J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PHYSICAL)
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, npcEnemy:GetLocation()
				end

				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation()
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()

		if J.IsValidTarget(npcTarget)
		and J.CanCastOnMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
		end
	end

    if J.IsFarming(bot) and J.AllowedToSpam(bot, nManaCost)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
		local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius / 2, nCastPoint, 0)
		if (locationAoE.count >= 2 and #nNeutralCreeps >= 2)
		then
            if SleightOfFist:GetLevel() >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
            end

			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	if J.IsLaning(bot) and J.AllowedToSpam(bot, nManaCost)
	then
		local botTarget = bot:GetTarget()
		if J.IsValidTarget(botTarget)
		and botTarget:GetHealth() <= nDamage
		then
			return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetLocation()
		end
	end

	if (J.IsPushing(bot) or J.IsDefending(bot))
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + nRadius, true)
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius / 2, nCastPoint, 0)
		if (locationAoE.count >= 3 and #nLaneCreeps >= 3)
		then
            if SleightOfFist:GetLevel() >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
            end

			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius / 2, nCastPoint, 0)
		if (locationAoE.count >= 2)
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFlameGuard()
	if ( not FlameGuard:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius   = FlameGuard:GetSpecialValueInt( "radius" )
	local nDamage   = FlameGuard:GetSpecialValueFloat( "duration" ) * FlameGuard:GetSpecialValueInt( "damage_per_second" )
	local nManaCost = FlameGuard:GetManaCost()

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()
		if J.IsValidTarget(npcTarget)
		and J.CanCastOnNonMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
		for _, npcEnemy in pairs( nEnemyHeroes )
		do
			if (bot:WasRecentlyDamagedByHero(npcEnemy, 2.0))
			then
				return BOT_ACTION_DESIRE_LOW
			end
		end
	end

	if J.IsFarming(bot)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
		if nNeutralCreeps ~= nil and #nNeutralCreeps >= 3 then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsDoingRoshan(bot)
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsRoshan(npcTarget)
		and J.CanCastOnMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
		and J.IsInRange(nEnemyHeroes[1], bot, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderActivateFireRemnant()
	if (not ActivateFireRemnant:IsFullyCastable()) then
		return BOT_ACTION_DESIRE_NONE, {}
	end

	local units = GetUnitList(UNIT_LIST_ALLIES)

	if J.IsRetreating(bot)
	or J.IsGoingOnSomeone(bot)
	then
		for _, u in pairs(units) do
			if u ~= nil and u:GetUnitName() == "npc_dota_ember_spirit_remnant" and GetUnitToLocationDistance(u, remnantLoc) < 250 then
				return BOT_ACTION_DESIRE_HIGH, u:GetLocation()
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, {}
end

function X.ConsiderFireRemnant()
	if (not FireRemnant:IsFullyCastable() or not ActivateFireRemnant:IsFullyCastable() or bot:IsRooted())
	then
		return BOT_ACTION_DESIRE_NONE, {}
	end

	if DotaTime() < remnantCastTime + remnantCastGap then
		return BOT_ACTION_DESIRE_NONE, {}
	end

	local units = GetUnitList(UNIT_LIST_ALLIES)
	local remnantCount = 0

	for _, u in pairs(units) do
		if u ~= nil and u:GetUnitName() == "npc_dota_ember_spirit_remnant" and GetUnitToUnitDistance(bot, u) < 1600 then
			remnantCount = remnantCount + 1
		end
	end

	if remnantCount > 0 then
		return BOT_ACTION_DESIRE_NONE, {}
	end

	local nRadius      = FireRemnant:GetSpecialValueInt( "radius" )
	local nCastRange   = FireRemnant:GetCastRange()
	local nCastPoint   = FireRemnant:GetCastPoint()
	local nDamage      = FireRemnant:GetSpecialValueInt( "damage" )
	local nSpeed       = bot:GetCurrentMovementSpeed() * (FireRemnant:GetSpecialValueInt( "speed_multiplier" ) / 100)
	local nManaCost    = FireRemnant:GetManaCost()

	if nCastRange > 1600 then nCastRange = 1600 end

	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

	for _, npcEnemy in pairs(nEnemyHeroes)
	do
		if J.CanCastOnMagicImmune(npcEnemy)
		and J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL)
		then
			local eta = (GetUnitToUnitDistance(npcEnemy, bot) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(eta)
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()
		if J.IsValidTarget(npcTarget)
		and J.CanCastOnMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nCastRange)
		then
			local targetAlly  = npcTarget:GetNearbyHeroes(nCastRange, false, BOT_MODE_ATTACK)
			local targetEnemy = npcTarget:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
			if targetEnemy ~= nil and targetAlly ~= nil and #targetEnemy >= #targetAlly
			then
				local eta = (GetUnitToUnitDistance(npcTarget, bot) / nSpeed) + nCastPoint
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(eta)
			end
		end
	end

	if J.IsRetreating(bot)
	then
		for _, npcEnemy in pairs(nEnemyHeroes)
		do
			if (bot:WasRecentlyDamagedByHero(npcEnemy, 1.0) and #nEnemyHeroes > 1)
			then
				local loc = J.GetEscapeLoc()
				return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, (#nEnemyHeroes * (nCastRange / 5)))
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, {}
end

return X