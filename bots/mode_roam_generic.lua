local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local bot = GetBot()
local botName = bot:GetUnitName()

if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end


local cAbility = nil
local TinkerShouldWaitInBaseToHeal = false

local ShouldWaitInBaseToHeal = false
local TPScroll = nil

local ShouldMoveCloseTowerForEdict = false
local EdictTowerTarget = nil

local ShouldMoveOutsideFountain = false
local ShouldMoveOutsideFountainCheckTime = 0
local MoveOutsideFountainDistance = 1500
local BearAttackLimitDistance = 1100
local ConsiderHeroSpecificRoaming = {}


local laneToRoam = nil
local lastRoamDecisionTime = DotaTime()
local roamDecisionHoldTime = 1.25 * 60 -- cant change dicision within this time
local TwinGates = { }
local targetGate
local gateWarp = bot:GetAbilityByName("twin_gate_portal_warp")
local enableGateUsage = false -- to be fixed
local arriveRoamLocTime = 0
local roamTimeAfterArrival = 0.55 * 60 -- stay to roam after arriving the location
local roamGapTime = 3 * 60 -- don't roam again within this duration after roaming once.
local nInRangeEnemy

function GetDesire()

	TPScroll = J.GetItem2(bot, 'item_tpscroll')

	if ConsiderWaitInBaseToHeal()
	and GetUnitToLocationDistance(bot, J.GetTeamFountain()) > 5500
	then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end

	TinkerShouldWaitInBaseToHeal = TinkerWaitInBaseAndHeal()
	if TinkerShouldWaitInBaseToHeal
	then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end

	if DotaTime() > 0 and DotaTime() - ShouldMoveOutsideFountainCheckTime < 2 then
		return Clamp(bot:GetActiveModeDesire() + 0.2, 0, 1.1)
	else
		ShouldMoveOutsideFountain = false
	end

	if ConsiderHeroMoveOutsideFountain() then
		ShouldMoveOutsideFountain = true
		ShouldMoveOutsideFountainCheckTime = DotaTime()
		return Clamp(bot:GetActiveModeDesire() + 0.2, 0, 1.1)
	end

	-- unit special abilities
	local specialRoaming = ConsiderHeroSpecificRoaming[botName]
	if specialRoaming then
		-- return specialRoaming
		return Clamp(specialRoaming(), 0, 0.99)
	end

	-- general items or conditions.
	local generalRoaming = ConsiderGeneralRoamingInConditions()
	if generalRoaming then
		return Clamp(generalRoaming, 0, 0.99)
	end

	return BOT_MODE_DESIRE_NONE
end

function Think()
    if J.CanNotUseAction(bot) then return end

	nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	ThinkIndividualRoaming() -- unit special abilities
	-- ThinkActualRoamingInLanes()
	ThinkGeneralRoaming() -- general items or conditions.
end

