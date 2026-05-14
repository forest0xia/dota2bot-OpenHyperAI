if GetScriptDirectory == nil then GetScriptDirectory = function () return "bots" end end
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )

local Dota2Teams = { }

Dota2Teams.defaultPostfix = 'OHA' -- Open Hyper AI.
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

-- 古代神话故事主题 Teams
local ancientChineseStoryTeams = {
    -- 阴司鬼神
    {name = "阴司", players = {
        "钟馗", "阎罗", "孟婆", "判官", "黑无常", "白无常", "牛头", "马面"
    }},

    -- 天宫神将
    {name = "天宫", players = {
        "哪吒", "杨戬", "雷震", "李靖", "巨灵", "托塔", "哮天", "哪父"
    }},

    -- 妖魔鬼怪
    {name = "妖魔", players = {
        "饕餮", "穷奇", "梼杌", "混沌", "九婴", "无支祁", "相柳", "猰貐"
    }},

    -- 海川水灵
    {name = "水神", players = {
        "河伯", "海若", "风伯", "雨师", "水德", "洛神", "共工", "玄冥"
    }},

    -- 烈火雷霆
    {name = "火雷", players = {
        "祝融", "火神", "雷公", "电母", "赤焰", "炎帝", "火德", "金乌"
    }},

    -- 英魂战将
    {name = "英魂", players = {
        "刑天", "后羿", "夸父", "精卫", "黄帝", "炎帝", "神农", "蚩尤"
    }},
    -- 四象 Four Symbols
    {name = "灵兽", players = {"青龙", "白虎", "朱雀", "玄武", "腾蛇"}},
    -- 封神演义 Investiture of the Gods
    {name = "封神", players = {"姜子牙", "哪吒", "杨戬", "雷震子", "托塔天王"}},
    -- 三十六天罡 Heavenly Stars (sample)
    {name = "天罡", players = {"天勇", "天雄", "天猛", "天伤", "天英"}},
    -- 七十二地煞 Earthly Stars (sample)
    {name = "地煞", players = {"地勇", "地煞", "地俊", "地雄", "地恶"}},
    -- 山海经 Mythical figures
    {name = "山海", players = {"夸父", "共工", "精卫", "女娲", "伏羲"}},
    -- 上古异兽 Mythic Beasts
    {name = "异兽", players = {"饕餮", "烛龙", "穷奇", "梼杌", "狻猊"}},
    -- 风雷雨电 Weather Deities
    {name = "天象", players = {"雷公", "电母", "风伯", "雨师", "云华"}},
    -- 异世 Extra Pool (20 mythic characters)
    {name = "上古", players = {
        "蚩尤", "黄帝", "炎帝", "盘古", "女娲", "伏羲", "神农", "祝融", "共工", "刑天",
        "夸父", "后羿", "嫦娥", "西王母", "东皇太一", "玄冥", "羲和", "强良", "句芒", "应龙"
    }}
}

-- 随机使用古代神话故事主题 Teams
defaultTeams = RandomInt(1, 2) >= 2 and ancientChineseStoryTeams or defaultTeams

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
