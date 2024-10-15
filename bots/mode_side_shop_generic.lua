local bot = GetBot()
local botTeam = bot:GetTeam()
local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )

local Tormentor = nil
local TormentorLocation

local tormentorMessageTime = DotaTime()
local canDoTormentor = false

local IsTeamHealthy = false

if bot.tormentorState == nil then bot.tormentorState = false end
if bot.lastKillTime == nil then bot.lastKillTime = 0 end
if bot.wasAttackingTormentor == nil then bot.wasAttackingTormentor = false end

local NoTormentorAfterThisTime = 35 * 60 -- do not do tormentor again since it's late and doing tormentor only slows down the game more.

local WisdomRuneSpawned = {
	[TEAM_RADIANT] = false,
	[TEAM_DIRE] = false
}

local ClosestAllyToWisdomRune
local TeamWisdomRune = J.Utils.WisdomRunes

local LastWisdomRuneTime = 0
local TeamWisdomTimer = 0
local WisdomRuneTimeGap = 420 - 5

function GetDesire()
	local wisdomRuneDesire = WisdomRuneDesire()
	if wisdomRuneDesire > 0 and WisdomRuneSpawned[botTeam] then
		return wisdomRuneDesire
	end
	local tormentorDesire = TormentorDesire()
	if tormentorDesire > 0 then
		return tormentorDesire
	end

	return BOT_MODE_DESIRE_NONE
end

