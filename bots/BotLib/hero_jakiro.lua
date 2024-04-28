----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
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
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{3,1,2,1,1,6,1,2,2,2,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_crystal_maiden_outfit",
--	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_force_staff",
	"item_ultimate_scepter",
	"item_hurricane_pike",
	"item_cyclone", 
	"item_sheepstick",
	"item_wind_waker",
	"item_refresher",
	"item_lotus_orb",
	"item_moon_shard",
	"item_ultimate_scepter_2",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = {

	"item_priest_outfit",
	"item_urn_of_shadows",
	"item_mekansm",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
--	"item_wraith_pact",
	"item_ultimate_scepter",
	"item_shivas_guard",
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_sheepstick",

}

tOutFitList['outfit_mage'] = {

	"item_mage_outfit",
	"item_ancient_janggo",
	"item_glimmer_cape",
	"item_boots_of_bearing",
	"item_pipe",
	"item_aghanims_shard",
	"item_veil_of_discord",
	"item_cyclone",
	"item_sheepstick",
	"item_wind_waker",
	"item_moon_shard",
	"item_ultimate_scepter_2",

}

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_cyclone",
	"item_magic_wand",

	"item_ultimate_scepter",
	"item_magic_wand",
	
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_jakiro

"Ability1"		"jakiro_dual_breath"
"Ability2"		"jakiro_ice_path"
"Ability3"		"jakiro_liquid_fire"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"jakiro_macropyre"
"Ability10"		"special_bonus_attack_range_300"
"Ability11"		"special_bonus_spell_amplify_8"
"Ability12"		"special_bonus_exp_boost_40"
"Ability13"		"special_bonus_unique_jakiro_2"
"Ability14"		"special_bonus_unique_jakiro_4"
"Ability15"		"special_bonus_gold_income_25"
"Ability16"		"special_bonus_unique_jakiro_3"
"Ability17"		"special_bonus_unique_jakiro"

modifier_jakiro_dual_breath
modifier_jakiro_dual_breath_slow
modifier_jakiro_dual_breath_burn
modifier_jakiro_ice_path_stun
modifier_jakiro_ice_path
modifier_jakiro_liquidfire
modifier_jakiro_liquid_fire_burn
modifier_jakiro_macropyre
modifier_jakiro_macropyre_burn

--]]


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castCombo1Desire = 0
local castCombo2Desire = 0
local castQDesire, castQTarget
local castQ2Desire, castQLocation
local castWDesire, castWLocation
local castEDesire, castETarget
local castASDesire, castASTarget
local castRDesire, castRLocation

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList
local aetherRange = 0

