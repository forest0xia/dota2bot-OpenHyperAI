local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local U = require(GetScriptDirectory()..'/FunLib/minion_lib/utils')

local X = {}
local bot

local nLanes = {
    LANE_TOP,
    LANE_MID,
    LANE_BOT,
}

function X.Think(ownerBot, hMinionUnit)
    if not U.IsValidUnit(hMinionUnit) then return end

    bot = ownerBot
    bot.illusionThink = bot.illusionThink or {attack_desire = 0, attack_target = nil, move_desire = 0, move_location = nil, time = 0}
    if DotaTime() - bot.illusionThink.time < 0.5 then
        if bot.illusionThink.attack_desire > 0 and U.IsValidUnit(bot.illusionThink.attack_target) then
            hMinionUnit:Action_AttackUnit(bot.illusionThink.attack_target, true)
            return
        end
        if bot.illusionThink.move_desire > 0 and bot.illusionThink.move_location then
            hMinionUnit:Action_MoveToLocation(bot.illusionThink.move_location)
            return
        end
        return
    end

	hMinionUnit.attack_desire, hMinionUnit.attack_target = X.ConsiderAttack(hMinionUnit)
    if hMinionUnit.attack_desire > 0
    then
        if U.IsValidUnit(hMinionUnit.attack_target)
        then
            if not J.CanBeAttacked(hMinionUnit.attack_target)
            and (not bot:IsAlive()
                or (bot:IsAlive() and bot:GetAttackTarget() ~= hMinionUnit.attack_target))
            then
                local loc = J.Site.GetXUnitsTowardsLocation(GetAncient(GetTeam()), hMinionUnit.attack_target:GetLocation(), 600)
                hMinionUnit:Action_MoveToLocation(loc)
                bot.illusionThink.move_desire = BOT_ACTION_DESIRE_HIGH
                bot.illusionThink.move_location = loc
                bot.illusionThink.time = DotaTime()
                return
            else
                hMinionUnit:Action_AttackUnit(hMinionUnit.attack_target, true)
                bot.illusionThink.attack_desire = BOT_ACTION_DESIRE_HIGH
                bot.illusionThink.attack_target = hMinionUnit.attack_target
                bot.illusionThink.time = DotaTime()
                return
            end
        end
    end

    hMinionUnit.move_desire, hMinionUnit.move_location = X.ConsiderMove(hMinionUnit)
	if hMinionUnit.move_desire > 0
	then
		hMinionUnit:Action_MoveToLocation(hMinionUnit.move_location)
		bot.illusionThink.move_desire = BOT_ACTION_DESIRE_HIGH
		bot.illusionThink.move_location = hMinionUnit.move_location
		bot.illusionThink.time = DotaTime()
		return
	end

    -- Default
    if bot:IsAlive()
    then
        local vFaceEndLocation = J.GetFaceTowardDistanceLocation(bot, 450)
        hMinionUnit:Action_MoveToLocation(vFaceEndLocation)
        bot.illusionThink.move_desire = BOT_ACTION_DESIRE_HIGH
        bot.illusionThink.move_location = vFaceEndLocation
        bot.illusionThink.time = DotaTime()
        return
    else
        local vLoc = GetLaneFrontLocation(GetTeam(), LANE_MID, 0)
        hMinionUnit:Action_MoveToLocation(vLoc)
        bot.illusionThink.move_desire = BOT_ACTION_DESIRE_HIGH
        bot.illusionThink.move_location = vLoc
        bot.illusionThink.time = DotaTime()
        return
    end
end

