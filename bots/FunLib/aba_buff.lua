----------------------------------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------


local Buff = {}


Buff["creep_is_immune"] = {

"modifier_fountain_glyph",
"modifier_crystal_maiden_frostbite",

}

Buff["enemy_is_immune"] = {

"modifier_necrolyte_reapers_scythe", 		 --Nec大
"modifier_winter_wyvern_winters_curse", 		 --冰龙大
"modifier_winter_wyvern_winters_curse_aura", --冰龙大
"modifier_troll_warlord_battle_trance", --巨魔大
--"modifier_modifier_dazzle_shallow_grave",
--"modifier_oracle_false_promise_timer",
--"modifier_item_blade_mail_reflect",
--"modifier_oracle_fates_edict"

}

Buff["enemy_is_undead"] = {

"modifier_dazzle_shallow_grave",
"modifier_oracle_false_promise_timer",
"modifier_abaddon_borrowed_time",

}

Buff["enemy_not_illusion"] = {

"modifier_item_satanic_unholy",
"modifier_item_mask_of_madness_berserk",
"modifier_black_king_bar_immune",
"modifier_rune_doubledamage",
"modifier_rune_regen",
"modifier_rune_haste",
"modifier_rune_arcane",
"modifier_item_phase_boots_active",

}


Buff["enemy_is_illusion"] = {

"modifier_illusion",
"modifier_phantom_lancer_doppelwalk_illusion",
"modifier_phantom_lancer_juxtapose_illusion",
"modifier_darkseer_wallofreplica_illusion",
"modifier_terrorblade_conjureimage",

}

Buff["hero_cannot_ability"] = {

"modifier_doom_bringer_doom",
"modifier_item_forcestaff_active",

}

Buff["hero_is_taunted"] = {

"modifier_axe_berserkers_call",
"modifier_legion_commander_duel",
"modifier_winter_wyvern_winters_curse",
"modifier_winter_wyvern_winters_curse_aura",

}

Buff["hero_has_spell_shield"] = {

"modifier_antimage_spell_shield",
"modifier_item_sphere_target",
"modifier_item_lotus_orb_active",
"modifier_item_aeon_disk_buff",
"modifier_dazzle_shallow_grave",
"modifier_abaddon_borrowed_time",


}

--可被打断的回复效果
Buff["hero_is_healing"] = {

"modifier_flask_healing",
"modifier_clarity_potion",
"modifier_item_urn_heal",
"modifier_item_spirit_vessel_heal",
"modifier_bottle_regeneration",
--"modifier_filler_heal",

}


Buff["hero_not_invisible"] = {

"modifier_item_dustofappearance",
"modifier_sniper_assassinate",
"modifier_bounty_hunter_track",
--大鱼大
--血魔嗜血
--祸乱魔爪
--渔网诱捕
--阿托斯
--小Y锁
--米波网
--娜迦网
--冰女冰
--火猫索
--军团决斗
--骨法吸
--屠夫大
--大树大
--孽主深渊

}


return Buff
-- dota2jmz@163.com QQ:2462331592..