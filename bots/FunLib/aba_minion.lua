local X = {};

local bot = GetBot();
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local V = require(GetScriptDirectory()..'/FunLib/aba_hero_skill')
local SU = require(GetScriptDirectory()..'/FunLib/aba_hero_sub_units')

local nTeamAncient = GetAncient(GetTeam());
local vTeamAncientLoc = nil;
if nTeamAncient ~= nil then vTeamAncientLoc = nTeamAncient:GetLocation() end;

local nEnemyAncient = GetAncient(GetOpposingTeam());
local vEnemyAncientLoc = nil
if nEnemyAncient ~= nil then vEnemyAncientLoc = nEnemyAncient:GetLocation() end;
local centre = Vector(0, 0, 0);

local attackDesire = 0;
local moveDesire = 0;
local retreatDesire = 0;

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;

function X.GetXUnitsTowardsLocation( hUnit, vLocation, nDistance)
    local direction = (vLocation - hUnit:GetLocation()):Normalized()
    return hUnit:GetLocation() + direction * nDistance
end

function X.IsFrozeSigil(unit_name)
	return unit_name == "npc_dota_tusk_frozen_sigil1"
		or unit_name == "npc_dota_tusk_frozen_sigil2"
		or unit_name == "npc_dota_tusk_frozen_sigil3"
		or unit_name == "npc_dota_tusk_frozen_sigil4";
end

------------BEASTMASTER'S HAWK
function X.IsHawk(unit_name)
	return unit_name == "npc_dota_scout_hawk"
		or unit_name == "npc_dota_greater_hawk"
		or unit_name == "npc_dota_beastmaster_hawk"
		or unit_name == "npc_dota_beastmaster_hawk_1"
		or unit_name == "npc_dota_beastmaster_hawk_2"
		or unit_name == "npc_dota_beastmaster_hawk_3"
		or unit_name == "npc_dota_beastmaster_hawk_4";
end

function X.HawkThink(minion)
	if X.CantMove(minion) then return end
	minion:Action_MoveToLocation(bot:GetLocation());
	return
end

function X.IsTornado(unit_name)
	return unit_name == "npc_dota_enraged_wildkin_tornado";
end

function X.IsHealingWard(unit_name)
	return unit_name == "npc_dota_juggernaut_healing_ward";
end

function X.IsBear(unit_name)
	return unit_name == "npc_dota_lone_druid_bear1"
		or unit_name == "npc_dota_lone_druid_bear2"
		or unit_name == "npc_dota_lone_druid_bear3"
		or unit_name == "npc_dota_lone_druid_bear4";
end

function X.IsFamiliar(unit_name)
	return unit_name == "npc_dota_visage_familiar1"
		or unit_name == "npc_dota_visage_familiar2"
		or unit_name == "npc_dota_visage_familiar3";
end

function X.IsBrewLink(unit_name)
	return unit_name == "npc_dota_brewmaster_earth_1"
		or unit_name ==  "npc_dota_brewmaster_earth_2"
		or unit_name ==  "npc_dota_brewmaster_earth_3"
		or unit_name ==  "npc_dota_brewmaster_storm_1"
		or unit_name ==  "npc_dota_brewmaster_storm_2"
		or unit_name ==  "npc_dota_brewmaster_storm_3"
		or unit_name ==  "npc_dota_brewmaster_fire_1"
		or unit_name ==  "npc_dota_brewmaster_fire_2"
		or unit_name ==  "npc_dota_brewmaster_fire_3"
		or unit_name ==  "npc_dota_brewmaster_void_1"
		or unit_name ==  "npc_dota_brewmaster_void_2"
		or unit_name ==  "npc_dota_brewmaster_void_3"
end

function X.IsMinionWithNoSkill(unit_name)
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
		or unit_name == "npc_dota_warlock_golem_1"
		or unit_name == "npc_dota_warlock_golem_2"
		or unit_name == "npc_dota_warlock_golem_3"
		or unit_name == "npc_dota_warlock_golem_scepter_1"
		or unit_name == "npc_dota_warlock_golem_scepter_2"
		or unit_name == "npc_dota_warlock_golem_scepter_3"
		or unit_name == "npc_dota_beastmaster_boar"
		or unit_name == "npc_dota_beastmaster_greater_boar"
		or unit_name == "npc_dota_beastmaster_boar_1"
		or unit_name == "npc_dota_beastmaster_boar_2"
		or unit_name == "npc_dota_beastmaster_boar_3"
		or unit_name == "npc_dota_beastmaster_boar_4"
		or unit_name == "npc_dota_lycan_wolf1"
		or unit_name == "npc_dota_lycan_wolf2"
		or unit_name == "npc_dota_lycan_wolf3"
		or unit_name == "npc_dota_lycan_wolf4"
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

local remnant = {
	"npc_dota_stormspirit_remnant",
	"npc_dota_ember_spirit_remnant",
	"npc_dota_earth_spirit_stone"
}

