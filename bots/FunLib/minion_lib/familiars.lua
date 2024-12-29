local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local U = require(GetScriptDirectory()..'/FunLib/minion_lib/utils')

local X = {}
local bot

---------------------
-- Visage's Familiars
---------------------
local StoneForm
local IsAttackingSomethingNotHero = false
function X.Think(ownerBot, hMinionUnit)
	if J.CanNotUseAbility(hMinionUnit) then return end

	bot = ownerBot
	StoneForm = hMinionUnit:GetAbilityByName('visage_summon_familiars_stone_form')

	hMinionUnit.cast_desire = X.ConsiderStoneForm(hMinionUnit, StoneForm)
	if hMinionUnit.cast_desire > 0
	then
		hMinionUnit:Action_UseAbilityOnLocation(StoneForm, hMinionUnit:GetLocation())
		return
	end

	hMinionUnit.retreat_desire, hMinionUnit.retreat_location = X.ConsiderFamiliarRetreat(hMinionUnit)
	if hMinionUnit.retreat_desire > 0
	then
		hMinionUnit:Action_MoveToLocation(hMinionUnit.retreat_location + RandomVector(75))
		return
	end

	hMinionUnit.attack_desire, hMinionUnit.attack_target = X.ConsiderFamiliarAttack(hMinionUnit)
	if hMinionUnit.attack_desire > 0
	then
		hMinionUnit:Action_AttackUnit(hMinionUnit.attack_target, true)
		return
	end

	hMinionUnit.move_desire, hMinionUnit.move_location = X.ConsiderFamiliarMove(hMinionUnit)
	if hMinionUnit.move_desire > 0
	then
		hMinionUnit:Action_MoveToLocation(hMinionUnit.move_location + RandomVector(75))
		return
	end
end

