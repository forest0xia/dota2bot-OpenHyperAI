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


-- Check if any bot is stuck/idle for some time.
local botIdelStateTimeThreshold = 12 -- things like long durating casting spells (e.g. CM's ult) or TP can take longer time.
local deltaIdleDistance = 3
local botIdleStateTracker = { }
function CheckBotIdleState()
	local botState = botIdleStateTracker[bot:GetUnitName()]
	if botState then
		if DotaTime() - botState.lastCheckTime >= botIdelStateTimeThreshold then
			if GetLocationToLocationDistance( botState.botLocation, bot:GetLocation()) <= deltaIdleDistance then
				print('Bot '..bot:GetUnitName()..' got stuck.')
				
				bot:Action_ClearActions(true);

				local foundTarget = false
				local closetLocation = nil

				for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
				do
					local mode = allyHero:GetActiveMode()
					local isActiveMode = 
					       mode == BOT_MODE_ROAM
						or mode == BOT_MODE_TEAM_ROAM
						or mode == BOT_MODE_GANK
						or mode == BOT_MODE_ATTACK
						or mode == BOT_MODE_DEFEND_ALLY
						or mode == BOT_MODE_PUSH_TOWER_TOP
						or mode == BOT_MODE_PUSH_TOWER_MID
						or mode == BOT_MODE_PUSH_TOWER_BOT
						or mode == BOT_MODE_DEFEND_TOWER_TOP
						or mode == BOT_MODE_DEFEND_TOWER_MID
						or mode == BOT_MODE_DEFEND_TOWER_BOT
					if isActiveMode and GetLocationToLocationDistance( allyHero:GetLocation(), bot:GetLocation() ) > deltaIdleDistance then
						foundTarget = true
						if closetLocation == nil or (GetLocationToLocationDistance( closetLocation, bot:GetLocation() ) > GetLocationToLocationDistance( allyHero:GetLocation(), bot:GetLocation() )) then
							closetLocation = allyHero:GetLocation()
						end
					end
				end

				if foundTarget and closetLocation then
					print('Relocate bot '..bot:GetUnitName()..' to move to where ally '..allyHero:GetUnitName()..' currently is.')
					bot:ActionQueue_AttackMove(closetLocation)
				else
					print('[ERROR] Can not find a location to relocate the idle bot: '..bot:GetUnitName())
				end

			end
			botState.botLocation = bot:GetLocation()
			botState.lastCheckTime = DotaTime()
		end
	else
		local botIdleState = {
			botLocation = bot:GetLocation(),
			lastCheckTime = DotaTime()
		}
		botIdleStateTracker[bot:GetUnitName()] = botIdleState
	end
end
function GetLocationToLocationDistance( fLoc, sLoc )
	local x1 = fLoc.x
	local x2 = sLoc.x
	local y1 = fLoc.y
	local y2 = sLoc.y
	return math.sqrt( math.pow( ( y2-y1 ), 2 ) + math.pow( ( x2-x1 ), 2 ) )
end
CheckBotIdleState()




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
