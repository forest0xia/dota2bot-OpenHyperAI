local X = {}

X['spells'] = {
    ['npc_dota_hero_abaddon'] = {
        ['abaddon_death_coil'] = {weight = 0.8},
        ['abaddon_aphotic_shield'] = {weight = 0.8},
    },
    
    ['npc_dota_hero_abyssal_underlord'] = {
        ['abyssal_underlord_firestorm'] = {weight = 0.5},
        ['abyssal_underlord_pit_of_malice'] = {weight = 0.5},
        ['abyssal_underlord_dark_portal'] = {weight = 0.9},
    },
    
    ['npc_dota_hero_alchemist'] = {
        ['alchemist_acid_spray'] = {weight = 0.6},
        ['alchemist_unstable_concoction'] = {weight = 0.8},
        ['alchemist_unstable_concoction_throw'] = {weight = 0.8},
        ['alchemist_berserk_potion'] = {weight = 0.8},
        ['alchemist_chemical_rage'] = {weight = 0.9},
    },
    
    ['npc_dota_hero_ancient_apparition'] = {
        ['ancient_apparition_cold_feet'] = {weight = 0.7},
        ['ancient_apparition_ice_vortex'] = {weight = 0.6},
        ['ancient_apparition_chilling_touch'] = {weight = 1},
        ['ancient_apparition_ice_blast'] = {weight = 0.3},
        ['ancient_apparition_ice_blast_release'] = {weight = 0.3},
    },
    
    ['npc_dota_hero_antimage'] = {
        ['antimage_blink'] = {weight = 0.5},
        ['antimage_counterspell'] = {weight = 0.8},
        ['antimage_counterspell_ally'] = {weight = 0.9},
        ['antimage_mana_void'] = {weight = 0.5},
    },
    
    ['npc_dota_hero_arc_warden'] = {
        ['arc_warden_flux'] = {weight = 0.6},
        ['arc_warden_magnetic_field'] = {weight = 0.9},
        ['arc_warden_spark_wraith'] = {weight = 0.9},
        ['arc_warden_tempest_double'] = {weight = 1},
    },
    
    ['npc_dota_hero_axe'] = {
        ['axe_berserkers_call'] = {weight = 1},
        ['axe_battle_hunger'] = {weight = 0.8},
        ['axe_culling_blade'] = {weight = 0.2},
    },
    
    ['npc_dota_hero_bane'] = {
        ['bane_enfeeble'] = {weight = 0.5},
        ['bane_brain_sap'] = {weight = 0.5},
        ['bane_nightmare'] = {weight = 0.1},
        ['bane_fiends_grip'] = {weight = 0},
    },
    
    ['npc_dota_hero_batrider'] = {
        ['batrider_sticky_napalm'] = {weight = 1},
        ['batrider_flamebreak'] = {weight = 0.9},
        ['batrider_firefly'] = {weight = 0.9},
        ['batrider_flaming_lasso'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_beastmaster'] = {
        ['beastmaster_wild_axes'] = {weight = 0.4},
        ['beastmaster_call_of_the_wild_boar'] = {weight = 1},
        ['beastmaster_inner_beast'] = {weight = 1},
        ['beastmaster_call_of_the_wild_hawk'] = {weight = 1},
    },
    
    ['npc_dota_hero_bloodseeker'] = {
        ['bloodseeker_bloodrage'] = {weight = 1},
        ['bloodseeker_blood_bath'] = {weight = 0.9},
        ['bloodseeker_blood_mist'] = {weight = 1},
        ['bloodseeker_thirst'] = {weight = 0.9},
        ['bloodseeker_rupture'] = {weight = 0.3},
    },
    
    ['npc_dota_hero_bounty_hunter'] = {
        ['bounty_hunter_shuriken_toss'] = {weight = 0.7},
        ['bounty_hunter_jinada'] = {weight = 1},
        ['bounty_hunter_wind_walk'] = {weight = 0.5},
        ['bounty_hunter_wind_walk_ally'] = {weight = 6},
        ['bounty_hunter_track'] = {weight = 1},
    },
    
    ['npc_dota_hero_brewmaster'] = {
        ['brewmaster_thunder_clap'] = {weight = 0.7},
        ['brewmaster_cinder_brew'] = {weight = 0.7},
        ['brewmaster_drunken_brawler'] = {weight = 1},
        ['brewmaster_primal_companion'] = {weight = 1},
        ['brewmaster_primal_split'] = {weight = 1},
    },
    
    ['npc_dota_hero_bristleback'] = {
        ['bristleback_viscous_nasal_goo'] = {weight = 0.6},
        ['bristleback_quill_spray'] = {weight = 1},
        ['bristleback_bristleback'] = {weight = 0.9},
        ['bristleback_hairball'] = {weight = 0.5},
        ['bristleback_warpath'] = {weight = 1},
    },
    
    ['npc_dota_hero_broodmother'] = {
        ['broodmother_insatiable_hunger'] = {weight = 0.8},
        ['broodmother_spin_web'] = {weight = 1},
        ['broodmother_silken_bola'] = {weight = 0.5},
        ['broodmother_sticky_snare'] = {weight = 1},
        ['broodmother_spawn_spiderlings'] = {weight = 1},
    },
    
    ['npc_dota_hero_centaur'] = {
        ['centaur_hoof_stomp'] = {weight = 0.7},
        ['centaur_double_edge'] = {weight = 1},
        ['centaur_work_horse'] = {weight = 0.2},
        ['centaur_mount'] = {weight = 1},
        ['centaur_stampede'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_chaos_knight'] = {
        ['chaos_knight_chaos_bolt'] = {weight = 0.4},
        ['chaos_knight_reality_rift'] = {weight = 0.8},
        ['chaos_knight_phantasm'] = {weight = 1},
    },
    
    ['npc_dota_hero_chen'] = {
        ['chen_penitence'] = {weight = 0.1},
        ['chen_holy_persuasion'] = {weight = 1},
        ['chen_divine_favor'] = {weight = 0.1},
        ['chen_summon_convert'] = {weight = 1},
        ['chen_hand_of_god'] = {weight = 0.2},
    },
    
    ['npc_dota_hero_clinkz'] = {
        ['clinkz_strafe'] = {weight = 0.9},
        ['clinkz_tar_bomb'] = {weight = 0.8},
        ['clinkz_death_pact'] = {weight = 0.9},
        ['clinkz_burning_barrage'] = {weight = 0.9},
        ['clinkz_burning_army'] = {weight = 0.9},
        ['clinkz_wind_walk'] = {weight = 0.7},
    },
    
    ['npc_dota_hero_crystal_maiden'] = {
        ['crystal_maiden_crystal_nova'] = {weight = 0.6},
        ['crystal_maiden_frostbite'] = {weight = 0.5},
        ['crystal_maiden_brilliance_aura'] = {weight = 1},
        ['crystal_maiden_crystal_clone'] = {weight = 1},
        ['crystal_maiden_freezing_field'] = {weight = 0.1},
    },

    ['npc_dota_hero_dark_willow'] = {
        ['dark_willow_bramble_maze'] = {weight = 0.1},
        ['dark_willow_shadow_realm'] = {weight = 0.5},
        ['dark_willow_cursed_crown'] = {weight = 0.4},
        ['dark_willow_bedlam'] = {weight = 0.8},
        ['dark_willow_terrorize'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_dark_seer'] = {
        ['dark_seer_vacuum'] = {weight = 0.3},
        ['dark_seer_ion_shell'] = {weight = 0.8},
        ['dark_seer_surge'] = {weight = 0.5},
        ['dark_seer_wall_of_replica'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_dawnbreaker'] = {
        ['dawnbreaker_fire_wreath'] = {weight = 0.8},
        ['dawnbreaker_celestial_hammer'] = {weight = 0.4},
        ['dawnbreaker_converge'] = {weight = 1},
        ['dawnbreaker_solar_guardian'] = {weight = 0.7},
    },
    
    ['npc_dota_hero_dazzle'] = {
        ['dazzle_poison_touch'] = {weight = 0.7},
        ['dazzle_shallow_grave'] = {weight = 0.1},
        ['dazzle_shadow_wave'] = {weight = 0.6},
        ['dazzle_bad_juju'] = {weight = 0.8},
        ['dazzle_nothl_projection'] = {weight = 1},
        ['dazzle_nothl_projection_end'] = {weight = 1},
    },
    
    ['npc_dota_hero_death_prophet'] = {
        ['death_prophet_carrion_swarm'] = {weight = 0.7},
        ['death_prophet_silence'] = {weight = 0.2},
        ['death_prophet_spirit_siphon'] = {weight = 0.8},
        ['death_prophet_exorcism'] = {weight = 0.4},
    },
    
    ['npc_dota_hero_disruptor'] = {
        ['disruptor_thunder_strike'] = {weight = 0.6},
        ['disruptor_glimpse'] = {weight = 0.3},
        ['disruptor_kinetic_field'] = {weight = 0.3},
        ['disruptor_kinetic_fence'] = {weight = 0.3},
        ['disruptor_static_storm'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_doom_bringer'] = {
        ['doom_bringer_devour'] = {weight = 0.9},
        ['doom_bringer_scorched_earth'] = {weight = 0.8},
        ['doom_bringer_infernal_blade'] = {weight = 0.9},
        ['doom_bringer_doom'] = {weight = 0.2},
    },
    
    ['npc_dota_hero_dragon_knight'] = {
        ['dragon_knight_breathe_fire'] = {weight = 0.7},
        ['dragon_knight_dragon_tail'] = {weight = 0.5},
        ['dragon_knight_fireball'] = {weight = 0.7},
        ['dragon_knight_elder_dragon_form'] = {weight = 0.5},
    },
    
    ['npc_dota_hero_drow_ranger'] = {
        ['drow_ranger_frost_arrows'] = {weight = 1},
        ['drow_ranger_wave_of_silence'] = {weight = 0.3},
        ['drow_ranger_multishot'] = {weight = 0.9},
        ['drow_ranger_glacier'] = {weight = 0.7},
    },
    
    ['npc_dota_hero_earth_spirit'] = {
        ['earth_spirit_boulder_smash'] = {weight = 0.6},
        ['earth_spirit_rolling_boulder'] = {weight = 0.3},
        ['earth_spirit_geomagnetic_grip'] = {weight = 1},
        ['earth_spirit_petrify'] = {weight = 1},
        ['earth_spirit_stone_caller'] = {weight = 0.9},
        ['earth_spirit_magnetize'] = {weight = 0.2},
    },
    
    ['npc_dota_hero_earthshaker'] = {
        ['earthshaker_fissure'] = {weight = 0},
        ['earthshaker_enchant_totem'] = {weight = 1},
        ['earthshaker_echo_slam'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_elder_titan'] = {
        ['elder_titan_echo_stomp'] = {weight = 0.8},
        ['elder_titan_ancestral_spirit'] = {weight = 1},
        ['elder_titan_move_spirit'] = {weight = 1},
        ['elder_titan_return_spirit'] = {weight = 1},
        ['elder_titan_earth_splitter'] = {weight = 0.5},
    },

    ['npc_dota_hero_ember_spirit'] = {
        ['ember_spirit_searing_chains'] = {weight = 0.7},
        ['ember_spirit_sleight_of_fist'] = {weight = 0.9},
        ['ember_spirit_flame_guard'] = {weight = 0.8},
        ['ember_spirit_activate_fire_remnant'] = {weight = 1},
        ['ember_spirit_fire_remnant'] = {weight = 1},
    },
    
    ['npc_dota_hero_enchantress'] = {
        ['enchantress_impetus'] = {weight = 1},
        ['enchantress_enchant'] = {weight = 1},
        ['enchantress_natures_attendants'] = {weight = 0.5},
        ['enchantress_bunny_hop'] = {weight = 0.9},
        ['enchantress_little_friends'] = {weight = 1},
    },
    
    ['npc_dota_hero_enigma'] = {
        ['enigma_malefice'] = {weight = 0.8},
        ['enigma_demonic_conversion'] = {weight = 1},
        ['enigma_midnight_pulse'] = {weight = 0.6},
        ['enigma_black_hole'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_faceless_void'] = {
        ['faceless_void_time_walk'] = {weight = 0.5},
        ['faceless_void_time_dilation'] = {weight = 0.8},
        ['faceless_void_time_walk_reverse'] = {weight = 1},
        ['faceless_void_chronosphere'] = {weight = 0.1},
        ['faceless_void_time_zone'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_furion'] = {
        ['furion_sprout'] = {weight = 0.1},
        ['furion_teleportation'] = {weight = 0.5},
        ['furion_force_of_nature'] = {weight = 0.8},
        ['furion_curse_of_the_forest'] = {weight = 0.3},
        ['furion_wrath_of_nature'] = {weight = 0.7},
    },
    
    ['npc_dota_hero_grimstroke'] = {
        ['grimstroke_dark_artistry'] = {weight = 0.5},
        ['grimstroke_ink_creature'] = {weight = 0.3},
        ['grimstroke_spirit_walk'] = {weight = 0.5},
        ['grimstroke_dark_portrait'] = {weight = 0.2},
        ['grimstroke_return'] = {weight = 1},
        ['grimstroke_soul_chain'] = {weight = 0.2},
    },
    
    ['npc_dota_hero_gyrocopter'] = {
        ['gyrocopter_rocket_barrage'] = {weight = 0.8},
        ['gyrocopter_homing_missile'] = {weight = 0.3},
        ['gyrocopter_flak_cannon'] = {weight = 0.9},
        ['gyrocopter_call_down'] = {weight = 0.6},
    },

    ['npc_dota_hero_hoodwink'] = {
        ['hoodwink_acorn_shot'] = {weight = 0.8},
        ['hoodwink_bushwhack'] = {weight = 0.8},
        ['hoodwink_scurry'] = {weight = 0.8},
        ['hoodwink_hunters_boomerang'] = {weight = 0.5},
        ['hoodwink_decoy'] = {weight = 0.9},
        ['hoodwink_sharpshooter'] = {weight = 0.8},
        ['hoodwink_sharpshooter_release'] = {weight = 1},
    },
    
    ['npc_dota_hero_huskar'] = {
        ['huskar_inner_fire'] = {weight = 0.5},
        ['huskar_burning_spear'] = {weight = 1},
        ['huskar_life_break'] = {weight = 1},
    },
    
    ['npc_dota_hero_invoker'] = {
        ['invoker_quas'] = {weight = 1},
        ['invoker_wex'] = {weight = 1},
        ['invoker_exort'] = {weight = 1},
        ['invoker_invoke'] = {weight = 1},
        ['invoker_alacrity'] = {weight = 0.9},
        ['invoker_chaos_meteor'] = {weight = 0.5},
        ['invoker_cold_snap'] = {weight = 0.5},
        ['invoker_deafening_blast'] = {weight = 0.6},
        ['invoker_emp'] = {weight = 0.4},
        ['invoker_forge_spirit'] = {weight = 0.9},
        ['invoker_ghost_walk'] = {weight = 0.8},
        ['invoker_ice_wall'] = {weight = 0.7},
        ['invoker_sun_strike'] = {weight = 0.8},
        ['invoker_tornado'] = {weight = 0.7},
    },
    
    ['npc_dota_hero_jakiro'] = {
        ['jakiro_dual_breath'] = {weight = 0.8},
        ['jakiro_ice_path'] = {weight = 0.1},
        ['jakiro_liquid_fire'] = {weight = 1},
        ['jakiro_liquid_frost'] = {weight = 1},
        ['jakiro_macropyre'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_juggernaut'] = {
        ['juggernaut_blade_fury'] = {weight = 0.3},
        ['juggernaut_healing_ward'] = {weight = 0.3},
        ['juggernaut_blade_dance'] = {weight = 1},
        ['juggernaut_swift_slash'] = {weight = 1},
        ['juggernaut_omni_slash'] = {weight = 1},
    },
    
    ['npc_dota_hero_keeper_of_the_light'] = {
        ['keeper_of_the_light_illuminate'] = {weight = 0.9},
        ['keeper_of_the_light_illuminate_end'] = {weight = 1},
        ['keeper_of_the_light_blinding_light'] = {weight = 0.7},
        ['keeper_of_the_light_chakra_magic'] = {weight = 0.2},
        ['keeper_of_the_light_radiant_bind'] = {weight = 0.2},
        ['keeper_of_the_light_recall'] = {weight = 1},
        ['keeper_of_the_light_will_o_wisp'] = {weight = 0.1},
        ['keeper_of_the_light_spirit_form'] = {weight = 1},
    },

    ['npc_dota_hero_kez'] = {
        ['kez_echo_slash'] = {weight = 0.9},
        ['kez_grappling_claw'] = {weight = 0.5},
        ['kez_kazurai_katana'] = {weight = 1},
        ['kez_raptor_dance'] = {weight = 0.8},
        ['kez_falcon_rush'] = {weight = 0.8},
        ['kez_talon_toss'] = {weight = 0.2},
        ['kez_shodo_sai'] = {weight = 1},
        ['kez_ravens_veil'] = {weight = 0.6},
        ['kez_switch_weapons'] = {weight = 1},
    },
    
    ['npc_dota_hero_kunkka'] = {
        ['kunkka_torrent'] = {weight = 0.7},
        ['kunkka_tidebringer'] = {weight = 1},
        ['kunkka_x_marks_the_spot'] = {weight = 0.3},
        ['kunkka_return'] = {weight = 1},
        ['kunkka_tidal_wave'] = {weight = 0.2},
        ['kunkka_ghostship'] = {weight = 0.8},
    },
    
    ['npc_dota_hero_legion_commander'] = {
        ['legion_commander_overwhelming_odds'] = {weight = 0.8},
        ['legion_commander_press_the_attack'] = {weight = 0.2},
        ['legion_commander_moment_of_courage'] = {weight = 1},
        ['legion_commander_duel'] = {weight = 0.8},
    },
    
    ['npc_dota_hero_leshrac'] = {
        ['leshrac_split_earth'] = {weight = 0.3},
        ['leshrac_diabolic_edict'] = {weight = 0.9},
        ['leshrac_lightning_storm'] = {weight = 0.7},
        ['leshrac_greater_lightning_storm'] = {weight = 0.2},
        ['leshrac_pulse_nova'] = {weight = 1},
    },
    
    ['npc_dota_hero_lich'] = {
        ['lich_frost_nova'] = {weight = 0.4},
        ['lich_frost_shield'] = {weight = 0.4},
        ['lich_sinister_gaze'] = {weight = 0.7},
        ['lich_ice_spire'] = {weight = 0.9},
        ['lich_chain_frost'] = {weight = 0.1},
    },
    
    ['npc_dota_hero_life_stealer'] = {
        ['life_stealer_rage'] = {weight = 0.1},
        ['life_stealer_feast'] = {weight = 1},
        ['life_stealer_ghoul_frenzy'] = {weight = 1},
        ['life_stealer_open_wounds'] = {weight = 0.5},
        ['life_stealer_infest'] = {weight = 1},
        ['life_stealer_consume'] = {weight = 1},
    },
    
    ['npc_dota_hero_lina'] = {
        ['lina_dragon_slave'] = {weight = 0.5},
        ['lina_light_strike_array'] = {weight = 0.5},
        ['lina_fiery_soul'] = {weight = 1},
        ['lina_flame_cloak'] = {weight = 1},
        ['lina_laguna_blade'] = {weight = 0.5},
    },

    ['npc_dota_hero_lion'] = {
        ['lion_impale'] = {weight = 0},
        ['lion_voodoo'] = {weight = 0},
        ['lion_mana_drain'] = {weight = 0.5},
        ['lion_finger_of_death'] = {weight = 0.5},
    },

    ['npc_dota_hero_luna'] = {
        ['luna_lucent_beam'] = {weight = 0.5},
        ['luna_lunar_orbit'] = {weight = 1},
        ['luna_moon_glaive'] = {weight = 1},
        ['luna_lunar_blessing'] = {weight = 1},
        ['luna_eclipse'] = {weight = 0.5},
    },

    ['npc_dota_hero_lycan'] = {
        ['lycan_summon_wolves'] = {weight = 0.8},
        ['lycan_howl'] = {weight = 0.5},
        ['lycan_feral_impulse'] = {weight = 1},
        ['lycan_wolf_bite'] = {weight = 1},
        ['lycan_shapeshift'] = {weight = 1},
    },

    ['npc_dota_hero_magnataur'] = {
        ['magnataur_shockwave'] = {weight = 8},
        ['magnataur_empower'] = {weight = 0.8},
        ['magnataur_skewer'] = {weight = 0.3},
        ['magnataur_horn_toss'] = {weight = 0.5},
        ['magnataur_reverse_polarity'] = {weight = 0.1},
    },

    ['npc_dota_hero_marci'] = {
        ['marci_grapple'] = {weight = 0.2},
        ['marci_companion_run'] = {weight = 0.7},
        ['marci_guardian'] = {weight = 0.5},
        ['marci_bodyguard'] = {weight = 0.5},
        ['marci_unleash'] = {weight = 0.8},
    },

    ['npc_dota_hero_mars'] = {
        ['mars_spear'] = {weight = 0.1},
        ['mars_gods_rebuke'] = {weight = 0.8},
        ['mars_bulwark'] = {weight = 1},
        ['mars_arena_of_blood'] = {weight = 0.2},
    },

    ['npc_dota_hero_medusa'] = {
        ['medusa_split_shot'] = {weight = 1},
        ['medusa_mystic_snake'] = {weight = 0.5},
        ['medusa_mana_shield'] = {weight = 1},
        ['medusa_cold_blooded'] = {weight = 1},
        ['medusa_gorgon_grasp'] = {weight = 0.3},
        ['medusa_stone_gaze'] = {weight = 0.8},
    },

    ['npc_dota_hero_meepo'] = {
        ['meepo_earthbind'] = {weight = 0.2},
        ['meepo_poof'] = {weight = 1},
        ['meepo_ransack'] = {weight = 1},
        ['meepo_petrify'] = {weight = 0.3},
        ['meepo_megameepo'] = {weight = 1},
        ['meepo_megameepo_fling'] = {weight = 1},
        ['meepo_divided_we_stand'] = {weight = 1},
    },

    ['npc_dota_hero_mirana'] = {
        ['mirana_starfall'] = {weight = 0.8},
        ['mirana_arrow'] = {weight = 0.5},
        ['mirana_leap'] = {weight = 0.5},
        ['mirana_invis'] = {weight = 0.5},
    },

    ['npc_dota_hero_monkey_king'] = {
        ['monkey_king_boundless_strike'] = {weight = 0.2},
        ['monkey_king_tree_dance'] = {weight = 0.9},
        ['monkey_king_primal_spring'] = {weight = 0.8},
        ['monkey_king_primal_spring_early'] = {weight = 1},
        ['monkey_king_jingu_mastery'] = {weight = 1},
        ['monkey_king_mischief'] = {weight = 1},
        ['monkey_king_untransform'] = {weight = 1},
        ['monkey_king_wukongs_command'] = {weight = 0.2},
    },

    ['npc_dota_hero_muerta'] = {
        ['muerta_dead_shot'] = {weight = 0.8},
        ['muerta_the_calling'] = {weight = 0.5},
        ['muerta_gunslinger'] = {weight = 1},
        ['muerta_ofrenda'] = {weight = 1},
        ['muerta_ofrenda_destroy'] = {weight = 1},
        ['muerta_parting_shot'] = {weight = 0.5},
        ['muerta_pierce_the_veil'] = {weight = 0.9},
    },

    ['npc_dota_hero_naga_siren'] = {
        ['naga_siren_mirror_image'] = {weight = 0.9},
        ['naga_siren_ensnare'] = {weight = 0.2},
        ['naga_siren_rip_tide'] = {weight = 1},
        ['naga_siren_deluge'] = {weight = 1},
        ['naga_siren_reel_in' ] = {weight = 1},
        ['naga_siren_song_of_the_siren'] = {weight = 0.5},
        [ 'naga_siren_song_of_the_siren_cancel' ] = {weight = 1},
    },

    ['npc_dota_hero_necrolyte'] = {
        ['necrolyte_death_pulse'] = {weight = 0.9},
        ['necrolyte_ghost_shroud'] = {weight = 0.5},
        ['necrolyte_heartstopper_aura'] = {weight = 1},
        ['necrolyte_death_seeker'] = {weight = 0.8},
        ['necrolyte_reapers_scythe'] = {weight = 0.5},
    },

    ['npc_dota_hero_nevermore'] = {
        ['nevermore_shadowraze1'] = {weight = 0.9},
        ['nevermore_shadowraze2'] = {weight = 0.9},
        ['nevermore_shadowraze3'] = {weight = 0.9},
        ['nevermore_frenzy'] = {weight = 1},
        ['nevermore_necromastery'] = {weight = 1},
        ['nevermore_dark_lord'] = {weight = 1},
        ['nevermore_requiem'] = {weight = 0.5},
    },

    ['npc_dota_hero_night_stalker'] = {
        ['night_stalker_void'] = {weight = 0.5},
        ['night_stalker_crippling_fear'] = {weight = 0.5},
        ['night_stalker_hunter_in_the_night'] = {weight = 1},
        ['night_stalker_darkness'] = {weight = 0.8},
    },

    ['npc_dota_hero_nyx_assassin'] = {
        ['nyx_assassin_impale'] = {weight = 0},
        ['nyx_assassin_jolt'] = {weight = 0.5},
        ['nyx_assassin_spiked_carapace'] = {weight = 0.8},
        ['nyx_assassin_burrow'] = {weight = 0.8},
        ['nyx_assassin_unburrow'] = {weight = 1},
        ['nyx_assassin_vendetta'] = {weight = 0.4},
    },

    ['npc_dota_hero_obsidian_destroyer'] = {
        ['obsidian_destroyer_arcane_orb'] = {weight = 1},
        ['obsidian_destroyer_astral_imprisonment'] = {weight = 0.2},
        ['obsidian_destroyer_equilibrium'] = {weight = 1},
        ['obsidian_destroyer_sanity_eclipse'] = {weight = 0.5},
    },

    ['npc_dota_hero_ogre_magi'] = {
        ['ogre_magi_fireblast'] = {weight = 0.1},
        ['ogre_magi_ignite'] = {weight = 0.5},
        ['ogre_magi_bloodlust'] = {weight = 0.5},
        ['ogre_magi_unrefined_fireblast'] = {weight = 0.3},
        ['ogre_magi_smash'] = {weight = 0.5},
        ['ogre_magi_multicast'] = {weight = 1},
    },

    ['npc_dota_hero_omniknight'] = {
        ['omniknight_purification'] = {weight = 0.5},
        ['omniknight_martyr'] = {weight = 0.3},
        ['omniknight_hammer_of_purity'] = {weight = 0.8},
        ['omniknight_guardian_angel'] = {weight = 0.2},
    },

    ['npc_dota_hero_oracle'] = {
        ['oracle_fortunes_end'] = {weight = 0.5},
        ['oracle_fates_edict'] = {weight = 0.5},
        ['oracle_purifying_flames'] = {weight = 0.5},
        ['oracle_rain_of_destiny'] = {weight = 0.5},
        ['oracle_false_promise'] = {weight = 0.2},
    },

    ['npc_dota_hero_pangolier'] = {
        ['pangolier_swashbuckle'] = {weight = 0.5},
        ['pangolier_shield_crash'] = {weight = 0.5},
        ['pangolier_luckyshot'] = {weight = 1},
        ['pangolier_rollup'] = {weight = 0.2},
        ['pangolier_rollup_stop'] = {weight = 1},
        ['pangolier_gyroshell'] = {weight = 0.1},
        ['pangolier_gyroshell_stop'] = {weight = 1},
    },

    ['npc_dota_hero_phantom_assassin'] = {
        ['phantom_assassin_stifling_dagger'] = {weight = 0.9},
        ['phantom_assassin_phantom_strike'] = {weight = 0.9},
        ['phantom_assassin_fan_of_knives'] = {weight = 0.5},
        ['phantom_assassin_blur'] = {weight = 0.5},
        ['phantom_assassin_coup_de_grace'] = {weight = 1},
    },

    ['npc_dota_hero_phantom_lancer'] = {
        ['phantom_lancer_spirit_lance'] = {weight = 0.8},
        ['phantom_lancer_doppelwalk'] = {weight = 0.5},
        ['phantom_lancer_phantom_edge'] = {weight = 1},
        ['phantom_lancer_juxtapose'] = {weight = 1},
    },

    ['npc_dota_hero_phoenix'] = {
        ['phoenix_icarus_dive'] = {weight = 0.5},
        ['phoenix_icarus_dive_stop'] = {weight = 1},
        ['phoenix_fire_spirits'] = {weight = 0.5},
        ['phoenix_launch_fire_spirit'] = {weight = 1},
        ['phoenix_sun_ray'] = {weight = 0.5},
        ['phoenix_sun_ray_stop'] = {weight = 1},
        ['phoenix_sun_ray_toggle_move'] = {weight = 1},
        ['phoenix_supernova'] = {weight = 0.1},
    },

    ['npc_dota_hero_primal_beast'] = {
        ['primal_beast_onslaught'] = {weight = 0.9},
        ['primal_beast_onslaught_release'] = {weight = 0.9},
        ['primal_beast_trample'] = {weight = 0.9},
        ['primal_beast_uproar'] = {weight = 1},
        ['primal_beast_rock_throw'] = {weight = 0.3},
        ['primal_beast_pulverize'] = {weight = 0.1},
    },

    ['npc_dota_hero_puck'] = {
        ['puck_illusory_orb'] = {weight = 0.5},
        ['puck_waning_rift'] = {weight = 0.5},
        ['puck_phase_shift'] = {weight = 0.5},
        ['puck_ethereal_jaunt'] = {weight = 0.5},
        ['puck_dream_coil'] = {weight = 0.1},
    },

    ['npc_dota_hero_pudge'] = {
        ['pudge_meat_hook'] = {weight = 0},
        ['pudge_rot'] = {weight = 0.9},
        ['pudge_flesh_heap'] = {weight = 0.5},
        ['pudge_eject'] = {weight = 1},
        ['pudge_dismember'] = {weight = 0.3},
    },

    ['npc_dota_hero_pugna'] = {
        ['pugna_nether_blast'] = {weight = 0.3},
        ['pugna_decrepify'] = {weight = 0.3},
        ['pugna_nether_ward'] = {weight = 0.5},
        ['pugna_life_drain'] = {weight = 0.4},
    },

    ['npc_dota_hero_queenofpain'] = {
        ['queenofpain_shadow_strike'] = {weight = 0.2},
        ['queenofpain_blink'] = {weight = 0.4},
        ['queenofpain_scream_of_pain'] = {weight = 0.8},
        ['queenofpain_sonic_wave'] = {weight = 0.3},
    },

    ['npc_dota_hero_rattletrap'] = {
        ['rattletrap_battery_assault'] = {weight = 0.8},
        ['rattletrap_power_cogs'] = {weight = 0.8},
        ['rattletrap_rocket_flare'] = {weight = 0.5},
        ['rattletrap_jetpack'] = {weight = 0.1},
        ['rattletrap_overclocking'] = {weight = 0.9},
        ['rattletrap_hookshot'] = {weight = 0.4},
    },

    ['npc_dota_hero_razor'] = {
        ['razor_plasma_field'] = {weight = 0.7},
        ['razor_static_link'] = {weight = 0.9},
        ['razor_unstable_current'] = {weight = 1},
        ['razor_eye_of_the_storm'] = {weight = 0.6},
    },

    ['npc_dota_hero_riki'] = {
        ['riki_smoke_screen'] = {weight = 0.2},
        ['riki_blink_strike'] = {weight = 0.5},
        ['riki_tricks_of_the_trade'] = {weight = 0.7},
        ['riki_backstab'] = {weight = 1},
    },

    ['npc_dota_hero_ringmaster'] = {
        ['ringmaster_tame_the_beasts'] = {weight = 0.1},
        ['ringmaster_tame_the_beasts_crack'] = {weight = 1},
        ['ringmaster_the_box'] = {weight = 0.3},
        ['ringmaster_impalement'] = {weight = 0.5},
        ['ringmaster_spotlight'] = {weight = 0.4},
        ['ringmaster_wheel'] = {weight = 0.3},
        ['ringmaster_funhouse_mirror'] = {weight = 0.8},
        ['ringmaster_strongman_tonic'] = {weight = 0.2},
        ['ringmaster_whoopee_cushion'] = {weight = 0.2},
        ['ringmaster_crystal_ball'] = {weight = 1},
        ['ringmaster_weighted_pie'] = {weight = 0.2},
        ['ringmaster_summon_unicycle'] = {weight = 0.5},
    },

    ['npc_dota_hero_sand_king'] = {
        ['sandking_burrowstrike'] = {weight = 0},
        ['sandking_sand_storm'] = {weight = 0.5},
        ['sandking_scorpion_strike'] = {weight = 0.8},
        ['sandking_epicenter'] = {weight = 0.4},
    },

    ['npc_dota_hero_shadow_demon'] = {
        ['shadow_demon_disruption'] = {weight = 0.2},
        ['shadow_demon_disseminate'] = {weight = 0.5},
        ['shadow_demon_shadow_poison'] = {weight = 0.5},
        ['shadow_demon_shadow_poison_release'] = {weight = 1},
        ['shadow_demon_demonic_cleanse'] = {weight = 0.3},
        ['shadow_demon_demonic_purge'] = {weight = 0.3},
    },

    ['npc_dota_hero_shadow_shaman'] = {
        ['shadow_shaman_ether_shock'] = {weight = 0.5},
        ['shadow_shaman_voodoo'] = {weight = 0},
        ['shadow_shaman_shackles'] = {weight = 0},
        ['shadow_shaman_mass_serpent_ward'] = {weight = 0.2},
    },

    ['npc_dota_hero_shredder'] = {
        ['shredder_whirling_death'] = {weight = 0.5},
        ['shredder_timber_chain'] = {weight = 0.5},
        ['shredder_reactive_armor'] = {weight = 1},
        ['shredder_chakram'] = {weight = 0.5},
        ['shredder_return_chakram'] = {weight = 1},
        ['shredder_chakram_2'] = {weight = 0.5},
        ['shredder_return_chakram_2'] = {weight = 1},
        ['shredder_flamethrower'] = {weight = 0.5},
        ['shredder_twisted_chakram'] = {weight = 0.5},
    },

    ['npc_dota_hero_silencer'] = {
        ['silencer_curse_of_the_silent'] = {weight = 0.5},
        ['silencer_glaives_of_wisdom'] = {weight = 0.9},
        ['silencer_last_word'] = {weight = 1},
        ['silencer_global_silence'] = {weight = 0.1},
    },

    ['npc_dota_hero_skeleton_king'] = {
        ['skeleton_king_hellfire_blast'] = {weight = 0.1},
        ['skeleton_king_bone_guard'] = {weight = 0.8},
        ['skeleton_king_mortal_strike'] = {weight = 1},
        ['skeleton_king_reincarnation'] = {weight = 0.1},
    },

    ['npc_dota_hero_skywrath_mage'] = {
        ['skywrath_mage_arcane_bolt'] = {weight = 0.5},
        ['skywrath_mage_concussive_shot'] = {weight = 0.5},
        ['skywrath_mage_ancient_seal'] = {weight = 0.5},
        ['skywrath_mage_mystic_flare'] = {weight = 0.5},
    },

    ['npc_dota_hero_slardar'] = {
        ['slardar_sprint'] = {weight = 0.5},
        ['slardar_slithereen_crush'] = {weight = 0.5},
        ['slardar_bash'] = {weight = 1},
        ['slardar_amplify_damage'] = {weight = 0.1},
    },

    ['npc_dota_hero_slark'] = {
        ['slark_dark_pact'] = {weight = 0.5},
        ['slark_pounce'] = {weight = 0.6},
        ['slark_essence_shift'] = {weight = 1},
        ['slark_depth_shroud'] = {weight = 0.2},
        ['slark_shadow_dance'] = {weight = 0.6},
    },

    ['npc_dota_hero_snapfire'] = {
        ['snapfire_scatterblast'] = {weight = 0.8},
        ['snapfire_firesnap_cookie'] = {weight = 0.8},
        ['snapfire_lil_shredder'] = {weight = 0.8},
        ['snapfire_gobble_up'] = {weight = 1},
        ['snapfire_spit_creep'] = {weight = 1},
        ['snapfire_mortimer_kisses'] = {weight = 0.4},
    },

    ['npc_dota_hero_sniper'] = {
        ['sniper_shrapnel'] = {weight = 0.5},
        ['sniper_headshot'] = {weight = 1},
        ['sniper_take_aim'] = {weight = 1},
        ['sniper_concussive_grenade'] = {weight = 0.5},
        ['sniper_assassinate'] = {weight = 0.8},
    },

    ['npc_dota_hero_spectre'] = {
        ['spectre_spectral_dagger'] = {weight = 0.6},
        ['spectre_desolate'] = {weight = 1},
        ['spectre_dispersion'] = {weight = 1},
        ['spectre_haunt_single'] = {weight = 1},
        ['spectre_haunt'] = {weight = 1},
        ['spectre_reality'] = {weight = 1},
    },

    ['npc_dota_hero_spirit_breaker'] = {
        ['spirit_breaker_charge_of_darkness'] = {weight = 0.6},
        ['spirit_breaker_bulldoze'] = {weight = 0.7},
        ['spirit_breaker_greater_bash'] = {weight = 1},
        ['spirit_breaker_planar_pocket'] = {weight = 0.7},
        ['spirit_breaker_nether_strike'] = {weight = 0.6},
    },

    ['npc_dota_hero_storm_spirit'] = {
        ['storm_spirit_static_remnant'] = {weight = 0.8},
        ['storm_spirit_electric_vortex'] = {weight = 0.2},
        ['storm_spirit_overload'] = {weight = 1},
        ['storm_spirit_ball_lightning'] = {weight = 0.4},
    },

    ['npc_dota_hero_sven'] = {
        ['sven_storm_bolt'] = {weight = 0},
        ['sven_great_cleave'] = {weight = 1},
        ['sven_warcry'] = {weight = 0.1},
        ['sven_gods_strength'] = {weight = 0.8},
    },

    ['npc_dota_hero_techies'] = {
        ['techies_sticky_bomb'] = {weight = 0.2},
        ['techies_reactive_tazer'] = {weight = 0.5},
        ['techies_reactive_tazer_stop'] = {weight = 1},
        ['techies_suicide'] = {weight = 1},
        ['techies_minefield_sign'] = {weight = 1},
        ['techies_land_mines'] = {weight = 0.5},
    },

    ['npc_dota_hero_templar_assassin'] = {
        ['templar_assassin_refraction'] = {weight = 1},
        ['templar_assassin_meld'] = {weight = 0.8},
        ['templar_assassin_psi_blades'] = {weight = 1},
        ['templar_assassin_trap'] = {weight = 1},
        ['templar_assassin_trap_teleport'] = {weight = 1},
        ['templar_assassin_psionic_trap'] = {weight = 1},
    },

    ['npc_dota_hero_terrorblade'] = {
        ['terrorblade_reflection'] = {weight = 0.1},
        ['terrorblade_conjure_image'] = {weight = 0.6},
        ['terrorblade_metamorphosis'] = {weight = 0.6},
        ['terrorblade_demon_zeal'] = {weight = 0.8},
        ['terrorblade_terror_wave'] = {weight = 0.5},
        ['terrorblade_sunder'] = {weight = 0.1},
    },

    ['npc_dota_hero_tidehunter'] = {
        ['tidehunter_gush'] = {weight = 0.5},
        ['tidehunter_kraken_shell'] = {weight = 0.4},
        ['tidehunter_anchor_smash'] = {weight = 0.5},
        [ 'tidehunter_dead_in_the_water' ] = {weight = 0.1},
        ['tidehunter_ravage'] = {weight = 0.1},
    },

    ['npc_dota_hero_tinker'] = {
        ['tinker_laser'] = {weight = 0.3},
        ['tinker_heat_seeking_missile'] = {weight = 1},
        ['tinker_march_of_the_machines'] = {weight = 0.5},
        ['tinker_defense_matrix'] = {weight = 0.1},
        ['tinker_warp_grenade'] = {weight = 0.6},
        ['tinker_keen_teleport'] = {weight = 0.6},
        ['tinker_rearm'] = {weight = 1},
    },

    ['npc_dota_hero_tiny'] = {
        ["tiny_avalanche"] = {weight = 0.1},
        ["tiny_toss"] = {weight = 0.1},
        ["tiny_tree_grab"] = {weight = 1},
        ["tiny_toss_tree"] = {weight = 1},
        ["tiny_tree_channel"] = {weight = 0.8},
        ["tiny_grow"] = {weight = 1},
    },

    ['npc_dota_hero_treant'] = {
        ['treant_natures_grasp'] = {weight = 0.2},
        ['treant_leech_seed'] = {weight = 0.2},
        ['treant_living_armor'] = {weight = 0.1},
        ['treant_natures_guise'] = {weight = 1},
        ['treant_eyes_in_the_forest'] = {weight = 0.5},
        ['treant_overgrowth'] = {weight = 0.1},
    },

    ['npc_dota_hero_troll_warlord'] = {
        ['troll_warlord_switch_stance'] = {weight = 1},
        ['troll_warlord_whirling_axes_ranged'] = {weight = 0.1},
        ['troll_warlord_whirling_axes_melee'] = {weight = 0.6},
        ['troll_warlord_fervor'] = {weight = 1},
        ['troll_warlord_berserkers_rage'] = {weight = 1},
        ['troll_warlord_battle_trance'] = {weight = 1},
    },

    ['npc_dota_hero_tusk'] = {
        ['tusk_ice_shards'] = {weight = 0.6},
        ['tusk_snowball'] = {weight = 0.8},
        ['tusk_launch_snowball'] = {weight = 1},
        ['tusk_tag_team'] = {weight = 0.5},
        ['tusk_drinking_buddies'] = {weight = 0.5},
        ['tusk_walrus_kick'] = {weight = 1},
        ['tusk_walrus_punch'] = {weight = 0.4},
    },

    ['npc_dota_hero_undying'] = {
        ['undying_decay'] = {weight = 0.2},
        ['undying_soul_rip'] = {weight = 0.2},
        ['undying_tombstone'] = {weight = 0.1},
        ['undying_flesh_golem'] = {weight = 1},
    },

    ['npc_dota_hero_ursa'] = {
        ['ursa_earthshock'] = {weight = 0.2},
        ['ursa_overpower'] = {weight = 1},
        ['ursa_fury_swipes'] = {weight = 1},
        ['ursa_enrage'] = {weight = 0.1},
    },

    ['npc_dota_hero_vengefulspirit'] = {
        ['vengefulspirit_magic_missile'] = {weight = 0},
        ['vengefulspirit_wave_of_terror'] = {weight = 0.1},
        ['vengefulspirit_command_aura'] = {weight = 1},
        ['vengefulspirit_nether_swap'] = {weight = 0.3},
    },

    ['npc_dota_hero_venomancer'] = {
        ['venomancer_venomous_gale'] = {weight = 0.4},
        ['venomancer_poison_sting'] = {weight = 1},
        ['venomancer_plague_ward'] = {weight = 0.8},
        ['venomancer_latent_poison'] = {weight = 1},
        ['venomancer_poison_nova'] = {weight = 1},
        ['venomancer_noxious_plague'] = {weight = 0.5},
    },

    ['npc_dota_hero_viper'] = {
        ['viper_poison_attack'] = {weight = 0.8},
        ['viper_nethertoxin'] = {weight = 0.5},
        ['viper_corrosive_skin'] = {weight = 1},
        ['viper_nose_dive' ] = {weight = 0.6},
        ['viper_viper_strike'] = {weight = 0.1},
    },

    ['npc_dota_hero_visage'] = {
        ['visage_grave_chill'] = {weight = 0.2},
        ['visage_soul_assumption'] = {weight = 1},
        ['visage_gravekeepers_cloak'] = {weight = 1},
        ['visage_silent_as_the_grave'] = {weight = 0.7},
        ['visage_summon_familiars'] = {weight = 1},
    },

    ['npc_dota_hero_void_spirit'] = {
        ['void_spirit_aether_remnant'] = {weight = 0.9},
        ['void_spirit_dissimilate'] = {weight = 0.5},
        ['void_spirit_resonant_pulse'] = {weight = 0.2},
        ['void_spirit_astral_step'] = {weight = 0.2},
    },

    ['npc_dota_hero_warlock'] = {
        ['warlock_fatal_bonds'] = {weight = 0.1},
        ['warlock_shadow_word'] = {weight = 0.5},
        ['warlock_upheaval'] = {weight = 0.8},
        ['warlock_rain_of_chaos'] = {weight = 0},
    },

    ['npc_dota_hero_weaver'] = {
        ['weaver_the_swarm'] = {weight = 0.4},
        ['weaver_shukuchi'] = {weight = 0.2},
        ['weaver_geminate_attack'] = {weight = 1},
        ['weaver_time_lapse'] = {weight = 0.6},
    },

    ['npc_dota_hero_windrunner'] = {
        ['windrunner_shackleshot'] = {weight = 0.1},
        ['windrunner_powershot'] = {weight = 0.4},
        ['windrunner_windrun'] = {weight = 0.6},
        ['windrunner_gale_force'] = {weight = 0.3},
        ['windrunner_focusfire'] = {weight = 0.9},
    },

    ['npc_dota_hero_winter_wyvern'] = {
        ['winter_wyvern_arctic_burn'] = {weight = 0.9},
        ['winter_wyvern_splinter_blast'] = {weight = 0.6},
        ['winter_wyvern_cold_embrace'] = {weight = 0.2},
        ['winter_wyvern_winters_curse'] = {weight = 0.5},
    },

    ['npc_dota_hero_wisp'] = {
        ['wisp_tether'] = {weight = 0.9},
        ['wisp_tether_break'] = {weight = 1},
        ['wisp_spirits'] = {weight = 1},
        ['wisp_spirits_in'] = {weight = 1},
        ['wisp_spirits_out'] = {weight = 1},
        ['wisp_overcharge'] = {weight = 0.4},
        ['wisp_relocate'] = {weight = 0.9},
    },

    ['npc_dota_hero_witch_doctor'] = {
        ['witch_doctor_paralyzing_cask'] = {weight = 0.1},
        ['witch_doctor_voodoo_restoration'] = {weight = 0.5},
        ['witch_doctor_maledict'] = {weight = 0.1},
        ['witch_doctor_voodoo_switcheroo'] = {weight = 0.1},
        ['witch_doctor_death_ward'] = {weight = 0.1},
    },

    ['npc_dota_hero_zuus'] = {
        ['zuus_arc_lightning'] = {weight = 0.3},
        ['zuus_lightning_bolt'] = {weight = 0.3},
        ['zuus_heavenly_jump'] = {weight = 0.2},
        ['zuus_cloud'] = {weight = 0.6},
        ['zuus_lightning_hands'] = {weight = 1},
        ['zuus_thundergods_wrath'] = {weight = 0.4},
    },

    -- --[[4]] ['rubick_empty1'] = {weight = 1},
    -- --[[5]] ['rubick_empty2'] = {weight = 1},
}

function X.GetSpellReplaceWeight(ability)
    for hero, _ in pairs(X['spells'])
    do
        if X['spells'][hero] and X['spells'][hero][ability]
        then
            return X['spells'][hero][ability].weight
        end
    end

    return 1
end

function X.GetSpellHeroName(ability)
    for hero, _ in pairs(X['spells'])
    do
        if X['spells'][hero] and X['spells'][hero][ability]
        then
            return hero
        end
    end

    return nil
end

return X