local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local bot = GetBot()

local MAX_DIST = 1600
local minute = 0
local second = 0
local ClosestRune = -1
local ClosestDistance = -1
local nRuneStatus = -1

local botActiveMode = -1
local bBottle = false

local nRuneList = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2,
}

local radiantWRLocation = Vector(-7988.583008, 423.058716, 256.000000)
local direWRLocation = Vector(8244.062500, -1026.568848, 256.000000)
local wisdomRuneSpots = {
	[1] = radiantWRLocation,
	[2] = direWRLocation,
}
local wisdomRuneInfo = {0, 0, false} -- time, loc, did
local timeInMin = 0

function GetDesire()
	local cacheKey = 'GetRuneDesire'..tostring(bot:GetPlayerID())
	local cachedVar = J.Utils.GetCachedVars(cacheKey, 1)
	if cachedVar ~= nil then return cachedVar end
	local res = GetDesireHelper()
	J.Utils.SetCachedVars(cacheKey, res)
	return res
end
function GetDesireHelper()
    if not bot:IsAlive()
	or (DotaTime() > 2 * 60 and DotaTime() < 6 * 60 and GetUnitToLocationDistance(bot, GetRuneSpawnLocation(RUNE_POWERUP_2)) < 80)
	then
        return 0
    end

    botActiveMode = bot:GetActiveMode()
	bBottle = J.HasItem(bot, 'item_bottle')

	-- 如果在打高地 就别撤退去干别的
	if J.Utils.IsTeamPushingSecondTierOrHighGround(bot) then
		return BOT_MODE_DESIRE_NONE
	end

    if bot:IsInvulnerable() and J.GetHP(bot) > 0.95 and bot:DistanceFromFountain() < 100 then
        return BOT_MODE_DESIRE_ABSOLUTE
    end

	-- Wisdom Rune
	if bot:GetLevel() < 30 then
		timeInMin = X.GetMulTime()
		X.UpdateWisdom()
		if DotaTime() >= 7 * 60
		and not J.IsMeepoClone(bot)
		and not bot:HasModifier('modifier_arc_warden_tempest_double') then
			if DotaTime() < wisdomRuneInfo[1] + 3.5 then
				if not bot:WasRecentlyDamagedByAnyHero(3.0) then --back
					return BOT_MODE_DESIRE_ABSOLUTE
				end
				-- if GetUnitToLocationDistance(bot, wisdomRuneSpots[wisdomRuneInfo[2]]) < 80 then
				-- 	return 0
				-- end
			else
				wisdomRuneInfo[1] = 0
				wisdomRuneInfo[3] = false
			end


			local tEnemyTowers = bot:GetNearbyTowers(700, true)
			local tEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
			if (#tEnemyTowers > 0 and bot:WasRecentlyDamagedByTower(1.0) and J.GetHP(bot) < 0.3)
			or (#tEnemyHeroes > 0 and not J.IsRealInvisible(bot))
			then
				return 0
			end

			local runeSpot = X.GetWisdomRuneSpot()

			if runeSpot ~= nil
			and bot.wisdom ~= nil
			and bot.wisdom[timeInMin][runeSpot] == false
			and bot == X.GetWisdomAlly(wisdomRuneSpots[runeSpot]) then
				wisdomRuneInfo[2] = runeSpot
				wisdomRuneInfo[3] = true
				return X.GetWisdomDesire(wisdomRuneSpots[runeSpot])
			end
		end
	else
		wisdomRuneInfo[3] = false
	end

	if (bot:HasModifier("modifier_arc_warden_tempest_double"))
	or (DotaTime() > -10 and bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE)
	then
		return BOT_MODE_DESIRE_NONE
	end

    minute = math.floor(DotaTime() / 60)
    second = DotaTime() % 60

	ClosestRune, ClosestDistance = X.GetBotClosestRune()

    if not X.IsSuitableToPickRune(ClosestRune) then
        return BOT_MODE_DESIRE_NONE
    end

    if DotaTime() < 0 and not bot:WasRecentlyDamagedByAnyHero(10.0)
    then
        local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
        if #nEnemyHeroes <= 1 then
            return BOT_MODE_DESIRE_MODERATE
        end
    end

    if J.IsLateGame() and X.IsUnitAroundLocation(GetAncient(GetTeam()):GetLocation(), 2800) then
        MAX_DIST = 900
    else
        MAX_DIST = 1600
    end

	if ClosestRune ~= -1 and ClosestDistance < 6000 then
		local botPos = J.GetPosition(bot)
		local nRuneType = GetRuneType(ClosestRune)

        if ClosestRune == RUNE_BOUNTY_1 or ClosestRune == RUNE_BOUNTY_2 then
			nRuneStatus = GetRuneStatus(ClosestRune)

            if nRuneStatus == RUNE_STATUS_AVAILABLE
			and (X.IsTeamMustSaveRune(ClosestRune) or DotaTime() > 585)
			then
				if ((botPos == 1 or botPos == 3) and J.IsInLaningPhase() and ClosestDistance > 2000)
				or X.IsEnemyPickRune(ClosestRune)
				then
					return BOT_MODE_DESIRE_NONE
				end

                return X.GetScaledDesire(BOT_MODE_DESIRE_HIGH, ClosestDistance, 3500)
            elseif nRuneStatus == RUNE_STATUS_UNKNOWN
				and ClosestDistance <= MAX_DIST * 1.5
                and DotaTime() > 3 * 60 + 50
                and ((minute % 4 == 0) or (minute % 4 == 3 and second > 45))
            then
				if J.IsCore(bot) and J.IsInLaningPhase() and ClosestDistance > 2000 then
					return BOT_MODE_DESIRE_NONE
				end

                return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, ClosestDistance, MAX_DIST)
            elseif nRuneStatus == RUNE_STATUS_MISSING
				and ClosestDistance <= MAX_DIST * 1.5
                and DotaTime() > 3 * 60
                and (minute % 4 == 3 and second > 52)
            then
				if J.IsCore(bot) and J.IsInLaningPhase() and ClosestDistance > 2000 then
					return BOT_MODE_DESIRE_NONE
				end

                return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, ClosestDistance, MAX_DIST * 2)
            end
        else
			nRuneStatus = GetRuneStatus(ClosestRune)

            if nRuneStatus == RUNE_STATUS_AVAILABLE then
				if X.IsEnemyPickRune(ClosestRune) then
					return BOT_MODE_DESIRE_NONE
				end

				if nRuneType == RUNE_WATER and (bBottle or (J.GetHP(bot) < 0.6) or J.GetMP(bot) < 0.5) then
					return X.GetScaledDesire(BOT_MODE_DESIRE_HIGH, ClosestDistance, 3200)
				else
					if nRuneType == RUNE_WATER and not bBottle then
						return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, ClosestDistance, MAX_DIST)
					else
						if X.IsPowerRune(ClosestRune) and J.IsCore(bot) then
							return X.GetScaledDesire(BOT_MODE_DESIRE_HIGH, ClosestDistance, MAX_DIST * 2.5)
						else
							return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, ClosestDistance, MAX_DIST * 2.5)
						end
					end
				end
            elseif nRuneStatus == RUNE_STATUS_UNKNOWN
                and DotaTime() > 113
            then
				return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, ClosestDistance, MAX_DIST)
            elseif nRuneStatus == RUNE_STATUS_MISSING
                and DotaTime() > 60
                and (minute % 2 == 1 and second > 53)
            then
                return X.GetScaledDesire(BOT_MODE_DESIRE_MODERATE, ClosestDistance, MAX_DIST)
            end
        end
    end

    return 0
