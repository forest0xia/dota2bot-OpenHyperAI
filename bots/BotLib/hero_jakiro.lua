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
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,1,2,1,6,1,2,2,2,6,3,3,3,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_3'] = {
	"item_mage_outfit",
	"item_ancient_janggo",
	"item_glimmer_cape",
	"item_boots_of_bearing",
	"item_rod_of_atos",
	"item_mjollnir",--
	"item_aghanims_shard",
	"item_veil_of_discord",
	"item_cyclone",
	"item_shivas_guard",
	"item_sheepstick",
	"item_wind_waker",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_4'] = {
	"item_blood_grenade",
	"item_priest_outfit",
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

sRoleItemsBuyList['pos_5'] = {
	"item_blood_grenade",

	'item_mage_outfit',
	'item_ancient_janggo',
	'item_glimmer_cape',
	'item_boots_of_bearing',
	'item_pipe',
	"item_shivas_guard",
	'item_cyclone',
	'item_sheepstick',
	"item_wind_waker",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = {
	"item_crystal_maiden_outfit",
	-- "item_falcon_blade",
    "item_witch_blade",
    "item_orchid",
    "item_force_staff",
    "item_ultimate_scepter",
    "item_hurricane_pike",--
    "item_yasha_and_kaya",--
    -- "item_black_king_bar",--
	"item_bloodthorn",--
	-- "item_mjollnir",--
    "item_sphere",--
    "item_aghanims_shard",
    "item_skadi",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_2']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

	"item_ultimate_scepter",
	"item_magic_wand",

	"item_cyclone",
	"item_magic_wand",

	"item_shivas_guard",
	'item_magic_wand',

	"item_skadi",--
    "item_witch_blade",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

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

local abilityQ = bot:GetAbilityByName('jakiro_dual_breath')
local abilityW = bot:GetAbilityByName('jakiro_ice_path')
local abilityE = bot:GetAbilityByName('jakiro_liquid_fire')
local abilityAS = bot:GetAbilityByName('jakiro_liquid_frost')
local abilityR = bot:GetAbilityByName('jakiro_macropyre')

local castQDesire, castQTarget
local castWDesire, castWLocation
local castEDesire, castETarget
local castASDesire, castASTarget
local castRDesire, castRLocation

function X.SkillsComplement()
	if J.CanNotUseAbility( bot ) then return end

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

	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQTarget )
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
	if not J.CanCastAbility(abilityQ) then return 0 end

	local nCastRange = J.GetProperCastRange(false, bot, abilityQ:GetCastRange())
	local nCastPoint = abilityQ:GetCastPoint()
	local manaCost = abilityQ:GetManaCost()
	local nRadius = abilityQ:GetSpecialValueInt( "start_radius" )
	local nDuration = abilityQ:GetDuration()
	local nSpeed = abilityQ:GetSpecialValueInt( 'speed' )
	local nDamage = abilityQ:GetSpecialValueInt( 'burn_damage' )

	local botTarget = J.GetProperTarget( bot )
	local nEnemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )

    for _, enemy in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemy)
        and J.IsInRange(bot, enemy, nCastRange)
        and J.CanCastOnNonMagicImmune(enemy)
        and J.WillKillTarget(enemy, nDamage, DAMAGE_TYPE_MAGICAL, nDuration)
        and not enemy:HasModifier('modifier_abaddon_borrowed_time')
        and not enemy:HasModifier('modifier_dazzle_shallow_grave')
        and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemy:HasModifier('modifier_oracle_false_promise_timer')
        and not enemy:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(enemy, nCastPoint)
        end
    end

	if J.IsInTeamFight( bot, 1300 )
	then
		local nLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
		local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if #nInRangeEnemy >= 2
		then
			return BOT_ACTION_DESIRE_LOW, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone( bot ) and #nEnemyHeroes == 1
	then
		if J.IsValidHero( botTarget )
		and J.CanCastOnNonMagicImmune( botTarget )
		and J.IsInRange( botTarget, bot, nCastRange )
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, nCastPoint)
		end
	end

	if J.IsRetreating( bot )
	and not J.IsRealInvisible(bot)
	and bot:WasRecentlyDamagedByAnyHero(3.0)
	then
        if J.IsValidHero(nEnemyHeroes[1])
        and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
        and J.IsInRange(bot, nEnemyHeroes[1], nCastRange)
        and J.IsChasingTarget(nEnemyHeroes[1], bot)
        and not nEnemyHeroes[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]:GetLocation()
		end

		local nLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 100, nRadius * 1.6, nCastPoint, 0 )
		if nLocationAoE.count >= 2 and #nEnemyHeroes >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	local tEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

	if J.IsPushing(bot)
	and J.GetManaAfter(manaCost) >= 0.5
	and not J.IsThereCoreNearby(1400)
	then
		if #tEnemyLaneCreeps > 3
		and J.CanBeAttacked(tEnemyLaneCreeps[1])
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(tEnemyLaneCreeps)
		end
	end

	if J.IsDefending(bot)
	and J.GetManaAfter(manaCost) >= 0.35
	then
		if #tEnemyLaneCreeps > 3
		and J.CanBeAttacked(tEnemyLaneCreeps[1])
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(tEnemyLaneCreeps)
		end
	end

	if J.IsFarming(bot)
	and J.GetManaAfter(manaCost) >= 0.4
	then
		local tCreeps = bot:GetNearbyCreeps(nCastRange, true)
		if #tCreeps > 2
		and J.CanBeAttacked(tCreeps[1])
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(tCreeps)
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

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderW()

	if not J.CanCastAbility(abilityW) then return 0 end

	local nCastRange = J.GetProperCastRange(false, bot, abilityW:GetCastRange())
	local nCastPoint = abilityW:GetCastPoint()
	local manaCost = abilityW:GetManaCost()
	local nRadius = abilityW:GetSpecialValueInt( "path_radius" )
	local nDelay = abilityW:GetSpecialValueFloat( 'path_delay' )
	local nDamage = abilityW:GetSpecialValueInt( 'damage' )

	local botTarget = J.GetProperTarget( bot )
	local nEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE )
	local hNearEnemyHeroList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	for _, enemy in pairs( nEnemyHeroes )
	do
		if J.IsValidHero(enemy)
		and J.IsInRange(bot, enemy, nCastRange + 200)
		and J.CanCastOnNonMagicImmune(enemy)
		then
			if enemy:IsChanneling() then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
			end
		end
	end

	if J.IsRetreating( bot )
	and not J.IsRealInvisible(bot)
	then
		if #nEnemyHeroes > 0 and bot:WasRecentlyDamagedByAnyHero( 2.0 ) then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 100, nRadius * 1.6, nCastPoint, 0 )
			if locationAoE.count >= 1 and #hNearEnemyHeroList >= 1
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
			end
		end
	end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) ) and J.IsAllowedToSpam( bot, manaCost )
	then
		local lanecreeps = bot:GetNearbyLaneCreeps( nCastRange, true )
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
		if ( locationAoE.count >= 6 and #lanecreeps >= 6 )
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
	end


	if J.IsInTeamFight( bot, 1300 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nDelay + nCastPoint, 0 )
		local nInRangeEnemy = J.GetEnemiesNearLoc(locationAoE.targetloc, nRadius)
		if #nInRangeEnemy >= 2
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
		and J.CanCastOnNonMagicImmune( botTarget )
		and J.IsInRange( botTarget, bot, nCastRange - 150 )
		and not J.IsDisabled( botTarget )
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, nDelay + nCastPoint)
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


