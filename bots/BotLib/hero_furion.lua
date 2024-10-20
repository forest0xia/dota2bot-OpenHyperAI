local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						{--pos1
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {10, 0},
                            ['t10'] = {10, 0},
                        },
                        {--pos3
                            ['t25'] = {0, 10},
                            ['t20'] = {10, 0},
                            ['t15'] = {10, 0},
                            ['t10'] = {10, 0},
                        }
}

local tAllAbilityBuildList = {
						{2,1,1,2,1,6,1,2,2,3,6,3,3,3,6},--pos1
                        {3,2,3,1,3,6,3,2,2,2,6,1,1,1,6},--pos3
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
    "item_gungir",--
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
    "item_gungir",--
    "item_black_king_bar",--
    "item_aghanims_shard",
    nUtility,--
    "item_assault",--
    "item_satanic",--
    "item_sheepstick",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

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

local RadiantTormentorLoc = Vector(-8075, -1148, 1000)
local DireTormentorLoc = Vector(8132, 1102, 1000)

local loc
if GetTeam() == TEAM_RADIANT
then
	loc = RadiantTormentorLoc
else
	loc = DireTormentorLoc
end

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    if bot.useProphetTP
    and bot.ProphetTPLocation ~= nil
    then
        bot:Action_UseAbilityOnLocation(Teleportation, bot.ProphetTPLocation)
        bot.useProphetTP = false
        return
    end

    SproutCallDesire, SproutCallTarget, SproutCallLocation = X.ConsiderSproutCall()
    if SproutCallDesire > 0
    then
        bot:Action_ClearActions(false)
        bot:ActionQueue_UseAbilityOnEntity(Sprout, SproutCallTarget)
        bot:ActionQueue_Delay(0.35)
        bot:ActionQueue_UseAbilityOnLocation(NaturesCall, SproutCallLocation)
        return
    end

    TeleportationDesire, TeleportationLocation = X.ConsiderTeleportation()
    if TeleportationDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Teleportation, TeleportationLocation)
        bot.useProphetTP = false
        return
    end

    SproutDesire, SproutTarget = X.ConsiderSprout()
    if SproutDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Sprout, SproutTarget)
        return
    end

    NaturesCallDesire, NaturesCallLocation = X.ConsiderNaturesCall()
    if NaturesCallDesire > 0
    then
        bot:Action_UseAbilityOnLocation(NaturesCall, NaturesCallLocation)
        return
    end

    CurseOfTheOldGrowthDesire = X.ConsiderCurseOfTheOldGrowth()
    if CurseOfTheOldGrowthDesire > 0
    then
        bot:Action_UseAbility(CurseOfTheOldGrowth)
        return
    end

    WrathOfNatureDesire, WrathOfNatureTarget = X.ConsiderWrathOfNature()
    if WrathOfNatureDesire > 0
    then
        bot:Action_UseAbilityOnEntity(WrathOfNature, WrathOfNatureTarget)
        return
    end
end