end

local Bottle = nil
function OnStart()
	local bottle_slot = bot:FindItemSlot('item_bottle')
	if bot:GetItemSlotType(bottle_slot) == ITEM_SLOT_TYPE_MAIN then
		Bottle = bot:GetItemInSlot(bottle_slot)
	end
end

function OnEnd()
	Bottle = nil
end

function Think()
    if bot:IsInvulnerable()
    and J.GetHP(bot) > 0.95
    and bot:DistanceFromFountain() < 100 then
        bot:Action_MoveToLocation(bot:GetLocation() + RandomVector(500))
        return
    end

    if J.CanNotUseAction(bot)
	or bot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_RUNE
	or (GetGameState() ~= GAME_STATE_PRE_GAME and GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS)
	then
        return
    end

	-- Wisdom Rune
	if wisdomRuneInfo[3] then
		local vWisdomSpot = wisdomRuneSpots[wisdomRuneInfo[2]]
		local nInRangeEnemy = J.GetEnemiesNearLoc(vWisdomSpot, 1600)
		if J.IsValidHero(nInRangeEnemy[1]) and (not nInRangeEnemy[1]:IsBot() or (GetUnitToLocationDistance(nInRangeEnemy[1], vWisdomSpot) < GetUnitToLocationDistance(bot, vWisdomSpot)))
		then
			bot.wisdom[timeInMin][wisdomRuneInfo[2]] = true
		end

		if GetUnitToLocationDistance(bot, vWisdomSpot) < 75 then
			if bot.wisdom[timeInMin][wisdomRuneInfo[2]] == false then
				wisdomRuneInfo[1] = DotaTime()
			end
			bot.wisdom[timeInMin][wisdomRuneInfo[2]] = true
		end

		bot:Action_MoveDirectly(vWisdomSpot)
		return
	end

    if DotaTime() < 0 then
		if J.IsModeTurbo() and DotaTime() < -50 then
			return
		end

        if DotaTime() < -25 then
            local vGoOutLocation = X.GetGoOutLocation()

            if GetUnitToLocationDistance(bot, vGoOutLocation) > 500 then
                bot:Action_MoveToLocation(vGoOutLocation)
                return
            end

            bot:Action_ClearActions(false)
            return
        end

        if GetTeam() == TEAM_RADIANT
		then
			if bot:GetAssignedLane() == LANE_BOT
			then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2) + RandomVector(50))
				return
            else
                bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_POWERUP_1) + RandomVector(50))
				return
			end
		else
			if bot:GetAssignedLane() == LANE_TOP
			then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1) + RandomVector(50))
				return
            else
                bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_POWERUP_2) + RandomVector(50))
				return
			end
		end
    end

    local botAttackRange = bot:GetAttackRange() + 150
    if botAttackRange > 1400 then botAttackRange = 1400 end
    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), botAttackRange)
	nRuneStatus = GetRuneStatus(ClosestRune)

	if nRuneStatus == RUNE_STATUS_AVAILABLE then
		if J.CanCastAbility(Bottle) and ClosestDistance < 1200
		then
			local nCharges = Bottle:GetCurrentCharges()
			if nCharges > 0
			and (bot:GetHealth() < bot:GetMaxHealth() or bot:GetMana() < bot:GetMaxMana())
			then
				bot:Action_UseAbility(Bottle)
				return
			end
		end

		if ClosestDistance > 50 then
			if J.IsValidHero(nEnemyHeroes[1])
            and bot:GetEstimatedDamageToTarget(false, nEnemyHeroes[1], 5.0, DAMAGE_TYPE_ALL) > nEnemyHeroes[1]:GetEstimatedDamageToTarget(false, bot, 5.0, DAMAGE_TYPE_ALL) * 1.5
            and bot:GetHealth() > 500
			then
				bot:Action_AttackUnit(nEnemyHeroes[1], true)
				return
			end

			if X.CouldBlink(GetRuneSpawnLocation(ClosestRune)) then return end

			bot:Action_MoveToLocation(GetRuneSpawnLocation(ClosestRune) + RandomVector(25))
			return
		else
			bot:Action_PickUpRune(ClosestRune)
			return
		end
	else
        if J.IsValidHero(nEnemyHeroes[1])
        and bot:GetEstimatedDamageToTarget(false, nEnemyHeroes[1], 5.0, DAMAGE_TYPE_ALL) > nEnemyHeroes[1]:GetEstimatedDamageToTarget(false, bot, 5.0, DAMAGE_TYPE_ALL) * 1.5
        and bot:GetHealth() > 500
        then
            bot:Action_AttackUnit(nEnemyHeroes[1], true)
            return
        end

		bot:Action_MoveToLocation(GetRuneSpawnLocation(ClosestRune))
		return
	end
 end

