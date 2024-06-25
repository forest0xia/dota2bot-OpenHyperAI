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
						{1,2,3,3,3,6,3,1,1,1,6,2,2,2,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}


sRoleItemsBuyList['pos_1'] = {
	"item_sven_outfit",
	"item_echo_sabre",
	"item_hand_of_midas",
	"item_aghanims_shard",
	"item_blink",
	"item_black_king_bar",
	"item_travel_boots",
	"item_satanic",
	"item_overwhelming_blink",
	"item_greater_crit", 
	"item_abyssal_blade",
	"item_moon_shard",
	"item_travel_boots_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = {
	"item_tank_outfit",
	"item_crimson_guard",
	"item_aghanims_shard",
	"item_heavens_halberd",
	"item_lotus_orb",
	"item_travel_boots",
	"item_assault",
	"item_ultimate_scepter_2",
	"item_heart",
	"item_moon_shard",
	"item_travel_boots_2",
}

sRoleItemsBuyList['pos_4'] = {
	"item_priest_outfit",
	"item_urn_of_shadows",
	"item_blink",
	"item_mekansm",
	"item_glimmer_cape",--
	"item_aghanims_shard",--
	"item_guardian_greaves",--
	"item_spirit_vessel",--
--	"item_wraith_pact",
	"item_overwhelming_blink",--
	"item_ultimate_scepter_2",
	"item_sheepstick",--
	"item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_4']

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

local Fissure       = bot:GetAbilityByName('earthshaker_fissure')
local EnchantTotem  = bot:GetAbilityByName('earthshaker_enchant_totem')
local Aftershock    = bot:GetAbilityByName('earthshaker_aftershock')
local EchoSlam      = bot:GetAbilityByName('earthshaker_echo_slam')

local FissureDesire, FissureLocation
local EnchantTotemDesire, EnchantTotemLocation, WantToJump
local EchoSlamDesire

local BlinkSlamDesire, BlinkSlamLocation
local TotemSlamDesire, TotemSlamLocation

local Blink

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    or bot:NumQueuedActions() > 0
    then return end

    botTarget = J.GetProperTarget(bot)

    BlinkSlamDesire, BlinkSlamLocation = X.ConsiderBlinkSlam()
    if BlinkSlamDesire > 0
    then
        bot:Action_ClearActions(false)

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkSlamLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbility(EchoSlam)
        return
    end

    TotemSlamDesire, TotemSlamLocation = X.ConsiderTotemSlam()
    if TotemSlamDesire > 0
    then
        local nLeapDuration = EnchantTotem:GetSpecialValueFloat('scepter_leap_duration')

        bot:Action_ClearActions(false)
        bot:ActionQueue_UseAbilityOnLocation(EnchantTotem, TotemSlamLocation)
        bot:ActionQueue_Delay(nLeapDuration + 0.1)
        bot:ActionQueue_UseAbility(EchoSlam)
        return
    end

    EchoSlamDesire = X.ConsiderEchoSlam()
    if EchoSlamDesire > 0
    then
        bot:Action_UseAbility(EchoSlam)
        return
    end

    EnchantTotemDesire, EnchantTotemLocation, WantToJump = X.ConsiderEnchantTotem()
    if EnchantTotemDesire > 0
    then
        if bot:HasScepter()
        then
            if WantToJump
            then
                bot:Action_UseAbilityOnLocation(EnchantTotem, EnchantTotemLocation)
            else
                bot:Action_UseAbilityOnEntity(EnchantTotem, bot)
            end

            return
        else
            bot:Action_UseAbility(EnchantTotem)
            return
        end
    end

    FissureDesire, FissureLocation = X.ConsiderFissure()
    if FissureDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Fissure, FissureLocation)
        return
    end
end

