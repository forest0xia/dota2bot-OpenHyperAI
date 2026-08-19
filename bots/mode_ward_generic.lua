if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return
end

local X = {}

local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local W = require(GetScriptDirectory() ..'/FunLib/aba_ward_utility')
local Customize = require(GetScriptDirectory()..'/Customize/general')
Customize.ThinkLess = Customize.Enable and Customize.ThinkLess or 1

local nObserverWardCastRange = 500
local nSentryWardCastRange = 500

local ObserverWard = nil
local SentryWard = nil

local hTargetSpot = nil
local fLastWardPlantTime = -math.huge

-- Active dewarding state
local bDewarding = false
local hDewardWard = nil
local hDewardLoc = nil
local fLastDewardPlantTime = -math.huge

-- Whether the current hTargetSpot is a sentry spot (else an observer spot), so
-- Think plants the matching ward type when the bot carries both.
local bTargetIsSentry = false

function GetDesire()
	if J.GetPosition(bot) <= 3 then return false end
	-- local cacheKey = 'GetWardDesire'..tostring(bot:GetPlayerID())
	-- local cachedVar = J.Utils.GetCachedVars(cacheKey, 0.6 * (1 + Customize.ThinkLess))
	-- if DotaTime() > 30 and cachedVar ~= nil then return cachedVar end
	local res = GetDesireHelper()
	-- J.Utils.SetCachedVars(cacheKey, res)
	return RemapValClamped(J.GetHP(bot) * res, 0, 1, BOT_MODE_DESIRE_NONE, res)
end
function GetDesireHelper()
    if not X.IsSuitableToWard() then
        return BOT_MODE_DESIRE_NONE
    end

	local enemiesAtAncient = J.Utils.CountEnemyHeroesNear(GetAncient(GetTeam()):GetLocation(), 3200)
    if enemiesAtAncient >= 1 then
        return BOT_MODE_DESIRE_NONE
    end

    -- Detect ward items (a dispenser doubles as both observer and sentry).
    ObserverWard = nil
    SentryWard = nil
    for i = 0, 5 do
        local hItem = bot:GetItemInSlot(i)
        if hItem then
            local sItemName = hItem:GetName()
            if sItemName == 'item_ward_observer' then
                ObserverWard = hItem
            elseif sItemName == 'item_ward_sentry' then
                SentryWard = hItem
            elseif sItemName == 'item_ward_dispenser' then
                ObserverWard = hItem
                SentryWard = hItem
            end
        end
    end

    local bSafe = #bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE) == 0

    -- 1) TOP PRIORITY: destroy a visible enemy ward (revealed by our detection).
    if bSafe then
        local hVisibleWard = W.GetNearbyEnemyWard(bot, 1200)
        if hVisibleWard ~= nil then
            hTargetSpot = nil
            bDewarding = true
            hDewardWard = hVisibleWard
            hDewardLoc = hVisibleWard:GetLocation()
            return BOT_MODE_DESIRE_ABSOLUTE
        end
    end

    -- 2) Observer placement -- primary vision, territory-aware (aggressive when
    --    winning, defensive when losing); GetClosestObserverWardSpot biases the side.
    if J.CanCastAbility(ObserverWard) then
        local spot = W.GetClosestObserverWardSpot(bot, W.GetAvailabeObserverWardSpots(bot))
        if spot and (not X.IsEnemyCloserToWardLocation(spot.location) or J.IsRealInvisible(bot)) then
            if DotaTime() < 0 and DotaTime() > (J.IsModeTurbo() and -45 or -60) then
                hTargetSpot = spot
                bDewarding = false
                bTargetIsSentry = false
                return BOT_MODE_DESIRE_ABSOLUTE
            end
            if DotaTime() > fLastWardPlantTime + 1.0 and GetUnitToLocationDistance(bot, spot.location) <= 3200 then
                hTargetSpot = spot
                bDewarding = false
                bTargetIsSentry = false
                return BOT_MODE_DESIRE_VERYHIGH
            end
        end
    end

    -- 3) Sentry placement (detection -- high priority). Prefer dropping on a suspected
    --    enemy ward spot to deny their vision (blind-deward); otherwise place
    --    defensively to guard our vision and catch invisible units.
    if J.CanCastAbility(SentryWard) then
        if bSafe then
            local hDewardSpot = W.GetClosestDewardSpot(bot, 1200)
            if hDewardSpot ~= nil then
                hTargetSpot = nil
                bDewarding = true
                hDewardWard = nil
                hDewardLoc = hDewardSpot.location
                return BOT_MODE_DESIRE_VERYHIGH
            end
        end

        local spot = W.GetClosestSentryWardSpot(bot, W.GetPossibleSentryWardSpots(bot))
        if spot and (not X.IsEnemyCloserToWardLocation(spot.location) or J.IsRealInvisible(bot)) then
            if DotaTime() > fLastWardPlantTime + 1.0 and GetUnitToLocationDistance(bot, spot.location) <= 3200 then
                hTargetSpot = spot
                bDewarding = false
                bTargetIsSentry = true
                return BOT_MODE_DESIRE_VERYHIGH
            end
        end
    end

    -- 4) Grace: stay a few seconds after a blind-deward sentry to finish the reveal+kill.
    if bDewarding and DotaTime() < fLastDewardPlantTime + 4.0 then
        return BOT_MODE_DESIRE_HIGH
    end

    bDewarding = false
    return BOT_MODE_DESIRE_NONE
