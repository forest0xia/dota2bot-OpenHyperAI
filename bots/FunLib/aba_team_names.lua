local Utils = require( GetScriptDirectory()..'/FunLib/utils' )

local Dota2Teams = {}

local defaultPostfix = 'OHA' -- Open Hyper AI.
local maxTeamSize = 12 -- e.g. for 12 v 12

-- List should have a least 4 teams for better performance.
local defaultTeams = {
    {name = "Liquid", players = {"miCKe", "Nisha", "zai", "Boxi", "Insania"}},
    {name = "GaiminGladiators", players = {"dyrachyo", "Quinn", "Ace", "tOfu", "Seleri"}},
    {name = "TundraEsports", players = {"Skiter", "Nine", "33", "Sneyking", "Aui_2000"}},
    {name = "EvilGeniuses", players = {"Pakazs", "Chris Luck", "Wisper", "Matthew", "Panda"}},
    {name = "PSG_LGD", players = {"shiro", "NothingToSay", "niu 牛", "planet", "y`"}},
    {name = "ShopifyRebellion", players = {"Arteezy", "Abed", "SaberLight", "Cr1t-", "Fly"}},
    {name = "TalonEsports", players = {"23savage", "Mikoto", "Jabz", "Q", "Oli"}},
    {name = "beastcoast", players = {"K1", "Chris Luck", "Wisper", "Stinger", "Scofield"}},
    {name = "Spirit", players = {"Yatoro雨", "Larl", "Collapse", "Mira", "Miposhka"}},
    {name = "TSM", players = {"Timado", "Bryle", "Kasane", "Ari", "Whitemon"}},
    {name = "BetBoom", players = {"Nightfall", "gpk", "Pure", "Save-", "TORONTOTOKYO"}},
    {name = "Execration", players = {"Palos", "Bob", "Tino", "Shanks", "Carlo"}},
    {name = "QuestEsports", players = {"TA2000", "No!ob", "Tobi", "OmaR", "kaori"}},
    {name = "nouns", players = {"Gunnar", "Costabile", "Moo", "ZFreek", "Husky"}},
    {name = "BleedEsports", players = {"JaCkky", "Kordan", "iceiceice", "DJ", "DuBu"}},
    {name = "Aster", players = {"Monet", "Xxs", "Ori", "BoBoKa", "LaNm"}},
    {name = "InvictusGaming", players = {"flyfly", "Emo", "JT-", "Kaka 卡卡", "Oli"}},
    {name = "AzureRay", players = {"Eurus", "Somnus丶M", "Yang", "Fy", "xNova"}},
    {name = "Blacklist", players = {"Raven", "Karl", "Kuku", "TIMS", "Eyyou"}},
    {name = "VirtusPro", players = {"RAMZES666", "kiyotaka", "MieRo", "Antares", "Solo"}},
    {name = "Additionals", players = { -- not really an actual team but random names in case there is a need to more names in a team e.g. 12 v 12
        "Azazel", "Lucifer", "Belial", "Lilith", "Diablo", "Mephisto", "Asmodeus", "Beelzebub", "Samael", "Abaddon", "Mammon", "Astaroth",
        "Leviathan", "Moloch", "Belphegor", "Apollyon", "Gorgoth", "Zaganthar", "Nyxoloth", "Malphas", "Inferno", "Darkfire", "Shadowblade",
        "Nightmare", "Hellspawn", "Bloodlust", "Doombringer", "Soulreaper", "Deathbringer", "Lightbringer", "Celestial", "Heavenly", "Seraphim",
        "Radiant", "Divinity", "Archangel", "Gloriosa", "Holystone", "Etherealis", "Heavenfire"
    }}
}

local function generateTeam(overrides)
    local playerList = { }
    local randomNum = 0
    
    if overrides and #overrides > 0 then
        playerList = overrides
    else
        repeat
            randomNum = RandomInt(1, #defaultTeams)
        -- ensure a team can only pick from certain team names.
        until randomNum % 2 == GetTeam() - 2 and defaultTeams[randomNum].name ~= 'Additionals'
        -- print('randomNum='..tostring(randomNum)..', team name='..tostring(defaultTeams[randomNum].name)..', for team='..tostring(GetTeam()))
        playerList = Utils.MergeLists(defaultTeams[randomNum].players, defaultTeams[#defaultTeams].players)
    end

    local team = { }
    for i = 1, maxTeamSize do
        if overrides and #overrides > 0 then
            table.insert(team, table.remove(playerList, 1))
        else
            table.insert(team, defaultTeams[randomNum].name .. "." .. table.remove(playerList, 1)..'.'..defaultPostfix)
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
