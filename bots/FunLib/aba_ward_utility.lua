local X = {}

local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local nVisionRadius = 1600

-- Radiant Warding Spots
-- Game Start
local RADIANT_GAME_START_1 = Vector(-450, 456, 128) -- dire mid lane top left
local RADIANT_GAME_START_1_2 = Vector(719, -369, 128) -- dire mid lane bot right
local RADIANT_GAME_START_2 = Vector(-4000, 4000, 128) -- dire top river enterance besides the first left jungle.

-- Laning Phase
local RADIANT_LANE_PHASE_1 = Vector(2306, -3001, 128)
local RADIANT_LANE_PHASE_2 = Vector(-3048, 1779, 128)
local RADIANT_LANE_PHASE_3 = Vector(-3556, 6446, 128)

-- Dire Warding Spots
-- Game Start
local DIRE_GAME_START_1 = Vector(57, -1335, 128) -- radiant mid lane bot right
local DIRE_GAME_START_1_2 = Vector(-1337, -355, 128) -- radiant mid lane top left
local DIRE_GAME_START_2 = Vector(2026, -3003, 128) -- radiant bot river to jungle enterance

-- Laning Phase
local DIRE_LANE_PHASE_1 = Vector(-5183, 3780, 128) -- radian ward near t1 on the left side of the river top left enterance.
local DIRE_LANE_PHASE_2 = Vector(-773, 1135, 0) 
local DIRE_LANE_PHASE_3 = Vector(3851, -4636, 353)

local nTowerList = {
	TOWER_TOP_1,
	TOWER_MID_1,
	TOWER_BOT_1,
	TOWER_TOP_2,
	TOWER_MID_2,
	TOWER_BOT_2,
	TOWER_TOP_3,
	TOWER_MID_3,
	TOWER_BOT_3,
}

-- #############################################################
-- RADIANT
-- #############################################################
local WardSpotAliveTeamTowerRadiant = {
	[TOWER_TOP_1] = {
						Vector(-3290, 5302, 128),
						Vector(-5217, 2463, 128),
					},
	[TOWER_MID_1] = {
						Vector(-3048, 1779, 128),
						Vector( 449, -1953, 128),
					},
	[TOWER_BOT_1] = {
						Vector(2306, -3001, 128),
						Vector(3897, -4626, 535),
					},

	[TOWER_TOP_2] = {
						Vector(-4575, 469, 256),
						Vector(-7581, 335, 256),
					},
	[TOWER_MID_2] = {
						Vector(-3615, -1757, 256),
						Vector( -410, -2488, 256),
					},
	[TOWER_BOT_2] = {
						Vector(2551, -7177, 407),
						Vector(1297, -5594, 256),
					},

	[TOWER_TOP_3] = {
						Vector(-6558, -3055, 256),
						Vector(-5111, -1788, 256),
					},
	[TOWER_MID_3] = {
						Vector(-4346, -3911, 256),
						Vector(-4346, -3911, 256),
					},
	[TOWER_BOT_3] = {
						Vector( -993, -5074, 256),
						Vector(-3623, -6089, 256),
					},
}

local InvadeWardSpotDeadEnemyTowerDire = {
	[TOWER_TOP_1] = {
						Vector(-4737, 7936, 128),
						Vector(-1545, 6902, 399),
						Vector(-2563, 7593, 128),
						Vector(-1930, 4128, 256),
						Vector( -767, 3599, 527),
						Vector( -844, 4673, 256),
					},
	[TOWER_MID_1] = {
						Vector(1038, 3309, 399),
						Vector( 836, 1950, 128),
						Vector(2054, -777, 527),
						Vector(3440, -704, 256),
					},
	[TOWER_BOT_1] = {
						Vector(4646, -1805, 128),
						Vector(7622, -2553, 256),
						Vector(7677, -1581, 527),
						Vector(5093,  -238, 256),
					},

	[TOWER_TOP_2] = {
						Vector( 462, 4408, 128),
						Vector(  50, 8668, 512),
						Vector(3069, 6554, 256),
						Vector(2334, 4270, 128),
					},
	[TOWER_MID_2] = {
						Vector(4610,  759, 527),
						Vector(3400,  986, 256),
						Vector(1048, 3313, 399),
						Vector(4590, 2915, 256),
					},
	[TOWER_BOT_2] = {
						Vector(8130,  700, 256),
						Vector(4610,  759, 527),
						Vector(7143, 2210, 256),
						Vector(5521, 2649, 256),
					},

	[TOWER_TOP_3] = {
						Vector(3107, 2986, 256),
						Vector(4441, 5559, 256),
					},
	[TOWER_MID_3] = {
						Vector(4474, 3877, 256),
						Vector(5747, 5298, 256),
					},
	[TOWER_BOT_3] = {
						Vector(6003, 3884, 256),
						Vector(5124, 2755, 256),
					},
}

