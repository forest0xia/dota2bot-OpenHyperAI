local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Customize = require(GetScriptDirectory()..'/Customize/general')
Customize.ThinkLess = Customize.Enable and Customize.ThinkLess or 1

local bot = GetBot()

local minute = 0
local second = 0

local bBottle = false

local nRuneList = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2,
}

local botHP, botMP, botPos, botActiveMode, botActiveModeDesire, botAssignedLane
local nAllyHeroes, nEnemyHeroes

local nHumanClaimedRuneTime = {}

local function IsHumanClaimingRune(nRune)
	local vRuneLoc = GetRuneSpawnLocation(nRune)
	if nHumanClaimedRuneTime[nRune] and GameTime() - nHumanClaimedRuneTime[nRune] < 5 then
		return true
	end
	for i = 1, #GetTeamPlayers(GetTeam()) do
		local member = GetTeamMember(i)
		if member ~= nil and member:IsAlive() and not member:IsBot() then
			if GetUnitToLocationDistance(member, vRuneLoc) < 2000 then
				nHumanClaimedRuneTime[nRune] = GameTime()
				return true
			end
			local ping = member:GetMostRecentPing()
			if ping ~= nil and ping.normal_ping
			and J.GetDistance(ping.location, vRuneLoc) < 800
			and GameTime() - ping.time < 5 then
				nHumanClaimedRuneTime[nRune] = GameTime()
				return true
			end
		end
	end
	return false
end

-- Wisdom rune state
local radiantWRLocation = Vector(-7948.152344, 768.207825, 256.000000)
local direWRLocation = Vector(8029.234375, -1125.811768, 256.000000)
local wisdomRuneSpots = { [TEAM_RADIANT] = radiantWRLocation, [TEAM_DIRE] = direWRLocation }
local nShrineOfWisdomTime = 0
local nShrineOfWisdomTeam = TEAM_RADIANT

