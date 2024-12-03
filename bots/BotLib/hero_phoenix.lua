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
                        ['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,1,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",

    "item_boots",
    "item_magic_wand",
    "item_tranquil_boots",
    "item_veil_of_discord",
    "item_aghanims_shard",
    "item_shivas_guard",--
    "item_force_staff",--
    "item_boots_of_bearing",--
    "item_cyclone",
    "item_refresher",--
    "item_sheepstick",--
    "item_wind_waker",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_blood_grenade",
	"item_mage_outfit",
	"item_ancient_janggo",
	"item_glimmer_cape",
	"item_boots_of_bearing",
	"item_pipe",
    "item_ultimate_scepter",
	"item_cyclone",
	"item_shivas_guard",--
--	"item_wraith_pact",
    "item_refresher",--
	"item_sheepstick",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}


sRoleItemsBuyList['pos_2'] = {
	"item_bristleback_outfit",
    "item_hand_of_midas",
    "item_radiance",--
	"item_kaya_and_sange",--
    "item_aghanims_shard",
	"item_shivas_guard",--
	"item_heart",--
    "item_ultimate_scepter_2",
    "item_refresher",--
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_2']
sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_2']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_heart",--
    "item_hand_of_midas",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local IcarusDive        = bot:GetAbilityByName('phoenix_icarus_dive')
local IcarusDiveStop    = bot:GetAbilityByName('phoenix_icarus_dive_stop')
local FireSpirits       = bot:GetAbilityByName('phoenix_fire_spirits')
local FireSpiritsLaunch = bot:GetAbilityByName('phoenix_launch_fire_spirit')
local SunRay            = bot:GetAbilityByName('phoenix_sun_ray')
local SunRayStop        = bot:GetAbilityByName('phoenix_sun_ray_stop')
local ToggleMovement    = bot:GetAbilityByName('phoenix_sun_ray_toggle_move')
local Supernova         = bot:GetAbilityByName('phoenix_supernova')

local IcarusDiveDesire, IcarusDiveLocation
local IcarusDiveStopDesire
local FireSpiritsDesire
local FireSpiritsLaunchDesire, FireSpiritsLaunchLocation
local SunRayDesire, SunRayLocation
local SunRayStopDesire
local ToggleMovementDesire, State
local SupernovaDesire, SupernovaTarget

local IcarusDiveTime = -1
local IcarusDiveDuration = 2

local FireSpiritsLaunchTime = 0

if bot.sun_ray_target == nil then bot.sun_ray_target = bot end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    FireSpiritsDesire = X.ConsiderFireSpirits()
    if FireSpiritsDesire > 0
    then
        bot:Action_UseAbility(FireSpirits)
        return
    end

    FireSpiritsLaunchDesire, FireSpiritsLaunchLocation, ETA = X.ConsiderFireSpiritsLaunch()
    if FireSpiritsLaunchDesire > 0
    then
        bot:Action_UseAbilityOnLocation(FireSpiritsLaunch, FireSpiritsLaunchLocation)
        FireSpiritsLaunchTime = DotaTime()
        return
    end

    SupernovaDesire, SupernovaTarget, AllyCast = X.ConsiderSupernova()
    if SupernovaDesire > 0
    then
        if string.find(GetBot():GetUnitName(), 'phoenix')
        and bot:HasScepter()
        and AllyCast
        then
            bot:Action_UseAbilityOnEntity(Supernova, SupernovaTarget)
            return
        else
            -- use Fire Spirits before exploding
            if J.CanCastAbility(FireSpirits) then
                bot:ActionQueue_UseAbility(FireSpirits)

                local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
                for _, enemy in pairs(tEnemyHeroes) do
                    if J.IsValidHero(enemy)
                    and J.IsInRange(bot, enemy, FireSpirits:GetCastRange())
                    and J.CanCastOnNonMagicImmune(enemy)
                    and not J.IsEnemyChronosphereInLocation(enemy:GetLocation())
                    and not J.IsEnemyBlackHoleInLocation(enemy:GetLocation())
                    and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
                    and not enemy:HasModifier('modifier_phoenix_fire_spirit_burn') then
                        bot:ActionQueue_UseAbilityOnLocation(FireSpiritsLaunch, enemy:GetLocation())
                    end
                end

                bot:ActionQueue_UseAbility(Supernova)
                return
            else
                bot:Action_UseAbility(Supernova)
                return
            end
        end
    end

    IcarusDiveDesire, IcarusDiveLocation = X.ConsiderIcarusDive()
    if IcarusDiveDesire > 0
    then
        bot:Action_UseAbilityOnLocation(IcarusDive, IcarusDiveLocation)
        IcarusDiveTime = DotaTime()
        return
    end

    IcarusDiveStopDesire = X.ConsiderIcarusDiveStop()
    if IcarusDiveStopDesire > 0
    then
        bot:Action_UseAbility(IcarusDiveStop)
        bot.icarus_dive_stuck = false
        return
    end

    SunRayDesire, SunRayLocation = X.ConsiderSunRay()
    if SunRayDesire > 0
    then
        bot:Action_UseAbilityOnLocation(SunRay, SunRayLocation)
        return
    end

    SunRayStopDesire = X.ConsiderSunRayStop()
    if SunRayStopDesire > 0
    then
        bot:Action_UseAbility(SunRayStop)
        bot.sun_ray_engage = false
        bot.sun_ray_heal_ally = false
        return
    end

    ToggleMovementDesire, State = X.ConsiderToggleMovement()
    if ToggleMovementDesire > 0
    then
		if State == 'on'
        then
			if not ToggleMovement:GetToggleState()
            then
				bot:Action_UseAbility(ToggleMovement)
			end
		else
			if ToggleMovement:GetToggleState()
            then
				bot:Action_UseAbility(ToggleMovement)
			end
		end

        return
    end
end

function X.ConsiderIcarusDive()
    if not J.CanCastAbility(IcarusDive)
    or bot:IsRooted()
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    or bot:HasModifier('modifier_bloodseeker_rupture')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nDiveLength = IcarusDive:GetSpecialValueInt('dash_length')
	local nDiveWidth = IcarusDive:GetSpecialValueInt('dash_width')
    local nHealthCost = (IcarusDive:GetSpecialValueInt('hp_cost_perc') / 100) * bot:GetHealth()
	local nDamage = IcarusDive:GetSpecialValueInt('damage_per_second') * IcarusDive:GetSpecialValueFloat('burn_duration')
    local nHealth = (bot:GetHealth() - nHealthCost) / bot:GetMaxHealth()
    local botTarget = J.GetProperTarget(bot)

    local tAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(tEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nDiveLength)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not J.IsEnemyChronosphereInLocation(enemyHero:GetLocation())
        and not J.IsEnemyBlackHoleInLocation(enemyHero:GetLocation())
        and nHealth > 0.4
        then
            bot.icarus_dive_kill = true
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
    end

	if J.IsStuck(bot)
	then
        bot.icarus_dive_stuck = true
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nDiveLength)
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nDiveLength, nDiveWidth / 1.5, 0, 0)

		if  nLocationAoE.count >= 2
        and not J.IsEnemyChronosphereInLocation(nLocationAoE.targetloc)
        and not J.IsEnemyBlackHoleInLocation(nLocationAoE.targetloc)
        and nHealth > 0.3
        then
            bot.icarus_dive_engage = true
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

    if J.IsGoingOnSomeone(bot)
    then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nDiveLength)
        and not J.IsEnemyChronosphereInLocation(botTarget:GetLocation())
        and not J.IsEnemyBlackHoleInLocation(botTarget:GetLocation())
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and nHealth > 0.3
        then
            if #tAllyHeroes >= #tEnemyHeroes + 1
            then
                bot.icarus_dive_engage = true
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    if J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.75
    and not J.IsSuspiciousIllusion(bot)
    then
        for _, enemy in pairs(tEnemyHeroes) do
            if J.IsValidHero(enemy)
            and not J.IsSuspiciousIllusion(enemy)
            and bot:WasRecentlyDamagedByHero(enemy, 3.0)
            and nHealth > 0.15
            then
                bot.icarus_dive_retreat = true
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nDiveLength)
            end
        end

        if J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByTower(2.5)
        and nHealth > 0.2
        then
            bot.icarus_dive_retreat = true
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nDiveLength)
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderIcarusDiveStop()
    if not J.CanCastAbility(IcarusDiveStop)
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if bot.icarus_dive_kill
    or bot.icarus_dive_engage then
        if DotaTime() > (IcarusDiveTime + IcarusDiveDuration) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if bot.icarus_dive_stuck
    or bot.icarus_dive_retreat then
        if DotaTime() > (IcarusDiveTime + (IcarusDiveDuration / 2))
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderFireSpirits()
    if not J.CanCastAbility(FireSpirits)
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    or bot:HasModifier('modifier_phoenix_fire_spirit_count')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = J.GetProperCastRange(false, bot, FireSpirits:GetCastRange())
	local nRadius = FireSpirits:GetSpecialValueInt('radius')
    local nHealthCost = (FireSpirits:GetSpecialValueInt('hp_cost_perc') / 100) * bot:GetHealth()
	local nDamage = FireSpirits:GetSpecialValueInt('damage_per_second') * FireSpirits:GetSpecialValueFloat('duration')
    local nSpeed = FireSpirits:GetSpecialValueInt('spirit_speed')
    local nHealth = (bot:GetHealth() - nHealthCost) / bot:GetMaxHealth()
    local botTarget = J.GetProperTarget(bot)

    local tAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(tEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not enemyHero:HasModifier('modifier_phoenix_fire_spirit_burn')
        and nHealth > 0.25
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        local target = nil
        local targetAttackDamage = 0
        for _, enemy in pairs(tEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.IsInRange(bot, enemy, nCastRange)
            and J.CanCastOnNonMagicImmune(enemy)
            and not J.IsEnemyChronosphereInLocation(enemy:GetLocation())
            and not J.IsEnemyBlackHoleInLocation(enemy:GetLocation())
            and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemy:HasModifier('modifier_phoenix_fire_spirit_burn') then
                local enemyAttackDamage = enemy:GetAttackDamage() * enemy:GetAttackSpeed()
                if enemyAttackDamage > targetAttackDamage then
                    target = enemy
                    targetAttackDamage = enemyAttackDamage
                end
            end
        end

        if target ~= nil then
            if J.IsInLaningPhase() then
                for _, ally in pairs(tAllyHeroes) do
                    if J.IsValidHero(ally)
                    and not ally:IsIllusion()
                    and (J.IsAttacking(target) == ally or (J.IsChasingTarget(target, ally)) or target:GetAttackTarget() == ally)
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end
            else
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    local tEnemyLaneCreeps = bot:GetNearbyLaneCreeps(math.min(nCastRange, 1600), true)

    if (J.IsPushing(bot) or J.IsDefending(bot))
    and not J.IsThereNonSelfCoreNearby(1200)
    then
        if #tEnemyLaneCreeps >= 4
        and J.CanBeAttacked(tEnemyLaneCreeps[1])
        and not J.IsRunning(tEnemyLaneCreeps[1])
        and #tEnemyHeroes == 0
        and J.GetMP(bot) > 0.35
        and nHealth > 0.5
        and not J.DoesSomeoneHaveModifier(tEnemyLaneCreeps, 'modifier_phoenix_fire_spirit_burn')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsFarming(bot) and J.GetMP(bot) > 0.35 and nHealth > 0.4
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(math.min(nCastRange, 1600))
        if ((#nNeutralCreeps >= 2)
            or (#nNeutralCreeps >= 1 and nNeutralCreeps[1]:IsAncientCreep()))
        and not J.DoesSomeoneHaveModifier(nNeutralCreeps, 'modifier_phoenix_fire_spirit_burn')
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if #tEnemyLaneCreeps >= 3
        and not J.DoesSomeoneHaveModifier(tEnemyLaneCreeps, 'modifier_phoenix_fire_spirit_burn')
        and not J.IsThereNonSelfCoreNearby(1200)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.GetHP(botTarget) > 0.25
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and nHealth > 0.6
        and not botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and nHealth > 0.7
        and not botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderFireSpiritsLaunch()
    if not J.CanCastAbility(FireSpiritsLaunch)
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = FireSpirits:GetCastRange()
	local nRadius = FireSpirits:GetSpecialValueInt('radius')
    local nSpeed = FireSpirits:GetSpecialValueInt('spirit_speed')
    local nDuration = FireSpirits:GetSpecialValueFloat('burn_duration')
	local nDamage = FireSpirits:GetSpecialValueInt('damage_per_second') * nDuration
    local botTarget = J.GetProperTarget(bot)

    local tAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(tEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not enemyHero:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            local eta = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed)
            local targetLoc = J.GetCorrectLoc(enemyHero, eta)
            local nLocationAoE = bot:FindAoELocation(true, true, targetLoc, nCastRange, nRadius, 0, 0)

            if eta > X.GetModifierTime(enemyHero, 'modifier_phoenix_fire_spirit_burn')
            then
                if nLocationAoE.count >= 2 then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                else
                    return BOT_ACTION_DESIRE_HIGH, targetLoc
                end
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        local target = nil
        local targetAttackDamage = 0
        for _, enemy in pairs(tEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.IsInRange(bot, enemy, nCastRange)
            and J.CanCastOnNonMagicImmune(enemy)
            and not J.IsEnemyChronosphereInLocation(enemy:GetLocation())
            and not J.IsEnemyBlackHoleInLocation(enemy:GetLocation())
            and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemy:HasModifier('modifier_phoenix_fire_spirit_burn') then
                local enemyAttackDamage = enemy:GetAttackDamage() * enemy:GetAttackSpeed()
                if enemyAttackDamage > targetAttackDamage then
                    target = enemy
                    targetAttackDamage = enemyAttackDamage
                end
            end
        end

        if target ~= nil then
            local eta = GetUnitToUnitDistance(bot, target) / nSpeed
            local targetLoc = J.GetCorrectLoc(target, eta)
            local nLocationAoE = bot:FindAoELocation(true, true, targetLoc, nCastRange, nRadius, 0, 0)

            if DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and eta > X.GetModifierTime(target, 'modifier_phoenix_fire_spirit_burn')
            then
                if J.IsInLaningPhase() then
                    for _, ally in pairs(tAllyHeroes) do
                        if J.IsValidHero(ally)
                        and not ally:IsIllusion()
                        and (J.IsAttacking(target) == ally or (J.IsChasingTarget(target, ally)) or target:GetAttackTarget() == ally)
                        then
                            if nLocationAoE.count >= 2 then
                                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                            else
                                return BOT_ACTION_DESIRE_HIGH, targetLoc
                            end
                        end
                    end
                else
                    if nLocationAoE.count >= 2 then
                        return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                    else
                        return BOT_ACTION_DESIRE_HIGH, targetLoc
                    end
                end
            end
        end
    end

    local tEnemyLaneCreeps = bot:GetNearbyLaneCreeps(math.min(nCastRange, 1600), true)
    local vCenterLaneCreeps = J.GetCenterOfUnits(tEnemyLaneCreeps)

    if (J.IsPushing(bot) or J.IsDefending(bot))
    and not J.IsThereNonSelfCoreNearby(1200)
    then
        if #tEnemyLaneCreeps >= 4
        and J.CanBeAttacked(tEnemyLaneCreeps[1])
        and not J.IsRunning(tEnemyLaneCreeps[1])
        and #tEnemyHeroes == 0
        then
            local eta = GetUnitToLocationDistance(bot, vCenterLaneCreeps) / nSpeed
            if DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and eta > X.GetModifierTime(tEnemyLaneCreeps[1], 'modifier_phoenix_fire_spirit_burn') then
                return BOT_ACTION_DESIRE_HIGH, vCenterLaneCreeps
            end
        end
    end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(math.min(nCastRange, 1600))
        local vCenterNeutralCreeps = J.GetCenterOfUnits(nNeutralCreeps)

        if ((#nNeutralCreeps >= 2)
            or (#nNeutralCreeps >= 1 and nNeutralCreeps[1]:IsAncientCreep()))
        and not J.IsRunning(bot)
        then
            local eta = GetUnitToLocationDistance(bot, vCenterNeutralCreeps) / nSpeed
            if DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and eta > X.GetModifierTime(nNeutralCreeps[1], 'modifier_phoenix_fire_spirit_burn') then
                return BOT_ACTION_DESIRE_HIGH, vCenterNeutralCreeps
            end
        end

        if #tEnemyLaneCreeps >= 3
        and J.CanBeAttacked(tEnemyLaneCreeps[1])
        and not J.IsRunning(tEnemyLaneCreeps[1])
        and not J.IsThereNonSelfCoreNearby(1200)
        then
            local eta = GetUnitToLocationDistance(bot, vCenterLaneCreeps) / nSpeed
            if DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and eta > X.GetModifierTime(tEnemyLaneCreeps[1], 'modifier_phoenix_fire_spirit_burn') then
                return BOT_ACTION_DESIRE_HIGH, vCenterLaneCreeps
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.GetHP(botTarget) > 0.25
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            local eta = GetUnitToUnitDistance(bot, botTarget) / nSpeed
            if DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and eta > X.GetModifierTime(botTarget, 'modifier_phoenix_fire_spirit_burn') then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_phoenix_fire_spirit_burn')
        then
            local eta = GetUnitToUnitDistance(bot, botTarget) / nSpeed
            if DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and eta > X.GetModifierTime(botTarget, 'modifier_phoenix_fire_spirit_burn') then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    local tCreeps = bot:GetNearbyCreeps(nCastRange, true)
    if J.IsValid(tCreeps[2])
    and J.CanBeAttacked(tCreeps[2])
    and not J.IsRunning(tCreeps[2]) then
        local nLocationAoE = bot:FindAoELocation(true, false, J.GetCenterOfUnits(tCreeps), nRadius, nRadius, 0, 0)
        if nLocationAoE.count >= 3 then
            local eta = GetUnitToLocationDistance(bot, nLocationAoE.targetloc) / nSpeed
            if DotaTime() > FireSpiritsLaunchTime + eta + 0.25
            and eta > X.GetModifierTime(tCreeps[2], 'modifier_phoenix_fire_spirit_burn') then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderSunRay()
    if not J.CanCastAbility(SunRay)
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    or bot:HasModifier('modifier_phoenix_sun_ray')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, SunRay:GetCastRange())
    local botHP = J.GetHP(bot)

    local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    if J.IsGoingOnSomeone(bot)
    then
        local target = nil
        local targetHP = 99999
        local tInRangeAlly_attacking = J.GetSpecialModeAllies(bot, 900, BOT_MODE_ATTACK)

        for _, enemy in pairs(tEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.IsInRange(bot, enemy, nCastRange * 0.8)
            and J.CanCastOnNonMagicImmune(enemy)
            and not enemy:HasModifier('modifier_abaddon_borrowed_time')
            and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
            and botHP > 0.4 then
                local enemyHP = enemy:GetHealth()
                if enemyHP < targetHP then
                    target = enemy
                    targetHP = enemyHP
                end
            end
        end

        if target ~= nil and #tInRangeAlly_attacking >= 2 then
            bot.sun_ray_engage = true
            bot.sun_ray_target = target
            return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
        end
    end

    local tInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(tInRangeAlly)
    do
        if J.IsValidHero(allyHero)
        and J.IsCore(allyHero)
        and J.GetHP(allyHero) < 0.5
        and allyHero:WasRecentlyDamagedByAnyHero(3.5)
        and not allyHero:IsIllusion()
        and botHP > 0.38
        and not (J.IsRetreating(bot) and J.IsRealInvisible(bot))
        then
            if not J.IsRunning(allyHero)
            or allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or allyHero:HasModifier('modifier_enigma_black_hole_pull') then
                bot.sun_ray_heal_ally = true
                bot.sun_ray_target = allyHero
                return BOT_ACTION_DESIRE_HIGH, allyHero:GetLocation()
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderSunRayStop()
    if not J.CanCastAbility(SunRayStop)
    or bot:HasModifier('modifier_phoenix_icarus_dive')
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local tAllyHeroes = J.GetAlliesNearLoc(bot:GetLocation(), 1600)
	local tEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
    local botHP = J.GetHP(bot)

    if bot.sun_ray_engage then
        if (X.IsBeingAttackedByRealHero(tEnemyHeroes, bot) and botHP < 0.25 and bot:WasRecentlyDamagedByAnyHero(2.0))
        or #tAllyHeroes + 1 < #tEnemyHeroes
        or #tEnemyHeroes == 0
        or #tAllyHeroes == 0 and #tEnemyHeroes == 0
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if bot.sun_ray_heal_ally then
        if (X.IsBeingAttackedByRealHero(tEnemyHeroes, bot) and botHP < 0.25 and bot:WasRecentlyDamagedByAnyHero(2.0))
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if botHP < 0.17 then
        return BOT_ACTION_DESIRE_HIGH
    end

    if math.floor(DotaTime()) % 2 == 0 then
        if J.IsValidHero(bot.sun_ray_target)
        and not bot:IsFacingLocation(bot.sun_ray_target:GetLocation(), 45)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderToggleMovement()
    if not J.CanCastAbility(ToggleMovement)
    or not bot:HasModifier('modifier_phoenix_sun_ray')
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    or bot:IsRooted()
    then
        return BOT_ACTION_DESIRE_NONE, ''
    end

    local nBeamDistance = 1150

    if J.IsValidHero(bot.sun_ray_target) then
        if not J.IsInRange(bot, bot.sun_ray_target, nBeamDistance) then
            if ToggleMovement:GetToggleState() == false then
                return BOT_ACTION_DESIRE_HIGH, 'on'
            end

            return BOT_ACTION_DESIRE_NONE, ''
        end
    end

    if ToggleMovement:GetToggleState() == true then
        return BOT_ACTION_DESIRE_HIGH, 'off'
    end

    return BOT_ACTION_DESIRE_NONE, ''
end

function X.ConsiderSupernova()
    if not J.CanCastAbility(Supernova)
    or bot:HasModifier('modifier_phoenix_supernova_hiding')
    then
        return BOT_ACTION_DESIRE_NONE, nil, false
    end

	local nCastRange = J.GetProperCastRange(false, bot, Supernova:GetCastRange())
	local nRadius = Supernova:GetSpecialValueInt('aura_radius')

    if J.IsInTeamFight(bot, 1200)
	then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), (nRadius / 2) + 250)

        if #nInRangeEnemy >= 2
        then
            if string.find(GetBot():GetUnitName(), 'phoenix') and bot:HasScepter()
            then
                nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
                for _, allyHero in pairs(nInRangeAlly)
                do
                    if J.IsValidHero(allyHero)
                    and not J.IsAttacking(allyHero)
                    and J.GetHP(allyHero) < 0.25
                    and allyHero:WasRecentlyDamagedByAnyHero(3.0)
                    then
                        return BOT_ACTION_DESIRE_HIGH, allyHero, true
                    end
                end
            else
                if not (#nInRangeAlly >= #nInRangeEnemy + 2) then
                    return BOT_ACTION_DESIRE_HIGH, nil, false
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil, false
end

function X.IsBeingAttackedByRealHero(hUnitList, hUnit)
    for _, enemy in pairs(hUnitList)
    do
        if J.IsValidHero(enemy)
        and not J.IsSuspiciousIllusion(enemy)
        and (enemy:GetAttackTarget() == hUnit or J.IsChasingTarget(enemy, hUnit))
        then
            return true
        end
    end

    return false
end

function X.GetModifierTime(unit, sModifierName)
    if unit:HasModifier(sModifierName) then
        return unit:GetModifierRemainingDuration(unit:GetModifierByName(sModifierName))
    else
        return 0
    end
end

return X