-- #############################################################
-- DIRE
-- #############################################################
local WardSpotAliveTeamTowerDire = {
	[TOWER_TOP_1] = {
						Vector(-2845, 3282, 256),
						Vector(-5163, 2560, 128),
					},
	[TOWER_MID_1] = {
						Vector(-1454, 728, 0),
						Vector(2740, -1604, 256),
					},
	[TOWER_BOT_1] = {
						Vector(3537, -3396, 128),
						Vector(3809,  -986, 256),
					},

	[TOWER_TOP_2] = {
						Vector(-1964, 4150, 256),
						Vector(-1538, 6897, 399),
					},
	[TOWER_MID_2] = {
						Vector(3116, -274, 256),
						Vector(1052, 3306, 399),
					},
	[TOWER_BOT_2] = {
						Vector(7661, -1543, 527),
						Vector(5041,  -369, 256),
						Vector(4616,   756, 527),
					},

	[TOWER_TOP_3] = {
						Vector(3122, 5724, 256),
						Vector(2165, 4029, 128),
					},
	[TOWER_MID_3] = {
						Vector(4007, 3492, 256),
						Vector(3351, 1759, 128),
					},
	[TOWER_BOT_3] = {
						Vector(6350, 2653, 256),
						Vector(4670,  781, 527),
					},
}

local InvadeWardSpotDeadEnemyTowerRadiant = {
	[TOWER_TOP_1] = {
						Vector(-4120, 1499, 535),
						Vector(-7900, 1786, 535),
						Vector(-7561,  372, 256),
						Vector(-4576,  451, 256),
					},
	[TOWER_MID_1] = {
						Vector(-4320, -1028, 535),
						Vector(-3408,  -339, 256),
						Vector(-1305, -2479, 256),
						Vector(-1451, -3310, 256),
						Vector(-1451, -3310, 256),
						Vector(-2582, -3851, 256),
						Vector( -284, -3538, 256),
					},
	[TOWER_BOT_1] = {
						Vector(3851, -4636, 353),
						Vector(4708, -7817, 128),
						Vector(2586, -7189, 407),
						Vector(1263, -5657, 256),
						Vector( 771, -4630, 535),
						Vector(1110, -7836, 128),
					},

	[TOWER_TOP_2] = {
						Vector(-5285, -1585, 256),
						Vector(-8143, -1519, 256),
						Vector(-7373, -2822, 256),
						Vector(-5685, -3139, 256),
					},
	[TOWER_MID_2] = {
						Vector(-1587, -3742, 256),
						Vector(-4334, -1054, 535),
						Vector(-3269, -1425, 256),
						Vector(-3791, -4518, 256),
						Vector(-5167, -3419, 256),
						Vector(-4907, -2860, 128),
						Vector(-3088, -4273, 128),
					},
	[TOWER_BOT_2] = {
						Vector(-1060, -5068, 256),
						Vector(-1314, -7927, 128),
						Vector(-3323, -7154, 256),
						Vector(-3609, -5320, 256),
						Vector(-2755, -5275, 128),
					},

	[TOWER_TOP_3] = {
						Vector(-6401, -4286, 256),
					},
	[TOWER_MID_3] = {
						Vector(-4912, -4403, 256),
						Vector(-4912, -4403, 256),
						Vector(-6170,  5643, 256),
					},
	[TOWER_BOT_3] = {
						Vector(-4853, -5937, 256),
					},
}

function X.GetLaningPhaseWardSpots()
	local WardSpotRadiant = {
		RADIANT_LANE_PHASE_1,
		RADIANT_LANE_PHASE_2,
		RADIANT_LANE_PHASE_3,
	}

	local WardSpotDire = {
		DIRE_LANE_PHASE_1,
		DIRE_LANE_PHASE_2,
		DIRE_LANE_PHASE_3,
	}

	if GetTeam() == TEAM_RADIANT
    then
		return WardSpotRadiant
	else
		return WardSpotDire
	end
end

function X.GetGameStartWardSpots()
	local radianStartWard1
	if (RandomInt(1, 9) >= 5) then
		radianStartWard1 = RADIANT_GAME_START_1_2
	else
		radianStartWard1 = RADIANT_GAME_START_1
	end

	local WardSpotRadiant = {
		radianStartWard1,
		RADIANT_GAME_START_2,
	}

	local direStartWard1
	if (RandomInt(1, 9) >= 5) then
		direStartWard1 = DIRE_GAME_START_1_2
	else
		direStartWard1 = DIRE_GAME_START_1
	end
	local WardSpotDire = {
		direStartWard1,
		DIRE_GAME_START_2,
	}

	if GetTeam() == TEAM_RADIANT
    then
		return WardSpotRadiant
	else
		return WardSpotDire
	end