function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end


	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end


	castWDesire, castWLocation = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
	end


	castRDesire, castRLocation = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation )
		return
	end

	castQ2Desire, castQLocation = X.ConsiderQ2()
	if ( castQ2Desire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return
	end

	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end

	castEDesire, castETarget = X.ConsiderE()
	if ( castEDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end
	
	
	castASDesire, castASTarget = X.ConsiderAS()
	if ( castASDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityAS, castASTarget )
		return
	end


end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end

	local castRange = abilityQ:GetCastRange() + aetherRange
	if castRange > 1600 then castRange = 1600 end
	
	local target = J.GetProperTarget( bot )
	local enemies = bot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE )

	if J.IsGoingOnSomeone( bot ) and #enemies == 1
	then
		if J.IsValidHero( target )
			and J.CanCastOnNonMagicImmune( target )
			and J.IsInRange( target, bot, castRange )
		then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end


	return BOT_ACTION_DESIRE_NONE

end


function X.ConsiderQ2()

	if not abilityQ:IsFullyCastable() then return 0 end

	local castRange = abilityQ:GetCastRange() + aetherRange
	local castPoint = abilityQ:GetCastPoint()
	local manaCost = abilityQ:GetManaCost()
	local nRadius = abilityQ:GetSpecialValueInt( "start_radius" )
	local nDuration = abilityQ:GetDuration()
	local nSpeed = abilityQ:GetSpecialValueInt( 'speed' )
	local nDamage = abilityQ:GetSpecialValueInt( 'burn_damage' )

	local target = J.GetProperTarget( bot )
	local enemies = bot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE )

	if J.IsRetreating( bot )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange - 100, nRadius * 1.6, castPoint, 0 )
		if locationAoE.count >= 2 and #enemies >= 2
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
	end

	if ( J.IsPushing( bot ) or J.IsDefending( bot ) ) and J.IsAllowedToSpam( bot, manaCost )
	then
		local lanecreeps = bot:GetNearbyLaneCreeps( castRange, true )
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius, 0, 0 )
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 )
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
	end

	if J.IsInTeamFight( bot, 1300 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, 0, 0 )
		if ( locationAoE.count >= 2 and #enemies >= 2 )
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( target )
			and J.CanCastOnNonMagicImmune( target )
			and J.IsInRange( target, bot, castRange - 200 )
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation( castPoint + 0.3 )
		end
	end


	return BOT_ACTION_DESIRE_NONE

end


function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end

	local castRange = abilityW:GetCastRange() + aetherRange
	local castPoint = abilityW:GetCastPoint()
	local manaCost = abilityW:GetManaCost()
	local nRadius = abilityW:GetSpecialValueInt( "path_radius" )
	local nDelay = abilityW:GetSpecialValueFloat( 'path_delay' )/2.0
	local nDamage = abilityW:GetSpecialValueInt( 'damage' )

	local target = J.GetProperTarget( bot )
	local enemies = bot:GetNearbyHeroes( castRange + 200, true, BOT_MODE_NONE )
	local hNearEnemyHeroList = bot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE )

	for _, enemy in pairs( enemies )
	do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
		end
	end


	if J.IsRetreating( bot )
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero( 2.0 ) then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange - 100, nRadius * 1.6, castPoint, 0 )
			if locationAoE.count >= 1 and #hNearEnemyHeroList >= 1
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
			end
		end
	end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) ) and J.IsAllowedToSpam( bot, manaCost )
	then
		local lanecreeps = bot:GetNearbyLaneCreeps( castRange, true )
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius, castPoint, 0 )
		if ( locationAoE.count >= 6 and #lanecreeps >= 6 )
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
	end


	if J.IsInTeamFight( bot, 1300 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, nDelay + castPoint, 0 )
		if locationAoE.count >= 2 and #hNearEnemyHeroList >= 2
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( target )
			and J.CanCastOnNonMagicImmune( target )
			and J.IsInRange( target, bot, castRange - 200 )
			and not J.IsDisabled( target )
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation( nDelay + castPoint )
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return 0 end

	local castRange = bot:GetAttackRange() + 200
	if castRange > 1300 then castRange = 1300 end

	local target = J.GetProperTarget( bot )
	local aTarget = bot:GetAttackTarget()
	local enemies = bot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE )
	local nRadius = 300

	--团战中对作用数量最多或物理输出最强的敌人使用
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcMostAoeEnemy = nil
		local nMostAoeECount = 1
		local nEnemysHerosInBonus = bot:GetNearbyHeroes( castRange + 299, true, BOT_MODE_NONE )
		local nEnemysHerosInRange = bot:GetNearbyHeroes( castRange + 43, true, BOT_MODE_NONE )
		local nEmemysCreepsInRange = bot:GetNearbyCreeps( castRange + 43, true )
		local nAllEnemyUnits = J.CombineTwoTable( nEnemysHerosInRange, nEmemysCreepsInRange )

		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		for _, npcEnemy in pairs( nAllEnemyUnits )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then

				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount( npcEnemy, nRadius )
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount
					npcMostAoeEnemy = npcEnemy
				end

				if npcEnemy:IsHero()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL )
					if ( npcEnemyDamage > nMostDangerousDamage )
					then
						nMostDangerousDamage = npcEnemyDamage
						npcMostDangerousEnemy = npcEnemy
					end
				end
			end
		end

		if ( npcMostAoeEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostAoeEnemy
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy
		end
	end


	if aTarget ~= nil
		and aTarget:IsAlive()
		and aTarget:IsBuilding()
		and J.IsInRange( aTarget, bot, castRange )
	then
		return BOT_ACTION_DESIRE_HIGH, aTarget
	end


	if aTarget == nil and #enemies == 0
	then
		local hEnemyTowerList = bot:GetNearbyTowers( castRange + 36, true )
		local hEnemyBarrackList = bot:GetNearbyBarracks( castRange + 36, true )
		local hTarget = hEnemyTowerList[1]
		if hTarget == nil then hTarget = hEnemyBarrackList[1] end
		if hTarget ~= nil
			and not hTarget:IsAttackImmune()
			and not hTarget:IsInvulnerable()
			and not hTarget:HasModifier( "modifier_fountain_glyph" )
			and not hTarget:HasModifier( "modifier_backdoor_protection_active" )
		then
			return BOT_ACTION_DESIRE_HIGH, hTarget
		end
	end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) )
	then
		local towers = bot:GetNearbyTowers( castRange, true )
		if towers[1] ~= nil and not towers[1]:IsInvulnerable() and not towers[1]:HasModifier( "modifier_fountain_glyph" )
		then
			return BOT_ACTION_DESIRE_HIGH, towers[1]
		end
		local barracks = bot:GetNearbyBarracks( castRange, true )
		if barracks[1] ~= nil and not barracks[1]:IsInvulnerable() and not barracks[1]:HasModifier( "modifier_fountain_glyph" )
		then
			return BOT_ACTION_DESIRE_HIGH, barracks[1]
		end
		local creeps = bot:GetNearbyLaneCreeps( castRange, true )
		if #creeps >= 2 and creeps[1] ~= nil and not creeps[1]:HasModifier( "modifier_fountain_glyph" )
		then
			return BOT_ACTION_DESIRE_HIGH, creeps[1]
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( target )
			and J.CanCastOnNonMagicImmune( target )
			and J.IsInRange( target, bot, castRange )
		then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderAS()

	if not abilityAS:IsTrained() or not abilityAS:IsFullyCastable() then return 0 end

	local castRange = bot:GetAttackRange() + 200
	if castRange > 1300 then castRange = 1300 end

	local target = J.GetProperTarget( bot )
	local aTarget = bot:GetAttackTarget()
	local enemies = bot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE )
	

	if aTarget ~= nil
		and aTarget:IsAlive()
		and aTarget:IsBuilding()
		and J.IsInRange( aTarget, bot, castRange )
	then
		return BOT_ACTION_DESIRE_HIGH, aTarget
	end


	if aTarget == nil and #enemies == 0
	then
		local hEnemyTowerList = bot:GetNearbyTowers( castRange + 36, true )
		local hEnemyBarrackList = bot:GetNearbyBarracks( castRange + 36, true )
		local hTarget = hEnemyTowerList[1]
		if hTarget == nil then hTarget = hEnemyBarrackList[1] end
		if hTarget ~= nil
			and not hTarget:IsAttackImmune()
			and not hTarget:IsInvulnerable()
			and not hTarget:HasModifier( "modifier_fountain_glyph" )
			and not hTarget:HasModifier( "modifier_backdoor_protection_active" )
		then
			return BOT_ACTION_DESIRE_HIGH, hTarget
		end
	end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) )
	then
		local towers = bot:GetNearbyTowers( castRange, true )
		if towers[1] ~= nil and not towers[1]:IsInvulnerable() and not towers[1]:HasModifier( "modifier_fountain_glyph" )
		then
			return BOT_ACTION_DESIRE_HIGH, towers[1]
		end
		local barracks = bot:GetNearbyBarracks( castRange, true )
		if barracks[1] ~= nil and not barracks[1]:IsInvulnerable() and not barracks[1]:HasModifier( "modifier_fountain_glyph" )
		then
			return BOT_ACTION_DESIRE_HIGH, barracks[1]
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( target )
			and J.CanCastOnNonMagicImmune( target )
			and J.IsInRange( target, bot, castRange )
		then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end


	return BOT_ACTION_DESIRE_NONE

