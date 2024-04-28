-----------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
-----------------------------------------------------------------------------
local Chat = {}
local sRawLanguage = 'sRawName'


Chat['sAllHeroList'] = {
	'sRandomHero',
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
	
}


Chat['tLanguageNameList'] = {

	[1] = {
		['sRawName'] = 'sCnName',
		['sLocalName'] = '中文',
	},

	[2] = {
		['sRawName'] = 'sEnName',
		['sLocalName'] = 'English',
	},

	[3] = {
		['sRawName'] = 'sFrName',
		['sLocalName'] = 'Français',
	},

	[4] = {
		['sRawName'] = 'sDeName',
		['sLocalName'] = 'Deutsch',
	},

	[5] = {
		['sRawName'] = 'sRuName',
		['sLocalName'] = 'русский',
	},

	[6] = {
		['sRawName'] = 'sJpName',
		['sLocalName'] = 'わぶん',
	},

	[7] = {
		['sRawName'] = 'sEsName',
		['sLocalName'] = 'Испанский',
	},


}


Chat['tGameWordList'] = {

	[1] = {
		['sRawName'] = true,
		['sShortName'] = 'y',
		['sCnName'] = '是',
		['sEnName'] = 'yes',

	},


	[2] = {
		['sRawName'] = false,
		['sShortName'] = 'n',
		['sCnName'] = '否',
		['sEnName'] = 'no',

	},


	[3] = {
		['sRawName'] = 10,
		['sShortName'] = 'l',
		['sCnName'] = '左',
		['sEnName'] = 'left',

	},

	[4] = {
		['sRawName'] = 0,
		['sShortName'] = 'r',
		['sCnName'] = '右',
		['sEnName'] = 'right',

	},

	[5] = {
		['sRawName'] = LANE_TOP,
		['sShortName'] = 'top',
		['sCnName'] = '上路',
		['sEnName'] = 0,

	},

	[6] = {
		['sRawName'] = LANE_MID,
		['sShortName'] = 'mid',
		['sCnName'] = '中路',
		['sEnName'] = 0,

	},

	[7] = {
		['sRawName'] = LANE_BOT,
		['sShortName'] = 'bot',
		['sCnName'] = '下路',
		['sEnName'] = 0,

	},

}


Chat['tSpWordList'] = {
	
	['key_dir'] = 'game/激活密钥/AI激活密钥',
	
	['hero_pool_dir'] = 'game/AI锦囊/AI随机英雄池',
	
	['radiant_set'] = 'game/AI锦囊/天辉锦囊/',
	
	['dire_set'] = 'game/AI锦囊/夜魇锦囊/',
	
	['radiant_lineup'] = 'AI天辉阵容',
	
	['dire_lineup'] = 'AI夜魇阵容',
	
	['user_call'] = ' 军师:',
	
	['aba_lineup_202007'] = '天地星AI·2020丶年七月版',
	
	['aba_lineup_202008'] = '天地星AI·2020丶年八月版',
	
	['aba_lineup_202009'] = '天地星AI·2020丶年九月版',
	
	['aba_lineup_2020d3'] = '天地星AI·2020丶年第三季版',
	
	['aba_lineup_2020'] = '天地星AI·2020丶年版',
	
	['aba_lineup_202105'] = '天地星AI·2021丶年5月体验阵容版',
	
	['aba_lineup_202106'] = '天地星AI·2021丶年6月体验阵容版',
	
	['aba_lineup_2021'] = '天地星AI·2021丶年阵容版',
	
	['aba_all_202007'] = '天地星AI·2020丶年七月完全版',
	
	['aba_all_202008'] = '天地星AI·2020丶年八月完全版',
	
	['aba_all_202009'] = '天地星AI·2020丶年九月完全版',
	
	['aba_all_2020d3'] = '天地星AI·2020丶年第三季完全版',
	
	['aba_all_2020'] = '天地星AI·2020丶年完全版',
	
	['aba_all_202105'] = '天地星AI·2021丶年5月体验版',
	
	['aba_all_202106'] = '天地星AI·2021丶年6月体验版',
	
	['aba_all_2021'] = '天地星AI·2021丶年完全版',
	
	['sa_all_202007'] = 'SiriusAI拓展天地星·2020丶七月完全版',
	
	['sa_all_202008'] = 'SiriusAI拓展天地星·2020丶八月完全版',
	
	['sa_all_202009'] = 'SiriusAI拓展天地星·2020丶九月完全版',
	
	['sa_all_2020d3'] = 'SiriusAI拓展天地星·2020丶年第三季完全版',
	
	['sa_all_2020'] = 'SiriusAI拓展天地星·2020丶年完全版',
	
	['sa_all_202105'] = 'SiriusAI拓展天地星·2021丶年5月体验版',
	
	['sa_all_202106'] = 'SiriusAI拓展天地星·2021丶年6月体验版',
	
	['sa_all_2021'] = 'SiriusAI拓展天地星·2021丶年完全版',


}


