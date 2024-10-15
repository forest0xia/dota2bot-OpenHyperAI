local bot = GetBot()
if bot:IsInvulnerable() or not bot:IsHero() or not string.find(bot:GetUnitName(), "hero") or bot:IsIllusion() then
	return
end

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Item = require( GetScriptDirectory()..'/FunLib/aba_item' )

local PickedItem = nil
local ConsiderDroppedTime = -90
local SwappedCheeseTime = -90
local SwappedClarityTime = -90
local SwappedFlaskTime = -90
local SwappedRefresherShardTime = -90
local SwappedMoonshardTime = -90

local ignorePickupList = { }
local tryPickCount = 0
local lastCheckBotToDropTime = 0

local RuneLocations = { }

table.insert(RuneLocations, J.Utils.WisdomRunes[TEAM_DIRE])
table.insert(RuneLocations, J.Utils.WisdomRunes[TEAM_RADIANT])

function GetDesire()

	if DotaTime() >= ConsiderDroppedTime + 2.0 then
		local nDroppedItem = GetDroppedItemList()
		for _, droppedItem in pairs(nDroppedItem)
		do
			if droppedItem ~= nil
			and J.Item.GetEmptyInventoryAmount(bot) > 0 then
				local itemName = droppedItem.item:GetName()
				if not J.Utils.SetContains(itemName) and not J.Utils.HasValue(Item['tEarlyConsumableItem'], itemName) then
					-- 关键掉落物品
					if itemName == 'item_aegis' and J.GetPosition(bot) <= 3 and not J.HasItem(bot, 'item_aegis') then
						if J.Item.GetEmptyNonBackpackInventoryAmount(bot) == 0 then
							local lessValItem = J.Item.GetMainInvLessValItemSlot(bot)
							local emptySlot = J.Item.GetEmptyBackpackSlot(bot)
							if lessValItem ~= -1 and emptySlot ~= -1 then
								bot:ActionImmediate_SwapItems(emptySlot, lessValItem)
							end
						end
						PickedItem = droppedItem
					end
					if itemName == 'item_cheese' and J.GetPosition(bot) <= 3 and not J.HasItem(bot, 'item_aegis') then PickedItem = droppedItem end
					if itemName == 'item_refresher_shard' then
						local mostCDHero = J.GetMostUltimateCDUnit()
						if mostCDHero ~= nil
						and mostCDHero:IsBot()
						and bot == mostCDHero then
							PickedItem = droppedItem
						end
					end

					--尝试捡起自己的物品
					local nDropOwner = droppedItem.owner
					if nDropOwner ~= nil and nDropOwner == bot and not string.find(itemName, 'token') then PickedItem = droppedItem end

					if PickedItem ~= nil then
						return RemapValClamped(J.Utils.GetLocationToLocationDistance(droppedItem.location, bot:GetLocation()),
							5000, 0, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_VERYHIGH)
					end
				end
				
			end
		end
		ConsiderDroppedTime = DotaTime()
	end

	TrySwapInvItemForCheese()
	TrySwapInvItemForRefresherShard()
	TrySwapInvItemForClarity()
	TrySwapInvItemForFlask()
	TrySwapInvItemForMoonshard()

	-- -- can't take runes normally
	-- for _, runeLoc in pairs( RuneLocations )
	-- do
	-- 	if J.Utils.GetLocationToLocationDistance(runeLoc, bot:GetLocation()) < 300 then
	-- 		return BOT_ACTION_DESIRE_VERYHIGH
	-- 	end
	-- end

	return BOT_MODE_DESIRE_NONE
end

-- Swap Items for healing
function TrySwapInvItemForClarity()
	if 	DotaTime() >= SwappedClarityTime + 6.0
	and bot:GetActiveMode() ~= BOT_MODE_WARD
	then
		local cSlot = bot:FindItemSlot('item_clarity')
		if cSlot and bot:GetItemSlotType(cSlot) == ITEM_SLOT_TYPE_BACKPACK
		then
			local lessValItem = J.Item.GetMainInvLessValItemSlot(bot)

			if lessValItem ~= -1
			then
				bot:ActionImmediate_SwapItems(cSlot, lessValItem)
			end
		end

		SwappedClarityTime = DotaTime()
	end
end
function TrySwapInvItemForFlask()
	if 	DotaTime() >= SwappedFlaskTime + 6.0
	and bot:GetActiveMode() ~= BOT_MODE_WARD
	then
		local cSlot = bot:FindItemSlot('item_flask')
		if cSlot and bot:GetItemSlotType(cSlot) == ITEM_SLOT_TYPE_BACKPACK
		then
			local lessValItem = J.Item.GetMainInvLessValItemSlot(bot)

			if lessValItem ~= -1
			then
				bot:ActionImmediate_SwapItems(cSlot, lessValItem)
			end
		end

		SwappedFlaskTime = DotaTime()
	end
