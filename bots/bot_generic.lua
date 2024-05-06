----------------------------------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI 
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------

local bot = GetBot()
local botName = bot:GetUnitName()

if bot:IsInvulnerable()
	or not bot:IsHero()
	or bot:IsIllusion()
	or not string.find( botName, "hero" )
then
	return
end

local BotBuild = dofile(GetScriptDirectory() .. "/BotLib/" .. string.gsub(bot:GetUnitName(), "npc_dota_", ""));

if BotBuild == nil
then
	print('[ERROR] No build config file found for bot: '..bot:GetUnitName())
	return
end

function MinionThink(hMinionUnit)
	BotBuild.MinionThink(hMinionUnit)
end

-- local origin_Think
-- if origin_Think == nil then
-- 	origin_Think = Think
-- end

-- if botName == 'npc_dota_hero_muerta' then
-- 	Think = BotBuild.Think
-- else
-- 	Think = origin_Think
-- end
