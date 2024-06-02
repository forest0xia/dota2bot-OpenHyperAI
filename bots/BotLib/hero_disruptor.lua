local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,1,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_double_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_blood_grenade",

    "item_tranquil_boots",
    "item_magic_wand",
    "item_force_staff",--
    "item_solar_crest",--
    "item_glimmer_cape",--
    "item_boots_of_bearing",--
    "item_sheepstick",--
    "item_wind_waker",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_double_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_blood_grenade",

    "item_arcane_boots",
    "item_magic_wand",
    "item_force_staff",--
    "item_solar_crest",--
    "item_glimmer_cape",--
    "item_guardian_greaves",--
    "item_sheepstick",--
    "item_wind_waker",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_double_tango",
    "item_double_branches",
    "item_faerie_fire",

    "item_arcane_boots",
    "item_magic_wand",
    "item_force_staff",--
    "item_solar_crest",--
    "item_glimmer_cape",--
    "item_guardian_greaves",--
    "item_sheepstick",--
    "item_wind_waker",--
    "item_aghanims_shard",
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

X['sSellList'] = {}

if sRole == "pos_4"
then
    X['sSellList'] = Pos4SellList
else
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

local ThunderStrike = bot:GetAbilityByName('disruptor_thunder_strike')
local Glimpse       = bot:GetAbilityByName('disruptor_glimpse')
local KineticField  = bot:GetAbilityByName('disruptor_kinetic_field')
local StaticStorm   = bot:GetAbilityByName('disruptor_static_storm')

local ThunderStrikeDesire, ThunderStrikeTarget
local GlimpseDesire, GlimpseTarget
local KineticFieldDesire, KineticFieldLocation
local StaticStormDesire, StaticStormLocation

local KineticStormDesire, KineticStormLocation

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    KineticStormDesire, KineticStormLocation = X.ConsiderKineticStorm()
    if KineticStormDesire > 0
    then
        bot:Action_ClearActions(false)
        bot:ActionQueue_UseAbilityOnLocation(StaticStorm, KineticStormLocation)
        bot:ActionQueue_Delay(0.05)
        bot:ActionQueue_UseAbilityOnLocation(KineticField, KineticStormLocation)
        bot:ActionQueue_Delay(0.05)
        return
    end

    StaticStormDesire, StaticStormLocation = X.ConsiderStaticStorm()
    if StaticStormDesire > 0
    then
        bot:Action_UseAbilityOnLocation(StaticStorm, StaticStormLocation)
        return
    end

    KineticFieldDesire, KineticFieldLocation = X.ConsiderKineticField()
    if KineticFieldDesire > 0
    then
        bot:Action_UseAbilityOnLocation(KineticField, KineticFieldLocation)
        return
    end

    ThunderStrikeDesire, ThunderStrikeTarget = X.ConsiderThunderStrike()
    if ThunderStrikeDesire > 0
    then
        bot:Action_UseAbilityOnEntity(ThunderStrike, ThunderStrikeTarget)
        return
    end

    GlimpseDesire, GlimpseTarget = X.ConsiderGlimpse()
    if GlimpseDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Glimpse, GlimpseTarget)
        return
    end
end