function X.ConsiderFissure()
    if not Fissure:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, Fissure:GetCastRange())
	local nCastPoint = Fissure:GetCastPoint()
	local nRadius = Fissure:GetSpecialValueInt('fissure_radius')
    local nDamage = Fissure:GetSpecialValueInt('fissure_damage')
    local nAbilityLevel = Fissure:GetLevel()

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
            end
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,1400, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:GetActiveModeDesire() >= 0.5
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(nCastPoint + 0.1)
            end
        end
    end

	if J.IsInTeamFight(bot)
	then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange + 300)
        local target = nil
        local dmg = 0

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local currDmg = enemyHero:GetEstimatedDamageToTarget(false, bot, 5, DAMAGE_TYPE_ALL)
                if currDmg > dmg
                then
                    dmg = currDmg
                    target = enemyHero
                end
            end
        end

        if target ~= nil
        then
            nInRangeEnemy = J.GetEnemiesNearLoc(target:GetLocation(), nRadius)
            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
            else
                return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(nCastPoint)
            end
        end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)
                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                else
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
                end
            end
		end
	end

	if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeEnemy > #nInRangeAlly
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and bot:WasRecentlyDamagedByAnyHero(2)
        and not J.IsInRange(bot, nInRangeEnemy[1], 300)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            nInRangeEnemy = J.GetEnemiesNearLoc(nInRangeEnemy[1]:GetLocation(), nRadius)
            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
            else
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
            end
        end
    end

    nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
	if  (J.IsPushing(bot) or J.IsDefending(bot))
    and J.GetManaAfter(Fissure:GetManaCost()) * bot:GetMana() > EchoSlam:GetManaCost()
    and nAbilityLevel >= 3
    and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
    and not J.IsThereCoreNearby(1000)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
		if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		and J.CanBeAttacked(nEnemyLaneCreeps[1])
		then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderEnchantTotem()
    if not EnchantTotem:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0, false
    end

    local nCastRange = bot:HasScepter() and EnchantTotem:GetSpecialValueInt('distance_scepter') or 0
	local nRadius = Aftershock:GetSpecialValueInt('aftershock_range')
    local nLeapDuration = EnchantTotem:GetSpecialValueFloat('scepter_leap_duration')

	if bot:HasScepter() and J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange), true
	end

	if J.IsInTeamFight(bot)
	then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)
        local nInRangeIllusion = J.GetIllusionsNearLoc(bot:GetLocation(), nRadius)

		if bot:HasScepter()
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nLeapDuration, 0)
            nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy), true
            end

            nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
            if  nInRangeIllusion ~= nil and #nInRangeIllusion >= 2
            and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
            then
                return BOT_ACTION_DESIRE_HIGH, 0, false
            end
		else
            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, 0, false
            end

            nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
            if  nInRangeIllusion ~= nil and #nInRangeIllusion >= 2
            and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
            then
                return BOT_ACTION_DESIRE_HIGH, 0, false
            end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if bot:HasScepter()
                then
                    if  J.IsInRange(bot, botTarget, nCastRange)
                    and not J.IsInRange(bot, botTarget, nRadius)
                    and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nLeapDuration), true
                    else
                        if J.IsInRange(bot, botTarget, nRadius - 50)
                        then
                            return BOT_ACTION_DESIRE_HIGH, 0, false
                        end
                    end
                else
                    if J.IsInRange(bot, botTarget, nRadius - 50)
                    then
                        return BOT_ACTION_DESIRE_HIGH, 0, false
                    end
                end
            end
		end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.7
    then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    if bot:HasScepter()
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange), true
                    else
                        if J.IsInRange(bot, enemyHero, nRadius)
                        then
                            return BOT_ACTION_DESIRE_HIGH, 0, false
                        end
                    end
                end
            end
        end
    end

    if  (J.IsPushing(bot) or J.IsDefending(bot))
    and J.GetManaAfter(EnchantTotem:GetManaCost()) * bot:GetMana() > Fissure:GetManaCost() * 2
    and J.GetManaAfter(EnchantTotem:GetManaCost()) * bot:GetMana() > EchoSlam:GetManaCost()
    and not bot:HasModifier('modifier_earthshaker_enchant_totem')
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1400, true)

        if bot:HasScepter()
        then
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and J.CanBeAttacked(nEnemyLaneCreeps[1])
            and not J.IsRunning(nEnemyLaneCreeps[1])
            then
                local nCreepCount = J.GetNearbyAroundLocationUnitCount(true, false, nRadius, nEnemyLaneCreeps[1]:GetLocation())
                if nCreepCount >= 3
                then
                    return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]:GetLocation(), true
                end
            end

            if  J.IsValidBuilding(botTarget)
            and J.CanBeAttacked(botTarget)
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH, 0, false
            end
        else
            nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and J.CanBeAttacked(nEnemyLaneCreeps[1])
            then
                return BOT_ACTION_DESIRE_HIGH, 0, false
            end

            if  J.IsValidBuilding(botTarget)
            and J.CanBeAttacked(botTarget)
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH, 0, false
            end
        end
    end

    if  J.IsLaning(bot)
    and J.IsInLaningPhase()
    then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_abaddon_borrowed_time')
        then
            return BOT_ACTION_DESIRE_HIGH, 0, false
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, 0, false
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, 0, false
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, false
end

