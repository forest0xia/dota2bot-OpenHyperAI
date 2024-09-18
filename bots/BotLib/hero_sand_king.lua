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
						{1,3,2,2,2,6,2,1,1,1,6,3,3,3,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sCrimsonPipe = RandomInt( 1, 2 ) == 1 and "item_crimson_guard" or "item_pipe"

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_3'] = {
	"item_tango",
	"item_double_branches",
	"item_circlet",
	"item_circlet",
	"item_quelling_blade",

	"item_bracer",
	"item_boots",
	"item_veil_of_discord",
	"item_magic_wand",
	"item_blink",
	"item_cyclone",
	"item_shivas_guard",--
	"item_travel_boots",
	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_black_king_bar",--
	sCrimsonPipe,--
	"item_overwhelming_blink",--
	"item_ultimate_scepter_2",
	"item_wind_waker",--
	"item_travel_boots_2",--
	"item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = {
	"item_priest_outfit",
	"item_mekansm",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
--	"item_wraith_pact",
	"item_ultimate_scepter",
	"item_shivas_guard",
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_sheepstick",
}

sRoleItemsBuyList['pos_5'] = {
    "item_blood_grenade",
	"item_mage_outfit",
	"item_ancient_janggo",
	"item_glimmer_cape",
	"item_boots_of_bearing",
	"item_pipe",
    "item_ultimate_scepter",
	"item_cyclone",
--	"item_wraith_pact",
    "item_lotus_orb",--
	"item_gungir",--
	"item_shivas_guard",
	"item_sheepstick",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",
}
if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_sand_king

"Ability1"		"sandking_burrowstrike"
"Ability2"		"sandking_sand_storm"
"Ability3"		"sandking_caustic_finale"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"sandking_epicenter"
"Ability10"		"special_bonus_movement_speed_20"
"Ability11"		"special_bonus_hp_200"
"Ability12"		"special_bonus_unique_sand_king_2"
"Ability13"		"special_bonus_unique_sand_king_3"
"Ability14"		"special_bonus_armor_10"
"Ability15"		"special_bonus_unique_sand_king"
"Ability16"		"special_bonus_hp_regen_50"
"Ability17"		"special_bonus_unique_sand_king_4"

modifier_sand_king_caustic_finale
modifier_sand_king_caustic_finale_orb
modifier_sand_king_caustic_finale_slow
modifier_sandking_impale
modifier_sandking_burrowstrike
modifier_sandking_sand_storm
modifier_sandking_sand_storm_slow
modifier_sand_king_epicenter
modifier_sand_king_epicenter_slow


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local Stinger  = bot:GetAbilityByName('sandking_scorpion_strike')
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castWDesire
local StingerDesire, StingerLocation
local castRDesire

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


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

	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQTarget )
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

	castRDesire, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityR )
		return

	end

	StingerDesire, StingerLocation = X.ConsiderStinger()
	if StingerDesire > 0
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnLocation(Stinger, StingerLocation)
		return
	end
