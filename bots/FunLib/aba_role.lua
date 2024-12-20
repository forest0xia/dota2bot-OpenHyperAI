--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____dota = require(GetScriptDirectory().."/ts_libs/dota/index")
local GameMode = ____dota.GameMode
local GameState = ____dota.GameState
local Lane = ____dota.Lane
local Team = ____dota.Team
local ____utils = require(GetScriptDirectory().."/FunLib/utils")
local NumHumanBotPlayersInTeam = ____utils.NumHumanBotPlayersInTeam
local HeroRolesMap = require(GetScriptDirectory().."/FunLib/aba_hero_roles_map")
local ____enemy_role_estimation = require(GetScriptDirectory().."/FunLib/enemy_role_estimation")
local GetEnemyPosition = ____enemy_role_estimation.GetEnemyPosition
____exports.RoleAssignment = {TEAM_RADIANT = {
    1,
    2,
    3,
    4,
    5,
    1,
    2,
    3,
    4,
    5,
    1,
    2,
    3,
    4,
    5
}, TEAM_DIRE = {
    1,
    2,
    3,
    4,
    5,
    1,
    2,
    3,
    4,
    5,
    1,
    2,
    3,
    4,
    5
}}
____exports.IsCarry = function(hero)
    return HeroRolesMap.IsCarry(hero)
end
____exports.IsDisabler = function(hero)
    return HeroRolesMap.IsDisabler(hero)
end
____exports.IsDurable = function(hero)
    return HeroRolesMap.IsDurable(hero)
end
____exports.HasEscape = function(hero)
    return HeroRolesMap.HasEscape(hero)
end
____exports.IsInitiator = function(hero)
    return HeroRolesMap.IsInitiator(hero)
end
____exports.IsJungler = function(hero)
    return HeroRolesMap.IsJungler(hero)
end
____exports.IsNuker = function(hero)
    return HeroRolesMap.IsNuker(hero)
end
____exports.IsSupport = function(hero)
    return HeroRolesMap.IsSupport(hero)
end
____exports.IsPusher = function(hero)
    return HeroRolesMap.IsPusher(hero)
end
____exports.IsRanged = function(hero)
    return HeroRolesMap.IsRanged(hero)
end
____exports.IsHealer = function(hero)
    return HeroRolesMap.IsHealer(hero)
end
____exports.IsMelee = function(attackRange)
    return attackRange <= 326
end
____exports.CanBeOfflaner = function(hero)
    return ____exports.IsInitiator(hero) and ____exports.IsDurable(hero)
end
____exports.CanBeMidlaner = function(hero)
    return HeroRolesMap.IsCarry(hero)
end
____exports.CanBeSafeLaneCarry = function(hero)
    return HeroRolesMap.IsCarry(hero)
end
____exports.CanBeSupport = function(hero)
    return HeroRolesMap.IsSupport(hero)
end
____exports.GetCurrentSuitableRole = function(bot, hero)
    local lane = bot:GetAssignedLane()
    if ____exports.CanBeSupport(hero) and lane ~= Lane.Mid then
        return "support"
    elseif ____exports.CanBeMidlaner(hero) and lane == Lane.Mid then
        return "midlaner"
    elseif ____exports.CanBeSafeLaneCarry(hero) and (GetTeam() == Team.Radiant and lane == Lane.Bot or GetTeam() == Team.Dire and lane == Lane.Top) then
        return "carry"
    elseif ____exports.CanBeOfflaner(hero) and (GetTeam() == Team.Radiant and lane == Lane.Top or GetTeam() == Team.Dire and lane == Lane.Bot) then
        return "offlaner"
    else
        return "unknown"
    end
end
____exports.GetBestEffortSuitableRole = function(hero)
    if ____exports.CanBeSupport(hero) then
        return 4
    elseif ____exports.CanBeMidlaner(hero) then
        return 2
    elseif ____exports.CanBeSafeLaneCarry(hero) then
        return 1
    elseif ____exports.CanBeOfflaner(hero) then
        return 3
    else
        return 3
    end
end
____exports.invisEnemyExist = false
local globalEnemyCheck = false
local lastCheck = -90
____exports.UpdateInvisEnemyStatus = function(bot)
    if ____exports.invisEnemyExist then
        return
    end
    if globalEnemyCheck == false then
        local players = GetTeamPlayers(GetOpposingTeam())
        do
            local i = 0
            while i < #players do
                if HeroRolesMap.InvisHeroes[GetSelectedHeroName(players[i + 1])] == 1 then
                    ____exports.invisEnemyExist = true
                    break
                end
                i = i + 1
            end
        end
        globalEnemyCheck = true
    elseif globalEnemyCheck == true and DotaTime() > 10 * 60 and DotaTime() > lastCheck + 3 then
        local enemies = bot:GetNearbyHeroes(1600, true, 0)
        if #enemies > 0 then
            do
                local i = 0
                while i < #enemies do
                    local enemy = enemies[i + 1]
                    if enemy ~= nil and enemy:CanBeSeen() then
                        local SASlot = enemy:FindItemSlot("item_shadow_amulet")
                        local GCSlot = enemy:FindItemSlot("item_glimmer_cape")
                        local ISSlot = enemy:FindItemSlot("item_invis_sword")
                        local SESlot = enemy:FindItemSlot("item_silver_edge")
                        if SASlot >= 0 or GCSlot >= 0 or ISSlot >= 0 or SESlot >= 0 then
                            ____exports.invisEnemyExist = true
                            break
                        end
                    end
                    i = i + 1
                end
            end
        end
        lastCheck = DotaTime()
    end
