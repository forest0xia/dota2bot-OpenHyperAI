if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return
end

local X = {}

local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local W = require(GetScriptDirectory() ..'/FunLib/aba_ward_utility')

local nObserverWardCastRange = 500
local nSentryWardCastRange = 500

local ObserverWard = nil
local SentryWard = nil

local hTargetSpot = nil
local fLastWardPlantTime = -math.huge

function GetDesire()
	local cacheKey = 'GetWardDesire'..tostring(bot:GetPlayerID())
	local cachedVar = J.Utils.GetCachedVars(cacheKey, 1)
	if cachedVar ~= nil then return cachedVar end
	local res = GetDesireHelper()
	J.Utils.SetCachedVars(cacheKey, res)
	return res
end
function GetDesireHelper()
    if not X.IsSuitableToWard() then
        return BOT_MODE_DESIRE_NONE
    end

	local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

    for i = 0, 5 do
        local hItem = bot:GetItemInSlot(i)
        if hItem then
            local sItemName = hItem:GetName()
            if sItemName == 'item_ward_observer' or sItemName == 'item_ward_dispenser' then
                ObserverWard = hItem
				break
            end
        end
    end

    -- Observer
    if J.CanCastAbility(ObserverWard) then
        local hAvailabeObserverWardSpots = W.GetAvailabeObserverWardSpots(bot)
        hTargetSpot = W.GetClosestObserverWardSpot(bot, hAvailabeObserverWardSpots)
		if hTargetSpot and (not X.IsEnemyCloserToWardLocation(hTargetSpot.location) or J.IsRealInvisible(bot)) then
			if DotaTime() < 0 and DotaTime() > (J.IsModeTurbo() and -45 or -60) then
				return BOT_MODE_DESIRE_ABSOLUTE
			end

			if DotaTime() > fLastWardPlantTime + 1.0 then
				if GetUnitToLocationDistance(bot, hTargetSpot.location) <= 3200 then
					return BOT_MODE_DESIRE_VERYHIGH
				end
			end
		end
    end

	for i = 0, 5 do
        local hItem = bot:GetItemInSlot(i)
        if hItem then
            local sItemName = hItem:GetName()
            if sItemName == 'item_ward_sentry' or sItemName == 'item_ward_dispenser' then
                SentryWard = hItem
				break
            end
        end
    end

    -- Sentry
    if J.CanCastAbility(SentryWard) then
        local hPossibleSentryWardSpots = W.GetPossibleSentryWardSpots(bot)
        hTargetSpot = W.GetClosestSentryWardSpot(bot, hPossibleSentryWardSpots)
		if hTargetSpot and (not X.IsEnemyCloserToWardLocation(hTargetSpot.location) or J.IsRealInvisible(bot)) then
			if DotaTime() > fLastWardPlantTime + 1.0 then
				if GetUnitToLocationDistance(bot, hTargetSpot.location) <= 3200 then
					return BOT_MODE_DESIRE_VERYHIGH
				end
			end
		end
    end

	return BOT_MODE_DESIRE_NONE
end

function Think()
	if J.CanNotUseAction(bot) then return end

	if hTargetSpot then
		if ObserverWard and J.CanCastAbility(ObserverWard) then
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