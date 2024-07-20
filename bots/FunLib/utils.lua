
--[[

Simple utils that should be able to be imported to any other lua files without causing any circular dependency.
This lua file should NOT have any dependency libs or files is possible.

Anything that can be shared in any files without worrying about nested or circular dependency can be added to this file. Can gradually migrate functions into this file as well.

]]

local X = { }
X['DebugMode'] = true

local RadiantFountainTpPoint = Vector(-7172, -6652, 384 )
local DireFountainTpPoint = Vector(6982, 6422, 392)
local orig_print = print

-- This heroes bugged because Valve was too lazy to add them with the correct laning target point. No high desired lane.
X['BuggyHeroesDueToValveTooLazy'] = {
    ['npc_dota_hero_muerta'] = true,
    ['npc_dota_hero_marci'] = true,
    ['npc_dota_hero_lone_druid_bear'] = true,
    ['npc_dota_hero_primal_beast'] = true,
    ['npc_dota_hero_dark_willow'] = true,
    ['npc_dota_hero_elder_titan'] = true,
    ['npc_dota_hero_hoodwink'] = true,
    ['npc_dota_hero_wisp'] = true,
}

X['ActuallyBuggedHeroes'] = { } -- used to record the acutal bugged heroes in this game.

X['GameStates'] = { } -- A gaming state keeper to keep a record of different states to avoid recomupte or anything.
X['LoneDruid'] = { }
X['FrameProcessTime'] = 0.05

-- Override the print function
function print(...)
    if not X.DebugMode then return end

    local args = {...}
    for i, v in ipairs(args) do
        args[i] = tostring(v) -- Convert all arguments to strings
    end
    local output = table.concat(args, "\t") -- Concatenate with tab as separator

    orig_print(output)
end

function X.PrintTable(tbl, indent)
	if not indent then indent = 0 end
    if tbl == nil then print(tostring(tbl)); return end

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

function X.PrintPings(pingTimeGap)
	local listPings = {}
	local nTeamPlayers = GetTeamPlayers(GetTeam())
	for i, id in pairs(nTeamPlayers)
	do
        local allyHero = GetTeamMember(i)
		if allyHero ~= nil and not allyHero:IsIllusion()
        then
			local ping = allyHero:GetMostRecentPing()
            if ping.time ~= 0 and GameTime() - ping.time < pingTimeGap then
                table.insert(listPings, ping)
            end
		end
	end
	X.PrintTable(listPings)
end

function X.GetEnemyFountainTpPoint()
	if GetTeam() == TEAM_DIRE
	then
		return RadiantFountainTpPoint
	else
		return DireFountainTpPoint
	end
end

function X.Shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = RandomInt(1, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

function X.IsPingedToDefenseByAnyPlayer(bot, pingTimeGap)
	local listPings = {}
	local nTeamPlayers = GetTeamPlayers(GetTeam())
	for i, id in pairs(nTeamPlayers)
	do
        local allyHero = GetTeamMember(i)
		if allyHero ~= nil and not allyHero:IsIllusion()
        -- and allyHero ~= bot
        then
			local ping = allyHero:GetMostRecentPing()
			table.insert(listPings, ping)
		end
	end

	for _,ping in pairs(listPings)
	do
		if ping ~= nil and not ping.normal_ping and X.GetLocationToLocationDistance(ping.location, bot:GetLocation()) > 2000
        and GameTime() - ping.time < pingTimeGap and ping.player_id ~= -1 then
            print('Bot '..bot:GetUnitName()..' is pinged to defend')
			return ping
		end
	end
	return nil
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

-- Combine 2 tables into a unique table.
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

-- Merge two lists into one and return it
function X.MergeLists(list1, list2)
    local mergedList = {}
    for _, v in ipairs(list1) do
        table.insert(mergedList, v)
    end
    for _, v in ipairs(list2) do
        table.insert(mergedList, v)
    end
    return mergedList
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
    return math.sqrt((y2-y1) * (y2-y1) + (x2-x1) * (x2-x1))
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

-- check if a table contains a value
function X.HasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- for debug. Print Unit Muldifiers
function X.PrintUnitMuldifiers(unit)
    local npcModifier = unit:NumModifiers()
	for i = 0, npcModifier
	do
        print('Unit: '..unit:GetUnitName()..' has modifier '.. unit:GetModifierName(i) .. ' with stack count: '.. unit:GetModifierStackCount(i))
	end
end

function X.CountBackpackEmptySpace(bot)
	local countEmptyBackpack = 3
	if bot:GetItemInSlot( 6 ) ~= nil then countEmptyBackpack = countEmptyBackpack - 1 end
	if bot:GetItemInSlot( 7 ) ~= nil then countEmptyBackpack = countEmptyBackpack - 1 end
	if bot:GetItemInSlot( 8 ) ~= nil then countEmptyBackpack = countEmptyBackpack - 1 end
    return countEmptyBackpack
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

function X.RecentlyTookDamage(bot, interval)
    return bot:WasRecentlyDamagedByAnyHero(interval) or bot:WasRecentlyDamagedByTower(interval) or bot:WasRecentlyDamagedByCreep(interval)
end

function X.IsUnitWithName(unit, name)
    return string.find(unit:GetUnitName(), name)
end

function X.IsBear(unit)
    return X.IsUnitWithName(unit, 'lone_druid_bear')
end

function X.GetOffsetLocationTowardsTargetLocation(initLoc, targetLoc, offsetDist)
    local dir = (targetLoc - initLoc):Normalized()
    return initLoc + dir * offsetDist
end

return X



--[[

Coding notes to Dota2 script: 
- Valve dota2 scripting: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
- Valve dota2 abaility names: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Ability_Names
- dota2 internal names: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Heroes_internal_names
- dota2 modifiers: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Modifier_Names
- Dota 2 Workshop debugging with Lua script: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Debugging_Lua_scripts

========================= Modes =========================
Action Desires
These can be useful for making sure all action desires are using a common language for talking about their desire.

BOT_ACTION_DESIRE_NONE - 0.0
BOT_ACTION_DESIRE_VERYLOW - 0.1
BOT_ACTION_DESIRE_LOW - 0.25
BOT_ACTION_DESIRE_MODERATE - 0.5
BOT_ACTION_DESIRE_HIGH - 0.75
BOT_ACTION_DESIRE_VERYHIGH - 0.9
BOT_ACTION_DESIRE_ABSOLUTE - 1.0

Mode Desires
These can be useful for making sure all mode desires as using a common language for talking about their desire.

BOT_MODE_DESIRE_NONE - 0
BOT_MODE_DESIRE_VERYLOW - 0.1
BOT_MODE_DESIRE_LOW - 0.25
BOT_MODE_DESIRE_MODERATE - 0.5
BOT_MODE_DESIRE_HIGH - 0.75
BOT_MODE_DESIRE_VERYHIGH - 0.9
BOT_MODE_DESIRE_ABSOLUTE - 1.0





]]