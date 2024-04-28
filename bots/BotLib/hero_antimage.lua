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
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,2,2,2,1,6,3,3,3,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {
	"item_tango",
	"item_double_branches",
	"item_quelling_blade",
	"item_orb_of_venom",

	"item_magic_wand",
	"item_orb_of_corrosion",
	"item_power_treads",
	"item_bfury",--
	"item_manta",--
	"item_basher",
	"item_butterfly",--
	"item_skadi",--
	"item_abyssal_blade",--
	"item_monkey_king_bar",--
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_aghanims_shard",
}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
	"item_magic_wand",
	"item_orb_of_corrosion",
	"item_power_treads",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		if hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end


--[[

npc_dota_hero_antimage

"Ability1"		"antimage_mana_break"
"Ability2"		"antimage_blink"
"Ability3"		"antimage_counterspell"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"antimage_mana_void"
"Ability10"		"special_bonus_strength_10"
"Ability11"		"special_bonus_attack_speed_20"
"Ability12"		"special_bonus_unique_antimage_3"
"Ability13"		"special_bonus_agility_15"
"Ability14"		"special_bonus_unique_antimage_5"
"Ability15"		"special_bonus_unique_antimage"
"Ability16"		"special_bonus_unique_antimage_4"
"Ability17"		"special_bonus_unique_antimage_2"

modifier_antimage_mana_break
modifier_antimage_blink_illusion
modifier_antimage_spell_shield
modifier_antimage_counterspell_passive
modifier_antimage_counterspell

--]]

local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local CounterSpellAlly 	= bot:GetAbilityByName( 'antimage_counterspell_ally' )
local BlinkFragment		= bot:GetAbilityByName( 'antimage_mana_overload' )
local talent3 = bot:GetAbilityByName( sTalentList[3] )


local castWDesire, castWLocation
local castEDesire
local castRDesire, castRTarget
local CounterSpellAllyDesire, CounterSpellAllyTarget
local BlinkFragmentDesire, FragmentLocation
local castWEDesire, castWELocation, castWEType
local castWRDesire, castWRLocation, castWRTarget


local nKeepMana, nMP, nHP, nLV, hEnemyHeroList

function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 180
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	nLV = bot:GetLevel()
	hEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )

	if X.ConsiderSpecialE() > 0
	then
		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityE )
		return
	end

	BlinkFragmentDesire, FragmentLocation = X.ConsiderBlinkFragment()
	print(tostring(BlinkFragmentDesire)..": ", FragmentLocation)
	if (BlinkFragmentDesire > 0)
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnLocation(BlinkFragment, FragmentLocation)
		return
	end

	castWDesire, castWLocation = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return

	end
	
	castRDesire, castRTarget = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return

	end

	castEDesire = X.ConsiderE()
	if ( castEDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityE )
		return
	end

	CounterSpellAllyDesire, CounterSpellAllyTarget = X.ConsiderCounterSpellAlly()
	if (CounterSpellAllyDesire > 0)
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnEntity(CounterSpellAlly, CounterSpellAllyTarget)
		return
	end


	castWRDesire, castWRLocation, castWRTarget = X.ConsiderWR()
	if ( castWRDesire > 0 )
	then
		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWRLocation )
		bot:ActionQueue_UseAbilityOnEntity( abilityR, castWRTarget )
		return
	end

	castWEDesire, castWELocation, castWEType = X.ConsiderWE()
	if ( castWEDesire > 0 )
	then
		J.SetQueuePtToINT( bot, false )

		if castWEType == 'WE'
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityW, castWELocation )
			bot:ActionQueue_UseAbility( abilityE )
			return
		else
			bot:ActionQueue_UseAbility( abilityE )
			bot:ActionQueue_UseAbilityOnLocation( abilityW, castWELocation )
			return
		end

	end

end

function X.ConsiderSpecialE()

	if not bot:IsChanneling() or not abilityE:IsFullyCastable() then return 0 end

	if J.IsUnitTargetProjectileIncoming( bot, 303 )
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	return 0

end

