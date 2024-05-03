----------------------------------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI 
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------


-- Overridding GetBot to be able to override it's instance methods to all units, e.g. HasModifier()
local original_GetBot = GetBot

function GetBot()
	ApplyHasModifierOverride(original_GetBot())
	ApplGetNearbyHeroesOverride(original_GetBot())
	return original_GetBot()
end
function ApplyHasModifierOverride(unit)
    local original_HasModifier = unit.HasModifier

    unit.HasModifier = function(self, modifier_name)
		if not unit:CanBeSeen() then
			return nil
		end
        return original_HasModifier(self, modifier_name)
    end
end
function ApplGetNearbyHeroesOverride(unit)
    local original_GetNearbyHeroes = unit.GetNearbyHeroes

    unit.GetNearbyHeroes = function(self, nRadius, bEnemies, nMode)
		if not unit:CanBeSeen() then
			return nil
		end
        return original_GetNearbyHeroes(self, nRadius, bEnemies, nMode)
    end
end


-- Overridding functions to debug and redcue logging spam
local original_GetUnitToUnitDistance = GetUnitToUnitDistance
function GetUnitToUnitDistance(unit1, unit2)
	if not unit1 then
        print("[Error] GetUnitToUnitDistance called with invalid unit 1")
		print("Stack Trace:", debug.traceback())
	end
	if not unit2 then
		if unit1 then
        	print("[Error] GetUnitToUnitDistance called with invalid unit 2, the unit 1 is: " .. unit1:GetUnitName())
			print("Stack Trace:", debug.traceback())
		end
	end
    return original_GetUnitToUnitDistance(unit1, unit2)
end


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
	return
end	


function MinionThink(hMinionUnit)

	BotBuild.MinionThink(hMinionUnit)
	
end
