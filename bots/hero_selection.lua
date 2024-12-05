require( GetScriptDirectory()..'/FunLib/aba_global_overrides' )

local X = {}
local sSelectHero = "npc_dota_hero_zuus"
local fLastSlectTime, fLastRand = 5, 0
local nDelayTime = nil
local sBanList = {}
local sSelectList = {}
local tSelectPoolList = {}
local tLaneAssignList = {}
local bLineupReserve = false

local MU = require( GetScriptDirectory()..'/FunLib/aba_matchups' )
local Role = require( GetScriptDirectory()..'/FunLib/aba_role' )
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local Dota2Teams = require( GetScriptDirectory()..'/FunLib/aba_team_names' )
local CM = require( GetScriptDirectory()..'/FunLib/captain_mode' )
local Customize = require( GetScriptDirectory()..'/Customize/general' )
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )
local HeroPositionMap = require( GetScriptDirectory()..'/FunLib/aba_hero_pos_weights' )
local heroUnitNames = require( GetScriptDirectory()..'/FretBots/HeroNames')

local SupportedHeroes = {}

local CorrectRadiantAssignedLanes = false
local CorrectDireAssignedLanes = false
local CorrectDirePlayerIndexToLaneIndex = { }

-- Define the upper bound threshold for considering a hero a good fit for a position
local ROLE_WEIGHT_THRESHOLD = 50
-- Only pick the top k result of the heroes that have the heighest weight for the role.
local ROLE_LIST_TOP_K_LIMIT = 35

local CountCounterPicks = 0

--[[
Game Modes
[x]: to be added.

GAMEMODE_NONE
GAMEMODE_AP = 1 -- All Pick
GAMEMODE_CM = 2 -- Captain Mode
GAMEMODE_RD = 3 -- Random Draft. Players take turns choosing from a pool of 33 random heroes.
GAMEMODE_SD = 4 -- Single Draft. Choose from 4 random heroes.
GAMEMODE_AR = 5 -- All Random. Each player gets a random hero.
[x] GAMEMODE_REVERSE_CM
GAMEMODE_MO = 11 -- Mid Only
[x] GAMEMODE_CD = 16 -- Captains Draft. Captains ban and choose from a selection of 28 heroes.
[X] GAMEMODE_ABILITY_DRAFT -- Play a hero with four abilities selected from a random pool of abilities.
GAMEMODE_LP -- Least Played. Choose from a pool of your least played heroes.
[X] GAMEMODE_ARDM -- All Random Deathmatch. Players receive a random hero when they respawn after dying. First team to exhaust either teams 40 respawns, reach 45 kills on either team, or when the Ancient is destroyed, wins.
GAMEMODE_1V1MID = 21
GAMEMODE_ALL_DRAFT = 22 -- Ranked All Pick. The All Pick mode in ranked matches works different than the regular All Pick mode, and is called "Ranked Matchmaking".
GAMEMODE_TURBO = 23

]]

-- A list of to be improved heroes. They maybe selected for bots, but shouldn't have more than one in a team to ensure the bar of gaming experience for human players.
-- Weak due to 1, some have bugs from Valve side, I try my best to improve. 2, I'm not familir with the hero game play itself, or it's not easy hero in terms of do it with coding.
local SelectedWeakHero = 0
local MaxWeakHeroCount = 1
local WeakHeroes = {
	-- Weaks, meaning they are too far from being able to apply their power:
	'npc_dota_hero_chen',
	'npc_dota_hero_keeper_of_the_light',
	-- 'npc_dota_hero_winter_wyvern', -- somewhat improved
	'npc_dota_hero_ancient_apparition',
	-- 'npc_dota_hero_phoenix', -- somewhat improved
	'npc_dota_hero_tinker',
	'npc_dota_hero_pangolier',
	'npc_dota_hero_furion',
	'npc_dota_hero_tusk',
	'npc_dota_hero_morphling',
	'npc_dota_hero_visage',
	'npc_dota_hero_void_spirit',
	'npc_dota_hero_pudge',
	'npc_dota_hero_ember_spirit',

	-- Buggys, meaning they have bugs on Valves side, as of (still) 2024/8/1:
    'npc_dota_hero_muerta',
    'npc_dota_hero_marci',
    'npc_dota_hero_lone_druid',
    'npc_dota_hero_primal_beast',
    'npc_dota_hero_dark_willow',
    'npc_dota_hero_elder_titan',
    'npc_dota_hero_hoodwink',
    'npc_dota_hero_wisp',
	-- 'npc_dota_hero_kez', -- somewhat improved
}

