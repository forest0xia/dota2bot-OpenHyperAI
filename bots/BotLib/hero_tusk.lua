local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos4,5
                        ['t25'] = {10, 0},
                        ['t20'] = {0, 10},
                        ['t15'] = {10, 0},
                        ['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,1,2,3,3,6,3,2,2,2,6,1,1,1,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_double_tango",
    "item_faerie_fire",
    "item_wind_lace",

    "item_magic_wand",
    "item_arcane_boots",
    "item_blink",
    "item_guardian_greaves",--
    "item_cyclone",
    "item_ultimate_scepter",
    "item_aghanims_shard",
    "item_black_king_bar",--
    "item_lotus_orb",--
	"item_gungir",--
    "item_wind_waker",--
    -- "item_ultimate_scepter_2",
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_double_tango",
    "item_faerie_fire",
    "item_wind_lace",

    "item_magic_wand",
    "item_tranquil_boots",
    "item_boots_of_bearing",--
    "item_pipe",--
    "item_ultimate_scepter",
    "item_aghanims_shard",
    "item_pavise",
    "item_blink",
    "item_solar_crest",--
	"item_heavens_halberd",--
    "item_lotus_orb",--
	"item_gungir",--
    -- "item_ultimate_scepter_2",
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = {
	"item_tank_outfit",
	"item_echo_sabre",
	"item_crimson_guard",--
	"item_ultimate_scepter",
	"item_heavens_halberd",--
	"item_assault",--
	"item_travel_boots",
	"item_aghanims_shard",
	"item_satanic",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_heart",--
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

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

local IceShards         = bot:GetAbilityByName('tusk_ice_shards')
local Snowball          = bot:GetAbilityByName('tusk_snowball')
local LaunchSnowball    = bot:GetAbilityByName('tusk_launch_snowball')
local TagTeam           = bot:GetAbilityByName('tusk_tag_team')
local WalrusKick        = bot:GetAbilityByName('tusk_walrus_kick')
local WalrusPunch       = bot:GetAbilityByName('tusk_walrus_punch')
local DrinkingBuddies   = bot:GetAbilityByName('tusk_drinking_buddies')

local IceShardsDesire, IceShardsLocation
local SnowballDesire, SnowballTarget
local LaunchSnowballDesire
local TagTeamDesire
local WalrusKickDesire, WalrusKickTarget
local WalrusPunchDesire, WalrusPunchTarget
local DrinkingBuddiesDesire, DrinkingBuddiesTarget

local botTarget

if bot.snowballHeroRetreat then bot.snowballHeroRetreat = false end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    TagTeamDesire = X.ConsiderTagTeam()
    if TagTeamDesire > 0
    then
        bot:Action_UseAbility(TagTeam)
        return
    end

    DrinkingBuddiesDesire, DrinkingBuddiesTarget = X.ConsiderDrinkingBuddies()
    if DrinkingBuddiesDesire > 0 then
        bot:Action_UseAbilityOnEntity(DrinkingBuddies, DrinkingBuddiesTarget)
        return
    end

    IceShardsDesire, IceShardsLocation = X.ConsiderIceShards()
    if IceShardsDesire > 0
    then
        bot:Action_UseAbilityOnLocation(IceShards, IceShardsLocation)
        return
    end

    LaunchSnowballDesire = X.ConsiderLaunchSnowball()
    if LaunchSnowballDesire > 0
    then
        bot:Action_UseAbility(LaunchSnowball)
        bot.snowballHeroRetreat = false
        return
    end

    SnowballDesire, SnowballTarget = X.ConsiderSnowball()
    if SnowballDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Snowball, SnowballTarget)
        return
    end

    -- WalrusKickDesire, WalrusKickTarget = X.ConsiderWalrusKick()

    WalrusPunchDesire, WalrusPunchTarget = X.ConsiderWalrusPunch()
    if WalrusPunchDesire > 0
    then
        bot:Action_UseAbilityOnEntity(WalrusPunch, WalrusPunchTarget)
        return
    end
end

function X.ConsiderIceShards()
    if not IceShards:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, IceShards:GetCastRange())
	local nCastPoint = IceShards:GetCastPoint()
    local nRadius = IceShards:GetSpecialValueInt('shard_width')
	local nDamage = IceShards:GetSpecialValueInt('shard_damage')
	local nSpeed = IceShards:GetSpecialValueInt('shard_speed')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local eta =  (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint + 2
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(eta)
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and not J.IsLocationInChrono(nLocationAoE.targetloc)
        and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsChasingTarget(bot, botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_legion_commander_duel')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                local eta =  (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint + 2
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(eta)
            end
		end
	end

    -- if J.IsRetreating(bot)
    -- then
    --     local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
    --     local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

    --     if nInRangeAlly ~= nil and nInRangeEnemy
    --     and J.IsValidHero(nInRangeEnemy[1])
    --     and J.IsChasingTarget(nInRangeEnemy[1], bot)
    --     and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
    --     and not J.IsDisabled(nInRangeEnemy[1])
    --     and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
    --     and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
    --     and not nInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
    --     and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
    --     then
    --         local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

    --         if nTargetInRangeAlly ~= nil
    --         and ((#nTargetInRangeAlly > #nInRangeAlly)
    --             or bot:WasRecentlyDamagedByAnyHero(2))
    --         then
    --             local eta = ((GetUnitToUnitDistance(bot, nInRangeEnemy[1])) / nSpeed) + nCastPoint + 2
	-- 	        return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetExtrapolatedLocation(eta)
    --         end
    --     end
    -- end

    if J.IsLaning(bot) or J.IsPushing(bot)
    and not J.IsThereNonSelfCoreNearby(1200)
	then
        if not J.IsInLaningPhase()
        then
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

-- no alt-cast support from the api
function X.ConsiderDrinkingBuddies()
    if not J.CanCastAbility(DrinkingBuddies) then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, DrinkingBuddies:GetCastRange())
    local nAllyHeroes = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)

    local hTarget = nil
	local nMaxDamage = 0
    for _, allyHero in pairs(nAllyHeroes) do
        if allyHero ~= bot and J.IsValidHero(allyHero) and not allyHero:IsIllusion() then
            if J.IsStuck(bot) or J.IsStuck(allyHero) then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end

            if J.IsDoingRoshan(bot)
            then
                if  J.IsRoshan(botTarget)
                and J.CanBeAttacked(botTarget)
                and J.IsInRange(bot, botTarget, 500)
                and J.IsAttacking(bot)
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end

            if J.IsDoingTormentor(bot)
            then
                if  J.IsTormentor(botTarget)
                and J.IsInRange(bot, botTarget, 500)
                and J.IsAttacking(bot)
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end

            if not J.IsDisabled(allyHero)
            and (not J.IsWithoutTarget(allyHero))
            and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not allyHero:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
            then
                local nDamage = allyHero:GetAttackDamage() * allyHero:GetAttackSpeed()
                if nDamage > nMaxDamage then
                    hTarget = allyHero
                    nMaxDamage = nDamage
                end
            end
        end
    end

    if J.IsGoingOnSomeone(bot) and hTarget ~= nil then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 1000)
        and J.CanBeAttacked(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local bBotChasing = J.IsChasingTarget(bot, botTarget)
            local bAllyChasing = J.IsChasingTarget(hTarget, botTarget)
            local distbotToTarget = GetUnitToUnitDistance(bot, botTarget)
            local distAllyToTarget = GetUnitToUnitDistance(hTarget, botTarget)
            if (not bBotChasing or (bBotChasing and bAllyChasing and distAllyToTarget < distbotToTarget and distAllyToTarget < 500))
            then
                return BOT_ACTION_DESIRE_HIGH, hTarget
            end
		end
	end

    local nEnemyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

    if J.IsRetreating(bot)
	and not J.IsRealInvisible(bot)
	and not bot:HasModifier('modifier_fountain_aura_buff')
    and #nAllyHeroes > 1
	then
        for _, enemyHero in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, 800)
            and J.IsChasingTarget(enemyHero, bot)
            then
                if (bot:WasRecentlyDamagedByAnyHero(3.0) and not J.IsSuspiciousIllusion(enemyHero))
                or (#nAllyHeroes + 2 <= #nEnemyHeroes)
                then
                    for _, allyHero in pairs(nAllyHeroes) do
                        if allyHero ~= bot
                        and J.IsValidHero(allyHero)
                        and not allyHero:IsIllusion()
                        and J.IsRetreating(allyHero)
                        and GetUnitToUnitDistance(allyHero, enemyHero) > GetUnitToUnitDistance(bot, enemyHero)
                        and GetUnitToLocationDistance(enemyHero, ((bot:GetLocation() + allyHero:GetLocation()) / 2)) > 500
                        then
                            return BOT_ACTION_DESIRE_HIGH, allyHero
                        end
                    end
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSnowball()
    if not Snowball:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Snowball:GetCastRange())
    local nDuration = Snowball:GetSpecialValueFloat('snowball_duration')

	if J.IsGoingOnSomeone(bot)
	then
		local strongestTarget = nil
		local dmg = 0

		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_legion_commander_duel')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				local currDmg = enemyHero:GetEstimatedDamageToTarget(false, bot, nDuration, DAMAGE_TYPE_ALL)
				if currDmg > dmg
				then
					dmg = currDmg
					strongestTarget = enemyHero
				end
			end
		end

		if strongestTarget ~= nil
		then
            local nInRangeAlly = J.GetNearbyHeroes(strongestTarget, 1200, true, BOT_MODE_NONE)
            nInRangeEnemy = J.GetNearbyHeroes(strongestTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, strongestTarget
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
        local targetCreep = nil
        local dist = 0

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeEnemy > #nInRangeAlly
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, 600)
                and J.IsChasingTarget(enemyHero, bot)
                and bot:WasRecentlyDamagedByHero(enemyHero, 1.5)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                then
                    local nCreeps = bot:GetNearbyCreeps(nCastRange, true)
                    for _, creep in pairs(nCreeps)
                    do
                        if J.IsValid(creep)
                        and GetUnitToLocationDistance(creep, GetAncient(GetTeam()):GetLocation()) < GetUnitToLocationDistance(bot, GetAncient(GetTeam()):GetLocation())
                        and GetUnitToUnitDistance(bot, creep) > nCastRange / 2
                        and dist > GetUnitToUnitDistance(bot, creep)
                        then
                            dist = GetUnitToUnitDistance(bot, creep)
                            targetCreep = creep
                        end
                    end
                end
            end

            if targetCreep ~= nil
            then
                return BOT_ACTION_DESIRE_HIGH, targetCreep
            end

            nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, 600)
                and J.IsChasingTarget(enemyHero, bot)
                and bot:WasRecentlyDamagedByHero(enemyHero, 1.5)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
                and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not enemyHero:HasModifier('modifier_legion_commander_duel')
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    bot.snowballHeroRetreat = true
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderLaunchSnowball()
    if LaunchSnowball:IsHidden()
    or not LaunchSnowball:IsFullyCastable()
    or bot.snowballHeroRetreat
    then
        return BOT_ACTION_DESIRE_NONE
    end

    return BOT_ACTION_DESIRE_HIGH
