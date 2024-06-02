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
						{1,3,3,2,3,6,3,1,1,1,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",
	"item_blood_grenade",

	"item_tranquil_boots",
	"item_magic_wand",
	"item_aghanims_shard",
	"item_aether_lens",--
	"item_glimmer_cape",--
	"item_ultimate_scepter",
	"item_boots_of_bearing",--
	"item_force_staff",--
	"item_aeon_disk",--
	"item_wind_waker",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",
	"item_blood_grenade",

	"item_arcane_boots",
	"item_magic_wand",
	"item_aghanims_shard",
	"item_aether_lens",--
	"item_glimmer_cape",--
	"item_guardian_greaves",--
	"item_force_staff",--
	"item_ultimate_scepter",
	"item_aeon_disk",--
	"item_wind_waker",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_4']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_4']

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
else
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
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_lion

"Ability1"		"lion_impale"
"Ability2"		"lion_voodoo"
"Ability3"		"lion_mana_drain"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"lion_finger_of_death"
"Ability10"		"special_bonus_cast_range_100"
"Ability11"		"special_bonus_attack_damage_90"
"Ability12"		"special_bonus_unique_lion_3"
"Ability13"		"special_bonus_gold_income_25"
"Ability14"		"special_bonus_hp_500"
"Ability15"		"special_bonus_unique_lion"
"Ability16"		"special_bonus_unique_lion_2"
"Ability17"		"special_bonus_unique_lion_4"

modifier_lion_impale
modifier_lion_voodoo
modifier_lion_mana_drain
modifier_lion_finger_of_death_kill_counter
modifier_lion_finger_of_death
modifier_lion_finger_of_death_delay
modifier_lion_arcana_kill_effect

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent4 = bot:GetAbilityByName( sTalentList[4] )
local talent5 = bot:GetAbilityByName( sTalentList[5] )
local talent8 = bot:GetAbilityByName( sTalentList[8] )

local castQDesire, castQLocation
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local lastCastQTime = -99


function X.SkillsComplement()

	if X.ConsiderStopDrain() > 0
	then
		bot:Action_ClearActions( true )
		return
	end

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )

	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end
--	if talent4:IsTrained() then aetherRange = aetherRange + talent4:GetSpecialValueInt( "value" ) end
	

	castEDesire, castETarget, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		bot:Action_ClearActions( false )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
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
		lastCastQTime = DotaTime()
		return
	end


	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		if talent8:IsTrained()
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		end
		return
	end


end

function X.ConsiderStopDrain()

	if X.IsAbilityEChanneling()
		and J.IsRetreating( bot )
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	return BOT_ACTION_DESIRE_NONE

end