end
____exports.supportExist = nil
____exports.UpdateSupportStatus = function(bot)
    if ____exports.supportExist then
        return true
    end
    if ____exports.GetPosition(bot) >= 4 then
        ____exports.supportExist = true
        return true
    end
    local TeamMember = GetTeamPlayers(GetTeam())
    do
        local i = 0
        while i < #TeamMember do
            local ally = GetTeamMember(i + 1)
            if ally ~= nil and ally:IsHero() and ____exports.GetPosition(ally) >= 4 then
                ____exports.supportExist = true
                return true
            end
            i = i + 1
        end
    end
    return false
end
____exports.sayRate = false
____exports.NotSayRate = function()
    return ____exports.sayRate == false
end
____exports.sayJiDi = false
____exports.NotSayJiDi = function()
    return ____exports.sayJiDi == false
end
____exports.replyMemberID = nil
____exports.GetReplyMemberID = function()
    if ____exports.replyMemberID ~= nil then
        return ____exports.replyMemberID
    end
    local tMemberIDList = GetTeamPlayers(GetTeam())
    local nMemberCount = #tMemberIDList
    local nHumanCount = 0
    do
        local i = 0
        while i < #tMemberIDList do
            if not IsPlayerBot(tMemberIDList[i + 1]) then
                nHumanCount = nHumanCount + 1
            end
            i = i + 1
        end
    end
    ____exports.replyMemberID = tMemberIDList[RandomInt(nHumanCount + 1, nMemberCount) + 1]
    return ____exports.replyMemberID
end
____exports.memberIDIndexTable = nil
____exports.IsAllyMemberID = function(nID)
    if ____exports.memberIDIndexTable == nil then
        local tMemberIDList = GetTeamPlayers(GetTeam())
        if #tMemberIDList > 0 then
            ____exports.memberIDIndexTable = {}
            do
                local i = 0
                while i < #tMemberIDList do
                    ____exports.memberIDIndexTable[tMemberIDList[i + 1]] = true
                    i = i + 1
                end
            end
        end
    end
    return ____exports.memberIDIndexTable and ____exports.memberIDIndexTable[nID] == true
end
____exports.enemyIDIndexTable = nil
____exports.IsEnemyMemberID = function(nID)
    if ____exports.enemyIDIndexTable == nil then
        local tEnemyIDList = GetTeamPlayers(GetOpposingTeam())
        if #tEnemyIDList > 0 then
            ____exports.enemyIDIndexTable = {}
            do
                local i = 0
                while i < #tEnemyIDList do
                    ____exports.enemyIDIndexTable[tEnemyIDList[i + 1]] = true
                    i = i + 1
                end
            end
        else
            return false
        end
    end
    return ____exports.enemyIDIndexTable and ____exports.enemyIDIndexTable[nID] == true
end
____exports.sLastChatString = "-0"
____exports.sLastChatTime = -90
____exports.SetLastChatString = function(sChatString)
    ____exports.sLastChatString = sChatString
    ____exports.sLastChatTime = DotaTime()
end
____exports.ShouldTpToDefend = function()
    if ____exports.sLastChatString == "-都来守家" and ____exports.sLastChatTime >= DotaTime() - 10 then
        return true
    end
    return false
end
____exports.fLastGiveTangoTime = -90
____exports.aegisHero = nil
____exports.IsAllyHaveAegis = function()
    if ____exports.aegisHero ~= nil and ____exports.aegisHero:FindItemSlot("item_aegis") < 0 then
        ____exports.aegisHero = nil
    end
    return ____exports.aegisHero ~= nil
end
____exports.lastbbtime = -90
____exports.ShouldBuyBack = function()
    return DotaTime() > ____exports.lastbbtime + 1
end
____exports.lastFarmTpTime = -90
____exports.ShouldTpToFarm = function()
    return DotaTime() > ____exports.lastFarmTpTime + 4
end
____exports.lastPowerRuneTime = 90
____exports.IsPowerRuneKnown = function()
    return math.floor(____exports.lastPowerRuneTime / 120) == math.floor(DotaTime() / 120)
end
____exports.campCount = 18
____exports.GetCampCount = function()
    return ____exports.campCount
