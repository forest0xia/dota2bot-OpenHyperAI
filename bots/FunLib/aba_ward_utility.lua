local X = {}

local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local nVisionRadius = 1600

-- Radiant Warding Spots
-- Game Start
local RADIANT_GAME_START_MID_1 = Vector(-247, -1089, 128)
local RADIANT_GAME_START_MID_2 = Vector(-1936, 219, 128)
local RADIANT_GAME_START_MID_3 = Vector(192, -1245, 128)
local RADIANT_GAME_START_2 = Vector(1573, -4622, 256)

-- Laning Phase
local RADIANT_LANE_PHASE_1 = Vector(-3971, 1595, 256)
local RADIANT_LANE_PHASE_2 = Vector(-7804, 3814, 128)
local RADIANT_LANE_PHASE_3 = Vector(-1937, 214, 128)
local RADIANT_LANE_PHASE_4 = Vector(-135, 1380, 128)
local RADIANT_LANE_PHASE_5 = Vector(3106, -4055, 256)
local RADIANT_LANE_PHASE_6 = Vector(7939, -5568, 128)

-- Dire Warding Spots
-- Game Start
local DIRE_GAME_START_MID_1 = Vector(-489, 300, 128)
local DIRE_GAME_START_MID_2 = Vector(1384, -498, 128)
local DIRE_GAME_START_MID_3 = Vector(-1121, 1443, 128)
local DIRE_GAME_START_2 = Vector(-1751, 3570, 256)

-- Laning Phase
local DIRE_LANE_PHASE_1 = Vector(-4275, 3520, 128)
local DIRE_LANE_PHASE_2 = Vector(-7047, 5091, 128)
local DIRE_LANE_PHASE_3 = Vector(-1542, 2036, 256)
local DIRE_LANE_PHASE_4 = Vector(1386, -506, 128)
local DIRE_LANE_PHASE_5 = Vector(4196, -4765, 128)
local DIRE_LANE_PHASE_6 = Vector(8390, -4272, 128)

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
						Vector(-5922, 5928, 128),
						Vector(-6834, 3247, 128),
						Vector(-3654, 3793, 128),
					},
	[TOWER_MID_1] = {
						Vector(2452, -2576, 0),
						Vector(-108, -13, 128),
						Vector(-2406, 2231, 0),
					},
	[TOWER_BOT_1] = {
						Vector(5467, -4894, 128),
						Vector(5875, -7195, 256),
						Vector(3109, -4063, 256),
					},

	[TOWER_TOP_2] = {
						Vector(-7931, 1819, 536),
						Vector(-3973, 1598, 256),
						Vector(-4342, -1032, 536),
					},
	[TOWER_MID_2] = {
						Vector(-1285, -4335, 403),
						Vector(-4344, -1024, 536),
						Vector(-860, -2106, 128),
					},
	[TOWER_BOT_2] = {
						Vector(2551, -7068, 128),
						Vector(1576, -4627, 256),
						Vector(-210, -8172, 134),
					},

	[TOWER_TOP_3] = {
						Vector(-6553, -3060, 256),
						Vector(-7507, -958, 256),
						Vector(-4841, -2106, 256),
					},
	[TOWER_MID_3] = {
						Vector(-4344, -3908, 256),
						Vector(-1290, -4338, 403),
						Vector(-4339, -1026, 536),
					},
	[TOWER_BOT_3] = {
						Vector(-1797, -5896, 128),
						Vector(-3619, -6092, 256),
						Vector(-1691, -7687, 134),
					},
}

local InvadeWardSpotDeadEnemyTowerDire = {
	[TOWER_TOP_1] = {
						Vector(-5870, 8023, 256),
						Vector(-1611, 7652, 124),
						Vector(-2238, 4264, 256),
						Vector(1026, 3572, 400),
					},
	[TOWER_MID_1] = {
						Vector(1031, 3569, 400),
						Vector(829, 1583, 128),
						Vector(4610, 764, 528),
						Vector(3443, -700, 256),
					},
	[TOWER_BOT_1] = {
						Vector(4644, -1800, 128),
						Vector(7682, -2583, 256),
						Vector(7695, -1577, 528),
						Vector(5095, -242, 256),
					},

	[TOWER_TOP_2] = {
						Vector(1030, 3568, 400),
						Vector(-1616, 7654, 124),
						Vector(3168, 6605, 256),
						Vector(2339, 4270, 128),
					},
	[TOWER_MID_2] = {
						Vector(4607, 770, 528),
						Vector(3403, 983, 256),
						Vector(1028, 3571, 400),
						Vector(4550, 2872, 256),
						Vector(3383, 4062, 256),
					},
	[TOWER_BOT_2] = {
						Vector(8125, 704, 256),
						Vector(4610, 764, 528),
						Vector(5497, 2661, 256),
					},

	[TOWER_TOP_3] = {
						Vector(2331, 4272, 128),
						Vector(4446, 5554, 256),
					},
	[TOWER_MID_3] = {
						Vector(4470, 3880, 256),
						Vector(5749, 5296, 256),
					},
	[TOWER_BOT_3] = {
						Vector(5998, 3888, 256),
						Vector(5127, 2752, 256),
					},
}

