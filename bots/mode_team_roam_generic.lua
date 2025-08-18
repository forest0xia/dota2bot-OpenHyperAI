local bot = GetBot()
local botName = bot:GetUnitName();
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local EnemyRoles = require( GetScriptDirectory()..'/FunLib/enemy_role_estimation' )
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )

local team = GetTeam()
local X = {}

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Item = require( GetScriptDirectory()..'/FunLib/aba_item')
local Roles = require( GetScriptDirectory()..'/FunLib/aba_role')
local AttackSpecialUnit = dofile( GetScriptDirectory()..'/FunLib/aba_special_units')

local targetUnit = nil;

local towerCreepMode = false;
local towerCreep = nil;
local towerTime =  0;
local towerCreepTime = 0;
local nTpSolt = 15

local beInitDone = false
local IsSupport = false
local IsHeroCore = false
local beFirstStop = false
local bePvNMode = false

local ShouldAttackSpecialUnit = false

local shouldHarass = false
local harassTarget = nil
local lastIdleStateCheck = -1
local isInIdleState = false
local ShouldHelpAlly = false

local PickedItem = nil
local minPickItemCost = 200
local ignorePickupList = { }
local tryPickCount = 0

local ConsiderDroppedTime = -90
local SwappedCheeseTime = -90
local SwappedClarityTime = -90
local SwappedFlaskTime = -90
local SwappedSmokeTime = -90
local SwappedRefresherShardTime = -90
local SwappedMoonshardTime = -90

local lastCheckBotToDropTime = 0

local SearchNearLocAllyForPingDistance = 2200

local TormentorLocation
local IsAvoidingAbilityZone = false
local IsShouldFindTeammates = false
local ShouldFindTeammatesTime = 0
local ShouldFindTeammatesTimeGap = 10
local pingedDefendDesire = 0
local pingedDefendLocation = nil
local nEffctiveAlliesNearPingedDefendLoc = nil
local pingTimeDelta = 5
local goToTargetAlly = nil
local nearbyAllies, nearbyEnemies
local ShouldHelpWhenCoreIsTargeted = false

if team == TEAM_RADIANT
then
	TormentorLocation = Vector(-8075, -1148, 1000)
else
	TormentorLocation = Vector(8132, 1102, 1000)
end

function GetDesire()
	local cacheKey = 'GetTeamRoamDesire'..tostring(bot:GetPlayerID())
	local cachedVar = J.Utils.GetCachedVars(cacheKey, 0.6)
	if cachedVar ~= nil then return cachedVar end
	local res = GetDesireHelper()
	J.Utils.SetCachedVars(cacheKey, res)
	return res
end
function GetDesireHelper()
	if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return BOT_MODE_DESIRE_NONE end
	Utils.SetFrameProcessTime(bot)
	EnemyRoles.UpdateEnemyHeroPositions()

	IsAvoidingAbilityZone = false
	pingedDefendDesire = 0
	local botMode = bot:GetActiveMode()

	bot.laneToPush = J.GetMostPushLaneDesire()
	bot.laneToDefend = J.GetMostDefendLaneDesire()

	if IsShouldFindTeammates then
		if DotaTime() - ShouldFindTeammatesTime > ShouldFindTeammatesTimeGap or not goToTargetAlly then
			IsShouldFindTeammates = false
			goToTargetAlly = nil
		elseif GetUnitToUnitDistance(bot, goToTargetAlly) <= 1600 then
			IsShouldFindTeammates = false
			goToTargetAlly = nil
		end
	end
	-- check if bot is idle
	if DotaTime() - lastIdleStateCheck >= 1 or isInIdleState then
		isInIdleState = J.CheckBotIdleState()
		lastIdleStateCheck = DotaTime()
	end

	if not beInitDone
	then
		beInitDone = true
		bePvNMode = J.Role.IsPvNMode()
		IsHeroCore = J.IsCore(bot)
		IsSupport = not J.IsCore(bot)
	end

	local nDesire = 0

	ItemOpsDesire()

	targetUnit, ShouldHelpWhenCoreIsTargeted = X.ConsiderHelpWhenCoreIsTargeted()
	if ShouldHelpWhenCoreIsTargeted
	then
		bot:SetTarget(targetUnit)
		return BOT_ACTION_DESIRE_ABSOLUTE * 0.98
	end

	local nAliveAllies = J.GetNumOfAliveHeroes(false)
	local nAliveEnemies = J.GetNumOfAliveHeroes(true)
	local teamAveLvl = J.GetAverageLevel( false )
	nearbyAllies = J.GetAlliesNearLoc(bot:GetLocation(), 2200)
	nearbyEnemies = J.GetEnemiesNearLoc(bot:GetLocation(), 2000)

	targetUnit, ShouldHelpAlly = ConsiderHelpAlly()
	if ShouldHelpAlly
	then
		bot:SetTarget(targetUnit)
		-- print("bot to help ally near it: " .. botName)
		return BOT_ACTION_DESIRE_ABSOLUTE * 0.98
	end

	if not bot:IsAlive() or bot:GetCurrentActionType() == BOT_ACTION_TYPE_DELAY then
		return BOT_MODE_DESIRE_NONE
	end

	nDesire = AttackSpecialUnit.GetDesire(bot)
	if nDesire > 0 then
		-- print("bot to attack special unit: " .. botName .. ', desire: ' .. nDesire)
		ShouldAttackSpecialUnit = true
		return RemapValClamped(J.GetHP(bot), 0.1, 0.8, BOT_MODE_DESIRE_NONE, nDesire)
	end

	if J.IsInLaningPhase() then
		if bot:HasModifier('modifier_warlock_upheaval') then
			IsAvoidingAbilityZone = true
			return BOT_ACTION_DESIRE_VERYHIGH + 0.1
		end
	end

	if HasModifierThatNeedToAvoidEffects()
	-- and not J.WeAreStronger(bot, 1500)
	then
		-- local botLoc = bot:GetLocation()
		-- J.AddAvoidanceZone(Vector(botLoc.x, botLoc.y, 100.0), 5)
		IsAvoidingAbilityZone = true
		print("bot to avoid some abilities: " .. botName)
		return BOT_ACTION_DESIRE_VERYHIGH + 0.1
	end

	if not J.IsFarming(bot)
	and not J.IsPushing(bot)
	and not J.IsDefending(bot)
	and not J.IsDoingRoshan(bot)
	and not J.IsDoingTormentor(bot)
	and bot:GetActiveMode() ~= BOT_MODE_RUNE
	and bot:GetActiveMode() ~= BOT_MODE_SECRET_SHOP
	and bot:GetActiveMode() ~= BOT_MODE_OUTPOST
	and bot:GetActiveMode() ~= BOT_MODE_WARD
	and bot:GetActiveMode() ~= BOT_MODE_ATTACK
	and bot:GetActiveMode() ~= BOT_MODE_DEFEND_ALLY
	and bot:GetActiveMode() ~= BOT_MODE_ROAM
	and bot:GetActiveMode() ~= BOT_MODE_ATTACK
	then
		return BOT_ACTION_DESIRE_NONE
	elseif #nearbyAllies >= #nearbyEnemies then
		if IsHeroCore
		then
			local botTarget, targetDesire = X.CarryFindTarget()
			if botTarget ~= nil
			then
				targetUnit = botTarget
				bot:SetTarget(botTarget)
				-- print("carry found a target. bot: " .. botName .. ', targetDesire: ' .. targetDesire)
				return targetDesire
			end
		end

		if IsSupport
		then
			local botTarget, targetDesire = X.SupportFindTarget()
			if botTarget ~= nil
			then
				targetUnit = botTarget
				bot:SetTarget(botTarget)
				-- print("support found a target. bot: " .. botName .. ', targetDesire: ' .. targetDesire)
				return targetDesire
			end
		end

		if bot:IsAlive() and bot:DistanceFromFountain() > 4600
		then
			if towerTime ~= 0 and X.IsValid(towerCreep)
				and DotaTime() < towerTime + towerCreepTime
			then
				print("bot should attack tower creep 1: " .. botName)
				return BOT_MODE_DESIRE_ABSOLUTE * 0.9;
			else
				towerTime = 0;
				towerCreepMode = false;
			end

			towerCreepTime,towerCreep = X.ShouldAttackTowerCreep(bot);
			if towerCreepTime ~= 0 and towerCreep ~= nil
			then
				if towerTime == 0 then 
					towerTime = DotaTime(); 
					towerCreepMode = true;
				end
				bot:SetTarget(towerCreep);
				print("bot should attack tower creep 2: " .. botName)
				return BOT_MODE_DESIRE_ABSOLUTE * 0.9;
			end
		end
	end
	
	return 0.0;
	
end

-- Leave from the area that's affected by some spells like ults of Lich, Jakiro, etc.
function HasModifierThatNeedToAvoidEffects()
	-- local cacheKey = 'HasModifierThatNeedToAvoidEffects'..tostring(bot:GetPlayerID())
	-- local cache = J.Utils.GetCachedVars(cacheKey, 3)
	-- if cache ~= nil then return cache end

	local res = bot:HasModifier('modifier_jakiro_macropyre_burn') -- 可能无视魔免的技能
	or bot:HasModifier('modifier_dark_seer_wall_slow')
	or ( -- 不无视魔免的技能
		(bot:HasModifier('modifier_sandking_sand_storm_slow')
		or bot:HasModifier('modifier_sand_king_epicenter_slow'))
		and (not bot:HasModifier("modifier_black_king_bar_immune") or not bot:HasModifier("modifier_magic_immune") or not bot:HasModifier("modifier_omniknight_repel"))
	)
	-- J.Utils.SetCachedVars(cacheKey, res)
	return res
end

