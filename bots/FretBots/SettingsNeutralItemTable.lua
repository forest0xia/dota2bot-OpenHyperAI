	-- Default neutral items table, returns the table, so use
	-- local <x> = require "SettingsNeutralItemTable" to include in another file.

local neutral_items =
{
	-- Matched to Dota 2 7.42 VPK scripts/npc/neutral_items.txt (4 tiers)
	-- roles{} arrays are the desire weights for roles {1,2,3,4,5}

	-- Tier 1 (0:00)
	{name="item_chipped_vest",          tier=1, ranged=1, melee=2, roles={2,2,4,2,2}, realName="Chipped Vest"},
	{name="item_ash_legion_shield",     tier=1, ranged=1, melee=2, roles={1,1,3,3,3}, realName="Ash Legion Shield"},
	{name="item_possessed_mask",        tier=1, ranged=1, melee=1, roles={3,3,2,1,1}, realName="Possessed Mask"},
	{name="item_dormant_curio",         tier=1, ranged=1, melee=1, roles={1,1,1,1,1}, realName="Dormant Curio"},
	{name="item_red_ledger",            tier=1, ranged=1, melee=1, roles={2,2,2,2,2}, realName="Red Ledger"},
	{name="item_weighted_dice",         tier=1, ranged=1, melee=1, roles={3,3,1,1,1}, realName="Weighted Dice"},
	{name="item_polliwog_charm",        tier=1, ranged=1, melee=1, roles={1,1,1,2,2}, realName="Pollywog Charm"},
	{name="item_seeds_of_serenity",     tier=1, ranged=1, melee=1, roles={0,0,1,2,2}, realName="Seeds of Serenity"},
	{name="item_foragers_kit",          tier=1, ranged=1, melee=1, roles={1,1,1,3,3}, realName="Forager's Kit"},
	{name="item_kobold_cup",            tier=1, ranged=1, melee=1, roles={1,1,1,3,3}, realName="Kobold Cup"},
	{name="item_stonefeather_satchel",  tier=1, ranged=1, melee=1, roles={1,1,1,2,2}, realName="Stonefeather Satchel"},
	{name="item_pogo_stick",            tier=1, ranged=1, melee=1, roles={3,3,3,3,3}, realName="Tumbler's Toy"},

	-- Tier 2 (15:00)
	{name="item_psychic_headband",      tier=2, ranged=3, melee=1, roles={1,1,1,6,6}, realName="Psychic Headband"},
	{name="item_safety_bubble",         tier=2, ranged=1, melee=1, roles={2,2,3,2,2}, realName="Safety Bubble"},
	{name="item_metamorphic_mandible",  tier=2, ranged=1, melee=1, roles={1,1,1,3,3}, realName="Metamorphic Mandible"},
	{name="item_jidi_pollen_bag",       tier=2, ranged=1, melee=1, roles={1,1,2,2,2}, realName="Jidi Pollen Bag"},
	{name="item_brick",                 tier=2, ranged=1, melee=1, roles={2,2,3,2,2}, realName="Brick"},
	{name="item_crippling_crossbow",    tier=2, ranged=2, melee=1, roles={2,2,3,1,1}, realName="Crippling Crossbow"},
	{name="item_imp_claw",              tier=2, ranged=1, melee=1, roles={3,2,1,0,0}, realName="Imp Claw"},
	{name="item_gunpowder_gauntlets",   tier=2, ranged=1, melee=1, roles={2,2,4,1,1}, realName="Gunpowder Gauntlets"},
	{name="item_defiant_shell",         tier=2, ranged=1, melee=2, roles={2,2,6,2,2}, realName="Defiant Shell"},
	{name="item_partisans_brand",       tier=2, ranged=1, melee=1, roles={3,3,1,0,0}, realName="Partisan's Brand"},
	{name="item_spellslinger",          tier=2, ranged=1, melee=1, roles={1,2,1,3,3}, realName="Spellslinger"},
	{name="item_mana_draught",          tier=2, ranged=1, melee=1, roles={1,1,1,3,3}, realName="Mana Draught"},

	-- Tier 3 (30:00)
	{name="item_prophets_pendulum",     tier=3, ranged=1, melee=1, roles={1,1,1,3,3}, realName="Prophet's Pendulum"},
	{name="item_dandelion_amulet",      tier=3, ranged=1, melee=2, roles={2,2,5,2,2}, realName="Dandelion Amulet"},
	{name="item_idol_of_screeauk",      tier=3, ranged=1, melee=1, roles={2,2,3,4,4}, realName="Idol of Scree'Auk"},
	{name="item_balmhook",              tier=3, ranged=1, melee=1, roles={1,1,4,2,2}, realName="Balmhook"},
	{name="item_rattlecage",            tier=3, ranged=1, melee=2, roles={1,1,6,1,1}, realName="Rattlecage"},
	{name="item_stormcrafter",          tier=3, ranged=1, melee=1, roles={1,1,3,3,3}, realName="Stormcrafter"},
	{name="item_enchanters_bauble",     tier=3, ranged=1, melee=1, roles={1,1,1,3,3}, realName="Enchanter's Bauble"},
	{name="item_ceremonial_robe",       tier=3, ranged=1, melee=1, roles={1,1,1,5,5}, realName="Ceremonial Robe"},
	{name="item_harmonizer",            tier=3, ranged=1, melee=1, roles={1,1,1,3,3}, realName="Harmonizer"},
	{name="item_vile_phial",            tier=3, ranged=1, melee=1, roles={4,3,2,0,0}, realName="Vile Phial"},
	{name="item_serrated_shiv",         tier=3, ranged=1, melee=1, roles={2,2,4,1,1}, realName="Serrated Shiv"},
	{name="item_revenants_brooch",      tier=3, ranged=1, melee=1, roles={5,4,2,0,0}, realName="Revenant's Brooch"},

	-- Tier 4 (50:00, max tier in 7.42)
	{name="item_fallen_sky",            tier=4, ranged=1, melee=1, roles={1,1,5,1,1}, realName="Fallen Sky"},
	{name="item_flicker",               tier=4, ranged=1, melee=1, roles={2,2,2,3,3}, realName="Flicker"},
	{name="item_minotaur_horn",         tier=4, ranged=1, melee=1, roles={3,3,3,1,1}, realName="Minotaur Horn"},
	{name="item_mind_breaker",          tier=4, ranged=1, melee=1, roles={4,2,1,0,0}, realName="Mind Breaker"},
	{name="item_divine_regalia",        tier=4, ranged=1, melee=1, roles={4,4,1,1,1}, realName="Divine Regalia"},
	{name="item_heavy_blade",           tier=4, ranged=1, melee=1, roles={3,6,1,1,1}, realName="Witchbane"},
	{name="item_helm_of_the_hivemind",  tier=4, ranged=1, melee=1, roles={1,2,2,5,5}, realName="Helm of the Hivemind"},
	{name="item_dezun_bloodrite",       tier=4, ranged=1, melee=1, roles={1,2,3,4,4}, realName="Dezun Bloodrite"},
	{name="item_conjurers_catalyst",    tier=4, ranged=1, melee=1, roles={1,1,1,3,3}, realName="Conjurer's Catalyst"},
	{name="item_giants_ring",           tier=4, ranged=1, melee=2, roles={3,3,6,1,1}, realName="Giant's Ring"},
	{name="item_demonicon",             tier=4, ranged=1, melee=1, roles={1,1,1,5,6}, realName="Book of the Dead"},
	{name="item_riftshadow_prism",      tier=4, ranged=1, melee=2, roles={4,4,1,1,1}, realName="Riftshadow Prism"},
}

