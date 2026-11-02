-- dota-bot team brain v3, game 0 (trabajo/cerebro-v3.md, "Versión final"): checks in one observed match which Bot API
-- calls really answer about ENEMY heroes, before the brain relies on them. Two earlier changes did nothing in silence
-- because a call did not exist (GetAbilityType) or OHA overrode it (WasRecentlyDamagedByAnyHero on towers).
-- Benchmark variant "api_sonda = true" only: team_desires.lua calls Probe.Tick() once per frame for the team; without
-- the variant nothing loads this file. It only reads and prints "[bench] api ..." lines (they reach the log with
-- --observar); it never orders a bot. Every check runs in its own pcall: a missing call prints "err=" and goes on.
local P = {}

local EVERY = 10          -- seconds of game time between periodic checks
local nextTick = -1000
local seenTp = {}         -- "pid:x:y" -> true, so each enemy teleport prints once
local lastActive = {}     -- enemy unit name -> name of the ability it was casting at the last frame
local watchUlt = {}       -- enemy unit name -> { ability, at }: an ultimate just seen cast, re-read 3 s later

local function Fmt(v)
	if v == nil then return 'nil' end
	if type(v) == 'number' then return string.format('%.1f', v) end
	return tostring(v)
end

local function Try(tag, fn)
	local ok, err = pcall(fn)
	if not ok then print('[bench] api ' .. tag .. ' err=' .. tostring(err)) end
end

local function EnemyPids()
	local set = {}
	for _, pid in ipairs(GetTeamPlayers(GetOpposingTeam())) do set[pid] = true end
	return set
end

local function EnemyUnits()
	local list = {}
	for _, e in ipairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
		if e ~= nil and e:IsHero() and not e:IsIllusion() then table.insert(list, e) end
	end
	return list
end

local function Ultimate(u)
	for i = 0, 23 do
		local a = u:GetAbilityInSlot(i)
		if a ~= nil and not a:IsHidden() and a:IsUltimate() then return a end
	end
	return nil
end

-- Every frame: which ability each visible enemy is casting (detecting enemy ultimates, since their cooldown is hidden).
local function CheckCasting(t)
	for _, e in ipairs(EnemyUnits()) do
		if e:IsAlive() and e:CanBeSeen() then
			local a = e:GetCurrentActiveAbility()
			local name = a ~= nil and a:GetName() or nil
			local key = e:GetUnitName()
			if name ~= nil and name ~= lastActive[key] then
				print(string.format('[bench] api cast t=%d %s %s ult=%s', t, string.gsub(key, 'npc_dota_hero_', ''), name,
					Fmt(a:IsUltimate())))
				if a:IsUltimate() then watchUlt[key] = { ability = a, at = DotaTime() } end
			end
			lastActive[key] = name
		end
	end
end

-- Enemy teleports: does GetIncomingTeleports list enemy TPs at all?
local function CheckTeleports(t)
	local enemy = EnemyPids()
	for _, tp in ipairs(GetIncomingTeleports() or {}) do
		local loc = tp.location
		local key = tostring(tp.playerid) .. ':' .. (loc and math.floor(loc.x / 200) or 0) .. ':' .. (loc and math.floor(loc.y / 200) or 0)
		if not seenTp[key] then
			seenTp[key] = true
			print(string.format('[bench] api tp t=%d pid=%s enemigo=%s quedan=%s', t, Fmt(tp.playerid),
				Fmt(enemy[tp.playerid] == true), Fmt(tp.time_remaining)))
		end
	end
end