end

function X.GetWardSpotBeforeTowerFall()
	local wardSpot = {}

	for i = 1, #nTowerList
	do
		local t = GetTower(GetTeam(),  nTowerList[i])

		if t ~= nil
		or (t == GetTower(GetTeam(), TOWER_TOP_3) == nil
			or t == GetTower(GetTeam(), TOWER_MID_3) == nil
			or t == GetTower(GetTeam(), TOWER_BOT_3) == nil)
        then
			if (t == GetTower(GetTeam(), TOWER_TOP_2)
				and GetTower(GetTeam(), TOWER_TOP_1) ~= nil)
			or (t == GetTower(GetTeam(), TOWER_TOP_3)
				and GetTower(GetTeam(), TOWER_TOP_2) ~= nil)
			or (t == GetTower(GetTeam(), TOWER_MID_2)
				and GetTower(GetTeam(), TOWER_MID_1) ~= nil)
			or (t == GetTower(GetTeam(), TOWER_MID_3)
				and GetTower(GetTeam(), TOWER_MID_2) ~= nil)
			or (t == GetTower(GetTeam(), TOWER_BOT_2)
				and GetTower(GetTeam(), TOWER_BOT_1) ~= nil)
			or (t == GetTower(GetTeam(), TOWER_BOT_3)
				and GetTower(GetTeam(), TOWER_BOT_2) ~= nil)
			then
				break
			end

			if GetTeam() == TEAM_RADIANT
            then
				for j = 1, #WardSpotAliveTeamTowerRadiant[nTowerList[i]]
				do
					table.insert(wardSpot, WardSpotAliveTeamTowerRadiant[nTowerList[i]][j])
				end
			else
				for j = 1, #WardSpotAliveTeamTowerDire[nTowerList[i]]
				do
					table.insert(wardSpot, WardSpotAliveTeamTowerDire[nTowerList[i]][j])
				end
			end
		end
	end

	return wardSpot
end

function X.GetWardSpotDeadEnemyTowerDire()
	local wardSpot = {}

	for i = 1, #nTowerList
	do
		local t = GetTower(GetOpposingTeam(),  nTowerList[i])

		if t == nil
        then
			if (t == GetTower(GetOpposingTeam(), TOWER_TOP_2)
				and GetTower(GetOpposingTeam(), TOWER_TOP_1) ~= nil)
			or (t == GetTower(GetOpposingTeam(), TOWER_TOP_3)
				and GetTower(GetOpposingTeam(), TOWER_TOP_2) ~= nil)
			or (t == GetTower(GetOpposingTeam(), TOWER_MID_2)
				and GetTower(GetOpposingTeam(), TOWER_MID_1) ~= nil)
			or (t == GetTower(GetOpposingTeam(), TOWER_MID_3)
				and GetTower(GetOpposingTeam(), TOWER_MID_2) ~= nil)
			or (t == GetTower(GetOpposingTeam(), TOWER_BOT_2)
				and GetTower(GetOpposingTeam(), TOWER_BOT_1) ~= nil)
			or (t == GetTower(GetOpposingTeam(), TOWER_BOT_3)
				and GetTower(GetOpposingTeam(), TOWER_BOT_2) ~= nil)
			then
				break
			end

			if GetTeam() == TEAM_RADIANT
            then
				for j = 1, #InvadeWardSpotDeadEnemyTowerDire[nTowerList[i]]
				do
					table.insert(wardSpot, InvadeWardSpotDeadEnemyTowerDire[nTowerList[i]][j])
				end
			else
				for j = 1, #InvadeWardSpotDeadEnemyTowerRadiant[nTowerList[i]]
				do
					table.insert(wardSpot, InvadeWardSpotDeadEnemyTowerRadiant[nTowerList[i]][j])
				end
			end
		end
	end

	return wardSpot
end

local IsPinged = false
function X.GetItemWard(bot)
	for i = 0, 8
    do
		local item = bot:GetItemInSlot(i)

		if  item ~= nil
		and (item:GetName() == 'item_ward_observer'
			or (item:GetName() == 'item_ward_sentry' and IsPinged))
        then
			return item
		end
	end

	return nil
end