function TormentorDesire()
    local aliveAlly = J.GetNumOfAliveHeroes(false)
    local aliveEnemy = J.GetNumOfAliveHeroes(true)
    local hasSameOrMoreHero = aliveAlly >= aliveEnemy + 2
    if not hasSameOrMoreHero then
        return BOT_ACTION_DESIRE_NONE
    end

	if J.GetHP(bot) < 0.1 then
		bot:Action_ClearActions(false)
		bot:Action_MoveToLocation(J.GetTeamFountain())
        return BOT_ACTION_DESIRE_NONE
	end

	if J.GetHP(bot) < 0.3
	and J.IsTormentor(Tormentor)
	and J.GetHP(Tormentor) > 0.2
	then
		bot:Action_ClearActions(false)
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return BOT_ACTION_DESIRE_NONE
	end

	TormentorLocation = J.GetTormentorLocation(GetTeam())

	if not IsEnoughAllies()
	then
		return BOT_ACTION_DESIRE_NONE
	end

    local nAllyInLoc = J.GetAlliesNearLoc(TormentorLocation, 700)
	-- local aveDistance, heroCount = GetAveTeamDistance()
	local spawnTime = J.IsModeTurbo() and 18 or 28 -- give bots more time. original: 10 or 20
	local topFrontP = GetLaneFrontAmount(GetOpposingTeam(), LANE_TOP, true)
	local midFrontP = GetLaneFrontAmount(GetOpposingTeam(), LANE_MID, true)
	local botFrontP = GetLaneFrontAmount(GetOpposingTeam(), LANE_BOT, true)
	local topFrontD = 1 - GetLaneFrontAmount(GetOpposingTeam(), LANE_TOP, true)
	local midFrontD = 1 - GetLaneFrontAmount(GetOpposingTeam(), LANE_MID, true)
	local botFrontD = 1 - GetLaneFrontAmount(GetOpposingTeam(), LANE_BOT, true)
	local aveCoreLevel = 0
	local aveSuppLevel = 0

    local currTime = DotaTime()
    local startTimer = J.IsModeTurbo() and 15 * 60 or 35 * 60
    local timeForLowDesire = J.IsModeTurbo() and 20 * 60 or 45 * 60
    local nModeDesire = RemapValClamped(currTime, startTimer, timeForLowDesire, BOT_ACTION_DESIRE_HIGH, BOT_MODE_DESIRE_VERYLOW)

	local enemyAncient = GetAncient(GetOpposingTeam())
	if GetUnitToUnitDistance(bot, enemyAncient) < 3200
	or (topFrontP > 0.9 or midFrontP > 0.9 or botFrontP > 0.9)
	or (topFrontD > 0.9 or midFrontD > 0.9 or botFrontD > 0.9)
	or J.IsPushing(bot)
	or J.IsDefending(bot)
	or J.IsDoingRoshan(bot)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if DidSomeoneSeeTormentorAlive()
	then
		bot.tormentorState = true
	end

	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member.lastKillTime ~= nil
		and member.lastKillTime > 0
		and member.lastKillTime ~= bot.lastKillTime
		and member.lastKillTime > bot.lastKillTime
		then
			bot.lastKillTime = member.lastKillTime
		end
	end

	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and not member:IsIllusion()
		and not member:HasModifier("modifier_arc_warden_tempest_double")
		and not J.IsMeepoClone(member)
		then
			if J.IsCore(member)
			then
				aveCoreLevel = aveCoreLevel + member:GetLevel()
			else
				aveSuppLevel = aveSuppLevel + member:GetLevel()
			end
		end
	end

	aveCoreLevel = aveCoreLevel / 3
	aveSuppLevel = aveSuppLevel / 2

	if DotaTime() <= NoTormentorAfterThisTime then
		if DotaTime() >= spawnTime * 60
		and (DotaTime() - bot.lastKillTime) >= (spawnTime / 2) * 60
		then
			-- Go check
			if not IsTormentorAlive()
			then
				if not J.IsCore(bot)
				and (GetUnitToUnitDistance(bot, enemyAncient) > 2000
				or (topFrontP < 0.9 or midFrontP < 0.9 or botFrontP < 0.9)
				or (topFrontD < 0.9 or midFrontD < 0.9 or botFrontD < 0.9))
				then
					local closestAlly = nil
					local dist = 100000
					for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
					do
						if J.IsValidHero(allyHero)
						and allyHero:IsAlive()
						and not allyHero:IsIllusion()
						and not J.IsCore(allyHero)
						then
							if GetUnitToLocationDistance(allyHero, TormentorLocation) < dist
							then
								closestAlly = allyHero
								dist = GetUnitToLocationDistance(allyHero, TormentorLocation)
							end
						end
					end

					if closestAlly ~= nil
					and bot == closestAlly
					and bot.tormentorState == false
					then
						return nModeDesire
					end
				end
			else
				bot.tormentorState = true
			end
		else
			bot.tormentorState = false
		end

		if not IsTeamHealthy
		then
			if WasHealthy()
			then
				IsTeamHealthy = true
			end
		end

		if bot.tormentorState
		and aveCoreLevel > 12.9
		and aveSuppLevel > 9.9
		and (((bot.lastKillTime == 0 and aliveAlly >= 3)
			or (bot.lastKillTime > 0 and aliveAlly >= 2)
			or (GetAttackingCount() >= 3 and J.GetAliveAllyCoreCount() >= 2)))
		then
			if not IsTeamHealthy
			then
				return BOT_ACTION_DESIRE_NONE
			end

			canDoTormentor = IsTeamHealthy

			if nAllyInLoc ~= nil and #nAllyInLoc >= 3
			or IsHumanInLoc()
			then
				return BOT_ACTION_DESIRE_VERYHIGH
			else
				return nModeDesire
			end
		end
	end

	if not IsTormentorAlive()
	then
		IsTeamHealthy = false
		bot.wasAttackingTormentor = false
	end

	canDoTormentor = false
	return BOT_ACTION_DESIRE_NONE
end

function Think()

	if bot.lastSideShopFrameProcessTime == nil then bot.lastSideShopFrameProcessTime = DotaTime() end
	if DotaTime() - bot.lastSideShopFrameProcessTime < bot.frameProcessTime then return end
	bot.lastSideShopFrameProcessTime = DotaTime()

	if WisdomRuneThink() >= 1 then
		return
	end

	if TormentorThink() >= 1 then
		return
	end
end

function IsTormentorAlive()
	if IsLocationVisible(TormentorLocation)
	and GetUnitToLocationDistance(bot, TormentorLocation) <= 100
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(700)
		for _, c in pairs(nCreeps)
		do
			if c:GetUnitName() == "npc_dota_miniboss"
			then
				return true
			end
		end

		bot.lastKillTime = DotaTime()
	end

	return false
