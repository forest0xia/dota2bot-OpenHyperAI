if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return
end

local bot = GetBot()
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local Outposts = {}
local DidWeGetOutpost = false
local ClosestOutpost = nil
local ClosestOutpostDist = 10000

local IsEnemyTier2Down = false

local TinkerShouldWaitInBaseToHeal = false

local ShouldWaitInBaseToHeal = false
local TPScroll = nil

local botName = bot:GetUnitName()
local cAbility = nil

local ShouldMoveCloseTowerForEdict = false
local EdictTowerTarget = nil

local ShouldHuskarMoveOutsideFountain = false

function GetDesire()
	if not IsEnemyTier2Down
	then
		if GetTower(GetOpposingTeam(), TOWER_TOP_2) == nil
		or GetTower(GetOpposingTeam(), TOWER_MID_2) == nil
		or GetTower(GetOpposingTeam(), TOWER_BOT_2) == nil
		then
			IsEnemyTier2Down = true
		end
	end

	TPScroll = J.GetItem2(bot, 'item_tpscroll')

	if  ConsiderWaitInBaseToHeal()
	and GetUnitToLocationDistance(bot, J.GetTeamFountain()) > 5500
	then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end

	TinkerShouldWaitInBaseToHeal = TinkerWaitInBaseAndHeal()
	if TinkerShouldWaitInBaseToHeal
	then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end

	ShouldHuskarMoveOutsideFountain = ConsiderHuskarMoveOutsideFountain()
	if ShouldHuskarMoveOutsideFountain
	then
		return bot:GetActiveModeDesire() + 0.2
	end

	-- If in item mode
	ShouldHeroMoveOutsideFountain = ConsiderHeroMoveOutsideFountain()
	if ShouldHeroMoveOutsideFountain
	then
		return bot:GetActiveModeDesire() + 0.2
	end

	-- Leshrac
	ShouldMoveCloseTowerForEdict = ConsiderLeshracEdictTower()
	if ShouldMoveCloseTowerForEdict
	then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end

	------------------------------
	-- Hero Channel/Kill/CC abilities
	------------------------------

	if botName == "npc_dota_hero_rubick"
	then
		if bot:IsChanneling() or bot:IsUsingAbility() or bot:IsCastingAbility()
		then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end

	if botName == "npc_dota_hero_pugna"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName( "pugna_life_drain" ) end;
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
			return BOT_MODE_DESIRE_ABSOLUTE;
		end
	elseif botName == "npc_dota_hero_drow_ranger"
		then
			if cAbility == nil then cAbility = bot:GetAbilityByName( "drow_ranger_multishot" ) end;
			if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
				return BOT_MODE_DESIRE_ABSOLUTE;
			end
	elseif botName == "npc_dota_hero_shadow_shaman"
		then
			if cAbility == nil then cAbility = bot:GetAbilityByName( "shadow_shaman_shackles" ) end;
			if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
				return BOT_MODE_DESIRE_ABSOLUTE;
			end
	elseif botName == "npc_dota_hero_clinkz"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("clinkz_burning_barrage") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_tiny"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("tiny_tree_channel") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_void_spirit"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("void_spirit_dissimilate") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:HasModifier("modifier_void_spirit_dissimilate_phase")
			then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_batrider"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("batrider_flaming_lasso") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:HasModifier("modifier_batrider_flaming_lasso_self")
			then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_enigma"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("enigma_black_hole") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_keeper_of_the_light"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("keeper_of_the_light_illuminate") end
		if cAbility:IsInAbilityPhase() or bot:IsChanneling() or bot:HasModifier('modifier_keeper_of_the_light_illuminate') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	elseif botName == "npc_dota_hero_meepo"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("meepo_poof") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_monkey_king"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("monkey_king_primal_spring") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_nyx_assassin"
	then
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
	elseif botName == "npc_dota_hero_pangolier"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("pangolier_gyroshell") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_pangolier_gyroshell')
			then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_phoenix"
	then
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
	elseif botName == "npc_dota_hero_puck"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("puck_phase_shift") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_puck_phase_shift') then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_snapfire"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("snapfire_mortimer_kisses") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_snapfire_mortimer_kisses') then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_spirit_breaker"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("spirit_breaker_charge_of_darkness") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_spirit_breaker_charge_of_darkness') then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_windrunner"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("windrunner_powershot") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:IsChanneling() then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	elseif botName == "npc_dota_hero_tinker"
	then
		if cAbility == nil then cAbility = bot:GetAbilityByName("tinker_rearm") end
		if cAbility:IsTrained()
		then
			if cAbility:IsInAbilityPhase() or bot:IsChanneling() or bot:HasModifier('modifier_tinker_rearm') then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	end

	----------
	-- Outpost
	----------

	if not IsEnemyTier2Down then return BOT_ACTION_DESIRE_NONE end

	if not DidWeGetOutpost
	then
		if bot:GetUnitName() == 'npc_dota_hero_invoker' then return BOT_ACTION_DESIRE_NONE end
		for _, unit in pairs(GetUnitList(UNIT_LIST_ALL))
		do
			if unit:GetUnitName() == '#DOTA_OutpostName_North'
			or unit:GetUnitName() == '#DOTA_OutpostName_South'
			then
				table.insert(Outposts, unit)
			end
		end

		DidWeGetOutpost = true
	end

	ClosestOutpost, ClosestOutpostDist = GetClosestOutpost()
	if  ClosestOutpost ~= nil and ClosestOutpostDist < 3500
	and not IsEnemyCloserToOutpostLoc(ClosestOutpost:GetLocation(), ClosestOutpostDist)
	and IsSuitableToCaptureOutpost()
	then
		if GetUnitToUnitDistance(bot, ClosestOutpost) < 600
		then
			local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), bot:GetCurrentVisionRange())
			if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
			then
				return BOT_ACTION_DESIRE_NONE
			end
		end

		return RemapValClamped(GetUnitToUnitDistance(bot, ClosestOutpost), 5000, 0, BOT_ACTION_DESIRE_VERYLOW, BOT_ACTION_DESIRE_VERYHIGH )
	end

	return BOT_ACTION_DESIRE_NONE
