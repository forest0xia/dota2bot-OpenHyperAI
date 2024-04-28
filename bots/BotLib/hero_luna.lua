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
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,1,3,1,6,1,2,2,2,6,2,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRandomItem_1 = RandomInt( 1, 9 ) > 5 and "item_greater_crit" or "item_butterfly"

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_ranged_carry_outfit",
	"item_dragon_lance",
	"item_yasha",
	"item_point_booster",
	"item_aghanims_shard",
	"item_manta",
	"item_skadi",
	"item_hurricane_pike",
	"item_travel_boots",
	"item_black_king_bar",
	sRandomItem_1,
	"item_moon_shard",
	"item_travel_boots_2",
	"item_ultimate_scepter_2",


}

tOutFitList['outfit_mid'] = {

	"item_mid_outfit",
	"item_dragon_lance",
	"item_aghanims_shard",
	"item_manta",
	"item_skadi",
	"item_hurricane_pike",
	"item_black_king_bar",
	"item_travel_boots",
	sRandomItem_1,
	"item_moon_shard",
	"item_travel_boots_2",
	"item_ultimate_scepter_2",


}

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']


X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_black_king_bar",
	"item_magic_wand",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_ranged_carry' }, {} end

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

npc_dota_hero_luna

"Ability1"		"luna_lucent_beam"
"Ability2"		"luna_moon_glaive"
"Ability3"		"luna_lunar_blessing"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"luna_eclipse"
"Ability10"		"special_bonus_attack_speed_15"
"Ability11"		"special_bonus_cast_range_300"
"Ability12"		"special_bonus_unique_luna_2"
"Ability13"		"special_bonus_movement_speed_30"
"Ability14"		"special_bonus_all_stats_8"
"Ability15"		"special_bonus_unique_luna_1"
"Ability16"		"special_bonus_lifesteal_25"
"Ability17"		"special_bonus_unique_luna_5"

modifier_luna_moon_glaive
modifier_luna_lunar_blessing
modifier_luna_lunar_blessing_aura
modifier_luna_eclipse

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget = 0
local castRDesire = 0

local nKeepMana, nMP, nHP, nLV
local aetherRange = 0
local talent6BonusDamage = 0

function X.SkillsComplement()

	J.ConsiderTarget()

	if J.CanNotUseAbility( bot ) then return end

	nKeepMana = 400
	aetherRange = 0
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	nLV = bot:GetLevel()

	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end

