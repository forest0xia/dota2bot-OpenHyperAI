local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local X = {}

-- Vengeful Spirit Scepter Illusion
function X.ConsiderMagicMissile(hMinionUnit, MagicMissile)
    if not MagicMissile:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, hMinionUnit, MagicMissile:GetCastRange())
    local nDamage = MagicMissile:GetSpecialValueInt('magic_missile_damage')
    local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if enemyHero:IsChanneling()
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

    local nAllyHeroes = hMinionUnit:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.5)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(hMinionUnit, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

	local target = nil
	local dmg = 0

	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not J.IsDisabled(enemyHero)
		and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
		and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			local currDmg = enemyHero:GetEstimatedDamageToTarget(true, hMinionUnit, 5, DAMAGE_TYPE_ALL)

			if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
			and #nInRangeAlly >= #nTargetInRangeAlly
			and dmg < currDmg
			then
				dmg = currDmg
				target = enemyHero
			end
		end
	end

	if target ~= nil
	then
		return BOT_ACTION_DESIRE_HIGH, target
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderWaveOfTerror(hMinionUnit, WaveOfTerror)
    if not WaveOfTerror:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, hMinionUnit, WaveOfTerror:GetCastRange())
	local nRadius = WaveOfTerror:GetSpecialValueInt('wave_width')
    local nDamage = WaveOfTerror:GetAbilityDamage()
    local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nTargetInRangeAlly = J.GetEnemiesNearLoc(target:GetLocation(), nRadius)

            if nTargetInRangeAlly ~= nil and #nTargetInRangeAlly >= 1
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nTargetInRangeAlly)
            end

            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
    end

	local target = nil
	local dmg = 0

	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not J.IsDisabled(enemyHero)
		and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
		and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			local currDmg = enemyHero:GetEstimatedDamageToTarget(true, hMinionUnit, 5, DAMAGE_TYPE_ALL)

			if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
			and #nInRangeAlly >= #nTargetInRangeAlly
			and dmg < currDmg
			then
				dmg = currDmg
				target = enemyHero
			end
		end
	end

	if target ~= nil
	then
		nEnemyHeroes = J.GetEnemiesNearLoc(target:GetLocation(), nRadius)
		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyHeroes)
		end

		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end

    local nLocationAoE = hMinionUnit:FindAoELocation(true, false, hMinionUnit:GetLocation(), nCastRange, nRadius, 0, 0)
    local nEnemyLaneCreeps = hMinionUnit:GetNearbyLaneCreeps(nCastRange, true)

    if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
    and nLocationAoE.count >= 3
    and not J.IsThereCoreNearby(1000)
    then
        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderNetherSwap(hMinionUnit, NetherSwap)
    if not NetherSwap:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, hMinionUnit, NetherSwap:GetCastRange())

    local nAllyHeroes = hMinionUnit:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        if  J.IsValidHero(allyHero)
        and J.IsCore(allyHero)
        and not J.IsSuspiciousIllusion(allyHero)
        then
            if allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or allyHero:HasModifier('modifier_enigma_black_hole_pull')
            or allyHero:HasModifier('modifier_legion_commander_duel')
            or (allyHero:HasModifier('modifier_mars_arena_of_blood_leash')
                and not hMinionUnit:HasModifier('modifier_mars_arena_of_blood_leash'))
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
        end
    end

	local target = nil
	local dmg = 0
	local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

	for _, enemyHero in pairs(nInRangeEnemy)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsInRange(hMinionUnit, enemyHero, nCastRange / 2)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not J.IsDisabled(enemyHero)
		and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
		and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not enemyHero:HasModifier('modifier_legion_commander_duel')
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		and not enemyHero:WasRecentlyDamagedByAnyHero(2)
		then
			local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			local currDmg = enemyHero:GetEstimatedDamageToTarget(true, bot, 5, DAMAGE_TYPE_ALL)

			if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
			and #nInRangeAlly >= #nTargetInRangeAlly
			and #nInRangeAlly >= 1
			and not (#nInRangeAlly > #nTargetInRangeAlly + 2)
			and dmg < currDmg
			then
				dmg = currDmg
				target = enemyHero
			end
		end
	end

	if target ~= nil
	then
		return BOT_ACTION_DESIRE_HIGH, target
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X