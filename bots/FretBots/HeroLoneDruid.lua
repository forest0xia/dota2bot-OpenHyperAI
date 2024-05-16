-- Dependencies
 -- global debug flag
require 'bots.FretBots.Debug'
 -- Global flags
 require 'bots.FretBots.Flags'
 -- Data Tables and helper functions
require 'bots.FretBots.DataTables'
 -- This registers the Timer helpers
require 'bots.FretBots.Timers'

-- local debug flag
local thisDebug = false
local isDebug = Debug.IsDebug() and thisDebug

-- Instantiate ourself
if HeroLoneDruid == nil then
	HeroLoneDruid = {}
	-- Global bear entity
	HeroLoneDruid.Bear = nil
	-- LD himself
	HeroLoneDruid.Hero = nil
	-- LD's player index
	HeroLoneDruid.PlayerID = nil
end

-- if they don't summon the bear before two minutes, then they don't get items
local bearSpawnCount				= 0
local bearSpawnInterval				= 5
local bearSpawnFailSafe 			= 120
local bearSpawnTimerName 			= 'bearSpawnTimerName'
-- LD Inventory watcher settings.  Initially I tried making this event driven,
-- but the dota inventory events are too disparate to be really useful (e.g.
-- they don't all give the hero as an argument to the event).  So instead we'll
-- be low tech and just check Ld's inventory every so often and see if
-- we need to swap anything to the bear.
local itemCheckInterval				=	10
-- Table of things to move.  At the time of this comment I haven't gotten to
-- test this, but my assumption is that if LD were building say, radiance,
-- and we moved the relic to the bear when he got it, he would buy another
-- relic instead of buying the recipe.  So if we ever move something to the bear,
-- it has to be something we're pretty sure won't screw up LD's buying.
local itemCheckMoveList =
{

}
local itemCheckTimerName			= 'itemCheckTimerName'

-- watches for items in LD's possession and moves them to the bear as appropriate.
function HeroLoneDruid:ItemCheckTimer()
	for i = 1,16 do
		local currentItem = unit:GetItemInSlot(i)
		-- anything?
		if currentItem ~= nil then
			replacedItem = currentItem:GetName()
		end
	end
end

-- Waits for lone druid to summon his bear.  Caches bear entity when this is done.
-- Starts inventory watcher when complete.
function HeroLoneDruid:BearSpawnTimer()
	local isFound = false
	local bear = HeroLoneDruid:FindBear()
	-- bear found, do stuff and then stop this timer
	if bear ~= nil then
		Debug:Print('HeroLoneDruid: Bear Found. Starting LoneDruid item event watcher.')
		-- cache bear entity for convenience
		HeroLoneDruid.Bear = bear
		-- Register hero timer
		Timers:CreateTimer(itemCheckTimerName, {endTime = 1, callback =  HeroLoneDruid['ItemCheckTimer']} )
		-- Remove this timer
		Timers:RemoveTimer(bearSpawnTimerName)
		return nil
	end
	-- bear not found, try again some time later
	bearSpawnCount = bearSpawnCount + bearSpawnInterval
	if bearSpawnCount < bearSpawnFailSafe then
		return bearSpawnInterval
	else
		Debug:Print('Bear not found before fail safe timer reached.')
		Timers:RemoveTimer(bearSpawnTimerName)
		return nil
	end
end

-- Performs initialization activies
-- Right now this whole object is just used to force items onto the lone druid bear, so
-- if a lone druid isn't in the game, this will do nothing
function HeroLoneDruid:Initialize()
	-- If settings aren't enabled, do nothing
	if not Settings.heroSpecific.loneDruid.enabled then
		Debug:Print('Lone Druid Specific Extensions are disabled.  HeroLoneDruid Exiting.')
		return
	end
	for _, unit in pairs(AllUnits) do
		if unit:GetName() == 'npc_dota_hero_lone_druid' then
			-- Cache the hero
			HeroLoneDruid.Hero = unit
			if unit:GetPlayerID() ~= nil then
				HeroLoneDruid.PlayerID = unit:GetPlayerID()
			end
			break
		end
	end
	-- Drop out if lone druid not found
	if HeroLoneDruid.Hero == nil then
			Debug:Print('Lone Druid Specific Extensions are enabled, but Lone Druid is not present.  HeroLoneDruid Exiting.')
		return
	end
	-- The bear doesn't exist until it gets cast once, so start a time to wait for that
	-- This method will cache the bear entity and start the item listener once it spawns
	Timers:CreateTimer(bearSpawnTimerName, {endTime = 1, callback =  HeroLoneDruid['BearSpawnTimer']} )
end

-- returns the lone druid bear entity if it exists
function HeroLoneDruid:FindBear()
	local units = FindUnitsInRadius(
		2,
		Vector(0, 0, 0),
		nil,
		FIND_UNITS_EVERYWHERE,
		3,
		DOTA_UNIT_TARGET_HERO,
		88,
		FIND_ANY_ORDER,
		false);
	for _, unit in pairs(units) do
		if unit:GetName() == 'npc_dota_lone_druid_bear' then
			return unit
		end
	end
	-- nil if not found
	return nil
end

