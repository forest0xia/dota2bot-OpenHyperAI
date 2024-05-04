local X = {}
local sSelectHero = "npc_dota_hero_zuus"
local fLastSlectTime, fLastRand = -100, 0
local nDelayTime = nil
local FretBots = nil
local nHumanCount = 0
local sBanList = {}
local sSelectList = {}
local tSelectPoolList = {}
local tLaneAssignList = {}

local bUserMode = false
local bLaneAssignActive = true
local bLineupReserve = false

local nDireFirstLaneType = 1
if pcall( require,  'game/bot_dire_first_lane_type' )
then
	nDireFirstLaneType = require( 'game/bot_dire_first_lane_type' )
end

local Role = require( GetScriptDirectory()..'/FunLib/aba_role' )
local Chat = require( GetScriptDirectory()..'/FunLib/aba_chat' )
local HeroSet = {}

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

---------------------------------------------------------
---------------------------------------------------------

local sPos1List = {
	"npc_dota_hero_alchemist",
	"npc_dota_hero_antimage",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_faceless_void",
	"npc_dota_hero_furion",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_life_stealer",
	"npc_dota_hero_lina",
	"npc_dota_hero_luna",
	-- "npc_dota_hero_marci", -- DOESN'T WORK
	"npc_dota_hero_medusa",
	"npc_dota_hero_meepo",
	"npc_dota_hero_morphling",
	-- "npc_dota_hero_muerta", -- DOESN'T WORK
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
	"npc_dota_hero_tiny",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_ursa",
	"npc_dota_hero_weaver",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_viper",
}

local sPos2List = {
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_batrider",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_doom_bringer",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_earth_spirit",
	"npc_dota_hero_ember_spirit",
	"npc_dota_hero_huskar",
	"npc_dota_hero_rubick",
	"npc_dota_hero_invoker", -- TOO WEAK
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_lina",
	-- "npc_dota_hero_lone_druid", -- DOESN'T WORK
	"npc_dota_hero_meepo",
	"npc_dota_hero_mirana",
	"npc_dota_hero_monkey_king",
	"npc_dota_hero_morphling",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_pangolier",
	-- "npc_dota_hero_primal_beast", -- DOESN'T WORK
	"npc_dota_hero_puck",
	"npc_dota_hero_pudge",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_razor",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_sniper",
	"npc_dota_hero_storm_spirit",
	"npc_dota_hero_templar_assassin",
	-- "npc_dota_hero_tinker", -- TOO WEAK
	"npc_dota_hero_tiny",
	"npc_dota_hero_viper",
	"npc_dota_hero_void_spirit",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_zuus",
}

local sPos3List = {
	"npc_dota_hero_abyssal_underlord",
	"npc_dota_hero_axe",
	"npc_dota_hero_batrider",
	"npc_dota_hero_beastmaster",
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
	"npc_dota_hero_enigma",
	"npc_dota_hero_furion",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_lycan",
	"npc_dota_hero_magnataur",
	-- "npc_dota_hero_marci", -- DOESN'T WORK
	"npc_dota_hero_mars",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_night_stalker",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_pangolier",
	-- "npc_dota_hero_primal_beast", -- DOESN'T WORK
	"npc_dota_hero_pudge",
	"npc_dota_hero_razor",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_shredder",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_slardar",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_viper",
	"npc_dota_hero_visage",
	"npc_dota_hero_windrunner",
}

local sPos4List = {
	"npc_dota_hero_abaddon",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_bane",
	-- "npc_dota_hero_chen", -- TOO WEAK
	"npc_dota_hero_crystal_maiden",
	-- "npc_dota_hero_dark_willow", -- DOESN'T WORK
	"npc_dota_hero_dazzle",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_earthshaker",
	-- "npc_dota_hero_elder_titan", -- DOESN'T WORK
	"npc_dota_hero_enchantress",
	"npc_dota_hero_grimstroke",
	-- "npc_dota_hero_hoodwink", -- DOESN'T WORK
	"npc_dota_hero_jakiro",
	"npc_dota_hero_lich",
	"npc_dota_hero_lion",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_oracle",
	-- "npc_dota_hero_phoenix",  -- TOO WEAK
	"npc_dota_hero_pugna",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_rubick",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_silencer",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_techies",
	"npc_dota_hero_treant",
	"npc_dota_hero_tusk",
	"npc_dota_hero_undying",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_warlock",
	-- "npc_dota_hero_winter_wyvern", -- TOO WEAK
	"npc_dota_hero_witch_doctor",
}