local trap = {
	"npc_dota_templar_assassin_psionic_trap",
	"npc_dota_techies_remote_mine",
	"npc_dota_techies_land_mine",
	"npc_dota_techies_stasis_trap"
}

local independent = {
	"npc_dota_brewmaster_earth_1",
	"npc_dota_brewmaster_earth_2",
	"npc_dota_brewmaster_earth_3",
	"npc_dota_brewmaster_storm_1",
	"npc_dota_brewmaster_storm_2",
	"npc_dota_brewmaster_storm_3",
	"npc_dota_brewmaster_fire_1",
	"npc_dota_brewmaster_fire_2",
	"npc_dota_brewmaster_fire_3"
}

function X.IsValidUnit(unit)
	return unit ~= nil
	   and not unit:IsNull()
	   and unit:IsAlive()
end

function X.IsValidTarget(target)
	return target ~= nil
	   and not target:IsNull()
	   and target:CanBeSeen()
	   and not target:IsInvulnerable()
	   and not target:IsAttackImmune()
	   and target:IsAlive();
end

function X.IsInRange(unit, target, range)
	return GetUnitToUnitDistance(unit, target) <= range;
end

function X.CanCastOnTarget(target, ability)
	if X.CheckFlag(ability:GetTargetFlags(), ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) then
		return target:IsHero() and target:IsIllusion() == false;
	else
		return target:IsHero() and target:IsIllusion() == false and target:IsMagicImmune() == false;
	end
end

local globRadius = 1600;

function X.GetWeakest( unitList )

	local target = nil
	local minKillTime = 10000
	if unitList ~= nil and #unitList > 0
	then
		for i=1, #unitList 
		do
			local unit = unitList[i]
			if X.IsValidTarget( unit ) 
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

function X.GetWeakestHero(radius, minion)

	local enemies = minion:GetNearbyHeroes( radius * 0.5, true, BOT_MODE_NONE);
	
	if enemies ~= nil and #enemies == 0 then enemies = minion:GetNearbyHeroes( radius, true, BOT_MODE_NONE) end
	
	return X.GetWeakest(enemies);
end

function X.GetWeakestCreep(radius, minion)

	local creeps = minion:GetNearbyLaneCreeps(radius, true)
	
	if #creeps == 0 then creeps = minion:GetNearbyNeutralCreeps(radius * 0.5) end
	
	if #creeps == 0 then creeps = minion:GetNearbyNeutralCreeps(radius) end
	
	return X.GetWeakest(creeps)
	
end

function X.GetWeakestTower(radius, minion)
	if J.IsValidHero(minion) then
		local towers = minion:GetNearbyTowers(radius, true);
		return X.GetWeakest(towers);
	end
	return nil
end

function X.GetWeakestBarracks(radius, minion)
	local barracks = minion:GetNearbyBarracks(radius, true);
	if nEnemyAncient ~= nil
		and X.IsInRange(minion,nEnemyAncient,radius)
	then
		table.insert(barracks,nEnemyAncient)
	end
	return X.GetWeakest(barracks);
end

function X.GetIllusionAttackTarget(minion)
	local target = bot:GetAttackTarget()

	if bot:HasModifier('modifier_bane_nightmare') and not bot:IsInvulnerable() then target = bot end
	if target == nil then target = bot:GetTarget() end

	if target == nil or J.IsRetreating(bot)
	then
		target = X.GetWeakestHero(globRadius, minion)
		if target == nil then target = X.GetWeakestCreep(globRadius, minion); end
		if target == nil then target = X.GetWeakestTower(globRadius, minion); end
		if target == nil then target = X.GetWeakestBarracks(globRadius, minion); end
	end

	return target
end


function X.IsBusy(unit)
	return unit:IsUsingAbility() or unit:IsCastingAbility() or unit:IsChanneling();
end

function X.CantMove(unit)
	return unit:CanBeSeen() and (unit:IsStunned() or unit:IsRooted() or unit:IsNightmared() or unit:IsInvulnerable());
end

function X.CantAttack(unit)
	return unit:CanBeSeen() and (unit:IsStunned() or unit:IsRooted() or unit:IsNightmared() or unit:IsDisarmed() or unit:IsInvulnerable() or unit:GetAttackDamage() <= 0);
end

------------ILLUSION ACT
function X.ConsiderIllusionAttack(minion)
	if X.CantAttack(minion) then return BOT_MODE_DESIRE_NONE, nil end

	local target = X.GetIllusionAttackTarget(minion)

	if target ~= nil
	then
		return BOT_MODE_DESIRE_HIGH, target
	end

	return BOT_MODE_DESIRE_NONE, nil
end

