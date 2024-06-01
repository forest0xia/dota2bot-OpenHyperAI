local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos4,5
                        ['t25'] = {0, 10},
                        ['t20'] = {0, 10},
                        ['t15'] = {10, 0},
                        ['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sUtility = {"item_pipe", "item_lotus_orb", "item_heavens_halberd"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",

    "item_boots",
    "item_magic_wand",
    "item_urn_of_shadows",
    "item_tranquil_boots",
    "item_solar_crest",--
    "item_spirit_vessel",--
    "item_force_staff",--
    "item_boots_of_bearing",--
    "item_aghanims_shard",
    nUtility,--
    "item_ultimate_scepter",
    "item_wind_waker",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",

    "item_boots",
    "item_magic_wand",
    "item_urn_of_shadows",
    "item_arcane_boots",
    "item_solar_crest",--
    "item_spirit_vessel",--
    "item_force_staff",--
    "item_guardian_greaves",--
    "item_aghanims_shard",
    nUtility,--
    "item_ultimate_scepter",
    "item_wind_waker",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_double_tango",
    "item_double_branches",

    "item_boots",
    "item_magic_wand",
    "item_urn_of_shadows",
    "item_tranquil_boots",
    "item_solar_crest",--
    "item_spirit_vessel",--
    "item_force_staff",--
    "item_boots_of_bearing",--
    "item_aghanims_shard",
    nUtility,--
    "item_ultimate_scepter",
    "item_wind_waker",--
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

local VenomousGale      = bot:GetAbilityByName('venomancer_venomous_gale')
-- local PoisonSting       = bot:GetAbilityByName('venomancer_poison_sting')
local PlagueWard        = bot:GetAbilityByName('venomancer_plague_ward')
-- local LatentToxicity    = bot:GetAbilityByName('venomancer_latent_poison')
-- local PoisonNova        = bot:GetAbilityByName('venomancer_poison_nova')
local NoxiousPlague     = bot:GetAbilityByName('venomancer_noxious_plague')

local VenomousGaleDesire, VenomousGaleLocation
local PlagueWardDesire, PlagueWardLocation
-- local LatentToxicityDesire, LatentToxicityTarget
local NoxiousPlagueDesire, NoxiousPlagueTarget

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    NoxiousPlagueDesire, NoxiousPlagueTarget = X.ConsiderNoxiousPlague()
    if NoxiousPlagueDesire > 0
    then
        bot:Action_UseAbilityOnEntity(NoxiousPlague, NoxiousPlagueTarget)
        return
    end

    -- LatentToxicityDesire, LatentToxicityTarget = X.ConsiderLatentToxicity()
    -- if LatentToxicityDesire > 0
    -- then
    --     bot:Action_UseAbilityOnEntity(LatentToxicity, LatentToxicityTarget)
    --     return
    -- end

    VenomousGaleDesire, VenomousGaleLocation = X.ConsiderVenomousGale()
    if VenomousGaleDesire > 0
    then
        bot:Action_UseAbilityOnLocation(VenomousGale, VenomousGaleLocation)
        return
    end

    PlagueWardDesire, PlagueWardLocation = X.ConsiderPlagueWard()
    if PlagueWardDesire > 0
    then
        bot:Action_UseAbilityOnLocation(PlagueWard, PlagueWardLocation)
        return
    end
end

function X.ConsiderVenomousGale()
    if not VenomousGale:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, VenomousGale:GetCastRange())
	local nRadius = VenomousGale:GetSpecialValueInt('radius')
    local nInitDamage = VenomousGale:GetSpecialValueInt('strike_damage')
    local nTickDamage = VenomousGale:GetSpecialValueInt('tick_damage')

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and (J.CanKillTarget(enemyHero, nInitDamage, DAMAGE_TYPE_MAGICAL)
            or J.CanKillTarget(enemyHero, nInitDamage * nTickDamage, DAMAGE_TYPE_MAGICAL))
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            if J.IsInLaningPhase()
            then
                local nInRangeTower = enemyHero:GetNearbyTowers(700, true)

                if  nInRangeTower ~= nil and #nInRangeTower >= 1
                and J.IsValidBuilding(nInRangeTower[1])
                and nInRangeTower[1]:GetAttackTarget() == enemyHero
                then
                    local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)

                    if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                    end

                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end

            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nAllyInRangeEnemy)
        do
            if  J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.5)
            and not allyHero:IsIllusion()
            then
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and J.IsChasingTarget(enemyHero, allyHero)
                and not J.IsDisabled(enemyHero)
                and not J.IsTaunted(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    local nTargetInRangeAlly = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)

                    if nTargetInRangeAlly ~= nil and #nTargetInRangeAlly >= 1
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nTargetInRangeAlly)
                    end

                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)

                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                end

                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    nTargetInRangeAlly = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)

                    if nTargetInRangeAlly ~= nil and #nTargetInRangeAlly >= 1
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nTargetInRangeAlly)
                    end

                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
	end

    if  (J.IsPushing(bot) or J.IsDefending(bot))
    and not J.IsThereCoreNearby(1000)
	then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nLocationAoE.count >= 3
        and J.GetMP(bot) > 0.5
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
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
            if  J.IsValid(creep)
            and creep:GetHealth() <= nInitDamage
            then
                canKill = canKill + 1
                table.insert(creepList, creep)
            end
		end

        if  canKill >= 2
        and J.GetMP(bot) > 0.41
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.CanBeAttacked(creepList[1])
        and not J.IsThereCoreNearby(1200)
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
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

