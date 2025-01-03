local Push = {}
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local ShouldNotPushLane = false
local LanePushCooldown = 0
local LanePush = LANE_MID

local GlyphDuration = 7
local ShoulNotPushTower = false
local TowerPushCooldown = 0
local StartToPushTime = 16 * 60 -- after x mins, start considering to push.
local PushDuration = 4.5 * 60 -- keep pushing for x mins.
local PushGapMinutes = 6 -- only push once in x mins.
local lastPushTime = 0
local teamAveLvl = 0
local enemyTeamAveLvl = 0
local nEffctiveEnemyHeroesNearPushLoc = 0

local pingTimeDelta = 5
local targetBuilding = nil
local weAreStronger = false
local nInRangeAlly, nInRangeEnemy = {}, {}

function Push.GetPushDesire(bot, lane)
    local botName = bot:GetUnitName()
	if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return BOT_MODE_DESIRE_NONE end

    if bot.laneToPush == nil then bot.laneToPush = lane end

    targetBuilding = nil
    local nMaxDesire = 0.93
	local nSearchRange = 2000
    local nModeDesire = bot:GetActiveModeDesire()
    nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nSearchRange)
    nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nSearchRange)
    local laneFront = GetLaneFrontLocation(GetTeam(), lane, 0)
    local distanceToLaneFront = GetUnitToLocationDistance(bot, laneFront)
    local lEnemyHeroesAroundLoc = J.GetLastSeenEnemiesNearLoc(laneFront, nSearchRange)
    nEffctiveEnemyHeroesNearPushLoc = #lEnemyHeroesAroundLoc + #J.Utils.GetAllyIdsInTpToLocation(laneFront, nSearchRange)

	teamAveLvl = J.GetAverageLevel( false )
	enemyTeamAveLvl = J.GetAverageLevel( true )

    -- do not push too early.
    local currentTime = DotaTime()
    if GetGameMode() == 23 then
        currentTime = currentTime * 2
    end

    if (bot:GetAssignedLane() ~= lane and J.GetPosition(bot) == 1 and currentTime < 10 * 60 and #nInRangeAlly < 3 and distanceToLaneFront > 4000)
    or (J.IsDoingRoshan(bot) and #J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), nSearchRange) >= 3)
    then
        return BOT_MODE_DESIRE_NONE
    end

    -- 如果不在当前线上，且等级低，不推进
    local botLevel = bot:GetLevel()
    if bot:GetAssignedLane() ~= lane
    and distanceToLaneFront > 3000
    and (J.GetPosition(bot) == 1 and botLevel < 6
    or J.GetPosition(bot) == 2 and botLevel < 6
    or J.GetPosition(bot) == 3 and botLevel < 5
    or J.GetPosition(bot) == 4 and botLevel < 4
    or J.GetPosition(bot) == 5 and botLevel < 4)
    then
        return BOT_MODE_DESIRE_NONE
    end

    local nInRangeAlly_core = {}
    for _, ally in pairs(nInRangeAlly) do
        if J.IsValidHero(ally) and J.IsCore(ally) then
            table.insert(nInRangeAlly_core, ally)
        end
    end
    local nInRangeEnemy_core = {}
    for _, enemy in pairs(nInRangeEnemy) do
        if J.IsValidHero(enemy) and J.IsCore(enemy) then
            table.insert(nInRangeEnemy_core, enemy)
        end
    end
    if #nInRangeAlly < #nInRangeEnemy and #nInRangeAlly_core < #nInRangeEnemy_core then
        return BOT_MODE_DESIRE_NONE
    end

    local nH, _ = J.Utils.NumHumanBotPlayersInTeam(GetOpposingTeam())
    if nH > 0 then
        if currentTime <= StartToPushTime
        then
            return BOT_MODE_DESIRE_NONE
        end
    end
    if teamAveLvl < 5 then return BOT_MODE_DESIRE_NONE end

	if J.IsDefending(bot) and nModeDesire >= 0.8
    then
        nMaxDesire = 0.75
    end

    local human, humanPing = J.GetHumanPing()
	if human ~= nil and DotaTime() > pingTimeDelta
	then
		local isPinged, pingedLane = J.IsPingCloseToValidTower(GetOpposingTeam(), humanPing)
		if isPinged and lane == pingedLane
		and DotaTime() < humanPing.time + pingTimeDelta
		then
			return BOT_ACTION_DESIRE_ABSOLUTE * 0.95
		end
	end

    if ShoulNotPushTower
    then
        if DotaTime() < TowerPushCooldown + GlyphDuration
        then
            return BOT_ACTION_DESIRE_NONE
        else
            ShoulNotPushTower = false
            TowerPushCooldown = 0
        end
    end

    if ShouldNotPushLane
    then
        if DotaTime() < LanePushCooldown + 10
        then
            if LanePush == lane then
                return BOT_MODE_DESIRE_NONE
            end
        else
            ShouldNotPushLane = false
            LanePushCooldown = 0
        end
    end

    local aAliveCount = J.GetNumOfAliveHeroes(false)
    local eAliveCount = J.GetNumOfAliveHeroes(true)
    local allyKills = J.GetNumOfTeamTotalKills(false) + 1
    local enemyKills = J.GetNumOfTeamTotalKills(true) + 1
    local aAliveCoreCount = J.GetAliveCoreCount(false)
    local eAliveCoreCount = J.GetAliveCoreCount(true)
    local nPushDesire = GetPushLaneDesire(lane)
    local hEnemyAncient = GetAncient(GetOpposingTeam())
    -- local teamHasAegis = J.DoesTeamHaveAegis()
    local nMissingEnemyHeroes = J.Utils.CountMissingEnemyHeroes()
    local teamKillsRatio = allyKills / enemyKills
    local distanceToEnemyAncient = GetUnitToUnitDistance(bot, hEnemyAncient)
	weAreStronger = J.WeAreStronger(bot, nSearchRange)

    local teamAncientLoc = GetAncient(GetTeam()):GetLocation()
    local nEffctiveAllyHeroesNearAncient = #J.GetAlliesNearLoc(teamAncientLoc, 4500) + #J.Utils.GetAllyIdsInTpToLocation(teamAncientLoc, 4500)
	local nEnemyUnitsAroundAncient = J.GetEnemiesAroundLoc(teamAncientLoc, 4500)
    if nEnemyUnitsAroundAncient > 0 and nEffctiveAllyHeroesNearAncient < 1
    then
        nMaxDesire = 0.75
    end
    if nEffctiveAllyHeroesNearAncient >= 1 then
        nPushDesire = nPushDesire * 0.5
    end

    if J.IsValidBuilding(hEnemyAncient)
    and J.CanBeAttacked(hEnemyAncient)
    and distanceToEnemyAncient < nSearchRange
    then
        return BOT_MODE_DESIRE_HIGH - 0.01
    end
    local fEnemyLaneFrontAmount = GetLaneFrontAmount(GetOpposingTeam(), lane, true)
    if fEnemyLaneFrontAmount < 0.25 and distanceToEnemyAncient > 3500 then
        return BOT_MODE_DESIRE_HIGH - 0.01
    end
    local vEnemyLaneFrontLocation = GetLaneFrontLocation(GetOpposingTeam(), lane, 0)

    -- 如果有重要物品或技能在cd，且敌人英雄数量大于我方英雄数量，则不上高
    if nPushDesire > 0.7
    and Push.ShouldWaitForImportantItemsSpells(vEnemyLaneFrontLocation)
    and (eAliveCount >= aAliveCount or (eAliveCount >= aAliveCount - 2 and eAliveCoreCount >= aAliveCoreCount))
    and teamAveLvl < enemyTeamAveLvl
    and distanceToEnemyAncient < 5500
    then
        return BOT_MODE_DESIRE_VERYLOW
    end

    local botTarget = bot:GetAttackTarget()
    if J.IsValidBuilding(botTarget)
    then
        if botTarget:HasModifier('modifier_fountain_glyph')
        and not (aAliveCount >= eAliveCount + 2)
        then
            ShoulNotPushTower = true
            TowerPushCooldown = DotaTime()
            return RemapValClamped(J.GetHP(bot), 0.1, 0.6, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
        end

        if botTarget:HasModifier('modifier_backdoor_protection')
        or botTarget:HasModifier('modifier_backdoor_protection_in_base')
        or botTarget:HasModifier('modifier_backdoor_protection_active')
        then
            return RemapValClamped(J.GetHP(bot), 0.1, 0.6, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
        end
    end

    if distanceToEnemyAncient < nSearchRange * 0.8
    and J.CanBeAttacked(hEnemyAncient)
    and not bot:WasRecentlyDamagedByAnyHero(1)
    and J.GetHP(bot) > 0.5
    and not (hEnemyAncient:HasModifier('modifier_backdoor_protection')
        or hEnemyAncient:HasModifier('modifier_backdoor_protection_in_base')
        or hEnemyAncient:HasModifier('modifier_backdoor_protection_active'))
    then
        bot:SetTarget(hEnemyAncient)
        bot:Action_AttackUnit(hEnemyAncient, true)
        return BOT_ACTION_DESIRE_ABSOLUTE * 0.98
    end

    if bot:WasRecentlyDamagedByTower(3) and Push.IsInDangerWithinTower(bot, 0.4, 5.0)
    then
        return BOT_MODE_DESIRE_NONE
    end

    local nAroundEnemyLaneFrontAlly = #J.GetAlliesNearLoc(vEnemyLaneFrontLocation, nSearchRange)
    if GetUnitToLocationDistance(bot, vEnemyLaneFrontLocation) > nSearchRange then
        nAroundEnemyLaneFrontAlly = nAroundEnemyLaneFrontAlly + 1
    end
    local nAroundEnemyLaneFrontEnemy = #J.Utils.GetLastSeenEnemyIdsNearLocation(vEnemyLaneFrontLocation, nSearchRange)
    if nAroundEnemyLaneFrontAlly < nAroundEnemyLaneFrontEnemy
    or (J.Utils.GetNearbyAllyAverageHpPercent(bot, 1400) < 0.5 and nAroundEnemyLaneFrontEnemy > 0 and #nInRangeAlly < eAliveCount)
    then
        ShouldNotPushLane = true
        LanePushCooldown = DotaTime()
        LanePush = lane
        return BOT_MODE_DESIRE_NONE
    end

    -- 应该攻击建筑物而不是英雄
    if J.Utils.IsNearEnemyHighGroundTower(bot, 1000) then
        if J.IsValidHero(botTarget)
        and (eAliveCount >= 2 or #nInRangeAlly < eAliveCount)
        and (teamAveLvl - enemyTeamAveLvl < 2 or J.Utils.IsAnyBarracksOnLaneAlive(true, lane))
        and (J.GetHP(bot) < 0.7 and J.GetHP(bot) < J.GetHP(botTarget) or not J.CanKillTarget(botTarget, bot:GetAttackDamage() * 3, DAMAGE_TYPE_PHYSICAL))
        and not J.IsInRange(bot, botTarget, bot:GetAttackRange() - 50)
        then
            targetBuilding = J.Utils.GetClosestTowerOrBarrackToAttack(bot)
            if targetBuilding then
                bot:SetTarget(targetBuilding)
                return BOT_MODE_DESIRE_ABSOLUTE * 1.2
            end
        end
    end

    local pushLaneFront, pushLane = Push.WhichLaneToPush(bot)
    local distantToPushFront = GetUnitToLocationDistance(bot, pushLaneFront)
    local pushLaneFrontToEnemyAncient = GetUnitToLocationDistance(GetAncient( GetOpposingTeam() ), pushLaneFront)
    local maxDistanceFromPushFront = 5500
    local bNearbyHeroesMoreThanEnemy = #nInRangeAlly >= #nInRangeEnemy and #nInRangeAlly >= nEffctiveEnemyHeroesNearPushLoc + nMissingEnemyHeroes - 2
    if nH > 0 and J.Customize.Force_Group_Push_Level < 2 and pushLaneFrontToEnemyAncient > 4500 and weAreStronger then
        -- 前中期推进
        if teamAveLvl < 12 or (teamAveLvl < 15 and distantToPushFront > maxDistanceFromPushFront) then
            if bNearbyHeroesMoreThanEnemy then
                if distanceToLaneFront < 3000 and (not bot:WasRecentlyDamagedByAnyHero(2) or not bot:WasRecentlyDamagedByTower(2)) then
                    local nDistance, cTower = J.Utils.GetDistanceToCloestEnemyTower(bot)
                    if cTower and nDistance < 6000 then
                        nPushDesire = RemapValClamped(J.GetHP(bot), 0.1, 0.8, BOT_MODE_DESIRE_NONE, nMaxDesire)
                        bot.laneToPush = lane
                        return nPushDesire
                    end
                end
            end
        elseif J.GetCoresAverageNetworth() < 22000
        and (teamKillsRatio > 0.6 or teamAveLvl > enemyTeamAveLvl)
        and (teamAveLvl < 16 and distantToPushFront > maxDistanceFromPushFront)
        then
            if bNearbyHeroesMoreThanEnemy then
                if distanceToLaneFront < 3000 and (not bot:WasRecentlyDamagedByAnyHero(2) or not bot:WasRecentlyDamagedByTower(2)) then
                    local nDistance, cTower = J.Utils.GetDistanceToCloestEnemyTower(bot)
                    if cTower and nDistance < 6000 then
                        nPushDesire = RemapValClamped(J.GetHP(bot), 0.1, 0.8, BOT_MODE_DESIRE_NONE, nMaxDesire)
                        bot.laneToPush = lane
                        return nPushDesire
                    end
                end
            end
        end
        return RemapValClamped(J.GetHP(bot), 0.1, 0.8, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_LOW)
    end

    if nH > 0 and J.Customize.Force_Group_Push_Level < 2 and J.GetDistanceFromAllyFountain( bot ) < J.GetDistanceFromEnemyFountain(bot) - 1000 then
        return nPushDesire
    end

    if J.Customize.Force_Group_Push_Level < 3 and distanceToLaneFront < 3000 and weAreStronger then
        -- priority to push the lane with no ally barracks
        if bNearbyHeroesMoreThanEnemy then
            if not J.Utils.IsAnyBarracksOnLaneAlive(false, lane) or J.GetDistanceFromAllyFountain(bot) < 2000 then
                nPushDesire = RemapValClamped(J.GetHP(bot), 0.1, 0.8, BOT_MODE_DESIRE_NONE, nMaxDesire)
                bot.laneToPush = lane
                return nPushDesire
            end
        end
    end

    -- General Push
    if pushLane == lane
    or (J.Customize.Force_Group_Push_Level < 3 and #nInRangeEnemy > eAliveCoreCount and teamAveLvl > enemyTeamAveLvl and aAliveCount >= eAliveCount and distanceToLaneFront < 3000)
    then
        if eAliveCount == 0
        or aAliveCoreCount >= eAliveCoreCount
        or (aAliveCoreCount >= 1 and aAliveCount >= eAliveCount + 2)
        then
            if J.DoesTeamHaveAegis()
            then
                local aegis = 1.3
                nPushDesire = nPushDesire * aegis
            end

            if aAliveCount >= eAliveCount
            and J.GetAverageLevel(GetTeam()) >= 12
            then
                nPushDesire = nPushDesire + RemapValClamped(allyKills / enemyKills, 1, 2, 0.0, 1)
            end

            bot.laneToPush = lane
            nPushDesire = Clamp(nPushDesire, 0, nMaxDesire)
        end
    else
        nPushDesire = BOT_MODE_DESIRE_VERYLOW
    end

	-- 如果离进攻点位近，且有敌方英雄，或我方不强，则降低欲望
	if ((distanceToLaneFront < 1200 or GetUnitToLocationDistance(bot, vEnemyLaneFrontLocation) < 800) and #nInRangeEnemy >= 1)
    or not weAreStronger then
		-- 1. if we are not stronger, most likely defend == feed
		-- 2. we dont want to get stuck in defend mode too much because other modes are also important after bots arrive the location.
		nPushDesire = RemapValClamped(nPushDesire, 0, 1, BOT_ACTION_DESIRE_NONE, nPushDesire / 2)
	end

    return nPushDesire
end

function IsGroupPushingTime()
    local minute = math.floor(DotaTime() / 60)
    return math.fmod(minute, PushGapMinutes) == 0
        or DotaTime() - lastPushTime < PushDuration
        or J.IsAnyAllyHeroSurroundedByManyAllies()
        or J.GetCoresAverageNetworth() > 22000
        or minute >= 50
        or teamAveLvl > 20
        or teamHasAegis
        or J.GetNumOfTeamTotalKills( false ) <= J.GetNumOfTeamTotalKills(true) - 20
        -- or J.Utils.IsTeamPushingSecondTierOrHighGround(bot)
end

function Push.WhichLaneToPush(bot)

    local distanceToTop = 0
    local distanceToMid = 0
    local distanceToBot = 0

    local topFront = GetLaneFrontLocation(GetTeam(),LANE_TOP, 0)
    local midFront = GetLaneFrontLocation(GetTeam(),LANE_MID, 0)
    local botFront = GetLaneFrontLocation(GetTeam(),LANE_BOT, 0)
    for i = 1, #GetTeamPlayers( GetTeam() ) do
        local member = GetTeamMember(i)
        if member ~= nil and member:IsAlive() then
            local teamLoc = member:GetLocation()
            if J.GetPosition(member) <= 3 then
                distanceToTop = math.max(distanceToTop, J.GetDistance(topFront, teamLoc))
                distanceToMid = math.max(distanceToMid, J.GetDistance(midFront, teamLoc))
                distanceToBot = math.max(distanceToBot, J.GetDistance(botFront, teamLoc))
            end
        end
    end

    local topLaneScore = CalculateLaneScore(distanceToTop, LANE_TOP)
    local midLaneScore = CalculateLaneScore(distanceToMid, LANE_MID)
    local botLaneScore = CalculateLaneScore(distanceToBot, LANE_BOT)

    if midLaneScore <= topLaneScore and midLaneScore <= botLaneScore then return midFront, LANE_MID end
    if topLaneScore <= midLaneScore and topLaneScore <= botLaneScore then return topFront, LANE_TOP end
    if botLaneScore <= topLaneScore and botLaneScore <= midLaneScore then return botFront, LANE_BOT end

    return nil
end

-- the smaller the better
function CalculateLaneScore(distance, lane)
    local hasAllyBarracks = J.Utils.IsAnyBarracksOnLaneAlive(false, lane)
    local hasEnemyBarracks = J.Utils.IsAnyBarracksOnLaneAlive(true, lane)
    local delta, aDelta = 5000, 5000
    if not hasAllyBarracks then aDelta = aDelta - delta * 0.5 end
    if hasEnemyBarracks then aDelta = aDelta - delta * 0.5 end
    return distance + aDelta
end

function Push.PushThink(bot, lane)
    if J.CanNotUseAction(bot) then return end

    local botAttackRange = bot:GetAttackRange()
    local fDeltaFromFront = (Min(J.GetHP(bot), 0.7) * 1000 - 700) + RemapValClamped(botAttackRange, 300, 700, 0, -600)
    local nEnemyTowers = bot:GetNearbyTowers(1600, true)
    local targetLoc = GetLaneFrontLocation(GetTeam(), lane, fDeltaFromFront)
    if J.Utils.GetLocationToLocationDistance(J.Utils.GetTeamFountainTpPoint(), targetLoc) < 3000 then
        local enemyLaneFront = GetLaneFrontLocation(GetOpposingTeam(), lane, -fDeltaFromFront)
        if GetUnitToLocationDistance(bot, enemyLaneFront) > bot:GetAttackRange()
        and #nInRangeAlly >= #nInRangeEnemy
        then
            targetLoc = enemyLaneFront
        end
    end

    local nEnemyAncient = GetAncient(GetOpposingTeam())
    if  GetUnitToUnitDistance(bot, nEnemyAncient) < 1600
    and J.CanBeAttacked(nEnemyAncient)
    then
        bot:Action_AttackUnit(nEnemyAncient, true)
        return
    end

    if targetBuilding then
        bot:Action_AttackUnit(targetBuilding, true)
        return
    end

    local nAllyHeroes = J.GetAlliesNearLoc(bot:GetLocation(), 900)
    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), botAttackRange + 150)
    if #nAllyHeroes >= #nEnemyHeroes
    and J.IsValidHero(nEnemyHeroes[1]) and J.CanBeAttacked(nEnemyHeroes[1])
    and (nEnemyHeroes[1]:GetAttackTarget() == bot or J.IsChasingTarget(nEnemyHeroes[1], bot))
    then
        bot:Action_AttackUnit(nEnemyHeroes[1], true)
        return
    end

    local nCreeps = bot:GetNearbyLaneCreeps(math.min(700 + botAttackRange, 1600), true)
    if  nCreeps ~= nil and #nCreeps > 0
    and J.CanBeAttacked(nCreeps[1])
    then
        bot:Action_AttackUnit(nCreeps[1], true)
        return
    end

    local nBarracks = bot:GetNearbyBarracks(math.min(700 + botAttackRange, 1600), true)
    if  nBarracks ~= nil and #nBarracks > 0
    and Push.CanBeAttacked(nBarracks[1])
    then
        bot:Action_AttackUnit(nBarracks[1], true)
        return
    end

    if  nEnemyTowers ~= nil and #nEnemyTowers > 0
    and Push.CanBeAttacked(nEnemyTowers[1])
    then
        bot:Action_AttackUnit(nEnemyTowers[1], true)
        return
    end

    local sEnemyTowers = bot:GetNearbyFillers(math.min(700 + botAttackRange, 1600), true)
    if  sEnemyTowers ~= nil and #sEnemyTowers > 0
    and Push.CanBeAttacked(sEnemyTowers[1])
    then
        bot:Action_AttackUnit(sEnemyTowers[1], true)
        return
    end

    bot:Action_MoveToLocation(targetLoc)
end

function Push.CanBeAttacked(building)
    if  building ~= nil
    and building:CanBeSeen()
    and not building:IsInvulnerable()
    then
        return true
    end

    return false
end

--[[
    hUnit: the unit to check
    fThreshold: the threshold of damage from tower comparing to unit's health percentage
    fDuration: the duration of damage to tower
]]
function Push.IsInDangerWithinTower(hUnit, fThreshold, fDuration)
    local totalDamage = 0
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
        if J.IsValid(enemy)
        and J.IsInRange(hUnit, enemy, 1600)
        and (enemy:GetAttackTarget() == hUnit or J.IsChasingTarget(enemy, hUnit)) then
            totalDamage = totalDamage + hUnit:GetActualIncomingDamage(enemy:GetAttackDamage() * enemy:GetAttackSpeed() * fDuration, DAMAGE_TYPE_PHYSICAL)
        end
    end

    local hUnitHealth = hUnit:GetHealth()
    return (totalDamage / hUnitHealth * 1.2) > fThreshold
end

function Push.ShouldWaitForImportantItemsSpells(vLocation)
    if J.IsMidGame() or J.IsLateGame() then
        if J.Utils.HasTeamMemberWithCriticalItemInCooldown(vLocation) then return true end
        if J.Utils.HasTeamMemberWithCriticalSpellInCooldown(vLocation) then return true end
    end
    return false
end

return Push