function ConsiderPingedDefendDesire()
	-- 判断是否要提醒回防
	if J.IsInLaningPhase() then return 0 end

	J.Utils['GameStates']['defendPings'] = J.Utils['GameStates']['defendPings'] ~= nil and J.Utils['GameStates']['defendPings'] or { pingedTime = GameTime() }
	local botIsCloseToPing = pingedDefendLocation and GetUnitToLocationDistance(bot, pingedDefendLocation) < 1600
	if bot:WasRecentlyDamagedByAnyHero(3) or botIsCloseToPing then
		return 0
	else
		local timeDiff = GameTime() - J.Utils['GameStates']['defendPings'].pingedTime
		if pingedDefendDesire and timeDiff <= 5 and pingedDefendLocation then
			return pingedDefendDesire
		end
	end

	local team = GetTeam()
	local ancient = GetAncient(team):GetLocation()
	local nEnemyHeroNearAncient = #J.GetLastSeenEnemiesNearLoc(ancient, 1800)
	local nEnemyUnitsAroundLoc = J.GetAroundTargetLocEnemyUnitCount(ancient, 1800)

	local enemeyPushingBase = false
	local nDefendLoc = nil

	local barrack = J.Utils.IsAnyBarrackAttackByEnemyHero()
	if barrack ~= nil then
		nDefendLoc = barrack:GetLocation()
		enemeyPushingBase = true
		print("Barracks are in danger for team " .. team)
	end

	if not enemeyPushingBase then
		for _, t in pairs( J.Utils.HighGroundTowers )
		do
			local tower = GetTower( team, t )
			if tower ~= nil and tower:GetHealth()/tower:GetMaxHealth() < 0.8
			and #J.GetHeroesNearLocation(true, tower:GetLocation(), 1400) >= 1
			then
				nDefendLoc = tower:GetLocation()
				enemeyPushingBase = true
				print("HG towers are in danger for team " .. team)
				pingedDefendDesire = 0.7
			end
		end
	end

	if not enemeyPushingBase and (nEnemyHeroNearAncient >= 1 or nEnemyUnitsAroundLoc >= 1) then
		nDefendLoc = GetAncient(team):GetLocation() -- GetLaneFrontLocation(team, nDefendLane, 100)
		enemeyPushingBase = true
		print("Ancient is in danger for team " .. team)
		pingedDefendDesire = 0.96
	end
	-- if not enemeyPushingBase then
	-- 	local towerWithLeastEnemiesAround = J.Utils.GetNonTier1TowerWithLeastEnemiesAround(1400)
	-- 	if towerWithLeastEnemiesAround then
	-- 		nDefendLoc = towerWithLeastEnemiesAround:GetLocation()
	-- 		if nDefendLoc then
	-- 			enemeyPushingBase = true
	-- 			print("Non-tier-1 towers are in danger for team " .. team)
	-- 			pingedDefendDesire = 0.75
	-- 		end
	-- 	end
	-- end

	if nDefendLoc ~= nil and pingedDefendDesire and enemeyPushingBase then
		local saferLoc = J.AdjustLocationWithOffsetTowardsFountain(nDefendLoc, 850) + RandomVector(50)

		J.Utils['GameStates']['defendPings'].pingedTime = GameTime()
		bot:ActionImmediate_Chat(Localization.Get('say_come_def'), false)
		bot:ActionImmediate_Ping(saferLoc.x, saferLoc.y, false)

		pingedDefendLocation = saferLoc
	end
	return pingedDefendDesire
end

function ItemOpsDesire()
	if DotaTime() >= ConsiderDroppedTime + 2.0 then
		local nDroppedItem = GetDroppedItemList()
		for _, droppedItem in pairs(nDroppedItem)
		do
			if droppedItem ~= nil then
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

					--尝试捡起物品
					local nDropOwner = droppedItem.owner
					if nDropOwner ~= nil and nDropOwner == bot and not string.find(itemName, 'token') then PickedItem = droppedItem end

					if PickedItem ~= nil and GetItemCost(itemName) > minPickItemCost then
						return RemapValClamped(J.Utils.GetLocationToLocationDistance(droppedItem.location, bot:GetLocation()),
							5000, 0, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_VERYHIGH)
					end
				end
				
			end
		end
		ConsiderDroppedTime = DotaTime()
	end

	TrySellOrDropItem()
	SwapSmokeSupport()
	TrySwapInvItemForCheese()
	TrySwapInvItemForRefresherShard()
	TrySwapInvItemForClarity()
	TrySwapInvItemForFlask()
	TrySwapInvItemForSmoke()
	TrySwapInvItemForMoonshard()
end

function OnStart() end

function OnEnd()
	towerTime = 0
	towerCreepMode = false
	harassTarget = nil
	PickedItem = nil
	pingedDefendDesire = 0
	nEffctiveAlliesNearPingedDefendLoc = nil
end

function Think()

	if J.CanNotUseAction(bot) then return end
	if J.Utils.IsBotThinkingMeaningfulAction(bot) then return end

	ItemOpsThink()

	if IsAvoidingAbilityZone then
		bot:Action_MoveToLocation(Utils.GetOffsetLocationTowardsTargetLocation(bot:GetLocation(), J.GetTeamFountain(), 600) + RandomVector(200))
		return
	end

	if IsShouldFindTeammates then
		if J.IsValidHero(goToTargetAlly) then
			bot:Action_MoveToLocation(goToTargetAlly:GetLocation() + RandomVector(500))
		else
			IsShouldFindTeammates = false
		end
		return
	end

	if shouldHarass
	and J.Utils.IsValidUnit(harassTarget)
	then
		if J.IsInRange(bot, harassTarget, bot:GetAttackRange()) then
			bot:Action_AttackUnit(harassTarget, false)
		else
			bot:Action_MoveToLocation(harassTarget:GetLocation())
		end
		return
	end

	if ShouldAttackSpecialUnit
	then
		AttackSpecialUnit.Think()
	end

	-- if pingedDefendDesire > 0 and pingedDefendLocation then
	-- 	PingedDefendThink()
	-- 	return
	-- end

	if towerCreepMode
	then
		bot:Action_AttackUnit(towerCreep, false)
		return
	end

	if isInIdleState then
		isInIdleState = J.CheckBotIdleState()
	end

	if ShouldHelpAlly
	and J.Utils.IsValidUnit(targetUnit) then
		bot:Action_AttackUnit(targetUnit, false)
		return
	end

	if (IsHeroCore or IsSupport)
	and J.Utils.IsValidUnit(targetUnit)
	then
		bot:Action_AttackUnit(targetUnit, false)
		return
	end
end

