---------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI 
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
---------------------------------------------------------------------------
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
-- dota2jmz@163.com QQ:2462331592..
