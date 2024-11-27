local bot = GetBot()
local botName = bot:GetUnitName();
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end

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

local Roshan

function GetDesire()
	if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return BOT_MODE_DESIRE_NONE end
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
	if J.Utils.IsTeamPushingSecondTierOrHighGround(bot) then
		return BOT_MODE_DESIRE_NONE
	end

	if J.GetEnemiesAroundAncient(1800) > 0 then
		return BOT_MODE_DESIRE_NONE
	end

    local timeOfDay = J.CheckTimeOfDay()

    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    then
        if timeOfDay == 'day'
        and GetUnitToLocationDistance(bot, roshanRadiantLoc) < 1600
        and GetUnitToLocationDistance(bot, nTeamFightLocation) < 2000
        then
            return BOT_ACTION_DESIRE_NONE
        else
            if timeOfDay == 'night'
            and GetUnitToLocationDistance(bot, roshanDireLoc) < 1600
            and GetUnitToLocationDistance(bot, nTeamFightLocation) < 2000
            then
                return BOT_ACTION_DESIRE_NONE
            end
        end
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

    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1300)
    if nEnemyHeroes ~= nil and #nEnemyHeroes > 0
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if shouldKillRoshan
    and initDPSFlag
    then
        local human, humanPing = J.GetHumanPing()
        if human ~= nil and DotaTime() > 5.0 then
            if humanPing ~= nil
            and humanPing.normal_ping
            and GetUnitToLocationDistance(human, J.GetCurrentRoshanLocation()) < 4500
            and J.GetDistance(humanPing.location, J.GetCurrentRoshanLocation()) < 600
            and DotaTime() < humanPing.time + 5.0
            then
                return 0.95
            end
        end

        local mul = RemapValClamped(DotaTime(), sinceRoshAliveTime, sinceRoshAliveTime + (2.5 * 60), 1, 2)
        local nRoshanDesire = (GetRoshanDesire() * mul)

        if hasSameOrMoreHero or (not hasSameOrMoreHero and J.HasEnoughDPSForRoshan(aliveHeroesList)) then
            return Clamp(nRoshanDesire, 0, 0.95)
        end
    end

    return BOT_ACTION_DESIRE_NONE
end