end

-- Swap Items for moonshard
function TrySwapInvItemForMoonshard()
	if DotaTime() >= SwappedMoonshardTime + 10.0
	and bot:GetActiveMode() ~= BOT_MODE_WARD
	then
		local cSlot = bot:FindItemSlot('item_moon_shard')
		if cSlot and bot:GetItemSlotType(cSlot) == ITEM_SLOT_TYPE_BACKPACK
		then
			local lessValItem = J.Item.GetMainInvLessValItemSlot(bot)

			if lessValItem ~= -1
			then
				bot:ActionImmediate_SwapItems(cSlot, lessValItem)
			end
		end
		SwappedMoonshardTime = DotaTime()
	end
end

-- Swap Items for Cheese
function TrySwapInvItemForCheese()
	if 	DotaTime() >= SwappedCheeseTime + 2.0
	and bot:GetActiveMode() ~= BOT_MODE_WARD
	then
		local cSlot = bot:FindItemSlot('item_cheese')

		if bot:GetItemSlotType(cSlot) == ITEM_SLOT_TYPE_BACKPACK
		then
			local lessValItem = J.Item.GetMainInvLessValItemSlot(bot)

			if lessValItem ~= -1
			then
				bot:ActionImmediate_SwapItems(cSlot, lessValItem)
			end
		end

		SwappedCheeseTime = DotaTime()
	end
end

-- Swap Items for Refresher Shard
function TrySwapInvItemForRefresherShard()
	if 	DotaTime() >= SwappedRefresherShardTime + 2.0
	and bot:GetActiveMode() ~= BOT_MODE_WARD
	then
		local rSlot = bot:FindItemSlot('item_refresher_shard')

		if bot:GetItemSlotType(rSlot) == ITEM_SLOT_TYPE_BACKPACK
		then
			local lessValItem = J.Item.GetMainInvLessValItemSlot(bot)

			if lessValItem ~= -1
			then
				bot:ActionImmediate_SwapItems(rSlot, lessValItem)
			end
		end

		SwappedRefresherShardTime = DotaTime()
	end
end

function OnEnd()
	PickedItem = nil
end

function Think()

	if PickedItem ~= nil then
		local itemName = PickedItem.item:GetName()
		if tryPickCount >= 3 and not Utils.SetContains(itemName) then
			tryPickCount = 0
			Utils.AddToSet(ignorePickupList, PickedItem.item)
		end

		-- 先尝试捡起
		if not Utils.SetContains(itemName) and not Utils.HasValue(Item['tEarlyConsumableItem'], itemName)
		then
			if J.Item.GetEmptyInventoryAmount(bot) > 0 then
				if itemName == 'item_aegis'
				or itemName == 'item_cheese' then
					if J.GetPosition(bot) <= 3 and not J.HasItem(bot, 'item_aegis') then
						GoPickUpItem(PickedItem, 0)
					end
				else
					GoPickUpItem(PickedItem, 260)
				end
			end
		end

	end

	if DotaTime() > 0 and DotaTime() - lastCheckBotToDropTime > 3
	then
		lastCheckBotToDropTime = DotaTime()

		-- 再尝试丢/卖掉
		if Utils.CountBackpackEmptySpace(bot) <= 1 then
			for i = 1, #Item['tEarlyConsumableItem']
			do
				local itemName = Item['tEarlyConsumableItem'][i]
				local itemSlot = bot:FindItemSlot( itemName )
				if itemSlot >= 6 and itemSlot <= 8
				then
					local distance = bot:DistanceFromFountain()
					if distance <= 300 then
						bot:ActionImmediate_SellItem( bot:GetItemInSlot( itemSlot ))
					elseif bot:GetNetWorth() >= 15000 and distance >= 3000 then
						bot:Action_DropItem( bot:GetItemInSlot( itemSlot ), bot:GetLocation() )
					end
				end
			end
		end
	end
end

function GoPickUpItem(goPickItem, minCost)
	Utils.PrintTable(goPickItem)

	local distance = GetUnitToLocationDistance(bot, goPickItem.location)
	if distance > 200 and distance < 2000
	then
		bot:Action_MoveToLocation(goPickItem.location)
	elseif distance <= 100 and GetItemCost(itemName) >= minCost then
		tryPickCount = tryPickCount + 1
		bot:Action_PickUpItem(goPickItem.item)
		return
	end
end