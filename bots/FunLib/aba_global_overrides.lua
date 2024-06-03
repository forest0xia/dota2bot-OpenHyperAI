
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
    return originalGetNearbyTowers(self, nRadius, bEnemies)
end

local originalIsIllusion = CDOTA_Bot_Script.IsIllusion
function CDOTA_Bot_Script:IsIllusion()
    if not self:IsHero() then
		-- print("IsIllusion has been called on non hero")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalIsIllusion(self)
end

local originalHasModifier = CDOTA_Bot_Script.HasModifier
function CDOTA_Bot_Script:HasModifier(sModifierName)
    if not self:CanBeSeen() then
		return nil
		-- print("HasModifier has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
	end
    -- if not self:IsHero() then
	-- 	print("HasModifier has been called on non hero")
	-- 	print("Stack Trace:", debug.traceback())
	-- end
    return originalHasModifier(self, sModifierName)
end

local X = {
	orig_GetTeamPlayers = orig_GetTeamPlayers,
	GetTeamPlayers = GetTeamPlayers
}

return X