function X.ConsiderStoneForm(hMinionUnit, ability)
	if not J.CanCastAbility(ability)
	or hMinionUnit:HasModifier('modifier_visage_summon_familiars_stone_form_buff')
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = ability:GetSpecialValueInt('stun_radius')

    local nFamiliarInRangeEnemy = hMinionUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

	if J.IsRetreating(bot)
	then
		for _, enemyHero in pairs(nFamiliarInRangeEnemy)
		do
			if  J.IsValidHero(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and J.IsChasingTarget(enemyHero, bot)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not U.CantMove(enemyHero)
            and bot:WasRecentlyDamagedByHero(enemyHero, 3.0)
			then
                return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.GetHP(hMinionUnit) < 0.35
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	for _, enemyHero in pairs(nFamiliarInRangeEnemy)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and enemyHero:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	local attackTarget = hMinionUnit:GetAttackTarget()
	if  J.IsValidHero(attackTarget)
	and not J.IsSuspiciousIllusion(attackTarget)
	and not J.IsDisabled(attackTarget)
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderFamiliarRetreat(hMinionUnit)
	if hMinionUnit:HasModifier('modifier_visage_summon_familiars_stone_form_buff')
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	if not bot:IsAlive()
	then
		return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain()
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFamiliarAttack(hMinionUnit)
	if hMinionUnit:HasModifier('modifier_visage_summon_familiars_stone_form_buff')
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local botTarget = J.GetProperTarget(bot)

	if J.IsValidHero(botTarget)
	or J.IsValidBuilding(botTarget)
	then
		IsAttackingSomethingNotHero = false
		return BOT_ACTION_DESIRE_HIGH, botTarget
	end

	local nUnits = bot:GetNearbyCreeps(700, true)
	for _, creep in pairs(nUnits)
	do
		if  J.IsValid(creep)
		and J.CanBeAttacked(creep)
		and GetUnitToUnitDistance(bot, hMinionUnit) < 1600
		then
			IsAttackingSomethingNotHero = true
			return BOT_ACTION_DESIRE_HIGH, creep
		end
	end

	nUnits = bot:GetNearbyTowers(700, true)
	for _, tower in pairs(nUnits)
	do
		if  J.IsValidBuilding(tower)
		and J.CanBeAttacked(tower)
		and tower:GetAttackTarget() ~= hMinionUnit
		and not hMinionUnit:WasRecentlyDamagedByTower(3)
		then
			local nInRangeEnemy = J.GetEnemiesNearLoc(tower:GetLocation(), 700)

			if  nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and GetUnitToUnitDistance(bot, hMinionUnit) < 1600
			then
				IsAttackingSomethingNotHero = true
				return BOT_ACTION_DESIRE_HIGH, tower
			end
		end
	end

	IsAttackingSomethingNotHero = false

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFamiliarMove(hMinionUnit)
	if hMinionUnit:HasModifier('modifier_visage_summon_familiars_stone_form_buff')
	or not bot:IsAlive()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and enemyHero:IsChanneling()
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local nInRangeAlly = enemyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
			local nInRangeEnemy = enemyHero:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

			if #nInRangeAlly >= #nInRangeEnemy
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
			end
		end
	end

	if  GetUnitToUnitDistance(hMinionUnit, bot) > hMinionUnit:GetAttackRange()
	and not IsAttackingSomethingNotHero
	then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation() + RandomVector(hMinionUnit:GetAttackRange())
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

-- --------------------
-- -- Lone Druid's Bear
-- --------------------
-- local sBearItems = {
--     "item_six_branches",

--     "item_phase_boots",
--     "item_diffusal_blade",
--     "item_harpoon",--
--     "item_aghanims_shard",
--     "item_assault",--
--     "item_basher",
--     "item_skadi",--
--     "item_disperser",--
--     "item_monkey_king_bar",--
-- 	"item_bloodthorn",--
-- }

-- local Return
-- local botTarget

-- function X.BearThink(hero, hMinionUnit)
--     bot = hero
--     botTarget = J.GetProperTarget(bot)
--     Return = hMinionUnit:GetAbilityByName('lone_druid_spirit_bear_return')

-- 	Desire = ConsiderReturn(hMinionUnit, Return)
-- 	if Desire > 0
-- 	then
-- 		hMinionUnit:Action_UseAbility(Return)
-- 		return
-- 	end

-- 	RetreatDesire, RetreatLocation = ConsiderBearRetreat(hMinionUnit)
-- 	if RetreatDesire > 0
-- 	then
-- 		hMinionUnit:Action_MoveToLocation(RetreatLocation)
-- 		return
-- 	end

-- 	AttackDesire, AttackTarget = ConsiderBearAttack(hMinionUnit)
-- 	if AttackDesire > 0
-- 	then
-- 		hMinionUnit:Action_AttackUnit(AttackTarget, false)
-- 		return
-- 	end

-- 	MoveDesire, MoveLocation = ConsiderBearMove(hMinionUnit)
-- 	if MoveDesire > 0
-- 	then
-- 		hMinionUnit:Action_MoveToLocation(MoveLocation)
-- 		return
-- 	end
-- end

-- function ConsiderReturn(hMinionUnit, ability)
--     if not ability:IsFullyCastable()
--     then
--         return BOT_ACTION_DESIRE_NONE
--     end

--     if GetUnitToUnitDistance(bot, hMinionUnit) > 1100
--     then
--         hMinionUnit:SetTarget(nil)
--         return BOT_ACTION_DESIRE_HIGH
--     end

--     return BOT_ACTION_DESIRE_NONE
-- end

-- function ConsiderBearRetreat(hMinionUnit)
--     if J.IsRetreating(bot)
--     then
--         local nInRangeAlly = hMinionUnit:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
--         local nInRangeEnemy = hMinionUnit:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

--         if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
--         and #nInRangeEnemy > #nInRangeAlly
--         then
--             return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
--         end
--     end

--     if  hMinionUnit:WasRecentlyDamagedByTower(1)
--     and J.GetHP(hMinionUnit) < 0.5
--     then
--         local nEnemyTower = hMinionUnit:GetNearbyTowers(700, true)
--         if  nEnemyTower ~= nil and #nEnemyTower >= 1
--         and GetUnitToUnitDistance(hMinionUnit, nEnemyTower[1]) < 700
--         then
--             return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
--         end
--     end

-- 	return BOT_ACTION_DESIRE_NONE, 0
-- end

-- function ConsiderBearAttack(hMinionUnit)
--     if J.IsPushing(bot) or J.IsDefending(bot)
--     then
--         local nEnemyTower = hMinionUnit:GetNearbyTowers(1200, true)
--         if nEnemyTower ~= nil and #nEnemyTower >= 1
--         then
--             return BOT_ACTION_DESIRE_HIGH, nEnemyTower[1]
--         end

--         local nEnemyLaneCreeps = hMinionUnit:GetNearbyLaneCreeps(1600, true)
--         if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 1
--         then
--             return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
--         end
--     end

--     if J.IsLaning(bot)
--     then
--         local nEnemyLaneCreeps = hMinionUnit:GetNearbyLaneCreeps(bot:GetAttackRange(), true)

--         if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 1
--         then
--             for _, creep in pairs(nEnemyLaneCreeps)
--             do
--                 if  J.IsValid(creep)
--                 and J.CanBeAttacked(creep)
--                 and creep:GetHealth() <= hMinionUnit:GetAttackDamage()
--                 then
--                     return BOT_ACTION_DESIRE_HIGH, creep
--                 end
--             end
--         end
--     end

--     if J.IsFarming(bot)
--     then
--         local nCreeps = hMinionUnit:GetNearbyCreeps(1600, true)
--         if  nCreeps ~= nil and #nCreeps >= 1
--         and J.IsAttacking(bot)
--         then
--             local target = nil
--             local hp = 0
--             for _, creep in pairs(nCreeps)
--             do
--                 if  J.IsValid(creep)
--                 and J.CanBeAttacked(creep)
--                 and hp < creep:GetHealth()
--                 then
--                     hp = creep:GetHealth()
--                     target = creep
--                 end
--             end

--             if target ~= nil
--             then
--                 return BOT_ACTION_DESIRE_HIGH, target
--             end
--         end
--     end

--     if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
--     then
--         if  (J.IsRoshan(bot) or J.IsDoingTormentor(bot))
--         and J.IsInRange(bot, botTarget, 500)
--         and J.IsAttacking(bot)
--         then
--             hMinionUnit:SetTarget(botTarget)
--             return BOT_ACTION_DESIRE_HIGH, botTarget
--         end
--     end

--     return BOT_ACTION_DESIRE_NONE, nil
-- end

-- function ConsiderBearMove(hMinionUnit)
--     if not J.IsInRange(bot, hMinionUnit, 700)
--     then
--         return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
--     end

--     return BOT_ACTION_DESIRE_NONE, 0
-- end

return X