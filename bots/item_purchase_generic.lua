local Item = require( GetScriptDirectory()..'/FunLib/aba_item' )
local Role = require( GetScriptDirectory()..'/FunLib/aba_role' )
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Utils = require( GetScriptDirectory()..'/FunLib/utils')

local bot = GetBot()

local X = {}

if bot:IsInvulnerable()
	or not bot:IsHero()
	or bot:IsIllusion()
then
	return
end

local BotBuild = require( GetScriptDirectory() .. "/BotLib/" .. string.gsub( bot:GetUnitName(), "npc_dota_", "" ) )

if BotBuild == nil then return end

bot.itemToBuy = {}
bot.currentItemToBuy = nil
bot.currentComponentToBuy = nil
bot.currListItemToBuy = {}
bot.SecretShop = false

local sPurchaseList = BotBuild['sBuyList']
local sItemSellList = BotBuild['sSellList']


if sPurchaseList == nil then
	print("[ERROR] Can't load purchase list for: " .. bot:GetUnitName())
	print("Stack Trace:", debug.traceback())
	return
end

for i = 1, #sPurchaseList
do
	bot.itemToBuy[i] = sPurchaseList[#sPurchaseList - i + 1]
end

if Role.IsBanShadow()
then

	for i = 1, #bot.itemToBuy
	do 
		if bot.itemToBuy[i] == "item_glimmer_cape"
		then
			bot.itemToBuy[i] = "item_tpscroll"
		end
	end

end


bot.sell_time = -90
local check_time = -90

bot.countInvCheck = 0

bot.lastItemToBuy = nil
bot.bPurchaseFromSecret = false
bot.hasBuyShard = true
local itemCost = 0
local courier = nil
local t3AlreadyDamaged = false
local t3Check = -90

local function GeneralPurchase()

	if bot.lastItemToBuy ~= bot.currentComponentToBuy
	then
		bot.lastItemToBuy = bot.currentComponentToBuy
		bot:SetNextItemPurchaseValue( GetItemCost( bot.currentComponentToBuy ) )
		bot.bPurchaseFromSecret = IsItemPurchasedFromSecretShop( bot.currentComponentToBuy )
		itemCost = GetItemCost( bot.currentComponentToBuy )
	end

	if bot.currentComponentToBuy == "item_infused_raindrop"
		or bot.currentComponentToBuy == "item_tome_of_knowledge"
		or bot.currentComponentToBuy == "item_flask"
	then
		if GetItemStockCount( bot.currentComponentToBuy ) <= 0
		then
			ClearBuyList()
			return
		end
	end

	local cost = itemCost


	if bot.lastItemToBuy == 'item_boots'
		and bot.currentItemToBuy == 'item_travel_boots'
		and Item.HasBootsInMainSolt( bot )
	then
		cost = GetItemCost( 'item_travel_boots' )
	end
	


	if bot:GetLevel() >= 18
		and t3AlreadyDamaged == false
		and DotaTime() > t3Check + 1.0
	then

		for i = 2, 8, 3
		do
			local tower = GetTower( GetTeam(), i )
			if tower == nil or tower:GetHealth() / tower:GetMaxHealth() < 0.3
			then
				t3AlreadyDamaged = true
				break
			end
		end


		for i = 1, 7, 3
		do
			local tower = GetTower( GetTeam(), i )
			if tower ~= nil
				and tower:IsAlive()
			then
				t3AlreadyDamaged = false
				break
			end
		end


		for i = 9, 10, 1
		do
			local tower = GetTower( GetTeam(), i )
			if tower == nil
				or tower:GetHealth() / tower:GetMaxHealth() < 0.9
			then
				t3AlreadyDamaged = true
				break
			end
		end


		if DotaTime() >= 54 * 60 then t3AlreadyDamaged = true end

		t3Check = DotaTime()

	elseif t3AlreadyDamaged == true
			and bot:GetBuybackCooldown() <= 10
	then
		cost = itemCost + bot:GetBuybackCost() + bot:GetNetWorth() / 40 - 300
	end

	--如果只剩下一个小配件则不留
	if #bot.currListItemToBuy == 1
		or Role.IsPvNMode()
	then
		cost = itemCost
	end

	--从第12分钟起存钱买魔晶
	if not bot.hasBuyShard
		and DotaTime() > 12 * 60
	then
		local shardCDTime = 15 * 60 - DotaTime()
		if shardCDTime < 0
		then
			cost = cost + 1400
		else
			cost = cost + 1400 * ( 1 - shardCDTime / 300 )
		end
	end

	--开始购买魔晶
	if bot.currentComponentToBuy == "item_aghanims_shard"
	then
		bot.hasBuyShard = false
		ClearBuyList()
		return
	end

	--达到金钱需要时购物
	if bot:GetGold() >= cost
		and bot:GetItemInSlot( 14 ) == nil
	then

		if courier == nil
		then
			courier = bot.theCourier
		end

		--当信使购买神秘商店物品后
		if bot.SecretShop
			and courier ~= nil
			and GetCourierState( courier ) == COURIER_STATE_IDLE
			and courier:DistanceFromSecretShop() == 0
		then
			if courier:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) == PURCHASE_ITEM_SUCCESS
			then
				ClearBuyList()
				bot.SecretShop = false
				return
			end
		end

		--决定是否在神秘购物
		if bot.bPurchaseFromSecret
			and bot:DistanceFromSecretShop() > 0
		then
			bot.SecretShop = true
		else
			if Utils.CountBackpackEmptySpace(bot) > 0 -- has empty slot
			or bot:DistanceFromSecretShop() > 700
			then
				if bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) == PURCHASE_ITEM_SUCCESS
				then
					ClearBuyList()
					bot.SecretShop = false
					return
				else
					if GetItemStockCount(bot.currentComponentToBuy ) < 1 then
						-- out of stock, skip that item.
						-- print( bot:GetUnitName().." failed to purchase item - "..bot.currentComponentToBuy.." : out of stock.")
						ClearBuyList()
						bot.SecretShop = false
					else
						print( bot:GetUnitName().." 未能购买物品 "..bot.currentComponentToBuy.." : "..tostring( bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) ) )
					end
				end
			end
		end
	else
		bot.SecretShop = false
	end
