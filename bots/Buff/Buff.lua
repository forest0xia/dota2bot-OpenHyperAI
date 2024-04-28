dofile('bots/Buff/Timers')
dofile('bots/Buff/Experience')
dofile('bots/Buff/GPM')
dofile('bots/Buff/NeutralItems')
dofile('bots/Buff/Helper')

if Buff == nil
then
    Buff = {}
end

local botTable = {
    [DOTA_TEAM_GOODGUYS]    = {},
    [DOTA_TEAM_BADGUYS]     = {}
}

function Buff:AddBotsToTable()
    local playerCount = PlayerResource:GetPlayerCount()

    for playerID = 0, playerCount - 1 do
        local player = PlayerResource:GetPlayer(playerID)
        local connectionState = PlayerResource:GetConnectionState(playerID)

        if connectionState ~= DOTA_CONNECTION_STATE_CONNECTED then
            local hero = player:GetAssignedHero()
            local team = player:GetTeam()

            if hero then
                table.insert(botTable[team], hero)
            end
        end
    end
end

function Buff:Init()
    Buff:AddBotsToTable()
    local TeamRadiant = botTable[DOTA_TEAM_GOODGUYS]
    local TeamDire = botTable[DOTA_TEAM_BADGUYS]

    Timers:CreateTimer(function()
        NeutralItems.GiveNeutralItems(TeamRadiant, TeamDire)

        if not Helper.IsTurboMode()
        then
            for _, h in pairs(TeamRadiant) do
                if Helper.IsCore(h, TeamRadiant)
                then
                    GPM.UpdateBotGold(h)
                end

                XP.UpdateXP(h, TeamRadiant)
            end

            for _, h in pairs(TeamDire) do
                if Helper.IsCore(h, TeamDire)
                then
                    GPM.UpdateBotGold(h)
                end

                XP.UpdateXP(h, TeamDire)
            end
        end

        return 1
    end)
end

Buff:Init()