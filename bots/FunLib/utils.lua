-- Simple utils that should be able to be imported to any other lua files without causing any circular dependency.
-- This lua file should NOT have any dependency libs or files is possible.

local X = { }

local BuggyHeroesDueToValveTooLazy = {
    ['npc_dota_hero_muerta'] = true,
    ['npc_dota_hero_marci'] = true,
    ['npc_dota_hero_lone_druid'] = true,
    ['npc_dota_hero_primal_beast'] = true,
    ['npc_dota_hero_dark_willow'] = true,
    ['npc_dota_hero_elder_titan'] = true,
    ['npc_dota_hero_hoodwink'] = true,
}

function X.PrintTable(tbl, indent)
	if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            if indent < 3 then
                print(formatting)
                X.PrintTable(v, indent+1)
            else
                print(formatting .. "[WARN] Table has deep nested tables in it, stop printing more nexted tables.")
            end
        else
            print(formatting .. tostring(v))
        end
    end
end


-- Function to perform a deep copy of a table
function X.Deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[X.Deepcopy(orig_key)] = X.Deepcopy(orig_value)
        end
        setmetatable(copy, X.Deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function X.CombineTablesUnique(tbl1, tbl2)
    -- Create a set to track unique values
    local set = {}
    
    -- Add all elements of the first table to the set
    for _, value in ipairs(tbl1) do
        set[value] = true
    end
    
    -- Add all elements of the second table to the set
    for _, value in ipairs(tbl2) do
        set[value] = true
    end
    
    -- Create a result table with unique values
    local result = {}
    for key, _ in pairs(set) do
        table.insert(result, key)
    end
    
    return result
end

function X.RemoveValueFromTable(tbl, valueToRemove)
    for i = #tbl, 1, -1 do  -- Iterate backwards to avoid issues with changing indices
        if tbl[i] == valueToRemove then
            table.remove(tbl, i)
        end
    end
end

-- count the number of human vs bot players in the team. returns: #humen, #bots
function X.NumHumanBotPlayersInTeam(team)
	local nHuman, nBot = 0, 0
	for _, member in pairs(GetTeamPlayers(team))
	do
		if not IsPlayerBot(member)
		then
			nHuman = nHuman + 1
		else
			nBot = nBot + 1
		end
	end

	return nHuman, nBot
end

-- Set-like operation
function X.AddToSet(set, key)
    set[key] = true
end

-- Set-like operation
function X.RemoveFromSet(set, key)
    set[key] = nil
end

-- Set-like operation
function X.SetContains(set, key)
    return set[key] ~= nil
end

X.BuggyHeroesDueToValveTooLazy = BuggyHeroesDueToValveTooLazy

return X