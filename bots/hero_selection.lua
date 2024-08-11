local X = {}
local sSelectHero = "npc_dota_hero_zuus"
local fLastSlectTime, fLastRand = 5, 0
local nDelayTime = nil
local nHumanCount = 0
local sBanList = {}
local sSelectList = {}
local tSelectPoolList = {}
local tLaneAssignList = {}

local bUserMode = false
local bLaneAssignActive = true
local bLineupReserve = false
local overridePicks = false

local MU = require( GetScriptDirectory()..'/FunLib/aba_matchups' )
local Role = require( GetScriptDirectory()..'/FunLib/aba_role' )
local Chat = require( GetScriptDirectory()..'/FunLib/aba_chat' )
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local Dota2Teams = require( GetScriptDirectory()..'/FunLib/aba_team_names' )
local Overrides = require( GetScriptDirectory()..'/FunLib/aba_global_overrides' )
local CM = require( GetScriptDirectory()..'/FunLib/captain_mode' )
local Customize = require( GetScriptDirectory()..'/Customize/general' )
local HeroSet = {}
local SupportedHeroes = {}
local UseCustomizedPicks = false

--[[
'npc_dota_hero_abaddon',
'npc_dota_hero_abyssal_underlord',
'npc_dota_hero_alchemist',
'npc_dota_hero_ancient_apparition',
'npc_dota_hero_antimage',
'npc_dota_hero_arc_warden',
'npc_dota_hero_axe',
'npc_dota_hero_bane',
'npc_dota_hero_batrider',
'npc_dota_hero_beastmaster',
'npc_dota_hero_bloodseeker',
'npc_dota_hero_bounty_hunter',
'npc_dota_hero_brewmaster',
'npc_dota_hero_bristleback',
'npc_dota_hero_broodmother',
'npc_dota_hero_centaur',
'npc_dota_hero_chaos_knight',
'npc_dota_hero_chen',
'npc_dota_hero_clinkz',
'npc_dota_hero_crystal_maiden',
'npc_dota_hero_dark_seer',
'npc_dota_hero_dark_willow',
'npc_dota_hero_dazzle',
'npc_dota_hero_disruptor',
'npc_dota_hero_death_prophet',
'npc_dota_hero_doom_bringer',
'npc_dota_hero_dragon_knight',
'npc_dota_hero_drow_ranger',
'npc_dota_hero_earth_spirit',
'npc_dota_hero_earthshaker',
'npc_dota_hero_elder_titan',
'npc_dota_hero_ember_spirit',
'npc_dota_hero_enchantress',
'npc_dota_hero_enigma',
'npc_dota_hero_faceless_void',
'npc_dota_hero_furion',
'npc_dota_hero_grimstroke',
'npc_dota_hero_gyrocopter',
'npc_dota_hero_huskar',
'npc_dota_hero_invoker',
'npc_dota_hero_jakiro',
'npc_dota_hero_juggernaut',
'npc_dota_hero_keeper_of_the_light',
'npc_dota_hero_kunkka',
'npc_dota_hero_legion_commander',
'npc_dota_hero_leshrac',
'npc_dota_hero_lich',
'npc_dota_hero_life_stealer',
'npc_dota_hero_lina',
'npc_dota_hero_lion',
'npc_dota_hero_lone_druid',
'npc_dota_hero_luna',
'npc_dota_hero_lycan',
'npc_dota_hero_magnataur',
'npc_dota_hero_mars',
'npc_dota_hero_medusa',
'npc_dota_hero_meepo',
'npc_dota_hero_mirana',
'npc_dota_hero_morphling',
'npc_dota_hero_monkey_king',
'npc_dota_hero_naga_siren',
'npc_dota_hero_necrolyte',
'npc_dota_hero_nevermore',
'npc_dota_hero_night_stalker',
'npc_dota_hero_nyx_assassin',
'npc_dota_hero_obsidian_destroyer',
'npc_dota_hero_ogre_magi',
'npc_dota_hero_omniknight',
'npc_dota_hero_oracle',
'npc_dota_hero_pangolier',
'npc_dota_hero_phantom_lancer',
'npc_dota_hero_phantom_assassin',
'npc_dota_hero_phoenix',
'npc_dota_hero_puck',
'npc_dota_hero_pudge',
'npc_dota_hero_pugna',
'npc_dota_hero_queenofpain',
'npc_dota_hero_rattletrap',
'npc_dota_hero_razor',
'npc_dota_hero_riki',
'npc_dota_hero_rubick',
'npc_dota_hero_sand_king',
'npc_dota_hero_shadow_demon',
'npc_dota_hero_shadow_shaman',
'npc_dota_hero_shredder',
'npc_dota_hero_silencer',
'npc_dota_hero_skeleton_king',
'npc_dota_hero_skywrath_mage',
'npc_dota_hero_slardar',
'npc_dota_hero_slark',
"npc_dota_hero_snapfire",
'npc_dota_hero_sniper',
'npc_dota_hero_spectre',
'npc_dota_hero_spirit_breaker',
'npc_dota_hero_storm_spirit',
'npc_dota_hero_sven',
'npc_dota_hero_techies',
'npc_dota_hero_terrorblade',
'npc_dota_hero_templar_assassin',
'npc_dota_hero_tidehunter',
'npc_dota_hero_tinker',
'npc_dota_hero_tiny',
'npc_dota_hero_treant',
'npc_dota_hero_troll_warlord',
'npc_dota_hero_tusk',
'npc_dota_hero_undying',
'npc_dota_hero_ursa',
'npc_dota_hero_vengefulspirit',
'npc_dota_hero_venomancer',
'npc_dota_hero_viper',
'npc_dota_hero_visage',
'npc_dota_hero_void_spirit',
'npc_dota_hero_warlock',
'npc_dota_hero_weaver',
'npc_dota_hero_windrunner',
'npc_dota_hero_winter_wyvern',
'npc_dota_hero_wisp',
'npc_dota_hero_witch_doctor',
'npc_dota_hero_zuus',
'npc_dota_hero_hoodwink',
'npc_dota_hero_dawnbreaker',
'npc_dota_hero_marci',
'npc_dota_hero_primal_beast',
--]]


