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
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,1,2,1,6,1,2,2,2,3,6,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_4'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",
	"item_enchanted_mango",
	"item_blood_grenade",

	"item_boots",
	"item_tranquil_boots",
	"item_magic_wand",
	"item_glimmer_cape",--
	"item_aether_lens",--
	"item_aghanims_shard",
	"item_force_staff",--
	"item_boots_of_bearing",--
	"item_cyclone",
	"item_lotus_orb",--
	"item_wind_waker",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",
	"item_enchanted_mango",
	"item_blood_grenade",

	"item_boots",
	"item_arcane_boots",
	"item_magic_wand",
	"item_glimmer_cape",--
	"item_aether_lens",--
	"item_aghanims_shard",
	"item_force_staff",--
	"item_guardian_greaves",--
	"item_cyclone",
	"item_lotus_orb",--
	"item_wind_waker",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos4SellList = {
	"item_magic_wand",
}

Pos5SellList = {
	"item_magic_wand",
}

X['sSellList'] = {}

if sRole == "pos_4"
then
    X['sSellList'] = Pos4SellList
elseif sRole == "pos_5"
then
    X['sSellList'] = Pos5SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsKeyWordUnit( 'pugna_nether_ward', hMinionUnit )
		then
			hNetherWard = hMinionUnit
			return
		end

		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

"npc_dota_hero_pugna"

"Ability1"		"pugna_nether_blast"
"Ability2"		"pugna_decrepify"
"Ability3"		"pugna_nether_ward"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"pugna_life_drain"
"Ability10"		"special_bonus_movement_speed_20"
"Ability11"		"special_bonus_hp_225"
"Ability12"		"special_bonus_unique_pugna_4"
"Ability13"		"special_bonus_unique_pugna_6"
"Ability14"		"special_bonus_unique_pugna_1"
"Ability15"		"special_bonus_unique_pugna_5"
"Ability16"		"special_bonus_unique_pugna_2"
"Ability17"		"special_bonus_unique_pugna_3"

modifier_pugna_nether_blast_thinker
modifier_pugna_decrepify
modifier_pugna_nether_ward
modifier_pugna_nether_ward_aura
modifier_pugna_life_drain

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent7 = bot:GetAbilityByName( sTalentList[7] )

local castQDesire, castQLocation
local castWDesire, castWTarget
local castEDesire, castELocation
local castRDesire, castRTarget


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local talent7Damage = 0

local hNetherWard = nil