function X.ConsiderIllusionMove(minion)
	if X.CantMove(minion) then return BOT_MODE_DESIRE_NONE, nil end

	if not J.IsRetreating(bot)
	then
		return BOT_MODE_DESIRE_HIGH, X.GetXUnitsTowardsLocation(bot, vEnemyAncientLoc, 250)
	end

	if not bot:IsAlive()
	then
		return BOT_MODE_DESIRE_HIGH, X.GetXUnitsTowardsLocation(minion, vEnemyAncientLoc, 500)
	end

	return BOT_MODE_DESIRE_NONE, nil;
end

function X.IllusionThink(minion)
	minion.attackDesire, minion.target = X.ConsiderIllusionAttack(minion);
	minion.moveDesire, minion.loc      = X.ConsiderIllusionMove(minion);

	if bot:GetUnitName() == 'npc_dota_hero_chen'
	or bot:GetUnitName() == 'npc_dota_hero_beastmaster'
	then
		minion.retreatDesire, minion.retreatLoc = X.ConsiderBrewLinkRetreat(minion)
		minion.attackDesire, minion.target = X.ConsiderBrewLinkAttack(minion)
		minion.moveDesire, minion.loc = X.ConsiderBrewLinkMove(minion)

		if minion.retreatDesire > 0
		then
			if bot:IsAlive() and J.IsRetreating(bot)
			then
				minion:Action_MoveToLocation(bot:GetLocation())
			else
				minion:Action_MoveToLocation(minion.retreatLoc)
			end

			return
		end
	end

	if minion.attackDesire > 0 then
		if minion.target:IsAttackImmune() or minion.target:IsInvulnerable()
		then
			minion:Action_MoveToLocation(minion.target:GetLocation())
			return
		else
			minion:Action_AttackUnit(minion.target, false)
			return
		end
	end

	if minion.moveDesire > 0
	then
		minion:Action_MoveToLocation(minion.loc)
		return
	end
end

-----------ATTACKING WARD LIKE UNIT
local tAttackWardNameList = {
	["npc_dota_shadow_shaman_ward_1"] = true,
	["npc_dota_shadow_shaman_ward_2"] = true,
	["npc_dota_shadow_shaman_ward_3"] = true,
	["npc_dota_venomancer_plague_ward_1"] = true,
	["npc_dota_venomancer_plague_ward_2"] = true,
	["npc_dota_venomancer_plague_ward_3"] = true,
	["npc_dota_venomancer_plague_ward_4"] = true,
	["npc_dota_witch_doctor_death_ward"] = true,
}

function X.IsAttackingWard(unit_name)
	return tAttackWardNameList[unit_name] == true
end

function X.GetWardAttackTarget(minion)
	local range = minion:GetAttackRange()
	local target = bot:GetAttackTarget();
	if	not X.IsValidTarget(target)
		or (X.IsValidTarget(target) and GetUnitToUnitDistance(minion, target) > range)
	then
		target = X.GetWeakestHero(range, minion);
		if target == nil then target = X.GetWeakestCreep(range, minion); end
		if target == nil then target = X.GetWeakestTower(range, minion); end
		if target == nil then target = X.GetWeakestBarracks(range, minion); end
	end
	return target;
end

function X.ConsiderWardAttack(minion)
	local target = X.GetWardAttackTarget(minion);
	if target ~= nil then
		return BOT_MODE_DESIRE_HIGH, target;
	end
	return BOT_MODE_DESIRE_NONE, nil;
end

function X.AttackingWardThink(minion)
	minion.attackDesire, minion.target = X.ConsiderWardAttack(minion);
	if minion.attackDesire > 0
		--and minion:GetAnimActivity() ~= 1503
	then
		minion:Action_AttackUnit(minion.target, true);
		return
	end
end

function X.HealingWardThink(minion)

	local nEnemyHeroes = minion:GetNearbyHeroes( 1200, true, BOT_MODE_DESIRE_NONE )

	local targetLocation = nil
	local weakestHero = nil
	local weakestHP = 0.99
	for i = 1, 5
	do 
		local allyHero = GetTeamMember( i )
		if allyHero ~= nil
			and allyHero:IsAlive()
			and GetUnitToUnitDistance( allyHero, minion ) <= 1200
		then
			local allyHP = allyHero:GetHealth()/allyHero:GetMaxHealth()
			if allyHP < weakestHP
			then
				weakestHP = allyHP
				weakestHero = allyHero
			end
		end
	end

	if #nEnemyHeroes == 0
	then
	
		local nAoeHeroTable = minion:FindAoELocation( false, true, minion:GetLocation(), 1000, 400 , 0, 0);
		if nAoeHeroTable.count >= 2
		then
			targetLocation = nAoeHeroTable.targetloc
		end
		
		if targetLocation == nil
		then			
			if weakestHero ~= nil
			then
				targetLocation = weakestHero:GetLocation()
			end
		end

		if targetLocation == nil
		then			
			local nAoeCreepTable = minion:FindAoELocation( false, false, minion:GetLocation(), 800, 400 , 0, 0);
			if nAoeCreepTable.count >= 1
			then
				targetLocation = nAoeCreepTable.targetloc
			end			
		end
		
	else
		if weakestHero ~= nil
		then
			targetLocation = weakestHero:GetLocation()
		end	
	end

	

	if targetLocation ~= nil
	then
		if targetLocation == GetBot():GetLocation()
		then
		--自动人棒合一
			return
		else
			minion:Action_MoveToLocation( targetLocation )
		end
	else
		minion:Action_MoveToLocation( vTeamAncientLoc )
	end

