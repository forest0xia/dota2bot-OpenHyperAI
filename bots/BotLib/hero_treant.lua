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
                        {2,1,2,1,2,6,2,1,1,3,6,3,3,3,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_tango",
    "item_double_branches",
    "item_enchanted_mango",
    "item_blood_grenade",
    "item_wind_lace",

    "item_boots",
    "item_magic_wand",
    "item_tranquil_boots",
    "item_aghanims_shard",
    "item_blink",
    "item_force_staff",--
    "item_boots_of_bearing",--
    "item_pipe",--
    "item_sheepstick",--
    "item_aeon_disk",--
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_tango",
    "item_double_branches",
    "item_enchanted_mango",
    "item_blood_grenade",
    "item_wind_lace",

    "item_boots",
    "item_ring_of_basilius",
    "item_magic_wand",
    "item_arcane_boots",
    "item_aghanims_shard",
    "item_blink",
    "item_glimmer_cape",--
    "item_guardian_greaves",--
    "item_pipe",--
    "item_sheepstick",--
    "item_aeon_disk",--
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_enchanted_mango",
    "item_wind_lace",

    "item_boots",
    "item_ring_of_basilius",
    "item_magic_wand",
    "item_arcane_boots",
    "item_aghanims_shard",
    "item_blink",
    "item_glimmer_cape",--
    "item_guardian_greaves",--
    "item_pipe",--
    "item_sheepstick",--
    "item_aeon_disk",--
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos4SellList = {
    "item_magic_wand",
}

Pos5SellList = {
    "item_magic_wand",
    "item_wind_lace",
}

X['sSellList'] = Pos4SellList

if sRole == "pos_4"
then
    X['sSellList'] = Pos4SellList
elseif sRole == "pos_5"
then
    X['sSellList'] = Pos5SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local NaturesGrasp      = bot:GetAbilityByName('treant_natures_grasp')
local LeechSeed         = bot:GetAbilityByName('treant_leech_seed')
local LivingArmor       = bot:GetAbilityByName('treant_living_armor')
-- local NaturesGuise      = bot:GetAbilityByName('treant_natures_guise')
local EyesInTheForest   = bot:GetAbilityByName('treant_eyes_in_the_forest')
local Overgrowth        = bot:GetAbilityByName('treant_overgrowth')

local NaturesGraspDesire, NaturesGraspLocation
local LeechSeedDesire, LeechSeedTarget
local LivingArmorDesire, LivingArmorTarget
local EyesInTheForestDesire, EyesInTheForestTarget
local OvergrowthDesire

local Blink
local BlinkOvergrowthDesire, BlinkLocation

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    BlinkOvergrowthDesire, BlinkLocation = X.ConsiderBlinkOvergrowth()
    if BlinkOvergrowthDesire > 0
    then
        bot:Action_ClearActions(false)
        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbility(Overgrowth)
        return
    end

    OvergrowthDesire = X.ConsiderOvergrowth()
    if OvergrowthDesire > 0
    then
        bot:Action_UseAbility(Overgrowth)
        return
    end

    NaturesGraspDesire, NaturesGraspLocation = X.ConsiderNaturesGrasp()
    if NaturesGraspDesire > 0
    then
        bot:Action_UseAbilityOnLocation(NaturesGrasp, NaturesGraspLocation)
        return
    end

    LeechSeedDesire, LeechSeedTarget = X.ConsiderLeechSeed()
    if LeechSeedDesire > 0
    then
        bot:Action_UseAbilityOnEntity(LeechSeed, LeechSeedTarget)
        return
    end

    EyesInTheForestDesire, EyesInTheForestTarget = X.ConsiderEyesInTheForest()
    if EyesInTheForestDesire > 0
    then
        bot:Action_UseAbilityOnEntity(EyesInTheForest, EyesInTheForestTarget)
        return
    end

    LivingArmorDesire, LivingArmorTarget = X.ConsiderLivingArmor()
    if LivingArmorDesire > 0
    then
        bot:Action_UseAbilityOnEntity(LivingArmor, LivingArmorTarget)
        return
    end
end

function X.ConsiderNaturesGrasp()
    if not NaturesGrasp:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, NaturesGrasp:GetCastRange())
    local nRadius = NaturesGrasp:GetSpecialValueInt('latch_range')
    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not J.IsLocationInChrono(botTarget:GetLocation())
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nTargetInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1000, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.75 and bot:WasRecentlyDamagedByAnyHero(1)))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
            end
        end
    end

    if J.IsDefending(bot)
	then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nLocationAoE.count >= 3
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        if nLocationAoE.count >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsLaning(bot)
	then
		local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, 5)

		if  J.IsValidTarget(strongestTarget)
        and J.CanCastOnNonMagicImmune(strongestTarget)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not strongestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not strongestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and J.GetMP(bot) > 0.75
		then
            return BOT_ACTION_DESIRE_HIGH, strongestTarget:GetLocation()
		end

        if not J.IsInLaningPhase()
        then
            local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and nLocationAoE.count >= 3
            and J.CanBeAttacked(nEnemyLaneCreeps[1])
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
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

