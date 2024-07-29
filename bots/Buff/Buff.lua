dofile('bots/Buff/Timers')
dofile('bots/Buff/Experience')
dofile('bots/Buff/GPM')
dofile('bots/Buff/NeutralItems')
dofile('bots/Buff/Helper')

local InitTimerName = 'InitTimer'
local initDelay = 0
local initDelayDuration = 6

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
        -- print('Getting player: '..playerID..', connection state: '..tostring(connectionState))

        local hero = player:GetAssignedHero()
        local team = player:GetTeam()

        if hero ~= nil then
            if PlayerResource:GetSteamID(hero:GetMainControllingPlayer()) == PlayerResource:GetSteamID(100) then
                -- print('Instering bot player: '..hero:GetUnitName()..', to team: '..team)
                table.insert(botTable[team], hero)
            end
        else
            print('[WARN] Failed to add player '.. playerID .. ' to bots list. Spectator?')
        end
    end
end

function Buff:Init()
    if initDelay < initDelayDuration then
        if GameRules:State_Get() > 6 then initDelay = initDelay + 1 end
        print('Wait to init Buff - wait for all heroes to be loaded in game...')
        return 1
    end
    Timers:RemoveTimer(InitTimerName)
    print('Initing Buff...')

    Buff:AddBotsToTable()
    local TeamRadiant = botTable[DOTA_TEAM_GOODGUYS]
    local TeamDire = botTable[DOTA_TEAM_BADGUYS]
    print('Number of bots in TeamRadiant: ' .. #TeamRadiant)
    print('Number of bots in TeamDire: ' .. #TeamDire)

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

Timers:CreateTimer(InitTimerName, {endTime = 1, callback = Buff['Init']} )