function X.ConsiderE()

	if not J.CanCastAbility(abilityE) then return 0 end

	local nCastRange = bot:GetAttackRange() + 200
	if nCastRange > 1300 then nCastRange = 1300 end

	local botTarget = J.GetProperTarget( bot )
	local aTarget = bot:GetAttackTarget()
	local nEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local nRadius = 300

	--团战中对作用数量最多或物理输出最强的敌人使用
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcMostAoeEnemy = nil
		local nMostAoeECount = 1
		local nEnemysHerosInBonus = bot:GetNearbyHeroes( nCastRange + 299, true, BOT_MODE_NONE )
		local nEnemysHerosInRange = bot:GetNearbyHeroes( nCastRange + 43, true, BOT_MODE_NONE )
		local nEmemysCreepsInRange = bot:GetNearbyCreeps( nCastRange + 43, true )
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


	if J.IsValidBuilding(aTarget)
	and J.IsInRange( aTarget, bot, nCastRange )
	then
		return BOT_ACTION_DESIRE_HIGH, aTarget
	end


	if aTarget == nil and #nEnemyHeroes == 0
	then
		local hEnemyTowerList = bot:GetNearbyTowers( nCastRange + 36, true )
		local hEnemyBarrackList = bot:GetNearbyBarracks( nCastRange + 36, true )
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
		local towers = bot:GetNearbyTowers( nCastRange, true )
		if J.IsValidBuilding(towers[1]) and J.CanBeAttacked(towers[1])
		then
			return BOT_ACTION_DESIRE_HIGH, towers[1]
		end
		local barracks = bot:GetNearbyBarracks( nCastRange, true )
		if J.IsValidBuilding(barracks[1]) and J.CanBeAttacked(barracks[1])
		then
			return BOT_ACTION_DESIRE_HIGH, barracks[1]
		end
		local creeps = bot:GetNearbyLaneCreeps( nCastRange, true )
		if #creeps >= 2 and J.IsValid(creeps[1]) and J.CanBeAttacked(creeps[1])
		then
			return BOT_ACTION_DESIRE_HIGH, creeps[1]
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderAS()
	if not J.CanCastAbility(abilityAS) then return 0 end

	local nCastRange = bot:GetAttackRange() + 200
	if nCastRange > 1300 then nCastRange = 1300 end

	local botTarget = J.GetProperTarget( bot )
	local aTarget = bot:GetAttackTarget()
	local nEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsValidBuilding(aTarget)
		and J.IsInRange( aTarget, bot, nCastRange )
	then
		return BOT_ACTION_DESIRE_HIGH, aTarget
	end


	if aTarget == nil and #nEnemyHeroes == 0
	then
		local hEnemyTowerList = bot:GetNearbyTowers( nCastRange + 36, true )
		local hEnemyBarrackList = bot:GetNearbyBarracks( nCastRange + 36, true )
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
		local towers = bot:GetNearbyTowers( nCastRange, true )
		if J.IsValidBuilding(towers[1]) and J.CanBeAttacked(towers[1])
		then
			return BOT_ACTION_DESIRE_HIGH, towers[1]
		end
		local barracks = bot:GetNearbyBarracks( nCastRange, true )
		if J.IsValidBuilding(barracks[1]) and J.CanBeAttacked(barracks[1])
		then
			return BOT_ACTION_DESIRE_HIGH, barracks[1]
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end


	return BOT_ACTION_DESIRE_NONE