function X.IsAbilityEChanneling()

	if bot:IsChanneling()
	then
		local nEnemyCreepList = bot:GetNearbyCreeps( 1200, true )
		for _, nCreep in pairs( nEnemyCreepList )
		do
			if nCreep:HasModifier( "modifier_lion_mana_drain" )
			then
				return true
			end
		end

		local nEnemyHeroList = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( nEnemyHeroList )
		do
			if npcEnemy:HasModifier( "modifier_lion_mana_drain" )
			then
				return true
			end
		end
	end

	return false

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange + 20
	local nRadius	 = abilityQ:GetSpecialValueInt( "width" )
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local nInBonusEnemyList = J.GetNearbyHeroes(bot, nCastRange + 200, true, BOT_MODE_NONE )

	local nTargetLocation = nil

	--击杀
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, 5.0 )
		then
			nTargetLocation = npcEnemy:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-击杀'..J.Chat.GetNormName( npcEnemy )
		end
	end

	--Aoe
	local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius + 10, 0, 0 )
	if nCanHurtEnemyAoE.count >= 3
	then
		nTargetLocation = nCanHurtEnemyAoE.targetloc
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-Aoe:'..( nCanHurtEnemyAoE.count )
	end

	--团战
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius + 20, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-团控'
		end
	end


	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 300 )
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHP( botTarget ) < 0.5
			then
				local nDelayTime = nCastPoint + GetUnitToUnitDistance( bot, botTarget )/1600
				nTargetLocation = J.GetDelayCastLocation( bot, botTarget, nCastRange, 260, nDelayTime )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-攻击:'..J.Chat.GetNormName( botTarget )
				end
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) or bot:GetActiveModeDesire() > 0.7 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				nTargetLocation = npcEnemy:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-撤退:'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--Farm
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, 1000 )
			and bot:IsFacingLocation( botTarget:GetLocation(), 45 )
			and ( botTarget:GetMagicResist() < 0.4 or nMP > 0.9 )
		then
			local nShouldHurtCount = nMP > 0.6 and 3 or 4
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, 200, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q-打钱:"..locationAoE.count
			end
		end
	end


	--Push
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and nSkillLV >= 4 and DotaTime() > 9 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
		and not bot:HasScepter()
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1300, true )
		if #laneCreepList >= 5
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 90, 0, 0 )
			if locationAoEHurt.count >= 3
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q-推线"..locationAoEHurt.count
			end
		end
	end


	--Roshan
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 900
	then
		if J.IsRoshan( botTarget ) and J.GetHP( botTarget ) > 0.15
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			nTargetLocation = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end
	end


	--常规
	if ( #hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 15
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy ) 
				and J.IsInRange( bot, npcEnemy, nCastRange )
			then
				nTargetLocation = npcEnemy:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-常规'
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()


	if not abilityW:IsFullyCastable()
		or lastCastQTime > DotaTime() - 0.8
	then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + aetherRange
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local nInBonusEnemyList = J.GetNearbyHeroes(bot, nCastRange + 300, true, BOT_MODE_NONE )

	--打断
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and ( J.CanCastOnTargetAdvanced( npcEnemy ) or talent8:IsTrained() )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then
			if npcEnemy:IsChanneling()
			then
				if talent8:IsTrained()
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation(), 'W-打断吟唱:'..J.Chat.GetNormName( npcEnemy )
				else
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'W-打断吟唱:'..J.Chat.GetNormName( npcEnemy )
				end
			end

			if npcEnemy:IsCastingAbility()
				and J.IsInRange( bot, npcEnemy, nCastRange + 50 )
			then
				if talent8:IsTrained()
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation(), 'W-打断施法:'..J.Chat.GetNormName( npcEnemy )
				else
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'W-打断施法:'..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end


	--团战中对最强的敌人使用
	if J.IsInTeamFight( bot, 1200 )
		and ( #nInBonusEnemyList >= 2 or #hAllyList >= 3 )
	then

		if talent8:IsTrained()
		then
			local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, 250, 2 )
			if nAoeLoc ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nAoeLoc, 'W-团控'
			end
		end


		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and ( J.CanCastOnTargetAdvanced( npcEnemy ) or talent8:IsTrained() )
				and not J.IsDisabled( npcEnemy )
				and not J.IsTaunted( npcEnemy )
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

		if npcMostDangerousEnemy ~= nil
			and J.IsInRange( bot, npcMostDangerousEnemy, nCastRange + 50 )
		then
			if talent8:IsTrained()
			then
				return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy:GetLocation(), 'W-团战:'..J.Chat.GetNormName( npcMostDangerousEnemy )
			else
				return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy, 'W-团战:'..J.Chat.GetNormName( npcMostDangerousEnemy )
			end
		end

	end


	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and ( J.CanCastOnTargetAdvanced( botTarget ) or talent8:IsTrained() )
			and J.IsInRange( bot, botTarget, nCastRange + 150 )
			and not J.IsDisabled( botTarget )
			and not J.IsTaunted( botTarget )
			and not botTarget:IsDisarmed()
		then
			if talent8:IsTrained()
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), 'W-进攻:'..J.Chat.GetNormName( botTarget )
			else
				return BOT_ACTION_DESIRE_HIGH, botTarget, 'W-进攻:'..J.Chat.GetNormName( botTarget )
			end
		end
	end


	--保护自己
	if bot:WasRecentlyDamagedByAnyHero( 3.0 ) and nLV >= 10
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nInRangeEnemyList >= 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and ( J.CanCastOnTargetAdvanced( npcEnemy ) or talent8:IsTrained() )
				and not J.IsDisabled( npcEnemy )
				and not J.IsTaunted( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				if talent8:IsTrained()
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation(), 'W-保护自己:'..J.Chat.GetNormName( npcEnemy )
				else
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'W-保护自己'
				end
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
						or GetUnitToUnitDistance( bot, npcEnemy ) <= 600 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and ( J.CanCastOnTargetAdvanced( npcEnemy ) or talent8:IsTrained() )
				and not J.IsDisabled( npcEnemy )
				and not J.IsTaunted( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				if talent8:IsTrained()
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation(), 'W-撤退:'..J.Chat.GetNormName( npcEnemy )
				else
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, "W-撤退:"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end

	--roshan
	if J.IsDoingRoshan( bot ) and nMP > 0.6
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
		then
			if talent8:IsTrained()
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), 'W-肉山:'..J.Chat.GetNormName( botTarget )
			else
				return BOT_ACTION_DESIRE_HIGH, botTarget, "W-肉山"
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nSkillLV = abilityE:GetLevel()
	local nCastRange = abilityE:GetCastRange() + aetherRange
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nDamage = abilityE:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	local nDuration = abilityE:GetSpecialValueFloat( 'duration' )
	local nManaDrain = abilityE:GetSpecialValueInt( 'mana_per_second' ) * nDuration
	local nLostMana = bot:GetMaxMana() - bot:GetMana()

	local nEnemyTowers = bot:GetNearbyTowers( 1000, true )

	--缺蓝的时候抽蓝
	if #hEnemyList == 0 and #nEnemyTowers == 0
		and not J.IsRetreating( bot )
		and not bot:WasRecentlyDamagedByAnyHero( 2.0 )
		and ( nLostMana > nManaDrain + bot:GetManaRegen() * nDuration + 50
				or nLostMana > 500 )
	then
		local nEnemyCreepList = bot:GetNearbyCreeps( 1600, true )
		for _, nCreep in pairs( nEnemyCreepList )
		do
			if J.IsValid( nCreep )
				and ( nCreep:GetMana() > nManaDrain * 0.8 or nCreep:GetMana() > 349 )
				and J.CanCastOnNonMagicImmune( nCreep )
			then
				return BOT_ACTION_DESIRE_HIGH, nCreep, 'E-补篮'
			end
		end
	end


	--秒杀幻像
	if #hEnemyList >= 1
	then
		local nTargetIllusion = nil
		local nMaxHealth = 0
		local nIllusionCount = 0
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and npcEnemy:GetUnitName() ~= "npc_dota_hero_chaos_knight"
				and npcEnemy:GetUnitName() ~= "npc_dota_hero_vengefulspirit"
				and J.IsInRange( npcEnemy, bot, nCastRange + 300 )
				and J.IsSuspiciousIllusion( npcEnemy )
			then
				nIllusionCount = nIllusionCount + 1
				if npcEnemy:GetHealth() > nMaxHealth
				then
					nTargetIllusion = npcEnemy
					nMaxHealth = npcEnemy:GetHealth()
				end
			end
		end

		if nTargetIllusion ~= nil
			and ( nIllusionCount >= 2 or J.GetHP( nTargetIllusion ) > 0.9 )
		then
			return BOT_ACTION_DESIRE_HIGH, nTargetIllusion, 'E-清理幻像:'..J.Chat.GetNormName( nTargetIllusion )
		end
	end


	if X.IsOtherAbilityFullyCastable() or nSkillLV <= 1 then return 0 end

	--团战吸蓝
	if J.IsInTeamFight( bot, 1000 )
	then
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.IsInRange( bot, npcEnemy, nCastRange )
				and not npcEnemy:HasModifier( "modifier_lion_finger_of_death" )
				and npcEnemy:GetMana() > 200
				and J.CanCastOnMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and ( not J.IsValidHero( botTarget ) or not X.MayKillTarget( botTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'E-团战吸篮:'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--打架抽蓝
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and not botTarget:HasModifier( "modifier_lion_finger_of_death" )
			and botTarget:GetMana() > 200
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and not J.IsDisabled( botTarget )
			and not X.MayKillTarget( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'E-抽篮:'..J.Chat.GetNormName( botTarget )
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nRadius	 = 0
	local nCastRange = abilityR:GetCastRange() + aetherRange
	if nCastRange > 1200 then nCastRange = 1200 end
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamageBonus = X.GetAbilityRDamageBonus()
	local nRawDamage = 475 + 125 * nSkillLV
	if bot:HasScepter()
	then
		nRadius = abilityR:GetSpecialValueInt( 'splash_radius_scepter' )
		nRawDamage = 575 + 125 * nSkillLV
	end

	local nDamage = nRawDamage + nDamageBonus
	local nDamageType = DAMAGE_TYPE_MAGICAL

	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local nInBonusEnemyList = J.GetNearbyHeroes(bot, nCastRange + 400, true, BOT_MODE_NONE )

	--击杀
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
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
		or ( nHP < 0.4 and nSkillLV >= 2 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, npcEnemy in pairs( nInBonusEnemyList )
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

		if npcWeakestEnemy ~= nil
			and J.WillMagicKillTarget( bot, npcWeakestEnemy, nDamage , nCastPoint + 0.25 )
		then
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy, 'R团战'..J.Chat.GetNormName( npcWeakestEnemy )
		end

		--有A后的团战Aoe
		if bot:HasScepter()
		then
			local hNearbyEnemyList = J.GetEnemyList( bot, nCastRange + nRadius + 200 )
			local nMaxAoeCount = 1
			local nBestAoeEnemy = nil
			for _, npcEnemy in pairs( nInBonusEnemyList )
			do
				if J.IsValidHero( npcEnemy )
					and J.IsInRange( bot, npcEnemy, nCastRange + 150 )
					and not npcEnemy:IsMagicImmune()
					and not npcEnemy:IsInvulnerable()
				then
					local nAoeCount = 0
					for _, nEnemy in pairs( hNearbyEnemyList )
					do
						if J.IsInRange( npcEnemy, nEnemy, nRadius )
							and not nEnemy:IsMagicImmune()
							and not nEnemy:IsInvulnerable()
						then
							nAoeCount = nAoeCount + 1
						end
					end
					if nAoeCount > nMaxAoeCount
					then
						nMaxAoeCount = nAoeCount
						nBestAoeEnemy = npcEnemy
					end
				end
			end

			if nBestAoeEnemy ~= nil
				and ( nMaxAoeCount >= 4
					or ( nMaxAoeCount >= 3 and nHP < 0.46 ) )
			then
				return BOT_ACTION_DESIRE_HIGH, nBestAoeEnemy, 'R团战Aoe:'..J.Chat.GetNormName( nBestAoeEnemy )
			end
		end

	end


	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 200 )
			and X.CanCastAbilityROnTarget( botTarget )
		then
			if J.WillMagicKillTarget( bot, botTarget, nDamage , nCastPoint + 0.25 ) or ( nHP < 0.2 and nSkillLV >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget, "R打架"..J.Chat.GetNormName( botTarget )
			end
		end
	end





	--撤退
	if J.IsRetreating( bot ) and nSkillLV >= 2
		and nHP < 0.3 and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and X.CanCastAbilityROnTarget( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "R死前大"..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--带线
	if bot:HasScepter()
		and ( J.IsPushing( bot ) or J.IsFarming( bot ) or J.IsDefending( bot ) )
		and nSkillLV >= 3
		and #hEnemyList == 0
		and #hAllyList <= 2
	then
		local nEnemyCreepList = bot:GetNearbyLaneCreeps( 1200, true )
		if #nEnemyCreepList >= 5
			and not nEnemyCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local nMaxAoeCount = 4
			local nBestCreep = nil
			for _, nCreep in pairs( nEnemyCreepList )
			do
				local nAoeCount = J.GetNearbyAroundLocationUnitCount( true, false, nRadius, nCreep:GetLocation() )
				if nAoeCount > nMaxAoeCount
				then
					nBestCreep = nCreep
					nMaxAoeCount = nAoeCount
				end
			end
			if nBestCreep ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nBestCreep, "R-带线"
			end
		end
	end

	--roshan
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 1300
		and bot:HasScepter()
	then
		if J.IsRoshan( botTarget ) and J.GetHP( botTarget ) > 0.2
			and J.IsInRange( bot, botTarget, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE


end


function X.GetAbilityRDamageBonus()

	local nTalantDamage = talent5:IsTrained() and talent5:GetSpecialValueInt( 'value' ) or 0
	local nDamageBonus = abilityR:GetSpecialValueInt( 'damage_per_kill' ) + nTalantDamage
	local sModifierName = "modifier_lion_finger_of_death_kill_counter"
	local nModifierCount = J.GetModifierCount( bot, sModifierName )
	

	return nModifierCount * nDamageBonus

end


function X.CanCastAbilityROnTarget( nTarget )

	if J.CanCastOnTargetAdvanced( nTarget )
		and not nTarget:HasModifier( "modifier_arc_warden_tempest_double" )
		and not J.IsHaveAegis( nTarget )
	then
		return J.CanCastOnNonMagicImmune( nTarget )
	end

	return false

end


function X.IsOtherAbilityFullyCastable()

	return abilityQ:IsFullyCastable() or abilityW:IsFullyCastable() or abilityR:IsFullyCastable()

end


function X.MayKillTarget( nTarget )

	if nTarget:HasModifier( "modifier_lion_finger_of_death" )
	then
		return true
	end

	local nDamageToTarget = bot:GetEstimatedDamageToTarget( true, botTarget, 9.0, DAMAGE_TYPE_PHYSICAL )
	if J.CanKillTarget( botTarget, nDamageToTarget, DAMAGE_TYPE_PHYSICAL )
	then
		return true
	end

	return false

end

return X
-- dota2jmz@163.com QQ:2462331592..
