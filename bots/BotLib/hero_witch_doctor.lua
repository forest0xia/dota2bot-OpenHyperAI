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
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,3,1,3,6,3,1,1,2,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
	"item_tango",
	"item_tango",
	"item_enchanted_mango",
	"item_double_branches",
	"item_blood_grenade",

	"item_arcane_boots",
	"item_magic_wand",
	"item_aghanims_shard",
	"item_glimmer_cape",--
	"item_guardian_greaves",--
	"item_force_staff",--
	"item_ultimate_scepter",
	"item_cyclone",
	"item_black_king_bar",--
	"item_wind_waker",--
	"item_ultimate_scepter_2",
	"item_sheepstick",--
	"item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",

    "item_boots",
    "item_magic_wand",
    "item_urn_of_shadows",
    "item_tranquil_boots",
    "item_pavise",
    'item_pipe',--
    "item_solar_crest",--
    "item_spirit_vessel",--
    "item_force_staff",--
    "item_boots_of_bearing",--
    "item_aghanims_shard",
    "item_ultimate_scepter",
    "item_wind_waker",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
	"item_tango",
	"item_tango",
	"item_enchanted_mango",
	"item_double_branches",

	"item_arcane_boots",
	"item_magic_wand",
	"item_aghanims_shard",
	"item_glimmer_cape",--
    'item_veil_of_discord',
	"item_shivas_guard",--
	"item_ultimate_scepter",
    "item_maelstrom",
	"item_gungir",--
	"item_cyclone",
	"item_black_king_bar",--
	"item_wind_waker",--
	"item_ultimate_scepter_2",
	"item_sheepstick",--
	"item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
		and hMinionUnit:GetUnitName() ~= 'npc_dota_witch_doctor_death_ward'
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

"npc_dota_hero_witch_doctor"

"Ability1"		"witch_doctor_paralyzing_cask"
"Ability2"		"witch_doctor_voodoo_restoration"
"Ability3"		"witch_doctor_maledict"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"witch_doctor_death_ward"
"Ability10"		"special_bonus_attack_damage_75"
"Ability11"		"special_bonus_armor_6"
"Ability12"		"special_bonus_unique_witch_doctor_3"
"Ability13"		"special_bonus_gold_income_20"
"Ability14"		"special_bonus_unique_witch_doctor_1"
"Ability15"		"special_bonus_unique_witch_doctor_4"
"Ability16"		"special_bonus_unique_witch_doctor_2"
"Ability17"		"special_bonus_unique_witch_doctor_5"


modifier_witchdoctor_cask_thinker
modifier_voodoo_restoration_aura
modifier_voodoo_restoration_heal
modifier_maledict_dot
modifier_maledict
modifier_witch_doctor_death_ward

--]]


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget
local castWDesire
local castEDesire, castELocation
local castRDesire, castRLocation
local castASDesire, castASTarget


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local talentDamage = 0



function X.SkillsComplement()

	X.ConsiderCombo()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	talentDamage = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1200 )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end

	
	castASDesire, sMotive = X.ConsiderAS()
	if ( castASDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityAS )
		return

	end
	

	castEDesire, castELocation, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityE, castELocation )
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


	castWDesire, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		bot:ActionQueue_UseAbility( abilityW )
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

end

local amuletTime = -90
function X.ConsiderCombo()
	if bot:IsAlive()
		and bot:IsChanneling()
		and not bot:IsInvisible()
	then
		local nEnemyTowers = bot:GetNearbyTowers( 880, true )

		if nEnemyTowers[1] ~= nil then return end

		local amulet = J.IsItemAvailable( 'item_shadow_amulet' )
		if amulet ~= nil and amulet:IsFullyCastable() and amuletTime < DotaTime()- 10
		then
			amuletTime = DotaTime()
			bot:Action_UseAbilityOnEntity( amulet, bot )
			return
		end

		if not bot:HasModifier( 'modifier_teleporting' )
		then
			local glimer = J.IsItemAvailable( 'item_glimmer_cape' )
			if glimer ~= nil and glimer:IsFullyCastable()
			then
				bot:Action_UseAbilityOnEntity( glimer, bot )
				return
			end

			local invissword = J.IsItemAvailable( 'item_invis_sword' )
			if invissword ~= nil and invissword:IsFullyCastable()
			then
				bot:Action_UseAbility( invissword )
				return
			end

			local silveredge = J.IsItemAvailable( 'item_silver_edge' )
			if silveredge ~= nil and silveredge:IsFullyCastable()
			then
				bot:Action_UseAbility( silveredge )
				return
			end
		end
	end