function X.ConsiderSprout()
    if not Sprout:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = Sprout:GetCastRange()
    local nDuration = Sprout:GetSpecialValueInt('duration')
    local botTarget = J.GetProperTarget(bot)

	if J.IsInTeamFight(bot, 1200)
	then
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

        if strongestTarget == nil
        then
            strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, true, nDuration)
        end

        if J.IsValidTarget(strongestTarget)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.IsDisabled(strongestTarget)
        and not J.IsTaunted(strongestTarget)
        and not strongestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not strongestTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not strongestTarget:HasModifier('modifier_legion_commander_duel')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
			return BOT_ACTION_DESIRE_HIGH, strongestTarget
		end
	end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

        if J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,900, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
        and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not nInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 900, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.72 and bot:WasRecentlyDamagedByAnyHero(2.4)))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, nCastRange, true, BOT_MODE_NONE)

        if J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2.3)
        and not allyHero:IsIllusion()
        and J.GetMP(bot) > 0.41
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], nCastRange)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsRunning(allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderTeleportation()
    if not Teleportation:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nChannelTime = Teleportation:GetCastPoint()

	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, GetAncient(GetTeam()):GetLocation()
	end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    then
        if GetUnitToLocationDistance(bot, nTeamFightLocation) > 1600
        then
            local nAllyHeroes = J.GetAlliesNearLoc(nTeamFightLocation, 1200)

            if nAllyHeroes ~= nil and #nAllyHeroes >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyHeroes[#nAllyHeroes]:GetExtrapolatedLocation(nChannelTime)
            end
        end
    end

    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if J.IsValidHero(allyHero)
        and J.IsGoingOnSomeone(allyHero)
        and GetUnitToUnitDistance(bot, allyHero) > 2000
        and not J.IsInLaningPhase()
        and not allyHero:IsIllusion()
        then
            local allyTarget = allyHero:GetAttackTarget()
            local nAllyInRangeAlly = J.GetNearbyHeroes(allyHero, 800, false, BOT_MODE_NONE)

            if J.IsValidTarget(allyTarget)
            and J.IsInRange(allyHero, allyTarget, 800)
            and J.GetHP(allyHero) > 0.25
            and not J.IsSuspiciousIllusion(allyTarget)
            then
                local nTargetInRangeAlly = J.GetNearbyHeroes(allyTarget, 800, false, BOT_MODE_NONE)

                if nAllyInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nAllyInRangeAlly + 1 >= #nTargetInRangeAlly
                and #nTargetInRangeAlly >= 2
                and not J.IsLocationInChrono(allyHero:GetExtrapolatedLocation(nChannelTime))
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero:GetExtrapolatedLocation(nChannelTime)
                end
            end
        end
    end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and (not J.IsInRange(bot, nInRangeEnemy[1], 600) or bot:IsMagicImmune() or bot:IsInvulnerable())
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.8 and bot:WasRecentlyDamagedByAnyHero(2.9)))
            then
                return BOT_ACTION_DESIRE_HIGH, GetAncient(GetTeam()):GetLocation()
            end
        end
	end

    if J.IsDoingTormentor(bot)
    then
        local nAllyHeroes = J.GetAlliesNearLoc(loc, 600)

        if nAllyHeroes ~= nil and #nAllyHeroes >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, loc
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderNaturesCall()
    if not NaturesCall:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = NaturesCall:GetCastRange()
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

        if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 900)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)
            local nInRangeTrees = bot:GetNearbyTrees(nCastRange)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            and nInRangeTrees ~= nil and #nInRangeTrees >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(nInRangeTrees[1])
            end
        end
	end

    local nInRangeTrees = bot:GetNearbyTrees(nCastRange)

    if nInRangeTrees ~= nil and #nInRangeTrees >= 1
    then
        if J.IsPushing(bot) or J.IsDefending(bot)
        and not CanDoSproutCall()
        then
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
            then
                return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(nInRangeTrees[1])
            end
        end

        if J.IsFarming(bot)
        and J.GetMP(bot) > 0.3
        then
            if J.IsAttacking(bot)
            then
                local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
                if nNeutralCreeps ~= nil
                and ((#nNeutralCreeps >= 3)
                    or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
                then
                    return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(nInRangeTrees[1])
                end

                local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
                if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
                then
                    return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(nInRangeTrees[1])
                end
            end
        end

        if J.IsLaning(bot)
        and J.GetMP(bot) > 0.55
        then
            if J.IsAttacking(bot)
            then
                local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
                if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
                then
                    return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(nInRangeTrees[1])
                end
            end
        end

        if J.IsDoingRoshan(bot)
        and not CanDoSproutCall()
        then
            if J.IsRoshan(botTarget)
            and J.IsInRange(bot, botTarget, 1000)
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(nInRangeTrees[1])
            end
        end

        if J.IsDoingTormentor(bot)
        and not CanDoSproutCall()
        then
            if J.IsTormentor(botTarget)
            and J.IsInRange(bot, botTarget, 400)
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(nInRangeTrees[1])
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderWrathOfNature()
    if not WrathOfNature:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nDamage = WrathOfNature:GetSpecialValueInt('damage')

    for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
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
		local weakestTarget = J.GetVulnerableWeakestUnit(bot, true, true, 1600)

        if J.IsValidTarget(weakestTarget)
        and J.CanCastOnNonMagicImmune(weakestTarget)
        and not J.IsSuspiciousIllusion(weakestTarget)
        and not weakestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not weakestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not weakestTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, weakestTarget
        end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

        local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_legion_commander_duel')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1000, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderCurseOfTheOldGrowth()
    if not CurseOfTheOldGrowth:IsTrained()
    or not CurseOfTheOldGrowth:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = CurseOfTheOldGrowth:GetSpecialValueInt('range')

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSproutCall()
    if CanDoSproutCall()
    then
        local nCastRange = Sprout:GetCastRange()
        local botTarget = J.GetProperTarget(bot)

        if nCastRange > NaturesCall:GetCastRange()
        then
            nCastRange = NaturesCall:GetCastRange()
        end

        local nInRangeTrees = bot:GetNearbyTrees(nCastRange)

        if nInRangeTrees ~= nil and #nInRangeTrees >= 1
        then
            if J.IsPushing(bot) or J.IsDefending(bot)
            then
                local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
                if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
                then
                    return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                end
            end

            if J.IsFarming(bot)
            and J.GetMP(bot) > 0.33
            then
                if J.IsAttacking(bot)
                then
                    local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
                    if nNeutralCreeps ~= nil
                    and ((#nNeutralCreeps >= 3)
                        or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
                    then
                        return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                    end

                    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
                    if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
                    then
                        return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                    end
                end
            end

            if J.IsLaning(bot)
            and J.GetMP(bot) > 0.65
            then
                if J.IsAttacking(bot)
                then
                    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
                    if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
                    then
                        return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                    end
                end
            end

            if J.IsDoingRoshan(bot)
            then
                if J.IsRoshan(botTarget)
                and J.IsInRange(bot, botTarget, 1000)
                and J.IsAttacking(bot)
                then
                    return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                end
            end

            if J.IsDoingTormentor(bot)
            then
                if J.IsTormentor(botTarget)
                and J.IsInRange(bot, botTarget, 400)
                and J.IsAttacking(bot)
                then
                    return BOT_ACTION_DESIRE_HIGH, bot, bot:GetLocation()
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil, 0
end

function CanDoSproutCall()
    if Sprout:IsFullyCastable()
    and NaturesCall:IsFullyCastable()
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