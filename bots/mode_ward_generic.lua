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
local nMaxDistanceToGoPlaceWard = 3200
local nMinObserverSeparation = 1600 * 2
local nMinSentrySeparation = 1200 * 2

local ObserverWard = nil
local SentryWard = nil

local hTargetSpot = nil
local fLastWardPlantTime = -math.huge

-- Which ward type the current hTargetSpot was selected for, so Think plants the matching
-- type instead of letting the observer branch hijack a sentry target (or vice versa).
local bTargetIsSentry = false

function GetDesire()
	-- Every bot (cores included) can ward now, not just supports.
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

    -- 1) Observer placement (primary vision) -- head to the nearest available observer
    --    spot. Observers and sentries are placed independently (no pairing).
    if J.CanCastAbility(ObserverWard) then
        local spot = W.GetClosestObserverWardSpot(bot, W.GetAvailabeObserverWardSpots(bot))
        if spot and (not X.IsEnemyCloserToWardLocation(spot.location) or J.IsRealInvisible(bot)) then
            if DotaTime() > fLastWardPlantTime + 1.0 and GetUnitToLocationDistance(bot, spot.location) <= nMaxDistanceToGoPlaceWard then
                hTargetSpot = spot
                bTargetIsSentry = false
                return BOT_MODE_DESIRE_VERYHIGH
            end
        end
    end

    -- 2) Sentry placement (detection) -- head to the nearest available sentry spot.
    if J.CanCastAbility(SentryWard) then
        local spot = W.GetClosestSentryWardSpot(bot, W.GetPossibleSentryWardSpots(bot))
        if spot and (not X.IsEnemyCloserToWardLocation(spot.location) or J.IsRealInvisible(bot)) then
            if DotaTime() > fLastWardPlantTime + 1.0 and GetUnitToLocationDistance(bot, spot.location) <= nMaxDistanceToGoPlaceWard then
                hTargetSpot = spot
                bTargetIsSentry = true
                return BOT_MODE_DESIRE_VERYHIGH
            end
        end
    end

    return BOT_MODE_DESIRE_NONE
end

function Think()
	if J.CanNotUseAction(bot) then return end
	if J.Utils.IsBotThinkingMeaningfulAction(bot, Customize.ThinkLess, "ward") then return end
	if hTargetSpot then
		if not bTargetIsSentry and ObserverWard and J.CanCastAbility(ObserverWard) then
			if GetUnitToLocationDistance(bot, hTargetSpot.location) <= nObserverWardCastRange then
				if W.IsOtherWardClose(hTargetSpot.location, 'npc_dota_observer_wards', nMinObserverSeparation, true, false) then
					hTargetSpot = nil
					return
				end
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
				fLastWardPlantTime = DotaTime()
				return
			else
				bot:Action_MoveToLocation(hTargetSpot.location)
				return
			end
		end

		if bTargetIsSentry and SentryWard and J.CanCastAbility(SentryWard) then
			if GetUnitToLocationDistance(bot, hTargetSpot.location) <= nSentryWardCastRange then
				if W.IsOtherWardClose(hTargetSpot.location, 'npc_dota_sentry_wards', nMinSentrySeparation, true, false) then
					hTargetSpot = nil
					return
				end
				if SentryWard:GetName() == 'item_ward_sentry' then
					bot:Action_UseAbilityOnLocation(SentryWard, hTargetSpot.location + RandomVector(5))
				else
					if SentryWard:GetToggleState() == true then
						bot:Action_UseAbilityOnEntity(SentryWard, bot)
						return
					else
						bot:Action_UseAbilityOnLocation(SentryWard, hTargetSpot.location + RandomVector(5))
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