function ThinkIndividualRoaming()
	-- Heal in Base
	-- Just for TP. Too much back and forth when "forcing" them try to walk to fountain; <- not reliable and misses farm.
	if ShouldWaitInBaseToHeal
	then
		if GetUnitToLocationDistance(bot, J.GetTeamFountain()) > 150
		then
			nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
			if  J.Item.GetItemCharges(bot, 'item_tpscroll') >= 1
			and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			then
				if bot:GetUnitName() == 'npc_dota_hero_furion'
				then
					local Teleportation = bot:GetAbilityByName('furion_teleportation')
					if  Teleportation:IsTrained()
					and Teleportation:IsFullyCastable()
					then
						bot:Action_UseAbilityOnLocation(Teleportation, J.GetTeamFountain())
						return
					end
				end

				if  TPScroll ~= nil
				and not TPScroll:IsNull()
				and TPScroll:IsFullyCastable()
				then
					bot:Action_UseAbilityOnLocation(TPScroll, J.GetTeamFountain())
					return
				end
			end
		else
			if J.GetHP(bot) < 0.85 or J.GetMP(bot) < 0.85
			then
				if  J.Item.GetItemCharges(bot, 'item_tpscroll') <= 1
				and bot:GetGold() >= GetItemCost('item_tpscroll')
				then
					bot:ActionImmediate_PurchaseItem('item_tpscroll')
					return
				end

				bot:Action_MoveToLocation(bot:GetLocation() + 150)
				return
			else
				ShouldWaitInBaseToHeal = false
			end
		end
	end

	-- Tinker
	if TinkerShouldWaitInBaseToHeal
	then
		if J.GetHP(bot) < 0.8 or J.GetMP(bot) < 0.8
		then
			bot:Action_ClearActions(true)
			return
		end
	end

	-- Spirit Breaker
	if bot:HasModifier('modifier_spirit_breaker_charge_of_darkness')
	then
		bot:Action_ClearActions(false)
		if  bot.chargeRetreat
		and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
		then
			bot:Action_MoveToLocation(bot:GetLocation() + RandomVector(150))
			bot.chargeRetreat = false
		end

		return
	end

	-- Batrider
	if bot:HasModifier('modifier_batrider_flaming_lasso_self')
	then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	-- Nyx Assassin
	if bot.canVendettaKill
	then
		if bot.vendettaTarget ~= nil
		then
			if GetUnitToUnitDistance(bot, bot.vendettaTarget) > bot:GetAttackRange()
			then
				bot:Action_MoveToLocation(bot.vendettaTarget:GetLocation())
				return
			else
				bot:Action_AttackUnit(bot.vendettaTarget, true)
				return
			end
		end
	end

	-- Rolling Thunder
	if bot:HasModifier('modifier_pangolier_gyroshell')
	then
		if J.IsInTeamFight(bot, 1600)
		then
			local target = nil
			local hp = 0
			for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
			do
				if J.IsValidHero(enemyHero)
				and J.IsInRange(bot, enemyHero, 2200)
				and J.CanBeAttacked(enemyHero)
				and J.CanCastOnNonMagicImmune(enemyHero)
				and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
				and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				and hp < enemyHero:GetHealth()
				then
					hp = enemyHero:GetHealth()
					target = enemyHero
				end
			end

			if target ~= nil
			then
				bot:Action_MoveToLocation(target:GetLocation())
				return
			end
		end

		if J.IsRetreating(bot)
		then
			bot:Action_MoveToLocation(J.GetTeamFountain())
			return
		end

		local tEnemyHeroes = bot:GetNearbyHeroes(880, true, BOT_MODE_NONE)
		if J.IsValidHero(tEnemyHeroes[1])
		and not tEnemyHeroes[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			bot:Action_MoveToLocation(tEnemyHeroes[1]:GetLocation())
			return
		end

		local tCreeps = bot:GetNearbyCreeps(880, true)
		if J.IsValid(tCreeps[1])
		then
			bot:Action_MoveToLocation(tCreeps[1]:GetLocation())
			return
		end
	end

	-- Primal Beast
	if bot:HasModifier('modifier_primal_beast_trample') then
		if J.IsInTeamFight(bot, 1600)
		then
			local target = nil
			local hp = 0
			for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
			do
				if J.IsValidHero(enemyHero)
				and J.IsInRange(bot, enemyHero, 2200)
				and J.CanBeAttacked(enemyHero)
				and J.CanCastOnNonMagicImmune(enemyHero)
				and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
				and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				and hp < enemyHero:GetHealth()
				then
					hp = enemyHero:GetHealth()
					target = enemyHero
				end
			end

			if target ~= nil
			then
				bot:ActionQueue_MoveToLocation(target:GetLocation() + RandomVector(200))
				return
			end
		end

		if J.IsRetreating(bot)
		then
			bot:ActionQueue_MoveToLocation(J.GetTeamFountain() + RandomVector(200))
			return
		end

		local tEnemyHeroes = bot:GetNearbyHeroes(880, true, BOT_MODE_NONE)
		if J.IsValidHero(tEnemyHeroes[1])
		and not tEnemyHeroes[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			bot:ActionQueue_MoveToLocation(tEnemyHeroes[1]:GetLocation() + RandomVector(200))
			return
		end

		local tCreeps = bot:GetNearbyCreeps(880, true)
		if J.IsValid(tCreeps[1])
		then
			bot:ActionQueue_MoveToLocation(tCreeps[1]:GetLocation() + RandomVector(200))
			return
		end
	end

	-- Phoenix
	if bot:HasModifier('modifier_phoenix_sun_ray') and not bot:HasModifier('modifier_phoenix_supernova_hiding')
	then
		if J.IsValidHero(bot.targetSunRay)
		then
			bot:Action_MoveToLocation(bot.targetSunRay:GetLocation())
			return
		end
	end

	-- Snapfire
	if bot:HasModifier('modifier_snapfire_mortimer_kisses')
	then
		local nKissesTarget = GetMortimerKissesTarget()

		if nKissesTarget ~= nil
		then
			local eta = (GetUnitToUnitDistance(bot, nKissesTarget) / 1300) + 0.3
			bot:Action_MoveToLocation(J.GetCorrectLoc(nKissesTarget, eta))
			return
		end
	end

	-- Leshrac
	if ShouldMoveCloseTowerForEdict
	then
		if EdictTowerTarget ~= nil
		then
			if GetUnitToUnitDistance(bot, EdictTowerTarget) > 350
			then
				bot:Action_MoveToLocation(EdictTowerTarget:GetLocation())
				return
			end
		end
	end

	-- Void Spirit
	if bot:HasModifier('modifier_void_spirit_dissimilate_phase')
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsGoingOnSomeone(bot)
		then
			if J.IsValidTarget(botTarget)
			then
				bot:Action_MoveToLocation(botTarget:GetLocation())
			end
		end

		if J.IsRetreating(bot)
		then
			bot:Action_MoveToLocation(J.GetEscapeLoc())
		end

		return
	end

	-- Marci
	if bot:HasModifier("modifier_marci_unleash") then
		local botTarget = J.GetProperTarget(bot)
		if GetUnitToUnitDistance(bot, botTarget) > bot:GetAttackRange()
		then
			bot:Action_MoveToLocation(botTarget:GetLocation())
			return
		else
			bot:Action_AttackUnit(botTarget, false)
			return
		end
	end

	-- Leshrac
	if bot:HasModifier("modifier_leshrac_pulse_nova")
	then
		local botTarget = J.GetProperTarget(bot)
		if GetUnitToUnitDistance(bot, botTarget) > 400
		then
			bot:Action_MoveToLocation(botTarget:GetLocation())
			return
		else
			bot:ActionQueue_AttackUnit(botTarget, false)
			return
		end
	end

	if botName == 'npc_dota_hero_lone_druid_bear' then
		local hero = J.Utils.GetLoneDruid(bot).hero
		local hasUltimateScepter = J.Item.HasItem(bot, 'item_ultimate_scepter') or bot:HasModifier('modifier_item_ultimate_scepter_consumed')
		local distanceFromHero = GetUnitToUnitDistance(J.Utils.GetLoneDruid(bot).hero, bot)
		local target = J.GetProperTarget(bot) or J.GetProperTarget(hero)

		if J.IsValidHero(hero)
		and not hasUltimateScepter
		then
			-- has enemy near by.
			if #nInRangeEnemy >= 1 then
				-- distance to bear beyond attack limit
				if distanceFromHero > BearAttackLimitDistance then
					bot:Action_ClearActions(false)
					bot:Action_MoveToLocation(hero:GetLocation())
					return
				end
				-- distance of target to hero beyond attack limit
				if J.IsValidTarget(target) then
					local heroDistanceFromTarget = GetUnitToUnitDistance(hero, target)
					if heroDistanceFromTarget > BearAttackLimitDistance then
						bot:Action_ClearActions(false)
						bot:Action_AttackMove(hero:GetLocation())
						return
					end
				end
			else
				if distanceFromHero > 500 then
					bot:Action_ClearActions(false)
					bot:Action_AttackMove(hero:GetLocation())
					return
				end
			end
			if J.IsValidTarget(target) then
				bot:Action_AttackUnit(target, false)
				return
			end
		end
		return
	end
end

function ThinkGeneralRoaming()
	-- Get out of fountain if in item mode
	if ShouldMoveOutsideFountain
	then
		bot:Action_AttackMove(J.Utils.GetOffsetLocationTowardsTargetLocation(J.GetTeamFountain(), J.GetEnemyFountain(), MoveOutsideFountainDistance))
		return
	end

	if bot:HasModifier("modifier_item_mask_of_madness_berserk") then
		local botTarget = J.GetProperTarget(bot)
		if GetUnitToUnitDistance(bot, botTarget) > bot:GetAttackRange()
		then
			bot:Action_MoveToLocation(botTarget:GetLocation())
			return
		else
			bot:Action_AttackUnit(botTarget, false)
			return
		end
	end
end

function GankWithTwinGateDesire()
	if J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() or not bot:IsAlive() or gateWarp == nil then return BOT_ACTION_DESIRE_NONE end

	if #TwinGates == 0 then
		for _, unit in pairs(GetUnitList(UNIT_LIST_ALL))
		do
			if unit:GetUnitName() == 'npc_dota_unit_twin_gate'
			then
				table.insert(TwinGates, unit)
			end
			if #TwinGates >= 2 then
				break
			end
		end
	end

	if J.IsInLaningPhase() then
		local botLvl = bot:GetLevel()
		if (J.GetPosition(bot) == 2 and botLvl >= 6) -- mid player roaming
		or (J.GetPosition(bot) > 3 and botLvl >= 3) -- supports roaming
		then
			return CheckLaneToRoam()
		end
	end
	return BOT_MODE_DESIRE_NONE
end

function ThinkActualRoamingInLanes()
	if laneToRoam ~= nil then
		local targetLoc = GetLaneFrontLocation(GetTeam(), laneToRoam, -300)
		local distanceToRoamLoc = GetUnitToLocationDistance(bot, targetLoc)
		if distanceToRoamLoc > 5000 then
			if J.GetPosition(bot) > 3
			and targetGate ~= nil
			and enableGateUsage
			then
				local distanceToGate = GetUnitToUnitDistance(bot, targetGate)
				if distanceToGate > 350 then
					bot:Action_MoveToLocation(targetGate:GetLocation())
					return
				elseif gateWarp:IsFullyCastable()
				then
					print('Trying to use gate '..botName)
					bot:Action_UseAbilityOnEntity(gateWarp, targetGate)
					return
				end
			end
		end

		if distanceToRoamLoc > bot:GetAttackRange() + 300 and bot:WasRecentlyDamagedByAnyHero(1.5) then
			bot:Action_MoveToLocation(targetLoc)
		end
		if distanceToRoamLoc < 600 and DotaTime() - arriveRoamLocTime > roamTimeAfterArrival * 1.1 then
			arriveRoamLocTime = DotaTime()
		end
		if DotaTime() - arriveRoamLocTime > roamTimeAfterArrival then
			laneToRoam = nil
		end
	end
end

function OnStart()
	lastRoamDecisionTime = DotaTime()
end

function OnEnd()
	laneToRoam = nil
	targetGate = nil
end

function CheckLaneToRoam()

	if DotaTime() - lastRoamDecisionTime <= roamDecisionHoldTime and laneToRoam ~= nil then
		return BOT_ACTION_DESIRE_VERYHIGH
	end

	if DotaTime() - lastRoamDecisionTime < roamGapTime then
		return BOT_MODE_DESIRE_NONE
	end

	if not HasSufficientMana(300) then -- idelaly should have mana at least able to use 2 abilities + tp.
		return BOT_MODE_DESIRE_NONE
	end

	local lanes = {
		{LANE_TOP, TOWER_TOP_1},
		{LANE_MID, TOWER_MID_1},
		{LANE_BOT, TOWER_BOT_1}
	}

	for _, lane in pairs(lanes)
	do
		local enemyCountInLane = J.GetEnemyCountInLane(lane[1])
		if enemyCountInLane > 0
		then
			local laneFront = GetLaneFrontLocation(GetTeam(), lane[1], 0)
			local tTower = GetTower(GetTeam(), lane[2])
			local laneFrontToT1Dist = GetUnitToLocationDistance(tTower, laneFront)
			local nInRangeAlly = J.GetAlliesNearLoc(laneFront, 1200)

			if tTower ~= nil
			and enableGateUsage
			and laneFrontToT1Dist < 2000
			then
				targetGate = GetGateNearLane(laneFront)

				if enemyCountInLane >= #nInRangeAlly
				then
					laneToRoam = lane[1]
					return RemapValClamped(GetUnitToUnitDistance(bot, targetGate), 5000, 600, BOT_ACTION_DESIRE_VERYLOW, BOT_ACTION_DESIRE_VERYHIGH )
				end
			end

			if #enemyCountInLane >= 1 then
				return RemapValClamped(laneFrontToT1Dist, 4000, 400, BOT_ACTION_DESIRE_LOW, BOT_ACTION_DESIRE_VERYHIGH)
			end

		end
	end

	return BOT_MODE_DESIRE_NONE
end

function HasSufficientMana(nMana)
	return bot:GetMana() > nMana and not botName == 'npc_dota_hero_huskar'
end

function GetGateNearLane(laneLoc)
	local minDis = 99999
	local tGate
	for _, gate in pairs(TwinGates)
	do
		local distanceToGate = GetUnitToLocationDistance(gate, laneLoc)
		if distanceToGate < minDis then
			tGate = gate
			minDis = distanceToGate
		end
	end
	return tGate
end


function TinkerWaitInBaseAndHeal()
	if  bot:GetUnitName() == 'npc_dota_hero_tinker'
	and bot.healInBase
	and GetUnitToLocationDistance(bot, J.GetTeamFountain()) < 500
	then
		return true
	end

	return false
end

function GetMortimerKissesTarget()
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if  J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, 3000 + (275 / 2))
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsInRange(bot, enemyHero, 600)
		then
			if J.IsLocationInChrono(enemyHero:GetLocation())
			or J.IsLocationInBlackHole(enemyHero:GetLocation())
			then
				return enemyHero
			end
		end

		if  J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, 3000 + (275 / 2))
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsInRange(bot, enemyHero, 600)
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return enemyHero
		end
	end

	local nCreeps = bot:GetNearbyCreeps(1600, true)
	if J.IsValid(nCreeps[1])
	then
		return nCreeps[1]
	end

	return nil
