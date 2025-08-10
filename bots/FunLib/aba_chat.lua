-----------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
-----------------------------------------------------------------------------
local Chat = {}
local sRawLanguage = 'sRawName'
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )
local Customize = require(GetScriptDirectory()..'/FunLib/custom_loader')

Chat['tItemNameList'] = {
	{sRawName='item_cyclone', sShortName='itemNull', sCnName='EUL的神圣法杖', sEnName="Eul's Scepter of Divinity"},
	{sRawName='item_ultimate_scepter', sShortName='itemNull', sCnName='阿哈利姆神杖', sEnName="Aghanim's Scepter"},
	{sRawName='item_ultimate_scepter_2', sShortName='itemNull', sCnName='阿哈利姆神杖2', sEnName="Aghanim's Scepter 2"},
	{sRawName='item_rod_of_atos', sShortName='itemNull', sCnName='阿托斯之棍', sEnName='Rod of Atos'},
	{sRawName='item_shadow_amulet', sShortName='itemNull', sCnName='暗影护符', sEnName='Shadow Amulet'},
	{sRawName='item_desolator', sShortName='itemNull', sCnName='黯灭', sEnName='Desolator'},
	{sRawName='item_arcane_boots', sShortName='itemNull', sCnName='奥术鞋', sEnName='Arcane Boots'},
	{sRawName='item_silver_edge', sShortName='itemNull', sCnName='白银之锋', sEnName='Silver Edge'},
	{sRawName='item_platemail', sShortName='itemNull', sCnName='板甲', sEnName='Platemail'},
	{sRawName='item_javelin', sShortName='itemNull', sCnName='标枪', sEnName='Javelin'},
	{sRawName='item_crimson_guard', sShortName='itemNull', sCnName='赤红甲', sEnName='Crimson Guard'},
	{sRawName='item_orb_of_frost', sShortName='itemNull', sCnName='淬毒之珠', sEnName='Orb of Venom'},
	{sRawName='item_dagon', sShortName='itemNull', sCnName='达贡之神力', sEnName='Dagon'},
	{sRawName='item_dagon_2', sShortName='itemNull', sCnName='达贡之神力2', sEnName='Dagon Level 2'},
	{sRawName='item_dagon_3', sShortName='itemNull', sCnName='达贡之神力3', sEnName='Dagon Level 3'},
	{sRawName='item_dagon_4', sShortName='itemNull', sCnName='达贡之神力4', sEnName='Dagon Level 4'},
	{sRawName='item_dagon_5', sShortName='itemNull', sCnName='达贡之神力5', sEnName='Dagon Level 5'},
	{sRawName='item_claymore', sShortName='itemNull', sCnName='大剑', sEnName='Claymore'},
	{sRawName='item_greater_crit', sShortName='itemNull', sCnName='代达罗斯之殇', sEnName='Daedalus'},
	{sRawName='item_power_treads', sShortName='itemNull', sCnName='动力鞋', sEnName='Power Treads'},
	{sRawName='item_courier', sShortName='itemNull', sCnName='动物信使', sEnName='Animal Courier'},
	{sRawName='item_pipe', sShortName='itemNull', sCnName='洞察烟斗', sEnName='Pipe of Insight'},
	{sRawName='item_quarterstaff', sShortName='itemNull', sCnName='短棍', sEnName='Quarterstaff'},
	{sRawName='item_demon_edge', sShortName='itemNull', sCnName='恶魔刀锋', sEnName='Demon Edge'},
	{sRawName='item_robe', sShortName='itemNull', sCnName='法师长袍', sEnName='Robe of the Magi'},
	{sRawName='item_veil_of_discord', sShortName='itemNull', sCnName='纷争面纱', sEnName='Veil of Discord'},
	{sRawName='item_mask_of_madness', sShortName='itemNull', sCnName='疯狂面具', sEnName='Mask of Madness'},
	{sRawName='item_nullifier', sShortName='itemNull', sCnName='否决坠饰', sEnName='Nullifier'},
	{sRawName='item_vladmir', sShortName='itemNull', sCnName='弗拉迪米尔的祭品', sEnName="Vladmir's Offering"},
	{sRawName='item_ward_sentry', sShortName='itemNull', sCnName='岗哨守卫', sEnName='Sentry Ward'},
	{sRawName='item_blades_of_attack', sShortName='itemNull', sCnName='攻击之爪', sEnName='Blades of Attack'},
	{sRawName='item_smoke_of_deceit', sShortName='itemNull', sCnName='诡计之雾', sEnName='Smoke of Deceit'},
	{sRawName='item_black_king_bar', sShortName='itemNull', sCnName='黑皇杖', sEnName='Black King Bar'},
	{sRawName='item_butterfly', sShortName='itemNull', sCnName='蝴蝶', sEnName='Butterfly'},
	{sRawName='item_bracer', sShortName='itemNull', sCnName='护腕', sEnName='Bracer'},
	{sRawName='item_blade_of_alacrity', sShortName='itemNull', sCnName='欢欣之刃', sEnName='Blade of Alacrity'},
	{sRawName='item_manta', sShortName='itemNull', sCnName='幻影斧', sEnName='Manta Style'},
	{sRawName='item_headdress', sShortName='itemNull', sCnName='恢复头巾', sEnName='Headdress'},
	{sRawName='item_radiance', sShortName='itemNull', sCnName='辉耀', sEnName='Radiance'},
	{sRawName='item_tpscroll', sShortName='itemNull', sCnName='回城卷轴', sEnName='Town Portal Scroll'},
	{sRawName='item_ring_of_health', sShortName='itemNull', sCnName='回复戒指', sEnName='Ring of Health'},
	{sRawName='item_echo_sabre', sShortName='itemNull', sCnName='回音战刃', sEnName='Echo Sabre'},
	{sRawName='item_kaya', sShortName='itemNull', sCnName='慧光', sEnName='Kaya'},
	{sRawName='item_yasha_and_kaya', sShortName='itemNull', sCnName='慧夜对剑', sEnName='Yasha and Kaya'},
	{sRawName='item_vitality_booster', sShortName='itemNull', sCnName='活力之球', sEnName='Vitality Booster'},
	{sRawName='item_ultimate_orb', sShortName='itemNull', sCnName='极限法球', sEnName='Ultimate Orb'},
	{sRawName='item_gloves', sShortName='itemNull', sCnName='加速手套', sEnName='Gloves of Haste'},
	{sRawName='item_pers', sShortName='itemNull', sCnName='坚韧球', sEnName='Perseverance'},
	{sRawName='item_monkey_king_bar', sShortName='itemNull', sCnName='金箍棒', sEnName='Monkey King Bar'},
	{sRawName='item_boots_of_elves', sShortName='itemNull', sCnName='精灵布带', sEnName="Band of Elvenskin"},
	{sRawName='item_point_booster', sShortName='itemNull', sCnName='精气之球', sEnName='Point Booster'},
	{sRawName='item_clarity', sShortName='itemNull', sCnName='净化药水', sEnName='Clarity'},
	{sRawName='item_diffusal_blade', sShortName='itemNull', sCnName='净魂之刃', sEnName='Diffusal Blade'},
	{sRawName='item_tranquil_boots', sShortName='itemNull', sCnName='静谧之鞋', sEnName='Tranquil Boots'},
	{sRawName='item_cloak', sShortName='itemNull', sCnName='抗魔斗篷', sEnName='Cloak'},
	{sRawName='item_null_talisman', sShortName='itemNull', sCnName='空灵挂件', sEnName='Null Talisman'},
	{sRawName='item_oblivion_staff', sShortName='itemNull', sCnName='空明杖', sEnName='Oblivion Staff'},
	{sRawName='item_fluffy_hat', sShortName='itemNull', sCnName='毛毛帽', sEnName='Fluffy Hat'},
	{sRawName='item_heart', sShortName='itemNull', sCnName='恐鳌之心', sEnName='Heart of Tarrasque'},
	{sRawName='item_bfury', sShortName='itemNull', sCnName='狂战斧', sEnName='Battle Fury'},
	{sRawName='item_broadsword', sShortName='itemNull', sCnName='阔剑', sEnName='Broadsword'},
	{sRawName='item_mjollnir', sShortName='itemNull', sCnName='雷神之锤', sEnName='Mjollnir'},
	{sRawName='item_gauntlets', sShortName='itemNull', sCnName='力量手套', sEnName='Gauntlets of Strength'},
	{sRawName='item_belt_of_strength', sShortName='itemNull', sCnName='力量腰带', sEnName='Belt of Strength'},
	{sRawName='item_sphere', sShortName='itemNull', sCnName='林肯法球', sEnName="Linken's Sphere"},
	{sRawName='item_soul_ring', sShortName='itemNull', sCnName='灵魂之戒', sEnName='Soul Ring'},
	{sRawName='item_octarine_core', sShortName='itemNull', sCnName='玲珑心', sEnName='Octarine Core'},
	{sRawName='item_reaver', sShortName='itemNull', sCnName='掠夺者之斧', sEnName='Reaver'},
	{sRawName='item_hand_of_midas', sShortName='itemNull', sCnName='迈达斯之手', sEnName='Hand of Midas'},
	{sRawName='item_mekansm', sShortName='itemNull', sCnName='梅肯斯姆', sEnName="Mekansm"},
	{sRawName='item_mithril_hammer', sShortName='itemNull', sCnName='秘银锤', sEnName='Mithril Hammer'},
	{sRawName='item_slippers', sShortName='itemNull', sCnName='敏捷便鞋', sEnName='Slippers of Agility'},
	{sRawName='item_magic_stick', sShortName='itemNull', sCnName='魔棒', sEnName='Magic Stick'},
	{sRawName='item_enchanted_mango', sShortName='itemNull', sCnName='魔法芒果', sEnName='Enchanted Mango'},
	{sRawName='item_staff_of_wizardry', sShortName='itemNull', sCnName='魔力法杖', sEnName='Staff of Wizardry'},
	{sRawName='item_dragon_lance', sShortName='itemNull', sCnName='魔龙枪', sEnName='Dragon Lance'},
	{sRawName='item_bottle', sShortName='itemNull', sCnName='魔瓶', sEnName='Bottle'},
	{sRawName='item_magic_wand', sShortName='itemNull', sCnName='魔杖', sEnName='Magic Wand'},
	{sRawName='item_armlet', sShortName='itemNull', sCnName='莫尔迪基安的臂章', sEnName='Armlet of Mordiggian'},
	{sRawName='item_energy_booster', sShortName='itemNull', sCnName='能量之球', sEnName='Energy Booster'},
	{sRawName='item_assault', sShortName='itemNull', sCnName='强袭胸甲', sEnName='Assault Cuirass'},
	{sRawName='item_lotus_orb', sShortName='itemNull', sCnName='清莲宝珠', sEnName='Lotus Orb'},
	{sRawName='item_blade_mail', sShortName='itemNull', sCnName='刃甲', sEnName='Blade Mail'},
	{sRawName='item_ancient_janggo', sShortName='itemNull', sCnName='韧鼓', sEnName='Drum of Endurance'},
	{sRawName='item_satanic', sShortName='itemNull', sCnName='撒旦之邪力', sEnName='Satanic'},
	{sRawName='item_sange', sShortName='itemNull', sCnName='散华', sEnName='Sange'},
	{sRawName='item_kaya_and_sange', sShortName='itemNull', sCnName='散慧对剑', sEnName='Kaya and Sange'},
	{sRawName='item_sange_and_yasha', sShortName='itemNull', sCnName='散夜对剑', sEnName='Sange and Yasha'},
	{sRawName='item_talisman_of_evasion', sShortName='itemNull', sCnName='闪避护符', sEnName='Talisman of Evasion'},
	{sRawName='item_blink', sShortName='itemNull', sCnName='闪烁匕首', sEnName='Blink Dagger'},
	{sRawName='item_abyssal_blade', sShortName='itemNull', sCnName='深渊之刃', sEnName='Abyssal Blade'},
	{sRawName='item_mystic_staff', sShortName='itemNull', sCnName='神秘法杖', sEnName='Mystic Staff'},
	{sRawName='item_rapier', sShortName='itemNull', sCnName='圣剑', sEnName='Divine Rapier'},
	{sRawName='item_holy_locket', sShortName='itemNull', sCnName='圣洁吊坠', sEnName='Holy Locket'},
	{sRawName='item_relic', sShortName='itemNull', sCnName='圣者遗物', sEnName='Sacred Relic'},
	{sRawName='item_ogre_axe', sShortName='itemNull', sCnName='食人魔之斧', sEnName='Ogre Axe'},
	{sRawName='item_ring_of_protection', sShortName='itemNull', sCnName='守护指环', sEnName='Ring of Protection'},
	{sRawName='item_tango', sShortName='itemNull', sCnName='树之祭祀', sEnName='Tango'},
	{sRawName='item_refresher', sShortName='itemNull', sCnName='刷新球', sEnName='Refresher Orb'},
	{sRawName='item_lesser_crit', sShortName='itemNull', sCnName='水晶剑', sEnName='Crystalys'},
	{sRawName='item_skadi', sShortName='itemNull', sCnName='斯嘉蒂之眼', sEnName="Eye of Skadi"},
	{sRawName='item_necronomicon', sShortName='itemNull', sCnName='死灵书', sEnName='Necronomicon'},
	{sRawName='item_necronomicon_2', sShortName='itemNull', sCnName='死灵书2', sEnName='Necronomicon Level 2'},
	{sRawName='item_necronomicon_3', sShortName='itemNull', sCnName='死灵书3', sEnName='Necronomicon Level 3'},
	{sRawName='item_boots', sShortName='itemNull', sCnName='速度之靴', sEnName='Boots of Speed'},
	{sRawName='item_basher', sShortName='itemNull', sCnName='碎颅锤', sEnName='Skull Basher'},
	{sRawName='item_chainmail', sShortName='itemNull', sCnName='锁子甲', sEnName='Chainmail'},
	{sRawName='item_heavens_halberd', sShortName='itemNull', sCnName='天堂之戟', sEnName="Heaven's Halberd"},
	{sRawName='item_hood_of_defiance', sShortName='itemNull', sCnName='挑战头巾', sEnName='Hood of Defiance'},
	{sRawName='item_branches', sShortName='itemNull', sCnName='铁树枝干', sEnName='Iron Branch'},
	{sRawName='item_helm_of_iron_will', sShortName='itemNull', sCnName='铁意头盔', sEnName='Helm of Iron Will'},
	{sRawName='item_crown', sShortName='itemNull', sCnName='王冠', sEnName='Crown'},
	{sRawName='item_ring_of_basilius', sShortName='itemNull', sCnName='王者之戒', sEnName='Ring of Basilius'},
	{sRawName='item_glimmer_cape', sShortName='itemNull', sCnName='微光披风', sEnName='Glimmer Cape'},
	{sRawName='item_guardian_greaves', sShortName='itemNull', sCnName='卫士胫甲', sEnName='Guardian Greaves'},
	{sRawName='item_lifesteal', sShortName='itemNull', sCnName='吸血面具', sEnName='Morbid Mask'},
	{sRawName='item_shivas_guard', sShortName='itemNull', sCnName='希瓦的守护', sEnName="Shiva's Guard"},
	{sRawName='item_faerie_fire', sShortName='itemNull', sCnName='仙灵之火', sEnName='Faerie Fire'},
	{sRawName='item_vanguard', sShortName='itemNull', sCnName='先锋盾', sEnName='Vanguard'},
	{sRawName='item_sobi_mask', sShortName='itemNull', sCnName='贤者面罩', sEnName='Sage\'s Mask'},
	{sRawName='item_dust', sShortName='itemNull', sCnName='显影之尘', sEnName='Dust of Appearance'},
	{sRawName='item_phase_boots', sShortName='itemNull', sCnName='相位鞋', sEnName='Phase Boots'},
	{sRawName='item_sheepstick', sShortName='itemNull', sCnName='邪恶镰刀', sEnName='Scythe of Vyse'},
	{sRawName='item_ethereal_blade', sShortName='itemNull', sCnName='虚灵之刃', sEnName='Ethereal Blade'},
	{sRawName='item_void_stone', sShortName='itemNull', sCnName='虚无宝石', sEnName='Void Stone'},
	{sRawName='item_buckler', sShortName='itemNull', sCnName='玄冥盾牌', sEnName='Buckler'},
	{sRawName='item_maelstrom', sShortName='itemNull', sCnName='漩涡', sEnName='Maelstrom'},
	{sRawName='item_bloodthorn', sShortName='itemNull', sCnName='血棘', sEnName='Bloodthorn'},
	{sRawName='item_bloodstone', sShortName='itemNull', sCnName='血精石', sEnName='Bloodstone'},
	{sRawName='item_quelling_blade', sShortName='itemNull', sCnName='压制之刃', sEnName='Quelling Blade'},
	{sRawName='item_solar_crest', sShortName='itemNull', sCnName='炎阳纹章', sEnName='Solar Crest'},
	{sRawName='item_yasha', sShortName='itemNull', sCnName='夜叉', sEnName='Yasha'},
	{sRawName='item_aether_lens', sShortName='itemNull', sCnName='以太透镜', sEnName='Aether Lens'},
	{sRawName='item_moon_shard', sShortName='itemNull', sCnName='银月之晶', sEnName='Moon Shard'},
	{sRawName='item_eagle', sShortName='itemNull', sCnName='鹰歌弓', sEnName='Eaglesong'},
	{sRawName='item_invis_sword', sShortName='itemNull', sCnName='影刃', sEnName='Shadow Blade'},
	{sRawName='item_urn_of_shadows', sShortName='itemNull', sCnName='影之灵龛', sEnName='Urn of Shadows'},
	{sRawName='item_aeon_disk', sShortName='itemNull', sCnName='永恒之盘', sEnName='Aeon Disk'},
	{sRawName='item_medallion_of_courage', sShortName='itemNull', sCnName='勇气勋章', sEnName='Medallion of Courage'},
	{sRawName='item_ghost', sShortName='itemNull', sCnName='幽魂权杖', sEnName='Ghost Scepter'},
	{sRawName='item_force_staff', sShortName='itemNull', sCnName='原力法杖', sEnName='Force Staff'},
	{sRawName='item_aegis', sShortName='itemNull', sCnName='不朽之守护', sEnName='Aegis of the Immortal'},
	{sRawName='item_circlet', sShortName='itemNull', sCnName='圆环', sEnName='Circlet'},
	{sRawName='item_travel_boots', sShortName='itemNull', sCnName='远行鞋', sEnName='Boots of Travel'},
	{sRawName='item_travel_boots_2', sShortName='itemNull', sCnName='远行鞋2', sEnName='Boots of Travel Level 2'},
	{sRawName='item_wraith_band', sShortName='itemNull', sCnName='怨灵系带', sEnName='Wraith Band'},
	{sRawName='item_meteor_hammer', sShortName='itemNull', sCnName='陨星锤', sEnName='Meteor Hammer'},
	{sRawName='item_ward_observer', sShortName='itemNull', sCnName='侦查守卫', sEnName='Observer Ward'},
	{sRawName='item_gem', sShortName='itemNull', sCnName='真视宝石', sEnName='Gem of True Sight'},
	{sRawName='item_hyperstone', sShortName='itemNull', sCnName='振奋宝石', sEnName='Hyperstone'},
	{sRawName='item_soul_booster', sShortName='itemNull', sCnName='镇魂石', sEnName='Soul Booster'},
	{sRawName='item_helm_of_the_dominator', sShortName='itemNull', sCnName='支配头盔', sEnName='Helm of the Dominator'},
	{sRawName='item_flask', sShortName='itemNull', sCnName='治疗药膏', sEnName='Healing Salve'},
	{sRawName='item_mantle', sShortName='itemNull', sCnName='智力斗篷', sEnName='Mantle of Intelligence'},
	{sRawName='item_orchid', sShortName='itemNull', sCnName='紫怨', sEnName='Orchid Malevolence'},
	{sRawName='item_spirit_vessel', sShortName='itemNull', sCnName='魂之灵瓮', sEnName='Spirit Vessel'},
	{sRawName='item_blight_stone', sShortName='itemNull', sCnName='枯萎之石', sEnName='Blight Stone'},
	{sRawName='item_hurricane_pike', sShortName='itemNull', sCnName='飓风长戟', sEnName='Hurricane Pike'},
	{sRawName='item_tome_of_knowledge', sShortName='itemNull', sCnName='知识之书', sEnName='Tome of Knowledge'},
	{sRawName='item_infused_raindrop', sShortName='itemNull', sCnName='凝魂之露', sEnName='Infused Raindrops'},
	{sRawName='item_wind_lace', sShortName='itemNull', sCnName='风灵之纹', sEnName='Wind Lace'},
	{sRawName='item_refresher_shard', sShortName='itemNull', sCnName='刷新球碎片', sEnName='Refresher Shard'},
	{sRawName='item_cheese', sShortName='itemNull', sCnName='奶酪', sEnName='Cheese'},
	{sRawName='item_blitz_knuckles', sShortName='itemNull', sCnName='闪电指套', sEnName='Blitz Knuckles'},
	{sRawName='item_voodoo_mask', sShortName='itemNull', sCnName='巫毒面具', sEnName='Voodoo Mask'},
	{sRawName='item_aghanims_shard', sShortName='itemNull', sCnName='阿哈利姆魔晶', sEnName="Aghanim's Shard"},
	{sRawName='item_helm_of_the_overlord', sShortName='itemNull', sCnName='统御头盔', sEnName='Helm of the Overlord'},
	{sRawName='item_broken_satanic', sShortName='itemNull', sCnName='拆疯脸转撒旦', sEnName='Broken Satanic'},
	{sRawName='item_double_tango', sShortName='itemNull', sCnName='两个树之祭祀', sEnName='Two Tangos'},
	{sRawName='item_double_clarity', sShortName='itemNull', sCnName='两个净化药水', sEnName='Two Clarities'},
	{sRawName='item_double_flask', sShortName='itemNull', sCnName='两个治疗药膏', sEnName='Two Healing Salves'},
	{sRawName='item_double_enchanted_mango', sShortName='itemNull', sCnName='两个魔法芒果', sEnName='Two Enchanted Mangos'},
	{sRawName='item_double_branches', sShortName='itemNull', sCnName='两个铁树枝干', sEnName='Two Iron Branches'},
	{sRawName='item_double_circlet', sShortName='itemNull', sCnName='两个圆环', sEnName='Two Circlets'},
	{sRawName='item_double_slippers', sShortName='itemNull', sCnName='两个敏捷便鞋', sEnName='Two Slippers of Agility'},
	{sRawName='item_double_mantle', sShortName='itemNull', sCnName='两个智力斗篷', sEnName='Two Mantles of Intelligence'},
	{sRawName='item_double_gauntlets', sShortName='itemNull', sCnName='两个力量手套', sEnName='Two Gauntlets of Strength'},
	{sRawName='item_double_wraith_band', sShortName='itemNull', sCnName='两个怨灵系带', sEnName='Two Wraith Bands'},
	{sRawName='item_double_null_talisman', sShortName='itemNull', sCnName='两个空灵挂件', sEnName='Two Null Talismans'},
	{sRawName='item_double_bracer', sShortName='itemNull', sCnName='两个护腕', sEnName='Two Bracers'},
	{sRawName='item_double_crown', sShortName='itemNull', sCnName='两个王冠', sEnName='Two Crowns'},
	{sRawName='item_keen_optic', sShortName='itemNull', sCnName='基恩镜片', sEnName='Keen Optic'},
	{sRawName='item_poor_mans_shield', sShortName='itemNull', sCnName='穷鬼盾', sEnName="Poor Man's Shield"},
	{sRawName='item_iron_talon', sShortName='itemNull', sCnName='寒铁钢爪', sEnName='Iron Talon'},
	{sRawName='item_ironwood_tree', sShortName='itemNull', sCnName='铁树之木', sEnName='Ironwood Tree'},
	{sRawName='item_royal_jelly', sShortName='itemNull', sCnName='蜂王浆', sEnName='Royal Jelly'},
	{sRawName='item_mango_tree', sShortName='itemNull', sCnName='芒果树', sEnName='Mango Tree'},
	{sRawName='item_ocean_heart', sShortName='itemNull', sCnName='海洋之心', sEnName='Ocean Heart'},
	{sRawName='item_broom_handle', sShortName='itemNull', sCnName='扫帚柄', sEnName='Broom Handle'},
	{sRawName='item_trusty_shovel', sShortName='itemNull', sCnName='可靠铁铲', sEnName='Trusty Shovel'},
	{sRawName='item_faded_broach', sShortName='itemNull', sCnName='暗淡胸针', sEnName='Faded Broach'},
	{sRawName='item_arcane_ring', sShortName='itemNull', sCnName='奥术指环', sEnName='Arcane Ring'},
	{sRawName='item_grove_bow', sShortName='itemNull', sCnName='林野长弓', sEnName='Grove Bow'},
	{sRawName='item_vampire_fangs', sShortName='itemNull', sCnName='吸血鬼獠牙', sEnName='Vampire Fangs'},
	{sRawName='item_ring_of_aquila', sShortName='itemNull', sCnName='天鹰之戒', sEnName='Ring of Aquila'},
	{sRawName='item_pupils_gift', sShortName='itemNull', sCnName='学徒之礼', sEnName="Pupil's Gift"},
	{sRawName='item_imp_claw', sShortName='itemNull', sCnName='魔童之爪', sEnName="Imp Claw"},
	{sRawName='item_philosophers_stone', sShortName='itemNull', sCnName='贤者石', sEnName="Philosopher's Stone"},
	{sRawName='item_nether_shawl', sShortName='itemNull', sCnName='幽冥披巾', sEnName='Nether Shawl'},
	{sRawName='item_dragon_scale', sShortName='itemNull', sCnName='炎龙之鳞', sEnName='Dragon Scale'},
	{sRawName='item_essence_ring', sShortName='itemNull', sCnName='精华指环', sEnName='Essence Ring'},
	{sRawName='item_vambrace', sShortName='itemNull', sCnName='臂甲', sEnName='Vambrace'},
	{sRawName='item_clumsy_net', sShortName='itemNull', sCnName='笨拙渔网', sEnName='Clumsy Net'},
	{sRawName='item_repair_kit', sShortName='itemNull', sCnName='维修器具', sEnName='Repair Kit'},
	{sRawName='item_craggy_coat', sShortName='itemNull', sCnName='崎岖外衣', sEnName='Craggy Coat'},
	{sRawName='item_greater_faerie_fire', sShortName='itemNull', sCnName='高级仙灵之火', sEnName='Greater Faerie Fire'},
	{sRawName='item_quickening_charm', sShortName='itemNull', sCnName='加速护符', sEnName='Quickening Charm'},
	{sRawName='item_mind_breaker', sShortName='itemNull', sCnName='智灭', sEnName='Mind Breaker'},
	{sRawName='item_spider_legs', sShortName='itemNull', sCnName='网虫腿', sEnName='Spider Legs'},
	{sRawName='item_enchanted_quiver', sShortName='itemNull', sCnName='魔力箭袋', sEnName='Enchanted Quiver'},
	{sRawName='item_paladin_sword', sShortName='itemNull', sCnName='骑士剑', sEnName='Paladin Sword'},
	{sRawName='item_orb_of_destruction', sShortName='itemNull', sCnName='毁灭灵球', sEnName='Orb of Destruction'},
	{sRawName='item_titan_sliver', sShortName='itemNull', sCnName='巨神残铁', sEnName='Titan Sliver'},
	{sRawName='item_witless_shako', sShortName='itemNull', sCnName='无知小帽', sEnName='Witless Shako'},
	{sRawName='item_timeless_relic', sShortName='itemNull', sCnName='永恒遗物', sEnName='Timeless Relic'},
	{sRawName='item_spell_prism', sShortName='itemNull', sCnName='法术棱镜', sEnName='Spell Prism'},
	{sRawName='item_princes_knife', sShortName='itemNull', sCnName='亲王短刀', sEnName="Prince's Knife"},
	{sRawName='item_flicker', sShortName='itemNull', sCnName='闪灵', sEnName='Flicker'},
	{sRawName='item_spy_gadget', sShortName='itemNull', sCnName='望远镜', sEnName='Telescope'},
	{sRawName='item_ninja_gear', sShortName='itemNull', sCnName='忍者用具', sEnName='Ninja Gear'},
	{sRawName='item_illusionsts_cape', sShortName='itemNull', sCnName='幻术师披风', sEnName="Illusionist's Cape"},
	{sRawName='item_havoc_hammer', sShortName='itemNull', sCnName='浩劫巨锤', sEnName='Havoc Hammer'},
	{sRawName='item_panic_button', sShortName='itemNull', sCnName='魔力明灯', sEnName='Magic Lamp'},
	{sRawName='item_the_leveller', sShortName='itemNull', sCnName='平世剑', sEnName='The Leveller'},
	{sRawName='item_minotaur_horn', sShortName='itemNull', sCnName='恶牛角', sEnName='Minotaur Horn'},
	{sRawName='item_force_boots', sShortName='itemNull', sCnName='原力靴', sEnName='Force Boots'},
	{sRawName='item_desolator_2', sShortName='itemNull', sCnName='寂灭', sEnName='Desolator 2'},
	{sRawName='item_seer_stone', sShortName='itemNull', sCnName='先哲之石', sEnName='Seer Stone'},
	{sRawName='item_apex', sShortName='itemNull', sCnName='极', sEnName='Apex'},
	{sRawName='item_ballista', sShortName='itemNull', sCnName='弩炮', sEnName='Ballista'},
	{sRawName='item_woodland_striders', sShortName='itemNull', sCnName='林地神行靴', sEnName='Woodland Striders'},
	{sRawName='item_trident', sShortName='itemNull', sCnName='三元重戟', sEnName='Trident'},
	{sRawName='item_demonicon', sShortName='itemNull', sCnName='冥灵书', sEnName='Book of the Dead'},
	{sRawName='item_fallen_sky', sShortName='itemNull', sCnName='堕天斧', sEnName='Fallen Sky'},
	{sRawName='item_pirate_hat', sShortName='itemNull', sCnName='海盗帽', sEnName='Pirate Hat'},
	{sRawName='item_ex_machina', sShortName='itemNull', sCnName='机械之心', sEnName='Ex Machina'},
	{sRawName='item_falcon_blade', sShortName='itemNull', sCnName='猎鹰战刃', sEnName='Falcon Blade'},
	{sRawName='item_orb_of_corrosion', sShortName='itemNull', sCnName='腐蚀之球', sEnName='Orb of Corrosion'},
	{sRawName='item_witch_blade', sShortName='itemNull', sCnName='巫师之刃', sEnName='Witch Blade'},
	{sRawName='item_gungir', sShortName='itemNull', sCnName='缚灵索', sEnName='Gleipnir'},
	{sRawName='item_mage_slayer', sShortName='itemNull', sCnName='法师克星', sEnName='Mage Slayer'},
	{sRawName='item_eternal_shroud', sShortName='itemNull', sCnName='永世法衣', sEnName='Eternal Shroud'},
	{sRawName='item_overwhelming_blink', sShortName='itemNull', sCnName='盛势闪光', sEnName='Overwhelming Blink'},
	{sRawName='item_swift_blink', sShortName='itemNull', sCnName='迅疾闪光', sEnName='Swift Blink'},
	{sRawName='item_arcane_blink', sShortName='itemNull', sCnName='秘奥闪光', sEnName='Arcane Blink'},
	{sRawName='item_mysterious_hat', sShortName='itemNull', sCnName='仙灵饰品', sEnName='Fairy Trinket'},
	{sRawName='item_chipped_vest', sShortName='itemNull', sCnName='碎裂背心', sEnName='Chipped Vest'},
	{sRawName='item_possessed_mask', sShortName='itemNull', sCnName='附魂面具', sEnName='Possessed Mask'},
	{sRawName='item_quicksilver_amulet', sShortName='itemNull', sCnName='银闪护符', sEnName='Quicksilver Amulet'},
	{sRawName='item_bullwhip', sShortName='itemNull', sCnName='凌厉长鞭', sEnName='Bullwhip'},
	{sRawName='item_elven_tunic', sShortName='itemNull', sCnName='精灵外衣', sEnName='Elven Tunic'},
	{sRawName='item_cloak_of_flames', sShortName='itemNull', sCnName='火焰斗篷', sEnName='Cloak of Flames'},
	{sRawName='item_ceremonial_robe', sShortName='itemNull', sCnName='祭礼长袍', sEnName='Ceremonial Robe'},
	{sRawName='item_psychic_headband', sShortName='itemNull', sCnName='通灵头带', sEnName='Psychic Headband'},
	{sRawName='item_penta_edged_sword', sShortName='itemNull', sCnName='五锋长剑', sEnName='Penta-Edged Sword'},
	{sRawName='item_stormcrafter', sShortName='itemNull', sCnName='风暴宝器', sEnName='Stormcrafter'},
	{sRawName='item_trickster_cloak', sShortName='itemNull', sCnName='欺诈师斗篷', sEnName='Trickster Cloak'},
	{sRawName='item_giants_ring', sShortName='itemNull', sCnName='巨人之戒', sEnName="Giant's Ring"},
	{sRawName='item_book_of_shadows', sShortName='itemNull', sCnName='暗影邪典', sEnName='Book of Shadows'},
	{sRawName='item_wind_waker', sShortName='itemNull', sCnName='风之杖', sEnName='Wind Waker'},
	{sRawName='item_unstable_wand', sShortName='itemNull', sCnName='豚杆', sEnName='Pig Pole'},
	{sRawName='item_pogo_stick', sShortName='itemNull', sCnName='杂技玩具', sEnName='Tumbler\'s Toy'},
	{sRawName='item_misericorde', sShortName='itemNull', sCnName='飞贼之刃', sEnName='Misericorde'},
	{sRawName='item_paintball', sShortName='itemNull', sCnName='仙灵榴弹', sEnName='Fairy\'s Trinket'},
	{sRawName='item_black_powder_bag', sShortName='itemNull', sCnName='炸雷服', sEnName='Blast Rig'},
	{sRawName='item_ascetic_cap', sShortName='itemNull', sCnName='简普短帽', sEnName='Ascetic\'s Cap'},
	{sRawName='item_heavy_blade', sShortName='itemNull', sCnName='行巫之祸', sEnName='Witchbane'},
	{sRawName='item_force_field', sShortName='itemNull', sCnName='秘术师铠甲', sEnName='Force Field'},
	{sRawName='item_revenants_brooch', sShortName='itemNull', sCnName='亡魂胸针', sEnName='Revenant\'s Brooch'},
	{sRawName='item_boots_of_bearing', sShortName='itemNull', sCnName='宽容之靴', sEnName='Boots of Bearing'},
	{sRawName='item_wraith_pact', sShortName='itemNull', sCnName='怨灵之契', sEnName='Wraith Pact'},
	{sRawName='item_new_1', sShortName='itemNull', sCnName='自定义物品1', sEnName='Custom Item 1'},
	{sRawName='item_new_2', sShortName='itemNull', sCnName='自定义物品2', sEnName='Custom Item 2'},
	{sRawName='item_new_3', sShortName='itemNull', sCnName='自定义物品3', sEnName='Custom Item 3'},
	{sRawName='item_new_4', sShortName='itemNull', sCnName='自定义物品4', sEnName='Custom Item 4'},
	{sRawName='item_new_5', sShortName='itemNull', sCnName='自定义物品5', sEnName='Custom Item 5'},
	{sRawName='item_new_6', sShortName='itemNull', sCnName='自定义物品6', sEnName='Custom Item 6'},
}