end

function IsEnoughAllies()
	local heroCount = 0
    local coreCount = 0

	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member:IsAlive()
		and not member:IsIllusion()
		and not member:HasModifier("modifier_arc_warden_tempest_double")
		and GetUnitToLocationDistance(member, TormentorLocation) <= 800
		then
            if J.IsCore(member)
            then
                coreCount = coreCount + 1
            end

			heroCount = heroCount + 1
		end
	end
	
	local nInRangeAlly = J.GetNearbyHeroes(bot, 900, false)

	return #nInRangeAlly >= 3 and bot.lastKillTime >= 0 and heroCount >= 4 and coreCount >= 2
end

function DoesAllHaveShard()
	local heroCount = 0

	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and J.HasAghanimsShard(member)
		then
			heroCount = heroCount + 1
		end
	end

	return heroCount == 5
end

function GetAveTeamDistance()
	local heroCount = 0
	local aveDistance = 0
    local coreCount = 0

	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member:IsAlive()
		and not member:IsIllusion()
		and not member:HasModifier("modifier_arc_warden_tempest_double")
		and GetUnitToLocationDistance(member, TormentorLocation) <= 2400
		then
			heroCount = heroCount + 1
			aveDistance = aveDistance + GetUnitToLocationDistance(member, TormentorLocation)

            if J.IsCore(member)
            then
                coreCount = coreCount + 1
            end
		end
	end

	if heroCount > 0
    and coreCount >= 2
	then
		return aveDistance / heroCount, heroCount
	end

	return 0, 0
end

function DidSomeoneSeeTormentorAlive()
	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member.tormentorState
		then
			return true
		end
	end

	return false
end

function GetAttackingCount()
	local count = 0

	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member:IsAlive()
		and member.wasAttackingTormentor
		then
			count = count + 1
		end
	end

	return count
end

function IsHumanInLoc()
	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member:IsAlive()
		and not member:IsBot()
		and not member:IsIllusion()
		and not member:HasModifier("modifier_arc_warden_tempest_double")
		and not J.IsMeepoClone(member)
		and GetUnitToLocationDistance(member, TormentorLocation) <= 700
		then
			return true
		end
	end

	return false
end

function WasHealthy()
	local count = 0

	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member:IsAlive()
		and J.GetHP(member) > 0.5
		then
			count = count + 1
		end
	end

	return count == J.GetNumOfAliveHeroes(false)
end

local humanSideTimeGap = WisdomRuneTimeGap
local function CheckWisdomRuneAvailability()
	if not WisdomRuneSpawned[botTeam] then
		if humanSideTimeGap ~= WisdomRuneTimeGap and J.IsHumanPlayerInTeam() then
			humanSideTimeGap = WisdomRuneTimeGap + 90
		end

		if DotaTime() - LastWisdomRuneTime >= humanSideTimeGap then
			LastWisdomRuneTime = DotaTime()
			WisdomRuneSpawned[botTeam] = true
		end
	end
end

local function GetClosestAllyToWisdomRune()
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	
	if J.IsLaning(bot) then
		for v, Ally in pairs(Allies) do
			if Ally:IsAlive() and J.IsValidHero(Ally) and not Ally:IsIllusion() and J.GetPosition(Ally) > 3 then
				return Ally
			end
		end
	else
		local ClosestAllyToTeamRune = bot
		local ClosestDistanceToTheirRune = 99999
		
		for v, Ally in pairs(Allies) do
			if Ally:IsAlive() and J.IsValidHero(Ally) and not Ally:IsIllusion() then
				local dist = GetUnitToLocationDistance(Ally, TeamWisdomRune[botTeam])
				if dist < ClosestDistanceToTheirRune then
					ClosestAllyToTeamRune = Ally
					ClosestDistanceToTheirRune = dist
				end
				
			end
		end
		
		return ClosestAllyToTeamRune
	end
	
	return bot
