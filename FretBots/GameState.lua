-- Dependencies
 -- global debug flag
require 'Fretbots.Debug'
 -- Other Flags
require 'Fretbots.Flags'
 -- Utilities
require 'Fretbots.Utilities'
-- DataTables
require 'Fretbots.DataTables'

-- local debug flag
local thisDebug = false;
local isDebug = Debug.IsDebug() and thisDebug;
GameState = nil

-- Other local variables
-- the expectation for the building table is that we'll poll OnEntityKilled
-- for the building name, and if we find it, add this many points to the
-- team that killed it (well, not actually, since they could be denied.
-- The other team, anyway).  As such, there is no need for these to be
-- named, we'll just iterate ipairs over the whole table in OnEntityKilled.
local radiantBuildings 	= dofile('Fretbots.RadiantBuildings')
local direBuildings		= dofile('Fretbots.DireBuildings')
local RADIANT			= 2
local DIRE				= 3

-- For now we'll just calculate this internally and apply it in the bonus methods.
-- Later on we'll consider making it more granular.
-- Yes, I am getting lazier over time.
local throttle 			= 0
local botLead			= 0
-- This determines when we want to start throttling the bots
-- (They are this far ahead)
local throttleThreshold	= 10
-- throttle value is (Max - Lead) / (Max - Threshold)
local throttleMax		= 20

-- Instantiate ourself
if GameState == nil then
	GameState = {}
end

-- Updates the game state.  This is to be called from OnEntityKilled(),
-- but it checks for IsTower and IsVictim, so we know we're getting a
-- building.  Still, safe to check.
function GameState:Update(building)
	-- Drop out if the other method was an idiot
	if not building:IsTower() and not building:IsBuilding() then
		return
	end
	-- get team
	local team = building:GetTeam()
	local name = building:GetName()
	local msg = name..' destroyed: bot lead is '
	-- Compare for the right team
	if team == RADIANT then
		for _, comparison in ipairs(radiantBuildings) do
			if comparison.name == building:GetName() then
				GameState:IncrementBotLead(comparison.value, team)
			end
		end
	elseif team == DIRE then
		for _, comparison in ipairs(direBuildings) do
			if comparison.name == building:GetName() then
				GameState:IncrementBotLead(comparison.value, team)
			end
		end
	end
	msg = msg..botLead
	Debug:Print(msg)
end

-- Returns the current throttle value (making its global accessability moot!)
-- or nil if Throttle is <= 0
-- Also returns the team to which the throttle applies
function GameState:GetThrottle()
	-- if not above threshold, return nil
	if botLead <= throttleThreshold then return nil end
	-- else return the throttle
	throttle = (throttleMax - botLead) / (throttleMax - throttleThreshold)
	-- sanity check!
	if throttle < 0 then
		throttle = 0
	elseif throttle > 1 then
		throttle = 1
	end
	return throttle, BotTeam
end

-- Increments the botLead variable based on points and the team that scored them
-- Note that the team here is the owner of the dead building, so logic is inverted
function GameState:IncrementBotLead(points, team)
	if team ~= BotTeam then
		botLead = botLead + points
	else
		botLead = botLead - points
	end
end


