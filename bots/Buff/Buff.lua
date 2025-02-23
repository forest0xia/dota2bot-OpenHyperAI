-- Version information
local Version = require 'bots.FunLib.version'
if GetScriptDirectory == nil then GetScriptDirectory = function() return "bots" end end
-- Print version to console
print('Starting Buff. Version: ' .. Version.number)

dofile('bots/Buff/Timers')
dofile('bots/Buff/Experience')
dofile('bots/Buff/GPM')
dofile('bots/Buff/NeutralItems')
dofile('bots/Buff/Helper')
local Chat = require('bots.FretBots.Chat')

local InitTimerName = 'InitTimer'
local initDelay = 0
local initDelayDuration = 5

if Buff == nil
then
    Buff = {}
end

local Colors =
{
	good				= '#00ff00',
	warning			= '#fbff00',
	bad					= '#ff0000',
	consoleGood = '#1ce8b5',
	consoleBad  = '#e68d39',
}

local botTable = {
    [DOTA_TEAM_GOODGUYS]    = {},
    [DOTA_TEAM_BADGUYS]     = {}
}

function Buff:AddBotsToTable()
    for nTeam = 0, 3 do
        local pNum = PlayerResource:GetPlayerCountForTeam(nTeam)
        for i = 0, pNum do
            local playerID = PlayerResource:GetNthPlayerIDOnTeam(nTeam, i)
            local player = PlayerResource:GetPlayer(playerID)
            -- local connectionState = PlayerResource:GetConnectionState(playerID)
            -- print('Setting up Buff for player: '..playerID..', connection state: '..tostring(connectionState))
            if player then
                local hero = player:GetAssignedHero()
                local team = player:GetTeam()
                if hero ~= nil then
                    if PlayerResource:GetSteamID(hero:GetMainControllingPlayer()) == PlayerResource:GetSteamID(100) then
                        -- print('Instering bot player: '..hero:GetUnitName()..', to team: '..team)
                        table.insert(botTable[team], hero)
                    end
                else
                    -- print('[WARN] Failed to add player '.. playerID .. ' to bots list. Spectator?')
                end
            else
                -- print('[WARN] Failed to add player '.. playerID .. ' to bots list. Spectator?')
            end
        end
    end
end

function Buff:Init()
    if Helper.IsTurboMode() == nil then
        return 1
    end

    if initDelay < initDelayDuration then
        if GameRules:State_Get() > 6 then initDelay = initDelay + 1 end
        -- print('[Buff] Wait for all heroes to be loaded in game...')
        return 1
    end
    Timers:RemoveTimer(InitTimerName)
    print('[Buff] Initing Buff...')

    Buff:AddBotsToTable()
    local TeamRadiant = botTable[DOTA_TEAM_GOODGUYS]
    local TeamDire = botTable[DOTA_TEAM_BADGUYS]
    print('[Buff] Number of bots in TeamRadiant: ' .. #TeamRadiant)
    print('[Buff] Number of bots in TeamDire: ' .. #TeamDire)

    Chat:SendHttpRequest('start', Utilities:GetPInfo(), Chat.StartCallback)
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

function Buff:Print(msg, color)
	local message = msg
    if color ~= nil then
      message = Buff:ColorString(msg, color)
    end
	GameRules:SendCustomMessage(message, 0, 0)
end

-- returns html encoding to change the text of msg the appropriate color
function Buff:ColorString(msg, color)
	return '<font color="'..color..'">'..msg..'</font>'
end

Buff:Print('Buff mode initialized. Version: ' .. Version.number, Colors.good)
Buff:Print("Bot link for any feedback: https://steamcommunity.com/sharedfiles/filedetails/?id=3246316298 . Kudos to BeginnerAI, Fretbots, and ryndrb@; and thanks all for sharing your ideas.", Colors.consoleGood)
Timers:CreateTimer(InitTimerName, {endTime = 1, callback = Buff['Init']} )