end


-- Just for TP. Too much back and forth when "forcing" them try to walk to fountain; <- not reliable and misses farm.
function ConsiderWaitInBaseToHeal()
	local ProphetTP = nil
	if bot:GetUnitName() == 'npc_dota_hero_furion'
	then
		ProphetTP = bot:GetAbilityByName('furion_teleportation')
	end

	if  not J.IsInLaningPhase()
	and not (J.IsFarming(bot) and J.IsAttacking(bot))
	and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
	and GetUnitToUnitDistance(bot, GetAncient(GetOpposingTeam())) > 2400
	and (  (TPScroll ~= nil and TPScroll:IsFullyCastable())
		or (ProphetTP ~= nil and ProphetTP:IsTrained() and ProphetTP:IsFullyCastable()))
	then
		if  (J.GetHP(bot) < 0.25
			and bot:GetHealthRegen() < 15
			and bot:GetUnitName() ~= 'npc_dota_hero_huskar'
			and bot:GetUnitName() ~= 'npc_dota_hero_slark'
			and bot:GetUnitName() ~= 'npc_dota_hero_necrolyte'
			and not bot:HasModifier('modifier_tango_heal')
			and not bot:HasModifier('modifier_flask_healing')
			and not bot:HasModifier('modifier_alchemist_chemical_rage')
			and not bot:HasModifier('modifier_arc_warden_tempest_double')
			and not bot:HasModifier('modifier_juggernaut_healing_ward_heal')
			and not bot:HasModifier('modifier_oracle_purifying_flames')
			and not bot:HasModifier('modifier_warlock_fatal_bonds')
			and not bot:HasModifier('modifier_item_satanic_unholy')
			and not bot:HasModifier('modifier_item_spirit_vessel_heal')
			and not bot:HasModifier('modifier_item_urn_heal'))
		or (((J.IsCore(bot) and J.GetMP(bot) < 0.25 and (J.GetHP(bot) < 0.75 and bot:GetHealthRegen() < 10))
				or ((not J.IsCore(bot) and J.GetMP(bot) < 0.25 and bot:GetHealthRegen() < 10)))
			and bot:GetUnitName() ~= 'npc_dota_hero_necrolyte'
			and not (J.IsPushing(bot) and #J.GetAlliesNearLoc(bot:GetLocation(), 900) >= 3))
		then
			ShouldWaitInBaseToHeal = true
			return true
		end
	end

	return false
end

function ConsiderHeroMoveOutsideFountain()
	if DotaTime() < 0 then return false end
	if bot:DistanceFromFountain() > MoveOutsideFountainDistance then return false end

	if (bot:HasModifier('modifier_fountain_aura_buff') -- in fountain with high hp
		and J.GetHP(bot) > 0.95)
	and (bot:GetUnitName() == 'npc_dota_hero_huskar' -- is huskar (ignore mana)
		or (bot:GetActiveMode() == BOT_MODE_ITEM -- is stuck in item mode
			and J.GetMP(bot) > 0.95))
	then
		return true
	end

	return false
end

function ConsiderGeneralRoamingInConditions()
	if bot:HasModifier("modifier_item_mask_of_madness_berserk") then
		if J.GetHP(bot) > 0.2 then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end
end

------------------------------
-- Hero Channel/Kill/CC abilities
------------------------------
-- ConsiderHeroSpecificRoaming['npc_dota_hero_rubick'] = function ()
-- 	if bot:IsChanneling() or bot:IsUsingAbility() or bot:IsCastingAbility()
-- 	then
-- 		return BOT_MODE_DESIRE_ABSOLUTE
-- 	end
-- 	return BOT_MODE_DESIRE_NONE
-- end

function CheckHighPriorityChannelAbility(abilityName)
	if cAbility == nil then cAbility = bot:GetAbilityByName(abilityName) end;
	if cAbility:IsTrained() and (cAbility:IsInAbilityPhase() or bot:IsChanneling()) then
		return BOT_MODE_DESIRE_ABSOLUTE;
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_pugna'] = function ()
	return CheckHighPriorityChannelAbility("pugna_life_drain")
end

ConsiderHeroSpecificRoaming['npc_dota_hero_drow_ranger'] = function ()
	return CheckHighPriorityChannelAbility("drow_ranger_multishot")
end

ConsiderHeroSpecificRoaming['npc_dota_hero_shadow_shaman'] = function ()
	return CheckHighPriorityChannelAbility("shadow_shaman_shackles")
end

ConsiderHeroSpecificRoaming['npc_dota_hero_clinkz'] = function ()
	return CheckHighPriorityChannelAbility("clinkz_burning_barrage")
end

ConsiderHeroSpecificRoaming['npc_dota_hero_tiny'] = function ()
	return CheckHighPriorityChannelAbility("tiny_tree_channel")
end

ConsiderHeroSpecificRoaming['npc_dota_hero_void_spirit'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("void_spirit_dissimilate") end
	if cAbility:IsTrained()
	then
		if cAbility:IsInAbilityPhase() or bot:HasModifier("modifier_void_spirit_dissimilate_phase")
		then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_primal_beast'] = function ()
	if bot:HasModifier('modifier_primal_beast_trample') then
		return BOT_MODE_DESIRE_ABSOLUTE
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_batrider'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("batrider_flaming_lasso") end
	if cAbility:IsTrained()
	then
		if cAbility:IsInAbilityPhase() or bot:HasModifier("modifier_batrider_flaming_lasso_self")
		then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_enigma'] = function ()
	return CheckHighPriorityChannelAbility("enigma_black_hole")
end

ConsiderHeroSpecificRoaming['npc_dota_hero_keeper_of_the_light'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("keeper_of_the_light_illuminate") end
	if cAbility:IsInAbilityPhase() or bot:IsChanneling() or bot:HasModifier('modifier_keeper_of_the_light_illuminate') then
		return BOT_MODE_DESIRE_ABSOLUTE
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_meepo'] = function ()
	return CheckHighPriorityChannelAbility("meepo_poof")
end

ConsiderHeroSpecificRoaming['npc_dota_hero_monkey_king'] = function ()
	return CheckHighPriorityChannelAbility("monkey_king_primal_spring")
end

ConsiderHeroSpecificRoaming['npc_dota_hero_nyx_assassin'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("nyx_assassin_vendetta") end
	if cAbility:IsTrained()
	then
		if cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_nyx_assassin_vendetta')
		then
			if bot.canVendettaKill
			then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_pangolier'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("pangolier_gyroshell") end
	if cAbility:IsTrained()
	then
		if cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_pangolier_gyroshell')
		then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_phoenix'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("phoenix_supernova") end
	if cAbility:IsTrained()
	then
		if bot:HasModifier('modifier_phoenix_supernova_hiding') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end

	if cAbility == nil then cAbility = bot:GetAbilityByName("phoenix_sun_ray") end
	if cAbility:IsTrained()
	then
		if bot:HasModifier('modifier_phoenix_sun_ray')
		and not bot:HasModifier('modifier_phoenix_supernova_hiding')
		then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_puck'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("puck_phase_shift") end
	if cAbility:IsTrained()
	then
		if cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_puck_phase_shift') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_snapfire'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("snapfire_mortimer_kisses") end
	if cAbility:IsTrained()
	then
		if cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_snapfire_mortimer_kisses') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_spirit_breaker'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("spirit_breaker_charge_of_darkness") end
	if cAbility:IsTrained()
	then
		if cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_spirit_breaker_charge_of_darkness') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_windrunner'] = function ()
	return CheckHighPriorityChannelAbility("windrunner_powershot")
end

ConsiderHeroSpecificRoaming['npc_dota_hero_tinker'] = function ()
	if cAbility == nil then cAbility = bot:GetAbilityByName("tinker_rearm") end
	if cAbility:IsTrained()
	then
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() or bot:HasModifier('modifier_tinker_rearm') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_leshrac'] = function ()
	if bot:HasModifier("modifier_leshrac_diabolic_edict")
	then
		local DiabolicEdict = bot:GetAbilityByName('leshrac_diabolic_edict')
		if DiabolicEdict:IsTrained()
		then
			local nRadius = DiabolicEdict:GetSpecialValueInt('radius')
			if J.IsPushing(bot)
			then
				local nEnemyTowers = bot:GetNearbyTowers(1600, true)
				local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
				if  nEnemyTowers ~= nil and #nEnemyTowers >= 1
				and J.IsValidBuilding(nEnemyTowers[1])
				and J.CanBeAttacked(nEnemyTowers[1])
				and not J.IsInRange(bot, nEnemyTowers[1], nRadius - 75)
				and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps <= 2
				then
					EdictTowerTarget = nEnemyTowers[1]
					return BOT_MODE_DESIRE_ABSOLUTE
				end
			end
		end
	end

	if bot:HasModifier("modifier_leshrac_pulse_nova")
	then
		if J.GetHP(bot) > 0.2 then
			local botTarget = J.GetProperTarget(bot)
			if GetUnitToUnitDistance(bot, botTarget) > 400
			then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_lone_druid_bear'] = function ()
	local hero = J.Utils.GetLoneDruid(bot).hero
	local hasUltimateScepter = J.Item.HasItem(bot, 'item_ultimate_scepter') or bot:HasModifier('modifier_item_ultimate_scepter_consumed')
    local distanceFromHero = GetUnitToUnitDistance(J.Utils.GetLoneDruid(bot).hero, bot)

    if J.IsValidHero(hero)
	and J.GetHP(bot) >= J.GetHP(hero) - 0.2 -- hp is higher or within 20% lower than hero.
	and J.GetHP(bot) > 0.2
    and not (bot:IsChanneling() or bot:IsUsingAbility())
	and not hasUltimateScepter
	then
        if distanceFromHero > BearAttackLimitDistance * 0.6 then
			return BOT_MODE_DESIRE_ABSOLUTE
        end
    end
	return BOT_MODE_DESIRE_NONE
end

ConsiderHeroSpecificRoaming['npc_dota_hero_marci'] = function ()
	if bot:HasModifier("modifier_marci_unleash")
	then
		if J.GetHP(bot) > 0.2 then
			if J.IsInTeamFight(bot, 1500) then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
			if J.IsGoingOnSomeone(bot) and #nInRangeEnemy >= 1 then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	end
	return BOT_MODE_DESIRE_NONE
end