end

function WisdomRuneDesire()
	if J.Utils.BuggyHeroesDueToValveTooLazy[botName] then return BOT_MODE_DESIRE_NONE end
	-- don't worry about wisdom rune if human player exist in the team.
	if J.IsHumanPlayerInTeam() or J.IsCore(bot) then
		return BOT_MODE_DESIRE_NONE
	end

	-- 先杀小兵，别带着小兵去吃符，过程中可能攻击tormentor因为那东西在代码里也是Creep
	local nCreeps = bot:GetNearbyLaneCreeps(700, true)
	if #nCreeps > 1 then
		return BOT_MODE_DESIRE_NONE
	end

	CheckWisdomRuneAvailability()

	if WisdomRuneSpawned[botTeam] then
		ClosestAllyToWisdomRune = GetClosestAllyToWisdomRune()
		if ClosestAllyToWisdomRune ~= nil then
			if GetUnitToLocationDistance(ClosestAllyToWisdomRune, TeamWisdomRune[botTeam]) > 600 then
				TeamWisdomTimer = DotaTime()
			else
				if (DotaTime() - TeamWisdomTimer) > 3 then
					WisdomRuneSpawned[botTeam] = false
				end
			end
		end
	end

	local botLvl = bot:GetLevel()
	if ClosestAllyToWisdomRune == bot then
		if WisdomRuneSpawned[botTeam] then
			local distance = GetUnitToLocationDistance(ClosestAllyToWisdomRune, TeamWisdomRune[botTeam])
			if botLvl < 12 then
				return RemapValClamped(distance, 6400, 100, BOT_ACTION_DESIRE_HIGH, BOT_ACTION_DESIRE_ABSOLUTE  )
			elseif botLvl < 18 then
				return RemapValClamped(distance, 6400, 100, BOT_ACTION_DESIRE_HIGH , BOT_ACTION_DESIRE_VERYHIGH   )
			elseif botLvl < 25 then
				return RemapValClamped(distance, 6400, 100, BOT_ACTION_DESIRE_MODERATE, BOT_ACTION_DESIRE_VERYHIGH  )
			elseif botLvl < 30 then
				return RemapValClamped(distance, 6400, 100, BOT_ACTION_DESIRE_LOW , BOT_ACTION_DESIRE_HIGH  )
			end
		end
	end

	return BOT_MODE_DESIRE_NONE
end

function WisdomRuneThink()
	-- don't worry about wisdom rune if human player exist in the team.
	if J.IsHumanPlayerInTeam() then
		return 0
	end

	if WisdomRuneSpawned[botTeam] then
		if ClosestAllyToWisdomRune == bot then
			bot:Action_MoveToLocation(TeamWisdomRune[botTeam] + RandomVector(50))
			return 1
		end
	end

	return 0
end

function TormentorThink()
	if J.GetHP(bot) < 0.2
	then
		bot:Action_ClearActions(false)
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return 1
	end

	if DotaTime() <= NoTormentorAfterThisTime then
		if GetUnitToLocationDistance(bot, TormentorLocation) > 300
		then
			bot:Action_MoveToLocation(TormentorLocation + RandomVector(200))
			return 1
		else
			local nCreeps = bot:GetNearbyNeutralCreeps(700)

			for _, creepOrTormentor in pairs(nCreeps)
			do
				if creepOrTormentor:GetUnitName() == "npc_dota_miniboss"
				then
					Tormentor = creepOrTormentor

					if IsEnoughAllies()
					and J.GetHP(bot) > 0.25
					then
						bot.wasAttackingTormentor = true
						bot:Action_AttackUnit(creepOrTormentor, false)
					end

					if (DotaTime() - tormentorMessageTime) > 15
					and canDoTormentor
					then
						tormentorMessageTime = DotaTime()
						bot:ActionImmediate_Chat("Let's try tormentor?", false)
						bot:ActionImmediate_Ping(creepOrTormentor:GetLocation().x, creepOrTormentor:GetLocation().y, true)
					end
					return 1
				end
			end
		end
	end
	return 0
end