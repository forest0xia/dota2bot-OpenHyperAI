local bot = GetBot()
local botName = bot:GetUnitName()

if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local targetBot = J.GetProperTarget( bot )
local nAllyHeroes, nEnemyHeroes, ourPower, enemyPower, uniqueMates, uniqueEnemies, nearbyEnemyUnits, nearbyAllyUnits, retreatDesire, possibleMaxDesire
local maxDesireReduceRate = 1.5 -- can make max smaller so any peak from one of the factor can have more impact. dont get too small to cause bots being passive.

if Utils.BuggyHeroesDueToValveTooLazy[botName] then
function GetDesire()
	if not bot:IsAlive() then return BOT_ACTION_DESIRE_NONE end
    if J.GetHP(bot) > 0.2 and (bot:IsUsingAbility() or bot:IsChanneling()) then return BOT_ACTION_DESIRE_NONE end

	-- 有特殊增益状态不要跑
	if J.IsHaveAegis( bot )
	or bot:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
	or bot:HasModifier('modifier_item_satanic_unholy')
	or bot:HasModifier('modifier_abaddon_borrowed_time')
	or J.GetModifierTime(bot, "modifier_muerta_pierce_the_veil_buff") > 0.5
	or (J.GetModifierTime(bot, 'modifier_dazzle_shallow_grave') > 0.5 and J.GetHP(bot) > 0.2)
	or J.GetModifierTime(bot, 'modifier_oracle_false_promise_timer') > 0.5
	or (bot:GetCurrentMovementSpeed() < 240 and not bot:HasModifier("modifier_arc_warden_spark_wraith_purge"))
	then
		return BOT_ACTION_DESIRE_NONE
	end

    -- if J.GetHP(bot) <= 0.3
	-- and Utils.RecentlyTookDamage(bot, 3)
	-- and botName ~= 'npc_dota_hero_huskar'
    -- then
    --     return BOT_ACTION_DESIRE_HIGH
    -- end

    nAllyHeroes = J.GetNearbyHeroes(bot, 1400, false, BOT_MODE_NONE)
    nEnemyHeroes = J.GetNearbyHeroes(bot, 1400, true, BOT_MODE_NONE)
	targetBot = J.GetProperTarget( bot )
	
    ourPower = 0
    enemyPower = 0
	uniqueMates = { }
	uniqueEnemies = { }
	nearbyEnemyUnits = CountNearByUnits(true, 700)
	nearbyAllyUnits = CountNearByUnits(false, 700)
	retreatDesire = 0
	possibleMaxDesire = 0

	-- more care in laning phase
	if J.IsInLaningPhase() and Utils.RecentlyTookDamage(bot, 2) then
		enemyPower = enemyPower * 2
		nearbyEnemyUnits = nearbyEnemyUnits * 2
	end

	if #nAllyHeroes > 0 then
		for _, hero in pairs(nAllyHeroes) do
			if not hero:IsIllusion()
			and not J.IsMeepoClone(hero)
			and not hero:HasModifier("modifier_arc_warden_tempest_double") then
				table.insert(uniqueMates, hero)
				ourPower = ourPower + hero:GetOffensivePower()
			end
		end
	end
	if #nEnemyHeroes > 0 then
		for _, hero in pairs(nEnemyHeroes) do
			if J.IsValidHero(hero)
			and not J.IsSuspiciousIllusion(hero)
			and not J.IsMeepoClone(hero)
			and not hero:HasModifier("modifier_arc_warden_tempest_double")
			then
				table.insert(uniqueEnemies, hero)
				if J.IsAttacking( hero ) and hero:IsFacingLocation(bot:GetLocation(), 5) then
					enemyPower = enemyPower + hero:GetRawOffensivePower()
				elseif hero:IsFacingLocation(bot:GetLocation(), 10) and GetUnitToUnitDistance(hero, bot) < hero:GetAttackRange() + 150 then
					enemyPower = enemyPower + hero:GetRawOffensivePower() * 0.4
				else
					enemyPower = enemyPower + hero:GetRawOffensivePower() * 0.2
				end
			end
		end
	end

	local weAreStronger = ourPower >= enemyPower

	-- if J.IsLaning( bot ) or bot:GetLevel() <= 10 then
		if not weAreStronger and J.GetHP(bot) < 0.7 then
			if bot:HasModifier('modifier_maledict') -- 防止中了巫医毒还继续吃伤害
			or bot:HasModifier('modifier_dazzle_poison_touch')
			-- or bot:HasModifier('modifier_slark_essence_shift_debuff') -- 防止不停被小鱼偷属性, 其实不被近身也算防止了
			-- or bot:HasModifier('modifier_razor_static_link_debuff') -- 电棍静电链接
			then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end

		-- 别被近战近身
		for _, enemy in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemy)
			and not bot.isBear
			and enemy:GetAttackRange() < 400
			and bot:GetAttackRange() > 400
			and GetUnitToUnitDistance( bot, enemy ) < enemy:GetAttackRange() + 260
			and J.GetHP(enemy) > J.GetHP(bot) - 0.2 then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	-- end

	-- 别遛进塔
	local nTowers = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
		TOWER_TOP_2,
		TOWER_TOP_3,
		TOWER_MID_2,
		TOWER_MID_3,
		TOWER_BOT_2,
		TOWER_BOT_3,
		TOWER_BASE_1,
		TOWER_BASE_2,
	}
	local towers = bot:GetNearbyTowers(700, true )
	if #towers >= 1 then
		local towerType = -1
		for i = 1, #nTowers do
			local tower = GetTower(GetOpposingTeam(), nTowers[i])
			if tower == towers[1] then
				towerType = nTowers[i]
			end
		end

		-- may only go aggresive for T1s
		local distanceToTower = GetUnitToUnitDistance(bot, towers[1])
		local deltaRange = 200
		if towerType == TOWER_TOP_1 or towerType == TOWER_MID_1 or towerType == TOWER_BOT_1 then
			if J.IsValid(targetBot)
			and distanceToTower < towers[1]:GetAttackRange() + deltaRange
			and GetUnitToUnitDistance( bot, targetBot ) > bot:GetAttackRange() + deltaRange
			and J.GetHP(targetBot) > 0.2
			and not (bot:IsStunned() or bot:IsHexed() or J.IsInRange(bot, targetBot, bot:GetAttackRange())) then
				bot:Action_ClearActions(false)
				return BOT_ACTION_DESIRE_HIGH
			end
			if distanceToTower < towers[1]:GetAttackRange() + deltaRange then
				bot:Action_ClearActions(false)
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	-- 别轻易上高送
	if #nAllyHeroes <= 2 and #nAllyHeroes + 1 <= J.GetNumOfAliveHeroes(true)
	and GetUnitToLocationDistance(bot, J.GetEnemyFountain()) < 5500
	and bot:GetActiveModeDesire() <= BOT_ACTION_DESIRE_HIGH then
		bot:Action_ClearActions(false)
		return BOT_ACTION_DESIRE_HIGH
	end

	-- 掩护队友
	if #nAllyHeroes >= 2 and J.GetHP(bot) > 0.3 then
		for _, hero in pairs(nAllyHeroes) do
			if hero ~= bot and J.IsRetreating(hero) and J.GetHP(hero) < J.GetHP(bot) then
				return BOT_ACTION_DESIRE_NONE
			end
		end
	end

	-- if weAreStronger then
	-- 	return RemapValClamped(ourPower / enemyPower, 1, 3, BOT_ACTION_DESIRE_LOW , BOT_ACTION_DESIRE_VERYLOW )
	-- elseif #uniqueMates < #uniqueEnemies or (targetBot ~= nil and J.GetHP(targetBot) > J.GetHP(bot)) then
    --     return BOT_ACTION_DESIRE_HIGH
	-- end

	-- if halfway back to fountain
	if bot:DistanceFromFountain() < 5000
	and botName ~= 'npc_dota_hero_huskar'
	and (Utils.TimeNeedToHealHP(bot) > 60 or Utils.TimeNeedToHealMP(bot) > 60)
	and bot:GetActiveModeDesire() <= BOT_ACTION_DESIRE_HIGH then
        return BOT_ACTION_DESIRE_HIGH
	end

	if J.GetHP(bot) < 0.15
	and (not J.IsValid(targetBot) or J.GetHP(targetBot) > J.GetHP(bot) or Utils.RecentlyTookDamage(bot, 3))
	then
		return BOT_ACTION_DESIRE_VERYHIGH
	end

	local closestEnemy, closestAlly = nEnemyHeroes[1], nAllyHeroes[1]

	-- enemy may going for nearby ally. dont retreat.
	-- if J.IsValidHero(closestEnemy)
	-- and not closestEnemy:IsFacingLocation(bot:GetLocation(), 8) then
	-- 	return BOT_ACTION_DESIRE_NONE
	-- end

	-- General cases:

	retreatDesire = retreatDesire + RemapValClamped(enemyPower / ourPower, 0, 2, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_VERYHIGH )
	retreatDesire = retreatDesire + RemapValClamped(nearbyEnemyUnits - nearbyAllyUnits, 0, 5, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_VERYHIGH )
	retreatDesire = retreatDesire + RemapValClamped(#uniqueEnemies - #uniqueMates, 0, 2, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_VERYHIGH )
	retreatDesire = retreatDesire + RemapValClamped(J.GetHP(bot), 0.7, 0, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_ABSOLUTE )
	possibleMaxDesire = BOT_ACTION_DESIRE_VERYHIGH * 4

	if J.IsValid(closestEnemy) and J.GetHP(bot) < J.GetHP(closestEnemy) then
		retreatDesire = retreatDesire + RemapValClamped(GetUnitToUnitDistance(closestEnemy, bot) - bot:GetAttackRange(), 0, -bot:GetAttackRange(), BOT_ACTION_DESIRE_VERYLOW, BOT_ACTION_DESIRE_VERYHIGH * 2 )
		possibleMaxDesire = possibleMaxDesire + BOT_ACTION_DESIRE_VERYHIGH
	end
	possibleMaxDesire = possibleMaxDesire / maxDesireReduceRate

	local clampedDesire = RemapValClamped(retreatDesire, 0, possibleMaxDesire, 0, 1)

	-- if bot.isBear then
	-- 	clampedDesire = clampedDesire * 0.9
	-- end

	-- print('Retreat mode, bot: '..botName..', clamped desire: ' .. tostring(clampedDesire))

	if retreatDesire > 0 then
		return clampedDesire
	end

    return BOT_ACTION_DESIRE_NONE
end

end

function CountNearByUnits(bEnemy, range)
	local nearbyEnemies = 0
	local team = bEnemy and GetOpposingTeam() or GetTeam()
	local pIDs = GetTeamPlayers(team)
	for _, pid in pairs(pIDs) do
		local lastSeenInfo = GetHeroLastSeenInfo(pid)
		if lastSeenInfo ~= nil and lastSeenInfo[1] ~= nil then
			local lastSeenI = lastSeenInfo[1]
			if GetUnitToLocationDistance(bot, lastSeenI.location) <= 1600 then
				nearbyEnemies = nearbyEnemies + 1
			end
		end
	end

	local uList = bEnemy and UNIT_LIST_ENEMIES or UNIT_LIST_ALLIES
	local units = GetUnitList(uList)
	for _, unit in pairs(units) do
		if Utils.IsValidUnit(unit)
		and GetUnitToUnitDistance(bot, unit) <= range
		then
			local deltaEnemy = 1
			if string.find(unit:GetUnitName(), 'spiderling') then deltaEnemy = 0.1 end
			if string.find(unit:GetUnitName(), 'eidolon') then deltaEnemy = 0.3 end
			if string.find(unit:GetUnitName(), 'lone_druid_bear') then deltaEnemy = 1 end
			if string.find(unit:GetUnitName(), 'tower') then deltaEnemy = 3 end
			if string.find(unit:GetUnitName(), 'warlock_golem') then
				if DotaTime() < 10 * 60 then deltaEnemy = 3
				elseif DotaTime() < 20 * 60 then deltaEnemy = 2.5
				elseif DotaTime() < 30 * 60 then deltaEnemy = 2
				end
			end
			if string.find(unit:GetUnitName(), "tombstone") then deltaEnemy = 2 end

			if unit:IsFacingLocation(bot:GetLocation(), 10) and GetUnitToUnitDistance(unit, bot) < unit:GetAttackRange() + 100
			then
				deltaEnemy = deltaEnemy * 0.8
			else
				deltaEnemy = deltaEnemy * 0.3
			end
			nearbyEnemies = nearbyEnemies + deltaEnemy
		end
	end
	return nearbyEnemies
end
