--==============================================================================
--  DRAFTER — with per-team weak-hero cap + configurable
--  penalty curve, matchup-aware selection, and strict ban/repeat policy.
--
--  Key guarantees:
--    1) Prefer matchup-ranked heroes that are pickable (not banned, not above
--       weak cap, not repeated unless allowed) AND inside the role's pool.
--    2) If none from matchup list are pickable, randomly pick within pool
--       under the same constraints.
--    3) Repeats are allowed ONLY when Customize.Allow_Repeated_Heroes == true.
--    4) Weak-hero cap is tracked per-team (Radiant/Dire) per game.
--    5) Weak penalty curve during scoring is configurable in Customize.*
--==============================================================================

require( GetScriptDirectory()..'/FunLib/aba_global_overrides' )

local X = {}

local PickSchedule = {
	initialized = false,
	NextPickAt = { [1]=math.huge,[2]=math.huge,[3]=math.huge,[4]=math.huge,[5]=math.huge },
}

local sBanList = {}
local sSelectList = {}
local tSelectPoolList = {}
local tLaneAssignList = {}
local bLineupReserve = false

-- matchup data: matchups[cand][enemy] = enemy_advantage_vs_cand (Dotabuff-style)
local matchups = require( GetScriptDirectory()..'/FretBots/matchups_data' )

local Role = require( GetScriptDirectory()..'/FunLib/aba_role' )
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local Dota2Teams = require( GetScriptDirectory()..'/FunLib/aba_team_names' )
local CaptainMode = require( GetScriptDirectory()..'/FunLib/captain_mode' )
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )
local HeroPositionMap = require( GetScriptDirectory()..'/FunLib/aba_hero_pos_weights' )
local heroUnitNames = require( GetScriptDirectory()..'/FretBots/HeroNames')
local Customize = require(GetScriptDirectory()..'/FunLib/custom_loader')
HeroPositionMap = HeroPositionMap.GetHeroPositions()

if GAMEMODE_TURBO == nil then GAMEMODE_TURBO = 23 end

