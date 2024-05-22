-- Creates stats tables for units
-- containts helper functions for manipulating data

-- Global Debug flag
require 'bots.FretBots.Debug';
-- Other Flags
require 'bots.FretBots.Flags'
-- Makes a unit strong
require 'bots.FretBots.BuffUnit'
-- Settings
require 'bots.FretBots.Settings'
-- Convenience Utilities
require 'bots.FretBots.Utilities'
-- Neutral items
require 'bots.FretBots.NeutralItems'

local role 			= require('bots.FretBots.RoleUtility')
local radiantTowers	= dofile('bots.FretBots.RadiantTowers')
local direTowers	= dofile('bots.FretBots.DireTowers')

-- local debug flags
local thisDebug = false
local isDebug = Debug.IsDebug() and thisDebug
local isChatDebug = Debug.IsDebug() and false
local isVerboseDebug = Debug.IsDebug() and false
-- Set to true to initialize data tables on loading this file every time
local isSoloDebug = false
-- Set to true to buff Fret if he's in the game
local isBuff = false
-- Warn Fret if he left this on
if isBuff then
	Utilities:Print('Hey Fret, isBuff is True!', MSG_BAD)
end

-- Globals
Bots = {}
Players = {}
PlayerBots = {}
AllUnits = {}
DireTowers = {}
RadiantTowers = {}

BotTeam = 0
HumanTeam = 0

-- convenient constants for dumb valve integers
local RADIANT = 2
local DIRE = 3

-- globlal constants for lane identification
LANE_UNKNOWN	= 0
LANE_SAFE 		= 1
LANE_MID 		= 2
LANE_OFF 		= 3

-- Instantiate the class
if DataTables == nil then
	DataTables = class({})
end

