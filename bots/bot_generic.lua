require( GetScriptDirectory()..'/FunLib/utils' )

local bot = GetBot()
local botName = bot:GetUnitName()

if bot:IsInvulnerable()
	or not bot:IsHero()
	or bot:IsIllusion()
	or not string.find( botName, "hero" )
then
	return
end

local function IsValidUnit(unit)
	return unit ~= nil
	   and not unit:IsNull()
	   and unit:IsAlive()
end

local BotBuild = dofile(GetScriptDirectory() .. "/BotLib/" .. string.gsub(botName, "npc_dota_", ""));

if BotBuild == nil
then
	print('[ERROR] No build config file found for bot: '..botName)
	return
end

function MinionThink(hMinionUnit)
	if not IsValidUnit(hMinionUnit) then return end
	
	BotBuild.MinionThink(hMinionUnit, bot)
end