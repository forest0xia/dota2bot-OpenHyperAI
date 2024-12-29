local J = require(GetScriptDirectory() ..  "/FunLib/jmz_func")
local U = require(GetScriptDirectory()..'/FunLib/minion_lib/utils')
local X = {}
local bot = GetBot()
local DispelMagicDesire, CycloneDesire, WindWalkDesire, HurlBoulderDesire = 0, 0, 0, 0
local nAllyHeroes, nEnemyHeroes, botTarget

function X.MinionThink(aBot, hMinionUnit)
    bot = aBot
    botTarget = J.GetProperTarget(bot)
    nAllyHeroes = hMinionUnit:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    nEnemyHeroes = hMinionUnit:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if J.IsValid(hMinionUnit) then
		if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_storm") then
			if (hMinionUnit:IsUsingAbility()) then return end
			DispelMagic = hMinionUnit:GetAbilityByName("brewmaster_storm_dispel_magic")
			Cyclone = hMinionUnit:GetAbilityByName("brewmaster_storm_cyclone")
			WindWalk = hMinionUnit:GetAbilityByName("brewmaster_storm_wind_walk")
			DispelMagicDesire, DispelMagicTarget = UseDispelMagic(hMinionUnit)
			if DispelMagicDesire > 0 then
				hMinionUnit:Action_UseAbilityOnLocation(DispelMagic, DispelMagicTarget)
				return
			end
			CycloneDesire, CycloneTarget = UseCyclone(hMinionUnit)
			if CycloneDesire > 0 then
				hMinionUnit:Action_UseAbilityOnEntity(Cyclone, CycloneTarget)
				return
			end
			WindWalkDesire, WindWalkTarget = UseWindWalk(hMinionUnit)
			if WindWalkDesire > 0 then
				hMinionUnit:Action_UseAbility(WindWalk)
				return
			end
		end
		if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_earth") then
			if (hMinionUnit:IsUsingAbility()) then return end
			HurlBoulder = hMinionUnit:GetAbilityByName("brewmaster_earth_hurl_boulder")
			HurlBoulderDesire, HurlBoulderTarget = UseHurlBoulder(hMinionUnit)
			if HurlBoulderDesire > 0 then
				hMinionUnit:Action_UseAbilityOnEntity(HurlBoulder, HurlBoulderTarget)
				return
			end

			if hMinionUnit:GetHealth() <= hMinionUnit:GetMaxHealth() * 0.3 then
				hMinionUnit:Action_MoveToLocation(J.GetTeamFountain())
				return
			end

		end

		if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_fire") then
		end

		if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_void") then
			if (hMinionUnit:IsUsingAbility()) then return end
			AstralPull = hMinionUnit:GetAbilityByName("brewmaster_void_astral_pull")
			AstralPullDesire, AstralPullTarget = UseAstralPull(hMinionUnit)
			if AstralPullDesire > 0 then
				hMinionUnit:Action_UseAbility(AstralPull)
				return
			end
		end

        local target = AttackUnits(hMinionUnit)
        if target ~= nil then
            hMinionUnit:Action_AttackUnit(target, false)
            return
        end

        local move_desire, move_location = ConsiderMove(hMinionUnit)
        if move_desire > 0
        then
            hMinionUnit:Action_MoveToLocation(move_location)
            return
        end
	end
end

function AttackUnits(hMinionUnit)
    local enemies = hMinionUnit:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local target = nil
	
	if GetUnitToUnitDistance(hMinionUnit, bot) > 1600 then
		target = nil
		return target
	end
	
	if enemies ~= nil and #enemies >= 1 then
		target = J.GetWeakestUnit(enemies)
	end
	
	if enemies == nil or #enemies <= 0 then
		enemies = hMinionUnit:GetNearbyLaneCreeps(1600, true)
	end
	
	if enemies == nil or #enemies <= 0 then
		enemies = hMinionUnit:GetNearbyBarracks(1600, true)
	end
	
	if enemies == nil or #enemies <= 0 then
		enemies = hMinionUnit:GetNearbyTowers(1600, true)
	end
	
	if target == nil and enemies ~= nil and #enemies >= 1 then
		target = enemies[1]
	end
	
	if target ~= nil and not target:IsAttackImmune() and not target:IsInvulnerable() then
		return target
	end
	
	return target
