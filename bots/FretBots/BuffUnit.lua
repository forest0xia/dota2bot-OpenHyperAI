require 'bots.FretBots.Debug'
require 'bots.FretBots.Timers'

-- Instantiate ourself
if BuffUnit == nil then
	BuffUnit = {}
end

-- Make someone stronk
function BuffUnit:Hero(unit)
	-- Gotta go fast
	BuffUnit:GiveItem('item_travel_boots_2', unit);
	BuffUnit:GiveItem('item_yasha_and_kaya', unit);
	BuffUnit:GiveItem('item_cyclone', unit);
	BuffUnit:GiveItem('item_force_boots', unit);
	BuffUnit:GiveItem('item_blink', unit);
	-- Make Stronk
	unit:ModifyStrength(1000);
	unit:ModifyAgility(1000);
	unit:ModifyIntellect(1000);
	-- Make Rich
	unit:ModifyGold(30000, true, 0);
	-- Level 30
	for i=1,29 do
		unit:HeroLevelUp(false)
	end
	-- For Lols
	unit:AddAbility('phantom_assassin_stifling_dagger')
end

-- Give someone an item
function BuffUnit:GiveItem(itemName, unit)
	if unit:HasRoomForItem(itemName, true, true) then
		local item = CreateItem(itemName, unit, unit)
		item:SetPurchaseTime(0)
		unit:AddItem(item)
	end
end

function BuffUnit:Fret()
	-- Units = FindUnitsInRadius(
	-- 	2,
	-- 	Vector(0, 0, 0),
	-- 	nil,
	-- 	FIND_UNITS_EVERYWHERE,
	-- 	3,
	-- 	DOTA_UNIT_TARGET_HERO,
	-- 	88,
	-- 	FIND_ANY_ORDER,
	-- 	false);
	-- for i,unit in pairs(Units) do
	-- 	local id = PlayerResource:GetSteamID(unit:GetMainControllingPlayer())
	-- 	local isFret = Debug:IsFret(id)
	-- 	if isFret then
	-- 		BuffUnit:Hero(unit)
	-- 		return
	-- 	end
	-- end
end

