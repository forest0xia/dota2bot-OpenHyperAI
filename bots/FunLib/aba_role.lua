local X = {}

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )

----------------------------------------------------------------------------------------------------

-- The index in the list is the pick order, value is the role.
-- X.roleAssignment = { 2, 3, 1, 5, 4 }
X.roleAssignment = {
	TEAM_RADIANT = { 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5 },
	TEAM_DIRE = { 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5 }
}


-- ["carry"] will become more useful later in the game if they gain a significant gold advantage.
-- ["durable"] has the ability to last longer in teamfights.
-- ["support"] can focus less on amassing gold and items, and more on using their abilities to gain an advantage for the team.
-- ["escape"] has the ability to quickly avoid death.
-- ["nuker"] can quickly kill enemy heroes using high damage spells with low cooldowns.
-- ["pusher"] can quickly siege and destroy towers and barracks at all points of the game.
-- ["disabler"] has a guaranteed disable for one or more of their spells.
-- ["initiator"] good at starting a teamfight.
-- ["jungler"] can farm effectively from neutral creeps inside the jungle early in the game.

X["hero_roles"] = {
	["npc_dota_hero_abaddon"] = {
		['carry'] = 1,
		['disabler'] = 0,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_alchemist"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_axe"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 3,
		['escape'] = 0,
		['initiator'] = 3,
		['jungler'] = 2,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_beastmaster"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_brewmaster"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_bristleback"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 3,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_centaur"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 3,
		['escape'] = 0,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_chaos_knight"] = {
		['carry'] = 3,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 2
	},

	["npc_dota_hero_rattletrap"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_doom_bringer"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_dragon_knight"] = {
		['carry'] = 2,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 3
	},

	["npc_dota_hero_earth_spirit"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 2,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_earthshaker"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_elder_titan"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_grimstroke"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_huskar"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_wisp"] = {
		['carry'] = 0,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 2,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_kunkka"] = {
		['carry'] = 1,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_legion_commander"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_life_stealer"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 2,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 1,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_lycan"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 1,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 1,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 3
	},

	["npc_dota_hero_magnataur"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_night_stalker"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_omniknight"] = {
		['carry'] = 0,
		['disabler'] = 0,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_phoenix"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 2,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_pudge"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_sand_king"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 2,
		['initiator'] = 3,
		['jungler'] = 1,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_slardar"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 2,
		['escape'] = 1,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_spirit_breaker"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 1,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_sven"] = {
		['carry'] = 2,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_tidehunter"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 3,
		['escape'] = 0,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_shredder"] = {
		['carry'] = 1,
		['disabler'] = 0,
		['durable'] = 2,
		['escape'] = 2,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_tiny"] = {
		['carry'] = 3,
		['disabler'] = 1,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 2
	},

	["npc_dota_hero_treant"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 1,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_tusk"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_abyssal_underlord"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 2,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_undying"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_skeleton_king"] = {
		['carry'] = 2,
		['disabler'] = 2,
		['durable'] = 3,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_antimage"] = {
		['carry'] = 3,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_arc_warden"] = {
		['carry'] = 3,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_bloodseeker"] = {
		['carry'] = 1,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 1,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_bounty_hunter"] = {
		['carry'] = 0,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 2,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_broodmother"] = {
		['carry'] = 1,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 3
	},

	["npc_dota_hero_clinkz"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 1
	},

	["npc_dota_hero_dark_willow"] = {
		['carry'] = 0,
		['disabler'] = 3,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_drow_ranger"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_ember_spirit"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_faceless_void"] = {
		['carry'] = 2,
		['disabler'] = 2,
		['durable'] = 1,
		['escape'] = 1,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_gyrocopter"] = {
		['carry'] = 3,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_juggernaut"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 1
	},

	["npc_dota_hero_lone_druid"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 1,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 3
	},

	["npc_dota_hero_luna"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_medusa"] = {
		['carry'] = 3,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_meepo"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 2,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 1
	},

	["npc_dota_hero_mirana"] = {
		['carry'] = 1,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 2,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_monkey_king"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 2,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_morphling"] = {
		['carry'] = 3,
		['disabler'] = 1,
		['durable'] = 2,
		['escape'] = 3,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_naga_siren"] = {
		['carry'] = 3,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 1,
		['pusher'] = 2
	},

	["npc_dota_hero_nyx_assassin"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_phantom_assassin"] = {
		['carry'] = 3,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_phantom_lancer"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 2,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 1
	},

	["npc_dota_hero_razor"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_riki"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 2,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_nevermore"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_slark"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_sniper"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_spectre"] = {
		['carry'] = 3,
		['disabler'] = 0,
		['durable'] = 1,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_templar_assassin"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_terrorblade"] = {
		['carry'] = 3,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 2
	},

	["npc_dota_hero_troll_warlord"] = {
		['carry'] = 3,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 1
	},

	["npc_dota_hero_ursa"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 1,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_vengefulspirit"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_venomancer"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 2,
		['pusher'] = 1
	},

	["npc_dota_hero_viper"] = {
		['carry'] = 3,
		['disabler'] = 1,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 1
	},

	["npc_dota_hero_weaver"] = {
		['carry'] = 2,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_ancient_apparition"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_bane"] = {
		['carry'] = 0,
		['disabler'] = 3,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_batrider"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 3,
		['jungler'] = 2,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_chen"] = {
		['carry'] = 0,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 3,
		['nuker'] = 0,
		['support'] = 2,
		['pusher'] = 2
	},

	["npc_dota_hero_crystal_maiden"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 1,
		['nuker'] = 2,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_dark_seer"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 1,
		['jungler'] = 1,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_dazzle"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_death_prophet"] = {
		['carry'] = 1,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 3
	},

	["npc_dota_hero_disruptor"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_enchantress"] = {
		['carry'] = 0,
		['disabler'] = 0,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 3,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 2
	},

	["npc_dota_hero_enigma"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 3,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 2
	},

	["npc_dota_hero_invoker"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 0,
		['pusher'] = 1
	},

	["npc_dota_hero_jakiro"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 1,
		['pusher'] = 2
	},

	["npc_dota_hero_keeper_of_the_light"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 1,
		['nuker'] = 2,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_leshrac"] = {
		['carry'] = 1,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 1,
		['pusher'] = 3
	},

	["npc_dota_hero_lich"] = {
		['carry'] = 0,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_lina"] = {
		['carry'] = 1,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_lion"] = {
		['carry'] = 0,
		['disabler'] = 3,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_furion"] = {
		['carry'] = 1,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 3,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 3
	},

	["npc_dota_hero_necrolyte"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_ogre_magi"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_oracle"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_obsidian_destroyer"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_pangolier"] = {
		['carry'] = 2,
		['disabler'] = 2,
		['durable'] = 1,
		['escape'] = 1,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_puck"] = {
		['carry'] = 0,
		['disabler'] = 3,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_pugna"] = {
		['carry'] = 0,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 2
	},

	["npc_dota_hero_queenofpain"] = {
		['carry'] = 1,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_rubick"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_shadow_demon"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_shadow_shaman"] = {
		['carry'] = 0,
		['disabler'] = 3,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 2,
		['pusher'] = 3
	},

	["npc_dota_hero_silencer"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_skywrath_mage"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 2,
		['pusher'] = 0
	},

	["npc_dota_hero_storm_spirit"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_techies"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_tinker"] = {
		['carry'] = 1,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 0,
		['pusher'] = 2
	},

	["npc_dota_hero_visage"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 1,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 1,
		['pusher'] = 1
	},

	["npc_dota_hero_warlock"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 2,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_windrunner"] = {
		['carry'] = 1,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_winter_wyvern"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_witch_doctor"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 2,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_mars"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 2,
		['escape'] = 0,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_zuus"] = {
		['carry'] = 0,
		['disabler'] = 0,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_void_spirit"] = {
		['carry'] = 2,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 3,
		['initiator'] = 1,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

	["npc_dota_hero_snapfire"] = {
		['carry'] = 0,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 3,
		['pusher'] = 0
	},
	
	["npc_dota_hero_hoodwink"] = {
		['carry'] = 2,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 3,
		['pusher'] = 0
	},
	
	["npc_dota_hero_dawnbreaker"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 3,
		['pusher'] = 0
	},
	
	["npc_dota_hero_marci"] = {
		['carry'] = 1,
		['disabler'] = 2,
		['durable'] = 0,
		['escape'] = 1,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 3,
		['support'] = 3,
		['pusher'] = 0
	},

	["npc_dota_hero_muerta"] = {
		['carry'] = 3,
		['disabler'] = 1,
		['durable'] = 0,
		['escape'] = 0,
		['initiator'] = 0,
		['jungler'] = 0,
		['nuker'] = 0,
		['support'] = 1,
		['pusher'] = 0
	},

	["npc_dota_hero_primal_beast"] = {
		['carry'] = 0,
		['disabler'] = 1,
		['durable'] = 3,
		['escape'] = 0,
		['initiator'] = 3,
		['jungler'] = 0,
		['nuker'] = 1,
		['support'] = 0,
		['pusher'] = 0
	},

}

X['invisHeroes'] = {
	['npc_dota_hero_templar_assassin'] = 1,
	['npc_dota_hero_clinkz'] = 1,
	['npc_dota_hero_mirana'] = 1,
	['npc_dota_hero_riki'] = 1,
	['npc_dota_hero_nyx_assassin'] = 1,
	['npc_dota_hero_bounty_hunter'] = 1,
	['npc_dota_hero_invoker'] = 1,
	['npc_dota_hero_sand_king'] = 1,
	['npc_dota_hero_treant'] = 1,
--	['npc_dota_hero_broodmother'] = 1,
	['npc_dota_hero_weaver'] = 1
}

function X.IsCarry( hero )
	if X["hero_roles"][hero] == nil then return false end
	return X["hero_roles"][hero]["carry"] > 0
end
function X.IsDisabler( hero )
	if X["hero_roles"][hero] == nil then return false end
	return X["hero_roles"][hero]["disabler"] > 0
end
function X.IsDurable( hero )
	if X["hero_roles"][hero] == nil then return false end
	return X["hero_roles"][hero]["durable"] > 0
end
function X.HasEscape( hero )
	if X["hero_roles"][hero] == nil then return false end
	return X["hero_roles"][hero]["escape"] > 0
end
function X.IsInitiator( hero )
	if X["hero_roles"][hero] == nil then return false end
	return X["hero_roles"][hero]["initiator"] > 0
end
function X.IsJungler( hero )
	if X["hero_roles"][hero] == nil then return false end
	return X["hero_roles"][hero]["jungler"] > 0
end
function X.IsNuker( hero )
	if X["hero_roles"][hero] == nil then return false end
	return X["hero_roles"][hero]["nuker"] > 0
end
function X.IsSupport( hero )
	if X["hero_roles"][hero] == nil then return false end
	return X["hero_roles"][hero]["support"] > 0
end
function X.IsPusher( hero )
	if X["hero_roles"][hero] == nil then return false end
	return X["hero_roles"][hero]["pusher"] > 0
end

function X.IsMelee( attackRange )
	return attackRange <= 326
end

X['off'] = {
	'npc_dota_hero_abaddon',
	'npc_dota_hero_abyssal_underlord',
	'npc_dota_hero_axe',
	'npc_dota_hero_batrider',
	'npc_dota_hero_beastmaster',
	'npc_dota_hero_brewmaster',
	'npc_dota_hero_bristleback',
	'npc_dota_hero_centaur',
	'npc_dota_hero_dark_seer',
	'npc_dota_hero_dawnbreaker',
	'npc_dota_hero_doom_bringer',
	'npc_dota_hero_enchantress',
	'npc_dota_hero_enigma',
	'npc_dota_hero_furion',
	'npc_dota_hero_legion_commander',
	'npc_dota_hero_leshrac',
	'npc_dota_hero_lycan',
	'npc_dota_hero_magnataur',
	'npc_dota_hero_marci',
	"npc_dota_hero_mars",
	'npc_dota_hero_night_stalker',
	'npc_dota_hero_omniknight',
	'npc_dota_hero_pangolier',
	'npc_dota_hero_primal_beast',
	'npc_dota_hero_pudge',
	'npc_dota_hero_rattletrap',
	'npc_dota_hero_sand_king',
	'npc_dota_hero_shredder',
	'npc_dota_hero_slardar',
	'npc_dota_hero_spirit_breaker',
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_visage',
	'npc_dota_hero_tusk',
	'npc_dota_hero_venomancer',
	'npc_dota_hero_windrunner',
	'npc_dota_hero_techies',
	'npc_dota_hero_rubick',
	'npc_dota_hero_earth_spirit',
	'npc_dota_hero_troll_warlord',
	'npc_dota_hero_invoker',
	'npc_dota_hero_tiny',
	'npc_dota_hero_ogre_magi',
	'npc_dota_hero_skeleton_king',
	'npc_dota_hero_zuus',
}

X['mid'] = {
	'npc_dota_hero_alchemist',
	'npc_dota_hero_arc_warden',
	'npc_dota_hero_batrider',
	'npc_dota_hero_bloodseeker',
	'npc_dota_hero_broodmother',
	'npc_dota_hero_clinkz',
	'npc_dota_hero_death_prophet',
	'npc_dota_hero_doom_bringer',
	'npc_dota_hero_dragon_knight',
	'npc_dota_hero_ember_spirit',
	'npc_dota_hero_huskar',
	'npc_dota_hero_invoker',
	'npc_dota_hero_keeper_of_the_light',
	'npc_dota_hero_kunkka',
	'npc_dota_hero_leshrac',
	'npc_dota_hero_lina',
	'npc_dota_hero_lone_druid',
	'npc_dota_hero_medusa',
	'npc_dota_hero_meepo',
	'npc_dota_hero_mirana',
	'npc_dota_hero_monkey_king',
	'npc_dota_hero_morphling',
	'npc_dota_hero_necrolyte',
	'npc_dota_hero_nevermore',
	'npc_dota_hero_obsidian_destroyer',
	'npc_dota_hero_pangolier',
	'npc_dota_hero_primal_beast',
	'npc_dota_hero_puck',
	'npc_dota_hero_pudge',
	'npc_dota_hero_pugna',
	'npc_dota_hero_queenofpain',
	'npc_dota_hero_snapfire',
	'npc_dota_hero_sniper',
	'npc_dota_hero_storm_spirit',
	'npc_dota_hero_templar_assassin',
	'npc_dota_hero_tinker',
	'npc_dota_hero_tiny',
	'npc_dota_hero_viper',
	'npc_dota_hero_zuus',
	"npc_dota_hero_razor",
	'npc_dota_hero_weaver',
	'npc_dota_hero_windrunner',
	'npc_dota_hero_techies',
	'npc_dota_hero_rubick',
	'npc_dota_hero_troll_warlord',
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_void_spirit',
	'npc_dota_hero_magnataur',
}

X['safe'] = {
	'npc_dota_hero_antimage',
	'npc_dota_hero_chaos_knight',
	"npc_dota_hero_mars",
	'npc_dota_hero_clinkz',
	'npc_dota_hero_drow_ranger',
	'npc_dota_hero_faceless_void',
	'npc_dota_hero_furion',
	'npc_dota_hero_gyrocopter',
	'npc_dota_hero_juggernaut',
	'npc_dota_hero_life_stealer',
	'npc_dota_hero_luna',
	'npc_dota_hero_lycan',
	'npc_dota_hero_meepo',
	'npc_dota_hero_monkey_king',
	'npc_dota_hero_morphling',
	'npc_dota_hero_muerta',
	'npc_dota_hero_bloodseeker',
	'npc_dota_hero_naga_siren',
	'npc_dota_hero_phantom_assassin',
	'npc_dota_hero_phantom_lancer',
	'npc_dota_hero_razor',
	'npc_dota_hero_riki',
	'npc_dota_hero_bounty_hunter',
	'npc_dota_hero_skeleton_king',
	'npc_dota_hero_slark',
	'npc_dota_hero_spectre',
	'npc_dota_hero_sven',
	'npc_dota_hero_terrorblade',
	'npc_dota_hero_troll_warlord',
	'npc_dota_hero_ursa',
	'npc_dota_hero_shredder',
	'npc_dota_hero_axe',
	'npc_dota_hero_weaver',
	'npc_dota_hero_ogre_magi',
	'npc_dota_hero_omniknight',
	'npc_dota_hero_marci',
	'npc_dota_hero_windrunner',
	'npc_dota_hero_techies',
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_alchemist',
	'npc_dota_hero_medusa',
	'npc_dota_hero_void_spirit',
	'npc_dota_hero_magnataur',
	'npc_dota_hero_zuus',
}

X['supp'] = {
	'npc_dota_hero_abaddon',
	'npc_dota_hero_ancient_apparition',
	'npc_dota_hero_bane',
	'npc_dota_hero_bounty_hunter',
	'npc_dota_hero_chen',
	'npc_dota_hero_crystal_maiden',
	'npc_dota_hero_dark_willow',
	'npc_dota_hero_dazzle',
	'npc_dota_hero_disruptor',
	'npc_dota_hero_earth_spirit',
	'npc_dota_hero_earthshaker',
	'npc_dota_hero_elder_titan',
	'npc_dota_hero_enchantress',
	'npc_dota_hero_enigma',
	'npc_dota_hero_grimstroke',
	'npc_dota_hero_hoodwink',
	'npc_dota_hero_jakiro',
	'npc_dota_hero_keeper_of_the_light',
	'npc_dota_hero_lich',
	'npc_dota_hero_lina',
	'npc_dota_hero_lion',
	'npc_dota_hero_nyx_assassin',
	'npc_dota_hero_oracle',
	'npc_dota_hero_phoenix',
	'npc_dota_hero_pudge',
	'npc_dota_hero_rattletrap',
	'npc_dota_hero_rubick',
	'npc_dota_hero_shadow_demon',
	'npc_dota_hero_shadow_shaman',
	'npc_dota_hero_silencer',
	'npc_dota_hero_skywrath_mage',
	'npc_dota_hero_techies',
	'npc_dota_hero_treant',
	'npc_dota_hero_tusk',
	'npc_dota_hero_undying',
	'npc_dota_hero_vengefulspirit',
	'npc_dota_hero_visage',
	'npc_dota_hero_warlock',
	'npc_dota_hero_winter_wyvern',
	'npc_dota_hero_wisp',
	'npc_dota_hero_necrolyte',
	'npc_dota_hero_witch_doctor',
	'npc_dota_hero_zuus',
	'npc_dota_hero_pugna',
	'npc_dota_hero_queenofpain',
	'npc_dota_hero_death_prophet',
	'npc_dota_hero_windrunner',
	'npc_dota_hero_venomancer',
	'npc_dota_hero_techies',
	'npc_dota_hero_invoker',
	'npc_dota_hero_ogre_magi',
}


--OFFLANER
function X.CanBeOfflaner( hero )
	for i = 1, #X['off']
	do
		if X['off'][i] == hero
		then
			return true
		end
	end
	return false
end

--MIDLANER
function X.CanBeMidlaner( hero )
	for i = 1, #X['mid']
	do
		if X['mid'][i] == hero
		then
			return true
		end
	end
	return false
end

--SAFELANER
function X.CanBeSafeLaneCarry( hero )
	for i = 1, #X['safe']
	do
		if X['safe'][i] == hero
		then
			return true
		end
	end
	return false
end

--SUPPORT
function X.CanBeSupport( hero )
	for i = 1, #X['supp']
	do
		if X['supp'][i] == hero
		then
			return true
		end
	end
	return false
end

function X.GetCurrentSuitableRole( bot, hero )

	local lane = bot:GetAssignedLane()
	if X.CanBeSupport( hero ) and lane ~= LANE_MID
	then
		return "support"
	elseif X.CanBeMidlaner( hero ) and lane == LANE_MID
	then
		return "midlaner"
	elseif X.CanBeSafeLaneCarry( hero )
			and ( ( GetTeam() == TEAM_RADIANT and lane == LANE_BOT ) or ( GetTeam() == TEAM_DIRE and lane == LANE_TOP ) )
	then
		return "carry"
	elseif X.CanBeOfflaner( hero )
			and ( ( GetTeam() == TEAM_RADIANT and lane == LANE_TOP ) or ( GetTeam() == TEAM_DIRE and lane == LANE_BOT ) )
	then
		return "offlaner"
	else
		return "unknown"
	end

end

-- best guess for e.g. enemy heroes
function X.GetBestEffortSuitableRole(hero)
	if X.CanBeSupport(hero) then
		return 4
	elseif X.CanBeMidlaner(hero) then
		return 2
	elseif X.CanBeSafeLaneCarry(hero) then
		return 1
	elseif X.CanBeOfflaner(hero) then
		return 3
	else
		return 3
	end
end

function X.CountValue( hero, role )
	local highest = 0
	local TeamMember = GetTeamPlayers( GetTeam() )
	return highest
end

X['invisEnemyExist'] = false
local globalEnemyCheck = false
local lastCheck = -90

function X.UpdateInvisEnemyStatus( bot )

	if X['invisEnemyExist'] then return end

	if globalEnemyCheck == false
	then
		local players = GetTeamPlayers( GetOpposingTeam() )
		for i = 1, #players
		do
			if X["invisHeroes"][GetSelectedHeroName( players[i] )] == 1
			then
				X['invisEnemyExist'] = true
				break
			end
		end
		globalEnemyCheck = true
	elseif globalEnemyCheck == true
			and DotaTime() > 10 * 60
			and DotaTime() > lastCheck + 3.0
	then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE )
		if #enemies > 0
		then
			for i = 1, #enemies
			do
				if enemies[i] ~= nil
					and enemies[i]:CanBeSeen()
				then
					local SASlot = enemies[i]:FindItemSlot( "item_shadow_amulet" )
					local GCSlot = enemies[i]:FindItemSlot( "item_glimmer_cape" )
					local ISSlot = enemies[i]:FindItemSlot( "item_invis_sword" )
					local SESlot = enemies[i]:FindItemSlot( "item_silver_edge" )
					if SASlot >= 0 or GCSlot >= 0 or ISSlot >= 0 or SESlot >= 0
					then
						X['invisEnemyExist'] = true
						break
					end
				end
			end
		end
		lastCheck = DotaTime()
	end

