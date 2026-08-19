if GetScriptDirectory == nil then GetScriptDirectory = function () return "bots" end end
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )

local Dota2Teams = { }

Dota2Teams.defaultPostfix = 'EHA' -- Open Hyper AI.
Dota2Teams.maxTeamSize = 12 -- e.g. for 12 v 12

-- List should have a least 4 teams for better performance.
local defaultTeams = {
    {name = "XG", players = {"Ame", "Xm", "Xxs", "XinQ", "xNova"}},                  -- Xtreme Gaming
    {name = "PARI", players = {"Satanic", "No[o]ne-", "DM", "9Class", "Dukalis"}},   -- PARIVISION
    {name = "FLCN", players = {"ATF", "Malr1ne", "skiter", "Sneyking", "Cr1t-"}},    -- Team Falcons
    {name = "LQD", players = {"miCKe", "Nisha", "zai", "Boxi", "Insania"}},          -- Liquid
    {name = "GG", players = {"dyrachyo", "Quinn", "Ace", "tOfu", "Seleri"}},         -- Gaimin Gladiators
    {name = "TUND", players = {"Skiter", "Nine", "33", "Sneyking", "Aui_2000"}},     -- Tundra Esports
    {name = "EG", players = {"Pakazs", "Chris Luck", "Wisper", "Matthew", "Panda"}}, -- Evil Geniuses
    {name = "LGD", players = {"shiro", "NTS", "niu", "planet", "y`"}},               -- PSG.LGD
    {name = "SR", players = {"Arteezy", "Abed", "SaberL", "Cr1t-", "Fly"}},          -- Shopify Rebellion
    {name = "TLN", players = {"23savage", "Mikoto", "Jabz", "Q", "Oli"}},            -- Talon Esports
    {name = "BC", players = {"K1", "C.Luck", "Wisper", "Stinger", "Scofield"}},      -- beastcoast
    {name = "TS", players = {"Yatoro", "Larl", "Collapse", "Mira", "Miposhka"}},     -- Team Spirit
    {name = "TSM", players = {"Timado", "Bryle", "Kasane", "Ari", "Whitemon"}},      -- TSM
    {name = "BB", players = {"Nightfall", "gpk", "Pure", "Save-", "TTT"}},           -- BetBoom
    {name = "EXE", players = {"Palos", "Bob", "Tino", "Shanks", "Carlo"}},           -- Execration
    {name = "QUEST", players = {"TA2000", "No!ob", "Tobi", "OmaR", "kaori"}},        -- Quest Esports
    {name = "NOUNS", players = {"Gunnar", "Costabile", "Moo", "ZFreek", "Husky"}},   -- nouns
    {name = "BLEED", players = {"JaCkky", "Kordan", "ice3", "DJ", "DuBu"}},          -- Bleed Esports
    {name = "AST", players = {"Monet", "Xxs", "Ori", "BoBoKa", "LaNm"}},             -- Aster
    {name = "IG", players = {"flyfly", "Emo", "JT-", "Kaka", "Oli"}},                -- Invictus Gaming
    {name = "AR", players = {"Eurus", "Somnus", "Yang", "Fy", "xNova"}},             -- Azure Ray
    {name = "BLK", players = {"Raven", "Karl", "Kuku", "TIMS", "Eyyou"}},            -- Blacklist
    {name = "9P", players = {"RAMZES", "kiyotaka", "MieRo", "Antares", "Solo"}},     -- 9Pandas
    {name = "SMG", players = {"MidOne", "Moon", "Masaros", "Ahfu", "RPotato"}},      -- Team SMG
    {name = "KEYD", players = {"4dr", "Tavo", "hFn", "KJ", "mini"}},                 -- Keyd Stars
    {name = "TG", players = {"watson", "Quinn", "Ace", "tOfu", "Malady"}},           -- Gaimin Gladiators
    {name = "TA", players = {"shiro", "NothingToSay", "Bach", "planet", "y`"}},      -- Team Tidebound
    {name = "ADD", players = {
        "Azazel", "Lucifer", "Belial", "Lilith", "Diablo", "Mephisto", "Samael", "Abaddon", "Mammon", "Astaroth", "Moloch", "Apollyon", "Zagan", "Nyx", "Malphas",
        "Inferno", "Darkfire", "Shadow", "Nightmare", "Doom", "Soul", "Death", "Light", "Seraph", "Radiant", "Divine", "Angel"
    }}
}

local function generateTeam(overrides)
    local playerList = { }
    local overriddenNames = { }
    local randomNum = 0
    repeat
        randomNum = RandomInt(1, #defaultTeams)
    -- ensure a team can only pick from certain team names.
    until randomNum % 2 == GetTeam() - 2 and (defaultTeams[randomNum].name ~= 'ADD' or defaultTeams[randomNum].name ~= '上古')
    -- print('randomNum='..tostring(randomNum)..', team name='..tostring(defaultTeams[randomNum].name)..', for team='..tostring(GetTeam()))
    playerList = Utils.MergeLists(defaultTeams[randomNum].players, defaultTeams[#defaultTeams].players)
    if overrides and #overrides > 0 then
        for i = 1, #overrides do
            if overrides[i] and overrides[i] ~= 'Random' then
                playerList[i] = overrides[i]
                table.insert(overriddenNames, overrides[i])
            end
        end
    end

    local team = { }
    for i = 1, Dota2Teams.maxTeamSize do
        local pName = table.remove(playerList, 1)
        if Utils.HasValue(overriddenNames, pName) then
            table.insert(team, pName)
        else
            table.insert(team, defaultTeams[randomNum].name .. "." .. pName ..'.'..Dota2Teams.defaultPostfix)
        end
    end
    return team
end

--[[
    Example of overrides arg with specific player names for Radiant:
    local playerNameOverrides = {
        Radiant = {"p1", "p2", "p3", "p4", "p5"}
    }
]]
function Dota2Teams.generateTeams(overrides)
    local radiantOverrides = overrides and overrides.Radiant or {}
    local direOverrides = overrides and overrides.Dire or {}

    local radiantTeam = generateTeam(radiantOverrides)
    local direTeam = generateTeam(direOverrides)

    return {
        Radiant = radiantTeam,
        Dire = direTeam
    }
end

return Dota2Teams
