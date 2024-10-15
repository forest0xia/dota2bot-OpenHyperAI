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
						{2,3,1,2,2,6,2,3,3,3,6,1,1,1,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local nItemRandom = RandomInt(1, 2) == 1 and "item_butterfly" or "item_black_king_bar"

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
    "item_double_branches",
    "item_faerie_fire",

    "item_wraith_band",
    "item_falcon_blade",
    "item_power_treads",
    "item_magic_wand",
    "item_maelstrom",
    "item_dragon_lance",
    "item_gungir",--
    "item_black_king_bar",--
    "item_aghanims_shard",
    "item_greater_crit",--
    "item_force_staff",
    "item_hurricane_pike",--
    "item_satanic",--
    nItemRandom,--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local TheSwarm          = bot:GetAbilityByName('weaver_the_swarm')
local Shukuchi          = bot:GetAbilityByName('weaver_shukuchi')
-- local GeminateAttack    = bot:GetAbilityByName('weaver_geminate_attack')
local TimeLapse         = bot:GetAbilityByName('weaver_time_lapse')

local TheSwarmDesire, TheSwarmLocation
local ShukuchiDesire
local TimeLapseDesire

local botTarget
if bot.tryShukuchiKill == nil then bot.tryShukuchiKill = false end
if bot.ShukuchiKillTarget == nil then bot.ShukuchiKillTarget = nil end

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    if not bot:HasModifier("modifier_weaver_shukuchi")
    then
        bot.tryShukuchiKill = false
    end

    TimeLapseDesire, Target = X.ConsiderTimeLapse()
    if TimeLapseDesire > 0
    then
        if Target == 'self'
        then
            bot:Action_UseAbility(TimeLapse)
        else
            if bot:HasScepter()
            then
                bot:Action_UseAbilityOnEntity(TimeLapse, Target)
            end
        end

        return
    end

    ShukuchiDesire = X.ConsiderShukuchi()
    if ShukuchiDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbility(Shukuchi)
        return
    end

    TheSwarmDesire, TheSwarmLocation = X.ConsiderTheSwarm()
    if TheSwarmDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbilityOnLocation(TheSwarm, TheSwarmLocation)
        return
    end
end

function X.ConsiderTheSwarm()
    if not TheSwarm:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = TheSwarm:GetCastRange()
    local nRadius = TheSwarm:GetSpecialValueInt('spawn_radius')

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange * 0.8)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)
                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                end

                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(0.5)
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)
                    if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                    end

                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 5
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end

        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1600, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderShukuchi()
    if not Shukuchi:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nAttackRange = bot:GetAttackRange()
    local nDamage = Shukuchi:GetSpecialValueInt('damage')
    local nDuration = Shukuchi:GetSpecialValueFloat('duration')
    local nSpeed = 550
    local roshanLoc = J.GetCurrentRoshanLocation()
    local tormentorLoc = J.GetTormentorLocation(GetTeam())

    local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and enemyHero:DistanceFromFountain() > 600
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local eta = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed)
            if eta + 1 < nDuration
            then
                if J.IsInLaningPhase()
                then
                    local nInRangeTower = enemyHero:GetNearbyTowers(700, false)
                    if nInRangeTower ~= nil and #nInRangeTower == 0
                    then
                        bot.tryShukuchiKill = true
                        bot.ShukuchiKillTarget = enemyHero
                        return BOT_ACTION_DESIRE_HIGH
                    end
                else
                    bot.tryShukuchiKill = true
                    bot.ShukuchiKillTarget = enemyHero
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and not J.IsInRange(bot, botTarget, nAttackRange + 300)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end

        if bot:WasRecentlyDamagedByTower(2)
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if (J.IsTormentor(botTarget) or J.IsRoshan(botTarget))
        and J.IsInRange(bot, botTarget, 500)
        then
            if J.GetHP(bot) < 0.4
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsPushing(bot)
    and J.GetMP(bot) > 0.3
    then
        local tableNearbyEnemyTowers = bot:GetNearbyTowers(800, true)

        if tableNearbyEnemyTowers ~= nil
        and #tableNearbyEnemyTowers >= 1
        and tableNearbyEnemyTowers[1] ~= nil
        and
           J.IsInRange(tableNearbyEnemyTowers[1], bot, nAttackRange)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    -- if J.IsPushing(bot)
    -- then
    --     local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
    --     local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)
    --     local eta = (GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0)) / nSpeed)

    --     if J.GetMP(bot) > 0.33
    --     and nInRangeAlly ~= nil and #nInRangeAlly == 0
    --     and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
    --     and eta > nDuration + 1
    --     then
    --         return  BOT_ACTION_DESIRE_HIGH
    --     end
    -- end

    -- if J.IsDefending(bot)
    -- then
    --     local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
    --     local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)
        
    --     local eta = (GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToDefend, 0)) / nSpeed)

    --     if J.GetMP(bot) > 0.33
    --     and nInRangeAlly ~= nil and #nInRangeAlly == 0
    --     and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
    --     and eta > nDuration
    --     then
    --         return  BOT_ACTION_DESIRE_HIGH
    --     end
    -- end

    
    if J.IsFarming(bot)
    and J.GetHP(bot) > 0.25 and J.GetMP(bot) > 0.25
    then
        local npcTarget = bot:GetAttackTarget()

        if npcTarget ~= nil
        then
            return BOT_ACTION_DESIRE_MODERATE
        end
    end

 --    if J.IsFarming(bot)
	-- then
 --        local eta = (GetUnitToLocationDistance(bot, bot.farmLocation) / nSpeed)
 --        local nCreeps = bot:GetNearbyCreeps(1000, true)

	-- 	if nCreeps ~= nil and #nCreeps == 0
 --        and J.GetMP(bot) > 0.3
 --        and eta > nDuration
	-- 	then
	-- 		return BOT_ACTION_DESIRE_HIGH
	-- 	end

 --        if J.IsAttacking(bot)
 --        and J.IsValid(botTarget)
 --        and botTarget:IsCreep()
 --        and J.GetMP(bot) > 0.3
 --        and nCreeps ~= nil and #nCreeps >= 2
 --        then
 --            return BOT_ACTION_DESIRE_HIGH
 --        end
	-- end

 --    if J.IsLaning(bot)
	-- then
	-- 	if ((bot:GetMana() - Shukuchi:GetManaCost()) / bot:GetMaxMana()) > 0.8
	-- 	and bot:DistanceFromFountain() > 100
	-- 	and bot:DistanceFromFountain() < 6000
	-- 	and J.IsInLaningPhase()
	-- 	and #nEnemyHeroes == 0
	-- 	then
	-- 		local nLane = bot:GetAssignedLane()
	-- 		local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(), nLane, 0)
	-- 		local nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocation)

	-- 		if nDistFromLane > 800
	-- 		then
 --                return BOT_ACTION_DESIRE_HIGH
	-- 		end
	-- 	end
	-- end

    if J.IsDoingRoshan(bot)
    and J.GetMP(bot) > 0.4
    then
        local eta = (GetUnitToLocationDistance(bot, roshanLoc) / nSpeed)
        if eta > nDuration
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    and J.GetMP(bot) > 0.4
    then
        local eta = (GetUnitToLocationDistance(bot, tormentorLoc) / nSpeed)
        if eta > nDuration
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTimeLapse()
    if not TimeLapse:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly))
                then
                    if J.GetHP(bot) < 0.42
                    and Shukuchi:IsTrained() and Shukuchi:GetCooldownTimeRemaining() < 2.5
                    and J.IsChasingTarget(enemyHero, bot)
                    then
                        return BOT_ACTION_DESIRE_HIGH, 'self'
                    end
                end

                if J.GetHP(bot) < 0.33
                and bot:WasRecentlyDamagedByHero(enemyHero, 1)
                then
                    return BOT_ACTION_DESIRE_HIGH, 'self'
                end
            end
        end
	end

	if bot:HasScepter()
	then
        local nCastRange = TimeLapse:GetCastRange()
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)

		for _, allyHero in pairs(nInRangeAlly)
        do
			if J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and J.GetHP(allyHero) < 0.33
            and J.IsCore(allyHero)
            and J.GetHP(bot) > 0.75
            and allyHero:WasRecentlyDamagedByAnyHero(2)
            and not J.IsSuspiciousIllusion(allyHero)
            and not allyHero:HasModifier('modifier_legion_commander_duel')
            and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
                local nInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)
                for _, enemyHero in pairs(nInRangeEnemy)
                do
                    if J.IsValidHero(enemyHero)
                    and J.IsChasingTarget(enemyHero, allyHero)
                    and not J.IsSuspiciousIllusion(enemyHero)
                    and not J.IsDisabled(enemyHero)
                    then
                        return BOT_ACTION_DESIRE_HIGH, allyHero
                    end
                end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X