end

X['supportExist'] = nil
function X.UpdateSupportStatus( bot )

	if X['supportExist'] == true
	then
		return true
	end

	if bot.theRole == "support"
	then
		X['supportExist'] = true
		return true
	end

	local TeamMember = GetTeamPlayers( GetTeam() )

	for i = 1, #TeamMember
	do
		local ally = GetTeamMember( i )
		if ally ~= nil
			and ally:IsHero()
			and ally.theRole == "support"
		then
			X['supportExist'] = true
			return true
		end
	end

	return false

end

X['sayRate'] = false
function X.NotSayRate()
	return X['sayRate'] == false
end

X['sayJiDi'] = false
function X.NotSayJiDi()
	return X['sayJiDi'] == false
end

X['replyMemberID'] = nil
function X.GetReplyMemberID()

	if X['replyMemberID'] ~= nil then return X['replyMemberID'] end

	local tMemberIDList = GetTeamPlayers( GetTeam() )

	local nMemberCount = #tMemberIDList
	local nHumanCount = 0
	for i = 1, #tMemberIDList
	do
		if not IsPlayerBot( tMemberIDList[i] )
		then
			nHumanCount = nHumanCount + 1
		end
	end

	X['replyMemberID'] = tMemberIDList[RandomInt( nHumanCount + 1, nMemberCount )]

	return X['replyMemberID']

