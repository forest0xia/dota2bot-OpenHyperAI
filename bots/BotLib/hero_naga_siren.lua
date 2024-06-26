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

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sRole = J.Item.GetRoleItemsBuyList(bot)

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,2,1,1,3,1,3,3,6,6,2,2,2,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
	"item_double_branches",
	"item_quelling_blade",
	"item_slippers",
	"item_circlet",

	"item_wraith_band",
	"item_power_treads",
	"item_magic_wand",
	"item_diffusal_blade",
	"item_manta",--
	"item_orchid",
	"item_heart",--
	"item_butterfly",--
	"item_moon_shard",
	"item_abyssal_blade",--
	"item_bloodthorn",--
	"item_aghanims_shard",
	"item_travel_boots",
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
	
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_quelling_blade",
	"item_wraith_band",
	"item_magic_wand",
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'],X['sSellList'] = { 'PvN_PL' }, {"item_manta",'item_quelling_blade'} end

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end

--[[


npc_dota_hero_naga_siren


"Ability1"		"naga_siren_mirror_image"
"Ability2"		"naga_siren_ensnare"
"Ability3"		"naga_siren_rip_tide"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"naga_siren_song_of_the_siren"
"Ability7"		"naga_siren_song_of_the_siren_cancel"
"Ability10"		"special_bonus_movement_speed_20"
"Ability11"		"special_bonus_unique_naga_siren_4"
"Ability12"		"special_bonus_agility_10"
"Ability13"		"special_bonus_strength_13"
"Ability14"		"special_bonus_unique_naga_siren_2"
"Ability15"		"special_bonus_unique_naga_siren"
"Ability16"		"special_bonus_evasion_25"
"Ability17"		"special_bonus_unique_naga_siren_3"

modifier_naga_siren_mirror_image
modifier_naga_siren_ensnare
modifier_naga_siren_rip_tide_passive
modifier_naga_siren_rip_tide
modifier_naga_siren_song_of_the_siren_aura
modifier_naga_siren_song_of_the_siren
modifier_naga_siren_song_of_the_siren_ignore_me

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilitySR = bot:GetAbilityByName( 'naga_siren_song_of_the_siren_cancel' )
local ReelIn = bot:GetAbilityByName( 'naga_siren_reel_in' )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget
local castSRDesire, castSRTarget
local ReelInDesire

local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive;
local aetherRange = 0

function X.SkillsComplement()


	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	botTarget = J.GetProperTarget(bot);
	hEnemyList = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE);
	hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1600);
	
	
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end	
	
	
	castQDesire, castQTarget, sMotive = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);		
	
		bot:Action_ClearActions( false )
	
		bot:Action_UseAbility( abilityQ )
		return;
	end
	
	castWDesire, castWTarget, sMotive = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end

	ReelInDesire = X.ConsiderReelIn()
	if (ReelInDesire > 0)
	then
		J.SetQueuePtToINT(bot, true)
		bot:Action_UseAbility(ReelIn)
		return;
	end
	
	castRDesire, castRTarget, sMotive = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityR )
		return;
	
	end
	
	castSRDesire, castSRTarget, sMotive = X.ConsiderSR();
	if ( castSRDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive)
		
		bot:Action_UseAbility( abilitySR )
		return;
	
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityQ:GetLevel(); 
	local nCastRange  = abilityQ:GetCastRange()
	local nCastPoint  = abilityQ:GetCastPoint()
	local nManaCost   = abilityQ:GetManaCost()
	local nDamage     = abilityQ:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( 800 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( 1200 )
	local hCastTarget = nil
	local sCastMotive = nil
	
	
	if J.IsInTeamFight( bot, 1000 )
	then
		if #nInBonusEnemyList >= 2
		then
			hCastTarget = nInBonusEnemyList[1]
			sCastMotive = 'Q-团战'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget,sCastMotive	
		end
	end
	
	
	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, 700 )
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-攻击:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget,sCastMotive	
		end
	end
	
	
	--对线 
	if J.IsLaning( bot )
	then
		local attackTarget = bot:GetAttackTarget()
		if J.IsValidHero( attackTarget )
			and J.IsInRange( bot, attackTarget, 600 )
		then
			hCastTarget = attackTarget
			sCastMotive = 'Q-对线'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive		
		end	
		
		if bot:WasRecentlyDamagedByAnyHero( 1.0 )
			and #nInRangeEnemyList >= 1
			and nMP > 0.4
		then
			hCastTarget = bot
			sCastMotive = 'Q-对线防御伤害'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive	
		end		
	end
	
	
	--打钱
	if J.IsFarming( bot )
	then
		local targetCreep = bot:GetAttackTarget()
		if J.IsValid( targetCreep )
			and not targetCreep:HasModifier( 'modifier_fountain_glyph' )
			and J.IsInRange( bot, targetCreep, 500 )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep, "Q-打钱"
		end
	end
	
	
	--推线推塔
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 800, true )
		local enemyTowerList = bot:GetNearbyTowers( 800, true )
		local enemyBarrackList = bot:GetNearbyBarracks( 800, true )
		if #laneCreepList >= 1 or #enemyTowerList >= 1 or #enemyBarrackList >= 1
		then
			if botTarget ~= nil
			then
				hCastTarget = botTarget
				sCastMotive = 'Q-推线推塔'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
		
		local attackTarget = bot:GetAttackTarget()
		if J.IsValidBuilding( attackTarget )
			and attackTarget:GetTeam() ~= bot:GetTeam()
		then
			hCastTarget = attackTarget
			sCastMotive = 'Q-拆建筑'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive		
		end
	end
	
	
	
	--撤退时掩护
	if J.IsRetreating( bot ) 
		and #nInRangeEnemyList >= 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-撤退时掩护'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	
	--通用的情况
	if nSkillLV >= 4
		and J.IsAllowedToSpam( bot, 80 )
	then
		local enemyCreepList = bot:GetNearbyCreeps(1600, true)
		local enemyTowerList = bot:GetNearbyTowers(1600, true)
		if #enemyCreepList >= 1
			or #enemyTowerList >= 1
			or #hEnemyList >= 1
		then
			hCastTarget = bot
			sCastMotive = 'Q-通用的情况'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE
	
