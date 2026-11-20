local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end

local Utils = require( GetScriptDirectory()..'/FunLib/utils')
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local local_mode_attack_generic
if bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end

if Utils.BuggyHeroesDueToValveTooLazy[botName] then
	local_mode_attack_generic = dofile( GetScriptDirectory().."/FunLib/override_generic/mode_attack_generic" )
end

local Generic = {}

local fLastAttackDesire = 0
local botAttackRange, botHP, botLocation

function Generic.OnStart() end
function Generic.OnEnd()
	fLastAttackDesire = 0
end

local function GetActualDesire(nDesire)
	local alpha = 0.3
	nDesire = fLastAttackDesire * (1 - alpha) + nDesire * alpha
	fLastAttackDesire = nDesire
	return nDesire
end

function Generic.GetDesire()
	if not bot:IsAlive()
	or bot:IsIllusion()
	or bot:HasModifier('modifier_fountain_fury_swipes_damage_increase')
	then
		return BOT_MODE_DESIRE_NONE
	end

	botAttackRange = bot:GetAttackRange() + bot:GetBoundingRadius()
	botHP = J.GetHP(bot)
	botLocation = bot:GetLocation()

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if #nEnemyHeroes == 0 then
		return GetActualDesire(BOT_MODE_DESIRE_NONE)
	end

	-- Avoid trading/counterattacking under lethal lane creep damage during laning
	if J.IsInLaningPhase() then
		local creepDmg = 0
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)
		for _, creep in pairs(nEnemyLaneCreeps) do
			if J.IsValid(creep) and creep:GetAttackTarget() == bot then
				creepDmg = creepDmg + (bot:GetActualIncomingDamage(creep:GetAttackDamage() * creep:GetAttackSpeed() * 5.0, DAMAGE_TYPE_PHYSICAL) - bot:GetHealthRegen() * 5.0)
			end
		end
		if creepDmg / (bot:GetHealth() + 1) >= 0.25 then
			return GetActualDesire(BOT_MODE_DESIRE_NONE)
		end
	end

	-- Counterattack enemy heroes attacking this bot within 1200u
	for _, enemy in ipairs(nEnemyHeroes) do
		if J.IsValidHero(enemy)
		and not J.IsSuspiciousIllusion(enemy)
		and (enemy:GetAttackTarget() == bot or bot:WasRecentlyDamagedByHero(enemy, 2.5))
		and J.IsInRange(bot, enemy, 1200)
		then
			local nAllyNear = J.GetAlliesNearLoc(botLocation, 1200)
			local nEnemyNear = J.GetEnemiesNearLoc(botLocation, 1200)
			if #nEnemyNear <= #nAllyNear + 1 and botHP > 0.25 then
				return GetActualDesire(0.95)
			end
		end
	end

	-- Safe laning harass when not tanking tower or lethal burst
	if J.IsInLaningPhase() then
		local nAllyNear = J.GetAlliesNearLoc(botLocation, 1200)
		local nEnemyNear = J.GetEnemiesNearLoc(botLocation, 1200)
		local nEnemyTowers = bot:GetNearbyTowers(1200, true)
		local fEnemyDamage = 0
		for _, possibleEnemy in ipairs(nEnemyHeroes) do
			if J.IsValidHero(possibleEnemy)
			and J.GetHP(possibleEnemy) >= 0.25
			and J.IsInRange(bot, possibleEnemy, 900)
			then
				fEnemyDamage = fEnemyDamage + possibleEnemy:GetEstimatedDamageToTarget(false, bot, 3.0, DAMAGE_TYPE_ALL)
			end
		end
		if #nAllyNear >= #nEnemyNear
		and not bot:WasRecentlyDamagedByTower(2.0)
		and not (J.IsValidBuilding(nEnemyTowers[1]) and nEnemyTowers[1]:GetAttackTarget() == bot)
		and bot:GetHealth() > fEnemyDamage * 1.15
		then
			for _, enemy in ipairs(nEnemyHeroes) do
				if J.IsValidHero(enemy)
				and not J.IsSuspiciousIllusion(enemy)
				and J.IsInRange(bot, enemy, math.max(botAttackRange, 500))
				and botHP > 0.5
				then
					return GetActualDesire(0.42)
				end
			end
		end
	end

	return GetActualDesire(BOT_MODE_DESIRE_NONE)
end

function Generic.Think()
	if J.CanNotUseActionExceptQueue(bot) then
		return
	end

	botAttackRange = bot:GetAttackRange() + bot:GetBoundingRadius()
	botLocation = bot:GetLocation()

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nEnemyTowers = bot:GetNearbyTowers(1600, true)

	if J.IsValidBuilding(nEnemyTowers[1]) and nEnemyTowers[1]:GetAttackTarget() == bot then
		bot:Action_MoveToLocation(J.VectorAway(botLocation, nEnemyTowers[1]:GetLocation(), 900))
		return
	end

	local __target = nil
	for _, enemy in ipairs(nEnemyHeroes) do
		if J.IsValidHero(enemy)
		and not J.IsSuspiciousIllusion(enemy)
		and J.CanBeAttacked(enemy)
		and J.IsInRange(bot, enemy, 1200)
		then
			if enemy:GetAttackTarget() == bot or bot:WasRecentlyDamagedByHero(enemy, 2.5) then
				__target = enemy
				break
			end
		end
	end

	if __target == nil then
		local targetScore = -1
		for _, enemy in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemy)
			and not J.IsSuspiciousIllusion(enemy)
			and J.CanBeAttacked(enemy)
			and J.IsInRange(bot, enemy, math.max(botAttackRange + 200, 500))
			and not enemy:HasModifier('modifier_abaddon_borrowed_time')
			and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
			and not enemy:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
			and not enemy:HasModifier('modifier_ursa_enrage')
			and not enemy:HasModifier('modifier_item_aeon_disk_buff')
			then
				local mul = 1
				if J.IsCore(enemy) then mul = mul * 1.5 else mul = mul * 0.5 end
				local score = (1 - J.GetHP(enemy)) * mul
				if score > targetScore then
					targetScore = score
					__target = enemy
				end
			end
		end
	end

	if __target ~= nil then
		bot:SetTarget(__target)
		local dist = GetUnitToUnitDistance(bot, __target)
		if dist <= botAttackRange then
			bot:Action_AttackUnit(__target, true)
		else
			bot:Action_MoveToLocation(__target:GetLocation())
		end
		return
	end
end

if local_mode_attack_generic ~= nil then
	function GetDesire() return local_mode_attack_generic.GetDesire() end
	function Think() return local_mode_attack_generic.Think() end
	function OnStart() return local_mode_attack_generic.OnStart() end
	function OnEnd() return local_mode_attack_generic.OnEnd() end
else
	function GetDesire() return Generic.GetDesire() end
	function Think() return Generic.Think() end
	function OnStart() return Generic.OnStart() end
	function OnEnd() return Generic.OnEnd() end
end