function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	talent7Damage = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end
	if talent7:IsTrained() then talent7Damage = talent7:GetSpecialValueInt( "value" ) end


	castQDesire, castQLocation, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end

	castEDesire, castELocation, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityE, castELocation )
		return
	end

	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return

	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nRadius 	 = abilityQ:GetSpecialValueInt( "radius" )
	local nCastPoint = abilityQ:GetCastPoint() + abilityQ:GetSpecialValueInt( "delay" )
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( "blast_damage" ) + talent7Damage
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange + nRadius * 0.8, true, BOT_MODE_NONE )

	local nTargetLocation = nil


	--击杀
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius, nCastPoint )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q击杀"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end


	--消耗
	local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange + 50, nRadius + 20, 0, 0 )
	if nCanHurtEnemyAoE.count >= 3
	then
		nTargetLocation = nCanHurtEnemyAoE.targetloc
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q消耗'
	end



	--团战
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q团战'
		end
	end


	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + nRadius - 120 )
		then
			nTargetLocation = J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius -60, nCastPoint + 0.3 )
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q打架"..J.Chat.GetNormName( botTarget )
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange -120, nRadius -30, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q撤退Aoe'
		end

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 ) or bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_VERYHIGH )
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange -140, nRadius, nCastPoint + 0.3 )
				if not bot:IsFacingLocation( npcEnemy:GetLocation(), 50 ) then nTargetLocation = bot:GetLocation() end
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q撤退消耗:"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end


	--自保
	if bot:WasRecentlyDamagedByAnyHero( 3.0 ) and nLV >= 6
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nInRangeEnemyList >= 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy ) 
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 60 )
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius -30, nCastPoint + 0.2 )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q自保"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end

	--对线

	--打野
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, 1000 )
			and ( botTarget:GetMagicResist() < 0.4 or nMP > 0.9 )
		then
			local nShouldHurtCount = nMP > 0.6 and 2 or 3
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange + 220, nRadius, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q打钱"..locationAoE.count
			end
		end
	end

	--带线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and nSkillLV >= 3 and DotaTime() > 9 * 60
		and #hAllyList <= 3 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nCastRange + 400, true )
		if #laneCreepList >= 4
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange + 220, nRadius, nCastPoint, nDamage )
			if locationAoEKill.count >= 3
			then
				nTargetLocation = locationAoEKill.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q带线补刀"..locationAoEKill.count
			end

			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange + 220, nRadius + 50, 0.8, 0 )
			if locationAoEHurt.count >= 4
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q带线清兵"..locationAoEHurt.count
			end
		end
	end

	--肉山
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 600
	then
		if J.IsRoshan( botTarget ) and J.GetHP( botTarget ) > 0.2
			and J.IsInRange( botTarget, bot, nCastRange + 300 )
		then
			nTargetLocation = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q肉山'
		end
	end


	--推塔
	if J.IsAllowedToSpam( bot, 120 )
		and nSkillLV >= 4
		and ( nLV >= 8 or DotaTime() > 8 * 60 )
		and bot:GetMana() > abilityR:GetManaCost() + 200
	then
		local nTowerList = bot:GetNearbyTowers( 990, true )
		local nBarrackList = bot:GetNearbyBarracks( 990, true )
		local nEnemyAcient = GetAncient( GetOpposingTeam() )
		local hBuildingList = {
			botTarget,
			nTowerList[1],
			nBarrackList[1],
			nEnemyAcient, 
		}

		for _, nBuilding in pairs( hBuildingList )
		do
			if J.IsValidBuilding( nBuilding )
				and J.IsInRange( bot, nBuilding, nCastRange + nRadius - 50 )
				and not nBuilding:HasModifier( 'modifier_fountain_glyph' )
				and not nBuilding:HasModifier( 'modifier_invulnerable' )
				and not nBuilding:HasModifier( 'modifier_backdoor_protection' )
				and not J.IsKeyWordUnit( "DOTA_Outpost", nBuilding )
			then
				local nTargetLocation = nBuilding:GetLocation()
				if not J.IsInLocRange( bot, nTargetLocation, nCastRange )
				then
					nTargetLocation = J.GetUnitTowardDistanceLocation( bot, nBuilding, nCastRange )
				end
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q推塔"
				end
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + aetherRange
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange + 50, true, BOT_MODE_NONE )


	if J.IsValid( hNetherWard )
		and J.IsInRange( bot, hNetherWard, nCastRange )
		and J.GetHP( hNetherWard ) < 0.9
	then
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValid( npcEnemy )
				and npcEnemy:GetAttackTarget() == hNetherWard
			then
				return BOT_ACTION_DESIRE_HIGH, hNetherWard, 'W-NetherWard'
			end
		end
	end


	if J.IsInTeamFight( bot, 900 ) and #hEnemyList >= 3
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL )
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage
					npcMostDangerousEnemy = npcEnemy
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy, "W-Battle"..J.Chat.GetNormName( npcMostDangerousEnemy )
		end

	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange - 60 )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsAttacking( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "W-attack:"..J.Chat.GetNormName( botTarget )
		end
	end

	for _, npcAlly in pairs( hAllyList )
	do
		if J.IsValidHero( npcAlly )
			and J.IsRetreating( npcAlly )
			and J.IsRunning( npcAlly )
			and npcAlly:WasRecentlyDamagedByAnyHero( 4.0 )
		then
			local nNearbyEnemyList = J.GetEnemyList( npcAlly, 1000 )
			if #nNearbyEnemyList >= 2
			then
				for _, npcEnemy in pairs( hEnemyList )
				do
					if J.IsValidHero( npcEnemy )
						and J.IsInRange( npcAlly, npcEnemy, npcEnemy:GetAttackRange() + 60 )
						and ( npcEnemy:GetAttackTarget() == npcAlly
								or J.IsInRange( npcAlly, npcEnemy, 500 ) )
					then
						return BOT_ACTION_DESIRE_HIGH, npcAlly, "W-protect:"..J.Chat.GetNormName( npcAlly )
					end
				end
			else
				local npcEnemy = nNearbyEnemyList[1]
				if J.IsValidHero( npcEnemy )
					and J.IsInRange( bot, npcEnemy, nCastRange )
					and J.CanCastOnNonMagicImmune( npcEnemy )
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, "W-Retreat:"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nSkillLV = abilityE:GetLevel()
	local nCastRange = abilityE:GetCastRange() + aetherRange
	local nRadius 	 = abilityE:GetSpecialValueInt( 'radius' )
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nDamage = abilityE:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )

	local vCastLocation = J.GetLocationTowardDistanceLocation( bot, J.GetTeamFountain(), nCastRange * 0.8 )

	if J.IsInTeamFight( bot, 1400 )
	then
		if #nInRangeEnemyList >= 2
		then
			local vEnemyCenter = J.GetCenterOfUnits( nInRangeEnemyList )
			if J.GetLocationToLocationDistance( vCastLocation, vEnemyCenter ) < nRadius - 300
			then
				return BOT_ACTION_DESIRE_HIGH, vCastLocation, "E-Battle"
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInLocRange( botTarget, vCastLocation, nRadius - 500 )
			and ( botTarget:IsFacingLocation( bot:GetLocation(), 50 )
				  or J.IsInLocRange( botTarget, vCastLocation, 800 ) )
			and J.CanCastOnNonMagicImmune( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, vCastLocation, "E-Attack:"..J.Chat.GetNormName( botTarget )
		end
	end

	if J.IsRetreating( bot ) and nLV >= 8
	then
		local vCastLocation = J.GetFaceTowardDistanceLocation( bot, nCastRange )
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.IsInLocRange( npcEnemy, vCastLocation, nRadius - 400 )
			then
				return BOT_ACTION_DESIRE_HIGH, vCastLocation, "E-Retreat:"..J.Chat.GetNormName( npcEnemy )
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local nInWardRangeEnemyList = bot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE )

	if J.IsInTeamFight( bot, 1400 )
	and J.HasAghanimsShard(bot)
	then
		if #nInWardRangeEnemyList >= 2
		then
			local nAllyUnits = GetUnitList(UNIT_LIST_ALLIES)

			for _, a in pairs(nAllyUnits)
			do
				if (string.find(a:GetUnitName(), "nether_ward"))
				and J.IsInRange(bot, a, nCastRange)
				then
					return BOT_ACTION_DESIRE_HIGH, a, "Nether Ward"..J.Chat.GetNormName( botTarget )
				end
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "R-Attack:"..J.Chat.GetNormName( botTarget )
		end
	end

	if J.IsRetreating( bot )
	then
		local nAttackAllyList = bot:GetNearbyHeroes( 1400, false, BOT_MODE_ATTACK )
		local nDefendAllyList = bot:GetNearbyHeroes( 1600, false, BOT_MODE_DEFEND_ALLY )
		if #nAttackAllyList >= 1
			or #nDefendAllyList >= 1
			or #hEnemyList <= 1
		then
			for _, npcEnemy in pairs( nInRangeEnemyList )
			do
				if J.IsValidHero( npcEnemy )
					and J.IsInRange( bot, npcEnemy, nCastRange -100 )
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and J.CanCastOnTargetAdvanced( npcEnemy )
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, "R-Retreat:"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592..