end


function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityW:GetLevel(); 
	local nCastRange  = abilityW:GetCastRange() + aetherRange
	local nCastPoint  = abilityW:GetCastPoint()
	local nManaCost   = abilityW:GetManaCost()
	local nDamage     = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil
	
	
	--打断TP
	for _,npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid(npcEnemy)
		   and (J.CanCastOnNonMagicImmune(npcEnemy) or (J.CanCastOnMagicImmune(npcEnemy) and bot:HasScepter()))
		   and npcEnemy:IsChanneling()
		   and npcEnemy:HasModifier( 'modifier_teleporting' )
	   then			
			hCastTarget = npcEnemy
			sCastMotive = 'W-打断TP:'..J.Chat.GetNormName( npcEnemy )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget,sCastMotive	
		end
	end
	
	
	
	--追击时
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and (J.CanCastOnNonMagicImmune( botTarget ) or (J.CanCastOnMagicImmune(botTarget) and bot:HasScepter()))
			and J.CanCastOnTargetAdvanced( botTarget )
			and not J.IsDisabled( botTarget )
			and J.IsRunning( botTarget ) 
			and bot:IsFacingLocation( botTarget:GetLocation(), 20 )
			and not botTarget:IsFacingLocation( bot:GetLocation(), 140 )
		then			
			hCastTarget = botTarget
			sCastMotive = 'W-攻击'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
		
		--攻击时显示隐身
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
			then
				if npcEnemy:HasModifier( 'modifier_item_glimmer_cape' )
					or npcEnemy:HasModifier( 'modifier_invisible' )
					or npcEnemy:HasModifier( 'modifier_item_shadow_amulet_fade' )
				then
					if ((J.CanCastOnNonMagicImmune( npcEnemy )) or (J.CanCastOnMagicImmune(npcEnemy) and bot:HasScepter()))
						and J.CanCastOnTargetAdvanced( npcEnemy )
						and not npcEnemy:HasModifier( 'modifier_item_dustofappearance' )
						and not npcEnemy:HasModifier( 'modifier_slardar_amplify_damage' )
						and not npcEnemy:HasModifier( 'modifier_bloodseeker_thirst_vision' )
						and not npcEnemy:HasModifier( 'modifier_sniper_assassinate' )
						and not npcEnemy:HasModifier( 'modifier_bounty_hunter_track' )
					then
						hCastTarget = npcEnemy
						sCastMotive = 'W-显隐'..J.Chat.GetNormName( hCastTarget )
						return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
					end
				end
			end
		end
	end
	
	
	
	
	--逃跑时减速
	if J.IsRetreating( bot ) 
		and bot:WasRecentlyDamagedByAnyHero( 5.0 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )				
				and (J.CanCastOnNonMagicImmune( npcEnemy ) or (J.CanCastOnMagicImmune(npcEnemy) and bot:HasScepter()))
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
				and npcEnemy:IsFacingLocation( bot:GetLocation(), 30 )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'W-撤退'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE
	
