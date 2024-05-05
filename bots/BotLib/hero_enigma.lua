local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos3
                        ['t25'] = {10, 0},
                        ['t20'] = {10, 0},
                        ['t15'] = {0, 10},
                        ['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,1,2,1,2,6,2,1,1,3,6,3,3,3,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sUtility = {"item_pipe", "item_lotus_orb"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

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

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_circlet",
    "item_magic_wand",
    "item_vladmir",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
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

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end
    
    -- if near by enemy hero is pulled by black hole, don't do anything
    local nEnemyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
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

        if  CanBKB()
        and not bot:IsMagicImmune()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
            bot:ActionQueue_Delay(0.1)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkPulseHoleLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbilityOnLocation(MidnightPulse, BlinkPulseHoleLocation)
        bot:ActionQueue_UseAbilityOnLocation(BlackHole, BlinkPulseHoleLocation)
        return
    end

    BlinkHoleDesire, BlinkHoleLocation = X.ConsiderBlinkHole()
    if BlinkHoleDesire > 0
    then
        bot:Action_ClearActions(false)

        if  CanBKB()
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
        if  CanBKB()
        and not bot:IsMagicImmune()
        then
            bot:Action_ClearActions(false)
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

	local nCastRange = Malefice:GetCastRange()
    local nStunInstances = Malefice:GetSpecialValueInt('value')
    if MaleficeAdditionalInstanceTalent:IsTrained()
    then
        nStunInstances = nStunInstances + Malefice:GetSpecialValueInt('value')
    end

	local nDamage = Malefice:GetSpecialValueInt('damage') * nStunInstances
    local botTarget = J.GetProperTarget(bot)

	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 250, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.75 and bot:WasRecentlyDamagedByAnyHero(2.5)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
		end
	end

	if J.IsDoingRoshan(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and nInRangeAlly ~= nil and #nInRangeAlly >= 1
        then
            return BOT_ACTION_DESIRE_MODERATE, botTarget
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDemonicSummoning()
    if not DemonicSummoning:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = DemonicSummoning:GetCastRange()
    local nCastPoint = DemonicSummoning:GetCastPoint()
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    if  J.IsGoingOnSomeone(bot)
    and J.GetHP(bot) > 0.5
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
		end
	end

	if J.IsDefending(bot) or J.IsPushing(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]:GetLocation()
        end
	end

    if  J.IsFarming(bot)
    and J.GetHP(bot) > 0.5
    and nMana > 0.35
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)

        if nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end
    end

    if  J.IsLaning(bot)
    and J.GetHP(bot) > 0.75
    and nMana > 0.6
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end
    end

    if  J.IsDoingRoshan(bot)
    and J.GetHP(bot) > 0.65
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and nInRangeAlly ~= nil and #nInRangeAlly >= 1
        then
            return BOT_ACTION_DESIRE_MODERATE, bot:GetLocation()
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderMidnightPulse()
    if not MidnightPulse:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = MidnightPulse:GetCastRange()
    local nCastPoint = MidnightPulse:GetCastPoint()
    local nRadius = MidnightPulse:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)

    if MidnightPulseRadiusTalent:IsTrained()
    then
        nRadius = nRadius + MidnightPulse:GetSpecialValueInt('value')
    end

	if  J.IsInTeamFight(bot, 1200)
    and not (CanDoBlinkHole() or CanDoBlinkPulseHole())
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius / 2, 0, 0)

		if nLocationAoE.count >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 250, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
		end
	end

    if J.IsDoingRoshan(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and nInRangeAlly ~= nil and #nInRangeAlly >= 1
        then
            return BOT_ACTION_DESIRE_MODERATE, botTarget:GetLocation()
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderBlackHole()
    if not BlackHole:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = BlackHole:GetCastRange()
    local nRadius = BlackHole:GetSpecialValueInt('radius')
    local nDamage = BlackHole:GetSpecialValueInt('value')
    local nDuration = BlackHole:GetSpecialValueInt('duration')
    local botTarget = J.GetProperTarget(bot)

	if  J.IsInTeamFight(bot, 1200)
    and not (CanDoBlinkHole() or CanDoBlinkPulseHole())
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )

		if nLocationAoE.count >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly <= 1 and #nInRangeEnemy <= 1
		then
            if J.CanKillTarget(botTarget, nDamage * nDuration, DAMAGE_TYPE_PURE)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

------------------------------
function X.ConsiderBlinkHole()
    if CanDoBlinkHole()
    then
        local nRadius = BlackHole:GetSpecialValueInt('radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1199, nRadius, 0, 0)

            if  nLocationAoE.count >= 2
            then
                local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

                if realEnemyCount ~= nil and realEnemyCount >= 2
                then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkHole()
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
    if CanDoBlinkPulseHole()
    then
        local nRadius = BlackHole:GetSpecialValueInt('radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1199, nRadius, 0, 0)

            if  nLocationAoE.count >= 2
            then
                local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

                if realEnemyCount ~= nil and realEnemyCount >= 2
                then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkPulseHole()
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

function HasBlink()
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

function CanBKB()
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
    and bot:GetMana() >= 75
	then
        BlackKingBar = bkb
        return true
	end

    return false
end

return X