local sPos5List = {
	"npc_dota_hero_abaddon",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_bane",
	-- "npc_dota_hero_chen", -- TOO WEAK
	"npc_dota_hero_crystal_maiden",
	-- "npc_dota_hero_dark_willow", -- DOESN'T WORK
	"npc_dota_hero_dazzle",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_earthshaker",
	-- "npc_dota_hero_elder_titan", -- DOESN'T WORK
	"npc_dota_hero_enchantress",
	"npc_dota_hero_grimstroke",
	-- "npc_dota_hero_hoodwink", -- DOESN'T WORK
	"npc_dota_hero_jakiro",
	"npc_dota_hero_lich",
	"npc_dota_hero_lion",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_oracle",
	-- "npc_dota_hero_phoenix",  -- TOO WEAK
	"npc_dota_hero_pugna",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_rubick",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_silencer",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_techies",
	"npc_dota_hero_treant",
	"npc_dota_hero_tusk",
	"npc_dota_hero_undying",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_warlock",
	-- "npc_dota_hero_winter_wyvern", -- TOO WEAK
	"npc_dota_hero_witch_doctor",
}

tSelectPoolList = {
	[1] = sPos2List,
	[2] = sPos3List,
	[3] = sPos1List,
	[4] = sPos5List,
	[5] = sPos4List,
}

