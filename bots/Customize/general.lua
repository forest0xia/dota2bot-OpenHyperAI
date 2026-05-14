--[[
This is a place for you to customize the Open Hyper AI bots.

1. When modiftying this file, be VERY careful to the spelling, punctuation and variable names - it's very easy to cause 
   syntax errors and mess up the entire logic for all bots, and could be hard for you to debug.
2. In the case you saw the bots having some random names or picks (heroes not what you have set or without "OHA" name suffix), 
   that means you had made some mistakes/errors while modifying this file. 
3. In any case this file got messed up and caused the bots to malfunction, you can try to restore the file. Either you have a 
   copy to replace, or resubscribe the script, or download from github.
4. To avoid these customize files from getting overridden by workshop updates, you can copy 
   the entire Customize folder to under: <Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts\game>
   and then modify the settings in <Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts\game\Customize> directory.
5. Note there is a list of known to-be-improved (aka weak) heroes, check out [Appendix - 2] on the bottom of this file.

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
-- Hero name ref: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/71
-- Please note that it is not 100% guaranteed that the banned hero will not be picked; for example if you banned too many heroes 
-- like near 100% of the heroes, bots will need to randomly pick heroes regardless of the ban list to continue the game.
Customize.Ban = {
    'example_npc_dota_hero_internal_name_to_ban',
}

--[[
1. To pick heroes for the Radiant bots. You have to use hero's internal name.
2. Hero internal name ref: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/71
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

-- The max number of weak heroes allowed in a team the bots can pick.
Customize.Weak_Hero_Cap = 1

-- The weak penalty curve for bots picking weak heroes:
--   { type="linear", k=0.25 }         ->  penalty = max(0, 1 - k * (weakPicked/cap))
--   { type="quad",   k=1.0 }          ->  penalty = (1 - min(1, weakPicked/cap))^2
--   { type="exp",    base=0.6 }       ->  penalty = base^(weakPicked)  (more weak -> smaller)
Customize.Weak_Penalty = { type = "exp", base = 0.6 }

-- Exact match on unit names by default; set Customize.Strict_Ban_Match = false to allow guarded substring matches (length ≥ 6).
Customize.Strict_Ban_Match = true

-- To allow bots do trash talking in different scenarios: got fb, killing a human, etc. Disable this also disables GPT chat.
Customize.Allow_Trash_Talk = true

-- To allow bots response with GPT generated text to your chats in global channel. Disable Allow_Trash_Talk can disable this.
Customize.Allow_AI_GPT_Response = true

-- Set the level of bots' trash talks. Disable Allow_Trash_Talk can disable this.
-- 1 => no trash talks from ally bots, no taunt from enemy after it gets a kill. 2 => ally bots also trash talk to you, allow taunt from enemy after it gets a kill.
Customize.Trash_Talk_Level = 1

-- To set the names for the Radiant bots. Don't need to provide a value for all 5 bots, missing names will have a Random value.
Customize.Radiant_Names = {
    'Random',
    'Random',
}

-- Same notes as above for setting the bots' names but for the Dire side.
Customize.Dire_Names = {
    'Random',
}

-- The desire level that the bots will group up and push the same lane. 
-- 1 is mild meaning bots will group up only when convenient; 3 is bots will almost always try to push together.
-- Group pushing may increase the difficulty but can reduce the game experience. 
Customize.Force_Group_Push_Level = 1

-- The Enhanced Fretbots mode settings:
-- For more about Fretbots mode: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/68
-- Note: these settings below will override the pre-defind settings in Fretbots folder.
Customize.Fretbots = {
    -- Default difficulty, a number between: [0, 10]
    Default_Difficulty = 2,

    -- Default ally bots bonus scale comparing to enemy bots, a number between: [0, 1]
    Default_Ally_Scale = 0.5,

    -- Set whether or not allowing the team to vote for difficulty. If false, will directly apply the default difficulty.
    Allow_To_Vote = true,

    -- Set to false disables all sounds from Fretbots mode
    Play_Sounds = true,

    -- Set to play chatwheel taunt sounds when human player died
    Player_Death_Sound = true,
}

-- Make bots think less, 0: fully think through, 1 to 10: think less and less frequently.
-- Bots can become slow or dumb in reaction and decision making if you set this value to a higher number.
-- When doing Local Host, you can potentially improve PC performance (FPS) by setting this to 1 to 10, which sacrifices some bot IQ/performance.
-- This won't be very effective for FPS improvement because Valve has a lot of compute on their side that your PC have to handle for Local Hosting.
Customize.ThinkLess = 1;

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
