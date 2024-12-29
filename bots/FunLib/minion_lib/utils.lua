local U = {}

local nEnemyAncient = GetAncient(GetOpposingTeam())

function U.IsValidUnit(unit)
    return unit ~= nil
        and not unit:IsNull()
        and unit:IsAlive()
        and unit:CanBeSeen()
end

function U.IsValidTarget(unit)
	return U.IsValidUnit(unit)
	   and not unit:IsInvulnerable()
	   and not unit:IsAttackImmune()
end

function U.IsBusy(unit)
	return U.IsValidUnit(unit)
        and (unit:IsUsingAbility()
            or unit:IsCastingAbility()
            or unit:IsChanneling())
end

function U.CantMove(unit)
	return U.IsValidUnit(unit)
        and (unit:IsStunned()
            or unit:IsRooted()
            or unit:IsNightmared()
            or unit:IsInvulnerable() and not unit:HasModifier('modifier_fountain_invulnerability')
            )
end


function U.CantAttack(unit)
	return U.IsValidUnit(unit)
        and (unit:IsStunned()
            or unit:IsRooted()
            or unit:IsNightmared()
            or unit:IsDisarmed()
            or unit:IsInvulnerable()
            or unit:GetAttackDamage() <= 0
            )
end

function U.GetWeakestHero(nRadius, thisUnit)
    if U.IsValidUnit(thisUnit)
    then
        local nEnemyHeroes = thisUnit:GetNearbyHeroes(nRadius * 0.5, true, BOT_MODE_NONE)
        if #nEnemyHeroes == 0
        then
            nEnemyHeroes = thisUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
        end

        return U.GetWeakest(nEnemyHeroes)
    end

    return nil
end

function U.GetWeakestCreep(nRadius, hMinionUnit)
    if U.IsValidUnit(hMinionUnit)
    then
        local nCreeps = hMinionUnit:GetNearbyCreeps(nRadius * 0.5, true)

        if #nCreeps == 0
        then
            nCreeps = hMinionUnit:GetNearbyCreeps(nRadius, true)
        end

        return U.GetWeakest(nCreeps)
    end

    return nil
end

function U.GetWeakestTower(nRadius, hMinionUnit)
    if U.IsValidUnit(hMinionUnit)
    then
        if U.IsValidTarget(nEnemyAncient)
        and GetUnitToUnitDistance(hMinionUnit, nEnemyAncient) <= nRadius
        then
            return nEnemyAncient
        end

		local nTowers = hMinionUnit:GetNearbyTowers(nRadius, true)
        if nTowers == nil or #nTowers == 0
        then
			nTowers = hMinionUnit:GetNearbyBarracks(nRadius, true)
            if nTowers == nil or #nTowers == 0
            then
                nTowers = hMinionUnit:GetNearbyFillers(nRadius, true)
            end
        end

        return U.GetWeakest(nTowers)
    end

	return nil
end

function U.GetWeakest(unitList)
	local target = nil
	local minKillTime = 10000

	if #unitList > 0
	then
		for i = 1, #unitList
		do
			local unit = unitList[i]
			if U.IsValidTarget(unit)
			and not U.IsNotAllowedToAttack(unit)
			then
				local killUnitTime = unit:GetHealth() / unit:GetActualIncomingDamage( 3000, DAMAGE_TYPE_PHYSICAL )
				if killUnitTime < minKillTime
				then
					target = unit
					minKillTime = killUnitTime
				end
			end
		end
	end

	return target
end

function U.IsNotAllowedToAttack(unit)
	local unit_name = unit:GetUnitName()
	return unit_name == '#DOTA_OutpostName_North'
		or unit_name == '#DOTA_OutpostName_South'
		or unit_name == 'npc_dota_unit_twin_gate'
end

function U.IsTargetedByHero(unit)
	for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if U.IsValidUnit(enemy)
		and enemy:IsHero()
		and GetUnitToUnitDistance( unit, enemy ) <= enemy:GetAttackRange() + 300
		and enemy:GetAttackTarget() == unit
		then
			return true
		end
	end

	return false
