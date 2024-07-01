local bot = GetBot()
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

local WisdomRuneSpawned = false
local ClosestAllyToWisdomRune
local TeamWisdomRune
local RWR = Vector( -8126, -320, 256 )
local DWR = Vector( 8319, 266, 256 )
local LastWisdomRuneTime = 0
local TeamWisdomTimer = 0
local WisdomRuneTimeGap = 420

function GetDesire()
	local wisdomRuneDesire = WisdomRuneDesire()
	if wisdomRuneDesire > 0 then
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

	TormentorLocation = J.GetTormentorLocation(GetTeam())

    local nAllyInLoc = J.GetAlliesNearLoc(TormentorLocation, 700)
	local aliveAlly = J.GetNumOfAliveHeroes(false)
	-- local aveDistance, heroCount = GetAveTeamDistance()
	local spawnTime = J.IsModeTurbo() and 15 or 25 -- give bots more time. original: 10 or 20
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

		if  member ~= nil
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
						if  J.IsValidHero(allyHero)
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

					if  closestAlly ~= nil
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

		if  bot.tormentorState
		and aveCoreLevel > 12.9
		and aveSuppLevel > 9.9
		and (((bot.lastKillTime == 0 and aliveAlly >= 5)
			or (bot.lastKillTime > 0 and aliveAlly >= 3)
			or (GetAttackingCount() >= 3 and J.GetAliveAllyCoreCount() >= 2)))
		then
			if not IsTeamHealthy
			then
				return BOT_ACTION_DESIRE_NONE
			end

			canDoTormentor = IsTeamHealthy

			if  J.GetHP(bot) < 0.3
			and J.IsTormentor(Tormentor)
			and J.GetHP(Tormentor) > 0.2
			then
				return BOT_ACTION_DESIRE_NONE
			end

			if IsEnoughAllies()
			then
				return BOT_ACTION_DESIRE_VERYHIGH
			end

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
end

local FrameProcessTime = 0.08
function Think()
	
	if bot.lastSideShopFrameProcessTime == nil then bot.lastSideShopFrameProcessTime = DotaTime() end
	if DotaTime() - bot.lastSideShopFrameProcessTime < FrameProcessTime then return end
	bot.lastSideShopFrameProcessTime = DotaTime()

	if WisdomRuneThink() >= 1 then
		return
	end

	if DotaTime() <= NoTormentorAfterThisTime then
		if GetUnitToLocationDistance(bot, TormentorLocation) > 100
		then
			bot:Action_MoveToLocation(TormentorLocation)
			return
		else
			local nCreeps = bot:GetNearbyNeutralCreeps(700)
	
			for _, c in pairs(nCreeps)
			do
				if c:GetUnitName() == "npc_dota_miniboss"
				then
					Tormentor = c
	
					if IsEnoughAllies()
					and J.GetHP(c) > 0.25
					then
						bot.wasAttackingTormentor = true
						bot:Action_AttackUnit(c, false)
					end
	
					if  (DotaTime() - tormentorMessageTime) > 15
					and canDoTormentor
					then
						tormentorMessageTime = DotaTime()
						bot:ActionImmediate_Chat("Let's try tormentor?", false)
						bot:ActionImmediate_Ping(c:GetLocation().x, c:GetLocation().y, true)
					end
				end
			end
		end
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
		and GetUnitToLocationDistance(member, TormentorLocation) <= 700
		then
            if J.IsCore(member)
            then
                coreCount = coreCount + 1
            end

			heroCount = heroCount + 1
		end
	end
	
	local nInRangeEnemy = J.GetNearbyHeroes(bot, 1600, false)

	return #nInRangeEnemy >= 3 and bot.lastKillTime >= 0 and heroCount >= 4 and coreCount >= 2
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

	if  heroCount > 0
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

		if  member ~= nil
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

		if  member ~= nil
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

		if  member ~= nil
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
	if not WisdomRuneSpawned then
		if humanSideTimeGap ~= WisdomRuneTimeGap and J.IsHumanPlayerInTeam() then
			humanSideTimeGap = WisdomRuneTimeGap + 90
		end

		if DotaTime() - LastWisdomRuneTime >= humanSideTimeGap then
			LastWisdomRuneTime = DotaTime()
			WisdomRuneSpawned = true
		end
	end
end

local function GetClosestAllyToWisdomRune()
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	
	if J.IsLaning(bot) then
		for v, Ally in pairs(Allies) do
			if Ally:IsAlive() and J.IsValidHero(Ally) and not Ally:IsIllusion() and J.GetPosition(Ally) >= 3 then
				return Ally
			end
		end
	else
		local ClosestAlly = bot
		local ClosestDistance = 99999
		
		for v, Ally in pairs(Allies) do
			if Ally:IsAlive() and J.IsValidHero(Ally) and not Ally:IsIllusion() then
				local dist = GetUnitToLocationDistance(Ally, TeamWisdomRune)
				if dist < ClosestDistance then
					ClosestAlly = Ally
					ClosestDistance = dist
				end
			end
		end

		if (ClosestDistance >= 3200) then
			return nil -- too far. bots may be group pushing.
		end
		
		return ClosestAlly
	end
	
	return bot
end

function WisdomRuneDesire()
	-- don't worry about wisdom rune if human player exist in the team.
	if J.IsHumanPlayerInTeam() then
		return 0
	end

	if bot:GetTeam() == TEAM_RADIANT then
		TeamWisdomRune = RWR
	elseif bot:GetTeam() == TEAM_DIRE then
		TeamWisdomRune = DWR
	end
	
	CheckWisdomRuneAvailability()
	
	if WisdomRuneSpawned then

		ClosestAllyToWisdomRune = GetClosestAllyToWisdomRune()
		if ClosestAllyToWisdomRune ~= nil then
			if GetUnitToLocationDistance(ClosestAllyToWisdomRune, TeamWisdomRune) > 200 then
				TeamWisdomTimer = DotaTime()
			else
				if (DotaTime() - TeamWisdomTimer) > 1 then
					WisdomRuneSpawned = false
				end
			end
		end
	end
	
	if ClosestAllyToWisdomRune == bot and bot:GetLevel() < 25 then
		if WisdomRuneSpawned then
			return 0.81
		end
	end
	return 0
end

function WisdomRuneThink()
	-- don't worry about wisdom rune if human player exist in the team.
	if J.IsHumanPlayerInTeam() then
		return 0
	end

	if bot:GetTeam() == TEAM_RADIANT then
		TeamWisdomRune = RWR
	elseif bot:GetTeam() == TEAM_DIRE then
		TeamWisdomRune = DWR
	end
	
	if WisdomRuneSpawned then
		if ClosestAllyToWisdomRune == bot then
			bot:Action_MoveToLocation(TeamWisdomRune)
			return 1
		end
	end
	return 0
end
