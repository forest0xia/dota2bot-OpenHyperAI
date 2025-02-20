local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local Version = require(GetScriptDirectory()..'/FunLib/version')
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )

local team = GetTeam()

local X = {}
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local RadiantBase = Vector(-7174.000000, -6671.00000, 0.000000)
local DireBase = Vector(7023.000000, 6450.000000, 0.000000)

local minute = 0;
local sec = 0;
local preferedCamp = nil;
local availableCamp = {};
local hLaneCreepList = {};
local numCamp = 18;
local farmState = 0;
local teamPlayers = nil;
local nLaneList = {LANE_TOP, LANE_MID, LANE_BOT};
local nTpSolt = 15

local runTime = 0;
local shouldRunTime = 0
local runMode = false;

local pushTime = 0;
local laningTime = 0;
local assembleTime = 0;
local teamTime = 0;

local countTime = 0;
local countCD = 5.0;
local allyKills = 0;
local enemyKills = 0;

local nLostCount = RandomInt(35,45);
local nWinCount = RandomInt(24,34);

local bInitDone = false;
local beNormalFarmer = false;
local beHighFarmer = false;
local beVeryHighFarmer = false;

local isChangePosMessageDone = false

local IsShouldGoFarm = false
local ShouldGoFarmTime = 0
local nH, nB = J.Utils.NumHumanBotPlayersInTeam(GetOpposingTeam())

local lastAnnouncePrintedTime = 0
local numberAnnouncePrinted = 1
local announcementGap = 6
local hasPickedOneAnnouncer = false
local checkGoFarmTimeGap = 5
local botTarget = nil
local botActiveMode = nil
local CleanupCachedVarsTime = -100

local buggedFarmAttackHeroes = {
	"npc_dota_hero_invoker"
}

if bot.farmLocation == nil then bot.farmLocation = bot:GetLocation() end