function PingedDefendThink()
	local attackRange = bot:GetAttackRange()
	local enemySearchRange = 1400
	local nSearchRange = attackRange < 600 and 600 or math.min(attackRange + 100, enemySearchRange)

	local tps = bot:GetItemInSlot(nTpSolt)
	local saferLoc = pingedDefendLocation
	local bestTpLoc = J.GetNearbyLocationToTp(saferLoc)
	local distance = GetUnitToLocationDistance(bot, pingedDefendLocation)

	if distance > 3500 then
		if tps ~= nil and tps:IsFullyCastable() then
			bot:Action_UseAbilityOnLocation(tps, bestTpLoc + RandomVector(30))
			return
		else
			bot:Action_MoveToLocation(saferLoc + RandomVector(30));
			return
		end
	elseif distance > 2000 and distance <= 3500 then
		bot:Action_AttackMove(saferLoc + RandomVector(30));
	elseif distance <= 2000 and bot:GetTarget() == nil then
		local hNearbyEnemyHeroList = J.GetHeroesNearLocation( true, pingedDefendLocation, 1300 )
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if J.IsValidHero(npcEnemy)
			then
				bot:SetTarget( npcEnemy )
                bot:Action_AttackUnit( npcEnemy, false )
				return
			end
		end
	end

	if distance < enemySearchRange then
		local nInRangeEnemy = bot:GetNearbyHeroes(nSearchRange, true, BOT_MODE_NONE)
		if J.IsValidHero(nInRangeEnemy[1])
		then
			bot:SetTarget( nInRangeEnemy[1] )
            bot:Action_AttackUnit( nInRangeEnemy[1], false )
			return
		end

		local nEnemyLaneCreeps = bot:GetNearbyCreeps(900, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps > 0
		then
			local targetCreep = nil
			local attackDMG = 0
			for _, creep in pairs(nEnemyLaneCreeps)
			do
				if J.IsValid(creep)
				and J.CanBeAttacked(creep)
				and creep:GetAttackDamage() > attackDMG
				then
					attackDMG = creep:GetAttackDamage()
					targetCreep = creep
				end

				if targetCreep ~= nil
				then
					bot:Action_AttackUnit(creep, true)
					return
				end
			end
		end
	end
	bot:Action_AttackMove(saferLoc + RandomVector(75))
end

function ConsiderHelpAlly()
	if J.GetHP(bot) < 0.3 then return nil, false end

	local nRadius = 3500
	local nModeDesire = bot:GetActiveModeDesire()
	local nClosestAlly = J.GetClosestAlly(bot, nRadius)

	if nClosestAlly ~= nil
	and J.GetHP(bot) >= J.GetHP(nClosestAlly)
	and (not J.IsCore(bot) or (J.IsCore(bot) and (not J.IsInLaningPhase() or J.IsInRange(bot, nClosestAlly, 1600))))
	and not J.IsGoingOnSomeone(bot)
	and not (J.IsRetreating(bot) and nModeDesire > 0.8)
	then
		local nInRangeAlly = J.GetAlliesNearLoc(nClosestAlly:GetLocation(), 1200)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nClosestAlly:GetLocation(), 1600)

		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidHero(enemyHero)
			and GetUnitToUnitDistance(enemyHero, nClosestAlly) <= 1600
			and (#nInRangeAlly + 1 >= #nInRangeEnemy)
			then
				if (enemyHero:GetAttackTarget() == nClosestAlly or J.IsChasingTarget(enemyHero, nClosestAlly))
				or nClosestAlly:WasRecentlyDamagedByHero(enemyHero, 2.5)
				then
					return enemyHero, true
				end
			end
		end
	end

	return nil, false
end

function ItemOpsThink()
	if PickedItem ~= nil then
		if J.Item.GetEmptyInventoryAmount(bot) > 0 and not PickedItem.item:IsNull() then
			local itemName = PickedItem.item:GetName()
			if tryPickCount >= 3 and not Utils.SetContains(itemName) then
				tryPickCount = 0
				Utils.AddToSet(ignorePickupList, PickedItem.item)
			end

			-- 先尝试捡起
			if not Utils.SetContains(itemName) and not Utils.HasValue(Item['tEarlyConsumableItem'], itemName)
			then
				if itemName == 'item_aegis' or itemName == 'item_cheese' then
					if J.GetPosition(bot) <= 3 and not J.HasItem(bot, 'item_aegis') then
						GoPickUpItem(PickedItem)
					end
				else
					GoPickUpItem(PickedItem)
				end
			end
		else
			-- swap item to backpack, or drop it to pick up new item.
			
			-- local aSlot, aCost = Item.GetBodyInvLessValItemSlot( bot )

		end
	end
end

function GoPickUpItem(goPickItem)
	local distance = GetUnitToLocationDistance(bot, goPickItem.location)
	if distance > 200 and distance < 2000
	then
		bot:Action_MoveToLocation(goPickItem.location)
	elseif distance <= 100 then
		tryPickCount = tryPickCount + 1
		bot:Action_PickUpItem(goPickItem.item)
		return
	end
end

function X.SupportFindTarget()
	if X.CanNotUseAttack(bot) or DotaTime() < 0 then return nil,0 end

	local IsModeSuitHit = X.IsModeSuitToHitCreep(bot);
	local nAttackRange = bot:GetAttackRange() + 50;
	if nAttackRange > 1200 then nAttackRange = 1200 end

	local nTarget = J.GetProperTarget(bot);
	local botMode = bot:GetActiveMode();
	local botLV   = bot:GetLevel();
	local botAD   = bot:GetAttackDamage();
	local botBAD  = X.GetAttackDamageToCreep(bot) - 1;

	if X.CanBeAttacked(nTarget) and nTarget == targetUnit
	   and GetUnitToUnitDistance(bot,nTarget) <= 1600
	then
	    if nTarget:GetTeam() == bot:GetTeam() 
		then
			if nTarget:GetHealth() > X.GetLastHitHealth(bot,nTarget)
			then
				return nTarget,BOT_MODE_DESIRE_VERYHIGH * 1.08;
			end

			return nTarget,BOT_MODE_DESIRE_VERYHIGH * 1.04;
		end

		if nTarget:IsCourier()
			and GetUnitToUnitDistance(bot,nTarget) <= nAttackRange + 300
			and J.GetHP(bot) > 0.3 and not J.IsRetreating(bot)
		then
			return nTarget,BOT_MODE_DESIRE_ABSOLUTE *1.5;
		end

		if nTarget:IsHero()
		   and (bot:GetCurrentMovementSpeed() < 300 or botLV >= 25)
		then
		    return nTarget,BOT_MODE_DESIRE_ABSOLUTE *1.2;
		end

		if J.IsPushing( bot ) and not nTarget:IsHero() then return nil,0 end
		if not nTarget:IsHero()
		   and GetUnitToUnitDistance(bot,nTarget) < nAttackRange +50
		then
			return nTarget,BOT_MODE_DESIRE_ABSOLUTE *0.98;
		end

		if not nTarget:IsHero()
		   and GetUnitToUnitDistance(bot,nTarget) > nAttackRange +300
		then
			return nTarget,BOT_MODE_DESIRE_ABSOLUTE *0.7;
		end

		return nTarget,BOT_MODE_DESIRE_ABSOLUTE *0.96;
	end

	local enemyCourier = X.GetEnemyCourier(bot, nAttackRange + botLV * 2 + 20 );
	if enemyCourier ~= nil 
		and not enemyCourier:IsAttackImmune()
		and not enemyCourier:IsInvulnerable()
		and J.GetHP(bot) > 0.3 and not J.IsRetreating(bot)
	then
		return enemyCourier,BOT_MODE_DESIRE_ABSOLUTE * 1.5;
	end

	if botMode == BOT_MODE_RETREAT
	   and botLV > 9
	   and not X.CanBeInVisible(bot)
	   and X.ShouldNotRetreat(bot)
	then
		nTarget = J.GetAttackableWeakestUnit( bot,  nAttackRange + 50, true, true ) --X.WeakestUnitCanBeAttacked(true, true, nAttackRange + 50, bot)
		if nTarget ~= nil
		then
		    return nTarget,BOT_MODE_DESIRE_ABSOLUTE * 1.09;
		end
	end

	local attackDamage = botBAD - 1;
	if IsModeSuitHit
		and not X.HasHumanAlly( bot )
		and ( J.GetHP(bot) > 0.5 or not bot:WasRecentlyDamagedByAnyHero(2.0) )
	then
		local nBonusRange = 400;
		if botLV > 12 then nBonusRange = 300; end
		if botLV > 20 then nBonusRange = 200; end

		nTarget = X.GetNearbyLastHitCreep(false, true, attackDamage, nAttackRange + nBonusRange, bot); -----**************
		if nTarget ~= nil
		then
			return nTarget,BOT_MODE_DESIRE_ABSOLUTE; 
		end

		local nEnemyTowers = bot:GetNearbyTowers(nAttackRange + 150,true);
		if X.CanBeAttacked(nEnemyTowers[1])
		   and J.IsWithoutTarget(bot)
		   and X.IsLastHitCreep(nEnemyTowers[1],botAD * 2)
		then
			return nEnemyTowers[1],BOT_MODE_DESIRE_ABSOLUTE; 
		end

		local nNeutrals = bot:GetNearbyNeutralCreeps(nAttackRange + 150);
		local nAllies = J.GetNearbyHeroes(bot,1300,false,BOT_MODE_NONE); -----***************
		if J.IsWithoutTarget(bot)
			and botMode ~= BOT_MODE_FARM 
			and #nNeutrals > 0
			and #nAllies <= 1 ----******************
		then
			for i = 1,#nNeutrals
			do
				if X.CanBeAttacked(nNeutrals[i])
					and not X.IsAllysTarget(nNeutrals[i])
					and not J.IsTormentor(nNeutrals[i])
					and not J.IsRoshan(nNeutrals[i])
					and X.IsLastHitCreep(nNeutrals[i],attackDamage)
				then
					return nNeutrals[i],BOT_MODE_DESIRE_ABSOLUTE; 
				end
			end
		end
	end

	local denyDamage = botAD + 3
	local nNearbyEnemyHeroes = J.GetNearbyHeroes(bot,750,true,BOT_MODE_NONE); -----------*************
	if IsModeSuitHit
		and bot:GetLevel() <= 8
		and bot:GetNetWorth() < 13998   -----------*************
		and ( J.GetHP(bot) > 0.38 or not bot:WasRecentlyDamagedByAnyHero(3.0))
		and (nNearbyEnemyHeroes[1] == nil or nNearbyEnemyHeroes[1]:GetLevel() < 10) -----------*************
		and bot:DistanceFromFountain() > 3800
		and J.GetDistanceFromEnemyFountain(bot) > 5000
	then
		local nWillAttackCreeps = X.GetExceptRangeLastHitCreep(true, attackDamage *1.1, 0, nAttackRange +60, bot);
		if nWillAttackCreeps == nil
			or denyDamage > 130
			or not X.IsOthersTarget(nWillAttackCreeps)
			or not X.IsMostAttackDamage(bot)
		then
			nTarget = X.GetNearbyLastHitCreep(false, false, denyDamage, nAttackRange +300, bot);
			if nTarget ~= nil then
				return nTarget,BOT_MODE_DESIRE_ABSOLUTE *0.97;
			end
		end

		local nAllyTowers = bot:GetNearbyTowers(nAttackRange + 300,false);
		if J.IsWithoutTarget(bot)
		   and #nAllyTowers > 0
		then
			if X.CanBeAttacked(nAllyTowers[1])
			   and J.GetHP(nAllyTowers[1]) < 0.08
			   and X.IsLastHitCreep(nAllyTowers[1],denyDamage * 3)
			then
				return nAllyTowers[1],BOT_MODE_DESIRE_ABSOLUTE;
			end
		end
	end

	if J.IsPushing( bot ) then return nil,0 end
	if IsModeSuitHit
		and bot:GetLevel() <= 7
		and X.CanAttackTogether(bot)
		and (nNearbyEnemyHeroes[1] == nil or nNearbyEnemyHeroes[1]:GetLevel() < 12)
		and bot:DistanceFromFountain() > 3800
		and J.GetDistanceFromEnemyFountain(bot) > 5000
	 then
	     local nAllies = J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE);
		 local nNum = X.GetCanTogetherCount(nAllies)
		 local centerAlly = X.GetMostDamageUnit(nAllies);
		 if centerAlly ~= nil and nNum >= 2
		 then
			 
			local nTowerCreeps = centerAlly:GetNearbyLaneCreeps(1600,true);
			local nAllyTower = bot:GetNearbyTowers(1400,false);
			if(nAllyTower[1] ~= nil and nAllyTower[1]:GetAttackTarget() ~= nil)
			then
				local nTowerDamage = nAllyTower[1]:GetAttackDamage();
				local nTowerTarget = nAllyTower[1]:GetAttackTarget();
				for _,creep in pairs(nTowerCreeps)
				do
					if nTowerTarget == creep
						and X.CanBeAttacked(creep)
						and creep:GetHealth() < X.GetLastHitHealth(nAllyTower[1],creep)
						and creep:GetHealth() > X.GetLastHitHealth(bot,creep)
					then
						local togetherDamage = 0;
						local togetherCount = 0;
						for _,ally in pairs(nAllies)
						do
							if X.CanAttackTogether(ally)
								and GetUnitToUnitDistance(ally,creep) <= ally:GetAttackRange() +50
							then
								togetherDamage = ally:GetAttackDamage() + togetherDamage;
								togetherCount =  togetherCount +1;
							end
						end
						if X.IsLastHitCreep(creep,togetherDamage)
						   and togetherCount >= 2
						   and GetUnitToUnitDistance(bot,creep) <= bot:GetAttackRange() +50
						then
							return creep,BOT_MODE_DESIRE_ABSOLUTE;
						end
					end
				end
		    end
			
			local nWillAttackCreeps = X.GetExceptRangeLastHitCreep(true, centerAlly:GetAttackDamage() * 1.2, 0, 800, centerAlly);
			if nWillAttackCreeps == nil
				or not X.IsOthersTarget(nWillAttackCreeps)
			then
				local nDenyCreeps = centerAlly:GetNearbyCreeps(1600,false);
				for _,creep in pairs(nDenyCreeps)
				do
					if X.CanBeAttacked(creep)
					and creep:GetHealth()/creep:GetMaxHealth() < 0.5
					and not X.IsLastHitCreep(creep,denyDamage)
					and not J.IsTormentor(creep)
					and not J.IsRoshan(creep)
					then
						local togetherDamage = 0;
						local togetherCount = 0;
						for _,ally in pairs(nAllies)
						do
							if X.CanAttackTogether(ally)
								and GetUnitToUnitDistance(ally,creep) <= ally:GetAttackRange() + 150 
							then
								togetherDamage = ally:GetAttackDamage() + togetherDamage;
								togetherCount = togetherCount +1;
							end
						end
						if X.IsLastHitCreep(creep,togetherDamage)
						   and togetherCount >= 2
						   and GetUnitToUnitDistance(bot,creep) <= bot:GetAttackRange() + 150
						then
							return creep,BOT_MODE_DESIRE_HIGH;
						end
					end
				end
			end
		end

	end

	local nNearbyEnemyHeroes = J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE);
	local nEnemyLaneCreep = bot:GetNearbyLaneCreeps(1200, true);
	local nWillAttackCreeps = X.GetExceptRangeLastHitCreep(true, attackDamage *1.2, 0, nAttackRange + 120, bot);
	if IsModeSuitHit
		and botLV >= 6  -----------*************
		and nNearbyEnemyHeroes[1] == nil
		and ( attackDamage > 108 or bot:GetSecondsPerAttack() < 0.7 ) -----------*************
		and ( nWillAttackCreeps == nil or not X.IsMostAttackDamage(bot) or not X.IsOthersTarget(nWillAttackCreeps))
	then

		local nEnemyTowers = bot:GetNearbyTowers(900,true);

		local nTwoHitCreeps = bot:GetNearbyLaneCreeps(nAttackRange +150, true);
		for _,creep in pairs(nTwoHitCreeps)
		do
			if X.CanBeAttacked(creep)
			   and not X.IsLastHitCreep(creep,attackDamage *1.2)
			   and not X.IsOthersTarget(creep)
			then
				local nAllyLaneCreep = bot:GetNearbyLaneCreeps(600, false);
				if X.IsLastHitCreep(creep,attackDamage *2)
				then
					return creep,BOT_MODE_DESIRE_ABSOLUTE;
				elseif X.IsLastHitCreep(creep,attackDamage *3 - 5) 
						and #nAllyLaneCreep == 0 and botLV >= 3						
					then
						return creep,BOT_MODE_DESIRE_ABSOLUTE *0.9;
				end
			end
		end

		if bot:DistanceFromFountain() > 3800 
			and not bePvNMode and bot:GetLevel() <= 6
			and J.GetDistanceFromEnemyFountain(bot) > 5000
			and nEnemyTowers[1] == nil
			and bot:GetNetWorth() < 19800
			and denyDamage > 110
		then
			local nTwoHitDenyCreeps = bot:GetNearbyCreeps(nAttackRange +120, false);
			for _,creep in pairs(nTwoHitDenyCreeps)
			do
				if X.CanBeAttacked(creep)
				and creep:GetHealth()/creep:GetMaxHealth() < 0.5
				and X.IsLastHitCreep(creep,denyDamage *2)
				and ( not X.IsLastHitCreep(creep,denyDamage *1.2) or #nEnemyLaneCreep == 0 )
				and not X.IsOthersTarget(creep)
				and not J.IsTormentor(creep)
				and not J.IsRoshan(creep)
				then
					return creep,BOT_MODE_DESIRE_ABSOLUTE;
				end
			end
		end
	end

    return nil,0;
end


function X.CarryFindTarget()
	if X.CanNotUseAttack(bot) or DotaTime() < 0 then return nil,0 end

	local IsModeSuitHit = X.IsModeSuitToHitCreep(bot);
	local nAttackRange = bot:GetAttackRange() + 50;
	if nAttackRange > 1170 then nAttackRange = 1170 end
	if botName == "npc_dota_hero_templar_assassin" then nAttackRange = nAttackRange + 100 end;

	local nTarget = J.GetProperTarget(bot);
	local botMode = bot:GetActiveMode();
	local botLV   = bot:GetLevel();
	local botAD   = bot:GetAttackDamage() - 0.8;
	local botBAD  = X.GetAttackDamageToCreep(bot) - 1.2;

	if X.CanBeAttacked(nTarget) and nTarget == targetUnit
		and GetUnitToUnitDistance(bot,nTarget) <= 1600
	then
	    if nTarget:GetTeam() == bot:GetTeam() 
		then
			if nTarget:GetHealth() > X.GetLastHitHealth(bot,nTarget)
			then
				return nTarget,BOT_MODE_DESIRE_VERYHIGH * 1.08;
			end

			return nTarget,BOT_MODE_DESIRE_VERYHIGH * 1.04;
		end

		if nTarget:IsCourier()
			and GetUnitToUnitDistance(bot,nTarget) <= nAttackRange + 300
			and J.GetHP(bot) > 0.3 and not J.IsRetreating(bot)
		then
			return nTarget,BOT_MODE_DESIRE_ABSOLUTE *1.5;
		end

		if nTarget:IsHero()
		   and (bot:GetCurrentMovementSpeed() < 300 or botLV >= 25)
		then
			if botName == "npc_dota_hero_antimage"
			then
				local bAbility = bot:GetAbilityByName("antimage_blink");
				if bAbility ~= nil and bAbility:IsFullyCastable()
				then
					return nil,BOT_MODE_DESIRE_NONE;
				end
			end
		    return nTarget,BOT_MODE_DESIRE_ABSOLUTE *1.2;
		end

		if J.IsPushing( bot ) and not nTarget:IsHero() then return nil,0 end

		if not nTarget:IsHero()
		   and GetUnitToUnitDistance(bot,nTarget) < nAttackRange +50
		then
			return nTarget,BOT_MODE_DESIRE_ABSOLUTE *0.98;
		end

		if not nTarget:IsHero()
		   and GetUnitToUnitDistance(bot,nTarget) > nAttackRange +300
		then
			return nTarget,BOT_MODE_DESIRE_ABSOLUTE *0.7;
		end

		return nTarget,BOT_MODE_DESIRE_ABSOLUTE *0.96;
	end

	if bot:HasModifier('modifier_phantom_lancer_phantom_edge_boost')
	then
		return nil,0
	end

	local enemyCourier = X.GetEnemyCourier(bot, nAttackRange + botLV * 2 + 30);
	if enemyCourier ~= nil
		and not enemyCourier:IsAttackImmune()
		and not enemyCourier:IsInvulnerable()
		and J.GetHP(bot) > 0.3 and not J.IsRetreating(bot)
	then
		return enemyCourier,BOT_MODE_DESIRE_ABSOLUTE * 1.5;
	end

	if botMode == BOT_MODE_RETREAT
	   and botName ~= "npc_dota_hero_bristleback"
	   and botLV > 9
	   and not X.CanBeInVisible(bot)
	   and X.ShouldNotRetreat(bot)
	then
	    nTarget = J.GetAttackableWeakestUnit( bot,  nAttackRange + 50, true, true ) --X.WeakestUnitCanBeAttacked(true, true, nAttackRange + 50, bot)
		if nTarget ~= nil
		then
		    return nTarget,BOT_MODE_DESIRE_ABSOLUTE * 1.09;
		end
	end

	local cItem = J.IsItemAvailable("item_echo_sabre")
    if cItem ~= nil and (cItem:IsFullyCastable() or cItem:GetCooldownTimeRemaining() < bot:GetAttackPoint() +0.8)
		and IsModeSuitHit
		and (J.GetHP(bot) > 0.35 or not bot:WasRecentlyDamagedByAnyHero(1.0))
	then

		local echoDamage = botBAD *2;

		if (cItem:IsFullyCastable() or cItem:GetCooldownTimeRemaining() <  bot:GetAttackPoint())
		then
			nTarget = X.GetNearbyLastHitCreep(true, true, echoDamage, 350, bot);
			if nTarget ~= nil then return nTarget,BOT_MODE_DESIRE_ABSOLUTE *0.98; end
		end

		local nEnemyTowers = bot:GetNearbyTowers(1000,true);	
		if (cItem:IsFullyCastable() or cItem:GetCooldownTimeRemaining() <  bot:GetAttackPoint() +0.8)
			and #nEnemyTowers == 0
		then
			for i=400, 580, 60 do
				nTarget = X.GetExceptRangeLastHitCreep(true, echoDamage, 350, i, bot);
				if nTarget ~= nil
				   then return nTarget,BOT_MODE_DESIRE_HIGH; end
			end
		end
	end

	local attackDamage = botBAD;
	if IsModeSuitHit
		and not X.HasHumanAlly( bot )
		and ( J.GetHP(bot) > 0.5 or not bot:WasRecentlyDamagedByAnyHero(2.0))
	then
		local nBonusRange = 430;
		if botLV > 12 then nBonusRange = 380; end
		if botLV > 20 then nBonusRange = 330; end

		nTarget = X.GetNearbyLastHitCreep(true, true, attackDamage, nAttackRange + nBonusRange, bot);
		if nTarget ~= nil
		then
			return nTarget,BOT_MODE_DESIRE_ABSOLUTE;
		end

		--补两刀塔
		local nEnemyTowers = bot:GetNearbyTowers(nAttackRange + 150,true);
		if X.CanBeAttacked(nEnemyTowers[1])
		   and J.IsWithoutTarget(bot)
		   and X.IsLastHitCreep(nEnemyTowers[1], botAD * 2)
		then
			return nEnemyTowers[1],BOT_MODE_DESIRE_ABSOLUTE;
		end

		--补一刀野
		local nNeutrals = bot:GetNearbyNeutralCreeps(nAttackRange + 150);
		if J.IsWithoutTarget(bot)
			and botMode ~= BOT_MODE_FARM 
			and #nNeutrals > 0
		then
			for i = 1,#nNeutrals
			do
				if X.CanBeAttacked(nNeutrals[i])
					and not X.IsAllysTarget(nNeutrals[i])
					and X.IsLastHitCreep(nNeutrals[i],attackDamage)
				then
					return nNeutrals[i],BOT_MODE_DESIRE_ABSOLUTE;
				end
			end
		end
	end

	local denyDamage = botAD + 3
	local nNearbyEnemyHeroes = J.GetNearbyHeroes(bot,650,true,BOT_MODE_NONE);
	if IsModeSuitHit 
		and ( J.GetHP(bot) > 0.38 or not bot:WasRecentlyDamagedByAnyHero(3.0))
		and (nNearbyEnemyHeroes[1] == nil or nNearbyEnemyHeroes[1]:GetLevel() < 12)
		and bot:DistanceFromFountain() > 3800
		and J.GetDistanceFromEnemyFountain(bot) > 5000
	then
	
		if bot:GetLevel() <= 8
		then
			local nWillAttackCreeps = X.GetExceptRangeLastHitCreep(true, attackDamage *1, 0, nAttackRange +60, bot);
			if nWillAttackCreeps == nil 
				or denyDamage > 130
				or not X.IsOthersTarget(nWillAttackCreeps)
				or not X.IsMostAttackDamage(bot)
			then
				nTarget = X.GetNearbyLastHitCreep(false, false, denyDamage, nAttackRange +300, bot); 
				if nTarget ~= nil then 	
					return nTarget,BOT_MODE_DESIRE_ABSOLUTE *0.97; 
				end		
			end
		end
		

		local nAllyTowers = bot:GetNearbyTowers(nAttackRange + 300, false);
		if J.IsWithoutTarget(bot)
		   and #nAllyTowers > 0
		then
			if X.CanBeAttacked(nAllyTowers[1])
			   and J.GetHP(nAllyTowers[1]) < 0.05
			   and X.IsLastHitCreep(nAllyTowers[1],denyDamage * 3)
			then 
				return nAllyTowers[1],BOT_MODE_DESIRE_ABSOLUTE; 
			end	
		end
	end
		
	if J.IsPushing( bot ) then return nil,0 end
	if IsModeSuitHit 
		and bot:GetLevel() <= 8
		and X.CanAttackTogether(bot)
		and (nNearbyEnemyHeroes[1] == nil or nNearbyEnemyHeroes[1]:GetLevel() < 12)
		and bot:DistanceFromFountain() > 3800
		and J.GetDistanceFromEnemyFountain(bot) > 5000
	 then
	     local nAllies = J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE);
		 local nNum = X.GetCanTogetherCount(nAllies)
		 local centerAlly = X.GetMostDamageUnit(nAllies);
		 if centerAlly ~= nil and nNum >= 2
		 then
			 
			local nTowerCreeps = centerAlly:GetNearbyLaneCreeps(1600,true);
			local nAllyTower = bot:GetNearbyTowers(1400,false);
			if(nAllyTower[1] ~= nil and nAllyTower[1]:GetAttackTarget() ~= nil)
			then
				local nTowerDamage = nAllyTower[1]:GetAttackDamage();
				local nTowerTarget = nAllyTower[1]:GetAttackTarget();
				for _,creep in pairs(nTowerCreeps)
				do
					if nTowerTarget == creep
						and X.CanBeAttacked(creep)
						and creep:GetHealth() < X.GetLastHitHealth(nAllyTower[1],creep)
						and creep:GetHealth() > X.GetLastHitHealth(bot,creep)
					then
						local togetherDamage = 0;
						local togetherCount = 0;
						for _,ally in pairs(nAllies)
						do
							if X.CanAttackTogether(ally)
								and GetUnitToUnitDistance(ally,creep) <= ally:GetAttackRange() +50
							then
								togetherDamage = ally:GetAttackDamage() + togetherDamage;
								togetherCount =  togetherCount +1;
							end
						end
						if X.IsLastHitCreep(creep,togetherDamage)
						   and togetherCount >= 2
						   and GetUnitToUnitDistance(bot,creep) <= bot:GetAttackRange() +50
						then
							return creep,BOT_MODE_DESIRE_ABSOLUTE;
						end
					end
				end
		    end
			
			local nWillAttackCreeps = X.GetExceptRangeLastHitCreep(true, centerAlly:GetAttackDamage() *1, 0, 800, centerAlly);
			if nWillAttackCreeps == nil 
				or not X.IsOthersTarget(nWillAttackCreeps)
			then				
				local nDenyCreeps = centerAlly:GetNearbyCreeps(1600,false);
				for _,creep in pairs(nDenyCreeps)
				do
					if X.CanBeAttacked(creep)
					and creep:GetHealth()/creep:GetMaxHealth() < 0.5
					and not X.IsLastHitCreep(creep,denyDamage)
					and not J.IsTormentor(creep)
					and not J.IsRoshan(creep)
					then
						local togetherDamage = 0;
						local togetherCount = 0;
						for _,ally in pairs(nAllies)
						do
							if X.CanAttackTogether(ally)
								and GetUnitToUnitDistance(ally,creep) <= ally:GetAttackRange() + 150 
							then
								togetherDamage = ally:GetAttackDamage() + togetherDamage;
								togetherCount = togetherCount +1;
							end
						end
						if X.IsLastHitCreep(creep,togetherDamage)
						   and togetherCount >= 2
						   and GetUnitToUnitDistance(bot,creep) <= bot:GetAttackRange() + 150
						then
							return creep,BOT_MODE_DESIRE_HIGH;
						end
					end
				end
			end
		end
		
	end
	
	
	local nNearbyEnemyHeroes = J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE);
	local nEnemyLaneCreep = bot:GetNearbyLaneCreeps(1200, true);
	local nWillAttackCreeps = X.GetExceptRangeLastHitCreep(true, attackDamage *1.2, 0, nAttackRange + 120, bot);
	if IsModeSuitHit
		and botLV >= 8
		and nNearbyEnemyHeroes[1] == nil
		and ( attackDamage > 118 or bot:GetSecondsPerAttack() < 0.7 )
		and ( nWillAttackCreeps == nil or not X.IsMostAttackDamage(bot) or not X.IsOthersTarget(nWillAttackCreeps))
	then
		
		local nEnemyTowers = bot:GetNearbyTowers(900,true);
		if botName ~= "npc_dota_hero_templar_assassin"
		then
		
			local nTwoHitCreeps = bot:GetNearbyLaneCreeps(nAttackRange +150, true);
			for _,creep in pairs(nTwoHitCreeps)
			do
				if X.CanBeAttacked(creep)
				   and not X.IsLastHitCreep(creep,attackDamage *1.2)
				   and not X.IsOthersTarget(creep)
				then
					local nAllyLaneCreep = bot:GetNearbyLaneCreeps(600, false);
					if X.IsLastHitCreep(creep,attackDamage *2)
					then
						return creep,BOT_MODE_DESIRE_ABSOLUTE;
					elseif X.IsLastHitCreep(creep,attackDamage *3 - 5) 
							and #nAllyLaneCreep == 0 and botLV >= 3						
						then
							return creep,BOT_MODE_DESIRE_ABSOLUTE *0.9;
					end
				end
			end
			
		end
		
		if bot:DistanceFromFountain() > 3800 
			and not bePvNMode and bot:GetLevel() <= 6
			and J.GetDistanceFromEnemyFountain(bot) > 5000
			and nEnemyTowers[1] == nil
			and bot:GetNetWorth() < 19800
			and denyDamage > 110
		then
			local nTwoHitDenyCreeps = bot:GetNearbyCreeps(nAttackRange +120, false);
			for _,creep in pairs(nTwoHitDenyCreeps)
			do
				if X.CanBeAttacked(creep)
				and creep:GetHealth()/creep:GetMaxHealth() < 0.5
				and X.IsLastHitCreep(creep,denyDamage *2)
				and ( not X.IsLastHitCreep(creep,denyDamage *1.2) or #nEnemyLaneCreep == 0 )
				and not X.IsOthersTarget(creep)
				and not J.IsTormentor(creep)
				and not J.IsRoshan(creep)
				then
					return creep,BOT_MODE_DESIRE_ABSOLUTE;
				end			
			end
		end	
		

		local nEnemysCreeps = bot:GetNearbyCreeps(1600,true)
		local nAttackAlly = J.GetSpecialModeAllies(bot, 2500, BOT_MODE_ATTACK);
		local nTeamFightLocation = J.GetTeamFightLocation(bot);
		local nDefendLane, nDefendDesire = J.GetMostDefendLaneDesire();

		if X.CanBeAttacked(nEnemysCreeps[1])
		and bot:GetHealth() > 300
		and not X.IsAllysTarget(nEnemysCreeps[1])
		and not J.IsRoshan(nEnemysCreeps[1])
		and (nEnemysCreeps[1]:GetTeam() == TEAM_NEUTRAL or attackDamage > 110)
		and ( not nEnemysCreeps[1]:IsAncientCreep() or attackDamage > 150 )
		and ( not J.IsKeyWordUnit("warlock", nEnemysCreeps[1]) or J.GetHP(bot) > 0.58 )		
		and ( nTeamFightLocation == nil or GetUnitToLocationDistance(bot,nTeamFightLocation) >= 3000 )
		and ( nDefendDesire <= 0.8 )
		and botMode ~= BOT_MODE_FARM
		and botMode ~= BOT_MODE_RUNE
		and botMode ~= BOT_MODE_LANING
		and botMode ~= BOT_MODE_ASSEMBLE
		and botMode ~= BOT_MODE_SECRET_SHOP
		and botMode ~= BOT_MODE_SIDE_SHOP
		and botMode ~= BOT_MODE_WARD
		and GetRoshanDesire() < BOT_MODE_DESIRE_HIGH	
		and not bot:WasRecentlyDamagedByAnyHero(2.0)
		and bot:GetAttackTarget() == nil
		and botLV >= 10
		and #nAttackAlly == 0
		and #nEnemyTowers == 0
		and not J.IsTormentor(nEnemysCreeps[1])
		and not J.IsRoshan(nEnemysCreeps[1])
		then
		
			if nEnemysCreeps[1]:GetTeam() == TEAM_NEUTRAL 
			   and J.IsInRange(bot, nEnemysCreeps[1], nAttackRange + 100)
			   and ( #nEnemysCreeps <= 2 
			         or attackDamage > 220 
					 or botName == "npc_dota_hero_antimage" )
			then
				J.Role['availableCampTable'] = X.UpdateCommonCamp(nEnemysCreeps[1], J.Role['availableCampTable']);
			end
			
			return nEnemysCreeps[1],BOT_MODE_DESIRE_ABSOLUTE;
		end
		

		if bot:GetHealth() > 160 
		   and J.IsWithoutTarget(bot)
		then
			local nNeutrals = bot:GetNearbyNeutralCreeps(nAttackRange + 150);
			if #nNeutrals > 0
			   and botMode ~= BOT_MODE_FARM 
			then			
				for i = 1,#nNeutrals
				do	
					if X.CanBeAttacked(nNeutrals[i])
						and not X.IsAllysTarget(nNeutrals[i])
						and not J.IsTormentor(nNeutrals[i])
						and not J.IsRoshan(nNeutrals[i])
						and X.IsLastHitCreep(nNeutrals[i],attackDamage * 2)
					then 
						return nNeutrals[i],BOT_MODE_DESIRE_ABSOLUTE; 
					end	
				end
			end
		end			
	end	 
	 
    return nil,0;  
end	


function X.IsValid(nUnit)
	
	return nUnit ~= nil and not nUnit:IsNull() and nUnit:IsAlive() and nUnit:CanBeSeen()
	
end


function X.GetAttackDamageToCreep( bot )
	
	if bot:GetItemSlotType(bot:FindItemSlot("item_quelling_blade")) == ITEM_SLOT_TYPE_MAIN
	then
		if bot:GetAttackRange() > 310 or bot:GetUnitName() == "npc_dota_hero_templar_assassin"
		then
			return bot:GetAttackDamage() + 4;
		else
			return bot:GetAttackDamage() + 8;
		end
	end
	
	if bot:FindItemSlot("item_bfury") >= 0
	then
		return bot:GetAttackDamage() + 15;
	end
	
	return bot:GetAttackDamage();
end


function X.CanNotUseAttack(bot)

	return not bot:IsAlive()
		   or J.HasQueuedAction( bot )
		   or bot:IsInvulnerable()
		   or bot:IsCastingAbility() 
		   or bot:IsUsingAbility() 
		   or bot:IsChanneling()  
	       or bot:IsStunned()
		   or bot:IsDisarmed()
		   or bot:IsHexed()
		   or bot:IsRooted()	
		   or X.WillBreakInvisible(bot)
end


function X.WillBreakInvisible(bot)

	local botName = bot:GetUnitName()
	
	local tInvisibleHeroIndex = {
		["npc_dota_hero_riki"] = true,
		["npc_dota_hero_phantom_assassin"] = true,
		["npc_dota_hero_templar_assassin"] = true,		
		["npc_dota_hero_bounty_hunter"] = true,		
	}

	if bot:IsInvisible() 
		and tInvisibleHeroIndex[botName] == nil
	then
		return true
	end

	return false
	
end


function X.CanBeAttacked(unit)
         
	return  unit ~= nil
			and unit:IsAlive()
			and unit:CanBeSeen()
			and not unit:IsNull()
			and not unit:IsAttackImmune()
			and not unit:IsInvulnerable()
			and not unit:HasModifier("modifier_fountain_glyph")
			and (unit:GetTeam() == team 
					or not unit:HasModifier("modifier_crystal_maiden_frostbite") )
			and (unit:GetTeam() ~= team 
			     or ( unit:GetUnitName() ~= "npc_dota_wraith_king_skeleton_warrior" 
					  and unit:GetHealth()/unit:GetMaxHealth() < 0.5 ) )

end


local courierFindCD = 0.1;
local lastFindTime = -90;
function X.GetEnemyCourier(bot,nRadius)
	
	if GetGameMode() == 23 then return nil end
	
	if J.GetDistanceFromEnemyFountain( bot ) < 1400 then return nil end
	
	if DotaTime() > lastFindTime + courierFindCD
	then
		lastFindTime = DotaTime();
		local units = GetUnitList(UNIT_LIST_ENEMIES)
		for _,u in pairs(units) 
		do
		   if u ~= nil 
			  and u:IsCourier()
		   then
			   if u:IsAlive()
				  and GetUnitToUnitDistance(bot,u) <= nRadius
				  and not u:IsInvulnerable()
				  and not u:IsAttackImmune()
				  and not u:HasModifier( 'modifier_fountain_aura' )
			   then
				   return u;
			   end
		   end
		end	
	end
	
	return nil;
	
end

function X.WeakestUnitExceptRangeCanBeAttacked(bHero, bEnemy, nRange, nRadius, bot)
	local units = {};
	local weakest = nil;
	local weakestHP = 4999;
	local realHP = 0;
	if nRadius > 1600 then nRadius = 1600 end;

	if bHero then
		units = J.GetNearbyHeroes(bot,nRadius, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyLaneCreeps(nRadius, bEnemy);
	end

	for _,u in pairs(units) do
		if J.IsValid(u) then
			if GetUnitToUnitDistance(bot,u) > nRange
			   and X.CanBeAttacked(u)
			--    and not u:HasModifier("modifier_crystal_maiden_frostbite")
			then
				realHP = u:GetHealth() / 1;
				if realHP < weakestHP
				then
					weakest = u;
					weakestHP = realHP;
				end
			end
		end
	end
	return weakest;
end


function X.GetSpecialDamageBonus(nDamage,nCreep,bot)
	return 0
end

function X.GetNearbyLastHitCreep(ignorAlly, bEnemy, nDamage, nRadius, bot)

	if nRadius > 1600 then nRadius = 1600 end;
	local nNearbyCreeps = bot:GetNearbyLaneCreeps(nRadius, bEnemy);
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	local botName = bot:GetUnitName();

	if bEnemy
		and botName == "npc_dota_hero_templar_assassin" --V bug
		and bot:HasModifier("modifier_templar_assassin_refraction_damage")
	then
		local cAbility = bot:GetAbilityByName( "templar_assassin_refraction" );
		local bonusDamage = cAbility:GetSpecialValueInt( 'bonus_damage' );
		nDamage = nDamage + bonusDamage;
	end

	if bEnemy
		and botName == "npc_dota_hero_kunkka"
	then
		local cAbility = bot:GetAbilityByName( "kunkka_tidebringer" );
		if cAbility:IsFullyCastable() 
		then
			local bonusDamage = cAbility:GetSpecialValueInt( 'damage_bonus' );
			nDamage = nDamage + bonusDamage;
		end
	end

	for _,nCreep in pairs(nNearbyCreeps)
	do
		if X.CanBeAttacked(nCreep) and nCreep:GetHealth() < ( nDamage + 256 )
		   and ( ignorAlly or not X.IsAllysTarget(nCreep) )
		then
			local nAttackProDelayTime = J.GetAttackProDelayTime(bot,nCreep) ;
			if bEnemy and botName == "npc_dota_hero_antimage"
				and J.IsKeyWordUnit("ranged",nCreep)
			then
				local cAbility = bot:GetAbilityByName( "antimage_mana_break" );
				if cAbility:IsTrained()
				then
					local bonusDamage = 0.5 * cAbility:GetSpecialValueInt( 'mana_per_hit' );
					nDamage = nDamage + bonusDamage;
				end
			end

			local nRealDamage = nDamage * 1
			if J.WillKillTarget(nCreep,nRealDamage,nDamageType,nAttackProDelayTime)
			then
				return nCreep;
			end
		end
	end
	return nil;
end


function X.GetExceptRangeLastHitCreep(bEnemy,nDamage,nRange,nRadius,bot)
	local nCreep = X.WeakestUnitExceptRangeCanBeAttacked(false, bEnemy, nRange, nRadius, bot);
	local nDamageType = DAMAGE_TYPE_PHYSICAL;

	if nCreep ~= nil and nCreep:IsAlive()
	then
		if not bEnemy and nCreep:GetHealth()/nCreep:GetMaxHealth() >= 0.5
		then return nil end
		nDamage = nDamage * 1 ;
		local nAttackProDelayTime = J.GetAttackProDelayTime(bot,nCreep);
		if J.WillKillTarget(nCreep,nDamage,nDamageType,nAttackProDelayTime)
		then
			return nCreep;
		end

	end

	return nil;
end

function X.IsLastHitCreep(nCreep,nDamage)
	
	if nCreep ~= nil and nCreep:IsAlive()
	then
		
		nDamage = nDamage * 1;
		
		if nCreep:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_PHYSICAL) + J.GetCreepAttackProjectileWillRealDamage(nCreep,0.66) > nCreep:GetHealth() +1
		then 
		    return true;
		end
		
	end
	 
	return false;
	
end


function X.GetLastHitHealth(bot,nCreep)
	
	if nCreep ~= nil and nCreep:IsAlive()
	then
	   
       local nDamage = X.GetAttackDamageToCreep(bot) * 1
		
	   return nCreep:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_PHYSICAL);
	end
	 
	return bot:GetAttackDamage();