end


--加速模式购物逻辑
local function TurboModeGeneralPurchase()

	if bot.lastItemToBuy ~= bot.currentComponentToBuy
	then
		bot.lastItemToBuy = bot.currentComponentToBuy
		bot:SetNextItemPurchaseValue( GetItemCost( bot.currentComponentToBuy ) )
		itemCost = GetItemCost( bot.currentComponentToBuy )
		bot.lastItemToBuy = bot.currentComponentToBuy
	end

	if bot.currentComponentToBuy == "item_infused_raindrop"
		or bot.currentComponentToBuy == "item_tome_of_knowledge"
	then
		if GetItemStockCount( bot.currentComponentToBuy ) <= 0
		then
			ClearBuyList()
			return
		end
	end

	local cost = itemCost

	if bot.lastItemToBuy == 'item_boots'
		and bot.currentItemToBuy == 'item_travel_boots'
		and Item.HasBootsInMainSolt( bot )
	then
		cost = GetItemCost( 'item_travel_boots' )
	end
	

	if not bot.hasBuyShard
		and DotaTime() > 6 * 60
	then
		local shardCDTime = 10 * 60 - DotaTime()
		if shardCDTime < 0
		then
			cost = cost + 1400
		else
			cost = cost + 1400 * ( 1 - shardCDTime / 180 )
		end
	end

	if bot.currentComponentToBuy == "item_aghanims_shard"
	then
		bot.hasBuyShard = false
		ClearBuyList()
		return
	end

	if bot:GetGold() >= cost
		and bot:GetItemInSlot( 14 ) == nil
	then
		if bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) == PURCHASE_ITEM_SUCCESS
		then
			ClearBuyList()
			return
		else
			if GetItemStockCount(bot.currentComponentToBuy ) < 1 then
				-- out of stock, skip that item.
				-- print( bot:GetUnitName().." failed to purchase item - "..bot.currentComponentToBuy.." : out of stock.")
				ClearBuyList()
			else
				print( bot:GetUnitName().." 未能购买物品 "..bot.currentComponentToBuy.." : "..tostring( bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) ) )
			end
		end
	end
end


bot.lastInvCheck = -90
bot.fullInvCheck = -90
bot.switchTime = 0
bot.hasBuyClarity = false
local lastBootsCheck = -90
local buyBootsStatus = false
local buyRD = false

