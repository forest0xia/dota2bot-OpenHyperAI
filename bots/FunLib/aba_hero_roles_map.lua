X = {}

-- ["carry"] will become more useful later in the game if they gain a significant gold advantage.
-- ["durable"] has the ability to last longer in teamfights.
-- ["support"] can focus less on amassing gold and items, and more on using their abilities to gain an advantage for the team.
-- ["escape"] has the ability to quickly avoid death.
-- ["nuker"] can quickly kill enemy heroes using high damage spells with low cooldowns.
-- ["pusher"] can quickly siege and destroy towers and barracks at all points of the game.
-- ["disabler"] has a guaranteed disable for one or more of their spells.
-- ["initiator"] good at starting a teamfight. Better tanky so it can initiate and then servive.
-- ["jungler"] can farm effectively from neutral creeps inside the jungle early in the game.
-- ["healer"] can heal allies.
-- ["randge"] is ranged or melee hero.

X["hero_roles"] = {
    ["npc_dota_hero_abaddon"] = { carry = 1, disabler = 0, durable = 2, escape = 0, initiator = 0, jungler = 0, nuker = 0, support = 2, pusher = 0, ranged = 0, healer = 1 },
    ["npc_dota_hero_abyssal_underlord"] = { carry = 0, disabler = 1, durable = 1, escape = 2, initiator = 0, jungler = 0, nuker = 1, support = 1, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_alchemist"] = { carry = 2, disabler = 1, durable = 2, escape = 0, initiator = 1, jungler = 0, nuker = 1, support = 1, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_ancient_apparition"] = { carry = 0, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 2, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_antimage"] = { carry = 3, disabler = 0, durable = 0, escape = 3, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_arc_warden"] = { carry = 3, disabler = 0, durable = 0, escape = 3, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_axe"] = { carry = 1, disabler = 2, durable = 3, escape = 0, initiator = 3, jungler = 2, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_bane"] = { carry = 1, disabler = 3, durable = 1, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 3, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_batrider"] = { carry = 0, disabler = 2, durable = 0, escape = 1, initiator = 3, jungler = 2, nuker = 0, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_beastmaster"] = { carry = 0, disabler = 2, durable = 2, escape = 0, initiator = 2, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_bloodseeker"] = { carry = 1, disabler = 1, durable = 0, escape = 0, initiator = 1, jungler = 1, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_bounty_hunter"] = { carry = 1, disabler = 0, durable = 0, escape = 2, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_brewmaster"] = { carry = 1, disabler = 2, durable = 2, escape = 0, initiator = 3, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_bristleback"] = { carry = 2, disabler = 0, durable = 3, escape = 0, initiator = 1, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_broodmother"] = { carry = 1, disabler = 1, durable = 0, escape = 3, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 3, ranged = 0, healer = 0 },
    ["npc_dota_hero_centaur"] = { carry = 0, disabler = 1, durable = 3, escape = 0, initiator = 3, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_chaos_knight"] = { carry = 3, disabler = 2, durable = 2, escape = 0, initiator = 1, jungler = 0, nuker = 0, support = 0, pusher = 2, ranged = 0, healer = 0 },
    ["npc_dota_hero_chen"] = { carry = 0, disabler = 0, durable = 0, escape = 0, initiator = 0, jungler = 3, nuker = 0, support = 2, pusher = 2, ranged = 1, healer = 1 },
    ["npc_dota_hero_clinkz"] = { carry = 2, disabler = 0, durable = 0, escape = 3, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 1, ranged = 1, healer = 0 },
    ["npc_dota_hero_crystal_maiden"] = { carry = 0, disabler = 2, durable = 0, escape = 0, initiator = 0, jungler = 1, nuker = 2, support = 3, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_dark_seer"] = { carry = 0, disabler = 1, durable = 0, escape = 1, initiator = 1, jungler = 1, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_dark_willow"] = { carry = 0, disabler = 3, durable = 0, escape = 0, initiator = 2, jungler = 0, nuker = 1, support = 2, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_dawnbreaker"] = { carry = 1, disabler = 2, durable = 1, escape = 1, initiator = 1, jungler = 0, nuker = 1, support = 3, pusher = 0, ranged = 0, healer = 1 },
    ["npc_dota_hero_dazzle"] = { carry = 0, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 3, pusher = 0, ranged = 1, healer = 1 },
    ["npc_dota_hero_death_prophet"] = { carry = 1, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 3, ranged = 1, healer = 0 },
    ["npc_dota_hero_disruptor"] = { carry = 0, disabler = 2, durable = 0, escape = 0, initiator = 1, jungler = 0, nuker = 1, support = 2, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_doom_bringer"] = { carry = 1, disabler = 2, durable = 2, escape = 0, initiator = 2, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_dragon_knight"] = { carry = 2, disabler = 2, durable = 2, escape = 0, initiator = 1, jungler = 0, nuker = 1, support = 0, pusher = 3, ranged = 0, healer = 0 },
    ["npc_dota_hero_drow_ranger"] = { carry = 2, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_earth_spirit"] = { carry = 0, disabler = 1, durable = 1, escape = 2, initiator = 1, jungler = 0, nuker = 2, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_earthshaker"] = { carry = 0, disabler = 2, durable = 0, escape = 0, initiator = 3, jungler = 0, nuker = 1, support = 1, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_elder_titan"] = { carry = 0, disabler = 1, durable = 1, escape = 0, initiator = 2, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_ember_spirit"] = { carry = 2, disabler = 1, durable = 0, escape = 3, initiator = 1, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_enchantress"] = { carry = 0, disabler = 0, durable = 1, escape = 0, initiator = 0, jungler = 3, nuker = 1, support = 0, pusher = 2, ranged = 1, healer = 1 },
    ["npc_dota_hero_enigma"] = { carry = 0, disabler = 2, durable = 0, escape = 0, initiator = 2, jungler = 3, nuker = 0, support = 0, pusher = 2, ranged = 1, healer = 0 },
    ["npc_dota_hero_faceless_void"] = { carry = 2, disabler = 2, durable = 1, escape = 1, initiator = 3, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_furion"] = { carry = 1, disabler = 0, durable = 0, escape = 1, initiator = 0, jungler = 3, nuker = 1, support = 0, pusher = 3, ranged = 1, healer = 0 },
    ["npc_dota_hero_grimstroke"] = { carry = 0, disabler = 2, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 3, support = 3, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_gyrocopter"] = { carry = 3, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_hoodwink"] = { carry = 1, disabler = 2, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 1, support = 3, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_huskar"] = { carry = 2, disabler = 0, durable = 2, escape = 0, initiator = 1, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_invoker"] = { carry = 1, disabler = 2, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 3, support = 0, pusher = 1, ranged = 1, healer = 0 },
    ["npc_dota_hero_jakiro"] = { carry = 0, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 2, support = 1, pusher = 2, ranged = 1, healer = 0 },
    ["npc_dota_hero_juggernaut"] = { carry = 2, disabler = 0, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 0, support = 0, pusher = 1, ranged = 0, healer = 1 },
    ["npc_dota_hero_keeper_of_the_light"] = { carry = 0, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 1, nuker = 2, support = 3, pusher = 0, ranged = 1, healer = 1 },
    ["npc_dota_hero_kunkka"] = { carry = 1, disabler = 1, durable = 1, escape = 0, initiator = 1, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_legion_commander"] = { carry = 1, disabler = 2, durable = 1, escape = 0, initiator = 1, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 1 },
    ["npc_dota_hero_leshrac"] = { carry = 1, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 3, support = 1, pusher = 3, ranged = 1, healer = 0 },
    ["npc_dota_hero_lich"] = { carry = 0, disabler = 0, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 2, support = 3, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_life_stealer"] = { carry = 2, disabler = 1, durable = 2, escape = 1, initiator = 0, jungler = 1, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_lina"] = { carry = 1, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 3, support = 1, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_lion"] = { carry = 0, disabler = 3, durable = 0, escape = 0, initiator = 2, jungler = 0, nuker = 3, support = 2, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_lone_druid"] = { carry = 2, disabler = 0, durable = 1, escape = 0, initiator = 0, jungler = 1, nuker = 0, support = 0, pusher = 3, ranged = 1, healer = 0 },
    ["npc_dota_hero_luna"] = { carry = 2, disabler = 0, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 2, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_lycan"] = { carry = 2, disabler = 0, durable = 1, escape = 1, initiator = 0, jungler = 1, nuker = 1, support = 0, pusher = 3, ranged = 0, healer = 0 },
    ["npc_dota_hero_magnataur"] = { carry = 0, disabler = 2, durable = 0, escape = 1, initiator = 3, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_marci"] = { carry = 1, disabler = 1, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 1, support = 1, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_mars"] = { carry = 1, disabler = 2, durable = 2, escape = 0, initiator = 3, jungler = 0, nuker = 1, support = 0, pusher = 1, ranged = 0, healer = 0 },
    ["npc_dota_hero_medusa"] = { carry = 3, disabler = 1, durable = 1, escape = 0, initiator = 0, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_meepo"] = { carry = 2, disabler = 1, durable = 0, escape = 2, initiator = 1, jungler = 0, nuker = 2, support = 0, pusher = 1, ranged = 0, healer = 0 },
    ["npc_dota_hero_mirana"] = { carry = 1, disabler = 1, durable = 0, escape = 2, initiator = 0, jungler = 0, nuker = 1, support = 1, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_monkey_king"] = { carry = 2, disabler = 1, durable = 0, escape = 2, initiator = 1, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_morphling"] = { carry = 3, disabler = 1, durable = 2, escape = 3, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_muerta"] = { carry = 3, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 1, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_naga_siren"] = { carry = 3, disabler = 2, durable = 0, escape = 1, initiator = 1, jungler = 0, nuker = 0, support = 1, pusher = 2, ranged = 0, healer = 0 },
    ["npc_dota_hero_necrolyte"] = { carry = 1, disabler = 1, durable = 1, escape = 0, initiator = 0, jungler = 0, nuker = 2, support = 2, pusher = 0, ranged = 1, healer = 1 },
    ["npc_dota_hero_nevermore"] = { carry = 2, disabler = 0, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 3, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_night_stalker"] = { carry = 1, disabler = 2, durable = 2, escape = 0, initiator = 2, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_nyx_assassin"] = { carry = 0, disabler = 2, durable = 0, escape = 1, initiator = 2, jungler = 0, nuker = 2, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_obsidian_destroyer"] = { carry = 2, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 2, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_ogre_magi"] = { carry = 1, disabler = 2, durable = 1, escape = 0, initiator = 1, jungler = 0, nuker = 2, support = 2, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_omniknight"] = { carry = 0, disabler = 0, durable = 1, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 2, pusher = 0, ranged = 0, healer = 1 },
    ["npc_dota_hero_oracle"] = { carry = 0, disabler = 2, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 3, support = 3, pusher = 0, ranged = 1, healer = 1 },
    ["npc_dota_hero_pangolier"] = { carry = 2, disabler = 2, durable = 1, escape = 1, initiator = 3, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_phantom_assassin"] = { carry = 3, disabler = 0, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_phantom_lancer"] = { carry = 2, disabler = 0, durable = 0, escape = 2, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 1, ranged = 0, healer = 0 },
    ["npc_dota_hero_phoenix"] = { carry = 0, disabler = 1, durable = 0, escape = 2, initiator = 2, jungler = 0, nuker = 3, support = 1, pusher = 0, ranged = 1, healer = 1 },
    ["npc_dota_hero_primal_beast"] = { carry = 0, disabler = 1, durable = 3, escape = 0, initiator = 3, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_puck"] = { carry = 0, disabler = 3, durable = 0, escape = 3, initiator = 3, jungler = 0, nuker = 2, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_pudge"] = { carry = 0, disabler = 2, durable = 2, escape = 0, initiator = 2, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_pugna"] = { carry = 0, disabler = 0, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 2, support = 0, pusher = 2, ranged = 1, healer = 1 },
    ["npc_dota_hero_queenofpain"] = { carry = 1, disabler = 0, durable = 0, escape = 3, initiator = 0, jungler = 0, nuker = 3, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_razor"] = { carry = 2, disabler = 0, durable = 2, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_rattletrap"] = { carry = 0, disabler = 2, durable = 1, escape = 0, initiator = 3, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_riki"] = { carry = 2, disabler = 1, durable = 0, escape = 2, initiator = 0, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_ringmaster"] = { carry = 0, disabler = 2, durable = 1, escape = 1, initiator = 0, jungler = 0, nuker = 0, support = 2, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_rubick"] = { carry = 0, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 2, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_sand_king"] = { carry = 0, disabler = 2, durable = 0, escape = 2, initiator = 3, jungler = 1, nuker = 2, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_shadow_demon"] = { carry = 0, disabler = 2, durable = 0, escape = 0, initiator = 1, jungler = 0, nuker = 1, support = 2, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_shadow_shaman"] = { carry = 0, disabler = 3, durable = 0, escape = 0, initiator = 1, jungler = 0, nuker = 2, support = 2, pusher = 3, ranged = 1, healer = 0 },
    ["npc_dota_hero_shredder"] = { carry = 1, disabler = 0, durable = 2, escape = 2, initiator = 0, jungler = 0, nuker = 3, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_silencer"] = { carry = 1, disabler = 2, durable = 0, escape = 0, initiator = 2, jungler = 0, nuker = 1, support = 1, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_skeleton_king"] = { carry = 2, disabler = 2, durable = 3, escape = 0, initiator = 1, jungler = 0, nuker = 0, support = 1, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_skywrath_mage"] = { carry = 0, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 3, support = 2, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_slardar"] = { carry = 2, disabler = 1, durable = 2, escape = 1, initiator = 2, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_slark"] = { carry = 2, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_snapfire"] = { carry = 0, disabler = 1, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 2, support = 3, pusher = 0, ranged = 1, healer = 1 },
    ["npc_dota_hero_sniper"] = { carry = 2, disabler = 0, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_spectre"] = { carry = 3, disabler = 0, durable = 1, escape = 1, initiator = 0, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_spirit_breaker"] = { carry = 1, disabler = 2, durable = 2, escape = 1, initiator = 2, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_storm_spirit"] = { carry = 2, disabler = 1, durable = 0, escape = 3, initiator = 1, jungler = 0, nuker = 2, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_sven"] = { carry = 2, disabler = 2, durable = 2, escape = 0, initiator = 2, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_techies"] = { carry = 1, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 2, support = 3, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_templar_assassin"] = { carry = 2, disabler = 0, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_terrorblade"] = { carry = 3, disabler = 0, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 0, pusher = 2, ranged = 0, healer = 0 },
    ["npc_dota_hero_tidehunter"] = { carry = 0, disabler = 2, durable = 3, escape = 0, initiator = 3, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_tinker"] = { carry = 1, disabler = 0, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 2, pusher = 2, ranged = 1, healer = 0 },
    ["npc_dota_hero_tiny"] = { carry = 3, disabler = 1, durable = 2, escape = 0, initiator = 2, jungler = 0, nuker = 2, support = 0, pusher = 2, ranged = 0, healer = 0 },
    ["npc_dota_hero_treant"] = { carry = 0, disabler = 1, durable = 1, escape = 1, initiator = 2, jungler = 0, nuker = 0, support = 3, pusher = 0, ranged = 0, healer = 1 },
    ["npc_dota_hero_troll_warlord"] = { carry = 3, disabler = 1, durable = 1, escape = 0, initiator = 0, jungler = 0, nuker = 0, support = 0, pusher = 1, ranged = 1, healer = 0 },
    ["npc_dota_hero_tusk"] = { carry = 0, disabler = 2, durable = 0, escape = 0, initiator = 2, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_undying"] = { carry = 0, disabler = 1, durable = 2, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 1, pusher = 0, ranged = 0, healer = 1 },
    ["npc_dota_hero_ursa"] = { carry = 2, disabler = 1, durable = 1, escape = 0, initiator = 0, jungler = 1, nuker = 0, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_vengefulspirit"] = { carry = 0, disabler = 2, durable = 0, escape = 1, initiator = 2, jungler = 0, nuker = 1, support = 3, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_venomancer"] = { carry = 0, disabler = 1, durable = 0, escape = 0, initiator = 1, jungler = 0, nuker = 1, support = 2, pusher = 1, ranged = 1, healer = 0 },
    ["npc_dota_hero_viper"] = { carry = 3, disabler = 1, durable = 2, escape = 0, initiator = 1, jungler = 0, nuker = 0, support = 0, pusher = 1, ranged = 1, healer = 0 },
    ["npc_dota_hero_visage"] = { carry = 1, disabler = 1, durable = 1, escape = 0, initiator = 0, jungler = 0, nuker = 2, support = 1, pusher = 1, ranged = 1, healer = 0 },
    ["npc_dota_hero_void_spirit"] = { carry = 2, disabler = 1, durable = 0, escape = 3, initiator = 1, jungler = 0, nuker = 1, support = 0, pusher = 0, ranged = 0, healer = 0 },
    ["npc_dota_hero_warlock"] = { carry = 0, disabler = 1, durable = 1, escape = 0, initiator = 0, jungler = 0, nuker = 0, support = 3, pusher = 0, ranged = 1, healer = 1 },
    ["npc_dota_hero_weaver"] = { carry = 2, disabler = 0, durable = 0, escape = 3, initiator = 0, jungler = 0, nuker = 0, support = 0, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_windrunner"] = { carry = 3, disabler = 1, durable = 0, escape = 1, initiator = 0, jungler = 0, nuker = 1, support = 2, pusher = 0, ranged = 1, healer = 0 },
    ["npc_dota_hero_winter_wyvern"] = { carry = 0, disabler = 2, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 1, support = 3, pusher = 0, ranged = 1, healer = 1 },
    ["npc_dota_hero_wisp"] = { carry = 0, disabler = 0, durable = 0, escape = 2, initiator = 0, jungler = 0, nuker = 0, support = 1, pusher = 0, ranged = 0, healer = 1 },
    ["npc_dota_hero_witch_doctor"] = { carry = 0, disabler = 1, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 2, support = 3, pusher = 0, ranged = 1, healer = 1 },
    ["npc_dota_hero_zuus"] = { carry = 1, disabler = 0, durable = 0, escape = 0, initiator = 0, jungler = 0, nuker = 3, support = 1, pusher = 0, ranged = 1, healer = 0 },
}

-- General function to check hero roles
function X.HasRole(hero, role)
    local roles = X["hero_roles"][hero]
    if roles == nil then return false end
    return roles[role] > 0
end

-- Wrapper functions for common role checks
function X.IsCarry(hero) return X.HasRole(hero, "carry") end
function X.IsDisabler(hero) return X.HasRole(hero, "disabler") end
function X.IsDurable(hero) return X.HasRole(hero, "durable") end
function X.HasEscape(hero) return X.HasRole(hero, "escape") end
function X.IsInitiator(hero) return X.HasRole(hero, "initiator") end
function X.IsJungler(hero) return X.HasRole(hero, "jungler") end
function X.IsNuker(hero) return X.HasRole(hero, "nuker") end
function X.IsSupport(hero) return X.HasRole(hero, "support") end
function X.IsPusher(hero) return X.HasRole(hero, "pusher") end
function X.IsRanged(hero) return X.HasRole(hero, "ranged") end
function X.IsHealer(hero) return X.HasRole(hero, "healer") end

return X
