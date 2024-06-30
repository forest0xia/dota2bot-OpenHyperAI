---------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI 
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
---------------------------------------------------------------------------
local Utils = require( GetScriptDirectory()..'/FunLib/utils')
local overrides = require( GetScriptDirectory()..'/FunLib/aba_global_overrides')

if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return
end

local X = {}
local bot = GetBot()

--[[
	Mode Desires - These can be useful for making sure all mode desires as using a common language for talking about their desire.
	BOT_MODE_DESIRE_NONE - 0
	BOT_MODE_DESIRE_VERYLOW - 0.1
	BOT_MODE_DESIRE_LOW - 0.25
	BOT_MODE_DESIRE_MODERATE - 0.5
	BOT_MODE_DESIRE_HIGH - 0.75
	BOT_MODE_DESIRE_VERYHIGH - 0.9
	BOT_MODE_DESIRE_ABSOLUTE - 1.0
]]


function GetDesire()
	if GetGameMode() == GAMEMODE_1V1MID or GetGameMode() == GAMEMODE_MO then
		return 1
	end

	-- if bot.isBuggyHero == nil then
	-- 	bot.isBuggyHero = Utils.BuggyHeroesDueToValveTooLazy[bot:GetUnitName()] ~= nil
	-- end
	-- if bot.isBuggyHero -- and DotaTime() < 3 * 60
	-- then
	-- 	local assignedLaneLoc = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
	-- 	if GetUnitToLocationDistance(bot, assignedLaneLoc) > 1000 then
	-- 		bot:Action_MoveToLocation(assignedLaneLoc)
	-- 		return 0
	-- 	end
	-- 	return 0.228
	-- end

	local currentTime = DotaTime()
	local botLV = bot:GetLevel()

	if currentTime <= 10
	then
		return 0.268
	end
	
	if currentTime <= 9 * 60
		and botLV <= 7
	then
		return 0.446
	end
	
	if currentTime <= 12 * 60
		and botLV <= 11
	then
		return 0.369
	end
	
	if botLV <= 17
	then
		return 0.228
	end

	return 0

end

-- if bot.isBuggyHero == nil then
-- 	bot.isBuggyHero = Utils.BuggyHeroesDueToValveTooLazy[bot:GetUnitName()] ~= nil
-- end
-- if bot.isBuggyHero
-- then
-- 	local assignedLaneLoc = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
-- 	if GetUnitToLocationDistance(bot, assignedLaneLoc) > 1000
-- 	then
-- 		function Think()
-- 			bot:Action_MoveToLocation(assignedLaneLoc)
-- 		end
-- 	end
	
	-- function Think()
	-- 	local mostFarmDesireLane = bot:GetAssignedLane()
	-- 	local tpLoc = GetLaneFrontLocation(GetTeam(), mostFarmDesireLane, 0)
	-- 	local enemyHeroes = bot:GetNearbyHeroes(900, true, BOT_MODE_NONE)
	-- 	local runModeTowers = bot:GetNearbyTowers(700, true)
	-- 	local enemyLaneCreeps = bot:GetNearbyLaneCreeps(550, true);
	-- 	if #enemyHeroes <= 0 and #runModeTowers <= 0 and #enemyLaneCreeps <= 2 then
	-- 		bot:Action_MoveToLocation(tpLoc)
	-- 	end
	-- end
-- end