Chat['tItemNameList'] = {

	[0] = {
		['sRawName'] = 'item_cyclone',
		['sShortName'] = 'itemNull',
		['sCnName'] = 'EUL的神圣法杖',
		['sEnName'] = 0,

	},


	[1] = {
		['sRawName'] = 'item_cyclone',
		['sShortName'] = 'itemNull',
		['sCnName'] = 'Eul的神圣法杖',
		['sEnName'] = 0,

	},

	[2] = {
		['sRawName'] = 'item_ultimate_scepter',
		['sShortName'] = 'itemNull',
		['sCnName'] = '阿哈利姆神杖',
		['sEnName'] = 0,

	},

	[3] = {
		['sRawName'] = 'item_ultimate_scepter_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '阿哈利姆神杖2',
		['sEnName'] = 0,

	},

	[4] = {
		['sRawName'] = 'item_rod_of_atos',
		['sShortName'] = 'itemNull',
		['sCnName'] = '阿托斯之棍',
		['sEnName'] = 0,

	},

	[5] = {
		['sRawName'] = 'item_shadow_amulet',
		['sShortName'] = 'itemNull',
		['sCnName'] = '暗影护符',
		['sEnName'] = 0,

	},

	[6] = {
		['sRawName'] = 'item_desolator',
		['sShortName'] = 'itemNull',
		['sCnName'] = '黯灭',
		['sEnName'] = 0,

	},

	[7] = {
		['sRawName'] = 'item_arcane_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '奥术鞋',
		['sEnName'] = 0,

	},

	[8] = {
		['sRawName'] = 'item_silver_edge',
		['sShortName'] = 'itemNull',
		['sCnName'] = '白银之锋',
		['sEnName'] = 0,

	},

	[9] = {
		['sRawName'] = 'item_platemail',
		['sShortName'] = 'itemNull',
		['sCnName'] = '板甲',
		['sEnName'] = 0,

	},

	[10] = {
		['sRawName'] = 'item_javelin',
		['sShortName'] = 'itemNull',
		['sCnName'] = '标枪',
		['sEnName'] = 0,

	},

	[11] = {
		['sRawName'] = 'item_crimson_guard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '赤红甲',
		['sEnName'] = 0,

	},

	[12] = {
		['sRawName'] = 'item_orb_of_venom',
		['sShortName'] = 'itemNull',
		['sCnName'] = '淬毒之珠',
		['sEnName'] = 0,

	},

	[13] = {
		['sRawName'] = 'item_dagon',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力',
		['sEnName'] = 0,

	},

	[14] = {
		['sRawName'] = 'item_dagon_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力2',
		['sEnName'] = 0,

	},

	[15] = {
		['sRawName'] = 'item_dagon_3',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力3',
		['sEnName'] = 0,

	},

	[16] = {
		['sRawName'] = 'item_dagon_4',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力4',
		['sEnName'] = 0,

	},

	[17] = {
		['sRawName'] = 'item_dagon_5',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力5',
		['sEnName'] = 0,

	},

	[18] = {
		['sRawName'] = 'item_claymore',
		['sShortName'] = 'itemNull',
		['sCnName'] = '大剑',
		['sEnName'] = 0,

	},

	[19] = {
		['sRawName'] = 'item_greater_crit',
		['sShortName'] = 'itemNull',
		['sCnName'] = '代达罗斯之殇',
		['sEnName'] = 0,

	},

	[20] = {
		['sRawName'] = 'item_power_treads',
		['sShortName'] = 'itemNull',
		['sCnName'] = '动力鞋',
		['sEnName'] = 0,

	},

	[21] = {
		['sRawName'] = 'item_courier',
		['sShortName'] = 'itemNull',
		['sCnName'] = '动物信使',
		['sEnName'] = 0,

	},

	[22] = {
		['sRawName'] = 'item_pipe',
		['sShortName'] = 'itemNull',
		['sCnName'] = '洞察烟斗',
		['sEnName'] = 0,

	},

	[23] = {
		['sRawName'] = 'item_quarterstaff',
		['sShortName'] = 'itemNull',
		['sCnName'] = '短棍',
		['sEnName'] = 0,

	},

	[24] = {
		['sRawName'] = 'item_demon_edge',
		['sShortName'] = 'itemNull',
		['sCnName'] = '恶魔刀锋',
		['sEnName'] = 0,

	},

	[25] = {
		['sRawName'] = 'item_robe',
		['sShortName'] = 'itemNull',
		['sCnName'] = '法师长袍',
		['sEnName'] = 0,

	},

	[26] = {
		['sRawName'] = 'item_veil_of_discord',
		['sShortName'] = 'itemNull',
		['sCnName'] = '纷争面纱',
		['sEnName'] = 0,

	},

	[27] = {
		['sRawName'] = 'item_mask_of_madness',
		['sShortName'] = 'itemNull',
		['sCnName'] = '疯狂面具',
		['sEnName'] = 0,

	},

	[28] = {
		['sRawName'] = 'item_nullifier',
		['sShortName'] = 'itemNull',
		['sCnName'] = '否决坠饰',
		['sEnName'] = 0,

	},

	[29] = {
		['sRawName'] = 'item_vladmir',
		['sShortName'] = 'itemNull',
		['sCnName'] = '弗拉迪米尔的祭品',
		['sEnName'] = 0,

	},

	[30] = {
		['sRawName'] = 'item_ward_sentry',
		['sShortName'] = 'itemNull',
		['sCnName'] = '岗哨守卫',
		['sEnName'] = 0,

	},

	[31] = {
		['sRawName'] = 'item_blades_of_attack',
		['sShortName'] = 'itemNull',
		['sCnName'] = '攻击之爪',
		['sEnName'] = 0,

	},

	[32] = {
		['sRawName'] = 'item_smoke_of_deceit',
		['sShortName'] = 'itemNull',
		['sCnName'] = '诡计之雾',
		['sEnName'] = 0,

	},

	[33] = {
		['sRawName'] = 'item_black_king_bar',
		['sShortName'] = 'itemNull',
		['sCnName'] = '黑皇杖',
		['sEnName'] = 0,

	},

	[34] = {
		['sRawName'] = 'item_butterfly',
		['sShortName'] = 'itemNull',
		['sCnName'] = '蝴蝶',
		['sEnName'] = 0,

	},

	[35] = {
		['sRawName'] = 'item_bracer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '护腕',
		['sEnName'] = 0,

	},

	[36] = {
		['sRawName'] = 'item_blade_of_alacrity',
		['sShortName'] = 'itemNull',
		['sCnName'] = '欢欣之刃',
		['sEnName'] = 0,

	},

	[37] = {
		['sRawName'] = 'item_manta',
		['sShortName'] = 'itemNull',
		['sCnName'] = '幻影斧',
		['sEnName'] = 0,

	},

	[38] = {
		['sRawName'] = 'item_headdress',
		['sShortName'] = 'itemNull',
		['sCnName'] = '恢复头巾',
		['sEnName'] = 0,

	},

	[39] = {
		['sRawName'] = 'item_radiance',
		['sShortName'] = 'itemNull',
		['sCnName'] = '辉耀',
		['sEnName'] = 0,

	},

	[40] = {
		['sRawName'] = 'item_tpscroll',
		['sShortName'] = 'itemNull',
		['sCnName'] = '回城卷轴',
		['sEnName'] = 0,

	},

	[41] = {
		['sRawName'] = 'item_ring_of_health',
		['sShortName'] = 'itemNull',
		['sCnName'] = '回复戒指',
		['sEnName'] = 0,

	},

	[42] = {
		['sRawName'] = 'item_echo_sabre',
		['sShortName'] = 'itemNull',
		['sCnName'] = '回音战刃',
		['sEnName'] = 0,

	},

	[43] = {
		['sRawName'] = 'item_kaya',
		['sShortName'] = 'itemNull',
		['sCnName'] = '慧光',
		['sEnName'] = 0,

	},

	[44] = {
		['sRawName'] = 'item_yasha_and_kaya',
		['sShortName'] = 'itemNull',
		['sCnName'] = '慧夜对剑',
		['sEnName'] = 0,

	},

	[45] = {
		['sRawName'] = 'item_vitality_booster',
		['sShortName'] = 'itemNull',
		['sCnName'] = '活力之球',
		['sEnName'] = 0,

	},

	[46] = {
		['sRawName'] = 'item_ultimate_orb',
		['sShortName'] = 'itemNull',
		['sCnName'] = '极限法球',
		['sEnName'] = 0,

	},

	[47] = {
		['sRawName'] = 'item_gloves',
		['sShortName'] = 'itemNull',
		['sCnName'] = '加速手套',
		['sEnName'] = 0,

	},

	[48] = {
		['sRawName'] = 'item_pers',
		['sShortName'] = 'itemNull',
		['sCnName'] = '坚韧球',
		['sEnName'] = 0,

	},

	[49] = {
		['sRawName'] = 'item_monkey_king_bar',
		['sShortName'] = 'itemNull',
		['sCnName'] = '金箍棒',
		['sEnName'] = 0,

	},

	[50] = {
		['sRawName'] = 'item_boots_of_elves',
		['sShortName'] = 'itemNull',
		['sCnName'] = '精灵布带',
		['sEnName'] = 0,

	},

	[51] = {
		['sRawName'] = 'item_point_booster',
		['sShortName'] = 'itemNull',
		['sCnName'] = '精气之球',
		['sEnName'] = 0,

	},

	[52] = {
		['sRawName'] = 'item_clarity',
		['sShortName'] = 'itemNull',
		['sCnName'] = '净化药水',
		['sEnName'] = 0,

	},

	[53] = {
		['sRawName'] = 'item_diffusal_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '净魂之刃',
		['sEnName'] = 0,

	},

	[54] = {
		['sRawName'] = 'item_tranquil_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '静谧之鞋',
		['sEnName'] = 0,

	},

	[55] = {
		['sRawName'] = 'item_cloak',
		['sShortName'] = 'itemNull',
		['sCnName'] = '抗魔斗篷',
		['sEnName'] = 0,

	},

	[56] = {
		['sRawName'] = 'item_null_talisman',
		['sShortName'] = 'itemNull',
		['sCnName'] = '空灵挂件',
		['sEnName'] = 0,

	},

	[57] = {
		['sRawName'] = 'item_oblivion_staff',
		['sShortName'] = 'itemNull',
		['sCnName'] = '空明杖',
		['sEnName'] = 0,

	},

	[58] = {
		['sRawName'] = 'item_fluffy_hat',
		['sShortName'] = 'itemNull',
		['sCnName'] = '毛毛帽',
		['sEnName'] = 0,

	},

	[59] = {
		['sRawName'] = 'item_heart',
		['sShortName'] = 'itemNull',
		['sCnName'] = '恐鳌之心',
		['sEnName'] = 0,

	},

	[60] = {
		['sRawName'] = 'item_bfury',
		['sShortName'] = 'itemNull',
		['sCnName'] = '狂战斧',
		['sEnName'] = 0,

	},

	[61] = {
		['sRawName'] = 'item_broadsword',
		['sShortName'] = 'itemNull',
		['sCnName'] = '阔剑',
		['sEnName'] = 0,

	},

	[62] = {
		['sRawName'] = 'item_mjollnir',
		['sShortName'] = 'itemNull',
		['sCnName'] = '雷神之锤',
		['sEnName'] = 0,

	},

	[63] = {
		['sRawName'] = 'item_gauntlets',
		['sShortName'] = 'itemNull',
		['sCnName'] = '力量手套',
		['sEnName'] = 0,

	},

	[64] = {
		['sRawName'] = 'item_belt_of_strength',
		['sShortName'] = 'itemNull',
		['sCnName'] = '力量腰带',
		['sEnName'] = 0,

	},

	[65] = {
		['sRawName'] = 'item_sphere',
		['sShortName'] = 'itemNull',
		['sCnName'] = '林肯法球',
		['sEnName'] = 0,

	},

	[66] = {
		['sRawName'] = 'item_soul_ring',
		['sShortName'] = 'itemNull',
		['sCnName'] = '灵魂之戒',
		['sEnName'] = 0,

	},

	[67] = {
		['sRawName'] = 'item_octarine_core',
		['sShortName'] = 'itemNull',
		['sCnName'] = '玲珑心',
		['sEnName'] = 0,

	},

	[68] = {
		['sRawName'] = 'item_reaver',
		['sShortName'] = 'itemNull',
		['sCnName'] = '掠夺者之斧',
		['sEnName'] = 0,

	},

	[69] = {
		['sRawName'] = 'item_hand_of_midas',
		['sShortName'] = 'itemNull',
		['sCnName'] = '迈达斯之手',
		['sEnName'] = 0,

	},

	[70] = {
		['sRawName'] = 'item_mekansm',
		['sShortName'] = 'itemNull',
		['sCnName'] = '梅肯斯姆',
		['sEnName'] = 0,

	},

	[71] = {
		['sRawName'] = 'item_mithril_hammer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '秘银锤',
		['sEnName'] = 0,

	},

	[72] = {
		['sRawName'] = 'item_slippers',
		['sShortName'] = 'itemNull',
		['sCnName'] = '敏捷便鞋',
		['sEnName'] = 0,

	},

	[73] = {
		['sRawName'] = 'item_magic_stick',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔棒',
		['sEnName'] = 0,

	},

	[74] = {
		['sRawName'] = 'item_enchanted_mango',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔法芒果',
		['sEnName'] = 0,

	},

	[75] = {
		['sRawName'] = 'item_staff_of_wizardry',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔力法杖',
		['sEnName'] = 0,

	},

	[76] = {
		['sRawName'] = 'item_dragon_lance',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔龙枪',
		['sEnName'] = 0,

	},

	[77] = {
		['sRawName'] = 'item_bottle',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔瓶',
		['sEnName'] = 0,

	},

	[78] = {
		['sRawName'] = 'item_magic_wand',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔杖',
		['sEnName'] = 0,

	},

	[79] = {
		['sRawName'] = 'item_armlet',
		['sShortName'] = 'itemNull',
		['sCnName'] = '莫尔迪基安的臂章',
		['sEnName'] = 0,

	},

	[80] = {
		['sRawName'] = 'item_energy_booster',
		['sShortName'] = 'itemNull',
		['sCnName'] = '能量之球',
		['sEnName'] = 0,

	},

	[81] = {
		['sRawName'] = 'item_assault',
		['sShortName'] = 'itemNull',
		['sCnName'] = '强袭胸甲',
		['sEnName'] = 0,

	},

	[82] = {
		['sRawName'] = 'item_lotus_orb',
		['sShortName'] = 'itemNull',
		['sCnName'] = '清莲宝珠',
		['sEnName'] = 0,

	},

	[83] = {
		['sRawName'] = 'item_blade_mail',
		['sShortName'] = 'itemNull',
		['sCnName'] = '刃甲',
		['sEnName'] = 0,

	},

	[84] = {
		['sRawName'] = 'item_ancient_janggo',
		['sShortName'] = 'itemNull',
		['sCnName'] = '韧鼓',
		['sEnName'] = 0,

	},

	[85] = {
		['sRawName'] = 'item_satanic',
		['sShortName'] = 'itemNull',
		['sCnName'] = '撒旦之邪力',
		['sEnName'] = 0,

	},

	[86] = {
		['sRawName'] = 'item_sange',
		['sShortName'] = 'itemNull',
		['sCnName'] = '散华',
		['sEnName'] = 0,

	},

	[87] = {
		['sRawName'] = 'item_kaya_and_sange',
		['sShortName'] = 'itemNull',
		['sCnName'] = '散慧对剑',
		['sEnName'] = 0,

	},

	[88] = {
		['sRawName'] = 'item_sange_and_yasha',
		['sShortName'] = 'itemNull',
		['sCnName'] = '散夜对剑',
		['sEnName'] = 0,

	},

	[89] = {
		['sRawName'] = 'item_talisman_of_evasion',
		['sShortName'] = 'itemNull',
		['sCnName'] = '闪避护符',
		['sEnName'] = 0,

	},

	[90] = {
		['sRawName'] = 'item_blink',
		['sShortName'] = 'itemNull',
		['sCnName'] = '闪烁匕首',
		['sEnName'] = 0,

	},

	[91] = {
		['sRawName'] = 'item_abyssal_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '深渊之刃',
		['sEnName'] = 0,

	},

	[92] = {
		['sRawName'] = 'item_mystic_staff',
		['sShortName'] = 'itemNull',
		['sCnName'] = '神秘法杖',
		['sEnName'] = 0,

	},

	[93] = {
		['sRawName'] = 'item_rapier',
		['sShortName'] = 'itemNull',
		['sCnName'] = '圣剑',
		['sEnName'] = 0,

	},

	[94] = {
		['sRawName'] = 'item_holy_locket',
		['sShortName'] = 'itemNull',
		['sCnName'] = '圣洁吊坠',
		['sEnName'] = 0,

	},

	[95] = {
		['sRawName'] = 'item_relic',
		['sShortName'] = 'itemNull',
		['sCnName'] = '圣者遗物',
		['sEnName'] = 0,

	},

	[96] = {
		['sRawName'] = 'item_ogre_axe',
		['sShortName'] = 'itemNull',
		['sCnName'] = '食人魔之斧',
		['sEnName'] = 0,

	},

	[97] = {
		['sRawName'] = 'item_ring_of_protection',
		['sShortName'] = 'itemNull',
		['sCnName'] = '守护指环',
		['sEnName'] = 0,

	},

	[98] = {
		['sRawName'] = 'item_tango',
		['sShortName'] = 'itemNull',
		['sCnName'] = '树之祭祀',
		['sEnName'] = 0,

	},

	[99] = {
		['sRawName'] = 'item_refresher',
		['sShortName'] = 'itemNull',
		['sCnName'] = '刷新球',
		['sEnName'] = 0,

	},

	[100] = {
		['sRawName'] = 'item_lesser_crit',
		['sShortName'] = 'itemNull',
		['sCnName'] = '水晶剑',
		['sEnName'] = 0,

	},

	[101] = {
		['sRawName'] = 'item_skadi',
		['sShortName'] = 'itemNull',
		['sCnName'] = '斯嘉蒂之眼',
		['sEnName'] = 0,

	},

	[102] = {
		['sRawName'] = 'item_necronomicon',
		['sShortName'] = 'itemNull',
		['sCnName'] = '死灵书',
		['sEnName'] = 0,

	},

	[103] = {
		['sRawName'] = 'item_necronomicon_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '死灵书2',
		['sEnName'] = 0,

	},

	[104] = {
		['sRawName'] = 'item_necronomicon_3',
		['sShortName'] = 'itemNull',
		['sCnName'] = '死灵书3',
		['sEnName'] = 0,

	},

	[105] = {
		['sRawName'] = 'item_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '速度之靴',
		['sEnName'] = 0,

	},

	[106] = {
		['sRawName'] = 'item_basher',
		['sShortName'] = 'itemNull',
		['sCnName'] = '碎颅锤',
		['sEnName'] = 0,

	},

	[107] = {
		['sRawName'] = 'item_chainmail',
		['sShortName'] = 'itemNull',
		['sCnName'] = '锁子甲',
		['sEnName'] = 0,

	},

	[108] = {
		['sRawName'] = 'item_heavens_halberd',
		['sShortName'] = 'itemNull',
		['sCnName'] = '天堂之戟',
		['sEnName'] = 0,

	},

	[109] = {
		['sRawName'] = 'item_hood_of_defiance',
		['sShortName'] = 'itemNull',
		['sCnName'] = '挑战头巾',
		['sEnName'] = 0,

	},

	[110] = {
		['sRawName'] = 'item_branches',
		['sShortName'] = 'itemNull',
		['sCnName'] = '铁树枝干',
		['sEnName'] = 0,

	},

	[111] = {
		['sRawName'] = 'item_helm_of_iron_will',
		['sShortName'] = 'itemNull',
		['sCnName'] = '铁意头盔',
		['sEnName'] = 0,

	},

	[112] = {
		['sRawName'] = 'item_crown',
		['sShortName'] = 'itemNull',
		['sCnName'] = '王冠',
		['sEnName'] = 0,

	},

	[113] = {
		['sRawName'] = 'item_ring_of_basilius',
		['sShortName'] = 'itemNull',
		['sCnName'] = '王者之戒',
		['sEnName'] = 0,

	},

	[114] = {
		['sRawName'] = 'item_glimmer_cape',
		['sShortName'] = 'itemNull',
		['sCnName'] = '微光披风',
		['sEnName'] = 0,

	},

	[115] = {
		['sRawName'] = 'item_guardian_greaves',
		['sShortName'] = 'itemNull',
		['sCnName'] = '卫士胫甲',
		['sEnName'] = 0,

	},

	[116] = {
		['sRawName'] = 'item_lifesteal',
		['sShortName'] = 'itemNull',
		['sCnName'] = '吸血面具',
		['sEnName'] = 0,

	},

	[117] = {
		['sRawName'] = 'item_shivas_guard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '希瓦的守护',
		['sEnName'] = 0,

	},

	[118] = {
		['sRawName'] = 'item_faerie_fire',
		['sShortName'] = 'itemNull',
		['sCnName'] = '仙灵之火',
		['sEnName'] = 0,

	},

	[119] = {
		['sRawName'] = 'item_vanguard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '先锋盾',
		['sEnName'] = 0,

	},

	[120] = {
		['sRawName'] = 'item_sobi_mask',
		['sShortName'] = 'itemNull',
		['sCnName'] = '贤者面罩',
		['sEnName'] = 0,

	},

	[121] = {
		['sRawName'] = 'item_dust',
		['sShortName'] = 'itemNull',
		['sCnName'] = '显影之尘',
		['sEnName'] = 0,

	},

	[122] = {
		['sRawName'] = 'item_phase_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '相位鞋',
		['sEnName'] = 0,

	},

	[123] = {
		['sRawName'] = 'item_sheepstick',
		['sShortName'] = 'itemNull',
		['sCnName'] = '邪恶镰刀',
		['sEnName'] = 0,

	},

	[124] = {
		['sRawName'] = 'item_ethereal_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '虚灵之刃',
		['sEnName'] = 0,

	},

	[125] = {
		['sRawName'] = 'item_void_stone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '虚无宝石',
		['sEnName'] = 0,

	},

	[126] = {
		['sRawName'] = 'item_buckler',
		['sShortName'] = 'itemNull',
		['sCnName'] = '玄冥盾牌',
		['sEnName'] = 0,

	},

	[127] = {
		['sRawName'] = 'item_maelstrom',
		['sShortName'] = 'itemNull',
		['sCnName'] = '漩涡',
		['sEnName'] = 0,

	},

	[128] = {
		['sRawName'] = 'item_bloodthorn',
		['sShortName'] = 'itemNull',
		['sCnName'] = '血棘',
		['sEnName'] = 0,

	},

	[129] = {
		['sRawName'] = 'item_bloodstone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '血精石',
		['sEnName'] = 0,

	},

	[130] = {
		['sRawName'] = 'item_quelling_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '压制之刃',
		['sEnName'] = 0,

	},

	[131] = {
		['sRawName'] = 'item_solar_crest',
		['sShortName'] = 'itemNull',
		['sCnName'] = '炎阳纹章',
		['sEnName'] = 0,

	},

	[132] = {
		['sRawName'] = 'item_yasha',
		['sShortName'] = 'itemNull',
		['sCnName'] = '夜叉',
		['sEnName'] = 0,

	},

	[133] = {
		['sRawName'] = 'item_aether_lens',
		['sShortName'] = 'itemNull',
		['sCnName'] = '以太透镜',
		['sEnName'] = 0,

	},

	[134] = {
		['sRawName'] = 'item_moon_shard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '银月之晶',
		['sEnName'] = 0,

	},

	[135] = {
		['sRawName'] = 'item_eagle',
		['sShortName'] = 'itemNull',
		['sCnName'] = '鹰歌弓',
		['sEnName'] = 0,

	},

	[136] = {
		['sRawName'] = 'item_invis_sword',
		['sShortName'] = 'itemNull',
		['sCnName'] = '影刃',
		['sEnName'] = 0,

	},

	[137] = {
		['sRawName'] = 'item_urn_of_shadows',
		['sShortName'] = 'itemNull',
		['sCnName'] = '影之灵龛',
		['sEnName'] = 0,

	},

	[138] = {
		['sRawName'] = 'item_aeon_disk',
		['sShortName'] = 'itemNull',
		['sCnName'] = '永恒之盘',
		['sEnName'] = 0,

	},

	[139] = {
		['sRawName'] = 'item_medallion_of_courage',
		['sShortName'] = 'itemNull',
		['sCnName'] = '勇气勋章',
		['sEnName'] = 0,

	},

	[140] = {
		['sRawName'] = 'item_ghost',
		['sShortName'] = 'itemNull',
		['sCnName'] = '幽魂权杖',
		['sEnName'] = 0,

	},

	[141] = {
		['sRawName'] = 'item_force_staff',
		['sShortName'] = 'itemNull',
		['sCnName'] = '原力法杖',
		['sEnName'] = 0,

	},

	[142] = {
		['sRawName'] = 'item_aegis',
		['sShortName'] = 'itemNull',
		['sCnName'] = '不朽之守护',
		['sEnName'] = 0,

	},

	[143] = {
		['sRawName'] = 'item_circlet',
		['sShortName'] = 'itemNull',
		['sCnName'] = '圆环',
		['sEnName'] = 0,

	},

	[144] = {
		['sRawName'] = 'item_travel_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '远行鞋',
		['sEnName'] = 0,

	},

	[145] = {
		['sRawName'] = 'item_travel_boots_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '远行鞋2',
		['sEnName'] = 0,

	},

	[146] = {
		['sRawName'] = 'item_wraith_band',
		['sShortName'] = 'itemNull',
		['sCnName'] = '怨灵系带',
		['sEnName'] = 0,

	},

	[147] = {
		['sRawName'] = 'item_meteor_hammer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '陨星锤',
		['sEnName'] = 0,

	},

	[148] = {
		['sRawName'] = 'item_ward_observer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '侦查守卫',
		['sEnName'] = 0,

	},

	[149] = {
		['sRawName'] = 'item_gem',
		['sShortName'] = 'itemNull',
		['sCnName'] = '真视宝石',
		['sEnName'] = 0,

	},

	[150] = {
		['sRawName'] = 'item_hyperstone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '振奋宝石',
		['sEnName'] = 0,

	},

	[151] = {
		['sRawName'] = 'item_soul_booster',
		['sShortName'] = 'itemNull',
		['sCnName'] = '镇魂石',
		['sEnName'] = 0,

	},

	[152] = {
		['sRawName'] = 'item_helm_of_the_dominator',
		['sShortName'] = 'itemNull',
		['sCnName'] = '支配头盔',
		['sEnName'] = 0,

	},

	[153] = {
		['sRawName'] = 'item_flask',
		['sShortName'] = 'itemNull',
		['sCnName'] = '治疗药膏',
		['sEnName'] = 0,

	},

	[154] = {
		['sRawName'] = 'item_ring_of_health',
		['sShortName'] = 'itemNull',
		['sCnName'] = '治疗指环',
		['sEnName'] = 0,

	},

	[155] = {
		['sRawName'] = 'item_mantle',
		['sShortName'] = 'itemNull',
		['sCnName'] = '智力斗篷',
		['sEnName'] = 0,

	},

	[156] = {
		['sRawName'] = 'item_orchid',
		['sShortName'] = 'itemNull',
		['sCnName'] = '紫怨',
		['sEnName'] = 0,

	},

	[157] = {
		['sRawName'] = 'item_spirit_vessel',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魂之灵瓮',
		['sEnName'] = 0,

	},

	[158] = {
		['sRawName'] = 'item_blight_stone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '枯萎之石',
		['sEnName'] = 0,

	},

	[159] = {
		['sRawName'] = 'item_hurricane_pike',
		['sShortName'] = 'itemNull',
		['sCnName'] = '飓风长戟',
		['sEnName'] = 0,

	},

	[160] = {
		['sRawName'] = 'item_tome_of_knowledge',
		['sShortName'] = 'itemNull',
		['sCnName'] = '知识之书',
		['sEnName'] = 0,

	},

	[161] = {
		['sRawName'] = 'item_infused_raindrop',
		['sShortName'] = 'itemNull',
		['sCnName'] = '凝魂之露',
		['sEnName'] = 0,

	},

	[162] = {
		['sRawName'] = 'item_wind_lace',
		['sShortName'] = 'itemNull',
		['sCnName'] = '风灵之纹',
		['sEnName'] = 0,

	},

	[163] = {
		['sRawName'] = 'item_refresher_shard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '刷新球碎片',
		['sEnName'] = 0,

	},

	[164] = {
		['sRawName'] = 'item_cheese',
		['sShortName'] = 'itemNull',
		['sCnName'] = '奶酪',
		['sEnName'] = 0,

	},

	[165] = {
		['sRawName'] = 'item_blitz_knuckles',
		['sShortName'] = 'itemNull',
		['sCnName'] = '闪电指套',
		['sEnName'] = 0,

	},

	[166] = {
		['sRawName'] = 'item_voodoo_mask',
		['sShortName'] = 'itemNull',
		['sCnName'] = '巫毒面具',
		['sEnName'] = 0,

	},

	[167] = {
		['sRawName'] = 'item_aghanims_shard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '阿哈利姆魔晶',
		['sEnName'] = 0,

	},

	[168] = {
		['sRawName'] = 'item_helm_of_the_overlord',
		['sShortName'] = 'itemNull',
		['sCnName'] = '统御头盔',
		['sEnName'] = 0,

	},

	[169] = {
		['sRawName'] = 'item_broken_satanic',
		['sShortName'] = 'itemNull',
		['sCnName'] = '拆疯脸转撒旦',
		['sEnName'] = 0,

	},

	[170] = {
		['sRawName'] = 'item_double_tango',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个树之祭祀',
		['sEnName'] = 0,

	},

	[171] = {
		['sRawName'] = 'item_double_clarity',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个净化药水',
		['sEnName'] = 0,

	},

	[172] = {
		['sRawName'] = 'item_double_flask',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个治疗药膏',
		['sEnName'] = 0,

	},

	[173] = {
		['sRawName'] = 'item_double_enchanted_mango',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个魔法芒果',
		['sEnName'] = 0,

	},

	[174] = {
		['sRawName'] = 'item_double_branches',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个铁树枝干',
		['sEnName'] = 0,

	},

	[175] = {
		['sRawName'] = 'item_double_circlet',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个圆环',
		['sEnName'] = 0,

	},

	[176] = {
		['sRawName'] = 'item_double_slippers',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个敏捷便鞋',
		['sEnName'] = 0,

	},

	[177] = {
		['sRawName'] = 'item_double_mantle',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个智力斗篷',
		['sEnName'] = 0,

	},

	[178] = {
		['sRawName'] = 'item_double_gauntlets',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个力量手套',
		['sEnName'] = 0,

	},

	[179] = {
		['sRawName'] = 'item_double_wraith_band',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个怨灵系带',
		['sEnName'] = 0,

	},

	[180] = {
		['sRawName'] = 'item_double_null_talisman',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个空灵挂件',
		['sEnName'] = 0,

	},

	[181] = {
		['sRawName'] = 'item_double_bracer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个护腕',
		['sEnName'] = 0,

	},

	[182] = {
		['sRawName'] = 'item_double_crown',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个王冠',
		['sEnName'] = 0,

	},

	[183] = {
		['sRawName'] = 'item_keen_optic',
		['sShortName'] = 'itemNull',
		['sCnName'] = '基恩镜片',
		['sEnName'] = 0,

	},

	[184] = {
		['sRawName'] = 'item_poor_mans_shield',
		['sShortName'] = 'itemNull',
		['sCnName'] = '穷鬼盾',
		['sEnName'] = 0,

	},


	[185] = {
		['sRawName'] = 'item_iron_talon',
		['sShortName'] = 'itemNull',
		['sCnName'] = '寒铁钢爪',
		['sEnName'] = 0,

	},

	[186] = {
		['sRawName'] = 'item_ironwood_tree',
		['sShortName'] = 'itemNull',
		['sCnName'] = '铁树之木',
		['sEnName'] = 0,

	},

	[187] = {
		['sRawName'] = 'item_royal_jelly',
		['sShortName'] = 'itemNull',
		['sCnName'] = '蜂王浆',
		['sEnName'] = 0,

	},

	[188] = {
		['sRawName'] = 'item_mango_tree',
		['sShortName'] = 'itemNull',
		['sCnName'] = '芒果树',
		['sEnName'] = 0,

	},

	[189] = {
		['sRawName'] = 'item_ocean_heart',
		['sShortName'] = 'itemNull',
		['sCnName'] = '海洋之心',
		['sEnName'] = 0,

	},

	[190] = {
		['sRawName'] = 'item_broom_handle',
		['sShortName'] = 'itemNull',
		['sCnName'] = '扫帚柄',
		['sEnName'] = 0,

	},


	[191] = {
		['sRawName'] = 'item_trusty_shovel',
		['sShortName'] = 'itemNull',
		['sCnName'] = '可靠铁铲',
		['sEnName'] = 0,

	},

	[192] = {
		['sRawName'] = 'item_faded_broach',
		['sShortName'] = 'itemNull',
		['sCnName'] = '暗淡胸针',
		['sEnName'] = 0,

	},

	[193] = {
		['sRawName'] = 'item_arcane_ring',
		['sShortName'] = 'itemNull',
		['sCnName'] = '奥术指环',
		['sEnName'] = 0,

	},

	[194] = {
		['sRawName'] = 'item_grove_bow',
		['sShortName'] = 'itemNull',
		['sCnName'] = '林野长弓',
		['sEnName'] = 0,

	},

	[195] = {
		['sRawName'] = 'item_vampire_fangs',
		['sShortName'] = 'itemNull',
		['sCnName'] = '吸血鬼獠牙',
		['sEnName'] = 0,

	},

	[196] = {
		['sRawName'] = 'item_ring_of_aquila',
		['sShortName'] = 'itemNull',
		['sCnName'] = '天鹰之戒',
		['sEnName'] = 0,

	},


	[197] = {
		['sRawName'] = 'item_pupils_gift',
		['sShortName'] = 'itemNull',
		['sCnName'] = '学徒之礼',
		['sEnName'] = 0,

	},

	[198] = {
		['sRawName'] = 'item_imp_claw',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔童之爪',
		['sEnName'] = 0,

	},

	[199] = {
		['sRawName'] = 'item_philosophers_stone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '贤者石',
		['sEnName'] = 0,

	},

	[200] = {
		['sRawName'] = 'item_nether_shawl',
		['sShortName'] = 'itemNull',
		['sCnName'] = '幽冥披巾',
		['sEnName'] = 0,

	},

	[201] = {
		['sRawName'] = 'item_dragon_scale',
		['sShortName'] = 'itemNull',
		['sCnName'] = '炎龙之鳞',
		['sEnName'] = 0,

	},

	[202] = {
		['sRawName'] = 'item_essence_ring',
		['sShortName'] = 'itemNull',
		['sCnName'] = '精华指环',
		['sEnName'] = 0,

	},


	[203] = {
		['sRawName'] = 'item_vambrace',
		['sShortName'] = 'itemNull',
		['sCnName'] = '臂甲',
		['sEnName'] = 0,

	},

	[204] = {
		['sRawName'] = 'item_clumsy_net',
		['sShortName'] = 'itemNull',
		['sCnName'] = '笨拙渔网',
		['sEnName'] = 0,

	},

	[205] = {
		['sRawName'] = 'item_repair_kit',
		['sShortName'] = 'itemNull',
		['sCnName'] = '维修器具',
		['sEnName'] = 0,

	},

	[206] = {
		['sRawName'] = 'item_craggy_coat',
		['sShortName'] = 'itemNull',
		['sCnName'] = '崎岖外衣',
		['sEnName'] = 0,

	},

	[207] = {
		['sRawName'] = 'item_greater_faerie_fire',
		['sShortName'] = 'itemNull',
		['sCnName'] = '高级仙灵之火',
		['sEnName'] = 0,

	},

	[208] = {
		['sRawName'] = 'item_quickening_charm',
		['sShortName'] = 'itemNull',
		['sCnName'] = '加速护符',
		['sEnName'] = 0,

	},


	[209] = {
		['sRawName'] = 'item_mind_breaker',
		['sShortName'] = 'itemNull',
		['sCnName'] = '智灭',
		['sEnName'] = 0,

	},

	[210] = {
		['sRawName'] = 'item_spider_legs',
		['sShortName'] = 'itemNull',
		['sCnName'] = '网虫腿',
		['sEnName'] = 0,

	},

	[211] = {
		['sRawName'] = 'item_enchanted_quiver',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔力箭袋',
		['sEnName'] = 0,

	},

	[212] = {
		['sRawName'] = 'item_paladin_sword',
		['sShortName'] = 'itemNull',
		['sCnName'] = '骑士剑',
		['sEnName'] = 0,

	},

	[213] = {
		['sRawName'] = 'item_orb_of_destruction',
		['sShortName'] = 'itemNull',
		['sCnName'] = '毁灭灵球',
		['sEnName'] = 0,

	},

	[214] = {
		['sRawName'] = 'item_titan_sliver',
		['sShortName'] = 'itemNull',
		['sCnName'] = '巨神残铁',
		['sEnName'] = 0,

	},


	[215] = {
		['sRawName'] = 'item_witless_shako',
		['sShortName'] = 'itemNull',
		['sCnName'] = '无知小帽',
		['sEnName'] = 0,

	},

	[216] = {
		['sRawName'] = 'item_timeless_relic',
		['sShortName'] = 'itemNull',
		['sCnName'] = '永恒遗物',
		['sEnName'] = 0,

	},

	[217] = {
		['sRawName'] = 'item_spell_prism',
		['sShortName'] = 'itemNull',
		['sCnName'] = '法术棱镜',
		['sEnName'] = 0,

	},

	[218] = {
		['sRawName'] = 'item_princes_knife',
		['sShortName'] = 'itemNull',
		['sCnName'] = '亲王短刀',
		['sEnName'] = 0,

	},

	[219] = {
		['sRawName'] = 'item_flicker',
		['sShortName'] = 'itemNull',
		['sCnName'] = '闪灵',
		['sEnName'] = 0,

	},

	[220] = {
		['sRawName'] = 'item_spy_gadget',
		['sShortName'] = 'itemNull',
		['sCnName'] = '望远镜',
		['sEnName'] = 0,

	},


	[221] = {
		['sRawName'] = 'item_ninja_gear',
		['sShortName'] = 'itemNull',
		['sCnName'] = '忍者用具',
		['sEnName'] = 0,

	},

	[222] = {
		['sRawName'] = 'item_illusionsts_cape',
		['sShortName'] = 'itemNull',
		['sCnName'] = '幻术师披风',
		['sEnName'] = 0,

	},

	[223] = {
		['sRawName'] = 'item_havoc_hammer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '浩劫巨锤',
		['sEnName'] = 0,

	},

	[224] = {
		['sRawName'] = 'item_panic_button',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔力明灯',
		['sEnName'] = 0,

	},

	[225] = {
		['sRawName'] = 'item_the_leveller',
		['sShortName'] = 'itemNull',
		['sCnName'] = '平世剑',
		['sEnName'] = 0,

	},

	[226] = {
		['sRawName'] = 'item_minotaur_horn',
		['sShortName'] = 'itemNull',
		['sCnName'] = '恶牛角',
		['sEnName'] = 0,

	},


	[227] = {
		['sRawName'] = 'item_force_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '原力靴',
		['sEnName'] = 0,

	},

	[228] = {
		['sRawName'] = 'item_desolator_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '寂灭',
		['sEnName'] = 0,

	},

	[229] = {
		['sRawName'] = 'item_seer_stone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '先哲之石',
		['sEnName'] = 0,

	},

	[230] = {
		['sRawName'] = 'item_mirror_shield',
		['sShortName'] = 'itemNull',
		['sCnName'] = '神镜盾',
		['sEnName'] = 0,

	},

	[230] = {
		['sRawName'] = 'item_apex',
		['sShortName'] = 'itemNull',
		['sCnName'] = '极',
		['sEnName'] = 0,

	},

	[232] = {
		['sRawName'] = 'item_ballista',
		['sShortName'] = 'itemNull',
		['sCnName'] = '弩炮',
		['sEnName'] = 0,

	},

	[233] = {
		['sRawName'] = 'item_woodland_striders',
		['sShortName'] = 'itemNull',
		['sCnName'] = '林地神行靴',
		['sEnName'] = 0,

	},

	[234] = {
		['sRawName'] = 'item_trident',
		['sShortName'] = 'itemNull',
		['sCnName'] = '三元重戟',
		['sEnName'] = 0,

	},

	[235] = {
		['sRawName'] = 'item_demonicon',
		['sShortName'] = 'itemNull',
		['sCnName'] = '冥灵书',
		['sEnName'] = 0,

	},

	[236] = {
		['sRawName'] = 'item_fallen_sky',
		['sShortName'] = 'itemNull',
		['sCnName'] = '堕天斧',
		['sEnName'] = 0,

	},

	[237] = {
		['sRawName'] = 'item_pirate_hat',
		['sShortName'] = 'itemNull',
		['sCnName'] = '海盗帽',
		['sEnName'] = 0,

	},

	[238] = {
		['sRawName'] = 'item_ex_machina',
		['sShortName'] = 'itemNull',
		['sCnName'] = '机械之心',
		['sEnName'] = 0,

	},
	
--7.28

	[239] = {
		['sRawName'] = 'item_falcon_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '猎鹰战刃',
		['sEnName'] = 0,

	},
 
	[240] = {
		['sRawName'] = 'item_orb_of_corrosion',
		['sShortName'] = 'itemNull',
		['sCnName'] = '腐蚀之球',
		['sEnName'] = 0,

	},
 
	[241] = {
		['sRawName'] = 'item_witch_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '巫师之刃',
		['sEnName'] = 0,

	},
 
	[242] = {
		['sRawName'] = 'item_gungir',
		['sShortName'] = 'itemNull',
		['sCnName'] = '缚灵索',
		['sEnName'] = 0,

	},
 
	[243] = {
		['sRawName'] = 'item_mage_slayer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '法师克星',
		['sEnName'] = 0,

	},
 
	[244] = {
		['sRawName'] = 'item_eternal_shroud',
		['sShortName'] = 'itemNull',
		['sCnName'] = '永世法衣',
		['sEnName'] = 0,

	},
 
	[245] = {
		['sRawName'] = 'item_overwhelming_blink',
		['sShortName'] = 'itemNull',
		['sCnName'] = '盛势闪光',
		['sEnName'] = 0,

	},
 
	[246] = {
		['sRawName'] = 'item_swift_blink',
		['sShortName'] = 'itemNull',
		['sCnName'] = '迅疾闪光',
		['sEnName'] = 0,

	},
 
	[247] = {
		['sRawName'] = 'item_arcane_blink',
		['sShortName'] = 'itemNull',
		['sCnName'] = '秘奥闪光',
		['sEnName'] = 0,

	},
 
    --中立物品
	[248] = {
		['sRawName'] = 'item_mysterious_hat',
		['sShortName'] = 'itemNull',
		['sCnName'] = '仙灵饰品',
		['sEnName'] = 0,

	},
 
	[249] = {
		['sRawName'] = 'item_chipped_vest',
		['sShortName'] = 'itemNull',
		['sCnName'] = '碎裂背心',
		['sEnName'] = 0,

	},
 
	[250] = {
		['sRawName'] = 'item_possessed_mask',
		['sShortName'] = 'itemNull',
		['sCnName'] = '附魂面具',
		['sEnName'] = 0,

	},
 
	[251] = {
		['sRawName'] = 'item_quicksilver_amulet',
		['sShortName'] = 'itemNull',
		['sCnName'] = '银闪护符',
		['sEnName'] = 0,

	},
 
	[252] = {
		['sRawName'] = 'item_bullwhip',
		['sShortName'] = 'itemNull',
		['sCnName'] = '凌厉长靴',
		['sEnName'] = 0,

	},
 
	[253] = {
		['sRawName'] = 'item_elven_tunic',
		['sShortName'] = 'itemNull',
		['sCnName'] = '精灵外衣',
		['sEnName'] = 0,

	},
 
	[254] = {
		['sRawName'] = 'item_cloak_of_flames',
		['sShortName'] = 'itemNull',
		['sCnName'] = '火焰斗篷',
		['sEnName'] = 0,

	},
 
	[255] = {
		['sRawName'] = 'item_ceremonial_robe',
		['sShortName'] = 'itemNull',
		['sCnName'] = '祭礼长袍',
		['sEnName'] = 0,

	},
 
	[256] = {
		['sRawName'] = 'item_psychic_headband',
		['sShortName'] = 'itemNull',
		['sCnName'] = '通灵头带',
		['sEnName'] = 0,

	},
 
	[257] = {
		['sRawName'] = 'item_penta_edged_sword',
		['sShortName'] = 'itemNull',
		['sCnName'] = '五锋长剑',
		['sEnName'] = 0,

	},
 
	[258] = {
		['sRawName'] = 'item_stormcrafter',
		['sShortName'] = 'itemNull',
		['sCnName'] = '风暴宝器',
		['sEnName'] = 0,

	},
 
	[259] = {
		['sRawName'] = 'item_trickster_cloak',
		['sShortName'] = 'itemNull',
		['sCnName'] = '欺诈师斗篷',
		['sEnName'] = 0,

	},
 
	[260] = {
		['sRawName'] = 'item_giants_ring',
		['sShortName'] = 'itemNull',
		['sCnName'] = '巨人之戒',
		['sEnName'] = 0,

	},
 
	[261] = {
		['sRawName'] = 'item_book_of_shadows',
		['sShortName'] = 'itemNull',
		['sCnName'] = '暗影邪典',
		['sEnName'] = 0,

	},
	
	[262] = {
		['sRawName'] = 'item_wind_waker',
		['sShortName'] = 'itemNull',
		['sCnName'] = '风之杖',
		['sEnName'] = 0,

	},
	
--7.30	中立物品
	[263] = {
		['sRawName'] = 'item_unstable_wand',
		['sShortName'] = 'itemNull',
		['sCnName'] = '豚杆',
		['sEnName'] = 0,

	},

	[264] = {
		['sRawName'] = 'item_pogo_stick',
		['sShortName'] = 'itemNull',
		['sCnName'] = '杂技玩具',
		['sEnName'] = 0,

	},

	[265] = {
		['sRawName'] = 'item_misericorde',
		['sShortName'] = 'itemNull',
		['sCnName'] = '飞贼之刃',
		['sEnName'] = 0,

	},

	[266] = {
		['sRawName'] = 'item_paintball',
		['sShortName'] = 'itemNull',
		['sCnName'] = '仙灵榴弹',
		['sEnName'] = 0,

	},

	[267] = {
		['sRawName'] = 'item_black_powder_bag',
		['sShortName'] = 'itemNull',
		['sCnName'] = '炸雷服',
		['sEnName'] = 0,

	},

	[268] = {
		['sRawName'] = 'item_ascetic_cap',
		['sShortName'] = 'itemNull',
		['sCnName'] = '简普短帽',
		['sEnName'] = 0,

	},

	[269] = {
		['sRawName'] = 'item_heavy_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '行巫之祸',
		['sEnName'] = 0,

	},

	[270] = {
		['sRawName'] = 'item_force_field',
		['sShortName'] = 'itemNull',
		['sCnName'] = '秘术师铠甲',
		['sEnName'] = 0,

	},
	
--7.31 新物品
	[271] = {
		['sRawName'] = 'item_revenants_brooch',
		['sShortName'] = 'itemNull',
		['sCnName'] = '亡魂胸针',
		['sEnName'] = 0,

	},

	[272] = {
		['sRawName'] = 'item_boots_of_bearing',
		['sShortName'] = 'itemNull',
		['sCnName'] = '宽容之靴',
		['sEnName'] = 0,

	},

	[273] = {
		['sRawName'] = 'item_wraith_pact',
		['sShortName'] = 'itemNull',
		['sCnName'] = '怨灵之契',
		['sEnName'] = 0,

	},	
	
--内部自定义新物品
	[274] = {
		['sRawName'] = 'item_new_1',
		['sShortName'] = 'itemNull',
		['sCnName'] = '自定义物品1',
		['sEnName'] = 0,

	},

	[275] = {
		['sRawName'] = 'item_new_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '自定义物品2',
		['sEnName'] = 0,

	},

	[276] = {
		['sRawName'] = 'item_new_3',
		['sShortName'] = 'itemNull',
		['sCnName'] = '自定义物品3',
		['sEnName'] = 0,

	},

	[277] = {
		['sRawName'] = 'item_new_4',
		['sShortName'] = 'itemNull',
		['sCnName'] = '自定义物品4',
		['sEnName'] = 0,

	},

	[278] = {
		['sRawName'] = 'item_new_5',
		['sShortName'] = 'itemNull',
		['sCnName'] = '自定义物品5',
		['sEnName'] = 0,

	},

	[279] = {
		['sRawName'] = 'item_new_6',
		['sShortName'] = 'itemNull',
		['sCnName'] = '自定义物品6',
		['sEnName'] = 0,

	},
	
}