function X.ConsiderEchoSlam()
    if not EchoSlam:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = EchoSlam:GetSpecialValueInt('echo_slam_echo_range')

	if J.IsInTeamFight(bot, 1200)
	then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius / 2)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius / 2)
        -- and J.IsCore(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not botTarget:HasModifier('modifier_item_aeon_disk_buff')
        and not botTarget:IsInvulnerable()
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            then
                if #nInRangeAlly <= 1 and #nInRangeEnemy <= 1
                then
                    if botTarget:IsChanneling()
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end

                    if botTarget:GetHealth() <= bot:GetEstimatedDamageToTarget(true, botTarget, 5, DAMAGE_TYPE_ALL)
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end

                if #nInRangeEnemy > #nInRangeAlly
                then
                    if botTarget:GetHealth() <= bot:GetEstimatedDamageToTarget(true, botTarget, 5, DAMAGE_TYPE_ALL)
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end

                if  #nInRangeAlly >= #nInRangeEnemy
                and not (#nInRangeAlly >= #nInRangeEnemy + 2)
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

-- Blink > Echo
function X.ConsiderBlinkSlam()
    if X.CanDoBlinkSlam()
    then
        local nCastRange = 1199
        local nRadius = EchoSlam:GetSpecialValueInt('echo_slam_echo_range')

        if J.IsGoingOnSomeone(bot)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
            local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius / 2)

            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.CanDoBlinkSlam()
    if  X.HasBlink()
    and EchoSlam:IsFullyCastable()
    then
        local nManaCost = EchoSlam:GetManaCost()

        if  bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

-- Enchant Totem > Echo
function X.ConsiderTotemSlam()
    if X.CanDoTotemSlam()
    then
        local nETCastRange = EnchantTotem:GetSpecialValueInt('distance_scepter')
        local nETLeapDuration = EnchantTotem:GetSpecialValueFloat('scepter_leap_duration')
        local nRadius = EchoSlam:GetSpecialValueInt('echo_slam_echo_range')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nETCastRange, nRadius, nETLeapDuration, 0)
            local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius / 2)

            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.CanDoTotemSlam()
    if  bot:HasScepter()
    and EnchantTotem:IsFullyCastable()
    and EchoSlam:IsFullyCastable()
    then
        local nManaCost = EnchantTotem:GetManaCost() + EchoSlam:GetManaCost()

        if  bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end

function X.CanJump()
    if  bot:HasScepter()
    and EnchantTotem:IsFullyCastable()
    then
        return true
    end

    return false
end

function X.HasBlink()
    local blink = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if item ~= nil
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