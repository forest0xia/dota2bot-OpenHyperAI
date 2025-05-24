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
    "item_arcane_boots",
    "item_pavise",
    "item_guardian_greaves",--
    "item_solar_crest",--
    "item_spirit_vessel",--
    "item_force_staff",--
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
    "item_tranquil_boots",
    "item_pavise",
    'item_pipe',--
    "item_solar_crest",--
    "item_spirit_vessel",--
    "item_force_staff",--
    "item_boots_of_bearing",--
    "item_aghanims_shard",
    "item_ultimate_scepter",
    "item_wind_waker",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
	"item_tango",
	"item_double_branches",
	"item_faerie_fire",
	"item_circlet",

	"item_magic_wand",
	"item_boots",
	"item_ring_of_basilius",
	"item_arcane_boots",
	"item_shivas_guard",--
	"item_cyclone",
	"item_kaya_and_sange",--
	"item_eternal_shroud",--
	"item_black_king_bar",--
	"item_aghanims_shard",
	"item_octarine_core",--
	"item_refresher",--
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_1'] = {
	"item_crystal_maiden_outfit",
	"item_dragon_lance",
	"item_witch_blade",
	"item_hurricane_pike",--
	"item_black_king_bar",--
	"item_aghanims_shard",
    "item_ultimate_scepter",
	"item_sange_and_yasha",--
	"item_devastator",--
	"item_sheepstick",--
	"item_moon_shard",
	"item_travel_boots",
	"item_ultimate_scepter_2",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = {
	"item_mid_outfit",
	"item_dragon_lance",
	"item_witch_blade",
	"item_hurricane_pike",--
	"item_black_king_bar",--
	"item_aghanims_shard",
    "item_ultimate_scepter",
	"item_kaya_and_sange",--
	"item_devastator",--
	"item_sheepstick",--
	"item_moon_shard",
	"item_travel_boots",
	"item_ultimate_scepter_2",
	"item_travel_boots_2",--
}

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

local VenomousGale      = bot:GetAbilityByName('venomancer_venomous_gale')
-- local PoisonSting       = bot:GetAbilityByName('venomancer_poison_sting')
local PlagueWard        = bot:GetAbilityByName('venomancer_plague_ward')
-- local LatentToxicity    = bot:GetAbilityByName('venomancer_latent_poison')
-- local PoisonNova        = bot:GetAbilityByName('venomancer_poison_nova')
local NoxiousPlague     = bot:GetAbilityByName('venomancer_noxious_plague')

local VenomousGaleDesire, VenomousGaleLocation
local PlagueWardDesire, PlagueWardLocation, bTargetAlly
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

    PlagueWardDesire, PlagueWardLocation, bTargetAlly = X.ConsiderPlagueWard()
    if PlagueWardDesire > 0
    then
        if bTargetAlly then
            bot:Action_UseAbilityOnEntity(PlagueWard, PlagueWardLocation)
        else
            bot:Action_UseAbilityOnLocation(PlagueWard, PlagueWardLocation)
        end
        return
    end
end

function X.ConsiderVenomousGale()
    if not J.CanCastAbility(VenomousGale)
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
        if J.IsValidHero(enemyHero)
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

                if nInRangeTower ~= nil and #nInRangeTower >= 1
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
            if J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.5)
            and not allyHero:IsIllusion()
            then
                if J.IsValidHero(enemyHero)
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
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
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
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
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

    if (J.IsPushing(bot) or J.IsDefending(bot))
    and not J.IsThereCoreNearby(1000)
	then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
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
            if J.IsValid(creep)
            and creep:GetHealth() <= nInitDamage
            then
                canKill = canKill + 1
                table.insert(creepList, creep)
            end
		end

        if canKill >= 2
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
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
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

function X.ConsiderPlagueWard()
    if not J.CanCastAbility(PlagueWard)
    then
        return BOT_ACTION_DESIRE_NONE, 0, false
    end

    local nCastRange = J.GetProperCastRange(false, bot, PlagueWard:GetCastRange())

    local nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local nStacks = 20 -- J.GetModifierCount(bot, 'modifier_venomancer_ward_counter') -- 7.39 facet changed

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidTarget(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            if nStacks < 8 then
                return BOT_ACTION_DESIRE_HIGH, bot, true
            else
                local nEnemyTower = botTarget:GetNearbyTowers(700, false)
                if nEnemyTower ~= nil and #nEnemyTower == 0 then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), false
                end
            end

		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
        for _, enemyHero in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemyHero)
            and J.CanBeAttacked(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                if (J.GetHP(bot) < 0.75 and bot:WasRecentlyDamagedByAnyHero(3.0))
                or (#nAllyHeroes < #nEnemyHeroes)
                then
                    if J.IsInRange(bot, enemyHero, 550) and nStacks < 6 then
                        return BOT_ACTION_DESIRE_HIGH, bot, true
                    else
                        return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + enemyHero:GetLocation()) / 2, false
                    end
                end
            end
        end
	end

    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and allyHero ~= bot
        and J.IsInRange(bot, allyHero, nCastRange)
        and not allyHero:IsIllusion()
        then
            local allyStack = J.GetModifierCount(allyHero, 'modifier_venomancer_ward_counter')
            if J.IsPushing(allyHero) or J.IsFarming(allyHero) then
                if #nAllyHeroes <= 2 or ( #nAllyHeroes > 2 and allyHero:GetAttackRange() < 450) then
                    if allyStack < 6 then
                        return BOT_ACTION_DESIRE_HIGH, allyHero, true
                    end
                end
            end

            if J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(3.0) then
                local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(600, true, BOT_MODE_NONE)
                for _, enemyHero in pairs(nAllyInRangeEnemy) do
                    if J.IsValidHero(enemyHero)
                    and J.CanBeAttacked(enemyHero)
                    and J.IsChasingTarget(enemyHero, allyHero)
                    and not J.IsSuspiciousIllusion(enemyHero)
                    then
                        if allyStack < 6 then
                            return BOT_ACTION_DESIRE_HIGH, allyHero, true
                        end
                    end
                end
            end
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot) then
        if nStacks < 6 then
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)
            if J.CanBeAttacked(nEnemyLaneCreeps[1])
            and not J.IsRunning(nEnemyLaneCreeps[1])
            and J.GetMP(bot) > 0.5
            then
                return BOT_ACTION_DESIRE_HIGH, bot, true
            end

            if J.IsValidBuilding(botTarget)
            and J.CanBeAttacked(botTarget)
            and J.IsInRange(bot, botTarget, 550)
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH, bot, true
            end
        end
	end

    if nStacks < 6 then
        if J.IsDoingRoshan(bot)
        then
            if J.IsRoshan(botTarget)
            and J.CanBeAttacked(botTarget)
            and J.IsInRange(bot, botTarget, 500)
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH, bot, true
            end
        end

        if J.IsDoingTormentor(bot)
        then
            if J.IsTormentor(botTarget)
            and J.IsInRange(bot, botTarget, 500)
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH, bot, true
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, false
end

function X.ConsiderNoxiousPlague()
    if not J.CanCastAbility(NoxiousPlague)
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
            if J.IsValidHero(enemyHero)
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

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
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


return X