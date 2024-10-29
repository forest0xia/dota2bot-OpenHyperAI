local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(bot:GetUnitName(), "hero") or bot:IsIllusion() then return end

local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Ward = require(GetScriptDirectory() ..'/FunLib/aba_ward_utility')

local AvailableSpots = {}
local nWardCastRange = 500
local ItemWard = nil
local WardTargetDist = 0
local WardTargetLocation
local SmokeOfDeceit = nil
local WardCastTime = J.IsModeTurbo() and -45 or -90
local ItemSwapTime = J.IsModeTurbo() and -45 or -90
local EnemyTeam = nil

bot.ward = false
bot.steal = false

local Route1 = {
	Vector(-6263, 2265, 0),
	Vector(-5012, 4765, 0),
	Vector(-3212, 4865, 0),
	Vector(-3706, 2950, 0),
}

local Route2 = {
	Vector(6041, -1978, 0),
	Vector(4622, -4873, 0),
	Vector(3561, -4297, 0),
	Vector(3957, -2808, 0),
}

local vNonStuck = Vector(-2610, 538, 0)
local hasChatted = false

function GetDesire()
	if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return BOT_MODE_DESIRE_NONE end
	if bot:IsChanneling()
	or bot:IsIllusion()
	or bot:IsInvulnerable()
	or bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE
	or not bot:IsHero()
	or not IsSuitableToWard()
	then
		return BOT_MODE_DESIRE_NONE
	end

	ItemWard = Ward.GetItemWard(bot)

	if bot.WardTable == nil then bot.WardTable = {} end

	-- 如果在打高地 就别撤退去干别的
	if J.Utils.IsTeamPushingSecondTierOrHighGround(bot) then
		return BOT_MODE_DESIRE_NONE
	end

	if ItemWard ~= nil
	and ItemWard:GetCooldownTimeRemaining() == 0
	then

		Pinged, WardTargetLocation = Ward.IsPingedByHumanPlayer(bot)
		if Pinged
		and WardTargetLocation ~= nil
		and not Ward.IsOtherWardClose(WardTargetLocation)
		then
			bot.ward = true
			return RemapValClamped(GetUnitToLocationDistance(bot, WardTargetLocation), 1200, 0, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_HIGH)
		end

		AvailableSpots = Ward.GetAvailableSpot(bot)
		WardTargetLocation, WardTargetDist = Ward.GetClosestSpot(bot, AvailableSpots)

		if WardTargetLocation ~= nil
		and DotaTime() > (J.IsModeTurbo() and -45 or -60)
		and DotaTime() < 0
		and not IsEnemyCloserToWardLocation(WardTargetLocation, WardTargetDist)
		then
			bot.ward = true
			return BOT_MODE_DESIRE_HIGH
		end

		if WardTargetLocation ~= nil
		and DotaTime() > WardCastTime + 1.0
		and not IsEnemyCloserToWardLocation(WardTargetLocation, WardTargetDist)
		then
			bot.ward = true
			return RemapValClamped(WardTargetDist, 3500, 200, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
		end
	else
		bot.lastPlayerChat = nil
	end

	return BOT_MODE_DESIRE_NONE
end

function OnStart()
	if ItemWard ~= nil
	then
		local wardSlot = bot:FindItemSlot(ItemWard:GetName())

		if bot:GetItemSlotType(wardSlot) == ITEM_SLOT_TYPE_BACKPACK
		then
			local leastCostItem = FindLeastItemSlot()

			if leastCostItem ~= -1
			then
				ItemSwapTime = DotaTime()
				bot:ActionImmediate_SwapItems(wardSlot, leastCostItem)
				return
			end
		end
	end
end

function OnEnd()
	AvailableSpots = {}
	bot.ward = false
	bot.steal = false
	ItemWard = nil

	if ItemWard ~= nil
	then
		local wardSlot = bot:FindItemSlot(ItemWard:GetName())

		if wardSlot >= 0
		and wardSlot <= 5
		then
			local mostCostItem = FindMostItemSlot()

			if mostCostItem ~= -1
			then
				bot:ActionImmediate_SwapItems(wardSlot, mostCostItem)
				return
			end
		end
	end
end

function Think()
	if GetGameState() ~= GAME_STATE_PRE_GAME
	and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS
	then
		return
	end

	if bot.ward
	then
		if (WardTargetDist <= nWardCastRange)
		or Pinged
		then
			if DotaTime() > ItemSwapTime + 7.0
			and ItemWard ~= nil and not ItemWard:IsNull()
			then
				-- ^gives object [none]?
				local wardName = ItemWard:GetName()
				table.insert(bot.WardTable, {
					type= string.find(wardName, 'observer') and 'observer' or 'sentry',
					timePlanted= DotaTime(),
					loc= WardTargetLocation,
					duration= string.find(wardName, 'observer') and 360 or 420,
				})

				bot:Action_UseAbilityOnLocation(ItemWard, WardTargetLocation)
				WardCastTime = DotaTime()
				return
			else
				if WardTargetLocation.x == Vector(-2948, 769, 0)
				then
					bot:Action_MoveToLocation(vNonStuck + RandomVector(300))
					return
				else
					bot:Action_MoveToLocation(WardTargetLocation + RandomVector(300))
					return
				end
			end
		else
			if WardTargetLocation == Vector(-2948, 769, 0)
			then
				bot:Action_MoveToLocation(vNonStuck)
				return
			else
				bot:Action_MoveToLocation(WardTargetLocation)
				return
			end
		end
	end
end

function CountStealingUnit()
	local count = 0

	for i, id in pairs(GetTeamPlayers(GetTeam()))
	do
		local member = GetTeamMember(i)

		if IsPlayerBot(id)
		and member ~= nil
		and member.steal
		then
			count = count + 1
		end
	end

	return count
end

function CountStealUnitNearLoc(loc, nRadius)
	local count = 0

	for i, id in pairs(GetTeamPlayers(GetTeam()))
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member.steal
		and GetUnitToLocationDistance(member, loc) <= nRadius
		then
			count = count + 1
		end
	end

	return count
end

function FindLeastItemSlot()
	local minCost = 100000
	local idx = -1

	for i = 0,5
	do
		if bot:GetItemInSlot(i) ~= nil
		and bot:GetItemInSlot(i):GetName() ~= 'item_aegis'
		then
			local item = bot:GetItemInSlot(i):GetName()

			if GetItemCost(item) < minCost
			then
				minCost = GetItemCost(item)
				idx = i
			end
		end
	end

	return idx
end

function FindMostItemSlot()
	local maxCost = 0
	local idx = -1

	for i = 6, 8
	do
		if bot:GetItemInSlot(i) ~= nil
		then
			local item = bot:GetItemInSlot(i):GetName()

			if GetItemCost(item) > maxCost
			then
				maxCost = GetItemCost(item)
				idx = i
			end
		end
	end

	return idx
end

function IsSuitableToWard()
	local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

	local nMode = bot:GetActiveMode()

	if (nMode == BOT_MODE_RETREAT
		and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH)
	or nMode == BOT_MODE_ATTACK
	or (nMode == BOT_MODE_RUNE and DotaTime() > 0)
	or nMode == BOT_MODE_DEFEND_ALLY
	or nMode == BOT_MODE_DEFEND_TOWER_TOP
	or nMode == BOT_MODE_DEFEND_TOWER_MID
	or nMode == BOT_MODE_DEFEND_TOWER_BOT
	or (nEnemyHeroes ~= nil and #nEnemyHeroes >= 1 and IsIBecameTheTarget(nEnemyHeroes))
	or bot:WasRecentlyDamagedByAnyHero(5.0)
	then
		return false
	end

	return true
end

function IsIBecameTheTarget(units)
	for _, u in pairs(units)
	do
		if u ~= nil
		and u:IsAlive()
		and u:CanBeSeen()
		and u:GetAttackTarget() == bot
		then
			return true
		end
	end

	return false
end

function IsEnemyCloserToWardLocation(wardLoc, botDist)
	if EnemyTeam == nil
	then
		EnemyTeam = GetTeamPlayers(GetOpposingTeam())
	end

	for _, id in pairs(EnemyTeam)
	do
		local info = GetHeroLastSeenInfo(id)

		if info ~= nil
		then
			local dInfo = info[1]

			if dInfo ~= nil
			and dInfo.time_since_seen < 3.0
			and J.GetDistance(dInfo.location, wardLoc) <  botDist
			then
				return true
			end
		end
	end

	return false
end

function GetItem(item_name)
	for i = 0, 5
	do
		local item = bot:GetItemInSlot(i)

		if item ~= nil
		and item:GetName() == item_name
		then
			return item
		end
	end

	return nil
end
