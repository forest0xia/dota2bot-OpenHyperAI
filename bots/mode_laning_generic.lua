
local Utils = require( GetScriptDirectory()..'/FunLib/utils')

local bot = GetBot()
local botName = bot:GetUnitName()
local local_mode_laning_generic

local skipLaningState = {
	count = 0,
	lastCheckTime = 0,
	checkGap = 3,
}

if bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end

if Utils.BuggyHeroesDueToValveTooLazy[botName] then
	local_mode_laning_generic = dofile( GetScriptDirectory().."/FunLib/override_generic/mode_laning_generic" )
end

function GetDesire()
	if DotaTime() - skipLaningState.lastCheckTime < skipLaningState.checkGap then
		if skipLaningState.count > 6 then
			print('[WARN] Bot ' ..botName.. ' switching modes too often, now stop it for laning to avoid conflicts.')
			return 0
		end
	else
		skipLaningState.lastCheckTime = DotaTime()
		skipLaningState.count = 0
	end

	if local_mode_laning_generic ~= nil and local_mode_laning_generic.GetDesire ~= nil then return local_mode_laning_generic.GetDesire() end

	if GetGameMode() == GAMEMODE_1V1MID or GetGameMode() == GAMEMODE_MO then
		return 1
	end

	local currentTime = DotaTime()
	if GetGameMode() == 23 then
		currentTime = currentTime * 1.65
	end

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

function OnStart()
	skipLaningState.count = skipLaningState.count + 1
end

if local_mode_laning_generic ~= nil then
	function Think() return local_mode_laning_generic.Think() end
end