-- #############################################################
-- DIRE
-- #############################################################
local WardSpotAliveTeamTowerDire = {
	[TOWER_TOP_1] = {
						Vector(-8032, 6462, 256),
						Vector(-3874, 5246, 128),
						Vector(-4529, 2137, 128),
					},
	[TOWER_MID_1] = {
						Vector(-1119, 1438, 128),
						Vector(2816, -1451, 256),
						Vector(-1634, 3504, 256),
					},
	[TOWER_BOT_1] = {
						Vector(4328, -3322, 128),
						Vector(4883, -1857, 128),
						Vector(7697, -1581, 528),
					},

	[TOWER_TOP_2] = {
						Vector(-1638, 3507, 256),
						Vector(-1611, 7647, 124),
						Vector(-4167, 6423, 128),
					},
	[TOWER_MID_2] = {
						Vector(3114, -272, 256),
						Vector(1032, 3569, 400),
						Vector(-1641, 3508, 256),
					},
	[TOWER_BOT_2] = {
						Vector(7702, -1582, 528),
						Vector(4608, 769, 528),
						Vector(2822, -1457, 256),
					},

	[TOWER_TOP_3] = {
						Vector(3119, 5729, 256),
						Vector(1029, 3567, 400),
						Vector(941, 5142, 128),
						Vector(1269, 7236, 134),
					},
	[TOWER_MID_3] = {
						Vector(4010, 3487, 256),
						Vector(4607, 770, 528),
						Vector(1732, 2450, 128),
					},
	[TOWER_BOT_3] = {
						Vector(6346, 2655, 256),
						Vector(4611, 764, 528),
						Vector(8034, 761, 256),
					},
}

local InvadeWardSpotDeadEnemyTowerRadiant = {
	[TOWER_TOP_1] = {
						Vector(-3856, 495, 256),
						Vector(-7904, 1791, 535),
						Vector(-7559, 370, 256),
					},
	[TOWER_MID_1] = {
						Vector(-4342, -1024, 536),
						Vector(-3404, -344, 256),
						Vector(-813, -2435, 128),
						Vector(-1287, -4357, 403),
					},
	[TOWER_BOT_1] = {
						Vector(3806, -4584, 128),
						Vector(3937, -7217, 128),
						Vector(2558, -7080, 128),
						Vector(1743, -5084, 256),
						Vector(2033, -8356, 250),
					},

	[TOWER_TOP_2] = {
						Vector(-5282, -1584, 256),
						Vector(-7489, -1117, 256),
						Vector(-5680, -3137, 256),
					},
	[TOWER_MID_2] = {
						Vector(-1290, -4332, 403),
						Vector(-4340, -1031, 536),
						Vector(-3271, -1423, 256),
						Vector(-3788, -4521, 256),
						Vector(-5172, -3414, 256),
						Vector(-4903, -2862, 128),
						Vector(-3086, -4270, 128),
					},
	[TOWER_BOT_2] = {
						Vector(-1289, -4338, 403),
						Vector(-1890, -7873, 134),
						Vector(-3526, -6962, 256),
						Vector(-3611, -5316, 256),
						Vector(-2750, -5278, 128),
					},

	[TOWER_TOP_3] = {
						Vector(-6401, -4283, 256),
					},
	[TOWER_MID_3] = {
						Vector(-4915, -4405, 256),
						Vector(-4908, -4402, 256),
						Vector(-6172, 5639, 256),
					},
	[TOWER_BOT_3] = {
						Vector(-4850, -5935, 256),
					},
}

function X.GetLaningPhaseWardSpots()
	local WardSpotRadiant = {
		RADIANT_LANE_PHASE_1,
		RADIANT_LANE_PHASE_2,
		RADIANT_LANE_PHASE_3,
		RADIANT_LANE_PHASE_4,
		RADIANT_LANE_PHASE_5,
		RADIANT_LANE_PHASE_6,
	}

	local WardSpotDire = {
		DIRE_LANE_PHASE_1,
		DIRE_LANE_PHASE_2,
		DIRE_LANE_PHASE_3,
		DIRE_LANE_PHASE_4,
		DIRE_LANE_PHASE_5,
		DIRE_LANE_PHASE_6,
	}

	if GetTeam() == TEAM_RADIANT
    then
		return WardSpotRadiant
	else
		return WardSpotDire
	end
end

local startSpots = { [TEAM_RADIANT]=nil,[TEAM_DIRE]=nil }
function X.GetGameStartWardSpots()
	if startSpots[GetTeam()] then return startSpots[GetTeam()] end

	local hMidWardSpots = {
		RADIANT_GAME_START_MID_1,
		RADIANT_GAME_START_MID_2,
		RADIANT_GAME_START_MID_3,
	}

	local vWardMidSpot = hMidWardSpots[RandomInt(1, #hMidWardSpots)]

	local WardSpotRadiant = {
		vWardMidSpot,
		RADIANT_GAME_START_2,
	}

	hMidWardSpots = {
		DIRE_GAME_START_MID_1,
		DIRE_GAME_START_MID_2,
		DIRE_GAME_START_MID_3,
	}
	vWardMidSpot = hMidWardSpots[RandomInt(1, #hMidWardSpots)]

	local WardSpotDire = {
		vWardMidSpot,
		DIRE_GAME_START_2,
	}

	if GetTeam() == TEAM_RADIANT
    then
		startSpots[TEAM_RADIANT] = WardSpotRadiant
		return WardSpotRadiant
	else
		startSpots[TEAM_DIRE] = WardSpotDire
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

		if item ~= nil
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

			if member ~= nil
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

				if GetUnitToLocationDistance(bot, ping.location) <= 700
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
		if X.IsWard(ward)
        and GetUnitToLocationDistance(ward, wardLoc) <= nVisionRadius * 1.5
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

		if member ~= nil
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