end


X['memberIDIndexTable'] = nil
function X.IsAllyMemberID( nID )

	if X['memberIDIndexTable'] == nil
	then
		local tMemberIDList = GetTeamPlayers( GetTeam() )
		if #tMemberIDList > 0
		then
			X['memberIDIndexTable'] = {}
			for i = 1, #tMemberIDList
			do
				X['memberIDIndexTable'][tMemberIDList[i]] = true
			end
		end
	end

	return X['memberIDIndexTable'][nID] == true

end


X['enemyIDIndexTable'] = nil
function X.IsEnemyMemberID( nID )

	if X['enemyIDIndexTable'] == nil
	then
		local tEnemyIDList = GetTeamPlayers( GetOpposingTeam() )
		if #tEnemyIDList > 0
		then
			X['enemyIDIndexTable'] = {}
			for i = 1, #tEnemyIDList
			do
				X['enemyIDIndexTable'][tEnemyIDList[i]] = true
			end
		else
			return false
		end
	end

	return X['enemyIDIndexTable'][nID] == true

end


X['sLastChatString'] = '-0'
X['sLastChatTime'] = -90
function X.SetLastChatString( sChatString )

	X['sLastChatString'] = sChatString
	X['sLastChatTime'] = DotaTime()

end

function X.ShouldTpToDefend()

	if X['sLastChatString'] == "-都来守家"
		and X['sLastChatTime'] >= DotaTime() - 10.0
	then
		return true
	end
	
	return false
	