end


function X.IsAllysTarget(unit)
	local bot = GetBot();
	local allies = J.GetNearbyHeroes(bot,1000,false,BOT_MODE_NONE);
	if #allies < 2 then return false end;
	
	for _,ally in pairs(allies) 
	do
		if ally ~= bot
			and not ally:IsIllusion()
			and ( ally:GetTarget() == unit or ally:GetAttackTarget() == unit )
		then
			return true;
		end
	end
	return false;
end


function X.IsEnemysTarget(unit)
	local bot = GetBot();
	local enemys = J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE);
	for _,enemy in pairs(enemys) 
	do
		if X.IsValid(enemy) and J.GetProperTarget(enemy) == unit 
		then
			return true;
		end
	end
	return false;
end


function X.CanAttackTogether(bot)
   
   local allies = J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE);
   local nNearbyEnemyHeroes = J.GetNearbyHeroes(bot,600,true,BOT_MODE_NONE);
   
   return bot ~= nil and bot:IsAlive()
		  and not bot:IsIllusion()
		  and J.GetProperTarget(bot) == nil
	      and #allies >= 2
		  and (nNearbyEnemyHeroes[1] == nil or nNearbyEnemyHeroes[1]:GetLevel() < 10)
   
end


function X.GetMostDamageUnit(nUnits)
	
	local mostAttackDamage = 0;
	local mostUnit = nil;
	for _,unit in pairs(nUnits)
	do
		if unit ~= nil and unit:IsAlive()
			and J.GetProperTarget(unit) == nil
			and unit:GetAttackDamage() > mostAttackDamage
		then
			mostAttackDamage = unit:GetAttackDamage();
			mostUnit = unit;
		end
	end
	
	return mostUnit;

