local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
                        {--pos3
                            ['t25'] = {10, 0},
                            ['t20'] = {10, 0},
                            ['t15'] = {0, 10},
                            ['t10'] = {0, 10},
                        },
                        {--pos4,5
                            ['t25'] = {10, 0},
                            ['t20'] = {10, 0},
                            ['t15'] = {0, 10},
                            ['t10'] = {0, 10},
                        }
}

local tAllAbilityBuildList = {
						{2,1,2,1,2,6,2,1,1,3,6,3,3,3,6},--pos3
                        {2,1,2,1,2,6,2,1,1,3,6,3,3,3,6},--pos4,5
}

local nAbilityBuildList = tAllAbilityBuildList[1]
if sRole == 'pos_3' then nAbilityBuildList = tAllAbilityBuildList[1] end
if sRole == 'pos_4' then nAbilityBuildList = tAllAbilityBuildList[2] end
if sRole == 'pos_5' then nAbilityBuildList = tAllAbilityBuildList[2] end

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList[1])
if sRole == 'pos_3' then nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList[1]) end
if sRole == 'pos_4' then nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList[2]) end
if sRole == 'pos_5' then nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList[2]) end

local sUtility = {"item_pipe", "item_lotus_orb"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_double_circlet",

    "item_magic_wand",
    "item_vladmir",
    "item_boots",
    "item_blink",
    "item_black_king_bar",--
    "item_aghanims_shard",
    "item_octarine_core",--
    nUtility,--
    "item_refresher",--
    "item_travel_boots",
    "item_arcane_blink",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_4'] = {
    "item_enchanted_mango",
    "item_double_tango",
    "item_circlet",
    "item_double_branches",
    "item_blood_grenade",

    "item_magic_wand",
    "item_boots",
    "item_vladmir",--
    "item_arcane_boots",
    "item_blink",
    "item_guardian_greaves",--
    "item_black_king_bar",--
    "item_pipe",--
    "item_refresher",--
    "item_arcane_blink",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_enchanted_mango",
    "item_double_tango",
    "item_circlet",
    "item_double_branches",
    "item_blood_grenade",

    "item_magic_wand",
    "item_boots",
    "item_vladmir",--
    "item_tranquil_boots",
    "item_blink",
    "item_boots_of_bearing",--
    "item_black_king_bar",--
    "item_pipe",--
    "item_refresher",--
    "item_arcane_blink",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]


