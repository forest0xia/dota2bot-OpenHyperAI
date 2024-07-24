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
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{3,1,1,2,3,6,3,3,2,2,6,2,1,1,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
	"item_tango",
	"item_double_branches",
	"item_faerie_fire",

	"item_bottle",
	"item_boots",
	"item_magic_wand",
	"item_power_treads",
	"item_witch_blade",
	"item_kaya_and_sange",--
	"item_ultimate_scepter",
	"item_black_king_bar",--
    "item_veil_of_discord",
	"item_shivas_guard",--
	"item_aghanims_shard",
	"item_travel_boots",
	"item_devastator",--
	"item_cyclone",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_wind_waker",--
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
	"item_double_branches",

	"item_boots",
	"item_magic_wand",
	"item_power_treads",
	"item_witch_blade",
	"item_kaya_and_sange",--
	"item_ultimate_scepter",
	"item_black_king_bar",--
    "item_veil_of_discord",
	"item_shivas_guard",--
	"item_aghanims_shard",
	"item_travel_boots",
	"item_devastator",--
	"item_cyclone",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_wind_waker",--
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_bottle",
	"item_magic_wand",
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'],X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit, bot)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end

--[[

npc_dota_hero_queenofpain

"Ability1"		"queenofpain_shadow_strike"
"Ability2"		"queenofpain_blink"
"Ability3"		"queenofpain_scream_of_pain"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"queenofpain_sonic_wave"
"Ability10"		"special_bonus_attack_damage_20"
"Ability11"		"special_bonus_strength_8"
"Ability12"		"special_bonus_cooldown_reduction_10"
"Ability13"		"special_bonus_attack_speed_30"
"Ability14"		"special_bonus_spell_lifesteal_25"
"Ability15"		"special_bonus_unique_queen_of_pain"
"Ability16"		"special_bonus_unique_queen_of_pain_2"
"Ability17"		"special_bonus_spell_block_18"

modifier_queenofpain_shadow_strike
modifier_queenofpain_scream_of_pain_fear

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget


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
	
	castWDesire, castWTarget, sMotive = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget )
		return;
	end
	
	castQDesire, castQTarget, sMotive = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);		

		J.SetQueuePtToINT(bot, true)

		if bot:HasScepter()
		and castQTarget ~= nil
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQTarget:GetLocation() )
			return
		end

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	castRDesire, castRTarget, sMotive = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRTarget )
		return;
	
	end
	
	castEDesire, castETarget, sMotive = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityE )
		return;
	end
	

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityQ:GetLevel()
	local nCastRange  = abilityQ:GetCastRange()
	local nCastPoint  = abilityQ:GetCastPoint()
	local nManaCost   = abilityQ:GetManaCost()
	
	local nDamage = 75 + 125 * nSkillLV
	
	local nDamageType = DAMAGE_TYPE_MAGICAL 
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + 20 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 100 )
	local hCastTarget = nil
	local sCastMotive = nil


	for _, npcEnemy in pairs( nInBonusEnemyList )
	do 
		if J.IsValid( npcEnemy )
			and not npcEnemy:HasModifier( 'modifier_queenofpain_shadow_strike' )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage , nDamageType )
		then
			hCastTarget = npcEnemy
			sCastMotive = 'Q-击杀'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	
	end
	
	

	if J.IsGoingOnSomeone( bot ) or (J.IsLaning( bot ) and J.IsAllowedToSpam(bot, nManaCost))
	then
	
		if J.IsValidHero( botTarget )
			and not botTarget:HasModifier( 'modifier_queenofpain_shadow_strike' )
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )			
			and J.CanCastOnTargetAdvanced( botTarget )
		then			
			hCastTarget = botTarget
			sCastMotive = 'Q-先手'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
		
		
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do 
			if J.IsValid( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_queenofpain_shadow_strike' )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-标'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end	
		
	end
			
	
	

	if J.IsRetreating( bot )
--		and bot:WasRecentlyDamagedByAnyHero( 5.0 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.IsInRange( bot, npcEnemy, nCastRange - 100 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-撤退'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	
	

	if J.IsFarming( bot )
		-- and DotaTime() > 4 * 60
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nCastRange )

		local targetCreep = J.GetMostHpUnit( creepList )

		if J.IsValid( targetCreep )
			and #creepList >= 2 
			and not J.IsOtherAllysTarget( targetCreep )
			and targetCreep:GetMagicResist() < 0.4
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 5, DAMAGE_TYPE_PHYSICAL )
		then
			hCastTarget = targetCreep
			sCastMotive = 'Q-打野:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() 
		or bot:IsRooted()
		or bot:HasModifier( "modifier_bloodseeker_rupture" )
	then return 0 end
	
	local nSkillLV    = abilityW:GetLevel() 
	local nCastRange  = 1000 + nSkillLV * 75
	local nAttackRange  = bot:GetAttackRange()
	local nCastPoint  = abilityW:GetCastPoint()
	local nManaCost   = abilityW:GetManaCost()
	local nDamage     = abilityW:GetAbilityDamage()
	local ScreamOfPainDamage     = abilityE:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local hCastTarget = nil
	local sCastMotive = nil
	

	if J.IsStuck( bot )
	then
		hCastTarget = J.GetEscapeLoc()
		sCastMotive = 'W-被卡住'
		return BOT_ACTION_DESIRE_ABSOLUTE, hCastTarget, sCastMotive
	end
	

	if J.IsRetreating( bot ) 
		or ( bot:GetActiveMode() == BOT_MODE_RETREAT and nHP < 0.2 and bot:DistanceFromFountain() > 1100 )
	then
		if J.ShouldEscape( bot ) 
			or ( bot:DistanceFromFountain() > 600 and  bot:DistanceFromFountain() < 3800 )
		then
			hCastTarget = J.GetEscapeLoc()
			sCastMotive = 'W-逃跑'
			return BOT_ACTION_DESIRE_ABSOLUTE, hCastTarget, sCastMotive
		end
	end
	
	

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 500 )
			and not J.IsInRange( bot, botTarget, nAttackRange + 50 )
			and J.CanCastOnMagicImmune( botTarget )
			and not botTarget:IsAttackImmune()
		then
			local enemyList = J.GetNearbyHeroes(botTarget,  1100, false, BOT_MODE_NONE )
			local allyList = J.GetNearbyHeroes(botTarget,  1000, true, BOT_MODE_NONE )
			local aliveEnemyCount = J.GetNumOfAliveHeroes( true )
			
			if aliveEnemyCount <= 1
				or #enemyList <= 1
				or #enemyList < #allyList
				or J.WillKillTarget( botTarget, bot:GetAttackDamage() * 2, DAMAGE_TYPE_PHYSICAL, 2.0 )
			then
			
				hCastTarget = J.Site.GetXUnitsTowardsLocation( botTarget, bot:GetLocation(), 330 )
				sCastMotive = 'W-进攻:'..J.Chat.GetNormName( botTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				
			end		
		end	
	end
	
	

	local nEnemysTowers = bot:GetNearbyTowers( 1600, true )
	if ( bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7 )
		and #hEnemyList == 0 and #nEnemysTowers == 0 and DotaTime() < 12 * 60
	then
		
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
					hCastTarget = location
					sCastMotive = 'W-对线赶路'
					
					if bot:GetTarget() ~= nil
					then
						if J.CanKillTarget( bot:GetTarget(), ScreamOfPainDamage, DAMAGE_TYPE_MAGICAL ) and abilityE.IsFullyCastable()
						then
							return BOT_ACTION_DESIRE_VERYHIGH
						end
					end
					
					return BOT_ACTION_DESIRE_MODERATE, hCastTarget, sCastMotive
				end
			end
		end
	end
	


	if J.IsFarming( bot ) and nLV >= 6
	then
		if botTarget ~= nil and botTarget:IsAlive()
			and not J.IsInRange( bot, botTarget, 900 )
			and J.IsInRange( bot, botTarget, 1600 )
			--and ( nLV > 11 or not botTarget:IsAncientCreep() )
		then
			hCastTarget = botTarget:GetLocation()
			sCastMotive = 'W-打钱赶路'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	

	local nAttackAllys = J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_ATTACK )
	if #hEnemyList == 0 
		and not bot:WasRecentlyDamagedByAnyHero( 3.0 ) 
		and nLV >= 9
		and #nAttackAllys == 0 
		and #hAllyList <= 3
		--and abilityE:IsFullyCastable()
		and ( botTarget ~= nil and not botTarget:IsHero() )
	then
		local nAOELocation = bot:FindAoELocation( true, false, bot:GetLocation(), 1400, 400, 0, 0 )
		local nLaneCreeps = bot:GetNearbyLaneCreeps( 1400, true )
		if nAOELocation.count >= 3
			and #nLaneCreeps >= 3
		then
			local bCenter = J.GetCenterOfUnits( nLaneCreeps )
			local bDist = GetUnitToLocationDistance( botTarget, bCenter )
			
			if bDist <= 500
				and IsLocationPassable( bCenter )
				and IsLocationVisible( bCenter )
				and GetUnitToLocationDistance( bot, bCenter ) >= 700
			then
				hCastTarget = bCenter
				sCastMotive = 'W-跳兵堆'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityE:GetLevel()
	local nCastRange  = abilityE:GetCastRange()
	local nCastPoint  = abilityE:GetCastPoint()
	local nRadius  = abilityE:GetSpecialValueInt( 'area_of_effect' )
	local nManaCost   = abilityE:GetManaCost()
	local nDamage = abilityE:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius - 30 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nRadius + 200 )
	local hCastTarget = nil
	local sCastMotive = nil
	
	

	for _, npcEnemy in pairs( nInRangeEnemyList )
	do 
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage, nDamageType )
		then
			hCastTarget = npcEnemy
			sCastMotive = 'E-击杀'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	
	end
		
	

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nRadius - 20 )
			and J.CanCastOnMagicImmune( botTarget )			
		then			
			hCastTarget = botTarget
			sCastMotive = 'E-攻击'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	

	if J.IsInTeamFight( bot, 1000 )
	then
		local nAoeCount = 0
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do 
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				nAoeCount = nAoeCount + 1	
			end
		end

		if nAoeCount >= 2
		then
			hCastTarget = botTarget
			sCastMotive = 'E-团战AOE'..nAoeCount
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	

	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'E-撤退'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	

	if J.IsLaning( bot ) and J.IsAllowedToSpam(bot, nManaCost)
	then
		local nCanKillMeleeCount = 0
		local nCanKillRangedCount = 0
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nRadius, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and not J.IsOtherAllysTarget( creep )
			then
				local lastHitDamage = nDamage
				local nDelay = nCastPoint + GetUnitToUnitDistance( bot, creep )/900
						
				if J.WillKillTarget( creep, lastHitDamage, nDamageType, nDelay )
				then
					if J.IsKeyWordUnit( 'ranged', creep )
					then
						nCanKillRangedCount = nCanKillRangedCount + 1
					end

					if J.IsKeyWordUnit( 'melee', creep )
					then
						nCanKillMeleeCount = nCanKillMeleeCount + 1
					end

				end
			end
		end

		if nCanKillMeleeCount + nCanKillRangedCount >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E对线1'
		end

		if nCanKillRangedCount >= 1 and nCanKillMeleeCount >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E对线2'
		end

		if #hLaneCreepList == 0
			and J.IsValidHero( nInRangeEnemyList[1] )
			and J.CanCastOnNonMagicImmune( nInRangeEnemyList[1] )
			and nMP > 0.5
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E消耗'	
		end
	end
	

	if ( J.IsPushing( bot ) or J.IsDefending( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and #hAllyList <= 3
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nRadius , true )
		if ( #laneCreepList >= 4 or ( #laneCreepList >= 3 and nMP > 0.82 ) )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then			
			hCastTarget = creep
			sCastMotive = 'E-带线AOE'..(#laneCreepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	

	if J.IsFarming( bot )
	and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nRadius )

		if #creepList >= 2
			and J.IsValid( botTarget )
		then
			hCastTarget = botTarget
			sCastMotive = 'E-打野AOE'..(#creepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
	    end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityR:GetLevel()
	local nCastRange  = abilityR:GetCastRange()
	local nCastPoint  = abilityR:GetCastPoint()
	local nManaCost   = abilityR:GetManaCost()
	local nDamage     = abilityR:GetSpecialValueInt( 'damage' )
	
	local nRadius = abilityR:GetSpecialValueInt( 'final_aoe' ) * 0.88
	
	if bot:HasScepter() then nDamage = abilityR:GetSpecialValueInt( 'damage_scepter' ) end
	
	local nDamageType = DAMAGE_TYPE_PURE
	
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local hCastTarget = nil
	local sCastMotive = nil
	
	
	--团战AOE
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			hCastTarget = nAoeLoc
			sCastMotive = 'R-团战AOE'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	
	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + nRadius * 0.5 )
			and J.CanCastOnMagicImmune( botTarget )
		then
			local nearbyEnemyList = J.GetNearbyHeroes(botTarget,  nRadius, false, BOT_MODE_NONE )
			if J.CanKillTarget( botTarget, nDamage * 1.3, nDamageType )
				or #nearbyEnemyList >= 2
			then
				local nTargetLocation = J.GetCastLocation( bot, botTarget, nCastRange, nRadius )
				if nTargetLocation ~= nil
				then
					hCastTarget = nTargetLocation
					sCastMotive = 'R-攻击目标:'..J.Chat.GetNormName( botTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end	
		end
	end
	
	
	--撤退时保护团队
	if J.IsRetreating( bot ) 
		and #hAllyList >= 2
		and #hEnemyList >= 2
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
				and not J.IsDisabled( npcEnemy )				
			then
				hCastTarget = npcEnemy:GetExtrapolatedLocation( nCastPoint )
				sCastMotive = 'R-保护团队撤退'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end	
	end
	
	
	--带线AOE
	-- local laneCreepList = bot:GetNearbyLaneCreeps( 1400, true )
	-- if bot:HasScepter() and #hEnemyList == 0
	-- 	and #laneCreepList >= 12
	-- 	and J.IsAllowedToSpam( bot, nManaCost )
	-- 	and ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
	-- then
	-- 	local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange - 50 , nRadius + 50 , 0, 0 )
	-- 	if locationAoEHurt.count >= 11
	-- 	then
	-- 		hCastTarget = locationAoEHurt.targetloc
	-- 		sCastMotive = 'R-清兵'
	-- 		return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
	-- 	end
	-- end
	
	
	return BOT_ACTION_DESIRE_NONE
	
	
end


return X
-- dota2jmz@163.com QQ:2462331592