local buyWardTime = -999

local buyBookTime = 0

local initSmoke = false

function ItemPurchaseThink()

	if ( GetGameState() ~= GAME_STATE_PRE_GAME and GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS )
	then return	end

	
	if bot == Utils['LoneDruid'].hero then
		local bear = Utils['LoneDruid'].bear
		if bear ~= nil then
			local hEnemyList = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE)
			if #hEnemyList >= 1 then return end
	
			if not bear:IsAlive() or bear:IsChanneling() or bear:IsUsingAbility() or Utils.CountBackpackEmptySpace(bear) <= 0 then return end
			if bear:HasModifier('modifier_item_ultimate_scepter_consumed') then return end

			local bearNetworth = Item.GetItemTotalWorthInSlots(bear)
			if GetUnitToUnitDistance(bot, bear) < 400 then
				for i = 0, 9
				do
					local item = bot:GetItemInSlot( i )
					if item ~= nil
					then
						local itemName = item:GetName()
						if Utils.HasValue(Item['tEarlyConsumableItem'], itemName)
						or Utils.HasValue(Item['item_ultimate_scepter'], itemName)
						or (string.find(itemName, 'boot') and bearNetworth > 600)
						or itemName == 'item_tpscroll' and Item.HasItem(bear, 'item_tpscroll')
						then
							-- do nothing, keep it.
						elseif Utils.CountBackpackEmptySpace(bear) >= 1 then
							bot:Action_DropItem(item, bear:GetLocation())
						end
					end
				end
			end
		end
	end
	if Utils.IsBear(bot) and bot:IsAlive() then
		local dropItemList = GetDroppedItemList()
		for _, tDropItem in pairs( dropItemList )
		do
			if tDropItem.owner == Utils['LoneDruid'].hero and not string.find(tDropItem.item:GetName(), 'token')
			and not (string.find(tDropItem.item:GetName(), 'boot') and Item.HasItemWithName(bot, 'boot')) then
				local distance = GetUnitToLocationDistance(bot, tDropItem.location)
				if distance > 200 and distance < 1000 and tDropItem.owner == bot
				then
					bot:Action_MoveToLocation(tDropItem.location)
				elseif distance <= 100 then
					bot:Action_PickUpItem(tDropItem.item)
					return
				end
			end
		end
	end

	if bot:HasModifier( 'modifier_arc_warden_tempest_double' )
	or (DotaTime() > 0 and J.IsMeepoClone(bot))
	then
		bot.itemToBuy = {}
		return
	end

	--------*******----------------*******----------------*******--------
	local currentTime = DotaTime()
	local botName = bot:GetUnitName()
	local botLevel = bot:GetLevel()
	local botGold = bot:GetGold()
	local botWorth = bot:GetNetWorth()
	local botMode = bot:GetActiveMode()
	local botHP	= bot:GetHealth() / bot:GetMaxHealth()
	--------*******----------------*******----------------*******--------



	--更新队伍里是否有辅助的定位
	if Role['supportExist'] == nil then Role.UpdateSupportStatus( bot ) end

	--更新敌方是否有隐身英雄或道具的状态
	if Role['invisEnemyExist'] == false then Role.UpdateInvisEnemyStatus( bot ) end

	--更新是否出鞋的状态
	if buyBootsStatus == false
		and currentTime > lastBootsCheck + 2.0
	then
		buyBootsStatus = Item.HasBuyBoots( bot )
		lastBootsCheck = currentTime
	end

	--买小净化
	if J.GetMP(bot) < 0.3
	and bot:DistanceFromFountain() > 2000
	and bot:GetCourierValue() == 0
	and GetItemStockCount('item_clarity') > 1
	and Item.GetItemCharges(bot, 'item_clarity') <= 0
	and botGold >= GetItemCost( "item_clarity" )
	then
		bot.hasBuyClarity = true
		bot:ActionImmediate_PurchaseItem( "item_clarity" )
	end

	--辅助定位英雄购买辅助物品
	if bot.theRole == 'support'
	then
		if currentTime > 30 and not bot.hasBuyClarity
			and botGold >= GetItemCost( "item_clarity" )
			and not Role.IsPvNMode()
			and Utils.CountBackpackEmptySpace(bot) >= 2
		then
			bot.hasBuyClarity = true
			bot:ActionImmediate_PurchaseItem( "item_clarity" )
		elseif botLevel >= 5
			and Role['invisEnemyExist'] == true
			and buyBootsStatus == true
			and botGold >= GetItemCost( "item_dust" )
			and Item.GetEmptyInventoryAmount( bot ) >= 2
			and Item.GetItemCharges( bot, "item_dust" ) <= 0
			and bot:GetCourierValue() == 0
			and not J.HasItem(bot, 'item_ward_sentry')
		then
			bot:ActionImmediate_PurchaseItem( "item_dust" )
		end
	end

	-- Init Healing Items in Lane; works for now
	if J.IsInLaningPhase()
	then
		if botLevel < 6
		and bot:IsAlive()
		and bot:GetCourierValue() == 0
		and bot:FindItemSlot('item_flask') < 0
		and bot:FindItemSlot('item_tango') < 0
		and bot:DistanceFromFountain() > 2000
		and bot:GetStashValue() > 0
		and not bot:HasModifier('modifier_elixer_healing')
		and not bot:HasModifier('modifier_filler_heal')
		and not bot:HasModifier('modifier_flask_healing')
		and not bot:HasModifier('modifier_fountain_aura_buff')
		and not bot:HasModifier('modifier_juggernaut_healing_ward_heal')
		and not bot:HasModifier('modifier_warlock_shadow_word')
		and not IsThereHealingInStash(bot)
		and Item.GetEmptyInventoryAmount(bot) >= 1
		and J.GetHP(bot) < 0.5
		then
			local partner = J.GetLanePartner(bot)

			if bot:GetHealthRegen() <= 10
			then
				if J.IsCore(bot)
				then
					if partner ~= nil
					then
						if  partner:FindItemSlot('item_flask') < 0
						and partner:FindItemSlot('item_tango') < 0
						and Item.GetItemCharges(bot, 'item_flask') <= 0
						and botGold >= GetItemCost('item_flask')
						and GetItemStockCount('item_flask') > 1
						then
							bot:ActionImmediate_PurchaseItem('item_flask')
						end
					else
						if  Item.GetItemCharges(bot, 'item_flask') <= 0
						and botGold >= GetItemCost('item_flask')
						and GetItemStockCount('item_flask') > 1
						and (not J.HasItem(bot, 'item_bottle')
							or (J.HasItem(bot, 'item_bottle') and Item.GetItemCharges(bot, 'item_bottle') <= 0))
						then
							bot:ActionImmediate_PurchaseItem('item_flask')
						end
					end
				else
					if Item.GetItemCharges(bot, 'item_flask') <= 0
					and botGold >= GetItemCost('item_flask')
					and GetItemStockCount('item_flask') > 1
					then
						bot:ActionImmediate_PurchaseItem('item_flask')
					end
				end
			else
				if J.IsCore(bot)
				then
					if partner ~= nil
					then
						if  partner:FindItemSlot('item_flask') < 0
						and partner:FindItemSlot('item_tango') < 0
						and partner ~= nil
						and Item.GetItemCharges(bot, 'item_tango') <= 0
						and botGold >= GetItemCost('item_tango')
						and GetItemStockCount('item_flask') > 1
						then
							bot:ActionImmediate_PurchaseItem('item_tango')
						end
					else
						if  Item.GetItemCharges(bot, 'item_flask') <= 0
						and GetItemStockCount('item_flask') > 1
						and botGold >= GetItemCost('item_flask')
						and (not J.HasItem(bot, 'item_bottle')
							or (J.HasItem(bot, 'item_bottle') and Item.GetItemCharges(bot, 'item_bottle') <= 0))
						then
							bot:ActionImmediate_PurchaseItem('item_flask')
						end
					end
				else
					if Item.GetItemCharges(bot, 'item_tango') <= 0
					and botGold >= GetItemCost('item_tango')
					then
						bot:ActionImmediate_PurchaseItem('item_tango')
					end
				end
			end
		end
	end

	-- Observer and Sentry Wards
	if J.GetPosition(bot) == 4 and DotaTime() > 300 and botWorth < 10000
	then
		local wardType = 'item_ward_sentry'

		if  GetItemStockCount(wardType) > 1
		and botGold >= GetItemCost(wardType)
		and Item.GetEmptyInventoryAmount(bot) >= 2
		and Item.GetItemCharges(bot, wardType) < 1
		and bot:GetCourierValue() == 0
		then
			bot:ActionImmediate_PurchaseItem(wardType)
		end
	end

	if J.GetPosition(bot) == 5 and botWorth < 10000
	then
		local wardType = 'item_ward_observer'

		if  GetItemStockCount(wardType) > 1
		and botGold >= GetItemCost(wardType)
		and Item.GetEmptyInventoryAmount(bot) >= 2
		and Item.GetItemCharges(bot, wardType) < 2
		and bot:GetCourierValue() == 0
		then
			bot:ActionImmediate_PurchaseItem(wardType)
		end
	end

	-- Smoke of Deceit
	if J.GetPosition(bot) == 5 and botWorth < 10000
	and Utils.CountBackpackEmptySpace(bot) >= 2
	and GetItemStockCount('item_smoke_of_deceit') > 1
	and botGold >= GetItemCost('item_smoke_of_deceit')
	and Item.GetEmptyInventoryAmount(bot) >= 3
	and Item.GetItemCharges(bot, 'item_smoke_of_deceit') == 0
	and bot:GetCourierValue() == 0
	then
		if  DotaTime() < 0
		and not initSmoke
		then
			local hasSmoke = false
			for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
			do
				if  J.IsValidHero(allyHero)
				and J.IsNotSelf(bot, allyHero)
				and J.HasItem(allyHero, 'item_smoke_of_deceit')
				then
					hasSmoke = true
				end
			end

			if not hasSmoke
			then
				bot:ActionImmediate_PurchaseItem('item_smoke_of_deceit')
			end
		else
			if not J.IsInLaningPhase()
			then
				bot:ActionImmediate_PurchaseItem('item_smoke_of_deceit')
			end
		end
	end

	-- Blood Grenade
	if  J.IsInLaningPhase()
	and (J.GetPosition(bot) == 4 or J.GetPosition(bot) == 5)
	and GetItemStockCount('item_blood_grenade') > 0
	and botLevel < 5
	and botGold >= GetItemCost('item_blood_grenade')
	and Item.GetEmptyInventoryAmount(bot) >= 3
	and Item.GetItemCharges(bot, 'item_blood_grenade') == 0
	and bot:GetStashValue() > 0
	then
		bot:ActionImmediate_PurchaseItem('item_blood_grenade')
	end

	--为自己购买魔晶
	if not bot.hasBuyShard
		and GetItemStockCount( "item_aghanims_shard" ) > 0
		and botGold >= 1400
	then
		bot.hasBuyShard = true
		bot:ActionImmediate_PurchaseItem( "item_aghanims_shard" )
	end


	--防止非辅助购买魂泪
	if buyRD == false
		and currentTime < 0
		and bot.theRole ~= 'support'
	then
		buyRD = true
	end


	--死前如果会损失金钱则购买额外TP
	local tpCost = GetItemCost( "item_tpscroll" )
	if botGold >= tpCost
		and bot:IsAlive()
		and botGold < ( tpCost + botWorth / 40 )
		and botHP < 0.08
		and bot:GetHealth() >= 1
		and bot:WasRecentlyDamagedByAnyHero( 3.1 )
		and not Item.HasItem( bot, 'item_travel_boots' )
		and not Item.HasItem( bot, 'item_travel_boots_2' )
		and Item.GetItemCharges( bot, 'item_tpscroll' ) <= 2
	then
		bot:ActionImmediate_PurchaseItem( "item_tpscroll" )
	end
	
	--正常买备用tp
	if currentTime > 4 * 60
		and bot:GetCourierValue() <= 100
		and botGold >= tpCost
		and not Item.HasItem( bot, 'item_travel_boots' )
		and not Item.HasItem( bot, 'item_travel_boots_2' )
		and bot:GetUnitName() ~= "npc_dota_hero_meepo" -- don't let meepo buy tp
		and bot:GetUnitName() ~= "npc_dota_hero_lone_druid_bear"
	then
		local tCharges = Item.GetItemCharges( bot, 'item_tpscroll' )
		if bot:HasModifier("modifier_teleporting") then tCharges = tCharges - 1 end
		if tCharges <= 0 or ( botLevel >= 18 and tCharges <= 1 )
		then
			if botGold >= tpCost * 2 and currentTime > 25 * 60 then
				bot:ActionImmediate_PurchaseItem( "item_tpscroll" )
			end
			bot:ActionImmediate_PurchaseItem( "item_tpscroll" )
		end
	end

	-- --辅助死前如果会损失金钱则购买粉
	if botGold >= GetItemCost( "item_dust" )
		and bot:IsAlive()
		and botLevel > 6
		and bot.theRole == 'support'
		and botGold < ( GetItemCost( "item_dust" )  + botWorth / 40 )
		and botHP < 0.06
		and bot:WasRecentlyDamagedByAnyHero( 3.1 )
		and Item.GetItemCharges( bot, 'item_dust' ) <= 1
		and Utils.CountBackpackEmptySpace(bot) >= 2
	then
		bot:ActionImmediate_PurchaseItem( "item_dust" )
	end

	--交换魂泪的位置避免过早被破坏
	if currentTime > 180
		and currentTime < 1800
		and bot.switchTime < currentTime - 5.6
	then
		local raindrop = bot:FindItemSlot( "item_infused_raindrop" )
		local raindropCharge = Item.GetItemCharges( bot, "item_infused_raindrop" )
		local nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
		if ( raindrop >= 0 and raindrop <= 5 )
			and ( nEnemyHeroes[1] ~= nil
				or botMode == BOT_MODE_ROSHAN
				or bot:WasRecentlyDamagedByAnyHero( 3.1 ) )
			and ( raindropCharge == 1 or raindropCharge >= 7 )
		then
			bot.switchTime = currentTime
			bot:ActionImmediate_SwapItems( raindrop, 6 )
		end
	end

	if ( GetGameMode() ~= 23 and botLevel > 6 and currentTime > bot.fullInvCheck + 1.0
		and (bot:DistanceFromFountain() <= 200 or bot:DistanceFromSecretShop() <= 200 ))
		or ( GetGameMode() == 23 and botLevel > 9 and currentTime > bot.fullInvCheck + 1.0 )
	then
		local emptySlot = Item.GetEmptyInventoryAmount( bot )
		local slotToSell = nil

		local preEmpty = 2
		if botLevel <= 17 then preEmpty = 1 end
		if emptySlot <= preEmpty - 1
		then
			for i = 1, #Item['tEarlyItem']
			do
				local itemName = Item['tEarlyItem'][i]
				local itemSlot = bot:FindItemSlot( itemName )
				if itemSlot >= 0 and itemSlot <= 8
				then
					slotToSell = itemSlot
					break
				end
			end
		end


		if botWorth > 10000
			and bot:GetItemInSlot( 6 ) ~= nil
			and bot:GetItemInSlot( 7 ) ~= nil
		then
			local wand = bot:FindItemSlot( "item_magic_wand" )
			local assitItem = bot:FindItemSlot( "item_infused_raindrop" )
			if assitItem < 0 then assitItem = bot:FindItemSlot( "item_bracer" ) end
			if assitItem < 0 then assitItem = bot:FindItemSlot( "item_null_talisman" ) end
			if assitItem < 0 then assitItem = bot:FindItemSlot( "item_wraith_band" ) end
			if assitItem >= 0
				and wand >= 6
				and wand <= 8
			then
				slotToSell = assitItem
			end
		end

		if slotToSell ~= nil
		then
			bot:ActionImmediate_SellItem( bot:GetItemInSlot( slotToSell ) )
		end

		bot.fullInvCheck = currentTime
	end

	--出售廉价装备, 可能偶然卖掉components
	-- if bot:GetLevel() >= 10 and currentTime > bot.sell_time + 1
	-- and ( bot:DistanceFromFountain() <= 200 or bot:DistanceFromSecretShop() <= 100 ) then
	-- 	for i = 1, 8
	-- 	do
	-- 		local item = bot:GetItemInSlot(i)
	-- 		local itemName = item:GetName()
	-- 		if item ~= nil and GetItemCost(itemName) <= 150
	-- 		and itemName ~= 'item_ward_sentry'
	-- 		and itemName ~= 'item_ward_observer'
	-- 		and itemName ~= 'item_smoke_of_deceit'
	-- 		and itemName ~= 'item_dust' then
	-- 			bot:ActionImmediate_SellItem(item)
	-- 		end
	-- 	end
	-- end

	--出售过渡装备
	local countEmptyBackpack = Utils.CountBackpackEmptySpace(bot)
	if currentTime > bot.sell_time + 0.5
		and countEmptyBackpack <= 1
		and ( bot:DistanceFromFountain() <= 100 or bot:DistanceFromSecretShop() <= 100 )
	then
		bot.sell_time = currentTime

		for i = 2 , #sItemSellList, 2
		do
			local nNewSlot = bot:FindItemSlot( sItemSellList[i - 1] )
			local nOldSlot = bot:FindItemSlot( sItemSellList[i] )
			if nNewSlot >= 0 and nOldSlot >= 0
			and not Utils.HasValue(Item['tEarlyBoots'], sItemSellList[i]) -- dont sell boots too early.
			then
				bot:ActionImmediate_SellItem( bot:GetItemInSlot( nOldSlot ) )
			end
		end

		if (currentTime > 18 * 60 or botWorth > 20000)
			and ( Item.HasItem( bot, "item_travel_boots" ) or Item.HasItem( bot, "item_travel_boots_2" ) )
		then
			for i = 1, #Item['tEarlyBoots']
			do
				local bootsSlot = bot:FindItemSlot( Item['tEarlyBoots'][i] )
				if bootsSlot >= 0
				then
					bot:ActionImmediate_SellItem( bot:GetItemInSlot( bootsSlot ) )
				end
			end
		end
	end

	if Item.HasItem(bot, 'item_mask_of_madness')
	and Item.HasItem(bot, 'item_satanic')
	then
		bot:ActionImmediate_SellItem(bot:GetItemInSlot(bot:FindItemSlot('item_mask_of_madness')))
	end

	if #bot.itemToBuy == 0 then
		ClearBuyList()
		bot:SetNextItemPurchaseValue( 0 )
		return
	end

	if bot.currentItemToBuy == nil
	and #bot.currListItemToBuy == 0
	then
		bot.currentItemToBuy = bot.itemToBuy[#bot.itemToBuy]
		local tempTable = Item.GetBasicItems( { bot.currentItemToBuy } )
		for i = 1, math.ceil( #tempTable / 2 )
		do
			bot.currListItemToBuy[i] = tempTable[#tempTable-i+1]
			bot.currListItemToBuy[#tempTable-i+1] = tempTable[i]
		end
	end
	
	if #bot.currListItemToBuy == 0 and currentTime > bot.lastInvCheck + 1.0
	then
		if Item.IsItemInHero( bot.currentItemToBuy )
			or bot.currentItemToBuy == "item_aghanims_shard"
			or (bot == Utils['LoneDruid'].hero and Utils['LoneDruid'].bear ~= nil and Item.IsItemInTargetHero(bot.currentItemToBuy, Utils['LoneDruid'].bear))
			or bot.countInvCheck > 5 * 60 -- if can't finish the item for a long time
		then
			bot.countInvCheck = 0
			bot.currentItemToBuy = nil
			bot.itemToBuy[#bot.itemToBuy] = nil
		else
			bot.lastInvCheck = currentTime

			-- and can't finish even with lots of gold
			if bot:GetGold() > 7000 or bot:GetGold() > GetItemCost(bot.currentItemToBuy) * 2 then
				bot.countInvCheck = bot.countInvCheck + 1
			end
		end
	elseif #bot.currListItemToBuy > 0
	then
		if bot.currentComponentToBuy == nil
		then
			bot.currentComponentToBuy = bot.currListItemToBuy[#bot.currListItemToBuy]
		else
			if GetGameMode() == 23
			then
				TurboModeGeneralPurchase()
			else
				GeneralPurchase()
			end
		end
	end

end

function ClearBuyList()
	bot.countInvCheck = 0
	bot.currentComponentToBuy = nil
	bot.currListItemToBuy[#bot.currListItemToBuy] = nil
end

function IsThereHealingInStash(unit)
	local amount = 0

	for i = 9, 14
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil
		then
			if string.find(item:GetName(), 'item_flask')
			or string.find(item:GetName(), 'item_tango')
			or string.find(item:GetName(), 'item_bottle')
			then
				amount = amount + 1
			end
		end
	end

	return amount > 0
end

X.ItemPurchaseThink = ItemPurchaseThink

return X