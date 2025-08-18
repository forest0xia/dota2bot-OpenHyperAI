local X = {}

local botTeam = bot:GetTeam()
local bot = GetBot()
local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )

local Tormentor = nil
local TormentorLocation = 0
local vWaitingLocation = 0

local tormentorMessageTime = 0
local canDoTormentor = false

if bot.tormentor_state == nil then bot.tormentor_state = false end
if bot.tormentor_kill_time == nil then bot.tormentor_kill_time = 0 end

local nCoreCountInLoc = 0
local nSuppCountInLoc = 0
local bHumanInTeam = false

function GetDesire()
	local cacheKey = 'GetSideShopDesire'..tostring(bot:GetPlayerID())
	local cachedVar = J.Utils.GetCachedVars(cacheKey, 1)
	if cachedVar ~= nil then return cachedVar end
	local res = GetDesireHelper()
	J.Utils.SetCachedVars(cacheKey, res)
	return res
end
function GetDesireHelper()
    TormentorLocation = J.GetTormentorLocation(GetTeam())
    vWaitingLocation = J.GetTormentorWaitingLocation(GetTeam())

    local tAllyInTormentorLocation = J.GetAlliesNearLoc(TormentorLocation, 900)
    local tAllyInTormentorWaitLocation = J.GetAlliesNearLoc(vWaitingLocation, 900)
    local tInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
    local nAliveAlly = 0

    local nTormentorSpawnInterval = J.IsModeTurbo() and 5 or 10
    local nTormentorSpawnTime = J.IsModeTurbo() and 10 or 20

    local nHumanCountInLoc = 0
    local nAttackingTormentorCount = 0

    local nAveCoreLevel = 0
    local nAveSuppLevel = 0

    -- update vars
    local tAliveAllies = {}
    for i = 1, 5 do
        local member = GetTeamMember(i)
        if member ~= nil then
            local memberLevel = member:GetLevel()

            if member:IsAlive() then
                nAliveAlly = nAliveAlly + 1
                table.insert(tAliveAllies, member)

                if not member:IsBot() then
                    if bot.tormentor_state == false and J.IsValidHero(member) then
                        if GetUnitToLocationDistance(member, TormentorLocation) <= 1300
                        and IsLocationVisible(TormentorLocation)
                        then
                            local nNeutralCreeps = member:GetNearbyNeutralCreeps(1300)
                            for j = #nNeutralCreeps, 1, -1 do
                                if J.IsValid(nNeutralCreeps[j]) and string.find(nNeutralCreeps[j]:GetUnitName(), 'miniboss') then
                                    bot.tormentor_state = true
                                end
                            end
                        end
                    end

                    if GetUnitToLocationDistance(member, TormentorLocation) <= 1600
                    or GetUnitToLocationDistance(member, vWaitingLocation) <= 1600
                    then
                        nHumanCountInLoc = nHumanCountInLoc + 1
                    end
                end

                -- attacking tormentor count
                local memberTarget = J.GetProperTarget(member)
                if J.IsTormentor(memberTarget) and J.IsAttacking(member) then
                    nAttackingTormentorCount = nAttackingTormentorCount + 1
                end

                if member.tormentor_team_healthy == nil then member.tormentor_team_healthy = false end
                if member.tormentor_team_healthy == true then
                    bot.tormentor_team_healthy = true
                end

                if J.IsCore(member) then
                    if GetUnitToLocationDistance(member, TormentorLocation) <= 900
                    or GetUnitToLocationDistance(member, vWaitingLocation) <= 900
                    then
                        nCoreCountInLoc = nCoreCountInLoc + 1
                    end
                else
                    if GetUnitToLocationDistance(member, TormentorLocation) <= 900
                    or GetUnitToLocationDistance(member, vWaitingLocation) <= 900
                    then
                        nSuppCountInLoc = nSuppCountInLoc + 1
                    end
                end
            end

            -- get average levels
            if J.IsCore(member) then
                if memberLevel < 13 then
                    nAveCoreLevel = 0
                else
                    nAveCoreLevel = nAveCoreLevel + member:GetLevel()
                end
            else
                if memberLevel < 11 then
                    nAveSuppLevel = 0
                else
                    nAveSuppLevel = nAveSuppLevel + member:GetLevel()
                end
            end

            -- update tormentor state
            if member.tormentor_state == true then
                bot.tormentor_state = true
            end

            --update kill time
            if member.tormentor_kill_time ~= nil
            and member.tormentor_kill_time > 0
            and member.tormentor_kill_time > bot.tormentor_kill_time
            then
                bot.tormentor_kill_time = member.tormentor_kill_time
            end

            if not member:IsBot() and not bHumanInTeam then
                bHumanInTeam = true
            end
        end
    end

    if #tAllyInTormentorLocation <= 1 and nHumanCountInLoc == 0
    and DotaTime() > (J.IsModeTurbo() and (25 * 60) or (40 * 60)) then
        return BOT_MODE_DESIRE_NONE
    end

    local hEnemyAncient = GetAncient(GetOpposingTeam())
    if #tAllyInTormentorLocation <= 1 and nHumanCountInLoc == 0
    and GetUnitToLocationDistance(bot, TormentorLocation) > 1600
    and (GetUnitToUnitDistance(bot, hEnemyAncient) < 4000
        and J.GetEnemiesAroundAncient(bot, 4000) > 0
        or (J.IsDoingRoshan(bot) and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH)
    ) then
        return BOT_MODE_DESIRE_NONE
    end

    if #J.GetEnemiesNearLoc(GetAncient(GetTeam()):GetLocation(), 2000) >= 2
    or (GetTower(GetTeam(), TOWER_TOP_3) == nil or GetTower(GetTeam(), TOWER_MID_3) == nil or GetTower(GetTeam(), TOWER_BOT_3) == nil) -- stop when any these towers fall
    then
        return BOT_MODE_DESIRE_NONE
    end

    nAveCoreLevel = nAveCoreLevel / 3
    nAveSuppLevel = nAveSuppLevel / 2

    if nAveSuppLevel < 11 then
        return BOT_MODE_DESIRE_NONE
    end

    local bGoodRightClickDamage = X.IsGoodRighClickDamage()

    -- TODO: reduce wasting time waiting for someone as the location is very far now
    -- Someone go check Tormentor
    if DotaTime() >= nTormentorSpawnTime * 60 and (DotaTime() - bot.tormentor_kill_time) >= nTormentorSpawnInterval * 60 then
        if not X.IsTormentorAlive() and bot.tormentor_state ~= true then
            if (nAveCoreLevel >= 13 and nAveSuppLevel >= 11)
            and GetUnitToUnitDistance(bot, hEnemyAncient) > 4000
            and bGoodRightClickDamage
            then
                local ally = nil
                local allyDist = 100000
                for i = 1, 5 do
                    local member = GetTeamMember(i)
                    if J.IsValidHero(member) and member:IsBot() and not J.IsCore(member) then
                        local memberDist = GetUnitToLocationDistance(member, TormentorLocation)
                        if memberDist < allyDist then
                            ally = member
                            allyDist = memberDist
                        end
                    end
                end

                if ally ~= nil and bot == ally and bot.tormentor_state == false then
                    local tInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
                    if not J.IsRealInvisible(bot) and (#tInRangeEnemy > #tInRangeAlly) then
                        return BOT_MODE_DESIRE_LOW
                    else
                        return BOT_MODE_DESIRE_VERYHIGH
                    end
                end
            end
        else
            bot.tormentor_state = true
        end
    else
        bot.tormentor_state = false
    end

    if bot.tormentor_state == true
    and bGoodRightClickDamage
    and nAveCoreLevel >= 13
    and nAveSuppLevel >= 11
    and (not bHumanInTeam or (bHumanInTeam and X.DidHumanPingedOrAtLocation()))
    and (  (bot.tormentor_kill_time == 0 and nAliveAlly >= 5)
        or (bot.tormentor_kill_time == 0 and nAliveAlly >= 4 and nCoreCountInLoc >= 3 and nSuppCountInLoc >= 1)
        or (bot.tormentor_kill_time > 0 and nAliveAlly >= 3 and J.GetAliveAllyCoreCount() >= 2)
        or (nAttackingTormentorCount >= 2 and nCoreCountInLoc >= 2)
    ) then
        if bot.tormentor_state == true and bot.tormentor_team_healthy == false and bot == J.GetFirstBotInTeam() then
            if X.IsTeamHealthy() then
                bot.tormentor_team_healthy = true
            end
        end

        if bot.tormentor_team_healthy == false then
            return BOT_MODE_DESIRE_NONE
        end

        canDoTormentor = true

        if J.GetHP(bot) < 0.3
        and not bot:HasModifier('modifier_item_crimson_guard_extra')
        and J.IsTormentor(Tormentor)
        and J.GetHP(Tormentor) > 0.3 then
            return BOT_MODE_DESIRE_NONE
        end

        local nDesire = 0.9

        if (#tAllyInTormentorLocation >= 2 or #tAllyInTormentorWaitLocation >= 2)
        or nCoreCountInLoc >= 1
        or nSuppCountInLoc >= 2
        or nHumanCountInLoc >= 1 then
            nDesire = 0.9
        else
            nDesire = 0.75
        end

        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

        return nDesire - (#nInRangeEnemy * (0.9 / 5))
    end

    if bot.tormentor_state == false then
        bot.tormentor_team_healthy = false
    end

    canDoTormentor = false
    return BOT_MODE_DESIRE_NONE
end

local fNextMovementTime = 0
local fStillAlive = 0
local bTormentorAlive = false
function Think()
    if J.CanNotUseAction(bot) then return end

    if bot.tormentor_state == true and GetUnitToLocationDistance(bot, TormentorLocation) > 800 and GetUnitToLocationDistance(bot, TormentorLocation) < 1800 then
        local nLaneCreeps = bot:GetNearbyLaneCreeps(Min(1600, bot:GetAttackRange() + 300), true)
        if J.IsValid(nLaneCreeps[1])
        and J.CanBeAttacked(nLaneCreeps[1])
        then
            bot:Action_AttackUnit(nLaneCreeps[1], true)
            return
        end
    end

    if bot.tormentor_state == true and not X.IsEnoughAllies(vWaitingLocation, 1600) then
        if X.GetClosestBot() == bot and DotaTime() > fStillAlive + 15.0 then
            if GetUnitToLocationDistance(bot, TormentorLocation) <= 350 then
                local nNeutralCreeps = bot:GetNearbyNeutralCreeps(900)
                for i = #nNeutralCreeps, 1, -1 do
                    if J.IsValid(nNeutralCreeps[i]) and string.find(nNeutralCreeps[i]:GetUnitName(), 'miniboss') then
                        fStillAlive = DotaTime()
                        bTormentorAlive = true
                    end
                end
                if not bTormentorAlive then
                    bot.tormentor_kill_time = DotaTime()
                    bot.tormentor_state = false
                    bTormentorAlive = false
                end
            end

            bot:Action_MoveToLocation(TormentorLocation)
            return
        end

        if DotaTime() >= fNextMovementTime then
            bot:Action_MoveToLocation(vWaitingLocation + RandomVector(300))
            fNextMovementTime = DotaTime() + RandomFloat(0.05, 0.2)
            return
        end
    else
        if GetUnitToLocationDistance(bot, TormentorLocation) > bot:GetAttackRange() + 50 then
            bot:Action_MoveToLocation(TormentorLocation)
            return
        else
            local tCreeps = bot:GetNearbyNeutralCreeps(900)
            for _, c in pairs(tCreeps) do
                if J.IsValid(c) and string.find(c:GetUnitName(), 'miniboss') then
                    Tormentor = c
                    if GetUnitToUnitDistance(bot, c) > bot:GetAttackRange() + 50 then
                        bot:Action_MoveDirectly(TormentorLocation)
                        return
                    else
                        if X.IsEnoughAllies(TormentorLocation, 900) or J.GetHP(c) < 0.25 then
                            bot:Action_AttackUnit(c, true)
                            return
                        end
                    end

                    if J.GetFirstBotInTeam() == bot and canDoTormentor and (DotaTime() > tormentorMessageTime + 15) then
                        tormentorMessageTime = DotaTime()
                        bot:ActionImmediate_Chat(Localization.Get('can_try_tormentor'), false)
                        bot:ActionImmediate_Ping(c:GetLocation().x, c:GetLocation().y, true)
                        return
                    end
                end
            end
        end
    end
end

function X.IsTormentorAlive()
    if IsLocationVisible(TormentorLocation) then
        for i = 1, 5 do
            local member = GetTeamMember(i)
            if member ~= nil and member:IsAlive() then
                if GetUnitToLocationDistance(member, TormentorLocation) <= 350 then
                    local nNeutralCreeps = member:GetNearbyNeutralCreeps(900)
                    for j = #nNeutralCreeps, 1, -1 do
                        if J.IsValid(nNeutralCreeps[j]) and string.find(nNeutralCreeps[j]:GetUnitName(), 'miniboss') then
                            return true
                        end
                    end

                    member.tormentor_kill_time = DotaTime()
                end
            end
        end
	end

	return false
end

function X.IsEnoughAllies(vLocation, nRadius)
    local nAllyCount = 0
    local nCoreCountInLoc2 = 0
    local nSuppCountInLoc2 = 0
	for i = 1, 5 do
		local member = GetTeamMember(i)
		if member ~= nil and member:IsAlive() then
            if GetUnitToLocationDistance(member, vLocation) <= nRadius then
                nAllyCount = nAllyCount + 1
                if J.IsCore(member) then
                    nCoreCountInLoc2 = nCoreCountInLoc2 + 1
                else
                    nSuppCountInLoc2 = nSuppCountInLoc2 + 1
                end
            end
		end
	end

	return ((bot.tormentor_kill_time == 0 and nAllyCount >= 5)
         or (bot.tormentor_kill_time == 0 and nAllyCount >= 4 and nCoreCountInLoc2 >= 2 and nSuppCountInLoc2 >= 1)
         or (bot.tormentor_kill_time > 0 and nAllyCount >= 3))
    and nCoreCountInLoc2 >= 2
end

function X.GetClosestBot()
    local hUnitList = J.GetAlliesNearLoc(vWaitingLocation, 2800)
    local hTarget = nil
    local hTargetDistance = math.huge
    for _, unit in pairs(hUnitList) do
        if J.IsValidHero(unit) and GetUnitToLocationDistance(unit, TormentorLocation) < 2000 then
            local unitDistance = GetUnitToLocationDistance(unit, TormentorLocation)
            if hTargetDistance > unitDistance * (1 - J.GetHP(unit)) then
                hTargetDistance = unitDistance
                hTarget = unit
            end
        end
    end

    if hTarget ~= nil then
        return hTarget
    end
    return nil
end

function X.IsTeamHealthy()
	local nHealthyAlly = 0
	for i = 1, 5 do
		local member = GetTeamMember(i)
		if J.IsValid(member) and (J.GetHP(member) > 0.5 or not member:IsBot()) then
			nHealthyAlly = nHealthyAlly + 1
		end
	end

	return nHealthyAlly >= J.GetNumOfAliveHeroes(false)
end

-- just some threshold
local tTeamDamage = {}
local fThresholdChatTime = 0
function X.IsGoodRighClickDamage()
    if bot.tormentor_kill_time > 0 then return true end

    for i = 1, 5 do
		local member = GetTeamMember(i)
		if member ~= nil
        and member:CanBeSeen()
        and J.IsCore(member)
        and not J.DoesUnitHaveTemporaryBuff(member)
        then
            local memberPosition = J.GetPosition(member)
            local attackDamage = member:GetAttackDamage() * member:GetAttackSpeed()
            if memberPosition == 1 then
                attackDamage = attackDamage * 0.50
            elseif memberPosition == 2 then
                attackDamage = attackDamage * 0.25
            elseif memberPosition == 3 then
                attackDamage = attackDamage * 0.25
            end

            local id = member:GetPlayerID()
			if tTeamDamage[id] == nil then tTeamDamage[id] = 0 end
            if tTeamDamage[id] < attackDamage then
                tTeamDamage[id] = attackDamage
            end
		end
	end

    local totalAttackDamage = 0
    for _, damage in pairs(tTeamDamage) do totalAttackDamage = totalAttackDamage + damage end

    if not J.IsDoingTormentor(bot) and J.GetFirstBotInTeam() == bot and bot.tormentor_state == true and DotaTime() - fThresholdChatTime < 30 and totalAttackDamage >= 400.0 then
        bot:ActionImmediate_Chat("Tormentor threshold met..", false)
        fThresholdChatTime = DotaTime()
    end

    -- if math.floor(DotaTime()) % 5 == 0 then
    --     if GetTeam() == TEAM_RADIANT then
    --         print(bot.tormentor_team_healthy, 'RADIANT:', totalAttackDamage)
    --     else
    --         print(bot.tormentor_team_healthy, 'DIRE:', totalAttackDamage)
    --     end
    -- end

    return totalAttackDamage >= 400.0
end

local bHumanPinged = false
function X.DidHumanPingedOrAtLocation()
    local human, ping = J.GetHumanPing()
    if bot.tormentor_state == true and human and ping and not bHumanPinged then
        if J.GetDistance(ping.location, vWaitingLocation) <= 800
        or J.GetDistance(ping.location, TormentorLocation) <= 800
        then
            if GameTime() < ping.time + 15 then
                bHumanPinged = true
            end
        end
    end

    if bot.tormentor_state == false then
        bHumanPinged = false
    elseif bot.tormentor_state == true and bHumanPinged then
        return true
    end

    return false
end