X['sSellList'] = {

	"item_ultimate_scepter",
	"item_magic_wand",

	"item_cyclone",
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

local Malefice          = bot:GetAbilityByName('enigma_malefice')
local DemonicSummoning  = bot:GetAbilityByName('enigma_demonic_conversion')
local MidnightPulse     = bot:GetAbilityByName('enigma_midnight_pulse')
local BlackHole         = bot:GetAbilityByName('enigma_black_hole')

local MaleficeAdditionalInstanceTalent = bot:GetAbilityByName('special_bonus_unique_enigma_2')
local MidnightPulseRadiusTalent = bot:GetAbilityByName('special_bonus_unique_enigma_6')

local MaleficeDesire, MaleficeTarget
local DemonicSummoningDesire, DemonicSummoningLocation
local MidnightPulseDesire, MidnightPulseLocation
local BlackHoleDesire, BlackHoleLocation

local BlinkHoleDesire, BlinkHoleLocation
local BlinkPulseHoleDesire, BlinkPulseHoleLocation

local Blink
local BlackKingBar

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    -- if near by enemy hero is pulled by black hole, don't do anything
    local nEnemyHeroes = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and (enemyHero:HasModifier('modifier_enigma_black_hole_pull')
        or enemyHero:HasModifier('modifier_enigma_black_hole_pull_scepter'))
        then
            return
        end
    end
    
    BlinkPulseHoleDesire, BlinkPulseHoleLocation = X.ConsiderBlinkPulseHole()
    if BlinkPulseHoleDesire > 0
    then
        bot:Action_ClearActions(false)

        if  X.CanBKB()
        and not bot:IsMagicImmune()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
            bot:ActionQueue_Delay(0.1)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkPulseHoleLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbilityOnLocation(MidnightPulse, BlinkPulseHoleLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbilityOnLocation(BlackHole, BlinkPulseHoleLocation)
        return
    end

    BlinkHoleDesire, BlinkHoleLocation = X.ConsiderBlinkHole()
    if BlinkHoleDesire > 0
    then
        bot:Action_ClearActions(false)

        if  X.CanBKB()
        and not bot:IsMagicImmune()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
            bot:ActionQueue_Delay(0.1)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkHoleLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbilityOnLocation(BlackHole, BlinkHoleLocation)
        return
    end

    MidnightPulseDesire, MidnightPulseLocation = X.ConsiderMidnightPulse()
    if MidnightPulseDesire > 0
    then
        bot:Action_UseAbilityOnLocation(MidnightPulse, MidnightPulseLocation)
        return
    end

    BlackHoleDesire, BlackHoleLocation = X.ConsiderBlackHole()
    if BlackHoleDesire > 0
    then
        if  X.CanBKB()
        and not bot:IsMagicImmune()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
            bot:ActionQueue_Delay(0.1)
            bot:ActionQueue_UseAbilityOnLocation(BlackHole, BlackHoleLocation)
            return
        end

        bot:Action_UseAbilityOnLocation(BlackHole, BlackHoleLocation)
        return
    end

    MaleficeDesire, MaleficeTarget = X.ConsiderMalefice()
    if MaleficeDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Malefice, MaleficeTarget)
        return
    end

    DemonicSummoningDesire, DemonicSummoningLocation = X.ConsiderDemonicSummoning()
    if DemonicSummoningDesire > 0
    then
        bot:Action_UseAbilityOnLocation(DemonicSummoning, DemonicSummoningLocation)
        return
    end
end

function X.ConsiderMalefice()
    if not Malefice:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, Malefice:GetCastRange())
    local nStunInstances = Malefice:GetSpecialValueInt('value')

    if MaleficeAdditionalInstanceTalent:IsTrained()
    then
        nStunInstances = nStunInstances + Malefice:GetSpecialValueInt('value')
    end

	local nDamage = Malefice:GetSpecialValueInt('damage') * nStunInstances

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + 150)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1400, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1400, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

        if  J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.CanCastOnTargetAdvanced(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsRealInvisible(bot)
		then
            local nInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and (#nTargetInRangeAlly > #nInRangeAlly
                or bot:WasRecentlyDamagedByAnyHero(2))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
		end
	end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1600, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and (not J.IsCore(bot) or J.IsCore(bot) and J.GetManaAfter(Malefice:GetManaCost()) > 0.66)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

	if J.IsDoingRoshan(bot)
	then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_roshan_spell_block')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

    if J.IsDoingTormentor(bot)
	then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDemonicSummoning()
    if not DemonicSummoning:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, DemonicSummoning:GetCastRange())
    local nHPCost = 75 + (25 * (DemonicSummoning:GetLevel() - 1))

    if  J.IsGoingOnSomeone(bot)
    and J.GetHP(bot) > 0.5
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1400, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1400, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if DotaTime() < 10 * 60
                then
                    local nEnemyTowers = botTarget:GetNearbyTowers(800, false)
                    if nEnemyTowers ~= nil
                    then
                        if J.IsChasingTarget(bot, botTarget)
                        then
                            if  J.IsInRange(bot, botTarget, nCastRange)
                            and #nEnemyTowers == 0
                            then
                                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                            else
                                if #nEnemyTowers == 0
                                then
                                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
                                end
                            end
                        else
                            if J.IsInRange(bot, botTarget, nCastRange)
                            then
                                return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + botTarget:GetLocation()) / 2
                            end
                        end
                    end
                else
                    if J.IsChasingTarget(bot, botTarget)
                    then
                        if J.IsInRange(bot, botTarget, nCastRange)
                        then
                            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                        else
                            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
                        end
                    else
                        if J.IsInRange(bot, botTarget, bot:GetAttackRange())
                        then
                            return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + botTarget:GetLocation()) / 2
                        end
                    end
                end
            end
		end
	end

	if J.IsDefending(bot) or J.IsPushing(bot)
	then
        if J.IsAttacking(bot)
        then
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
            end

            local nEnemyTowers = bot:GetNearbyTowers(800, true)
            local nEnemyBarracks = bot:GetNearbyBarracks(800,true)
            local nEnemyFillers = bot:GetNearbyFillers(800, true)

            if  J.IsValidBuilding(bot:GetAttackTarget())
            and (nEnemyTowers ~= nil and #nEnemyTowers >= 1
                or nEnemyBarracks ~= nil and #nEnemyBarracks >= 1
                or nEnemyFillers ~= nil and #nEnemyFillers >= 1)
            then
                return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
            end
        end
	end

    if  J.IsFarming(bot)
    and J.GetHealthAfter(nHPCost) > 0.5
    and J.GetManaAfter(DemonicSummoning:GetManaCost()) > 0.33
    and J.IsAttacking(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end

        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
        if nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end
    end

    if  J.IsLaning(bot)
    and J.GetHealthAfter(nHPCost) > 0.61
    and J.GetManaAfter(DemonicSummoning:GetManaCost()) > 0.5
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(800, true)
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end
    end

    if  J.IsDoingRoshan(bot)
    and J.GetHealthAfter(nHPCost) > 0.5
	then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end
	end

    if  J.IsDoingTormentor(bot)
    and J.GetHealthAfter(nHPCost) > 0.63
	then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderMidnightPulse()
    if not MidnightPulse:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, MidnightPulse:GetCastRange())
    local nRadius = MidnightPulse:GetSpecialValueInt('radius')

    if MidnightPulseRadiusTalent:IsTrained()
    then
        nRadius = nRadius + MidnightPulse:GetSpecialValueInt('value')
    end

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius / 2, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius * 0.8)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1400, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1400, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius * 0.66)
                if J.IsInRange(bot, botTarget, nCastRange)
                then
                    if not J.IsChasingTarget(bot, botTarget)
                    then
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
                            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                        end
                    else
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(1)
                    end
                else
                    if  J.IsInRange(bot, botTarget, nCastRange + nRadius)
                    and not J.IsInRange(bot, botTarget, nCastRange)
                    and not J.IsChasingTarget(bot, botTarget)
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
                    end
                end
            end
		end
	end

    if J.IsDoingRoshan(bot)
	then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
	end

    if J.IsDoingTormentor(bot)
	then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderBlackHole()
    if not BlackHole:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, BlackHole:GetCastRange())
    local nRadius = BlackHole:GetSpecialValueInt('radius')
    local nDamage = BlackHole:GetSpecialValueInt('value')
    local nDuration = BlackHole:GetSpecialValueInt('duration')

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius * 0.8, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 800)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not botTarget:HasModifier('modifier_item_aeon_disk_buff')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            then
                if  #nInRangeEnemy >= #nInRangeAlly
                and #nInRangeEnemy <= 1
                then
                    if  J.CanKillTarget(botTarget, nDamage * nDuration, DAMAGE_TYPE_PURE)
                    -- and J.IsCore(botTarget)
                    and botTarget:GetHealth() > 200
                    then
                        nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
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

                if  #nInRangeAlly >= #nInRangeEnemy
                -- and J.IsCore(botTarget)
                then
                    if  #nInRangeAlly <= 1
                    and J.CanKillTarget(botTarget, nDamage * 1.1 * nDuration, DAMAGE_TYPE_PURE)
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                    else
                        nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
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
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