end

function U.IsTargetedByTower(unit)
	for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_BUILDINGS))
	do
		if U.IsValidUnit(enemy)
		and enemy:IsTower()
		and GetUnitToUnitDistance( unit, enemy ) <= enemy:GetAttackRange() + 300
		and enemy:GetAttackTarget() == unit
		then
			return true
		end
	end

	return false
end

function U.IsTargetedByCreep(unit)
	for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_CREEPS))
	do
		if U.IsValidUnit(enemy)
		and enemy:IsCreep()
		and GetUnitToUnitDistance( unit, enemy ) <= enemy:GetAttackRange() + 300
		and enemy:GetAttackTarget() == unit
		then
			return true
		end
	end

    for _, enemy in pairs(GetUnitList(UNIT_LIST_NEUTRAL_CREEPS))
	do
		if U.IsValidUnit(enemy)
		and enemy:IsCreep()
		and GetUnitToUnitDistance( unit, enemy ) <= enemy:GetAttackRange() + 300
		and enemy:GetAttackTarget() == unit
		then
			return true
		end
	end

	return false
end

function U.IsShamanFowlPlayChicken(unit)
	if unit:GetUnitName() == 'npc_dota_hero_shadow_shaman'
	and unit:IsIllusion()
	and unit:IsHexed()
	then
		return true
	end

	return false
end

-- Init Spells
function U.InitiateAbility(unit)
    if unit ~= nil and not unit:IsNull()
    then
        unit.abilities = {}

        if unit:GetUnitName() == 'npc_dota_hero_vengefulspirit'
        then
            for i = 0, 23
            do
                unit.abilities[i+1] = unit:GetAbilityInSlot(i)
            end
        else
            for i = 0, 3
            do
                unit.abilities[i+1] = unit:GetAbilityInSlot(i)
            end
        end
    end
end

---------------
-- Unit Names
---------------

function U.IsAttackingWard(unit)
	local unit_name = unit:GetUnitName()
    return unit_name == "npc_dota_shadow_shaman_ward_1"
	    or unit_name == "npc_dota_shadow_shaman_ward_2"
	    or unit_name == "npc_dota_shadow_shaman_ward_3"
	    or unit_name == "npc_dota_venomancer_plague_ward_1"
	    or unit_name == "npc_dota_venomancer_plague_ward_2"
	    or unit_name == "npc_dota_venomancer_plague_ward_3"
	    or unit_name == "npc_dota_venomancer_plague_ward_4"
	    or unit_name == "npc_dota_witch_doctor_death_ward"
end