end




function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

	local castRange = abilityR:GetCastRange() -100 + aetherRange
	if castRange > 1500 then castRange = 1500 end
	local castPoint = abilityR:GetCastPoint()
	local manaCost = abilityR:GetManaCost()
	local nRadius = abilityR:GetSpecialValueInt( "path_radius" )
	local nDamage = abilityR:GetSpecialValueInt( 'damage' )

	local target = J.GetProperTarget( bot )
	local enemies = bot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE )


	if J.IsRetreating( bot )
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero( 2.0 ) then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange - 100, nRadius * 1.6, castPoint, 0 )
			if locationAoE.count >= 1 and #enemies >= 1
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
			end
		end
	end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, castPoint, 0 )
		if locationAoE.count >= 2
		then
			local hTrueHeroList = J.GetEnemyList( bot, 1200 )
			if #hTrueHeroList >= 1
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
			end
		end
	end


	if J.IsInTeamFight( bot, 1300 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, castPoint, 0 )
		if locationAoE.count >= 2
		then
			local hTrueHeroList = J.GetEnemyList( bot, 1300 )
			if #hTrueHeroList >= 2
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
			end
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( target )
			and target:GetHealth() > 600
			and J.CanCastOnNonMagicImmune( target )
			and J.IsInRange( target, bot, castRange -200 )
		then
			local targetAllies = target:GetNearbyHeroes( 2 * nRadius, false, BOT_MODE_NONE )
			if #targetAllies >= 2 or J.IsInRange( target, bot, 600 )
			then
				return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation( castPoint )
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

return X
-- dota2jmz@163.com QQ:2462331592..