--==============================================================================
-- Game Modes notes
--==============================================================================
--[[

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

--==============================================================================
-- Configuration (can be overridden in Customize)
--==============================================================================

-- Upper bound threshold for considering a hero a good fit for a position
local ROLE_WEIGHT_THRESHOLD = 50
-- Only pick top-k by role weight when building the pool
local ROLE_LIST_TOP_K_LIMIT = 35

-- Default weak-hero cap per-team (can override via Customize.Weak_Hero_Cap)
local DEFAULT_WEAK_HERO_CAP = 1

-- Default weak penalty curve. Can override via Customize.Weak_Penalty:
--   { type="linear", k=0.25 }         ->  penalty = max(0, 1 - k * (weakPicked/cap))
--   { type="quad",   k=1.0 }          ->  penalty = (1 - min(1, weakPicked/cap))^2
--   { type="exp",    base=0.6 }       ->  penalty = base^(weakPicked)  (more weak -> smaller)
-- Missing params fall back to sensible defaults.
local DEFAULT_WEAK_PENALTY = { type = "exp", base = 0.6 }

--==============================================================================
-- State
--==============================================================================

local SupportedHeroes = {}

local CorrectRadiantAssignedLanes = false
local CorrectDireAssignedLanes = false
local CorrectDirePlayerIndexToLaneIndex = { }

-- Track how many "durable" etc. have been allowed per role during pool build
local countDurableHeroes = {}

-- Per-team, per-game weak-hero counter (hard cap enforcement)
local WeakHeroCount = {
	[TEAM_RADIANT] = 0,
	[TEAM_DIRE]    = 0
}

--==============================================================================
-- Weak & Buggy hero lists (tunable)
--   Note: They're still eligible, but we throttle picks and score-penalize.
--==============================================================================

-- A list of to be improved heroes. They maybe selected for bots, but shouldn't have more than one in a team to ensure the bar of gaming experience for human players.
-- Weak due to 1, some have bugs from Valve side, I try my best to improve. 2, I'm not familir with the hero game play itself, or it's not easy hero in terms of do it with coding.
local WeakHeroes = {
	-- Weaks, meaning they are too far from being able to apply their power:
	'npc_dota_hero_chen',
	'npc_dota_hero_ancient_apparition',
	'npc_dota_hero_tinker',
	'npc_dota_hero_pangolier',
	'npc_dota_hero_tusk',
	'npc_dota_hero_morphling',
	'npc_dota_hero_visage',
	'npc_dota_hero_void_spirit',
	'npc_dota_hero_ember_spirit',
	'npc_dota_hero_rubick',
	'npc_dota_hero_brewmaster',
	'npc_dota_hero_puck',

	-- Buggys (as of 2024/8/1):
    'npc_dota_hero_marci',
    'npc_dota_hero_lone_druid',
    'npc_dota_hero_primal_beast',
    'npc_dota_hero_dark_willow',
    'npc_dota_hero_hoodwink',
    'npc_dota_hero_wisp',
}

--==============================================================================
-- Helpers: global options
--==============================================================================

if Customize and not Customize.Enable then Customize = nil end

-- Per-team string name for Role.RoleAssignment keying
local sTeamName = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'

--==============================================================================
-- Role-pool construction helpers
--==============================================================================

local function GetAllHeroNames(heroPosMap)
    local heroNames = {}
    for heroName, _ in pairs(heroPosMap) do
        table.insert(heroNames, heroName)
    end
    return heroNames
end

local function ShouldPickDurableOrOtherCores(name, position, minCount)
	return (countDurableHeroes[position] <= minCount and Role.IsDurable(name))
	       or (Role.IsDisabler(name) or Role.IsNuker(name))
end

local function ShouldPickDurableOrOtherInitiator(name, position, minCount)
	return (countDurableHeroes[position] <= minCount and Role.IsDurable(name))
	       or (Role.IsInitiator(name) or (Role.IsDisabler(name) and Role.IsDurable(name)))
end

local function ShouldPickDurableOrOtherSupports(name, position, minCount)
	return (countDurableHeroes[position] <= minCount and Role.IsDurable(name))
	       or (Role.IsDisabler(name) or Role.IsHealer(name) or Role.IsInitiator(name))
end

-- Build a weighted/screened list for a position, then cut to top-k
local function GetPositionedPool(heroPosMap, position)
    local heroList = {}
	-- Pick from weighted options for the pos first.
    for heroName, roleWeights in pairs(heroPosMap) do
        local weight = roleWeights[position]
        if weight > RandomInt(5, ROLE_WEIGHT_THRESHOLD) then
			if not Utils.HasValue(WeakHeroes, heroName) or RandomInt(1, 10) > 7 then
				table.insert(heroList, {name = heroName, weight = weight})
			end
        end
    end
    table.sort(heroList, function(a, b) return a.weight > b.weight end)

    local sortedHeroNames = {}
    for _, hero in ipairs(heroList) do
		local name = hero.name
		if countDurableHeroes[position] == nil then countDurableHeroes[position] = 0 end
		if (position == 1 and ShouldPickDurableOrOtherCores(name, position, 6))
		or (position == 2 and ShouldPickDurableOrOtherCores(name, position, 6))
		or (position == 3 and (not Role.IsRanged(name) or hero.weight > 50) and ShouldPickDurableOrOtherInitiator(name, position, 6))
		or (position == 4 and Role.IsSupport(name) and ShouldPickDurableOrOtherSupports(name, position, 4))
		or (position == 5 and Role.IsSupport(name) and (Role.IsRanged(name) or hero.weight >= 60) and (Role.IsDisabler(name) or Role.IsHealer(name) or Role.IsInitiator(name)))
		then
			table.insert(sortedHeroNames, name)
			countDurableHeroes[position] = countDurableHeroes[position] + 1
			if #sortedHeroNames >= ROLE_LIST_TOP_K_LIMIT then
				return sortedHeroNames
			end
		end
    end

	-- In case pool is small (rare), re-merge another pass
	if #sortedHeroNames < 6 then
		sortedHeroNames = Utils.CombineTablesUnique(sortedHeroNames, GetPositionedPool(heroPosMap, position))
	end
    return sortedHeroNames
end

--==============================================================================
-- Setup supported heroes & initial pools
--==============================================================================

SupportedHeroes = GetAllHeroNames(HeroPositionMap)

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

--==============================================================================
-- Default lane mapping scaffolding
--==============================================================================

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
	TEAM_RADIANT = Utils.Deepcopy(tDefaultLaningRadiant),
	TEAM_DIRE    = Utils.Deepcopy(tDefaultLaningDire)
}

local MidOnlyLaneAssignment = { [1]=LANE_MID,[2]=LANE_MID,[3]=LANE_MID,[4]=LANE_MID,[5]=LANE_MID }
local OneVoneLaneAssignment = { [1]=LANE_MID,[2]=LANE_TOP,[3]=LANE_TOP,[4]=LANE_TOP,[5]=LANE_TOP }

--==============================================================================
-- Customize overrides (preset picks)
--==============================================================================

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

--==============================================================================
-- Utility: customization checks & shuffles
--==============================================================================

function X.IsInCustomizedPicks(name)
	if not Customize then return false end
	local heroes = {}
	if GetTeam() == TEAM_RADIANT and Customize.Radiant_Heros then
		heroes = Customize.Radiant_Heros
	elseif GetTeam() == TEAM_DIRE and Customize.Dire_Heros then
		heroes = Customize.Dire_Heros
	end
	return Utils.HasValue(heroes, name)
end

function X.ShuffleArray(array)
	if type(array) ~= "table" then error("Expected a table, got " .. type(array)) end
    local n = #array
    for i = n, 2, -1 do
        local j = RandomInt(1, i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end

function X.ShufflePickOrder(teamPlayers)
	local shuffleSelection = X.ShuffleArray({1, 2, 3, 4, 5})
	for i = 1, #shuffleSelection do
		local targetIndex = shuffleSelection[i]
		if teamPlayers[i] and teamPlayers[i] >= 0 and IsPlayerBot(teamPlayers[i]) and IsPlayerBot(teamPlayers[targetIndex]) then
			sSelectList[i], sSelectList[targetIndex] = sSelectList[targetIndex], sSelectList[i]
			tSelectPoolList[i], tSelectPoolList[targetIndex] = tSelectPoolList[targetIndex], tSelectPoolList[i]
			tLaneAssignList['TEAM_RADIANT'][i], tLaneAssignList['TEAM_RADIANT'][targetIndex] = tLaneAssignList['TEAM_RADIANT'][targetIndex], tLaneAssignList['TEAM_RADIANT'][i]
			tLaneAssignList['TEAM_DIRE'][i],    tLaneAssignList['TEAM_DIRE'][targetIndex]    = tLaneAssignList['TEAM_DIRE'][targetIndex],    tLaneAssignList['TEAM_DIRE'][i]
			Role.RoleAssignment['TEAM_RADIANT'][i], Role.RoleAssignment['TEAM_RADIANT'][targetIndex] = Role.RoleAssignment['TEAM_RADIANT'][targetIndex], Role.RoleAssignment['TEAM_RADIANT'][i]
			Role.RoleAssignment['TEAM_DIRE'][i],    Role.RoleAssignment['TEAM_DIRE'][targetIndex]    = Role.RoleAssignment['TEAM_DIRE'][targetIndex],    Role.RoleAssignment['TEAM_DIRE'][i]
		end
	end
end

--==============================================================================
-- Ban List plumbing
--==============================================================================

if Customize and Customize.Ban then
	sBanList = Customize.Ban
end

function X.SetChatHeroBan( sChatText )
	sBanList[#sBanList + 1] = string.lower( sChatText )
end

-- Safer bans: exact match on unit-name by default; optional guarded substring
function X.IsBannedHero( sHero )
	if not sHero then return true end

	-- CM bans enforced by engine
	if (GetGameMode() == GAMEMODE_CM or GetGameMode() == GAMEMODE_REVERSE_CM) and IsCMBannedHero(sHero) then
		return true
	end

	local strict = true
	if Customize and Customize.Strict_Ban_Match ~= nil then
		strict = Customize.Strict_Ban_Match
	end

	for i = 1, #sBanList do
		local ban = sBanList[i]
		if ban ~= nil then
			ban = Utils.TrimString(string.lower(ban))
			if string.lower(sHero) == ban then
				return true
			end
			if not strict then
				-- only allow fuzzy if ban token is reasonably long to avoid false positives
				if #ban >= 6 and string.find(string.lower(sHero), ban, 1, true) then
					return true
				end
			end
		end
	end
	return false
end

--==============================================================================
-- Per-team Weak-Hero Cap & Penalty
--==============================================================================

-- Returns per-team weak cap
local function GetWeakCapForTeam(team)
	if Customize and Customize.Weak_Hero_Cap ~= nil then
		return tonumber(Customize.Weak_Hero_Cap) or DEFAULT_WEAK_HERO_CAP
	end
	return DEFAULT_WEAK_HERO_CAP
end

-- Returns multiplicative score penalty given how many weak heroes already on team
--  1.0 = no penalty; 0.0 = completely exclude (we never set to zero; CanPickHero blocks by cap)
local function WeakPenaltyFactor(team)
	local cfg = (Customize and Customize.Weak_Penalty) or DEFAULT_WEAK_PENALTY
	local picked = WeakHeroCount[team] or 0
	local cap = math.max(1, GetWeakCapForTeam(team))  -- avoid divide by zero

	-- Normalize 0..1
	local ratio = math.min(1.0, picked / cap)

	if cfg.type == "linear" then
		local k = (cfg.k ~= nil and tonumber(cfg.k)) or 0.25
		local p = 1.0 - (k * ratio)
		if p < 0 then p = 0 end
		return p

	elseif cfg.type == "quad" then
		-- More aggressive near cap
		local k = (cfg.k ~= nil and tonumber(cfg.k)) or 1.0
		local p = (1.0 - ratio) ^ 2
		return p * k + (1.0 - k)  -- allow scaling if k != 1

	elseif cfg.type == "exp" then
		-- Simple exponential decay by count (ignores cap)
		local base = (cfg.base ~= nil and tonumber(cfg.base)) or 0.6
		if base < 0.05 then base = 0.05 end
		if base > 0.99 then base = 0.99 end
		return base ^ picked
	end

	-- Default (exp-like)
	return DEFAULT_WEAK_PENALTY.base ^ picked
end

--==============================================================================
-- Pickability policy (centralized)
--==============================================================================

local function AlreadyPickedOnTeam(sHero)
	for id = 0, 20 do
		if IsTeamPlayer(id) and GetSelectedHeroName(id) == sHero then
			return true
		end
	end
	return false
end

-- Should we *block* picking a weak hero due to cap?
local function IsWeakHeroOverCap(team, sHero)
	if not Utils.HasValue(WeakHeroes, sHero) then return false end
	return WeakHeroCount[team] >= GetWeakCapForTeam(team)
end

-- Single source of truth whether a hero can be picked *right now* by this team
function X.CanPickHero(team, sHero)
	if not sHero then return false end

	-- Bans always block
	if X.IsBannedHero(sHero) then return false end

	-- Weak cap enforcement per team
	if IsWeakHeroOverCap(team, sHero) then return false end

	-- Repeats policy
	if Customize and Customize.Allow_Repeated_Heroes then
		return true
	end
	-- Otherwise, no duplicates within the team
	return not AlreadyPickedOnTeam(sHero)
end

-- Random pick within a role pool under the policy above
function X.GetRandomAvailableHero(team, pool)
	if type(pool) ~= "table" or #pool == 0 then return nil end
	local copy = {}
	for i = 1, #pool do copy[i] = pool[i] end
	X.ShuffleArray(copy)
	for _, cand in ipairs(copy) do
		if X.CanPickHero(team, cand) then
			return cand
		end
	end
	return nil
end

-- Backwards-compat wrapper; avoid using this in new code
function X.GetNotRepeatHero(nTable)
	if type(nTable) ~= "table" or #nTable == 0 then return nil end
	local pick = X.GetRandomAvailableHero(GetTeam(), nTable)
	return pick or nTable[1]
end

-- Kept for compatibility when code checks "repeatness" only
function X.IsRepeatHero(sHero)
	if Customize and Customize.Allow_Repeated_Heroes then
		return false
	end
	return AlreadyPickedOnTeam(sHero)
end

-- Skip weak heroes only if over cap (policy uses CanPickHero anyway)
function X.SkipPickingWeakHeroes(sHero)
	-- If repeats allowed, we still enforce weak cap
	return IsWeakHeroOverCap(GetTeam(), sHero)
end

--==============================================================================
-- Team snapshots & lane utilities
--==============================================================================

function X.IsHumanNotReady( nTeam )
	if GameTime() > 20 or bLineupReserve then return false end
	local humanCount, readyCount = 0, 0
	for _, id in pairs( GetTeamPlayers( nTeam ) ) do
        if not IsPlayerBot( id ) then
			humanCount = humanCount + 1
			if GetSelectedHeroName( id ) ~= "" then
				readyCount = readyCount + 1
			end
		end
    end
	return readyCount < humanCount
end

function X.GetCurrentTeam(nTeam, bEnemy)
	local nHeroList = {}
	for i, id in pairs(GetTeamPlayers(nTeam)) do
		local hName = GetSelectedHeroName(id)
		if hName ~= nil and hName ~= '' then
			if bEnemy then
				table.insert(nHeroList, {name=hName, pos=Role.GetBestEffortSuitableRole(hName)})
			else
				table.insert(nHeroList, {name=hName, pos=Role.RoleAssignment[sTeamName][i] })
			end
		end
	end
	return nHeroList
end

local ShuffledPickOrder = { TEAM_RADIANT = false, TEAM_DIRE = false }

local function CorrectPotentialLaneAssignment()
	if GetTeam() == TEAM_RADIANT and not CorrectRadiantAssignedLanes then
		for i, id in pairs( GetTeamPlayers(TEAM_RADIANT) ) do
			local role = Role.RoleAssignment['TEAM_RADIANT'][i]
			tLaneAssignList.TEAM_RADIANT[i] = tDefaultLaningRadiant[role]
		end
		CorrectRadiantAssignedLanes = true
	elseif GetTeam() == TEAM_DIRE and not CorrectDireAssignedLanes then
		-- Put humans first
		local index = 1
		for i, id in pairs( GetTeamPlayers(TEAM_DIRE) ) do
			local role = Role.RoleAssignment['TEAM_DIRE'][i]
			if not IsPlayerBot( id ) then
				tLaneAssignList.TEAM_DIRE[index] = tDefaultLaningDire[role]
				CorrectDirePlayerIndexToLaneIndex[i] = index
				index = index + 1
			end
		end
		for i, id in pairs( GetTeamPlayers(TEAM_DIRE) ) do
			local role = Role.RoleAssignment['TEAM_DIRE'][i]
			if IsPlayerBot( id ) then
				tLaneAssignList.TEAM_DIRE[index] = tDefaultLaningDire[role]
				CorrectDirePlayerIndexToLaneIndex[i] = index
				index = index + 1
			end
		end
		CorrectDireAssignedLanes = true
	end
end

-- Enemy hero unit-name list
local function GetEnemyHeroNames()
    local enemies = {}
    for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
        local h = GetSelectedHeroName(id)
        if h ~= nil and h ~= '' then table.insert(enemies, h) end
    end
    return enemies
end

--==============================================================================
-- Draft core (AllPick)
--==============================================================================

local RemainingPos = {
	TEAM_RADIANT = {'1', '2', '3', '4', '5'},
	TEAM_DIRE    = {'1', '2', '3', '4', '5'},
}

local function CountWeakHeroesSelectedOnTeam(team)
	local cnt = 0
	for _, id in pairs(GetTeamPlayers(team)) do
		local h = GetSelectedHeroName(id)
		if h and h ~= '' and Utils.HasValue(WeakHeroes, h) then
			cnt = cnt + 1
		end
	end
	return cnt
end

local function TeamOfPlayer(id)
	return GetTeamForPlayer(id) -- returns TEAM_RADIANT/TEAM_DIRE for that player
end

local function ScoreCandidatesForTeam(team, rolePool, enemyNames)
	-- Build scored list among pickable heroes only
	local list = {}
	local weakPenalty = WeakPenaltyFactor(team)

	for _, cand in ipairs(rolePool) do
		if X.CanPickHero(team, cand) then
			local score = 0
			-- Sum counter advantages (negate enemy advantage)
			if matchups[cand] then
				for _, e in ipairs(enemyNames) do
					local adv = matchups[cand][e]
					if adv ~= nil then
						score = score + (-1 * adv)
					end
				end
			end

			-- Penalize weak heroes multiplicatively (soft), in addition to hard cap
			if Utils.HasValue(WeakHeroes, cand) then
				score = score * weakPenalty
			end

			table.insert(list, { name = cand, score = score })
		end
	end

	table.sort(list, function(a, b) return a.score > b.score end)
	return list
end

local function SelectTopWithFuzz(scored)
	-- Keep only top 3 and roll among them 50/25/25
	while #scored > 3 do table.remove(scored) end
	if #scored == 0 then return nil end

	local roll = RandomInt(0, 100) / 100.0
	if roll <= 0.50 then
		return scored[1].name
	elseif roll <= 0.75 and scored[2] then
		return scored[2].name
	elseif scored[3] then
		return scored[3].name
	else
		return scored[1].name
	end
end

local function PickHeroForBotSlot(i, id)
	local team = TeamOfPlayer(id)
	local rolePool = tSelectPoolList[i]
	local preselect = sSelectList[i]

	-- Default to preselect for variety path; can be overridden below
	local pick = preselect

	-- Use matchup data most of the time unless user forced picks
	if not X.IsInCustomizedPicks(preselect) and RandomInt(1, 5) >= 1 then
		local enemyNames = GetEnemyHeroNames()
		local scored = ScoreCandidatesForTeam(team, rolePool, enemyNames)

		local teamName = (team == TEAM_RADIANT and 'Radiant' or 'Dire')
		print('==== top 3 heroes for team: '..teamName..' slot: '..i..' id: '..id..' ====')
		for k = 1, math.min(3, #scored) do
			print(k, scored[k].score, scored[k].name)
		end

		pick = SelectTopWithFuzz(scored)

		-- Fallback: if none are pickable (due to bans/repeats/weakcap), random available
		if not pick then
			pick = X.GetRandomAvailableHero(team, rolePool) or preselect
		end
	end

	-- Final safety: ensure policy still holds (e.g., late ban added)
	if not X.CanPickHero(team, pick) then
		pick = X.GetRandomAvailableHero(team, rolePool) or preselect
	end

	-- Update per-team weak count if needed
	if Utils.HasValue(WeakHeroes, pick) then
		-- Refresh live count (defensive) and then increment by pick
		WeakHeroCount[team] = CountWeakHeroesSelectedOnTeam(team)
		WeakHeroCount[team] = WeakHeroCount[team] + 1
	end

	return pick
end

local function AllPickHeros()
	local teamPlayers = GetTeamPlayers(GetTeam(), true)

	-- Shuffle internal pick order when all-bot team to mix patterns
	if not ShuffledPickOrder[sTeamName] and not Utils.IsHumanPlayerInTeam(GetTeam()) then
		X.ShufflePickOrder(teamPlayers)
		ShuffledPickOrder[sTeamName] = true
	end

	for i, id in pairs(teamPlayers) do
		-- Only pick when: this is a bot, slot is unpicked, and its scheduled time has arrived.
		if IsPlayerBot(id) and GetSelectedHeroName(id) == ""
		and IsPlayerInHeroSelectionControl(id)
		and GameTime() >= (PickSchedule.NextPickAt[i] or math.huge)
		then
			local finalPick = PickHeroForBotSlot(i, id)
			SelectHero(id, finalPick)

			-- Mark this slot as done so it won’t pick again
			PickSchedule.NextPickAt[i] = math.huge
			break
		end
	end
end

--==============================================================================
-- Commands & chat handling
--==============================================================================

-- Function to check if a string starts with "!"
local function startsWithExclamation(str)
    return string.len(str) > 3 and str:sub(1, 1) == "!"
end

local function parseCommand(command)
    local action, target = Utils.TrimString(command):match("^(%S+)%s+(.*)$")
    return action, target
end

local userSwitchedRole = false

local function handleCommand(inputStr, PlayerID, bTeamOnly)
    local actionKey, actionVal = parseCommand(inputStr)
	if actionKey == nil then
		print('[WARN] Invalid command: '..tostring(inputStr))
		return
	end

	local teamPlayers = GetTeamPlayers(GetTeam())

	print('Handling command starting with: '..tostring(actionKey)..', text: '..tostring(actionVal))

	local commands = {}
    for command in inputStr:gmatch("[^;]+") do
        table.insert(commands, command:match("^%s*(.-)%s*$"))
    end

    for _, command in ipairs(commands) do
		local subKey, subVal = command:match("(!%w+)%s*(.*)")

		if subKey == "!pick" and GetGameMode() ~= GAMEMODE_CM and GetGameMode() ~= GAMEMODE_REVERSE_CM then
			print("Picking hero " .. subVal .. ', is-for-ally: ' .. tostring(bTeamOnly))
			local hero = GetHumanChatHero(subVal);
			if hero ~= "" then
				if not X.CanPickHero(GetTeam(), hero) then
					print('Hero '..hero..' cannot be picked now (banned/repeat/weakcap)')
					return
				end
				if bTeamOnly then
					for _, id in pairs(teamPlayers) do
						if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" then
							SelectHero(id, hero);
							if Utils.HasValue(WeakHeroes, hero) then
								WeakHeroCount[GetTeam()] = WeakHeroCount[GetTeam()] + 1
							end
							break;
						end
					end
				elseif bTeamOnly == false and GetTeamForPlayer(PlayerID) ~= GetTeam() then
					for _, id in pairs(teamPlayers) do
						if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" then
							SelectHero(id, hero);
							if Utils.HasValue(WeakHeroes, hero) then
								WeakHeroCount[GetTeam()] = WeakHeroCount[GetTeam()] + 1
							end
							break;
						end
					end
				end
				userSwitchedRole = true
			else
				print("Hero name not found or not supported! See: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/71");
			end

		elseif subKey == "!ban" and GetGameState() == GAME_STATE_HERO_SELECTION then
			print("Banning hero " .. subVal)
			local hero = GetHumanChatHero(subVal);
			if hero ~= "" then
				if AlreadyPickedOnTeam(hero) then
					print('Hero  ' .. hero .. ' has already been picked')
					return
				end
				X.SetChatHeroBan( hero )
				print("Banned hero " .. hero.. '. Banned list:')
				Utils.PrintTable(sBanList)
			else
				print("Hero name not found or not supported! See: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/71");
			end

		elseif subKey == "!pos" and GetGameState() == GAME_STATE_PRE_GAME then
			print("Selecting pos " .. subVal)
			local sTeamNameLocal = GetTeamForPlayer(PlayerID) == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
			local remainingPos = RemainingPos[sTeamNameLocal]
			if Utils.HasValue(remainingPos, subVal) then
				local role = tonumber(subVal)
				local playerIndex = PlayerID + 1
				for idx, id in pairs(teamPlayers) do
					if id == PlayerID then playerIndex = idx end
				end
				for index, id in pairs(teamPlayers) do
					if Role.RoleAssignment[sTeamNameLocal][index] == role then
						if IsPlayerBot(id) then
							Role.RoleAssignment[sTeamNameLocal][playerIndex], Role.RoleAssignment[sTeamNameLocal][index] = role, Role.RoleAssignment[sTeamNameLocal][playerIndex]
							if GetTeamForPlayer(PlayerID) == TEAM_DIRE then
								tLaneAssignList[sTeamNameLocal][CorrectDirePlayerIndexToLaneIndex[playerIndex]], tLaneAssignList[sTeamNameLocal][CorrectDirePlayerIndexToLaneIndex[index]] =
									tLaneAssignList[sTeamNameLocal][CorrectDirePlayerIndexToLaneIndex[index]], tLaneAssignList[sTeamNameLocal][CorrectDirePlayerIndexToLaneIndex[playerIndex]]
							else
								tLaneAssignList[sTeamNameLocal][playerIndex], tLaneAssignList[sTeamNameLocal][index] = tLaneAssignList[sTeamNameLocal][index], tLaneAssignList[sTeamNameLocal][playerIndex]
							end
							print('Switch role ok. Team: '..sTeamNameLocal.. ' PID: '..PlayerID..', idx: '..playerIndex..', new role: '..Role.RoleAssignment[sTeamNameLocal][playerIndex])
							print('Switch role ok. Team: '..sTeamNameLocal.. ' PID: '..id..', idx: '..index..', new role: '..Role.RoleAssignment[sTeamNameLocal][index])
						else
							print('Switch role failed: target role belongs to human.')
						end
						break;
					end
				end
			else
				print("Cannot select pos: " .. subVal..' (not available).')
			end

		elseif subKey:match("^!(%d+)pos$") ~= nil and GetGameState() == GAME_STATE_PRE_GAME then
			local x, y = inputStr:match("^!(%d+)pos (%d+)$")
			if x and y then
				print("Swap position for #" .. x .. " to play pos " .. y)
			else
				print("Invalid command format for swapping pos")
				return
			end
			local sTeamNameLocal = GetTeamForPlayer(PlayerID) == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
			local remainingPos = RemainingPos[sTeamNameLocal]
			if Utils.HasValue(remainingPos, y) then
				local role = tonumber(y)
				local playerIndex = PlayerID + 1
				for idx, id in pairs(teamPlayers) do
					if idx == tonumber(x) then playerIndex = idx end
				end
				for index, id in pairs(teamPlayers) do
					if Role.RoleAssignment[sTeamNameLocal][index] == role then
						Role.RoleAssignment[sTeamNameLocal][playerIndex], Role.RoleAssignment[sTeamNameLocal][index] = role, Role.RoleAssignment[sTeamNameLocal][playerIndex]
						if GetTeamForPlayer(PlayerID) == TEAM_DIRE then
							tLaneAssignList[sTeamNameLocal][CorrectDirePlayerIndexToLaneIndex[playerIndex]], tLaneAssignList[sTeamNameLocal][CorrectDirePlayerIndexToLaneIndex[index]] =
								tLaneAssignList[sTeamNameLocal][CorrectDirePlayerIndexToLaneIndex[index]], tLaneAssignList[sTeamNameLocal][CorrectDirePlayerIndexToLaneIndex[playerIndex]]
						else
							tLaneAssignList[sTeamNameLocal][playerIndex], tLaneAssignList[sTeamNameLocal][index] =
								tLaneAssignList[sTeamNameLocal][index], tLaneAssignList[sTeamNameLocal][playerIndex]
						end
						print('Switch role ok. Team: '..sTeamNameLocal.. ' PID: '..PlayerID..', idx: '..playerIndex..', new role: '..Role.RoleAssignment[sTeamNameLocal][playerIndex])
						print('Switch role ok. Team: '..sTeamNameLocal.. ' PID: '..id..', idx: '..index..', new role: '..Role.RoleAssignment[sTeamNameLocal][index])
						break;
					end
				end
			else
				print("Cannot select pos: " .. y..' (not available).')
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

-- Initialize a clean, staggered per-slot schedule once we’re allowed to pick.
-- Slots pick at: base + (slot-1)*step + jitter
local function InitPickScheduleOnce()
	if PickSchedule.initialized then return end

	-- Don’t even initialize until basic preconditions are met
	if (GameTime() < 3.0 and not bLineupReserve)
	or X.IsHumanNotReady(GetTeam())
	or X.IsHumanNotReady(GetOpposingTeam()) then
		return
	end

	-- Tweak these three to taste:
	local base  = GameTime() + 3          -- when the *first* bot may pick
	local step  = GetTeam() * 3           -- spacing between slots
	local jitter_min, jitter_max = 1, 3   -- small variability per slot

	local teamPlayers = GetTeamPlayers(GetTeam(), true)
	for slot = 1, #teamPlayers do
		-- tiny jitter per-slot for a more organic feel
		local jitter = RandomFloat(jitter_min, jitter_max)
		PickSchedule.NextPickAt[slot] = base + (slot - 1) * step + jitter
	end

	PickSchedule.initialized = true

	-- Debug:
	-- print("Pick schedule init @ "..string.format("%.2f", GameTime()))
	-- for i=1,5 do print("slot "..i.." at "..string.format("%.2f", PickSchedule.NextPickAt[i])) end
end

--==============================================================================
-- Think loop
--==============================================================================

function Think()
	if GetGameMode() == GAMEMODE_CM or GetGameMode() == GAMEMODE_REVERSE_CM then
		CaptainMode.CaptainModeLogic(SupportedHeroes);
		CaptainMode.AddToList();
	elseif GetGameMode() == GAMEMODE_1V1MID then
		OneVsOneLogic()
	else
		if (GameTime() < 3.0 and not bLineupReserve)
		or X.IsHumanNotReady(GetTeam())
		or X.IsHumanNotReady(GetOpposingTeam()) then
			if GetGameMode() ~= GAMEMODE_TURBO then return end
		end

		-- Initialize schedule once preconditions are OK
		InitPickScheduleOnce()
		-- If still not initialized, we’re waiting on readiness/3s gate
		if not PickSchedule.initialized then return end

		AllPickHeros()
	end
end

--==============================================================================
-- Human chat helper: map human input to unit name
--==============================================================================

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

--==============================================================================
-- Names per team (cosmetics)
--==============================================================================

local playerNameOverrides = { Radiant = {}, Dire = {} }

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

--==============================================================================
-- Lane assignment plumbing
--==============================================================================

function UpdateLaneAssignments()
	local team = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'

	if GetGameMode() == GAMEMODE_MO then
		Role.RoleAssignment[team] = {2, 2, 2, 2, 2}
		return MidOnlyLaneAssignment
	end
	if GetGameMode() == GAMEMODE_1V1MID then
		return OneVoneLaneAssignment
	end

	if GetGameMode() == GAMEMODE_CM or GetGameMode() == GAMEMODE_REVERSE_CM then
		tLaneAssignList[team] = CaptainMode.CMLaneAssignment(Role.RoleAssignment, userSwitchedRole)
	end

	if GetGameState() == GAME_STATE_HERO_SELECTION or GetGameState() == GAME_STATE_STRATEGY_TIME or GetGameState() == GAME_STATE_PRE_GAME then
		InstallChatCallback(function (attr) SelectHeroChatCallback(attr.player_id, attr.string, attr.team_only); end);
	end

	CorrectPotentialLaneAssignment()
	return tLaneAssignList[team]
end

-- Keep lanes in sync with roles
function AlignLanesBasedOnRoles(team)
	for idx, nRole in pairs(Role.RoleAssignment[team]) do
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

--==============================================================================
-- 1v1 mode (unchanged logic, with policy-aware fallbacks)
--==============================================================================

local oboselect = false;
function OneVsOneLogic()
	local hero;
	if Utils.IsHumanPlayerInTeam(GetTeam()) then
		oboselect = true;
	end

	for _, i in pairs(GetTeamPlayers(GetTeam())) do
		if not oboselect and IsPlayerBot(i) and IsPlayerInHeroSelectionControl(i) and GetSelectedHeroName(i) == "" then
			if Utils.IsHumanPlayerInAnyTeam() then
				hero = GetSelectedHumanHero(GetOpposingTeam());
			else
				hero = X.GetRandomAvailableHero(GetTeam(), tSelectPoolList[2])
				     or sSelectList[2]
			end
			if hero ~= nil then
				SelectHero(i, hero);
				oboselect = true;
				if Utils.HasValue(WeakHeroes, hero) then
					WeakHeroCount[GetTeam()] = WeakHeroCount[GetTeam()] + 1
				end
			end
			return

		elseif oboselect and IsPlayerBot(i) and IsPlayerInHeroSelectionControl(i) and GetSelectedHeroName(i) == "" then
			local tech = 'npc_dota_hero_techies'
			if X.CanPickHero(GetTeam(), tech) then
				SelectHero(i, tech);
			else
				local fallback = X.GetRandomAvailableHero(GetTeam(), tSelectPoolList[2]) or sSelectList[2]
				SelectHero(i, fallback)
				if Utils.HasValue(WeakHeroes, fallback) then
					WeakHeroCount[GetTeam()] = WeakHeroCount[GetTeam()] + 1
				end
			end
			return
		end
	end
end

function GetSelectedHumanHero(team)
	for _, id in pairs(GetTeamPlayers(team)) do
		if not IsPlayerBot(id) and GetSelectedHeroName(id) ~= "" then
			return GetSelectedHeroName(id);
		end
	end
end