Chat['tHeroNameList'] = {
	['sRandomHero'] = {sNormName='随机', sShortName='random', sCnName='随机英雄', sEnName='Random Hero'},
	['npc_dota_hero_abaddon'] = {sNormName='死骑', sShortName='loa', sCnName='亚巴顿', sEnName='Abaddon'},
	['npc_dota_hero_alchemist'] = {sNormName='炼金', sShortName='ga', sCnName='炼金术士', sEnName='Alchemist'},
	['npc_dota_hero_axe'] = {sNormName='斧王', sShortName='axe', sCnName='斧王', sEnName='Axe'},
	['npc_dota_hero_beastmaster'] = {sNormName='兽王', sShortName='bm', sCnName='兽王', sEnName='Beastmaster'},
	['npc_dota_hero_brewmaster'] = {sNormName='熊猫', sShortName='panda', sCnName='酒仙', sEnName='Brewmaster'},
	['npc_dota_hero_bristleback'] = {sNormName='钢背', sShortName='bb', sCnName='钢背兽', sEnName='Bristleback'},
	['npc_dota_hero_centaur'] = {sNormName='人马', sShortName='cent', sCnName='半人马战行者', sEnName='Centaur Warrunner'},
	['npc_dota_hero_chaos_knight'] = {sNormName='混沌', sShortName='ck', sCnName='混沌骑士', sEnName='Chaos Knight'},
	['npc_dota_hero_rattletrap'] = {sNormName='发条', sShortName='cg', sCnName='发条技师', sEnName='Clockwerk'},
	['npc_dota_hero_doom_bringer'] = {sNormName='末日', sShortName='doom', sCnName='末日使者', sEnName='Doom'},
	['npc_dota_hero_dragon_knight'] = {sNormName='龙骑', sShortName='dk', sCnName='龙骑士', sEnName='Dragon Knight'},
	['npc_dota_hero_earth_spirit'] = {sNormName='土猫', sShortName='earthspirit', sCnName='大地之灵', sEnName='Earth Spirit'},
	['npc_dota_hero_earthshaker'] = {sNormName='小牛', sShortName='es', sCnName='撼地者', sEnName='Earthshaker'},
	['npc_dota_hero_elder_titan'] = {sNormName='大牛', sShortName='et', sCnName='上古巨神', sEnName='Elder Titan'},
	['npc_dota_hero_grimstroke'] = {sNormName='笔仙', sShortName='grimstroke', sCnName='天涯墨客', sEnName='Grimstroke'},
	['npc_dota_hero_huskar'] = {sNormName='神灵', sShortName='hus', sCnName='哈斯卡', sEnName='Huskar'},
	['npc_dota_hero_wisp'] = {sNormName='小精灵', sShortName='wisp', sCnName='艾欧', sEnName='Io'},
	['npc_dota_hero_kunkka'] = {sNormName='船长', sShortName='coco', sCnName='昆卡', sEnName='Kunkka'},
	['npc_dota_hero_legion_commander'] = {sNormName='军团', sShortName='legion', sCnName='军团指挥官', sEnName='Legion Commander'},
	['npc_dota_hero_life_stealer'] = {sNormName='小狗', sShortName='naix', sCnName='噬魂鬼', sEnName='Lifestealer'},
	['npc_dota_hero_lycan'] = {sNormName='狼人', sShortName='lyc', sCnName='狼人', sEnName='Lycan'},
	['npc_dota_hero_magnataur'] = {sNormName='猛犸', sShortName='mag', sCnName='马格纳斯', sEnName='Magnus'},
	['npc_dota_hero_night_stalker'] = {sNormName='夜魔', sShortName='ns', sCnName='暗夜魔王', sEnName='Night Stalker'},
	['npc_dota_hero_omniknight'] = {sNormName='全能', sShortName='ok', sCnName='全能骑士', sEnName='Omniknight'},
	['npc_dota_hero_phoenix'] = {sNormName='凤凰', sShortName='pho', sCnName='凤凰', sEnName='Phoenix'},
	['npc_dota_hero_pudge'] = {sNormName='屠夫', sShortName='pudge', sCnName='帕吉', sEnName='Pudge'},
	['npc_dota_hero_sand_king'] = {sNormName='沙王', sShortName='sk', sCnName='沙王', sEnName='Sand King'},
	['npc_dota_hero_slardar'] = {sNormName='大鱼', sShortName='sg', sCnName='斯拉达', sEnName='Slardar'},
	['npc_dota_hero_spirit_breaker'] = {sNormName='白牛', sShortName='sb', sCnName='裂魂人', sEnName='Spirit Breaker'},
	['npc_dota_hero_sven'] = {sNormName='流浪', sShortName='sv', sCnName='斯温', sEnName='Sven'},
	['npc_dota_hero_tidehunter'] = {sNormName='潮汐', sShortName='th', sCnName='潮汐猎人', sEnName='Tidehunter'},
	['npc_dota_hero_shredder'] = {sNormName='伐木机', sShortName='gs', sCnName='伐木机', sEnName='Timbersaw'},
	['npc_dota_hero_tiny'] = {sNormName='山岭', sShortName='tiny', sCnName='小小', sEnName='Tiny'},
	['npc_dota_hero_treant'] = {sNormName='大树', sShortName='tp', sCnName='树精卫士', sEnName='Treant Protector'},
	['npc_dota_hero_tusk'] = {sNormName='海民', sShortName='tusk', sCnName='巨牙海民', sEnName='Tusk'},
	['npc_dota_hero_abyssal_underlord'] = {sNormName='大屁股', sShortName='au', sCnName='孽主', sEnName='Underlord'},
	['npc_dota_hero_undying'] = {sNormName='尸王', sShortName='ud', sCnName='不朽尸王', sEnName='Undying'},
	['npc_dota_hero_skeleton_king'] = {sNormName='骷髅王', sShortName='snk', sCnName='冥魂大帝', sEnName='Wraith King'},
	['npc_dota_hero_antimage'] = {sNormName='敌法', sShortName='am', sCnName='敌法师', sEnName='Anti-Mage'},
	['npc_dota_hero_arc_warden'] = {sNormName='电狗', sShortName='arc', sCnName='天穹守望者', sEnName='Arc Warden'},
	['npc_dota_hero_bloodseeker'] = {sNormName='血魔', sShortName='bs', sCnName='血魔', sEnName='Bloodseeker'},
	['npc_dota_hero_bounty_hunter'] = {sNormName='赏金', sShortName='bh', sCnName='赏金猎人', sEnName='Bounty Hunter'},
	['npc_dota_hero_broodmother'] = {sNormName='蜘蛛', sShortName='br', sCnName='育母蜘蛛', sEnName='Broodmother'},
	['npc_dota_hero_clinkz'] = {sNormName='骨弓', sShortName='bone', sCnName='克林克兹', sEnName='Clinkz'},
	['npc_dota_hero_dark_willow'] = {sNormName='小仙女', sShortName='dw', sCnName='邪影芳灵', sEnName='Dark Willow'},
	['npc_dota_hero_drow_ranger'] = {sNormName='小黑', sShortName='dr', sCnName='卓尔游侠', sEnName='Drow Ranger'},
	['npc_dota_hero_ember_spirit'] = {sNormName='火猫', sShortName='ember', sCnName='灰烬之灵', sEnName='Ember Spirit'},
	['npc_dota_hero_faceless_void'] = {sNormName='虚空', sShortName='fv', sCnName='虚空假面', sEnName='Faceless Void'},
	['npc_dota_hero_gyrocopter'] = {sNormName='飞机', sShortName='av', sCnName='矮人直升机', sEnName='Gyrocopter'},
	['npc_dota_hero_juggernaut'] = {sNormName='剑圣', sShortName='jugg', sCnName='主宰', sEnName='Juggernaut'},
	['npc_dota_hero_lone_druid'] = {sNormName='熊德', sShortName='ld', sCnName='德鲁伊', sEnName='Lone Druid'},
	['npc_dota_hero_luna'] = {sNormName='月骑', sShortName='luna', sCnName='露娜', sEnName='Luna'},
	['npc_dota_hero_medusa'] = {sNormName='一姐', sShortName='med', sCnName='美杜莎', sEnName='Medusa'},
	['npc_dota_hero_meepo'] = {sNormName='狗头', sShortName='meepo', sCnName='米波', sEnName='Meepo'},
	['npc_dota_hero_mirana'] = {sNormName='白虎', sShortName='pom', sCnName='米拉娜', sEnName='Mirana'},
	['npc_dota_hero_monkey_king'] = {sNormName='大圣', sShortName='monkey', sCnName='齐天大圣', sEnName='Monkey King'},
	['npc_dota_hero_morphling'] = {sNormName='水人', sShortName='mor', sCnName='变体精灵', sEnName='Morphling'},
	['npc_dota_hero_naga_siren'] = {sNormName='小娜迦', sShortName='naga', sCnName='娜迦海妖', sEnName='Naga Siren'},
	['npc_dota_hero_nyx_assassin'] = {sNormName='小强', sShortName='na', sCnName='司夜刺客', sEnName='Nyx Assassin'},
	['npc_dota_hero_phantom_assassin'] = {sNormName='幻刺', sShortName='pa', sCnName='幻影刺客', sEnName='Phantom Assassin'},
	['npc_dota_hero_phantom_lancer'] = {sNormName='猴子', sShortName='pl', sCnName='幻影长矛手', sEnName='Phantom Lancer'},
	['npc_dota_hero_razor'] = {sNormName='电棍', sShortName='razor', sCnName='剃刀', sEnName='Razor'},
	['npc_dota_hero_riki'] = {sNormName='隐刺', sShortName='sa', sCnName='力丸', sEnName='Riki'},
	['npc_dota_hero_nevermore'] = {sNormName='影魔', sShortName='sf', sCnName='影魔', sEnName='Shadow Fiend'},
	['npc_dota_hero_slark'] = {sNormName='小鱼', sShortName='nc', sCnName='斯拉克', sEnName='Slark'},
	['npc_dota_hero_sniper'] = {sNormName='火枪', sShortName='sniper', sCnName='狙击手', sEnName='Sniper'},
	['npc_dota_hero_spectre'] = {sNormName='幽鬼', sShortName='spe', sCnName='幽鬼', sEnName='Spectre'},
	['npc_dota_hero_templar_assassin'] = {sNormName='圣堂', sShortName='ta', sCnName='圣堂刺客', sEnName='Templar Assassin'},
	['npc_dota_hero_terrorblade'] = {sNormName='魂守', sShortName='tb', sCnName='恐怖利刃', sEnName='Terrorblade'},
	['npc_dota_hero_troll_warlord'] = {sNormName='巨魔', sShortName='tw', sCnName='巨魔战将', sEnName='Troll Warlord'},
	['npc_dota_hero_ursa'] = {sNormName='拍拍', sShortName='ursa', sCnName='熊战士', sEnName='Ursa'},
	['npc_dota_hero_vengefulspirit'] = {sNormName='VS', sShortName='vs', sCnName='复仇之魂', sEnName='Vengeful Spirit'},
	['npc_dota_hero_venomancer'] = {sNormName='剧毒', sShortName='veno', sCnName='剧毒术士', sEnName='Venomancer'},
	['npc_dota_hero_viper'] = {sNormName='毒龙', sShortName='vip', sCnName='冥界亚龙', sEnName='Viper'},
	['npc_dota_hero_weaver'] = {sNormName='蚂蚁', sShortName='nw', sCnName='编织者', sEnName='Weaver'},
	['npc_dota_hero_ancient_apparition'] = {sNormName='冰魂', sShortName='aa', sCnName='远古冰魄', sEnName='Ancient Apparition'},
	['npc_dota_hero_bane'] = {sNormName='祸乱', sShortName='bane', sCnName='祸乱之源', sEnName='Bane'},
	['npc_dota_hero_batrider'] = {sNormName='蝙蝠', sShortName='bat', sCnName='蝙蝠骑士', sEnName='Batrider'},
	['npc_dota_hero_chen'] = {sNormName='陈', sShortName='chen', sCnName='陈', sEnName='Chen'},
	['npc_dota_hero_crystal_maiden'] = {sNormName='冰女', sShortName='cm', sCnName='水晶室女', sEnName='Crystal Maiden'},
	['npc_dota_hero_dark_seer'] = {sNormName='兔子', sShortName='ds', sCnName='黑暗贤者', sEnName='Dark Seer'},
	['npc_dota_hero_dazzle'] = {sNormName='暗牧', sShortName='sp', sCnName='戴泽', sEnName='Dazzle'},
	['npc_dota_hero_death_prophet'] = {sNormName='DP', sShortName='DP', sCnName='死亡先知', sEnName='Death Prophet'},
	['npc_dota_hero_disruptor'] = {sNormName='萨尔', sShortName='thrall', sCnName='干扰者', sEnName='Disruptor'},
	['npc_dota_hero_enchantress'] = {sNormName='小鹿', sShortName='eh', sCnName='魅惑魔女', sEnName='Enchantress'},
	['npc_dota_hero_enigma'] = {sNormName='谜团', sShortName='em', sCnName='谜团', sEnName='Enigma'},
	['npc_dota_hero_invoker'] = {sNormName='卡尔', sShortName='invoker', sCnName='祈求者', sEnName='Invoker'},
	['npc_dota_hero_jakiro'] = {sNormName='双头龙', sShortName='thd', sCnName='杰奇洛', sEnName='Jakiro'},
	['npc_dota_hero_keeper_of_the_light'] = {sNormName='光法', sShortName='kotl', sCnName='光之守卫', sEnName='Keeper of the Light'},
	['npc_dota_hero_leshrac'] = {sNormName='老鹿', sShortName='TS', sCnName='拉席克', sEnName='Leshrac'},
	['npc_dota_hero_lich'] = {sNormName='巫妖', sShortName='lich', sCnName='巫妖', sEnName='Lich'},
	['npc_dota_hero_lina'] = {sNormName='火女', sShortName='lina', sCnName='莉娜', sEnName='Lina'},
	['npc_dota_hero_lion'] = {sNormName='莱恩', sShortName='lion', sCnName='莱恩', sEnName='Lion'},
	['npc_dota_hero_furion'] = {sNormName='先知', sShortName='fur', sCnName='先知', sEnName="Nature's Prophet"},
	['npc_dota_hero_necrolyte'] = {sNormName='死灵法', sShortName='nec', sCnName='瘟疫法师', sEnName='Necrophos'},
	['npc_dota_hero_ogre_magi'] = {sNormName='蓝胖', sShortName='om', sCnName='食人魔魔法师', sEnName='Ogre Magi'},
	['npc_dota_hero_oracle'] = {sNormName='神谕', sShortName='oracle', sCnName='神谕者', sEnName='Oracle'},
	['npc_dota_hero_obsidian_destroyer'] = {sNormName='黑鸟', sShortName='od', sCnName='殁境神蚀者', sEnName='Outworld Destroyer'},
	['npc_dota_hero_pangolier'] = {sNormName='滚滚', sShortName='pangolier', sCnName='石鳞剑士', sEnName='Pangolier'},
	['npc_dota_hero_puck'] = {sNormName='精灵龙', sShortName='puck', sCnName='帕克', sEnName='Puck'},
	['npc_dota_hero_pugna'] = {sNormName='骨法', sShortName='pugna', sCnName='帕格纳', sEnName='Pugna'},
	['npc_dota_hero_queenofpain'] = {sNormName='女王', sShortName='qop', sCnName='痛苦女王', sEnName='Queen of Pain'},
	['npc_dota_hero_rubick'] = {sNormName='拉比克', sShortName='rubick', sCnName='拉比克', sEnName='Rubick'},
	['npc_dota_hero_shadow_demon'] = {sNormName='毒狗', sShortName='sd', sCnName='暗影恶魔', sEnName='Shadow Demon'},
	['npc_dota_hero_shadow_shaman'] = {sNormName='小Y', sShortName='ss', sCnName='暗影萨满', sEnName='Shadow Shaman'},
	['npc_dota_hero_silencer'] = {sNormName='沉默', sShortName='sil', sCnName='沉默术士', sEnName='Silencer'},
	['npc_dota_hero_skywrath_mage'] = {sNormName='天怒', sShortName='sm', sCnName='天怒法师', sEnName='Skywrath Mage'},
	['npc_dota_hero_storm_spirit'] = {sNormName='蓝猫', sShortName='st', sCnName='风暴之灵', sEnName='Storm Spirit'},
	['npc_dota_hero_techies'] = {sNormName='炸弹人', sShortName='techies', sCnName='工程师', sEnName='Techies'},
	['npc_dota_hero_tinker'] = {sNormName='TK', sShortName='tk', sCnName='修补匠', sEnName='Tinker'},
	['npc_dota_hero_visage'] = {sNormName='死灵龙', sShortName='vis', sCnName='维萨吉', sEnName='Visage'},
	['npc_dota_hero_warlock'] = {sNormName='术士', sShortName='wlk', sCnName='术士', sEnName='Warlock'},
	['npc_dota_hero_windrunner'] = {sNormName='风行', sShortName='wr', sCnName='风行者', sEnName='Windranger'},
	['npc_dota_hero_winter_wyvern'] = {sNormName='冰龙', sShortName='ww', sCnName='寒冬飞龙', sEnName='Winter Wyvern'},
	['npc_dota_hero_witch_doctor'] = {sNormName='巫医', sShortName='wd', sCnName='巫医', sEnName='Witch Doctor'},
	['npc_dota_hero_mars'] = {sNormName='玛尔斯', sShortName='mars', sCnName='玛尔斯', sEnName='Mars'},
	['npc_dota_hero_zuus'] = {sNormName='宙斯', sShortName='zeus', sCnName='宙斯', sEnName='Zeus'},
	['npc_dota_hero_snapfire'] = {sNormName='老奶奶', sShortName='snapfire', sCnName='电炎绝手', sEnName='Snapfire'},
	['npc_dota_hero_void_spirit'] = {sNormName='紫猫', sShortName='void', sCnName='虚无之灵', sEnName='Void Spirit'},
	['npc_dota_hero_hoodwink'] = {sNormName='小松鼠', sShortName='hoodwink', sCnName='森海飞霞', sEnName='Hoodwink'},
	['npc_dota_hero_dawnbreaker'] = {sNormName='锤妹', sShortName='dawnbreaker', sCnName='破晓辰星', sEnName='Dawnbreaker'},
	['npc_dota_hero_marci'] = {sNormName='拳妹', sShortName='marci', sCnName='玛西', sEnName='Marci'},
	['npc_dota_hero_muerta'] = {sNormName='琼碧', sShortName='muerta', sCnName='琼英碧灵', sEnName='Muerta'},
	['npc_dota_hero_primal_beast'] = {sNormName='兽', sShortName='beast', sCnName='獸', sEnName='Primal Beast'},
	['npc_dota_hero_ringmaster'] = {sNormName='百戏大王', sShortName='ringmaster', sCnName='百戏大王', sEnName='Ring Master'},
	['npc_dota_hero_kez'] = {sNormName='凯', sShortName='kez', sCnName='凯', sEnName='Kez'},
}