end


function X.GetCanTogetherCount(nAllies)
	
	local nNum = 0;
	for _,ally in pairs(nAllies)
	do
		if X.IsValid(ally) and X.CanAttackTogether(ally)
		then
			nNum = nNum +1;
		end
	end
	
	return nNum;

end

function X.ConsiderHelpWhenCoreIsTargeted()
	local nRadius = 3500
	local nModeDesire = bot:GetActiveModeDesire()
	local nClosestCore = J.GetClosestCore(bot, nRadius)

	if  nClosestCore ~= nil
	and J.GetHP(nClosestCore) > 0.2
	and (not J.IsCore(bot) or bot.isBear or (J.IsCore(bot) and (not J.IsInLaningPhase() or J.IsInRange(bot, nClosestCore, 1600))))
	and not J.IsGoingOnSomeone(bot)
	and not (J.IsRetreating(bot) and nModeDesire > 0.8)
	then
		local nInRangeAlly = J.GetAlliesNearLoc(nClosestCore:GetLocation(), 1200)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nClosestCore:GetLocation(), 1600)

		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if  J.IsValidHero(enemyHero)
			and GetUnitToUnitDistance(enemyHero, nClosestCore) <= 1600
			and (#nInRangeAlly + 1 >= #nInRangeEnemy)
			then
				if (enemyHero:GetAttackTarget() == nClosestCore or J.IsChasingTarget(enemyHero, nClosestCore))
				or nClosestCore:WasRecentlyDamagedByHero(enemyHero, 2.5)
				then
					return enemyHero, true
				end
			end
		end
	end

	return nil, false
end

function X.IsModeSuitToHitCreep(bot)

	local botMode = bot:GetActiveMode();
	local nEnemyHeroes = J.GetEnemyList(bot,750)

	if #nEnemyHeroes >= 3 
	   or (nEnemyHeroes[1] ~= nil and nEnemyHeroes[1]:GetLevel() >= 8 )
	then
		return false;
	end

	if bot:HasModifier("modifier_axe_battle_hunger")
	then
		local nEnemyLaneCreepList = bot:GetNearbyLaneCreeps( bot:GetAttackRange() + 180, true )
		if #nEnemyLaneCreepList > 0 then return true end
	end

	if bot:GetLevel() <= 3
		and botMode ~= BOT_MODE_EVASIVE_MANEUVERS
		and ( botMode ~= BOT_MODE_RETREAT or ( botMode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() < 0.78) )
	then
		return true;
	end

    return  botMode ~= BOT_MODE_ATTACK
			and botMode ~= BOT_MODE_EVASIVE_MANEUVERS
			and ( botMode ~= BOT_MODE_RETREAT or ( botMode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() < 0.68) )
end


function X.IsMostAttackDamage(bot)

	local nAllies = J.GetNearbyHeroes(bot,800,false,BOT_MODE_NONE);
	for _,ally in pairs(nAllies)
	do
		if ally ~= bot
			and not X.CanNotUseAttack(ally)
			and ally:GetAttackDamage() > bot:GetAttackDamage()
		then
			return false;
		end
	end

	return true;
end


function X.IsOthersTarget(nUnit)
	local bot = GetBot();

	if X.IsAllysTarget(nUnit)
	then
		return true;
	end
	
	if X.IsEnemysTarget(nUnit)
	then
		return true;
	end
	
	if X.IsCreepTarget(nUnit)
	then
		return true
	end
	
	local nTowers = bot:GetNearbyTowers(1600,true);
	for _,tower in pairs(nTowers)
	do
		if tower ~= nil and tower:IsAlive()
		   and tower:GetAttackTarget() == nUnit
		then
			return true;
		end
	end
	
	local nTowers = bot:GetNearbyTowers(1600,false);
	for _,tower in pairs(nTowers)
	do
		if tower ~= nil and tower:IsAlive()
		   and tower:GetAttackTarget() == nUnit
		then
			return true;
		end
	end
	
	return false;

end


function X.IsCreepTarget(nUnit)
	local bot = GetBot();
	local nCreeps = bot:GetNearbyCreeps(1200,true);
	for _,creep in pairs(nCreeps)
	do
		if creep ~= nil and creep:IsAlive()
		and creep:GetAttackTarget() == nUnit
		and not J.IsTormentor(creep)
		and not J.IsRoshan(creep)
		then
			return true;
		end
	end
	
	local nCreeps = bot:GetNearbyCreeps(1200,false);
	for _,creep in pairs(nCreeps)
	do
		if creep ~= nil and creep:IsAlive()
		and creep:GetAttackTarget() == nUnit
		and not J.IsTormentor(creep)
		and not J.IsRoshan(creep)
		then
			return true;
		end
	end

	return false;
end


function X.CanBeInVisible(bot)

	local nEnemyTowers = bot:GetNearbyTowers(800,true);
	if #nEnemyTowers > 0 
	   or bot:HasModifier("modifier_item_dustofappearance")
	then 
		return false;
	end

	if bot:IsInvisible()
	then
		return true;
	end

	local glimer = J.IsItemAvailable("item_glimmer_cape");
	if glimer ~= nil and glimer:IsFullyCastable() 
	then
		return true;			
	end
	
	local invissword = J.IsItemAvailable("item_invis_sword");
	if invissword ~= nil and invissword:IsFullyCastable() 
	then
		return true;			
	end
	
	local silveredge = J.IsItemAvailable("item_silver_edge");
	if silveredge ~= nil and silveredge:IsFullyCastable() 
	then
		return true;			
	end

	return false;
end


local lastUpdateTime = 0
function X.UpdateCommonCamp(creep, AvailableCamp)
	if lastUpdateTime < DotaTime() - 3.0
	then
		lastUpdateTime = DotaTime();
		for i = 1, #AvailableCamp
		do
			if GetUnitToLocationDistance(creep,AvailableCamp[i].cattr.location) < 500 then
				table.remove(AvailableCamp, i);
				return AvailableCamp;
			end
		end
	end
	return AvailableCamp;
end

function X.IsSpecialCore(bot)
    if J.IsCore(bot)
	then
		local botName = bot:GetUnitName();
		if Roles.IsNuker(botName) and Roles.IsCarry(botName) then
			return true
		end
	end

	return false
end

function X.IsSpecialSupport(bot)
	if not J.IsCore(bot) then
		local botName = bot:GetUnitName();
		if Roles.IsSupport(botName) and (Roles.IsHealer(botName) or Roles.IsDisabler(botName) or Roles.IsDurable(botName)) then
			return true
		end
	end
	return false
end

local fLastReturnTime = 0
function X.ShouldAttackTowerCreep(bot)
	if X.CanNotUseAttack(bot) then return 0 end
	if bot:GetLevel() > 2
		and bot:GetAnimActivity() == 1502
		and bot:GetTarget() == nil
	    and bot:GetAttackTarget() == nil
		and X.IsModeSuitToHitCreep(bot)
		and J.GetHP(bot) > 0.38
		and not bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local nRange = bot:GetAttackRange() + 150;
		if nRange > 1250 then nRange = 1250 end; 
		local allyCreeps = bot:GetNearbyLaneCreeps(800,false);
		local enemyCreeps = bot:GetNearbyLaneCreeps(800,true);
		local attackTime = bot:GetSecondsPerAttack() * 0.75;
		local attackTarget = nil;
		local nEnemyHeroes = J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE);
		local nEnemyTowers = bot:GetNearbyTowers(nRange,true);
		local botMoveSpeed = bot:GetCurrentMovementSpeed();
		if X.CanBeAttacked(nEnemyTowers[1]) 
			and ( nEnemyTowers[1]:GetAttackTarget() ~= bot or J.GetHP(bot) > 0.8 )
			-- and not nEnemyTowers[1]:HasModifier('modifier_backdoor_protection')
			and #allyCreeps > 0
			and fLastReturnTime < DotaTime() - 1.0
		then
			attackTarget = nEnemyTowers[1];
			local nDist = GetUnitToUnitDistance(bot,attackTarget) - bot:GetAttackRange();
			if nDist > 0 then attackTime = attackTime + nDist/botMoveSpeed;end
			fLastReturnTime = DotaTime();
			return attackTime,attackTarget;
		end

		local nEnemyBarracks = bot:GetNearbyBarracks(nRange,true);
		if X.CanBeAttacked(nEnemyBarracks[1]) and #allyCreeps > 0
			-- and not nEnemyBarracks[1]:HasModifier('modifier_backdoor_protection')
		then
			attackTarget = nEnemyBarracks[1];
			local nDist = GetUnitToUnitDistance(bot,attackTarget) - bot:GetAttackRange();
			if nDist > 0 then attackTime = attackTime + nDist/botMoveSpeed;end
			return attackTime,attackTarget;
		end

		local nEnemyAncient = GetAncient(GetOpposingTeam())
		if J.IsInRange(bot,nEnemyAncient,nRange + 80)
			and X.CanBeAttacked(nEnemyAncient) and #enemyCreeps == 0
			-- and not nEnemyAncient:HasModifier('modifier_backdoor_protection')
			and( nEnemyHeroes[1] == nil 
			     or nEnemyHeroes[1]:GetAttackTarget() ~= bot 
				 or J.GetHP(bot) > 0.49 )
		then
			attackTarget = nEnemyAncient;
			local nDist = GetUnitToUnitDistance(bot,attackTarget) - bot:GetAttackRange();
			if nDist > 0 then attackTime = attackTime + nDist/botMoveSpeed;end
			return attackTime,attackTarget;
		end
	end

	local nTowers = bot:GetNearbyTowers(1600,false);
	if nTowers[1] == nil
		or not X.IsMostAttackDamage(bot)
		or bot:GetLevel() > 12
	then
		return 0,nil;
	end

	if nTowers[1] ~= nil
		and nTowers[1]:GetAttackTarget() ~= nil
	then
		local towerTarget = nTowers[1]:GetAttackTarget();		
		local hAllyCreepList = bot:GetNearbyLaneCreeps(500,false);
		if not towerTarget:IsHero()
			and X.CanBeAttacked(towerTarget)
			and #hAllyCreepList == 0
			and not X.IsCreepTarget(towerTarget)
			and GetUnitToUnitDistance(bot,towerTarget) < bot:GetAttackRange() + 100
		then
			local towerRealDamage = X.GetLastHitHealth(nTowers[1],towerTarget);
			local botRealDamage =	X.GetLastHitHealth(bot,towerTarget);
			local attackTime = bot:GetSecondsPerAttack() -0.3;
			local towerTargetHealth = towerTarget:GetHealth();

			if towerRealDamage > botRealDamage
				and towerTargetHealth > towerRealDamage
				and towerTargetHealth % towerRealDamage > botRealDamage
			then
				return attackTime,towerTarget;
			end
		end
	end
	return 0,nil;
