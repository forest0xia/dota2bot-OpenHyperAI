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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,1,2,2,2,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_priest_outfit",
	"item_rod_of_atos",
--	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_force_staff",
	"item_cyclone",
	"item_gungir",
	"item_wind_waker",
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_sheepstick",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = {

	"item_priest_outfit",
	"item_urn_of_shadows",
	"item_mekansm",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_guardian_greaves", 
	"item_spirit_vessel",
--	"item_wraith_pact",
	"item_ultimate_scepter",
	"item_shivas_guard",
	"item_moon_shard",
	"item_sheepstick",
	"item_ultimate_scepter_2",

}

tOutFitList['outfit_mage'] = {

	"item_mage_outfit",
	--"item_soul_ring",
	"item_rod_of_atos",
	"item_ancient_janggo",
	"item_glimmer_cape",
	"item_boots_of_bearing",
	"item_pipe",
	"item_aghanims_shard",
	"item_veil_of_discord",
	"item_ultimate_scepter",
	"item_gungir",
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_sheepstick",

}

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_veil_of_discord",
	"item_magic_wand",
	
	"item_ultimate_scepter",
	"item_magic_wand",

	"item_sheepstick",
	"item_magic_wand",

}

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

npc_dota_hero_skywrath_mage

"Ability1"		"skywrath_mage_arcane_bolt"
"Ability2"		"skywrath_mage_concussive_shot"
"Ability3"		"skywrath_mage_ancient_seal"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"skywrath_mage_mystic_flare"
"Ability10"		"special_bonus_movement_speed_20"
"Ability11"		"special_bonus_intelligence_8"
"Ability12"		"special_bonus_unique_skywrath"
"Ability13"		"special_bonus_unique_skywrath_2"
"Ability14"		"special_bonus_unique_skywrath_4"
"Ability15"		"special_bonus_unique_skywrath_3"
"Ability16"		"special_bonus_gold_income_50"
"Ability17"		"special_bonus_unique_skywrath_5"

modifier_skywrath_mage_concussive_shot_slow
modifier_skywrath_mage_ancient_seal
modifier_skywrath_mage_mystic_flare
modifier_skywrath_mystic_flare_aura_effect


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castWDesire
local castEDesire, castETarget
local castRDesire, castRLocation


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive

local aetherRange = 0

