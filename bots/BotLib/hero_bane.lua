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
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,3,2,1,2,6,2,3,3,3,6,1,1,1,6},
						{2,3,2,1,2,6,2,1,1,1,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_crystal_maiden_outfit",
	"item_point_booster",
--	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_shadow_amulet",
	"item_rod_of_atos",
	"item_invis_sword", 
	"item_black_king_bar",
	"item_silver_edge",
	"item_shivas_guard",
	"item_gungir",
	"item_mystic_staff",
	"item_ultimate_scepter_2",
	"item_sheepstick",


}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = {

	"item_priest_outfit",
	"item_mekansm",
	"item_shadow_amulet",
--	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
	"item_glimmer_cape",
--	"item_wraith_pact",
	"item_shivas_guard",
	"item_mystic_staff",
	"item_sheepstick",
	"item_ultimate_scepter_2",

}

tOutFitList['outfit_mage'] = {

	"item_mage_outfit",
	"item_ancient_janggo",
	"item_glimmer_cape",
	"item_boots_of_bearing",
	"item_pipe",
--	"item_aghanims_shard",
	"item_veil_of_discord",
	"item_ultimate_scepter",	
	"item_wind_waker",
	"item_mystic_staff",
	"item_ultimate_scepter_2",
	"item_sheepstick",

}

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_veil_of_discord",
	"item_magic_wand",
	
	"item_vladmir",
	"item_magic_wand",
	
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

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


npc_dota_hero_bane


"Ability1"		"bane_nightmare"
"Ability2"		"bane_brain_sap"
"Ability3"		"bane_enfeeble"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"bane_fiends_grip"
"Ability7"		"bane_nightmare_end"
"Ability10"		"special_bonus_armor_6"
"Ability11"		"special_bonus_magic_resistance_15"
"Ability12"		"special_bonus_spell_amplify_7"
"Ability13"		"special_bonus_cast_range_125"
"Ability14"		"special_bonus_unique_bane_5"
"Ability15"		"special_bonus_movement_speed_40"
"Ability16"		"special_bonus_unique_bane_2"
"Ability17"		"special_bonus_unique_bane_3"


modifier_bane_enfeeble
modifier_bane_nightmare
modifier_bane_nightmare_invulnerable
modifier_bane_fiends_grip
modifier_bane_fiends_grip_self


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent4 = bot:GetAbilityByName( sTalentList[4] )
local talent7 = bot:GetAbilityByName( sTalentList[7] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local talent7Damage = 0

local abilityWFirstType = nil


function X.SkillsComplement()

	if abilityWFirstType == nil
		and abilityW:IsTrained()
	then
		abilityWFirstType = abilityW:GetTargetType()
	end


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 120
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end
--	if talent4:IsTrained() then aetherRange = aetherRange + talent4:GetSpecialValueInt( "value" ) end
	if talent7:IsTrained() then talent7Damage = talent7:GetSpecialValueInt( "value" ) end

	
	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end

	

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if castWDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		if abilityWFirstType ~= nil
			and abilityWFirstType ~= abilityW:GetTargetType()
		then
			bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget:GetLocation() )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		end
		return
	end


	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		J.SetQueueToInvisible( bot )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return
	end

	
	castEDesire, castETarget, sMotive = X.ConsiderE()
	if castEDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end
	



end

