local X = {}

local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

-- Minimum separation between wards of the SAME type, so vision/detection spreads across
-- the map instead of clustering. Observers use 2x their vision radius (circles touch but
-- don't overlap = maximum coverage). Raise these to spread wards further apart.
local nMinObserverSeparation = 1600 * 2
local nMinSentrySeparation = 1200 * 2

-- Per-spot debounce (seconds): after planting, a spot is on cooldown this long so the bot
-- doesn't re-select it during the cast->spawn gap. Live wards are blocked by IsOtherWardClose.
local nObserverDebounceSeconds = 1

-- Curated cliff ward spots (the only spots bots place wards at).
local WARD_POSITION = {
    [1] = { location = Vector(-4347, -1055), plant_time_obs = 0, plant_time_sentry = 0, }, -- RADIANT_CLIFF_LEFT
    [2] = { location = Vector(-1313, -4367), plant_time_obs = 0, plant_time_sentry = 0, }, -- RADIANT_CLIFF_RIGHT
    [3] = { location = Vector(1034, 3600), plant_time_obs = 0, plant_time_sentry = 0, }, -- DIRE_CLIFF_LEFT
    [4] = { location = Vector(4613, 850), plant_time_obs = 0, plant_time_sentry = 0, }, -- DIRE_CLIFF_RIGHT
    [5] = { location = Vector(-4550, 4867), plant_time_obs = 0, plant_time_sentry = 0, }, -- DIRE_EASY_LINE
    [6] = { location = Vector(4558, -4900), plant_time_obs = 0, plant_time_sentry = 0, }, -- RADIANT_EASY_LINE
}

function X.GetAvailabeObserverWardSpots(bot)
	local availableSpots = {}

	-- Bots only ward the curated cliff spots (WARD_POSITION). A spot is available when it
	-- is passable, has no friendly observer too close, no enemy sentry nearby, and is
	-- either never warded or the previous observer has expired.
	for _, spot in pairs(WARD_POSITION) do
		if not X.IsOtherWardClose(spot.location, 'npc_dota_observer_wards', nMinObserverSeparation, true, false)
		and (spot.plant_time_obs == 0 or (DotaTime() > spot.plant_time_obs + nObserverDebounceSeconds))
		then
			table.insert(availableSpots, spot)
		end
	end

	return availableSpots
end

-- Nearest available observer spot to the bot's current location.
function X.GetClosestObserverWardSpot(bot, spots)
	local cDist = 100000
	local cTarget = nil

	for _, spot in pairs(spots) do
		local dist = GetUnitToLocationDistance(bot, spot.location)
		if dist < cDist then
			cDist = dist
			cTarget = spot
		end
	end

	return cTarget
end

function X.GetPossibleSentryWardSpots(bot)
	local possibleSpots = {}

	-- Bots only sentry the curated cliff spots (WARD_POSITION). A spot is available when it
	-- is passable, has no friendly sentry too close, no existing true sight, and is either
	-- never sentried or the previous sentry has expired.
	for _, spot in pairs(WARD_POSITION) do
		if not X.IsOtherWardClose(spot.location, 'npc_dota_sentry_wards', nMinSentrySeparation, true, false)
		and not J.Site.IsLocationHaveTrueSight(spot.location)
		and (spot.plant_time_sentry == 0 or (DotaTime() > spot.plant_time_sentry + nObserverDebounceSeconds))
		then
			table.insert(possibleSpots, spot)
		end
	end

	return possibleSpots
end

function X.GetClosestSentryWardSpot(bot, spots)
	local cDist = 100000
	local cTarget = nil

	for _, spot in pairs(spots) do
		local dist = GetUnitToLocationDistance(bot, spot.location)
		if dist < cDist then
			cDist = dist
			cTarget = spot
		end
	end

	return cTarget
end

function X.IsOtherWardClose(vLocation, sWardName, nRadius, bTeam, bCheckLifespan)
	local unitList = GetUnitList(UNIT_LIST_ALLIED_WARDS)
	if not bTeam then unitList = GetUnitList(UNIT_LIST_ENEMY_WARDS) end

	for _, ward in pairs(unitList) do
		if J.IsValid(ward)
		and string.find(ward:GetUnitName(), sWardName)
        and GetUnitToLocationDistance(ward, vLocation) <= nRadius
        then
			if bCheckLifespan then
				if sWardName == 'item_ward_observer' and J.GetModifierTime(ward, 'modifier_item_buff_ward') >= 360/2 then
					return true
				end
			else
				return true
			end
		end
	end

	return false
end

return X