local sChineseItemNameIndexList = {}
for _, v in pairs( Chat['tItemNameList'] )
do
	local sRawItemName = v['sRawName']
	local sCnItemName = v['sCnName']
	sChineseItemNameIndexList[sRawItemName] = sCnItemName
end


Chat['tHeroNameList'] = {

	--000
	['sRandomHero'] = {
		['sNormName'] = '随机',
		['sShortName'] = 'random',
		['sCnName'] = '随机英雄',
		['sEnName'] = 0,

	},

	--001
	['npc_dota_hero_abaddon'] = {
		['sNormName'] = '死骑',
		['sShortName'] = 'loa',
		['sCnName'] = '亚巴顿',
		['sEnName'] = 0,

	},

	--002
	['npc_dota_hero_alchemist'] = {
		['sNormName'] = '炼金',
		['sShortName'] = 'ga',
		['sCnName'] = '炼金术士',
		['sEnName'] = 0,

	},

	--003
	['npc_dota_hero_axe'] = {
		['sNormName'] = '斧王',
		['sShortName'] = 'axe',
		['sCnName'] = '斧王',
		['sEnName'] = 0,

	},

	--004
	['npc_dota_hero_beastmaster'] = {
		['sNormName'] = '兽王',
		['sShortName'] = 'bm',
		['sCnName'] = '兽王',
		['sEnName'] = 0,

	},

	--005
	['npc_dota_hero_brewmaster'] = {
		['sNormName'] = '熊猫',
		['sShortName'] = 'panda',
		['sCnName'] = '酒仙',
		['sEnName'] = 0,

	},

	--006
	['npc_dota_hero_bristleback'] = {
		['sNormName'] = '钢背',
		['sShortName'] = 'bb',
		['sCnName'] = '钢背兽',
		['sEnName'] = 0,

	},

	--007
	['npc_dota_hero_centaur'] = {
		['sNormName'] = '人马',
		['sShortName'] = 'cent',
		['sCnName'] = '半人马战行者',
		['sEnName'] = 0,

	},

	--008
	['npc_dota_hero_chaos_knight'] = {
		['sNormName'] = '混沌',
		['sShortName'] = 'ck',
		['sCnName'] = '混沌骑士',
		['sEnName'] = 0,

	},

	--009
	['npc_dota_hero_rattletrap'] = {
		['sNormName'] = '发条',
		['sShortName'] = 'cg',
		['sCnName'] = '发条技师',
		['sEnName'] = 0,

	},

	--010
	['npc_dota_hero_doom_bringer'] = {
		['sNormName'] = '末日',
		['sShortName'] = 'doom',
		['sCnName'] = '末日使者',
		['sEnName'] = 0,

	},

	--011
	['npc_dota_hero_dragon_knight'] = {
		['sNormName'] = '龙骑',
		['sShortName'] = 'dk',
		['sCnName'] = '龙骑士',
		['sEnName'] = 0,

	},

	--012
	['npc_dota_hero_earth_spirit'] = {
		['sNormName'] = '土猫',
		['sShortName'] = 'earthspirit',
		['sCnName'] = '大地之灵',
		['sEnName'] = 0,

	},

	--013
	['npc_dota_hero_earthshaker'] = {
		['sNormName'] = '小牛',
		['sShortName'] = 'es',
		['sCnName'] = '撼地者',
		['sEnName'] = 0,

	},

	--014
	['npc_dota_hero_elder_titan'] = {
		['sNormName'] = '大牛',
		['sShortName'] = 'et',
		['sCnName'] = '上古巨神',
		['sEnName'] = 0,

	},

	--015
	['npc_dota_hero_grimstroke'] = {
		['sNormName'] = '笔仙',
		['sShortName'] = 'grimstroke',
		['sCnName'] = '天涯墨客',
		['sEnName'] = 0,

	},

	--016
	['npc_dota_hero_huskar'] = {
		['sNormName'] = '神灵',
		['sShortName'] = 'hus',
		['sCnName'] = '哈斯卡',
		['sEnName'] = 0,

	},

	--017
	['npc_dota_hero_wisp'] = {
		['sNormName'] = '小精灵',
		['sShortName'] = 'wisp',
		['sCnName'] = '艾欧',
		['sEnName'] = 0,

	},

	--018
	['npc_dota_hero_kunkka'] = {
		['sNormName'] = '船长',
		['sShortName'] = 'coco',
		['sCnName'] = '昆卡',
		['sEnName'] = 0,

	},

	--019
	['npc_dota_hero_legion_commander'] = {
		['sNormName'] = '军团',
		['sShortName'] = 'legion',
		['sCnName'] = '军团指挥官',
		['sEnName'] = 0,

	},

	--020
	['npc_dota_hero_life_stealer'] = {
		['sNormName'] = '小狗',
		['sShortName'] = 'naix',
		['sCnName'] = '噬魂鬼',
		['sEnName'] = 0,

	},

	--021
	['npc_dota_hero_lycan'] = {
		['sNormName'] = '狼人',
		['sShortName'] = 'lyc',
		['sCnName'] = '狼人',
		['sEnName'] = 0,

	},

	--022
	['npc_dota_hero_magnataur'] = {
		['sNormName'] = '猛犸',
		['sShortName'] = 'mag',
		['sCnName'] = '马格纳斯',
		['sEnName'] = 0,

	},

	--023
	['npc_dota_hero_night_stalker'] = {
		['sNormName'] = '夜魔',
		['sShortName'] = 'ns',
		['sCnName'] = '暗夜魔王',
		['sEnName'] = 0,

	},

	--024
	['npc_dota_hero_omniknight'] = {
		['sNormName'] = '全能',
		['sShortName'] = 'ok',
		['sCnName'] = '全能骑士',
		['sEnName'] = 0,

	},

	--025
	['npc_dota_hero_phoenix'] = {
		['sNormName'] = '凤凰',
		['sShortName'] = 'pho',
		['sCnName'] = '凤凰',
		['sEnName'] = 0,

	},

	--026
	['npc_dota_hero_pudge'] = {
		['sNormName'] = '屠夫',
		['sShortName'] = 'pudge',
		['sCnName'] = '帕吉',
		['sEnName'] = 0,

	},

	--027
	['npc_dota_hero_sand_king'] = {
		['sNormName'] = '沙王',
		['sShortName'] = 'sk',
		['sCnName'] = '沙王',
		['sEnName'] = 0,

	},

	--028
	['npc_dota_hero_slardar'] = {
		['sNormName'] = '大鱼',
		['sShortName'] = 'sg',
		['sCnName'] = '斯拉达',
		['sEnName'] = 0,

	},

	--029
	['npc_dota_hero_spirit_breaker'] = {
		['sNormName'] = '白牛',
		['sShortName'] = 'sb',
		['sCnName'] = '裂魂人',
		['sEnName'] = 0,

	},

	--030
	['npc_dota_hero_sven'] = {
		['sNormName'] = '流浪',
		['sShortName'] = 'sv',
		['sCnName'] = '斯温',
		['sEnName'] = 0,

	},

	--031
	['npc_dota_hero_tidehunter'] = {
		['sNormName'] = '潮汐',
		['sShortName'] = 'th',
		['sCnName'] = '潮汐猎人',
		['sEnName'] = 0,

	},

	--032
	['npc_dota_hero_shredder'] = {
		['sNormName'] = '伐木机',
		['sShortName'] = 'gs',
		['sCnName'] = '伐木机',
		['sEnName'] = 0,

	},

	--033
	['npc_dota_hero_tiny'] = {
		['sNormName'] = '山岭',
		['sShortName'] = 'tiny',
		['sCnName'] = '小小',
		['sEnName'] = 0,

	},

	--034
	['npc_dota_hero_treant'] = {
		['sNormName'] = '大树',
		['sShortName'] = 'tp',
		['sCnName'] = '树精卫士',
		['sEnName'] = 0,

	},

	--035
	['npc_dota_hero_tusk'] = {
		['sNormName'] = '海民',
		['sShortName'] = 'tusk',
		['sCnName'] = '巨牙海民',
		['sEnName'] = 0,

	},

	--036
	['npc_dota_hero_abyssal_underlord'] = {
		['sNormName'] = '大屁股',
		['sShortName'] = 'au',
		['sCnName'] = '孽主',
		['sEnName'] = 0,

	},

	--037
	['npc_dota_hero_undying'] = {
		['sNormName'] = '尸王',
		['sShortName'] = 'ud',
		['sCnName'] = '不朽尸王',
		['sEnName'] = 0,

	},

	--038
	['npc_dota_hero_skeleton_king'] = {
		['sNormName'] = '骷髅王',
		['sShortName'] = 'snk',
		['sCnName'] = '冥魂大帝',
		['sEnName'] = 0,

	},

	--039
	['npc_dota_hero_antimage'] = {
		['sNormName'] = '敌法',
		['sShortName'] = 'am',
		['sCnName'] = '敌法师',
		['sEnName'] = 0,

	},

	--040
	['npc_dota_hero_arc_warden'] = {
		['sNormName'] = '电 狗',
		['sShortName'] = 'arc',
		['sCnName'] = '天穹守望者',
		['sEnName'] = 0,

	},

	--041
	['npc_dota_hero_bloodseeker'] = {
		['sNormName'] = '血魔',
		['sShortName'] = 'bs',
		['sCnName'] = '血魔',
		['sEnName'] = 0,

	},

	--042
	['npc_dota_hero_bounty_hunter'] = {
		['sNormName'] = '赏金',
		['sShortName'] = 'bh',
		['sCnName'] = '赏金猎人',
		['sEnName'] = 0,

	},

	--043
	['npc_dota_hero_broodmother'] = {
		['sNormName'] = '蜘蛛',
		['sShortName'] = 'br',
		['sCnName'] = '育母蜘蛛',
		['sEnName'] = 0,

	},

	--044
	['npc_dota_hero_clinkz'] = {
		['sNormName'] = '骨弓',
		['sShortName'] = 'bone',
		['sCnName'] = '克林克兹',
		['sEnName'] = 0,

	},

	--045
	['npc_dota_hero_dark_willow'] = {
		['sNormName'] = '小仙女',
		['sShortName'] = 'dw',
		['sCnName'] = '邪影芳灵',
		['sEnName'] = 0,

	},

	--046
	['npc_dota_hero_drow_ranger'] = {
		['sNormName'] = '小黑',
		['sShortName'] = 'dr',
		['sCnName'] = '卓尔游侠',
		['sEnName'] = 0,

	},

	--047
	['npc_dota_hero_ember_spirit'] = {
		['sNormName'] = '火猫',
		['sShortName'] = 'ember',
		['sCnName'] = '灰烬之灵',
		['sEnName'] = 0,

	},

	--048
	['npc_dota_hero_faceless_void'] = {
		['sNormName'] = '虚空',
		['sShortName'] = 'fv',
		['sCnName'] = '虚空假面',
		['sEnName'] = 0,

	},

	--049
	['npc_dota_hero_gyrocopter'] = {
		['sNormName'] = '飞机',
		['sShortName'] = 'av',
		['sCnName'] = '矮人直升机',
		['sEnName'] = 0,

	},

	--050
	['npc_dota_hero_juggernaut'] = {
		['sNormName'] = '剑圣',
		['sShortName'] = 'jugg',
		['sCnName'] = '主宰',
		['sEnName'] = 0,

	},

	--051
	['npc_dota_hero_lone_druid'] = {
		['sNormName'] = '熊德',
		['sShortName'] = 'ld',
		['sCnName'] = '德鲁伊',
		['sEnName'] = 0,

	},

	--052
	['npc_dota_hero_luna'] = {
		['sNormName'] = '月骑',
		['sShortName'] = 'luna',
		['sCnName'] = '露娜',
		['sEnName'] = 0,

	},

	--053
	['npc_dota_hero_medusa'] = {
		['sNormName'] = '一姐',
		['sShortName'] = 'med',
		['sCnName'] = '美杜莎',
		['sEnName'] = 0,

	},

	--054
	['npc_dota_hero_meepo'] = {
		['sNormName'] = '狗头',
		['sShortName'] = 'meepo',
		['sCnName'] = '米波',
		['sEnName'] = 0,

	},

	--055
	['npc_dota_hero_mirana'] = {
		['sNormName'] = '白虎',
		['sShortName'] = 'pom',
		['sCnName'] = '米拉娜',
		['sEnName'] = 0,

	},

	--056
	['npc_dota_hero_monkey_king'] = {
		['sNormName'] = '大圣',
		['sShortName'] = 'monkey',
		['sCnName'] = '齐天大圣',
		['sEnName'] = 0,

	},

	--057
	['npc_dota_hero_morphling'] = {
		['sNormName'] = '水人',
		['sShortName'] = 'mor',
		['sCnName'] = '变体精灵',
		['sEnName'] = 0,

	},

	--058
	['npc_dota_hero_naga_siren'] = {
		['sNormName'] = '小娜迦',
		['sShortName'] = 'naga',
		['sCnName'] = '娜迦海妖',
		['sEnName'] = 0,

	},

	--059
	['npc_dota_hero_nyx_assassin'] = {
		['sNormName'] = '小强',
		['sShortName'] = 'na',
		['sCnName'] = '司夜刺客',
		['sEnName'] = 0,

	},

	--060
	['npc_dota_hero_phantom_assassin'] = {
		['sNormName'] = '幻刺',
		['sShortName'] = 'pa',
		['sCnName'] = '幻影刺客',
		['sEnName'] = 0,

	},

	--061
	['npc_dota_hero_phantom_lancer'] = {
		['sNormName'] = '猴子',
		['sShortName'] = 'pl',
		['sCnName'] = '幻影长矛手',
		['sEnName'] = 0,

	},

	--062
	['npc_dota_hero_razor'] = {
		['sNormName'] = '电棍',
		['sShortName'] = 'razor',
		['sCnName'] = '剃刀',
		['sEnName'] = 0,

	},

	--063
	['npc_dota_hero_riki'] = {
		['sNormName'] = '隐刺',
		['sShortName'] = 'sa',
		['sCnName'] = '力丸',
		['sEnName'] = 0,

	},

	--064
	['npc_dota_hero_nevermore'] = {
		['sNormName'] = '影魔',
		['sShortName'] = 'sf',
		['sCnName'] = '影魔',
		['sEnName'] = 0,

	},

	--065
	['npc_dota_hero_slark'] = {
		['sNormName'] = '小鱼',
		['sShortName'] = 'nc',
		['sCnName'] = '斯拉克',
		['sEnName'] = 0,

	},

	--066
	['npc_dota_hero_sniper'] = {
		['sNormName'] = '火枪',
		['sShortName'] = 'sniper',
		['sCnName'] = '狙击手',
		['sEnName'] = 0,

	},

	--067
	['npc_dota_hero_spectre'] = {
		['sNormName'] = '幽鬼',
		['sShortName'] = 'spe',
		['sCnName'] = '幽鬼',
		['sEnName'] = 0,

	},

	--068
	['npc_dota_hero_templar_assassin'] = {
		['sNormName'] = '圣堂',
		['sShortName'] = 'ta',
		['sCnName'] = '圣堂刺客',
		['sEnName'] = 0,

	},

	--069
	['npc_dota_hero_terrorblade'] = {
		['sNormName'] = '魂守',
		['sShortName'] = 'tb',
		['sCnName'] = '恐怖利刃',
		['sEnName'] = 0,

	},

	--070
	['npc_dota_hero_troll_warlord'] = {
		['sNormName'] = '巨魔',
		['sShortName'] = 'tw',
		['sCnName'] = '巨魔战将',
		['sEnName'] = 0,

	},

	--071
	['npc_dota_hero_ursa'] = {
		['sNormName'] = '拍拍',
		['sShortName'] = 'ursa',
		['sCnName'] = '熊战士',
		['sEnName'] = 0,

	},

	--072
	['npc_dota_hero_vengefulspirit'] = {
		['sNormName'] = 'VS',
		['sShortName'] = 'vs',
		['sCnName'] = '复仇之魂',
		['sEnName'] = 0,

	},

	--073
	['npc_dota_hero_venomancer'] = {
		['sNormName'] = '剧毒',
		['sShortName'] = 'veno',
		['sCnName'] = '剧毒术士',
		['sEnName'] = 0,

	},

	--074
	['npc_dota_hero_viper'] = {
		['sNormName'] = '毒龙',
		['sShortName'] = 'vip',
		['sCnName'] = '冥界亚龙',
		['sEnName'] = 0,

	},

	--075
	['npc_dota_hero_weaver'] = {
		['sNormName'] = '蚂蚁',
		['sShortName'] = 'nw',
		['sCnName'] = '编织者',
		['sEnName'] = 0,

	},

	--076
	['npc_dota_hero_ancient_apparition'] = {
		['sNormName'] = '冰魂',
		['sShortName'] = 'aa',
		['sCnName'] = '远古冰魄',
		['sEnName'] = 0,

	},

	--077
	['npc_dota_hero_bane'] = {
		['sNormName'] = '祸乱',
		['sShortName'] = 'bane',
		['sCnName'] = '祸乱之源',
		['sEnName'] = 0,

	},

	--078
	['npc_dota_hero_batrider'] = {
		['sNormName'] = '蝙蝠',
		['sShortName'] = 'bat',
		['sCnName'] = '蝙蝠骑士',
		['sEnName'] = 0,

	},

	--079
	['npc_dota_hero_chen'] = {
		['sNormName'] = '陈',
		['sShortName'] = 'chen',
		['sCnName'] = '陈',
		['sEnName'] = 0,

	},

	--080
	['npc_dota_hero_crystal_maiden'] = {
		['sNormName'] = '冰女',
		['sShortName'] = 'cm',
		['sCnName'] = '水晶室女',
		['sEnName'] = 0,

	},

	--081
	['npc_dota_hero_dark_seer'] = {
		['sNormName'] = '兔子',
		['sShortName'] = 'ds',
		['sCnName'] = '黑暗贤者',
		['sEnName'] = 0,

	},

	--082
	['npc_dota_hero_dazzle'] = {
		['sNormName'] = '暗牧',
		['sShortName'] = 'sp',
		['sCnName'] = '戴泽',
		['sEnName'] = 0,

	},

	--083
	['npc_dota_hero_death_prophet'] = {
		['sNormName'] = 'DP',
		['sShortName'] = 'DP',
		['sCnName'] = '死亡先知',
		['sEnName'] = 0,

	},

	--084
	['npc_dota_hero_disruptor'] = {
		['sNormName'] = '萨尔',
		['sShortName'] = 'thrall',
		['sCnName'] = '干扰者',
		['sEnName'] = 0,

	},

	--085
	['npc_dota_hero_enchantress'] = {
		['sNormName'] = '小鹿',
		['sShortName'] = 'eh',
		['sCnName'] = '魅惑魔女',
		['sEnName'] = 0,

	},

	--086
	['npc_dota_hero_enigma'] = {
		['sNormName'] = '谜团',
		['sShortName'] = 'em',
		['sCnName'] = '谜团',
		['sEnName'] = 0,

	},

	--087
	['npc_dota_hero_invoker'] = {
		['sNormName'] = '卡尔',
		['sShortName'] = 'invoker',
		['sCnName'] = '祈求者',
		['sEnName'] = 0,

	},

	--088
	['npc_dota_hero_jakiro'] = {
		['sNormName'] = '双头龙',
		['sShortName'] = 'thd',
		['sCnName'] = '杰奇洛',
		['sEnName'] = 0,

	},

	--089
	['npc_dota_hero_keeper_of_the_light'] = {
		['sNormName'] = '光法',
		['sShortName'] = 'kotl',
		['sCnName'] = '光之守卫',
		['sEnName'] = 0,

	},

	--090
	['npc_dota_hero_leshrac'] = {
		['sNormName'] = '老鹿',
		['sShortName'] = 'TS',
		['sCnName'] = '拉席克',
		['sEnName'] = 0,

	},

	--091
	['npc_dota_hero_lich'] = {
		['sNormName'] = '巫妖',
		['sShortName'] = 'lich',
		['sCnName'] = '巫妖',
		['sEnName'] = 0,

	},

	--092
	['npc_dota_hero_lina'] = {
		['sNormName'] = '火女',
		['sShortName'] = 'lina',
		['sCnName'] = '莉娜',
		['sEnName'] = 0,

	},

	--093
	['npc_dota_hero_lion'] = {
		['sNormName'] = '莱恩',
		['sShortName'] = 'lion',
		['sCnName'] = '莱恩',
		['sEnName'] = 0,

	},

	--094
	['npc_dota_hero_furion'] = {
		['sNormName'] = '先知',
		['sShortName'] = 'fur',
		['sCnName'] = '先知',
		['sEnName'] = 0,

	},

	--095
	['npc_dota_hero_necrolyte'] = {
		['sNormName'] = '死灵法',
		['sShortName'] = 'nec',
		['sCnName'] = '瘟疫法师',
		['sEnName'] = 0,

	},

	--096
	['npc_dota_hero_ogre_magi'] = {
		['sNormName'] = '蓝胖',
		['sShortName'] = 'om',
		['sCnName'] = '食人魔魔法师',
		['sEnName'] = 0,

	},

	--097
	['npc_dota_hero_oracle'] = {
		['sNormName'] = '神谕',
		['sShortName'] = 'oracle',
		['sCnName'] = '神谕者',
		['sEnName'] = 0,

	},

	--098
	['npc_dota_hero_obsidian_destroyer'] = {
		['sNormName'] = '黑鸟',
		['sShortName'] = 'od',
		['sCnName'] = '殁境神蚀者',
		['sEnName'] = 0,

	},

	--099
	['npc_dota_hero_pangolier'] = {
		['sNormName'] = '滚滚',
		['sShortName'] = 'pangolier',
		['sCnName'] = '石鳞剑士',
		['sEnName'] = 0,

	},

	-- 100
	['npc_dota_hero_puck'] = {
		['sNormName'] = '精灵龙',
		['sShortName'] = 'puck',
		['sCnName'] = '帕克',
		['sEnName'] = 0,

	},

	-- 101
	['npc_dota_hero_pugna'] = {
		['sNormName'] = '骨法',
		['sShortName'] = 'pugna',
		['sCnName'] = '帕格纳',
		['sEnName'] = 0,

	},

	-- 102
	['npc_dota_hero_queenofpain'] = {
		['sNormName'] = '女王',
		['sShortName'] = 'qop',
		['sCnName'] = '痛苦女王',
		['sEnName'] = 0,

	},

	-- 103
	['npc_dota_hero_rubick'] = {
		['sNormName'] = '拉比克',
		['sShortName'] = 'rubick',
		['sCnName'] = '拉比克',
		['sEnName'] = 0,

	},

	-- 104
	['npc_dota_hero_shadow_demon'] = {
		['sNormName'] = '毒狗',
		['sShortName'] = 'sd',
		['sCnName'] = '暗影恶魔',
		['sEnName'] = 0,

	},

	-- 105
	['npc_dota_hero_shadow_shaman'] = {
		['sNormName'] = '小Y',
		['sShortName'] = 'ss',
		['sCnName'] = '暗影萨满',
		['sEnName'] = 0,

	},

	-- 106
	['npc_dota_hero_silencer'] = {
		['sNormName'] = '沉默',
		['sShortName'] = 'sil',
		['sCnName'] = '沉默术士',
		['sEnName'] = 0,

	},

	-- 107
	['npc_dota_hero_skywrath_mage'] = {
		['sNormName'] = '天怒',
		['sShortName'] = 'sm',
		['sCnName'] = '天怒法师',
		['sEnName'] = 0,

	},

	-- 108
	['npc_dota_hero_storm_spirit'] = {
		['sNormName'] = '蓝猫',
		['sShortName'] = 'st',
		['sCnName'] = '风暴之灵',
		['sEnName'] = 0,

	},

	-- 109
	['npc_dota_hero_techies'] = {
		['sNormName'] = '炸弹人',
		['sShortName'] = 'techies',
		['sCnName'] = '工程师',
		['sEnName'] = 0,

	},

	-- 110
	['npc_dota_hero_tinker'] = {
		['sNormName'] = 'TK',
		['sShortName'] = 'tk',
		['sCnName'] = '修补匠',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 2
	},

	-- 111
	['npc_dota_hero_visage'] = {
		['sNormName'] = '死灵龙',
		['sShortName'] = 'vis',
		['sCnName'] = '维萨吉',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 1
	},

	-- 112
	['npc_dota_hero_warlock'] = {
		['sNormName'] = '术士',
		['sShortName'] = 'wlk',
		['sCnName'] = '术士',
		['sEnName'] = 0,

	},

	-- 113
	['npc_dota_hero_windrunner'] = {
		['sNormName'] = '风行',
		['sShortName'] = 'wr',
		['sCnName'] = '风行者',
		['sEnName'] = 0,

	},

	-- 114
	['npc_dota_hero_winter_wyvern'] = {
		['sNormName'] = '冰龙',
		['sShortName'] = 'ww',
		['sCnName'] = '寒冬飞龙',
		['sEnName'] = 0,

	},

	-- 115
	['npc_dota_hero_witch_doctor'] = {
		['sNormName'] = '巫医',
		['sShortName'] = 'wd',
		['sCnName'] = '巫医',
		['sEnName'] = 0,

	},

	-- 116
	['npc_dota_hero_mars'] = {
		['sNormName'] = '玛尔斯',
		['sShortName'] = 'mars',
		['sCnName'] = '玛尔斯',
		['sEnName'] = 0,

	},

	-- 117
	['npc_dota_hero_zuus'] = {
		['sNormName'] = '宙斯',
		['sShortName'] = 'zeus',
		['sCnName'] = '宙斯',
		['sEnName'] = 0,

	},

	-- 118
	['npc_dota_hero_snapfire'] = {
		['sNormName'] = '老奶奶',
		['sShortName'] = 'snapfire',
		['sCnName'] = '电炎绝手',
		['sEnName'] = 0,

	},

	-- 119
	['npc_dota_hero_void_spirit'] = {
		['sNormName'] = '紫猫',
		['sShortName'] = 'void',
		['sCnName'] = '虚无之灵',
		['sEnName'] = 0,

	},
	
	-- 120
	['npc_dota_hero_hoodwink'] = {
		['sNormName'] = '小松鼠',
		['sShortName'] = 'hoodwink',
		['sCnName'] = '森海飞霞',
		['sEnName'] = 0,

	},
	
	-- 121
	['npc_dota_hero_dawnbreaker'] = {
		['sNormName'] = '锤妹',
		['sShortName'] = 'dawnbreaker',
		['sCnName'] = '破晓辰星',
		['sEnName'] = 0,

	},
	
	-- 122
	['npc_dota_hero_marci'] = {
		['sNormName'] = '拳妹',
		['sShortName'] = 'marci',
		['sCnName'] = '玛西',
		['sEnName'] = 0,

	},

	-- 122
	['npc_dota_hero_primal_beast'] = {
		['sNormName'] = '兽',
		['sShortName'] = 'beast',
		['sCnName'] = '獸',
		['sEnName'] = 0,

	},

}


