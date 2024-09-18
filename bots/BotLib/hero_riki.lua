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
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,3,2,1,2,6,2,3,3,3,6,1,1,1,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

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
	"item_ultimate_scepter",
	"item_greater_crit",--
	"item_basher",
	"item_sphere",--
	"item_disperser",--
	"item_abyssal_blade",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_monkey_king_bar",--
	"item_aghanims_shard",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']


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
	
	"item_power_treads",
	"item_quelling_blade",

	"item_lotus_orb",
	"item_quelling_blade",

	"item_assault",
	"item_magic_wand",
	
	"item_travel_boots",
	"item_magic_wand",

	"item_assault",
	"item_ancient_janggo",
	
	"item_vladmir",
	"item_magic_wand",
}

if J.Role.IsPvNMode() then X['sBuyList'], X['sSellList'] = { 'PvN_BH' }, {{"item_power_treads", 'item_quelling_blade'}, 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_riki

"Ability1"		"riki_smoke_screen"
"Ability2"		"riki_blink_strike"
"Ability3"		"riki_tricks_of_the_trade"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"riki_backstab"
"Ability10"		"special_bonus_hp_regen_6"
"Ability11"		"special_bonus_attack_speed_20"
"Ability12"		"special_bonus_attack_damage_20"
"Ability13"		"special_bonus_unique_riki_2"
"Ability14"		"special_bonus_unique_riki_1"
"Ability15"		"special_bonus_unique_riki_3"
"Ability16"		"special_bonus_unique_riki_6"
"Ability17"		"special_bonus_unique_riki_7"

modifier_riki_smoke_screen_thinker
modifier_riki_smoke_screen
modifier_riki_blinkstrike
modifier_riki_permanent_invisibility
modifier_riki_tricks_of_the_trade_phase

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent5 = bot:GetAbilityByName( sTalentList[5] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )
local talent8 = bot:GetAbilityByName( sTalentList[8] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castASDesire, castASTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0

local nLastBlinkTime = -90
local nAttackPoint = 0


function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or DotaTime() < nLastBlinkTime + nAttackPoint + 0.3 then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )
	nAttackPoint = bot:GetSecondsPerAttack()


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end

	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQTarget )
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

	castEDesire, castETarget, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityE, castETarget )
		return

	end


end

