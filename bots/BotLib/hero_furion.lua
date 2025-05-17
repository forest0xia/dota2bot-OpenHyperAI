local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						{--pos1
                            ['t25'] = {10, 0},
                            ['t20'] = {0, 10},
                            ['t15'] = {0, 10},
                            ['t10'] = {0, 10},
                        },
                        {--pos3
                            ['t25'] = {10, 0},
                            ['t20'] = {0, 10},
                            ['t15'] = {0, 10},
                            ['t10'] = {0, 10},
                        }
}

local tAllAbilityBuildList = {
    {3,1,3,2,3,6,3,2,2,2,6,1,1,1,6},--pos1
    {3,1,3,2,3,6,3,2,2,2,6,1,1,1,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_1"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
else
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sUtility = {"item_pipe", "item_heavens_halberd", "item_crimson_guard"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
    "item_blight_stone",
    "item_tango",
    "item_faerie_fire",
    "item_double_branches",
    "item_magic_wand",

    "item_power_treads",
    "item_mjollnir",--
    "item_black_king_bar",--
    "item_aghanims_shard",
    "item_orchid",
    "item_satanic",--
    "item_assault",--
    "item_bloodthorn",--
    "item_monkey_king_bar",--
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
    "item_mjollnir",--
    "item_black_king_bar",--
    "item_aghanims_shard",
    nUtility,--
    "item_assault",--
    "item_satanic",--
    "item_sheepstick",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_double_circlet",

    "item_bottle",
    "item_magic_wand",
    "item_power_treads",
    "item_maelstrom",
    "item_orchid",
    "item_black_king_bar",--
    "item_mjollnir",--
    "item_aghanims_shard",
    "item_assault",--
    "item_satanic",--
    "item_bloodthorn",--
    "item_sheepstick",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_4'] = {
    "item_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_double_circlet",

    "item_boots",
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
    "item_monkey_king_bar",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_double_circlet",

    "item_boots",
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
    "item_monkey_king_bar",--
    "item_moon_shard",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

	"item_ultimate_scepter",
	"item_magic_wand",

	"item_cyclone",
	"item_magic_wand",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Sprout                = bot:GetAbilityByName('furion_sprout')
local Teleportation         = bot:GetAbilityByName('furion_teleportation')
local NaturesCall           = bot:GetAbilityByName('furion_force_of_nature')
local CurseOfTheOldGrowth   = bot:GetAbilityByName('furion_curse_of_the_forest')
local WrathOfNature         = bot:GetAbilityByName('furion_wrath_of_nature')

local SproutDesire, SproutTarget
local TeleportationDesire, TeleportationLocation
local NaturesCallDesire, NaturesCallLocation
local CurseOfTheOldGrowthDesire
local WrathOfNatureDesire, WrathOfNatureTarget

local SproutCallDesire, SproutCallTarget, SproutCallLocation

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    if  bot.useProphetTP
    and bot.ProphetTPLocation ~= nil
    and J.CanCastAbility(Teleportation)
    then
        bot:Action_UseAbilityOnLocation(Teleportation, bot.ProphetTPLocation)
        bot.useProphetTP = false
        return
    end

    -- SproutCallDesire, SproutCallTarget, SproutCallLocation = X.ConsiderSproutCall()
    -- if SproutCallDesire > 0
    -- then
    --     J.SetQueuePtToINT(bot, false)
    --     bot:ActionQueue_UseAbilityOnEntity(Sprout, SproutCallTarget)
    --     bot:ActionQueue_Delay(0.35 + 0.44)
    --     bot:ActionQueue_UseAbilityOnLocation(NaturesCall, SproutCallLocation)
    --     return
    -- end

    TeleportationDesire, TeleportationLocation = X.ConsiderTeleportation()
    if TeleportationDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(Teleportation, TeleportationLocation)
        bot.useProphetTP = false
        return
    end

    SproutDesire, SproutTarget = X.ConsiderSprout()
    if SproutDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(Sprout, SproutTarget)
        return
    end

    NaturesCallDesire, NaturesCallLocation = X.ConsiderNaturesCall()
    if NaturesCallDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnTree(NaturesCall, NaturesCallLocation)
        return
    end

    CurseOfTheOldGrowthDesire = X.ConsiderCurseOfTheOldGrowth()
    if CurseOfTheOldGrowthDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbility(CurseOfTheOldGrowth)
        return
    end

    WrathOfNatureDesire, WrathOfNatureTarget = X.ConsiderWrathOfNature()
    if WrathOfNatureDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(WrathOfNature, WrathOfNatureTarget)
        return
    end
end

function X.ConsiderSprout()
    if not J.CanCastAbility(Sprout)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, Sprout:GetCastRange())
    local nDuration = Sprout:GetSpecialValueInt('duration')
    local botTarget = J.GetProperTarget(bot)

	if J.IsInTeamFight(bot, 1200)
	then
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

        if strongestTarget == nil
        then
            strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, true, nDuration)
        end

        if  J.IsValidTarget(strongestTarget)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.IsDisabled(strongestTarget)
        and not strongestTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not strongestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not strongestTarget:HasModifier('modifier_legion_commander_duel')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
			return BOT_ACTION_DESIRE_HIGH, strongestTarget
		end
	end

    if J.IsGoingOnSomeone(bot)
    then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:WasRecentlyDamagedByAnyHero(4)
    then
        if J.IsValidHero(nEnemyHeroes[1])
        and J.CanCastOnMagicImmune(nEnemyHeroes[1])
        and J.IsInRange(bot, nEnemyHeroes[1], nCastRange)
        and J.IsChasingTarget(nEnemyHeroes[1], bot)
        and not nEnemyHeroes[1]:HasModifier('modifier_enigma_black_hole_pull')
        and not nEnemyHeroes[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not nEnemyHeroes[1]:HasModifier('modifier_legion_commander_duel')
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
        end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

    for _, allyHero in pairs(nAllyHeroes)
    do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(5)
        and not allyHero:IsIllusion()
        and (not J.IsCore(bot) or (J.IsCore(bot) and J.GetMP(bot) > 0.5))
        then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

            if J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], nCastRange)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderTeleportation()
    if not J.CanCastAbility(Teleportation)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nChannelTime = Teleportation:GetCastPoint()

	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain()
	end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    and (not J.IsCore(bot) or (J.IsCore(bot) and (not J.IsInLaningPhase() or bot:GetNetWorth() > 3500)))
    then
        if GetUnitToLocationDistance(bot, nTeamFightLocation) > 1600
        then
            local nAllyHeroes = J.GetAlliesNearLoc(nTeamFightLocation, 1200)

            if nAllyHeroes ~= nil and #nAllyHeroes >= 1
            and J.IsValidHero(nAllyHeroes[#nAllyHeroes])
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(nAllyHeroes[#nAllyHeroes], nChannelTime)
            end
        end
    end

    for i = 1, #GetTeamPlayers( GetTeam() )
    do
        local allyHero = GetTeamMember(i)

        if  J.IsValidHero(allyHero)
        and J.IsGoingOnSomeone(allyHero)
        and GetUnitToUnitDistance(bot, allyHero) > 2000
        and (not J.IsCore(bot) or (J.IsCore(bot) and (not J.IsInLaningPhase() or bot:GetNetWorth() > 3500)))
        and not allyHero:IsIllusion()
        then
            local allyTarget = allyHero:GetAttackTarget()
            local nAllyInRangeAlly = allyHero:GetNearbyHeroes(800, false, BOT_MODE_NONE)

            if  J.IsValidTarget(allyTarget)
            and not allyTarget:IsAttackImmune()
            and J.IsInRange(allyHero, allyTarget, 800)
            and J.GetHP(allyHero) > 0.25
            and not J.IsSuspiciousIllusion(allyTarget)
            and not allyTarget:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nTargetInRangeAlly = allyTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE)

                if  nAllyInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nAllyInRangeAlly + 1 >= #nTargetInRangeAlly
                and #nTargetInRangeAlly >= 2
                and not J.IsLocationInChrono(J.GetCorrectLoc(allyHero, nChannelTime))
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(allyHero, nChannelTime)
                end
            end
        end
    end

	if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:WasRecentlyDamagedByAnyHero(4)
    and bot:GetActiveModeDesire() > 0.75
    and bot:GetLevel() >= 6
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

        if J.IsValidHero(nInRangeEnemy[1])
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and (not J.IsInRange(bot, nInRangeEnemy[1], 600) or bot:IsMagicImmune() or not J.CanBeAttacked(bot))
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain()
        end
	end

    if J.IsDoingRoshan(bot)
    then
        local roshan_loc = J.GetCurrentRoshanLocation()
        local nAllyHeroes = J.GetAlliesNearLoc(roshan_loc, 700)

        if nAllyHeroes ~= nil and #nAllyHeroes >= 2
        and GetUnitToLocationDistance(bot, roshan_loc) > 1600
        then
            return BOT_ACTION_DESIRE_HIGH, roshan_loc
        end
    end

    if J.IsDoingTormentor(bot)
    then
        local tormentor_loc = J.GetTormentorLocation(GetTeam())
        local nAllyHeroes = J.GetAlliesNearLoc(tormentor_loc, 700)

        if nAllyHeroes ~= nil and #nAllyHeroes >= 2
        and GetUnitToLocationDistance(bot, tormentor_loc) > 1600
        then
            return BOT_ACTION_DESIRE_HIGH, tormentor_loc
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderNaturesCall()
    if not J.CanCastAbility(NaturesCall)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, NaturesCall:GetCastRange())
    local botTarget = J.GetProperTarget(bot)

    local nInRangeTrees = bot:GetNearbyTrees(nCastRange)

    if nInRangeTrees ~= nil and #nInRangeTrees >= 1
    then
        if J.IsGoingOnSomeone(bot)
        then
            if J.IsValidTarget(botTarget)
            and J.IsInRange(bot, botTarget, 900)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
            and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
            end
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if J.IsPushing(bot) or J.IsDefending(bot)
        then
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
            and J.CanBeAttacked(nEnemyLaneCreeps[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
            end
        end

        if  J.IsFarming(bot)
        and J.GetManaAfter(NaturesCall:GetManaCost()) > 0.35
        then
            if J.IsAttacking(bot)
            then
                local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
                if  nNeutralCreeps ~= nil
                and J.IsValid(nNeutralCreeps[1])
                and ((#nNeutralCreeps >= 3)
                    or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
                then
                    return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
                end

                if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
                and J.CanBeAttacked(nEnemyLaneCreeps[1])
                then
                    return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
                end
            end
        end

        if J.IsLaning(bot)
        and J.GetManaAfter(NaturesCall:GetManaCost()) > 0.3
        then
            if J.IsAttacking(bot)
            then
                if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
                and J.CanBeAttacked(nEnemyLaneCreeps[1])
                then
                    return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
                end
            end
        end

        if J.IsDoingRoshan(bot)
        then
            if  J.IsRoshan(botTarget)
            and not botTarget:IsAttackImmune()
            and J.IsInRange(bot, botTarget, bot:GetAttackRange())
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
            end
        end

        if J.IsDoingTormentor(bot)
        then
            if  J.IsTormentor(botTarget)
            and J.IsInRange(bot, botTarget, bot:GetAttackRange())
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeTrees[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderWrathOfNature()
    if not J.CanCastAbility(WrathOfNature)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nDamage = WrathOfNature:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

	if J.IsInTeamFight(bot, 1200)
	then
        local hTarget = nil
        local hp = 99999

        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if J.IsValidTarget(enemyHero)
            and J.GetHP(enemyHero) < 0.5
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            then
                local currHP = enemyHero:GetHealth()
                if currHP < hp
                then
                    hTarget = enemyHero
                    hp = currHP
                end
            end
        end

        if hTarget ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, hTarget
        end
	end

	if J.IsGoingOnSomeone(bot)
	then
        if  J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderCurseOfTheOldGrowth()
    if not J.CanCastAbility(CurseOfTheOldGrowth)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = CurseOfTheOldGrowth:GetSpecialValueInt('range')

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

        if #nInRangeEnemy >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSproutCall()
    if X.CanDoSproutCall()
    then
        local nCastRange = J.GetProperCastRange(false, bot, Sprout:GetCastRange())
        local botTarget = J.GetProperTarget(bot)

        local nInRangeTrees = bot:GetNearbyTrees(nCastRange)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if nInRangeTrees ~= nil and #nInRangeTrees >= 1
        then
            if J.IsPushing(bot) or J.IsDefending(bot)
            then
                if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
                and J.CanBeAttacked(nEnemyLaneCreeps[1])
                then
                    return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                end
            end

            if  J.IsFarming(bot)
            and J.GetMP(bot) > 0.5
            then
                if J.IsAttacking(bot)
                then
                    local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
                    if  nNeutralCreeps ~= nil
                    and J.IsValid(nNeutralCreeps[1])
                    and ((#nNeutralCreeps >= 3)
                        or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
                    then
                        return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                    end

                    if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
                    and J.CanBeAttacked(nEnemyLaneCreeps[1])
                    then
                        return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                    end
                end
            end

            if J.IsLaning(bot)
            and J.GetMP(bot) > 0.5
            then
                if J.IsAttacking(bot)
                then
                    if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
                    and J.CanBeAttacked(nEnemyLaneCreeps[1])
                    then
                        return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                    end
                end
            end

            if J.IsDoingRoshan(bot)
            then
                if  J.IsRoshan(botTarget)
                and not botTarget:IsAttackImmune()
                and J.IsInRange(bot, botTarget, bot:GetAttackRange())
                and J.IsAttacking(bot)
                then
                    return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                end
            end

            if J.IsDoingTormentor(bot)
            then
                if  J.IsTormentor(botTarget)
                and J.IsInRange(bot, botTarget, bot:GetAttackRange())
                and J.IsAttacking(bot)
                then
                    return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, 0
end

function X.CanDoSproutCall()
    if  J.CanCastAbility(Sprout)
    and J.CanCastAbility(NaturesCall)
    then
        local nManaCost = Sprout:GetManaCost() + NaturesCall:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end

return X