-- Sets up data tables, buffs Fret for debug
function DataTables:Initialize()
	Debug:Print('Initializing DataTables')
	-- Don't do this more than once.
	--if Flags.isStatsInitialized then return end;
	-- Lifted From Anarchy - Props
	Units = FindUnitsInRadius(
		2,
		Vector(0, 0, 0),
		nil,
		FIND_UNITS_EVERYWHERE,
		3,
		DOTA_UNIT_TARGET_HERO,
		88,
		FIND_ANY_ORDER,
		false)

	Bots = nil
	Bots={}
	Players={}
	AllUnits = {}
	for i,unit in pairs(Units) do
		local id = PlayerResource:GetSteamID(unit:GetMainControllingPlayer());
		local isFret = Debug:IsFret(id);
		-- Buff Fret for Debug purposes
		if isFret and not Flags.isDebugBuffed and isBuff then
			BuffUnit:Hero(unit)
			Flags.isDebugBuffed = true
			end
		-- Initialize data tables for this unit
		DataTables:GenerateStatsTables(unit)
	end
	Debug:Print('There are '..#Bots..' bots!')

	-- Purge human side bots
	DataTables:PurgeHumanSideBots()
	-- Get Towers (Used for determining bot role, eventually)
	DataTables:GetTowers()
	-- Assign roles to bots
	DataTables:AssignBotRoles()
	-- Sort Bots Table by role for convenience
	Bots = DataTables:SortBotsByRole()
	-- Set all bots to find tier 1 neutrals
	NeutralItems:InitializeFindTimings()
	-- Set Initialized Flag
	Flags.isStatsInitialized = true

	-- debug prints
	if isDebug then
		if Players ~= nil then
			for i,unit in pairs(Players) do
				print('Stats table for Player '.. i)
				DeepPrintTable(unit.stats)
			end
		end
		if Bots ~= nil then
			for i,unit in pairs(Bots) do
				print('Stats table for Bot '.. i)
				DeepPrintTable(unit.stats)
			end
		end
	end

end

-- Gets tower entities
function DataTables:GetTowers()
	buildings = FindUnitsInRadius(2,
									Vector(0, 0, 0),
									nil,
									FIND_UNITS_EVERYWHERE,
									3,
									DOTA_UNIT_TARGET_BUILDING,
									88,
									FIND_ANY_ORDER,
									false);
	for _,building in pairs (buildings) do
		-- get team
		local team = building:GetTeam()
		local name = building:GetName()
		-- Compare for the right team
		if team == RADIANT then
			-- I'm sure someone fancier than myself would just parse the string, but I am lazy today
			-- This only happens once anyway
			if name == radiantTowers.TopTier4 then
				RadiantTowers.TopTier4 = building
			elseif name == radiantTowers.TopTier3 then
				RadiantTowers.TopTier3 = building
			elseif name == radiantTowers.TopTier2 then
				RadiantTowers.TopTier2 = building
			elseif name == radiantTowers.TopTier1 then
				RadiantTowers.TopTier1 = building
			elseif name == radiantTowers.BotTier4 then
				RadiantTowers.BotTier4 = building
			elseif name == radiantTowers.BotTier3 then
				RadiantTowers.BotTier3 = building
			elseif name == radiantTowers.BotTier2 then
				RadiantTowers.BotTier2 = building
			elseif name == radiantTowers.BotTier1 then
				RadiantTowers.BotTier1 = building
			elseif name == radiantTowers.MidTier3 then
				RadiantTowers.MidTier3 = building
			elseif name == radiantTowers.MidTier2 then
				RadiantTowers.MidTier2 = building
			elseif name == radiantTowers.MidTier1 then
				RadiantTowers.MidTier1 = building
			end
		elseif team == DIRE then
			if name == direTowers.TopTier4 then
				DireTowers.TopTier4 = building
			elseif name == direTowers.TopTier3 then
				DireTowers.TopTier3 = building
			elseif name == direTowers.TopTier2 then
				DireTowers.TopTier2 = building
			elseif name == direTowers.TopTier1 then
				DireTowers.TopTier1 = building
			elseif name == direTowers.BotTier4 then
				DireTowers.BotTier4 = building
			elseif name == direTowers.BotTier3 then
				DireTowers.BotTier3 = building
			elseif name == direTowers.BotTier2 then
				DireTowers.BotTier2 = building
			elseif name == direTowers.BotTier1 then
				DireTowers.BotTier1 = building
			elseif name == direTowers.MidTier3 then
				DireTowers.MidTier3 = building
			elseif name == direTowers.MidTier2 then
				DireTowers.MidTier2 = building
			elseif name == direTowers.MidTier1 then
				DireTowers.MidTier1 = building
			end
		end
	end
end


-- Generates various data used to track bot stats
function DataTables:GenerateStatsTables(unit)
	-- Is this a bot?
	local thisIsBot = false
	local thisRole = 0
	local thisTeam = 0
	local thisId = 0
	local steamId = PlayerResource:GetSteamID(unit:GetMainControllingPlayer())
	-- Drop out for non-real hero units
	if not DataTables:IsRealHero(unit) then return end
	-- name for debug purposes
	local thisName = unit:GetName()
	-- Is bot?
	if PlayerResource:GetSteamID(unit:GetMainControllingPlayer())==PlayerResource:GetSteamID(100) then
		thisIsBot = true
		Utilities:InsertUnique(Bots, unit)
	else
		Utilities:InsertUnique(Players, unit)
	end
	Utilities:InsertUnique(AllUnits, unit)
	-- PlayerID, Team, Role
	if unit:GetPlayerID() ~= nil then
		thisId = unit:GetPlayerID()
		thisTeam=PlayerResource:GetTeam(thisId)
		thisRole = 0;
	end
	thisRole = DataTables:GetRole(thisName)

	-- create a stats table for the bot
	local stats =
	{
		-- base strength
		baseStrength = unit:GetBaseStrength(),
		-- base agility
		baseAgility = unit:GetBaseAgility(),
		-- base intellect
		baseIntellect = unit:GetBaseIntellect(),
		-- base Armor
		baseArmor = unit:GetPhysicalArmorBaseValue(),
		-- base Magic Resist
		baseMagicResist = unit:GetBaseMagicalResistanceValue(),
		-- str gain
		strengthGain = unit:GetStrengthGain(),
		-- agi gain
		agilityGain = unit:GetAgilityGain(),
		-- int gain
		intellectGain = unit:GetIntellectGain(),
		-- Number of punishments given to this player so far
		repurcussionCount =	0,
		-- Amount of repurcussions earned
		repurcussionTarget = 0,
		-- Number of kills
		kills =	0,
		-- Number of deaths: There is listener for this, we should register and track there
		deaths = 0,
		-- If KillStreak gets large, negatively affect multiplier
		killStreak = 0,
		-- If DeathStreak grows, enhance multiplier
		deathStreak = 0,
		-- teamNetWorth could be useful for a multiplier for bonuses
		teamNetWorth = 0,
		-- enemyTeamNetWorth could be useful for a multiplier for bonuses
		enemyTeamNetWorth = 0,
		-- netowrth
		netWorth = 0,
		-- Bot Team Kills
		botTeamKills = 0,
		-- Current human team kill advantage
		humanKillAdvantage = 0,
		-- Human Team kills
		humanTeamKills = 0,
		-- Is this a bot?
		isBot = thisIsBot,
		-- Team
		team = thisTeam,
		-- Role
		role = thisRole,
		-- Damage Table (by type)
		damageTable = {DAMAGE_TYPE_PHYSICAL=0, DAMAGE_TYPE_MAGICAL=0, DAMAGE_TYPE_PURE=0},
		-- Unit name
		internalName = thisName,
		-- Better unit name (actual hero name)
		name = Utilities:GetName(thisName),
		-- Skill
		skill = DataTables:GetSkill(thisName, thisRole, thisIsBot),
		-- Current death bonus chances
		chance =
		{
			gold 		= 0,
			armor 		= 0,
			magicResist = 0,
			levels 		= 0,
			neutral 	= 0,
			stats 		= 0
		},
		-- Death bonus awards
		awards =
		{
			gold 		= 0,
			armor 		= 0,
			magicResist = 0,
			levels 		= 0,
			neutral	    = 0,
			stats 		= 0
		},
		-- Lane weights (lower values indicate bot is probably in that lane)
		laneWeights =
		{
			bot = -1,
			mid = -1,
			top = -1
		},
		-- Currently assigned lane
		lane = LANE_UNKNOWN,
		-- Has role been assigned? (for dynamic role determination)
		isRoleAssigned = false,
		-- current level of neutral item
		neutralTier = 0,
		-- Timing for next level of neutral item
		neutralTiming = 0,
		-- current tier of neutralItems found (i.e. spawned by this hero's timer)
		neutralsFound = 0,
		-- Hero isMelee
		isMelee = role.IsMelee(unit:GetBaseAttackRange()),
		-- player ID
		id = thisId
	}
	-- Reduce human skill
	if not thisIsBot then stats.skill = stats.skill * 0.5 end
	-- Insert the stats object to the bot
	unit.stats = stats;
	-- update non-accruing deathBonus chances since they will never change
	for _, award in pairs(Settings.deathBonus.order) do
		if not Settings.deathBonus.accrue[award] then
			unit.stats.chance[award] = Settings.deathBonus.chance[award]
		end
	end
	if (isDebug) then
		print('Data tables initialized for ' ..thisName .. '. Unit ID: ' .. tostring(stats.id))
	end
	-- Warn humans about bot skill if enabled and skill is high
	if Settings.skill.isWarn and stats.skill > Settings.skill.warningThreshold and thisIsBot then
		Utilities:Print(stats.name.. ' is very talented!',  Utilities:GetPlayerColor(stats.id), ATTENTION)
	end
end

-- Called by OnEntityKilled to update stats of the victim
function DataTables:DoDeathUpdate(victim, killer)
	-- drop out if no stats table
	if victim.stats == nil then return end
	-- Always update team kills
	victim.stats.botTeamKills = PlayerResource:GetTeamKills(BotTeam)
	victim.stats.humanTeamKills = PlayerResource:GetTeamKills(HumanTeam)
	victim.stats.humanKillAdvantage = victim.stats.humanTeamKills - victim.stats.botTeamKills
	-- ignore kills by non-heroes (they won't have stats tables)
	if killer.stats == nil then return end
	-- don't track players
	if not victim.stats.isBot then return end
	-- Most of these numbers are predicated on being killed by the enemy team (ignore denies)
	if victim.stats.team == killer.stats.team then return end
	-- get current kills/deaths (as opposed to stats table)
	local kills = PlayerResource:GetKills(victim.stats.id)
	-- Determine the killstreak at the time of death
	local killStreak = kills - victim.stats.kills
	-- if killstreak at death is zero, increment death streak
	victim.stats.deathStreak = victim.stats.deathStreak + 1
	-- Kill streak is obviously zero now
	victim.stats.killStreak = 0
	-- Update deaths
	victim.stats.deaths = PlayerResource:GetDeaths(victim.stats.id)
	-- Update kills
	victim.stats.kills = kills
	-- Update Team Worths
	victim.stats.teamNetWorth = DataTables:GetTeamNetWorth(victim.stats.team)
	victim.stats.enemyTeamNetWorth = DataTables:GetTeamNetWorth(killer.stats.team)
	if isDebug then
		print('Updated stats table for ' .. victim.stats.name)
		DeepPrintTable(victim.stats.chance)
		DeepPrintTable(victim.stats.awards)
	end
end

-- Get team net worth
function DataTables:GetTeamNetWorth(team)
	local net = 0;
	for _,unit in pairs(AllUnits) do
		if unit.stats.team == team then
			net = net + PlayerResource:GetNetWorth(unit.stats.id)
		end
	end
	return net
end

-- Returns the net worth of the comparable position on the human side
-- or zero if there is no mathing human
function DataTables:GetRoleNetWorth(bot)
	local worths = {}
	for _,unit in pairs(AllUnits) do
		if unit.stats.team ~= bot.stats.team then
			table.insert(worths,PlayerResource:GetNetWorth(unit.stats.id))
		end
	end
	Utilities:SortHighToLow(worths)
	if worths[bot.stats.role] ~= nil then
		return worths[bot.stats.role]
	else
		return 0
	end
end

-- Returns the GPM the comparable position on the human side
-- or zero if there is no mathing human
function DataTables:GetRoleGPM(bot)
	local data = {}
	local names = {}
	for _,unit in pairs(Players) do
		local num = PlayerResource:GetGoldPerMin(unit.stats.id)
		table.insert(data,num)
		table.insert(names, unit.stats.name)
	end
	Utilities:SortHighToLow(data)
	if isVerboseDebug then
		print('GPM Table:')
		DeepPrintTable(data)
	end
	if data[bot.stats.role] ~= nil then
		return data[bot.stats.role], names[bot.stats.role]
	-- specific debug case, pretend we have more players than we do
	elseif isDebug and #Players == 1 then
		return data[1] / bot.stats.role, names[1]
	else
		return 0
	end
end

-- Returns the XPM of the comparable position on the human side
-- or zero if there is no matching human
function DataTables:GetRoleXPM(bot)
	local data = {}
	local names = {}
	for _,unit in pairs(Players) do
		local num = PlayerResource:GetXPPerMin(unit.stats.id)
		table.insert(data,num)
		table.insert(names, unit.stats.name)
	end
	Utilities:SortHighToLow(data)
	if isVerboseDebug then
		print('XPM Table:')
		DeepPrintTable(data)
	end
	-- edge case: bot mid is pos2 but the human mid will probably be 1st in this chart
	-- so swap these
	local role = bot.stats.role
	if role == 2 then
		role = 1
	elseif role == 1 then
		role = 2
	end
	if data[role] ~= nil then
		return data[role], names[role]
	-- specific debug case, pretend we have more players than we do
	elseif isDebug and #Players == 1 then
		return data[1] / role, names[1]
	else
		return 0
	end
end

-- Returns GPM and XPM tables for humans
function DataTables:GetPerMinuteTables()
	local gpm = {}
	local xpm = {}
	local names = {}
	for _,unit in pairs(Players) do
		local gp = PlayerResource:GetGoldPerMin(unit.stats.id)
		local xp = PlayerResource:GetXPPerMin(unit.stats.id)
		table.insert(gpm,gp)
		table.insert(xpm,xp)
		table.insert(names, unit.stats.name)
	end
	-- specific debug case, pretend we have more players than we do
	if isDebug and #Players == 1 then
		for i=2,5 do
			table.insert(gpm, gpm[1] / i)
			table.insert(xpm, xpm[1] / i)
		end
	end
	Utilities:SortHighToLow(gpm)
	Utilities:SortHighToLow(xpm)
	-- Special case: since these tables are consumed by role, swap XP for 1 and 2
	local temp = xpm[1]
	xpm[1] = xpm[2]
	xpm[2] = temp
	return gpm, xpm
end

-- returns a flat multiplier to represent the skill of the bot, combined with their role.
-- This affects all numeric bonuses
function DataTables:GetSkill(name, role, isBot)
	-- valid roles only
	if role < 1 or role > 5 then return 0 end
	-- remember math.Random only returns integers, so multiply / divide by 100
	local skill = math.random(Settings.skill.variance[role][1] * 100, Settings.skill.variance[role][2] * 100) / 100
	return skill
end

-- removes bots on the human team from the bots table
-- note that if there are humans on both sides, it will purge the side with more humans
function DataTables:PurgeHumanSideBots()
	-- determine humans per side
	local radiant = 0
	local dire = 0
	for _,unit in pairs(AllUnits) do
		if not unit.stats.isBot and unit.stats.team == RADIANT then
			radiant = radiant + 1
		elseif not unit.stats.isBot and unit.stats.team == DIRE then
			dire = dire + 1
		end
	end
	if isDebug then
		print('Radiant Humans: '..radiant..' Dire Humans: '..dire)
	end
	local team
	local countToRemove
	if radiant > dire then
		team = RADIANT
		HumanTeam = RADIANT
		BotTeam = DIRE
		countToRemove = 5 - radiant
	else
		team = DIRE
		HumanTeam = DIRE
		BotTeam = RADIANT
		countToRemove = 5 - dire
		end
	if isDebug then
		print('Removing '..countToRemove..' bots from the human side.')
	end
	local attempts = 0
	local removed = 0
	while removed < countToRemove and attempts < countToRemove do
		attempts = attempts + 1
		for i, unit in pairs(Bots) do
			if unit.stats.team == team then
				table.remove(Bots,i)
				removed = removed + 1
				print('Removing '..unit.stats.name..' from the bots list.')
				table.insert(PlayerBots, unit)
				break
			end
		end
	end
end

-- Both support bots will initially be set to position four.
-- Make one bot support 5 (at random)
function DataTables:SetBotPositionFive()
	for _, bot in pairs(Bots) do
		-- The first position four selected is the unlucky one
		if bot.stats.role == 4 then
			bot.stats.role = 5
			break
		end
	end
end

function DataTables:GetRole(hero)
	-- Carry?
	if role.CanBeSafeLaneCarry(hero) then
		if isDebug then print(hero..': role: '..1) end
		return 1
	-- MidLane
	elseif role.CanBeMidlaner(hero) then
		if isDebug then print(hero..': role: '..2) end
		return 2
	-- Offlane
	elseif role.CanBeOfflaner(hero) then
		if isDebug then print(hero..': role: '..3) end
		return 3
	-- Support is slightly more tricky
	elseif role.CanBeSupport(hero) then
		if isDebug then print(hero..': role: '..4) end
		return 4
	else
		if isDebug then print(hero..': role: '..5) end
		return 5
	end
end

-- Returns true if the unit is an actual hero and not a hero-like unit
function DataTables:IsRealHero(unit)
	return unit:IsHero() and unit:IsRealHero() and not unit:IsIllusion() and not unit:IsClone()
end

-- Assigns role positions to bots
-- Base role positions are determined by
function DataTables:AssignBotRoles()
	local assignedRoles = {false, false, false, false, false}
	local roleNames = {'', '', '', '', ''}
	local roleBuckets = { {}, {}, {}, {}, {}}
	-- Add bots to their preferred role bucket
	for index, bot in pairs(Bots) do
		table.insert(roleBuckets[bot.stats.role], bot)
	end
	-- iterate over buckets
	for _, bucket in ipairs(roleBuckets) do
		-- iterate over bucket members and assign best role
		for _, bot in ipairs(bucket) do
			local preferredRole = DataTables:GetBestPossibleRole(bot.stats.role, assignedRoles)
			if preferredRole ~= nil then
				bot.stats.role = preferredRole
				roleNames[preferredRole] = bot.stats.name
				assignedRoles[preferredRole] = true
			end
		end
	end
end

-- Returns the nearest available role to what the bot wants
-- Note that assignedRoles should be a table of five booleans
function DataTables:GetBestPossibleRole(preferredRole, assignedRoles)
	-- Trivial case: role they want is available
	if not (assignedRoles[preferredRole]) then
		return preferredRole
	end
	-- Random decision: Cores (1-5) search top down, Supports (4-5) search bottom up
	if preferredRole <= 3 then
		for i=1,5 do
			if not (assignedRoles[i]) then
				return i
			end
		end
		-- if we made it this far all the roles are full
		return nil
	end

	-- Support only can make it this far
	for i=5,1,-1 do
		if not (assignedRoles[i]) then
			return i
		end
	end
	-- if we made it this far all the roles are full
	return nil
end

-- Sorts the bots table by role
function DataTables:SortBotsByRole()
	local sortedData = {}
	for i = 1,#Bots do
		table.insert(sortedData,i)
	end
	for _,bot in pairs(Bots) do
		if type(bot) == 'table' then
		sortedData[bot.stats.role] = bot
		end
	end
	-- ensure all slots are bots
	for i=5,1,-1 do
			if type(sortedData[i]) ~= 'table' then
			table.remove(sortedData, i)
		end
	end
	return sortedData
end

-- returns a players Player table by their steam ID
function DataTables:GetPlayerById(id)
	for _, player in ipairs(Players) do
		if player.stats.id == id then
			return player
		end
	end
	return nil
end

-- Initialize (if Debug)
if isSoloDebug then
	DataTables:Initialize()
	DeepPrintTable(Bots)
end
