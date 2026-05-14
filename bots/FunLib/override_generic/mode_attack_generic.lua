--------------------------------------------------------------------
-- mode_attack_generic.lua (override for weak/buggy heroes)
--------------------------------------------------------------------
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local X = {}

local bot = GetBot()

local botTarget = {unit = nil, location = 0, id = -1, fogChase = false}
local helpAlly = {should = false, location = 0}

local botAttackRange, botHP, botMP, botHealth, botAttackDamage, botAttackSpeed, botActiveModeDesire, botLocation, botName

local fLastAttackDesire = 0
local bClearMode = false

local function IsValid(hUnit)
	return hUnit ~= nil and not hUnit:IsNull() and hUnit:IsAlive()
end

BotsInit = require("game/botsinit")
local Generic = BotsInit.CreateGeneric()

function Generic.OnStart() end
function Generic.OnEnd()
	botTarget.fogChase = false
	helpAlly.should = false
end

function Generic.GetDesire()
	if not bot:IsAlive()
	or bot:IsIllusion()
	or bot:HasModifier('modifier_fountain_fury_swipes_damage_increase')
	then
		return BOT_MODE_DESIRE_NONE
	end

	if bClearMode then bClearMode = false return 0 end

	botAttackRange = bot:GetAttackRange() + bot:GetBoundingRadius()
	botHP = J.GetHP(bot)
	botMP = J.GetMP(bot)
	botHealth = bot:GetHealth()
	botName = bot:GetUnitName()
	botLocation = bot:GetLocation()
	local bWeAreStronger = J.WeAreStronger(bot, 1600)
	local bCore = J.IsCore(bot)

	local tAllyHeroes_real = J.GetAlliesNearLoc(botLocation, 1600)
	local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local tEnemyHeroes_real = J.GetEnemiesNearLoc(botLocation, 1600)
	local tEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
	local tEnemyTowers = bot:GetNearbyTowers(1600, true)

	-- Laning phase: don't fight when taking heavy creep damage
	if J.IsInLaningPhase() then
		local creepDmg = 0
		for _, creep in pairs(tEnemyLaneCreeps) do
			if J.IsValid(creep) and J.IsInRange(bot, creep, 600) and creep:GetAttackTarget() == bot then
				creepDmg = creepDmg + (bot:GetActualIncomingDamage(creep:GetAttackDamage() * creep:GetAttackSpeed() * 5.0, DAMAGE_TYPE_PHYSICAL) - bot:GetHealthRegen() * 5.0)
			end
		end
		if creepDmg / (botHealth + 1) >= 0.25 then return GetActualDesire(BOT_MODE_DESIRE_NONE) end
	end

	-- Special hero modifiers that demand fighting
	if (bot:HasModifier('modifier_marci_unleash') and J.GetModifierTime(bot, 'modifier_marci_unleash') > 3)
	or (bot:HasModifier('modifier_muerta_pierce_the_veil_buff') and J.GetModifierTime(bot, 'modifier_muerta_pierce_the_veil_buff') > 3)
	then
		if #tEnemyHeroes_real > 0
		and not (#tEnemyHeroes_real >= #tAllyHeroes_real + 2)
		and ((botName == 'npc_dota_hero_muerta' and (botHP > 0.3 or bot:HasModifier('modifier_item_satanic_unholy') or bot:IsAttackImmune()))
			or (botName == 'npc_dota_hero_marci' and (botHP > 0.45 or bot:HasModifier('modifier_item_satanic_unholy') or bot:IsAttackImmune())))
		then
			return GetActualDesire(BOT_MODE_DESIRE_ABSOLUTE)
		end
	end

	-- Main engagement logic: check each visible enemy
	local fAllyDamage = 0
	local unitList_allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local unitList_enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)

	for _, enemyHero in ipairs(unitList_enemies) do
		if J.IsValidHero(enemyHero)
		and J.CanBeAttacked(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		and (J.IsInLaningPhase() and J.IsInRange(bot, enemyHero, 1600)
			or (not J.IsInLaningPhase() and (((GetUnitToUnitDistance(bot, enemyHero) - botAttackRange) / bot:GetCurrentMovementSpeed()) <= 6.0)))
		then
			fAllyDamage = 0
			local nInRangeAlly = J.GetAlliesNearLoc(enemyHero:GetLocation(), 1200)
			local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), 1200)
			local vTeamFightLocation = J.GetTeamFightLocation(bot)

			for _, allyHero in ipairs(unitList_allies) do
				if J.IsValidHero(allyHero)
				and not J.IsSuspiciousIllusion(allyHero)
				and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				and not allyHero:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
				and not allyHero:HasModifier('modifier_teleporting')
				and (((GetUnitToUnitDistance(allyHero, enemyHero) - botAttackRange) / allyHero:GetCurrentMovementSpeed()) <= 6.0)
				and (bot:GetPlayerID() == allyHero:GetPlayerID()
					or allyHero:GetAttackTarget() == enemyHero
					or J.IsInRange(allyHero, enemyHero, botAttackRange + 200))
				then
					fAllyDamage = fAllyDamage + allyHero:GetEstimatedDamageToTarget(true, enemyHero, 3.0, DAMAGE_TYPE_ALL) - enemyHero:GetHealthRegen() * 3.0
					local nAllyTowers = allyHero:GetNearbyTowers(800, false)
					if J.IsValidBuilding(nAllyTowers[1]) then
						fAllyDamage = fAllyDamage + #nAllyTowers * nAllyTowers[1]:GetAttackDamage()
					end
				end
			end

			-- Laning: allow hero attacks if not recently damaged and numbers ok
			if J.IsInLaningPhase() and not bot:WasRecentlyDamagedByAnyHero(3.0) and not bot:WasRecentlyDamagedByCreep(2.0) and #nInRangeAlly >= #nInRangeEnemy then
				if not J.IsRetreating(bot) and GetUnitToUnitDistance(bot, enemyHero) < botAttackRange then
					return GetActualDesire(BOT_MODE_DESIRE_VERYHIGH)
				end
			end

			-- Enemy damage estimate
			local fEnemyDamage = 0
			for _, possibleEnemy in ipairs(unitList_enemies) do
				if J.IsValidHero(possibleEnemy)
				and J.GetHP(possibleEnemy) >= 0.25
				and not J.IsSuspiciousIllusion(possibleEnemy)
				and not possibleEnemy:HasModifier('modifier_necrolyte_reapers_scythe')
				and not possibleEnemy:HasModifier('modifier_teleporting')
				and ((GetUnitToUnitDistance(bot, possibleEnemy)) / possibleEnemy:GetCurrentMovementSpeed()) <= 6.0
				then
					fEnemyDamage = fEnemyDamage + possibleEnemy:GetEstimatedDamageToTarget(false, bot, 3.0, DAMAGE_TYPE_ALL)
				end
			end
			local nEnemyTowersNear = bot:GetNearbyTowers(1200, true)
			if J.IsValidBuilding(nEnemyTowersNear[1]) then
				fEnemyDamage = fEnemyDamage + #nEnemyTowersNear * nEnemyTowersNear[1]:GetAttackDamage()
			end

			local b1 = (bWeAreStronger and fAllyDamage >= enemyHero:GetHealth() * 0.2 and botHealth > fEnemyDamage * 1.15)
			local b2 = (#nInRangeAlly >= #nInRangeEnemy and fAllyDamage >= enemyHero:GetHealth() * 0.3 and botHealth > fEnemyDamage * 1.15)
			local b3 = (vTeamFightLocation ~= nil and (((GetUnitToLocationDistance(bot, vTeamFightLocation) - botAttackRange) / bot:GetCurrentMovementSpeed()) <= 10.0))

			if b1 or b2 or b3 then
				local dist = GetUnitToUnitDistance(bot, enemyHero)
				if dist <= 2000 or ((dist / bot:GetCurrentMovementSpeed()) <= 10.0) then
					if J.IsInLaningPhase() and bot:GetActiveMode() == BOT_MODE_ATTACK then
						if bot:WasRecentlyDamagedByTower(2.0) or (J.IsValidBuilding(tEnemyTowers[1]) and tEnemyTowers[1]:GetAttackTarget() == bot) then
							return GetActualDesire(BOT_MODE_DESIRE_VERYLOW)
						end
					end
					if b3 then return GetActualDesire(BOT_MODE_DESIRE_ABSOLUTE) end
					return GetActualDesire(BOT_MODE_DESIRE_VERYHIGH)
				else
					return GetActualDesire(BOT_MODE_DESIRE_MODERATE)
				end
			end
		end
	end

	-- Help ally: supports or post-laning, join ally fights
	if not bCore or not J.IsInLaningPhase() then
		for _, allyHero in ipairs(unitList_allies) do
			if bot ~= allyHero
			and J.IsValidHero(allyHero)
			and J.IsInRange(bot, allyHero, 4000)
			and not J.IsSuspiciousIllusion(allyHero)
			and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			and not allyHero:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
			and not allyHero:HasModifier('modifier_item_helm_of_the_undying_active')
			and not allyHero:HasModifier('modifier_teleporting')
			then
				local enemyHero = allyHero:GetAttackTarget()
				local bWeAreStronger_Ally = J.WeAreStronger(allyHero, 1200)

				if J.IsValidHero(enemyHero)
				and J.IsInRange(allyHero, enemyHero, 1600)
				and not J.IsSuspiciousIllusion(enemyHero)
				and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				then
					local nInRangeAlly = J.GetAlliesNearLoc(enemyHero:GetLocation(), 1600)
					local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), 1600)

					if #nInRangeAlly >= #nInRangeEnemy or bWeAreStronger_Ally then
						helpAlly = {should = true, location = allyHero:GetLocation()}
						return GetActualDesire(BOT_MODE_DESIRE_VERYHIGH)
					else
						helpAlly.should = false
					end
				end
			end
		end
	end

	-- Fog-of-war chase
	if IsValid(botTarget.unit) and not botTarget.unit:CanBeSeen() then
		for _, id in ipairs(GetTeamPlayers(GetOpposingTeam())) do
			if IsHeroAlive(id) and id == botTarget.id then
				local info = GetHeroLastSeenInfo(id)
				if info then
					local dInfo = info[1]
					if dInfo
					and dInfo.time_since_seen > 0.5
					and dInfo.time_since_seen < 3.0
					and J.GetDistance(dInfo.location, botTarget.location) <= 1200 then
						local tAllyHeroes_real = J.GetAlliesNearLoc(botLocation, 1600)
						local tEnemyHeroes_real2 = J.GetEnemiesNearLoc(botLocation, 1600)
						if #tAllyHeroes_real >= #tEnemyHeroes_real2 or bWeAreStronger then
							botTarget.fogChase = true
							botTarget.location = dInfo.location
							return GetActualDesire(BOT_MODE_DESIRE_VERYHIGH)
						end
					end
				end
			end
		end
	end

	botTarget.fogChase = false

	return GetActualDesire(BOT_MODE_DESIRE_NONE)