local function CheckPeriodic(t)
	local units = EnemyUnits()
	-- Modifiers on visible enemies and their remaining time (stun windows, BKB, saves).
	Try('mod', function()
		local shown = 0
		for _, e in ipairs(units) do
			if e:IsAlive() and e:CanBeSeen() and shown < 2 then
				local n = e:NumModifiers()
				local parts = {}
				-- Every modifier with time left (stuns, BKB, saves), not just the first ones (passives come first).
				-- GetModifierSourceAbility does not exist (game 0).
				for i = 0, n - 1 do
					local rem = e:GetModifierRemainingDuration(i)
					if rem ~= nil and rem > 0 and #parts < 8 then
						table.insert(parts, string.format('%s=%s', tostring(e:GetModifierName(i)), Fmt(rem)))
					end
				end
				print(string.format('[bench] api mod t=%d %s n=%s %s', t, string.gsub(e:GetUnitName(), 'npc_dota_hero_', ''),
					Fmt(n), table.concat(parts, ' ')))
				shown = shown + 1
			end
		end
	end)
	-- Enemy ultimates: cooldown fields on an enemy ability.
	Try('ult', function()
		for _, e in ipairs(units) do
			if e:IsAlive() and e:CanBeSeen() then
				local u = Ultimate(e)
				if u ~= nil then
					print(string.format('[bench] api ult t=%d %s %s nivel=%s cd=%s cdrest=%s lista=%s', t,
						string.gsub(e:GetUnitName(), 'npc_dota_hero_', ''), u:GetName(), Fmt(u:GetLevel()), Fmt(u:GetCooldown()),
						Fmt(u:GetCooldownTimeRemaining()), Fmt(u:IsFullyCastable())))
				end
				break
			end
		end
	end)
	-- Respawn of dead enemies: is the dead unit still listed, and does GetRespawnTime answer for it?
	Try('respawn', function()
		for _, pid in ipairs(GetTeamPlayers(GetOpposingTeam())) do
			if not IsHeroAlive(pid) then
				local unit = nil
				for _, e in ipairs(units) do if e:GetPlayerID() == pid then unit = e end end
				print(string.format('[bench] api respawn t=%d pid=%d unidad=%s rt=%s nivel=%s', t, pid, Fmt(unit ~= nil),
					unit ~= nil and Fmt(unit:GetRespawnTime()) or 'nil', Fmt(GetHeroLevel(pid))))
			end
		end
	end)
	-- Last seen info: a table with fields (the reference) or a list (how OHA indexes it, info[1])?
	Try('visto', function()
		local pid = GetTeamPlayers(GetOpposingTeam())[1]
		local info = GetHeroLastSeenInfo(pid)
		local first = type(info) == 'table' and info[1] or nil
		print(string.format('[bench] api visto t=%d pid=%d tipo=%s campo=%s lista=%s hace=%s', t, pid, type(info),
			Fmt(type(info) == 'table' and info.location ~= nil), Fmt(type(first) == 'table' and first.location ~= nil),
			Fmt(type(info) == 'table' and (info.time_since_seen or (first and first.time_since_seen)) or nil)))
	end)
end

function P.Tick()
	local t = math.floor(DotaTime())
	Try('cast', function() CheckCasting(t) end)
	-- 3 s after an enemy ultimate was seen cast: does the API show it on cooldown (castable false, cooldown fields)?
	Try('ult_tras', function()
		for key, w in pairs(watchUlt) do
			if DotaTime() - w.at >= 3 then
				watchUlt[key] = nil
				local a = w.ability
				print(string.format('[bench] api ult_tras t=%d %s %s cd=%s cdrest=%s lista=%s', t,
					string.gsub(key, 'npc_dota_hero_', ''), a:GetName(), Fmt(a:GetCooldown()), Fmt(a:GetCooldownTimeRemaining()),
					Fmt(a:IsFullyCastable())))
			end
		end
	end)
	Try('tp', function() CheckTeleports(t) end)
	if DotaTime() >= nextTick then
		nextTick = DotaTime() + EVERY
		CheckPeriodic(t)
	end
end

-- Game 0 (2026-11-02, MEDICIONES v3-partida0) also tried an ATTACK GetDesire returning nil for Valve's desire: nil
-- counts as 0 (no bot attacked all game). Removed; see mode_attack_generic.lua.

return P
