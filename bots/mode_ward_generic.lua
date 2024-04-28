----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------

if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local Site = require( GetScriptDirectory()..'/FunLib/aba_site')
local bot = GetBot();
local X = {}
local AvailableSpots = {};
local nWardCastRange = 500;
local itemWard = nil;
local targetLoc = nil;
local wardCastTime = -90;


bot.lastSwapWardTime = -90;
bot.ward = false;


local vNonStuck = Vector(-2610.000000, 538.000000, 0.000000);


function GetDesire()
	

	if bot:IsChanneling() 
	   or bot:IsIllusion() 
	   or bot:IsInvulnerable() 
	   or not X.IsSuitableToWard()
	   or not bot:IsAlive()
	then
		return BOT_MODE_DESIRE_NONE;
	end
		

	itemWard = Site.GetItemWard(bot)
	
	if itemWard == nil 
	then 
		return BOT_MODE_DESIRE_NONE
	end
	
	-- local wardSlot = X.GetItemWardSolt()
	-- if wardSlot <= -1 
		-- or wardSlot >= 6
	-- then
		-- return BOT_MODE_DESIRE_NONE
	-- end
	
	if itemWard ~= nil  then
		
		AvailableSpots = Site.GetAvailableSpot(bot);
		targetLoc, targetDist = Site.GetClosestSpot(bot, AvailableSpots);
		if targetLoc ~= nil 
			and targetDist < 7200
			and DotaTime() > wardCastTime + 1.0 
		then
			bot.ward = true;
			return math.floor((RemapValClamped(targetDist, 6000, 0, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_VERYHIGH))*20)/20;
		end
	end
	
	return BOT_MODE_DESIRE_NONE;
end

function OnStart()
	if itemWard ~= nil then
		local wardSlot = X.GetItemWardSolt()
		if bot:GetItemSlotType(wardSlot) == ITEM_SLOT_TYPE_BACKPACK 
		then
			local leastCostItem = X.FindLeastItemSlot();
			if leastCostItem ~= -1 then
				bot.lastSwapWardTime = DotaTime();
				bot:ActionImmediate_SwapItems( wardSlot, leastCostItem );
				return
			end
			--local active = bot:GetItemInSlot(leastCostItem);
			--print(active:GetName()..'IsCastable:'..tostring(active:IsFullyCastable()));
		end
	end
end

function OnEnd()
	AvailableSpots = {};
	itemWard = nil;
	
end

function Think()

	
	if bot:IsChanneling() 
		or bot:NumQueuedActions() > 0
		or bot:IsCastingAbility()
		or bot:IsUsingAbility()
		or bot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_RUNE
		or ( GetGameState() ~= GAME_STATE_PRE_GAME and GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS ) 
	then 
		return
	end
	
	if bot.ward then
		if targetDist <= nWardCastRange then
			if  DotaTime() > bot.lastSwapWardTime + 6.1 then
				bot:Action_UseAbilityOnLocation(itemWard, targetLoc);
				wardCastTime = DotaTime();	
				return
			else
				bot:Action_MoveToLocation(targetLoc + RandomVector(200));
				return				
			end
		else
			bot:Action_MoveToLocation(targetLoc + RandomVector(100));
			return			
		end
	end
	
	

end


function X.FindLeastItemSlot()
	local minCost = 100000;
	local idx = -1;
	for i=0,5 
	do
		local hItem = bot:GetItemInSlot(i)
		
		if hItem == nil
		then
			return i
		end
		
		if  hItem ~= nil 
			and hItem:GetName() ~= "item_aegis"  
			and hItem:GetName() ~= "item_gem"  
		then
			local sItemName = hItem:GetName()
			if( GetItemCost(sItemName) < minCost ) 
			then
				minCost = GetItemCost(sItemName);
				idx = i;
			end
		end
	end
	return idx;
end


--check if the condition is suitable for warding
function X.IsSuitableToWard()
	local Enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
	local mode = bot:GetActiveMode();
	if ( ( mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_RUNE 
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		or #Enemies >= 2
		or ( #Enemies >= 1 and X.IsIBecameTheTarget(Enemies) )
		or bot:WasRecentlyDamagedByAnyHero(5.0)
		) 
	then
		return false;
	end
	return true;
end


function X.IsIBecameTheTarget(units)
	for _,u in pairs(units) do
		if u:GetAttackTarget() == bot then
			return true;
		end
	end
	return false;
end


function X.GetItemWardSolt()

	local sWardTypeList = {
		'item_ward_observer',
		'item_ward_sentry',
		'item_ward_dispenser',
	}


	for _,sType in pairs(sWardTypeList)
	do
		local nWardSolt = bot:FindItemSlot(sType)
		if nWardSolt ~= -1
		then
			return nWardSolt
		end
	end

	return -1

end

function X.GetXUnitsTowardsLocation( hUnit, vLocation, nDistance)
    local direction = (vLocation - hUnit:GetLocation()):Normalized()
    return hUnit:GetLocation() + direction * nDistance
end

function X.GetGoOutLocation()

	local nLane = bot:GetAssignedLane()	
	local vLocation = X.GetXUnitsTowardsLocation(GetTower(GetTeam(),TOWER_MID_3),GetTower(GetTeam(),TOWER_MID_1):GetLocation(),300)
	
	if nLane == LANE_BOT
	then
		vLocation = X.GetXUnitsTowardsLocation(GetTower(GetTeam(),TOWER_BOT_3),GetTower(GetTeam(),TOWER_BOT_1):GetLocation(),300)
	elseif nLane == LANE_TOP
	then
		vLocation = X.GetXUnitsTowardsLocation(GetTower(GetTeam(),TOWER_TOP_3),GetTower(GetTeam(),TOWER_TOP_1):GetLocation(),300)
	end
	
	return vLocation

end


-- dota2jmz@163.com QQ:2462331592..
