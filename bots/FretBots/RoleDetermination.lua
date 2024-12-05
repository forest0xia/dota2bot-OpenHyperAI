-- Dependencies
 -- global debug flag
require 'bots.FretBots.Debug'
-- Timers
require 'bots.FretBots.Timers'
local Localization = require 'bots/FunLib/localization'

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
local BotRoleDeterminationTime = 10
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
	-- If there are less than 5 bots (i.e. they have a human), don't even bother.
	-- far too many extra cases to handle.
	
	for team = 2, 3 do
	if #AllBots[team] < 5 then
		Debug:Print('The bots have human players on their team. Dynamic role assignment disabled.')
		return
	end
	for _, bot in ipairs(AllBots[team]) do
		local top = bot.stats.laneWeights.top
		local mid = bot.stats.laneWeights.mid
		local bottom = bot.stats.laneWeights.bot
		if BotTeam == TEAM_DIRE then
			if top < mid and top < bottom then
				bot.stats.lane = LANE_SAFE
				laneCounts.safe = laneCounts.safe + 1
			elseif mid < top and mid < bottom then
				bot.stats.lane = LANE_MID
				laneCounts.mid = laneCounts.mid + 1
			elseif	bottom < mid and bottom < top then
				bot.stats.lane = LANE_OFF
				laneCounts.off = laneCounts.off + 1
			else
				-- lane was initialized to LANE_UNKNOWN in DataTables, so leave that alone
				Debug:Print('This should have been really unlikely, but there was a lane tie!')
			end
		else
			if top < mid and top < bottom then
				bot.stats.lane = LANE_OFF
				laneCounts.off = laneCounts.off + 1
			elseif mid < top and mid < bottom then
				bot.stats.lane = LANE_MID
				laneCounts.mid = laneCounts.mid + 1
			elseif	bottom < mid and bottom < top then
				bot.stats.lane = LANE_SAFE
				laneCounts.safe = laneCounts.safe + 1
			else
				-- lane was initialized to LANE_UNKNOWN in DataTables, so leave that alone
				Debug:Print('This should have been really unlikely, but there was a lane tie!')
			end
		end
		Debug:Print(bot.stats.name..': lane: '..bot.stats.lane..': top '..bot.stats.laneWeights.top..': mid '..bot.stats.laneWeights.mid..': bot '..bot.stats.laneWeights.bot)
	end
	-- So now we have the lane for each bot, and know the role they want.  Time to go
	-- through all the scenarios and juggle.

	-- Typical case
	if laneCounts.safe == 2 and laneCounts.mid == 1 and laneCounts.off == 2 then
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 1))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 2))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 3))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 4))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 5))
		AllBots[team] = RoleDeterminationBots
	-- def. trilane
	elseif laneCounts.safe == 3 and laneCounts.mid == 1 and laneCounts.off == 1 then
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 1))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 2))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 3))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 4))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 5))
		AllBots[team] = RoleDeterminationBots
	-- off. trilane
	elseif laneCounts.safe == 1 and laneCounts.mid == 1 and laneCounts.off == 3 then
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 1))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 2))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 3))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 4))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF,5))
		AllBots[team] = RoleDeterminationBots
	-- dual mid, solo off
	elseif laneCounts.safe == 2 and laneCounts.mid == 2 and laneCounts.off == 1 then
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 1))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 2))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 3))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 4))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 5))
		AllBots[team] = RoleDeterminationBots
	-- dual mid, solo safe
	elseif laneCounts.safe == 2 and laneCounts.mid == 2 and laneCounts.off == 1 then
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 1))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 2))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 3))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 4))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 5))
		AllBots[team] = RoleDeterminationBots
	-- Things start getting wacky here
	-- tri safe, dual mid
	elseif laneCounts.safe == 3 and laneCounts.mid == 2 then
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 1))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 2))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 3))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 4))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 5))
		AllBots[team] = RoleDeterminationBots
	-- tri off, dual mid
	elseif laneCounts.off == 3 and laneCounts.mid == 2 then
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 1))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 2))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 3))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_MID, 4))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 5))
		AllBots[team] = RoleDeterminationBots
	-- tri off, dual safe
	elseif laneCounts.off == 3 and laneCounts.safe == 2 then
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 1))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 2))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 3))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 4))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 5))
		AllBots[team] = RoleDeterminationBots
	-- tri safe, dual off
	elseif laneCounts.safe == 3 and laneCounts.off == 2 then
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 1))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 2))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_OFF, 3))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 4))
		table.insert(RoleDeterminationBots, RoleDetermination:GetBestBot(LANE_SAFE, 5))
		AllBots[team] = RoleDeterminationBots
	else
		--If we got here, the bots are trying something too strange to bother with.
		Debug:Print('I consider the current case too edge to bother fixing.  Dynamic roles have not been assigned.')
	end
end
end

-- Iterates over the Bots table and finds the best bot for this role
-- It's assumed we'll work top down (1 to 5, that is), so all it really does
-- is find the first bot that is in the right lane and has not been assigned.
function RoleDetermination:GetBestBot(lane, role)
	for team = 2, 3 do
	-- typical case, bot assigned to right lane and not yet assigned
	for _, bot in ipairs(AllBots[team]) do
		if bot.stats.lane == lane and not bot.stats.isRoleAssigned then
			bot.stats.isRoleAssigned = true
			bot.stats.role = role
			Debug:Print('Picking '..bot.stats.name..' for lane '..lane..' and role '..role..'.')
			return bot
		end
	end
	-- This shouldn't happen, but if we get here then we didn't detect a bot
	-- for the desired lane. Just give 'em the best we got
	for _, bot in ipairs(AllBots[team]) do
		if not bot.stats.isRoleAssigned then
			bot.stats.isRoleAssigned = true
			bot.stats.role = role
			return bot
		end
	end
	-- This should double never happen, means all bots are already reassigned.
	Debug:Print('Something has gone horribly wrong.  All bots have already been assigned roles.')
end
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