end

function X.ShouldNotRetreat(bot)
	if bot:HasModifier("modifier_item_satanic_unholy")
	--    or bot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
	   or bot:HasModifier("modifier_abaddon_borrowed_time")
	   or ( bot:GetCurrentMovementSpeed() < 240 and not bot:HasModifier("modifier_arc_warden_spark_wraith_purge") )
	then
		return true;
	end
	local nAttackAlly = J.GetNearbyHeroes(bot,1000,false,BOT_MODE_ATTACK);
	if ( bot:HasModifier("modifier_item_mask_of_madness_berserk")
			or J.CanIgnoreLowHp(bot) )
		and ( #nAttackAlly >= 1 or J.GetHP(bot) > 0.6 )
		and (bot:WasRecentlyDamagedByAnyHero(1) or bot:WasRecentlyDamagedByTower(1))
	then
		return true;
	end

	local nAllies = J.GetAllyList(bot,800);
    if #nAllies <= 1
	then
	    return false;
	end

	if ( botName == "npc_dota_hero_medusa" 
	     or bot:FindItemSlot("item_abyssal_blade") >= 0 )
		 or bot:HasModifier('modifier_muerta_pierce_the_veil_buff')
		 and (bot:WasRecentlyDamagedByAnyHero(1) or J.GetHP(bot) > 0.2 or bot:WasRecentlyDamagedByTower(1))
		and #nAllies >= 3 and #nAttackAlly >= 1
	then
		return true;
	end

	if botName == "npc_dota_hero_skeleton_king"
		and bot:GetLevel() >= 6 and #nAttackAlly >= 1
	then
		local abilityR = bot:GetAbilityByName( "skeleton_king_reincarnation" );
		if abilityR:GetCooldownTimeRemaining() <= 1.0 and bot:GetMana() >= 160
		then
			return true;
		end
	end

	for _,ally in pairs(nAllies)
	do
		if J.IsValid(ally)
		then
			if J.GetHP(bot) >= 0.3 and ( J.GetHP(ally) > 0.88 and ally:GetLevel() >= 12 and ally:GetActiveMode() ~= BOT_MODE_RETREAT)
			    or ( ally:HasModifier("modifier_black_king_bar_immune") or ally:IsMagicImmune() )
				or ( ally:HasModifier("modifier_item_mask_of_madness_berserk") and ally:GetAttackTarget() ~= nil )
				or ally:HasModifier("modifier_abaddon_borrowed_time")
				or ally:HasModifier("modifier_item_satanic_unholy")
				or J.CanIgnoreLowHp(ally)
			then
				return true;
			end
		end
	end
	return false;
end

local bHumanAlly = nil
function X.HasHumanAlly( bot )

	if bHumanAlly == false then return false end

	if bHumanAlly == nil 
	then
		local teamPlayerIDList = GetTeamPlayers( team )
		for i = 1, #teamPlayerIDList
		do
			if not IsPlayerBot( teamPlayerIDList[i] )
			then
				bHumanAlly = true
				break
			end
		end
		if bHumanAlly ~= true then bHumanAlly = false end
	end

	local allyHeroList = J.GetNearbyHeroes(bot, 900, false, BOT_MODE_NONE )
	for _, npcAlly in pairs( allyHeroList )
	do
		if not npcAlly:IsBot()
		then
			return true
		end
	end
	return false
end

function ConsiderHarassInLaningPhase()
	local botLvl = bot:GetLevel()

	shouldHarass = false
	if J.IsInLaningPhase()
	and not J.IsCore(bot)
	and (botLvl >= 4 or (botLvl >= 3 and J.GetPosition(bot) == 4))
	and J.GetHP(bot) > 0.7
	and not bot:WasRecentlyDamagedByAnyHero(2)
	then
		local nModeDesire = bot:GetActiveModeDesire()
		local nInRangeAlly = J.GetNearbyHeroes(bot,700, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,700, true, BOT_MODE_NONE)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(700, true)
		local nAttackRange = bot:GetAttackRange()
		local nInRangeTower = bot:GetNearbyTowers(1200, true)
		if #nInRangeTower >= 1 or #nEnemyLaneCreeps >= 3
		then
			return BOT_ACTION_DESIRE_NONE
		end

		local canLastHitCount = 0
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and J.CanBeAttacked(creep)
			and J.GetHP(creep) <= 0.6
			then
				canLastHitCount = canLastHitCount + 1
			end
		end

		if J.GetHP(bot) > 0.41
		and ((J.IsCore(bot) and not canLastHitCount == 0)
			or (not J.IsCore(bot)))
		then
			-- MK Range
			if nAttackRange < 300
			then
				nAttackRange = 300
			end

			nInRangeEnemy = J.GetNearbyHeroes(bot,nAttackRange, true, BOT_MODE_NONE)
			if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
			then
				if J.IsValidHero(nInRangeEnemy[1])
				and J.CanBeAttacked(nInRangeEnemy[1])
				and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
				and not J.IsRetreating(bot)
				and nInRangeAlly ~= nil and nInRangeEnemy
				and #nInRangeAlly >= #nInRangeEnemy
				then
					local nTargetInRangeTower = nInRangeEnemy[1]:GetNearbyTowers(850, false)

					if (nInRangeTower ~= nil and #nInRangeTower == 0
						or nTargetInRangeTower ~= nil and #nTargetInRangeTower == 0)
					and not bot:WasRecentlyDamagedByAnyHero(2.2)
					and not bot:WasRecentlyDamagedByTower(2)
					and not bot:WasRecentlyDamagedByCreep(1.5)
					then
						shouldHarass = true
						harassTarget = nInRangeEnemy[1]

						if J.IsLaning(bot)
						then
							if J.IsHumanPlayer(nInRangeEnemy[1]) and bot:GetActiveMode() ~= BOT_MODE_TEAM_ROAM then
								return nModeDesire + 0.1
							end
							return BOT_MODE_DESIRE_MODERATE * 1.15
						else
							return BOT_MODE_DESIRE_MODERATE * 1.16
						end
					end
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function IsDoingTormentor()
	local nCreeps = bot:GetNearbyNeutralCreeps(700)

	for _, c in pairs(nCreeps)
	do
		if c:GetUnitName() == 'npc_dota_miniboss' or #J.GetAlliesNearLoc(TormentorLocation, 400) >= 2
		then
			return true
		end
	end

	return false
end

-- Swap smoke after killing Roshan
function SwapSmokeSupport()
	if J.IsDoingRoshan(bot)
	then
		local botTarget = bot:GetAttackTarget()

		if J.IsRoshan(botTarget)
		and J.IsAttacking(bot)
		then
			local smokeSlot = bot:FindItemSlot('item_smoke_of_deceit')

			if bot:GetItemSlotType(smokeSlot) == ITEM_SLOT_TYPE_BACKPACK
			then
				local leastCostItem = J.FindLeastExpensiveItemSlot()
	
				if leastCostItem ~= -1
				then
					bot:ActionImmediate_SwapItems(smokeSlot, leastCostItem)
				end
			end
		end
	end
end
-- Swap Items for healing
function TrySwapInvItemForClarity()
	if 	DotaTime() >= SwappedClarityTime + 6.3
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
	if 	DotaTime() >= SwappedFlaskTime + 6.2
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

function TrySwapInvItemForSmoke()
	if 	DotaTime() >= SwappedSmokeTime + 15
	then
		local cSlot = bot:FindItemSlot('item_smoke_of_deceit')
		if cSlot and bot:GetItemSlotType(cSlot) == ITEM_SLOT_TYPE_BACKPACK
		then
			local lessValItem = J.Item.GetMainInvLessValItemSlot(bot)

			if lessValItem ~= -1
			then
				bot:ActionImmediate_SwapItems(cSlot, lessValItem)
			end
		end

		SwappedSmokeTime = DotaTime()
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
	if 	DotaTime() >= SwappedCheeseTime + 2.3
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
	if 	DotaTime() >= SwappedRefresherShardTime + 2.2
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

function TrySellOrDropItem()
	if DotaTime() > 0 and DotaTime() - lastCheckBotToDropTime > 3
	then
		lastCheckBotToDropTime = DotaTime()

		-- 再尝试丢/卖掉
		if bot:GetLevel() >= 6 and bot:GetNetWorth() >= 14000 and Utils.CountBackpackEmptySpace(bot) <= 1 then
			for i = 1, #Item['tEarlyConsumableItem']
			do
				local itemName = Item['tEarlyConsumableItem'][i]
				local itemSlot = bot:FindItemSlot( itemName )
				if itemSlot >= 6 and itemSlot <= 8
				then
					local distance = bot:DistanceFromFountain()
					if distance <= 300 then
						bot:ActionImmediate_SellItem( bot:GetItemInSlot( itemSlot ))
					elseif distance >= 3000 then
						bot:Action_DropItem( bot:GetItemInSlot( itemSlot ), bot:GetLocation() )
					end
				end
			end
		end
	end
end

function J.FindLeastExpensiveItemSlot()
	local minCost = 100000
	local idx = -1

	for i = 0, 5
	do
		if bot:GetItemInSlot(i) ~= nil
		and bot:GetItemInSlot(i):GetName() ~= 'item_aegis'
		and bot:GetItemInSlot(i):GetName() ~= 'item_rapier'
		then
			local item = bot:GetItemInSlot(i):GetName()

			if GetItemCost(item) < minCost
			and not (item == 'item_ward_observer' or item == 'item_ward_sentry')
			then
				minCost = GetItemCost(item)
				idx = i
			end
		end
	end

	return idx
end

X.GetDesire = GetDesire
X.Think = Think

return X
