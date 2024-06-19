
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
function CDOTA_Bot_Script:GetNearbyNeutralCreeps( nRadius, bEnemies)
    return originalGetNearbyNeutralCreeps(self, math.min(nRadius, 1600), bEnemies)
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

local originalActionImmediate_SwapItems = CDOTA_Bot_Script.ActionImmediate_SwapItems
local itemSwapTime = { }
local itemSwapGapTime = 6 + 1 -- 6s item cd after swap, 1s delta time for item usage reaction.
function CDOTA_Bot_Script:ActionImmediate_SwapItems(intnSlot1, intnSlot2)
	local unitName = self:GetUnitName()
	-- print(unitName.." swaps items: "..tostring(intnSlot1)..', '..tostring(intnSlot2))
	if itemSwapTime[unitName] == nil then
		itemSwapTime[unitName] = DotaTime()
	end
	if DotaTime() - itemSwapTime[unitName] > itemSwapGapTime then
		return originalActionImmediate_SwapItems(self, intnSlot1, intnSlot2)
	else
		print('[WARN] '..unitName..' failed to swap items due to trying too frequently.')
	end
    return nil
end

-- local originalGetUnitToLocationDistance = CDOTA_Bot_Script.GetUnitToLocationDistance
-- -- Cache duration in seconds
-- local cacheDuration = 0.03 -- 30 milliseconds
-- -- Override the GetUnitToLocationDistance function with caching
-- function CDOTA_Bot_Script:GetUnitToLocationDistance(unit, location)
--     if not unit.distanceCache then
--         unit.distanceCache = {}
--     end

--     local cacheKey = tostring(location.x) .. "_" .. tostring(location.y) .. "_" .. tostring(location.z)
--     local currentTime = GameTime()

--     -- Check if we have a cached result and it's still valid
--     local cachedResult = unit.distanceCache[cacheKey]
--     if cachedResult and (currentTime - cachedResult.timestamp <= cacheDuration) then
--         return cachedResult.distance
--     end

--     -- Call the original function to get the distance
--     local distance = originalGetUnitToLocationDistance(self, unit, location)

--     -- Update the cache directly in the unit object
--     if cachedResult then
--         cachedResult.distance = distance
--         cachedResult.timestamp = currentTime
--     else
--         unit.distanceCache[cacheKey] = {distance = distance, timestamp = currentTime}
--     end

--     return distance
-- end


local X = {
	orig_GetTeamPlayers = orig_GetTeamPlayers,
	GetTeamPlayers = GetTeamPlayers
}

return X