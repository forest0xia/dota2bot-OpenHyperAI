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
						{--pos2
							['t25'] = {10, 0},
							['t20'] = {10, 0},
							['t15'] = {0, 10},
							['t10'] = {10, 0},
						},
						{--po3
							['t25'] = {10, 0},
							['t20'] = {10, 0},
							['t15'] = {10, 0},
							['t10'] = {10, 0},
						}
}

local tAllAbilityBuildList = {
						{2,3,2,1,2,6,2,1,1,1,6,3,3,3,6},--pos2
						{2,3,2,1,2,6,2,3,3,3,6,1,1,1,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_2"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
else
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sCrimsonPipe = RandomInt( 1, 2 ) == 1 and "item_crimson_guard" or "item_pipe"

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	
	'item_melee_carry_outfit',
--	'item_medallion_of_courage',
	'item_vanguard',
	"item_aghanims_shard",
	"item_crimson_guard",
	"item_black_king_bar",
	"item_ultimate_scepter",
	"item_travel_boots",
	"item_abyssal_blade",
	"item_butterfly",
	"item_moon_shard",
	"item_travel_boots_2",
	"item_reaver",
	"item_ultimate_scepter_2",
	"item_heart",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = {
	"item_dragon_knight_outfit",
	"item_crimson_guard",
	"item_heavens_halberd",
	"item_ultimate_scepter",
	"item_travel_boots",
	"item_aghanims_shard",
	"item_black_king_bar",
	"item_assault",
	"item_moon_shard",
	"item_travel_boots_2",
	"item_reaver",
	"item_ultimate_scepter_2",
	"item_heart",

}

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']


X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_power_treads",
	"item_quelling_blade",

	"item_heavens_halberd",
	"item_quelling_blade",

	"item_abyssal_blade",
	"item_magic_wand",

	"item_assault",
	"item_ancient_janggo",
}

if J.Role.IsPvNMode() then X['sBuyList'], X['sSellList'] = { 'PvN_BH' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_bounty_hunter

"Ability1"		"bounty_hunter_shuriken_toss"
"Ability2"		"bounty_hunter_jinada"
"Ability3"		"bounty_hunter_wind_walk"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"bounty_hunter_track"
"Ability10"		"special_bonus_movement_speed_15"
"Ability11"		"special_bonus_attack_damage_20"
"Ability12"		"special_bonus_unique_bounty_hunter_2"
"Ability13"		"special_bonus_hp_275"
"Ability14"		"special_bonus_attack_speed_50"
"Ability15"		"special_bonus_unique_bounty_hunter"
"Ability16"		"special_bonus_evasion_40"
"Ability17"		"special_bonus_unique_bounty_hunter_3"

modifier_bounty_hunter_jinada
modifier_bounty_hunter_wind_walk
modifier_bounty_hunter_wind_walk_slow
modifier_bounty_hunter_track

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local FriendlyShadow = bot:GetAbilityByName( 'bounty_hunter_wind_walk_ally' )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent3 = bot:GetAbilityByName( sTalentList[3] )

local castQDesire, castQTarget
local castEDesire
local FriendlyShadowDesire, FriendlyShadowTarget
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local talent3Damage = 0

function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) then return end

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
	if talent3:IsTrained() then talent3Damage = talent3:GetSpecialValueInt( "value" ) end



	castEDesire, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityE )
		return
	end

	FriendlyShadowDesire, FriendlyShadowTarget = X.ConsiderFriendlyShadow()
	if (FriendlyShadowDesire > 0)
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnEntity(FriendlyShadow, FriendlyShadowTarget)
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


	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( 'bonus_damage' ) + talent3Damage
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nCastTarget = nil


	local nRadius = abilityQ:GetSpecialValueInt( "bounce_aoe" )
	local nEnemyUnitList = J.GetAroundBotUnitList( bot, nCastRange + 100, true )
	local nTrackEnemyList = {}

	
	--击杀和打断
	for _, npcEnemy in pairs( hEnemyList )
	do
		--计算出视野内被标记的
		if npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
		then
			nTrackEnemyList[#nTrackEnemyList + 1] = npcEnemy
		end

		--打断施法
		if npcEnemy:IsChanneling()
			and not npcEnemy:IsMagicImmune()
		then
			if npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
			then
				for _, nUnit in pairs( nEnemyUnitList )
				do
					if J.IsValid( nUnit )
						and J.CanCastOnTargetAdvanced( nUnit )
						and not nUnit:IsMagicImmune()
					then
						nCastTarget = nUnit
						return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-通过弹射打断施法:"..J.Chat.GetNormName( npcEnemy )
					end
				end
			end

			if J.IsInRange( bot, npcEnemy, nCastRange + 200 )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				nCastTarget = npcEnemy
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-直接打断施法:"..J.Chat.GetNormName( nCastTarget )
			end
		end

		--击杀
		if J.CanCastOnNonMagicImmune( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint + GetUnitToUnitDistance( bot, npcEnemy )/1000 )
		then
			if npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
			then
				for _, nUnit in pairs( nEnemyUnitList )
				do
					if J.IsValid( nUnit )
						and J.CanCastOnTargetAdvanced( nUnit )
						and not nUnit:IsMagicImmune()
					then
						nCastTarget = nUnit
						return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-通过弹射击杀:"..J.Chat.GetNormName( npcEnemy )
					end
				end
			end

			if J.IsInRange( bot, npcEnemy, nCastRange + 200 )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				nCastTarget = npcEnemy
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-直接击杀:"..J.Chat.GetNormName( nCastTarget )
			end
		end
	end


	--可弹射两人以上时
	if #nTrackEnemyList >= 2
	then
		local nBestUnit = nil
		local nMaxBounceCount = 1.2
		for _, nUnit in pairs( nEnemyUnitList )
		do
			if J.IsValid( nUnit )
				and not nUnit:IsMagicImmune()
				and J.CanCastOnTargetAdvanced( nUnit )
			then
				local nBounceCount = 0

				if not nUnit:HasModifier( "modifier_bounty_hunter_track" )
				then
					if nUnit:IsHero()
					then
						nBounceCount = nBounceCount + 1
					else
						nBounceCount = nBounceCount + 0.1
					end
				end

				for _, npcEnemy in pairs( nTrackEnemyList )
				do 
					if J.IsInRange( nUnit, npcEnemy, nRadius - 80 )
					then
						nBounceCount = nBounceCount + 1
					end
				end

				if nBounceCount > nMaxBounceCount
				then
					nBestUnit = nUnit
					nMaxBounceCount = nBounceCount
				end
			end
		end

		if nBestUnit ~= nil
		then
			nCastTarget = nBestUnit
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-弹射多个:"..nMaxBounceCount
		end
	end


	--进攻时尽量弹小兵
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + nRadius + 100 )
			and J.CanCastOnNonMagicImmune( botTarget )
		then
			if botTarget:HasModifier( "modifier_bounty_hunter_track" )
			then
				for _, nUnit in pairs( nEnemyUnitList )
				do
					if J.IsInRange( nUnit, botTarget, nRadius - 100 )
						and not nUnit:IsMagicImmune()
						and J.CanCastOnTargetAdvanced( nUnit )
						and not nUnit:HasModifier( "modifier_bounty_hunter_track" )
					then
						nCastTarget = nUnit
						return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-弹射进攻:"..J.Chat.GetNormName( botTarget )
					end
				end
			end

			if J.IsInRange( bot, botTarget, nCastRange )
				and J.CanCastOnTargetAdvanced( botTarget )
			then
				nCastTarget = botTarget
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, "Q-直接进攻:"..J.Chat.GetNormName( botTarget )
			end
		end
	end


	--对线期间补刀远程兵
	if ( bot:GetActiveMode() == BOT_MODE_LANING or ( nLV <= 7 and #hAllyList <= 2 ) )
		and bot:GetMana() >= 150
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 300, true )
		local keyWord = "ranged"
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.IsKeyWordUnit( keyWord, creep )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint + GetUnitToUnitDistance( bot, creep )/1100 )
				and GetUnitToUnitDistance( creep, bot ) > 300
			then
				nCastTarget = creep
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'Q-补远程兵'
			end
		end
	end


	--带线期间补刀远程兵
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.52 )
		and ( bot:GetAttackDamage() < 300 or nMP > 0.7 )
		and nSkillLV >= 2 and DotaTime() > 7 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 350, true )
		local keyWord = "ranged"
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and J.IsKeyWordUnit( keyWord, creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint + GetUnitToUnitDistance( bot, creep )/1100 )
				and not J.CanKillTarget( creep, bot:GetAttackDamage() * 1.2, DAMAGE_TYPE_PHYSICAL )
			then
				nCastTarget = creep
				return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'Q-推线补远程'
			end
		end
	end


	--打钱时增加输出
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local nCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 200 )

		local targetCreep = J.GetMostHpUnit( nCreeps )

		if J.IsValid( targetCreep )
			and not J.IsRoshan( targetCreep )
			and ( #nCreeps >= 2 or GetUnitToUnitDistance( targetCreep, bot ) <= 400 )
			and bot:IsFacingLocation( targetCreep:GetLocation(), 40 )
			and ( targetCreep:GetMagicResist() < 0.3 or nMP > 0.9 )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 1.68, DAMAGE_TYPE_PHYSICAL )
			and not J.CanKillTarget( targetCreep, nDamage - 50, nDamageType )
		then
			nCastTarget = targetCreep
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'Q-打钱'
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
			return BOT_ACTION_DESIRE_HIGH, nCastTarget, 'Q-肉山'
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end


	local nSkillLV = abilityE:GetLevel()


	--进攻
	if J.IsGoingOnSomeone( bot )
		and ( nLV >= 7 or DotaTime() > 6 * 60 or nSkillLV >= 2 )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, 2500 )
			and ( not J.IsInRange( bot, botTarget, 1000 )
					or J.IsChasingTarget( bot, botTarget ) )
		then
			return BOT_ACTION_DESIRE_HIGH, "E-隐身进攻:"..J.Chat.GetNormName( botTarget )
		end
	end


	--撤退
	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and ( #hEnemyList >= 1 or nHP < 0.2 )
		and bot:DistanceFromFountain() > 800
	then
		return BOT_ACTION_DESIRE_HIGH, "E-隐身逃跑"
	end


	--潜行
	if J.IsInEnemyArea( bot ) and nLV >= 7 and nMP >= 280
	then
		local nEnemies = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
		local nEnemyTowers = bot:GetNearbyTowers( 1600, true )
		if #nEnemies == 0 and nEnemyTowers == 0
		then
			return BOT_ACTION_DESIRE_HIGH, "E-潜行"
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
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + 100 )
	local nCastTarget = nil

	--见人就标血最少那个
	local nMinHealth = 999999
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and not npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
			and not npcEnemy:HasModifier( "modifier_arc_warden_tempest_double" )
			and J.CanCastAbilityOnTarget( npcEnemy, false )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and npcEnemy:GetHealth() < nMinHealth
		then
			nCastTarget = npcEnemy
			nMinHealth = npcEnemy:GetHealth()
		end
	end
	if nCastTarget ~= nil
	then
		return BOT_ACTION_DESIRE_HIGH, nCastTarget, "R-标记:"..J.Chat.GetNormName( nCastTarget )
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderFriendlyShadow()
	if not FriendlyShadow:IsTrained()
	or not FriendlyShadow:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = FriendlyShadow:GetCastRange()
	local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)

	for _, ally in pairs(nAllyHeroes) do
		if J.IsGoingOnSomeone(ally)
		and J.IsInRange(bot, ally, nCastRange)
		and J.IsNotSelf(bot, ally)
		and not J.IsRealInvisible(ally)
		then
			return BOT_ACTION_DESIRE_HIGH, ally
		end

		if J.IsRetreating(ally)
		and ally:WasRecentlyDamagedByAnyHero(3.0)
		and ally:DistanceFromFountain() > 800
		and J.IsInRange(bot, ally, nCastRange)
		and J.IsNotSelf(bot, ally)
		and not J.IsRealInvisible(ally)
		and #hEnemyList >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, ally
		end

		if J.IsInEnemyArea(bot)
		then
			local nEnemies = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
			local nEnemyTowers = bot:GetNearbyTowers(1600, true)

			if nEnemies ~= nil and nEnemyTowers ~= nil
			and #nEnemies == 0 and #nEnemyTowers == 0
			and J.IsInRange(bot, ally, nCastRange)
			and J.IsNotSelf(bot, ally)
			and not J.IsRealInvisible(ally)
			then
				return BOT_ACTION_DESIRE_HIGH, ally
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

return X