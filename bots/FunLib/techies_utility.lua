local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local nRadius = 350

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

----------
-- Radiant Mines Center Spots
----------
local MineSpotAliveTeamTowerRadiant = {
	[TOWER_TOP_1] = {
						Vector(-5011, 2799, 74),
						Vector(-4288, 2089, 76),
						Vector(-3663, 3500, 128),
					},
	[TOWER_MID_1] = {
						Vector(-1921, 377, 68),
						Vector(-1459, 1120, 0),
						Vector(1030, -1195, 0),
						Vector(1916, -2890, 128),
					},
	[TOWER_BOT_1] = {
						Vector(3821, -3474, 128),
						Vector(7285, -4665, 128),
						Vector(7908, -5795, 128),
					},

	[TOWER_TOP_2] = {
						Vector(-5011, 2799, 74), -- T1
						Vector(-4288, 2089, 76), -- T1
						Vector(-3663, 3500, 128), -- T1
						Vector(-7798, 1156, 256),
						Vector(-4150, -48, 256),
					},
	[TOWER_MID_2] = {
						Vector(-1921, 377, 68), -- M1
						Vector(-1459, 1120, 0), -- M1
						Vector(1030, -1195, 0), -- M1
						Vector(1916, -2890, 128), -- M1
						Vector(-3345, -1644, 210),
						Vector(-846, -2191, 256),
						Vector(-1587, -3529, 256),
					},
	[TOWER_BOT_2] = {
						Vector(3821, -3474, 128), -- B1
						Vector(7285, -4665, 128), -- B1
						Vector(7908, -5795, 128), -- B1
						Vector(1241, -7744, 128),
						Vector(1109, -4812, 256),
					},

	[TOWER_TOP_3] = {
						Vector(-5011, 2799, 74), -- T1
						Vector(-4288, 2089, 76), -- T1
						Vector(-3663, 3500, 128), -- T1
						Vector(-7798, 1156, 256), -- T2
						Vector(-4150, -48, 256), -- T2
						Vector(-5298, -1721, 202),
						Vector(-7723, -2107, 256),
					},
	[TOWER_MID_3] = {
						Vector(-1921, 377, 68), -- M1
						Vector(-1459, 1120, 0), -- M1
						Vector(1030, -1195, 0), -- M1
						Vector(1916, -2890, 128), -- M1
						Vector(-3345, -1644, 210), -- M2
						Vector(-846, -2191, 256), -- M2
						Vector(-1587, -3529, 256), -- M2
						Vector(-3057, -4569, 128),
						Vector(-4906, -2730, 128),
					},
	[TOWER_BOT_3] = {
						Vector(3821, -3474, 128), -- B1
						Vector(7285, -4665, 128), -- B1
						Vector(7908, -5795, 128), -- B1
						Vector(1241, -7744, 128), -- B2
						Vector(1109, -4812, 256), -- B2
						Vector(-969, -4866, 256),
						Vector(-1200, -8400, 128),
						Vector(-2145, -7385, 128),
					},
}

-------
-- Dire Mines Center Spots
-------
local MineSpotAliveTeamTowerDire = {
	[TOWER_TOP_1] = {
						Vector(-5273, 4810, 128),
						Vector(5609, 6573, 128),
						Vector(-3314, 3704, 195),
					},
	[TOWER_MID_1] = {
						Vector(-1655, 850, 0),
						Vector(-1655, 850, 0),
						Vector(1187, -1476, 0),
						Vector(1187, -1476, 0),
						Vector(3194, -661, 256),
					},
	[TOWER_BOT_1] = {
						Vector(5108, -2320, 128),
						Vector(8068, -2248, 256),
						Vector(4640, -3424, 128),
					},

	[TOWER_TOP_2] = {
						Vector(-5273, 4810, 128), -- T1
						Vector(5609, 6573, 128), -- T1
						Vector(-3314, 3704, 195), -- T1
						Vector(-2250, 4830, 256),
						Vector(-2737, 6813, 128),
						Vector(-1454, 3012, 256),
					},
	[TOWER_MID_2] = {
						Vector(-1655, 850, 0), -- M1
						Vector(-1655, 850, 0), -- M1
						Vector(1187, -1476, 0), -- M1
						Vector(1187, -1476, 0), -- M1
						Vector(3194, -661, 256), -- M1
						Vector(683, 1807, 128),
						Vector(2532, 1304, 128),
						Vector(3575, 1481, 128),
					},
	[TOWER_BOT_2] = {
						Vector(5108, -2320, 128), -- B1
						Vector(8068, -2248, 256), -- B1
						Vector(4640, -3424, 128), -- B1
						Vector(5235, -984, 256),
						Vector(5107, 600, 256),
						Vector(8270, -59, 256),
					},

	[TOWER_TOP_3] = {
						Vector(-5273, 4810, 128), -- T1
						Vector(5609, 6573, 128), -- T1
						Vector(-3314, 3704, 195), -- T1
						Vector(-2250, 4830, 256), -- T2
						Vector(-2737, 6813, 128), -- T2
						Vector(-1454, 3012, 256), -- T2
						Vector(1948, 6918, 128),
						Vector(-161, 5172, 128),
					},
	[TOWER_MID_3] = {
						Vector(-1655, 850, 0), -- M1
						Vector(-1655, 850, 0), -- M1
						Vector(1187, -1476, 0), -- M1
						Vector(1187, -1476, 0), -- M1
						Vector(3194, -661, 256), -- M1
						Vector(683, 1807, 128), -- M2
						Vector(2532, 1304, 128), -- M2
						Vector(3575, 1481, 128), -- M2
						Vector(4248, 1999, 128),
						Vector(2578, 3729, 128),
					},
	[TOWER_BOT_3] = {
						Vector(5108, -2320, 128), -- B1
						Vector(8068, -2248, 256), -- B1
						Vector(4640, -3424, 128), -- B1
						Vector(5235, -984, 256), -- B2
						Vector(5107, 600, 256), -- B2
						Vector(8270, -59, 256), -- B2
						Vector(4248, 1999, 128),
						Vector(7072, 1376, 128),
					},
}

function X.GetMineSpotsBeforeTowerFall()
	local mineSpots = {}

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
				for j = 1, #MineSpotAliveTeamTowerRadiant[nTowerList[i]]
				do
					table.insert(mineSpots, MineSpotAliveTeamTowerRadiant[nTowerList[i]][j])
				end
			else
				for j = 1, #MineSpotAliveTeamTowerDire[nTowerList[i]]
				do
					table.insert(mineSpots, MineSpotAliveTeamTowerDire[nTowerList[i]][j])
				end
			end
		end
	end

	return mineSpots
end

function X.GetAvailableSpot()
	local availableSpot = {}

    for _, spot in pairs(X.GetMineSpotsBeforeTowerFall())
    do
		table.insert(availableSpot, spot)
	end

	return availableSpot
end

function X.IsOtherMinesClose(loc)
	for _, mine in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
		if  X.IsMines(mine)
        and GetUnitToLocationDistance(mine, loc) <= nRadius
        then
			return true
		end
	end

	return false
end

function X.GetClosestSpot(bot, spotList)
    local cDist = 100000
	local cTarget = nil

	for _, spot in pairs(spotList)
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

function X.IsMines(mine)
    return mine:GetUnitName() == 'npc_dota_techies_land_mine'
end

return X