function X.IsSuitableToPickRune(nRuneLoc)
    if X.IsNearRune(bot) then return true end

	local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

	if (J.IsRetreating(bot) and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH)
    or (#nEnemyHeroes >= 1 and X.IsIBecameTheTarget(nEnemyHeroes))
	or (nRuneLoc ~= nil and J.IsEnemyHeroAroundLocation(GetRuneSpawnLocation(nRuneLoc), 1200))
    or (bot:WasRecentlyDamagedByAnyHero(3.0) and J.IsRetreating(bot))
    or (GetUnitToUnitDistance(bot, GetAncient(GetTeam())) < 2500 and DotaTime() > 0)
    or GetUnitToUnitDistance(bot, GetAncient(GetOpposingTeam())) < 4000
    or bot:HasModifier('modifier_item_shadow_amulet_fade')
	then
		return false
	end

	return true
end

function X.IsNearRune(hUnit)
	for _, rune in pairs(nRuneList) do
		local rLoc = GetRuneSpawnLocation(rune)
		if GetUnitToLocationDistance(hUnit, rLoc) <= 600 then
			return true
		end
	end

	return false
end

function X.IsIBecameTheTarget(hUnitList)
	for _, unit in pairs(hUnitList) do
        if J.IsValid(unit)
		and ((unit:GetAttackTarget() == bot and J.IsInRange(bot, unit, 700))
			or (J.IsInRange(bot, unit, unit:GetAttackRange() + 300) and J.IsChasingTarget(unit, bot)))
		then
			return true
		end
	end

	return false
end

local function IsBountyRune(r)
    return r == RUNE_BOUNTY_1 or r == RUNE_BOUNTY_2
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

function X.GetBotClosestRune()
    local cDist = 100000
	local cRune = -1

	for _, rune in pairs(nRuneList) do
		if not (J.IsCore(bot) and DotaTime() > 170 and IsBountyRune(rune)) then
			local rLoc = GetRuneSpawnLocation(rune)
			if X.IsTheClosestOne(rLoc, rune)
			and not X.IsPingedByHumanPlayer(rLoc, 1200)
			and not X.IsMissing(rune)
			and not X.IsTherePosition(1, rune, 1600)
			and not X.IsTherePosition(2, rune, 1600)
			then
				local dist = GetUnitToLocationDistance(bot, rLoc)
				if dist < cDist then
					cDist = dist
					cRune = rune
				end
			end
		end
	end

	return cRune, cDist
end

function X.IsTheClosestOne(vLocation, nRuneLoc)
    local minDist = GetUnitToLocationDistance(bot, vLocation)
	local closest = bot
	local nRuneType = GetRuneType(nRuneLoc)

	local botPos = J.GetPosition(bot)

	if botPos == 1 and (J.IsMidGame() or J.IsLateGame()) and nRuneType == RUNE_DOUBLEDAMAGE
	and GetUnitToLocationDistance(bot, vLocation) <= 3500
	then
		return true
	end

	if botPos == 2 and nRuneType == RUNE_ARCANE
	and GetUnitToLocationDistance(bot, vLocation) <= 3500
	then
		return true
	end

	if J.HasItem(bot, 'item_bottle') and GetUnitToLocationDistance(bot, vLocation) <= 3500 then
		return true
	end

    for i = 1, #GetTeamPlayers( GetTeam() ) do
        local member = GetTeamMember(i)
        if member ~= nil and member:IsAlive() then
			local dist = GetUnitToLocationDistance(member, vLocation)
			if dist < minDist then
				minDist = dist
				closest = member
			end
        end
    end

	return closest == bot
end

function X.IsTherePosition(nPos, nRuneLoc, nRadius)
	if not X.IsPowerRune(nRuneLoc) and DotaTime() > 6 * 60 then return false end
	local rLoc = GetRuneSpawnLocation(nRuneLoc)

	for i = 1, #GetTeamPlayers( GetTeam() ) do
        local member = GetTeamMember(i)
        if member ~= nil and member:IsAlive() and bot ~= member
		and J.GetPosition(member) == nPos then
            if GetUnitToLocationDistance(member, rLoc) <= nRadius then
				return true
			end
        end
    end

	return false
end

-- When using Danger Ping ('X' in map)
local pingTimeDelta = 15
function X.IsPingedByHumanPlayer(vLocation, nRadius)
    local thisBotDistFromLocation = GetUnitToLocationDistance(bot, vLocation)
    for i = 1, #GetTeamPlayers( GetTeam() ) do
        local member = GetTeamMember(i)
        if member ~= nil and member:IsAlive() and not member:IsBot() then
            local ping = member:GetMostRecentPing()
            if ping ~= nil then
                if not ping.normal_ping
                and J.GetDistance(ping.location, vLocation) <= 600
                and GameTime() - ping.time < pingTimeDelta
                and thisBotDistFromLocation < nRadius
                and botActiveMode == BOT_MODE_RUNE
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
    nRuneStatus = GetRuneStatus(nRune)
	if second < 52 and nRuneStatus == RUNE_STATUS_MISSING then
		return true
	end

    return false
end

function X.IsEnemyPickRune(nRune)
	local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
	local vRuneLocation = GetRuneSpawnLocation(nRune)

	if GetUnitToLocationDistance(bot, vRuneLocation) < 600 then return false end

	for _, enemy in pairs(nEnemyHeroes) do
        if J.IsValidHero(enemy)
        and (enemy:IsFacingLocation(vRuneLocation, 30) or enemy:IsFacingLocation(bot:GetLocation(), 30) or GetUnitToLocationDistance(enemy, vRuneLocation) < 600)
        and (GetUnitToLocationDistance(enemy, vRuneLocation) < GetUnitToLocationDistance(bot, vRuneLocation) + 300)
        then
            return true
        end
	end

	return false
end

function X.GetScaledDesire(nBase, nCurrDist, nMaxDist)
    return Clamp(nBase + RemapValClamped(nCurrDist, nMaxDist, 0, 0, 1 - nBase), 0, 0.95)
end

function X.GetGoOutLocation()
	local nLane = bot:GetAssignedLane()
	local vLocation = J.Site.GetXUnitsTowardsLocation(GetTower(GetTeam(),TOWER_MID_2),GetTower(GetTeam(),TOWER_MID_1):GetLocation(),300)

	if nLane == LANE_BOT then
		vLocation = J.Site.GetXUnitsTowardsLocation(GetTower(GetTeam(),TOWER_BOT_2),GetTower(GetTeam(),TOWER_BOT_1):GetLocation(),300)
	elseif nLane == LANE_TOP then
		vLocation = J.Site.GetXUnitsTowardsLocation(GetTower(GetTeam(),TOWER_TOP_2),GetTower(GetTeam(),TOWER_TOP_1):GetLocation(),300)
	end

	return vLocation
end

function X.CouldBlink(vLocation)
	local blinkSlot = bot:FindItemSlot("item_blink")

	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN
	   or (bot:GetUnitName() == "npc_dota_hero_antimage" or bot:GetUnitName() == "npc_dota_hero_queenofpain")
	then
		local blink = bot:GetItemInSlot(blinkSlot)
		if bot:GetUnitName() == "npc_dota_hero_antimage"
		then
			blink = bot:GetAbilityByName( "antimage_blink" )
		end

        if bot:GetUnitName() == "npc_dota_hero_queenofpain"
		then
			blink = bot:GetAbilityByName( "queenofpain_blink" )
		end

		if J.CanCastAbility(blink)
		then
			local bDist = GetUnitToLocationDistance(bot,vLocation)
			local maxBlinkLoc = J.Site.GetXUnitsTowardsLocation(bot, vLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
			then
					bot:Action_UseAbilityOnLocation(blink, vLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
			then
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

-- Wisdom Rune
function X.UpdateWisdom()
	-- todo: see if a human has been at a spot within time, so don't go there and waste time
	if timeInMin >= 7 and timeInMin % 7 == 0 then
		for i = 1, #GetTeamPlayers( GetTeam() ) do
			local member = GetTeamMember(i)
			-- init
			if member ~= nil and member == bot then
				if bot.wisdom == nil then bot.wisdom = {} end
				if bot.wisdom[timeInMin] == nil then
					bot.wisdom[timeInMin] = { [1] = false, [2] = false } -- radi, dire
				end

				member.wisdom = bot.wisdom
			end

			-- update
			if member ~= nil
			and bot.wisdom ~= nil and bot.wisdom[timeInMin] ~= nil
			and member.wisdom ~= nil and member.wisdom[timeInMin] ~= nil
			then
				if member.wisdom[timeInMin][1] == true and bot.wisdom[timeInMin][1] == false then
					bot.wisdom[timeInMin][1] = true
				end

				if member.wisdom[timeInMin][2] == true and bot.wisdom[timeInMin][2] == false then
					bot.wisdom[timeInMin][2] = true
				end
			end
		end
	end
end

local lastMin = 0
function X.GetMulTime()
	local currTime = math.floor(DotaTime() / 60)
	if currTime > lastMin and currTime % 7 == 0 then
		lastMin = currTime
	end
	return lastMin
end

function X.GetWisdomAlly(vLoc)
	local target = nil
	local score = math.huge
	for i = 1, #GetTeamPlayers( GetTeam() ) do
		local member = GetTeamMember(i)
		if member ~= nil and member:IsAlive() and not J.IsDoingTormentor(member) then
			local dist = GetUnitToLocationDistance(member, vLoc)
			if dist < score then
				target = member
				score = dist
			end
		end
	end

	return target
end

function X.GetWisdomDesire(vWisdomLoc)
	if (J.IsDefending(bot) and bot:GetActiveModeDesire() > 0.7)
	or J.IsInTeamFight(bot, 1600) then
		return 0
	end

	local nDesire = 0
	local botLevel = bot:GetLevel()
	local distFromLoc = GetUnitToLocationDistance(bot, vWisdomLoc)
	if botLevel < 12 then
		nDesire = RemapValClamped(distFromLoc, 6400, 3200, 0.75, 0.95)
	elseif botLevel < 18 then
		nDesire = RemapValClamped(distFromLoc, 6400, 3200, 0.5, 0.95)
	elseif botLevel < 25 then
		nDesire = RemapValClamped(distFromLoc, 5800, 1600, 0.25, 0.95)
	elseif botLevel < 30 then
		nDesire = RemapValClamped(distFromLoc, 5800, 1600, 0.1, 0.95)
	end

	return nDesire
end

function X.GetWisdomRuneSpot()
	if GetTeam() == TEAM_RADIANT then
		local dist1 = GetUnitToLocationDistance(bot, radiantWRLocation)
		local dist2 = GetUnitToLocationDistance(bot, direWRLocation)
		if dist1 < dist2 then
			return 1
		else
			local tier_1_tower = GetTower(GetOpposingTeam(), TOWER_BOT_1) -- don't feed
			if tier_1_tower == nil then
				return 2
			end
		end

		return 1
	elseif GetTeam() == TEAM_DIRE then
		local dist1 = GetUnitToLocationDistance(bot, radiantWRLocation)
		local dist2 = GetUnitToLocationDistance(bot, direWRLocation)
		if dist1 > dist2 then
			return 2
		else
			local tier_1_tower = GetTower(GetOpposingTeam(), TOWER_TOP_1) -- don't feed
			if tier_1_tower == nil then
				return 1
			end
		end

		return 2
	end

	return nil
end