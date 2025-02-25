local X = {}
local bot = GetBot()
local botName = bot:GetUnitName();
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end

local botTeam = bot:GetTeam()
local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )

local Tormentor = nil
local TormentorLocation = J.GetTormentorLocation(GetTeam())
local TormentorLocOffset = RandomVector(200)

local tormentorMessageTime = 0
local canDoTormentor = false
local nTormentorSpawnTime = (J.IsModeTurbo() and 10 or 20)

if bot.tormentor_state == nil then bot.tormentor_state = false end
if bot.tormentor_kill_time == nil then bot.tormentor_kill_time = 0 end

local NoTormentorAfterThisTime = 40 * 60 -- do not do tormentor again since it's late and doing tormentor only slows down the game more.
local botTarget
local hAllAllyHeroList
local MaxAveDistanceForTormentor = 8000

function GetDesire()
	-- 如果在打高地 就别撤退去干别的
	if J.Utils.IsTeamPushingSecondTierOrHighGround(bot) then
		return BOT_MODE_DESIRE_NONE
	end
	if J.GetEnemiesAroundAncient(bot, 3200) > 0 then
		return BOT_MODE_DESIRE_NONE
	end

	-- local botMode = bot:GetActiveMode()
	-- if (J.IsPushing(bot) or J.IsDefending(bot) or J.IsDoingRoshan(bot)
	-- 	or botMode == BOT_MODE_RUNE or botMode == BOT_MODE_SECRET_SHOP or botMode == BOT_MODE_WARD or botMode == BOT_MODE_ROAM)
	-- 	and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE
	-- then
	-- 	return BOT_ACTION_DESIRE_NONE
	-- end

	local tormentorDesire = TormentorDesire()
	if tormentorDesire > 0 then
		return tormentorDesire
	end

	return BOT_MODE_DESIRE_NONE
end

function TormentorDesire()
	local currentTime = DotaTime()
	if GetGameMode() == 23 then currentTime = currentTime * 2 end
	if J.IsDoingRoshan(bot)
    or J.GetCoresAverageNetworth() > 20000
    or currentTime > NoTormentorAfterThisTime then
		return BOT_MODE_DESIRE_NONE
	end

    botTarget = bot:GetAttackTarget()
    local tAllyInTormentorLocation = J.GetAlliesNearLoc(TormentorLocation, 900)
    local tInRangeEnemy = J.GetLastSeenEnemiesNearLoc(bot:GetLocation(), 2000)

    if #tInRangeEnemy > 0 then
        return BOT_MODE_DESIRE_NONE
    end

    local nAliveAlly = J.GetNumOfAliveHeroes(false)
	TormentorLocOffset = (bot:GetTeam() == TEAM_DIRE and Vector(-200, 200, 392) or Vector(0, -450, 392)) + RandomVector(50)

    local nHumanCountInLoc = 0
    local nCoreCountInLoc = 0
    local nSuppCountInLoc = 0
    local nAttackingTormentorCount = 0

    local nAveCoreLevel = 0
    local nAveSuppLevel = 0
    local nTotalDistance = 0

    local tAliveAllies = {}
    hAllAllyHeroList = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	for i, allyHero in pairs(hAllAllyHeroList) do
        local member = GetTeamMember(i)
        if member ~= nil then
            if member:IsAlive() then
                table.insert(tAliveAllies, member)

                local distanceToTor = GetUnitToLocationDistance(member, TormentorLocation)
                if not member:IsBot() and distanceToTor <= 1000 then
                    nHumanCountInLoc = nHumanCountInLoc + 1
                end

                -- attacking tormentor count
                local memberTarget = J.GetProperTarget(member)
                if J.IsTormentor(memberTarget) and J.IsAttacking(member) and bot ~= member then
                    nAttackingTormentorCount = nAttackingTormentorCount + 1
                end

                nTotalDistance = nTotalDistance + distanceToTor

                -- get average levels
                if J.IsCore(member) then
                    if distanceToTor <= 1000 then
                        nCoreCountInLoc = nCoreCountInLoc + 1
                    end
                    nAveCoreLevel = nAveCoreLevel + member:GetLevel()
                else
                    if distanceToTor <= 1000 then
                        nSuppCountInLoc = nSuppCountInLoc + 1
                    end
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
        end
    end

    -- local hEnemyAncient = GetAncient(GetOpposingTeam())

    if #tAliveAllies < 4 then
        return BOT_MODE_DESIRE_NONE
    end

    nAveCoreLevel = nAveCoreLevel / 3
    nAveSuppLevel = nAveSuppLevel / 2
    local nAveDistance = nTotalDistance / #hAllAllyHeroList
    if nAveDistance > MaxAveDistanceForTormentor then
        return BOT_MODE_DESIRE_NONE
    end

    -- Someone go check Tormentor
    if DotaTime() >= nTormentorSpawnTime * 60 and (DotaTime() - bot.tormentor_kill_time) >= (nTormentorSpawnTime / 2) * 60 then
        if not X.IsTormentorAlive() then
            -- if not J.IsCore(bot) and GetUnitToUnitDistance(bot, hEnemyAncient) > 4000 then
            --     local ally = nil
            --     local allyDist = 4000
            --     for i, allyHero in pairs(hAllAllyHeroList) do
            --         local member = GetTeamMember(i)
            --         if member ~= nil and member:IsAlive() and member:IsBot() and not J.IsCore(member) then
            --             local memberDist = GetUnitToLocationDistance(member, TormentorLocation)
            --             if memberDist < allyDist then
            --                 ally = member
            --                 allyDist = memberDist
            --             end
            --         end
            --     end

            --     if ally ~= nil and bot == ally and bot.tormentor_state == false then
            --         return 0.8
            --     end
            -- end

            -- all go check tormentor
            if bot.tormentor_state == false then
                return BOT_MODE_DESIRE_VERYHIGH
            end
        else
            bot.tormentor_state = true
        end
    else
        bot.tormentor_state = false
    end

    if bot.tormentor_state == true
    and nAveCoreLevel >= 13
    and nAveSuppLevel >= 10
    and (  (bot.tormentor_kill_time == 0 and nAliveAlly >= 5)
        or (bot.tormentor_kill_time > 0 and nAliveAlly >= 3 and J.GetAliveAllyCoreCount() >= 2)
        or (nAttackingTormentorCount >= 2)
    ) then
        canDoTormentor = true

        if J.GetHP(bot) < 0.3
        and J.IsTormentor(Tormentor)
        and J.GetHP(Tormentor) > 0.3 then
            return BOT_MODE_DESIRE_NONE
        end

        if X.IsEnoughAllies() then
            return RemapValClamped(J.GetHP(bot), 0.25, 1, 0.95, 1.2)
        end

        if #tAllyInTormentorLocation >= 2
        or nCoreCountInLoc >= 1
        or nSuppCountInLoc >= 2
        or nHumanCountInLoc >= 1 then
            return RemapValClamped(J.GetHP(bot), 0.25, 1, 0.95, 1.2)
        else
            return BOT_MODE_DESIRE_VERYHIGH
        end
    end

    canDoTormentor = false
    return BOT_MODE_DESIRE_NONE