end

function Think()
	if J.CanNotUseAction(bot) then return end
	if J.Utils.IsBotThinkingMeaningfulAction(bot, Customize.ThinkLess, "ward") then return end

	if bDewarding then
		-- Prefer attacking a revealed enemy ward; re-acquire in case a fresh one showed.
		local hWard = hDewardWard
		if hWard == nil or not J.IsValid(hWard) then
			hWard = W.GetNearbyEnemyWard(bot, 1200)
		end
		if hWard ~= nil and J.IsValid(hWard) then
			if GetUnitToUnitDistance(bot, hWard) <= bot:GetAttackRange() + 100 then
				bot:Action_AttackUnit(hWard, true)
			else
				bot:Action_MoveToLocation(hWard:GetLocation())
			end
			return
		end

		-- No ward visible yet: go to the suspected spot and drop a sentry to reveal it.
		if hDewardLoc then
			if GetUnitToLocationDistance(bot, hDewardLoc) <= nSentryWardCastRange then
				if SentryWard and J.CanCastAbility(SentryWard) then
					if SentryWard:GetName() == 'item_ward_sentry' then
						bot:Action_UseAbilityOnLocation(SentryWard, hDewardLoc)
						fLastDewardPlantTime = DotaTime()
					elseif SentryWard:GetToggleState() == true then
						bot:Action_UseAbilityOnEntity(SentryWard, bot)
						return
					else
						bot:Action_UseAbilityOnLocation(SentryWard, hDewardLoc)
						fLastDewardPlantTime = DotaTime()
					end
				end
			else
				bot:Action_MoveToLocation(hDewardLoc)
			end
			return
		end
	end

	if hTargetSpot then
		if not bTargetIsSentry and ObserverWard and J.CanCastAbility(ObserverWard) then
			if GetUnitToLocationDistance(bot, hTargetSpot.location) <= nObserverWardCastRange then
				if ObserverWard:GetName() == 'item_ward_observer' then
					bot:Action_UseAbilityOnLocation(ObserverWard, hTargetSpot.location)
				else
					if ObserverWard:GetToggleState() == false then
						bot:Action_UseAbilityOnEntity(ObserverWard, bot)
						return
					else
						bot:Action_UseAbilityOnLocation(ObserverWard, hTargetSpot.location)
					end
				end

				hTargetSpot.plant_time_obs = DotaTime()
				return
			else
				bot:Action_MoveToLocation(hTargetSpot.location)
				return
			end
		end

		if SentryWard and J.CanCastAbility(SentryWard) then
			if GetUnitToLocationDistance(bot, hTargetSpot.location) <= nSentryWardCastRange then
				local fLength = 0
				if W.IsOtherWardClose(hTargetSpot.location, 'npc_dota_observer_wards', 300, true, false) then
					fLength = 30
				end

				if SentryWard:GetName() == 'item_ward_sentry' then
					bot:Action_UseAbilityOnLocation(SentryWard, hTargetSpot.location + RandomVector(fLength))
				else
					if SentryWard:GetToggleState() == true then
						bot:Action_UseAbilityOnEntity(SentryWard, bot)
						return
					else
						bot:Action_UseAbilityOnLocation(SentryWard, hTargetSpot.location + RandomVector(fLength))
					end
				end

				hTargetSpot.plant_time_sentry = DotaTime()
				return
			else
				bot:Action_MoveToLocation(hTargetSpot.location)
				return
			end
		end
	end
end

function X.IsSuitableToWard()
	local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

	local botActiveMode = bot:GetActiveMode()
    local botActiveModeDesire = bot:GetActiveModeDesire()

	if (J.IsRetreating(bot) and botActiveModeDesire > 0.75)
	or (botActiveMode == BOT_MODE_RUNE and DotaTime() > 0)
	or (botActiveMode == BOT_MODE_DEFEND_ALLY)
	or (nEnemyHeroes ~= nil and #nEnemyHeroes >= 1 and X.IsIBecameTheTarget(nEnemyHeroes))
    or J.IsDefending(bot)
	or J.IsGoingOnSomeone(bot)
	or bot:WasRecentlyDamagedByAnyHero(5.0)
	then
		return false
	end

	return true
end

function X.IsIBecameTheTarget(unitList)
	for _, unit in pairs(unitList) do
		if J.IsValid(unit)
        and not J.IsSuspiciousIllusion(unit)
		and unit:GetAttackTarget() == bot
		then
			return true
		end
	end

	return false
end

function X.IsEnemyCloserToWardLocation(vLocation)
	for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if  dInfo ~= nil
				and dInfo.time_since_seen < 3.0
				and J.GetDistance(dInfo.location, vLocation) < GetUnitToLocationDistance(bot, vLocation)
				then
					local nAllyHeroes = J.GetAlliesNearLoc(vLocation, 1200)
					local nEnemyHeroes = J.GetEnemiesNearLoc(vLocation, 1200)
					if #nEnemyHeroes > #nAllyHeroes then
						return true
					end
				end
			end
		end
	end

	return false
end