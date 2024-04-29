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
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,2,1,2,1,2,1,1,6,3,3,3,6,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )


local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_magic_wand",

	"item_ring_of_basilius",
	"item_power_treads",
	"item_manta",
	"item_butterfly",--
	"item_greater_crit",--
	"item_skadi",--
	"item_monkey_king_bar",--
	"item_travel_boots",
	"item_aghanims_shard",
	"item_disperser",--
	"item_moon_shard",
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_magic_wand",
	"item_ring_of_basilius",
	"item_manta",
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

--[[

npc_dota_hero_medusa

"Ability1"		"medusa_split_shot"
"Ability2"		"medusa_mystic_snake"
"Ability3"		"medusa_mana_shield"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"medusa_stone_gaze"
"Ability10"		"special_bonus_attack_damage_15"
"Ability11"		"special_bonus_evasion_15"
"Ability12"		"special_bonus_attack_speed_30"
"Ability13"		"special_bonus_unique_medusa_3"
"Ability14"		"special_bonus_unique_medusa_5"
"Ability15"		"special_bonus_unique_medusa"
"Ability16"		"special_bonus_mp_1000"
"Ability17"		"special_bonus_unique_medusa_4"

modifier_medusa_split_shot
modifier_medusa_mana_shield
modifier_medusa_stone_gaze_tracker
modifier_medusa_stone_gaze
modifier_medusa_stone_gaze_slow
modifier_medusa_stone_gaze_facing
modifier_medusa_stone_gaze_stone


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilityM = nil

local castQDesire
local castWDesire, castWTarget
local castEDesire
local castRDesire


local nKeepMana, nMP, nHP, nLV, hEnemyHeroList
local lastToggleTime = 0


function X.SkillsComplement()

	J.ConsiderForMkbDisassembleMask( bot )
	J.ConsiderTarget()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )


	castWDesire, castWTarget = X.ConsiderW()
	if castWDesire > 0
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end


	castRDesire = X.ConsiderR()
	if castRDesire > 0 
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityR )
		return

	end
	
	castQDesire = X.ConsiderQ()
	if castQDesire > 0
	then
		bot:Action_UseAbility( abilityQ )
		return
	end

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end

	local nCastRange = bot:GetAttackRange() + 150
	local nSkillLv = abilityQ:GetLevel()
	
	local nInRangeEnemyHeroList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local nInRangeEnemyCreepList = bot:GetNearbyCreeps(nCastRange, true)
	local nInRangeEnemyLaneCreepList = bot:GetNearbyLaneCreeps(nCastRange, true)
	local nAllyLaneCreepList = bot:GetNearbyLaneCreeps(800, false)
	local botTarget = J.GetProperTarget(bot)
	
	--关闭分裂的情况
	if J.IsLaning( bot )
		or ( #nInRangeEnemyHeroList == 1 )
		or ( J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget) and nSkillLv <= 2 and #nInRangeEnemyHeroList == 2 )
		or ( #nInRangeEnemyHeroList == 0 and #nInRangeEnemyCreepList <= 1 )
		or ( #nInRangeEnemyHeroList == 0 and #nInRangeEnemyLaneCreepList >= 2 and #nAllyLaneCreepList >= 1 and nSkillLv <= 3 )
	then
		if abilityQ:GetToggleState()
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	else
		if not abilityQ:GetToggleState()
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	

	return BOT_ACTION_DESIRE_NONE
		
end


function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return 0 end

	if nHP > 0.8 and nMP < 0.88 and nLV < 15
	  and J.GetEnemyCount( bot, 1600 ) <= 1
	  and lastToggleTime + 3.0 < DotaTime()
	then
		if abilityE:GetToggleState()
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	else
		if not abilityE:GetToggleState()
		then
			lastToggleTime = DotaTime()
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end

	local nCastRange = abilityW:GetCastRange() + 20
	local nDamage = abilityW:GetSpecialValueInt( 'snake_damage' ) * 2
	local nSkillLv = abilityW:GetLevel()

	if J.IsRetreating( bot )
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValidHero( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy
			end
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then

		local npcMaxManaEnemy = nil
		local nEnemyMaxMana = 0

		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 50, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				local nMaxMana = npcEnemy:GetMaxMana()
				if ( nMaxMana > nEnemyMaxMana )
				then
					nEnemyMaxMana = nMaxMana
					npcMaxManaEnemy = npcEnemy
				end
			end
		end

		if ( npcMaxManaEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMaxManaEnemy
		end

	end

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.CanCastOnTargetAdvanced( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 90 )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end

	if nSkillLv >= 3 then
		local nAoe = bot:FindAoELocation( true, false, bot:GetLocation(), 900, 500, 0, 0 )
		local nShouldAoeCount = 5
		local nCreeps = bot:GetNearbyCreeps( nCastRange, true )
		local nLaneCreeps = bot:GetNearbyLaneCreeps( 1600, true )

		if nSkillLv == 4 then nShouldAoeCount = 4 end
		if bot:GetLevel() >= 20 or J.GetMP( bot ) > 0.88 then nShouldAoeCount = 3 end

		if nAoe.count >= nShouldAoeCount
		then
			if J.IsValid( nCreeps[1] )
				and J.CanCastOnNonMagicImmune( nCreeps[1] )
				and not ( nCreeps[1]:GetTeam() == TEAM_NEUTRAL and #nLaneCreeps >= 1 )
				and J.GetAroundTargetEnemyUnitCount( nCreeps[1], 470 ) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, nCreeps[1]
			end
		end

		if #nCreeps >= 2 and nSkillLv >= 3
		then
			local creeps = bot:GetNearbyCreeps( 1400, true )
			local heroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
			if J.IsValid( nCreeps[1] )
				and #creeps + #heroes >= 4
				and J.CanCastOnNonMagicImmune( nCreeps[1] )
				and not ( nCreeps[1]:GetTeam() == TEAM_NEUTRAL and #nLaneCreeps >= 1 )
				and J.GetAroundTargetEnemyUnitCount( nCreeps[1], 470 ) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, nCreeps[1]
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end


function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0	end

	local nCastRange = abilityR:GetSpecialValueInt( "radius" )
	local nAttackRange = bot:GetAttackRange()

	--如果射程内无面对自己的真身则不开大
	local bRealHeroFace = false
	local realHeroList = J.GetEnemyList( bot, nAttackRange + 100 )
	for _, npcEnemy in pairs( realHeroList )
	do 
		if npcEnemy:IsFacingLocation( bot:GetLocation(), 50 )
		then
			bRealHeroFace = true
			break
		end
	end
	
	if not bRealHeroFace then return 0 end 
	

	if J.IsRetreating( bot )
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and npcEnemy:IsFacingLocation( bot:GetLocation(), 20 ) )
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end


	if J.IsInTeamFight( bot, 1200 ) or J.IsGoingOnSomeone( bot )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nAttackRange, 400, 0, 0 )
		if ( locationAoE.count >= 2 )
		then
			local nInvUnit = J.GetInvUnitInLocCount( bot, nAttackRange + 200, 400, locationAoE.targetloc, true )
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end

		local nEnemysHerosInSkillRange = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE )
		if #nEnemysHerosInSkillRange >= 3
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		local nAoe = bot:FindAoELocation( true, true, bot:GetLocation(), 10, 700, 1.0, 0 )
		if nAoe.count >= 3
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and not J.IsDisabled( npcTarget )
			and GetUnitToUnitDistance( npcTarget, bot ) <= bot:GetAttackRange()
			and npcTarget:GetHealth() > 600
			and npcTarget:GetPrimaryAttribute() ~= ATTRIBUTE_INTELLECT
			and npcTarget:IsFacingLocation( bot:GetLocation(), 30 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end

	end

	return BOT_ACTION_DESIRE_NONE

end


function X.GetHurtCount( nUnit, nCount )

	local nHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	local nCreeps = bot:GetNearbyCreeps( 1600, true, BOT_MODE_NONE )
	local nTable = {}
	table.insert( nTable, nUnit )
	local nHurtCount = 1

	for i=1, nCount
	do
		local nNeastUnit = X.GetNearestUnit( nUnit, nHeroes, nCreeps, nTable )

		if nNeastUnit ~= nil
			and GetUnitToUnitDistance( nUnit, nNeastUnit ) <= 475
		then
			nHurtCount = nHurtCount + 1
			table.insert( nTable, nNeastUnit )
		else
			break
		end
	end


	return nHurtCount

end

function X.GetNearestUnit( nUnit, nHeroes, nCreeps, nTable )

	local NearestUnit = nil
	local NearestDist = 9999
	for _, unit in pairs( nHeroes )
	do
		if unit ~= nil
			and unit:IsAlive()
			and not X.IsExistInTable( unit, nTable )
			and GetUnitToUnitDistance( nUnit, unit ) < NearestDist
		then
			NearestUnit = unit
			NearestDist = GetUnitToUnitDistance( nUnit, unit )
		end
	end

	for _, unit in pairs( nCreeps )
	do
		if unit ~= nil
			and unit:IsAlive()
			and not X.IsExistInTable( unit, nTable )
			and GetUnitToUnitDistance( nUnit, unit ) < NearestDist
		then
			NearestUnit = unit
			NearestDist = GetUnitToUnitDistance( nUnit, unit )
		end
	end

	return NearestUnit

end

function X.IsExistInTable( u, tUnit )
	for _, t in pairs( tUnit )
	do
		if t == u
		then
			return true
		end
	end
	return false
end

return X
-- dota2jmz@163.com QQ:2462331592..
