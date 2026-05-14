-- Dependencies
 -- global debug flag
require 'bots.FretBots.Debug'
-- Timers
require 'bots.FretBots.Timers'
local Localization = require 'bots/FunLib/localization'

-- Hero position weights from the main bot system (covers all 127 heroes).
-- Try multiple require paths since FretBots runs in a different Lua context.
local HeroPositions = {}
local function tryLoadWeights()
	-- Try bot-script-style path first
	local ok, mod = pcall(require, GetScriptDirectory()..'/FunLib/aba_hero_pos_weights')
	if ok and mod and mod.HeroPositions then
		HeroPositions = mod.HeroPositions
		return true
	end
	-- Try dot-separated path (server-side context)
	ok, mod = pcall(require, 'bots.FunLib.aba_hero_pos_weights')
	if ok and mod and mod.HeroPositions then
		HeroPositions = mod.HeroPositions
		return true
	end
	return false
end
local bWeightsLoaded = tryLoadWeights()

-- Get position weight for a hero (1-5). Returns 0 if not found.
local function GetHeroPosWeight(heroName, pos)
	if not bWeightsLoaded then return 0 end
	local weights = HeroPositions[heroName]
	if weights and weights[pos] then
		return weights[pos]
	end
	return 0
end

-- Instantiate ourself
if RoleDetermination == nil then
	RoleDetermination = {}
end

-- local debug flag
local thisDebug = true
local isDebug = Debug.IsDebug() and thisDebug

-- other local vars
local botRoleDeterminationTimerName = 'botRoleDeterminationTimerName'
-- Time at which to stop the BotRoleDetermination timer and declare rols
local BotRoleDeterminationTime = 20
-- Bots found to be in each lane
local laneCounts =
{
	safe = 0,
	mid = 0,
	off = 0
}

-- Temporarily global
RoleDeterminationBots = {}

-- Attempts to determine bot roles by looking at their distance from
-- respective towers to determine lane position, and then assigning
-- from top down based on an arbitrary farm priority list
-- Note that the DataTables (Bots in particular) need to have been populated
-- prior to starting this
function RoleDetermination:Timer()
	-- Sanity Check
	-- if AllBots == nil or AllBots[2] == nil or AllBots[3] == nil then
	if AllBots == nil then
		Debug:Print('DataTables not yet initialized!')
		Timers:RemoveTimer(botRoleDeterminationTimerName)
		return nil
	end
	-- Get Game Time
	local dotaTime = Utilities:GetTime()
	-- If done, declare roles, stop timer
	if dotaTime > BotRoleDeterminationTime then
		RoleDetermination:DetermineRoles()
		RoleDetermination:AnnounceRoles()
		Timers:RemoveTimer(botRoleDeterminationTimerName)
		Debug:Print('RoleDeterminationTimer complete. Unregistering.')
		return nil
	end
	-- The goal here is to track the tower to which they were closest after
	-- the horn sounds. This timer should ideally track for less than one
	-- minute so that we can resort the Bots array prior to the first
	-- PerMinuteTimer tick.
	for team = 2, 3 do

	for _, bot in ipairs(AllBots[team]) do
		local midWeight = 0
		local topWeight = 0
		local botWeight = 0

		if BotTeam == TEAM_RADIANT then
			midWeight = CalcDistanceBetweenEntityOBB(bot, RadiantTowers.MidTier1)
			topWeight = CalcDistanceBetweenEntityOBB(bot, RadiantTowers.TopTier1)
			botWeight = CalcDistanceBetweenEntityOBB(bot, RadiantTowers.BotTier1)
		else
			midWeight = CalcDistanceBetweenEntityOBB(bot, DireTowers.MidTier1)
			topWeight = CalcDistanceBetweenEntityOBB(bot, DireTowers.TopTier1)
			botWeight = CalcDistanceBetweenEntityOBB(bot, DireTowers.BotTier1)
		end
		-- save closest values
		if bot.stats.laneWeights.mid > midWeight or bot.stats.laneWeights.mid < 0 then
			bot.stats.laneWeights.mid = midWeight
		end
		if bot.stats.laneWeights.top > topWeight or bot.stats.laneWeights.top < 0 then
			bot.stats.laneWeights.top = topWeight
		end
		if bot.stats.laneWeights.bot > botWeight or bot.stats.laneWeights.bot < 0 then
			bot.stats.laneWeights.bot = botWeight
		end
	end