function U.CantBeControlled(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_zeus_cloud"
		or unit_name == "npc_dota_unit_tombstone1"
		or unit_name == "npc_dota_unit_tombstone2"
		or unit_name == "npc_dota_unit_tombstone3"
		or unit_name == "npc_dota_unit_tombstone4"
		or unit_name == "npc_dota_pugna_nether_ward_1"
		or unit_name == "npc_dota_pugna_nether_ward_2"
		or unit_name == "npc_dota_pugna_nether_ward_3"
		or unit_name == "npc_dota_pugna_nether_ward_4"
		or unit_name == "npc_dota_rattletrap_cog"
		or unit_name == "npc_dota_rattletrap_rocket"
		or unit_name == "npc_dota_broodmother_web"
		or unit_name == "npc_dota_unit_undying_zombie"
		or unit_name == "npc_dota_unit_undying_zombie_torso"
		or unit_name == "npc_dota_weaver_swarm"
		or unit_name == "npc_dota_death_prophet_torment"
		or unit_name == "npc_dota_gyrocopter_homing_missile"
		or unit_name == "npc_dota_plasma_field"
		or unit_name == "npc_dota_wisp_spirit"
		or unit_name == "npc_dota_beastmaster_axe"
		or unit_name == "npc_dota_troll_warlord_axe"
		or unit_name == "npc_dota_phoenix_sun"
		or unit_name == "npc_dota_techies_minefield_sign"
		or unit_name == "npc_dota_treant_eyes"
		or unit_name == "npc_dota_clinkz_skeleton_archer"
		or unit_name == "dota_death_prophet_exorcism_spirit"
		or unit_name == "npc_dota_dark_willow_creature"
		or (unit_name == "npc_dota_hero_hoodwink" and unit:HasModifier('modifier_hoodwink_sharpshooter_windup'))
end

function U.IsMinionWithNoSkill(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_lesser_eidolon"
		or unit_name == "npc_dota_eidolon"
		or unit_name == "npc_dota_greater_eidolon"
		or unit_name == "npc_dota_dire_eidolon"
		or unit_name == "npc_dota_furion_treant"
		or unit_name == "npc_dota_furion_treant_large"
		or unit_name == "npc_dota_invoker_forged_spirit"
		or unit_name == "npc_dota_broodmother_spiderling"
		or unit_name == "npc_dota_broodmother_spiderite"
		or unit_name == "npc_dota_wraith_king_skeleton_warrior"
		or unit_name == "npc_dota_warlock_golem"
		or unit_name == "npc_dota_warlock_golem_1"
		or unit_name == "npc_dota_warlock_golem_2"
		or unit_name == "npc_dota_warlock_golem_3"
		or unit_name == "npc_dota_warlock_golem_scepter"
		or unit_name == "npc_dota_warlock_golem_scepter_1"
		or unit_name == "npc_dota_warlock_golem_scepter_2"
		or unit_name == "npc_dota_warlock_golem_scepter_3"
		or unit_name == "npc_dota_beastmaster_boar"
		or unit_name == "npc_dota_beastmaster_greater_boar"
		or unit_name == "npc_dota_beastmaster_boar_1"
		or unit_name == "npc_dota_beastmaster_boar_2"
		or unit_name == "npc_dota_beastmaster_boar_3"
		or unit_name == "npc_dota_beastmaster_boar_4"
		or unit_name == "npc_dota_beastmaster_boar_5"
		or unit_name == "npc_dota_lycan_wolf1"
		or unit_name == "npc_dota_lycan_wolf2"
		or unit_name == "npc_dota_lycan_wolf3"
		or unit_name == "npc_dota_lycan_wolf4"
		or unit_name == "npc_dota_lycan_wolf5"
		or unit_name == "npc_dota_neutral_kobold"
		or unit_name == "npc_dota_neutral_kobold_tunneler"
		or unit_name == "npc_dota_neutral_kobold_taskmaster"
		or unit_name == "npc_dota_neutral_centaur_outrunner"
		or unit_name == "npc_dota_neutral_fel_beast"
		or unit_name == "npc_dota_neutral_polar_furbolg_champion"
		or unit_name == "npc_dota_neutral_ogre_mauler"
		or unit_name == "npc_dota_neutral_giant_wolf"
		or unit_name == "npc_dota_neutral_alpha_wolf"
		or unit_name == "npc_dota_neutral_wildkin"
		or unit_name == "npc_dota_neutral_jungle_stalker"
		or unit_name == "npc_dota_neutral_elder_jungle_stalker"
		or unit_name == "npc_dota_neutral_prowler_acolyte"
		or unit_name == "npc_dota_neutral_rock_golem"
		or unit_name == "npc_dota_neutral_granite_golem"
		or unit_name == "npc_dota_neutral_small_thunder_lizard"
		or unit_name == "npc_dota_neutral_gnoll_assassin"
		or unit_name == "npc_dota_neutral_ghost"
		or unit_name == "npc_dota_wraith_ghost"
		or unit_name == "npc_dota_neutral_dark_troll"
		or unit_name == "npc_dota_neutral_forest_troll_berserker"
		or unit_name == "npc_dota_neutral_harpy_scout"
		or unit_name == "npc_dota_neutral_black_drake"
		or unit_name == "npc_dota_dark_troll_warlord_skeleton_warrior"
		or unit_name == "npc_dota_necronomicon_warrior_1"
		or unit_name == "npc_dota_necronomicon_warrior_2"
		or unit_name == "npc_dota_necronomicon_warrior_3"
		or unit_name == "npc_dota_creep_goodguys_melee"
		or unit_name == "npc_dota_creep_goodguys_melee_upgraded"
		or unit_name == "npc_dota_creep_goodguys_ranged"
		or unit_name == "npc_dota_creep_goodguys_ranged_upgraded"
		or unit_name == "npc_dota_goodguys_siege"
		or unit_name == "npc_dota_goodguys_siege_upgraded"
end

function U.IsMinionWithSkill(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_neutral_centaur_khan"
		or unit_name == "npc_dota_neutral_polar_furbolg_ursa_warrior"
		or unit_name == "npc_dota_neutral_mud_golem"
		or unit_name == "npc_dota_neutral_mud_golem_split"
		or unit_name == "npc_dota_neutral_mud_golem_split_doom"
		or unit_name == "npc_dota_neutral_ogre_magi"
		or unit_name == "npc_dota_neutral_enraged_wildkin"
		or unit_name == "npc_dota_neutral_satyr_soulstealer"
		or unit_name == "npc_dota_neutral_satyr_hellcaller"
		or unit_name == "npc_dota_neutral_prowler_shaman"
		or unit_name == "npc_dota_neutral_big_thunder_lizard"
		or unit_name == "npc_dota_neutral_dark_troll_warlord"
		or unit_name == "npc_dota_neutral_satyr_trickster"
		or unit_name == "npc_dota_neutral_forest_troll_high_priest"
		or unit_name == "npc_dota_neutral_harpy_storm"
		or unit_name == "npc_dota_neutral_black_dragon"
		or unit_name == "npc_dota_necronomicon_archer_1"
		or unit_name == "npc_dota_necronomicon_archer_2"
		or unit_name == "npc_dota_necronomicon_archer_3"
		or unit_name == "npc_dota_neutral_warpine_raider"
end

function U.IsFrozeSigil(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_tusk_frozen_sigil1"
		or unit_name == "npc_dota_tusk_frozen_sigil2"
		or unit_name == "npc_dota_tusk_frozen_sigil3"
		or unit_name == "npc_dota_tusk_frozen_sigil4"
end

function U.IsHawk(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_scout_hawk"
		or unit_name == "npc_dota_greater_hawk"
		or unit_name == "npc_dota_beastmaster_hawk"
		or unit_name == "npc_dota_beastmaster_hawk_1"
		or unit_name == "npc_dota_beastmaster_hawk_2"
		or unit_name == "npc_dota_beastmaster_hawk_3"
		or unit_name == "npc_dota_beastmaster_hawk_4"
end

function U.IsTornado(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_enraged_wildkin_tornado"
end

function U.IsHealingWard(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_juggernaut_healing_ward"
end

function U.IsBear(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_lone_druid_bear1"
		or unit_name == "npc_dota_lone_druid_bear2"
		or unit_name == "npc_dota_lone_druid_bear3"
		or unit_name == "npc_dota_lone_druid_bear4"
end

function U.IsFamiliar(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_visage_familiar1"
		or unit_name == "npc_dota_visage_familiar2"
		or unit_name == "npc_dota_visage_familiar3"
end

function U.IsPrimalSplit(unit)
    local unit_name = unit:GetUnitName()
	return unit_name == "npc_dota_brewmaster_earth_1"
		or unit_name == "npc_dota_brewmaster_earth_2"
		or unit_name == "npc_dota_brewmaster_earth_3"
		or unit_name == "npc_dota_brewmaster_storm_1"
		or unit_name == "npc_dota_brewmaster_storm_2"
		or unit_name == "npc_dota_brewmaster_storm_3"
		or unit_name == "npc_dota_brewmaster_fire_1"
		or unit_name == "npc_dota_brewmaster_fire_2"
		or unit_name == "npc_dota_brewmaster_fire_3"
		or unit_name == "npc_dota_brewmaster_void_1"
		or unit_name == "npc_dota_brewmaster_void_2"
		or unit_name == "npc_dota_brewmaster_void_3"
end

return U