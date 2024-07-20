
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Utils = require( GetScriptDirectory()..'/FunLib/utils')

local bot = GetBot()
local botName = bot:GetUnitName()

local local_mode_attack_generic
if bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end

if Utils.BuggyHeroesDueToValveTooLazy[botName] then
	local_mode_attack_generic = dofile( GetScriptDirectory().."/FunLib/bugged_heroes_generic/mode_attack_generic" )
end

if local_mode_attack_generic ~= nil then
	function GetDesire() return local_mode_attack_generic.GetDesire() end
	function Think() return local_mode_attack_generic.Think() end
end