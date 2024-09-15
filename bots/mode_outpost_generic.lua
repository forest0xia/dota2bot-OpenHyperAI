if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return
end

local bot = GetBot()
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local Outposts = {}
local DidWeGetOutpost = false
local ClosestOutpost = nil
local ClosestOutpostDist = 10000

local IsEnemyTier2Down = false

function GetDesire()
	if not IsEnemyTier2Down
	then
		if GetTower(GetOpposingTeam(), TOWER_TOP_2) == nil
		or GetTower(GetOpposingTeam(), TOWER_MID_2) == nil
		or GetTower(GetOpposingTeam(), TOWER_BOT_2) == nil
		then
			IsEnemyTier2Down = true
		end
	end

	----------
	-- Outpost
	----------

	if not IsEnemyTier2Down then return BOT_ACTION_DESIRE_NONE end

	if not DidWeGetOutpost
	then
		if bot:GetUnitName() == 'npc_dota_hero_invoker' then return BOT_ACTION_DESIRE_NONE end
		for _, unit in pairs(GetUnitList(UNIT_LIST_ALL))
		do
			if unit:GetUnitName() == '#DOTA_OutpostName_North'
			or unit:GetUnitName() == '#DOTA_OutpostName_South'
			then
				table.insert(Outposts, unit)
			end
		end

		DidWeGetOutpost = true
	end

	ClosestOutpost, ClosestOutpostDist = GetClosestOutpost()
	if  ClosestOutpost ~= nil and ClosestOutpostDist < 3500
	and not IsEnemyCloserToOutpostLoc(ClosestOutpost:GetLocation(), ClosestOutpostDist)
	and IsSuitableToCaptureOutpost()
	then
		if GetUnitToUnitDistance(bot, ClosestOutpost) < 600
		then
			local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), bot:GetCurrentVisionRange())
			if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
			then
				return BOT_ACTION_DESIRE_NONE
			end
		end

		return RemapValClamped(GetUnitToUnitDistance(bot, ClosestOutpost), 3500, 0, BOT_ACTION_DESIRE_VERYLOW, BOT_ACTION_DESIRE_HIGH )
	end

	return BOT_ACTION_DESIRE_NONE
end

function OnStart()

end

function OnEnd()
	ClosestOutpost = nil
	ClosestOutpostDist = 10000
	ShouldWaitInBaseToHeal = false
end

function Think()
	if J.CanNotUseAction(bot) then return end

	if ClosestOutpost ~= nil
	then
		if GetUnitToUnitDistance(bot, ClosestOutpost) > 300
		then
			bot:Action_MoveToLocation(ClosestOutpost:GetLocation())
			return
		else
			bot:Action_AttackUnit(ClosestOutpost, false)
			return
		end
	end
end

function GetClosestOutpost()
	local closest = nil
	local dist = 10000

	for i = 1, 2
	do
		if  Outposts[i] ~= nil
		and Outposts[i]:GetTeam() ~= GetTeam()
		and GetUnitToUnitDistance(bot, Outposts[i]) < dist
		and not Outposts[i]:IsNull()
		and not Outposts[i]:IsInvulnerable()
		then
			closest = Outposts[i]
			dist = GetUnitToUnitDistance(bot, Outposts[i])
		end
	end

	return closest, dist
end

function IsEnemyCloserToOutpostLoc(opLoc, botDist)
	for _, id in pairs(GetTeamPlayers(GetOpposingTeam()))
	do
		local info = GetHeroLastSeenInfo(id)

		if info ~= nil
		then
			local dInfo = info[1]
			if dInfo ~= nil
			then
				if  dInfo ~= nil
				and dInfo.time_since_seen < 5
				and J.GetDistance(dInfo.location, opLoc) < botDist
				then
					return true
				end
			end
		end
	end

	return false
end

function IsSuitableToCaptureOutpost()
	local botTarget = J.GetProperTarget(bot)

	if (J.IsGoingOnSomeone(bot) and J.IsValidTarget(botTarget) and GetUnitToUnitDistance(bot, botTarget) < 700)
	or J.IsDefending(bot)
	or (J.IsDoingTormentor(bot) and J.IsTormentor(botTarget) and J.IsAttacking(bot))
	or (J.IsDoingRoshan(bot) and J.IsRoshan(botTarget) and J.IsAttacking(bot))
	or (J.IsRetreating(bot) and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH)
	or bot:WasRecentlyDamagedByAnyHero(1.5)
	or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
	then
		return false
	end

	return true
end
