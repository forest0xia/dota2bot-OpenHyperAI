local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local bot = GetBot()
local botName = bot:GetUnitName()

if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end

local team = GetTeam()
local X = { }
local laneToRoam = nil
local lastRoamDecisionTime = DotaTime()
local roamDecisionHoldTime = 1.25 * 60 -- cant change dicision within this time
local TwinGates = { }
local targetGate
local gateWarp = bot:GetAbilityByName("twin_gate_portal_warp")
local enableGateUsage = false -- to be fixed
local arriveRoamLocTime = 0
local roamTimeAfterArrival = 0.55 * 60 -- stay to roam after arriving the location
local roamGapTime = 3 * 60 -- don't roam again within this duration after roaming once.

if J.Utils.BuggyHeroesDueToValveTooLazy[botName] then
	function GetDesire()
		if J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() or not bot:IsAlive() or gateWarp == nil then return BOT_ACTION_DESIRE_NONE end

		if #TwinGates == 0 then
			for _, unit in pairs(GetUnitList(UNIT_LIST_ALL))
			do
				if unit:GetUnitName() == 'npc_dota_unit_twin_gate'
				then
					table.insert(TwinGates, unit)
				end
				if #TwinGates >= 2 then
					break
				end
			end
		end

		if J.IsInLaningPhase() then
			local botLvl = bot:GetLevel()
			if (J.GetPosition(bot) == 2 and botLvl >= 6) -- mid player roaming
			or (J.GetPosition(bot) > 3 and botLvl >= 3) -- supports roaming
			then
				return CheckLaneToRoam()
			end
		end
		return BOT_MODE_DESIRE_NONE
	end
else
	function GetDesire() return BOT_MODE_DESIRE_NONE end
end


function Think()
    if J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() then return end

	if laneToRoam ~= nil then
		local targetLoc = GetLaneFrontLocation(GetTeam(), laneToRoam, -300)
		local distanceToRoamLoc = GetUnitToLocationDistance(bot, targetLoc)
		if distanceToRoamLoc > 5000 then
			if J.GetPosition(bot) > 3
			and targetGate ~= nil
			and enableGateUsage
			then
				local distanceToGate = GetUnitToUnitDistance(bot, targetGate)
				if distanceToGate > 350 then
					bot:Action_MoveToLocation(targetGate:GetLocation())
					return
				elseif gateWarp:IsFullyCastable()
				then
					print('Trying to use gate '..botName)
					bot:Action_UseAbilityOnEntity(gateWarp, targetGate)
					return
				end
			end
		end

		if distanceToRoamLoc > bot:GetAttackRange() + 300 and bot:WasRecentlyDamagedByAnyHero(1.5) then
			bot:Action_MoveToLocation(targetLoc)
		end
		if distanceToRoamLoc < 600 and DotaTime() - arriveRoamLocTime > roamTimeAfterArrival * 1.1 then
			arriveRoamLocTime = DotaTime()
		end
		if DotaTime() - arriveRoamLocTime > roamTimeAfterArrival then
			laneToRoam = nil
		end
	end
end

function OnStart()
	lastRoamDecisionTime = DotaTime()
end

function OnEnd()
	laneToRoam = nil
	targetGate = nil
end

function CheckLaneToRoam()

	if DotaTime() - lastRoamDecisionTime <= roamDecisionHoldTime and laneToRoam ~= nil then
		return BOT_ACTION_DESIRE_VERYHIGH
	end

	if DotaTime() - lastRoamDecisionTime < roamGapTime then
		return BOT_MODE_DESIRE_NONE
	end

	if not HasSufficientMana(300) then -- idelaly should have mana at least able to use 2 abilities + tp.
		return BOT_MODE_DESIRE_NONE
	end

	local lanes = {
		{LANE_TOP, TOWER_TOP_1},
		{LANE_MID, TOWER_MID_1},
		{LANE_BOT, TOWER_BOT_1}
	}

	for _, lane in pairs(lanes)
	do
		local enemyCountInLane = J.GetEnemyCountInLane(lane[1])
		if enemyCountInLane > 0
		then
			local laneFront = GetLaneFrontLocation(GetTeam(), lane[1], 0)
			local tTower = GetTower(GetTeam(), lane[2])
			local laneFrontToT1Dist = GetUnitToLocationDistance(tTower, laneFront)
			local nInRangeAlly = J.GetAlliesNearLoc(laneFront, 1200)

			if tTower ~= nil
			and enableGateUsage
			and laneFrontToT1Dist < 2000
			then
				targetGate = GetGateNearLane(laneFront)

				if enemyCountInLane >= #nInRangeAlly
				then
					laneToRoam = lane[1]
					return RemapValClamped(GetUnitToUnitDistance(bot, targetGate), 5000, 600, BOT_ACTION_DESIRE_VERYLOW, BOT_ACTION_DESIRE_VERYHIGH )
				end
			end

			if #enemyCountInLane >= 1 then
				return RemapValClamped(laneFrontToT1Dist, 4000, 400, BOT_ACTION_DESIRE_LOW, BOT_ACTION_DESIRE_VERYHIGH)
			end

		end
	end

	return BOT_MODE_DESIRE_NONE
end

function HasSufficientMana(nMana)
	return bot:GetMana() > nMana and not botName == 'npc_dota_hero_huskar'
end

function GetGateNearLane(laneLoc)
	local minDis = 99999
	local tGate
	for _, gate in pairs(TwinGates)
	do
		local distanceToGate = GetUnitToLocationDistance(gate, laneLoc)
		if distanceToGate < minDis then
			tGate = gate
			minDis = distanceToGate
		end
	end
	return tGate
end