function X.ConsiderLeechSeed()
    if not LeechSeed:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, LeechSeed:GetCastRange())
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        local target = nil
        local dmg = 0

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_treant_natures_grasp_damage')
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
                local currDmg = enemyHero:GetEstimatedDamageToTarget(false, bot, 5, DAMAGE_TYPE_ALL)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                and currDmg > dmg
                then
                    dmg = currDmg
                    target = enemyHero
                end
            end
        end

        if target ~= nil
        then
            return BOT_ACTION_DESIRE_MODERATE, target
        end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_treant_natures_grasp_damage')
		then
            if (#nInRangeEnemy > #nInRangeAlly
                or J.GetHP(bot) < 0.75 and bot:WasRecentlyDamagedByAnyHero(1.5))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderLivingArmor()
    if not LivingArmor:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    -- Offensive Ally
    local strongestAlly = nil
    local off = 0

    if J.IsGoingOnSomeone(bot)
    or J.IsInTeamFight(bot, 1600)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

        for _, allyHero in pairs(nInRangeAlly)
        do
            if  J.IsValidHero(allyHero)
            and not J.IsMeepoClone(allyHero)
            and not allyHero:IsIllusion()
            and not allyHero:HasModifier('modifier_arc_warden_tempest_double')
            and not allyHero:HasModifier('modifier_treant_living_armor')
            and not allyHero:HasModifier('modifier_fountain_aura')
            then
                if off < allyHero:GetOffensivePower()
                then
                    off = allyHero:GetOffensivePower()
                    strongestAlly = allyHero
                end
            end
        end
    end

    if strongestAlly ~= nil
    then
        return BOT_ACTION_DESIRE_HIGH, strongestAlly
    end

    -- Ally
    local ally = nil
    local hp = 1

    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if  J.IsValidHero(allyHero)
        and not J.IsMeepoClone(allyHero)
        and not allyHero:IsIllusion()
        and not allyHero:HasModifier('modifier_arc_warden_tempest_double')
        and not allyHero:HasModifier('modifier_treant_living_armor')
        and not allyHero:HasModifier('modifier_fountain_aura')
        then
            if  J.GetHP(allyHero) < hp
            and J.GetHP(allyHero) < 0.8
            then
                hp = J.GetHP(allyHero)
                ally = allyHero
            end
        end
    end

    if ally ~= nil
    then
        return BOT_ACTION_DESIRE_HIGH, ally
    end

    -- Building
    local allyBuilding = nil
    local bHealth = 1

    for _, b in pairs(GetUnitList(UNIT_LIST_ALLIED_BUILDINGS))
    do
        if  J.IsValidBuilding(b)
        and not b:HasModifier('modifier_treant_living_armor')
        then
            if  (b:GetHealth() / b:GetMaxHealth()) < bHealth
            and (b:GetHealth() / b:GetMaxHealth()) < 0.9
            then
                bHealth = (b:GetHealth() / b:GetMaxHealth())
                allyBuilding = b
            end
        end
    end

    if allyBuilding ~= nil
    then
        return BOT_ACTION_DESIRE_HIGH, allyBuilding
    end

    -- Self
    if  J.GetHP(bot) < 0.75
    and not bot:HasModifier('modifier_treant_living_armor')
    and not bot:HasModifier('modifier_fountain_aura')
    then
        return BOT_ACTION_DESIRE_HIGH, bot
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderOvergrowth()
    if not Overgrowth:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = Overgrowth:GetSpecialValueInt('radius')

    if J.IsInTeamFight(bot, 1200)
	then
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and not J.IsLocationInChrono(bot:GetLocation())
        and not J.IsLocationInBlackHole(bot:GetLocation())
		then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderEyesInTheForest()
    if not EyesInTheForest:IsTrained()
    or not EyesInTheForest:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, EyesInTheForest:GetCastRange())
    local nRadius = EyesInTheForest:GetSpecialValueInt('vision_aoe')
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
    then
        if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_treant_eyes_in_the_forest')
        then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
            local nTrees = bot:GetNearbyTrees(nCastRange)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            and #nInRangeAlly >= 1
            and nTrees ~= nil and #nTrees >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, nTrees[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBlinkOvergrowth()
    if CanDoBlinkOvergrowth()
    then
        local nRadius = Overgrowth:GetSpecialValueInt('radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1199, nRadius, 0, 0)
            local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            and not J.IsLocationInChrono(nLocationAoE.targetloc)
            and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
            and GetUnitToLocationDistance(bot, nLocationAoE.targetloc) > 600
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkOvergrowth()
    if  Overgrowth:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = Overgrowth:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

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

return X