function Chat.GetRawLanguge( sName )

	for _, t in pairs( Chat['tLanguageNameList'] )
	do
		if t['sLocalName'] == sName
		then
			return t['sRawName']
		end
	end

	return 'sCnName'

end


function Chat.SetRawLanguage( sName )

	--sRawLanguage = Chat.GetRawLanguge( sName )

end


function Chat.GetEnName( bot )

	local sHeroName = string.gsub( string.sub( bot:GetUnitName(), 15 ), '_', '' )

	return sHeroName

end


function Chat.GetItemCnName( sRawName )

	return sChineseItemNameIndexList[sRawName] or "未定义:"..sRawName

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


--由本地名获得英雄代码名
function Chat.GetRawHeroName( sName )

	for _, s in pairs( Chat['sAllHeroList'] )
	do
		if sName == Chat['tHeroNameList'][s][sRawLanguage]
		then
			return s
		end
	end

	return 'npc_dota_hero_techies'  --默认的情况, 返回炸弹人

end


--由本地名获得装备代码名
function Chat.GetRawItemName( sName )

	for _, t in pairs( Chat['tItemNameList'] )
	do
		if t[sRawLanguage] == sName
		then
			return t['sRawName']
		end
	end

	return 'item_flask'  --如果是错误物品, 则改为治疗药膏