end
	-- rerun in one second
	return 1
end

-- Determines lane roles when the timer is complete
-- As of this moment, we still do an initial sort based
-- on the legacy role table, so the bots will have already been sorted
-- based on their preferred role as best possible, so for the wacky edge
-- cases where they Send AM and Medusa offlane together can be
-- resolved by just assigning the higher role to the one that's already
-- got a higher role, and the support role to the loser.
-- I've seen a couple of trilanes, and once a trilane AND dual mid with
-- no one in the remaining lane.  Have not seen four in one lane, but
-- whatever, we'll try to handle it!
-- All Possible scenarios, and the plan for each:
-- Typical Case: 		Safe: 1, 5 			Mid: 2 				Off: 3, 4
-- Def. Tri: 			Safe: 1, 4, 5 		Mid: 2, 			Off: 3
-- Off. Tri: 			Safe: 3 			Mid: 2 				Off: 1, 4 ,5
-- Dual Mid: 			Safe: 1, 5			Mid: 2, 4	  		Off: 3
-- Why?					Tri: 1, 3, 5		Other: 2, 4
-- Double Why??	  		Quad: 1, 3, 4, 5	Other: 2
-- Deathball			Lane: 1, 2, 3, 4, 5

function RoleDetermination:DetermineRoles()
	for team = 2, 3 do
		if #AllBots[team] < 1 then
			Debug:Print('Team '..team..' has no bots. Skipping.')
			goto continue_team
		end

		-- RESET per-team state
		laneCounts = { safe = 0, mid = 0, off = 0 }
		RoleDeterminationBots = {}

		-- Reset assignment flags
		for _, bot in ipairs(AllBots[team]) do
			bot.stats.isRoleAssigned = false
		end

		-- Determine each bot's lane based on tower proximity
		-- Radiant: top = offlane, bot = safe lane
		-- Dire: top = safe lane, bot = offlane
		-- Note: DIRE is local to DataTables.lua, use DOTA_TEAM_BADGUYS or raw value 3
		local bIsDire = (team == 3 or team == DOTA_TEAM_BADGUYS)
		for _, bot in ipairs(AllBots[team]) do
			local top = bot.stats.laneWeights.top
			local mid = bot.stats.laneWeights.mid
			local bottom = bot.stats.laneWeights.bot

			if top <= mid and top <= bottom then
				bot.stats.lane = bIsDire and LANE_SAFE or LANE_OFF
			elseif mid <= top and mid <= bottom then
				bot.stats.lane = LANE_MID
			else
				bot.stats.lane = bIsDire and LANE_OFF or LANE_SAFE
			end

			if bot.stats.lane == LANE_SAFE then laneCounts.safe = laneCounts.safe + 1
			elseif bot.stats.lane == LANE_MID then laneCounts.mid = laneCounts.mid + 1
			elseif bot.stats.lane == LANE_OFF then laneCounts.off = laneCounts.off + 1
			end

			Debug:Print(bot.stats.name..': lane: '..bot.stats.lane
				..': top '..bot.stats.laneWeights.top
				..': mid '..bot.stats.laneWeights.mid
				..': bot '..bot.stats.laneWeights.bot)
		end

		Debug:Print('Team '..team..' lane counts: safe='..laneCounts.safe..' mid='..laneCounts.mid..' off='..laneCounts.off)

		-- Assign roles respecting LANE FIRST, then use weights to pick the
		-- best role within that lane. Lane is the strongest signal:
		--   Safe lane → pos 1 (carry) or pos 5 (hard support)
		--   Mid lane → pos 2 (mid)
		--   Off lane → pos 3 (offlane) or pos 4 (soft support)
		--
		-- When only ONE bot is in a 2-role lane (human has the other slot),
		-- pick whichever role the hero has higher weight for. E.g., if Witch
		-- Doctor is solo bot in safe lane, WD gets pos 5 (not pos 1) because
		-- WD's pos 5 weight (50) > pos 1 weight (5).

		local availableRoles = {}
		for role = 1, 5 do availableRoles[role] = true end

		-- Group bots by lane
		local botsByLane = { [LANE_SAFE] = {}, [LANE_MID] = {}, [LANE_OFF] = {} }
		for _, bot in ipairs(AllBots[team]) do
			if bot.stats.lane and botsByLane[bot.stats.lane] then
				table.insert(botsByLane[bot.stats.lane], bot)
			end
		end

		-- Assign mid first (unambiguous: only pos 2)
		for _, bot in ipairs(botsByLane[LANE_MID]) do
			if availableRoles[2] then
				bot.stats.isRoleAssigned = true
				bot.stats.role = 2
				availableRoles[2] = false
				table.insert(RoleDeterminationBots, bot)
				Debug:Print('Lane->Role: '..bot.stats.name..' mid -> pos 2')
			end
		end

		-- Assign safe lane (pos 1 and pos 5)
		local safeBots = botsByLane[LANE_SAFE]
		if #safeBots == 1 then
			-- Solo bot in safe lane: pick whichever role fits better
			local bot = safeBots[1]
			local heroName = bot.stats.heroName or bot.stats.name or ''
			local w1 = GetHeroPosWeight(heroName, 1)
			local w5 = GetHeroPosWeight(heroName, 5)
			local bestRole = (w1 >= w5 and availableRoles[1]) and 1 or 5
			if not availableRoles[bestRole] then bestRole = (bestRole == 1) and 5 or 1 end
			if availableRoles[bestRole] then
				bot.stats.isRoleAssigned = true
				bot.stats.role = bestRole
				availableRoles[bestRole] = false
				table.insert(RoleDeterminationBots, bot)
				Debug:Print('Lane->Role: '..bot.stats.name..' safe -> pos '..bestRole..' (w1='..w1..', w5='..w5..')')
			end
		elseif #safeBots >= 2 then
			-- Two+ bots: highest pos 1 weight gets carry, rest get pos 5
			table.sort(safeBots, function(a, b)
				local na = a.stats.heroName or a.stats.name or ''
				local nb = b.stats.heroName or b.stats.name or ''
				return GetHeroPosWeight(na, 1) > GetHeroPosWeight(nb, 1)
			end)
			for i, bot in ipairs(safeBots) do
				local role = (i == 1 and availableRoles[1]) and 1 or 5
				if not availableRoles[role] then role = (role == 1) and 5 or 1 end
				if availableRoles[role] then
					bot.stats.isRoleAssigned = true
					bot.stats.role = role
					availableRoles[role] = false
					table.insert(RoleDeterminationBots, bot)
					Debug:Print('Lane->Role: '..bot.stats.name..' safe -> pos '..role)
				end
			end
		end

		-- Assign off lane (pos 3 and pos 4)
		local offBots = botsByLane[LANE_OFF]
		if #offBots == 1 then
			local bot = offBots[1]
			local heroName = bot.stats.heroName or bot.stats.name or ''
			local w3 = GetHeroPosWeight(heroName, 3)
			local w4 = GetHeroPosWeight(heroName, 4)
			local bestRole = (w3 >= w4 and availableRoles[3]) and 3 or 4
			if not availableRoles[bestRole] then bestRole = (bestRole == 3) and 4 or 3 end
			if availableRoles[bestRole] then
				bot.stats.isRoleAssigned = true
				bot.stats.role = bestRole
				availableRoles[bestRole] = false
				table.insert(RoleDeterminationBots, bot)
				Debug:Print('Lane->Role: '..bot.stats.name..' off -> pos '..bestRole..' (w3='..w3..', w4='..w4..')')
			end
		elseif #offBots >= 2 then
			table.sort(offBots, function(a, b)
				local na = a.stats.heroName or a.stats.name or ''
				local nb = b.stats.heroName or b.stats.name or ''
				return GetHeroPosWeight(na, 3) > GetHeroPosWeight(nb, 3)
			end)
			for i, bot in ipairs(offBots) do
				local role = (i == 1 and availableRoles[3]) and 3 or 4
				if not availableRoles[role] then role = (role == 3) and 4 or 3 end
				if availableRoles[role] then
					bot.stats.isRoleAssigned = true
					bot.stats.role = role
					availableRoles[role] = false
					table.insert(RoleDeterminationBots, bot)
					Debug:Print('Lane->Role: '..bot.stats.name..' off -> pos '..role)
				end
			end
		end

		-- Remaining unassigned bots: assign by weight to remaining roles
		for role = 1, 5 do
			if availableRoles[role] then
				local best = RoleDetermination:GetBestBot(nil, role, team)
				if best then
					table.insert(RoleDeterminationBots, best)
					availableRoles[role] = false
				end
			end
		end

		-- Sort by role number for consistency
		table.sort(RoleDeterminationBots, function(a, b) return a.stats.role < b.stats.role end)
		AllBots[team] = RoleDeterminationBots
		::continue_team::
	end