end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nRadius	 = abilityQ:GetSpecialValueInt( "burrow_width" )
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local nInBonusEnemyList = J.GetNearbyHeroes(bot, nCastRange + 200, true, BOT_MODE_NONE )

	local nTargetLocation = nil

	--击杀
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage + bot:GetAttackDamage(), 3.0 )
		then
			nTargetLocation = npcEnemy:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-击杀'..J.Chat.GetNormName( npcEnemy )
		end
	end

	--Aoe
	local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius + 40, 0, 0 )
	if nCanHurtEnemyAoE.count >= 3
	then
		nTargetLocation = nCanHurtEnemyAoE.targetloc
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-Aoe:'..( nCanHurtEnemyAoE.count )
	end

	--团战
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius + 30, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-TeamFight'
		end
	end


	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHP( botTarget ) < 0.38
			then
				nTargetLocation = botTarget:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-攻击:'..J.Chat.GetNormName( botTarget )
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
		and ( nSkillLV >= 4 or nHP < 0.4 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) or bot:GetActiveModeDesire() > 0.7 )
				and not bot:IsFacingLocation( npcEnemy:GetLocation(), 150 )
			then
				local nDistance = GetUnitToUnitDistance( bot, npcEnemy )
				nTargetLocation = J.GetUnitTowardDistanceLocation( npcEnemy, bot, nDistance + nCastRange )
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-撤退:'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--Farm
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, 1000 )
			and bot:IsFacingLocation( botTarget:GetLocation(), 45 )
			and ( botTarget:GetMagicResist() < 0.4 or nMP > 0.9 )
		then
			local nShouldHurtCount = nMP > 0.5 and 3 or 4
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, 200, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q-打钱:"..locationAoE.count
			end
		end
	end


	--Push
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and nSkillLV >= 2 and DotaTime() > 8 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1300, true )
		if #laneCreepList >= 5
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 90, 0, 0 )
			if locationAoEHurt.count >= 3
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q-推线"..locationAoEHurt.count
			end
		end
	end


	--Roshan
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 600
	then
		if J.IsRoshan( botTarget ) and J.GetHP( botTarget ) > 0.15
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			nTargetLocation = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q-肉山"
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange()
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE )

	local nRadius = abilityW:GetSpecialValueInt( "sand_storm_radius" )

	--躲弹道
	if J.IsNotAttackProjectileIncoming( bot, 400 )
		or ( J.IsWithoutTarget( bot ) and J.GetAttackProjectileDamageByRange( bot, 1600 ) >= bot:GetHealth() )
	then
		return BOT_ACTION_DESIRE_HIGH, vEscapeLoc, 'W-躲避'
	end


	--团战Aoe
	if J.IsInTeamFight( bot )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, 100, nRadius * 0.6, 2 )
		if nAoeLoc ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, 'W-团战Aoe'
		end
	end


	--进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nRadius/3 )
			and J.CanCastOnNonMagicImmune( botTarget )
		then
			if nSkillLV >= 3 or nMP > 0.88 or J.GetHP( botTarget ) < 0.4
			then
				return BOT_ACTION_DESIRE_HIGH, "W-进攻:"..J.Chat.GetNormName( botTarget )
			end
		end
	end


	--带线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and nSkillLV >= 4 and DotaTime() > 18 * 60
		and #hAllyList <= 1 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 700, true )
		if #laneCreepList >= 8
			and J.IsValid( laneCreepList[1] )
			and J.IsValid( botTarget )
			and J.IsInRange( botTarget, bot, 300 )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			return BOT_ACTION_DESIRE_HIGH, "W-推线"..#laneCreepList
		end
	end


	--打野
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, 300 )
			and bot:IsFacingLocation( botTarget:GetLocation(), 20 )
			and ( botTarget:GetMagicResist() < 0.4 or nMP > 0.8 )
		then
			local nShouldHurtCount = nMP > 0.5 and 4 or 5
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 100, 600, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W-打钱:"..locationAoE.count
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
		and ( nSkillLV >= 3 or nHP < 0.5 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) or bot:GetActiveModeDesire() > 0.7 )
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'W-撤退:'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end



	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderStinger()
	if not Stinger:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, Stinger:GetCastRange())
	local nRadius = Stinger:GetSpecialValueInt('radius')
	local nManaAfter = J.GetManaAfter(Stinger:GetManaCost()) * bot:GetMana()
	local nAbilityLevel = Stinger:GetLevel()

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nCastRange + nRadius)

                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
					if  GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nInRangeEnemy)) > nCastRange
					and GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nInRangeEnemy)) < nCastRange + nRadius
					then
						return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
					else
						return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
					end

                end

				if  J.IsInRange(bot, botTarget, nCastRange + nRadius)
				and not J.IsInRange(bot, botTarget, nCastRange)
				then
					return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
				end
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
			and (not abilityQ:IsFullyCastable() and not abilityW:IsFullyCastable())
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                and GetUnitToUnitDistance(bot, enemyHero) < nRadius
                then
                    return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + enemyHero:GetLocation()) / 2
                end
            end
        end
    end

	if  (J.IsPushing(bot) or J.IsDefending(bot))
	and nManaAfter > abilityQ:GetManaCost() + abilityW:GetManaCost()
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 5
		and J.CanBeAttacked(nEnemyLaneCreeps[1])
		and not J.IsRunning(nEnemyLaneCreeps[1])
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end
	end

    if  J.IsFarming(bot)
	and nManaAfter > abilityQ:GetManaCost() + abilityW:GetManaCost()
    then
        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(700)
            if nNeutralCreeps ~= nil and #nNeutralCreeps >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(700, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
			and J.CanBeAttacked(nEnemyLaneCreeps[1])
			and not J.IsRunning(nEnemyLaneCreeps[1])
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
        end
    end

    if  J.IsLaning(bot)
	and nManaAfter > abilityQ:GetManaCost() + abilityW:GetManaCost()
	and nAbilityLevel >= 2
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + nRadius, true)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and J.IsAttacking(bot)
		and J.CanBeAttacked(nEnemyLaneCreeps[1])
		and not J.IsRunning(nEnemyLaneCreeps[1])
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end
	end

    if  J.IsDoingRoshan(bot)
	and nManaAfter > abilityQ:GetManaCost() + abilityW:GetManaCost()
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 600)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if  J.IsDoingTormentor(bot)
	and nManaAfter > abilityQ:GetManaCost() + abilityW:GetManaCost()
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 600)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange()
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	local nRadius = abilityR:GetSpecialValueInt( "epicenter_radius" )
	local nPulses = abilityR:GetSpecialValueInt( "epicenter_pulses" )
	local nMaxRadius = nRadius + nPulses * 50

	--两机会或两个控后Aoe
	if J.IsInTeamFight( bot, 1600 )
	then
		--有Aoe的机会先开大
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, 1200, 400, 2 )
		if nAoeLoc ~= nil
			and #hAllyList >= 2
		then
			local npcEnemy = hEnemyList[1]
			if J.IsValidHero( npcEnemy )
				and not J.IsInRange( bot, npcEnemy, 800 )
				and J.IsInRange( bot, npcEnemy, 1200 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and ( #hEnemyList >= 2 or npcEnemy:GetHealth() > bot:GetAttackDamage() * 5 )
			then
				return BOT_ACTION_DESIRE_HIGH, 'R-团战1'
			end
		end

		--敌人被控制住再开大
		if #hEnemyList >= 2
		then
			local nDisabledCount = 0
			local nTotalCount = 0
			for _, npcEnemy in pairs( hEnemyList )
			do
				if J.IsValidHero( npcEnemy )
					and J.IsInRange( bot, npcEnemy, 1000 )
					and J.CanCastOnNonMagicImmune( npcEnemy )
				then
					nTotalCount = nTotalCount + 1
					if J.IsDisabled( npcEnemy )
						or npcEnemy:IsSilenced()
						or npcEnemy:GetMana() < 50
					then
						nDisabledCount = nDisabledCount + 1
					end
				end
			end

			if nDisabledCount == nTotalCount
				and J.IsInRange( bot, hEnemyList[1], nMaxRadius * 0.5 )
			then
				return BOT_ACTION_DESIRE_HIGH, 'R-团战2'
			end
		end

	end


	--进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, 1000 )
		then
			local nDamageToTarget = bot:GetEstimatedDamageToTarget( true, botTarget, 6.0, DAMAGE_TYPE_PHYSICAL )
			if not J.CanKillTarget( botTarget, nDamageToTarget, DAMAGE_TYPE_PHYSICAL )
			then

				if ( bot:IsInvisible() or bot:IsMagicImmune() )
					and J.IsInRange( bot, botTarget, nRadius + 200 )
				then
					return BOT_ACTION_DESIRE_HIGH, "R-隐身或魔免开大进攻"..J.Chat.GetNormName( botTarget )
				end

				if ( J.IsDisabled( botTarget ) or botTarget:IsSilenced() )
					and J.IsInRange( bot, botTarget, nRadius + 150 )
				then
					return BOT_ACTION_DESIRE_HIGH, "R-找机会开大进攻"..J.Chat.GetNormName( botTarget )
				end

			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592..