local enhancements = {
	-- Matched to Dota 2 7.42 VPK scripts/npc/neutral_items.txt (4 tiers)

	-- Tier 1
	{ name = "item_enhancement_quickened", tier = 1, level = 1, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },
	{ name = "item_enhancement_vital",     tier = 1, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Vital Enhancement" },
	{ name = "item_enhancement_brawny",    tier = 1, level = 1, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
	{ name = "item_enhancement_tough",     tier = 1, level = 1, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
	{ name = "item_enhancement_alert",     tier = 1, level = 1, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
	{ name = "item_enhancement_mystical",  tier = 1, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },

	-- Tier 2
	{ name = "item_enhancement_quickened", tier = 2, level = 2, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },
	{ name = "item_enhancement_vital",     tier = 2, level = 2, roles = {1, 1, 1, 1, 1}, realName = "Vital Enhancement" },
	{ name = "item_enhancement_brawny",    tier = 2, level = 2, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
	{ name = "item_enhancement_tough",     tier = 2, level = 2, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
	{ name = "item_enhancement_crude",     tier = 2, level = 1, roles = {2, 1, 2, 1, 1}, realName = "Crude Enhancement" },
	{ name = "item_enhancement_alert",     tier = 2, level = 2, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
	{ name = "item_enhancement_nimble",    tier = 2, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Nimble Enhancement" },
	{ name = "item_enhancement_mystical",  tier = 2, level = 2, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
	{ name = "item_enhancement_keen_eyed", tier = 2, level = 1, roles = {1, 1, 1, 1, 2}, realName = "Keen Eyed Enhancement" },
	{ name = "item_enhancement_titanic",   tier = 2, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Titanic Enhancement" },

	-- Tier 3
	{ name = "item_enhancement_quickened", tier = 3, level = 3, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },
	{ name = "item_enhancement_greedy",    tier = 3, level = 1, roles = {1, 1, 1, 2, 2}, realName = "Greedy Enhancement" },
	{ name = "item_enhancement_brawny",    tier = 3, level = 3, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
	{ name = "item_enhancement_tough",     tier = 3, level = 3, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
	{ name = "item_enhancement_crude",     tier = 3, level = 2, roles = {2, 1, 2, 1, 1}, realName = "Crude Enhancement" },
	{ name = "item_enhancement_alert",     tier = 3, level = 3, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
	{ name = "item_enhancement_nimble",    tier = 3, level = 2, roles = {1, 1, 1, 1, 1}, realName = "Nimble Enhancement" },
	{ name = "item_enhancement_mystical",  tier = 3, level = 3, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
	{ name = "item_enhancement_keen_eyed", tier = 3, level = 2, roles = {1, 1, 1, 1, 2}, realName = "Keen Eyed Enhancement" },
	{ name = "item_enhancement_titanic",   tier = 3, level = 2, roles = {1, 1, 1, 1, 1}, realName = "Titanic Enhancement" },

	-- Tier 4
	{ name = "item_enhancement_timeless",    tier = 4, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Timeless Enhancement" },
	{ name = "item_enhancement_evolved",     tier = 4, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Evolved Enhancement" },
	{ name = "item_enhancement_fleetfooted", tier = 4, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Fleetfooted Enhancement" },
	{ name = "item_enhancement_vampiric",    tier = 4, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Vampiric Enhancement" },
	{ name = "item_enhancement_hulking",     tier = 4, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Hulking Enhancement" },
	{ name = "item_enhancement_audacious",   tier = 4, level = 1, roles = {1, 2, 1, 1, 1}, realName = "Audacious Enhancement" },
	{ name = "item_enhancement_feverish",    tier = 4, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Feverish Enhancement" },
	{ name = "item_enhancement_manic",       tier = 4, level = 1, roles = {1, 1, 1, 1, 1}, realName = "Manic Enhancement" },
}

return {
	items = neutral_items,
	enhancements = enhancements
}
