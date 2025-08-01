	-- Default neutral items table, returns the table, so use
	-- local <x> = require "SettingsNeutralItemTable" to include in another file.

local neutral_items =
{
	-- Just going to comment out items we don"t want entirely rather than force the code to do a rollup on the roles count
	-- roles{} arrays are the desire weights for roles {1,2,3,4,5}
	-- {name="item_arcane_ring",			tier=1,		ranged=1,		melee=1,		roles={1,1,1,2,2},		realName="Arcane Ring"},
	-- {name="item_broom_handle",			tier=1,		ranged=0,		melee=3,		roles={2,2,1,0,0},		realName="Broom Handle"},
	-- {name="item_duelist_gloves",		tier=1,		ranged=0,		melee=1,		roles={1,1,1,1,1},		realName="Duelist Gloves"},
	-- {name="item_faded_broach",			tier=1,		ranged=1,		melee=1,		roles={5,5,5,5,5},		realName="Faded Broach"},
	-- {name="item_mysterious_hat",		tier=1,		ranged=1,		melee=1,		roles={1,4,1,1,1},		realName="Fairy's Trinket"},
	-- {name="item_lance_of_pursuit",		tier=1,		ranged=1,		melee=2,		roles={2,2,1,1,1},		realName="Lance of Pursuit"},
	{name="item_occult_bracelet",		tier=1,		ranged=1,		melee=1,		roles={1,1,3,2,2},		realName="Occult Bracelet"},
	-- {name="item_unstable_wand",			tier=1,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Pig Pole"},
	{name="item_polliwog_charm",			tier=1,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Polliwog Charm"},
	{name="item_rippers_lash",			tier=1,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Ripper's Lash"},
	-- {name="item_royal_jelly",			tier=1,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Royal Jelly"},
	-- {name="item_safety_bubble",			tier=1,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Safety Bubble"},
	-- {name="item_seeds_of_serenity",		tier=1,		ranged=1,		melee=1,		roles={0,0,0,1,1},		realName="Seeds of Serenity"},
	{name="item_spark_of_courage",		tier=1,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Spark of Courage"},
	{name="item_chipped_vest",			tier=1,		ranged=0,		melee=1,		roles={2,2,4,2,2},		realName="Chipped Vest"},
	-- {name="item_keen_optic",				tier=1,		ranged=1,		melee=1,		roles={1,1,1,2,2},		realName="Keen Optic"},
	-- {name="item_ironwood_tree",			tier=1,		ranged=1,		melee=1,		roles={2,2,2,1,1},		realName="Ironwood Tree"},
	-- {name="item_mango_tree",				tier=1,		ranged=1,		melee=1,		roles={0,0,0,0,0},		realName="Mango Tree"},
	-- {name="item_ocean_heart",				tier=1,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Ocean Heart"},
	-- {name="item_possessed_mask",			tier=1,		ranged=1,		melee=1,		roles={3,3,2,1,1},		realName="Possessed Mask"},
	-- {name="item_trusty_shovel",			tier=1,		ranged=1,		melee=1,		roles={0,0,0,0,0},		realName="Trusty Shovel"},
	-- {name="item_orb_of_destruction",	tier=1,		ranged=1,		melee=1,		roles={4,1,1,0,0},		realName="Orb of Destruction"},
	{name="item_sisters_shroud",			tier=1,		ranged=1,		melee=1,		roles={1,1,1,5,5},		realName="Sister's Shroud"},
	{name="item_dormant_curio",			tier=1,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Dormant Curio"},
	{name="item_kobold_cup",			tier=1,		ranged=1,		melee=1,		roles={1,1,1,3,3},		realName="Kobold Cup"},
	

	-- tier 2
	-- {name="item_bullwhip",				tier=2,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Bullwhip"},
	-- {name="item_dragon_scale",			tier=2,		ranged=1,		melee=1,		roles={1,1,3,1,1},		realName="Dragon Scale"},
	-- {name="item_eye_of_the_vizier",		tier=2,		ranged=1,		melee=1,		roles={1,1,1,4,4},		realName="Eye of the Vizier"},
	-- {name="item_gossamer_cape",			tier=2,		ranged=1,		melee=1,		roles={1,1,1,3,3},		realName="Gossamer Cape"},
	{name="item_searing_signet",			tier=2,		ranged=1,		melee=1,		roles={2,2,1,2,2},		realName="Searing Signet"},
	-- {name="item_grove_bow",				tier=2,		ranged=5,		melee=0,		roles={2,2,1,-5,-5},	realName="Grove Bow"},
	-- {name="item_light_collector", 		tier=2, 	ranged=1, 		melee=1,		roles={1,1,1,3,3}, 		realName = 'Light Collector'},
	-- {name="item_pupils_gift",			tier=2,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Pupil's Gift"},
	-- {name="item_specialists_array",		tier=2,		ranged=2,		melee=0,		roles={2,2,1,1,1},		realName="Specialist's Array"},
	-- {name="item_vambrace",				tier=2,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Vambrace"},
	-- {name="item_iron_talon",			tier=2,		ranged=1,		melee=1,		roles={1,1,1,0,0},		realName="Iron Talon"},
	-- {name="item_vampire_fangs",			tier=2,		ranged=1,		melee=1,		roles={2,2,2,0,0},		realName="Vampire Fangs"},
	{name="item_misericorde",				tier=2,		ranged=1,		melee=1,		roles={4,2,1,0,0},		realName="Brigand's Blade"},
	--{name="item_clumsy_net",				tier=2,		ranged=1,		melee=1,		roles={1,1,2,3,3},		realName="Clumsy Net"},
	--{name="item_dagger_of_ristul",		tier=2,		ranged=1,		melee=1,		roles={2,2,1,1,1},		realName="Dagger of Ristul"},
	{name="item_essence_ring",			tier=2,		ranged=1,		melee=1,		roles={3,3,3,2,2},		realName="Essence Ring"},
	--{name="item_paintball",				tier=2,		ranged=1,		melee=1,		roles={2,2,1,1,1},		realName="Fae Grenade"},
	--{name="item_imp_claw",				tier=2,		ranged=1,		melee=1,		roles={2,1,1,0,0},		realName="Imp Claw"},
	--{name="item_nether_shawl",			tier=2,		ranged=1,		melee=1,		roles={0,0,0,0,0},		realName="Nether Shawl"},
	--{name="item_philosophers_stone",		tier=2,		ranged=1,		melee=1,		roles={0,0,0,0,0},		realName="Philosopher's Stone"},
	--{name="item_quicksilver_amulet",		tier=2,		ranged=1,		melee=1,		roles={2,2,1,1,1},		realName="Quicksilver Amulet"},
	--{name="item_ring_of_aquila",			tier=2,		ranged=1,		melee=1,		roles={3,2,1,0,0},		realName="Ring of Aquila"},
	{name="item_pogo_stick",				tier=2,		ranged=1,		melee=1,		roles={3,3,3,3,3},		realName="Tumbler's Toy"},
	{name="item_mana_draught",			tier=2,		ranged=1,		melee=1,		roles={1,1,1,3,3},		realName="Mana Draught"},
	{name="item_poor_mans_shield",		tier=2,		ranged=1,		melee=3,		roles={2,2,3,1,1},		realName="Poor Man's Shield"},

	-- tier 3
	-- {name="item_cloak_of_flames",		tier=3,		ranged=1,		melee=2,		roles={2,2,6,2,2},		realName="Cloak of Flames"},
	-- {name="item_craggy_coat",			tier=3,		ranged=1,		melee=1,		roles={0,0,4,1,1},		realName="Craggy Coat"},
	-- {name="item_dandelion_amulet",		tier=3,		ranged=1,		melee=2,		roles={2,2,6,2,2},		realName="Dandelion Amulet"},
	-- {name="item_defiant_shell",			tier=3,		ranged=1,		melee=2,		roles={2,2,6,2,2},		realName="Defiant Shell"},
	-- {name="item_doubloon",				tier=3,		ranged=0,		melee=0,		roles={0,0,0,0,0},		realName="Doubloon"},
	-- {name="item_elven_tunic",			tier=3,		ranged=1,		melee=1,		roles={5,5,5,2,2},		realName="Elven Tunic"},
	-- {name="item_enchanted_quiver",		tier=3,		ranged=4,		melee=0,		roles={1,1,1,1,1},		realName="Enchanted Quiver"},
	-- {name="item_vambrace",				tier=3,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Vambrace"},
	-- {name="item_paladin_sword",			tier=3,		ranged=1,		melee=1,		roles={4,1,1,0,0},		realName="Paladin Sword"},
	{name="item_psychic_headband",		tier=3,		ranged=3,		melee=1,		roles={1,1,1,6,6},		realName="Psychic Headband"},
	-- {name="item_nemesis_curse",			tier=3,		ranged=1,		melee=1,		roles={2,2,0,0,0},		realName="Nemesis Curse"},
	-- {name="item_vindicators_axe",		tier=3,		ranged=1,		melee=1,		roles={1,1,4,1,1},		realName="Vindicator's Axe"},
	--{name="item_black_powder_bag",		tier=3,		ranged=1,		melee=1,		roles={1,1,4,1,1},		realName="Blast Rig"},
	--{name="item_greater_faerie_fire",		tier=3,		ranged=1,		melee=1,		roles={1,1,1,0,0},		realName="Greater Faerie Fire"},
	--{name="item_repair_kit",				tier=3,		ranged=1,		melee=1,		roles={0,0,2,1,1},		realName="Repair Kit"},
	--{name="item_quickening_charm",		tier=3,		ranged=1,		melee=1,		roles={1,1,1,4,4},		realName="Quickening Charm"},
	--{name="item_titan_sliver",			tier=3,		ranged=1,		melee=1,		roles={1,1,4,1,1},		realName="Titan Sliver"},
	{name="item_serrated_shiv",			tier=3,		ranged=1,		melee=1,		roles={1,1,4,1,1},		realName="Serrated Shiv"},
	{name="item_gale_guard",			tier=3,		ranged=1,		melee=1,		roles={1,1,4,1,1},		realName="Gale Guard"},
	{name="item_gunpowder_gauntlets",			tier=3,		ranged=1,		melee=1,		roles={1,1,4,1,1},		realName="Gunpowder Gauntlets"},
	{name="item_whisper_of_the_dread",	tier=3,		ranged=1,		melee=1,		roles={1,2,1,4,4},		realName="Whisper of the Dread"},
	-- {name="item_ninja_gear",			tier=3,		ranged=1,		melee=1,		roles={2,1,1,0,0},		realName="Ninja Gear"},
	{name="item_jidi_pollen_bag",	tier=3,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Jidi Pollen Bag"},
	

	-- tier 4
	-- {name="item_ancient_guardian",		tier=4,		ranged=1,		melee=1,		roles={3,1,1,0,0},		realName="Ancient Guardian"},
	-- {name="item_ascetic_cap",			tier=4,		ranged=1,		melee=1,		roles={1,1,6,1,1},		realName="Ascetic's Cap"},
	-- {name="item_avianas_feather",		tier=4,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Aviana's Feather"},
	-- {name="item_havoc_hammer",			tier=4,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Havoc Hammer"},
	-- {name="item_martyrs_plate",			tier=4,		ranged=1,		melee=1,		roles={1,1,5,0,0},		realName="Martyr's Plate"},
	-- {name="item_ogre_seal_totem",		tier=4,		ranged=1,		melee=1,		roles={1,1,3,1,1},		realName="Ogre Seal Totem"},
	-- {name="item_mind_breaker",			tier=4,		ranged=1,		melee=1,		roles={4,1,1,0,0},		realName="Mind Breaker"},
	{name="item_crippling_crossbow",		tier=4,		ranged=1,		melee=1,		roles={1,1,3,1,1},		realName="Crippling Crossbow"},
	{name="item_magnifying_monocle",		tier=4,		ranged=1,		melee=1,		roles={2,2,1,3,3},		realName="Magnifying Monocle"},
	-- {name="item_ceremonial_robe",		tier=4,		ranged=1,		melee=1,		roles={1,1,1,5,5},		realName="Ceremonial Robe"},
	-- {name="item_rattlecage",			tier=4,		ranged=1,		melee=1,		roles={0,0,6,1,1},		realName="Rattlecage"},
	-- {name="item_stormcrafter",			tier=4,		ranged=1,		melee=1,		roles={1,1,3,3,3},		realName="Stormcrafter"},
	-- {name="item_spy_gadget",			tier=4,		ranged=4,		melee=0,		roles={0,0,0,3,3},		realName="Telescope"},
	-- {name="item_timeless_relic",		tier=4,		ranged=1,		melee=1,		roles={1,4,1,3,3},		realName="Timeless Relic"},
	-- {name="item_trickster_cloak",		tier=4,		ranged=1,		melee=1,		roles={1,1,1,4,4},		realName="Trickster Cloak"},
	--{name="item_flicker",					tier=4,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Flicker"},
	--{name="item_illusionsts_cape",		tier=4,		ranged=1,		melee=1,		roles={1,1,1,0,0},		realName="Illusionist's Cape"},
	--{name="item_the_leveller",			tier=4,		ranged=1,		melee=1,		roles={5,1,0,0,0},		realName="The Leveller"},
	--{name="item_penta_edged_sword",		tier=4,		ranged=1,		melee=5,		roles={5,3,1,1,1},		realName="Penta-Edged Sword"},
	--{name="item_princes_knife",			tier=4,		ranged=4,		melee=0,		roles={2,2,1,1,1},		realName="Prince's Knife"},
	--{name="item_spell_prism",				tier=4,		ranged=1,		melee=1,		roles={1,2,1,4,5},		realName="Spell Prism"},
	--{name="item_heavy_blade",				tier=4,		ranged=1,		melee=1,		roles={3,6,1,1,1},		realName="Witchbane"},
	--{name="item_witless_shako",			tier=4,		ranged=1,		melee=1,		roles={1,1,5,2,2},		realName="Witless Shako"},
	{name="item_pyrrhic_cloak",		tier=4,		ranged=1,		melee=1,		roles={1,1,4,4,4},		realName="Pyrrhic Cloak"},
	{name="item_dezun_bloodrite",		tier=4,		ranged=1,		melee=1,		roles={1,2,3,4,4},		realName="Dezun Bloodrite"},
	{name="item_giant_maul",		tier=4,		ranged=1,		melee=1,		roles={5,5,1,0,0},		realName="Giant's Maul"},
	{name="item_outworld_staff",		tier=4,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Outworld Staff"},

	-- tier 5
	-- {name="item_apex",					tier=5,		ranged=1,		melee=1,		roles={1,1,1,0,0},		realName="Apex"},
	-- {name="item_force_field",			tier=5,		ranged=1,		melee=1,		roles={2,5,1,7,7},		realName="Arcanist's Armor"},
	-- {name="item_book_of_shadows",		tier=5,		ranged=1,		melee=1,		roles={1,1,1,6,6},		realName="Book of Shadows"},
	{name="item_demonicon",				tier=5,		ranged=1,		melee=1,		roles={1,1,1,5,6},		realName="Book of the Dead"},
	-- {name="item_force_boots",			tier=5,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Force Boots"},
	-- {name="item_giants_ring",			tier=5,		ranged=1,		melee=1,		roles={3,3,6,1,1},		realName="Giant's Ring"},
	-- {name="item_panic_button",			tier=5,		ranged=1,		melee=1,		roles={1,1,3,1,1},		realName="Magic Lamp"},
	-- {name="item_mirror_shield",			tier=5,		ranged=1,		melee=1,		roles={2,2,4,0,0},		realName="Mirror Shield"},
	-- {name="item_pirate_hat",			tier=5,		ranged=1,		melee=1,		roles={4,3,1,0,0},		realName="Pirate Hat"},
	-- {name="item_seer_stone",			tier=5,		ranged=1,		melee=1,		roles={1,1,2,5,5},		realName="Seer Stone"},
	{name="item_desolator_2",			tier=5,		ranged=1,		melee=1,		roles={5,1,0,0,0},		realName="Stygian Desolator"},
	-- {name="item_unwavering_condition",	tier=5,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Unwavering Condition"},
	--{name="item_ballista",				tier=5,		ranged=5,		melee=0,		roles={1,1,1,0,0},		realName="Ballista"},
	--{name="item_ex_machina",				tier=5,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Ex Machina"},
	{name="item_fallen_sky",				tier=5,		ranged=1,		melee=1,		roles={1,1,5,0,0},		realName="Fallen Sky"},
	--{name="item_trident",					tier=5,		ranged=1,		melee=1,		roles={5,5,3,3,3},		realName="Trident"},
	--{name="item_woodland_striders",		tier=5,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Woodland Striders"},
	{name="item_minotaur_horn",			tier=5,		ranged=1,		melee=1,		roles={1,1,1,1,1},		realName="Minotaur Horn"},
	{name="item_spider_legs",				tier=5,		ranged=1,		melee=1,		roles={2,2,2,2,2},		realName="Spider Legs"},
	{name="item_unrelenting_eye",				tier=5,		ranged=1,		melee=1,		roles={2,2,2,2,2},		realName="Unrelenting Eye"},
	{name="item_helm_of_the_undying",				tier=5,		ranged=1,		melee=1,		roles={5,5,5,5,5},		realName="Helm of the Undying"},
	{name="item_divine_regalia",				tier=5,		ranged=1,		melee=1,		roles={4,4,1,1,1},		realName="Divine Regalia"},
}

local enhancements = {
    -- Tier 1 enhancements
    { name = "item_enhancement_mystical", tier = 1, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
    { name = "item_enhancement_brawny",    tier = 1, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
    { name = "item_enhancement_alert",     tier = 1, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
    { name = "item_enhancement_tough",     tier = 1, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
    { name = "item_enhancement_quickened", tier = 1, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },

    -- Tier 2 enhancements
    { name = "item_enhancement_mystical", tier = 2, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
    { name = "item_enhancement_brawny",    tier = 2, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
    { name = "item_enhancement_alert",     tier = 2, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
    { name = "item_enhancement_tough",     tier = 2, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
    { name = "item_enhancement_quickened", tier = 2, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },
    { name = "item_enhancement_keen_eyed", tier = 2, roles = {1, 1, 1, 1, 2}, realName = "Keen Eyed Enhancement" },
    { name = "item_enhancement_vast",      tier = 2, roles = {1, 1, 1, 1, 1}, realName = "Vast Enhancement" },
    { name = "item_enhancement_greedy",    tier = 2, roles = {1, 1, 1, 2, 2}, realName = "Greedy Enhancement" },
    { name = "item_enhancement_vampiric",  tier = 2, roles = {1, 1, 1, 1, 1}, realName = "Vampiric Enhancement" },

    -- Tier 3 enhancements
    { name = "item_enhancement_mystical", tier = 3, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
    { name = "item_enhancement_brawny",    tier = 3, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
    { name = "item_enhancement_alert",     tier = 3, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
    { name = "item_enhancement_tough",     tier = 3, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
    { name = "item_enhancement_quickened", tier = 3, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },
    { name = "item_enhancement_keen_eyed", tier = 3, roles = {1, 1, 1, 1, 2}, realName = "Keen Eyed Enhancement" },
    { name = "item_enhancement_vast",      tier = 3, roles = {1, 1, 1, 1, 1}, realName = "Vast Enhancement" },
    { name = "item_enhancement_greedy",    tier = 3, roles = {1, 1, 1, 2, 2}, realName = "Greedy Enhancement" },
    { name = "item_enhancement_vampiric",  tier = 3, roles = {1, 1, 1, 1, 1}, realName = "Vampiric Enhancement" },

    -- Tier 4 enhancements
    { name = "item_enhancement_mystical", tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
    { name = "item_enhancement_brawny",    tier = 4, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
    { name = "item_enhancement_alert",     tier = 4, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
    { name = "item_enhancement_tough",     tier = 4, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
    { name = "item_enhancement_quickened", tier = 4, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },
    { name = "item_enhancement_vampiric",  tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Vampiric Enhancement" },
    { name = "item_enhancement_timeless", tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Timeless Enhancement" },
    { name = "item_enhancement_titanic",  tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Titanic Enhancement" },
    { name = "item_enhancement_crude",    tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Crude Enhancement" },

    -- Tier 5 enhancements
    { name = "item_enhancement_timeless", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Timeless Enhancement" },
    { name = "item_enhancement_titanic",  tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Titanic Enhancement" },
    { name = "item_enhancement_crude",    tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Crude Enhancement" },
    { name = "item_enhancement_feverish", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Feverish Enhancement" },
    { name = "item_enhancement_fleetfooted", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Fleetfooted Enhancement" },
    { name = "item_enhancement_audacious", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Audacious Enhancement" },
    { name = "item_enhancement_evolved",  tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Evolved Enhancement" },
    { name = "item_enhancement_boundless", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Boundless Enhancement" },
    { name = "item_enhancement_wise",     tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Wise Enhancement" },
}


return {
	items = neutral_items,
	enhancements = enhancements
}