------------------------------
function X.ConsiderBlinkHole()
    if X.CanDoBlinkHole()
    then
        local nRadius = BlackHole:GetSpecialValueInt('radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1199, nRadius, 0, 0)
            local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.CanDoBlinkHole()
    if  BlackHole:IsFullyCastable()
    and Blink ~= nil and Blink:IsFullyCastable()
    then
        local nManaCost = BlackHole:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end
------------------------------
function X.ConsiderBlinkPulseHole()
    if X.CanDoBlinkPulseHole()
    then
        local nRadius = BlackHole:GetSpecialValueInt('radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1199, nRadius, 0, 0)
            local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.CanDoBlinkPulseHole()
    if  BlackHole:IsFullyCastable()
    and MidnightPulse:IsFullyCastable()
    and Blink ~= nil and Blink:IsFullyCastable()
    then
        local nManaCost = BlackHole:GetManaCost() + MidnightPulse:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end
------------------------------

function X.HasBlink()
    local blink = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if  item ~= nil
        and (item:GetName() == "item_blink" or item:GetName() == "item_overwhelming_blink" or item:GetName() == "item_arcane_blink" or item:GetName() == "item_swift_blink")
        then
			blink = item
			break
		end
	end

    if  blink ~= nil
    and blink:IsFullyCastable()
	then
        Blink = blink
        return true
	end

    return false
end

function X.CanBKB()
    local bkb = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if  item ~= nil
        and item:GetName() == "item_black_king_bar"
        then
			bkb = item
			break
		end
	end

    if  bkb ~= nil
    and bkb:IsFullyCastable()
	then
        BlackKingBar = bkb
        return true
	end

    return false
end

return X