end

-- Finds the best bot for a role from a specific lane and team.
-- Among unassigned bots in the right lane, picks the one with the highest
-- position weight (e.g., Anti-Mage has weight 90 for pos 1).
-- Falls back to first unassigned bot if no weights are available.
function RoleDetermination:GetBestBot(lane, role, nTeam)
	if not AllBots[nTeam] then return nil end

	local bestBot = nil
	local bestWeight = -1

	-- Find the bot in this lane with the highest weight for this role
	for _, bot in ipairs(AllBots[nTeam]) do
		if bot.stats.lane == lane and not bot.stats.isRoleAssigned then
			local heroName = bot.stats.heroName or bot.stats.name or 'unknown'
			local weight = GetHeroPosWeight(heroName, role)
			if weight > bestWeight then
				bestWeight = weight
				bestBot = bot
			end
		end
	end

	if bestBot then
		bestBot.stats.isRoleAssigned = true
		bestBot.stats.role = role
		Debug:Print('Picking '..bestBot.stats.name..' (weight: '..bestWeight..') for lane '..lane..' role '..role..' team '..nTeam)
		return bestBot
	end

	-- Fallback: no bot in desired lane, pick unassigned bot with highest weight
	bestBot = nil
	bestWeight = -1
	for _, bot in ipairs(AllBots[nTeam]) do
		if not bot.stats.isRoleAssigned then
			local heroName = bot.stats.heroName or bot.stats.name or 'unknown'
			local weight = GetHeroPosWeight(heroName, role)
			if weight > bestWeight then
				bestWeight = weight
				bestBot = bot
			end
		end
	end

	if bestBot then
		bestBot.stats.isRoleAssigned = true
		bestBot.stats.role = role
		Debug:Print('Fallback: '..bestBot.stats.name..' (weight: '..bestWeight..') for role '..role..' team '..nTeam)
		return bestBot
	end

	Debug:Print('All bots already assigned for team '..nTeam..'.')
	return nil