--	if talent2:IsTrained() then aetherRange = aetherRange + talent2:GetSpecialValueInt( "value" ) end
	if talent6:IsTrained() then talent6BonusDamage = talent6:GetSpecialValueInt( "value" ) end


	castRDesire = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		if bot:HasScepter()
		then
			bot:ActionQueue_UseAbilityOnEntity( abilityR, bot )
			return
		else
			bot:ActionQueue_UseAbility( abilityR )
			return
		end

	end

	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable()
		or bot:IsInvisible()
		or ( nLV >= 6 and abilityR:GetCooldownTimeRemaining() <= 2.0 and ( bot:GetMana() - abilityQ:GetManaCost() ) < abilityR:GetManaCost() )
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nSkillLV = abilityQ:GetLevel()
	local nDamage = 75 * nSkillLV + talent6BonusDamage
	local nDamageType = DAMAGE_TYPE_MAGICAL

	local nAllies =  bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )

	local nEnemysHerosInView = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	local nEnemysHerosInRange = bot:GetNearbyHeroes( nCastRange + 32, true, BOT_MODE_NONE )
	local nEnemysHerosInBonus = bot:GetNearbyHeroes( nCastRange + 300, true, BOT_MODE_NONE )


	--打断和击杀
	for _, npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			if npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end

			if J.IsInRange( bot, npcEnemy, nCastRange + 80 )
				and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end

		end
	end

	--团战中对血量最低的敌人使用
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
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
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy
		end
	end

	--受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nEnemysHerosInRange >= 1
		and nLV >= 10
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 75 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end


	--打架时先手
	if J.IsGoingOnSomeone( bot ) and ( nLV >= 5 or nMP > 0.62 )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.CanCastOnTargetAdvanced( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 32 )
			and not J.IsDisabled( npcTarget )
			and not npcTarget:IsDisarmed()
		then
			if nSkillLV >= 4 or nMP > 0.88 or J.GetHP( npcTarget ) < 0.38
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget
			end
		end
	end

	--撤退时保护自己
	if J.IsRetreating( bot )
		and #nEnemysHerosInBonus <= 2
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	--对线期间对线上小兵使用
	if bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 200, true )
		local keyWord = "ranged"
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.IsKeyWordUnit( keyWord, creep )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				and GetUnitToUnitDistance( creep, bot ) > bot:GetAttackRange() + 80
			then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
		end

		if nSkillLV >= 2
			and ( bot:GetMana() > 330 or nMP > 0.95 )
		then
			local keyWord = "melee"
			for _, creep in pairs( nLaneCreeps )
			do
				if J.IsValid( creep )
					and not creep:HasModifier( "modifier_fountain_glyph" )
					and J.IsKeyWordUnit( keyWord, creep )
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
					and GetUnitToUnitDistance( creep, bot ) > bot:GetAttackRange() + 80
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end

	--发育时对野怪输出
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and ( bot:GetAttackDamage() < 200 or nMP > 0.78 )
		and J.IsAllowedToSpam( bot, nManaCost * 0.15 )
	then
		local nCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 100 )

		local targetCreep = J.GetMostHpUnit( nCreeps )

		if J.IsValid( targetCreep )
			and ( #nCreeps >= 2 or GetUnitToUnitDistance( targetCreep, bot ) <= 400 )
			and bot:IsFacingLocation( targetCreep:GetLocation(), 30 )
			and not J.IsRoshan( targetCreep )
			and ( targetCreep:GetMagicResist() < 0.3 or nMP > 0.95 )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 1.68, DAMAGE_TYPE_PHYSICAL )
			and not J.CanKillTarget( targetCreep, nDamage - 10, nDamageType )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep
		end
	end


	--推进时对小兵用
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and ( bot:GetAttackDamage() < 200 or nMP > 0.9 )
		and nSkillLV >= 3
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange, true )
		local keyWord = "ranged"
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and ( J.IsKeyWordUnit( keyWord, creep ) or nMP > 0.8 )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				and not J.CanKillTarget( creep, bot:GetAttackDamage() * 1.68, DAMAGE_TYPE_PHYSICAL )
			then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
		end
	end

	--打肉的时候输出
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 400
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

	--通用消耗敌人或受到伤害时保护自己
	if ( #nEnemysHerosInView > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAllies >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 10
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and not J.IsDisabled( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	return 0

end

function X.ConsiderR()

	if not abilityR:IsFullyCastable()
		or ( bot:WasRecentlyDamagedByAnyHero( 1.5 ) and  nHP < 0.38 )
		or bot:DistanceFromFountain() < 600
	then return 0 end

	local nRadius = 675

	local nEnemysHerosInSkillRange = bot:GetNearbyHeroes( 675, true, BOT_MODE_NONE )
	local nEnemysHerosNearby	 = bot:GetNearbyHeroes( 350, true, BOT_MODE_NONE )


	if #nEnemysHerosInSkillRange >= 3
		or ( #nEnemysHerosNearby >= 1 and #nEnemysHerosInSkillRange >= 2 )
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	local nAoe = bot:FindAoELocation( true, true, bot:GetLocation(), 100, 600, 0.8, 0 )
	if nAoe.count >= 3
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	local npcTarget = J.GetProperTarget( bot )
	if J.IsValidHero( npcTarget )
		and J.CanCastOnNonMagicImmune( npcTarget )
		and ( GetUnitToUnitDistance( npcTarget, bot ) <= 450
				or ( J.GetHP( npcTarget ) < 0.38 and  GetUnitToUnitDistance( npcTarget, bot ) <= 650 ) )
		and npcTarget:GetHealth() > 600
	then
		return BOT_ACTION_DESIRE_HIGH
	end


	return 0
end

return X
-- dota2jmz@163.com QQ:2462331592..