local sPos1List = {
	"npc_dota_hero_abaddon",
	"npc_dota_hero_alchemist",
	"npc_dota_hero_antimage",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_faceless_void",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_life_stealer",
	"npc_dota_hero_lina",
	"npc_dota_hero_luna",
	"npc_dota_hero_lycan",
	"npc_dota_hero_medusa",
	"npc_dota_hero_meepo",
	"npc_dota_hero_morphling",
	"npc_dota_hero_muerta", -- Weak
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_razor",
	"npc_dota_hero_riki",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_slark",
	"npc_dota_hero_spectre",
	"npc_dota_hero_sniper",
	"npc_dota_hero_sven",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_ursa",
	"npc_dota_hero_weaver",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_invoker",
	"npc_dota_hero_lone_druid",
}

local sPos2List = {
	"npc_dota_hero_abaddon",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_bane",
	"npc_dota_hero_batrider",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_bounty_hunter",
	'npc_dota_hero_bristleback',
	"npc_dota_hero_broodmother",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_doom_bringer",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_earth_spirit",
	"npc_dota_hero_ember_spirit",
	"npc_dota_hero_huskar",
	"npc_dota_hero_invoker",
	"npc_dota_hero_invoker", -- increase the chance of having mid Invoker.
	"npc_dota_hero_invoker",
	"npc_dota_hero_rubick",
	"npc_dota_hero_rubick",
	-- "npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_lina",
	"npc_dota_hero_lycan",
	"npc_dota_hero_meepo",
	"npc_dota_hero_monkey_king",
	"npc_dota_hero_morphling",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_pangolier",
	-- "npc_dota_hero_primal_beast", -- still passive
	"npc_dota_hero_puck",
	"npc_dota_hero_pugna",
	"npc_dota_hero_pudge",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_razor",
	"npc_dota_hero_silencer",
	"npc_dota_hero_slardar",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_sniper",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_storm_spirit",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_tinker", -- TOO WEAK
	"npc_dota_hero_tiny",
	"npc_dota_hero_tusk",
	"npc_dota_hero_viper",
	"npc_dota_hero_visage",
	"npc_dota_hero_void_spirit",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_winter_wyvern", -- TOO WEAK
	"npc_dota_hero_zuus",
	"npc_dota_hero_lone_druid",
}

local sPos3List = {
	"npc_dota_hero_abaddon",
	"npc_dota_hero_abyssal_underlord",
	"npc_dota_hero_axe",
	"npc_dota_hero_batrider",
	"npc_dota_hero_beastmaster",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_brewmaster",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_centaur",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_dark_seer",
	"npc_dota_hero_dawnbreaker",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_doom_bringer",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_earthshaker",
	'npc_dota_hero_enchantress',
	"npc_dota_hero_enigma",
	"npc_dota_hero_furion",
	"npc_dota_hero_huskar",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_lycan",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_marci", -- still passive
	"npc_dota_hero_mars",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_night_stalker",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_pangolier",
	"npc_dota_hero_primal_beast", -- still passive
	"npc_dota_hero_pudge",
	"npc_dota_hero_razor",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_shredder",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_slardar",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_tiny",
	"npc_dota_hero_riki",
	"npc_dota_hero_tusk",
	"npc_dota_hero_viper",
	"npc_dota_hero_visage",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_invoker",
	"npc_dota_hero_lone_druid",
	-- "npc_dota_hero_winter_wyvern", -- TOO WEAK
}

local sPos4List = {
	"npc_dota_hero_abaddon",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_bane",
	"npc_dota_hero_batrider",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_chen",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_dark_willow", -- still passive
	"npc_dota_hero_dawnbreaker",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_earthshaker",
	'npc_dota_hero_earth_spirit',
	"npc_dota_hero_elder_titan", -- still passive
	"npc_dota_hero_enchantress",
	"npc_dota_hero_enigma",
	"npc_dota_hero_furion",
	"npc_dota_hero_grimstroke",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_hoodwink", -- Weak
	"npc_dota_hero_jakiro",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_lich",
	"npc_dota_hero_lina",
	"npc_dota_hero_lion",
	"npc_dota_hero_mirana",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_oracle",
	"npc_dota_hero_phoenix",  -- TOO WEAK
	"npc_dota_hero_pudge",
	"npc_dota_hero_pugna",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_rubick",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_silencer",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_techies",
	"npc_dota_hero_tiny",
	"npc_dota_hero_treant",
	"npc_dota_hero_tusk",
	"npc_dota_hero_undying",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_warlock",
	"npc_dota_hero_weaver",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_winter_wyvern", -- TOO WEAK
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_zuus",
	"npc_dota_hero_invoker",
	"npc_dota_hero_wisp",
}

local sPos5List = {
	"npc_dota_hero_abaddon",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_bane",
	"npc_dota_hero_batrider",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_chen",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_dark_willow", -- still passive
	"npc_dota_hero_dawnbreaker",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_earth_spirit",
	-- "npc_dota_hero_elder_titan", -- still passive
	"npc_dota_hero_enchantress",
	"npc_dota_hero_enigma",
	"npc_dota_hero_furion",
	"npc_dota_hero_grimstroke",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_hoodwink", -- Weak
	"npc_dota_hero_jakiro",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_lich",
	"npc_dota_hero_lina",
	"npc_dota_hero_lion",
	"npc_dota_hero_mirana",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_oracle",
	"npc_dota_hero_phoenix",  -- TOO WEAK
	"npc_dota_hero_pudge",
	"npc_dota_hero_pugna",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_rubick",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_silencer",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_techies",
	"npc_dota_hero_tiny",
	"npc_dota_hero_treant",
	"npc_dota_hero_tusk",
	"npc_dota_hero_undying",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_warlock",
	"npc_dota_hero_weaver",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_zuus",
}

-- A list of to be improved heroes. They maybe selected for bots, but shouldn't have more than one in a team to ensure the bar of gaming experience for human players.
-- Weak due to 1, some have bugs from Valve side, I try my best to improve. 2, I'm not familir with the hero game play itself, or it's not easy hero in terms of do it with coding.
local WeakHeroes = {
	-- Weaks, meaning they are too far from being able to apply their power:
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

	-- Buggys, meaning they have bugs on Valves side, as of (still) 2024/8/1:
    'npc_dota_hero_muerta',
    'npc_dota_hero_marci',
    'npc_dota_hero_lone_druid',
    'npc_dota_hero_primal_beast',
    'npc_dota_hero_dark_willow',
    'npc_dota_hero_elder_titan',
    'npc_dota_hero_hoodwink',
    'npc_dota_hero_wisp',

	-- Lost some abilities due to Facet updates in 7.37 that they do not select a default facet that defines the ability.
	'npc_dota_hero_faceless_void',
	'npc_dota_hero_magnataur',
}