function X.ConsiderWE()

	if nLV < 10
		or bot:IsRooted()
		or bot:IsMagicImmune()
		or abilityE:GetLevel() < 4
		or not abilityW:IsFullyCastable()
		or not abilityE:IsFullyCastable()
		or bot:HasModifier( "modifier_sniper_assassinate" )
		or bot:HasModifier( "modifier_bloodseeker_rupture" )
	then return 0 end

	local abilityWManaCost = abilityW:GetManaCost()
	local abilityEManaCost = abilityE:GetManaCost()

	if abilityEManaCost + abilityWManaCost > bot:GetMana() then return 0 end

	local nCastRange = 1200
	local nCastPoint = abilityW:GetCastPoint()
	local nAttackPoint = bot:GetAttackPoint()

	local nAllies =  J.GetAllyList( bot, 1200 )
	local nAlliesNearby =  J.GetAllyList( bot, 600 )

	local nEnemysHerosInView = hEnemyHeroList
	local nEnemysHerosInRange = bot:GetNearbyHeroes( nCastRange + 150, true, BOT_MODE_NONE )

	local npcTarget = J.GetProperTarget( bot )

	if J.IsRetreating( bot ) and #nEnemysHerosInRange > 0
		and J.ShouldEscape( bot ) and #nAlliesNearby <= 1
	then
		local loc = J.GetEscapeLoc()
		local location = J.Site.GetXUnitsTowardsLocation( bot, loc, nCastRange )
		return BOT_ACTION_DESIRE_MODERATE, location, 'EW'
	end

	if J.IsInTeamFight( bot, 1200 ) and nHP > 0.2 and nLV >= 12
		and ( npcTarget == nil or GetUnitToUnitDistance( bot, npcTarget ) > 1400 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and IsPlayerBot( npcEnemy:GetPlayerID() )
				and not npcEnemy:IsAttackImmune()
				and J.CanCastOnMagicImmune( npcEnemy )
				and not J.IsInRange( npcEnemy, bot, 850 )
				and J.IsInRange( npcEnemy, bot, nCastRange + 150 )
				and J.GetAroundTargetAllyHeroCount( npcEnemy, 660 ) == 0
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				local tableNearbyAllysHeroes = npcEnemy:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
				if npcEnemyHealth < npcWeakestEnemyHealth
					and #tableNearbyAllysHeroes >= 1
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = npcEnemy
				end
			end
		end

		if npcWeakestEnemy ~= nil
			and not npcWeakestEnemy:IsSilenced()
			and not npcWeakestEnemy:IsMuted()
			and not npcWeakestEnemy:IsHexed()
			and not npcWeakestEnemy:IsStunned()
		then
			local fLocation = npcWeakestEnemy:GetExtrapolatedLocation( nAttackPoint + nCastPoint + 0.1 )
			local bLocation = npcWeakestEnemy:GetExtrapolatedLocation( nCastPoint )
			if GetUnitToLocationDistance( bot, bLocation ) < GetUnitToLocationDistance( bot, fLocation )
			then
				bLocation = fLocation
			end

			if GetUnitToLocationDistance( bot, bLocation ) < nCastRange + 150
			then
				bot:SetTarget( npcWeakestEnemy )
				return BOT_ACTION_DESIRE_HIGH, bLocation, 'WE'
			end
		end
	end

	if J.IsGoingOnSomeone( bot ) and nLV >= 15
		and ( #nAllies >= 2 or #nEnemysHerosInView <= 1 )
	then
		if J.IsValidHero( npcTarget )
			and npcTarget:GetMana() > 49
			and IsPlayerBot( npcTarget:GetPlayerID() )
			and not J.IsInRange( npcTarget, bot, 650 )
			and J.IsInRange( npcTarget, bot, nCastRange + 150 )
			and not npcTarget:IsAttackImmune()
			and not npcTarget:IsMuted()
			and not npcTarget:IsHexed()
			and not npcTarget:IsStunned()
			and not npcTarget:IsSilenced()
			and J.CanCastOnMagicImmune( npcTarget )
			and J.GetAroundTargetAllyHeroCount( npcTarget, 650 ) == 0
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE )
			local tableNearbyAllysHeroes = npcTarget:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
			local tableAllEnemyHeroes = J.GetAllyList( npcTarget, 1600 )
			if ( #tableNearbyEnemyHeroes <= #tableNearbyAllysHeroes )
				or ( #tableAllEnemyHeroes <= 1 )
			then
				local fLocation = npcTarget:GetExtrapolatedLocation( nAttackPoint + nCastPoint + 0.38 )
				local bLocation = npcTarget:GetExtrapolatedLocation( nCastPoint )
				if GetUnitToLocationDistance( bot, bLocation ) < GetUnitToLocationDistance( bot, fLocation )
				then
					bLocation = fLocation
				end

				if GetUnitToLocationDistance( bot, bLocation ) < nCastRange + 150
				then
					bot:SetTarget( npcTarget )
					return BOT_ACTION_DESIRE_HIGH, bLocation, 'WE'
				end
			end
		end
	end


	return 0
end

function X.ConsiderW()
	if not abilityW:IsFullyCastable()
		or bot:IsRooted()
		or bot:HasModifier( "modifier_bloodseeker_rupture" )
	then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = 600 + 150 * nSkillLV
	local nCastPoint = abilityW:GetCastPoint()
	local nAttackPoint = bot:GetAttackPoint()

	local nAllies = J.GetAllyList( bot, 1200 )

	local nEnemysHerosInView = hEnemyHeroList
	local nEnemysHerosInRange = bot:GetNearbyHeroes( nCastRange + 150, true, BOT_MODE_NONE )
	local nEnemysHerosInBonus = bot:GetNearbyHeroes( nCastRange + 350, true, BOT_MODE_NONE )

	local nEnemysTowers = bot:GetNearbyTowers( 1300, true )
	local aliveEnemyCount = J.GetNumOfAliveHeroes( true )

	local npcTarget = J.GetProperTarget( bot )

	if J.IsStuck( bot )
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation( bot, loc, nCastRange )
	end

	if J.IsRetreating( bot ) or ( bot:GetActiveMode() == BOT_MODE_RETREAT and nHP < 0.16 and bot:DistanceFromFountain() > 600 )
	then
		if J.ShouldEscape( bot ) or ( bot:DistanceFromFountain() > 600 and  bot:DistanceFromFountain() < 3800 )
		then
			local loc = J.GetEscapeLoc()
			local location = J.Site.GetXUnitsTowardsLocation( bot, loc, nCastRange )
			return BOT_ACTION_DESIRE_MODERATE, location
		end
	end

	if J.IsGoingOnSomeone( bot ) and nLV >= 3
		and ( #nAllies >= 2 or #nEnemysHerosInView <= 1 )
	then
		if J.IsValidHero( npcTarget )
			and not npcTarget:IsAttackImmune()
			and J.CanCastOnMagicImmune( npcTarget )
			and not J.IsInRange( npcTarget, bot, 400 )
			and J.IsInRange( npcTarget, bot, nCastRange + 200 )
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 900, false, BOT_MODE_NONE )
			local tableNearbyAllysHeroes = npcTarget:GetNearbyHeroes( 1300, true, BOT_MODE_NONE )
			local tableAllEnemyHeroes = J.GetAllyList( npcTarget, 1600 )
			if ( J.WillKillTarget( npcTarget, bot:GetAttackDamage() * 3, DAMAGE_TYPE_PHYSICAL, 2.0 ) )
				or ( #tableNearbyEnemyHeroes <= #tableNearbyAllysHeroes )
				or ( #tableAllEnemyHeroes <= 1 )
				or ( aliveEnemyCount <= 2 )
			then
				local fLocation = npcTarget:GetExtrapolatedLocation( nAttackPoint + nCastPoint )
				local bLocation = npcTarget:GetExtrapolatedLocation( nCastPoint )
				if GetUnitToLocationDistance( bot, bLocation ) < GetUnitToLocationDistance( bot, fLocation )
				then
					bLocation = fLocation
				end
				if GetUnitToLocationDistance( bot, bLocation ) < nCastRange + 150
				then
					bot:SetTarget( npcTarget )
					return BOT_ACTION_DESIRE_HIGH, bLocation
				end
			end
		end
	end


	if ( bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7 )
		and #nEnemysHerosInView == 0 and #nEnemysTowers == 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 80, true )
		local keyWord = "ranged"
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.IsKeyWordUnit( keyWord, creep )
				and GetUnitToUnitDistance( creep, bot ) > 500
			then
				local nTime = nCastPoint + bot:GetAttackPoint()
				local nDamage = bot:GetAttackDamage() + 38
				if J.WillKillTarget( creep, nDamage, DAMAGE_TYPE_PHYSICAL, nTime * 0.9 )
				then
					bot:SetTarget( creep )
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
				end
			end
		end

		if nMP > 0.96
			and bot:DistanceFromFountain() > 60
			and bot:DistanceFromFountain() < 6000
			and bot:GetAttackTarget() == nil
			and bot:GetActiveMode() == BOT_MODE_LANING
		then
			local nLane = bot:GetAssignedLane()
			local nLaneFrontLocation = GetLaneFrontLocation( GetTeam(), nLane, 0 )
			local nDist = GetUnitToLocationDistance( bot, nLaneFrontLocation )

			if nDist > 2000
			then
				local location = J.Site.GetXUnitsTowardsLocation( bot, nLaneFrontLocation, nCastRange )
				if IsLocationPassable( location )
				then
					return BOT_ACTION_DESIRE_HIGH, location
				end
			end
		end
	end

	if J.IsFarming( bot )
	then
		if npcTarget ~= nil and npcTarget:IsAlive()
			and GetUnitToUnitDistance( bot, npcTarget ) > 550
			and ( nLV > 9 or not npcTarget:IsAncientCreep() )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
		end
	end


	local nAttackAllys = bot:GetNearbyHeroes( 1600, false, BOT_MODE_ATTACK )
	if #nEnemysHerosInView == 0 and not bot:WasRecentlyDamagedByAnyHero( 3.0 ) and nLV >= 10
		and #nAttackAllys == 0 and ( npcTarget == nil or not npcTarget:IsHero() )
	then
		local nAOELocation = bot:FindAoELocation( true, false, bot:GetLocation(), 1600, 400, 0, 0 )
		local nLaneCreeps = bot:GetNearbyLaneCreeps( 1600, true )
		if nAOELocation.count >= 3
			and #nLaneCreeps >= 3
		then
			local bCenter = J.GetCenterOfUnits( nLaneCreeps )
			local bDist = GetUnitToLocationDistance( bot, bCenter )
			local vLocation = J.Site.GetXUnitsTowardsLocation( bot, bCenter, bDist + 550 )
			local bLocation = J.Site.GetXUnitsTowardsLocation( bot, bCenter, bDist - 350 )
			if bDist >= 1500 then bLocation = J.Site.GetXUnitsTowardsLocation( bot, bCenter, 1150 ) end

			if IsLocationPassable( bLocation )
				and IsLocationVisible( vLocation )
				and GetUnitToLocationDistance( bot, bLocation ) > 600
			then
				return BOT_ACTION_DESIRE_HIGH, bLocation
			end
		end
	end

	return 0
end

function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return 0 end

	if J.IsUnitTargetProjectileIncoming( bot, 400 )
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if not bot:HasModifier( "modifier_sniper_assassinate" )
		and not bot:IsMagicImmune()
	then
		if J.IsWillBeCastUnitTargetSpell( bot, 1400 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return 0
end

function X.ConsiderWR()

	if nLV < 6
		or bot:IsRooted()
		or not abilityW:IsFullyCastable()
		or not abilityR:IsFullyCastable()
	then return 0 end

	local abilityWManaCost = abilityW:GetManaCost()
	local abilityRManaCost = abilityR:GetManaCost()

	if abilityWManaCost + abilityRManaCost > bot:GetMana() then return 0 end

	local rCastRange = abilityR:GetCastRange()
	local rCastPoint = abilityR:GetCastPoint()
	local wCastRange = 1200
	local wCastPoint = abilityW:GetCastPoint()
	local nDelayTime = rCastPoint + wCastPoint
	local nAoeRange = 500
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nDamagaPerHealth = abilityR:GetSpecialValueFloat( "mana_void_damage_per_mana" )
	local nCastTarget = nil

	local nMaxRange = rCastRange + wCastRange + 50

	local nEnemysHerosCanSeen = GetUnitList( UNIT_LIST_ENEMY_HEROES )

	for _, npcEnemy in pairs( nEnemysHerosCanSeen )
	do

		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and J.IsInRange( npcEnemy, bot, nMaxRange )
			and not J.IsInRange( npcEnemy, bot, rCastRange + 300 )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then
			local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )

			for _, enemy in pairs( nEnemysHerosCanSeen )
			do
				if GetUnitToLocationDistance( npcEnemy, enemy:GetExtrapolatedLocation( nDelayTime ) ) < nAoeRange
					and J.CanCastOnNonMagicImmune( enemy )
					and not J.IsHaveAegis( enemy )
					and not enemy:HasModifier( "modifier_arc_warden_tempest_double" )
					and J.WillMagicKillTarget( bot, enemy, EstDamage, nDelayTime )
				then
					nCastTarget = npcEnemy
					break
				end
			end

			if ( nCastTarget ~= nil )
			then
				return BOT_ACTION_DESIRE_HIGH, nCastTarget:GetLocation(), nCastTarget
			end
		end
	end


	return 0
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

	local nCastRange = abilityR:GetCastRange()
	local CastPoint = abilityR:GetCastPoint()
	local nAoeRange = 500
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nDamagaPerHealth = abilityR:GetSpecialValueFloat( "mana_void_damage_per_mana" )
	local nCastTarget = nil

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 200 )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.CanCastOnTargetAdvanced( npcTarget )
			and not J.IsHaveAegis( npcTarget )
			and not npcTarget:HasModifier( "modifier_arc_warden_tempest_double" )
		then
			local EstDamage = nDamagaPerHealth * ( npcTarget:GetMaxMana() - npcTarget:GetMana() )
			if J.WillMagicKillTarget( bot, npcTarget, EstDamage, CastPoint )
			then
				nCastTarget = npcTarget
				return BOT_ACTION_DESIRE_HIGH, nCastTarget
			end
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 700, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and not J.IsHaveAegis( npcEnemy )
				and not npcEnemy:HasModifier( "modifier_arc_warden_tempest_double" )
				and J.IsInRange( npcEnemy, bot, nCastRange + 150 )
				and ( J.WillMagicKillTarget( bot, npcEnemy, EstDamage, CastPoint ) )
			then
				nCastTarget = npcEnemy
				break
			end
		end

		if ( nCastTarget ~= nil )
		then
			bot:SetTarget( nCastTarget )
			return BOT_ACTION_DESIRE_HIGH, nCastTarget
		end
	end

	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE )
	for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
		local TPerMana = npcEnemy:GetMana()/npcEnemy:GetMaxMana()
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then

			if npcEnemy:IsChanneling()
				and npcEnemy:HasModifier( "modifier_teleporting" )
				and not npcEnemy:HasModifier( "modifier_arc_warden_tempest_double" )
			then
				nCastTarget = npcEnemy
			end

			if TPerMana < 0.01
				and not J.IsHaveAegis( npcEnemy )
				and not npcEnemy:HasModifier( "modifier_arc_warden_tempest_double" )
				and ( J.WillMagicKillTarget( bot, npcEnemy, EstDamage * 1.68, CastPoint )
					  or ( J.GetAroundTargetEnemyHeroCount( npcEnemy, nAoeRange ) >= 3 and J.CanKillTarget( npcEnemy, EstDamage * 1.98, nDamageType ) )
					  or nHP < 0.25 )
			then
				nCastTarget = npcEnemy
			end

			local nEnemys = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
			for _, enemy in pairs( nEnemys )
			do
				if GetUnitToLocationDistance( npcEnemy, enemy:GetExtrapolatedLocation( CastPoint ) ) < nAoeRange
					and J.CanCastOnNonMagicImmune( enemy )
					and not J.IsHaveAegis( enemy )
					and not enemy:HasModifier( "modifier_arc_warden_tempest_double" )
					and J.WillMagicKillTarget( bot, enemy, EstDamage, CastPoint )
				then
					nCastTarget = npcEnemy
					break
				end
			end

			if ( nCastTarget ~= nil )
			then
				bot:SetTarget( nCastTarget )
				return BOT_ACTION_DESIRE_HIGH, nCastTarget
			end
		end
	end


	return 0
end

function X.ConsiderCounterSpellAlly()
	if not J.HasAghanimsShard(bot)
	or not CounterSpellAlly:IsTrained()
	or not CounterSpellAlly:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local cCastRange = CounterSpellAlly:GetCastRange()
	local nAllyHeroes = bot:GetNearbyHeroes(cCastRange, false, BOT_MODE_NONE)

	for _, ally in pairs(nAllyHeroes) do
		if J.IsInRange(bot, ally, cCastRange)
		and J.IsUnitTargetProjectileIncoming(ally, 400)
		and not ally:IsMagicImmune()
		then
			return BOT_ACTION_DESIRE_HIGH, ally
		end

		if not ally:HasModifier("modifier_sniper_assassinate")
		and not ally:IsMagicImmune()
		then
			if J.IsWillBeCastUnitTargetSpell(ally, cCastRange)
			then
				return BOT_ACTION_DESIRE_HIGH, ally
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBlinkFragment()
	if not bot:HasScepter()
	or not BlinkFragment:IsTrained()
	or not BlinkFragment:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = abilityW:GetSpecialValueInt('value')
	local nCastPoint = BlinkFragment:GetCastPoint()
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local npcTarget = J.GetProperTarget(bot)

	if J.IsRetreating(bot)
	and (nEnemysHerosInRange ~= nil and #nEnemysHerosInRange > 0)
	then
		bot:SetTarget(nEnemysHerosInRange[1])
		return BOT_ACTION_DESIRE_MODERATE, nEnemysHerosInRange[1]:GetLocation()
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(npcTarget)
		and not npcTarget:IsAttackImmune()
		and J.IsInRange(npcTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

return X