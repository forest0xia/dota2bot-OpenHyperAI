local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local hHeroList = {
    ['npc_dota_hero_abaddon'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {12,10,8,6},
    },
    ['npc_dota_hero_abyssal_underlord'] = {
        engage_score = 8,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {16,15,14,13},
    },
    ['npc_dota_hero_alchemist'] = {
        engage_score = 4,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {22,21,20,19},
    },
    ['npc_dota_hero_ancient_apparition'] = {
        engage_score = 6,
        retreat_score = 4,
        is_good_to_morph_back = false,
        time_len = {10,8,6,4},
    },
    ['npc_dota_hero_antimage'] = {
        engage_score = 3,
        retreat_score = 9,
        is_good_to_morph_back = true,
        time_len = {12,10,8,6},
    },
    ['npc_dota_hero_arc_warden'] = {
        engage_score = 4,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {16,16,16,16},
    },
    ['npc_dota_hero_axe'] = {
        engage_score = 3,
        retreat_score = 9,
        is_good_to_morph_back = false,
        time_len = {20,15,10,5},
    },
    ['npc_dota_hero_bane'] = {
        engage_score = 5,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {28,21,14,7},
    },
    ['npc_dota_hero_batrider'] = {
        engage_score = 3,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {22,19,16,13},
    },
    ['npc_dota_hero_beastmaster'] = {
        engage_score = 3,
        retreat_score = 9,
        is_good_to_morph_back = false,
        time_len = {8,8,8,8}
    },
    ['npc_dota_hero_bloodseeker'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {14,12,10,8},
    },
    ['npc_dota_hero_bounty_hunter'] = {
        engage_score = 2,
        retreat_score = 6,
        is_good_to_morph_back = false,
        time_len = {5,5,5,5},
    },
    ['npc_dota_hero_brewmaster'] = {
        engage_score = 3,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {22,19,16,13},
    },
    ['npc_dota_hero_bristleback'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {6,6,6,6},
    },
    ['npc_dota_hero_broodmother'] = {
        engage_score = 5,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {45,40,35,30},
    },
    ['npc_dota_hero_centaur'] = {
        engage_score = 2,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {18,16,14,12},
    },
    ['npc_dota_hero_chaos_knight'] = {
        engage_score = 6,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {13,12,11,10},
    },
    ['npc_dota_hero_chen'] = {
        engage_score = 4,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {14,13,12,11},
    },
    ['npc_dota_hero_clinkz'] = {
        engage_score = 3,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {30,25,20,15},
    },
    ['npc_dota_hero_crystal_maiden'] = {
        engage_score = 8,
        retreat_score = 8,
        is_good_to_morph_back = true,
        time_len = {9,8,7,6},
    },
    ['npc_dota_hero_dark_seer'] = {
        engage_score = 2,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {9,9,9,9},
    },
    ['npc_dota_hero_dark_willow'] = {
        engage_score = 6,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {17,15,13,11},
    },
    ['npc_dota_hero_dawnbreaker'] = {
        engage_score = 6,
        retreat_score = 4,
        is_good_to_morph_back = true,
        time_len = {18,16,14,12},
    },
    ['npc_dota_hero_dazzle'] = {
        engage_score = 7,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {12,11,10,9},
    },
    ['npc_dota_hero_death_prophet'] = {
        engage_score = 4,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {9,8,7,6},
    },
    ['npc_dota_hero_disruptor'] = {
        engage_score = 8,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {18,15,12,9},
    },
    ['npc_dota_hero_doom_bringer'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {41,39,37,35},
    },
    ['npc_dota_hero_dragon_knight'] = {
        engage_score = 3,
        retreat_score = 7,
        is_good_to_morph_back = true,
        time_len = {16,14,12,10},
    },
    ['npc_dota_hero_drow_ranger'] = {
        engage_score = 2,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {19,17,15,13},
    },
    ['npc_dota_hero_earth_spirit'] = {
        engage_score = 8,
        retreat_score = 10,
        is_good_to_morph_back = true,
        time_len = {16,12,8,4},
    },
    ['npc_dota_hero_earthshaker'] = {
        engage_score = 10,
        retreat_score = 7,
        is_good_to_morph_back = true,
        time_len = {5,5,5,5},
    },
    ['npc_dota_hero_elder_titan'] = {
        engage_score = 1,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {14,13,12,11},
    },
    ['npc_dota_hero_ember_spirit'] = {
        engage_score = 5,
        retreat_score = 4,
        is_good_to_morph_back = true,
        time_len = {13,11,9,7},
    },
    ['npc_dota_hero_enchantress'] = {
        engage_score = 2,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {30,24,18,12},
    },
    ['npc_dota_hero_enigma'] = {
        engage_score = 3,
        retreat_score = 9,
        is_good_to_morph_back = false,
        time_len = {20,18,16,14},
    },
    ['npc_dota_hero_faceless_void'] = {
        engage_score = 5,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {24,18,12,6},
    },
    ['npc_dota_hero_furion'] = {
        engage_score = 5,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {14,12,10,8},
    },
    ['npc_dota_hero_grimstroke'] = {
        engage_score = 8,
        retreat_score = 4,
        is_good_to_morph_back = true,
        time_len = {11,9,7,5},
    },
    ['npc_dota_hero_gyrocopter'] = {
        engage_score = 6,
        retreat_score = 4,
        is_good_to_morph_back = true,
        time_len = {26,24,22,20},
    },
    ['npc_dota_hero_hoodwink'] = {
        engage_score = 5,
        retreat_score = 3,
        is_good_to_morph_back = true,
        time_len = {16,14,12,10},
    },
    ['npc_dota_hero_huskar'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {17,15,13,11},
    },
    ['npc_dota_hero_invoker'] = {
        engage_score = 5,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {3,3,3,3},
    },
    ['npc_dota_hero_jakiro'] = {
        engage_score = 5,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {18,15,12,9},
    },
    ['npc_dota_hero_juggernaut'] = {
        engage_score = 3,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {42,34,26,18},
    },
    ['npc_dota_hero_keeper_of_the_light'] = {
        engage_score = 2,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {25,22,19,16},
    },
    ['npc_dota_hero_kunkka'] = {
        engage_score = 4,
        retreat_score = 4,
        is_good_to_morph_back = true,
        time_len = {30,24,18,12},
    },
    ['npc_dota_hero_legion_commander'] = {
        engage_score = 6,
        retreat_score = 4,
        is_good_to_morph_back = true,
        time_len = {16,15,14,13},
    },
    ['npc_dota_hero_leshrac'] = {
        engage_score = 5,
        retreat_score = 4,
        is_good_to_morph_back = true,
        time_len = {4,4,4,4},
    },
    ['npc_dota_hero_lich'] = {
        engage_score = 6,
        retreat_score = 2,
        is_good_to_morph_back = true,
        time_len = {30,25,20,15},
    },
    ['npc_dota_hero_life_stealer'] = {
        engage_score = 5,
        retreat_score = 4,
        is_good_to_morph_back = true,
        time_len = {20,19,18,17},
    },
    ['npc_dota_hero_lina'] = {
        engage_score = 6,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {13,11,9,7},
    },
    ['npc_dota_hero_lion'] = {
        engage_score = 10,
        retreat_score = 10,
        is_good_to_morph_back = true,
        time_len = {14,13,12,11},
    },
    ['npc_dota_hero_lone_druid'] = {
        engage_score = 1,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {38,32,26,20},
    },
    ['npc_dota_hero_luna'] = {
        engage_score = 4,
        retreat_score = 2,
        is_good_to_morph_back = true,
        time_len = {9,8,7,6},
    },
    ['npc_dota_hero_lycan'] = {
        engage_score = 7,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {22,20,18,16},
    },
    ['npc_dota_hero_magnataur'] = {
        engage_score = 4,
        retreat_score = 7,
        is_good_to_morph_back = true,
        time_len = {8,8,8,8},
    },
    ['npc_dota_hero_marci'] = {
        engage_score = 3,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {16,14,12,10},
    },
    ['npc_dota_hero_mars'] = {
        engage_score = 6,
        retreat_score = 4,
        is_good_to_morph_back = true,
        time_len = {14,13,12,11},
    },
    ['npc_dota_hero_medusa'] = {
        engage_score = 1,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {15,14,13,12},
    },
    ['npc_dota_hero_meepo'] = {
        engage_score = 2,
        retreat_score = 4,
        is_good_to_morph_back = false,
        time_len = {16,14,12,10},
    },
    ['npc_dota_hero_mirana'] = {
        engage_score = 3,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {12,12,12,12},
    },
    -- ['npc_dota_hero_morphling']          = { time_len = {0}, },
    ['npc_dota_hero_monkey_king'] = {
        engage_score = 3,
        retreat_score = 4,
        is_good_to_morph_back = false,
        time_len = {24,21,18,15},
    },
    ['npc_dota_hero_muerta'] = {
        engage_score = 5,
        retreat_score = 3,
        is_good_to_morph_back = true,
        time_len = {16,14,12,10},
    },
    ['npc_dota_hero_naga_siren'] = {
        engage_score = 2,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {21,18,15,12},
    },
    ['npc_dota_hero_necrolyte'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {8,7,6,5},
    },
    ['npc_dota_hero_nevermore'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {9,9,9,9},
    },
    ['npc_dota_hero_night_stalker'] = {
        engage_score = 5,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {11,10,9,8},
    },
    ['npc_dota_hero_nyx_assassin'] = {
        engage_score = 6,
        retreat_score = 6,
        is_good_to_morph_back = true,
        time_len = {18,16,14,12},
    },
    ['npc_dota_hero_obsidian_destroyer'] = {
        engage_score = 2,
        retreat_score = 6,
        is_good_to_morph_back = true,
        time_len = {18,16,14,12},
    },
    ['npc_dota_hero_ogre_magi'] = {
        engage_score = 7,
        retreat_score = 7,
        is_good_to_morph_back = true,
        time_len = {11,10,9,8},
    },
    ['npc_dota_hero_omniknight'] = {
        engage_score = 2,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {18,16,14,12},
    },
    ['npc_dota_hero_oracle'] = {
        engage_score = 2,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {20,17,14,11},
    },
    ['npc_dota_hero_pangolier'] = {
        engage_score = 5,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {18,16,14,12},
    },
    ['npc_dota_hero_phantom_lancer'] = {
        engage_score = 1,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {6,6,6,6},
    },
    ['npc_dota_hero_phantom_assassin'] = {
        engage_score = 3,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {10,9,8,7},
    },
    ['npc_dota_hero_phoenix'] = {
        engage_score = 2,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {50,40,30,20},
    },
    ['npc_dota_hero_primal_beast'] = {
        engage_score = 2,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {30,27,24,21},
    },
    ['npc_dota_hero_puck'] = {
        engage_score = 6,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {11,10,9,8},
    },
    ['npc_dota_hero_pudge'] = {
        engage_score = 5,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {18,16,14,12},
    },
    ['npc_dota_hero_pugna'] = {
        engage_score = 4,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {5,5,5,5},
    },
    ['npc_dota_hero_queenofpain'] = {
        engage_score = 7,
        retreat_score = 10,
        is_good_to_morph_back = true,
        time_len = {12,10,8,6},
    },
    ['npc_dota_hero_rattletrap'] = {
        engage_score = 2,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {20,18,16,14},
    },
    ['npc_dota_hero_razor'] = {
        engage_score = 8,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {13,12,11,10},
    },
    ['npc_dota_hero_riki'] = {
        engage_score = 2,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {17,15,13,11},
    },
    ['npc_dota_hero_ringmaster'] = {
        engage_score = 4,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {16,14,12,10},
    },
    ['npc_dota_hero_rubick'] = {
        engage_score = 3,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {16,14,12,10},
    },
    ['npc_dota_hero_sand_king'] = {
        engage_score = 9,
        retreat_score = 8,
        is_good_to_morph_back = true,
        time_len = {14,13,12,11},
    },
    ['npc_dota_hero_shadow_demon'] = {
        engage_score = 6,
        retreat_score = 5,
        is_good_to_morph_back = false,
        time_len = {26,22,18,14},
    },
    ['npc_dota_hero_shadow_shaman'] = {
        engage_score = 5,
        retreat_score = 7,
        is_good_to_morph_back = true,
        time_len = {24,20,16,12},
    },
    ['npc_dota_hero_shredder'] = {
        engage_score = 4,
        retreat_score = 6,
        is_good_to_morph_back = true,
        time_len = {7.5,7,6.5,6},
    },
    ['npc_dota_hero_silencer'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {22,20,18,16},
    },
    ['npc_dota_hero_skeleton_king'] = {
        engage_score = 2,
        retreat_score = 5,
        is_good_to_morph_back = false,
        time_len = {17,14,11,8},
    },
    ['npc_dota_hero_skywrath_mage'] = {
        engage_score = 4,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {14,14,14,14},
    },
    ['npc_dota_hero_slardar'] = {
        engage_score = 3,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {7,7,7,7},
    },
    ['npc_dota_hero_slark'] = {
        engage_score = 6,
        retreat_score = 6,
        is_good_to_morph_back = true,
        time_len = {9,8,7,6},
    },
    ["npc_dota_hero_snapfire"] = {
        engage_score = 4,
        retreat_score = 5,
        is_good_to_morph_back = false,
        time_len = {24,20,16,12},
    },
    ['npc_dota_hero_sniper'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {20,18,16,14},
    },
    ['npc_dota_hero_spectre'] = {
        engage_score = 1,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {22,20,18,16},
    },
    ['npc_dota_hero_spirit_breaker'] = {
        engage_score = 5,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {22,19,16,13},
    },
    ['npc_dota_hero_storm_spirit'] = {
        engage_score = 2,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {20,18,16,14},
    },
    ['npc_dota_hero_sven'] = {
        engage_score = 3,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {21,18,15,12},
    },
    ['npc_dota_hero_techies'] = {
        engage_score = 5,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {16,13,10,7},
    },
    ['npc_dota_hero_templar_assassin'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {16,16,16,16},
    },
    ['npc_dota_hero_terrorblade'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {23,20,17,14},
    },
    ['npc_dota_hero_tidehunter'] = {
        engage_score = 3,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {12,12,12,12},
    },
    ['npc_dota_hero_tinker'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {20,20,20,20},
    },
    ['npc_dota_hero_tiny'] = {
        engage_score = 7,
        retreat_score = 7,
        is_good_to_morph_back = true,
        time_len = {23,20,17,14},
    },
    ['npc_dota_hero_treant'] = {
        engage_score = 3,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {30,25,20,15},
    },
    ['npc_dota_hero_troll_warlord'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {9,9,9,9},
    },
    ['npc_dota_hero_tusk'] = {
        engage_score = 3,
        retreat_score = 5,
        is_good_to_morph_back = false,
        time_len = {23,20,17,14},
    },
    ['npc_dota_hero_undying'] = {
        engage_score = 1,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {13,10,7,4},
    },
    ['npc_dota_hero_ursa'] = {
        engage_score = 3,
        retreat_score = 3,
        is_good_to_morph_back = false,
        time_len = {12,11,10,9},
    },
    ['npc_dota_hero_vengefulspirit'] = {
        engage_score = 4,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {16,14,12,10},
    },
    ['npc_dota_hero_venomancer'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {21,20,19,18},
    },
    ['npc_dota_hero_viper'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {14,14,14,14},
    },
    ['npc_dota_hero_visage'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {17,15,13,11},
    },
    ['npc_dota_hero_void_spirit'] = {
        engage_score = 6,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {20,17,14,11},
    },
    ['npc_dota_hero_warlock'] = {
        engage_score = 4,
        retreat_score = 2,
        is_good_to_morph_back = false,
        time_len = {15,14,13,12},
    },
    ['npc_dota_hero_weaver'] = {
        engage_score = 2,
        retreat_score = 7,
        is_good_to_morph_back = true,
        time_len = {15,12,9,6},
    },
    ['npc_dota_hero_windrunner']  = {
        engage_score = 4,
        retreat_score = 5,
        is_good_to_morph_back = true,
        time_len = {24,21,18,15},
    },
    ['npc_dota_hero_wisp'] = {
        engage_score = 2,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {25,22,19,16},
    },
    ['npc_dota_hero_witch_doctor'] = {
        engage_score = 5,
        retreat_score = 4,
        is_good_to_morph_back = false,
        time_len = {20,18,16,14},
    },
    ['npc_dota_hero_zuus'] = {
        engage_score = 3,
        retreat_score = 1,
        is_good_to_morph_back = false,
        time_len = {6,6,6,6},
    },
}

function X.GetMorphEngageScore(hName)
    if hHeroList[hName] ~= nil and hHeroList[hName].engage_score ~= nil then
        return hHeroList[hName].engage_score
    end

    return 0.1
end

function X.GetMorphRetreatScore(hName)
    if hHeroList[hName] ~= nil and hHeroList[hName].retreat_score ~= nil then
        if hHeroList[hName].retreat_score >= 5 then
            return hHeroList[hName].retreat_score
        end
    end

    return -1
end

function X.IsGoodToMorphBack(hName)
    if hHeroList[hName] ~= nil and hHeroList[hName].is_good_to_morph_back ~= nil then
        return hHeroList[hName].is_good_to_morph_back
    end

    return false
end

function X.GetMorphLength(bot, hName)
    local len = 0
    if hHeroList[hName] ~= nil then
        if bot:GetLevel() <= 6 then
            len = hHeroList[hName].time_len[1]
        elseif bot:GetLevel() <= 9 then
            len = hHeroList[hName].time_len[2]
        elseif bot:GetLevel() <= 12 then
            len = hHeroList[hName].time_len[3]
        else
            len = hHeroList[hName].time_len[4]
        end
    end

    return len
end

return X