end

----------CAN'T BE CONTROLLED UNIT
function X.CantBeControlled(unit_name)
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
		or unit_name == "grimstroke_ink_creature"
		or unit_name == "npc_dota_death_prophet_torment"
		or unit_name == "npc_dota_gyrocopter_homing_missile"
		or unit_name == "npc_dota_plasma_field"
		or unit_name == "npc_dota_wisp_spirit"
		or unit_name == "npc_dota_beastmaster_axe"
		or unit_name == "npc_dota_troll_warlord_axe"
		or unit_name == "npc_dota_phoenix_sun"
		or unit_name == "npc_dota_techies_minefield_sign"
		or unit_name == "npc_dota_treant_eyes"
		or unit_name == 'npc_dota_warlock_minor_imp'
		or unit_name == "dota_death_prophet_exorcism_spirit"
		or unit_name == "npc_dota_dark_willow_creature";
end

function X.CantBeControlledThink(minion)
	return
end

-----------MINION WITH SKILLS
function X.IsMinionWithSkill(unit_name)
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
		or unit_name == "npc_dota_hero_vengefulspirit"
end

function X.InitiateAbility(minion)
	minion.abilities = {}

	if minion:GetUnitName() == 'npc_dota_hero_vengefulspirit'
	then
		for i = 1, 23
		do
			minion.abilities[i] = minion:GetAbilityInSlot(i)
		end
	else
		for i = 0, 3
		do
			minion.abilities[i + 1] = minion:GetAbilityInSlot(i)
		end
	end
end

function X.CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1
end

function X.CanCastAbility(ability)
	return ability ~= nil
		and ability:IsFullyCastable()
		and ability:GetName() ~= ''
		and not ability:IsPassive()
		and not ability:IsHidden()
		and not ability:IsNull()
end

function X.ConsiderUnitTarget(minion, ability)
	local castRange = ability:GetCastRange() + 200;
	if bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(2.0) then
		local enemies = minion:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
		if enemies ~= nil and #enemies > 0 then
			for i=1, #enemies do
				if X.IsValidTarget(enemies[i]) and X.CanCastOnTarget(enemies[i], ability) then
					return BOT_ACTION_DESIRE_HIGH, enemies[i];
				end
			end
		end
	else
		local target = bot:GetAttackTarget();
		if X.IsValidTarget(target) and X.CanCastOnTarget(target, ability) and X.IsInRange(minion, target, castRange) then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.ConsiderPointTarget(minion, ability)
	local castRange = ability:GetCastRange()+200;
	if bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(2.0) then
		local enemies = minion:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
		if enemies ~= nil and #enemies > 0 then
			for i=1, #enemies do
				if X.IsValidTarget(enemies[i]) and X.CanCastOnTarget(enemies[i], ability) then
					return BOT_ACTION_DESIRE_HIGH, enemies[i]:GetLocation();
				end
			end
		end
	elseif bot:GetActiveMode() == BOT_MODE_ATTACK or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY then
		local target = bot:GetAttackTarget();
		if X.IsValidTarget(target) and X.CanCastOnTarget(target, ability) and X.IsInRange(minion, target, castRange) then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end


function X.ConsiderNoTarget(minion, ability)
	local nRadius = ability:GetSpecialValueInt("radius")

	if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local enemies = minion:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if enemies ~= nil and #enemies > 0
		then
			for i = 1, #enemies
			do
				if X.IsValidTarget(enemies[i]) and X.CanCastOnTarget(enemies[i], ability)
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	elseif J.IsGoingOnSomeone(bot) or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
	then
		local target = bot:GetAttackTarget()

		if X.IsValidTarget(target) and X.CanCastOnTarget(target, ability) and X.IsInRange(minion, target, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.CastThink(minion, ability)
	if X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET) then
		if ability:GetName() == "ogre_magi_frost_armor" then
			local castRange = ability:GetCastRange();
			local allies = GetNearbyHeroes(castRange+200, false, BOT_MODE_NONE);
			if #allies > 0 then
				for i=1, #allies do
					if X.IsValidTarget(allies[i]) and X.CanCastOnTarget(allies[i], ability)
					   and allies[i]:HasModifier("ogre_magi_frost_armor") == false
					then
						minion:Action_UseAbilityOnEntity(ability, allies[i]);
						return
					end
				end
			end
		else
			minion.castDesire, botTarget = X.ConsiderUnitTarget(minion, ability);
			if minion.castDesire > 0 then
				--print(minion:GetUnitName()..tostring(minion.castDesire).." Use Ability "..ability:GetName())
				minion:Action_UseAbilityOnEntity(ability, botTarget);
				return
			end
		end
	elseif X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT) then
		minion.castDesire, loc = X.ConsiderPointTarget(minion, ability);
		if minion.castDesire > 0 then
			--print(minion:GetUnitName()..tostring(minion.castDesire).." Use Ability "..ability:GetName())
			minion:Action_UseAbilityOnLocation(ability, loc);
			return
		end
	elseif X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET) then
		minion.castDesire = X.ConsiderNoTarget(minion, ability);
		if minion.castDesire > 0 then
			--print(minion:GetUnitName()..tostring(minion.castDesire).." Use Ability "..ability:GetName())
			minion:Action_UseAbility(ability);
			return
		end
	end
