----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return;
end

local bot = GetBot();
local bDebugMode = ( 1 == 10 )
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


local t3Destroyed = false;


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

local sBotVersion,sVersionDate = J.Role.GetBotVersion();

local bPushNoticeDone = false;
local bAllNotice = true;
local nPushNoticeTime = nil;

local nLobbyNoticeTime = -90

if J.Role.IsPvNMode()
then
	sVersionDate = sVersionDate.." (3V5)"
end


local sNoticeList = {
	
	[1] = "GL HF!",
	[2] = "Enjoy the game <3",
	
}

local hasTestDone = false


function GetDesire()	



	--设置夜魇方公告延迟 
	if not bPushNoticeDone
	   and DotaTime() < 0
	   and GetTeam() == TEAM_DIRE
	   and bot == GetTeamMember(5)
	   and GetTeamPlayers(GetOpposingTeam())[5] ~= nil
	   and IsPlayerBot( GetTeamPlayers(GetOpposingTeam())[5])
	   and nPushNoticeTime == nil
	then
		nPushNoticeTime = DotaTime();
		bAllNotice = false
	end
	
	
	--播放开局公告
	if not bPushNoticeDone
	   and DotaTime() < 0
	   and bot:GetGold() < 300 
	   and bot == GetTeamMember(5)
	   and (GetTeam() ~= TEAM_DIRE 
	         or nPushNoticeTime == nil
			 or nPushNoticeTime + 2.0 < DotaTime())
	then
	
		local sPushVersion = "随机搭配"
		if sBotVersion == "New" then sPushVersion = "固定搭配" end 
		local firstMessage = "(QQ交流群:877599588)天地星AI: "..sPushVersion..sVersionDate		
		local secondMessage = firstMessage
		

		if J.Role.GetKeyType() ~= 0
		then
			local sKeyType = J.Role.GetKeyType()
			local sUserName = J.Role.GetUserName()
			-- firstMessage = J.Chat.GetLocalWord(sKeyType)..sVersionDate
			if sUserName ~= "" and sUserName ~= " " and sUserName ~= "   " and sUserName ~= nil  
			then
				firstMessage = sUserName
			end
		end	
		
		-- bot:ActionImmediate_Chat( firstMessage, true)
		
		if firstMessage ~= secondMessage and GetTeamMember( 1 ):IsBot()
		then
			local sKeyType = J.Role.GetKeyType()
			local sUserName = J.Role.GetUserName()
			secondMessage = J.Chat.GetLocalWord(sKeyType)..sVersionDate
			bot:ActionImmediate_Chat( secondMessage, true)
		end
		
		if not J.Role.IsUserMode()
		then
			if bAllNotice
			then			
				-- bot:ActionImmediate_Chat("AI游戏群:459875234, 加群和其他玩家一起挑战多倍难度.",true);
	
			else
				local sNoticeMessage = sNoticeList[RandomInt(1,#sNoticeList)]
				bot:ActionImmediate_Chat(sNoticeMessage,true);
			end
		end		
		
		--夜魇方推送提示
		if GetTeam() == TEAM_DIRE
		then
			if J.Role.IsWillPastKey()
			then
				bot:ActionImmediate_Chat("当前使用的锦囊包即将停止更新修复.",true);
			elseif J.Role.IsPastKey()
			then
				bot:ActionImmediate_Chat("当前使用的锦囊包已经停止更新修复.",true);			
			end		
		end	

		X.SetPushBonus( bot )
		
		bPushNoticeDone = true
	end
	
	
	--播放创建房间提示
	if DotaTime() < 100
		and nLobbyNoticeTime < DotaTime() - 15.0
		and bot == GetTeamMember(5)
		and GetTeam() == TEAM_DIRE
		and not J.Role["bLobbyGame"]
		and GetGameMode() == GAMEMODE_AP
	then
		local sVersion = J.Role.GetBotVersion()
		if sVersion == "New" or sVersion == "Mid"
		then
			bot:ActionImmediate_Chat("提示:由于没有通过创建比赛房间来使用AI, 大部分英雄会失效(客户端的BUG), 请不要直接在主界面开始机器人练习.", true);
			nLobbyNoticeTime = DotaTime()
		end
	end

	-------------#############---------
	--if true then return 0 end
	-----------------------------------
	
	if not bInitDone
	then
		bInitDone = true
		beNormalFarmer = X.IsNormalFarmer(bot);
		beHighFarmer = X.IsHighFarmer(bot);
		beVeryHighFarmer = X.IsVeryHighFarmer(bot);
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
	
	local hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	local hNearbyAttackAllyHeroList  = bot:GetNearbyHeroes(1600, false,BOT_MODE_ATTACK);
	
	
	if #hEnemyHeroList > 0 or #hNearbyAttackAllyHeroList > 0
	then
		return BOT_MODE_DESIRE_NONE;
	end	

	local nAttackAllys = J.GetSpecialModeAllies(bot,2600,BOT_MODE_ATTACK);
	if #nAttackAllys > 0 and (not beVeryHighFarmer or bot:GetLevel() >= 18)
	then
		return BOT_MODE_DESIRE_NONE;
	end	
	
	local nRetreatAllyList = bot:GetNearbyHeroes(1600,false,BOT_MODE_RETREAT);
	if J.IsValid(nRetreatAllyList[1]) and (not beVeryHighFarmer or bot:GetLevel() >= 22)
	   and nRetreatAllyList[1]:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	local nTeamFightLocation = J.GetTeamFightLocation(bot);
	if nTeamFightLocation ~= nil 
	   and ( not beVeryHighFarmer or bot:GetLevel() >= 20 )
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
				bot:ActionImmediate_Chat("我们预估获胜的概率低于百分之一,甘拜下风! Well played! ",true);
			else
				bot:ActionImmediate_Chat("We estimate the probability of winning to be below 1%.Well played!",true);
			end
		end
		if allyKills > enemyKills + nWinCount and J.Role.NotSayRate() 
		then
		    J.Role['sayRate'] = true;
			if RandomInt(1,6) < 3 
			then
				bot:ActionImmediate_Chat("我们预估团战获胜的概率在百分之九十以上。",true);
			else
				bot:ActionImmediate_Chat("We estimate the probability of winning to above 90%.",true);
			end
		end
	
	end
	if allyKills > enemyKills + 20 and aliveAllyCount >= 4
	then return BOT_MODE_DESIRE_NONE; end
	
	local nAlliesCount = J.GetAllyCount(bot,1400);
	if nAlliesCount >= 4
	   or (bot:GetLevel() >= 23 and nAlliesCount >= 3)
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
		
		if #nNeutrals == 0 and #nDefendAllies >= 2 and (not beVeryHighFarmer or bot:GetLevel() >= 15)
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
	   and ( J.Site.IsTimeToFarm(bot) )
	   and ( not X.IsHumanPlayerInTeam() or enemyKills > allyKills + 16 ) 
	   and ( bot:GetNextItemPurchaseValue() > 0 or not bot:HasModifier("modifier_item_moon_shard_consumed") )
	   and ( DotaTime() > 7 * 60 or bot:GetLevel() >= 8 or ( bot:GetAttackRange() < 220 and bot:GetLevel() >= 6 ) )	   
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
					    return BOT_MODE_DESIRE_ABSOLUTE *0.89;
				else
					
					if aliveEnemyCount >= 3
					then
						if pushTime > DotaTime() - 8.0
						then
							if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp);end
							return BOT_MODE_DESIRE_MODERATE;
						end
						
						if bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
							or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
							or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
						then
							local enemyAncient = GetAncient(GetOpposingTeam());
							local allies       = bot:GetNearbyHeroes(1400,false,BOT_MODE_NONE);
							local enemyAncientDistance = GetUnitToUnitDistance(bot,enemyAncient);
							if enemyAncientDistance < 2800
								and enemyAncientDistance > 1600
								and bot:GetActiveModeDesire() < BOT_MODE_DESIRE_HIGH
								and #allies < 2
							then
								pushTime = DotaTime();
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
									return  BOT_MODE_DESIRE_ABSOLUTE *0.98;
								end
							end
						
						end
					end
					
					local farmDistance = GetUnitToLocationDistance(bot,preferedCamp.cattr.location);
					
					if botName == 'npc_dota_hero_medusa' and farmDistance < 133 then return 0.33 end 
					
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


function Think()
	
	if J.CanNotUseAction(bot)
	then return end
	
	if runMode 
	then
	
		if not bot:IsInvisible() and bot:GetLevel() >= 15
			and not bot:HasModifier('modifier_medusa_stone_gaze_facing')
		then
			local botAttackRange = bot:GetAttackRange();
			if botAttackRange > 1400 then botAttackRange = 1400 end;
			local runModeAllies = bot:GetNearbyHeroes(900,false,BOT_MODE_NONE);
			local runModeEnemyHeroes = bot:GetNearbyHeroes(botAttackRange +50,true,BOT_MODE_NONE);
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
					local mostFarmDesireLane,mostFarmDesire = J.GetMostFarmLaneDesire();
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


function X.IsHumanPlayerInTeam()

	local numPlayer =  GetTeamPlayers(GetTeam());
	if not IsPlayerBot(numPlayer[1]) 
	then
		return true;
	end
	
	return false;
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
			local nNearByHeroes = bot:GetNearbyHeroes(700,true,BOT_MODE_NONE);
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
			local nNearByHeroes = bot:GetNearbyHeroes(700,true,BOT_MODE_NONE);
			if #nNearByHeroes < 2
	        then
				return 3;
			end
		end	
		
		local nEnemy = bot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
		for _,enemy in pairs(nEnemy)
		do
			if J.IsValid(enemy)
				and enemy:GetUnitName() == "npc_dota_hero_necrolyte"
				and enemy:GetMana() >= 200
				and J.GetHP(bot) < 0.45
				and enemy:IsFacingLocation(bot:GetLocation(),20)
			then
				return 3;
			end
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
		maxBlinkDist = blink:GetSpecialValueInt("blink_range");
	end
	
	if botName == "npc_dota_hero_queenofpain"
	then
		blink = bot:GetAbilityByName( "queenofpain_blink" );
		maxBlinkDist = blink:GetSpecialValueInt("blink_range");
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


function X.IsNormalFarmer(bot)

	local botName = bot:GetUnitName();
	
	 return botName == "npc_dota_hero_chaos_knight" 
		 or botName == "npc_dota_hero_dragon_knight"
		 or botName == "npc_dota_hero_ogre_magi"
		 or botName == "npc_dota_hero_omniknight"
		 or botName == "npc_dota_hero_bristleback" 
		 or botName == "npc_dota_hero_sand_king" 
		 or botName == "npc_dota_hero_skeleton_king"
		 or botName == "npc_dota_hero_kunkka"
		 or botName == "npc_dota_hero_sniper"
		 or botName == "npc_dota_hero_viper" 
		 or botName == "npc_dota_hero_clinkz" 
		 or botName == "npc_dota_hero_mirana" 

end


function X.IsHighFarmer(bot)

	local botName = bot:GetUnitName();
	
	return botName == "npc_dota_hero_nevermore"
		or botName == "npc_dota_hero_templar_assassin"
		or botName == "npc_dota_hero_phantom_assassin"
		or botName == "npc_dota_hero_phantom_lancer"
		or botName == "npc_dota_hero_drow_ranger"
		or botName == "npc_dota_hero_luna"
		or botName == "npc_dota_hero_antimage"
		or botName == "npc_dota_hero_arc_warden"
		or botName == "npc_dota_hero_bloodseeker"
		or botName == "npc_dota_hero_medusa"
		or botName == "npc_dota_hero_razor"
		or botName == "npc_dota_hero_huskar"
		or botName == "npc_dota_hero_juggernaut"
		or botName == "npc_dota_hero_slark"
		or botName == "npc_dota_hero_naga_siren"
		or botName == "npc_dota_hero_legion_commander"
		
end


function X.IsVeryHighFarmer(bot)

	local botName = bot:GetUnitName();
	
	return botName == "npc_dota_hero_nevermore"
		or botName == "npc_dota_hero_luna"
		or botName == "npc_dota_hero_antimage"
		or botName == "npc_dota_hero_medusa"
		or botName == "npc_dota_hero_naga_siren"
		or botName == "npc_dota_hero_phantom_lancer"
		or botName == "npc_dota_hero_razor"
		
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
		bot:ActionImmediate_Chat( "你好, 当前挑战的是其他高手定制倍数AI.", true )
		return
	end
	
end
-- dota2jmz@163.com QQ:2462331592..