--核心函数
--J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius, nTime )
function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nCastPoint = abilityQ:GetCastPoint() + 0.5
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL

	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )

	local nRadius = abilityQ:GetSpecialValueInt( "radius" )
	if talent8:IsTrained() then nRadius = nRadius + talent8:GetSpecialValueInt( "value" ) end
	local nCastTarget = nil

	--打断
	for _, npcEnemy in pairs( hEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.IsInRange( bot, npcEnemy, nCastRange + nRadius )
			and npcEnemy:IsChanneling()
			and not npcEnemy:HasModifier( "modifier_teleporting" )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then
			nCastTarget = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius, nCastPoint )
			if nCastTarget ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-打断吟唱:"..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--团战Aoe
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			nCastTarget = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'Q-团战Aoe'
		end
	end


	--进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			nCastTarget = J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius, nCastPoint + 0.3 )
			if nCastTarget ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-进攻"..J.Chat.GetNormName( botTarget )
			end
		end
	end



	--撤退时干扰
	if J.IsRetreating( bot )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange -100, nRadius -20, 2 )
		if nAoeLoc ~= nil
		then
			nCastTarget = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'Q-撤退Aoe'
		end

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 ) or bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_VERYHIGH )
			then
				nCastTarget = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius, nCastPoint + 0.2 )
				if nCastTarget ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-撤退撒雾"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end


	--肉山
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 370
	then
		if J.IsRoshan( botTarget ) and J.GetHP( botTarget ) > 0.3
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			nCastTarget = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'Q-肉山'
		end
	end

	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()


	if not abilityW:IsFullyCastable()
		or bot:IsRooted()
	then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + aetherRange

	if talent6:IsTrained() then nCastRange = nCastRange + talent6:GetSpecialValueInt( "value" )	end

	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()

	local nPhysicalDamge = bot:GetAttackDamage()
	if abilityR:IsTrained()
	then
		local nBonusRate = abilityR:GetSpecialValueFloat( "damage_multiplier" )
		if talent5:IsTrained() then nBonusRate = nBonusRate + talent5:GetSpecialValueFloat( "value" ) end
		nPhysicalDamge = nPhysicalDamge + bot:GetAttributeValue( ATTRIBUTE_AGILITY ) * nBonusRate
	end

	local nDamage = abilityW:GetSpecialValueInt( "bonus_damage" )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local aliveEnemyCount = J.GetNumOfAliveHeroes( true )

	local nCastTarget = nil


	--击杀
	for _, npcEnemy in pairs( hEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and not npcEnemy:IsAttackImmune()
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.IsInRange( bot, npcEnemy, nCastRange + 100 )
			and ( J.WillMixedDamageKillTarget( npcEnemy, nPhysicalDamge, nDamage, 0, nCastPoint )
				or ( npcEnemy:IsChanneling() and J.WillMixedDamageKillTarget( npcEnemy, nPhysicalDamge * 3, nDamage, 0, nCastPoint * 3 ) ) )
		then
			nCastTarget = npcEnemy
			bot:SetTarget( nCastTarget )
			nLastBlinkTime = DotaTime()
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, "W-击杀:"..J.Chat.GetNormName( nCastTarget )
		end
	end


	--团战中对血量最低的敌人使用
	if J.IsInTeamFight( bot, 1000 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and not npcEnemy:IsAttackImmune()
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				local tableNearbyAllyHeroes = J.GetNearbyHeroes(npcEnemy,  600, true, BOT_MODE_NONE )
				if npcEnemyHealth < npcWeakestEnemyHealth
					and ( #tableNearbyAllyHeroes >= 1 or aliveEnemyCount <= 2 )
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = npcEnemy
				end
			end
		end

		if ( npcWeakestEnemy ~= nil )
		then
			nCastTarget = npcWeakestEnemy
			bot:SetTarget( nCastTarget )
			nLastBlinkTime = DotaTime()
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, "W-团战攻击最弱的:"..J.Chat.GetNormName( nCastTarget )
		end
	end



	--进攻
	if J.IsGoingOnSomeone( bot ) and ( nLV >= 2 or #hEnemyList <= 1 )
		and ( #hAllyList >= 2 or #hEnemyList <= 1 or nLV >= 20 )
	then

		if J.IsValidHero( botTarget )
			and not botTarget:IsAttackImmune()
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 50 )
		then
			local tableNearbyEnemyHeroes = J.GetNearbyHeroes(botTarget,  800, false, BOT_MODE_NONE )
			local tableNearbyAllyHeroes = J.GetNearbyHeroes(botTarget,  800, true, BOT_MODE_NONE )
			local tableAllEnemyHeroes = J.GetNearbyHeroes(botTarget,  1600, false, BOT_MODE_NONE )
			if ( J.WillKillTarget( botTarget, nPhysicalDamge * 3, DAMAGE_TYPE_PHYSICAL, 1.0 ) )
				or ( #tableNearbyEnemyHeroes <= #tableNearbyAllyHeroes )
				or ( #tableAllEnemyHeroes <= 1 )
				or GetUnitToUnitDistance( bot, botTarget ) <= 400
				or aliveEnemyCount <= 2
			then
				nCastTarget = botTarget
				bot:SetTarget( nCastTarget )
				nLastBlinkTime = DotaTime()
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, "W-进攻:"..J.Chat.GetNormName( nCastTarget )
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		local nAttackAllys = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_ATTACK )
		if #nAttackAllys == 0 or nHP < 0.16
		then
			local nAllyInCastRange = J.GetNearbyHeroes(bot, nCastRange, false, BOT_MODE_NONE )
			local nAllyCreeps	 = bot:GetNearbyCreeps( nCastRange, false )
			local nEnemyCreeps = bot:GetNearbyCreeps( nCastRange, true )
			local nAllyUnits = J.CombineTwoTable( nAllyInCastRange, nAllyCreeps )
			local nAllUnits = J.CombineTwoTable( nAllyUnits, nEnemyCreeps )

			local targetUnit = nil
			local targetUnitDistance = J.GetDistanceFromAllyFountain( bot )
			for _, unit in pairs( nAllUnits )
			do
				if J.IsValid( unit )
					and not unit:IsMagicImmune()
					and GetUnitToUnitDistance( unit, bot ) > 300
					and J.GetDistanceFromAllyFountain( unit ) < targetUnitDistance
				then
					targetUnit = unit
					targetUnitDistance = J.GetDistanceFromAllyFountain( unit )
				end
			end

			if targetUnit ~= nil
			then
				nCastTarget = targetUnit
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, "W-撤退了:"..J.Chat.GetNormName( nCastTarget )
			end
		end
	end


	--带线期间补刀远程兵
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and ( bot:GetAttackDamage() < 300 or nMP > 0.7 )
		and nSkillLV >= 2 and DotaTime() > 8 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 200, true )
		local keyWord = "ranged"
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and J.IsKeyWordUnit( keyWord, creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.WillMixedDamageKillTarget( creep, nPhysicalDamge, nDamage, 0, nCastPoint )
				and not J.CanKillTarget( creep, bot:GetAttackDamage() * 1.3, DAMAGE_TYPE_PHYSICAL )
			then
				nCastTarget = creep
				bot:SetTarget( nCastTarget )
				nLastBlinkTime = DotaTime()
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'W-推线补远程'
			end
		end

		local targetCreep = nLaneCreeps[1]
		if J.IsValid( targetCreep )
			and not J.IsInRange( bot, targetCreep, 650 )
			and not targetCreep:HasModifier( "modifier_fountain_glyph" )
		then
			nCastTarget = targetCreep
			nLastBlinkTime = DotaTime()
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'W-推线闪烁'
		end
	end



	--打钱时增加输出
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local nCreeps = bot:GetNearbyNeutralCreeps( 800 )

		if J.IsValid( botTarget )
		then
			if ( #nCreeps >= 2 or GetUnitToUnitDistance( botTarget, bot ) <= 400 )
				and not J.CanKillTarget( botTarget, bot:GetAttackDamage() * 2.3, DAMAGE_TYPE_PHYSICAL )
			then
				nCastTarget = botTarget
				nLastBlinkTime = DotaTime()
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'W-打钱输出'
			end

			if bot:GetMana() >= 240
				and GetUnitToUnitDistance( botTarget, bot ) >= 600
			then
				nCastTarget = botTarget
				nLastBlinkTime = DotaTime()
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'W-打钱闪烁'
			end
		end
	end


	--肉山
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 460
	then
		if J.IsRoshan( botTarget )
			and J.GetHP( botTarget ) > 0.2
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			nCastTarget = botTarget
			nLastBlinkTime = DotaTime()
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'W-肉山'
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
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )

	local nRadius = abilityE:GetSpecialValueInt( "range" )
	local vEscapeLoc = J.GetLocationTowardDistanceLocation( bot, J.GetTeamFountain(), nCastRange )
	local nCastTarget = nil

	--躲避弹道, 可包括无目标弹道
	if J.IsNotAttackProjectileIncoming( bot, 1000 )
		or ( J.IsWithoutTarget( bot ) and J.GetAttackProjectileDamageByRange( bot, 1600 ) >= bot:GetHealth() )
	then
		return BOT_ACTION_DESIRE_HIGH, vEscapeLoc, 'E-躲避'
	end


	--团战Aoe
	if J.IsInTeamFight( bot, 1000 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nAoeLoc, 'E-团战Aoe'
		end
	end


	--进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + nRadius )
			and J.CanCastOnMagicImmune( botTarget )
		then
			local targetFutrueLocation = J.GetCorrectLoc( botTarget, nCastPoint )
			if J.IsInLocRange( bot, targetFutrueLocation, nCastRange )
			then
				return BOT_ACTION_DESIRE_HIGH, targetFutrueLocation, 'E-进攻:'..J.Chat.GetNormName( botTarget )
			end
		end
	end



	--撤退时隐藏自己
	if J.IsRetreating( bot )
		and ( bot:WasRecentlyDamagedByAnyHero( 3.0 ) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
	then
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.IsInRange( bot, npcEnemy, 560 )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
			then
				local nDistance = GetUnitToUnitDistance( bot, npcEnemy )
				nCastTarget = J.GetUnitTowardDistanceLocation( npcEnemy, bot, nDistance + nCastRange )
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'E-撤退:'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end



function X.ConsiderAS()

	if not abilityAS:IsTrained()
		or not abilityAS:IsFullyCastable() 
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = 700
	local nCastRange = abilityAS:GetCastRange()
	local nCastPoint = abilityAS:GetCastPoint()
	local nManaCost = abilityAS:GetManaCost()

	
	local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy, "AS-打断"
		end
	end

	
	if J.IsRetreating( bot )
	then
		local enemyHeroList = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )
		local targetHero = enemyHeroList[1]
		if J.IsValidHero( targetHero )
			and J.CanCastOnNonMagicImmune( targetHero )
			and J.CanCastOnTargetAdvanced( targetHero )
			and not J.IsDisabled( targetHero )
		then
			return BOT_ACTION_DESIRE_HIGH, targetHero, "AS-撤退了"
		end
	end
	

	if J.IsInTeamFight( bot, 1400 )
		and #hEnemyList >= 3
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		for _, npcEnemy in pairs( hEnemyList )
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
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy, "AS-团战控制"
		end
		
	end
	

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero(botTarget)
			and J.CanCastOnNonMagicImmune(botTarget)
		then
			if J.IsInRange( bot, botTarget, nCastRange )
				and not J.IsInRange( bot, botTarget, 600 )
				and not J.IsDisabled( botTarget )
				and bot:IsFacingLocation( botTarget:GetLocation(), 30 )
				and not botTarget:IsFacingLocation( bot:GetLocation(), 100 )
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget, "AS-追击"
			end
			
			local enemyHeroList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_ACTION_DESIRE_NONE )
			if #enemyHeroList >= 2
			then
				for _, npcEnemy in pairs( enemyHeroList )
				do 
					if npcEnemy ~= botTarget
						and J.CanCastOnNonMagicImmune( npcEnemy )
						and not J.IsDisabled( npcEnemy )
					then
						return BOT_ACTION_DESIRE_HIGH, npcEnemy, "AS-睡眠敌方"
					end
				end
			end		
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end


return X
-- dota2jmz@163.com QQ:2462331592..
