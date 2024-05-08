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
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,2,2,3,6,3,3,2,2,1,6,1,1,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
	"item_tango",
	"item_faerie_fire",
	"item_gauntlets",
	"item_gauntlets",
	"item_gauntlets",

	"item_boots",
	"item_armlet",
	"item_black_king_bar",--
	"item_sange",
	"item_ultimate_scepter",
	"item_heavens_halberd",--
	"item_travel_boots",
	"item_satanic",--
	"item_aghanims_shard",
	"item_assault",--
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
	"item_sheepstick",--
	"item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_gauntlets",
	"item_armlet",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_huskar' }, {} end

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

npc_dota_hero_huskar

"Ability1"		"huskar_inner_fire"
"Ability2"		"huskar_burning_spear"
"Ability3"		"huskar_berserkers_blood"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"huskar_life_break"
"Ability10"		"special_bonus_hp_225"
"Ability11"		"special_bonus_attack_damage_15"
"Ability12"		"special_bonus_unique_huskar_2"
"Ability13"		"special_bonus_lifesteal_20"
"Ability14"		"special_bonus_strength_20"
"Ability15"		"special_bonus_unique_huskar"
"Ability16"		"special_bonus_attack_range_175"
"Ability17"		"special_bonus_unique_huskar_5"

modifier_huskar_inner_fire_knockback
modifier_huskar_inner_fire_disarm
modifier_huskar_inner_vitality
modifier_huskar_burning_spear_self
modifier_huskar_burning_spear_counter
modifier_huskar_burning_spear_debuff
modifier_huskar_berserkers_blood
modifier_huskar_life_break_charge
modifier_huskar_life_break_slow

--]]


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )
local abilityH = nil

local castQDesire
local castWDesire, castWTarget
local castRDesire, castRTarget
local castHWDesire, castHWTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local talent6Range = 0


function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end


	nKeepMana = 400
	aetherRange = 0
	talent6Range = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )
	abilityH = J.IsItemAvailable( "item_hurricane_pike" )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end