local SelectedWeakHero = 0
local MaxWeakHeroCount = 1

-- Combine hero list
SupportedHeroes = Utils.CombineTablesUnique(SupportedHeroes, sPos1List)
SupportedHeroes = Utils.CombineTablesUnique(SupportedHeroes, sPos2List)
SupportedHeroes = Utils.CombineTablesUnique(SupportedHeroes, sPos3List)
SupportedHeroes = Utils.CombineTablesUnique(SupportedHeroes, sPos4List)
SupportedHeroes = Utils.CombineTablesUnique(SupportedHeroes, sPos5List)

if Customize and not Customize.Enable then Customize = nil end

-- Role weight for now, heroes synergy later
-- Might take DotaBuff or others role weights once other pos are added
function X.GetAdjustedPool(heroList, pos)
	local sTempList = {}
	local sHeroList = {										-- pos  1, 2, 3, 4, 5
		{name = 'npc_dota_hero_abaddon', 					role = {5, 5, 25, 15, 50}},
		{name = 'npc_dota_hero_abyssal_underlord', 			role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_alchemist', 					role = {50, 30, 20, 0, 0}},
		{name = 'npc_dota_hero_ancient_apparition', 		role = {0, 5, 0, 25, 70}},
		{name = 'npc_dota_hero_antimage', 					role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_arc_warden', 				role = {20, 80, 0, 0, 0}},
		{name = 'npc_dota_hero_axe',	 					role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_bane', 						role = {0, 15, 0, 25, 60}},
		{name = 'npc_dota_hero_batrider', 					role = {0, 10, 10, 50, 30}},
		{name = 'npc_dota_hero_beastmaster', 				role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_bloodseeker', 				role = {65, 20, 15, 0, 0}},
		{name = 'npc_dota_hero_bounty_hunter', 				role = {0, 25, 10, 50, 15}},
		{name = 'npc_dota_hero_brewmaster', 				role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_bristleback', 				role = {10, 10, 80, 0, 0}},
		{name = 'npc_dota_hero_broodmother', 				role = {0, 80, 20, 0, 0}},
		{name = 'npc_dota_hero_centaur', 					role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_chaos_knight', 				role = {60, 0, 40, 0, 0}},
		{name = 'npc_dota_hero_chen', 						role = {0, 0, 0, 0, 100}},
		{name = 'npc_dota_hero_clinkz', 					role = {45, 30, 0, 20, 5}},
		{name = 'npc_dota_hero_crystal_maiden', 			role = {0, 0, 0, 15, 85}},
		{name = 'npc_dota_hero_dark_seer', 					role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_dark_willow', 				role = {0, 0, 0, 100, 10}},--nil
		{name = 'npc_dota_hero_dawnbreaker', 				role = {0, 5, 70, 15, 10}},
		{name = 'npc_dota_hero_dazzle', 					role = {0, 20, 0, 20, 60}},
		{name = 'npc_dota_hero_disruptor', 					role = {0, 0, 0, 25, 75}},
		{name = 'npc_dota_hero_death_prophet', 				role = {0, 50, 50, 0, 0}},
		{name = 'npc_dota_hero_doom_bringer', 				role = {0, 10, 90, 0, 0}},
		{name = 'npc_dota_hero_dragon_knight', 				role = {5, 35, 60, 0, 0}},
		{name = 'npc_dota_hero_drow_ranger', 				role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_earth_spirit', 				role = {0, 45, 10, 40, 5}},
		{name = 'npc_dota_hero_earthshaker', 				role = {0, 15, 25, 50, 10}},
		{name = 'npc_dota_hero_elder_titan', 				role = {0, 0, 0, 100, 100}},--nil
		{name = 'npc_dota_hero_ember_spirit', 				role = {0, 100, 0, 0, 0}},
		{name = 'npc_dota_hero_enchantress', 				role = {0, 0, 10, 30, 60}},
		{name = 'npc_dota_hero_enigma', 					role = {0, 0, 60, 25, 15}},
		{name = 'npc_dota_hero_faceless_void', 				role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_furion', 					role = {0, 0, 10, 60, 30}},
		{name = 'npc_dota_hero_grimstroke', 				role = {0, 0, 0, 45, 55}},
		{name = 'npc_dota_hero_gyrocopter', 				role = {50, 0, 0, 30, 20}},
		{name = 'npc_dota_hero_hoodwink', 					role = {0, 0, 0, 100, 20}},--nil
		{name = 'npc_dota_hero_huskar', 					role = {0, 90, 10, 0, 0}},
		{name = 'npc_dota_hero_invoker', 					role = {0, 100, 0, 0, 0}},
		{name = 'npc_dota_hero_jakiro', 					role = {0, 0, 0, 30, 70}},
		{name = 'npc_dota_hero_juggernaut', 				role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_keeper_of_the_light', 		role = {0, 75, 0, 20, 5}},
		{name = 'npc_dota_hero_kunkka', 					role = {0, 40, 60, 0, 0}},
		{name = 'npc_dota_hero_legion_commander', 			role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_leshrac', 					role = {0, 90, 10, 0, 0}},
		{name = 'npc_dota_hero_lich', 						role = {0, 0, 0, 20, 80}},
		{name = 'npc_dota_hero_life_stealer', 				role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_lina', 						role = {5, 75, 0, 15, 5}},
		{name = 'npc_dota_hero_lion', 						role = {0, 0, 0, 35, 65}},
		{name = 'npc_dota_hero_lone_druid', 				role = {50, 100, 50, 0, 0}},--nil
		{name = 'npc_dota_hero_luna', 						role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_lycan', 						role = {5, 25, 70, 0, 0}},
		{name = 'npc_dota_hero_magnataur', 					role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_marci',	 					role = {50, 0, 100, 0, 0}},--nil
		{name = 'npc_dota_hero_mars', 						role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_medusa', 					role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_meepo', 						role = {20, 80, 0, 0, 0}},
		{name = 'npc_dota_hero_mirana', 					role = {0, 0, 0, 60, 40}},
		{name = 'npc_dota_hero_morphling', 					role = {95, 5, 0, 0, 0}},
		{name = 'npc_dota_hero_monkey_king', 				role = {70, 30, 0, 0, 0}},
		{name = 'npc_dota_hero_naga_siren', 				role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_necrolyte', 					role = {0, 70, 30, 0, 0}},
		{name = 'npc_dota_hero_nevermore', 					role = {35, 65, 0, 0, 0}},
		{name = 'npc_dota_hero_night_stalker', 				role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_nyx_assassin', 				role = {0, 0, 0, 85, 15}},
		{name = 'npc_dota_hero_obsidian_destroyer', 		role = {0, 100, 0, 0, 0}},
		{name = 'npc_dota_hero_ogre_magi', 					role = {0, 5, 15, 30, 50}},
		{name = 'npc_dota_hero_omniknight', 				role = {0, 15, 75, 5, 5}},
		{name = 'npc_dota_hero_oracle', 					role = {0, 0, 0, 20, 80}},
		{name = 'npc_dota_hero_pangolier', 					role = {0, 80, 20, 0, 0}},
		{name = 'npc_dota_hero_phantom_lancer', 			role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_phantom_assassin', 			role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_phoenix', 					role = {0, 0, 0, 50, 50}},
		{name = 'npc_dota_hero_primal_beast', 				role = {0, 100, 100, 0, 0}},--nil
		{name = 'npc_dota_hero_puck', 						role = {0, 100, 0, 0, 0}},
		{name = 'npc_dota_hero_pudge', 						role = {0, 20, 25, 35, 20}},
		{name = 'npc_dota_hero_pugna', 						role = {0, 20, 0, 45, 35}},
		{name = 'npc_dota_hero_queenofpain', 				role = {0, 100, 0, 0, 0}},
		{name = 'npc_dota_hero_rattletrap', 				role = {0, 0, 0, 55, 45}},
		{name = 'npc_dota_hero_razor', 						role = {30, 20, 50, 0, 0}},
		{name = 'npc_dota_hero_riki', 						role = {65, 35, 0, 0, 0}},
		{name = 'npc_dota_hero_rubick', 					role = {0, 0, 0, 70, 30}},
		{name = 'npc_dota_hero_sand_king', 					role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_shadow_demon', 				role = {0, 0, 0, 45, 55}},
		{name = 'npc_dota_hero_shadow_shaman', 				role = {0, 0, 0, 35, 65}},
		{name = 'npc_dota_hero_shredder', 					role = {0, 40, 60, 0, 0}},
		{name = 'npc_dota_hero_silencer', 					role = {0, 10, 0, 35, 55}},
		{name = 'npc_dota_hero_skeleton_king', 				role = {100, 0, 50, 0, 0}},
		{name = 'npc_dota_hero_skywrath_mage', 				role = {0, 0, 0, 70, 30}},
		{name = 'npc_dota_hero_slardar', 					role = {0, 10, 90, 0, 0}},
		{name = 'npc_dota_hero_slark', 						role = {100, 0, 0, 0, 0}},
		{name = "npc_dota_hero_snapfire", 					role = {0, 20, 0, 50, 30}},
		{name = 'npc_dota_hero_sniper', 					role = {25, 75, 0, 0, 0}},
		{name = 'npc_dota_hero_spectre', 					role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_spirit_breaker', 			role = {0, 10, 35, 50, 5}},
		{name = 'npc_dota_hero_storm_spirit', 				role = {0, 100, 0, 0, 0}},
		{name = 'npc_dota_hero_sven', 						role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_techies', 					role = {0, 0, 0, 60, 40}},
		{name = 'npc_dota_hero_terrorblade', 				role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_templar_assassin', 			role = {45, 55, 0, 0, 0}},
		{name = 'npc_dota_hero_tidehunter', 				role = {0, 0, 100, 0, 0}},
		{name = 'npc_dota_hero_tinker', 					role = {0, 100, 0, 0, 0}},
		{name = 'npc_dota_hero_tiny', 						role = {0, 25, 15, 55, 5}},
		{name = 'npc_dota_hero_treant', 					role = {0, 0, 0, 20, 80}},
		{name = 'npc_dota_hero_troll_warlord', 				role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_tusk', 						role = {0, 10, 15, 55, 20}},
		{name = 'npc_dota_hero_undying', 					role = {0, 0, 0, 25, 75}},
		{name = 'npc_dota_hero_ursa', 						role = {100, 0, 0, 0, 0}},
		{name = 'npc_dota_hero_vengefulspirit', 			role = {0, 0, 0, 35, 65}},
		{name = 'npc_dota_hero_venomancer', 				role = {0, 0, 0, 35, 65}},
		{name = 'npc_dota_hero_viper', 						role = {0, 60, 40, 0, 0}},
		{name = 'npc_dota_hero_visage', 					role = {0, 50, 50, 0, 0}},
		{name = 'npc_dota_hero_void_spirit', 				role = {0, 100, 0, 0, 0}},
		{name = 'npc_dota_hero_warlock', 					role = {0, 0, 0, 25, 75}},
		{name = 'npc_dota_hero_weaver', 					role = {70, 0, 10, 15, 5}},
		{name = 'npc_dota_hero_windrunner', 				role = {15, 30, 30, 20, 5}},
		{name = 'npc_dota_hero_winter_wyvern', 				role = {0, 15, 25, 30, 30}},
		{name = 'npc_dota_hero_wisp', 						role = {0, 0, 0, 50, 100}},
		{name = 'npc_dota_hero_witch_doctor', 				role = {0, 0, 0, 30, 70}},
		{name = 'npc_dota_hero_zuus', 						role = {0, 80, 0, 15, 5}},
	}

	for i = 1, #heroList
	do
		for _, hero in pairs(sHeroList)
		do
			if  hero.name == heroList[i]
			and hero.role[pos] >= RandomInt(0, 100)
			then
				table.insert(sTempList, hero.name)
			end
		end
	end

	if #sTempList == 0
	then
		table.insert(sTempList, heroList[RandomInt(1, #heroList)])
	end

	return sTempList
end

sPos1List = X.GetAdjustedPool(sPos1List, 1)
sPos2List = X.GetAdjustedPool(sPos2List, 2)
sPos3List = X.GetAdjustedPool(sPos3List, 3)
sPos4List = X.GetAdjustedPool(sPos4List, 4)
sPos5List = X.GetAdjustedPool(sPos5List, 5)

tSelectPoolList = {
	[1] = sPos1List,
	[2] = sPos2List,
	[3] = sPos3List,
	[4] = sPos4List,
	[5] = sPos5List,
}

sSelectList = {
	[1] = tSelectPoolList[1][RandomInt( 1, #tSelectPoolList[1] )],
	[2] = tSelectPoolList[2][RandomInt( 1, #tSelectPoolList[2] )],
	[3] = tSelectPoolList[3][RandomInt( 1, #tSelectPoolList[3] )],
	[4] = tSelectPoolList[4][RandomInt( 1, #tSelectPoolList[4] )],
	[5] = tSelectPoolList[5][RandomInt( 1, #tSelectPoolList[5] )],
}

local tDefaultLaningDire = {
	[1] = LANE_TOP,
	[2] = LANE_MID,
	[3] = LANE_BOT,
	[4] = LANE_BOT,
	[5] = LANE_TOP,
}

tLaneAssignList = {
	-- 天辉夜宴的上下路相反
	TEAM_RADIANT = {
		[1] = LANE_BOT,
		[2] = LANE_MID,
		[3] = LANE_TOP,
		[4] = LANE_TOP,
		[5] = LANE_BOT,
	},
	TEAM_DIRE = Utils.Deepcopy(tDefaultLaningDire)
}

local MidOnlyLaneAssignment = {
	[1] = LANE_MID,
	[2] = LANE_MID,
	[3] = LANE_MID,
	[4] = LANE_MID,
	[5] = LANE_MID,
}
local OneVoneLaneAssignment = {
	[1] = LANE_MID,
	[2] = LANE_TOP,
	[3] = LANE_TOP,
	[4] = LANE_TOP,
	[5] = LANE_TOP,
};

if Customize then
	if GetTeam() == TEAM_RADIANT and Customize.Radiant_Heros then
		for i = 1, #Customize.Radiant_Heros do
			local hero = Customize.Radiant_Heros[i]
			if hero and hero ~= 'Random' and Utils.HasValue(SupportedHeroes, hero) then
				sSelectList[i] = hero
				UseCustomizedPicks = true
			end
		end
	elseif GetTeam() == TEAM_DIRE and Customize.Dire_Heros then
		for i = 1, #Customize.Dire_Heros do
			local hero = Customize.Dire_Heros[i]
			if hero and hero ~= 'Random' and Utils.HasValue(SupportedHeroes, hero) then
				sSelectList[i] = hero
				UseCustomizedPicks = true
			end
		end
	end
end

function X.ShuffleArray(array)
	if type(array) ~= "table" then
        error("Expected a table, got " .. type(array))
    end

    local n = #array
    for i = n, 2, -1 do
        local j = RandomInt(1, i)
        array[i], array[j] = array[j], array[i]  -- Swap elements
    end
    return array
end

function X.ShufflePickOrder(teamPlayers)
	local shuffleSelection = X.ShuffleArray({1, 2, 3, 4, 5})
	-- print('Random pick order: '..table.concat(shuffleSelection, ", "))
	for i = 1, #shuffleSelection do
		local targetIndex = shuffleSelection[i]
		if IsPlayerBot(teamPlayers[i]) and IsPlayerBot(teamPlayers[targetIndex]) then
			-- print('Shuffle team '..GetTeam()..', swap '..i.." with "..targetIndex)
			sSelectList[i], sSelectList[targetIndex] = sSelectList[targetIndex], sSelectList[i]
			tSelectPoolList[i], tSelectPoolList[targetIndex] = tSelectPoolList[targetIndex], tSelectPoolList[i]
			tLaneAssignList['TEAM_RADIANT'][i], tLaneAssignList['TEAM_RADIANT'][targetIndex] = tLaneAssignList['TEAM_RADIANT'][targetIndex], tLaneAssignList['TEAM_RADIANT'][i]
			tLaneAssignList['TEAM_DIRE'][i], tLaneAssignList['TEAM_DIRE'][targetIndex] = tLaneAssignList['TEAM_DIRE'][targetIndex], tLaneAssignList['TEAM_DIRE'][i]
			Role.roleAssignment['TEAM_RADIANT'][i], Role.roleAssignment['TEAM_RADIANT'][targetIndex] = Role.roleAssignment['TEAM_RADIANT'][targetIndex], Role.roleAssignment['TEAM_RADIANT'][i]
			Role.roleAssignment['TEAM_DIRE'][i], Role.roleAssignment['TEAM_DIRE'][targetIndex] = Role.roleAssignment['TEAM_DIRE'][targetIndex], Role.roleAssignment['TEAM_DIRE'][i]
		end
	end
end

function X.GetMoveTable( nTable )

	local nLenth = #nTable
	local temp = nTable[nLenth]

	table.remove( nTable, nLenth )
	table.insert( nTable, 1, temp )

	return nTable

end

function X.IsExistInTable( sString, sStringList )

	for _, sTemp in pairs( sStringList )
	do
		if sString == sTemp then return true end
	end

	return false
end

function X.IsHumanNotReady( nTeam )

	if GameTime() > 20 or bLineupReserve then return false end

	local humanCount, readyCount = 0, 0
	local nIDs = GetTeamPlayers( nTeam )
	for i, id in pairs( nIDs )
	do
        if not IsPlayerBot( id )
		then
			humanCount = humanCount + 1
			if GetSelectedHeroName( id ) ~= ""
			then
				readyCount = readyCount + 1
			end
		end
    end

	if( readyCount >= humanCount )
	then
		return false
	end

	return true
end

function X.GetNotRepeatHero( nTable )

	local sHero = nTable[1]
	local maxCount = #nTable
	local nRand = 0
	local bRepeated = false

	for count = 1, maxCount
	do
		nRand = RandomInt( 1, #nTable )
		sHero = nTable[nRand]
		bRepeated = false
		for id = 0, 20
		do
			if ( IsTeamPlayer( id ) and GetSelectedHeroName( id ) == sHero )
				or ( IsCMBannedHero( sHero ) )
				or ( X.IsBannedHero( sHero ) )
				or ( X.SkipPickingWeakHeroes(sHero) )
			then
				bRepeated = true
				table.remove( nTable, nRand )
				break
			end
		end
		if not bRepeated then break end
	end

	return sHero
end

function X.IsRepeatHero( sHero )
	if Customize and Customize.Allow_Repeated_Heroes then
		return false
	end

	for id = 0, 20
	do
		if ( IsTeamPlayer( id ) and GetSelectedHeroName( id ) == sHero )
			or ( IsCMBannedHero( sHero ) )
			or ( X.IsBannedHero( sHero ) )
			or ( X.SkipPickingWeakHeroes(sHero) )
		then
			return true
		end
	end

	return false
end

-- limit the number and chance the weak heroes can be picked.
function X.SkipPickingWeakHeroes(sHero)
	if Customize and Customize.Allow_Repeated_Heroes then
		return false
	end

	return Utils.HasValue(WeakHeroes, sHero)
	and SelectedWeakHero >= MaxWeakHeroCount
end

if Customize and Customize.Ban
then
	sBanList = Customize.Ban
end

function X.SetChatHeroBan( sChatText )
	sBanList[#sBanList + 1] = string.lower( sChatText )
end

function X.IsBannedHero( sHero )

	for i = 1, #sBanList
	do
		if sBanList[i] ~= nil
		   and string.find( sHero, sBanList[i] )
		then
			return true
		end
	end

	return false
end

local sTeamName = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'

function X.GetCurrentTeam(nTeam, bEnemy)
	local nHeroList = {}
	for i, id in pairs(GetTeamPlayers(nTeam))
	do
		local hName = GetSelectedHeroName(id)
		if hName ~= nil and hName ~= ''
		then
			if bEnemy then
				table.insert(nHeroList, {name=hName, pos=Role.GetBestEffortSuitableRole(hName)})
			else
				table.insert(nHeroList, {name=hName, pos=Role.roleAssignment[sTeamName][i] })
			end
		end
	end

	return nHeroList
end

function X.GetBestHeroFromPool(i, nTeamList)
	local sBestHero = ''
	local nHeroes = {}

	for j = 1, #nTeamList
	do
		local hName = nTeamList[j].name
		for _, sName in pairs(tSelectPoolList[i])
		do
			if  (MU.IsSynergy(hName, sName) or MU.IsSynergy(sName, hName))
			and not X.IsRepeatHero(sName)
			then
				if nHeroes[sName] == nil then nHeroes[sName] = {} end
				if nHeroes[sName]['count'] == nil then nHeroes[sName]['count'] = 1 end
				nHeroes[sName]['count'] = nHeroes[sName]['count'] + 1
			end
		end
	end

	local c = -1
	for k1, v1 in pairs(nHeroes)
	do
		for k2, v2 in pairs(nHeroes[k1])
		do
			if not X.IsRepeatHero(k1)
			then
				if  v2 > 0 and c > 0 and v2 == c
				and RandomInt(1, 2) == 1
				then
					sBestHero = k1
				end

				if v2 > c
				then
					c = v2
					sBestHero = k1
				end
			end
		end
	end

	return sBestHero
end

function X.GetCurrEnmCores(nEnmTeam)
	local nCurrCores = {}
	for i = 1, #nEnmTeam
	do
		if nEnmTeam[i].pos >= 1 and nEnmTeam[i].pos <= 2
		then
			table.insert(nCurrCores, nEnmTeam[i].name)
		end
	end

	return nCurrCores
end

local ShuffledPickOrder = {
	TEAM_RADIANT = false,
	TEAM_DIRE = false,
}
local CorrectDireAssignedLanes = false
local CorrectDirePlayerIndexToLaneIndex = { }

function CorrectDireLaneAssignment()
	if GetTeam() == TEAM_DIRE and not CorrectDireAssignedLanes then
		-- lazy assignment, all humen on top of the list, bots on bottom.
		local index = 1
		for i, id in pairs( GetTeamPlayers(TEAM_DIRE) ) do
			local role = Role.roleAssignment['TEAM_DIRE'][i]
			if not IsPlayerBot( id ) then
				tLaneAssignList.TEAM_DIRE[index] = tDefaultLaningDire[role]
				CorrectDirePlayerIndexToLaneIndex[i] = index
				index = index + 1
			end
		end
		for i, id in pairs( GetTeamPlayers(TEAM_DIRE) ) do
			local role = Role.roleAssignment['TEAM_DIRE'][i]
			if IsPlayerBot( id ) then
				tLaneAssignList.TEAM_DIRE[index] = tDefaultLaningDire[role]
				CorrectDirePlayerIndexToLaneIndex[i] = index
				index = index + 1
			end
		end
		CorrectDireAssignedLanes = true
	end
end

function AllPickHeros()
	local teamPlayers = GetTeamPlayers(GetTeam())

	if not ShuffledPickOrder[sTeamName] and not IsHumanPlayerExist() then
		X.ShufflePickOrder(teamPlayers)
		ShuffledPickOrder[sTeamName] = true
	end
	
	local nOwnTeam = X.GetCurrentTeam(GetTeam(), false)
	local nEnmTeam = X.GetCurrentTeam(GetOpposingTeam(), true)

	for i, id in pairs( teamPlayers )
	do
		if IsPlayerBot( id ) and GetSelectedHeroName( id ) == "" and GameTime() >= fLastSlectTime + GetTeam() * 2
		then
			sSelectHero = sSelectList[i]

			-- Give a chance to pick counter/synergy heroes
			if not UseCustomizedPicks and RandomInt(1, 4) >= 3 then
				local nCurrEnmCores = X.GetCurrEnmCores(nEnmTeam)
				local selectCounter = nil

				-- Pick a random core in the current enemy comp to counter
				local nHeroToCounter = nCurrEnmCores[RandomInt(1, #nCurrEnmCores)]

				for j = 1, #tSelectPoolList[i], 1
				do
					local idx = RandomInt(1, #tSelectPoolList[i])
					local heroName = tSelectPoolList[i][idx]
					if not X.IsRepeatHero(heroName)
					and MU.IsCounter(heroName, nHeroToCounter) -- so it's not 'samey'; since bots don't really put pressure like a human would
					then
						print('Team '..GetTeam()..'. Counter pick. ', 'Selected: '..heroName, ' to counter: '..nHeroToCounter)
						selectCounter = heroName
						break
					end
				end

				if selectCounter ~= nil then
					sSelectHero = selectCounter
				else
					local synergy = X.GetBestHeroFromPool(i, nOwnTeam)
					if synergy ~= '' and synergy ~= nil then
						print('Team '..GetTeam()..'. Synergy pick. ', 'Selected: '..synergy)
						sSelectHero = synergy
					end
				end
			else
				print('Team '..GetTeam()..'. Skip picking counter/synergy heroes. For more chance to see any heroes')
			end

			if X.IsRepeatHero(sSelectHero) then sSelectHero = X.GetNotRepeatHero( tSelectPoolList[i] ) end
			if Utils.HasValue(WeakHeroes, sSelectHero) then SelectedWeakHero = SelectedWeakHero + 1 end
			SelectHero( id, sSelectHero )

			-- print('Selected hero for idx='..i..', id='..id..', bot='..sSelectHero)
			if Role["bLobbyGame"] == false then Role["bLobbyGame"] = true end
			fLastSlectTime = GameTime()
			fLastRand = RandomInt( 8, 28 )/10
			break
		end
	end
end

local RemainingPos = {
	TEAM_RADIANT = {'1', '2', '3', '4', '5'},
	TEAM_DIRE = {'1', '2', '3', '4', '5'},
}

-- Function to check if a string starts with "!"
local function startsWithExclamation(str)
    return string.len(str) > 3 and str:sub(1, 1) == "!"
end
-- Function to parse the command string
local function parseCommand(command)
    local action, target = command:match("^(%S+)%s+(.*)$")
    return action, target
end
local userSwitchedRole = false

-- Function to handle the command
local function handleCommand(command, PlayerID, bTeamOnly)
    local action, text = parseCommand(command)
	if action == nil then
		print('[WARN] Invalid command: '..tostring(command))
		return
	end
	if GetGameMode() == GAMEMODE_CM then
		print('[WARN] Captain mode does not support commands')
		return
	end

	local teamPlayers = GetTeamPlayers(GetTeam())

	print('Handling command: '..tostring(action)..', text: '..tostring(text))

    if action == "!pick" and GetGameMode() ~= GAMEMODE_CM then
        print("Picking hero " .. text)

		local hero = GetHumanChatHero(text);
		if hero ~= "" then
			if X.IsRepeatHero(hero) then
				print('Hero has already been picked')
				return
			end
			if bTeamOnly then
				for _, id in pairs(teamPlayers)
				do
					if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" then
						SelectHero(id, hero);
						break;
					end
				end
			elseif bTeamOnly == false and GetTeamForPlayer(PlayerID) ~= GetTeam() then
				for _, id in pairs(teamPlayers)
				do
					if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" then
						SelectHero(id, hero);
						break;
					end
				end
			end
			userSwitchedRole = true
		else
			print("Hero name not found or not supported! Please refer to the list of names here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Heroes_internal_names");
		end
    elseif action == "!ban" and GetGameState() == GAME_STATE_HERO_SELECTION then
        print("Banning hero " .. text)

		local hero = GetHumanChatHero(text);
		if hero ~= "" then
			if X.IsRepeatHero(hero) then
				print('Hero has already been picked')
				return
			end
			X.SetChatHeroBan( hero )
			print("Banned hero " .. hero.. '. Banned list:')
			Utils.PrintTable(sBanList)
		else
			print("Hero name not found or not supported! Please refer to the list of names here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Heroes_internal_names");
		end
    elseif action == "!pos" and GetGameState() == GAME_STATE_PRE_GAME then
        print("Selecting pos " .. text)
		local sTeamName = GetTeamForPlayer(PlayerID) == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
		local remainingPos = RemainingPos[sTeamName]
		if Utils.HasValue(remainingPos, text) then
			local role = tonumber(text)
			local playerIndex = PlayerID + 1 -- each team player id starts with 0, to 4 as the last player. 
			-- this index can be differnt if the player choose a slot in lobby that has empty slots before the one the player chooses.
			for idx, id in pairs(teamPlayers) do
				if id == PlayerID then playerIndex = idx end
			end

			for index, id in pairs(teamPlayers)
			do
				if Role.roleAssignment[sTeamName][index] == role then
					if IsPlayerBot(id) then
						-- remove so can't re-swap
						-- table.remove(RemainingPos[team], role)
						Role.roleAssignment[sTeamName][playerIndex], Role.roleAssignment[sTeamName][index] = role, Role.roleAssignment[sTeamName][playerIndex]
						if GetTeamForPlayer(PlayerID) == TEAM_DIRE then
							tLaneAssignList[sTeamName][CorrectDirePlayerIndexToLaneIndex[playerIndex]], tLaneAssignList[sTeamName][CorrectDirePlayerIndexToLaneIndex[index]] =
								tLaneAssignList[sTeamName][CorrectDirePlayerIndexToLaneIndex[index]], tLaneAssignList[sTeamName][CorrectDirePlayerIndexToLaneIndex[playerIndex]]
						else
							tLaneAssignList[sTeamName][playerIndex], tLaneAssignList[sTeamName][index] = tLaneAssignList[sTeamName][index], tLaneAssignList[sTeamName][playerIndex]
						end
						print('Switch role successfully. Team: '..sTeamName..
						'. Player Id: '..PlayerID..', idx: '..playerIndex..', new role: '..Role.roleAssignment[sTeamName][playerIndex]..
						'; Player Id: '..id..', idx: '..index..', new role: '..Role.roleAssignment[sTeamName][index])
					else
						print('Switch role failed, the target role belongs to human player. Ask the player directly to switch role.')
					end
					break;
				end
			end
		else
			print("Cannot select pos: " .. text..' because it is not available.')
		end
	else
        print("Unknown action: " .. action)
    end
end

function Think()
	if GetGameMode() == GAMEMODE_CM then
		CM.CaptainModeLogic(SupportedHeroes);
		CM.AddToList();
	elseif GetGameMode() == GAMEMODE_1V1MID then
		OneVsOneLogic()
	else
		if ( GameTime() < 3.0 and not bLineupReserve )
		or fLastSlectTime > GameTime() - fLastRand
		or X.IsHumanNotReady( GetTeam() )
		or X.IsHumanNotReady( GetOpposingTeam() )
		then
			if GetGameMode() ~= 23 then return end
		end

		if nDelayTime == nil then nDelayTime = GameTime() fLastRand = RandomInt( 12, 34 )/10 end
		if nDelayTime ~= nil and nDelayTime > GameTime() - fLastRand then return end

		AllPickHeros()
	end
end

--function to get hero name that match the expression
function GetHumanChatHero(name)
	if name == nil then return ""; end

	for _, hero in pairs(SupportedHeroes) do
		if string.find(hero, name) then
			return hero;
		end
	end
	print('Hero not supported with name: '..name)
	return "";
end
--function to decide which team should get the hero
function SelectHeroChatCallback(PlayerID, ChatText, bTeamOnly)
	local text = string.lower(ChatText);
	if startsWithExclamation(text) then
		handleCommand(text, PlayerID, bTeamOnly)
	end
end

-- Example of overrides with specific player names for Radiant
local playerNameOverrides = {
    Radiant = {},
    Dire = {}
}

if Customize then
	for i = 1, #Customize.Radiant_Names do
		if Customize.Radiant_Names[i] ~= nil then
			playerNameOverrides.Radiant[i] = Customize.Radiant_Names[i]
		end
	end
	for i = 1, #Customize.Dire_Names do
		if Customize.Dire_Names[i] ~= nil then
			playerNameOverrides.Dire[i] = Customize.Dire_Names[i]
		end
	end
end

local teamPlayerNames = Dota2Teams.generateTeams(playerNameOverrides)

function GetBotNames()
	return GetTeam() == TEAM_RADIANT and teamPlayerNames.Radiant or teamPlayerNames.Dire
end

local CMSupportAlreadyAssigned = {
	TEAM_RADIANT = false,
	TEAM_DIRE = false
};


--[[ Game Modes
GAMEMODE_NONE
GAMEMODE_AP = 1 -- All Pick
GAMEMODE_CM = 2 -- Captain Mode
GAMEMODE_RD = 3 -- Random Draft
GAMEMODE_SD = 4 -- Single Draft
GAMEMODE_AR = 5 -- All Random
GAMEMODE_REVERSE_CM
GAMEMODE_MO = 11 -- Mid Only
GAMEMODE_CD = 16
GAMEMODE_ABILITY_DRAFT
GAMEMODE_LP -- Least Played
GAMEMODE_ARDM
GAMEMODE_1V1MID = 21
GAMEMODE_ALL_DRAFT = 22 -- Ranked All Pick
GAMEMODE_TURBO = 23
]]

function UpdateLaneAssignments()

	local team = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'

	if GetGameMode() == GAMEMODE_MO then
		Role.roleAssignment[team] = {2, 2, 2, 2, 2}
		return MidOnlyLaneAssignment
	end
	if GetGameMode() == GAMEMODE_1V1MID then
		return OneVoneLaneAssignment
	end

	if GetGameMode() == GAMEMODE_CM then
		tLaneAssignList[team] = CM.CMLaneAssignment(Role.roleAssignment, userSwitchedRole)
		-- print('role assigment:')
		-- Utils.PrintTable(Role.roleAssignment.TEAM_RADIANT)
		-- print('lane assigment:' ..userSwitchedRole)
		-- Utils.PrintTable(CM.CMLaneAssignment(Role.roleAssignment, userSwitchedRole))
		-- AlignLanesBasedOnRoles(team)
		-- return tLaneAssignList[team]
	end

	if GetGameState() == GAME_STATE_HERO_SELECTION or GetGameState() == GAME_STATE_STRATEGY_TIME or GetGameState() == GAME_STATE_PRE_GAME then
		InstallChatCallback(function (attr) SelectHeroChatCallback(attr.player_id, attr.string, attr.team_only); end);
	end

	CorrectDireLaneAssignment()
	-- print('lane for team: '..team)
	-- Utils.PrintTable(tLaneAssignList[team])
	return tLaneAssignList[team]
end

-- Make sure the laning is in sync with the role assignment so bots won't keep switching lanings.
function AlignLanesBasedOnRoles(team)
	for idx, nRole in pairs(Role.roleAssignment[team]) do
		if nRole == 1 or nRole == 5 then
			if GetTeam() == TEAM_RADIANT then
				tLaneAssignList[team][idx] = LANE_BOT
			else
				tLaneAssignList[team][idx] = LANE_TOP
			end
		elseif nRole == 2 then
			tLaneAssignList[team][idx] = LANE_MID
		elseif nRole == 3 or nRole == 4 then
			if GetTeam() == TEAM_RADIANT then
				tLaneAssignList[team][idx] = LANE_TOP
			else
				tLaneAssignList[team][idx] = LANE_BOT
			end
		end
	end
end

local oboselect = false;
function OneVsOneLogic()
	local hero;
	if IsHumanPlayerExist() then
		oboselect = true;
	end

	for _, i in pairs(GetTeamPlayers(GetTeam())) do
		if not oboselect and IsPlayerBot(i) and IsPlayerInHeroSelectionControl(i) and GetSelectedHeroName(i) == ""
		then
			if IsHumanPresentInGame() then
				hero = GetSelectedHumanHero(GetOpposingTeam());
			else
				hero = X.GetNotRepeatHero( tSelectPoolList[2] );
			end
			if hero ~= nil then
				SelectHero(i, hero);
				oboselect = true;
				if Utils.HasValue(WeakHeroes, hero) then SelectedWeakHero = SelectedWeakHero + 1 end
			end
			return
		elseif oboselect and IsPlayerBot(i) and IsPlayerInHeroSelectionControl(i) and GetSelectedHeroName(i) == ""
		then
			SelectHero(i, 'npc_dota_hero_techies');
			return
		end
	end
end

--Check if human present in the game
function IsHumanPresentInGame()
	for i, id in pairs(GetTeamPlayers(GetTeam())) do
		if not IsPlayerBot(id)
		then
			return true;
		end
	end
	for i, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if not IsPlayerBot(id)
		then
			return true;
		end
	end
	return false;
end

--Get Human Selected Hero
function GetSelectedHumanHero(team)
	for i, id in pairs(GetTeamPlayers(team)) do
		if not IsPlayerBot(id) and GetSelectedHeroName(id) ~= ""
		then
			return GetSelectedHeroName(id);
		end
	end
end