--虚弱 'modifier_bane_enfeeble'
function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nSkillLV = abilityE:GetLevel()
	local nCastRange = abilityE:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nDamage = abilityE:GetSpecialValueInt( 'damage' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil


	--打断
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			if npcEnemy:IsChanneling()
			then
				hCastTarget = npcEnemy
				sCastMotive = 'E-打断'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end



	--撤退时保护自己
	if J.IsRetreating( bot )
		and ( bot:WasRecentlyDamagedByAnyHero( 3.0 ) or bot:GetActiveModeDesire() > 0.7 )
	then
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				hCastTarget = npcEnemy
				sCastMotive = 'E-撤退'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--团战中对最能输出的人使用
	if J.IsInTeamFight( bot, 1200 ) 
	then
		local npcStrongestEnemy = nil
		local nStrongestPower = 0
		local nEnemyCount = 0
		
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				nEnemyCount = nEnemyCount + 1
				if J.CanCastOnTargetAdvanced( npcEnemy )
					and not J.IsDisabled( npcEnemy )
					and not npcEnemy:IsDisarmed()
				then
					local npcEnemyPower = npcEnemy:GetEstimatedDamageToTarget( true, bot, 6.0, DAMAGE_TYPE_ALL )
					if ( npcEnemyPower > nStrongestPower )
					then
						nStrongestPower = npcEnemyPower
						npcStrongestEnemy = npcEnemy
					end
				end
			end
		end

		if npcStrongestEnemy ~= nil and nEnemyCount >= 2
			and J.IsInRange( bot, npcStrongestEnemy, nCastRange + 150 )
		then
			hCastTarget = npcStrongestEnemy
			sCastMotive = 'E-团战控制'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--打架时对目标之外的人或目标使用
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, 1200 )
		then
			for _, npcEnemy in pairs( nInRangeEnemyList )
			do
				if J.IsValid( npcEnemy )
					and npcEnemy:GetPlayerID() ~= botTarget:GetPlayerID()
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and J.CanCastOnTargetAdvanced( npcEnemy )
					and not J.IsDisabled( npcEnemy )
					and not npcEnemy:IsDisarmed()
				then
					hCastTarget = npcEnemy
					sCastMotive = 'E-睡眠:'..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
			
			if J.IsInRange( bot, botTarget, nCastRange )
				and not J.IsInRange( bot, botTarget, 530 )
				and J.IsRunning( botTarget )
				and bot:IsFacingLocation( botTarget:GetLocation(), 20 )
				and not botTarget:IsFacingLocation( bot:GetLocation(), 150 )
				and J.CanCastOnNonMagicImmune( botTarget )
				and J.CanCastOnTargetAdvanced( botTarget )
			then
				local allyList = botTarget:GetNearbyHeroes( 500, true, BOT_MODE_NONE )
				if #allyList == 0
				then
					hCastTarget = botTarget
					sCastMotive = 'E-留人'..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetSpecialValueInt( 'brain_sap_damage' ) + talent7Damage
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil

	local nLostHealth = bot:GetMaxHealth() - bot:GetHealth()


	--对线时回血并补刀远程兵


	--击杀敌人
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'W-击杀敌人'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end

		end
	end


	--7级以下如果不能给自己恢复对应的生命值则先不用
	if nLV <= 7 and nMP < 0.72
		and nLostHealth < nDamage * 0.8
	then return BOT_ACTION_DESIRE_NONE end

	--团战中对最弱的敌人使用
	if J.IsInTeamFight( bot, 1200 )
	then
		local nWeakestEnemy = nil
		local nWeakestEnemyHealth = 99999

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				if ( npcEnemyHealth < nWeakestEnemyHealth )
				then
					nWeakestEnemyHealth = npcEnemyHealth
					nWeakestEnemy = npcEnemy
				end
			end
		end

		if ( nWeakestEnemy ~= nil )
		then
			hCastTarget = nWeakestEnemy
			sCastMotive = 'W-团战最弱'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--进攻敌人
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 50 )
		then
			if nSkillLV >= 2 or nMP > 0.78 or J.GetHP( botTarget ) < 0.38
			then
				hCastTarget = botTarget
				sCastMotive = 'W-攻击'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero( 3.0 ) and nLV >= 10
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nInRangeEnemyList >= 1
		and nLostHealth >= nDamage
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 45 )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'W-自我保护'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	--撤退时回血
	if J.IsRetreating( bot ) and nLostHealth > nDamage
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) or nLostHealth > nDamage * 2 )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'W-通过敌人回血'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end

		if #hEnemyList == 0 and nLV >= 10
			and not bot:WasRecentlyDamagedByAnyHero( 3.0 )
			and nLostHealth > nDamage * 1.5
		then
			local creepList = bot:GetNearbyCreeps( 1000, true )
			for _, creep in pairs( creepList )
			do
				if J.IsValid( creep )
					and J.CanCastOnNonMagicImmune( creep )
				then
					hCastTarget = creep
					sCastMotive = 'W-通过小兵回血'
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end


	--发育时对野怪输出
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local targetCreep = botTarget

		if J.IsValid( targetCreep )
			and J.IsInRange( bot, targetCreep, nCastRange + 100 )
			and targetCreep:GetTeam() == TEAM_NEUTRAL
			and not J.IsRoshan( targetCreep )
			and ( targetCreep:GetMagicResist() < 0.3 or nMP > 0.8 )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 2, DAMAGE_TYPE_PHYSICAL )
		then
			hCastTarget = targetCreep
			sCastMotive = 'W-打野'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--推进时对小兵用
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and nSkillLV >= 3 and DotaTime() > 8 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1200, true )
		local keyWord = "ranged"
		for _, creep in pairs( laneCreepList )
		do
			if J.IsValid( creep )
				and ( J.IsKeyWordUnit( keyWord, creep ) or nMP > 0.6 )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				and not J.CanKillTarget( creep, bot:GetAttackDamage() * 1.38, DAMAGE_TYPE_PHYSICAL )
			then
				hCastTarget = creep
				sCastMotive = 'W-带线'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--肉山
	if J.IsDoingRoshan( bot )
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange - 200 )
		then
			hCastTarget = botTarget
			sCastMotive = 'W-肉上'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	--通用消耗敌人或受到伤害时保护自己
	if ( #hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 12
		and nLostHealth > nDamage
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'W-通用情况'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = 0
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil

	
	--进攻敌人
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and not botTarget:HasModifier( 'modifier_bane_enfeeble' )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 50 )
		then
			if nSkillLV >= 2 or nMP > 0.6
			then
				hCastTarget = botTarget
				sCastMotive = 'Q-攻击'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
		
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_bane_enfeeble' )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-虚弱其他人'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end



function X.ConsiderR()


	if not abilityR:IsFullyCastable()
	then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetSpecialValueInt( 'fiend_grip_damage' ) * 6
	local nDamageType = DAMAGE_TYPE_PURE
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil

	--打断和击杀
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			if npcEnemy:IsChanneling()
			then
				hCastTarget = npcEnemy
				sCastMotive = 'R-打断'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end

			if J.IsInRange( bot, npcEnemy, nCastRange + 80 )
				and J.CanKillTarget( npcEnemy, nDamage, nDamageType )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'R-击杀'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end

		end
	end


	if abilityW:IsFullyCastable() and bot:GetMana() > abilityR:GetManaCost() + abilityW:GetManaCost()
	then return 0 end


	--团战中控制
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcStrongestEnemy = nil
		local nStrongestPower = 0

		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
			then
				local npcEnemyPower = npcEnemy:GetEstimatedDamageToTarget( true, bot, 6.0, DAMAGE_TYPE_ALL )
				if ( npcEnemyPower > nStrongestPower )
				then
					nStrongestPower = npcEnemyPower
					npcStrongestEnemy = npcEnemy
				end
			end
		end

		if npcStrongestEnemy ~= nil
			and J.IsInRange( bot, npcStrongestEnemy, nCastRange + 100 )
		then
			hCastTarget = npcStrongestEnemy
			sCastMotive = 'R-团战控制'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--进攻敌人
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 50 )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
		then
			hCastTarget = botTarget
			sCastMotive = 'R-攻击'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592..