end




function X.ConsiderR()
	if not J.CanCastAbility(abilityR) then return 0 end

	local nCastRange = J.GetProperCastRange(false, bot, abilityR:GetCastRange())
	if nCastRange > 1500 then nCastRange = 1500 end
	local nCastPoint = abilityR:GetCastPoint()
	local manaCost = abilityR:GetManaCost()
	local nRadius = abilityR:GetSpecialValueInt( "path_radius" )
	local nDamage = abilityR:GetSpecialValueInt( 'damage' )

	local botTarget = J.GetProperTarget( bot )
	local nEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	for _, enemy in pairs(nEnemyHeroes)
	do
		if J.IsValidHero(enemy)
		and J.GetHP(bot) > 0.5
		and not J.IsSuspiciousIllusion(enemy)
		then
			if enemy:HasModifier('modifier_faceless_void_chronosphere_freeze')
			or enemy:HasModifier('modifier_enigma_black_hole_pull')
			then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
			end
		end
	end


	if J.IsRetreating( bot )
	and not J.IsRealInvisible(bot)
	then
		if #nEnemyHeroes > 0 and bot:WasRecentlyDamagedByAnyHero( 2.0 )
		then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 100, nRadius * 1.6, nCastPoint, 0 )
			local nInRangeEnemy = J.GetEnemiesNearLoc(locationAoE.targetloc, nRadius)
			if #nInRangeEnemy >= 2
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
			end
		end
	end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
		if locationAoE.count >= 2
		then
			local hTrueHeroList = J.GetEnemyList( bot, 1200 )
			if #hTrueHeroList >= 2
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
			end
		end
	end


	if J.IsInTeamFight( bot, 1300 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
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
		if J.IsValidHero( botTarget )
			and botTarget:GetHealth() > 600
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange -200 )
			and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local targetAllies = botTarget:GetNearbyHeroes( 2 * nRadius, false, BOT_MODE_NONE )
			if #targetAllies >= 2 or J.IsInRange( botTarget, bot, 600 )
			then
				return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, nCastPoint)
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

return X