end


--由本地名获得游戏词汇代码名
function Chat.GetRawGameWord( sName )

	for _, t in pairs( Chat['tGameWordList'] )
	do
		if t[sRawLanguage] == sName
		then
			return t['sRawName']
		end
	end

	return nil  --如果是错误词汇

end


--选人列表
function Chat.GetHeroSelectList( nLocalList )

	local sTargetList = {}

	for i = 1, #nLocalList
    do
		local tempName = Chat.GetRawHeroName( nLocalList[i] )
		sTargetList[#sTargetList + 1] = tempName
	end

	return sTargetList

end


--分路列表
function Chat.GetLaneAssignList( nLocalList )


	local sTargetList = {}

	for i = 1, #nLocalList
    do
		local tempName = Chat.GetRawGameWord( nLocalList[i] )
		sTargetList[#sTargetList + 1] = tempName
	end

	return sTargetList

end


--天赋列表
function Chat.GetTalentBuildList( nLocalList )

	local sTargetList = {}

	for i = 1, #nLocalList
    do
		local rawTalent = Chat.GetRawGameWord( nLocalList[i] )
		if rawTalent == 10
		then
			sTargetList[#sTargetList + 1] = i * 2
		else
			sTargetList[#sTargetList + 1] = i * 2 - 1
		end
	end
	
	for i = 1, #nLocalList
    do
		local rawTalent = Chat.GetRawGameWord( nLocalList[i] )
		if rawTalent ~= 10
		then
			sTargetList[#sTargetList + 1] = i * 2
		else
			sTargetList[#sTargetList + 1] = i * 2 - 1
		end
	end

	return sTargetList

end


--物品构成表
function Chat.GetItemBuildList( nLocalList )

	local sTargetList = {}

	for i = 1, #nLocalList
    do
		local tempName = Chat.GetRawItemName( nLocalList[i] )
		sTargetList[#sTargetList + 1] = tempName
	end

	return sTargetList

end


--本地英雄策略路径名
function Chat.GetHeroDirName( bot )

	local sType = ( GetTeam() == TEAM_RADIANT ) and 'radiant_set' or 'dire_set'

	local sString = Chat['tSpWordList'][sType]

	return sString..Chat.GetLocalName( bot )

end


--本地游戏词语名
function Chat.GetLocalWord( sType )

	local sString = Chat['tSpWordList'][sType]

	return sString

end


function Chat.GetUserKeyDir()

	return Chat['tSpWordList']['key_dir']

end



function Chat.GetRandomHeroPoolDir()

	return Chat['tSpWordList']['hero_pool_dir']

end


function Chat.GetHeroSetDir()

	if GetTeam() == TEAM_RADIANT
	then
		return ( Chat['tSpWordList']['radiant_set'] )..( Chat['tSpWordList']['radiant_lineup'] )
	else
		return ( Chat['tSpWordList']['dire_set'] )..( Chat['tSpWordList']['dire_lineup'] )
	end

end

function Chat.GetRandomLineupFromHeroPool( sLocalHeroPoolList )

	local sLineupList = {}
	local sHeroList = Chat.GetHeroSelectList( sLocalHeroPoolList )
	local nLineupCount = 0
	for i = 1, #sHeroList, 5
	do 
		if i <= #sHeroList
		then
			nLineupCount = nLineupCount + 1
		end
	end	
	
	local nLineupPosition = RandomInt(1, nLineupCount)	
	for i = 1, 5
	do 
		local sHeroName = sHeroList[nLineupPosition * 5 + i - 5]
		if sHeroName == nil	then sHeroName = 'sRandomHero' end
		sLineupList[i] = sHeroName		
	end
	
	return sLineupList

end

local tChatString = require( GetScriptDirectory()..'/FunLib/aba_chat_table' )
local tChatStringIndex = {}

for nChatStringIndex = 1, #tChatString
do
	local tIndexKey = tChatString[nChatStringIndex][1]
	for nIndexValue = 1, #tIndexKey
	do
		local sIndexKey = tIndexKey[nIndexValue]

		if tChatStringIndex[sIndexKey] == nil
		then
			tChatStringIndex[sIndexKey] = nChatStringIndex
		else
			local nRepeatedIndexKey = tChatStringIndex[sIndexKey]

			for i = 1, #tChatString[nChatStringIndex][2]
			do
				table.insert( tChatString[nRepeatedIndexKey][2], tChatString[nChatStringIndex][2][i] )
			end

			for i = 1, #tChatString[nChatStringIndex][3]
			do
				table.insert( tChatString[nRepeatedIndexKey][3], tChatString[nChatStringIndex][3][i] )
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

	local sChatStringList = tChatString[nIndex][nStringTableIndex]

	local sChatTableString = sChatStringList[RandomInt( 1, #sChatStringList )]

	return sChatTableString

end



function Chat.GetReplyString( sString, bAllChat )

	local sReplyString = nil

	local nIndex = Chat.GetChatStringTableIndex( sString )

	if nIndex ~= - 1
	then
		sReplyString = Chat.GetChatTableString( nIndex, bAllChat )
	else
		--print( sString )
		sReplyString = Chat.GetCheaterReplyString( sString )
		if sReplyString == nil
		then
			sReplyString = Chat.GetRepeatString( sString )
			if sReplyString == nil or RandomInt( 1, 99 ) > 88
			then
				sReplyString = "目前还没有这句话的回答, 快来群里设计吧."
				if bAllChat then sReplyString = "不知道你在说什么" end
			end
		else
			return nil
		end
	end

	return sReplyString

end


function Chat.GetCheaterReplyString( sString )

	return string.byte( sString, 1 ) == string.byte( '-', 1 ) and "cheater" or nil

end


function Chat.GetRepeatString( sString )

	if sString == "你们" or sString == "你" or sString == "我"
		or sString == "吗？" or sString == "吗"
		or sString == "吧" or sString == "？"
	then return nil end

	local sRawString = sString

	if string.find( sString, "我是你" ) ~= nil
	then return string.gsub( sString, "我是你", "我才是你" ) end

	if string.find( sString, "sb" ) ~= nil
		or string.find( sString, "SB" ) ~= nil
		or string.find( sString, "智障" ) ~= nil
		or string.find( sString, "弱智" ) ~= nil
		or string.find( sString, "脑残" ) ~= nil
		or string.find( sString, "脑瘫" ) ~= nil
		or string.find( sString, "猪" ) ~= nil
		or string.find( sString, "傻" ) ~= nil
		or string.find( sString, "菜" ) ~= nil
		or string.find( sString, "笨" ) ~= nil
		or string.find( sString, "蠢" ) ~= nil
	then return Chat.GetReplyTauntString() end

	local sMaReplyList = { "呀", "哦", "呀！", "哦！", "！", "" }
	local sMaReplyWord = sMaReplyList[RandomInt( 1, #sMaReplyList )]

	sString = string.gsub( sString, "你们", "" )
	sString = string.gsub( sString, "你", "" )
	sString = string.gsub( sString, "吗？", sMaReplyWord )
	sString = string.gsub( sString, "吗", sMaReplyWord )
	sString = string.gsub( sString, "吧", "啊" )
	sString = string.gsub( sString, "？", "！" )
	sString = string.gsub( sString, "我", "你" )

	return sString ~= sRawString and sString or nil

end


function Chat.GetReplyTauntString()

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

	return sReplyTauntList[RandomInt( 1, #sReplyTauntList )]


end

function Chat.GetStopReplyString()

	local sStopStringList = {
	"我已无话可说了。",
	"我要专心打游戏了，下次再说吧。",
	"不和你闹了，我要开始认真玩了。",
	"我的心好累，不说了。",
	"好了好了，别逗我玩了。",
	"玩竞技游戏的时候就不能严肃点嘛。",
	"打游戏呢，先不和你聊了。",
	"我不想再分心聊天了。",
	}

	return sStopStringList[RandomInt( 1, #sStopStringList )]

end


return Chat
-- dota2jmz@163.com QQ:2462331592..