sSelectList = {
	[1] = tSelectPoolList[1][RandomInt( 1, #tSelectPoolList[1] )],
	[2] = tSelectPoolList[2][RandomInt( 1, #tSelectPoolList[2] )],
	[3] = tSelectPoolList[3][RandomInt( 1, #tSelectPoolList[3] )],
	[4] = tSelectPoolList[4][RandomInt( 1, #tSelectPoolList[4] )],
	[5] = tSelectPoolList[5][RandomInt( 1, #tSelectPoolList[5] )],
}

if GetTeam() == TEAM_RADIANT
then
	local nRadiantLane = {
							[1] = LANE_MID,
							[2] = LANE_TOP,
							[3] = LANE_BOT,
							[4] = LANE_BOT,
							[5] = LANE_TOP,
						}

	tLaneAssignList = nRadiantLane

else
	local nDireLane = {
						[1] = LANE_MID,
						[2] = LANE_BOT,
						[3] = LANE_TOP,
						[4] = LANE_TOP,
						[5] = LANE_BOT,
					  }				

	tLaneAssignList = nDireLane
end

if nDireFirstLaneType == 2 and GetTeam() == TEAM_DIRE
then
	sSelectList[1], sSelectList[2] = sSelectList[2], sSelectList[1]
	tSelectPoolList[1], tSelectPoolList[2] = tSelectPoolList[2], tSelectPoolList[1]
	tLaneAssignList[1], tLaneAssignList[2] = tLaneAssignList[2], tLaneAssignList[1]
end

if nDireFirstLaneType == 3 and GetTeam() == TEAM_DIRE
then
	sSelectList[1], sSelectList[3] = sSelectList[3], sSelectList[1]
	tSelectPoolList[1], tSelectPoolList[3] = tSelectPoolList[3], tSelectPoolList[1]
	tLaneAssignList[1], tLaneAssignList[3] = tLaneAssignList[3], tLaneAssignList[1]
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
				or ( X.IsBanByChat( sHero ) )
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

	for id = 0, 20
	do
		if ( IsTeamPlayer( id ) and GetSelectedHeroName( id ) == sHero )
			or ( IsCMBannedHero( sHero ) )
			or ( X.IsBanByChat( sHero ) )
		then
			return true
		end
	end

	return false
end

if bUserMode and HeroSet['JinYongAI'] ~= nil
then
	sBanList = Chat.GetHeroSelectList( HeroSet['JinYongAI'] )
end

function X.SetChatHeroBan( sChatText )
	sBanList[#sBanList + 1] = string.lower( sChatText )
end

function X.IsBanByChat( sHero )

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

local TIWinners =
{
	-- Winners
	{--ti1
		"Na'Vi.Dendi",
		"Na'Vi.XBOCT",
		"Na'Vi.Artsyle",
		"Na'Vi.LighTofHeaveN",
		"Na'Vi.Puppey",
	},
	{--ti2
		"iG.Ferrari_430",
		"iG.YYF",
		"iG.Zhou",
		"iG.Faith",
		"iG.ChuaN",
	},
	{--ti3
		"Alliance.s4",
		"Alliance.AdmiralBulldog",
		"Alliance.Loda",
		"Alliance.Akke",
		"Alliance.EGM",
	},
	{--ti4
		"Newbee.Mu",
		"Newbee.xiao8",
		"Newbee.Hao",
		"Newbee.SanSheng",
		"Newbee.Banana",
	},
	{--ti5
		"EG.SumaiL",
		"EG.UNiVeRsE",
		"EG.Fear",
		"EG.ppd",
		"EG.Aui_2000",
	},
	{--ti6
		"Wings.bLink",
		"Wings.Faith_bian",
		"Wings.shadow",
		"Wings.iceice",
		"Wings.y`",
	},
	{--ti7
		"Liquid.Miracle-",
		"Liquid.MinD_ContRoL",
		"Liquid.MATUMBAMAN",
		"Liquid.KurokY",
		"Liquid.Gh",
	},
	{--ti8,9
		"OG.Topson",
		"OG.Ceb",
		"OG.ana",
		"OG.N0tail",
		"OG.JerAx",
	},
	{--ti10
		"TSpirit.TORONTOTOKYO",
		"TSpirit.Collapse",
		"TSpirit.Yatoro",
		"TSpirit.Miposhka",
		"TSpirit.Mira",
	},
	{--ti11
		"Tundra.Nine",
		"Tundra.33",
		"Tundra.skiter",
		"Tundra.Sneyking",
		"Tundra.Saksa",
	},
	{--ti12
		"TSpirit.Larl",
		"TSpirit.Collapse",
		"TSpirit.Yatoro雨",
		"TSpirit.Miposhka",
		"TSpirit.Mira",
	},
}

local TIRunnerUps =
{
-- Runner-Ups
	{--ti1
		"XG.Ame",
		"XG.Xm",
		"XG.Xxs",
		"XG.Xinq",
		"XG.Dy",
	},
	{
		"Azure Ray.Lou",
		"Azure Ray.Ori",
		"Azure Ray.Faith_bian",
		"Azure Ray.Fy",
		"Azure Ray.天命",
	},
	{--ti10
		"PSG.LGD.shiro",
		"PSG.LGD.Setsu",
		"PSG.LGD.niu",
		"PSG.LGD.Pyw",
		"PSG.LGD.y`",
	},
}

function X.GetRandomNameList( sStarList )
	local sNameList = {sStarList[1]}
	table.remove( sStarList, 1 )

	for i = 1, 4
	do
	    local nRand = RandomInt( 1, #sStarList )
		table.insert( sNameList, sStarList[nRand] )
		table.remove( sStarList, nRand )
	end

	return sNameList
end

-- The index in the list is the pick order. #1 pick is mid, #2 is pos3, #3 is pos1, #4 is pos 5, #5 is pos 4.
function X.OverrideTeamHeroes()
	if GetTeam() == TEAM_RADIANT
	then
		return {
			
			[1] = tSelectPoolList[1][RandomInt( 1, #tSelectPoolList[1] )],
			[2] = tSelectPoolList[2][RandomInt( 1, #tSelectPoolList[2] )],
			[3] = tSelectPoolList[3][RandomInt( 1, #tSelectPoolList[3] )],
			[4] = tSelectPoolList[4][RandomInt( 1, #tSelectPoolList[4] )],
			[5] = tSelectPoolList[5][RandomInt( 1, #tSelectPoolList[5] )],
			-- [1] = "npc_dota_hero_invoker",
			-- -- [1] = "npc_dota_hero_rubick",
			-- [2] = tSelectPoolList[2][RandomInt( 1, #tSelectPoolList[2] )],
			-- [3] = 'npc_dota_hero_faceless_void',
			-- [4] = tSelectPoolList[4][RandomInt( 1, #tSelectPoolList[4] )],
			-- [5] = tSelectPoolList[5][RandomInt( 1, #tSelectPoolList[5] )],
		}
	else
		return {
			-- [1] = "npc_dota_hero_invoker",
			-- [2] = "npc_dota_hero_arc_warden",
			-- [3] = "npc_dota_hero_clinkz",
		 --    [4] = "npc_dota_hero_witch_doctor",
			-- [5] = "npc_dota_hero_bane",

			-- [1] = "npc_dota_hero_rubick",
			-- [2] = "npc_dota_hero_snapfire",
			-- [3] = "npc_dota_hero_clinkz",
		    -- [4] = "npc_dota_hero_earth_spirit",
			-- [5] = "npc_dota_hero_techies",


			-- Test buggy heroes:
			[1] = "npc_dota_hero_invoker",
			[2] = tSelectPoolList[2][RandomInt( 1, #tSelectPoolList[2] )],
			[3] = "npc_dota_hero_weaver",
			[4] = tSelectPoolList[4][RandomInt( 1, #tSelectPoolList[4] )],
			[5] = tSelectPoolList[5][RandomInt( 1, #tSelectPoolList[5] )],

			-- [1] = tSelectPoolList[1][RandomInt( 1, #tSelectPoolList[1] )],
			-- [2] = tSelectPoolList[2][RandomInt( 1, #tSelectPoolList[2] )],
			-- [3] = tSelectPoolList[3][RandomInt( 1, #tSelectPoolList[3] )],
			-- [4] = tSelectPoolList[4][RandomInt( 1, #tSelectPoolList[4] )],
			-- [5] = tSelectPoolList[5][RandomInt( 1, #tSelectPoolList[5] )],
		    

			-- [1] = "npc_dota_hero_storm_spirit",
			-- [2] = "npc_dota_hero_ember_spirit",
		 --    [3] = "npc_dota_hero_void_spirit",
			-- [4] = "npc_dota_hero_earth_spirit",
			-- [5] = "npc_dota_hero_brewmaster",
		    
		}
	end
end
sSelectList = X.OverrideTeamHeroes()

function Think()
	if GetGameState() == GAME_STATE_HERO_SELECTION then
		InstallChatCallback( function ( tChat ) X.SetChatHeroBan( tChat.string ) end )
	end

	if ( GameTime() < 3.0 and not bLineupReserve )
	   or fLastSlectTime > GameTime() - fLastRand
	   or X.IsHumanNotReady( GetTeam() )
	   or X.IsHumanNotReady( GetOpposingTeam() )
	then
		if GetGameMode() ~= 23 then return end
	end

	if nDelayTime == nil then nDelayTime = GameTime() fLastRand = RandomInt( 12, 34 )/10 end
	if nDelayTime ~= nil and nDelayTime > GameTime() - fLastRand then return end

	local nIDs = GetTeamPlayers( GetTeam() )
	for i, id in pairs( nIDs )
	do
		if IsPlayerBot( id ) and GetSelectedHeroName( id ) == ""
		then
			if X.IsRepeatHero( sSelectList[i] )
			then
				sSelectHero = X.GetNotRepeatHero( tSelectPoolList[i] )
			else
				sSelectHero = sSelectList[i]
			end

			SelectHero( id, sSelectHero )
			if Role["bLobbyGame"] == false then Role["bLobbyGame"] = true end

			fLastSlectTime = GameTime()
			fLastRand = RandomInt( 8, 28 )/10
			break
		end
	end

end

function GetBotNames()
	return GetTeam() == TEAM_RADIANT and TIWinners[RandomInt(1, #TIWinners)] or TIRunnerUps[RandomInt(1, #TIRunnerUps)]
end

local bPvNLaneAssignDone = false
function UpdateLaneAssignments()

	if DotaTime() > 0
		and nHumanCount == 0
		and Role.IsPvNMode()
		and not bLaneAssignActive
		and not bPvNLaneAssignDone
	then
		if RandomInt( 1, 8 ) > 4 then tLaneAssignList[4] = LANE_MID else tLaneAssignList[5] = LANE_MID end
		bPvNLaneAssignDone = true
	end

	return tLaneAssignList
end