end

X['fLastGiveTangoTime'] = -90

X['aegisHero'] = nil
function X.IsAllyHaveAegis()

	if X['aegisHero'] ~= nil
	   and X['aegisHero']:FindItemSlot( "item_aegis" ) < 0
	then X['aegisHero'] = nil end

	return X['aegisHero'] ~= nil

end


X['lastbbtime'] = -90
function X.ShouldBuyBack()
	return DotaTime() > X['lastbbtime'] + 1.0
end


X['lastFarmTpTime'] = -90
function X.ShouldTpToFarm()
	return DotaTime() > X['lastFarmTpTime'] + 4.0
end


X['lastPowerRuneTime'] = 90
function X.IsPowerRuneKnown()
	return math.floor( X['lastPowerRuneTime']/120 ) == math.floor( DotaTime()/120 )
end


X['campCount'] = 18
function X.GetCampCount()
	return X['campCount']
end


X['hasRefreshDone'] = true
function X.IsCampRefreshDone()
	return X['hasRefreshDone'] == true
end


X['availableCampTable'] = {}
function X.GetAvailableCampCount()
	return #X['availableCampTable']
end


X['nStopWaitTime'] = RandomInt( 3, 8 )
function X.GetRuneActionTime()
	return X['nStopWaitTime']
end