function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end


	castEDesire, castETarget, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end

	castRDesire, castRLocation, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation )
		return

	end

	castWDesire, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityW )
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
	local nDamage = abilityQ:GetSpecialValueInt( "bolt_damage" ) + bot:GetAttributeValue( ATTRIBUTE_INTELLECT ) * 1.6
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyHeroList = bot:GetNearbyHeroes( nCastRange + 50, true, BOT_MODE_NONE )
	local nAttackDamage = bot:GetAttackDamage()


	local hAllyList = bot:GetNearbyHeroes( 1300, false, BOT_MODE_NONE )


	if ( not J.IsValidHero( botTarget ) or J.GetHP( botTarget ) > 0.2 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and J.GetHP( npcEnemy ) <= 0.2
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "Q击杀"..npcEnemy:GetUnitName()
			end
		end
	end


	--对线期的使用
	if bot:GetActiveMode() == BOT_MODE_LANING
		and ( hAllyList[2] == nil or not J.IsHumanPlayer( hAllyList[2] ) )
		and #hAllyList <= 2
	then
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nCastRange + 50, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.IsKeyWordUnit( "ranged", creep )
				and not J.IsOtherAllysTarget( creep )
				and creep:GetHealth() > nDamage * 0.68
			then
				local nDelay = nCastPoint + GetUnitToUnitDistance( bot, creep )/500
				if J.WillKillTarget( creep, nDamage, nDamageType, nDelay * 0.9 )
					and not J.WillKillTarget( creep, nAttackDamage, DAMAGE_TYPE_PHYSICAL, nDelay )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q对线'
				end
			end
		end
	end


	if J.IsRetreating( bot ) and bot:WasRecentlyDamagedByAnyHero( 2.0 )
	then
		local target = J.GetVulnerableWeakestUnit( bot, true, true, nCastRange )
		if target ~= nil
			and bot:IsFacingLocation( target:GetLocation(), 30 )
			and J.CanCastOnTargetAdvanced( target )
		then
			return BOT_ACTION_DESIRE_HIGH, target, 'Q撤退'
		end
	end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and #hAllyList < 3 and nLV > 7
		and J.IsAllowedToSpam( bot, 30 )
	then
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nCastRange + 150, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and ( J.IsKeyWordUnit( "ranged", creep )
						or ( nMP > 0.5 and J.IsKeyWordUnit( "melee", creep ) ) )
				and not J.IsOtherAllysTarget( creep )
				and creep:GetHealth() > nDamage * 0.68
			then
				local nDelay = nCastPoint + GetUnitToUnitDistance( bot, creep )/500
				if J.WillKillTarget( creep, nDamage, nDamageType, nDelay * 0.8 )
					and not J.WillKillTarget( creep, nAttackDamage, DAMAGE_TYPE_PHYSICAL, nDelay )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q推进'
				end
			end
		end
	end


	if J.IsFarming( bot ) and nLV > 9
	then
		if J.IsValid( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and ( botTarget:GetMagicResist() < 0.3 or nMP > 0.95 )
			and not J.CanKillTarget( botTarget, nAttackDamage * 1.68, DAMAGE_TYPE_PHYSICAL )
			and not J.CanKillTarget( botTarget, nDamage - 10, nDamageType )
			and not J.WillKillTarget( botTarget, nAttackDamage, DAMAGE_TYPE_PHYSICAL, nCastPoint )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q打野'
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 50 )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q进攻'
		end
	end


	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and nLV > 15 and nMP > 0.4
	then
		if J.IsRoshan( botTarget )
			and J.GetHP( botTarget ) > 0.2
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q肉山'
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = 1600
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL

	local nSkillTarget = hEnemyList[1]

	if J.IsValidHero( nSkillTarget )
		and J.CanCastOnNonMagicImmune( nSkillTarget )
	then
		local nDist = GetUnitToUnitDistance( bot, nSkillTarget )
		if J.WillMagicKillTarget( bot, nSkillTarget, nDamage, nCastPoint + nDist/1200 )
		then
			return BOT_ACTION_DESIRE_HIGH, 'W击杀'..J.Chat.GetNormName( nSkillTarget )
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsValidHero( nSkillTarget )
			and J.CanCastOnNonMagicImmune( nSkillTarget )
			and J.IsInRange( bot, nSkillTarget, nCastRange + 50 )
			and J.IsInRange( botTarget, nSkillTarget, 250 )
		then
			return BOT_ACTION_DESIRE_HIGH, 'W进攻'
		end
	end

	if J.IsRetreating( bot )
	then
		if J.IsValidHero( nSkillTarget )
			and J.CanCastOnNonMagicImmune( nSkillTarget )
			and J.IsInRange( bot, nSkillTarget, nCastRange + 50 )
			and ( bot:WasRecentlyDamagedByHero( nSkillTarget, 5.0 ) or nHP < 0.4 )
		then
			return BOT_ACTION_DESIRE_HIGH, 'W撤退'
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
	local nInRangeEnemyHeroList = bot:GetNearbyHeroes( nCastRange + 50, true, BOT_MODE_NONE )


	for _, npcEnemy in pairs( nInRangeEnemyHeroList )
	do
		if ( npcEnemy:IsCastingAbility() or npcEnemy:IsChanneling() )
			and not npcEnemy:HasModifier( "modifier_teleporting" )
			and not npcEnemy:HasModifier( "modifier_boots_of_travel_incoming" )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy, "E打断"
		end
	end


	if J.IsInTeamFight( bot, 700 )
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsSilenced()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_MAGICAL )
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage
					npcMostDangerousEnemy = npcEnemy
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy, "E团战"
		end

	end


	if bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and nInRangeEnemyHeroList[1] ~= nil
		and #nInRangeEnemyHeroList >= 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsSilenced()
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 40 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "E自保"
			end
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsSilenced()
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "E进攻"
		end
	end


	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.1 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsSilenced()
				and J.IsInRange( npcEnemy, bot, nCastRange )
				and ( not J.IsInRange( npcEnemy, bot, 450 ) or bot:IsFacingLocation( npcEnemy:GetLocation(), 45 ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "E撤退"
			end
		end
	end


	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 1200
		and abilityE:GetLevel() >= 3
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "E肉山"
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

--modifier_skywrath_mage_concussive_shot_slow
function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end


	local nCastRange = abilityR:GetCastRange() + aetherRange
	
	if nCastRange > 1400 then nCastRange = 1400 end
	
	local nRadius = 170
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyHeroList = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE )


	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nAoeLoc, 'R团战'
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 200 )
		then
			if ( not J.IsRunning( botTarget ) and not J.IsMoving( botTarget ) )
				or J.IsDisabled( botTarget )
				or botTarget:GetCurrentMovementSpeed() < 180
			then
				return BOT_ACTION_DESIRE_HIGH, J.GetFaceTowardDistanceLocation( botTarget, 148 ), 'R进攻'
			end
		end
	end

	if J.IsRetreating( bot ) and nHP < 0.78
	then
		for _, npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.1 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, J.GetFaceTowardDistanceLocation( npcEnemy, 168 ), 'R撤退'
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592..
