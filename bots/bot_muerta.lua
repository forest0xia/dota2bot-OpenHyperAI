
local bot = GetBot()

local X = dofile(GetScriptDirectory() .. "/BotLib/" .. string.gsub(bot:GetUnitName(), "npc_dota_", ""));

function Think()
	if bot:GetUnitName() == 'npc_dota_hero_muerta' then
		X.Think()
	else
		print('[ERROR] Failed to load script for Muerta')
	end
end
