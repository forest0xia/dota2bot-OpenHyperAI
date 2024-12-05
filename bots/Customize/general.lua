--[[
This is a place for you to customize the Open Hyper AI bots.

1. When modiftying this file, be VERY careful to the spelling, punctuation and variable names - it's very easy to cause 
   syntax errors and could be hard for you to debug.
2. In the case you saw the bots having some random names or picks (heroes not what you have set or without "OHA" name suffix), 
   that means you had made some mistakes/errors while modifying this file. 
3. In any case this file got messed up and caused the bots to malfunction, you can try to restore the file. Either you have a 
   copy to replace, or resubscribe the script, or download from github.
4. Note there is a list of known to-be-improved (aka weak) heroes, check out [Appendix - 2] on the bottom of this file.

- Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3246316298
- Github: https://github.com/forest0xia/dota2bot-OpenHyperAI
--]]


-- The variable to hold the settings. Only modify if you know exactly what you are doing.
local Customize = { }

-- Set it to true to turn on ALL of the custom settings in this file, or set it to false to turn off the settings.
Customize.Enable = true

-- Set the localization code to make bots speak the specific language when possible (not guaranteed to 100% localized). 
-- Currently supprot: "en" for "English", "zh" for "中文", "ru" for Russian, "ja" for Japanese
-- https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes
Customize.Localization = "en"

-- To ban some heroes for bots - Set the heroes you DO NOT want the bots to pick. Use hero internal names.
-- Hero name ref: https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4848777260032086340/
Customize.Ban = {
    'example_npc_dota_hero_internal_name_to_ban',
}

--[[
1. To pick heroes for the Radiant bots. You have to use hero's internal name.
2. Hero internal name ref: https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4848777260032086340/
3. Don't need to provide a value for all 5 bots, any empty/missing value will fallback to a Random value.
4. The position is ranked by the order of the names you put in the below list, pos 1 - 5, from top to down.
5. There are sample team picks in Appendix section below. 
6. Check Appendix to ensure you DO NOT pick more than 1 "weak" heroes in a team for your game experience.
--]]
Customize.Radiant_Heros = {
    'Random',
    'Random',
}

-- Same notes as above for picking heroes but for the Dire side.
Customize.Dire_Heros = {
    'Random',
}

--[[
1. To allow bots to randomly pick heroes that can be the same/repeated. 
2. WARNING: Setting this to true CAN reduce the gaming experience due to the fact some heroes are kind of weak or buggy
   at the moment (listed below) and are intentionally having reduced chances to get picked by bots. Setting this to true
   may cause the bots to pick multiple weak heroes. See Appendix below about "weak" heroes.
--]]
Customize.Allow_Repeated_Heroes = false

-- To set the names for the Radiant bots. Don't need to provide a value for all 5 bots, missing names will have a Random value.
Customize.Radiant_Names = {
    'Random',
    'Random',
}

-- Same notes as above for setting the bots' names but for the Dire side.
Customize.Dire_Names = {
    'Random',
}


return Customize




--[[

----------------------------------------------------------------------------------------------------
|                                        --- Appendix ---                                          |
----------------------------------------------------------------------------------------------------

[Appendix - 1] -- Some sample team picks: --

    -- -- All Pudges
    -- "npc_dota_hero_pudge",
    -- "npc_dota_hero_pudge",
    -- "npc_dota_hero_pudge",
    -- "npc_dota_hero_pudge",
    -- "npc_dota_hero_pudge",

    -- -- All Spirits/Pandas
    -- "npc_dota_hero_void_spirit",
    -- "npc_dota_hero_storm_spirit",
    -- "npc_dota_hero_ember_spirit",
    -- "npc_dota_hero_brewmaster",
    -- "npc_dota_hero_earth_spirit",

    -- -- Traditional -- --
    -- "npc_dota_hero_chaos_knight",
    -- "npc_dota_hero_sniper",
    -- "npc_dota_hero_axe",
    -- "npc_dota_hero_zuus",
    -- "npc_dota_hero_warlock",

    -- -- Rubick mid, and good team fights -- --
    -- "npc_dota_hero_clinkz",
    -- "npc_dota_hero_rubick",
    -- "npc_dota_hero_enigma",
    -- "npc_dota_hero_earth_spirit",
    -- "npc_dota_hero_techies",

    -- -- Invoker mid, and good team fights -- --
    -- "npc_dota_hero_arc_warden",
    -- 'npc_dota_hero_invoker',
    -- "npc_dota_hero_enigma",
    -- "npc_dota_hero_nyx_assassin",
    -- "npc_dota_hero_zuus",


[Appendix - 2] -- List of to-be-improved (aka weak) heroes, as of 2024/10/20 --

    They are relatively weaker than others and can still get selected by bots, 
    but there SHOULD NOT have more than 1 of those in a team to ensure the bar of gaming experience for human players.

    Those are weak due to:
        1, Some have bugs from Valve side, which I've spent a lot of effrot with to improve and fix things. 
        2, It's not easy to implement the hero in a good way in terms of doing it via coding with the code base we have.
        3, I do not play some of those heroes a lot myself so can't make good bots, 

    It's a matter of time to get everything improved, but I don't have a lot of time to do everything to make bots better. 
    So I put them here, and hopefully make it easy for you to use, or learn, or improve the script. 
    I'd appreciate any actual help from you to make the bots better, and I'm certain we can achieve it by contributing together.

    -- -- List A. Weak ones, meaning they are too far from being able to apply their power:
        'npc_dota_hero_chen',
        'npc_dota_hero_keeper_of_the_light',
        'npc_dota_hero_winter_wyvern',
        'npc_dota_hero_ancient_apparition',
        'npc_dota_hero_phoenix',
        'npc_dota_hero_tinker',
        'npc_dota_hero_pangolier',
        'npc_dota_hero_furion',
        'npc_dota_hero_tusk',
        'npc_dota_hero_morphling',
        'npc_dota_hero_visage',
        'npc_dota_hero_void_spirit',
        'npc_dota_hero_pudge',
        'npc_dota_hero_ember_spirit',

    -- -- List B. Buggy ones, meaning they have bugs on Valves side:
        'npc_dota_hero_muerta',
        'npc_dota_hero_marci',
        'npc_dota_hero_lone_druid',
        'npc_dota_hero_primal_beast',
        'npc_dota_hero_dark_willow',
        'npc_dota_hero_elder_titan',
        'npc_dota_hero_hoodwink',
        'npc_dota_hero_wisp',
]]--