end

function Think()
	if TormentorThink() >= 1 then return end
end

function TormentorThink()
	if GetUnitToLocationDistance(bot, TormentorLocation) > 550
    and not (J.IsValid(botTarget) and string.find(botTarget:GetUnitName(), 'miniboss')) then
        bot:Action_MoveToLocation(TormentorLocation + TormentorLocOffset)
        return 1
    else
        local tCreeps = bot:GetNearbyNeutralCreeps(900)
        for _, c in pairs(tCreeps) do
            if J.IsValid(c) and string.find(c:GetUnitName(), 'miniboss') then
                Tormentor = c
                if X.IsEnoughAllies() or J.GetHP(Tormentor) < 0.25 then
                    bot:Action_AttackUnit(Tormentor, true)
                    return 1
                end

                if canDoTormentor and (DotaTime() > tormentorMessageTime + 10) then
                    tormentorMessageTime = DotaTime()
					bot:ActionImmediate_Chat(Localization.Get('can_try_tormentor'), false)
					bot:ActionImmediate_Ping(Tormentor:GetLocation().x, Tormentor:GetLocation().y, true)
					return 1
                end
            end
        end
    end
	return 0
end

function X.IsTormentorAlive()
    if IsLocationVisible(TormentorLocation) then
        for i, allyHero in pairs(hAllAllyHeroList) do
            local member = GetTeamMember(i)
            if member ~= nil and member:IsAlive() then
                if GetUnitToLocationDistance(member, TormentorLocation) <= 600 then
                    local tCreeps = member:GetNearbyNeutralCreeps(900)
                    for _, c in pairs(tCreeps) do
                        if J.IsValid(c) and string.find(c:GetUnitName(), 'miniboss') then
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

function X.IsEnoughAllies()
    local cacheKey = "IsEnoughAllies" .. tostring(GetTeam())
    local cache = J.Utils.GetCachedVars(cacheKey, 1)
    if cache ~= nil then return cache end

    local nAllyCount = 0
    local nCoreCountInLoc = 0

	for i = 1, 5
    do
		local member = GetTeamMember(i)
		if member ~= nil and member:IsAlive()
		and GetUnitToLocationDistance(member, TormentorLocation) <= 900
		then
            if J.IsCore(member) then
                nCoreCountInLoc = nCoreCountInLoc + 1
            end

			nAllyCount = nAllyCount + 1
		end
	end

    local result = ((((bot.tormentor_kill_time == 0 and nAllyCount >= 4) or (bot.tormentor_kill_time > 0 and nAllyCount >= 3))) and nCoreCountInLoc >= 2)
    J.Utils.SetCachedVars(cacheKey, result)
	return result
end