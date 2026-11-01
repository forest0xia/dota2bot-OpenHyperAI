-- Tower defense with judgement (benchmark variant defensa_t12; off by default). Pedro, 2026-10-31: towers fall
-- undefended because each hero goes its own way, «con cabeza». Measured in the observer logs: of ~65 towers dota-bot
-- lost, most fell with no ally within 1500; 8 outer towers fell to only two attackers with nobody coming (defendable),
-- while 23 fell to three or more (better conceded than fed one by one).
-- For the outermost standing tier 1 or 2 tower of a lane, when enemy heroes are hitting it (real enemy heroes stand
-- within ATTACK_RADIUS and one targets it, or its health dropped in the last DAMAGE_WINDOW seconds), once a second:
--   defend if at least as many allies as attackers can be there within ARRIVE_SECONDS; up to attackers + 1 of them,
--   nearest first, get a high defend desire for that lane (a hero defends one lane at a time);
--   concede if they cannot: allies that are not already near the tower get no defend desire for it.
-- A decision holds HOLD_SECONDS unless the attack ends, so it does not flip as heroes walk in and out of range.
-- It has no opinion (nil, OHA decides) when enemies threaten the own Ancient, so the base defense always wins.
local D = {}
local variant = dofile(GetScriptDirectory()..'/FunLib/bench_variant')
local observe = dofile(GetScriptDirectory()..'/FunLib/bench_observe')

local ATTACK_RADIUS = 1200
local NEAR_RADIUS = 1600
local ANCIENT_RADIUS = 3000
local DAMAGE_WINDOW = 3
local ARRIVE_SECONDS = 18
local TP_MIN_DISTANCE = 5500 -- OHA teleports to defend only from farther than this (ability_item_usage_generic)
local TP_SECONDS = 5
local HOLD_SECONDS = 5
local DEFEND_DESIRE = 0.9

local TOWERS = {
	[LANE_TOP] = { TOWER_TOP_1, TOWER_TOP_2 },
	[LANE_MID] = { TOWER_MID_1, TOWER_MID_2 },
	[LANE_BOT] = { TOWER_BOT_1, TOWER_BOT_2 },
}

local plans = {} -- lane -> { at, tower, attackers, defenders = { [pid] = true }, concede, decidedAt }
local J

function D.Enabled()
	return variant.defensa_t12 == true
end

local function RealEnemyHero(unit)
	if unit == nil or not unit:IsAlive() or not unit:IsHero() or unit:IsIllusion() then return false end
	J = J or require(GetScriptDirectory()..'/FunLib/jmz_func')
	return not (J.IsSuspiciousIllusion and J.IsSuspiciousIllusion(unit))
end

local function HasReadyTp(hero)
	for _, slot in ipairs({ 0, 1, 2, 3, 4, 5, 15 }) do
		local item = hero:GetItemInSlot(slot)
		local name = item and item:GetName() or ""
		if (name == "item_tpscroll" or name:find("item_travel_boots")) and item:IsFullyCastable() then return true end
	end
	return false
end

local function ArriveSeconds(hero, loc)
	local distance = GetUnitToLocationDistance(hero, loc)
	if distance > TP_MIN_DISTANCE and HasReadyTp(hero) then return TP_SECONDS end
	return distance / math.max(hero:GetCurrentMovementSpeed(), 200)
end

local function AncientThreatened()
	local ancient = GetAncient(GetTeam())
	if ancient == nil then return false end
	for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES) or {}) do
		if RealEnemyHero(enemy) and GetUnitToUnitDistance(enemy, ancient) <= ANCIENT_RADIUS then return true end
	end
	return false
end

local lastHealth = {} -- tower handle -> { hp, at }

-- The tower is really being hit: an enemy hero near it targets it, or its health dropped within DAMAGE_WINDOW while
-- enemy heroes stand near. Not WasRecentlyDamagedByAnyHero: OHA's override returns nil for non-heroes (review
-- 2026-10-31), so it never fired on a tower.
local function UnderAttack(tower, near)
	for _, enemy in ipairs(near) do
		if enemy:GetAttackTarget() == tower then return true end
	end
	local now, hp = DotaTime(), tower:OriginalGetHealth()
	local last = lastHealth[tower]
	if last == nil or hp > last.hp then
		lastHealth[tower] = { hp = hp, at = now, droppedAt = -99 }
		return false
	end
	if hp < last.hp then last.droppedAt = now end
	last.hp = hp
	return now - last.droppedAt <= DAMAGE_WINDOW
end

local function AttackedTower(lane)
	for _, which in ipairs(TOWERS[lane] or {}) do
		local tower = GetTower(GetTeam(), which)
		if tower and tower:IsAlive() then
			-- The outermost standing tower is the one that matters on this lane; it must really be hit by heroes.
			local near = {}
			for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES) or {}) do
				if RealEnemyHero(enemy) and GetUnitToUnitDistance(enemy, tower) <= ATTACK_RADIUS then
					table.insert(near, enemy)
				end
			end
			local hit = UnderAttack(tower, near)
			if #near > 0 and hit then return tower, #near end
			return nil, 0
		end
	end
	return nil, 0
end

-- Allies already defending another lane, by a fresh plan.
local function Busy(lane, now)
	local busy = {}
	for other, plan in pairs(plans) do
		if other ~= lane and plan.tower and now - plan.at < 2 then
			for pid in pairs(plan.defenders) do busy[pid] = true end
		end
	end
	return busy
end

local function Plan(lane)
	local now = DotaTime()
	local plan = plans[lane]
	if plan and now - plan.at < 1 then return plan end
	local tower, attackers = AttackedTower(lane)
	if tower == nil then
		plans[lane] = { at = now, defenders = {} }
		return plans[lane]
	end
	-- The same tower still under attack: keep the decision for HOLD_SECONDS.
	if plan and plan.tower == tower and now - (plan.decidedAt or -99) < HOLD_SECONDS then
		plan.at = now
		return plan
	end
	plan = { at = now, decidedAt = now, tower = tower, attackers = attackers, defenders = {}, concede = false }
	local busy = Busy(lane, now)
	local loc = tower:GetLocation()
	local candidates = {}
	for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES) or {}) do
		local pid = ally:GetPlayerID()
		if ally:IsAlive() and not ally:IsIllusion() and IsPlayerBot(pid) and not busy[pid] then
			local t = ArriveSeconds(ally, loc)
			if t <= ARRIVE_SECONDS then table.insert(candidates, { pid = pid, t = t }) end
		end
	end
	table.sort(candidates, function(a, b) return a.t < b.t end)
	if #candidates >= attackers then
		for i = 1, math.min(#candidates, attackers + 1) do plan.defenders[candidates[i].pid] = true end
	else
		plan.concede = true
	end
	if observe then
		print(string.format("[bench] defensa t=%d lane=%d atacantes=%d llegan=%d %s", math.floor(now), lane, attackers,
			#candidates, plan.concede and "concede" or "defiende"))
	end
	plans[lane] = plan
	return plan
end

function D.DefendDesire(bot, lane)
	if not D.Enabled() or AncientThreatened() then return nil end
	local plan = Plan(lane)
	if plan.tower == nil then return nil end
	if plan.defenders[bot:GetPlayerID()] then return DEFEND_DESIRE end
	if plan.concede and GetUnitToUnitDistance(bot, plan.tower) > NEAR_RADIUS then return 0 end
	return nil
end

return D