end

--------------------------------------------------------------------
-- Think
--------------------------------------------------------------------
function Generic.Think()
	if J.CanNotUseAction(bot) then return end

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nEnemyTowers = bot:GetNearbyTowers(1600, true)
	local bTeamFight = J.IsInTeamFight(bot, 1600)

	-- Pugna life drain: run away
	if bot:HasModifier('modifier_pugna_life_drain') then
		for _, enemy in ipairs(nEnemyHeroes) do
			if J.IsValidHero(enemy) and J.IsInRange(bot, enemy, 750) and not J.IsSuspiciousIllusion(enemy)
			and (enemy:GetUnitName() == 'npc_dota_hero_pugna' or enemy:GetUnitName() == 'npc_dota_hero_rubick') then
				bot:Action_MoveToLocation(J.VectorAway(botLocation, enemy:GetLocation(), 800))
				return
			end
		end
	-- Razor static link: run away
	elseif bot:HasModifier('modifier_razor_static_link_debuff') then
		for _, enemy in ipairs(nEnemyHeroes) do
			if J.IsValidHero(enemy) and J.IsInRange(bot, enemy, 750) and not J.IsSuspiciousIllusion(enemy)
			and enemy:GetUnitName() == 'npc_dota_hero_razor' then
				bot:Action_MoveToLocation(J.VectorAway(botLocation, enemy:GetLocation(), 800))
				return
			end
		end
	else
		-- Helm of undying / WK scepter: kite
		for _, enemy in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemy) and enemy:GetAttackTarget() == bot
			and (enemy:HasModifier('modifier_item_helm_of_the_undying_active')
				or enemy:HasModifier('modifier_skeleton_king_reincarnation_scepter_active'))
			then
				if J.IsInRange(bot, enemy, enemy:GetAttackRange() + 150) then
					bot:Action_MoveToLocation(J.VectorAway(botLocation, enemy:GetLocation(), enemy:GetAttackRange() * 2))
					return
				end
			end
		end

		-- Tower damage: retreat if significant
		if J.IsValidBuilding(nEnemyTowers[1]) and nEnemyTowers[1]:GetAttackTarget() == bot and not bTeamFight then
			local unitDamage = 0
			for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
				if J.IsValid(unit) and unit:GetAttackTarget() == bot then
					unitDamage = unitDamage + bot:GetActualIncomingDamage(unit:GetAttackDamage() * unit:GetAttackSpeed() * 3.0, DAMAGE_TYPE_PHYSICAL)
				end
			end
			if unitDamage / (botHealth + bot:GetHealthRegen() * 3.0) >= 0.2 then
				bot:Action_MoveToLocation(J.VectorAway(botLocation, nEnemyTowers[1]:GetLocation(), 800))
				return
			end
		end
	end

	-- Target selection with hero-specific multipliers
	local __target = nil
	local targetScore = 0
	for _, enemy in pairs(nEnemyHeroes) do
		if J.IsValidHero(enemy)
		and J.IsInRange(bot, enemy, 1200)
		and not J.IsSuspiciousIllusion(enemy)
		and not enemy:HasModifier('modifier_abaddon_borrowed_time')
		and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
		and not enemy:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
		and not enemy:HasModifier('modifier_troll_warlord_battle_trance')
		and not enemy:HasModifier('modifier_ursa_enrage')
		and not enemy:HasModifier('modifier_winter_wyvern_cold_embrace')
		and not enemy:HasModifier('modifier_item_blade_mail_reflect')
		and not enemy:HasModifier('modifier_item_aeon_disk_buff')
		and J.CanBeAttacked(enemy)
		then
			local enemyName = enemy:GetUnitName()
			local mul = 1

			if enemyName == 'npc_dota_hero_sniper' then mul = 4
			elseif enemyName == 'npc_dota_hero_drow_ranger' then mul = 2
			elseif enemyName == 'npc_dota_hero_crystal_maiden' then mul = 2
			elseif enemyName == 'npc_dota_hero_jakiro' then mul = 2.5
			elseif enemyName == 'npc_dota_hero_lina' then mul = 3
			elseif enemyName == 'npc_dota_hero_nevermore' then mul = 3
			elseif enemyName == 'npc_dota_hero_bristleback' and not enemy:IsFacingLocation(botLocation, 90) then mul = 0.5
			elseif enemyName == 'npc_dota_hero_enchantress' and enemy:GetLevel() >= 6 then mul = 0.5
			end

			if enemyName ~= 'npc_dota_hero_bristleback' then
				if J.IsCore(enemy) then mul = mul * 1.5 else mul = mul * 0.5 end
			end

			if (J.IsEarlyGame() or J.IsMidGame()) and J.IsValidBuilding(nEnemyTowers[1]) and J.IsInRange(enemy, nEnemyTowers[1], 800) then
				mul = mul * 0.5
			end

			local nAllyHeroes_Attacking = J.GetSpecialModeAllies(enemy, 1200, BOT_MODE_ATTACK)
			local nInRangeAlly = J.GetAlliesNearLoc(enemy:GetLocation(), 900)
			local nInRangeEnemy = J.GetEnemiesNearLoc(enemy:GetLocation(), 900)

			local enemyScore = (math.min(1, bot:GetAttackRange() / GetUnitToUnitDistance(bot, enemy)))
				* ((1 - J.GetHP(enemy)) * J.GetTotalEstimatedDamageToTarget(nAllyHeroes_Attacking, enemy, 5.0))
				* mul
				* (math.exp(RemapValClamped(#nInRangeAlly - #nInRangeEnemy, -4, 4, 0, 1.6)) - 1)

			if enemyScore > targetScore then
				targetScore = enemyScore
				__target = enemy
			end
		end
	end

	if __target == nil then
		__target = J.GetAttackableWeakestUnit(bot, 1200, true, true)
	end

	if __target and J.IsValidHero(__target) then
		local dist = GetUnitToUnitDistance(bot, __target)
		botAttackRange = bot:GetAttackRange() + bot:GetBoundingRadius()

		botTarget.unit = __target
		botTarget.location = __target:GetExtrapolatedLocation(3.0)
		botTarget.id = __target:GetPlayerID()
		bot:SetTarget(__target)

		-- Melee vs ranged positioning
		if botAttackRange < 330 and botName ~= 'npc_dota_hero_templar_assassin' then
			if dist < botAttackRange then
				if not J.CanBeAttacked(__target) then
					bot:Action_MoveToLocation(__target:GetLocation())
				else
					bot:Action_AttackUnit(__target, true)
				end
			else
				bot:Action_MoveToLocation(__target:GetLocation())
			end
			return
		else
			-- Ranged: kite when target can't be attacked
			if dist < botAttackRange then
				if not J.CanBeAttacked(__target) then
					if dist < botAttackRange - 100 then
						bot:Action_MoveToLocation(J.VectorAway(botLocation, __target:GetLocation(), botAttackRange - dist - 100))
					elseif dist > botAttackRange - 100 then
						bot:Action_MoveToLocation(J.VectorTowards(botLocation, __target:GetLocation(), dist - botAttackRange - 100))
					end
				else
					bot:Action_AttackUnit(__target, true)
				end
			else
				bot:Action_MoveToLocation(__target:GetLocation())
			end
			return
		end
	end

	-- Help ally movement
	if helpAlly.should then
		bot:Action_MoveToLocation(helpAlly.location)
		return
	end

	-- Fog-of-war chase
	if botTarget.fogChase then
		local vLastSeen = botTarget.location
		local vDirs = {
			vLastSeen + Vector(700, 0),
			vLastSeen + Vector(-700, 0),
			vLastSeen + Vector(0, 700),
			vLastSeen + Vector(0, -700),
			vLastSeen + Vector(700, 700),
		}
		local vBest, vBestScore = nil, 0
		for _, loc in ipairs(vDirs) do
			local score = GetUnitPotentialValue(botTarget.unit, loc, 900)
			if score > vBestScore and score > 180 then
				vBestScore = score
				vBest = loc
			end
		end
		if vBest then
			bot:Action_MoveToLocation(vBest)
			return
		end
	end

	bClearMode = true
end

-- Desire smoothing (reference pattern)
function GetActualDesire(nDesire)
	local alpha = 0.3
	nDesire = fLastAttackDesire * (1 - alpha) + nDesire * alpha
	fLastAttackDesire = nDesire
	return nDesire
end

return Generic