end

function UseDispelMagic(hMinionUnit)
	if not DispelMagic:IsFullyCastable() then return 0, nil end
	if J.CanNotUseAbility(hMinionUnit) then return 0, nil end
	
	local CastRange = DispelMagic:GetCastRange()
	local Radius = DispelMagic:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, hMinionUnit:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
	end
	
	return 0, nil
end

function UseCyclone(hMinionUnit)
	if not Cyclone:IsFullyCastable() then return 0, nil end
	if J.CanNotUseAbility(hMinionUnit) then return 0, nil end
	
	local CastRange = Cyclone:GetCastRange()
	
	local enemies = hMinionUnit:GetNearbyHeroes(CastRange + 500, true, BOT_MODE_NONE)
	local filteredenemies = J.FilterEnemiesForStun(enemies)
	local target = nil
	
	for v, enemy in pairs(enemies) do
		if J.IsValidTarget(enemy) and enemy:IsChanneling() and J.IsNotImmune(enemy) then
			target = enemy
			break
		end
	end
	
	if target == nil and #filteredenemies >= 2 then
		target = J.GetStrongestEnemyHero(filteredenemies)
	end
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0, nil
end

function UseWindWalk(hMinionUnit)
	if not WindWalk:IsFullyCastable() then return 0, nil end
	if DispelMagic:IsFullyCastable() then return 0, nil end
	if Cyclone:IsFullyCastable() then return 0 , nil end
	if J.CanNotUseAbility(hMinionUnit) then return 0, nil end
	
	return BOT_ACTION_DESIRE_HIGH
end

function UseHurlBoulder(hMinionUnit)
	if not HurlBoulder:IsFullyCastable() then return 0, nil end
	if J.CanNotUseAbility(hMinionUnit) then return 0, nil end
	
	local CastRange = HurlBoulder:GetCastRange()
	
	local enemies = hMinionUnit:GetNearbyHeroes(CastRange + 500, true, BOT_MODE_NONE)
	local target = J.GetWeakestUnit(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0, nil
end

function UseAstralPull(hMinionUnit)
	if not AstralPull:IsFullyCastable() then return 0, nil end
	if J.CanNotUseAbility(hMinionUnit) then return 0, nil end
	
	local SearchRange = 800
	
	local enemies = hMinionUnit:GetNearbyHeroes(SearchRange, true, BOT_MODE_NONE)
    if enemies ~= nil and #enemies >= 1 then
        for v, enemy in pairs(enemies) do
            if enemy:IsChanneling() then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
	return 0, nil
end

function ConsiderMove(hMinionUnit)
	if U.CantMove(hMinionUnit)
	then
		return BOT_MODE_DESIRE_NONE, 0
	end

    local target = U.GetWeakestHero(1600, hMinionUnit)
    if target == nil
	then
		if target == nil then target = U.GetWeakestCreep(1600, hMinionUnit) end
		if target == nil then target = U.GetWeakestTower(1600, hMinionUnit) end
	end

    if target ~= nil
    then
        return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
    end

    local loc = J.GetClosestTeamLane(hMinionUnit)
    local nInRangeEnemy = J.GetEnemiesNearLoc(loc, 1600)
    if #nInRangeEnemy == 0
    then
        return BOT_ACTION_DESIRE_HIGH, loc
    else
        if nAllyHeroes and J.IsValidHero(nAllyHeroes[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nAllyHeroes[1]:GetLocation()
        else
            return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain()
        end
    end
end

return X
