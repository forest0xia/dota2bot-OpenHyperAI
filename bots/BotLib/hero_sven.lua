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
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,2,2,2,6,2,3,3,3,6,1,1,1,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
	"item_double_branches",
	"item_faerie_fire",
	"item_quelling_blade",

	"item_power_treads",
	"item_mask_of_madness",
	"item_magic_wand",
	"item_echo_sabre",
	"item_blink",
	"item_black_king_bar",--
	"item_greater_crit",--
	"item_harpoon",--
	"item_satanic",--
	"item_swift_blink",--
	"item_moon_shard",
	"item_orchid",
	"item_bloodthorn",--
	"item_ultimate_scepter_2",
	"item_aghanims_shard",

}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_quelling_blade",
	"item_magic_wand",
	"item_mask_of_madness",
	"item_power_treads",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_str_carry' }, {"item_power_treads", 'item_quelling_blade'} end

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

npc_dota_hero_sven

"Ability1"		"sven_storm_bolt"
"Ability2"		"sven_great_cleave"
"Ability3"		"sven_warcry"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"sven_gods_strength"
"Ability10"		"special_bonus_strength_8"
"Ability11"		"special_bonus_mp_regen_3"
"Ability12"		"special_bonus_movement_speed_30"
"Ability13"		"special_bonus_unique_sven_3"
"Ability14"		"special_bonus_lifesteal_25"
"Ability15"		"special_bonus_unique_sven"
"Ability16"		"special_bonus_unique_sven_2"
"Ability17"		"special_bonus_unique_sven_4"

modifier_sven_great_cleave
modifier_sven_warcry
modifier_sven_gods_strength
modifier_sven_gods_strength_child

--]]


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castEDesire
local castRDesire

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList


