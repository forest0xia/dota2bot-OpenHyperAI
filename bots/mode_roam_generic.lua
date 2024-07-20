local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local bot = GetBot()
local team = GetTeam()
local X = { }

if bot:IsInvulnerable() or not bot:IsHero() or not string.find(bot:GetUnitName(), "hero") or bot:IsIllusion() then
	return
end

function GetDesire()

	-- local botLvl = bot:GetLevel()

	-- -- mid player roaming
	-- if J.GetPosition(bot) == 2 then
	-- 	if botLvl >= 6 and botLvl <= 15 then
			
	-- 	end
	-- end

	return BOT_MODE_DESIRE_NONE

end
