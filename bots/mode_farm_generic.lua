local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local Version = require(GetScriptDirectory()..'/FunLib/version')
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )
local X = {}
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local RadiantBase = Vector(-7174, -6671, 0)
local DireBase = Vector(7023, 6450, 0)
local team = GetTeam()

local sec = 0;
local preferedCamp = nil;
local availableCamp = {};
local hLaneCreepList = {};
local numCamp = 18;
local farmState = 0;
local teamPlayers = nil;
local nLaneList = {LANE_TOP, LANE_MID, LANE_BOT};

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

local runTime = 0;
local shouldRunTime = 0
local runMode = false;

local isChangePosMessageDone = false

local nH, nB = J.Utils.NumHumanBotPlayersInTeam(GetOpposingTeam())

local lastAnnouncePrintedTime = 0
local numberAnnouncePrinted = 1
local announcementGap = 6
local hasPickedOneAnnouncer = false
local botActiveMode = nil
local CleanupCachedVarsTime = -100
local botLevel = 1

local buggedFarmAttackHeroes = {
	"npc_dota_hero_invoker"
}

if bot.farmLocation == nil then bot.farmLocation = bot:GetLocation() end

function GetDesire()
	local cacheKey = 'GetFarmDesire'..tostring(bot:GetPlayerID())
	local cachedVar = J.Utils.GetCachedVars(cacheKey, 0.5)
	if cachedVar ~= nil then return cachedVar end
	local res = GetDesireHelper()
	J.Utils.SetCachedVars(cacheKey, res)
	return res
