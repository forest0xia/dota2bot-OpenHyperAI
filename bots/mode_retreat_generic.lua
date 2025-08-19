local X = {}

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local bot = GetBot()

local botHP, botMP, botName, botHealth, botHealthRegen, botManaRegen, botLocation, botTarget
local botLevel, botActiveMode
local nAllyHeroes
local nEnemyHeroes

local fRetreatFromTormentorTime = 0
local fRetreatFromRoshanTime = 0

local fCurrentRunTime = 0
local fShouldRunTime = 0

local hTeamAncient, hEnemyAncient

function GetDesire()
    botActiveMode = bot:GetActiveMode()

    if not bot:IsAlive()
    or bot:HasModifier('modifier_dazzle_nothl_projection_soul_clone')
    or bot:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
    or bot:HasModifier('modifier_item_helm_of_the_undying_active')
    or (botActiveMode == BOT_MODE_EVASIVE_MANEUVERS)
    or (bot:GetUnitName() == 'npc_dota_hero_lone_druid' and bot:HasModifier('modifier_fountain_aura_buff') and DotaTime() < 0)
    or bot:HasModifier('modifier_item_satanic_unholy')
    or J.GetModifierTime(bot, "modifier_abaddon_borrowed_time") > 2
    or J.GetModifierTime(bot, "modifier_muerta_pierce_the_veil_buff") > 2
    or J.GetModifierTime(bot, 'modifier_dazzle_shallow_grave') > 3
    or J.GetModifierTime(bot, 'modifier_oracle_false_promise_timer') > 3
    then
        return BOT_MODE_DESIRE_NONE
    end

    botHP = J.GetHP(bot)
    botMP = J.GetMP(bot)
    botName = bot:GetUnitName()
    botHealth = bot:GetHealth()
    botHealthRegen = bot:GetHealthRegen()
    botManaRegen = bot:GetManaRegen()
    botLocation = bot:GetLocation()
    botTarget = J.GetProperTarget(bot)
    botLevel = bot:GetLevel()
    nAllyHeroes = {}
    nEnemyHeroes = {}
    hTeamAncient = GetAncient(GetTeam())
    hEnemyAncient = GetAncient(GetOpposingTeam())
    local nAllyTowers = bot:GetNearbyTowers(1200, false)
    local nEnemyTowers = bot:GetNearbyTowers(1200, true)
    local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)
    local bWeAreStronger = J.WeAreStronger(bot, 1600)
    local bTeamFight = J.IsInTeamFight(bot, 1200)

    if bTeamFight and botName == "npc_dota_hero_skeleton_king"
		and bot:GetLevel() >= 6
	then
		local abilityR = bot:GetAbilityByName( "skeleton_king_reincarnation" );
		if abilityR:GetCooldownTimeRemaining() <= 1.0 and bot:GetMana() >= 160
		then
			return BOT_MODE_DESIRE_NONE;
		end
	end

    local unitList = GetUnitList(UNIT_LIST_ALL)
	for _, unit in pairs(unitList) do
		if J.IsValidHero(unit)
		and GetUnitToUnitDistance(bot, unit) <= 1600
        and ((J.IsSuspiciousIllusion(unit) and unit:HasModifier('modifier_arc_warden_tempest_double'))
			or not J.IsSuspiciousIllusion(unit))
        and not J.IsMeepoClone(unit)
		and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
		and not unit:HasModifier('modifier_dazzle_nothl_projection_physical_body_debuff')
		and not unit:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
        and not unit:HasModifier('modifier_item_helm_of_the_undying_active')
        and not unit:HasModifier('modifier_teleporting')
        and not string.find(botName, 'lone_druid_bear')
		and unit:GetTeam() ~= TEAM_NEUTRAL
		and unit:GetTeam() ~= TEAM_NONE
		then
			if GetTeam() == unit:GetTeam() then
                table.insert(nAllyHeroes, unit)
			else
                table.insert(nEnemyHeroes, unit)
			end
		end
	end

    if J.GetHP(bot) < 0.2 and #nEnemyHeroes >= 2 and bot:WasRecentlyDamagedByAnyHero(1) then
        return RemapValClamped(J.GetHP(bot), 0.5, 0.1, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_VERYHIGH)
    end
    if X.LowChanceToRun() then
        return BOT_MODE_DESIRE_NONE
    end

    -- Not part of actual retreat
    if (botName == 'npc_dota_hero_lone_druid' and DotaTime() > 25 and DotaTime() < fRetreatFromRoshanTime + 6.5) then
        return 3.33
    end

    local vRoshanLocation = J.GetCurrentRoshanLocation()

    if botName == 'npc_dota_hero_lone_druid'
    and botActiveMode == BOT_MODE_ITEM
    and GetUnitToLocationDistance(bot, vRoshanLocation)
    and IsLocationVisible(vRoshanLocation)
    then
        for _, droppedItem in pairs(GetDroppedItemList()) do
            if droppedItem ~= nil
            and droppedItem.item:GetName() == 'item_aegis'
            and GetUnitToLocationDistance(bot, droppedItem.location) < 1200
            then
                fRetreatFromRoshanTime = DotaTime()
                return 3.33
            end
        end
    end

    -- when roshan dies, every desire sometimes drops to 0 somehow and it lingers in Roshan mode (which is also 0)
    if botActiveMode == BOT_MODE_ROSHAN
    and not J.IsRoshanAlive()
    and GetUnitToLocationDistance(bot, vRoshanLocation)
    and IsLocationVisible(vRoshanLocation)
    then
        local bAegisNearby = false
        for _, droppedItem in pairs(GetDroppedItemList()) do
            if droppedItem ~= nil
            and droppedItem.item:GetName() == 'item_aegis'
            and GetUnitToLocationDistance(bot, droppedItem.location) < 1200
            then
                bAegisNearby = true
                break
            end
        end

        if not bAegisNearby then
            return BOT_MODE_DESIRE_MODERATE
        end
    end
    -------------------------

    if bot:HasModifier('modifier_fountain_fury_swipes_damage_increase')
    or (not bTeamFight and J.IsTargetedByEnemyWithModifier(nEnemyHeroes, 'modifier_skeleton_king_reincarnation_scepter_active'))
    or (not bTeamFight and J.IsTargetedByEnemyWithModifier(nEnemyHeroes, 'modifier_item_helm_of_the_undying_active'))
    then
        return RemapValClamped(J.GetHP(bot), 0.9, 0.5, BOT_MODE_DESIRE_VERYLOW, BOT_MODE_DESIRE_ABSOLUTE)
    end

    if (bot:HasModifier('modifier_doom_bringer_doom_aura_enemy') and (#nEnemyHeroes > 0 or #nEnemyHeroes > #nAllyHeroes + 1))
    or (bot:HasModifier('modifier_razor_static_link_debuff') and J.IsUnitNearby(bot ,nEnemyHeroes, 700, 'npc_dota_hero_razor', true) and #nEnemyHeroes >= #nAllyHeroes)
    or (bot:HasModifier('modifier_ursa_fury_swipes_damage_increase') and not bTeamFight and J.IsUnitNearby(bot, nEnemyHeroes, 700, 'npc_dota_hero_ursa', true))
    or (bot:HasModifier('modifier_ice_blast') and not bTeamFight and #nEnemyHeroes > #nAllyHeroes)
    then
        return RemapValClamped(J.GetHP(bot), 0.9, 0.6, BOT_MODE_DESIRE_HIGH, BOT_MODE_DESIRE_ABSOLUTE)
    end

    if botName == 'npc_dota_hero_huskar' and not bot:HasModifier('modifier_item_spirit_vessel_damage') then
        local hAbility = bot:GetAbilityByName('huskar_berserkers_blood')
        if hAbility and hAbility:IsTrained() and hAbility:GetLevel() >= 3 then
            if botHP > 0.2 and botHealthRegen > 30 then botHP = 1 end
            if botHP < 0.3 and (#nEnemyHeroes == 0 and J.HasItem(bot, 'item_armlet')) then botHP = 1 end
        end
    end

    if --[[(botHP <= 0.3) or]] (( botMP < 0.4 ) and bot:DistanceFromFountain() <= 4000 and not bTeamFight) then
        return RemapValClamped(J.GetHP(bot), 0.9, 0.2, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_VERYHIGH)
    end

    if bot:HasModifier('modifier_fountain_aura_buff') then
        if botHP <= 0.9 or (botMP <= 0.8 and botName ~= 'npc_dota_hero_huskar') then
            return RemapValClamped(J.GetHP(bot), 0.9, 0.5, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_ABSOLUTE)
        end

        if (#nEnemyHeroes > #nAllyHeroes) and not bWeAreStronger and not J.CanBeAttacked(hTeamAncient)
        then
            return RemapValClamped(J.GetHP(bot), 0.9, 0.5, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_HIGH)
        end
    end

    if J.IsInLaningPhase() or botHP < 0.35 then
        local creepDamage = 0
        local nEnemyCreeps = bot:GetNearbyCreeps(1200, true)
        for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep)
            and not J.IsRoshan(creep)
            and not J.IsTormentor(creep)
            and creep:GetAttackTarget() == bot
            then
                creepDamage = creepDamage + bot:GetActualIncomingDamage(creep:GetAttackDamage() * creep:GetAttackSpeed() * 3.0, DAMAGE_TYPE_PHYSICAL)
            end
        end

        if creepDamage / (botHealth + botHealthRegen * 3.0) > 0.15 then
            return RemapValClamped(J.GetHP(bot), 0.9, 0.5, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_VERYHIGH)
        end
    end

    -- should directly run
	if bot:IsAlive() then
        -- print(fShouldRunTime, fCurrentRunTime, botName)
		if fCurrentRunTime ~= 0 and DotaTime() < fCurrentRunTime + fShouldRunTime then
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		else
			fCurrentRunTime = 0
		end

		fShouldRunTime = X.ShouldRun()
		if fShouldRunTime ~= 0 then
			if fCurrentRunTime == 0 then
				fCurrentRunTime = DotaTime()
			end

			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end

    local nDesire = 0

    -- try complete items
    local nCompletItemDesire = X.ConsiderCompleteItem()
    if nCompletItemDesire > 0 then
        return nCompletItemDesire
    end

    -- fall
    local nEnemyNearbyCount = #nEnemyHeroes
    local nAllyNearbyCount = #nAllyHeroes

    local count = 0
    for _, id in pairs( GetTeamPlayers(GetOpposingTeam())) do
        if IsHeroAlive(id) then
            local info = GetHeroLastSeenInfo(id)
            if info ~= nil then
                local dInfo = info[1]
                if dInfo ~= nil and GetUnitToLocationDistance(bot, dInfo.location) <= 3200 and dInfo.time_since_seen <= 5.0 then
                    count = count + 1
                end
            end
        end
    end

    if count > #nEnemyHeroes then nEnemyNearbyCount = count end

    unitList = GetUnitList(UNIT_LIST_ALL)
    for _, unit in ipairs(unitList) do
        if J.IsValid(unit) and J.IsInRange(bot, unit, 1200) then
            local sUnitName = unit:GetUnitName()

            if bot:GetTeam() ~= unit:GetTeam() then
                if string.find(sUnitName, 'warlock_golem')
                or string.find(sUnitName, 'tombstone')
                or string.find(sUnitName, 'npc_dota_phoenix_sun')
                then
                    nEnemyNearbyCount = nEnemyNearbyCount + 1
                end
                if string.find(sUnitName, 'tower') then
                    local towerDamage = bot:GetActualIncomingDamage(unit:GetAttackDamage() * unit:GetAttackSpeed() * 5.0, DAMAGE_TYPE_PHYSICAL) - botHealthRegen * 5.0
                    if towerDamage / botHealth >= 0.5 then
                        nEnemyNearbyCount = nEnemyNearbyCount + 1
                    end
                end
            elseif bot:GetTeam() == unit:GetTeam() then
                if string.find(sUnitName, 'npc_dota_phoenix_sun') then
                    nAllyNearbyCount = nAllyNearbyCount + 1
                end
            end
        end
    end

    if J.IsInLaningPhase()
    and J.IsValidBuilding(nAllyTowers[1])
    and bot:HasModifier('modifier_tower_aura_bonus')
    and #nEnemyLaneCreeps <= 1
    then
        nAllyNearbyCount = nAllyNearbyCount + 1
    end

    botHP = botHP + (botHealthRegen * 5.0 / bot:GetMaxHealth())
    botMP = botMP + (botManaRegen * 5.0 / bot:GetMaxMana())
    local nHealth = 0

    if botName == 'npc_dota_hero_medusa' then
        local unitHealth = botHealth - bot:GetMana()
        local unitMaxHealth = bot:GetMaxHealth() - bot:GetMaxMana()
        nHealth = (unitHealth / unitMaxHealth) * 0.2 + botMP * 0.8
    elseif botName == 'npc_dota_hero_huskar' then
        nHealth = botHP
    else
        nHealth = botHP * 0.8 + botMP * 0.2
    end

    nDesire = 1 - ((nHealth + 1 - (1 - nHealth) ^ 4) / 2)

    if nEnemyNearbyCount > 0 then
        if nEnemyNearbyCount - nAllyNearbyCount > 0 then
            nDesire = nDesire + (nEnemyNearbyCount - nAllyNearbyCount) * (0.75 / 4)
            if J.IsInLaningPhase() then
                nDesire = nDesire + (#J.GetHeroesTargetingUnit(nEnemyHeroes, bot)) * (0.75 / 4)
            end
        end

        if not bWeAreStronger and nEnemyNearbyCount >= nAllyNearbyCount then nDesire = nDesire + 0.25 end
        if nAllyNearbyCount >= nEnemyNearbyCount or bWeAreStronger then
            if bot:HasModifier('modifier_oracle_false_promise_timer') and J.GetModifierTime(bot, 'modifier_oracle_false_promise_timer') > 2.0 and J.IsUnitNearby(bot, nAllyHeroes, 1200, 'npc_dota_hero_oracle', true) then
                nDesire = nDesire - 0.25
            end
            if bot:HasModifier('modifier_dazzle_shallow_grave') and J.GetModifierTime(bot, 'modifier_dazzle_shallow_grave') >= 2.0 and J.IsUnitNearby(bot, nAllyHeroes, 1200, 'npc_dota_hero_dazzle', true) then
                nDesire = nDesire - 0.2
            end
            if bot:HasModifier('modifier_item_satanic_unholy') then
                nDesire = nDesire - 0.3
            end

            local hAbility = bot:GetAbilityByName('slark_shadow_dance')
            if J.CanCastAbility(hAbility)
            or (hAbility ~= nil and hAbility:IsTrained() and hAbility:GetCooldownTimeRemaining() <= 3 and bot:GetMana() >= 150)
            or (bot:HasModifier('modifier_slark_shadow_dance') and J.GetModifierTime(bot, 'modifier_slark_shadow_dance') > 1.5)
            then
                nDesire = nDesire - 0.3
            end
        end
    end

    if bot:DistanceFromFountain() > 4000 then
        if (nEnemyNearbyCount == 0 and count == 0) and #nEnemyTowers == 0 then nDesire = nDesire - 0.25 end
    end

    if J.IsInLaningPhase() then
        if not bot:WasRecentlyDamagedByAnyHero(3.0)
        and botHP > 0.25
        and bot:DistanceFromFountain() > 4000
        and (#J.GetHeroesTargetingUnit(nEnemyHeroes, bot) == 0)
        then
            nDesire = nDesire -  0.75
        end
    end

    -- mulling
    -- nDesire = nDesire + X.GetUnitDesire(1200)
    nDesire = nDesire + X.RetreatWhenTowerTargetedDesire()

    return RemapValClamped(J.GetHP(bot), 1, 0.3, BOT_MODE_DESIRE_NONE, Min(nDesire, 1.0))
end

function X.LowChanceToRun()
	local nEnemysHeroes = J.GetNearbyHeroes(bot, 900, true, BOT_MODE_NONE )
    if #nEnemysHeroes >= 3 and #nEnemysHeroes >= #nAllyHeroes and botHP < 0.6
    and bot:WasRecentlyDamagedByAnyHero(1) and bot:GetCurrentMovementSpeed() < 330 then
        return true
    end

    return false
end

function X.GetUnitDesire(nRadius)
    local unitList = GetUnitList(UNIT_LIST_ENEMIES)
    for _, unit in pairs(unitList) do
        if J.IsValid(unit)
        and not unit:IsBuilding()
        and J.IsInRange(bot, unit, nRadius)
        then
            local sUnitName = unit:GetUnitName()
            -- local unitHealth = unit:GetHealth()
            -- local botDamage = bot:GetAttackDamage() * bot:GetAttackSpeed() * 5.0
            local unitDamage = 0
            local bIsTargetingThisBot = J.IsChasingTarget(unit, bot) or unit:GetAttackTarget() == bot

            if not unit:HasModifier('modifier_arc_warden_tempest_double') and J.IsSuspiciousIllusion(unit)
            then
                local tIllusions = J.GetSameUnitType(bot, 1600, sUnitName, false)
                unitDamage = J.GetUnitListTotalAttackDamage(tIllusions, 5.0)
                local illusionDamage = bot:GetActualIncomingDamage(unitDamage, DAMAGE_TYPE_PHYSICAL) - botHealthRegen * 5.0

                if illusionDamage / botHealth > 0.5 then
                    if illusionDamage / botHealth > 0.65 then
                        return 0.9
                    else
                        return 0.75
                    end
                end
            elseif string.find(sUnitName, 'warlock_golem') and bIsTargetingThisBot
            then
                local tWarlockGolems = J.GetSameUnitType(bot, 1600, sUnitName, false)
                unitDamage = J.GetUnitListTotalAttackDamage(tWarlockGolems, 5.0)
                local golemsDamage = bot:GetActualIncomingDamage(unitDamage, DAMAGE_TYPE_PHYSICAL) - botHealthRegen * 5.0

                if golemsDamage / botHealth > 0.45 then
                    return 0.9
                end
            elseif string.find(sUnitName, 'spiderlings') and bIsTargetingThisBot
                and not J.IsInTeamFight(bot, 1600)
            then
                local tSpiderlings = J.GetSameUnitType(bot, 1600, sUnitName, true)
                unitDamage = J.GetUnitListTotalAttackDamage(tSpiderlings, 5.0)
                local spiderlingsDamage = bot:GetActualIncomingDamage(unitDamage, DAMAGE_TYPE_PHYSICAL) - botHealthRegen * 5.0

                if spiderlingsDamage / botHealth > 0.25 then
                    return 0.75
                end
            elseif string.find(sUnitName, 'eidolon') and bIsTargetingThisBot
                and not J.IsInTeamFight(bot, 1600)
            then
                local tEidolons = J.GetSameUnitType(bot, 1600, sUnitName, true)
                unitDamage = J.GetUnitListTotalAttackDamage(tEidolons, 5.0)
                local eidolonDamage = bot:GetActualIncomingDamage(unitDamage, DAMAGE_TYPE_PHYSICAL) - botHealthRegen * 5.0

                if eidolonDamage / botHealth > 0.25 then
                    return 0.9
                end
            end
        end
    end

    return 0
end

function X.RetreatWhenTowerTargetedDesire()
	if DotaTime() > 10 * 60
    or J.IsInTeamFight(bot, 1600)
	then
		return 0
	end

	local nEnemyTowers = bot:GetNearbyTowers(800, true)

    -- reduce feeding causes
	if J.IsValidBuilding(nEnemyTowers[1]) and not J.IsPushing(bot) then
        if J.IsGoingOnSomeone(bot) then
            if J.IsValidHero(botTarget)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
            and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nDamage = bot:GetEstimatedDamageToTarget(true, botTarget, 5.0, DAMAGE_TYPE_ALL) * 1.2
                nDamage = botTarget:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_ALL)
                if nDamage / botTarget:GetHealth() < 0.88 then
                    return 0.9
                end
            end
        end

        if nEnemyTowers[1]:GetAttackTarget() == bot then
            return 0.9
        end
	end

	return 0
end

-- from mode_farm_generic
function X.ShouldRun()
	if J.GetModifierTime(bot, 'modifier_medusa_stone_gaze_facing') > 3.33 then
		return 3.33
	end

    for _, enemyHero in pairs(nEnemyHeroes) do
        if J.IsValidHero(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe') then
            local enemyHeroAttackRange = enemyHero:GetAttackRange()
            if (enemyHero:HasModifier('modifier_muerta_pierce_the_veil_buff') and J.IsInRange(bot, enemyHero, enemyHeroAttackRange) and botHP < 0.5) then
                local fModifierTime = J.GetModifierTime(enemyHero, 'modifier_muerta_pierce_the_veil_buff')
                if enemyHero:GetEstimatedDamageToTarget(false, bot, fModifierTime, DAMAGE_TYPE_MAGICAL) >= (botHealth + botHealthRegen * fModifierTime) then
                    return fModifierTime
                end
            elseif (enemyHero:HasModifier('modifier_bristleback_active_conical_quill_spray') and J.IsInRange(bot, enemyHero, 400) and not enemyHero:IsFacingLocation(botLocation, 70)) then
                return 3
            end
        end
    end

	local nDistanceFromEnemyFountain = J.GetDistanceFromEnemyFountain(bot)
	local nDistanceFromEnemyAncient = GetUnitToUnitDistance(bot, hEnemyAncient)
	local nAliveEnemyCount = J.GetNumOfAliveHeroes(true)
	local rushEnemyTowerDistance = 250

	if nDistanceFromEnemyFountain < 1560 then
		return 2
	end

    local botAssignedLane = bot:GetAssignedLane()
	if botLevel <= 4 and nDistanceFromEnemyFountain < 8000 then
		if (botAssignedLane == LANE_TOP and nDistanceFromEnemyFountain < (GetTeam() == TEAM_RADIANT and 10800 or 8100))
		or (botAssignedLane == LANE_MID and nDistanceFromEnemyFountain < (GetTeam() == TEAM_RADIANT and 8100 or 8000))
		or (botAssignedLane == LANE_BOT and nDistanceFromEnemyFountain < (GetTeam() == TEAM_RADIANT and 8200 or 10800))
		then
            return 3.33
		end
	end

	if botLevel < 6 and DotaTime() > 30 and J.IsEarlyGame() then
		if (botAssignedLane == LANE_TOP and nDistanceFromEnemyFountain < (GetTeam() == TEAM_RADIANT and 12000 or 9000))
		or (botAssignedLane == LANE_MID and nDistanceFromEnemyFountain < (GetTeam() == TEAM_RADIANT and 9000 or 8000))
		or (botAssignedLane == LANE_BOT and nDistanceFromEnemyFountain < (GetTeam() == TEAM_RADIANT and 9000 or 12000))
		then
			if J.IsValidHero(botTarget)
			and not J.IsSuspiciousIllusion(botTarget)
            and J.GetHP(botTarget) > 0.35
            and (not J.IsInRange(bot,botTarget,bot:GetAttackRange() + 150)
                or not J.CanKillTarget(botTarget, bot:GetAttackDamage() * 2.33, DAMAGE_TYPE_PHYSICAL))
			then
				return 2.88
			end
		end
	end

	if botLevel < 10
    and bot:GetAttackDamage() < 133
    and J.IsValid(botTarget)
    and botTarget:IsAncientCreep()
    and #nAllyHeroes <= 1
    and bot:DistanceFromFountain() > 3000
	then
		return 6.21
	end

	-- if not J.AreTheseBuildingDestroyed({TOWER_TOP_3, TOWER_MID_3, TOWER_BOT_3})
    -- and nAliveEnemyCount >= 3
    -- and #nEnemyHeroes < nAliveEnemyCount + 2
    -- and not J.IsLateGame()
	-- then
	-- 	local averageAllyLevel = J.GetAverageLevel(false)
	-- 	local averageEnemyLevel = J.GetAverageLevel(true)
	-- 	if nDistanceFromEnemyFountain < 4765 then
	-- 		local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(700, false)
	-- 		if (averageAllyLevel - 4 < averageEnemyLevel and averageAllyLevel < 17)
    --         and not (averageAllyLevel - 2 > averageEnemyLevel and nAliveEnemyCount == 3)
    --         and #nAllyLaneCreeps <= 4
	-- 		then
	-- 			return 1.33
	-- 		end
	-- 	end
	-- end

	local nEnemyTowers = bot:GetNearbyTowers(900, true)
	local nEnemyBarracks = bot:GetNearbyBarracks(900, true)
	local enemyAncient = GetAncient(GetOpposingTeam());
    local enemyAncientDistance = GetUnitToUnitDistance(bot,enemyAncient);

	if #nEnemyBarracks >= 1 and nAliveEnemyCount >= 2 then
		if #nEnemyTowers >= 2
        or nDistanceFromEnemyAncient <= 1314
        or nDistanceFromEnemyFountain <= 2828
		then
			return 2
		end
	end

    -- if #nEnemyTowers >= 1
	-- and enemyAncientDistance < 7000 then -- 推2塔或者高地不要无视防御符文下的防御塔
	-- 	local cloestTower = nEnemyTowers[1]
	-- 	if J.IsValidBuilding(cloestTower)
	-- 	and GetUnitToUnitDistance(cloestTower, bot) < 800
	-- 	and (cloestTower:HasModifier("modifier_fountain_glyph")
	-- 	or cloestTower:HasModifier("modifier_invulnerable")
	-- 	or cloestTower:HasModifier("modifier_backdoor_protection_active"))
	-- 	then
	-- 		return 1.2
	-- 	end
	-- end

    if J.Utils.HasModifierContainsName(bot, "warlock_golem") then
		local nUnits = GetUnitList(UNIT_LIST_ENEMIES)
		for _, unit in pairs(nUnits)
		do
			if J.IsValid(unit)
			and J.IsInRange(bot, unit, unit:GetAttackRange() + 400)
			-- and string.find(unit:GetUnitName(), 'warlock_golem')
			then
				if (J.GetHP(bot) < J.GetHP(unit)
				and J.GetHP(bot) < 0.75)
				or J.GetHP(bot) < 0.5 then
					return 3
				end
			end
		end
	end

	-- if J.IsValidBuilding(nEnemyTowers[1]) and botLevel < 17 then
	-- 	if J.CanBeAttacked(nEnemyTowers[1]) and nAliveEnemyCount > 1 then
	-- 		return 2.5
	-- 	end

	-- 	if nDistanceFromEnemyAncient > 2100
    --     and nDistanceFromEnemyAncient < GetUnitToUnitDistance(nEnemyTowers[1], hEnemyAncient) - rushEnemyTowerDistance
	-- 	then
	-- 		if botTarget == nil then
	-- 			return 3.9
	-- 		end

	-- 		if J.IsValidHero(botTarget) and nAliveEnemyCount > 2 then
	-- 			local bAssistAlly = false
	-- 			for _, ally in pairs(nAllyHeroes) do
    --                 if J.IsValidHero(ally)
    --                 and GetUnitToUnitDistance(ally, botTarget) <= ally:GetAttackRange() + 100
    --                 and (ally:GetAttackTarget() == botTarget or ally:GetTarget() == botTarget)
    --                 then
    --                     bAssistAlly = true
    --                     break
    --                 end
	-- 			end

	-- 			if not bAssistAlly then
	-- 				return 2.5
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- if botLevel <= 10 and (#nEnemyHeroes > 0 or botHP < 0.2) then
	-- 	local nLongEnemyTowers = bot:GetNearbyTowers(999, true)
	-- 	if bot:GetAssignedLane() == LANE_MID then
	-- 		 nLongEnemyTowers = bot:GetNearbyTowers(988, true)
	-- 		 nEnemyTowers     = bot:GetNearbyTowers(966, true)
	-- 	end
	-- 	if (botLevel <= 2 or DotaTime() < 2 * 60)
	-- 	and J.IsValidBuilding(nLongEnemyTowers[1]) ~= nil
	-- 	then
	-- 		return 1
	-- 	end
	-- 	if (botLevel <= 4 or DotaTime() < 3 * 60)
	-- 	and J.IsValidBuilding(nEnemyTowers[1])
	-- 	then
	-- 		return 1
	-- 	end
	-- 	if botLevel <= 9
    --     and J.IsValidBuilding(nEnemyTowers[1])
    --     and nEnemyTowers[1]:GetAttackTarget() == bot
    --     and #nAllyHeroes <= 1
	-- 	then
	-- 		return 1
	-- 	end
	-- end

	if J.IsRealInvisible(bot)
    and not J.IsEarlyGame()
    and J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.4
    and #nAllyHeroes <= 1
    and J.IsValidHero(nEnemyHeroes[1])
    and botName ~= "npc_dota_hero_riki"
    and botName ~= "npc_dota_hero_bounty_hunter"
    and botName ~= "npc_dota_hero_slark"
    and J.GetDistanceFromAncient(bot, false) < J.GetDistanceFromAncient(nEnemyHeroes[1], false)
	then
		return 5
	end

	-- if #nAllyHeroes <= 1
    -- and botActiveMode ~= BOT_MODE_TEAM_ROAM
    -- and botActiveMode ~= BOT_MODE_LANING
    -- and botActiveMode ~= BOT_MODE_RETREAT
    -- and (botLevel <= 1 or botLevel > 5)
    -- and bot:DistanceFromFountain() > 1400
	-- then
	-- 	if enemyPids == nil then
	-- 		enemyPids = GetTeamPlayers(GetOpposingTeam())
	-- 	end	
	-- 	local enemyCount = 0
	-- 	for i = 1, #enemyPids do
	-- 		local info = GetHeroLastSeenInfo(enemyPids[i])
	-- 		if info ~= nil then
	-- 			local dInfo = info[1]; 
	-- 			if dInfo ~= nil and dInfo.time_since_seen < 2.0  
	-- 				and GetUnitToLocationDistance(bot,dInfo.location) < 1000 
	-- 			then
	-- 				enemyCount = enemyCount +1;
	-- 			end
	-- 		end	
	-- 	end
	-- 	if (enemyCount >= 4 or #hEnemyHeroList >= 4) 
	-- 		and botMode ~= BOT_MODE_ATTACK
	-- 		and botMode ~= BOT_MODE_TEAM_ROAM
	-- 		and bot:GetCurrentMovementSpeed() > 300
	-- 	then
	-- 		local nNearByHeroes = bot:GetNearbyHeroes(700,true,BOT_MODE_NONE);
	-- 		if #nNearByHeroes < 2
	--         then
	-- 			return 4;
	-- 		end
	-- 	end	
	-- 	if  botLevel >= 9 and botLevel <= 17  
	-- 		and (enemyCount >= 3 or #hEnemyHeroList >= 3) 
	-- 		and botMode ~= BOT_MODE_LANING
	-- 		and bot:GetCurrentMovementSpeed() > 300
	-- 	then
	-- 		local nNearByHeroes = bot:GetNearbyHeroes(700,true,BOT_MODE_NONE);
	-- 		if #nNearByHeroes < 2
	--         then
	-- 			return 3;
	-- 		end
	-- 	end	
	-- end	

	return 0
end

function X.ConsiderCompleteItem()
    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation == nil and #nEnemyHeroes == 0 and bot:DistanceFromFountain() < 4400 and not bot:HasModifier('modifier_fountain_aura_buff') then
        if J.Item.GetEmptyInventoryAmount(bot) == 0 then
            -- check if stash has recipe
            local bRecipeInStash = false
            local sItemRecipe = ''
            for i = 9, 14 do
                local hStashItem = bot:GetItemInSlot(i)
                if hStashItem then
                    if string.find(hStashItem:GetName(), 'item_recipe') then
                        sItemRecipe = hStashItem:GetName()
                        bRecipeInStash = true
                        break
                    end
                end
            end

            if bRecipeInStash then
                -- check if can form ^ item
                local sItemName = string.gsub(sItemRecipe, '_recipe', '')
                local tItemComponents = GetItemComponents(sItemName)[1]
                local count = 0
                for i = 0, 14 do
                    local hItem = bot:GetItemInSlot(i)
                    if hItem and not hItem:IsCombineLocked() then
                        local sItemName_ = hItem:GetName()
                        -- there's a broken item progression (<- valve bug)
                        if i <= 8 and string.find(sItemName_, 'recipe') then
                            return 0
                        end

                        for j = 1, #tItemComponents do
                            if sItemName_ == tItemComponents[j] then
                                count = count + 1
                            end
                        end
                    end
                end

                if count > 0 and count == #tItemComponents then
                    return BOT_MODE_DESIRE_ABSOLUTE * 1.5
                end
            end
        end
    end

    return 0
end