--	if talent6:IsTrained() then talent6Range = talent6:GetSpecialValueInt( "value" ) end


	castHWDesire, castHWTarget, sMotive = X.ConsiderHW()
	if ( castHWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		bot:Action_ClearActions( true )

		bot:ActionQueue_UseAbilityOnEntity( abilityH, castHWTarget )
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castHWTarget )
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castHWTarget )
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castHWTarget )
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castHWTarget )
		bot:SetTarget( castHWTarget )
		return
	end


	castQDesire, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityQ )
		return
	end


	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		bot:Action_ClearActions( true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return

	end


	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		bot:Action_ClearActions( true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end


end


function X.ConsiderHW()

	if abilityH == nil
		or not abilityH:IsFullyCastable()
		or not abilityW:IsFullyCastable()
		or bot:IsDisarmed()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = 400 + aetherRange + 50

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.GetHP( botTarget ) > 0.25
			and not botTarget:IsAttackImmune()
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, '飓风之力:'..J.Chat.GetNormName( botTarget )
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange()
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( 'damage' )
	local nRadius = abilityQ:GetSpecialValueInt( 'radius' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( nRadius -32, true, BOT_MODE_NONE )


	--击杀, 消耗, 撤退
	local nCanHurtCount = 0
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then

			nCanHurtCount = nCanHurtCount + 1
			if nCanHurtCount >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, "Q缴械两人:"..J.Chat.GetNormName( npcEnemy )
			end

			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				return BOT_ACTION_DESIRE_HIGH, "Q击杀:"..J.Chat.GetNormName( npcEnemy )
			end

			if J.IsRetreating( bot )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, "Q撤退:"..J.Chat.GetNormName( npcEnemy )
			end

		end
	end


	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nRadius -32 )
			and ( not J.IsInRange( bot, botTarget, 200 )
				or J.IsAttacking( botTarget )
				or botTarget:GetAttackTarget() ~= nil )
			and J.CanCastOnNonMagicImmune( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, "Q进攻:"..J.Chat.GetNormName( botTarget )
		end
	end

	

	--对线
	if J.IsLaning( bot )
	then
		local nLaneCreepList = bot:GetNearbyLaneCreeps( nRadius, true )
		local nCanKillCount = 0
		for _, creep in pairs( nLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
			then
				nCanKillCount = nCanKillCount + 1
			end
		end
		if nCanKillCount >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, "Q对线补刀:"..nCanKillCount
		end
	end


	--打钱
	if J.IsFarming( bot ) and nLV >= 8
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local nCreepList = bot:GetNearbyNeutralCreeps( nRadius )
		local targetCreep = nCreepList[1]
		if #nCreepList >= 2
			and J.IsValid( targetCreep )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 2.2, DAMAGE_TYPE_PHYSICAL )
		then
			return BOT_ACTION_DESIRE_HIGH, "Q打钱:"..#nCreepList
		end
	end


	--带线
	if #hEnemyList == 0 and #hAllyList <= 2 and nSkillLV >= 3 and nLV >= 8
		and J.IsAllowedToSpam( bot, nManaCost )
		and ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
	then
		local nLaneCreepList = bot:GetNearbyLaneCreeps( nRadius, true )
		local nCanKillCount = 0
		local nCanHurtCount = 0
		for _, creep in pairs( nLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
			then
				nCanHurtCount = nCanHurtCount + 1

				if J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				then
					nCanKillCount = nCanKillCount + 1
				end
			end
		end

		if nCanKillCount >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, "Q带线补兵:"..nCanKillCount
		end
		if nCanHurtCount >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, "Q带线清兵:"..nCanHurtCount
		end

	end

	--肉山
	if J.IsDoingRoshan( bot )
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( bot, botTarget, nRadius - 200 )
			and J.GetHP( botTarget ) > 0.3
			and bot:GetMana() > 400
		then
			return BOT_ACTION_DESIRE_HIGH, "Q肉山:"
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


local lastAutoTime = 0
function X.ConsiderW()


	if not abilityW:IsFullyCastable() or bot:IsDisarmed() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = bot:GetAttackRange() + 50
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	local nAttackDamage = bot:GetAttackDamage()

	local nTowerList = bot:GetNearbyTowers( 800, true )
	local nEnemysHeroesInAttackRange = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, nCastRange, true, true )



	--切换自动施法
	if nLV >= 7
	then
		if ( hEnemyList[1] ~= nil
			or ( nLV >= 15 and nHP > 0.38 ) )
			and not abilityW:GetAutoCastState()
		then
			lastAutoTime = DotaTime()
			abilityW:ToggleAutoCast()
		elseif hEnemyList[1] == nil
				and lastAutoTime < DotaTime() - 3.0
				and abilityW:GetAutoCastState()
			then
				abilityW:ToggleAutoCast()
		end
	else
		if abilityW:GetAutoCastState()
		then
			abilityW:ToggleAutoCast()
		end
	end


	--低等级手动法球
	if nLV <= 6 and not abilityW:GetAutoCastState()
		and J.IsValidHero( botTarget )
		and J.IsInRange( bot, botTarget, nCastRange + 99 )
		and ( not J.IsRunning( bot ) or J.IsInRange( bot, botTarget, nCastRange + 39 ) )
		and not botTarget:IsMagicImmune()
		and not botTarget:IsAttackImmune()
	then
		return BOT_ACTION_DESIRE_HIGH, botTarget --, 'W手动:'..J.Chat.GetNormName( botTarget )
	end


	--对线主动进攻
	if J.IsLaning( bot ) and #nTowerList == 0 and nHP > 0.5
	then

		--补刀
		if J.IsWithoutTarget( bot )
			and not J.IsAttacking( bot )
		then
			local nLaneCreepList = bot:GetNearbyLaneCreeps( 666, true )
			for _, creep in pairs( nLaneCreepList )
			do
				if J.IsValid( creep )
					and not creep:HasModifier( "modifier_fountain_glyph" )
					and creep:GetHealth() < nAttackDamage * 2.8
					and not J.IsAllysTarget( creep )
				then
					local nAttackProDelayTime = J.GetAttackProDelayTime( bot, nCreep ) * 1.12 + 0.05
					local nAD = nAttackDamage * 1.0
					if J.WillKillTarget( creep, nAD, DAMAGE_TYPE_PHYSICAL, nAttackProDelayTime )
					then
						return BOT_ACTION_DESIRE_HIGH, creep, nAD..'W对线补刀:'..creep:GetHealth()
					end
				end
			end

		end

		--消耗近处的敌人
		local nWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, 600, true, true )
		local nAllyCreepList = bot:GetNearbyCreeps( 500, false )
		local nEnemyCreepList = bot:GetNearbyCreeps( 800, false )
		if nWeakestEnemyHero ~= nil
			and #nAllyCreepList >= 1
			and #nEnemyCreepList - #nAllyCreepList <= 4
			and not nWeakestEnemyHero:IsMagicImmune()
			and not bot:WasRecentlyDamagedByCreep( 1.5 )
		then
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHero, 'W对线进攻:'..J.Chat.GetNormName( nWeakestEnemyHero )
		end


		--不耽误正补的情况下消耗远处敌人


		--敌人被小兵堆包围时上前消耗
	end

	--修改攻击目标
	if botTarget ~= nil
		and botTarget:IsHero()
		and not J.IsInRange( bot, botTarget, nCastRange + 120 )
		and J.IsValid( nInAttackRangeWeakestEnemyHero )
		and not nInAttackRangeWeakestEnemyHero:IsAttackImmune()
		and not nInAttackRangeWeakestEnemyHero:IsMagicImmune()
	then
		bot:SetTarget( nInAttackRangeWeakestEnemyHero )
		return BOT_ACTION_DESIRE_HIGH, nInAttackRangeWeakestEnemyHero, "W修改目标"
	end

	--打架
	if J.IsGoingOnSomeone( bot ) and not abilityW:GetAutoCastState()
	then
		if J.IsValidHero( botTarget )
			and not botTarget:IsAttackImmune()
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 80 )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget --, "W进攻:"..J.Chat.GetNormName( botTarget )
		end
	end
	
	
	--退无可退时
	

	--打钱
	if J.IsFarming( bot ) and nLV >= 7 and not abilityW:GetAutoCastState()
	then
		local nCreepList = bot:GetNearbyNeutralCreeps( nCastRange + 80 )
		local hMostHPCreep = J.GetMostHpUnit( nCreepList )
		local hTargetCreep = nil
		local nTargetHealth = 0
		for _, creep in pairs( nCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_huskar_burning_spear_debuff" )
				and creep:GetHealth() > nTargetHealth
			then
				hTargetCreep = creep
				nTargetHealth = creep:GetHealth()
			end
		end

		if hTargetCreep ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, hTargetCreep, "W打野buff"
		end

		if hMostHPCreep ~= nil
			and not J.CanKillTarget( hMostHPCreep, nAttackDamage * 2.6, DAMAGE_TYPE_PHYSICAL )
		then
			return BOT_ACTION_DESIRE_HIGH, hMostHPCreep, "W打野消耗"
		end

	end


	--带线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and nLV > 9 and #hEnemyList <= 1 and not abilityW:GetAutoCastState()
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 80, true )
		local nAllyLaneCreeps = bot:GetNearbyLaneCreeps( 1200, false )
		local nWeakestCreep = J.GetAttackableWeakestUnit( bot, nCastRange + 200, false, true )

		if ( #nAllyLaneCreeps == 0
			or ( nWeakestCreep ~= nil and nWeakestCreep:GetHealth() > bot:GetAttackDamage() + 88 ) )
			and #nEnemyLaneCreeps >= 2
		then
			local hTargetCreep = nil
			local nTargetHealth = 0
			for _, creep in pairs( nEnemyLaneCreeps )
			do
				if J.IsValid( creep )
					and not J.IsKeyWordUnit( 'siege', creep )
					and not creep:HasModifier( "modifier_huskar_burning_spear_debuff" )
					and not J.CanKillTarget( creep, nAttackDamage * 1.68, DAMAGE_TYPE_PHYSICAL )
					and creep:GetHealth() > nTargetHealth
				then
					hTargetCreep = creep
					nTargetHealth = creep:GetHealth()
				end
			end

			if hTargetCreep ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, hTargetCreep, "W带线"
			end
		end

	end


	--肉山
	if J.IsDoingRoshan( bot ) and not abilityW:GetAutoCastState()
	then
		if J.IsRoshan( bot:GetAttackTarget() )
			and J.IsInRange( bot, botTarget, nCastRange -40 )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "W肉山"
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange() + talent6Range + aetherRange
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and ( J.IsInRange( bot, botTarget, nCastRange + 88 )
				  or J.IsInRange( bot, botTarget, bot:GetAttackRange() + 99 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "R进攻"..J.Chat.GetNormName( botTarget )
		end
	end


	--跳跃
	if nLV >= 12 and #hEnemyList == 0
		and nHP > 0.38 and #hAllyList < 3
		and nCastRange > bot:GetAttackRange() + 58
	then
		if J.IsValid( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsInRange( bot, botTarget, nCastRange -80 )
			and J.GetHP( botTarget ) > 0.9
			and not botTarget:IsHero()
			and not J.IsRoshan( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "R跳跃"
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


return X
-- dota2jmz@163.com QQ:2462331592..



