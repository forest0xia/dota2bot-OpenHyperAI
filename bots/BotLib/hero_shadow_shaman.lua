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
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,3,2,2,6,2,2,3,3,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
	"item_tango",
	"item_double_branches",
	"item_faerie_fire",
	"item_blood_grenade",

	"item_arcane_boots",
	"item_magic_wand",
	"item_aghanims_shard",
	"item_glimmer_cape",--
	"item_ultimate_scepter",
	"item_guardian_greaves",--
	"item_aether_lens",--
	"item_octarine_core",--
	"item_black_king_bar",--
	"item_refresher",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
	"item_tango",
	"item_double_branches",
	"item_faerie_fire",
	"item_blood_grenade",

	"item_tranquil_boots",
	"item_magic_wand",
	"item_aghanims_shard",
	"item_pipe",--
	"item_glimmer_cape",--
	"item_ultimate_scepter",
	"item_boots_of_bearing",--
	"item_aether_lens",--
	"item_octarine_core",--
	-- "item_black_king_bar",--
	"item_refresher",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = {
	
	"item_crystal_maiden_outfit",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_force_staff",
	"item_cyclone",
	"item_sheepstick",
	"item_wind_waker",
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_refresher",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_cyclone",
	"item_magic_wand",

	"item_ultimate_scepter",
	"item_magic_wand",
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		if Minion.IsAttackingWard( hMinionUnit:GetUnitName() )
		then
			Minion.AttackingWardThink( hMinionUnit )
		else
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

--[[

npc_dota_hero_shadow_shaman

"Ability1"		"shadow_shaman_ether_shock"
"Ability2"		"shadow_shaman_voodoo"
"Ability3"		"shadow_shaman_shackles"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"shadow_shaman_mass_serpent_ward"
"Ability10"		"special_bonus_hp_200"
"Ability11"		"special_bonus_exp_boost_20"
"Ability12"		"special_bonus_cast_range_125"
"Ability13"		"special_bonus_unique_shadow_shaman_5"
"Ability14"		"special_bonus_unique_shadow_shaman_2"
"Ability15"		"special_bonus_unique_shadow_shaman_1"
"Ability16"		"special_bonus_unique_shadow_shaman_3"
"Ability17"		"special_bonus_unique_shadow_shaman_4"

modifier_shadow_shaman_ethershock
modifier_shadow_shaman_voodoo
modifier_shadow_shaman_shackles
modifier_shadow_shaman_serpent_ward

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent3 = bot:GetAbilityByName( sTalentList[3] )
local talent7 = bot:GetAbilityByName( sTalentList[7] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRLocation


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local talent7Damage = 0



function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	talent7Damage = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end
--	if talent3:IsTrained() then aetherRange = aetherRange + talent3:GetSpecialValueInt( "value" ) end
	if talent7:IsTrained() then talent7Damage = talent7:GetSpecialValueInt( "value" ) end


	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
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


	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end


	castEDesire, castETarget, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end


end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange()
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( "damage" ) + talent7Damage
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local nInBonusEnemyList = J.GetNearbyHeroes(bot, nCastRange + 220, true, BOT_MODE_NONE )


	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'Q-kill'..J.Chat.GetNormName( npcEnemy )
		end
	end


	if J.IsInTeamFight( bot, 1200 ) and nLV >= 5
	then
		local nWeakestEnemy = nil
		local nWeakestEnemyHealth = 9999

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
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemy, "Q-Battle-Weakest:"..J.Chat.GetNormName( nWeakestEnemy )
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
		then
			if nSkillLV >= 2 or nMP > 0.7 or J.GetHP( botTarget ) < 0.5 or nHP < 0.4
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q-attack:'..J.Chat.GetNormName( botTarget )
			end
		end
	end


	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
						or nMP > 0.68
						or GetUnitToUnitDistance( bot, npcEnemy ) <= 400 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 30 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "Q-Retreat:"..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	if J.IsLaning( bot )
	then
		if nMP > 0.5
		then
			for _, npcEnemy in pairs( nInRangeEnemyList )
			do
				if J.IsValid( npcEnemy )
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and J.CanCastOnTargetAdvanced( npcEnemy )
					and J.GetAttackEnemysAllyCreepCount( npcEnemy, 1400 ) >= 3
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, "Q-Laning:"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end

		
		if #hAllyList <= 1 or J.IsCore(bot) then
			local nEnemyCreeps = bot:GetNearbyLaneCreeps( 800, true )
			for _, creep in pairs( nEnemyCreeps )
			do
				if J.IsValid( creep )
					and not creep:HasModifier( 'modifier_fountain_glyph' )
					and not J.IsAllysTarget( creep )
				then
					if J.IsKeyWordUnit( 'ranged', creep )
						and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
					then
						return BOT_ACTION_DESIRE_HIGH, creep, "Q-LaneRanged"
					end

					if bot:GetMana() > 320
						and J.IsKeyWordUnit( 'melee', creep )
						and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
						and not J.WillKillTarget( creep, nDamage * 0.5, nDamageType, nCastPoint )
					then
						return BOT_ACTION_DESIRE_HIGH, creep, "Q-LaneMelee"
					end
				end
			end
		end
	end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, 30 )
		and nSkillLV >= 3
		and #hEnemyList == 0
		and #hAllyList <= 3
	then
		local nEnemyCreeps = bot:GetNearbyLaneCreeps( 999, true )
		local nAllyCreeps = bot:GetNearbyLaneCreeps( 888, false )

		for _, creep in pairs( nEnemyCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.IsInRange( creep, bot, nCastRange + 300 )
			then

				if #nAllyCreeps == 0
					and J.GetAroundTargetEnemyUnitCount( creep, 380 ) >= 2
					and #nEnemyCreeps >= 4
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-PushAoe"
				end

				if J.IsKeyWordUnit( 'ranged', creep )
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-PushRanged"
				end

				if J.IsKeyWordUnit( 'melee', creep )
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
					and ( J.GetAroundTargetEnemyUnitCount( creep, 380 ) >= 2 or nMP > 0.8 )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-PushMelee"
				end

			end
		end

	end


	if J.IsFarming( bot ) and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
		and #hEnemyList == 0
		and #hAllyList <= 2
		and not ( J.IsPushing( bot ) or J.IsDefending( bot ) )
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 200 )
		if #nNeutralCreeps >= 3 or nMP >= 0.8
		then
			local targetCreep = nNeutralCreeps[1]
			if J.IsValid( targetCreep )
				and bot:IsFacingLocation( targetCreep:GetLocation(), 30 )
				and targetCreep:GetHealth() >= 500
				and targetCreep:GetMagicResist() < 0.3
				and J.GetAroundTargetEnemyUnitCount( targetCreep, 300 ) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, targetCreep, "Q-Farm:"..( #nNeutralCreeps )
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + aetherRange
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local nInBonusEnemyList = J.GetNearbyHeroes(bot, nCastRange + 240, true, BOT_MODE_NONE )



	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then
			if npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'W-Check1:'..J.Chat.GetNormName( npcEnemy )
			end

			if npcEnemy:IsCastingAbility()
				and J.IsInRange( bot, npcEnemy, nCastRange + 50 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'W-Check2:'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end



	if J.IsInTeamFight( bot, 1200 )
		and ( #nInBonusEnemyList >= 2 or #hAllyList >= 3 )
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not J.IsTaunted( npcEnemy )
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

		if npcMostDangerousEnemy ~= nil
			and J.IsInRange( bot, npcMostDangerousEnemy, nCastRange + 50 )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy, 'W-Battle:'..J.Chat.GetNormName( npcMostDangerousEnemy )
		end

	end



	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 32 )
			and not J.IsDisabled( botTarget )
			and not J.IsTaunted( botTarget )
			and not botTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'W-Attack:'..J.Chat.GetNormName( botTarget )
		end
	end



	if bot:WasRecentlyDamagedByAnyHero( 3.0 ) and nLV >= 10
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nInRangeEnemyList >= 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not J.IsTaunted( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'W-protect'
			end
		end
	end



	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
						or GetUnitToUnitDistance( bot, npcEnemy ) <= 500 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not J.IsTaunted( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "W-Retreat:"..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	if J.IsDoingRoshan( bot ) and nMP > 0.6
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "W-Roshan"
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
	local nDamage = nSkillLV * 100 - 40 + bot:GetAttackDamage() * 2
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local nInBonusEnemyList = J.GetNearbyHeroes(bot, nCastRange + 240, true, BOT_MODE_NONE )


	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then
			if npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'E-Check1:'..J.Chat.GetNormName( npcEnemy )
			end

			if #hAllyList >= 2
				and npcEnemy:IsCastingAbility()
				and J.IsInRange( bot, npcEnemy, nCastRange + 30 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'E-Check2:'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	if J.IsInTeamFight( bot, 1200 ) and nLV >= 5
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not J.IsTaunted( npcEnemy )
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

		if npcMostDangerousEnemy ~= nil
			and J.IsInRange( bot, npcMostDangerousEnemy, nCastRange + 50 )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy, 'E-Battle:'..J.Chat.GetNormName( npcMostDangerousEnemy )
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 30 )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and not J.IsDisabled( botTarget )
			and not J.IsTaunted( botTarget )
			and not botTarget:IsDisarmed()
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHP( botTarget ) < 0.35 or nHP < 0.28
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget, "E-Attack:"..J.Chat.GetNormName( botTarget )
			end
		end
	end


	if J.IsRetreating( bot )
		and nSkillLV >= 3
		and #hEnemyList == 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not J.IsTaunted( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "E-Retreat:"..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 800
	then
		if J.IsRoshan( botTarget )
			and J.GetHP( botTarget ) > 0.2
			and J.IsInRange( bot, botTarget, nCastRange + 100 )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange() + aetherRange + 100
	local nRadius	 = 150
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local targetLocation = nil

	if J.IsGoingOnSomeone( bot )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange + 100, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			targetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, targetLocation, 'R-Aoe'
		end

		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnMagicImmune( botTarget )
			and botTarget:GetHealth() > bot:GetAttackDamage() * 3
		then
			targetLocation = botTarget:GetExtrapolatedLocation( nCastPoint )
			return BOT_ACTION_DESIRE_HIGH, targetLocation, "R-Attack:"..J.Chat.GetNormName( botTarget )
		end
	end


	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 )
			then
				targetLocation = npcEnemy:GetExtrapolatedLocation( nCastPoint )
				return BOT_ACTION_DESIRE_HIGH, targetLocation, "R-Retreat:"..J.Chat.GetNormName( npcEnemy )
			end
		end
	end

	if J.IsPushing( bot )
	then
		local nTowerList = bot:GetNearbyTowers( 1100, true )
		local nBarrackList = bot:GetNearbyBarracks( 1100, true )
		local nEnemyAcient = GetAncient( GetOpposingTeam() )
		local hBuildingList = {
			nTowerList[1],
			nBarrackList[1],
			nEnemyAcient, 
		}

		for _, nBuilding in pairs( hBuildingList )
		do
			if J.IsValidBuilding( nBuilding )
				and J.IsInRange( bot, nBuilding, nCastRange + 500 )
				and not nBuilding:HasModifier( 'modifier_fountain_glyph' )
				and not nBuilding:HasModifier( 'modifier_invulnerable' )
				and not nBuilding:HasModifier( 'modifier_backdoor_protection' )
			then
				targetLocation = J.GetUnitTowardDistanceLocation( nBuilding, bot, 240 )
				if GetUnitToLocationDistance( bot, targetLocation ) < 180
				then
					targetLocation = J.GetUnitTowardDistanceLocation( bot, nBuilding, 240 )
				end
				if targetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, targetLocation, "R-Pushing"
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592..