function X.SkillsComplement()


	J.ConsiderForMkbDisassembleMask( bot )
	X.SvenConsiderTarget()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )


	castRDesire = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityR )
		return

	end

	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return

	end

	castEDesire = X.ConsiderE()
	if ( castEDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityE )
		return

	end

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end

	local nCastRange = abilityQ:GetCastRange()
	
	if nCastRange > 1000 then nCastRange = 1000 end
	
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nSkillLV = abilityQ:GetLevel()
	local nDamage = 80 * nSkillLV
	local nRadius = 255
	local nDamageType = DAMAGE_TYPE_MAGICAL

	local nAllies =  J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE )

	if #hEnemyHeroList == 1
		and J.IsValidHero( hEnemyHeroList[1] )
		and J.IsInRange( hEnemyHeroList[1], bot, nCastRange + 350 )
		and hEnemyHeroList[1]:IsFacingLocation( bot:GetLocation(), 30 )
		and hEnemyHeroList[1]:GetAttackRange() > nCastRange
		and hEnemyHeroList[1]:GetAttackRange() < 1250
	then
		nCastRange = nCastRange + 260
	end

	local nEnemysHerosInRange = J.GetNearbyHeroes(bot, nCastRange + 43, true, BOT_MODE_NONE )
	local nEnemysHerosInBonus = J.GetNearbyHeroes(bot, nCastRange + 350, true, BOT_MODE_NONE )

	local nEmemysCreepsInRange = bot:GetNearbyCreeps( nCastRange + 43, true )

	--打断和击杀
	for _, npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and not J.IsDisabled( npcEnemy )
		then
			if npcEnemy:IsChanneling()
				or J.CanKillTarget( npcEnemy, nDamage, nDamageType )
			then

				--隔空打断击杀目标
				local nBetterTarget = nil
				local nAllEnemyUnits = J.CombineTwoTable( nEnemysHerosInRange, nEmemysCreepsInRange )
				for _, enemy in pairs( nAllEnemyUnits )
				do
					if J.IsValid( enemy )
						and J.IsInRange( npcEnemy, enemy, nRadius )
						and J.CanCastOnNonMagicImmune( enemy )
						and J.CanCastOnTargetAdvanced( enemy )
					then
						nBetterTarget = enemy
						break
					end
				end

				if nBetterTarget ~= nil
					and not J.IsInRange( npcEnemy, bot, nCastRange )
				then
					--打断或击杀更优目标
					return BOT_ACTION_DESIRE_HIGH, nBetterTarget
				else
					--打断或击杀目标
					return BOT_ACTION_DESIRE_HIGH, npcEnemy
				end
			end
		end
	end

	--团战中对作用数量最多或物理输出最强的敌人使用
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcMostAoeEnemy = nil
		local nMostAoeECount = 1
		local nAllEnemyUnits = J.CombineTwoTable( nEnemysHerosInRange, nEmemysCreepsInRange )

		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		for _, npcEnemy in pairs( nAllEnemyUnits )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then

				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount( npcEnemy, nRadius )
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount
					npcMostAoeEnemy = npcEnemy
				end

				if npcEnemy:IsHero()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL )
					if ( npcEnemyDamage > nMostDangerousDamage )
					then
						nMostDangerousDamage = npcEnemyDamage
						npcMostDangerousEnemy = npcEnemy
					end
				end
			end
		end

		if ( npcMostAoeEnemy ~= nil )
		then
			--团战控制数量多
			return BOT_ACTION_DESIRE_HIGH, npcMostAoeEnemy
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy
		end
	end

	--对线期间对敌方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 5
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and J.GetAttackEnemysAllyCreepCount( npcEnemy, 1400 ) >= 5
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	--打架时先手
	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.CanCastOnTargetAdvanced( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 60 )
			and not J.IsDisabled( npcTarget )
			and not npcTarget:IsDisarmed()
		then
			if nSkillLV >= 3 or nMP > 0.88 or J.GetHP( npcTarget ) < 0.38 or nHP < 0.25
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget
			end
		end
	end

	--撤退时保护自己
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
						or nMP > 0.8
						or GetUnitToUnitDistance( bot, npcEnemy ) <= 400 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	--发育时对野怪输出
	if J.IsFarming( bot ) and nSkillLV >= 3
		and ( bot:GetAttackDamage() < 200 or nMP > 0.88 )
		and nMP > 0.78
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps( 700 )
		if #nNeutralCreeps >= 3
		then
			for _, creep in pairs( nNeutralCreeps )
			do
				if J.IsValid( creep )
					and creep:GetHealth() >= 900
					and creep:GetMagicResist() < 0.3
					and J.IsInRange( creep, bot, 350 )
					and J.GetAroundTargetEnemyUnitCount( creep, nRadius ) >= 3
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end


	--推进时对小兵用
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and ( bot:GetAttackDamage() < 200 or nMP > 0.9 )
		and nSkillLV >= 4 and #hEnemyHeroList == 0 and nMP > 0.68
		and not J.IsInEnemyArea( bot )
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( 1000, true )
		if #nLaneCreeps >= 5
		then
			for _, creep in pairs( nLaneCreeps )
			do
				if J.IsValid( creep )
					and creep:GetHealth() >= 500
					and not creep:HasModifier( "modifier_fountain_glyph" )
					and J.IsInRange( creep, bot, nCastRange + 100 )
					and J.GetAroundTargetEnemyUnitCount( creep, nRadius ) >= 5
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end

	--打肉的时候输出
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 600
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsRoshan( npcTarget )
			and not J.IsDisabled( npcTarget )
			and not npcTarget:IsDisarmed()
			and J.IsInRange( npcTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end

	--通用受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 45 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	--通用消耗敌人或保护自己
	if ( #hEnemyHeroList > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAllies >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	return 0, nil
end

function X.ConsiderE()

	if not abilityE:IsFullyCastable()
		or ( #hEnemyHeroList == 0 and nHP > 0.2 )
	then
		return 0
	end

	local nSkillRange = 700

	local nAllies = J.GetAllyList( bot, nSkillRange )
	local nAlliesCount = #nAllies
	local nWeakestAlly = J.GetLeastHpUnit( nAllies )
	if nWeakestAlly == nil then nWeakestAlly = bot end
	local nWeakestAllyHP = J.GetHP( nWeakestAlly )

	local nEnemysHerosNearby = nWeakestAlly:GetNearbyHeroes( 800, true, BOT_MODE_NONE )

	local nBonusPer = ( #nEnemysHerosNearby )/20

	local nShouldBonusCount = 1
	if nWeakestAllyHP > 0.35 + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end
	if nWeakestAllyHP > 0.50 + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end
	if nWeakestAllyHP > 0.65 + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end
	if nWeakestAllyHP > 0.9 + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end

	--根据血量决定作用人数
	if nAlliesCount >= nShouldBonusCount
		and #nEnemysHerosNearby >= 1
		and nWeakestAlly:WasRecentlyDamagedByAnyHero( 4.0 )
	then
		return BOT_ACTION_DESIRE_HIGH
	end


	if J.IsRetreating( nWeakestAlly )
		and nWeakestAlly:GetHealth() < 800
		and J.IsRunning( nWeakestAlly )
		and nWeakestAlly:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		return BOT_ACTION_DESIRE_HIGH
	end


	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.IsInRange( npcTarget, bot, 600 )
			and bot:IsFacingLocation( npcTarget:GetLocation(), 15 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	
	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and #nEnemysHerosNearby >= 1
		and bot:GetHealth() / bot:GetMaxHealth() < 0.85
	then
		return BOT_ACTION_DESIRE_HIGH	
	end
	

	return 0
end


function X.ConsiderR()

	if not abilityR:IsFullyCastable()
	then
		return 0
	end

	local nEnemysHerosInBonus = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )

	--打架时先手
	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and ( J.GetHP( npcTarget ) > 0.25 or #nEnemysHerosInBonus >= 2 )
			and ( J.IsInRange( npcTarget, bot, 700 )
				or J.IsInRange( npcTarget, bot, npcTarget:GetAttackRange() + 80 ) )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	--撤退时保护自己
	if bot:GetActiveMode() == BOT_MODE_RETREAT
		and bot:DistanceFromFountain() > 800
		and nHP > 0.5
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and #nEnemysHerosInBonus >= 1
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	return 0
end

function X.SvenConsiderTarget()

	local bot = GetBot()

	if not J.IsRunning( bot )
	then return end

	local npcTarget = bot:GetAttackTarget()
	if not J.IsValidHero( npcTarget ) then return end

	local nAttackRange = bot:GetAttackRange() + 50
	local nEnemyHeroInRange = J.GetNearbyHeroes(bot, nAttackRange, true, BOT_MODE_NONE )

	local nInAttackRangeNearestEnemyHero = nEnemyHeroInRange[1]

	if J.IsValidHero( nInAttackRangeWeakestEnemyHero )
		and J.CanBeAttacked( nInAttackRangeWeakestEnemyHero )
		and ( GetUnitToUnitDistance( npcTarget, bot ) >  350 or U.HasForbiddenModifier( npcTarget ) )
	then
		--更改目标为
		bot:SetTarget( nInAttackRangeWeakestEnemyHero )
		return
	end

end

return X
-- dota2jmz@163.com QQ:2462331592..
