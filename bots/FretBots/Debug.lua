-- Edit this flag to enable / disable debug
local isDebug = true;

-- Instantiate the class
if Debug == nil then
	Debug = {};
end

local orig_print = print
function print(...)
    local args = {...}
    for i, v in ipairs(args) do
		if i == 1 then
			v = '[Fretbots] '..tostring(v)
		end
        args[i] = tostring(v)
    end
    local output = table.concat(args, "\t") -- Concatenate with tab as separator

    orig_print(output)
end

-- Edit this return to enable / disable debug
function Debug:IsDebug()
	return isDebug;
end

-- shorthand for debug printing
function Debug:Print(msg, header)
	if header ~= nil then
		if isDebug then print(header) end
	end
	if type(msg) == 'table' then
		if isDebug then DeepPrintTable(msg) end
	else
		if isDebug then print(msg) end
	end
end

-- shorthand for debug table printing
function Debug:DeepPrint(o, title)
	if isDebug then DeepPrintTable(o) end
end

-- Kills a random bot
function Debug:KillBot(index)
	
	for team = 2, 3 do
	-- Kill a specific bot (by position)
	if index ~= nil then
		-- check by index
		if AllBots[team][index] ~= nil then
			if AllBots[team][index]:IsAlive() then
				AllBots[team][index]:ForceKill(true)
			end
		-- Check by name
		else
			for _, bot in pairs(AllBots[team]) do
				if bot:IsAlive() and string.lower(bot.stats.name) == string.lower(index) then
					bot:ForceKill(true)
					break
				end
			end
		end
  -- otherwise kill one at random
	else
		local numBots = 0
		local aliveBots = {}
		for _, bot in pairs(AllBots[team]) do
			if bot:IsAlive() then
				numBots = numBots + 1
				table.insert(aliveBots,bot)
			end
		end
		if numBots > 0 then
			aliveBots[math.random(numBots)]:ForceKill(true)
		end
	end
end
end