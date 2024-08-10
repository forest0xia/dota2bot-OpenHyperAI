--[[

This is a place for you to customize the Open Hyper AI bots.

Be very careful to the punctuation and variable modification - it's very easy to cause syntax errors and could be hard for you to debug.
In the case you see the bots are having some random names, it means you made some mistakes/errors while modifying this file. 
In any case this file got messed up and caused the bots to malfunction, you can try to restore the file. Either you have a copy to replace, or resubscribe the script, or download from github.

Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3246316298
Github: https://github.com/forest0xia/dota2bot-OpenHyperAI

--]]

-- Variable to hold the settings. Only modify if you know exactly what you are doing.
local Customize = { }

-- Set it to true to turn on ALL of the custom settings in this file, or set it to false to turn off the settings.
Customize['Enable'] = true

-- Set the heroes you DON'T want the bots to pick. Use hero internal names.
-- Hero name ref: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Heroes_internal_names
Customize['Ban'] = {
    'npc_dota_hero_wisp',
}

-- Set the heroes you want Radiant bots to pick. Don't need to provide a value for all 5 bots, any empty value will fallback to a Random value.
-- Hero name ref: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Heroes_internal_names
Customize['Radiant_Heros'] = {
    [1] = 'Random',
    [2] = 'Random',
    [3] = 'Random',
}

-- Set the heroes you want Dire bots to pick. Don't need to provide a value for all 5 bots, any empty value will fallback to a Random value.
-- Hero name ref: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Heroes_internal_names
Customize['Dire_Heros'] = {
    [1] = 'Random',
    [4] = 'Random',
    [5] = 'Random',

    -- -- Some sample picks: -- --

    -- -- All Pandas/spirits
    -- [1] = "npc_dota_hero_void_spirit",
    -- [2] = "npc_dota_hero_storm_spirit",
    -- [3] = "npc_dota_hero_ember_spirit",
    -- [4] = "npc_dota_hero_brewmaster",
    -- [5] = "npc_dota_hero_earth_spirit",

    -- -- Traditional
    -- [1] = "npc_dota_hero_chaos_knight",
    -- [2] = "npc_dota_hero_sniper",
    -- [3] = "npc_dota_hero_axe",
    -- [4] = "npc_dota_hero_zuus",
    -- [5] = "npc_dota_hero_warlock",

    -- -- Rubick mid, and good team fights
    -- [1] = "npc_dota_hero_clinkz",
    -- [2] = "npc_dota_hero_rubick",
    -- [3] = "npc_dota_hero_enigma",
    -- [4] = "npc_dota_hero_earth_spirit",
    -- [5] = "npc_dota_hero_techies",

    -- -- Invoker mid 1, and good team fights
    -- [1] = "npc_dota_hero_chaos_knight",
    -- [2] = 'npc_dota_hero_invoker',
    -- [3] = "npc_dota_hero_legion_commander",
    -- [4] = "npc_dota_hero_nyx_assassin",
    -- [5] = "npc_dota_hero_zuus",

    -- -- Invoker mid 2, and good team fights
    -- [1] = "npc_dota_hero_chaos_knight",
    -- [2] = 'npc_dota_hero_invoker',
    -- [3] = "npc_dota_hero_enigma",
    -- [4] = "npc_dota_hero_zuus",
    -- [5] = "npc_dota_hero_techies",
}

-- Set the names of the heroes for Radiant bots. Don't need to provide a value for all 5 bots, any empty value will fallback to a Random value.
Customize['Radiant_Names'] = {
    'Hello World',
    'Random',
}

-- Set the names of the heroes for Dire bots. Don't need to provide a value for all 5 bots, any empty value will fallback to a Random value.
Customize['Dire_Names'] = {
    'EZ',
}

-- If true, the customized bot names will NOT have the team name prefix and suffix.
Customize['No_Team_Name_Affix'] = true


return Customize