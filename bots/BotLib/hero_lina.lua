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
						{--pos1
							['t25'] = {10, 0},
							['t20'] = {10, 0},
							['t15'] = {0, 10},
							['t10'] = {0, 10},
						},
						{--pos2
							['t25'] = {0, 10},
							['t20'] = {0, 10},
							['t15'] = {10, 0},
							['t10'] = {10, 0},
						}
}

local tAllAbilityBuildList = {
						{2,3,3,1,3,6,3,2,2,2,6,1,1,1,6},--pos1
						{1,3,1,2,1,6,1,2,2,2,6,3,3,3,6},--pos2
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_2"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
else
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
end

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_crystal_maiden_outfit",
	"item_cyclone",
	"item_force_staff",
	"item_black_king_bar",
	"item_hurricane_pike",
	"item_bloodthorn",
	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_wind_waker",
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_monkey_king_bar",
}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",

    "item_bottle",
    "item_boots",
    "item_magic_wand",

	"item_arcane_boots",
	"item_orchid",
	"item_black_king_bar",--
	"item_bloodthorn",--
	"item_maelstrom",
	"item_gungir",--
	"item_invis_sword",
	"item_silver_edge",--
	"item_sheepstick",--
	"item_moon_shard",
	"item_travel_boots",
	"item_travel_boots_2",--
	"item_ultimate_scepter",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_3'] = {
	"item_tango",
	"item_double_branches",
	"item_faerie_fire",

	"item_bottle",
	"item_null_talisman",
	"item_boots",
	"item_magic_wand",
	"item_travel_boots",
	"item_aether_lens",--
	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_black_king_bar",--
	"item_ethereal_blade",--
	"item_octarine_core",--
	"item_sheepstick",--
	"item_ultimate_scepter_2",
	"item_travel_boots_2",--
	"item_moon_shard",
}

sRoleItemsBuyList['pos_4'] = {
	
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

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_4']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_bottle",
	"item_null_talisman",
	"item_magic_wand",
	"item_ultimate_scepter",
	"item_magic_wand",
	"item_arcane_boots",
	"item_cyclone",
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


npc_dota_hero_lina


"Ability1"		"lina_dragon_slave"
"Ability2"		"lina_light_strike_array"
"Ability3"		"lina_fiery_soul"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"lina_laguna_blade"
"Ability10"		"special_bonus_attack_damage_30"
"Ability11"		"special_bonus_cast_range_125"
"Ability12"		"special_bonus_hp_350"
"Ability13"		"special_bonus_unique_lina_3"
"Ability14"		"special_bonus_spell_amplify_14"
"Ability15"		"special_bonus_unique_lina_2"
"Ability16"		"special_bonus_unique_lina_1"
"Ability17"		"special_bonus_attack_range_175"


modifier_lina_light_strike_array
modifier_lina_fiery_soul
modifier_lina_laguna_blade


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local FlameCloak = bot:GetAbilityByName( 'lina_flame_cloak' )
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent4 = bot:GetAbilityByName( sTalentList[4] )
local talent7 = bot:GetAbilityByName( sTalentList[7] )

local castQDesire, castQLocation
local castWDesire, castWLocation
local castRDesire, castRTarget
local FlameCloakDesire


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local talent4Damage = 0



function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end


	nKeepMana = 400
	aetherRange = 0
	talent4Damage = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )



	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end
--	if talent2:IsTrained() then aetherRange = aetherRange + talent2:GetSpecialValueInt( "value" ) end
	if talent4:IsTrained() then talent4Damage = talent4Damage + talent4:GetSpecialValueInt( "value" ) end

	FlameCloakDesire = X.ConsiderFlameCloak()
	if (FlameCloakDesire > 0)
	then
		bot:Action_UseAbility(FlameCloak)
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


	castQDesire, castQLocation, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return
	end

	castWDesire, castWLocation, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
	end


