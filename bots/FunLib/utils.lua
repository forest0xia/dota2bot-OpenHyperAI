-- Simple utils that should be able to be imported to any other lua files without causing any circular dependency.
-- This lua file should NOT have any dependency libs or files is possible.

local X = { }

-- This heroes bugged because Valve was too lazy to add them with the correct laning target point. No high desired lane.
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

function X.GetLocationToLocationDistance( fLoc, sLoc )
	local x1 = fLoc.x
	local x2 = sLoc.x
	local y1 = fLoc.y
	local y2 = sLoc.y
	return math.sqrt( math.pow( ( y2-y1 ), 2 ) + math.pow( ( x2-x1 ), 2 ) )
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

local function FloatEqual(a, b)
    return math.abs(a - b) < 0.000001
end

local magicTable = {}
local function GiveLinqFunctions(t)
    setmetatable(t, magicTable)
end

local function NewTable()
    local a = {}
    GiveLinqFunctions(a)
    return a
end

X.ForEach = function(self, tb, action)
    for k, v in ipairs(tb) do
        action(v, k)
    end
end

magicTable.__index = magicTable
function X.NewTable()
    return NewTable()
end

function X.Remove_Modify(tb, item)
    local filter = item
    if type(item) ~= "function" then
        filter = function(t)
            return t == item
        end
    end
    local i = 1
    local d = #tb
    while i <= d do
        if filter(tb[i]) then
            table.remove(tb, i)
            d = d - 1
        else
            i = i + 1
        end
    end
end

-- coroutine

local defaultReturn = NewTable()
local everySecondsCallRegistry = NewTable()
function X.EveryManySeconds(second, oldFunction)
    local functionName = tostring(oldFunction)
    local callTable = {}
    everySecondsCallRegistry[functionName] = callTable
    callTable.lastCallTime = DotaTime() + RandomInt(0, second * 1000) / 1000
    callTable.interval = second
    callTable.startup = true
    return function(...)
        local callTable = everySecondsCallRegistry[tostring(oldFunction)]
        if callTable.startup then
            callTable.startup = nil
            return oldFunction(...)
        elseif callTable.lastCallTime <= DotaTime() - callTable.interval then
            callTable.lastCallTime = DotaTime()
            return oldFunction(...)
        else
            return defaultReturn
        end
    end
end

local slowFunctionRegistries = NewTable()
local coroutineRegistry = NewTable()
local coroutineExempt = NewTable()
function X.TickFromDota()
    local time = DotaTime()
    local function ResumeCoroutine(thread)
        local coroutineResult = { coroutine.resume(thread, deltaTime) }
        if not coroutineResult[1] then
            table.remove(coroutineResult, 1)
            print("error in coroutine:")
            X.PrintTable(coroutineResult)
        end
    end

    if dotaTimer == nil then
        dotaTimer = time
        return
    end
    deltaTime = time - dotaTimer
    if not FloatEqual(time, dotaTimer) then
        frameNumber = frameNumber + 1
        X.ForEach(slowFunctionRegistries, function(t)
            t(deltaTime)
        end)
        local threadIndex = 1
        while threadIndex <= #coroutineRegistry do
            local t = coroutineRegistry[threadIndex]
            local exemptIndex
            local exempt
            X.ForEach(coroutineExempt, function(exemptPair, index)
                if exemptPair[1] == t then
                    if exemptPair[2] == frameNumber then
                        exempt = true
                    end
                    exemptIndex = index
                end
            end)
            if exemptIndex then
                table.remove(coroutineExempt, exemptIndex)
            end
            if not exempt then
                if coroutine.status(t) == "suspended" then
                    ResumeCoroutine(t)
                    threadIndex = threadIndex + 1
                elseif coroutine.status(t) == "dead" then
                    table.remove(coroutineRegistry, threadIndex)
                else
                    threadIndex = threadIndex + 1
                end
            end
        end
        dotaTimer = time
    end
end

function X.ResumeUntilReturn(func)
    local g = NewTable()
    local thread = coroutine.create(func)
    while true do
        local values = { coroutine.resume(thread) }
        if values[1] then
            table.remove(values, 1)
            table.insert(g, values)
        else
            table.remove(values, 1)
            print("error in coroutine:")
            X.PrintTable(values)
            break
        end
    end
    return g
end

function X.StartCoroutine(func)
    local newCoroutine = coroutine.create(func)
    table.insert(coroutineRegistry, newCoroutine)
    table.insert(coroutineExempt, {
        newCoroutine,
        frameNumber,
    })
    return newCoroutine
end

function X.WaitForSeconds(seconds)
    local t = seconds
    while t > 0 do
        t = t - coroutine.yield()
    end
end

function X.StopCoroutine(thread)
    X.Remove_Modify(coroutineExempt, function(t)
        return t[1] == thread
    end)
    X.Remove_Modify(coroutineRegistry, thread)
end



X.BuggyHeroesDueToValveTooLazy = BuggyHeroesDueToValveTooLazy

return X
