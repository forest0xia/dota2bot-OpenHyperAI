local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,1,3,1,2,1,6,2,2,2,6,3,3,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

local sUtility = {"item_lotus_orb", "item_crimson_guard", "item_heavens_halberd"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

sRoleItemsBuyList['pos_1'] = {
	"item_bristleback_outfit",
	"item_blade_mail",--
	"item_heavens_halberd",--
	"item_lotus_orb",--
	"item_black_king_bar",--
	"item_aghanims_shard",
	"item_travel_boots",
	"item_abyssal_blade",--
	-- "item_heart",--
	"item_moon_shard",
    "item_ultimate_scepter_2",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",
    "item_double_gauntlets",

    "item_bracer",
    "item_helm_of_iron_will",
    "item_soul_ring",
    "item_arcane_boots",
    "item_magic_wand",
    "item_veil_of_discord",
    "item_mekansm",
    "item_pipe",--
    "item_guardian_greaves",--
    nUtility,--
    "item_aghanims_shard",
    "item_shivas_guard",--
    "item_octarine_core",--
    "item_sheepstick",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_4'] = {

	"item_tank_outfit",
	"item_crimson_guard",
	"item_heavens_halberd",
	"item_lotus_orb",
	"item_aghanims_shard",
	"item_gungir",--
	"item_travel_boots",
	"item_assault",
	"item_heart",
	"item_moon_shard",
    "item_ultimate_scepter_2",
	"item_travel_boots_2",

}

sRoleItemsBuyList['pos_5'] = {
	'item_mage_outfit',
	"item_ancient_janggo",
	"item_glimmer_cape",--
	"item_boots_of_bearing",--
	"item_pipe",--
	"item_aghanims_shard",
	"item_cyclone",
    "item_shivas_guard",--
	"item_sheepstick",--
    "item_heart",--
	"item_octarine_core",--
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_power_treads",
	"item_quelling_blade",

	"item_assault",
	"item_magic_wand",
	
	"item_abyssal_blade",
	"item_magic_wand",
	
	"item_assault",
	"item_ancient_janggo",

    "item_quelling_blade",
    "item_bracer",
    "item_soul_ring",
    "item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
	Minion.MinionThink(hMinionUnit, bot)
end

local Firestorm     = bot:GetAbilityByName('abyssal_underlord_firestorm')
local PitOfMalice   = bot:GetAbilityByName('abyssal_underlord_pit_of_malice')
-- local AtrophyAura   = bot:GetAbilityByName('abyssal_underlord_atrophy_aura')
local FiendsGate    = bot:GetAbilityByName('abyssal_underlord_dark_portal')

local FirestormDesire, FirestormLocation
local PitOfMaliceDesire, PitOfMaliceLocation
local FiendsGateDesire, FiendsGateLocation

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    PitOfMaliceDesire, PitOfMaliceLocation = X.ConsiderPitOfMalice()
    if PitOfMaliceDesire > 0
    then
        bot:Action_UseAbilityOnLocation(PitOfMalice, PitOfMaliceLocation)
        return
    end

    FirestormDesire, FirestormLocation = X.ConsiderFirestorm()
    if FirestormDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Firestorm, FirestormLocation)
        return
    end

    FiendsGateDesire, FiendsGateLocation = X.ConsiderFiendsGate()
    if FiendsGateDesire > 0
    then
        bot:Action_UseAbilityOnLocation(FiendsGate, FiendsGateLocation)
        return
    end
end

function X.ConsiderFirestorm()
    if not Firestorm:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, Firestorm:GetCastRange())
    local nRadius = Firestorm:GetSpecialValueInt('radius')
    local nCastPoint = Firestorm:GetCastPoint()

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange + nRadius, nRadius, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, nLocationAoE.targetloc, nCastRange)
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nCastRange + nRadius)

                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
                end

                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
            end
		end
	end

    if J.IsPushing(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + nRadius, true)
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end
	end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange + nRadius)
            if  nNeutralCreeps ~= nil and #nNeutralCreeps >= 3
            and J.GetMP(bot) > 0.3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + nRadius, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and J.GetMP(bot) > 0.3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
        end
    end

    if J.IsLaning(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + nRadius, true)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and J.IsAttacking(bot)
        and J.GetMP(bot) > 0.5
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderPitOfMalice()
    if not PitOfMalice:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, PitOfMalice:GetCastRange())
	local nRadius = PitOfMalice:GetSpecialValueInt('radius')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and enemyHero:IsChanneling()
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, enemyHero:GetLocation(), nCastRange)
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
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
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
                end

                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2.5))
                and GetUnitToUnitDistance(bot, enemyHero) < nRadius + 100
                then
                    return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
                end
            end
        end
    end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange + nRadius, nRadius, 0, 0)
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeEnemy >= 1
        and not (#nInRangeAlly > #nInRangeEnemy + 1)
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFiendsGate()
    if not FiendsGate:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)

    if  nTeamFightLocation ~= nil
    and GetUnitToLocationDistance(bot, nTeamFightLocation) > 2500
    and not J.IsGoingOnSomeone(bot)
    and not J.IsRetreating(bot)
    and not J.IsInLaningPhase()
    then
        local nInRangeAlly = J.GetAlliesNearLoc(nTeamFightLocation, 1200)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nTeamFightLocation, 1200)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly + 1 >= #nInRangeEnemy
        and #nInRangeEnemy >= 1
        then
            local targetLoc = J.GetCenterOfUnits(nInRangeAlly)

            if  IsLocationPassable(targetLoc)
            and not J.IsLocationInChrono(targetLoc)
            and not J.IsLocationInBlackHole(targetLoc)
            and not J.IsLocationInArena(targetLoc, 600)
            then
                bot:SetTarget(nInRangeEnemy[1])
                return BOT_ACTION_DESIRE_HIGH, targetLoc
            end
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and GetUnitToUnitDistance(bot, botTarget) > 2500
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsInLaningPhase()
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, false, BOT_MODE_NONE)
            local nEnemyTowers = bot:GetNearbyTowers(700, true)

			if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and nInRangeEnemy ~= nil and nEnemyTowers ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            and #nInRangeEnemy == 0 and #nEnemyTowers == 0
            then
                local targetLoc = J.GetCenterOfUnits(nInRangeAlly)

                if  IsLocationPassable(targetLoc)
                and not J.IsLocationInChrono(targetLoc)
                and not J.IsLocationInBlackHole(targetLoc)
                and not J.IsLocationInArena(targetLoc, 600)
                then
                    bot:SetTarget(botTarget)
                    return BOT_ACTION_DESIRE_HIGH, targetLoc
                end
            end
		end
	end

    local aveDist = {0,0,0}
    local pushCount = {0,0,0}
    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if  J.IsValidHero(allyHero)
        and J.IsGoingOnSomeone(allyHero)
        and GetUnitToUnitDistance(bot, allyHero) > 2500
        and not allyHero:IsIllusion()
        and not J.IsInLaningPhase()
        then
            local allyTarget = allyHero:GetAttackTarget()
            local nAllyInRangeAlly = J.GetNearbyHeroes(allyHero, 800, false, BOT_MODE_NONE)

            if  J.IsValidTarget(allyTarget)
            and J.IsInRange(allyHero, allyTarget, 800)
            and J.GetHP(allyHero) > 0.5
            -- and J.IsCore(allyTarget)
            and not J.IsSuspiciousIllusion(allyTarget)
            then
                local nTargetInRangeAlly = J.GetNearbyHeroes(allyTarget, 800, false, BOT_MODE_NONE)
                local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, false, BOT_MODE_NONE)
                local nEnemyTowers = bot:GetNearbyTowers(700, true)

                if  nAllyInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nAllyInRangeAlly + 1 >= #nTargetInRangeAlly
                and #nTargetInRangeAlly >= 1
                and nInRangeEnemy ~= nil and nEnemyTowers ~= nil
                and #nInRangeEnemy == 0 and #nEnemyTowers == 0
                then
                    local targetLoc = J.GetCenterOfUnits(allyHero:GetExtrapolatedLocation(1))

                    if  IsLocationPassable(targetLoc)
                    and not J.IsLocationInChrono(targetLoc)
                    and not J.IsLocationInBlackHole(targetLoc)
                    and not J.IsLocationInArena(targetLoc, 600)
                    then
                        bot:SetTarget(allyTarget)
                        return BOT_ACTION_DESIRE_HIGH, targetLoc
                    end
                end
            end
        end

        if  J.IsValidHero(allyHero)
        and bot ~= allyHero
        and not J.IsSuspiciousIllusion(allyHero)
        and not J.IsMeepoClone(allyHero)
        then
            if  allyHero:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
            and bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
            then
                pushCount[1] = pushCount[1] + 1
                aveDist[1] = aveDist[1] + GetUnitToLocationDistance(allyHero, GetLaneFrontLocation(GetTeam(), LANE_TOP, 0))
            end

            if  allyHero:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
            and bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
            then
                pushCount[2] = pushCount[2] + 1
                aveDist[2] = aveDist[2] + GetUnitToLocationDistance(allyHero, GetLaneFrontLocation(GetTeam(), LANE_MID, 0))
            end

            if  allyHero:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
            and bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
            then
                pushCount[3] = pushCount[3] + 1
                aveDist[3] = aveDist[3] + GetUnitToLocationDistance(allyHero, GetLaneFrontLocation(GetTeam(), LANE_BOT, 0))
            end
        end
    end

    if pushCount[1] ~= nil and pushCount[1] >= 3 and (aveDist[1] / pushCount[1]) <= 1200
    then
        if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), LANE_TOP, 0)) > 4000
        then
            return BOT_ACTION_DESIRE_HIGH, GetLaneFrontLocation(GetTeam(), LANE_TOP, 0)
        end
    elseif pushCount[2] ~= nil and pushCount[2] >= 3 and (aveDist[2] / pushCount[2]) <= 1200
    then
        if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), LANE_MID, 0)) > 4000
        then
            return BOT_ACTION_DESIRE_HIGH, GetLaneFrontLocation(GetTeam(), LANE_MID, 0)
        end
    elseif pushCount[3] ~= nil and pushCount[3] >= 3 and (aveDist[3] / pushCount[3]) <= 1200
    then
        if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), LANE_BOT, 0)) > 4000
        then
            return BOT_ACTION_DESIRE_HIGH, GetLaneFrontLocation(GetTeam(), LANE_BOT, 0)
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

return X