--------------------------------------------------------------------
-- GetDesire  (reference structure, with local additions)
--------------------------------------------------------------------
function GetDesire()
	X.InitRune()

	if (DotaTime() > 2 * 60 and DotaTime() < 6 * 60 and GetUnitToLocationDistance(bot, GetRuneSpawnLocation(RUNE_POWERUP_2)) < 80) then
		return BOT_MODE_DESIRE_NONE
	end

	bBottle = bot:FindItemSlot('item_bottle') >= 0
	botHP = J.GetHP(bot)
	botMP = J.GetMP(bot)
	botPos = J.GetPosition(bot)
	botActiveMode = bot:GetActiveMode()
	botActiveModeDesire = bot:GetActiveModeDesire()
	botAssignedLane = bot:GetAssignedLane()
	nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if bot:IsInvulnerable() and botHP > 0.9 and bot:DistanceFromFountain() < 500 then
		return BOT_MODE_DESIRE_ABSOLUTE
	end

	-- Drop rune desire when outnumbered or taking damage so attack/retreat can take over.
	-- This prevents bots from walking into 5-man ambushes at rune spots.
	if #nEnemyHeroes > 0 then
		if #nEnemyHeroes > #nAllyHeroes then
			return BOT_MODE_DESIRE_NONE
		end
		if bot:WasRecentlyDamagedByAnyHero(2.0) and botHP < 0.7 then
			return BOT_MODE_DESIRE_NONE
		end
	end

	-- Wisdom Rune
	if bot:GetLevel() < 30 then
		nShrineOfWisdomTime = X.GetCurrentWisdomTime()
		X.UpdateWisdom()

		if  DotaTime() >= 7 * 60
		and not J.IsMeepoClone(bot)
		and not bot:HasModifier('modifier_arc_warden_tempest_double')
		and bot.rune and bot.rune.wisdom and bot.rune.wisdom[nShrineOfWisdomTime]
		then
			local wisdom = bot.rune.wisdom[nShrineOfWisdomTime]

			if DotaTime() < wisdom.time + 3.5 then
				if not bot:WasRecentlyDamagedByAnyHero(3.0) then
					return BOT_MODE_DESIRE_ABSOLUTE
				end
			end

			local nEnemyTowers = bot:GetNearbyTowers(700, true)
			local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
			if (#nEnemyTowers > 0 and bot:WasRecentlyDamagedByTower(1.0) and botHP < 0.3)
			or (#nInRangeEnemy > 0 and not J.IsRealInvisible(bot))
			then
				return 0
			end

			nShrineOfWisdomTeam = X.GetShrineOfWisdomTeam()
			if nShrineOfWisdomTeam then
				local bChecked  = wisdom.spot[nShrineOfWisdomTeam].status
				local vLocation = wisdom.spot[nShrineOfWisdomTeam].location
				if bChecked == false then
					if bot == X.GetWisdomAlly(vLocation) then
						return X.GetWisdomDesire(vLocation)
					end
				end
			end
		end
	end

	if (DotaTime() > -10 and bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE) then
		return BOT_MODE_DESIRE_NONE
	end

	-- Don't leave high ground push or ancient defense for runes (local addition)
	if J.Utils.IsTeamPushingSecondTierOrHighGround(bot) then
		return BOT_MODE_DESIRE_NONE
	end
	local enemiesAtAncient = J.Utils.CountEnemyHeroesNear(GetAncient(GetTeam()):GetLocation(), 3200)
	if enemiesAtAncient >= 1 then
		return BOT_MODE_DESIRE_NONE
	end

	-- Core rune logic using bot.rune state (reference pattern)
	if bot.rune and bot.rune.normal then
		local nProximityRadius = 1600
		local rune = bot.rune.normal

		rune.location, rune.distance = X.GetBestRune()

		-- Pre-game: move toward rune with moderate desire
		if DotaTime() < 0 and not bot:WasRecentlyDamagedByAnyHero(10.0) then
			return BOT_MODE_DESIRE_MODERATE
		end

		if rune.location ~= -1 then
			rune.type = GetRuneType(rune.location)
			rune.status = GetRuneStatus(rune.location)

			local vRuneLocation = GetRuneSpawnLocation(rune.location)

			-- Defer to human players nearby (local addition)
			if rune.distance < 1200 then
				for _, ally in pairs(nAllyHeroes) do
					if ally ~= nil and not ally:IsBot() and GetUnitToLocationDistance(ally, vRuneLocation) < 2000 then
						return BOT_MODE_DESIRE_NONE
					end
				end
			end

			if rune.location == RUNE_BOUNTY_1 or rune.location == RUNE_BOUNTY_2 then
				if rune.status == RUNE_STATUS_AVAILABLE
				and (X.IsTeamMustSaveRune(rune.location) or not J.IsInLaningPhase() or GetUnitToLocationDistance(bot, vRuneLocation) <= 500)
				then
					if X.IsEnemyPickRune(rune.location) then return BOT_MODE_DESIRE_NONE end

					if bBottle or (botPos >= 4 and not X.IsThereAllyWithBottle(vRuneLocation, 1600)) then
						return X.GetScaledDesire(BOT_MODE_DESIRE_HIGH, rune.distance, 3500)
					else
						return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, rune.distance, 3500)
					end
				elseif rune.status == RUNE_STATUS_UNKNOWN
					and rune.distance <= nProximityRadius * 1.5
					and DotaTime() > 3 * 60 + 50
					and ((minute % 4 == 0) or (minute % 4 == 3) and second > 45)
				then
					return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, rune.distance, nProximityRadius)
				elseif rune.status == RUNE_STATUS_MISSING
					and rune.distance <= nProximityRadius * 1.5
					and DotaTime() > 3 * 60 + 50
					and ((minute % 4 == 3) or second > 52)
				then
					return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, rune.distance, nProximityRadius * 2.5)
				end
			else
				-- Power rune / water rune
				if rune.status == RUNE_STATUS_AVAILABLE then
					if X.IsEnemyPickRune(rune.location) then return BOT_MODE_DESIRE_NONE end

					local nRuneType = rune.type
					-- Water rune support (local addition)
					if nRuneType == RUNE_WATER and (bBottle or botHP < 0.6 or botMP < 0.5) then
						return X.GetScaledDesire(BOT_MODE_DESIRE_HIGH, rune.distance, 3200)
					elseif nRuneType == RUNE_WATER and not bBottle then
						return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, rune.distance, nProximityRadius)
					end

					if bBottle or (not J.IsEarlyGame() and botPos <= 3) then
						return X.GetScaledDesire(BOT_MODE_DESIRE_HIGH, rune.distance, nProximityRadius * 2.5)
					else
						return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, rune.distance, nProximityRadius * 2.5)
					end
				elseif rune.status == RUNE_STATUS_UNKNOWN and DotaTime() > 113 then
					if bBottle or (not J.IsEarlyGame() and botPos <= 3) then
						return X.GetScaledDesire(BOT_MODE_DESIRE_HIGH, rune.distance, nProximityRadius * 2.5)
					else
						return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, rune.distance, nProximityRadius)
					end
				elseif rune.status == RUNE_STATUS_MISSING and DotaTime() > 60 and (minute % 2 == 1 and second > 53) then
					return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, rune.distance, nProximityRadius)
				elseif rune.status == RUNE_STATUS_UNKNOWN and X.IsTeamMustSaveRune(rune.location) and DotaTime() > 113 and rune.distance <= nProximityRadius * 2 then
					return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, rune.distance, nProximityRadius * 2)
				end
			end
		end
	end

	return BOT_MODE_DESIRE_NONE