local sChineseItemNameIndexList = {}
for _, v in pairs( Chat['tItemNameList'] )
do
	local sRawItemName = v['sRawName']
	local sCnItemName = v['sCnName']
	sChineseItemNameIndexList[sRawItemName] = sCnItemName
end

function Chat.GetItemCnName( sRawName )
	return sChineseItemNameIndexList[sRawName] or ("未定义:"..sRawName)
end

--本地英雄名
function Chat.GetLocalName( bot )

	local tBotName = Chat['tHeroNameList'][bot:GetUnitName()]

	if tBotName ~= nil
	then
		return tBotName[sRawLanguage]
	end

end


--简化中文名
function Chat.GetNormName( bot )

	local tBotName = Chat['tHeroNameList'][bot:GetUnitName()]

	return tBotName ~= nil and tBotName['sNormName'] or string.sub( bot:GetUnitName(), 10 )

end

local tChatStringTable = require( GetScriptDirectory()..'/FunLib/aba_chat_table' )
local tChatStringIndex = {}

for nChatStringIndex = 1, #tChatStringTable
do
	local tIndexKey = tChatStringTable[nChatStringIndex][1]
	for nIndexValue = 1, #tIndexKey
	do
		local sIndexKey = tIndexKey[nIndexValue]

		if tChatStringIndex[sIndexKey] == nil
		then
			tChatStringIndex[sIndexKey] = nChatStringIndex
		else
			local nRepeatedIndexKey = tChatStringIndex[sIndexKey]

			for i = 1, #tChatStringTable[nChatStringIndex][2]
			do
				table.insert( tChatStringTable[nRepeatedIndexKey][2], tChatStringTable[nChatStringIndex][2][i] )
			end

			for i = 1, #tChatStringTable[nChatStringIndex][3]
			do
				table.insert( tChatStringTable[nRepeatedIndexKey][3], tChatStringTable[nChatStringIndex][3][i] )
			end
		end
	end
