if dofile(GetScriptDirectory()..'/FunLib/bench_side') then return end -- benchmark: Valve's bots play this team
-- dota-bot team brain (FunLib/team_brain.lua): only with the benchmark variant "cerebro = true". The API probe of the
-- brain v3's game 0 (FunLib/api_probe.lua): only with "api_sonda = true". Without either, this file defines nothing and
-- the engine keeps its default team desires, as before this file existed.
local Customize = require(GetScriptDirectory()..'/Customize/general')
local brainOn = Customize.BenchVariant.cerebro == true
local probeOn = Customize.BenchVariant.api_sonda == true
if not brainOn and not probeOn then return end

local Brain = brainOn and require(GetScriptDirectory()..'/FunLib/team_brain') or nil
local Probe = probeOn and require(GetScriptDirectory()..'/FunLib/api_probe') or nil

function TeamThink()
	if Brain ~= nil then
		local ok, err = pcall(Brain.Update)
		if not ok then print('[bench] plan error ' .. tostring(err)) end
	end
	if Probe ~= nil then
		local ok, err = pcall(Probe.Tick)
		if not ok then print('[bench] api error ' .. tostring(err)) end
	end
end