end

--------------------------------------------------------------------
-- OnStart / OnEnd
--------------------------------------------------------------------
local Bottle = nil
function OnStart()
	local nSlot = bot:FindItemSlot('item_bottle')
	if bot:GetItemSlotType(nSlot) == ITEM_SLOT_TYPE_MAIN then
		Bottle = bot:GetItemInSlot(nSlot)
	end
end

function OnEnd()
	Bottle = nil
end

--------------------------------------------------------------------
-- Think  (reference structure)
--------------------------------------------------------------------
local fNextMovementTime = -math.huge
function Think()
	if bot:IsInvulnerable() and bot:DistanceFromFountain() < 500 then
		bot:Action_MoveToLocation(bot:GetLocation() + RandomVector(500))
		return
	end

	if J.CanNotUseAction(bot)
	or bot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_RUNE
	then
		return
	end

	-- Wisdom Rune
	if nShrineOfWisdomTeam and DotaTime() >= 7 * 60
	and bot.rune and bot.rune.wisdom and bot.rune.wisdom[nShrineOfWisdomTime]
	then
		local wisdom = bot.rune.wisdom[nShrineOfWisdomTime]
		if wisdom then
			local vLocation = wisdom.spot[nShrineOfWisdomTeam].location
			local nInRangeEnemy = J.GetEnemiesNearLoc(vLocation, 1600)

			if wisdom.spot[nShrineOfWisdomTeam].status == false then
				for _, enemyHero in pairs(nInRangeEnemy) do
					if J.IsValidHero(enemyHero)
					and ((not enemyHero:IsBot())
						or (GetUnitToLocationDistance(enemyHero, vLocation) + 400 < GetUnitToLocationDistance(bot, vLocation)))
					then
						wisdom.spot[nShrineOfWisdomTeam].status = true
					end
				end

				if GetUnitToLocationDistance(bot, vLocation) < 250 then
					if wisdom.spot[nShrineOfWisdomTeam].status == false then
						wisdom.time = DotaTime()
					end
					wisdom.spot[nShrineOfWisdomTeam].status = true
				end

				bot.rune.location = vLocation
				bot:Action_MoveDirectly(vLocation)
				return
			else
				nInRangeEnemy = J.GetEnemiesNearLoc(vLocation, 300)
				if GetUnitToLocationDistance(bot, vLocation) < 300 and #nInRangeEnemy > 0 then
					wisdom.spot[nShrineOfWisdomTeam].status = false
					wisdom.time = DotaTime()
				end
			end

			if DotaTime() < wisdom.time + 3.5 then
				bot:Action_ClearActions(false)
				return
			end
		end
	end

	-- Pre-game movement
	if DotaTime() < 0 then
		if J.IsModeTurbo() and DotaTime() < -50 then
			return
		end

		-- If outnumbered near rune spot, retreat to tower safety instead
		local preGameEnemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local preGameAllies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
		if #preGameEnemies > #preGameAllies and #preGameEnemies >= 2 then
			local safeLoc = GetLaneFrontLocation(GetTeam(), botAssignedLane or bot:GetAssignedLane(), -1500)
			bot:Action_MoveToLocation(safeLoc)
			return
		end

		if DotaTime() < -10 then
			local vLocation = X.GetGoOutLocation()
			if GetUnitToLocationDistance(bot, vLocation) > 300 then
				bot:Action_MoveToLocation(vLocation)
				return
			else
				if DotaTime() >= fNextMovementTime then
					bot:Action_MoveToLocation(vLocation + RandomVector(150))
					fNextMovementTime = DotaTime() + RandomFloat(1, 3)
					return
				end
			end
			return
		end

		if GetTeam() == TEAM_RADIANT then
			if botAssignedLane == LANE_BOT then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2) + RandomVector(50))
				return
			else
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_POWERUP_1) + RandomVector(50))
				return
			end
		else
			if botAssignedLane == LANE_TOP then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1) + RandomVector(50))
				return
			else
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_POWERUP_2) + RandomVector(50))
				return
			end
		end
	end

	-- Post-horn rune pickup (reference pattern using bot.rune state)
	if bot.rune and bot.rune.normal then
		local botAttackRange = math.min(bot:GetAttackRange() + 150, 1200)
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), botAttackRange)
		local nEnemyCreeps = bot:GetNearbyCreeps(botAttackRange, true)
		local rune = bot.rune.normal

		local vRuneLocation = GetRuneSpawnLocation(rune.location)

		if rune.status == RUNE_STATUS_AVAILABLE then
			if Bottle and J.CanCastAbility(Bottle) and rune.distance < 1200 then
				local nCharges = Bottle:GetCurrentCharges()
				if nCharges > 0 and (botHP ~= 1 or botMP ~= 1) then
					bot:Action_UseAbility(Bottle)
					return
				end
			end

			if rune.distance > 50 then
				for _, enemyHero in pairs(nInRangeEnemy) do
					if J.IsValidHero(enemyHero)
					and (1.5 * bot:GetEstimatedDamageToTarget(false, bot, 5.0, DAMAGE_TYPE_ALL) > enemyHero:GetEstimatedDamageToTarget(true, bot, 5.0, DAMAGE_TYPE_ALL))
					and botHP > 0.3
					then
						bot:Action_AttackUnit(enemyHero, true)
						return
					end
				end

				if J.IsValid(nEnemyCreeps[1])
				and J.CanBeAttacked(nEnemyCreeps[1])
				and J.CanKillTarget(nEnemyCreeps[1], bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL)
				then
					bot:Action_AttackUnit(nEnemyCreeps[1], true)
					return
				end

				bot.rune.location = vRuneLocation
				bot:Action_MoveToLocation(vRuneLocation)
				return
			else
				bot:Action_PickUpRune(rune.location)
				return
			end
		else
			for _, enemyHero in pairs(nInRangeEnemy) do
				if J.IsValidHero(enemyHero)
				and (1.6 * bot:GetEstimatedDamageToTarget(false, bot, 5.0, DAMAGE_TYPE_ALL) > enemyHero:GetEstimatedDamageToTarget(true, bot, 5.0, DAMAGE_TYPE_ALL))
				and botHP > 0.3
				then
					bot:Action_AttackUnit(enemyHero, true)
					return
				end
			end

			if J.IsValid(nEnemyCreeps[1])
			and J.CanBeAttacked(nEnemyCreeps[1])
			and J.CanKillTarget(nEnemyCreeps[1], bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL)
			then
				bot:Action_AttackUnit(nEnemyCreeps[1], true)
				return
			end

			bot.rune.location = vRuneLocation
			bot:Action_MoveToLocation(vRuneLocation)
			return
		end
	end
