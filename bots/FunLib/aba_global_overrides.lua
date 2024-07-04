
local Utils = require( GetScriptDirectory()..'/FunLib/utils')

-- Override this func for the script to use
local orig_GetTeamPlayers = GetTeamPlayers
local direTeamPlaters = nil
function GetTeamPlayers(nTeam)
	local nIDs = orig_GetTeamPlayers(nTeam)
	if nTeam == TEAM_DIRE then
		if direTeamPlaters ~= nil then
			return direTeamPlaters
		end
		
		local sHuman = {}
		for idx, id in pairs(nIDs) do
			if not IsPlayerBot(id)
			then
				table.insert(sHuman, id)
			end
		end

		if #sHuman > 0 then
			local nBotIDs = {5, 6, 7, 8, 9}
			nIDs = {}

			for i = 1, #nBotIDs do table.insert(nIDs, nBotIDs[i]) end

			-- Map it directly
			for i = 1, #sHuman do
				for j = 1, 5 do
					if sHuman[i] + 5 == nBotIDs[j]
					then
						nIDs[j] = sHuman[i]
					end
				end
			end

			-- "Shift" > 4
			for i = #nIDs, 1, -1 do
				local hCount = 0
				if nIDs[i] > 4 then
					for j = 1, #nIDs do
						if  nIDs[j + i] ~= nil and nIDs[j + i] < 5 then
							hCount = hCount + 1
						end
					end
					nIDs[i] = nIDs[i] + hCount
				end
			end
		end
		direTeamPlaters = nIDs
	end
	return nIDs
end

local original_GetUnitToUnitDistance = GetUnitToUnitDistance
function GetUnitToUnitDistance(unit1, unit2)
	if not unit1 then
		print("[Error] GetUnitToUnitDistance called with invalid unit 1")
		print("Stack Trace:", debug.traceback())
	end
	if not unit2 or unit2:GetLocation() == nil then
		if unit1 then
			print("[Error] GetUnitToUnitDistance called with invalid unit 2, the unit 1 is: " .. unit1:GetUnitName())
			print("Stack Trace:", debug.traceback())
		end
	end
	return original_GetUnitToUnitDistance(unit1, unit2)
end

local originalWasRecentlyDamagedByAnyHero = CDOTA_Bot_Script.WasRecentlyDamagedByAnyHero
function CDOTA_Bot_Script:WasRecentlyDamagedByAnyHero(fInterval)
    if not self:IsHero() then
		-- print("WasRecentlyDamagedByAnyHero has been called on non hero")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalWasRecentlyDamagedByAnyHero(self, fInterval)
end

local originalGetNearbyTowers = CDOTA_Bot_Script.GetNearbyTowers
function CDOTA_Bot_Script:GetNearbyTowers(nRadius, bEnemies)
    if not self:IsHero() then
		-- print("GetNearbyTowers has been called on non hero")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalGetNearbyTowers(self, math.min(nRadius, 1600), bEnemies)
end

local originalIsIllusion = CDOTA_Bot_Script.IsIllusion
function CDOTA_Bot_Script:IsIllusion()
    if not self:IsHero() then
		-- print("IsIllusion has been called on non hero")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    if not self:CanBeSeen() then
		-- print("IsIllusion has been called on non hero")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end

	-- TODO: add is-teammate check.
    return originalIsIllusion(self)
end