end

function X.CastAbilityThink(minion)

	if X.CanCastAbility(minion.abilities[1]) then
		X.CastThink(minion, minion.abilities[1]);
	end

	if X.CanCastAbility(minion.abilities[2]) then
		X.CastThink(minion, minion.abilities[2]);
	end

	if X.CanCastAbility(minion.abilities[3]) then
		X.CastThink(minion, minion.abilities[3]);
	end

	if X.CanCastAbility(minion.abilities[4]) then
		X.CastThink(minion, minion.abilities[4]);
	end

end

function X.MinionWithSkillThink(hMinionUnit)
	if X.IsBusy(hMinionUnit)
	then
		return
	end

	if hMinionUnit.abilities == nil
	then
		X.InitiateAbility(hMinionUnit)
	end

	if hMinionUnit:GetUnitName() == 'npc_dota_hero_vengefulspirit'
	then
		if hMinionUnit.abilities[1]:GetName() == 'vengefulspirit_magic_missile'
		then
			Desire, Target = V.ConsiderMagicMissile(hMinionUnit, hMinionUnit.abilities[1])
			if Desire > 0
			then
				hMinionUnit:Action_UseAbilityOnEntity(hMinionUnit.abilities[1], botTarget)
				return
			end
		end

		if hMinionUnit.abilities[2]:GetName() == 'vengefulspirit_wave_of_terror'
		then
			Desire, Location = V.ConsiderMagicMissile(hMinionUnit, hMinionUnit.abilities[2])
			if Desire > 0
			then
				hMinionUnit:Action_UseAbilityOnEntity(hMinionUnit.abilities[2], Location)
				return
			end
		end

		if hMinionUnit.abilities[6]:GetName() == 'vengefulspirit_nether_swap'
		then
			Desire, Target = V.ConsiderMagicMissile(hMinionUnit, hMinionUnit.abilities[6])
			if Desire > 0
			then
				hMinionUnit:Action_UseAbilityOnEntity(hMinionUnit.abilities[6], botTarget)
				return
			end
		end
	end

	for i = 1, #hMinionUnit.abilities
	do
		if X.CanCastAbility(hMinionUnit.abilities[i])
		then
			if X.CheckFlag(hMinionUnit.abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
			then
				if hMinionUnit.abilities[i]:GetName() == 'ogre_magi_frost_armor'
				then
					local nCastRange = hMinionUnit.abilities[i]:GetCastRange()
					local nAllyList = hMinionUnit:GetNearbyHeroes(nCastRange + 150, false, BOT_MODE_NONE)

					if nAllyList ~= nil and #nAllyList > 0
					then
						for j = 1, #nAllyList
						do
							if J.IsValidTarget(nAllyList[j])
							and J.CanCastOnNonMagicImmune(nAllyList[j])
							and not nAllyList[j]:HasModifier('modifier_ogre_magi_frost_armor')
							then
								hMinionUnit:Action_UseAbilityOnEntity(hMinionUnit.abilities[j], nAllyList[j])
								return
							end
						end
					end
				else
					hMinionUnit.castDesire, hMinionUnitTarget = X.ConsiderUnitTarget(hMinionUnit, hMinionUnit.abilities[i])
					if hMinionUnit.castDesire > 0
					then
						hMinionUnit:Action_UseAbilityOnEntity(hMinionUnit.abilities[i], hMinionUnitTarget)
						return
					end
				end
			elseif X.CheckFlag(hMinionUnit.abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_POINT)
			then
				hMinionUnit.castDesire, loc = X.ConsiderPointTarget(hMinionUnit, hMinionUnit.abilities[i])
				if hMinionUnit.castDesire > 0
				then
					hMinionUnit:Action_UseAbilityOnLocation(hMinionUnit.abilities[i], loc)
					return
				end
			elseif X.CheckFlag(hMinionUnit.abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
			then
				hMinionUnit.castDesire = X.ConsiderNoTarget(hMinionUnit, hMinionUnit.abilities[i])
				if hMinionUnit.castDesire > 0
				then
					hMinionUnit:Action_UseAbility(hMinionUnit.abilities[i])
					return
				end
			end
		end
	end

	hMinionUnit.attackDesire, hMinionUnit.attackTarget = X.ConsiderIllusionAttack(hMinionUnit)
	hMinionUnit.moveDesire, hMinionUnit.moveLocation = X.ConsiderIllusionMove(hMinionUnit)

	if hMinionUnit.attackDesire > 0
	then
		hMinionUnit:Action_AttackUnit(hMinionUnit.attackTarget, false)
		return
	end

	if hMinionUnit.moveDesire > 0
	then
		hMinionUnit:Action_MoveToLocation(hMinionUnit.moveLocation)
		return
	end
end

function X.BrewLinkThink(hMinionUnit)
	if X.IsBusy(hMinionUnit)
	then
		return
	end
	if hMinionUnit.abilities == nil
	then X.InitiateAbility(hMinionUnit)
	end
	for i = 1, #hMinionUnit.abilities
	do
		if X.CanCastAbility(hMinionUnit.abilities[i])
		then
			hMinionUnit.castDesire, hMinionUnit.target, TargetType = X.ConsiderBrewLinkUseAbilities(hMinionUnit, hMinionUnit.abilities[i])
			if hMinionUnit.castDesire > 0
			then
				if TargetType == 'no_target'
				then
					hMinionUnit:Action_UseAbility(hMinionUnit.abilities[i])
					return
				elseif TargetType == 'point'
				then
					hMinionUnit:Action_UseAbilityOnLocation(hMinionUnit.abilities[i], hMinionUnit.target)
					return
				elseif TargetType == 'unit'
				then
					hMinionUnit:Action_UseAbilityOnEntity(hMinionUnit.abilities[i], hMinionUnit.target)
					return
				elseif TargetType == 'tree'
				then
					hMinionUnit:Action_UseAbilityOnTree(hMinionUnit.abilities[i], hMinionUnit.target)
					return
				end
			end
		end
	end

	hMinionUnit.retreatDesire, hMinionUnit.retreatLocation = X.ConsiderBrewLinkRetreat(hMinionUnit)
	hMinionUnit.attackDesire, hMinionUnit.attackTarget = X.ConsiderBrewLinkAttack(hMinionUnit)
	hMinionUnit.moveDesire, hMinionUnit.moveLocation = X.ConsiderBrewLinkMove(hMinionUnit)

	if hMinionUnit.retreatDesire > 0
	then
		hMinionUnit:Action_MoveToLocation(hMinionUnit.retreatLocation)
		return
	end
	if hMinionUnit.attackDesire > 0
	then
		hMinionUnit:Action_AttackUnit(hMinionUnit.attackTarget, false)
		return
	end
	if hMinionUnit.moveDesire > 0
	then
		hMinionUnit:Action_MoveToLocation(hMinionUnit.moveLocation)
		return
	end
end

function X.ConsiderBrewLinkUseAbilities(hMinionUnit, ability)
	if ability:GetName() == 'brewmaster_earth_hurl_boulder'
	then
		local nCastRange = J.GetProperCastRange(false, hMinionUnit, ability:GetCastRange())
		local weakestTarget = J.GetVulnerableWeakestUnit(hMinionUnit, true, true, nCastRange)

		if weakestTarget ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, weakestTarget, 'unit'
		end
	elseif ability:GetName() == 'brewmaster_thunder_clap'
	then
		local nRadius = ability:GetSpecialValueInt("radius")
		local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, nil, 'no_target'
		end
	elseif ability:GetName() == 'brewmaster_drunken_brawler'
	then
		local nAttackRange = hMinionUnit:GetAttackRange()
		local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(nAttackRange, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, nil, 'no_target'
		end
	elseif ability:GetName() == 'brewmaster_storm_dispel_magic'
	then
		local nCastRange = J.GetProperCastRange(false, hMinionUnit, ability:GetCastRange())
		local nAllyHeroes = hMinionUnit:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

		if nAllyHeroes ~= nil then
			for i = 1, #nAllyHeroes
			do
				if J.IsDisabled(nAllyHeroes[i])
				then
					return BOT_ACTION_DESIRE_LOW, nAllyHeroes[i]:GetLocation(), 'point'
				end
			end
		end

		local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil and #nEnemyHeroes == 1
		and nEnemyHeroes[1]:HasModifier("modifier_brewmaster_storm_cyclone")
		then
			return BOT_ACTION_DESIRE_LOW, nEnemyHeroes[1]:GetLocation(), 'point'
		end
	elseif ability:GetName() == 'brewmaster_storm_cyclone'
	then
		local nCastRange = J.GetProperCastRange(false, hMinionUnit, ability:GetCastRange())
		local targetStrongest = J.GetStrongestUnit(nCastRange, hMinionUnit, true, false, 5.0)

		if targetStrongest ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, targetStrongest, 'unit'
		end

		local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		for i = 1, #nEnemyHeroes
		do
			if (J.IsValidTarget(nEnemyHeroes[i]) and nEnemyHeroes[i]:IsChanneling() and J.CanCastOnNonMagicImmune(nEnemyHeroes[i]))
			or (J.IsValidTarget(nEnemyHeroes[i]) and J.IsDisabled(nEnemyHeroes[i]) and J.CanCastOnNonMagicImmune(nEnemyHeroes[i]) )
			then
				return BOT_ACTION_DESIRE_LOW, nEnemyHeroes[i], 'unit'
			end
		end
	elseif ability:GetName() == 'brewmaster_storm_wind_walk'
	then
		local nEnemyLaneCreeps = hMinionUnit:GetNearbyLaneCreeps(1200, true)
		local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

		if #nEnemyLaneCreeps == 0 and #nEnemyHeroes == 0
		then
			return BOT_ACTION_DESIRE_HIGH, nil, 'no_target'
		end
	elseif ability:GetName() == 'brewmaster_cinder_brew'
	then
		local nCastRange = J.GetProperCastRange(false, hMinionUnit, ability:GetCastRange())
		local targetStrongest = J.GetStrongestUnit(nCastRange, hMinionUnit, true, false, 5.0)

		if targetStrongest ~= nil then
			return BOT_ACTION_DESIRE_HIGH, targetStrongest:GetLocation(), 'point'
		end
	elseif ability:GetName() == 'brewmaster_void_astral_pull'
	then
		local nCastRage = J.GetProperCastRange(false, hMinionUnit, ability:GetCastRange())
		local nAllyHeroes = hMinionUnit:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
		local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if J.IsValidTarget(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and (enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero))
			and J.IsInRange(hMinionUnit, enemyHero, nCastRage)
			then
				if nAllyHeroes ~= nil and #nAllyHeroes > 0
				and hMinionUnit:IsFacingLocation(nAllyHeroes[#nAllyHeroes]:GetLocation(), 30)
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit'
				end
			end
		end

		for _, allyHero in pairs(nAllyHeroes)
		do
			if J.IsValidHero(allyHero)
			and allyHero:GetUnitName() == 'npc_dota_brewmaster_earth'
			and J.GetHP(allyHero) < 0.45
			then
				if J.IsInRange(hMinionUnit, allyHero, nCastRage)
				and hMinionUnit:IsFacingLocation(vTeamAncientLoc, 30)
				then
					return BOT_ACTION_DESIRE_HIGH, allyHero, 'unit'
				end
			end
		end
	end

	return BOT_MODE_DESIRE_NONE
end

function X.ConsiderBrewLinkRetreat(hMinionUnit)
	if X.IsBusy(hMinionUnit) or X.CantMove(hMinionUnit)
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nAllyHeroes = hMinionUnit:GetNearbyHeroes(globRadius, false, BOT_MODE_NONE)
	local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(globRadius, true, BOT_MODE_NONE)

	if (nAllyHeroes ~= nil and #nAllyHeroes == 0 and #nEnemyHeroes >= 2)
	or J.GetHP(hMinionUnit) < 0.4
	then
		local loc = J.GetEscapeLoc()

		if hMinionUnit:GetUnitName() ~= 'npc_dota_brewmaster_earth'
		then
			return BOT_ACTION_DESIRE_LOW, loc
		else
			return BOT_ACTION_DESIRE_HIGH, loc
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderBrewLinkAttack(hMinionUnit)
	if X.IsBusy(hMinionUnit) or X.CantAttack(hMinionUnit)
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nUnitList = hMinionUnit:GetNearbyHeroes(globRadius, true, BOT_MODE_NONE)

	if nUnitList == nil or #nUnitList == 0
	then
		nUnitList = hMinionUnit:GetNearbyLaneCreeps(globRadius, true)
	end

	if nUnitList == nil or #nUnitList == 0
	then
		nUnitList = hMinionUnit:GetNearbyTowers(globRadius, true)
	end

	if nUnitList == nil or #nUnitList == 0
	then
		nUnitList = hMinionUnit:GetNearbyBarracks(globRadius, true)
	end

	if nUnitList ~= nil and #nUnitList > 0
	then
		local targetWeakest = X.GetWeakest(nUnitList)

		if targetWeakest ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, targetWeakest
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBrewLinkMove(hMinionUnit)
	if X.CantMove(hMinionUnit)
	then
		return BOT_MODE_DESIRE_NONE, 0
	end

	local nUnitList = hMinionUnit:GetNearbyHeroes(globRadius, true, BOT_MODE_NONE)

	if nUnitList == nil or #nUnitList == 0
	then
		nUnitList = hMinionUnit:GetNearbyLaneCreeps(globRadius, true);
	end

	if nUnitList == nil or #nUnitList == 0
	then
		nUnitList = hMinionUnit:GetNearbyTowers(globRadius, true);
	end

	if nUnitList == nil or #nUnitList == 0
	then
		nUnitList = hMinionUnit:GetNearbyBarracks(globRadius, true);
	end

	if nUnitList ~= nil and #nUnitList > 0
	then
		local targetWeakest = X.GetWeakest(nUnitList)

		if targetWeakest ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, targetWeakest:GetLocation()
		end
	end

	local loc = vTeamAncientLoc
	local distanceToTop = math.max(0, #(GetLaneFrontLocation(GetTeam(), LANE_TOP, 0.0) - bot:GetLocation()))
    local distanceToMid = math.max(0, #(GetLaneFrontLocation(GetTeam(), LANE_MID, 0.0) - bot:GetLocation()))
    local distanceToBot = math.max(0, #(GetLaneFrontLocation(GetTeam(), LANE_BOT, 0.0) - bot:GetLocation()))

	if distanceToTop < distanceToMid and distanceToTop < distanceToBot
	then
		loc = GetLaneFrontLocation(GetTeam(), LANE_TOP, 0.0)
	elseif distanceToMid < distanceToTop and distanceToMid < distanceToBot
	then
		loc = GetLaneFrontLocation(GetTeam(), LANE_MID, 0.0)
	elseif distanceToBot < distanceToTop and distanceToBot < distanceToMid
	then
		loc = GetLaneFrontLocation(GetTeam(), LANE_BOT, 0.0)
	end

	return BOT_MODE_DESIRE_HIGH, loc
end

function X.AttackWardThink(hMinionUnit)
	if hMinionUnit:GetUnitName() == 'npc_dota_venomancer_plague_ward_1'
	or hMinionUnit:GetUnitName() == 'npc_dota_venomancer_plague_ward_2'
	or hMinionUnit:GetUnitName() == 'npc_dota_venomancer_plague_ward_3'
	or hMinionUnit:GetUnitName() == 'npc_dota_venomancer_plague_ward_4'
	then
		local nUnits = hMinionUnit:GetNearbyHeroes(bot:GetAttackRange(), true, BOT_MODE_NONE)

		local target = nil
		local hp = 100000
		for _, enemyHero in pairs(nUnits)
		do
			if  J.IsValidHero(enemyHero)
			and hp > enemyHero:GetHealth()
			then
				hp = enemyHero:GetHealth()
				target = enemyHero
			end
		end

		if target ~= nil
		then
			hMinionUnit:Action_AttackUnit(target, false)
			return
		end

		nUnits = bot:GetNearbyCreeps(bot:GetAttackRange(), true)
		for _, creep in pairs(nUnits)
		do
			if  J.IsValid(creep)
			and J.CanBeAttacked(creep)
			then
				hMinionUnit:Action_AttackUnit(creep, false)
				return
			end
		end

		nUnits = bot:GetNearbyTowers(bot:GetAttackRange(), true)
		for _, tower in pairs(nUnits)
		do
			if J.IsValidBuilding(tower)
			then
				hMinionUnit:Action_AttackUnit(tower, false)
				return
			end
		end
	end
end

-- MINION THINK
function X.MinionThink(hMinionUnit)
	if hMinionUnit.lastMinionFrameProcessTime == nil then hMinionUnit.lastMinionFrameProcessTime = DotaTime() end
	if DotaTime() - hMinionUnit.lastMinionFrameProcessTime < 0.1 then return end
	hMinionUnit.lastMinionFrameProcessTime = DotaTime()

	if X.IsValidUnit(hMinionUnit)
	then
		if J.IsValidHero(hMinionUnit)
		and hMinionUnit:IsIllusion()
		and hMinionUnit:GetUnitName() ~= 'npc_dota_hero_vengefulspirit'
		then
			X.IllusionThink(hMinionUnit)
		elseif X.IsAttackingWard(hMinionUnit:GetUnitName())
		then
			X.AttackWardThink(hMinionUnit)
		elseif X.CantBeControlled(hMinionUnit:GetUnitName())
		then
			X.CantBeControlledThink(hMinionUnit)
		elseif X.IsMinionWithNoSkill(hMinionUnit:GetUnitName())
		then
			X.IllusionThink(hMinionUnit)
		elseif X.IsMinionWithSkill(hMinionUnit:GetUnitName())
		then
			X.MinionWithSkillThink(hMinionUnit)
		elseif X.IsBrewLink(hMinionUnit:GetUnitName())
		then
			X.BrewLinkThink(hMinionUnit)
		elseif X.IsFamiliar(hMinionUnit:GetUnitName())
		then
			SU.FamiliarThink(bot, hMinionUnit)
		end
	end
end

return X