function X.IsPingedByHumanPlayer(bot)
	local nTeamPlayers = GetTeamPlayers(GetTeam())

	for i, id in pairs(nTeamPlayers)
	do
		if not IsPlayerBot(id)
        then
			local member = GetTeamMember(i)

			if  member ~= nil
            and member:IsAlive()
            and GetUnitToUnitDistance(bot, member) < 1200
            then
				local ping = member:GetMostRecentPing()
				local wardType = "item_ward_observer"

				if J.HasItem(bot, "item_ward_sentry")
				then
					wardType = "item_ward_sentry"
				end

				local wardSlot = member:FindItemSlot(wardType)

				if  GetUnitToLocationDistance(bot, ping.location) <= 700
                and DotaTime() - ping.time < 5
                and wardSlot == -1
				and not ping.normal_ping
				then
					IsPinged = true
					return true, ping.location
				end

				IsPinged = false
			end
		end
	end

	return false, 0
end

function X.GetAvailableSpot(bot)
	local availableSpot = {}

	if DotaTime() < 0
	then
		for _, spot in pairs(X.GetGameStartWardSpots())
		do
			if not X.IsOtherWardClose(spot)
			then
				table.insert(availableSpot, spot)
			end
		end

		return availableSpot
	end

	if J.IsInLaningPhase()
	then
		local nSpots = X.CheckSpots(X.GetLaningPhaseWardSpots())
		for _, spot in pairs(nSpots)
		do
			if not X.IsOtherWardClose(spot)
			then
				table.insert(availableSpot, spot)
			end
		end
	end

	local nSpots = X.CheckSpots(X.GetWardSpotBeforeTowerFall())
	for _, spot in pairs(nSpots)
    do
		if not X.IsOtherWardClose(spot)
        then
			table.insert(availableSpot, spot)
		end
	end

	nSpots = X.CheckSpots(X.GetWardSpotDeadEnemyTowerDire())
	for _, spot in pairs(nSpots)
    do
		if not X.IsOtherWardClose(spot)
        then
			table.insert(availableSpot, spot)
		end
	end

	return availableSpot
end

function X.IsOtherWardClose(wardLoc)
	local nWardList = GetUnitList(UNIT_LIST_ALLIED_WARDS)

	for _, ward in pairs(nWardList)
    do
		if  X.IsWard(ward)
        and GetUnitToLocationDistance(ward, wardLoc) <= nVisionRadius
        then
			return true
		end
	end

	return false
end

function X.GetClosestSpot(bot, spots)
	local cDist = 100000
	local cTarget = nil

	for _, spot in pairs(spots)
    do
		local dist = GetUnitToLocationDistance(bot, spot)

		if dist < cDist
        then
			cDist = dist
			cTarget = spot
		end
	end

	return cTarget, cDist
end

function X.IsWard(ward)
    local bot = GetBot()

    if J.HasItem(bot, "item_ward_sentry")
    then
        return ward:GetUnitName() == "npc_dota_sentry_wards"
    elseif J.HasItem(bot, "item_ward_observer")
    then
        return ward:GetUnitName() == "npc_dota_observer_wards"
    end
end

function X.GetHumanPing()
	local nTeamPlayers = GetTeamPlayers(GetTeam())

	for _, id in pairs(nTeamPlayers)
	do
		local member = GetTeamMember(id)

		if  member ~= nil
        and not member:IsBot()
        then
			return member:GetMostRecentPing()
		end
	end

	return nil
end

function X.IsThereSentry(loc)
	local nWardList = GetUnitList(UNIT_LIST_ALLIED_WARDS)

	for _, ward in pairs(nWardList)
    do
		if ward ~= nil
		and ward:GetUnitName() == "npc_dota_sentry_wards"
        and GetUnitToLocationDistance(ward, loc) <= 600
        then
			return true
		end
	end

	return false
end

function X.GetWardType()
	if J.HasItem(GetBot(), 'item_ward_sentry') then return 'sentry' end
	return 'observer'
end

-- Can't refer to the actual (invalid) objects (wards) once garbage collected.
-- So affected spot will just be on cooldown according to the duration of the wards.
function X.CheckSpots(bSpots)
	local bot = GetBot()
	local sSpots = J.Utils.Deepcopy(bSpots)

	for i = 1, #bot.WardTable
	do
		if bot.WardTable[i] ~= nil
		and X.GetWardType() == bot.WardTable[i].type
		and DotaTime() < bot.WardTable[i].timePlanted + bot.WardTable[i].duration
		then
			for j = #sSpots, 1, -1
			do
				if J.GetDistance(sSpots[j], bot.WardTable[i].loc) < 50
				and not X.IsThereSentry(sSpots[j])
				then
					-- print('Ward Spot: '..tostring(sSpots[j])..' on cooldown!')
					table.remove(sSpots, j)
				end
			end
		end
	end

	return sSpots
end

return X