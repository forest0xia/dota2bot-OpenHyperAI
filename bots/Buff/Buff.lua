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
local VectorTargeting = require('bots.FretBots.VectorTargeting')

local InitTimerName = 'InitTimer'
local initDelay = 0
local initDelayDuration = 5
local botLoadFailSafeDelta = 15

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

local function IsBotPlayerSlot(playerID)
    if playerID == nil or playerID < 0 then return false end
    return PlayerResource:GetSteamID(playerID) == PlayerResource:GetSteamID(100)
        or (PlayerResource.IsFakeClient and PlayerResource:IsFakeClient(playerID))
end

local function IsRealBotHero(unit)
    if unit == nil or unit:IsNull() then return false end
    if not (unit:IsHero() and unit:IsRealHero() and not unit:IsIllusion()) then
        return false
    end
    if unit.IsClone and unit:IsClone() then
        return false
    end
    if unit.IsCreepHero and unit:IsCreepHero() then
        return false
    end
    if unit.IsTempestDouble and unit:IsTempestDouble() then
        return false
    end
    if not string.find(unit:GetUnitName(), '^npc_dota_hero_') then
        return false
    end
    local ownerId = unit:GetMainControllingPlayer()
    if ownerId == nil or ownerId < 0 then return false end
    local selectedHero = PlayerResource.GetSelectedHeroEntity and PlayerResource:GetSelectedHeroEntity(ownerId)
    if selectedHero ~= nil and not selectedHero:IsNull() and selectedHero ~= unit then
        return false
    end
    return IsBotPlayerSlot(ownerId)
end

local function CollectBotHeroes()
    local found = {
        [DOTA_TEAM_GOODGUYS] = {},
        [DOTA_TEAM_BADGUYS]  = {},
    }
    local seenBots = {}
    local seenOwners = {}
    local seenHeroes = {}
    local expectedBots = 0
    local readyBots = 0
    local totalHeroes = 0

    local maxPlayerId = (DOTA_MAX_TEAM_PLAYERS and (DOTA_MAX_TEAM_PLAYERS * 2) - 1) or 23
    for playerID = 0, maxPlayerId do
        local isValid = (PlayerResource.IsValidPlayerID and PlayerResource:IsValidPlayerID(playerID))
            or (PlayerResource:GetPlayer(playerID) ~= nil)
        if isValid then
            local team = PlayerResource:GetTeam(playerID)
            if team == DOTA_TEAM_GOODGUYS or team == DOTA_TEAM_BADGUYS then
                local isBotSlot = IsBotPlayerSlot(playerID)
                if isBotSlot then
                    expectedBots = expectedBots + 1
                end
                local hero = PlayerResource.GetSelectedHeroEntity and PlayerResource:GetSelectedHeroEntity(playerID)
                if hero == nil or hero:IsNull() then
                    local player = PlayerResource:GetPlayer(playerID)
                    if player then
                        hero = player:GetAssignedHero()
                    end
                end
                if hero ~= nil and not hero:IsNull() then
                    if not seenHeroes[hero]
                        and hero:IsHero() and hero:IsRealHero() and not hero:IsIllusion()
                        and (not hero.IsClone or not hero:IsClone())
                        and (not hero.IsCreepHero or not hero:IsCreepHero())
                        and (not hero.IsTempestDouble or not hero:IsTempestDouble())
                    then
                        seenHeroes[hero] = true
                        totalHeroes = totalHeroes + 1
                    end
                    if isBotSlot and not seenBots[hero] and not seenOwners[playerID] and IsRealBotHero(hero) then
                        local heroTeam = hero:GetTeam()
                        if found[heroTeam] then
                            seenBots[hero] = true
                            seenOwners[playerID] = true
                            table.insert(found[heroTeam], hero)
                            readyBots = readyBots + 1
                        end
                    end
                end
            end
        end
    end

    -- Fallback entity scan catches any bot hero whose PlayerResource hero handle is still nil
    if FindUnitsInRadius then
        local units = FindUnitsInRadius(
            DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, 3,
            DOTA_UNIT_TARGET_HERO, 88, FIND_ANY_ORDER, false)
        if units then
            for _, unit in pairs(units) do
                if unit and not unit:IsNull()
                    and unit:IsHero() and unit:IsRealHero() and not unit:IsIllusion()
                    and (not unit.IsClone or not unit:IsClone())
                    and (not unit.IsCreepHero or not unit:IsCreepHero())
                    and (not unit.IsTempestDouble or not unit:IsTempestDouble())
                then
                    if not seenHeroes[unit] then
                        seenHeroes[unit] = true
                        totalHeroes = totalHeroes + 1
                    end
                    if IsRealBotHero(unit) then
                        local ownerId = unit:GetMainControllingPlayer()
                        local team = unit:GetTeam()
                        if found[team] and not seenBots[unit] and not seenOwners[ownerId] then
                            seenBots[unit] = true
                            seenOwners[ownerId] = true
                            table.insert(found[team], unit)
                            readyBots = readyBots + 1
                        end
                    end
                end
            end
        end
    end

    return found, expectedBots, readyBots, totalHeroes
end

function Buff:CheckBotsReady()
    local _, expectedBots, readyBots, totalHeroes = CollectBotHeroes()
    if expectedBots > 0 and readyBots >= expectedBots then
        return true
    end
    if expectedBots == 0 and totalHeroes >= 10 then
        return true
    end

    botLoadFailSafeDelta = botLoadFailSafeDelta - 1
    if botLoadFailSafeDelta <= 0 then
        if (expectedBots > 0 and readyBots >= math.min(4, expectedBots)) or readyBots > 0 or totalHeroes >= 1 then
            print('[Buff] Failsafe: ' .. readyBots .. '/' .. expectedBots .. ' bot heroes found. Proceeding.')
            return true
        end
        botLoadFailSafeDelta = 5
    end
    return false
end

function Buff:AddBotsToTable()
    local found = CollectBotHeroes()
    botTable[DOTA_TEAM_GOODGUYS] = found[DOTA_TEAM_GOODGUYS]
    botTable[DOTA_TEAM_BADGUYS]  = found[DOTA_TEAM_BADGUYS]
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

    if not Buff:CheckBotsReady() then
        return 1
    end
    Timers:RemoveTimer(InitTimerName)
    print('[Buff] Initing Buff...')

    Buff:AddBotsToTable()
    VectorTargeting:Initialize()
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
Buff:Print("Bot link for any feedback: https://github.com/forest0xia/dota2bot-OpenHyperAI . Kudos to BeginnerAI, Fretbots, and ryndrb@; and thanks all for sharing your ideas.", Colors.consoleGood)
Timers:CreateTimer(InitTimerName, {endTime = 1, callback = Buff['Init']} )