-- Function to get a list of all hero names from the HeroPositionMap
function GetAllHeroNames(heroPosMap)
    local heroNames = {}
    for heroName, _ in pairs(heroPosMap) do
        table.insert(heroNames, heroName)
    end
    return heroNames
end

-- Function to get a list of heroes suitable for a given position. Sort the list by weight。
function GetPositionedPool(heroPosMap, position)
    local heroList = {}
	-- Pick from weighted options for the pos first.
    for heroName, roleWeights in pairs(heroPosMap) do
        local weight = roleWeights[position]
        if weight > RandomInt(5, ROLE_WEIGHT_THRESHOLD) then
			if not Utils.HasValue(WeakHeroes, heroName)
			or RandomInt(1, 10) > 7 then
				table.insert(heroList, {name = heroName, weight = weight})
			end
        end
    end
    -- Sort the list by weight in descending order
    table.sort(heroList, function(a, b) return a.weight > b.weight end)
    -- Extract hero names
    local sortedHeroNames = {}
    for _, hero in ipairs(heroList) do
		local name = hero.name
		print('Picking for position: '.. tostring(position) .. ", checking role for hero: "..name)
		if (position == 1 and (Role.IsDisabler(name) or Role.IsNuker(name)))
		or (position == 2 and (Role.IsDisabler(name) or Role.IsNuker(name) or Role.IsDurable(name)))
		or (position == 3 and (not Role.IsRanged(name)) and (Role.IsInitiator(name) or Role.IsDisabler(name) or Role.IsDurable(name)))
		or (position == 4 and Role.IsSupport(name) and (Role.IsDisabler(name) or Role.IsHealer(name) or Role.IsDurable(name)))
		or (position == 5 and Role.IsSupport(name) and Role.IsRanged(name) and (Role.IsDisabler(name) or Role.IsHealer(name) or Role.IsInitiator(name)))
		then
			print("Selected hero: " ..name .. " as an option for position: ".. tostring(position))
			table.insert(sortedHeroNames, name)
			-- Only return top k (ROLE_LIST_TOP_K_LIMIT) results.
			if #sortedHeroNames >= ROLE_LIST_TOP_K_LIMIT then
				return sortedHeroNames
			end
		end
    end
	if #sortedHeroNames < 6 then -- in case all selections is unavailable or have been picked.
		sortedHeroNames = Utils.CombineTablesUnique(sortedHeroNames, GetPositionedPool(heroPosMap, position))
	end
	print("For position: " .. position .. ", pool size count: ".. #sortedHeroNames)
	Utils.PrintTable(sortedHeroNames)
    return sortedHeroNames
end

SupportedHeroes = GetAllHeroNames(HeroPositionMap)

if Customize and not Customize.Enable then Customize = nil end

tSelectPoolList = {
	[1] = GetPositionedPool(HeroPositionMap, 1),
	[2] = GetPositionedPool(HeroPositionMap, 2),
	[3] = GetPositionedPool(HeroPositionMap, 3),
	[4] = GetPositionedPool(HeroPositionMap, 4),
	[5] = GetPositionedPool(HeroPositionMap, 5),
}

sSelectList = {
	[1] = tSelectPoolList[1][RandomInt( 1, #tSelectPoolList[1] )],
	[2] = tSelectPoolList[2][RandomInt( 1, #tSelectPoolList[2] )],
	[3] = tSelectPoolList[3][RandomInt( 1, #tSelectPoolList[3] )],
	[4] = tSelectPoolList[4][RandomInt( 1, #tSelectPoolList[4] )],
	[5] = tSelectPoolList[5][RandomInt( 1, #tSelectPoolList[5] )],
}

local tDefaultLaningRadiant = {
	[1] = LANE_BOT,
	[2] = LANE_MID,
	[3] = LANE_TOP,
	[4] = LANE_TOP,
	[5] = LANE_BOT,
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
	TEAM_RADIANT = Utils.Deepcopy(tDefaultLaningRadiant),
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
			local hero = Utils.TrimString(Customize.Radiant_Heros[i])
			if hero and hero ~= 'Random' and Utils.HasValue(SupportedHeroes, hero) then
				sSelectList[i] = hero
			end
		end
	elseif GetTeam() == TEAM_DIRE and Customize.Dire_Heros then
		for i = 1, #Customize.Dire_Heros do
			local hero = Utils.TrimString(Customize.Dire_Heros[i])
			if hero and hero ~= 'Random' and Utils.HasValue(SupportedHeroes, hero) then
				sSelectList[i] = hero
			end
		end
	end
end

function X.IsInCustomizedPicks(name)
	if not Customize then
		return false
	end

	local heroes = {}
	if GetTeam() == TEAM_RADIANT and Customize.Radiant_Heros then
		heroes = Customize.Radiant_Heros
	elseif GetTeam() == TEAM_DIRE and Customize.Dire_Heros then
		heroes = Customize.Dire_Heros
	end
	return Utils.HasValue(heroes, name)
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
		if teamPlayers[i] and teamPlayers[i] >= 0 and IsPlayerBot(teamPlayers[i]) and IsPlayerBot(teamPlayers[targetIndex]) then
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
		local heroExist = IsTeamPlayer( id ) and GetSelectedHeroName( id ) == sHero
		if heroExist
			or ( X.IsBannedHero( sHero ) )
			or ( X.SkipPickingWeakHeroes(sHero) and not (X.IsInCustomizedPicks(sHero) and not heroExist) )
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

	if not sHero then
		return true
	end

	if GetGameMode() == GAMEMODE_CM and IsCMBannedHero(sHero) then
		return true
	end

	for i = 1, #sBanList
	do
		if sBanList[i] ~= nil
		   and string.find( sHero, Utils.TrimString(sBanList[i]) )
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
			if (MU.IsSynergy(hName, sName) or MU.IsSynergy(sName, hName))
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
				if v2 > 0 and c > 0 and v2 == c
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

function CorrectPotentialLaneAssignment()
	if GetTeam() == TEAM_RADIANT and not CorrectRadiantAssignedLanes then
		for i, id in pairs( GetTeamPlayers(TEAM_RADIANT) ) do
			local role = Role.roleAssignment['TEAM_RADIANT'][i]
			tLaneAssignList.TEAM_RADIANT[i] = tDefaultLaningRadiant[role]
		end
		CorrectRadiantAssignedLanes = true
	elseif GetTeam() == TEAM_DIRE and not CorrectDireAssignedLanes then
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
			if not X.IsInCustomizedPicks(sSelectHero) and RandomInt(1, 5) >= 3 then
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

				if CountCounterPicks < 2
				and selectCounter ~= nil then
					sSelectHero = selectCounter
					CountCounterPicks = CountCounterPicks + 1
				else
					local synergy = X.GetBestHeroFromPool(i, nOwnTeam)
					if synergy ~= '' and synergy ~= nil then
						print('Team '..GetTeam()..'. Synergy pick. ', 'Selected: '..synergy)
						sSelectHero = synergy
					end
				end
			else
				-- print('Team '..GetTeam()..'. Skip picking counter/synergy heroes. For more chance to see any heroes')
			end

			if X.IsRepeatHero(sSelectHero) then sSelectHero = X.GetNotRepeatHero( tSelectPoolList[i] ) end
			if Utils.HasValue(WeakHeroes, sSelectHero) then SelectedWeakHero = SelectedWeakHero + 1 end
			SelectHero( id, sSelectHero )

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
    local action, target = Utils.TrimString(command):match("^(%S+)%s+(.*)$")
    return action, target
end
local userSwitchedRole = false

-- Function to handle the command
local function handleCommand(inputStr, PlayerID, bTeamOnly)
    local actionKey, actionVal = parseCommand(inputStr)
	if actionKey == nil then
		print('[WARN] Invalid command: '..tostring(inputStr))
		return
	end
	-- if GetGameMode() == GAMEMODE_CM then
	-- 	print('[WARN] Captain mode does not support commands')
	-- 	return
	-- end

	local teamPlayers = GetTeamPlayers(GetTeam())

	print('Handling command starting with: '..tostring(actionKey)..', text: '..tostring(actionVal))

	local commands = {}
    -- Split input by semicolon to handle multiple !pick commands
    for command in inputStr:gmatch("[^;]+") do
        table.insert(commands, command:match("^%s*(.-)%s*$")) -- Trim whitespace
    end

    for _, command in ipairs(commands) do
		local subKey, subVal = command:match("(!%w+)%s*(.*)")

		if subKey == "!pick" and GetGameMode() ~= GAMEMODE_CM then
			print("Picking hero " .. subVal .. ', is-for-ally: ' .. tostring(bTeamOnly))
			local hero = GetHumanChatHero(subVal);
			if hero ~= "" then
				if X.IsRepeatHero(hero) then
					print('Hero ' .. hero .. ' has already been picked')
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
				print("Hero name not found or not supported! Please refer to the list of names here: https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4848777260032086340/");
			end
		elseif subKey == "!ban" and GetGameState() == GAME_STATE_HERO_SELECTION then
			print("Banning hero " .. subVal)
			local hero = GetHumanChatHero(subVal);
			if hero ~= "" then
				if X.IsRepeatHero(hero) then
					print('Hero  ' .. hero .. ' has already been picked')
					return
				end
				X.SetChatHeroBan( hero )
				print("Banned hero " .. hero.. '. Banned list:')
				Utils.PrintTable(sBanList)
			else
				print("Hero name not found or not supported! Please refer to the list of names here: https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4848777260032086340/");
			end
		elseif subKey == "!pos" and GetGameState() == GAME_STATE_PRE_GAME then
			print("Selecting pos " .. subVal)
			local sTeamName = GetTeamForPlayer(PlayerID) == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
			local remainingPos = RemainingPos[sTeamName]
			if Utils.HasValue(remainingPos, subVal) then
				local role = tonumber(subVal)
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
							print('Switch role successfully. Team: '..sTeamName.. '. Player Id: '..PlayerID..', idx: '..playerIndex..', new role: '..Role.roleAssignment[sTeamName][playerIndex])
							print('Switch role successfully. Team: '..sTeamName.. '. Player Id: '..id..', idx: '..index..', new role: '..Role.roleAssignment[sTeamName][index])
						else
							print('Switch role failed, the target role belongs to human player. Ask the player directly to switch role.')
						end
						break;
					end
				end
			else
				print("Cannot select pos: " .. subVal..' because it is not available.')
			end
		elseif subKey:match("^!(%d+)pos$") ~= nil and GetGameState() == GAME_STATE_PRE_GAME then
			local x, y = inputStr:match("^!(%d+)pos (%d+)$")
			if x and y then
				print("Swap position for #" .. x .. " to play pos " .. y)
			else
				print("Invalid command format for swapping pos")
				return
			end

			local sTeamName = GetTeamForPlayer(PlayerID) == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
			local remainingPos = RemainingPos[sTeamName]
			if Utils.HasValue(remainingPos, y) then
				local role = tonumber(y)
				local playerIndex = PlayerID + 1 -- each team player id starts with 0, to 4 as the last player. 
				-- this index can be differnt if the player choose a slot in lobby that has empty slots before the one the player chooses.
				for idx, id in pairs(teamPlayers) do
					if idx == tonumber(x) then playerIndex = idx end
				end
				for index, id in pairs(teamPlayers)
				do
					if Role.roleAssignment[sTeamName][index] == role then
						Role.roleAssignment[sTeamName][playerIndex], Role.roleAssignment[sTeamName][index] = role, Role.roleAssignment[sTeamName][playerIndex]
						if GetTeamForPlayer(PlayerID) == TEAM_DIRE then
							tLaneAssignList[sTeamName][CorrectDirePlayerIndexToLaneIndex[playerIndex]], tLaneAssignList[sTeamName][CorrectDirePlayerIndexToLaneIndex[index]] =
								tLaneAssignList[sTeamName][CorrectDirePlayerIndexToLaneIndex[index]], tLaneAssignList[sTeamName][CorrectDirePlayerIndexToLaneIndex[playerIndex]]
						else
							tLaneAssignList[sTeamName][playerIndex], tLaneAssignList[sTeamName][index] = tLaneAssignList[sTeamName][index], tLaneAssignList[sTeamName][playerIndex]
						end
						print('Switch role successfully. Team: '..sTeamName.. '. Player Id: '..PlayerID..', idx: '..playerIndex..', new role: '..Role.roleAssignment[sTeamName][playerIndex])
						print('Switch role successfully. Team: '..sTeamName.. '. Player Id: '..id..', idx: '..index..', new role: '..Role.roleAssignment[sTeamName][index])
						break;
					end
				end
			else
				print("Cannot select pos: " .. y..' because it is not available.')
			end
		elseif subKey == "!sp" or subKey == "!speak" then
			HandleLocaleSetting(subVal)
		else
			print("Unknown action: " .. subKey .. ', command text: '..tostring(inputStr))
		end
	end
end

function HandleLocaleSetting(locale)
	Customize.Localization = locale
	print("Set to speak: ".. locale)
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
	name = name:lower()
	for _, hero in pairs(SupportedHeroes) do
		if heroUnitNames['en'][hero]:lower() == name then
			print('Found hero ' .. hero .. ' for '..name)
			return hero;
		end
	end
	for _, hero in pairs(SupportedHeroes) do
		if string.find(hero, name) then
			print('Found hero ' .. hero .. ' for '..name)
			return hero;
		end
	end
	print('Hero not supported with name: '..name)
	return "";
end
--function to decide which team should get the hero
function SelectHeroChatCallback(PlayerID, ChatText, bTeamOnly)
	local text = string.lower(ChatText);

	if GetGameState() == GAME_STATE_HERO_SELECTION and string.len(ChatText) == 2 then
		if Localization.Supported(ChatText) then
			HandleLocaleSetting(ChatText)
		end
	end

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
			playerNameOverrides.Radiant[i] = Utils.TrimString(Customize.Radiant_Names[i])
		end
	end
	for i = 1, #Customize.Dire_Names do
		if Customize.Dire_Names[i] ~= nil then
			playerNameOverrides.Dire[i] = Utils.TrimString(Customize.Dire_Names[i])
		end
	end
end

local teamPlayerNames = Dota2Teams.generateTeams(playerNameOverrides)

function GetBotNames()
	return GetTeam() == TEAM_RADIANT and teamPlayerNames.Radiant or teamPlayerNames.Dire
end

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
	end

	if GetGameState() == GAME_STATE_HERO_SELECTION or GetGameState() == GAME_STATE_STRATEGY_TIME or GetGameState() == GAME_STATE_PRE_GAME then
		InstallChatCallback(function (attr) SelectHeroChatCallback(attr.player_id, attr.string, attr.team_only); end);
	end

	CorrectPotentialLaneAssignment()
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
