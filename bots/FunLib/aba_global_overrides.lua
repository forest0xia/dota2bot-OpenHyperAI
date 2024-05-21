
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