end


function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityR:GetLevel(); 
	local nCastRange  = abilityR:GetSpecialValueInt( 'radius' )
	local nRadius     = nCastRange
	local nCastPoint  = abilityR:GetCastPoint();
	local nManaCost   = abilityR:GetManaCost();
	local nDamage     = 0
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange - 200 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local hCastTarget = nil
	local sCastMotive = nil
	
	
	--进攻时控制
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, 1400 )
			and not J.IsInRange( bot, botTarget, 800 )
			and J.CanCastOnNonMagicImmune( botTarget )
			and not botTarget:WasRecentlyDamagedByAnyHero( 3.0 )
			and bot:IsFacingLocation( botTarget:GetLocation(), 20 )
		then
			local allyList = J.GetNearbyHeroes(botTarget,  700, true, BOT_MODE_NONE )
			if #allyList == 0
			then
				hCastTarget = botTarget
				sCastMotive = 'R-伏击:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	
	
	--逃跑时防御
	if J.IsRetreating( bot ) 
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )				
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				hCastTarget = npcEnemy
				sCastMotive = 'R-撤退'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE
	
end

function X.ConsiderSR()


	if abilitySR:IsHidden()
		or not abilitySR:IsTrained()
		or not abilitySR:IsFullyCastable() 
	then return 0 end	

	
	
	--进攻时撤销控制
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, 300 )
		then
			local allyList = J.GetNearbyHeroes(botTarget,  300, true, BOT_MODE_NONE )
			if allyList ~= nil
				and #allyList >= 3
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget, 'SR-停止大招'
			end
		end
	end
		
	
	return BOT_ACTION_DESIRE_NONE
	
end

function X.ConsiderReelIn()
	if not bot:HasScepter()
	or not ReelIn:IsFullyCastable()
	or J.IsInTeamFight(bot, 1400)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRange = 1400
	local nInRangeAllyList = J.GetNearbyHeroes(bot,nRange, false, BOT_MODE_NONE)
	local nInRangeEnemyList = J.GetNearbyHeroes(bot,nRange, true, BOT_MODE_NONE)

	for _, npcEnemy in pairs(nInRangeEnemyList)
	do
		if J.IsValidHero(npcEnemy)
		and J.IsInRange(bot, npcEnemy, nRange)
		and not J.IsInRange(bot, npcEnemy, bot:GetAttackRange() * 2)
		and npcEnemy:HasModifier('modifier_naga_siren_ensnare')
		and #nInRangeAllyList >= #nInRangeEnemyList
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.IsInRange(bot, botTarget, nRange)
		and not J.IsInRange( bot, botTarget, bot:GetAttackRange() * 2)
		and bot:IsFacingLocation(botTarget:GetLocation(), 30)
		and botTarget:HasModifier('modifier_naga_siren_ensnare')
		and #nInRangeAllyList >= #nInRangeEnemyList
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X