end

--------------------------------------------------------------------
-- InitRune  (from reference — stores rune state on bot handle)
--------------------------------------------------------------------
function X.InitRune()
	if bot.rune == nil then
		bot.rune = {
			normal = {
				time = 0,
				type = nil,
				location = nil,
				distance = 0,
				status = RUNE_STATUS_MISSING,
			},
			wisdom = {},
			location = nil,
		}
	elseif bot.rune.wisdom == nil then
		bot.rune.wisdom = {}
	end
end

--------------------------------------------------------------------
-- IsSuitableToPickRune  (reference version — no last-seen check)
--------------------------------------------------------------------
function X.IsSuitableToPickRune()
	if X.IsNearRune(bot, 550) then return true end

	local vRuneLocation = GetRuneSpawnLocation(bot.rune.normal.location)

	if (J.IsRetreating(bot) and botActiveModeDesire > BOT_MODE_DESIRE_HIGH)
	or (#nEnemyHeroes >= 1 and #J.GetHeroesTargetingUnit(nEnemyHeroes, bot) > 0)
	or (bot:WasRecentlyDamagedByAnyHero(5.0) and J.IsRetreating(bot))
	or (GetUnitToUnitDistance(bot, GetAncient(GetTeam())) < 2500 and DotaTime() > 0)
	or GetUnitToUnitDistance(bot, GetAncient(GetOpposingTeam())) < 4000
	or bot:HasModifier('modifier_item_shadow_amulet_fade')
	then
		return false
	end

	return true
end

function X.IsNearRune(hUnit, nRadius)
	nRadius = nRadius or 600
	for _, rune in pairs(nRuneList) do
		local vRuneLocation = GetRuneSpawnLocation(rune)
		if GetUnitToLocationDistance(hUnit, vRuneLocation) <= nRadius then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------
-- GetBestRune  (reference version — simple closest ally check)
--------------------------------------------------------------------
function X.GetBestRune()
	minute = math.floor(DotaTime() / 60)
	second = DotaTime() % 60

	local targetRune = -1
	local targetRuneDistance = math.huge
	for _, rune in pairs(nRuneList) do
		local vRuneLocation = GetRuneSpawnLocation(rune)

		if X.IsTheClosestAlly(bot, vRuneLocation)
		and not X.IsPingedByHumanPlayer(vRuneLocation, math.huge)
		and not IsHumanClaimingRune(rune)
		and not X.IsMissing(rune)
		then
			if (rune == RUNE_BOUNTY_1 or rune == RUNE_BOUNTY_2)
			or (J.IsCore(bot) or not J.IsThereCoreNearby(1200))
			then
				local dist = GetUnitToLocationDistance(bot, vRuneLocation)
				if dist < targetRuneDistance then
					targetRune = rune
					targetRuneDistance = dist
				end
			end
		end
	end

	return targetRune, targetRuneDistance
end

--------------------------------------------------------------------
-- IsTheClosestAlly  (reference version — pure distance)
--------------------------------------------------------------------
function X.IsTheClosestAlly(hUnit, vLocation)
	local targetAlly = hUnit
	local targetAllyDistance = GetUnitToLocationDistance(hUnit, vLocation)
	for i = 1, 5 do
		local member = GetTeamMember(i)
		if J.IsValidHero(member) then
			local memberDistance = GetUnitToLocationDistance(member, vLocation)
			if memberDistance < targetAllyDistance then
				targetAlly = member
				targetAllyDistance = memberDistance
			end
		end
	end
	return targetAlly == hUnit
end

function X.IsThereAllyWithBottle(vLocation, nRadius)
	for i = 1, 5 do
		local member = GetTeamMember(i)
		if J.IsValidHero(member)
		and member ~= bot
		and GetUnitToLocationDistance(member, vLocation) <= nRadius
		and member:FindItemSlot('item_bottle') >= 0
		then
			return true
		end
	end
	return false
end

function X.IsTherePosition(nPos, nRuneLoc, nRadius)
	local vRuneLocation = GetRuneSpawnLocation(nRuneLoc)
	for i = 1, 5 do
		local member = GetTeamMember(i)
		if J.IsValidHero(member) and J.GetPosition(member) == nPos and bot ~= member then
			local dist1 = GetUnitToLocationDistance(bot, vRuneLocation)
			local dist2 = GetUnitToLocationDistance(member, vRuneLocation)
			if dist1 <= nRadius and dist2 <= nRadius then
				return true
			end
		end
	end
	return false
end

--------------------------------------------------------------------
-- Utility functions
--------------------------------------------------------------------
local pingTimeDelta = 30
function X.IsPingedByHumanPlayer(vLocation, nRadius)
	for i = 1, 5 do
		local member = GetTeamMember(i)
		if J.IsValidHero(member)
		and not member:IsBot()
		and GetUnitToLocationDistance(member, vLocation) <= nRadius
		then
			local ping = member:GetMostRecentPing()
			if ping then
				if not ping.normal_ping
				and J.GetDistance(ping.location, vLocation) <= 800
				and GameTime() - ping.time < pingTimeDelta
				then
					return true
				end
			end
		end
	end
	return false
end

function X.IsPowerRune(nRuneLoc)
	local nRuneType = GetRuneType(nRuneLoc)
	if nRuneType == RUNE_DOUBLEDAMAGE
	or nRuneType == RUNE_HASTE
	or nRuneType == RUNE_ILLUSION
	or nRuneType == RUNE_INVISIBILITY
	or nRuneType == RUNE_REGENERATION
	or nRuneType == RUNE_ARCANE
	or nRuneType == RUNE_SHIELD
	then
		return true
	end
	return false
end

function X.IsMissing(nRune)
	if second < 52 and GetRuneStatus(nRune) == RUNE_STATUS_MISSING then
		return true
	end
	return false
end

function X.IsEnemyPickRune(nRune)
	local vRuneLocation = GetRuneSpawnLocation(nRune)

	if GetUnitToLocationDistance(bot, vRuneLocation) < 600 then return false end

	for _, enemy in pairs(nEnemyHeroes) do
		if J.IsValidHero(enemy)
		and not J.IsSuspiciousIllusion(enemy)
		and (enemy:IsFacingLocation(vRuneLocation, 30) or GetUnitToLocationDistance(enemy, vRuneLocation) < 600)
		and (GetUnitToLocationDistance(enemy, vRuneLocation) < GetUnitToLocationDistance(bot, vRuneLocation) + 300)
		then
			return true
		end
	end

	return false
end

function X.IsUnitAroundLocation(vLoc, nRadius)
	for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil and J.GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < 1.0 then
					return true
				end
			end
		end
	end
	return false
end

function X.GetScaledDesire(nBase, nCurrDist, nMaxDist)
	-- Local enhancement: cap desire for distant runes in late game
	local maxDesire = 0.92
	if nCurrDist > 2000 and (J.IsLateGame() or J.GetDistanceFromEnemyFountain(bot) < 5500) then
		maxDesire = 0.55
	elseif nCurrDist > 1200 then
		maxDesire = 0.85
	end
	local hp = J.GetHP(bot)
	local resDesire = Clamp(nBase * RemapValClamped(nCurrDist, 0, nMaxDist, 1, 0.5), 0, maxDesire)
	if hp < 0.6 then
		resDesire = RemapValClamped(hp, 0, 0.8, 0, resDesire)
	end
	return resDesire
end

local vGoOutLoc = nil
function X.GetGoOutLocation()
	if vGoOutLoc then return vGoOutLoc end

	if GetTeam() == TEAM_RADIANT then
		if botPos == 1 or botPos == 5 then
			local locs = { Vector(526.370239, -3893.405762, 256.000000), Vector(1999.415894, -4838.790039, 256.000000) }
			vGoOutLoc = locs[RandomInt(1, #locs)]
		elseif botPos == 2 or botPos == 3 or botPos == 4 then
			local locs = { Vector(-3456.702637, 649.725403, 256.000000), Vector(-1945.830322, 60.404663, 128.000000) }
			vGoOutLoc = locs[RandomInt(1, #locs)]
		end
	elseif GetTeam() == TEAM_DIRE then
		if botPos == 1 or botPos == 5 then
			local locs = { Vector(-1051.021973, 3384.059082, 256.000000), Vector(-2415.422119, 4641.448242, 256.000000) }
			vGoOutLoc = locs[RandomInt(1, #locs)]
		elseif botPos == 2 or botPos == 3 or botPos == 4 then
			local locs = { Vector(2734.819580, -1155.105225, 256.000000), Vector(1142.979614, -337.891663, 128.000000) }
			vGoOutLoc = locs[RandomInt(1, #locs)]
		end
	end

	return vGoOutLoc
end

function X.CouldBlink(vLocation)
	local blinkSlot = bot:FindItemSlot("item_blink")
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN
	or (bot:GetUnitName() == "npc_dota_hero_antimage" or bot:GetUnitName() == "npc_dota_hero_queenofpain")
	then
		local blink = bot:GetItemInSlot(blinkSlot)
		if bot:GetUnitName() == "npc_dota_hero_antimage" then
			blink = bot:GetAbilityByName("antimage_blink")
		end
		if bot:GetUnitName() == "npc_dota_hero_queenofpain" then
			blink = bot:GetAbilityByName("queenofpain_blink")
		end
		if J.CanCastAbility(blink) then
			local bDist = GetUnitToLocationDistance(bot, vLocation)
			local maxBlinkLoc = J.Site.GetXUnitsTowardsLocation(bot, vLocation, 1199)
			if bDist <= 500 then
				return false
			elseif bDist < 1200 then
				bot:Action_UseAbilityOnLocation(blink, vLocation)
				return true
			elseif IsLocationPassable(maxBlinkLoc) then
				bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
				return true
			end
		end
	end
	return false
end

function X.IsTeamMustSaveRune(nRune)
	if GetTeam() == TEAM_DIRE then
		return nRune == RUNE_BOUNTY_1
			or nRune == RUNE_POWERUP_2
			or (DotaTime() > 1 * 60 + 45 and nRune == RUNE_POWERUP_1)
			or (DotaTime() > 10 * 60 + 45 and nRune == RUNE_BOUNTY_2)
	else
		return nRune == RUNE_BOUNTY_2
			or nRune == RUNE_POWERUP_1
			or (DotaTime() > 1 * 60 + 45 and nRune == RUNE_POWERUP_2)
			or (DotaTime() > 10 * 60 + 45 and nRune == RUNE_BOUNTY_1)
	end
end

--------------------------------------------------------------------
-- Wisdom Rune helpers
--------------------------------------------------------------------
function X.UpdateWisdom()
	if nShrineOfWisdomTime >= 7 and nShrineOfWisdomTime % 7 == 0 and bot.rune then
		for i = 1, 5 do
			local member = GetTeamMember(i)
			if member and member == bot then
				if bot.rune.wisdom[nShrineOfWisdomTime] == nil then
					bot.rune.wisdom[nShrineOfWisdomTime] = {
						spot = {
							[TEAM_RADIANT] = { status = false, location = radiantWRLocation },
							[TEAM_DIRE] = { status = false, location = direWRLocation },
						},
						time = 0,
					}
				end
				if member.rune then member.rune.wisdom = bot.rune.wisdom end
			end

			if member and member.rune and member.rune.wisdom
			and member.rune.wisdom[nShrineOfWisdomTime]
			and bot.rune and bot.rune.wisdom
			and bot.rune.wisdom[nShrineOfWisdomTime]
			then
				for _, team in pairs({TEAM_RADIANT, TEAM_DIRE}) do
					if member.rune.wisdom[nShrineOfWisdomTime].spot[team].status == true then
						bot.rune.wisdom[nShrineOfWisdomTime].spot[team].status = true
					end
				end
			end
		end
	end
end

local nMinuteLast = 0
function X.GetCurrentWisdomTime()
	local nMinuteCurr = math.floor(DotaTime() / 60)
	if nMinuteCurr > nMinuteLast and nMinuteCurr % 7 == 0 then
		nMinuteLast = nMinuteCurr
	end
	return nMinuteLast
end

function X.GetWisdomAlly(vLocation)
	local target = nil
	local targetDistance = math.huge
	for i = 1, 5 do
		local member = GetTeamMember(i)
		if J.IsValidHero(member) and not J.IsDoingTormentor(member) then
			local memberDistance = GetUnitToLocationDistance(member, vLocation)
			if memberDistance < targetDistance then
				target = member
				targetDistance = memberDistance
			end
		end
	end
	return target
end

function X.GetWisdomDesire(vLocation)
	if (J.IsDefending(bot) and botActiveModeDesire > 0.7)
	or J.IsInTeamFight(bot, 1600) then
		return 0
	end

	local nDesire = 0
	local botLevel = bot:GetLevel()
	local distance = GetUnitToLocationDistance(bot, vLocation)

	if botLevel < 12 then
		nDesire = RemapValClamped(distance, 6400, 3200, 0.75, 0.95)
	elseif botLevel < 18 then
		nDesire = RemapValClamped(distance, 6400, 3200, 0.65, 0.95)
	elseif botLevel < 25 then
		nDesire = RemapValClamped(distance, 6400, 2400, 0.55, 0.95)
	elseif botLevel < 30 then
		nDesire = RemapValClamped(distance, 6400, 2400, 0.45, 0.95)
	end

	return nDesire
end

function X.GetShrineOfWisdomTeam()
	local dist1 = GetUnitToLocationDistance(bot, radiantWRLocation)
	local dist2 = GetUnitToLocationDistance(bot, direWRLocation)

	if GetTeam() == TEAM_RADIANT then
		if dist1 < dist2 then
			return TEAM_RADIANT
		else
			local hTower = GetTower(GetOpposingTeam(), TOWER_BOT_1)
			if hTower == nil or not hTower:IsAlive() or dist2 <= 1600 then
				return TEAM_DIRE
			end
		end
	elseif GetTeam() == TEAM_DIRE then
		if dist1 > dist2 then
			return TEAM_DIRE
		else
			local hTower = GetTower(GetOpposingTeam(), TOWER_TOP_1)
			if hTower == nil or not hTower:IsAlive() or dist1 <= 1600 then
				return TEAM_RADIANT
			end
		end
	end

	return nil
end