function X.ConsiderAttack(hMinionUnit)
	if U.CantAttack(hMinionUnit)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local target = X.GetAttackTarget(hMinionUnit)

	if target ~= nil and not U.IsNotAllowedToAttack(target)
	then
		return BOT_ACTION_DESIRE_HIGH, target
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.GetAttackTarget(hMinionUnit)
	local target = nil
    local hMinionUnitName = hMinionUnit:GetUnitName()

	if bot:HasModifier('modifier_bane_nightmare') and not bot:IsInvulnerable()
    and GetUnitToUnitDistance(bot, hMinionUnit) < 2000
    then
        target = bot
    end

    if J.IsInLaningPhase()
    then
        if (string.find(hMinionUnitName, 'forge_spirit')
            or string.find(hMinionUnitName, 'eidolon')
            or string.find(hMinionUnitName, 'beastmaster_boar')
            or string.find(hMinionUnitName, 'lycan_wolf')
        )
        and U.IsTargetedByTower(hMinionUnit)
        then
            return nil
        end
    end

    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if J.IsValidHero(ally)
        and ally:IsAlive()
        and not ally:IsIllusion()
        -- and J.GetHP(ally) > 0.4
        and ally:HasModifier('modifier_bane_nightmare')
        and (GetUnitToUnitDistance(hMinionUnit, ally) <= hMinionUnit:GetAttackRange()
            or (hMinionUnit:GetCurrentMovementSpeed() and hMinionUnit:GetCurrentMovementSpeed() > 250 and GetUnitToUnitDistance(hMinionUnit, ally) < math.min(hMinionUnit:GetAttackRange() * 1.5, 700)))
        then
            return ally
        end
    end

    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMIES))
    do
        if J.IsValid(enemy)
        then
            local enemyName = enemy:GetUnitName()
            local specialUnits = J.GetSpecialUnits()

            if specialUnits[enemyName]
            and enemy:GetTeam() ~= hMinionUnit:GetTeam()
            and GetUnitToUnitDistance(hMinionUnit, enemy) <= specialUnits[enemyName] * 1600
            and RandomInt(0, 100) <= specialUnits[enemyName] * 100
            then
                return enemy
            end
        end
    end

    if GetUnitToUnitDistance(bot, hMinionUnit) < 1600
    then
        target = bot:GetAttackTarget()
    else
        target = nil
    end

	if target == nil or J.IsRetreating(bot)
	then
		target = U.GetWeakestHero(1600, hMinionUnit)
		if target == nil then target = U.GetWeakestCreep(1600, hMinionUnit) end
		if target == nil then target = U.GetWeakestTower(1600, hMinionUnit) end
	end

    if target ~= nil
    then
        if not target:IsBuilding()
        and not target:IsTower()
        and target ~= GetAncient(GetOpposingTeam())
        and X.IsTargetUnderEnemyTower(hMinionUnit, target, 1600)
        then
            if string.find(hMinionUnitName, 'warlock_golem')
            then
                local nDamage = hMinionUnit:GetAttackDamage()
                if J.IsChasingTarget(hMinionUnit, target)
                and not J.WillKillTarget(target, nDamage, DAMAGE_TYPE_PHYSICAL, 6.0)
                then
                    return bot:GetAttackTarget()
                end
            end

            if J.GetHP(target) > 0.25
            and bot:IsAlive()
            and not J.IsChasingTarget(bot, target)
            then
                return bot:GetAttackTarget()
            end
        end
    end

	return target
end

function X.ConsiderMove(hMinionUnit)
	if J.CanNotUseAction(hMinionUnit) or U.CantMove(hMinionUnit) then return BOT_MODE_DESIRE_NONE, nil end

    -- Have Naga or TB farm lanes
    local hMinionUnitName = hMinionUnit:GetUnitName()
    if string.find(hMinionUnitName, 'terrorblade')
    or string.find(hMinionUnitName, 'naga_siren')
    then
        for i = 1, #nLanes
        do
            local laneFrontLoc = J.GetClosestTeamLane(hMinionUnit)
            if not X.IsMinionInLane(hMinionUnit, nLanes[i])
            then
                laneFrontLoc = GetLaneFrontLocation(GetTeam(), nLanes[i], 0)
            end

            if not J.IsInLaningPhase()
            -- and GetUnitToLocationDistance(hMinionUnit, laneFrontLoc) <= 2500
            then
                hMinionUnit.to_farm_lane = nLanes[i]
                return BOT_ACTION_DESIRE_HIGH, laneFrontLoc
            end
        end
    end

    if GetUnitToUnitDistance(bot, hMinionUnit) > 1600
    or not bot:IsAlive()
    or bot:HasModifier('modifier_teleporting')
    then
        local nTeamFightLocation = J.GetTeamFightLocation(hMinionUnit)
        if nTeamFightLocation and GetUnitToLocationDistance(hMinionUnit, nTeamFightLocation) < 2200
        then
            return BOT_ACTION_DESIRE_HIGH, nTeamFightLocation
        end

        return BOT_ACTION_DESIRE_HIGH, J.GetClosestTeamLane(hMinionUnit)
    else
        return BOT_ACTION_DESIRE_HIGH, bot:GetLocation() + RandomVector(150)
    end
end

function X.IsTargetUnderEnemyTower(hMinionUnit, unit, nRange)
    local nEnemyTowers = hMinionUnit:GetNearbyTowers(nRange, true)
    if nEnemyTowers ~= nil and #nEnemyTowers > 0
    and J.IsValidBuilding(nEnemyTowers[1])
    and U.IsValidUnit(unit)
    and J.IsInRange(unit, nEnemyTowers[1], 880)
    then
        return true
    end

    return false
end

function X.IsMinionInLane(hMinionUnit, lane)
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
        if J.IsValid(ally)
        and hMinionUnit ~= ally
        and ally:IsIllusion()
        and string.find(bot:GetUnitName(), ally:GetUnitName())
        then
            if ally.to_farm_lane == lane
            or GetUnitToLocationDistance(ally, GetLaneFrontLocation(GetTeam(), lane, 0)) < 1600
            then
                return true
            end
        end
    end

    return false
end

return X
