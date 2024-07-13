local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()


function X.OnStart() end
function X.OnEnd() end

function X.GetDesire()

end


local function GetBestLastHitCreep(hCreepList)
	for _, creep in pairs(hCreepList)
	do
		if J.IsValid(creep) and J.CanBeAttacked(creep)
		then
			local nAttackDelayTime = J.GetAttackProDelayTime(bot, creep)
			if J.WillKillTarget(creep, bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL, nAttackDelayTime)
			then
				return creep
			end
		end
	end

	return nil
end

local function GetBestDenyCreep(hCreepList)
	for _, creep in pairs(hCreepList)
	do
		if J.IsValid(creep)
		and J.GetHP(creep) < 0.49
		and J.CanBeAttacked(creep)
		and creep:GetHealth() <= bot:GetAttackDamage()
		then
			return creep
		end
	end

	return nil
end

-- local function GetSafePosition(hAllyList, vLaneFront)
-- 	local vSafe = vLaneFront
-- 	for _, allyHero in pairs(hAllyList)
-- 	do
-- 		if J.IsValidHero(allyHero)
-- 		and J.IsInRange(bot, allyHero, 1600)
-- 		and bot:DistanceFromFountain() > allyHero:DistanceFromFountain()
-- 		then
-- 			vSafe = allyHero:GetLocation()
-- 			break
-- 		end
-- 	end

-- 	if J.GetDistance(bot:GetLocation(), vSafe) > 1600
-- 	then
-- 		vSafe = J.GetTeamFountain()
-- 	end

-- 	return vSafe + RandomVector(200)
-- end

local function HarassEnemyHero(hEnemyList)
    for _, enemyHero in pairs(hEnemyList)
    do
        if J.IsValidHero(enemyHero)
		and J.CanBeAttacked(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
        then
            return enemyHero
        end
    end

    return nil
end

function X.Think()
    print('3333 [ERROR] '..botName..' is actually bugged.')
    if not bot:IsAlive() or J.CanNotUseAction(bot) then return end

	local LowHealthThreshold = 0.35
	local RetreatThreshold = 0.15

	local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local nAllyCreeps = bot:GetNearbyCreeps(800, false)
	local nEnemyCreeps = bot:GetNearbyCreeps(800, true)
	local nAllyHeroes = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

	if (J.GetHP(bot) < RetreatThreshold and nEnemyHeroes ~= nil and #nEnemyHeroes > 0)
	or (bot:WasRecentlyDamagedByAnyHero(2) and (bot:GetAttackTarget() ~= nil and not (bot:GetAttackTarget()):IsHero()))
	or (J.GetHP(bot) < RetreatThreshold and (bot:WasRecentlyDamagedByCreep(2) or bot:WasRecentlyDamagedByTower(2)))
	then
		bot:Action_MoveToLocation(J.GetTeamFountain() + RandomVector(600))
		return
	end

	local hitCreep = GetBestLastHitCreep(nEnemyCreeps)
	if J.IsValid(hitCreep)
	then
		local nLanePartner = J.GetLanePartner(bot)
		if nLanePartner == nil
		or J.IsCore(bot)
		or (not J.IsCore(bot)
			and J.IsCore(nLanePartner)
			and (not nLanePartner:IsAlive()
				or not J.IsInRange(bot, nLanePartner, 800)))
		then
			bot:Action_AttackUnit(hitCreep, true)
			return
		end
	end

	local denyCreep = GetBestDenyCreep(nAllyCreeps)
	if J.IsValid(denyCreep)
	then
		bot:Action_AttackUnit(denyCreep, true)
		return
	end

	local vLaneFront = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), -(bot:GetAttackRange() - 50))
	local vEnemyLaneFront = GetLaneFrontLocation(GetOpposingTeam(), bot:GetAssignedLane(), -(bot:GetAttackRange() - 50))
	local nEnemyLaneAmount = 1 - GetLaneFrontAmount(GetOpposingTeam(), bot:GetAssignedLane(), true)

	if J.GetDistance(vLaneFront, vEnemyLaneFront) <= 100
	and nEnemyLaneAmount > 0
	then
		vLaneFront = vEnemyLaneFront
	end

	-- print(vLaneFront, vEnemyLaneFront)

	if J.GetHP(bot) > LowHealthThreshold
	then
		nEnemyHeroes = bot:GetNearbyHeroes(bot:GetAttackRange() + 50, true, BOT_MODE_NONE)
		local harassTarget = HarassEnemyHero(nEnemyHeroes)
		if not J.IsCore(bot) and J.IsValidHero(harassTarget)
		then
			bot:Action_AttackUnit(harassTarget, true)
		else
			bot:Action_MoveToLocation(vLaneFront + RandomVector(200))
		end
	else
		vLaneFront = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), -RemapValClamped(J.GetHP(bot), 0, 1, 1200, bot:GetAttackRange()))
		bot:Action_MoveToLocation(vLaneFront)
	end
end

return X