end
function GetDesireHelper()
	-- Utils.PrintPings(0.15)

	if DotaTime() - CleanupCachedVarsTime > Utils.CachedVarsCleanTime then
		Utils.CleanupCachedVars()
		CleanupCachedVarsTime = DotaTime()
	end

	PickOneAnnouncer()
	AnnounceMessages()

	if not bInitDone
	then
		bInitDone = true
		beNormalFarmer = J.GetPosition(bot) == 3
		beHighFarmer = J.GetPosition(bot) == 2
		beVeryHighFarmer = J.GetPosition(bot) == 1
	end

    botActiveMode = bot:GetActiveMode()
	local botActiveModeDesire = bot:GetActiveModeDesire()
    botLevel = bot:GetLevel()
    local bAlive = bot:IsAlive()

    local vTormentorLocation = J.GetTormentorLocation(GetTeam())
	local nInRangeAlly_tormentor = J.GetAlliesNearLoc(vTormentorLocation, 1600)
	local nInRangeAlly_roshan = J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), 1200)
    local bRoshanAlive = J.IsRoshanAlive()
    local teamNetworth, enemyNetworth = J.GetInventoryNetworth()
    local networthAdvantage = teamNetworth - enemyNetworth

    local nAliveEnemyCount = J.GetNumOfAliveHeroes(true)
	local nAliveAllyCount  = J.GetNumOfAliveHeroes(false)
	local bNotClone = not bot:HasModifier('modifier_arc_warden_tempest_double') and not J.IsMeepoClone(bot)

    if J.IsInLaningPhase()
	or (J.IsDoingRoshan(bot) and bNotClone)
	or (J.IsDoingTormentor(bot) and bNotClone)
    or DotaTime() < 50
    or ((botActiveMode == BOT_MODE_SECRET_SHOP
		or botActiveMode == BOT_MODE_RUNE
		or botActiveMode == BOT_MODE_OUTPOST) and botActiveModeDesire > 0)
	or (#nInRangeAlly_tormentor >= 2 and bot.tormentor_state == true)
    or (#nInRangeAlly_roshan >= 2 and bRoshanAlive and bNotClone)
    or (nAliveEnemyCount <= 1 and nAliveAllyCount >= 2)
    or (J.DoesTeamHaveAegis() and J.IsLateGame() and nAliveAllyCount >= 4)
    or not bAlive
    then
        return BOT_MODE_DESIRE_NONE
    end
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
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

	if DotaTime() < 50 or botActiveMode == BOT_MODE_RUNE then
		return 0.0
	end
	
	if X.IsUnitAroundLocation(GetAncient(GetTeam()):GetLocation(), 3000) 
	-- and aliveAllyCount >= aliveEnemyCount
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	sec = math.floor(DotaTime()) % 60;
	
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

    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
    if #nEnemyHeroes > 0 then
        return BOT_MODE_DESIRE_NONE
    end

    local nAllyHeroes_attacking = {}
	for i = 1, 5 do
		local member = GetTeamMember(i)
		if bot ~= member and J.IsValidHero(member) and J.IsInRange(bot, member, 1600) then
            local hTarget = member:GetAttackTarget()
			if J.IsGoingOnSomeone(member)
            or (J.IsValidHero(hTarget) and J.IsChasingTarget(member, hTarget) and J.IsInRange(member, hTarget, 1000))
			then
				table.insert(nAllyHeroes_attacking, member)
			end
		end
	end

    if #nAllyHeroes_attacking > 0 then
        local nInRangeEnemy = J.GetEnemiesNearLoc(J.GetCenterOfUnits(nAllyHeroes_attacking), 1200)
        if #nAllyHeroes_attacking + 1 >= #nInRangeEnemy then
            return BOT_MODE_DESIRE_NONE
        end
    end

	-- Retreating allies
    for i = 1, 5 do
		local member = GetTeamMember(i)
		if bot ~= member and J.IsValidHero(member) and J.IsInRange(bot, member, 2000) and J.IsRetreating(member) then
            local nInRangeEnemy = J.GetEnemiesNearLoc(member:GetLocation(), 1200)
            for _, enemy in pairs(nInRangeEnemy) do
                if J.IsValidHero(enemy)
                and (J.IsChasingTarget(enemy, bot) or enemy:GetAttackTarget() == member and J.GetHP(member) < 0.4)
                then
                    return BOT_MODE_DESIRE_NONE
                end
            end
		end
	end

    local vTeamFightLocation = J.GetTeamFightLocation(bot)
    if vTeamFightLocation ~= nil and GetUnitToLocationDistance(bot, vTeamFightLocation) < 2500 then
        if botLevel >= 18 or not J.IsCore(bot) then
            return BOT_MODE_DESIRE_NONE
        end
    end

    if bAlive and bot:HasModifier('modifier_arc_warden_tempest_double') then
        if bRoshanAlive then
            for _, ally in pairs(nInRangeAlly_roshan) do
                if ally ~= bot
                and J.IsValidHero(ally)
                and ally:GetUnitName() == 'npc_dota_hero_arc_warden'
				and J.IsDoingRoshan(ally)
                then
                    local hTarget = ally:GetAttackTarget()
                    if (J.IsRoshan(hTarget) and J.GetHP(hTarget) < 0.4)
                    or (botActiveMode == BOT_MODE_ITEM)
                    then
						if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end
                        return BOT_MODE_DESIRE_ABSOLUTE
					end
                end
            end
        end
    end

    if bAlive and J.IsMeepoClone(bot) then
        if bRoshanAlive then
            for _, ally in pairs(nInRangeAlly_roshan) do
                if ally ~= bot
                and J.IsValidHero(ally)
				and not J.IsMeepoClone(ally)
                and ally:GetUnitName() == 'npc_dota_hero_meepo'
                and J.IsDoingRoshan(ally)
                then
                    local hTarget = ally:GetAttackTarget()
                    if (J.IsRoshan(hTarget) and J.GetHP(hTarget) < 0.25)
                    or (botActiveMode == BOT_MODE_ITEM)
                    then
						if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end
                        return RemapValClamped(J.GetHP(bot), 0.2, 0.7, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_ABSOLUTE)
                    end
                end
            end
        end
    end
	
	if not J.Role.IsAllyHaveAegis() and J.IsHaveAegis(bot) then J.Role['aegisHero'] = bot end;
	if J.Role.IsAllyHaveAegis() and nAliveAllyCount >= 4 and J.IsLateGame()
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
	if allyKills > enemyKills + 20 and nAliveAllyCount >= 4 and networthAdvantage > 15000
	then return BOT_MODE_DESIRE_NONE; end

	local nAlliesCount = J.GetAllyCount(bot,1400);
	if nAlliesCount >= 4
	   or (botLevel >= 23 and nAlliesCount >= 3)
	   or GetRoshanDesire() > BOT_MODE_DESIRE_VERYHIGH
	then
		local nNeutrals = bot:GetNearbyNeutralCreeps( bot:GetAttackRange() ); 
		if #nNeutrals == 0 
		then 
		    teamTime = DotaTime();
		end
	end

    local hItem = J.IsItemAvailable('item_hand_of_midas')
    if J.IsInAllyArea(bot) and J.CanCastAbility(hItem) then
        if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp) end;
        return RemapValClamped(J.GetHP(bot), 0.2, 0.7, BOT_MODE_DESIRE_LOW, BOT_MODE_DESIRE_ABSOLUTE)
    end

	if J.IsDefending(bot) and botActiveModeDesire >= 0.75 then
		local nDefendLane, nDefendDesire = J.GetMostDefendLaneDesire()
		local vDefendLocation  = GetLaneFrontLocation(GetTeam(), nDefendLane, -600)
		local nDefendAllies = J.GetAlliesNearLoc(vDefendLocation, 2200)

		local nNeutrals = bot:GetNearbyNeutralCreeps(Min(bot:GetAttackRange(), 1600))

		if #nNeutrals == 0 and #nDefendAllies >= 2 and (not beVeryHighFarmer or botLevel >= 15 or J.IsLateGame()) then
		    teamTime = DotaTime()
		end
	end

	if teamTime > DotaTime() - 3.0 then return BOT_MODE_DESIRE_NONE end

	local aAliveCount = J.GetNumOfAliveHeroes(false)
    local eAliveCount = J.GetNumOfAliveHeroes(true)
    local aAliveCoreCount = J.GetAliveCoreCount(false)
    local eAliveCoreCount = J.GetAliveCoreCount(true)
	if eAliveCount == 0
	or aAliveCoreCount >= eAliveCoreCount
	or (aAliveCoreCount >= 1 and aAliveCount >= eAliveCount + 2)
	or J.IsLateGame()
	then
		if (beHighFarmer or (beNormalFarmer and J.IsMidGame()) or J.IsLateGame() or bot:GetNetWorth() >= 15000) then
			if bot:GetActiveMode() == BOT_MODE_ASSEMBLE then assembleTime = DotaTime() end
			if DotaTime() - assembleTime < 15.0 then return BOT_MODE_DESIRE_NONE end
			if J.IsTeamActivityCount(bot, 3)	then return BOT_MODE_DESIRE_NONE end
		end
	end


	if GetGameMode() ~= GAMEMODE_MO
	and (J.Site.IsTimeToFarm(bot) or pushTime > DotaTime() - 8.0)
	and (J.Site.IsTimeToFarm(bot) and (J.IsCore(bot) and bot:GetLastHits() < (J.IsModeTurbo() and 400 or 200) and not J.IsDefending(bot)))
	-- and J.Site.IsTimeToFarm(bot)
	and (DotaTime() > 8 * 60 or botLevel >= 8 or ( bot:GetAttackRange() < 220 and botLevel >= 6 ))
	then
		if J.GetDistanceFromEnemyFountain(bot) > 6000 
		then
			hLaneCreepList = bot:GetNearbyLaneCreeps(1600, true);
			-- if #hLaneCreepList == 0	
			--    and J.IsInAllyArea( bot )
			--    and X.IsNearLaneFront( bot )
			-- then
			-- 	hLaneCreepList = bot:GetNearbyLaneCreeps(1600, false);
			-- end
		end;
		
		local maxCampDesire = RemapValClamped(bot:GetNetWorth(), 5000, J.IsCore(bot) and 23000 or 16000, BOT_MODE_DESIRE_ABSOLUTE, BOT_MODE_DESIRE_MODERATE)
		if #hLaneCreepList > 0
		then
			bot.farmLocation = J.GetCenterOfUnits(hLaneCreepList)
			return RemapValClamped(J.GetHP(bot), 0.2, 0.7, 0.4, maxCampDesire)
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
				-- elseif farmState == 1
				--     then 
				-- 		bot.farmLocation = preferedCamp.cattr.location
				-- 	    return BOT_MODE_DESIRE_ABSOLUTE
				else
					
					if nAliveAllyCount >= 3
					then
						if pushTime > DotaTime() - 8.0
						then
							if preferedCamp == nil then preferedCamp = J.Site.GetClosestNeutralSpwan(bot, availableCamp);end
							bot.farmLocation = preferedCamp.cattr.location
							return RemapValClamped(J.GetHP(bot), 0.2, 0.7, BOT_MODE_DESIRE_LOW, maxCampDesire);
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
								bot.farmLocation = preferedCamp.cattr.location
								return RemapValClamped(J.GetHP(bot), 0.2, 0.7, 0.4, maxCampDesire * 0.93);
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
									return RemapValClamped(J.GetHP(bot), 0.2, 0.7, 0.4, maxCampDesire * 0.98);
								end
							end
						
						end
					end
					
					local farmDistance = GetUnitToLocationDistance(bot,preferedCamp.cattr.location);
					bot.farmLocation = preferedCamp.cattr.location
					return RemapValClamped(farmDistance, 600, 6400, 0.9, math.min(0.9, maxCampDesire))
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
	bot:SetTarget(nil);
end

function Think()
	if J.CanNotUseAction(bot) then return end

	local botAttackRange = bot:GetAttackRange();
	if runMode then
		if not bot:IsInvisible() and botLevel >= 15
			and not bot:HasModifier('modifier_medusa_stone_gaze_facing')
		then
			if botAttackRange > 1400 then botAttackRange = 1400 end;
			local runModeAllies = J.GetNearbyHeroes(bot,900,false,BOT_MODE_NONE);
			local runModeEnemyHeroes = J.GetNearbyHeroes(bot,botAttackRange +50,true,BOT_MODE_NONE);
			-- local runModeTowers  = bot:GetNearbyTowers(240,true);
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

	if J.IsValid(hLaneCreepList[1]) then
		local farmTarget = J.Site.GetFarmLaneTarget(hLaneCreepList);
		local nSearchRange = bot:GetAttackRange() + 180
		if nSearchRange > 1600 then nSearchRange = 1600 end
		local nNeutrals = bot:GetNearbyNeutralCreeps(nSearchRange);
		if J.IsValid(farmTarget) and #nNeutrals == 0 then
						
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
						   or ( J.IsValidBuilding(allyTower) and allyTower:GetAttackTarget() == farmTarget ) )
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
		local nNeutrals = bot:GetNearbyCreeps(1600, true);
		if #nNeutrals >= 3 and cDist <= 600 and cDist > 240
		   and ( botLevel >= 10 or not nNeutrals[1]:IsAncientCreep())
		then farmState = 1 end;
		
		if farmState == 0
		   and J.IsValid(nNeutrals[1])
		   and not J.IsRoshan(nNeutrals[1])
		   and ( botLevel >= 10 or not nNeutrals[1]:IsAncientCreep())
		then
			if GetUnitToUnitDistance(bot,nNeutrals[1]) < bot:GetAttackRange() + 150
				and J.HasNotActionLast(4.0,'creep')
			then
				J.Role['availableCampTable'] = J.Site.UpdateCommonCamp(nNeutrals[1],J.Role['availableCampTable']);
			end

			local farmTarget = J.Site.FindFarmNeutralTarget(nNeutrals)
			if J.IsValid(farmTarget)
			then
				bot:SetTarget(farmTarget);
				bot:Action_AttackUnit(farmTarget, true);
				return;
			elseif J.IsValid(nNeutrals[1]) then
				bot:SetTarget(nNeutrals[1]);
				bot:Action_AttackUnit(nNeutrals[1], true);
				return;
			end
			
		elseif farmState == 0
				and #nNeutrals == 0
		        and cDist > 240
		        and ( not X.IsLocCanBeSeen(targetFarmLoc) or cDist > 600 )
			then
				
				-- bot:SetTarget(nil);
				
				-- if botLevel >= 12
				-- 	 and J.Role.ShouldTpToFarm() 
				-- then
				-- 	local mostFarmDesireLane,mostFarmDesire = J.GetMostFarmLaneDesire();
				-- 	local tps = bot:GetItemInSlot(nTpSolt);
				-- 	local tpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,0);
				-- 	local bestTpLoc = J.GetNearbyLocationToTp(tpLoc);
				-- 	local nAllies = J.GetAlliesNearLoc(tpLoc, 1400);
				-- 	if mostFarmDesire > BOT_MODE_DESIRE_VERYHIGH 
				-- 		and J.IsLocHaveTower(1850,false,tpLoc)
				-- 		and bestTpLoc ~= nil					
				-- 		and #nAllies == 0
				-- 	then
				-- 		if tps ~= nil and tps:IsFullyCastable() 
				-- 		   and GetUnitToLocationDistance(bot,bestTpLoc) > 4200
				-- 		then
				-- 			preferedCamp = nil;
				-- 			J.Role['lastFarmTpTime'] = DotaTime();
				-- 			bot:Action_UseAbilityOnLocation(tps, bestTpLoc);
				-- 			return;
				-- 		end
				-- 	end	
					
				-- 	local tBoots = J.IsItemAvailable("item_travel_boots_2");
				-- 	if tBoots == nil then tBoots = J.IsItemAvailable("item_travel_boots"); end;
				-- 	if tBoots ~= nil and tBoots:IsFullyCastable()
				-- 	then
				-- 		local tpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,-600);
				-- 		local nAllies = J.GetAlliesNearLoc(tpLoc, 1600);
				-- 		if mostFarmDesire > BOT_MODE_DESIRE_HIGH * 1.12		
				-- 		   and #nAllies == 0
				-- 		   and GetUnitToLocationDistance(bot,tpLoc) > 3500
				-- 		then
				-- 			preferedCamp = nil;
				-- 			J.Role['lastFarmTpTime'] = DotaTime();
				-- 			bot:Action_UseAbilityOnLocation(tBoots, tpLoc);
				-- 			return;							
				-- 		end
				-- 	end					
				-- end
				
				if J.IsValid(hLaneCreepList[1])
				then
					bot:Action_MoveToLocation( hLaneCreepList[1]:GetLocation() );
					return;
				end
				
				if X.CouldBlink(bot,targetFarmLoc) then return end;
				
				if X.CouldBlade(bot,targetFarmLoc) then return end;
				
				if IsLocationPassable(targetFarmLoc) then
					bot:Action_MoveToLocation(targetFarmLoc);
				else
					bot:Action_MoveToLocation(targetFarmLoc + RandomVector(230));
				end
				return;
		else
			local neutralCreeps = bot:GetNearbyCreeps(1600, true); 
			
			if #neutralCreeps >= 2 then
				
				farmState = 1;
				
				local farmTarget = J.Site.FindFarmNeutralTarget(neutralCreeps)
				if J.IsValid(farmTarget)
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
					if J.IsValid(farmTarget)
					then
						bot:SetTarget(farmTarget);
						bot:Action_AttackUnit(farmTarget, true);
						return;
					end
			else
			
				local farmTarget = J.Site.FindFarmNeutralTarget(neutralCreeps)
				if J.IsValid(farmTarget)
				then
					bot:SetTarget(farmTarget);
					bot:Action_AttackUnit(farmTarget, true);
					return;
				end
				
				bot:SetTarget(nil);
				
				if cDist > 200 then
					if IsLocationPassable(targetFarmLoc) then
						bot:Action_MoveToLocation(targetFarmLoc);
					else
						bot:Action_MoveToLocation(targetFarmLoc + RandomVector(230));
					end
					return
				end
			end
		end
	end
	bot:SetTarget(nil);
	bot:Action_MoveToLocation( ( RadiantBase + DireBase )/2 );
	return;
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
	for i, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) and i <= 3 then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil and J.GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < 1.0 then
					return true
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

	if botLevel < 10
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
		   and IsRadiusVisible(vLoc,10)

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
		-- if GetTeam() == TEAM_DIRE then
		-- 	-- broken for 7.38 for now.
		-- 	return
		-- end
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