end


function Chat.GetChatStringTableIndex( sString )

	return tChatStringIndex[sString] or - 1

end


function Chat.GetChatTableString( nIndex, bAllChat )

	local nStringTableIndex = 2

	if bAllChat then nStringTableIndex = 3 end

	local sChatStringList = tChatStringTable[nIndex][nStringTableIndex]

	local sChatTableString = sChatStringList[RandomInt( 1, #sChatStringList )]

	return sChatTableString

end


function Chat.GetReplyString( sString, bAllChat )
	local sReplyString = nil
	if Chat.AllowTrashTalk(bAllChat) then
		if Customize.Localization == 'zh' then
			local nIndex = Chat.GetChatStringTableIndex( sString )
			if nIndex ~= - 1
			then
				sReplyString = Chat.GetChatTableString( nIndex, bAllChat )
			else
				sReplyString = Chat.GetCheaterReplyString( sString )
				if sReplyString == nil
				then
					sReplyString = Chat.GetRepeatString( sString )
				end
			end
		end
		if sReplyString == nil or RandomInt( 1, 100 ) > 90
		then
			sReplyString = Localization.Get('random_responses')[RandomInt( 1, #Localization.Get('random_responses'))]
		end
	end

	return sReplyString

end

function Chat.AllowTrashTalk(bAllChat)
	return Customize.Allow_Trash_Talk and
		((not bAllChat and (Customize.Trash_Talk_Level == nil or Customize.Trash_Talk_Level >= 2))
		or (bAllChat and (Customize.Trash_Talk_Level == nil or Customize.Trash_Talk_Level >= 1)))
end

function Chat.GetCheaterReplyString( sString )

	return string.byte( sString, 1 ) == string.byte( '-', 1 ) and "cheater" or nil

end


function Chat.GetRepeatString( sString )

	local ignoreList = {"你们", "你", "我", "吗？", "吗", "吧", "？"}
    for _, word in ipairs(ignoreList) do
        if sString == word then return nil end
    end

    local sRawString = sString
    if sString:find("我是你") then
        return sString:gsub("我是你", "我才是你")
    end

	local tauntWords = {"sb", "SB", "智障", "弱智", "脑残", "脑瘫", "猪", "傻", "菜", "笨", "蠢"}
    for _, word in ipairs(tauntWords) do
        if sString:find(word) then
            return Chat.GetReplyTauntString()
        end
    end

	local sMaReplyList = { "呀", "哦", "呀！", "哦！", "！", "" }
	local sMaReplyWord = sMaReplyList[RandomInt( 1, #sMaReplyList )]

	sString = string.gsub( sString, "你们", "" )
	sString = string.gsub( sString, "你", "" )
	sString = string.gsub( sString, "吗？", sMaReplyWord )
	sString = string.gsub( sString, "吗", sMaReplyWord )
	sString = string.gsub( sString, "吧", "啊" )
	sString = string.gsub( sString, "？", "！" )
	sString = string.gsub( sString, "?", "!" )
	sString = string.gsub( sString, "我", "你" )

	return sString ~= sRawString and sString or nil

end

local sReplyTauntList = {
	"你是在说你自己吗?",
	"你就只会说这个而已吗?",
	"我不允许你这么说你自己!",
	"别这么说你自己, 小伙汁.",
	"其实你不用这么来说你自己的.",
	"原来你自己就是酱紫的呀.",
	"自信点, 别这么说你自己.",
	"放松点, 就你这样没事的.",
	"反弹biubiubiu.",
	"给爷爬~~~",
}
function Chat.GetReplyTauntString()
	return sReplyTauntList[RandomInt( 1, #sReplyTauntList )]
end

function Chat.GetStopReplyString()
	return Localization.Get('no_more_talking')[RandomInt( 1, #Localization.Get('no_more_talking'))]
end


return Chat
