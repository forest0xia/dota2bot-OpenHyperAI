local Utils = require( GetScriptDirectory()..'/FunLib/utils' )

if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return;
end

local bot = GetBot();
local X = {}
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local RB = Vector(-7174.000000, -6671.00000, 0.000000)
local DB = Vector(7023.000000, 6450.000000, 0.000000)

local botName = bot:GetUnitName();
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

local isWelcomeMessageDone = false
local isChangePosMessageDone = false

if bot.farmLocation == nil then bot.farmLocation = bot:GetLocation() end

function GetDesire()
	if GetGameMode() ~= GAMEMODE_CM then
		if GetGameState() == GAME_STATE_PRE_GAME
		and (bot.announcedRole == nil or bot.announcedRole ~= J.GetPosition(bot)) then
			bot.announcedRole = J.GetPosition(bot)
			bot:ActionImmediate_Chat('I will play position '..J.GetPosition(bot), false)
		end
	
		if not isWelcomeMessageDone
		and J.GetPosition(bot) == 5
		then
			if J.IsModeTurbo() and DotaTime() > -45 or DotaTime() > -55
			then
				bot:ActionImmediate_Chat("You can type !pos X to swap position with a bot. For example, type: `!pos 2` to go mid lane.", false)
				isWelcomeMessageDone = true
			end
		end
	
		if not isChangePosMessageDone
		and J.GetPosition(bot) == 5
		then
			local nH, nB = J.NumHumanBotPlayersInTeam()
			if DotaTime() >= 0 and nH > 0 and nB > 0
			then
				bot:ActionImmediate_Chat("Position selection closed.", true)
				isChangePosMessageDone = true
			end
		end
	end

	if not bInitDone
	then
		bInitDone = true
		beNormalFarmer = J.GetPosition(bot) == 3
		beHighFarmer = J.GetPosition(bot) == 2
		beVeryHighFarmer = J.GetPosition(bot) == 1
	end
	
	-- if bot.isBuggyHero == nil then
	-- 	bot.isBuggyHero = Utils.BuggyHeroesDueToValveTooLazy[bot:GetUnitName()] ~= nil
	-- end
	-- if bot.isBuggyHero and DotaTime() < 0.5 * 60
	-- then
	-- 	return 0.369
	-- end

	-- local nMode = bot:GetActiveMode()
	-- local nModeDesire = bot:GetActiveModeDesire()
	-- if  (nMode == BOT_MODE_DEFEND_TOWER_TOP or nMode == BOT_MODE_DEFEND_TOWER_MID or nMode == BOT_MODE_DEFEND_TOWER_BOT)
	-- and nModeDesire > BOT_MODE_DESIRE_MODERATE
    -- then
    --     return BOT_ACTION_DESIRE_NONE
    -- end

	local TormentorLocation = J.GetTormentorLocation(GetTeam())
	local nNeutralCreeps = bot:GetNearbyNeutralCreeps(700)
	for _, c in pairs(nNeutralCreeps)
	do
		local nInRangeAlly = J.GetAlliesNearLoc(TormentorLocation, 700)
		if  c ~= nil
		and (c:GetUnitName() == "npc_dota_miniboss" and nInRangeAlly ~= nil and #nInRangeAlly >= 2)
		then
			return BOT_ACTION_DESIRE_NONE
		end
	end

	-- 如果在打高地 就别撤退去打钱了
	local nAllyList = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE);
	if #nAllyList >= 2 and GetUnitToLocationDistance(bot, J.GetEnemyFountain()) < 2000 then
		return BOT_MODE_DESIRE_NONE;
	end
	-- 如果在打推塔 就别撤退去打钱了
	local nEnemyTowers = bot:GetNearbyTowers(1200, true);
	if #nAllyList >= 2 and nEnemyTowers ~= nil and #nEnemyTowers > 0 and GetUnitToLocationDistance(bot, nEnemyTowers[1]:GetLocation()) < 1300 then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
	if bot:IsAlive() --For sometime to run
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
	
	if DotaTime() < 50 then return 0.0 end
	
	if X.IsUnitAroundLocation(GetAncient(GetTeam()):GetLocation(), 3000) then
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
	
	local hEnemyHeroList = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE);
	local hNearbyAttackAllyHeroList  = J.GetNearbyHeroes(bot,1600, false,BOT_MODE_ATTACK);
	
	if #hEnemyHeroList > 0 or #hNearbyAttackAllyHeroList > 0
	then
		return BOT_MODE_DESIRE_NONE;
	end	

	local nAttackAllys = J.GetSpecialModeAllies(bot,1600,BOT_MODE_ATTACK);
	if #nAttackAllys > 0 and (not beVeryHighFarmer or bot:GetLevel() >= 16)
	then
		return BOT_MODE_DESIRE_NONE;
	end	
	
	local nRetreatAllyList = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_RETREAT);
	if J.IsValid(nRetreatAllyList[1]) and (not beVeryHighFarmer or bot:GetLevel() >= 16)
	   and nRetreatAllyList[1]:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	local nTeamFightLocation = J.GetTeamFightLocation(bot);
	if nTeamFightLocation ~= nil 
	   and ( not beVeryHighFarmer or bot:GetLevel() >= 15 )
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

	if  bot:IsAlive()
	and J.IsMeepoClone(bot)
	then
		if J.IsDoingRoshan(bot)
		then
			local botTarget = bot:GetAttackTarget()

			if  J.IsRoshan(botTarget)
			and J.IsInRange(bot, botTarget, 400)
			and J.GetHP(botTarget) < 0.33
			then
				if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end

		if nMode == BOT_MODE_ITEM
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
				bot:ActionImmediate_Chat("We estimate that the probability of winning is less than 1%, so we are resigned to losing! Well played! ",true);
			else
				bot:ActionImmediate_Chat("We estimate the probability of winning to be below 1%.Well played!",true);
			end
		end
		if allyKills > enemyKills + nWinCount and J.Role.NotSayRate() 
		then
		    J.Role['sayRate'] = true;
			if RandomInt(1,6) < 3 
			then
				bot:ActionImmediate_Chat("We estimate that the probability of winning a team battle is over 90%",true);
			else
				bot:ActionImmediate_Chat("We estimate the probability of winning to above 90%.",true);
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

	if GetGameMode() ~= GAMEMODE_MO 
	and (J.Site.IsTimeToFarm(bot) or pushTime > DotaTime() - 8.0)
	-- and J.Site.IsTimeToFarm(bot)
	-- and (not J.IsHumanPlayerInTeam() or enemyKills > allyKills + 16)
	-- and ( bot:GetNextItemPurchaseValue() > 0 or not bot:HasModifier("modifier_item_moon_shard_consumed") )
	-- and ( DotaTime() > 7 * 60 or bot:GetLevel() >= 8 or ( bot:GetAttackRange() < 220 and bot:GetLevel() >= 6 ) )	   
	and not J.IsInLaningPhase()
	then
		if J.GetDistanceFromEnemyFountain(bot) > 4000 
		then
			hLaneCreepList = bot:GetNearbyLaneCreeps(1600, true);
			if #hLaneCreepList == 0	
			   and J.IsInAllyArea( bot )
			   and X.IsNearLaneFront( bot )
			then
				hLaneCreepList = bot:GetNearbyLaneCreeps(1600, false);
			end
		end;		
		
		if #hLaneCreepList > 0 
		then
			bot.farmLocation = J.GetCenterOfUnits(hLaneCreepList)
			return BOT_MODE_DESIRE_HIGH;
		else
			if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp);end
			
			if preferedCamp ~= nil then
				if not J.Site.IsModeSuitableToFarm(bot) 
				then 
					preferedCamp = nil;
					return BOT_MODE_DESIRE_NONE;
				elseif bot:GetHealth() <= 200 
					then 
						preferedCamp = nil;
						teamTime = DotaTime();
						return BOT_MODE_DESIRE_VERYLOW;
				elseif farmState == 1
				    then 
						bot.farmLocation = preferedCamp.cattr.location
					    return BOT_MODE_DESIRE_ABSOLUTE *0.89;
				else
					
					if aliveEnemyCount >= 3
					then
						if pushTime > DotaTime() - 8.0
						then
							if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp);end
							bot.farmLocation = preferedCamp.cattr.location
							return BOT_MODE_DESIRE_MODERATE;
						end
						
						if bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
							or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
							or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
						then
							local enemyAncient = GetAncient(GetOpposingTeam());
							local allies       = J.GetNearbyHeroes(bot,1400,false,BOT_MODE_NONE);
							local enemyAncientDistance = GetUnitToUnitDistance(bot,enemyAncient);
							if enemyAncientDistance < 2800
								and enemyAncientDistance > 1600
								and bot:GetActiveModeDesire() < BOT_MODE_DESIRE_HIGH
								and #allies < 2
							then
								pushTime = DotaTime();
								bot.farmLocation = preferedCamp.cattr.location
								return  BOT_MODE_DESIRE_ABSOLUTE *0.93;
							end
							
							if beHighFarmer or bot:GetAttackRange() < 310
							then
								if  bot:GetActiveModeDesire() <= BOT_MODE_DESIRE_MODERATE 
									and enemyAncientDistance > 1600
									and enemyAncientDistance < 5800
									and #allies < 2
								then
									pushTime = DotaTime();
									bot.farmLocation = preferedCamp.cattr.location
									return  BOT_MODE_DESIRE_ABSOLUTE *0.98;
								end
							end
						
						end
					end
					
					local farmDistance = GetUnitToLocationDistance(bot,preferedCamp.cattr.location);
					
					if botName == 'npc_dota_hero_medusa' and farmDistance < 133 then return 0.33 end 
					bot.farmLocation = preferedCamp.cattr.location
					return math.floor((RemapValClamped(farmDistance, 6000, 0, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_VERYHIGH))*10)/10;
				end
			end
		end
	end
	
	return BOT_MODE_DESIRE_NONE;
	
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


