local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )

local killTime = 0.0
local shouldKillRoshan = false
local DoingRoshanMessage = DotaTime()

local roshanRadiantLoc  = Vector(7625, -7511, 1092)
local roshanDireLoc     = Vector(-7549, 7562, 1107)

-- local rTwinGate = nil
-- local dTwinGate = nil
-- local rTwinGateLoc = Vector(5888, -7168, 256)
-- local dTwinGateLoc = Vector(6144, 7552, 256)

local sinceRoshAliveTime = 0
local roshTimeFlag = false
local initDPSFlag = false
local considerRoshGap = 0

local Roshan

function GetDesire()
    if DotaTime() - considerRoshGap < 5 then return end
    considerRoshGap = DotaTime()

    if Roshan == nil then
        local nCreeps = bot:GetNearbyNeutralCreeps(700)
        for _, creepOrRoshan in pairs(nCreeps)
        do
            if creepOrRoshan:GetUnitName() == "npc_dota_roshan"
            then
                Roshan = creepOrRoshan
            end
        end
    end

	-- 如果在打高地 就别撤退去干别的
	local nAllyList = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE);
	if #nAllyList > 2 and (J.Utils.isNearEnemyHighGroundTower(bot, 2500) or J.Utils.isNearEnemySecondTierTower(bot, 2500)) then
		return BOT_MODE_DESIRE_NONE
	end

    -- if Roshan is about to get killed, kill it unless there are other absolute actions.
    if J.Utils.IsValidUnit(Roshan) then
        local roshHP = Roshan:GetHealth()/Roshan:GetMaxHealth()
        if roshHP < 0.8 then
            return RemapValClamped(roshHP, 100, 0, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_ABSOLUTE )
        end
    end

    local aliveAlly = J.GetNumOfAliveHeroes(false)
    local aliveEnemy = J.GetNumOfAliveHeroes(true)
    local hasSameOrMoreHero = aliveAlly >= aliveEnemy
    
    if not hasSameOrMoreHero then
        return BOT_ACTION_DESIRE_NONE
    end
    
    local timeOfDay = J.CheckTimeOfDay()

    local nCoreWithNoEmptySlot = 0
    local aliveHeroesList = {}
    for _, h in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if h:IsAlive()
        then
            if J.Utils.CountBackpackEmptySpace(h) <= 0 and J.IsCore(h) then
                nCoreWithNoEmptySlot = nCoreWithNoEmptySlot + 1
            end

            -- do not take rosh if the cores do not have any empty slot, it may get dropped on ground.
            if nCoreWithNoEmptySlot >= 2 then
                return BOT_ACTION_DESIRE_NONE
            end
            table.insert(aliveHeroesList, h)
        end
    end

    shouldKillRoshan = J.IsRoshanAlive()

    if shouldKillRoshan
    and not roshTimeFlag
    then
        sinceRoshAliveTime = DotaTime()
        roshTimeFlag = true
    else
        if not shouldKillRoshan
        then
            sinceRoshAliveTime = 0
            roshTimeFlag = false
        end
    end

    if J.HasEnoughDPSForRoshan(aliveHeroesList)
    then
        initDPSFlag = true
    end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    then
        if timeOfDay == 'day'
        and GetUnitToLocationDistance(bot, roshanRadiantLoc) < 1000
        and GetUnitToLocationDistance(bot, nTeamFightLocation) < 1600
        then
            return BOT_ACTION_DESIRE_NONE
        else
            if timeOfDay == 'night'
            and GetUnitToLocationDistance(bot, roshanDireLoc) < 1000
            and GetUnitToLocationDistance(bot, nTeamFightLocation) < 1600
            then
                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsRoshanCloseToChangingSides()
    then
        local botTarget = J.GetProperTarget(bot)
        if J.IsRoshan(botTarget) then
            return RemapValClamped(J.GetHP(botTarget), 1, 0, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_VERYHIGH )
        end
        if not J.IsValid(botTarget) or not J.IsRoshan(botTarget) then
            return BOT_ACTION_DESIRE_NONE
        end
    end

    local nEnemyHeroes = J.GetNearbyHeroes(bot,700 + bot:GetAttackRange(), true, BOT_MODE_NONE)
    if nEnemyHeroes ~= nil and #nEnemyHeroes > 0
    then
        return BOT_ACTION_DESIRE_NONE
    end

    -- 如果在打高地 就别撤退去rosh了
	local nAllyList = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE);
	if #nAllyList >= 3 and (J.Utils.isNearEnemyHighGroundTower(bot, 2500) or J.Utils.isNearEnemySecondTierTower(bot, 2500)) then
		return BOT_ACTION_DESIRE_NONE;
	end

    if shouldKillRoshan
    and initDPSFlag
    -- and (hasSameOrMoreHero or (not hasSameOrMoreHero and IsEnoughAllies()))
    then
        local mul = RemapValClamped(DotaTime(), sinceRoshAliveTime, sinceRoshAliveTime + (2.5 * 60), 1, 2)
        local nRoshanDesire = (GetRoshanDesire() * mul)

        return Clamp(nRoshanDesire, 0, 0.91)
    end

    return BOT_ACTION_DESIRE_NONE
