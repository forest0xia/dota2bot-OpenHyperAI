
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local X = {}

function GetDesire()
	local bot = GetBot()
	
	local currentTime = DotaTime()
	local botLV = bot:GetLevel()
	local networth = bot:GetNetWorth()
	local isBotCore = J.IsCore(bot)
	local isEarlyGame = J.IsModeTurbo() and DotaTime() < 8 * 60 or DotaTime() < 12 * 60

	if currentTime < 0 then
		return BOT_ACTION_DESIRE_NONE
	end

	if  J.IsGoingOnSomeone(bot)
	and J.IsInLaningPhase()
	then
		local botTarget = J.GetProperTarget(bot)
		if  J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 1600)
		and J.IsChasingTarget(bot, botTarget)
		then
			local chasingAlly = {}
			local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
			for _, allyHero in pairs(nInRangeAlly)
			do
				if  J.IsValidHero(allyHero)
				and J.IsChasingTarget(allyHero, botTarget)
				and allyHero ~= bot
				and not J.IsRetreating(allyHero)
				and not J.IsSuspiciousIllusion(allyHero)
				then
					table.insert(chasingAlly, allyHero)
				end
			end

			table.insert(chasingAlly, bot)

			local nEnemyTowers = bot:GetNearbyTowers(700, true)
			if nEnemyTowers ~= nil and #nEnemyTowers >= 1
			then
				if botTarget:GetHealth() > J.GetTotalEstimatedDamageToTarget(chasingAlly, botTarget)
				then
					return bot:GetActiveModeDesire() + 0.1
				end
			end
		end
	end

	if isEarlyGame and botLV < 6
	then
		if isBotCore
		then
			return BOT_MODE_DESIRE_HIGH
		end

		return BOT_MODE_DESIRE_MODERATE
	end

	if isBotCore and networth < 4500
	then
		return BOT_MODE_DESIRE_HIGH
	end

	if  not isBotCore
	and not J.IsInLaningPhase()
	then
		local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1600)
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(700, true)

		if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil and nEnemyLaneCreeps ~= nil
		and #nInRangeAlly == 0 and #nInRangeEnemy == 0 and #nEnemyLaneCreeps >= 1
		and not J.IsPushing(bot)
		and not J.IsDefending(bot)
		and not J.IsDoingRoshan(bot)
		and not J.IsDoingTormentor(bot)
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_MODE_DESIRE_VERYLOW
end

X.GetDesire = GetDesire

return X