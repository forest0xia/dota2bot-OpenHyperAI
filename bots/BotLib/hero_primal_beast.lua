local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						{--pos2
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {10, 0},
                            ['t10'] = {10, 0},
                        },--pos3
                        {
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {0, 10},
                            ['t10'] = {10, 0},
                        }
}

local tAllAbilityBuildList = {
						{2,3,1,2,1,6,2,2,1,1,6,3,3,3,6},--pos2
                        {1,2,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_2"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
else
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sUtility = {"item_pipe", "item_lotus_orb", "item_crimson_guard"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_quelling_blade",
    "item_double_branches",

    "item_bracer",
    "item_bottle",
    "item_boots",
    "item_magic_wand",
    "item_phase_boots",
    "item_eternal_shroud",--
    "item_radiance",--
    "item_shivas_guard",--
    "item_black_king_bar",--
    "item_ultimate_scepter",
    "item_heart",--
    "item_ultimate_scepter_2",
    "item_travel_boots",
    "item_travel_boots_2",--
    "item_moon_shard",
    "item_aghanims_shard",
    "item_kaya_and_sange",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_magic_stick",
    "item_ring_of_protection",

    "item_helm_of_iron_will",
    "item_boots",
    "item_magic_wand",
    "item_phase_boots",
    "item_veil_of_discord",
    "item_eternal_shroud",--
    "item_ultimate_scepter",
    "item_blink",
    "item_shivas_guard",--
    nUtility,--
    "item_black_king_bar",--
    "item_travel_boots",
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--
    "item_aghanims_shard",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos2SellList = {
    "item_bracer",
    "item_bottle",
    "item_magic_wand",
    "item_phase_boots",
    "item_radiance",
}

Pos3SellList = {
	"item_ring_of_protection",
    "item_magic_wand",
    "item_phase_boots",
    "item_radiance",
}

X['sSellList'] = {}

if sRole == "pos_2"
then
    X['sSellList'] = Pos2SellList
else
    X['sSellList'] = Pos3SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Onslaught         = bot:GetAbilityByName('primal_beast_onslaught') -- Q 突
local Trample           = bot:GetAbilityByName('primal_beast_trample') -- W 踏
local Uproar            = bot:GetAbilityByName('primal_beast_uproar') -- E 咤
local RockThrow         = bot:GetAbilityByName('primal_beast_rock_throw') -- D 砸
local Pulverize         = bot:GetAbilityByName('primal_beast_pulverize') -- R 捶

local QDesire, QLocation

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    if bot:IsChanneling() or J.IsCastingUltimateAbility(bot) then return end

    X.ConsiderStopQ()

	QDesire, QLocation = X.ConsiderQ()
    if QDesire > 0
	then
        bot:Action_ClearActions(false)
		bot:Action_UseAbilityOnLocation(Onslaught, QLocation)
		return
	end
    X.ConsiderStopQ()

	WDesire = X.ConsiderW()
    if WDesire > 0
	then
        bot:Action_ClearActions(false)
		bot:Action_UseAbility(Trample)
		return
	end

	EDesire = X.ConsiderE()
    if EDesire > 0
	then
        bot:Action_ClearActions(false)
		bot:Action_UseAbility(Uproar)
		return
	end

	RDesire, RTarget = X.ConsiderR()
    if RDesire > 0
	then
        bot:Action_ClearActions(false)
		bot:Action_UseAbilityOnEntity(Pulverize, RTarget)
		return
	end


end


function X.ConsiderQ()
    if not Onslaught:IsFullyCastable() or bot:IsRooted()
	then
		return BOT_ACTION_DESIRE_NONE, 0, false
	end

	local maxDistance = 2000
    local nDistance = 1500
	local nSpeed = 1200 -- chargeSpeed
	local nKnockBackRadius = Onslaught:GetSpecialValueInt('knockback_radius')
	local nDamage = Onslaught:GetSpecialValueInt('knockback_damage')
	local nMana = bot:GetMana()
    local nDelay = 0.8  -- max_charge_time = 1.7. we always only charge 0.8
    --  bot:Action_ClearActions( true )

    -- 打断技能
	local nEnemyHeroes = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local loc = J.GetCorrectLoc(enemyHero, (GetUnitToUnitDistance(bot, target) / nSpeed) + nDelay)
			return BOT_ACTION_DESIRE_HIGH, loc, true
		end
	end

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nDistance)
	end

	-- 击杀
    local target = J.GetCanBeKilledUnit(nEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
    if target ~= nil
    and not J.IsSuspiciousIllusion(target)
    then
        local loc = J.GetCorrectLoc(target, (GetUnitToUnitDistance(bot, target) / nSpeed) + nDelay)

        if IsStoneInPath(loc, GetUnitToUnitDistance(bot, target))
        then
            return BOT_ACTION_DESIRE_HIGH, loc, false
        else
            return BOT_ACTION_DESIRE_HIGH, loc, true
        end
    end


	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nDistance)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
		then
			local loc = J.GetCorrectLoc(botTarget, nDelay)
			return BOT_ACTION_DESIRE_HIGH, loc, false
		end
	end

	local nInRangeAlly = bot:GetNearbyHeroes(1400, false, BOT_MODE_NONE)
	if J.IsRetreating(bot)
	or (nInRangeAlly ~= nil and nEnemyHeroes ~= nil and #nEnemyHeroes > #nInRangeAlly)
	then
		local nAllyHeroes  = bot:GetNearbyHeroes(math.min(nDistance * 2, 1600), false, BOT_MODE_NONE)
		local location = J.GetEscapeLoc()
		local loc = J.Site.GetXUnitsTowardsLocation(bot, location, nDistance)

		if  nAllyHeroes ~= nil and nEnemyHeroes ~= nil
		and ((#nEnemyHeroes > #nAllyHeroes) or (#nAllyHeroes >= #nEnemyHeroes and J.GetHP(bot) < 0.45))
		then
			return BOT_ACTION_DESIRE_HIGH, loc, false
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0, false
end

function X.ConsiderStopQ()
    if bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable') or bot:IsCastingAbility() then
        
    end
end

function X.ConsiderW()
    if not Trample:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = Trample:GetSpecialValueInt('effect_radius')
    local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
    then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and (J.CanCastOnNonMagicImmune(enemyHero) or #nEnemyHeroes >= 2)
            and J.IsInRange(bot, enemyHero, nRadius)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsRetreating(bot)
    then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nRadius)
            and (J.CanCastOnNonMagicImmune(enemyHero) or #nEnemyHeroes >= 2)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if nEnemyLaneCreeps ~= nil
        then
            if #nEnemyLaneCreeps >= 1
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.2
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if J.GetHP(bot) < 0.2
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
        if nNeutralCreeps ~= nil
        then
            if #nNeutralCreeps >= 1
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.35
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if J.GetHP(bot) < 0.35
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        if nEnemyLaneCreeps ~= nil
        then
            if #nEnemyLaneCreeps >= 1
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.2
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if J.GetHP(bot) < 0.2
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsLaning(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if nEnemyLaneCreeps ~= nil
        and nInRangeEnemy ~= nil and #nInRangeEnemy <= 1
        then
            if #nEnemyLaneCreeps >= 1
            and J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            if J.GetHP(bot) > 0.4
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            if J.GetHP(bot) > 0.4
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderE()
    if not Uproar:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if bot:HasModifier('modifier_pudge_rot')
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsGoingOnSomeone(bot) or J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly <= #nInRangeAlly)
                or (J.GetHP(bot) < 0.7 and bot:WasRecentlyDamagedByAnyHero(2.2)))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderD()

end


function X.ConsiderR()
    if not Pulverize:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Pulverize:GetCastRange())
    local nDuration = Pulverize:GetSpecialValueFloat('channel_time')
    local nDamage = Pulverize:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, true, 5)

		if  J.IsValidTarget(strongestTarget)
		and not J.IsSuspiciousIllusion(strongestTarget)
        and not strongestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not strongestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not strongestTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nTargetInRangeAlly = strongestTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, strongestTarget
            end
		end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local weakestTarget = J.GetAttackableWeakestUnit(bot, nCastRange, true, true)

		if  J.IsValidTarget(weakestTarget)
		and not J.IsSuspiciousIllusion(weakestTarget)
        and not weakestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not weakestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not weakestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not weakestTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nTargetInRangeAlly = weakestTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nTargetInRangeAlly > #nInRangeAlly
            and bot:WasRecentlyDamagedByAnyHero(2)
            then
                return BOT_ACTION_DESIRE_HIGH, weakestTarget
            end
		end
    end

    if J.IsInLaningPhase(bot)
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange + 100, true, BOT_MODE_NONE)
        local nInRangeTower = bot:GetNearbyTowers(700, true)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy == 1
        and nInRangeTower ~= nil and #nInRangeTower == 0
        then
            if  J.IsValidHero(nInRangeEnemy[1])
            and J.WillKillTarget(nInRangeEnemy[1], nDamage, DAMAGE_TYPE_MAGICAL, nDuration)
            and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
            and not nInRangeEnemy[1]:HasModifier('modifier_abaddon_borrowed_time')
            and not nInRangeEnemy[1]:HasModifier('modifier_dazzle_shallow_grave')
            and not nInRangeEnemy[1]:HasModifier('modifier_oracle_false_promise_timer')
            and not nInRangeEnemy[1]:HasModifier('modifier_templar_assassin_refraction_absorb')
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

    return BOT_ACTION_DESIRE_NONE, nil
end

return X