function X.ConsiderPlagueWard()
    if not PlagueWard:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, PlagueWard:GetCastRange())

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nAllyInRangeEnemy)
        do
            if  J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.5)
            and not allyHero:IsIllusion()
            then
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and J.IsChasingTarget(enemyHero, allyHero)
                and not J.IsDisabled(enemyHero)
                and not J.IsTaunted(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nEnemyTower = botTarget:GetNearbyTowers(700, true)
            if nEnemyTower ~= nil and #nEnemyTower == 0
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2.2))
                then
                    local nUnits = {bot, enemyHero}
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nUnits)
                end
            end
        end
	end

    if J.IsPushing(bot) or J.IsDefending(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and J.GetMP(bot) > 0.5
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end

        local nEnemyTower = bot:GetNearbyTowers(600, true)
        if  nEnemyTower ~= nil and #nEnemyTower >= 1
        and J.IsValidBuilding(nEnemyTower[1])
        and J.IsAttacking(bot)
        and bot:GetAttackTarget() == nEnemyTower[1]
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end
	end

    if  J.IsLaning(bot)
    and J.IsInLaningPhase()
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsAttacking(enemyHero)
            and J.IsValid(enemyHero:GetAttackTarget())
            and enemyHero:GetAttackTarget():IsCreep()
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nEnemyTower = enemyHero:GetNearbyTowers(700, true)
                if nEnemyTower ~= nil and #nEnemyTower == 0
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
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

function X.ConsiderNoxiousPlague()
    if not NoxiousPlague:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, NoxiousPlague:GetCastRange())

    if J.IsGoingOnSomeone(bot)
	then
        local target = nil
        local dmg = 0
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_venomancer_latent_poison')
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
                local currDmg = enemyHero:GetEstimatedDamageToTarget(true, bot, 5, DAMAGE_TYPE_ALL)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                and not (#nInRangeAlly >= #nTargetInRangeAlly + 2)
                and dmg < currDmg
                then
                    dmg = currDmg
                    target = enemyHero
                end
            end
        end

        if target ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, target
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

-- function X.ConsiderLatentToxicity()
--     if not LatentToxicity:IsTrained()
--     or not LatentToxicity:IsFullyCastable()
--     then
--         return BOT_ACTION_DESIRE_NONE, nil
--     end

--     local nCastRange = J.GetProperCastRange(false, bot, LatentToxicity:GetCastRange())
--     local nDamagePer = LatentToxicity:GetSpecialValueInt('duration_damage')
--     local nDuration = LatentToxicity:GetSpecialValueInt('duration')

--     local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
--     for _, enemyHero in pairs(nEnemyHeroes)
--     do
--         if  J.IsValidHero(enemyHero)
--         and J.CanCastOnNonMagicImmune(enemyHero)
--         and J.CanCastOnTargetAdvanced(enemyHero)
--         and (J.CanKillTarget(enemyHero, nDamagePer * nDuration, DAMAGE_TYPE_MAGICAL))
--         and not J.IsSuspiciousIllusion(enemyHero)
--         and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
--         and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
--         and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
--         and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
--         and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
--         then
--             return BOT_ACTION_DESIRE_HIGH
--         end
--     end

--     if J.IsGoingOnSomeone(bot)
-- 	then
--         local target = nil
--         local dmg = 0
--         local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

--         for _, enemyHero in pairs(nInRangeEnemy)
--         do
--             if  J.IsValidHero(enemyHero)
--             and J.CanCastOnNonMagicImmune(enemyHero)
--             and J.CanCastOnTargetAdvanced(enemyHero)
--             and not J.IsSuspiciousIllusion(enemyHero)
--             and not J.IsDisabled(enemyHero)
--             and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
--             and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
--             and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
--             and not enemyHero:HasModifier('modifier_venomancer_noxious_plague_primary')
--             then
--                 local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
--                 local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
--                 local currDmg = enemyHero:GetEstimatedDamageToTarget(true, bot, 5, DAMAGE_TYPE_ALL)

--                 if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
--                 and #nInRangeAlly >= #nTargetInRangeAlly
--                 and dmg < currDmg
--                 then
--                     dmg = currDmg
--                     target = enemyHero
--                 end
--             end
--         end

--         if target ~= nil
--         then
--             return BOT_ACTION_DESIRE_HIGH, target
--         end
-- 	end

--     if J.IsDoingRoshan(bot)
--     then
--         if  J.IsRoshan(botTarget)
--         and J.CanCastOnNonMagicImmune(botTarget)
--         and J.CanCastOnTargetAdvanced(botTarget)
--         and J.IsInRange(bot, botTarget, 500)
--         and J.IsAttacking(bot)
--         then
--             return BOT_ACTION_DESIRE_HIGH, botTarget
--         end
--     end

--     return BOT_ACTION_DESIRE_NONE, nil
-- end

return X