end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = 50 + nSkillLV * 25
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange + 50, true, BOT_MODE_NONE )

	local nRadius = abilityR:GetSpecialValueInt( 'bounce_range' )/2

	--击杀
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			local nDelayTime = nCastPoint + GetUnitToUnitDistance( bot, npcEnemy )/1000
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage * 1.6, nDelayTime )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'Q-Kill:'..J.Chat.GetNormName( npcEnemy )
			end

			if npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'Q-Check:'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--Aoe
	if #nInRangeEnemyList >= 1
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			for _, npcEnemy in pairs( nInRangeEnemyList )
			do
				if J.IsValidHero( npcEnemy )
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and J.CanCastOnTargetAdvanced( npcEnemy )
					and J.IsInLocRange( npcEnemy, nAoeLoc, nRadius + 50 )
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'Q-Aoe:'..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end


	--进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
		then
			local nEnemyCreepList = botTarget:GetNearbyCreeps( nRadius * 1.9, false )
			local nEnemyHeroList = J.GetNearbyHeroes(botTarget,  nRadius * 1.9, false, BOT_MODE_NONE )
			if #nEnemyCreepList >= 2 or #nEnemyHeroList >= 2 or nHP < 0.28
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q-Attack:'..J.Chat.GetNormName( botTarget )
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 )
			then
				local nEnemyCreepList = npcEnemy:GetNearbyCreeps( nRadius * 1.9, false )
				local nEnemyHeroList = J.GetNearbyHeroes(npcEnemy,  nRadius * 1.9, false, BOT_MODE_NONE )
				if #nEnemyCreepList + #nEnemyHeroList >= 2 or nHP < 0.23
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'Q-Retreat:'..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end

	--对线期间


	--推线时
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, 30 )
		and nSkillLV >= 2
		and #hEnemyList == 0
		and #hAllyList <= 2
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
					and J.GetAroundTargetEnemyUnitCount( creep, nRadius * 2 ) >= 3
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-PushAoe"
				end

				if J.IsKeyWordUnit( 'ranged', creep )
					and ( J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
							or ( #nEnemyCreeps >= 7 and J.GetAroundTargetEnemyUnitCount( creep, nRadius * 2 ) >= 3 ) )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-PushRanged"
				end

				if J.IsKeyWordUnit( 'melee', creep )
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
					and ( J.GetAroundTargetEnemyUnitCount( creep, nRadius * 2 ) >= 2 or nMP > 0.8 )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-PushMelee"
				end

			end
		end

	end


	--打野时
	if J.IsFarming( bot ) and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
		and #hEnemyList == 0
		and #hAllyList <= 2
		and not ( J.IsPushing( bot ) or J.IsDefending( bot ) )
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 400 )
		if #nNeutralCreeps >= 2
		then
			for _, creep in pairs( nNeutralCreeps )
			do
				if J.IsValid( creep )
					and J.IsInRange( bot, creep, nCastRange )
					and bot:IsFacingLocation( creep:GetLocation(), 30 )
					and creep:GetHealth() >= 600
					and creep:GetMagicResist() < 0.3
					and J.GetAroundTargetEnemyUnitCount( creep, nRadius * 2 ) >= 2
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-Farm:"..( #nNeutralCreeps )
				end
			end
		end
	end



	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()
	if not abilityW:IsFullyCastable() then return 0 end

	local nRadius = abilityW:GetSpecialValueInt( 'radius' )
	local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

	if J.GetMP(bot) < 0.33
	then
		if abilityW:GetToggleState() == true
		then
			return BOT_ACTION_DESIRE_HIGH
		else
			return BOT_ACTION_DESIRE_NONE
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 1600)
		and not J.IsSuspiciousIllusion(botTarget)
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

			if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
			and #nInRangeAlly >= #nTargetInRangeAlly
			then
				nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nRadius)
				for _, allyHero in pairs(nInRangeAlly)
				do
					if J.IsValidHero(allyHero)
					and J.GetHP(allyHero) < 0.5
					and not J.IsSuspiciousIllusion(allyHero)
					and not allyHero:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
					and not allyHero:HasModifier('modifier_oracle_false_promise_timer')
					and not allyHero:HasModifier('modifier_item_aeon_disk_buff')
					then
						if abilityW:GetToggleState() == false
						then
							return BOT_ACTION_DESIRE_HIGH
						else
							return BOT_ACTION_DESIRE_NONE
						end
					end
				end
			end
		end
	end

	if J.IsRetreating(bot)
	then
		if J.IsValidHero(nInRangeEnemy[1])
		and J.GetHP(bot) < 0.5
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		then
			local nInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

			if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
			and (#nInRangeAlly > #nTargetInRangeAlly
				or bot:WasRecentlyDamagedByAnyHero(1.5))
			then
				if abilityW:GetToggleState() == false
				then
					return BOT_ACTION_DESIRE_HIGH
				else
					return BOT_ACTION_DESIRE_NONE
				end
			end
		end
	end

	local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nRadius)
	for _, allyHero in pairs(nInRangeAlly)
	do
		if J.IsValidHero(allyHero)
		and J.GetHP(allyHero) < 0.5
		and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
		and not J.IsSuspiciousIllusion(allyHero)
		and not allyHero:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
		and not allyHero:HasModifier('modifier_oracle_false_promise_timer')
		and not allyHero:HasModifier('modifier_item_aeon_disk_buff')
		then
			if abilityW:GetToggleState() == false
			then
				return BOT_ACTION_DESIRE_HIGH
			else
				return BOT_ACTION_DESIRE_NONE
			end
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
		and J.IsInRange(bot, botTarget, bot:GetAttackRange())
		and J.IsAttacking(bot)
		then
			if abilityW:GetToggleState() == false
			then
				return BOT_ACTION_DESIRE_HIGH
			else
				return BOT_ACTION_DESIRE_NONE
			end
		end
	end

	if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, bot:GetAttackRange())
		and J.IsAttacking(bot)
		then
			if abilityW:GetToggleState() == false
			then
				return BOT_ACTION_DESIRE_HIGH
			else
				return BOT_ACTION_DESIRE_NONE
			end
		end
	end

	if abilityW:GetToggleState() == true
	-- and not bot:HasModifier('') -- to add DoT spells/items modifiers
	then
		return BOT_ACTION_DESIRE_HIGH
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
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange + 32, true, BOT_MODE_NONE )

	local nRadius = abilityE:GetSpecialValueInt( "radius" )

	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nAoeLoc, 'E-Fight'
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 99 )
			and J.CanCastOnNonMagicImmune( botTarget )
		then
			local nTargetLocation = J.GetCastLocation( bot, botTarget, nCastRange, nRadius )
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'E-Attack:'..J.Chat.GetNormName( botTarget )
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

	if abilityQ:IsFullyCastable()
		and bot:GetMana() > abilityR:GetManaCost() + abilityQ:GetManaCost()
	then return 0 end

	if abilityE:IsFullyCastable()
		and bot:GetMana() > abilityR:GetManaCost() + abilityE:GetManaCost()
	then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nRadius = 700 - 120

	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange + nRadius, true, BOT_MODE_NONE )

	if J.IsInTeamFight( bot, 900 )
	then
		if #nInRangeEnemyList >= 2
		then
			for _, npcEnemy in pairs( nInRangeEnemyList )
			do
				if J.IsValidHero( npcEnemy )
					and J.CanCastOnMagicImmune( npcEnemy )
					and not npcEnemy:IsAttackImmune()
				then
					local nTargetLocation = J.GetCastLocation( bot, npcEnemy, nCastRange, nRadius )
					if nTargetLocation ~= nil
					then
						return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'R-团战:'..J.Chat.GetNormName( npcEnemy )
					end
				end
			end
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + nRadius - 260 )
			and not botTarget:IsAttackImmune()
			and J.CanCastOnMagicImmune( botTarget )
			and ( J.IsDisabled( botTarget )
				  or botTarget:GetHealth() <= botTarget:GetActualIncomingDamage( bot:GetOffensivePower() * 2, DAMAGE_TYPE_ALL ) )
			and botTarget:GetHealth() > 500
			and #hAllyList <= 2
		then
			local nTargetLocation = J.GetCastLocation( bot, botTarget, nCastRange, nRadius )
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'R-Attack:'..J.Chat.GetNormName( botTarget )
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

	local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )
	
	
	if #tableNearbyEnemyHeroes >= 1
		and J.IsStunProjectileIncoming( bot, 600 )
	then
		return BOT_ACTION_DESIRE_HIGH, "AS-躲眩晕弹道"
	end
	
	

	if J.IsRetreating( bot )
		and #tableNearbyEnemyHeroes == 1
	then
		local npcEnemy = tableNearbyEnemyHeroes[1]
		if J.IsValidHero(npcEnemy)
			and J.CanCastOnMagicImmune(npcEnemy)
			and npcEnemy:GetAttackTarget() == bot
			and J.IsInRange( bot, npcEnemy, npcEnemy:GetAttackRange() + 100 )
		then
			return BOT_ACTION_DESIRE_HIGH, "AS-撤退隐藏"
		end		
	end
	
	
	
	if abilityR:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end	

	
	
	if J.IsInTeamFight( bot, 900 )
	then
		local nearbyEnemyList = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
		if #nearbyEnemyList >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, "AS-团战"
		end
	end
	

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nRadius * 0.5 )
			and J.CanCastOnMagicImmune( botTarget )
			and botTarget:GetAttackTarget() == bot
			and nHP < 0.5
		then
			return BOT_ACTION_DESIRE_HIGH, "AS-攻击"
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end


return X
-- dota2jmz@163.com QQ:2462331592..