function X.ConsiderThunderStrike()
    if not ThunderStrike:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, ThunderStrike:GetCastRange())
    local nRadius = ThunderStrike:GetSpecialValueInt('radius')
	local nDamage = ThunderStrike:GetSpecialValueInt('strike_damage')
    local nStikesCount = ThunderStrike:GetSpecialValueInt('strikes')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidTarget(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage * nStikesCount, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
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

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and J.IsCore(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and allyHero:GetActiveModeDesire() >= 0.5
        and not allyHero:IsIllusion()
        and not Glimpse:IsFullyCastable()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + 300)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
		end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.5
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        then
            for _, creep in pairs(nEnemyLaneCreeps)
            do
                if  J.IsValid(creep)
                and J.CanBeAttacked(creep)
                then
                    local nCreepCountAround = J.GetNearbyAroundLocationUnitCount(true, false, nRadius, creep:GetLocation())
                    if nCreepCountAround >= 3
                    then
                        return BOT_ACTION_DESIRE_HIGH, creep
                    end
                end
            end
        end
	end

    if J.IsDoingRoshan(bot)
	then
        -- Remove Spell Block
		if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
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

    local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
    for _, creep in pairs(nNeutralCreeps)
    do
        if  J.IsValid(creep)
        and J.CanBeAttacked(creep)
        and creep:GetHealth() > nDamage * nStikesCount / 2
        and creep:GetHealth() <= nDamage * nStikesCount
        then
            return BOT_ACTION_DESIRE_HIGH, creep
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderGlimpse()
    if not Glimpse:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Glimpse:GetCastRange())
    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and (enemyHero:IsChanneling()
		or (bot:GetActiveMode() == BOT_MODE_ATTACK
            and (nAllyHeroes ~= nil and #nAllyHeroes <= 3 and #nEnemyHeroes <= 2)
            and bot:IsFacingLocation(enemyHero:GetLocation(), 30)
            and enemyHero:IsFacingLocation(J.GetEnemyFountain(), 30)))
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
            if enemyHero:HasModifier('modifier_teleporting')
            or enemyHero:HasModifier('modifier_fountain_aura_buff')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if J.IsGoingOnSomeone(bot)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)
                if  J.IsChasingTarget(bot, enemyHero)
                and enemyHero:GetCurrentMovementSpeed() > bot:GetCurrentMovementSpeed()
                and nInRangeAlly ~= nil and #nInRangeAlly >= #nEnemyHeroes
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
		end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() >= 0.75
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not J.IsRealInvisible(bot)
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and J.IsCore(allyHero)
        and allyHero:GetActiveModeDesire() >= 0.75
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    local realHeroCount = 0
    local illuHeroCount = 0
    local illuTarget = nil

    for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and Glimpse:GetLevel() >= 3
		then
            if J.IsSuspiciousIllusion(enemyHero)
            then
                illuHeroCount = illuHeroCount + 1
                illuTarget = enemyHero
            else
                realHeroCount = realHeroCount + 1
            end
        end
    end

    if realHeroCount == 0 and illuHeroCount >= 1
    then
        return BOT_ACTION_DESIRE_HIGH, illuTarget
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderKineticField()
    if not KineticField:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, KineticField:GetCastRange())
	local nCastPoint = KineticField:GetCastPoint()
	local nRadius = KineticField:GetSpecialValueInt('radius')

	if  J.IsInTeamFight(bot, 1200)
    and not CanCastKineticStorm()
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius * 0.8, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius * 0.8)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:IsMagicImmune()
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1400, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1400, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if #nInRangeEnemy == 0
                then
                    if J.IsChasingTarget(bot, botTarget)
                    then
                        if J.IsInRange(bot, botTarget, nCastRange)
                        then
                            return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
                        end

                        if  J.IsInRange(bot, botTarget, nCastRange + nRadius)
                        and not J.IsInRange(bot, botTarget, nCastRange)
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
                        end
                    end
                else
                    if J.IsInRange(bot, botTarget, nCastRange)
                    then
                        nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius * 0.8)
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
                            return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
                        end
                    end

                    if  J.IsInRange(bot, botTarget, nCastRange + nRadius)
                    and not J.IsInRange(bot, botTarget, nCastRange)
                    then
                        nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius * 0.8)
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
                        else
                            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
                        end
                    end
                end
            end
		end
	end

    local desireCheck = RemapValClamped(KineticField:GetLevel(), 1, 4, 0.75, 0.5)
    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() >= desireCheck
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            if  J.IsValidHero(nInRangeEnemy[1])
            and J.IsChasingTarget(nInRangeEnemy[1], bot)
            and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
            and not J.IsDisabled(nInRangeEnemy[1])
            and not nInRangeEnemy[1]:IsMagicImmune()
            and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    if GetUnitToLocationDistance(bot, nInRangeEnemy[1]:GetExtrapolatedLocation(nCastPoint)) > nRadius
                    then
                        return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
                    else
                        return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + nInRangeEnemy[1]:GetLocation()) / 2
                    end
                end
            end
        end
	end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and J.IsCore(allyHero)
        and allyHero:GetActiveModeDesire() >= 0.75
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and not allyHero:IsIllusion()
        and not J.IsGoingOnSomeone(bot)
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:IsMagicImmune()
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            and GetUnitToUnitDistance(allyHero, nAllyInRangeEnemy[1]) < GetUnitToUnitDistance(bot, nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, (allyHero:GetLocation() + nAllyInRangeEnemy[1]:GetLocation()) / 2
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderStaticStorm()
	if not StaticStorm:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = StaticStorm:GetSpecialValueInt('radius')
	local nCastRange = StaticStorm:GetCastRange()

	if  J.IsInTeamFight(bot, 1200)
    and not CanCastKineticStorm()
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius * 0.8, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius * 0.8)

		if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and not J.IsLocationInChrono(nLocationAoE.targetloc)
        and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderKineticStorm()
    if CanCastKineticStorm()
    then
	    local nCastRange = J.GetProperCastRange(false, bot, KineticField:GetCastRange())
        local nRadius = KineticField:GetSpecialValueInt('radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius * 0.8, 0, 0)
            local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius * 0.8)

            if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            and not J.IsLocationInChrono(nLocationAoE.targetloc)
            and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function CanCastKineticStorm()
    if  KineticField:IsFullyCastable()
    and StaticStorm:IsFullyCastable()
    then
        local nManaCost = KineticField:GetManaCost() + StaticStorm:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end

return X