end
____exports.hasRefreshDone = true
____exports.IsCampRefreshDone = function()
    return ____exports.hasRefreshDone == true
end
____exports.availableCampTable = {}
____exports.GetAvailableCampCount = function()
    return #____exports.availableCampTable
end
____exports.nStopWaitTime = RandomInt(3, 8)
____exports.GetRuneActionTime = function()
    return ____exports.nStopWaitTime
end
____exports.GetPositionForCM = function(bot)
    local role = nil
    if GetTeam() ~= bot:GetTeam() then
        role = GetEnemyPosition(bot:GetPlayerID())
        if role ~= nil then
            return role
        end
        print("[WARNING] Cannot determine the role of an enemy bot. Return default pos as 3")
        print(
            "Stack Trace:",
            debug.traceback()
        )
        return 3
    end
    local lane = bot:GetAssignedLane()
    local heroName = bot:GetUnitName()
    if lane == Lane.Mid then
        role = 2
    elseif lane == Lane.Top then
        if bot:GetTeam() == Team.Radiant then
            if ____exports.CanBeOfflaner(heroName) then
                role = 3
            else
                role = 4
            end
        else
            if ____exports.CanBeSafeLaneCarry(heroName) then
                role = 1
            else
                role = 5
            end
        end
    elseif lane == Lane.Bot then
        if bot:GetTeam() == Team.Radiant then
            if ____exports.CanBeSafeLaneCarry(heroName) then
                role = 1
            else
                role = 5
            end
        else
            if ____exports.CanBeOfflaner(heroName) then
                role = 3
            else
                role = 4
            end
        end
    end
    if role == nil then
        role = 1
        print((((("[ERROR] Failed to determine role for bot " .. heroName) .. " in CM. It got assigned lane#: ") .. tostring(lane)) .. ". Set it to pos: ") .. tostring(role))
    end
    return role
end
____exports.GetRoleFromId = function(bot)
    local heroID = GetTeamPlayers(GetTeam())
    local heroName = bot:GetUnitName()
    local team = GetTeam() == Team.Radiant and "TEAM_RADIANT" or "TEAM_DIRE"
    do
        local i = 0
        while i < #heroID do
            if GetSelectedHeroName(heroID[i + 1]) == heroName then
                return ____exports.RoleAssignment[team][i + 1]
            end
            i = i + 1
        end
    end
    return nil
end
____exports.HeroPositions = {}
____exports.GetPosition = function(bot)
    local role = bot.assignedRole
    if role == nil and GetGameMode() == GameMode.Cm then
        local nH, _ = NumHumanBotPlayersInTeam(bot:GetTeam())
        if nH == 0 then
            role = ____exports.GetPositionForCM(bot)
        end
    end
    local playerId = bot:GetPlayerID()
    local unitName = bot:GetUnitName()
    if (role == nil or GetGameState() == GameState.PreGame) and playerId ~= nil then
        local cRole = ____exports.HeroPositions[playerId]
        if cRole ~= nil then
            role = cRole
        else
            local heroID = GetTeamPlayers(GetTeam())
            local team = GetTeam() == Team.Radiant and "TEAM_RADIANT" or "TEAM_DIRE"
            do
                local i = 0
                while i < #heroID do
                    if heroID[i + 1] == playerId then
                        role = ____exports.RoleAssignment[team][i + 1]
                    end
                    i = i + 1
                end
            end
        end
    end
    bot.assignedRole = role
    if GetTeam() ~= bot:GetTeam() then
        role = GetEnemyPosition(bot:GetPlayerID())
        print((("[WARNING] Trying to get role for enemy. The estimated role is: " .. tostring(role)) .. ", for bot: ") .. unitName)
        if role ~= nil then
            return role
        end
        print("[WARNING] Cannot determine the role of an enemy bot. Return default pos as 3")
        print(
            "Stack Trace:",
            debug.traceback()
        )
        return 3
    end
    if role == nil and GetGameState() ~= GameState.PreGame then
        if ____exports.HeroPositions[playerId] == nil then
            ____exports.HeroPositions[playerId] = ____exports.GetRoleFromId(bot)
        end
        role = ____exports.HeroPositions[playerId] ~= nil and ____exports.HeroPositions[playerId] or ____exports.GetPositionForCM(bot)
        print((((("[ERROR] Failed to match bot role for bot: " .. unitName) .. ", PlayerID: ") .. tostring(playerId)) .. ", set it to play pos: ") .. tostring(role))
        print(
            "Stack Trace:",
            debug.traceback()
        )
    end
    if role == nil then
        print(("[ERROR] Failed to determine role for bot " .. unitName) .. ". Set it to pos: 3.")
        role = 3
    end
    return role
end
____exports.IsPvNMode = function()
    return ____exports.IsAllShadow()
end
____exports.IsAllShadow = function()
    return false
end
return ____exports