function X.GetPositionForCM(bot)
	if GetTeam() ~= bot:GetTeam() then
		print('[WARNING] Cannot determine the role of an enemy bot. Return default pos as 3')
		print("Stack Trace:", debug.traceback())
		return 3
	end

	local lane = bot:GetAssignedLane()
	local role
	if lane == LANE_MID then
		role = 2
	elseif lane == LANE_TOP then
		if bot:GetTeam() == TEAM_RADIANT then
			if X.CanBeOfflaner(bot) then
				role = 3
			else
				role = 4
			end
		else
			if X.CanBeSafeLaneCarry(bot) then
				role = 1
			else
				role = 5
			end
		end
	elseif lane == LANE_BOT then
		if bot:GetTeam() == TEAM_RADIANT then
			if X.CanBeSafeLaneCarry(bot) then
				role = 1
			else
				role = 5
			end
		else
			if X.CanBeOfflaner(bot) then
				role = 3
			else
				role = 4
			end
		end
	end
	if role == nil then
		role = 1
		print('[ERROR] Failed to determine role for bot '..bot:GetUnitName()..' in CM. It got assigned lane#: '..lane..'. Set it to pos: '..tostring(role))
	end
	return role
end

function X.GetRoleFromId(bot)
	local heroID = GetTeamPlayers(GetTeam())
	for i, v in pairs(heroID) do
		if GetSelectedHeroName(v) == bot:GetUnitName() then
			local team = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
			return X.roleAssignment[team][i]
		end
	end
	return nil
