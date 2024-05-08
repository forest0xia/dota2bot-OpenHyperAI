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
						{1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local utilityItems = {"item_crimson_guard", "item_pipe", "item_heavens_halberd"}
local sCrimsonPipeHalberd = utilityItems[RandomInt(1, #utilityItems)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_3'] = {
	"item_tango",
	"item_double_branches",
	"item_quelling_blade",

	"item_bracer",
	"item_phase_boots",
	"item_magic_wand",
	"item_blade_mail",
	"item_blink",
	"item_black_king_bar",--
	sCrimsonPipeHalberd,--
	"item_assault",--
	"item_greater_crit",--
	"item_overwhelming_blink",--
	"item_travel_boots_2",--
	"item_moon_shard",
	"item_aghanims_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_quelling_blade",
	"item_bracer",
	"item_magic_wand",
	"item_blade_mail",
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

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

npc_dota_hero_legion_commander

"Ability1"		"legion_commander_overwhelming_odds"
"Ability2"		"legion_commander_press_the_attack"
"Ability3"		"legion_commander_moment_of_courage"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"legion_commander_duel"
"Ability10"		"special_bonus_strength_7"
"Ability11"		"special_bonus_mp_regen_150"
"Ability12"		"special_bonus_attack_speed_25"
"Ability13"		"special_bonus_unique_legion_commander_6"
"Ability14"		"special_bonus_movement_speed_30"
"Ability15"		"special_bonus_unique_legion_commander_3"
"Ability16"		"special_bonus_unique_legion_commander"
"Ability17"		"special_bonus_unique_legion_commander_5"

modifier_legion_commander_overwhelming_odds
modifier_legion_commander_press_the_attack
modifier_legion_commander_moment_of_courage
modifier_legion_commander_moment_of_courage_lifesteal
modifier_legion_commander_duel_damage_boost
modifier_legion_commander_duel


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent5 = bot:GetAbilityByName( sTalentList[5] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	--计算天赋可能带来的通用变化
	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end

	
	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		--J.SetQueuePtToINT( bot, true )
		
		--释放强攻给自己
		if abilityW:IsTrained() and false
			and abilityW:IsFullyCastable()
			and bot:GetMana() > abilityW:GetManaCost() + abilityR:GetManaCost()
		then
			if talent5:IsTrained()
			then
				bot:ActionQueue_UseAbilityOnLocation( abilityW, bot:GetLocation() )
			else
				bot:ActionQueue_UseAbilityOnEntity( abilityW, bot )
			end		
		end
			
		--释放刃甲
		local abilityBM = J.IsItemAvailable( "item_blade_mail" )
		if abilityBM ~= nil 
			and abilityBM:IsFullyCastable()
			and bot:GetMana() > abilityBM:GetManaCost() + abilityR:GetManaCost()
		then
			bot:ActionQueue_UseAbility( abilityBM )
		end

		bot:Action_UseAbilityOnEntity( abilityR, castRTarget )
		return
	end
	

	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityQ )
		return
	end
	

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if castWDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		if talent5:IsTrained()
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget:GetLocation() )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		end
		return
	end
	


end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = 600
	local nRadius = 600
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( 'damage' ) * 2
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil
	
	--击杀
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
		then
			hCastTarget = npcEnemy:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, 'Q-击杀'..J.Chat.GetNormName( npcEnemy )
		end
	end

	--消耗
	local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 10, 590, 0, 0 )
	if nCanHurtEnemyAoE.count >= 3
	then
		hCastTarget = nCanHurtEnemyAoE.targetloc
		return BOT_ACTION_DESIRE_HIGH, hCastTarget, 'Q-消耗'
	end


	--对线消耗或补刀
	if J.IsLaning( bot )
	then
		--对线消耗
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, 50, 450, 2 )
		if nAoeLoc ~= nil and nMP > 0.38
		then
			hCastTarget = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, 'Q-对线消耗'
		end
	end


	--团战
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, 49, 499, 2 )
		if nAoeLoc ~= nil
		then
			hCastTarget = nAoeLoc
			return BOT_ACTION_DESIRE_ABSOLUTE, hCastTarget, 'Q-团战'
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
				hCastTarget = J.GetCastLocation( bot, botTarget, 10, 490 )
				if hCastTarget ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, 'Q-攻击'..J.Chat.GetNormName( botTarget )
				end
			end
		end
	end


	--撤退前加速
	if J.IsRetreating( bot ) 
		and not bot:HasModifier( 'modifier_legion_commander_overwhelming_odds' )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				--and bot:IsFacingLocation( npcEnemy:GetLocation(), 40 )
			then
				hCastTarget = npcEnemy:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, 'Q-撤退'..J.Chat.GetNormName( npcEnemy )
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
			local nShouldHurtCount = nMP > 0.55 and 3 or 4
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 40, 400, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				hCastTarget = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, "Q-打钱"..locationAoE.count
			end
		end
	end


	--推进时对小兵用
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and nSkillLV >= 2 and DotaTime() > 6 * 60
		and #hAllyList <= 3 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1400, true )
		if #laneCreepList >= 4
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then

			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), 30, 400, 0, 0 )
			if locationAoEHurt.count >= 4 
			then
				hCastTarget = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, "Q-带线"..locationAoEHurt.count
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end