end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( "AbilityDamage" )
	local nRadius = abilityQ:GetSpecialValueInt( "dragon_slave_width_end" )
	local nDamageType = DAMAGE_TYPE_MAGICAL

	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange -80, true, BOT_MODE_NONE )
	local nTargetLocation = nil

	--击杀
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
		then
			nTargetLocation = npcEnemy:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q击杀'..J.Chat.GetNormName( npcEnemy )
		end
	end

	--消耗
	local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius + 50, 0, 0 )
	if nCanHurtEnemyAoE.count >= 3 and bot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		nTargetLocation = nCanHurtEnemyAoE.targetloc
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q消耗'
	end


	--对线消耗或补刀
	if J.IsLaning( bot )
	then
		--对线消耗
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange -80, nRadius, 2 )
		if nAoeLoc ~= nil and nMP > 0.58
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q对线消耗'
		end

		--对线补刀
		if #hAllyList == 1 and nMP > 0.38
		then
			local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0, nDamage )
			if locationAoEKill.count >= 3
			then
				nTargetLocation = locationAoEKill.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q对线补刀"..locationAoEKill.count
			end
		end
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


	--打架时先手
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange -80 )
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHP( botTarget ) < 0.38
			then
				nTargetLocation = botTarget:GetExtrapolatedLocation( nCastPoint )
				if J.IsInLocRange( bot, nTargetLocation, nCastRange )
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q打架'..J.Chat.GetNormName( botTarget )
				end
			end
		end
	end


	--撤退前加速
	if J.IsRetreating( bot ) and not bot:HasModifier( 'modifier_lina_fiery_soul' )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 20 )
			then
				nTargetLocation = npcEnemy:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q撤退'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--打钱
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
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q打钱"..locationAoE.count
			end
		end
	end


	--推进时对小兵用
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and nSkillLV >= 2 and DotaTime() > 8 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1400, true )
		if #laneCreepList >= 3
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage )
			if locationAoEKill.count >= 2
	 			and #hAllyList == 1
			then
				nTargetLocation = locationAoEKill.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q带线1"..locationAoEKill.count
			end

			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0, 0 )
			if ( locationAoEHurt.count >= 3 and #laneCreepList >= 4 )
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q带线2"..locationAoEHurt.count
			end
		end
	end


	--打肉的时候输出
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 400
	then
		if J.IsRoshan( botTarget ) and J.GetHP( botTarget ) > 0.15
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			nTargetLocation = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q肉山'
		end
	end



	--通用消耗敌人或受到伤害时保护自己
	if ( #hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 15 and false --there be bug
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy ) 
				and J.IsInRange( bot, npcEnemy, nCastRange - 200 )
			then
				nTargetLocation = npcEnemy:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q通用'
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

--核心函数
--J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius, nTime )
function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + aetherRange
	local nCastPoint = abilityW:GetCastPoint() + 0.5
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetSpecialValueInt( 'light_strike_array_damage' ) + talent4Damage
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius 	 = abilityW:GetSpecialValueInt( "light_strike_array_aoe" )

	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange + nRadius * 0.5, true, BOT_MODE_NONE )

	local nTargetLocation = nil


	--击杀和打断
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then
			--打断
			if npcEnemy:IsChanneling()
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius, nCastPoint )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W打断"..J.Chat.GetNormName( npcEnemy )
				end
			end

			--击杀
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius, nCastPoint + 0.2 )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W击杀"..J.Chat.GetNormName( npcEnemy )
				end
			end

		end


	end


	--消耗
	local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius + 20, 0, 0 )
	if nCanHurtEnemyAoE.count >= 3
	then
		nTargetLocation = nCanHurtEnemyAoE.targetloc
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'W消耗'
	end



	--团战
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'W团战'
		end
	end


	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange -30 )
		then
			nTargetLocation = J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius, nCastPoint + 0.3 )
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W打架"..J.Chat.GetNormName( botTarget )
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange -100, nRadius -20, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'W撤退1'
		end

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 ) or bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_VERYHIGH )
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius, nCastPoint + 0.3 )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W撤退2"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end


	--自保
	if bot:WasRecentlyDamagedByAnyHero( 3.0 ) and nLV >= 10
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nInRangeEnemyList >= 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy ) 
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 45 )
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius -30, nCastPoint + 0.3 )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W自保"..J.Chat.GetNormName( npcEnemy )
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
			local nShouldHurtCount = nMP > 0.6 and 3 or 4
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W打钱"..locationAoE.count
			end
		end
	end

	--带线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and nSkillLV >= 3 and DotaTime() > 9 * 60
		and #hAllyList <= 1 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nCastRange + 200, true )
		if #laneCreepList >= 4
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, nDamage )
			if locationAoEKill.count >= 3
			then
				nTargetLocation = locationAoEKill.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W带线1"..locationAoEKill.count
			end

			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0.5, 0 )
			if locationAoEHurt.count >= 4
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W带线2"..locationAoEHurt.count
			end
		end
	end

	--肉山
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 600
	then
		if J.IsRoshan( botTarget ) and J.GetHP( botTarget ) > 0.3
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			nTargetLocation = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'W肉山'
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
	local nDamage = abilityR:GetSpecialValueInt( "damage" )
	local nDamageType = bot:HasScepter() and DAMAGE_TYPE_PURE or DAMAGE_TYPE_MAGICAL


	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange + 80, true, BOT_MODE_NONE )
	local nInBonusEnemyList = J.GetNearbyHeroes(bot, nCastRange + 240, true, BOT_MODE_NONE )


	--击杀
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and not J.IsHaveAegis( npcEnemy )
			and X.CanCastAbilityROnTarget( npcEnemy )
		then
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint + 0.25 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'R击杀'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end

	--团战对最弱的敌人
	if J.IsInTeamFight( bot, 600 )
		or ( nHP < 0.3 and nSkillLV >= 2 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and X.CanCastAbilityROnTarget( npcEnemy )
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				if ( npcEnemyHealth < npcWeakestEnemyHealth )
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = npcEnemy
				end
			end
		end

		if ( npcWeakestEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy, 'R团战'..J.Chat.GetNormName( npcWeakestEnemy )
		end

	end


	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and X.CanCastAbilityROnTarget( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 100 )
		then
			if J.WillMagicKillTarget( bot, botTarget, nDamage * 1.88, nCastPoint + 0.25 )
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget, "R打架"..J.Chat.GetNormName( botTarget )
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.CanCastAbilityROnTarget( nTarget )

	if J.CanCastOnTargetAdvanced( nTarget )
		and not nTarget:HasModifier( "modifier_arc_warden_tempest_double" )
	then
		if bot:HasScepter()
		then
			return J.CanCastOnMagicImmune( nTarget )
		else
			return J.CanCastOnNonMagicImmune( nTarget )
		end
	end

	return false

end

function X.ConsiderFlameCloak()
	if not FlameCloak:IsTrained()
	or not FlameCloak:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nAttackRange = bot:GetAttackRange()
	local nEnemyHeroes = J.GetNearbyHeroes(bot,nAttackRange, true, BOT_MODE_NONE)
	local nAlliedHeroes = J.GetNearbyHeroes(bot,nAttackRange, false, BOT_MODE_NONE)

	if J.IsRetreating(bot)
	and (nEnemyHeroes ~= nil and nAlliedHeroes ~= nil and #nEnemyHeroes >= #nAlliedHeroes)
	and not J.WeAreStronger(bot, nAttackRange)
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsGoingOnSomeone(bot)
	and (nEnemyHeroes ~= nil and #nEnemyHeroes >= 2)
	then
		local botTarget = bot:GetTarget()

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
-- dota2jmz@163.com QQ:2462331592..

