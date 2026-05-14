local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
    {-- pos1/2: right-click focused
        ['t25'] = {10, 0},
        ['t20'] = {10, 0},
        ['t15'] = {0, 10},
        ['t10'] = {0, 10},
    },
    {-- pos3: offlane/utility
        ['t25'] = {10, 0},
        ['t20'] = {10, 0},
        ['t15'] = {0, 10},
        ['t10'] = {0, 10},
    },
    {-- pos4/5: support
        ['t25'] = {0, 10},
        ['t20'] = {0, 10},
        ['t15'] = {10, 0},
        ['t10'] = {10, 0},
    }
}

local tAllAbilityBuildList = {
    {1,2,1,2,1,6,1,2,2,3,6,3,3,3,6},-- pos1/2: Sprout max first (damage scales for right-click)
    {3,1,3,2,3,6,3,2,2,2,6,1,1,1,6},-- pos3: Nature's Call max first (push/pressure)
    {2,1,1,2,1,6,1,2,2,3,6,3,3,3,6},-- pos4/5: Early TP at 1, then Sprout max (ganking)
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_1" or sRole == "pos_2" then
    nAbilityBuildList = tAllAbilityBuildList[1]
    nTalentBuildList  = J.Skill.GetTalentBuild(tTalentTreeList[1])
elseif sRole == "pos_3" then
    nAbilityBuildList = tAllAbilityBuildList[2]
    nTalentBuildList  = J.Skill.GetTalentBuild(tTalentTreeList[2])
else
    nAbilityBuildList = tAllAbilityBuildList[3]
    nTalentBuildList  = J.Skill.GetTalentBuild(tTalentTreeList[3])
end

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_faerie_fire",
    "item_double_branches",
    "item_circlet",
    "item_mantle",

    "item_null_talisman",
    "item_magic_wand",
    "item_power_treads",
    "item_maelstrom",
    "item_orchid",
    "item_black_king_bar",--
    "item_mjollnir",--
    "item_aghanims_shard",
    "item_hurricane_pike",--
    "item_satanic",--
    "item_bloodthorn",--
    "item_greater_crit",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_double_circlet",

    "item_bottle",
    "item_null_talisman",
    "item_magic_wand",
    "item_power_treads",
    "item_maelstrom",
    "item_orchid",
    "item_black_king_bar",--
    "item_mjollnir",--
    "item_aghanims_shard",
    "item_hurricane_pike",--
    "item_satanic",--
    "item_bloodthorn",--
    "item_greater_crit",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_3'] = {
    "item_blight_stone",
    "item_tango",
    "item_faerie_fire",
    "item_double_branches",

    "item_magic_wand",
    "item_power_treads",
    "item_maelstrom",
    "item_rod_of_atos",  -- root + Sprout synergy for lockdown
    "item_black_king_bar",--
    "item_mjollnir",--
    "item_aghanims_shard",
    "item_assault",--
    "item_hurricane_pike",--
    "item_sheepstick",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_4'] = {
    "item_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_double_circlet",

    "item_tranquil_boots",
    "item_magic_wand",
    "item_urn_of_shadows",
    "item_solar_crest",--
    "item_aghanims_shard",
    "item_ancient_janggo",
    "item_spirit_vessel",
    "item_boots_of_bearing",--
    "item_ultimate_scepter",
    "item_orchid",
    "item_heavens_halberd",--
    "item_bloodthorn",--
    "item_ultimate_scepter_2",
    "item_sheepstick",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_double_circlet",

    "item_tranquil_boots",
    "item_magic_wand",
    "item_urn_of_shadows",
    "item_solar_crest",--
    "item_aghanims_shard",
    "item_mekansm",
    "item_spirit_vessel",--
    "item_guardian_greaves",--
    "item_ultimate_scepter",
    "item_orchid",
    "item_heavens_halberd",--
    "item_bloodthorn",--
    "item_ultimate_scepter_2",
    "item_sheepstick",--
    "item_moon_shard",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_black_king_bar",
	"item_quelling_blade",
	"item_null_talisman",
	"item_ultimate_scepter",
	"item_magic_wand",
	"item_cyclone",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

-- Re-fetch ability handles each tick for safety (Aghs upgrades, etc.)
local Sprout, Teleportation, NaturesCall, CurseOfTheOldGrowth, WrathOfNature

local function RefreshAbilities()
    Sprout              = bot:GetAbilityByName('furion_sprout')
    Teleportation       = bot:GetAbilityByName('furion_teleportation')
    NaturesCall         = bot:GetAbilityByName('furion_force_of_nature')
    CurseOfTheOldGrowth = bot:GetAbilityByName('furion_curse_of_the_forest')
    WrathOfNature       = bot:GetAbilityByName('furion_wrath_of_nature')
end

-- Cached per-tick variables
local botTarget, botHP, nAllyHeroes, nEnemyHeroes, bAttacking

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    RefreshAbilities()
    botTarget = J.GetProperTarget(bot)
    botHP = J.GetHP(bot)
    nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    bAttacking = J.IsAttacking(bot)

    -- External TP request
    if  bot.useProphetTP
    and bot.ProphetTPLocation ~= nil
    and J.CanCastAbility(Teleportation)
    then
        bot:Action_UseAbilityOnLocation(Teleportation, bot.ProphetTPLocation)
        bot.useProphetTP = false
        return
    end

    -- Sprout+NaturesCall combo for farming/pushing
    local scDesire, scTarget, scLoc = X.ConsiderSproutCall()
    if scDesire > 0 and scTarget ~= nil then
        bot:Action_ClearActions(true)
        bot:ActionQueue_UseAbilityOnEntity(Sprout, scTarget)
        bot:ActionQueue_Delay(0.35 + 0.44)
        bot:ActionQueue_UseAbilityOnLocation(NaturesCall, scLoc)
        return
    end

    local tpDesire, tpLoc = X.ConsiderTeleportation()
    if tpDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(Teleportation, tpLoc)
        bot.useProphetTP = false
        return
    end

    local sproutDesire, sproutTarget = X.ConsiderSprout()
    if sproutDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(Sprout, sproutTarget)
        return
    end

    local ncDesire, ncLoc = X.ConsiderNaturesCall()
    if ncDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(NaturesCall, GetTreeLocation(ncLoc))
        return
    end

    local curseDesire = X.ConsiderCurseOfTheOldGrowth()
    if curseDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbility(CurseOfTheOldGrowth)
        return
    end

    local wonDesire, wonTarget = X.ConsiderWrathOfNature()
    if wonDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(WrathOfNature, wonTarget)
        return
    end
end

function X.ConsiderSprout()
    if not J.CanCastAbility(Sprout) then return BOT_ACTION_DESIRE_NONE, nil end

    local nCastRange = J.GetProperCastRange(false, bot, Sprout:GetCastRange())
    local nDuration = Sprout:GetSpecialValueInt('duration')

    -- Tree-walkers negate Sprout entirely
    local function CanBeSprouted(target)
        return J.IsValidTarget(target)
            and not J.IsSuspiciousIllusion(target)
            and not target:HasModifier('modifier_hoodwink_scurry_active')
            and not target:HasModifier('modifier_item_spider_legs_active')
            and not target:HasModifier('modifier_enigma_black_hole_pull')
            and not target:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not target:HasModifier('modifier_legion_commander_duel')
            and not target:HasModifier('modifier_necrolyte_reapers_scythe')
    end

    -- Teamfight: target highest-threat enemy
    if J.IsInTeamFight(bot, 1200) then
        local bestTarget, bestDmg = nil, 0
        for _, enemy in pairs(nEnemyHeroes) do
            if CanBeSprouted(enemy)
            and not J.IsDisabled(enemy)
            and J.IsInRange(bot, enemy, nCastRange) then
                local dmg = enemy:GetEstimatedDamageToTarget(true, bot, 5, DAMAGE_TYPE_ALL)
                if dmg > bestDmg then
                    bestTarget = enemy
                    bestDmg = dmg
                end
            end
        end
        if bestTarget then return BOT_ACTION_DESIRE_HIGH, bestTarget end
    end

    -- Going on someone
    if J.IsGoingOnSomeone(bot) then
        if CanBeSprouted(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsDisabled(botTarget) then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    -- Retreating: sprout closest chaser (per-hero damage check, self-safety)
    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot) then
        for _, enemy in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.CanCastOnMagicImmune(enemy)
            and J.IsInRange(bot, enemy, nCastRange)
            and not J.IsInRange(bot, enemy, Sprout:GetSpecialValueInt('radius'))  -- don't trap self
            and J.IsChasingTarget(enemy, bot)
            and bot:WasRecentlyDamagedByHero(enemy, 2.0) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end

    -- Ally defense: sprout enemies chasing retreating allies
    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(5)
        and not allyHero:IsIllusion()
        and (not J.IsCore(bot) or J.GetMP(bot) > 0.5) then
            local nAllyEnemies = allyHero:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
            if J.IsValidHero(nAllyEnemies[1])
            and CanBeSprouted(nAllyEnemies[1])
            and J.IsInRange(bot, nAllyEnemies[1], nCastRange)
            and J.IsChasingTarget(nAllyEnemies[1], allyHero) then
                return BOT_ACTION_DESIRE_HIGH, nAllyEnemies[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderTeleportation()
    if not J.CanCastAbility(Teleportation) then return BOT_ACTION_DESIRE_NONE, 0 end

    local nChannelTime = Teleportation:GetCastPoint()
    local nMoveSpeed = bot:GetCurrentMovementSpeed()

    -- Projectile interrupt check: don't TP if stun is incoming
    if J.IsStunProjectileIncoming and J.IsStunProjectileIncoming(bot, 1200) then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    -- Stuck
    if J.IsStuck(bot) then
        return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain()
    end

    -- Teamfight TP
    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    and (not J.IsCore(bot) or not J.IsInLaningPhase() or bot:GetNetWorth() > 3500) then
        local dist = GetUnitToLocationDistance(bot, nTeamFightLocation)
        local walkTime = dist / nMoveSpeed
        if walkTime > nChannelTime + 2 then
            local allies = J.GetAlliesNearLoc(nTeamFightLocation, 1200)
            if allies ~= nil and #allies >= 1 and J.IsValidHero(allies[#allies]) then
                return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(allies[#allies], nChannelTime)
            end
        end
    end

    -- Ally gank TP
    for i = 1, #GetTeamPlayers(GetTeam()) do
        local allyHero = GetTeamMember(i)
        if J.IsValidHero(allyHero)
        and J.IsGoingOnSomeone(allyHero)
        and not allyHero:IsIllusion()
        and (not J.IsCore(bot) or not J.IsInLaningPhase() or bot:GetNetWorth() > 3500) then
            local dist = GetUnitToUnitDistance(bot, allyHero)
            local walkTime = dist / nMoveSpeed
            if walkTime > nChannelTime + 2 then
                local allyTarget = allyHero:GetAttackTarget()
                if J.IsValidTarget(allyTarget)
                and J.IsInRange(allyHero, allyTarget, 800)
                and J.GetHP(allyHero) > 0.25
                and not J.IsSuspiciousIllusion(allyTarget) then
                    local nTargetAllies = allyTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE)
                    local nAllyAllies = allyHero:GetNearbyHeroes(800, false, BOT_MODE_NONE)
                    if nAllyAllies and nTargetAllies
                    and #nAllyAllies + 1 >= #nTargetAllies
                    and not J.IsLocationInChrono(J.GetCorrectLoc(allyHero, nChannelTime)) then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(allyHero, nChannelTime)
                    end
                end
            end
        end
    end

    -- Retreat TP: only when no one can interrupt
    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:WasRecentlyDamagedByAnyHero(4)
    and bot:GetActiveModeDesire() > 0.75
    and bot:GetLevel() >= 6 then
        if #nEnemyHeroes == 0 then  -- safe to channel
            local fTimeToFountain = GetUnitToLocationDistance(bot, J.GetTeamFountain()) / nMoveSpeed
            if fTimeToFountain > nChannelTime + 1 then
                return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain()
            end
        end
    end

    -- Push TP: TP to lane front when pushing and far away
    if J.IsPushing(bot) and not bAttacking and #nEnemyHeroes == 0 then
        local nLane = bot:GetAssignedLane()
        if nLane ~= nil and nLane > 0 then
            local pushLoc = GetLaneFrontLocation(GetTeam(), nLane, 0)
            local dist = GetUnitToLocationDistance(bot, pushLoc)
            local walkTime = dist / nMoveSpeed
            if walkTime > nChannelTime * 2 and IsLocationPassable(pushLoc) then
                return BOT_ACTION_DESIRE_MODERATE, pushLoc
            end
        end
    end

    -- Defend TP: TP behind the front line
    if J.IsDefending(bot) and #nEnemyHeroes == 0 then
        local nDefendLane, _ = J.GetMostDefendLaneDesire()
        if nDefendLane ~= nil then
            local defendLoc = GetLaneFrontLocation(GetTeam(), nDefendLane, -1000)
            local dist = GetUnitToLocationDistance(bot, defendLoc)
            local walkTime = dist / nMoveSpeed
            if walkTime > nChannelTime * 2 and IsLocationPassable(defendLoc) then
                return BOT_ACTION_DESIRE_MODERATE, defendLoc
            end
        end
    end

    -- Roshan/Tormentor TP
    if J.IsDoingRoshan(bot) then
        local loc = J.GetCurrentRoshanLocation()
        local allies = J.GetAlliesNearLoc(loc, 700)
        local dist = GetUnitToLocationDistance(bot, loc)
        if allies and #allies >= 2 and dist / nMoveSpeed > nChannelTime + 1 then
            return BOT_ACTION_DESIRE_HIGH, loc
        end
    end

    if J.IsDoingTormentor(bot) then
        local loc = J.GetTormentorLocation(GetTeam())
        local allies = J.GetAlliesNearLoc(loc, 700)
        local dist = GetUnitToLocationDistance(bot, loc)
        if allies and #allies >= 2 and dist / nMoveSpeed > nChannelTime + 1 then
            return BOT_ACTION_DESIRE_HIGH, loc
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderNaturesCall()
    if not J.CanCastAbility(NaturesCall) then return BOT_ACTION_DESIRE_NONE, 0 end

    local nCastRange = J.GetProperCastRange(false, bot, NaturesCall:GetCastRange())
    local nInRangeTrees = bot:GetNearbyTrees(nCastRange)

    if nInRangeTrees == nil or #nInRangeTrees < 1 then return BOT_ACTION_DESIRE_NONE, 0 end

    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

    -- Teamfight: summon treants for extra damage/body block
    if J.IsInTeamFight(bot, 1200) then
        return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
    end

    -- Going on someone
    if J.IsGoingOnSomeone(bot) then
        if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 900)
        and J.CanBeAttacked(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze') then
            return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
        end
    end

    -- Push/Defend
    if J.IsPushing(bot) or J.IsDefending(bot) then
        if nEnemyLaneCreeps and #nEnemyLaneCreeps >= 4
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        and #nAllyHeroes <= 3 then  -- don't waste treants when grouped
            return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
        end
    end

    -- Farming
    if J.IsFarming(bot) and J.GetManaAfter(NaturesCall:GetManaCost()) > 0.35 and bAttacking then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
        if nNeutralCreeps and J.IsValid(nNeutralCreeps[1])
        and (#nNeutralCreeps >= 3 or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep())) then
            return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
        end
        if nEnemyLaneCreeps and #nEnemyLaneCreeps >= 3 and J.CanBeAttacked(nEnemyLaneCreeps[1]) then
            return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
        end
    end

    -- Laning
    if J.IsLaning(bot) and J.GetManaAfter(NaturesCall:GetManaCost()) > 0.3 and bAttacking then
        if nEnemyLaneCreeps and #nEnemyLaneCreeps >= 2 and J.CanBeAttacked(nEnemyLaneCreeps[1]) then
            return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
        end
    end

    -- Roshan/Tormentor
    if J.IsDoingRoshan(bot) and J.IsRoshan(botTarget)
    and not botTarget:IsAttackImmune() and J.IsInRange(bot, botTarget, bot:GetAttackRange()) and bAttacking then
        return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
    end

    if J.IsDoingTormentor(bot) and J.IsTormentor(botTarget)
    and J.IsInRange(bot, botTarget, bot:GetAttackRange()) and bAttacking then
        return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderWrathOfNature()
    if not J.CanCastAbility(WrathOfNature) then return BOT_ACTION_DESIRE_NONE, nil end

    local nDamage = WrathOfNature:GetSpecialValueInt('damage')

    -- Global kill-securing (FIXED: was UNIT_LIST_ALLIED_HEROES, now ENEMY)
    for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb') then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    -- Teamfight: lowest HP enemy
    if J.IsInTeamFight(bot, 1200) then
        local hTarget, hp = nil, 99999
        for _, enemyHero in pairs(nEnemyHeroes) do
            if J.IsValidTarget(enemyHero)
            and J.GetHP(enemyHero) < 0.5
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer') then
                if enemyHero:GetHealth() < hp then
                    hTarget = enemyHero
                    hp = enemyHero:GetHealth()
                end
            end
        end
        if hTarget then return BOT_ACTION_DESIRE_HIGH, hTarget end
    end

    -- Going on someone: cast when attacking or have scepter (treants on hit)
    if J.IsGoingOnSomeone(bot) and (bAttacking or bot:HasScepter()) then
        if J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer') then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderCurseOfTheOldGrowth()
    if not J.CanCastAbility(CurseOfTheOldGrowth) then return BOT_ACTION_DESIRE_NONE end

    local nRadius = CurseOfTheOldGrowth:GetSpecialValueInt('range')
    local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

    -- Teamfight or going on someone with 2+ enemies
    if (J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot))
    and #nInRangeEnemy >= 2 then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

-- Sprout + Nature's Call combo: create trees then convert to treants
function X.CanDoSproutCall()
    return J.CanCastAbility(Sprout) and J.CanCastAbility(NaturesCall)
        and J.GetMP(bot) > 0.5
end

function X.ConsiderSproutCall()
    if not X.CanDoSproutCall() then return BOT_ACTION_DESIRE_NONE, nil, 0 end

    local nCastRange = J.GetProperCastRange(false, bot, Sprout:GetCastRange())
    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

    -- Push/Defend: 4+ creeps
    if (J.IsPushing(bot) or J.IsDefending(bot))
    and nEnemyLaneCreeps and #nEnemyLaneCreeps >= 4
    and J.CanBeAttacked(nEnemyLaneCreeps[1]) then
        local loc = J.GetCenterOfUnits(nEnemyLaneCreeps)
        return BOT_ACTION_DESIRE_HIGH, bot, loc
    end

    -- Farming: 3+ creeps or ancients
    if J.IsFarming(bot) and bAttacking then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
        if nNeutralCreeps and J.IsValid(nNeutralCreeps[1])
        and (#nNeutralCreeps >= 3 or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep())) then
            return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
        end
        if nEnemyLaneCreeps and #nEnemyLaneCreeps >= 3 and J.CanBeAttacked(nEnemyLaneCreeps[1]) then
            local loc = J.GetCenterOfUnits(nEnemyLaneCreeps)
            return BOT_ACTION_DESIRE_HIGH, bot, loc
        end
    end

    -- Laning: 2+ creeps
    if J.IsLaning(bot) and bAttacking then
        if nEnemyLaneCreeps and #nEnemyLaneCreeps >= 2 and J.CanBeAttacked(nEnemyLaneCreeps[1]) then
            return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
        end
    end

    -- Roshan/Tormentor
    if J.IsDoingRoshan(bot) and J.IsRoshan(botTarget) and bAttacking then
        return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
    end
    if J.IsDoingTormentor(bot) and J.IsTormentor(botTarget) and bAttacking then
        return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
    end

    return BOT_ACTION_DESIRE_NONE, nil, 0
end

return X