function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange()
	local nRadius = 400
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = 0
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local hCastTarget = nil
	local sCastMotive = nil

	
	
	for _, npcAlly in pairs( hAllyList )
	do 
		if J.IsValidHero( npcAlly )
			and J.IsInRange( bot, npcAlly, nCastRange )
			and not npcAlly:HasModifier( 'modifier_legion_commander_press_the_attack' )
			and not npcAlly:IsMagicImmune()
			and not npcAlly:IsInvulnerable()
			and npcAlly:CanBeSeen()
		then
		
		
			--为加攻速
			if not npcAlly:IsBot()
				and npcAlly:GetLevel() >= 6
				and npcAlly:GetAttackTarget() ~= nil
				and npcAlly:GetMaxHealth() - npcAlly:GetHealth() >= 120
			then
				hCastTarget = npcAlly
				sCastMotive = 'W-加攻速:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive	
			end
		
			--为被控制队友解状态
			if J.IsDisabled( npcAlly )
			then
				hCastTarget = npcAlly
				sCastMotive = 'W-解状态:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive			
			end

			--为撤退中的队友加移速
			if J.IsRetreating( npcAlly )
				and J.IsRunning( npcAlly )
				and npcAlly:GetMaxHealth() - npcAlly:GetHealth() >= 300
				and npcAlly:WasRecentlyDamagedByAnyHero( 5.0 )
				and npcAlly:IsFacingLocation( GetAncient( GetTeam() ):GetLocation(), 30 )
			then
				hCastTarget = npcAlly
				sCastMotive = 'W-加移速:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
			
			--为准备打架的队友辅助
			if J.IsGoingOnSomeone( npcAlly )
			then
				local allyTarget = J.GetProperTarget( npcAlly )
				if J.IsValidHero( allyTarget )
					and npcAlly:IsFacingLocation( allyTarget:GetLocation(), 20 )
					and J.IsInRange( npcAlly, allyTarget, npcAlly:GetAttackRange() + 100 )
				then
					hCastTarget = npcAlly
					sCastMotive = 'W-进攻辅助:'..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
			
			--为残血队友buff
			if J.GetHP( npcAlly ) < 0.3
			then
				hCastTarget = npcAlly
				sCastMotive = 'W-为队友回血:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive			
			end			
		end
	end


	return BOT_ACTION_DESIRE_NONE


end



function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	
	local nDuration = abilityR:GetSpecialValueInt( 'duration' ) - 0.3
	local nDamage = bot:GetAttackDamage() * ( nDuration / bot:GetSecondsPerAttack() )
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( 350 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( 650 )
	local hCastTarget = nil
	local sCastMotive = nil
	
	--激进的决斗
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and botTarget:CanBeSeen()
			and not botTarget:IsMagicImmune()
			and not botTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( botTarget )
			and not J.HasForbiddenModifier( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 100 )
		then
			local attackDamage = botTarget:GetActualIncomingDamage( nDamage, nDamageType )
			
			--纠正估算错误
			if attackDamage > nDamage then attackDamage = nDamage * 0.6 end
			
			local allyDamage = X.GetAllyToTargetDamage( botTarget, nDuration ) 
			local totallyDamage = attackDamage * 0.8 + allyDamage * 1.2
			
			if totallyDamage > botTarget:GetHealth() + botTarget:GetHealthRegen() * nDuration
			then						
				hCastTarget = botTarget
				sCastMotive = 'R-激进的决斗:'..J.Chat.GetNormName( hCastTarget ).." 攻击:"..attackDamage.."队友:"..allyDamage
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive	
			end			
	
		end
	end
	
	
	
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do 
		
		--打断施法
		if npcEnemy:IsChanneling()
			and not npcEnemy:IsMagicImmune()
			and npcEnemy:IsBot()
		then
			hCastTarget = npcEnemy
			sCastMotive = 'R-打断'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_ABSOLUTE, hCastTarget, sCastMotive		
		end
		
		--保守的决斗
		if J.IsValidHero( npcEnemy )
			and npcEnemy:CanBeSeen()
			and not npcEnemy:IsMagicImmune()
			and not npcEnemy:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcEnemy )
			and not J.HasForbiddenModifier( npcEnemy )
		then
		
			local attackDamage = npcEnemy:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL )
			
			--纠正估算错误
			if attackDamage > nDamage then attackDamage = nDamage * 0.5 end
			
			local allyDamage = X.GetAllyToTargetDamage( npcEnemy, nDuration ) 
			local totallyDamage = attackDamage * 0.6 + allyDamage * 0.9
			
			if totallyDamage > npcEnemy:GetHealth()
			then
				local ememyPower = npcEnemy:GetEstimatedDamageToTarget( true, bot, 3.0, DAMAGE_TYPE_PHYSICAL )
				local botPower = bot:GetEstimatedDamageToTarget( true, npcEnemy, 3.0, DAMAGE_TYPE_PHYSICAL )
			
				if bot:GetHealth() * 1.1 / ememyPower > npcEnemy:GetHealth() / botPower
				then			
					hCastTarget = npcEnemy
					sCastMotive = 'R-保守的决斗:'..J.Chat.GetNormName( hCastTarget ).." 攻击:"..attackDamage.."队友:"..allyDamage
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive	
				end
			end
		
		end
		
	end
	
	

	return BOT_ACTION_DESIRE_NONE


end


function X.GetAllyToTargetDamage( npcEnemy, nDuration )

	local nTotalDamage = 0
	local nDamageType = DAMAGE_TYPE_PHYSICAL

	for i = 1, 5
	do
		local ally = GetTeamMember( i )
		if ally ~= nil
			and ally ~= bot
			and ally:IsAlive()
			and J.GetProperTarget( ally ) == npcEnemy
			and not J.IsDisabled( ally )
			and ally:IsFacingLocation( npcEnemy:GetLocation(), 25 )
			and GetUnitToUnitDistance( ally, npcEnemy ) <= ally:GetAttackRange() + 80
		then			
			nTotalDamage = nTotalDamage + ally:GetEstimatedDamageToTarget( true, npcEnemy, nDuration, nDamageType )
		end
	end

	return nTotalDamage

end


return X
-- dota2jmz@163.com QQ:2462331592..