function GetDesire()
	if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return BOT_MODE_DESIRE_NONE end

	Utils.PrintPings(0.15)

	if DotaTime() - CleanupCachedVarsTime > Utils.CachedVarsCleanTime then
		Utils.CleanupCachedVars()
		CleanupCachedVarsTime = DotaTime()
	end

	PickOneAnnouncer()
	AnnounceMessages()

	botTarget = bot:GetAttackTarget()

	if DotaTime() - ShouldGoFarmTime > checkGoFarmTimeGap then
		IsShouldGoFarm = false
	end

	if not bInitDone
	then
		bInitDone = true
		beNormalFarmer = J.GetPosition(bot) == 3
		beHighFarmer = J.GetPosition(bot) == 2
		beVeryHighFarmer = J.GetPosition(bot) == 1
	end

    local currentTime = DotaTime()
    if GetGameMode() == 23 then
        currentTime = currentTime * 2
    end

	botActiveMode = bot:GetActiveMode()
	local TormentorLocation = J.GetTormentorLocation(GetTeam())
	local nInRangeAlly_tormentor = J.GetAlliesNearLoc(TormentorLocation, 900)
	local nInRangeAlly_roshan = J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), 900)
	local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
	local lEnemyHeroesAroundAncient = J.GetLastSeenEnemiesNearLoc(GetAncient(team):GetLocation(), 3000)
	local nEnemyUnitsAroundAncient = J.GetEnemiesAroundAncient(bot, 3000)

	if #nInRangeAlly_tormentor >= 2
	or #nInRangeAlly_roshan >= 2
	or J.IsDoingTormentor(bot)
	or J.IsDoingRoshan(bot)
	or (J.IsDefending(bot) and bot:GetActiveModeDesire() > 0.2)
	or #lEnemyHeroesAroundAncient > 0
	or nEnemyUnitsAroundAncient > 0
	then
		return BOT_MODE_DESIRE_NONE
	end

	for _, creep in pairs(nNeutralCreeps)
	do
		if J.IsValid(creep)
		and J.IsInRange(bot, creep, 900)
		and creep:GetUnitName() == "npc_dota_miniboss"
		then
			return BOT_ACTION_DESIRE_NONE
		end
	end

	-- 如果在打高地 就别撤退去打钱了
	-- if J.Utils.IsTeamPushingSecondTierOrHighGround(bot) then
	-- 	return BOT_MODE_DESIRE_NONE;
	-- end

	if teamPlayers == nil then teamPlayers = GetTeamPlayers(team) end

	-- For sometime to run
	if bot:IsAlive()
	then
		if runTime ~= 0
			and DotaTime() < runTime + shouldRunTime
		then
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1;
		else
			runTime = 0;
			runMode = false;
		end
		shouldRunTime = X.ShouldRun(bot);
		if shouldRunTime ~= 0
		then
			if runTime == 0 then
				runTime = DotaTime();
				runMode = true;
				preferedCamp = nil;
				bot:Action_ClearActions(true);
			end
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1;
		end
	end

	if DotaTime() < 50 or botActiveMode == BOT_MODE_RUNE then return 0.0 end

	if X.IsUnitAroundLocation(GetAncient(team):GetLocation(), 3000) then
		return BOT_MODE_DESIRE_NONE;
	end

	minute = math.floor(DotaTime() / 60);
	sec = DotaTime() % 60;

	if not J.Role.IsCampRefreshDone()
	   and J.Role.GetAvailableCampCount() < J.Role.GetCampCount()
	   and ( DotaTime() > 20 and  sec > 0 and sec < 2 )
	then
		J.Role['availableCampTable'], J.Role['campCount'] = J.Site.RefreshCamp(bot);
		J.Role['hasRefreshDone'] = true;
	end

	if J.Role.IsCampRefreshDone() and sec > 52
	then
		J.Role['hasRefreshDone'] = false;
	end

	availableCamp = J.Role['availableCampTable'];

	local hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 3000)
	local hEnemyHeroList = J.GetEnemiesNearLoc(bot:GetLocation(), 2000)

	local numOfAliveEnemyHeroes = J.GetNumOfAliveHeroes(true)
	local teamAveLvl = J.GetAverageLevel( false )

	-- 避免过早推2塔或者高地
	-- if teamAveLvl < 10
	-- and #hEnemyHeroList >= 2
	-- and numOfAliveEnemyHeroes >= 3
	-- and #hAllyList <= 2 and #hAllyList < #hEnemyHeroList -- 我们人挺多，对面人也挺多，大战似乎在所难免，别跑了
	-- then
	-- 	if J.Utils.IsNearEnemySecondTierTower(bot, 1500)
	-- 	and (J.IsCore(bot) and bot:GetNetWorth() < 18000) then
	-- 		if DotaTime() - ShouldGoFarmTime >= checkGoFarmTimeGap then
	-- 			IsShouldGoFarm = true
	-- 			ShouldGoFarmTime = DotaTime()
	-- 		end
	-- 		hLaneCreepList = {}
	-- 		if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end;
	-- 		return BOT_MODE_DESIRE_ABSOLUTE * 1.1;
	-- 	end
	-- elseif teamAveLvl < 13
	-- and #hEnemyHeroList >= 2
	-- and numOfAliveEnemyHeroes >= 3
	-- and #hAllyList <= 2 and #hAllyList < #hEnemyHeroList -- 我们人挺多，对面人也挺多，大战似乎在所难免，别跑了
	-- then
	-- 	if J.Utils.IsNearEnemyHighGroundTower(bot, 1500)
	-- 	and (J.IsCore(bot) and bot:GetNetWorth() < 18000) then
	-- 		if DotaTime() - ShouldGoFarmTime >= checkGoFarmTimeGap then
	-- 			IsShouldGoFarm = true
	-- 			ShouldGoFarmTime = DotaTime()
	-- 		end
	-- 		hLaneCreepList = {}
	-- 		if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end;
	-- 		return BOT_MODE_DESIRE_ABSOLUTE * 1.1;
	-- 	end
	-- end

	-- 如果在打推塔 就别撤退去打钱了
	-- local nEnemyTowers = bot:GetNearbyTowers(1200, true);
	-- if #hAllyList >= 2 and nEnemyTowers ~= nil and #nEnemyTowers > 0 and GetUnitToLocationDistance(bot, nEnemyTowers[1]:GetLocation()) < 1300 then
	-- 	return BOT_MODE_DESIRE_NONE;
	-- end

	-- 如果在上高，对面人活着，其他队友活着却不在附近，赶紧溜去其他地方farm
	-- if IsShouldGoFarm or ((#hAllyList < 2 and #hAllyList < numOfAliveEnemyHeroes - 1)
	-- -- or (currentTime > 420 and bot:GetActiveModeDesire() < 0.15))
	-- -- if (IsShouldGoFarm or ((#hAllyList <= 2 and #hAllyList < numOfAliveEnemyHeroes)
	-- -- -- and not J.WeAreStronger(bot, 2000)
	-- -- -- and (J.IsCore(bot) and bot:GetNetWorth() < 18000)
	-- -- -- and bot:GetActiveModeDesire() <= BOT_ACTION_DESIRE_HIGH
	-- and J.GetDistanceFromAncient( bot, true ) < 5500)
    -- -- )
	-- and #J.Utils.GetLastSeenEnemyIdsNearLocation(bot:GetLocation(), 2000) == 0 then
	-- 	if DotaTime() - ShouldGoFarmTime >= checkGoFarmTimeGap then
	-- 		IsShouldGoFarm = true
	-- 		ShouldGoFarmTime = DotaTime()
	-- 	end
	-- 	hLaneCreepList = {}
	-- 	if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end;
	-- 	if preferedCamp ~= nil then
	-- 		return BOT_ACTION_DESIRE_ABSOLUTE * 0.98
	-- 	end
	-- end

	local hNearbyAttackAllyHeroList = J.GetNearbyHeroes(bot,1600, false, BOT_MODE_ATTACK);

	if #hEnemyHeroList > 0 or #hNearbyAttackAllyHeroList > 0
	then
		return BOT_MODE_DESIRE_NONE;
	end

	local nAttackAllys = J.GetSpecialModeAllies(bot,2600,BOT_MODE_ATTACK);
	if #nAttackAllys > 0 and (not beVeryHighFarmer or bot:GetLevel() >= 18)
	then
		return BOT_MODE_DESIRE_NONE;
	end

	local nRetreatAllyList = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_RETREAT);
	if J.IsValid(nRetreatAllyList[1]) and (not beVeryHighFarmer or bot:GetLevel() >= 18)
	   and nRetreatAllyList[1]:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
	then
		return BOT_MODE_DESIRE_NONE;
	end

	local nTeamFightLocation = J.GetTeamFightLocation(bot);
	if nTeamFightLocation ~= nil
	   and ( not beVeryHighFarmer or bot:GetLevel() >= 16 )
	   and GetUnitToLocationDistance(bot,nTeamFightLocation) < 2800
	then
		return BOT_MODE_DESIRE_NONE;
	end

	if bot:GetActiveMode() == BOT_MODE_LANING then laningTime = DotaTime(); end
	if DotaTime() - laningTime < 15.0 and GetHeroDeaths(bot:GetPlayerID()) <= 2 then return BOT_MODE_DESIRE_NONE; end

	if bot:IsAlive() and bot:HasModifier('modifier_arc_warden_tempest_double')
	   and GetRoshanDesire() > 0.85
	then
		if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end;
		return 0.99;
	end

	if bot:IsAlive()
	then
		if J.IsDoingRoshan(bot)
		and J.IsMeepoClone(bot)
		then
			if J.IsRoshan(botTarget)
			and J.IsInRange(bot, botTarget, 400)
			and J.GetHP(botTarget) < 0.2
			then
				if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end
				return BOT_MODE_DESIRE_ABSOLUTE * 0.99
			end
		end

		if botActiveMode == BOT_MODE_ITEM
		then
			if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end
			return bot:GetActiveModeDesire() + 0.1
		end
	end

	if not bot:IsAlive() 
	   or ( bot:WasRecentlyDamagedByAnyHero(2.5) and bot:GetAttackTarget() == nil )
	   or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
	   or bot.SecretShop 
	then
		return BOT_MODE_DESIRE_NONE;
	end

	local aliveEnemyCount = J.GetNumOfAliveHeroes(true);
	local aliveAllyCount  = J.GetNumOfAliveHeroes(false);
	if aliveEnemyCount <= 1
	then
		return BOT_MODE_DESIRE_NONE;
	end

	if not J.Role.IsAllyHaveAegis() and J.IsHaveAegis(bot) then J.Role['aegisHero'] = bot end;
	if J.Role.IsAllyHaveAegis() and aliveAllyCount >= 4
	then
		return BOT_MODE_DESIRE_NONE;
	end

	if DotaTime() > countTime + countCD
	then
		countTime  = DotaTime();
		allyKills  = J.GetNumOfTeamTotalKills(false);
		enemyKills = J.GetNumOfTeamTotalKills(true);

		if enemyKills > allyKills + nLostCount and J.Role.NotSayRate()
		then
			J.Role['sayRate'] = true;
			if RandomInt(1,6) < 3
			then
				bot:ActionImmediate_Chat(Localization.Get('say_will_lose'),true);
			else
				bot:ActionImmediate_Chat(Localization.Get('say_will_lose_2'),true);
			end
		end
		if allyKills > enemyKills + nWinCount and J.Role.NotSayRate()
		then
		    J.Role['sayRate'] = true;
			if RandomInt(1,6) < 3
			then
				bot:ActionImmediate_Chat(Localization.Get('say_will_win'),true);
			else
				bot:ActionImmediate_Chat(Localization.Get('say_will_win_2'),true);
			end
		end

	end
	if allyKills > enemyKills + 20 and aliveAllyCount >= 4
	then return BOT_MODE_DESIRE_NONE; end

	local nAlliesCount = J.GetAllyCount(bot,1400);
	if nAlliesCount >= 4
	   or (bot:GetLevel() >= 20 and nAlliesCount >= 3)
	   or GetRoshanDesire() > BOT_MODE_DESIRE_VERYHIGH
	then
		local nNeutrals = bot:GetNearbyNeutralCreeps( bot:GetAttackRange() );
		if #nNeutrals == 0
		then
		    teamTime = DotaTime();
		end
	end
	if GetDefendLaneDesire(LANE_TOP) > 0.85
	   or GetDefendLaneDesire(LANE_MID) > 0.80
	   or GetDefendLaneDesire(LANE_BOT) > 0.85
	then
		local nDefendLane,nDefendDesire = J.GetMostDefendLaneDesire();
		local nDefendLoc  = GetLaneFrontLocation(GetTeam(),nDefendLane,-600);
		local nDefendAllies = J.GetAlliesNearLoc(nDefendLoc, 2200);

		local nNeutrals = bot:GetNearbyNeutralCreeps( bot:GetAttackRange() );

		if #nNeutrals == 0 and #nDefendAllies >= 2 and (not beVeryHighFarmer or bot:GetLevel() >= 13)
		then
		    teamTime = DotaTime();
		end
	end
	if teamTime > DotaTime() - 3.0 then return BOT_MODE_DESIRE_NONE; end;

	if beNormalFarmer
	then
		if bot:GetActiveMode() == BOT_MODE_ASSEMBLE then assembleTime = DotaTime(); end

		if DotaTime() - assembleTime < 15.0 then return BOT_MODE_DESIRE_NONE; end

		if J.IsTeamActivityCount(bot,3)	then return BOT_MODE_DESIRE_NONE; end
	end

	local madas = J.IsItemAvailable("item_hand_of_midas");
	if madas ~= nil and madas:IsFullyCastable() and J.IsInAllyArea(bot)
	then
		hLaneCreepList = bot:GetNearbyLaneCreeps(1600, true);
		if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end;
		return BOT_MODE_DESIRE_HIGH;
	end

	local generalFarmDesire = BOT_MODE_DESIRE_NONE
	local shouldGoFarmDuringLaning = J.ShouldGoFarmDuringLaning(bot)
	if GetGameMode() ~= GAMEMODE_MO
	and not bot:WasRecentlyDamagedByAnyHero(5)
	and not (J.Utils['GameStates']['defendPings'] and GameTime() - J.Utils['GameStates']['defendPings'].pingedTime < 5)
	and (
		shouldGoFarmDuringLaning
		or (
			(J.IsCore(bot) or (not J.IsCore(bot) and currentTime > 7 * 60 and currentTime < 35 * 60))
			and (J.GetCoresAverageNetworth() < 15000
				-- or (bot:GetLevel() >= 10 and J.GetHP(bot) > 0.8 and #bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE) <= 1 and #bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE) == 0 and J.GetDistanceFromAncient(bot, false) < 4000)
			)
			and (J.Site.IsTimeToFarm(bot) or pushTime > DotaTime() - 8.0)
			-- and (not J.Utils.IsHumanPlayerInTeam(GetTeam()) or enemyKills > allyKills + 16)
			-- and ( bot:GetNextItemPurchaseValue() > 0 or not bot:HasModifier("modifier_item_moon_shard_consumed") )
			and ( currentTime > 7 * 60 or bot:GetLevel() >= 8 or (bot:GetAttackRange() < 220 and bot:GetLevel() >= 6) ))
			-- and (not bot.isBear or (bot.isBear and GetUnitToUnitDistance(bot, Utils.GetLoneDruid(bot).hero) < 1100))
		)
	then
		if J.GetDistanceFromAllyFountain( bot ) - J.GetDistanceFromEnemyFountain(bot) > 2000
		and (GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetOpposingTeam(), LANE_TOP, 0)) < 800
			or GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetOpposingTeam(), LANE_MID, 0)) < 800
			or GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetOpposingTeam(), LANE_BOT, 0)) < 800)
		then
			if #hLaneCreepList > 0 then
				hLaneCreepList = {}
			end
			if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp);end
			if preferedCamp ~= nil then
				generalFarmDesire = BOT_MODE_DESIRE_ABSOLUTE
			end
		end;

		if #hLaneCreepList > 0
		then
			bot.farmLocation = J.GetCenterOfUnits(hLaneCreepList)
			generalFarmDesire = BOT_MODE_DESIRE_ABSOLUTE
		else
			if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp);end

			if preferedCamp ~= nil then
				if not J.Site.IsModeSuitableToFarm(bot)
				then
					preferedCamp = nil;
					generalFarmDesire = BOT_MODE_DESIRE_NONE;
				elseif (bot:GetHealth() <= 400 or J.GetHP(bot) < 0.4)
					then
						preferedCamp = nil;
						teamTime = DotaTime();
						generalFarmDesire = BOT_MODE_DESIRE_MODERATE
				elseif farmState == 1
				    then
						bot.farmLocation = preferedCamp.cattr.location
					    generalFarmDesire = BOT_MODE_DESIRE_ABSOLUTE;
				else

					if aliveEnemyCount >= 3
					then
						if pushTime > DotaTime() - 8.0
						then
							if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp);end
							bot.farmLocation = preferedCamp.cattr.location
							generalFarmDesire = BOT_MODE_DESIRE_MODERATE;
						end

						if J.IsPushing( bot )
						then
							local enemyAncient = GetAncient(GetOpposingTeam());
							local allies       = J.GetNearbyHeroes(bot,1400,false,BOT_MODE_NONE);
							local enemyAncientDistance = GetUnitToUnitDistance(bot,enemyAncient);
							if enemyAncientDistance < 2800
								and enemyAncientDistance > 1600
								and bot:GetActiveModeDesire() < BOT_MODE_DESIRE_HIGH
								and #allies <= 2
								and (#hEnemyHeroList >= #allies
									or numOfAliveEnemyHeroes > #allies)
							then
								pushTime = DotaTime();
								bot.farmLocation = preferedCamp.cattr.location
								generalFarmDesire =  BOT_MODE_DESIRE_ABSOLUTE * 0.93;
							end

							if beHighFarmer or bot:GetAttackRange() < 310
							then
								if bot:GetActiveModeDesire() <= BOT_MODE_DESIRE_MODERATE
									and enemyAncientDistance > 1600
									and enemyAncientDistance < 5800
									and #allies < 2
									and (#hEnemyHeroList >= #allies
										or numOfAliveEnemyHeroes > #allies)
								then
									pushTime = DotaTime();
									bot.farmLocation = preferedCamp.cattr.location
									generalFarmDesire = BOT_MODE_DESIRE_ABSOLUTE * 0.98;
								end
							end
						end
					end
					local farmDistance = GetUnitToLocationDistance(bot, preferedCamp.cattr.location);
					bot.farmLocation = preferedCamp.cattr.location
					generalFarmDesire = RemapValClamped(farmDistance, 6400, 600, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_ABSOLUTE)
				end
			end
		end
	end

	local nNeutrals = bot:GetNearbyNeutralCreeps(600)
	if nNeutrals and #nNeutrals >= 2 and bot:GetLevel() < 10 and not nNeutrals[1]:IsAncientCreep()
	then generalFarmDesire = generalFarmDesire * 0.3 end;

	generalFarmDesire = RemapValClamped(J.GetHP(bot), 0.2, 0.7, BOT_MODE_DESIRE_LOW, generalFarmDesire)
	return generalFarmDesire;
end

function OnStart()

end


function OnEnd()
	preferedCamp = nil;
	farmState = 0;
	hLaneCreepList  = {};
	runMode = false;
	runTime = 0;
	bot:SetTarget(nil);
end

function Think()
	if J.CanNotUseAction(bot) then return end

	if bot.lastFarmFrameProcessTime == nil then bot.lastFarmFrameProcessTime = DotaTime() end
	if DotaTime() - bot.lastFarmFrameProcessTime < bot.frameProcessTime then return end
	bot.lastFarmFrameProcessTime = DotaTime()

	local botAttackRange = bot:GetAttackRange();
	if runMode then
		if not bot:IsInvisible() and bot:GetLevel() >= 15
			and not bot:HasModifier('modifier_medusa_stone_gaze_facing')
		then
			if botAttackRange > 1400 then botAttackRange = 1400 end;
			local runModeAllies = J.GetNearbyHeroes(bot,900,false,BOT_MODE_NONE);
			local runModeEnemyHeroes = J.GetNearbyHeroes(bot,botAttackRange +50,true,BOT_MODE_NONE);
			local runModeTowers  = bot:GetNearbyTowers(240,true);
			local runModeBarracks  = bot:GetNearbyBarracks(botAttackRange +150,true);
			if J.IsValid(runModeEnemyHeroes[1])
				and #runModeAllies >= 2
				and not runModeEnemyHeroes[1]:IsAttackImmune()
				and botName ~= "npc_dota_hero_bristleback"
				and J.GetDistanceFromEnemyFountain(bot) > 2200
			then
				bot:Action_AttackUnit(runModeEnemyHeroes[1], true);
				return;
			end
			if J.IsValid(runModeBarracks[1])
				and not bot:WasRecentlyDamagedByAnyHero(1.0)
				and not runModeBarracks[1]:IsAttackImmune()
				and not runModeBarracks[1]:IsInvulnerable()
				and not runModeBarracks[1]:HasModifier("modifier_fountain_glyph")
				and not runModeBarracks[1]:HasModifier("modifier_invulnerable")
				and not runModeBarracks[1]:HasModifier("modifier_backdoor_protection_active")
			then
				bot:Action_AttackUnit(runModeBarracks[1], not J.Utils.HasValue(buggedFarmAttackHeroes, botName));
				return;
			end
		end
		if J.IsInAllyArea(bot) or J.GetDistanceFromEnemyFountain(bot) < 2600
		then
			if team == TEAM_RADIANT
			then
				bot:Action_MoveToLocation(RadiantBase);
				return;
			else
				bot:Action_MoveToLocation(DireBase);
				return;
			end
		else
			if team == TEAM_RADIANT
			then
			    local mLoc = J.GetLocationTowardDistanceLocation(bot,DireBase,-700);
				bot:Action_MoveToLocation(mLoc);
				return;
			else
			    local mLoc = J.GetLocationTowardDistanceLocation(bot,RadiantBase,-700);
				bot:Action_MoveToLocation(mLoc);
				return;
			end
		end
	end

	if hLaneCreepList ~= nil and #hLaneCreepList > 0 then
		local farmTarget = J.Site.GetFarmLaneTarget(hLaneCreepList);
		local nSearchRange = botAttackRange + 180
		if nSearchRange > 1600 then nSearchRange = 1600 end
		local nNeutrals = bot:GetNearbyNeutralCreeps(nSearchRange);
		if farmTarget ~= nil and #nNeutrals == 0 then
			local distanceToFarmTarget = GetUnitToUnitDistance(bot,farmTarget)
			if farmTarget:GetTeam() == team
			   and J.IsInAllyArea(farmTarget)
			   and distanceToFarmTarget > botAttackRange + 230
			then
				bot:Action_MoveToLocation(farmTarget:GetLocation() + RandomVector(200));
				return
			end
			if farmTarget:GetTeam() ~= team
			then
				--如果小兵正在被友方小兵攻击且生命值略高于自己的击杀线则S自己的出手
				local allyTower = bot:GetNearbyTowers(1000,true)[1];
				if bot:GetAttackTarget() == farmTarget
				   and ( J.GetAttackEnemysAllyCreepCount(farmTarget, 800) > 0
						   or ( allyTower ~= nil and allyTower:GetAttackTarget() == farmTarget ) )
				then
					local botDamage = bot:GetAttackDamage();
					local nDamageReduce = 1
					if bot:FindItemSlot("item_quelling_blade") > 0
						or bot:FindItemSlot("item_bfury") > 0
					then
						botDamage = botDamage + 13;
					end
					if not J.CanKillTarget(farmTarget, botDamage * nDamageReduce, DAMAGE_TYPE_PHYSICAL)
					   and J.CanKillTarget(farmTarget, (botDamage +99) * nDamageReduce, DAMAGE_TYPE_PHYSICAL)
					then
						bot:Action_ClearActions( true );
					    return
					end
				end
				if botAttackRange > 310
				then
					if distanceToFarmTarget > nSearchRange
					then
						bot:Action_MoveToLocation(farmTarget:GetLocation());
						return
					else
						bot:Action_AttackUnit(farmTarget, not J.Utils.HasValue(buggedFarmAttackHeroes, botName));
						return
					end
				else
					if ( distanceToFarmTarget > botAttackRange + 100 )
						or bot:GetAttackDamage() > 200
					then
						bot:Action_AttackUnit(hLaneCreepList[1], not J.Utils.HasValue(buggedFarmAttackHeroes, botName));
						return
					else
						bot:Action_AttackUnit(farmTarget, not J.Utils.HasValue(buggedFarmAttackHeroes, botName));
						return
					end
				end
			end
		end
	end
	if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp);end
	if preferedCamp ~= nil then
		local targetFarmLoc = preferedCamp.cattr.location;
		local cDist = GetUnitToLocationDistance(bot, targetFarmLoc);
		local nNeutrals = bot:GetNearbyNeutralCreeps(888);
		if #nNeutrals >= 3 and cDist <= 600 and cDist > 240
		   and ( bot:GetLevel() >= 10 or not nNeutrals[1]:IsAncientCreep())
		then farmState = 1 end;
		if farmState == 0
		   and ( J.IsValid(nNeutrals[1]) or #nNeutrals > 1)
		   and not J.IsRoshan(nNeutrals[1])
		   and ( bot:GetLevel() >= 10 or not nNeutrals[1]:IsAncientCreep())
		then
			if GetUnitToUnitDistance(bot,nNeutrals[1]) < bot:GetAttackRange() + 150
				and J.HasNotActionLast(4.0,'creep')
			then
				J.Role['availableCampTable'] = J.Site.UpdateCommonCamp(nNeutrals[1],J.Role['availableCampTable']);
			end

			local farmTarget = J.Site.FindFarmNeutralTarget(nNeutrals)
			if farmTarget ~= nil
			then
				bot:SetTarget(farmTarget);
				bot:Action_AttackUnit(farmTarget, not J.Utils.HasValue(buggedFarmAttackHeroes, botName));
				return;
			else
				bot:SetTarget(nNeutrals[1]);
				bot:Action_AttackUnit(nNeutrals[1], not J.Utils.HasValue(buggedFarmAttackHeroes, botName));
				return;
			end
		elseif farmState == 0 
				and #nNeutrals == 0
		        and cDist > 240
		        and ( not X.IsLocCanBeSeen(targetFarmLoc) or cDist > 600 )
			then
				bot:SetTarget(nil);
				if bot:GetLevel() >= 12
					 and J.Role.ShouldTpToFarm()
				then
					local mostFarmDesireLane,mostFarmDesire = J.GetMostFarmLaneDesire(bot);
					local tps = bot:GetItemInSlot(nTpSolt);
					local tpLoc = GetLaneFrontLocation(team,mostFarmDesireLane,0);
					local bestTpLoc = J.GetNearbyLocationToTp(tpLoc);
					local nAllies = J.GetAlliesNearLoc(tpLoc, 1400);
					if mostFarmDesire > BOT_MODE_DESIRE_VERYHIGH 
						and J.IsLocHaveTower(1850,false,tpLoc)
						and bestTpLoc ~= nil
						and #nAllies == 0
					then
						if tps ~= nil and tps:IsFullyCastable() 
						   and GetUnitToLocationDistance(bot,bestTpLoc) > 4200
						then
							preferedCamp = nil;
							J.Role['lastFarmTpTime'] = DotaTime();
							bot:Action_UseAbilityOnLocation(tps, bestTpLoc);
							return;
						end
					end
					local tBoots = J.IsItemAvailable("item_travel_boots_2");
					if tBoots == nil then tBoots = J.IsItemAvailable("item_travel_boots"); end;
					if tBoots ~= nil and tBoots:IsFullyCastable()
					then
						local tpLoc = GetLaneFrontLocation(team,mostFarmDesireLane,-600);
						local nAllies = J.GetAlliesNearLoc(tpLoc, 1600);
						if mostFarmDesire > BOT_MODE_DESIRE_HIGH * 1.12
						   and #nAllies == 0
						   and GetUnitToLocationDistance(bot,tpLoc) > 3500
						then
							preferedCamp = nil;
							J.Role['lastFarmTpTime'] = DotaTime();
							bot:Action_UseAbilityOnLocation(tBoots, tpLoc);
							return
						end
					end
				end
				if hLaneCreepList and hLaneCreepList[1]
				   and not hLaneCreepList[1]:IsNull()
				   and hLaneCreepList[1]:IsAlive()
				   and GetUnitToUnitDistance(bot, hLaneCreepList[1]) > botAttackRange
				then
					bot:Action_MoveToLocation( hLaneCreepList[1]:GetLocation() );
					return;
				end
				if X.CouldBlink(bot,targetFarmLoc) then return end;
				if X.CouldBlade(bot,targetFarmLoc) then return end;

				if (GetUnitToLocationDistance(bot, targetFarmLoc) > botAttackRange
				or (not hLaneCreepList or not J.IsValid(hLaneCreepList[1])))
				and IsLocationPassable(targetFarmLoc)
				then
					bot:Action_MoveToLocation(targetFarmLoc);
				end
				return;
		else
			local neutralCreeps = bot:GetNearbyNeutralCreeps(1000);
			if #neutralCreeps >= 2 then
				farmState = 1;
				local farmTarget = J.Site.FindFarmNeutralTarget(neutralCreeps)
				if farmTarget ~= nil
				then
					bot:SetTarget(farmTarget);
					bot:Action_AttackUnit(farmTarget, not J.Utils.HasValue(buggedFarmAttackHeroes, botName));
					return;
				end
			elseif ( X.IsLocCanBeSeen(targetFarmLoc) and cDist <= 600 ) or cDist <= 240
				then
					farmState = 0;
					J.Role['availableCampTable'], preferedCamp = J.Site.UpdateAvailableCamp(bot, preferedCamp, J.Role['availableCampTable']);
					availableCamp = J.Role['availableCampTable'];
					preferedCamp  = J.Site.GetClosestNeutralSpwan(bot, availableCamp);

					local farmTarget = J.Site.FindFarmNeutralTarget(neutralCreeps)
					if farmTarget ~= nil
					then
						bot:SetTarget(farmTarget);
						bot:Action_AttackUnit(farmTarget, not J.Utils.HasValue(buggedFarmAttackHeroes, botName));
						return;
					end
			else
				local farmTarget = J.Site.FindFarmNeutralTarget(neutralCreeps)
				if farmTarget ~= nil
				then
					bot:SetTarget(farmTarget);
					bot:Action_AttackUnit(farmTarget, not J.Utils.HasValue(buggedFarmAttackHeroes, botName));
					return;
				end

				bot:SetTarget(nil);
				if GetUnitToLocationDistance(bot, targetFarmLoc) > botAttackRange
				and IsLocationPassable(targetFarmLoc)
				then
					bot:Action_MoveToLocation(targetFarmLoc);
				else
					preferedCamp = nil
				end
			end
		end
	end

	bot:SetTarget(nil);
	bot:Action_MoveToLocation( ( RadiantBase + DireBase )/2 );
	return;
end

function X.IsThereT3Detroyed()
	
	local T3s = {
		TOWER_TOP_3,
		TOWER_MID_3,
		TOWER_BOT_3
	}
	
	for _,t in pairs(T3s) do
		local tower = GetTower(GetOpposingTeam(), t);
		if tower == nil or not tower:IsAlive() then
			return true;
		end
	end	
	return false;
end


function X.IsNearLaneFront( bot )
	local testDist = 1600;
	for _,lane in pairs(nLaneList)
	do
		local tFLoc = GetLaneFrontLocation(team, lane, 0);
		if GetUnitToLocationDistance(bot,tFLoc) <= testDist
		then
		    return true;
		end		
	end
	return false;
end


function X.IsUnitAroundLocation(vLoc, nRadius)
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil and J.Site.GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < 1.0 then
					return true;
				end
			end
		end
	end
	return false;
end

local enemyPids = nil;
function X.ShouldRun(bot)
	if bot:HasModifier('modifier_medusa_stone_gaze_facing')
	then
		return 2.5
	end

	if bot:IsChanneling()
	   or not bot:IsAlive()
	then
		return 0
	end

	local botLevel    = bot:GetLevel();
	local botTarget   = J.GetProperTarget(bot);
	local hEnemyHeroList = J.GetEnemyList(bot,1600);
	local hAllyHeroList  = J.GetAllyList(bot,1600);
	local enemyFountainDistance = J.GetDistanceFromEnemyFountain(bot);
	local enemyAncient = GetAncient(GetOpposingTeam());
	local enemyAncientDistance = GetUnitToUnitDistance(bot,enemyAncient);
	local aliveEnemyCount = J.GetNumOfAliveHeroes(true)
	local aliveAllyCount = J.GetNumOfAliveHeroes(false)
	local rushEnemyTowerDistance = 250;

	if enemyFountainDistance < 1560
	then
		return 2;
	end

	if bot:HasModifier('modifier_abyssal_underlord_firestorm_burn')
	and #hEnemyHeroList >= 1
	and J.IsValidHero(hEnemyHeroList[1] ) and J.GetHP(hEnemyHeroList[1]) > J.GetHP(bot) - 0.15
	and J.GetHP(bot) < 0.85 and J.GetHP(bot) > 0.2 -- don't block real retreat action
	then
		return 2
	end

	if bot:DistanceFromFountain() < 200
		and botActiveMode ~= BOT_MODE_RETREAT
		and ( J.GetHP(bot) + J.GetMP(bot) < 1.7 )
	then
		return 3;
	end

	if botLevel <= 4
		and enemyFountainDistance < 7666
	then
		return 3.33;
	end

	if botLevel < 6
		and DotaTime() > 30
		and DotaTime() < 8 * 60
		and enemyFountainDistance < 8111
	then
		if botTarget ~= nil and botTarget:IsHero()
		   and J.GetHP(botTarget) > 0.35
		   and (  not J.IsInRange(bot,botTarget,bot:GetAttackRange() + 150) 
				  or not J.CanKillTarget(botTarget, bot:GetAttackDamage() * 2.33, DAMAGE_TYPE_PHYSICAL) )
		then
			return 2.88;
		end
	end

	if bot:GetLevel() < 10
	   and bot:GetAttackDamage() < 133
	   and botTarget ~= nil
	   and botTarget:IsAncientCreep()
	   and #hAllyHeroList <= 1 
	   and bot:DistanceFromFountain() > 3000
	then
		bot:SetTarget(nil);
		return 6.21;
	end

	if not X.IsThereT3Detroyed()
	   and aliveEnemyCount >= 3
	   and #hAllyHeroList < aliveEnemyCount + 2
	   and #hAllyHeroList < aliveAllyCount - 1
	   and not J.Role.IsPvNMode()
	   and ( DotaTime() % 600 > 285 or DotaTime() < 18 * 60 )--处于夜间或小于18分钟
	then
		local allyLevel = J.GetAverageLevel(false);
		local enemyLevel = J.GetAverageLevel(true);
		if enemyFountainDistance < 4765
		then
			local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(550,false);
			if( allyLevel - 4 < enemyLevel and allyLevel < 24 )
			   and not ( allyLevel - 2 > enemyLevel and aliveEnemyCount == 3)
			   and #nAllyLaneCreeps <= 4
			then
				return 1.33;
			end
		end
	end

	-- 前期线上别顶着小兵打太凶
	if botLevel < 5
	and bot:WasRecentlyDamagedByCreep(1)
	and J.GetHP(bot) < 0.7
	and botTarget ~= nil
	and J.GetHP(botTarget) > J.GetHP(bot) - 0.15 then
		return 2;
	end

	local nEnemyTowers = bot:GetNearbyTowers(1000, true);
	local nEnemyBrracks = bot:GetNearbyBarracks(800,true);

	if #nEnemyBrracks >= 1
	and #hAllyHeroList < aliveEnemyCount + 2
	and #hAllyHeroList < aliveAllyCount - 1
	then
		if #nEnemyTowers >= 2
		   or enemyAncientDistance <= 1314
		   or enemyFountainDistance <= 2828
		then
			return 2;
		end
	end

	if J.IsValidHero(botTarget) and J.GetModifierTime( botTarget, "modifier_item_blade_mail_reflect" ) > 0.2
	and J.IsInRange(bot, botTarget, bot:GetAttackRange())
	and ((#hEnemyHeroList == 1 and bot:GetHealth() - botTarget:GetHealth() < 250)
		or (#hEnemyHeroList >=2 and bot:GetHealth() - botTarget:GetHealth() < 400))
	then
		return 1;
	end

	if #nEnemyTowers >= 1
	and enemyAncientDistance < 7000 then -- 推2塔或者高地不要无视防御符文下的防御塔
		local cloestTower = nEnemyTowers[1]
		if J.IsValidBuilding(cloestTower)
		and GetUnitToUnitDistance(cloestTower, bot) < 800
		and (cloestTower:HasModifier("modifier_fountain_glyph")
		or cloestTower:HasModifier("modifier_invulnerable")
		or cloestTower:HasModifier("modifier_backdoor_protection_active"))
		then
			return 1.2
		end
	end

	if J.IsValidBuilding(nEnemyTowers[1]) and botLevel < 20
	then
		if nEnemyTowers[1]:HasModifier("modifier_invulnerable") and aliveEnemyCount > 1
		then
			return 2.5;
		end

		if enemyAncientDistance > 2100
			and enemyAncientDistance < GetUnitToUnitDistance(nEnemyTowers[1],enemyAncient) - rushEnemyTowerDistance
		then
			local nTarget = J.GetProperTarget(bot);
			if nTarget == nil
			then
				return 3.9;
			end

			if J.IsValidHero(nTarget) and aliveEnemyCount > 2
			then
				local assistAlly = false;
				for _,ally in pairs(hAllyHeroList)
				do
					if GetUnitToUnitDistance(ally,nTarget) <= ally:GetAttackRange() + 100
						and (ally:GetAttackTarget() == nTarget or ally:GetTarget() == nTarget)
					then
						assistAlly = true;
						break;
					end
				end
				if not assistAlly
				then
					return 2.5;
				end
			end
		end
	end

	-- 前期谨慎冲塔
	if botLevel <= 10 and DotaTime() > 0
		and (#hEnemyHeroList > 0 or bot:GetHealth() < 700)
	then
		local nLongEnemyTowers = bot:GetNearbyTowers(1200, true);
		if bot:GetAssignedLane() == LANE_MID
		then
			 nLongEnemyTowers = bot:GetNearbyTowers(1100, true);
			 nEnemyTowers     = bot:GetNearbyTowers(980, true);
		end
		if ( botLevel <= 2 or DotaTime() < 2 * 60 )
			and nLongEnemyTowers[1] ~= nil
		then
			return 2;
		end
		if ( botLevel <= 4 or DotaTime() < 3 * 60 )
			and nEnemyTowers[1] ~= nil
		then
			return 2;
		end
		if botLevel <= 9
			and nEnemyTowers[1] ~= nil
			and nEnemyTowers[1]:CanBeSeen()
			and nEnemyTowers[1]:GetAttackTarget() == bot
			and #hAllyHeroList <= 1
		then
			return 2;
		end
	end

	local nLongEnemyTowers = bot:GetNearbyTowers(1600, true);
	if #nLongEnemyTowers >= 2
	and J.IsValidHero(botTarget)
	and (
		botLevel < botTarget:GetLevel() + 2
		or not J.CanKillTarget(botTarget, bot:GetAttackDamage() * 5, DAMAGE_TYPE_PHYSICAL)
	)
	and #hAllyHeroList <= aliveEnemyCount + 1
	and #hAllyHeroList < aliveAllyCount - 1
	then
		return 3
	end


	if bot:IsInvisible() and DotaTime() > 8 * 60
		and botActiveMode == BOT_MODE_RETREAT
		and bot:GetActiveModeDesire() > 0.4
		and #hAllyHeroList <= 1
		and J.IsValid(hEnemyHeroList[1])
		and bot:GetUnitName() ~= "npc_dota_hero_riki"
		and bot:GetUnitName() ~= "npc_dota_hero_bounty_hunter"
		and bot:GetUnitName() ~= "npc_dota_hero_slark"
		and J.GetDistanceFromAncient(bot,false) < J.GetDistanceFromAncient(hEnemyHeroList[1], false)
	then
		return 5;
	end

	if J.Utils.HasModifierContainsName(bot, "warlock_golem") then
		local nUnits = GetUnitList(UNIT_LIST_ENEMIES)
		for _, unit in pairs(nUnits)
		do
			if J.IsValid(unit)
			and J.IsInRange(bot, unit, unit:GetAttackRange() + 400)
			-- and string.find(unit:GetUnitName(), 'warlock_golem')
			then
				if (J.GetHP(bot) < J.GetHP(unit)
				and J.GetHP(bot) < 0.75)
				or J.GetHP(bot) < 0.5 then
					return 3
				end
			end
		end
	end

	if #hAllyHeroList <= 1
	   and botActiveMode ~= BOT_MODE_TEAM_ROAM
	   and botActiveMode ~= BOT_MODE_LANING
	   and botActiveMode ~= BOT_MODE_RETREAT
	   and ( botLevel <= 1 or botLevel > 5 )
	   and bot:DistanceFromFountain() > 1400
	then
		if enemyPids == nil then
			enemyPids = GetTeamPlayers(GetOpposingTeam())
		end
		local enemyCount = 0
		for i = 1, #enemyPids do
			local info = GetHeroLastSeenInfo(enemyPids[i])
			if info ~= nil then
				local dInfo = info[1]; 
				if dInfo ~= nil and dInfo.time_since_seen < 2.0
					and GetUnitToLocationDistance(bot,dInfo.location) < 1000
				then
					enemyCount = enemyCount +1;
				end
			end
		end
		if (enemyCount >= 4 or #hEnemyHeroList >= 4)
			and botActiveMode ~= BOT_MODE_ATTACK
			and botActiveMode ~= BOT_MODE_TEAM_ROAM
			and bot:GetCurrentMovementSpeed() > 300
		then
			local nNearByHeroes = bot:GetNearbyHeroes(700,true,BOT_MODE_NONE);
			if #nNearByHeroes < 2
	        then
				return 4;
			end
		end
		if botLevel >= 9 and botLevel <= 17
			and (enemyCount >= 3 or #hEnemyHeroList >= 3)
			and botActiveMode ~= BOT_MODE_LANING
			and bot:GetCurrentMovementSpeed() > 300
		then
			local nNearByHeroes = bot:GetNearbyHeroes(700,true,BOT_MODE_NONE);
			if #nNearByHeroes < 2
	        then
				return 3;
			end
		end
		if J.IsValid(enemy)
		and not J.WeAreStronger(bot, 800)
		then
			return 3;
		end
	end
	return 0
end



function X.CouldBlade(bot,nLocation) 
	local blade = J.IsItemAvailable("item_quelling_blade");
	if blade == nil then blade = J.IsItemAvailable("item_bfury"); end
	
	if blade ~= nil 
	   and blade:IsFullyCastable() 
	then
		local trees = bot:GetNearbyTrees(380);
		local dist = GetUnitToLocationDistance(bot,nLocation);
		local vStart = J.Site.GetXUnitsTowardsLocation(bot, nLocation, 32 );
		local vEnd  = J.Site.GetXUnitsTowardsLocation(bot, nLocation, dist - 32 );
		for _,t in pairs(trees)
		do
			if t ~= nil
			then
				local treeLoc = GetTreeLocation(t);
				local tResult = PointToLineDistance(vStart, vEnd, treeLoc);
				if tResult ~= nil 
				   and tResult.within 
				   and tResult.distance <= 96
				   and J.GetLocationToLocationDistance(treeLoc,nLocation) < dist / 2
				then
					bot:Action_UseAbilityOnTree(blade, t);
					return true;
				end
			end			
		end
	end
	
	return false;
end

function X.CouldBlink(bot,nLocation)
	local maxBlinkDist = 1199;
	local blink = J.IsItemAvailable("item_blink");
	
	if botName == "npc_dota_hero_antimage"
	then
		blink = bot:GetAbilityByName( "antimage_blink" );
		maxBlinkDist = blink:GetSpecialValueInt('AbilityCastRange')
	end
	
	if botName == "npc_dota_hero_queenofpain"
	then
		blink = bot:GetAbilityByName( "queenofpain_blink" );
		maxBlinkDist = J.GetProperCastRange(false, bot, blink:GetCastRange())
	end
	
	if blink ~= nil 
	   and blink:IsFullyCastable() 
       and J.IsRunning(bot)
	then
		local bDist = GetUnitToLocationDistance(bot,nLocation);
		local maxBlinkLoc = J.Site.GetXUnitsTowardsLocation(bot, nLocation, maxBlinkDist );
		if bDist <= 600  -- recommend by oyster 2019/4/16
		then
			return false;
		elseif bDist < maxBlinkDist +1
			then
				if botName == "npc_dota_hero_antimage"
				then
					bot:Action_ClearActions(true);
		
					if not J.IsPTReady(bot,ATTRIBUTE_INTELLECT) 
					then
						J.SetQueueSwitchPtToINT(bot);
					end
							
					bot:ActionQueue_UseAbilityOnLocation(blink, nLocation);
									
					return true;
				end
			
				bot:Action_UseAbilityOnLocation(blink, nLocation);
				return true;
		elseif IsLocationPassable(maxBlinkLoc)
			then
				
				if botName == "npc_dota_hero_antimage"
				then
					bot:Action_ClearActions(true);
		
					if not J.IsPTReady(bot,ATTRIBUTE_INTELLECT) 
					then
						J.SetQueueSwitchPtToINT(bot);
					end
							
					bot:ActionQueue_UseAbilityOnLocation(blink, maxBlinkLoc);
									
					return true;
				end
				
				bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc);
				return true;
		end
	end

	return false;
end

function X.IsLocCanBeSeen(vLoc)
	if GetUnitToLocationDistance(GetBot(),vLoc) < 180 then return true end

	local tempLocUp    = vLoc + Vector(5  ,0  );
	local tempLocDown  = vLoc + Vector(0  ,10 );
	local tempLocLeft  = vLoc + Vector(-15,0  );
	local tempLocRight = vLoc + Vector(0  ,-20);

	return IsLocationVisible(tempLocRight)
		   and IsLocationVisible(tempLocLeft)
	       and IsLocationVisible(tempLocUp)
		   and IsLocationVisible(tempLocDown)
end

--[[
all ai, all human, ai talk global
all ai, all ai, ai talk private
all ai, some ai, ai talk p
some ai, all human, ai talk g
some ai, all ai, ai talk p
some ai, some ai, ai talk p
all human, all ai, ai talk g
all human, some ai, ai talk g
]]--
function PickOneAnnouncer()
	if not hasPickedOneAnnouncer then
		for i, id in pairs(GetTeamPlayers(GetTeam())) do
			local hero = GetTeamMember(i)
			if hero ~= nil and hero.isAnnouncer then return end
		end
		bot.isAnnouncer = true
		hasPickedOneAnnouncer = true
		return
	end
end

function AnnounceMessages()
	if DotaTime() > 60 then return end

	local welcome_msgs = Localization.Get('welcome_msgs')
	if ((J.IsModeTurbo() and DotaTime() > -50 + team * 2) or (not J.IsModeTurbo() and DotaTime() > -75 + team * 2))
	and numberAnnouncePrinted < #welcome_msgs + 1
	and bot.isAnnouncer
	and DotaTime() < 0
	then
		if GameTime() - lastAnnouncePrintedTime >= announcementGap then
			local msg = welcome_msgs[numberAnnouncePrinted]
			local isFirstLine = numberAnnouncePrinted == 1
			if msg then
				bot:ActionImmediate_Chat(isFirstLine and msg .. Version.number or msg, nB == 0 or isFirstLine)
			end
			numberAnnouncePrinted = numberAnnouncePrinted + 1
			lastAnnouncePrintedTime = GameTime()
		end
	end

	if GetGameMode() ~= GAMEMODE_1V1MID and GetGameState() == GAME_STATE_PRE_GAME and bot.isBear == nil
	and (bot.announcedRole == nil or bot.announcedRole ~= J.GetPosition(bot)) then
		bot.announcedRole = J.GetPosition(bot)
		if GetTeam() == TEAM_DIRE then
			-- broken for 7.38 for now.
			return
		end
		bot:ActionImmediate_Chat(Localization.Get('say_play_pos')..J.GetPosition(bot), false)
	end
	if GetGameMode() ~= GAMEMODE_1V1MID
	and not isChangePosMessageDone
	and bot.isAnnouncer
	then
		local nH, nB = J.NumHumanBotPlayersInTeam()
		if DotaTime() >= 0 and nH > 0 and nB > 0
		then
			bot:ActionImmediate_Chat(Localization.Get('pos_select_closed'), true)
			isChangePosMessageDone = true
		end
	end
end

X.GetDesire = GetDesire
X.Think = Think
return X