end

function RoleDetermination:AnnounceRoles()
	Utilities:Print(Localization.Get('fret_role_determined'))
	for team = 2, 3 do
		if team == 2 and #AllBots[team] >= 1 then
			Utilities:Print(Localization.Get('fret_role_rad'))
		elseif team == 3 and #AllBots[team] >= 1 then
			Utilities:Print(Localization.Get('fret_role_dire'))
		end
		for _, bot in ipairs(AllBots[team]) do
			-- Print this role to chat
			local msg = Utilities:ColorString(Localization.Get('fret_role_position')..bot.stats.role..': '.. bot.stats.name .. ': ' .. bot.stats.skill, Utilities:GetPlayerColor(bot.stats.id))
			Utilities:Print(msg)
		end
	end
end

-- Starts the role determination timer
function RoleDetermination:Register()
	Debug:Print('Registering RoleDeterminationTimer.')
	Timers:CreateTimer(botRoleDeterminationTimerName, {endTime = 1, callback = RoleDetermination['Timer']} )
end

-- OnGameRulesStateChange callback -- registers timers we only want to run after the game starts
function RoleDetermination:OnGameRulesStateChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		RoleDetermination:Register()
	end
end

-- Registers timers (or listens to events that register timers)
function RoleDetermination:Initialize()
	if not Flags.isRoleDeterminationTimerInitialized then
		-- if not enabled in settings, then just quit
		if not Settings.isDynamicRoleAssignment then
			Flags.isRoleDeterminationTimerInitialized = true
			Debug:Print('Dynamic Role Assignment is not enabled.')
		end
		-- Determine where we are
		local state =  GameRules:State_Get()
		-- various ways to implement based on game state
		-- Are we entering this after the horn blew?
		if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			 -- then immediately start timer
			 RoleDetermination:Register()
		-- is game over? Return if so
		elseif state == DOTA_GAMERULES_STATE_POST_GAME or state == DOTA_GAMERULES_STATE_DISCONNECT then
			return
		-- otherwise we are pre-horn and should register a game state listener
		-- that will register once the horn sounds
		else
			ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( RoleDetermination, "OnGameRulesStateChange" ), self)
			print('Game not in progress.  Registering RoleDetermination GameState Listener.')
		end
		Flags.isRoleDeterminationTimerInitialized = true
	end
end