end

function X.ConsiderTagTeam()
    if not J.CanCastAbility(TagTeam) then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = TagTeam:GetSpecialValueInt('radius')

	if J.IsInTeamFight(bot, 1200)
	then
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_legion_commander_duel')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,600, false, BOT_MODE_NONE)

        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and nInRangeAlly ~= nil and #nInRangeAlly >= 2
        and J.IsAttacking(nInRangeAlly[1])
        and J.IsAttacking(nInRangeAlly[2])
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderWalrusPunch()
    if not WalrusPunch:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, WalrusPunch:GetCastRange())

    if J.IsGoingOnSomeone(bot)
	then
		local strongestTarget = nil
		local dmg = 0

		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidHero(enemyHero)
            and J.CanCastOnMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_legion_commander_duel')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
			then
				local currDmg = enemyHero:GetEstimatedDamageToTarget(false, bot, 4, DAMAGE_TYPE_ALL)
				if currDmg > dmg
				then
					dmg = currDmg
					strongestTarget = enemyHero
				end
			end
		end

		if strongestTarget ~= nil
		then
            return BOT_ACTION_DESIRE_HIGH, strongestTarget
		end
	end

    if J.IsDoingRoshan(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,600, false, BOT_MODE_NONE)

        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and nInRangeAlly ~= nil and #nInRangeAlly >= 2
        and J.IsAttacking(nInRangeAlly[1])
        and J.IsAttacking(nInRangeAlly[2])
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X