end

function OnStart()

end

function OnEnd()
	ClosestOutpost = nil
	ClosestOutpostDist = 10000
	ShouldWaitInBaseToHeal = false
end

function Think()
	if J.CanNotUseAction(bot) then return end

	-- Huskar
	if ShouldHuskarMoveOutsideFountain
	then
		bot:Action_MoveToLocation(J.GetEnemyFountain())
		return
	end

	-- Heal in Base
	-- Just for TP. Too much back and forth when "forcing" them try to walk to fountain; <- not reliable and misses farm.
	if ShouldWaitInBaseToHeal
	then
		if GetUnitToLocationDistance(bot, J.GetTeamFountain()) > 150
		then
			local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)
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
	if bot.healInBase
	then
		if J.GetHP(bot) < 0.8 or J.GetMP(bot) < 0.8
		then
			bot:Action_ClearActions(true)
			return
		end
	end

	-- Batrider, Rubick
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

	if ClosestOutpost ~= nil
	then
		if GetUnitToUnitDistance(bot, ClosestOutpost) > 300
		then
			bot:Action_MoveToLocation(ClosestOutpost:GetLocation())
			return
		else
			bot:Action_AttackUnit(ClosestOutpost, false)
			return
		end
	end
end

function GetClosestOutpost()
	local closest = nil
	local dist = 10000

	for i = 1, 2
	do
		if  Outposts[i] ~= nil
		and Outposts[i]:GetTeam() ~= GetTeam()
		and GetUnitToUnitDistance(bot, Outposts[i]) < dist
		and not Outposts[i]:IsNull()
		and not Outposts[i]:IsInvulnerable()
		then
			closest = Outposts[i]
			dist = GetUnitToUnitDistance(bot, Outposts[i])
		end
	end

	return closest, dist
end

function IsEnemyCloserToOutpostLoc(opLoc, botDist)
	for _, id in pairs(GetTeamPlayers(GetOpposingTeam()))
	do
		local info = GetHeroLastSeenInfo(id)

		if info ~= nil
		then
			local dInfo = info[1]
			if dInfo ~= nil
			then
				if  dInfo ~= nil
				and dInfo.time_since_seen < 5
				and J.GetDistance(dInfo.location, opLoc) < botDist
				then
					return true
				end
			end
		end
	end

	return false
end

function IsSuitableToCaptureOutpost()
	local botTarget = J.GetProperTarget(bot)

	if (J.IsGoingOnSomeone(bot) and J.IsValidTarget(botTarget) and GetUnitToUnitDistance(bot, botTarget) < 700)
	or J.IsDefending(bot)
	or (J.IsDoingTormentor(bot) and J.IsTormentor(botTarget) and J.IsAttacking(bot))
	or (J.IsDoingRoshan(bot) and J.IsRoshan(botTarget) and J.IsAttacking(bot))
	or (J.IsRetreating(bot) and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH)
	or bot:WasRecentlyDamagedByAnyHero(1.5)
	or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
	then
		return false
	end

	return true
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

function ConsiderLeshracEdictTower()
	if  bot:GetUnitName() == "npc_dota_hero_leshrac"
	and bot:HasModifier("modifier_leshrac_diabolic_edict")
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
					return true
				end
			end
		end
	end

	return false
end

-- Just for TP. Too much back and forth when "forcing" them try to walk to fountain; <- not reliable and misses farm.
function ConsiderWaitInBaseToHeal()
	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1600)

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

function ConsiderHuskarMoveOutsideFountain()
	if bot:GetUnitName() == 'npc_dota_hero_huskar'
	then
		if  bot:HasModifier('modifier_fountain_aura_buff')
		and J.GetHP(bot) > 0.95
		then
			return true
		end
	end

	return false
end

function ConsiderHeroMoveOutsideFountain()
	if bot:GetActiveMode() == BOT_MODE_ITEM
	and bot:HasModifier('modifier_fountain_aura_buff')
	and J.GetHP(bot) > 0.95
	and J.GetMP(bot) > 0.95
	then
		return true
	end

	return false
end