end

-- function Think()
--     local timeOfDay, time = J.CheckTimeOfDay()
--     -- local isInPlace, twinGate = IsInTwinGates(timeOfDay, time)

--     if timeOfDay == "day" and time > 270
--     then
--         -- if ConsiderTwinGates(timeOfDay, time) then
--         --     bot:ActionPush_MoveToLocation(rTwinGateLoc)
--         -- end

--         -- if isInPlace then
--         --     bot:ActionPush_AttackUnit(twinGate, false)
--         -- end

--         bot:ActionPush_MoveToLocation(roshanDireLoc)
--     elseif timeOfDay == "day" then
--         bot:ActionPush_MoveToLocation(roshanRadiantLoc)
--     end

--     if timeOfDay == "night" and time > 570
--     then
--         -- if ConsiderTwinGates(timeOfDay, time) then
--         --     bot:ActionPush_MoveToLocation(dTwinGateLoc)
--         -- end

--         -- if isInPlace then
--         --     bot:ActionPush_AttackUnit(twinGate, false)
--         -- end

--         bot:ActionPush_MoveToLocation(roshanRadiantLoc)
--     elseif timeOfDay == "night" then
--         bot:ActionPush_MoveToLocation(roshanDireLoc)
--     end

--     local nRange = bot:GetAttackRange() + 700

--     local enemies = J.GetNearbyHeroes(bot,nRange, true, BOT_MODE_NONE)
--     if enemies ~= nil and #enemies > 0 and J.WeAreStronger(bot, nRange)
--     then
--         return bot:ActionPush_AttackUnit(enemies[1], false)
--     end

--     local creeps = bot:GetNearbyLaneCreeps(nRange, true)
--     if creeps ~= nil and #creeps > 0 then
--         bot:ActionPush_AttackUnit(creeps[1], false)
--     end

--     local nCreeps = bot:GetNearbyNeutralCreeps(nRange)
--     for _, c in pairs(nCreeps) do
--         if string.find(c:GetUnitName(), "roshan")
--         and (IsEnoughAllies() or (J.IsCore(bot) and c:GetHealth() / c:GetMaxHealth() < 0.3))
--         then
--             return bot:ActionPush_AttackUnit(c, false)
--         end

--         if (DotaTime() - DoingRoshanMessage) > 15 then
--             DoingRoshanMessage = DotaTime()
--             bot:ActionImmediate_Chat("Let's kill Roshan!", false)
--             if timeOfDay == "day" then
--                 bot:ActionImmediate_Ping(7625, -7511, true)
--             else
--                 bot:ActionImmediate_Ping(-7549, 7562, true)
--             end
--         end
--     end
-- end

-- function IsEnoughAllies()
--     local timeOfDay = J.CheckTimeOfDay()
--     local roshLoc = nil

--     if timeOfDay == "day" then
--         roshLoc = roshanRadiantLoc
--     else
--         roshLoc = roshanDireLoc
--     end

--     local allyList = {}
--     for _, h in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
--         if GetUnitToLocationDistance(h, roshLoc) < 1600
--         then
--             table.insert(allyList, h)
--         end
--     end

--     return J.HasEnoughDPSForRoshan(allyList)
-- end

-- No functionality yet from API
-- function ConsiderTwinGates(timeOfDay, time)
--     if timeOfDay == "day" and time > 240
--     then
--         if GetUnitToLocationDistance(bot, dTwinGateLoc) < 6000
--         and bot:GetMana() >= 75
--         then
--             return true
--         end
--     end

--     if timeOfDay == "night" and time > 540
--     then
--         if GetUnitToLocationDistance(bot, rTwinGateLoc) < 6000 then
--             return true
--         end
--     end

--     return false
-- end

-- function IsInTwinGates(timeOfDay, time)
--     local twinGate = nil
--     local unitList = GetUnitList(UNIT_LIST_ALL)
--     for _, u in pairs(unitList) do
--         if rTwinGate == nil then
--             if u:GetUnitName() == "npc_dota_unit_twin_gate" then
--                 rTwinGate = u
--             else
--                 dTwinGate = u
--             end
--         end
--     end

--     if rTwinGate ~= nil and dTwinGate ~= nil
--     and GetUnitToUnitDistance(bot, rTwinGate) < GetUnitToUnitDistance(bot, dTwinGate)
--     then
--         twinGate = rTwinGate
--     else
--         twinGate = dTwinGate
--     end

--     if timeOfDay == "day" and time > 240
--     then
--         if GetUnitToLocationDistance(bot, dTwinGateLoc) < 100
--         then
--             return true, twinGate
--         end
--     end

--     if timeOfDay == "night" and time > 540
--     then
--         if GetUnitToLocationDistance(bot, rTwinGateLoc) < 100 then
--             return true, twinGate
--         end
--     end

--     return false, twinGate
-- end