local originalHasModifier = CDOTA_Bot_Script.HasModifier
function CDOTA_Bot_Script:HasModifier(sModifierName)
    if not self:CanBeSeen() then
		return false
		-- print("HasModifier has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
	end
    -- if not self:IsHero() then
	-- 	print("HasModifier has been called on non hero")
	-- 	print("Stack Trace:", debug.traceback())
	-- end
    return originalHasModifier(self, sModifierName)
end

local originalIsInvulnerable = CDOTA_Bot_Script.IsInvulnerable
function CDOTA_Bot_Script:IsInvulnerable()
    if not self:CanBeSeen() then
		-- print("IsInvulnerable has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return false
	end
    return originalIsInvulnerable(self)
end

local originalIsAttackImmune = CDOTA_Bot_Script.IsAttackImmune
function CDOTA_Bot_Script:IsAttackImmune()
    if not self:CanBeSeen() then
		-- print("IsAttackImmune has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return false
	end
    return originalIsAttackImmune(self)
end

local originalIsUsingAbility = CDOTA_Bot_Script.IsUsingAbility
function CDOTA_Bot_Script:IsUsingAbility()
    if not self:CanBeSeen() or not self:IsHero() then
		-- print("IsUsingAbility has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return false
	end
    return originalIsUsingAbility(self)
end

local originalIsChanneling = CDOTA_Bot_Script.IsChanneling
function CDOTA_Bot_Script:IsChanneling()
    if not self:CanBeSeen() then
		-- print("IsChanneling has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return false
	end
    return originalIsChanneling(self)
end

local originalGetAttackTarget = CDOTA_Bot_Script.GetAttackTarget
function CDOTA_Bot_Script:GetAttackTarget()
    if not self:CanBeSeen() then
		-- print("GetAttackTarget has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalGetAttackTarget(self)
end

local originalGetNearbyHeroes = CDOTA_Bot_Script.GetNearbyHeroes
function CDOTA_Bot_Script:GetNearbyHeroes(nRadius, bEnemies, nMode)
    if not self:CanBeSeen() then
		-- print("GetNearbyHeroes has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalGetNearbyHeroes(self, math.min(nRadius, 1600), bEnemies, nMode)
end

local originalIsMagicImmune = CDOTA_Bot_Script.IsMagicImmune
function CDOTA_Bot_Script:IsMagicImmune()
    if not self:CanBeSeen() then
		-- print("IsMagicImmune has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return true
	end
    return originalIsMagicImmune(self)
end

local originalGetNearbyNeutralCreeps = CDOTA_Bot_Script.GetNearbyNeutralCreeps
function CDOTA_Bot_Script:GetNearbyNeutralCreeps( nRadius)
    return originalGetNearbyNeutralCreeps(self, math.min(nRadius, 1600))
end

local originalGetNearbyLaneCreeps = CDOTA_Bot_Script.GetNearbyLaneCreeps
function CDOTA_Bot_Script:GetNearbyLaneCreeps( nRadius, bEnemies)
    return originalGetNearbyLaneCreeps(self, math.min(nRadius, 1600), bEnemies)
end

local originalGetNearbyCreeps = CDOTA_Bot_Script.GetNearbyCreeps
function CDOTA_Bot_Script:GetNearbyCreeps( nRadius, bEnemies)
    return originalGetNearbyCreeps(self, math.min(nRadius, 1600), bEnemies)
end

local originalGetAttackRange = CDOTA_Bot_Script.GetAttackRange
function CDOTA_Bot_Script:GetAttackRange()
    if not self:CanBeSeen() then
		-- print("GetAttackRange has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return 200
	end
    return originalGetAttackRange(self)
end

-- local original_Action_MoveToLocation = CDOTA_Bot_Script.Action_MoveToLocation
-- function CDOTA_Bot_Script:Action_MoveToLocation(vLocation)
-- 	if self.isBuggyHero == nil then
-- 		self.isBuggyHero = Utils.BuggyHeroesDueToValveTooLazy[self:GetUnitName()] ~= nil
-- 	end
-- 	if self.isBuggyHero
-- 	then
-- 		self:Action_ClearActions(true);
-- 		print('Override buggy hero movement, make it go assigned lane front with Action_MoveToLocation.'..self:GetUnitName())
-- 		local assignedLaneLoc = GetLaneFrontLocation(GetTeam(), self:GetAssignedLane(), 0)
-- 		if Utils.GetLocationToLocationDistance(assignedLaneLoc, vLocation) > 1000 and DotaTime() < 2*60 then
-- 			return original_Action_MoveToLocation(self, assignedLaneLoc )
-- 		end
-- 	end
--     return original_Action_MoveToLocation(self, vLocation )
-- end

local original_Action_AttackMove = CDOTA_Bot_Script.Action_AttackMove
function CDOTA_Bot_Script:Action_AttackMove(vLocation)
	if self.isBuggyHero == nil then
		self.isBuggyHero = Utils.BuggyHeroesDueToValveTooLazy[self:GetUnitName()] ~= nil
	end
	if self.isBuggyHero
	then
		self:Action_ClearActions(true);
		print('Override buggy hero movement, make it go assigned lane front with Action_AttackMove.'..self:GetUnitName())
		local assignedLaneLoc = GetLaneFrontLocation(GetTeam(), self:GetAssignedLane(), 0)
		if Utils.GetLocationToLocationDistance(assignedLaneLoc, vLocation) > 1000 and DotaTime() < 2*60 then
			return original_Action_AttackMove(self, assignedLaneLoc )
		end
	end
    return original_Action_AttackMove(self, vLocation )
end


-- CDOTA_AttackRecordManager::GetRecordByIndex - Could not find attack record (-1)!
-- local originalGetRecordByIndex = CDOTA_AttackRecordManager.GetRecordByIndex
-- function CDOTA_AttackRecordManager:GetRecordByIndex(idx)
--     if idx < 0 then
-- 		print("GetRecordByIndex has been called on unit can't be seen")
-- 		print("Stack Trace:", debug.traceback())
-- 	end
--     return originalGetRecordByIndex(self)
-- end

local originalActionImmediate_SwapItems = CDOTA_Bot_Script.ActionImmediate_SwapItems
local itemSwapGapTime = 6 + 5 -- 6s item cd after swap, 5s delta time for item usage reaction.
function CDOTA_Bot_Script:ActionImmediate_SwapItems(intnSlot1, intnSlot2)
	local unitName = self:GetUnitName()
	-- print(unitName.." swaps items: "..tostring(intnSlot1)..', '..tostring(intnSlot2))
	if self.itemSwapTime == nil then
		self.itemSwapTime = 0
	end
	-- print("ActionImmediate_SwapItems has been called on unit: "..unitName)
	-- print("Stack Trace:", debug.traceback())
	if #self:GetNearbyHeroes(1000, true, BOT_MODE_NONE) == 0 and DotaTime() - self.itemSwapTime > itemSwapGapTime then
		self.itemSwapTime = DotaTime()
		return originalActionImmediate_SwapItems(self, intnSlot1, intnSlot2)
	else
		-- print('[WARN] '..unitName..' failed to swap items due to trying too frequently.')
	end
    return nil
end

local originalGetUnitToLocationDistance = CDOTA_Bot_Script.GetUnitToLocationDistance
-- Override the GetUnitToLocationDistance function with caching
function CDOTA_Bot_Script:GetUnitToLocationDistance(unit, location)
    if location == nil then
		print("GetUnitToLocationDistance error arg.")
		print("Stack Trace:", debug.traceback())
		return 200
	end
    return originalGetUnitToLocationDistance(self, unit, location)
end


local X = {
	orig_GetTeamPlayers = orig_GetTeamPlayers,
	GetTeamPlayers = GetTeamPlayers
}

return X