end

HeroPositions = { }
-- returns 1, 2, 3, 4, or 5 as the position of the hero in the team
function X.GetPosition(bot)
	local role = bot.assignedRole
	if role == nil and GetGameMode() == GAMEMODE_CM then
		local nH, nB = Utils.NumHumanBotPlayersInTeam(bot:GetTeam())
		if nH == 0 then
			role = X.GetPositionForCM(bot)
		end
	end
	local unitName = bot:GetUnitName()
	local playerId = bot:GetPlayerID()
	if role == nil or GetGameState() == GAME_STATE_PRE_GAME then
		local cRole = HeroPositions[playerId]
		if cRole ~= nil then
			role = cRole
		else
			local heroID = GetTeamPlayers(GetTeam())
			for i, v in pairs(heroID) do
				if v == playerId then
					local team = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
					role = X.roleAssignment[team][i]
				end
			end
			cRole = role
		end
	end

	bot.assignedRole = role
	
	if role == nil and GetGameState() ~= GAME_STATE_PRE_GAME then
		if HeroPositions[playerId] == nil then
			HeroPositions[playerId] = X.GetRoleFromId(bot)
		end
		-- fallback to use Captain mode logic to determine roles
		role = HeroPositions[playerId] ~= nil and HeroPositions[playerId] or X.GetPositionForCM(bot)
		print("[ERROR] Failed to match bot role for bot: "..unitName..', PlayerID: '..playerId..', set it to play pos: '..tostring(role))
		print("Stack Trace:", debug.traceback())
	end
	return role
end

function X.IsPvNMode()

	return X.IsAllShadow()

end

function X.IsAllShadow()

	return false

end

function X.GetHighestValueRoles( bot )

	local maxVal = - 1
	local role = ""

	print( "========="..bot:GetUnitName().."=========" )
	for key, value in pairs( X.hero_roles[bot:GetUnitName()] ) do
		print( tostring( key ).." : "..tostring( value ) )
		if value >= maxVal then
			maxVal = value
			role = key
		end
	end

	print( "Highest value role => "..role.." : "..tostring( maxVal ) )

end

return X