local FrameProcessTime = 0.08
function Think()
	if J.CanNotUseAction(bot) then return end

	if bot.lastFarmFrameProcessTime == nil then bot.lastFarmFrameProcessTime = DotaTime() end
	if DotaTime() - bot.lastFarmFrameProcessTime < FrameProcessTime then return end
	bot.lastFarmFrameProcessTime = DotaTime()


	-- if bot.isBuggyHero == nil then
	-- 	bot.isBuggyHero = Utils.BuggyHeroesDueToValveTooLazy[bot:GetUnitName()] ~= nil
	-- end
	-- if bot.isBuggyHero and DotaTime() < 0.5 * 60
	-- then
	-- 	local mostFarmDesireLane = bot:GetAssignedLane();
	-- 	local tpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,0);
	-- 	bot:Action_MoveToLocation(tpLoc);
	-- 	return
	-- end

	-- if bot.isBuggyHero == nil then
	-- 	bot.isBuggyHero = J.Utils.BuggyHeroesDueToValveTooLazy[bot:GetUnitName()] ~= nil
	-- end
	-- if bot.isBuggyHero and DotaTime() < 3 * 60
	-- then
	-- 	local closestHero, closestHeroDistance = J.GetClosestAllyHero(bot)
	-- 	if closestHeroDistance > 800 then
	-- 		bot:Action_ClearActions(true);
	-- 		bot:ActionQueue_AttackMove(closestHero:GetLocation())
	-- 		print('[ERROR] Relocating the buggy bot: '..botName..'. Sending it to the lane# it was originally assigned: '..tostring(bot:GetAssignedLane()))
	-- 	end

		-- local laningLoc = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
		-- local diffDistance = J.GetLocationToLocationDistance( laningLoc, bot:GetLocation())
		-- if diffDistance > 1500 then
		-- 	bot:Action_ClearActions(true);
		-- 	bot:ActionQueue_AttackMove(laningLoc)
		-- 	-- print('[ERROR] Relocating the buggy bot: '..botName..'. Sending it to the lane# it was originally assigned: '..tostring(bot:GetAssignedLane()))
		-- 	return
		-- end
	-- end
	
	if runMode then
	
		if not bot:IsInvisible() and bot:GetLevel() >= 15
			and not bot:HasModifier('modifier_medusa_stone_gaze_facing')
		then
			local botAttackRange = bot:GetAttackRange();
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
				bot:Action_AttackUnit(runModeBarracks[1], true);
				return;
			end			
		end
	
		if J.IsInAllyArea(bot) or J.GetDistanceFromEnemyFountain(bot) < 2600
		then	
			if bot:GetTeam() == TEAM_RADIANT
			then
				bot:Action_MoveToLocation(RB);
				return;
			else
				bot:Action_MoveToLocation(DB);
				return;
			end
		else
			if bot:GetTeam() == TEAM_RADIANT
			then
			    local mLoc = J.GetLocationTowardDistanceLocation(bot,DB,-700);
				bot:Action_MoveToLocation(mLoc);
				return;
			else
			    local mLoc = J.GetLocationTowardDistanceLocation(bot,RB,-700);
				bot:Action_MoveToLocation(mLoc);
				return;
			end		
		end
	end
	
		
	if hLaneCreepList ~= nil and #hLaneCreepList > 0 then
		local farmTarget = J.Site.GetFarmLaneTarget(hLaneCreepList);
		local nSearchRange = bot:GetAttackRange() + 180
		if nSearchRange > 1600 then nSearchRange = 1600 end
		local nNeutrals = bot:GetNearbyNeutralCreeps(nSearchRange);
		if farmTarget ~= nil and #nNeutrals == 0 then
						
			if farmTarget:GetTeam() == bot:GetTeam() 
			   and J.IsInAllyArea(farmTarget)
			then
				bot:Action_MoveToLocation(farmTarget:GetLocation() + RandomVector(300));
				return
			end
			
			if farmTarget:GetTeam() ~= bot:GetTeam()
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
			
				if bot:GetAttackRange() > 310 
				then
					if GetUnitToUnitDistance(bot,farmTarget) > bot:GetAttackRange() + 180
					then
						bot:Action_MoveToLocation(farmTarget:GetLocation());
						return
					else
						bot:Action_AttackUnit(farmTarget, true);
						return
					end
				else
					if ( GetUnitToUnitDistance(bot,farmTarget) > bot:GetAttackRange() + 100 )
						or bot:GetAttackDamage() > 200
					then
						bot:Action_AttackUnit(hLaneCreepList[1], true);
						return
					else
						bot:Action_AttackUnit(farmTarget, true);
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
				bot:Action_AttackUnit(farmTarget, true);
				return;
			else
				bot:SetTarget(nNeutrals[1]);
				bot:Action_AttackUnit(nNeutrals[1], true);
				return;
			end
			
		elseif  farmState == 0 
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
					local tpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,0);
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
						local tpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,-600);
						local nAllies = J.GetAlliesNearLoc(tpLoc, 1600);
						if mostFarmDesire > BOT_MODE_DESIRE_HIGH * 1.12		
						   and #nAllies == 0
						   and GetUnitToLocationDistance(bot,tpLoc) > 3500
						then
							preferedCamp = nil;
							J.Role['lastFarmTpTime'] = DotaTime();
							bot:Action_UseAbilityOnLocation(tBoots, tpLoc);
							return;							
						end
					end					
				end
				
				if hLaneCreepList[1] ~= nil 
				   and not hLaneCreepList[1]:IsNull() 
				   and hLaneCreepList[1]:IsAlive() 
				then
					bot:Action_MoveToLocation( hLaneCreepList[1]:GetLocation() );
					return;
				end
				
				if X.CouldBlink(bot,targetFarmLoc) then return end;
				
				if X.CouldBlade(bot,targetFarmLoc) then return end;
							
				bot:Action_MoveToLocation(targetFarmLoc);
				return;
		else
			local neutralCreeps = bot:GetNearbyNeutralCreeps(1000); 
			
			if #neutralCreeps >= 2 then
				
				farmState = 1;
				
				local farmTarget = J.Site.FindFarmNeutralTarget(neutralCreeps)
				if farmTarget ~= nil 
				then
					bot:SetTarget(farmTarget);
					bot:Action_AttackUnit(farmTarget, true);
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
						bot:Action_AttackUnit(farmTarget, true);
						return;
					end
			else
			
				local farmTarget = J.Site.FindFarmNeutralTarget(neutralCreeps)
				if farmTarget ~= nil 
				then
					bot:SetTarget(farmTarget);
					bot:Action_AttackUnit(farmTarget, true);
					return;
				end
				
				bot:SetTarget(nil);
				
				if cDist > 200 then bot:Action_MoveToLocation(targetFarmLoc) return end
			end
		end			
	end
	
	
	
	bot:SetTarget(nil);
	bot:Action_MoveToLocation( ( RB + DB )/2 );
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
		local tFLoc = GetLaneFrontLocation(GetTeam(), lane, 0);
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
		return 3.33
	end

		
	if bot:IsChanneling() 
	   or not bot:IsAlive()
	then
		return 0
	end	   
	
	local botLevel    = bot:GetLevel();
	local botMode     = bot:GetActiveMode();
	local botTarget   = J.GetProperTarget(bot);
	local hEnemyHeroList = J.GetEnemyList(bot,1600);
	local hAllyHeroList  = J.GetAllyList(bot,1600);
	local enemyFountainDistance = J.GetDistanceFromEnemyFountain(bot);
	local enemyAncient = GetAncient(GetOpposingTeam());
	local enemyAncientDistance = GetUnitToUnitDistance(bot,enemyAncient);
	local aliveEnemyCount = J.GetNumOfAliveHeroes(true)
	local rushEnemyTowerDistance = 250;
	
		
	if enemyFountainDistance < 1560
	then
		return 2;
	end
	
	if bot:DistanceFromFountain() < 200
		and botMode ~= BOT_MODE_RETREAT
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
	
	local nEnemyTowers = bot:GetNearbyTowers(898, true);
	local nEnemyBrracks = bot:GetNearbyBarracks(800,true);
	
	if #nEnemyBrracks >= 1 and aliveEnemyCount >= 2
	then
		if #nEnemyTowers >= 2
		   or enemyAncientDistance <= 1314
		   or enemyFountainDistance <= 2828
		then
			return 2;
		end
	end
	

	if nEnemyTowers[1] ~= nil and botLevel < 20
	then
		if nEnemyTowers[1]:HasModifier("modifier_invulnerable") and aliveEnemyCount > 1
		then
			return 2.5;
		end
		
		if  enemyAncientDistance > 2100
			and enemyAncientDistance < GetUnitToUnitDistance(nEnemyTowers[1],enemyAncient) - rushEnemyTowerDistance
		then
			local nTarget = J.GetProperTarget(bot);
			if nTarget == nil
			then
				return 3.9;
			end
			
			if nTarget ~= nil and nTarget:IsHero() and aliveEnemyCount > 2
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
	

	if  botLevel <= 10
		and (#hEnemyHeroList > 0 or bot:GetHealth() < 700)
	then
		local nLongEnemyTowers = bot:GetNearbyTowers(999, true);
		if bot:GetAssignedLane() == LANE_MID 
		then 
			 nLongEnemyTowers = bot:GetNearbyTowers(988, true); 
			 nEnemyTowers     = bot:GetNearbyTowers(966, true); 
		end
		if ( botLevel <= 2 or DotaTime() < 2 * 60 )
			and nLongEnemyTowers[1] ~= nil
		then
			return 1;
		end	
		if ( botLevel <= 4 or DotaTime() < 3 * 60 )
			and nEnemyTowers[1] ~= nil
		then
			return 1;
		end	
		if botLevel <= 9
			and nEnemyTowers[1] ~= nil
			and nEnemyTowers[1]:CanBeSeen()
			and nEnemyTowers[1]:GetAttackTarget() == bot
			and #hAllyHeroList <= 1
		then
			return 1;
		end
	end
	
	if  bot:IsInvisible() and DotaTime() > 8 * 60
		and botMode == BOT_MODE_RETREAT
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

	if #hAllyHeroList <= 1 
	   and botMode ~= BOT_MODE_TEAM_ROAM
	   and botMode ~= BOT_MODE_LANING
	   and botMode ~= BOT_MODE_RETREAT
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
			and botMode ~= BOT_MODE_ATTACK
			and botMode ~= BOT_MODE_TEAM_ROAM
			and bot:GetCurrentMovementSpeed() > 300
		then
			local nNearByHeroes = J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE);
			if #nNearByHeroes < 2
	        then
				return 4;
			end
		end	
		if  botLevel >= 9 and botLevel <= 17  
			and (enemyCount >= 3 or #hEnemyHeroList >= 3) 
			and botMode ~= BOT_MODE_LANING
			and bot:GetCurrentMovementSpeed() > 300
		then
			local nNearByHeroes = J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE);
			if #nNearByHeroes < 2
	        then
				return 3;
			end
		end	
		
		if J.IsValid(enemy)
		and not J.WeAreStronger(bot, 800)
		then
			-- and enemy:GetUnitName() == "npc_dota_hero_necrolyte"
			-- and enemy:GetMana() >= 200
			-- and J.GetHP(bot) < 0.45
			-- and enemy:IsFacingLocation(bot:GetLocation(),20)
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
				   and J.GetLocationToLocationDistance(treeLoc,nLocation) < dist
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

function X.SetPushBonus( bot )

	if not GetTeamMember(1):IsBot()	then return end
	
	local bonusType = nil
	
	if pcall( require,  'bot_bonus' )
	then
		bonusType = require( 'bot_bonus' )
	end	
	
	if bonusType == nil	then return	end
	
	local bonusNoticeTable = {	
	
		["7.31Y3"] = "大神, 当前挑战的是三倍金钱经验夜魇AI.",
		["7.31T3"] = "大神, 当前挑战的是三倍金钱经验天辉AI.",
		["7.31Y2"] = "勇士, 当前挑战的是双倍金钱经验夜魇AI.",
		["7.31T2"] = "勇士, 当前挑战的是双倍金钱经验天辉AI.",
		["7.31Y1.5"] = "少侠, 当前挑战的是1.5倍金钱经验夜魇AI.",
				
	}
	
	if bonusNoticeTable[bonusType] ~= nil
	then
		bot:ActionImmediate_Chat( bonusNoticeTable[bonusType], true )
		return
	else
		bot:ActionImmediate_Chat("Hello, I am currently challenging other experts to customize multiplier AI.", true)
		return
	end
	
end

X.GetDesire = GetDesire
X.Think = Think
return X