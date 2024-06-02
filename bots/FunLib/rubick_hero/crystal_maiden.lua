local bot
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local CrystalNova
local Frostbite
local CrystalClone
local FreezingField

local nKeepMana, nMP, nHP, nLV
local amuletTime = 0

local botTarget

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

    nKeepMana = 220
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	nLV = bot:GetLevel()

    X.ConsiderCombo()

    if abilityName == 'crystal_maiden_crystal_clone'
    then
		CrystalClone = ability
        CrystalCloneDesire = X.ConsiderCrystalClone()
        if CrystalCloneDesire > 0
        then
            bot:Action_UseAbility(CrystalClone)
            return
        end
    end

    if abilityName == 'crystal_maiden_crystal_nova'
    then
		CrystalNova = ability
        CrystalNovaDesire, CrystalNovaLocation = X.ConsiderCrystalNova()
        if CrystalNovaDesire > 0
        then
            bot:Action_UseAbilityOnLocation(CrystalNova, CrystalNovaLocation)
            return
        end
    end

    if abilityName == 'crystal_maiden_frostbite'
    then
		Frostbite = ability
        FrostbiteDesire, FrostbiteTarget = X.ConsiderFrostbite()
        if FrostbiteDesire > 0
        then
            bot:Action_UseAbilityOnEntity(Frostbite, FrostbiteTarget )
            return
        end
    end

    if abilityName == 'crystal_maiden_freezing_field'
    then
		FreezingField = ability
        FreezingFieldDesire = X.ConsiderFreezingField()
        if FreezingFieldDesire > 0
        then
            bot:Action_UseAbility(FreezingField)
            return
        end
    end
end

function X.ConsiderCombo()
	if bot:IsAlive()
		and bot:IsChanneling()
		and not bot:IsInvisible()
	then
		local nEnemyTowers = bot:GetNearbyTowers( 880, true )

		if nEnemyTowers[1] ~= nil then return end

		local amulet = J.IsItemAvailable( 'item_shadow_amulet' )
		if amulet~=nil and amulet:IsFullyCastable() and amuletTime < DotaTime()- 10
		then
			amuletTime = DotaTime()
			bot:Action_UseAbilityOnEntity( amulet, bot )
			return
		end

		if not bot:HasModifier( 'modifier_teleporting' )
		then
			local glimer = J.IsItemAvailable( 'item_glimmer_cape' )
			if glimer ~= nil and glimer:IsFullyCastable()
			then
				bot:Action_UseAbilityOnEntity( glimer, bot )
				return
			end

			local invissword = J.IsItemAvailable( 'item_invis_sword' )
			if invissword ~= nil and invissword:IsFullyCastable()
			then
				bot:Action_UseAbility( invissword )
				return
			end

			local silveredge = J.IsItemAvailable( 'item_silver_edge' )
			if silveredge ~= nil and silveredge:IsFullyCastable()
			then
				bot:Action_UseAbility( silveredge )
				return
			end
		end
	end
end

function X.ConsiderCrystalNova()


	if not CrystalNova:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = CrystalNova:GetSpecialValueInt( 'radius' )
	local nCastRange = J.GetProperCastRange(false, bot, CrystalNova:GetCastRange())
	local nDamage = CrystalNova:GetSpecialValueInt( 'nova_damage' )
	local nSkillLV = CrystalNova:GetLevel()

	local nAllys =  J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE )

	local nEnemysHeroesInRange = J.GetNearbyHeroes(bot, nCastRange + nRadius, true, BOT_MODE_NONE )
	local nEnemysHeroesInBonus = J.GetNearbyHeroes(bot, nCastRange + nRadius + 150, true, BOT_MODE_NONE )
	local nEnemysHeroesInView = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	local nWeakestEnemyHeroInRange, nWeakestEnemyHeroHealth1 = X.cm_GetWeakestUnit( nEnemysHeroesInRange )
	local nWeakestEnemyHeroInBonus, nWeakestEnemyHeroHealth2 = X.cm_GetWeakestUnit( nEnemysHeroesInBonus )

	local nEnemysLaneCreeps1 = bot:GetNearbyLaneCreeps( nCastRange + nRadius, true )
	local nEnemysLaneCreeps2 = bot:GetNearbyLaneCreeps( nCastRange + nRadius + 200, true )
	local nEnemysWeakestLaneCreeps1, nEnemysWeakestLaneCreepsHealth1 = X.cm_GetWeakestUnit( nEnemysLaneCreeps1 )
	local nEnemysWeakestLaneCreeps2, nEnemysWeakestLaneCreepsHealth2 = X.cm_GetWeakestUnit( nEnemysLaneCreeps2 )

	local nTowers = bot:GetNearbyTowers( 1000, true )

	local nCanKillHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0.8, nDamage )
	local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0.8, 0 )
	local nCanKillCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange + nRadius, nRadius, 0.5, nDamage )
	local nCanHurtCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange + nRadius, nRadius, 0.5, 0 )

	if nCanKillHeroLocationAoE.count ~= nil
		and nCanKillHeroLocationAoE.count >= 1
	then
		if J.IsValid( nWeakestEnemyHeroInBonus )
		then
			local nTargetLocation = J.GetCastLocation( bot, nWeakestEnemyHeroInBonus, nCastRange, nRadius )
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_LANING
		and #nTowers <= 0
		and nHP >= 0.4
	then
		if nCanHurtHeroLocationAoE.count >= 2
			and GetUnitToLocationDistance( bot, nCanHurtHeroLocationAoE.targetloc ) <= nCastRange + 50
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc
		end
	end

	if bot:GetActiveMode() == BOT_MODE_RETREAT
		and bot:WasRecentlyDamagedByAnyHero( 2.0 )
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 300, nRadius, 0.8, 0 )
		if nCanHurtHeroLocationAoENearby.count >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc
		end
	end

	if J.IsGoingOnSomeone( bot )
	then

		if J.IsValid( nWeakestEnemyHeroInBonus )
			and nCanHurtHeroLocationAoE.count >= 2
			and GetUnitToLocationDistance( bot, nCanHurtHeroLocationAoE.targetloc ) <= nCastRange
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc
		end

		local npcEnemy = J.GetProperTarget( bot )
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then

			if nMP > 0.75
				or bot:GetMana() > nKeepMana * 2
			then
				local nTargetLocation = J.GetCastLocation( bot, npcEnemy, nCastRange, nRadius )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation
				end
			end

			if ( npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.4 )
				and GetUnitToUnitDistance( npcEnemy, bot ) <= nRadius + nCastRange
			then
				local nTargetLocation = J.GetCastLocation( bot, npcEnemy, nCastRange, nRadius )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation
				end
			end

		end

		npcEnemy = nWeakestEnemyHeroInRange
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.4 )
			and GetUnitToUnitDistance( npcEnemy, bot ) <= nRadius + nCastRange
		then
			local nTargetLocation = J.GetCastLocation( bot, npcEnemy, nCastRange, nRadius )
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end
		end

		if 	J.IsValid( nEnemysWeakestLaneCreeps2 )
			and nCanHurtCreepsLocationAoE.count >= 5
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc
		end

		if nCanKillCreepsLocationAoE.count >= 3
			and ( J.IsValid( nEnemysWeakestLaneCreeps1 ) or nLV >= 25 )
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc
		end
	end

	if bot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		if J.IsValid( nWeakestEnemyHeroInBonus )
        and nWeakestEnemyHeroInBonus ~= nil
		then

			if nCanHurtHeroLocationAoE.count >= 3
				and GetUnitToLocationDistance( bot, nCanHurtHeroLocationAoE.targetloc ) <= nCastRange
			then
				return BOT_ACTION_DESIRE_VERYHIGH, nCanHurtHeroLocationAoE.targetloc
			end

			if nCanHurtHeroLocationAoE.count >= 2
				and GetUnitToLocationDistance( bot, nCanHurtHeroLocationAoE.targetloc ) <= nCastRange
				and bot:GetMana() > nKeepMana
			then
				return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc
			end

			if J.IsValid( nWeakestEnemyHeroInBonus )
			then
				if nMP > 0.8
					or bot:GetMana() > nKeepMana * 2
				then
					local nTargetLocation = J.GetCastLocation( bot, nWeakestEnemyHeroInBonus, nCastRange, nRadius )
					if nTargetLocation ~= nil
					then
						return BOT_ACTION_DESIRE_HIGH, nTargetLocation
					end
				end

				if ( nWeakestEnemyHeroInBonus:GetHealth()/nWeakestEnemyHeroInBonus:GetMaxHealth() < 0.4 )
					and GetUnitToUnitDistance( nWeakestEnemyHeroInBonus, bot ) <= nRadius + nCastRange
				then
					local nTargetLocation = J.GetCastLocation( bot, nWeakestEnemyHeroInBonus, nCastRange, nRadius )
					if nTargetLocation ~= nil
					then
						return BOT_ACTION_DESIRE_HIGH, nTargetLocation
					end
				end
			end
		end
	end


	if J.IsFarming( bot )
		and nSkillLV >= 3
	then

		if nCanKillCreepsLocationAoE.count >= 2
			and J.IsValid( nEnemysWeakestLaneCreeps1 )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc
		end

		if nCanHurtCreepsLocationAoE.count >= 4
			and J.IsValid( nEnemysWeakestLaneCreeps1 )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc
		end

	end

	if #nAllys <= 2 and nSkillLV >= 3
		and ( J.IsPushing( bot ) or J.IsDefending( bot ) )
	then

		if nCanHurtCreepsLocationAoE.count >= 4
			and  J.IsValid( nEnemysWeakestLaneCreeps1 )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc
		end

		if nCanKillCreepsLocationAoE.count >= 2
			and J.IsValid( nEnemysWeakestLaneCreeps1 )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc
		end
	end


	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 400
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsRoshan( npcTarget )
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
		end
	end

	if J.IsDoingTormentor(bot)
		and bot:GetMana() >= 400
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsTormentor(npcTarget)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
		end
	end

	local nNeutarlCreeps = bot:GetNearbyNeutralCreeps( nCastRange + nRadius )
	if J.IsValid( nNeutarlCreeps[1] )
	then
		for _, creep in pairs( nNeutarlCreeps )
		do
			if J.IsValid( creep )
				and creep:HasModifier( 'modifier_crystal_maiden_frostbite' )
				and creep:GetHealth()/creep:GetMaxHealth() > 0.3
				and ( creep:GetUnitName() == 'npc_dota_neutral_dark_troll_warlord'
					or creep:GetUnitName() == 'npc_dota_neutral_satyr_hellcaller'
					or creep:GetUnitName() == 'npc_dota_neutral_polar_furbolg_ursa_warrior' )
			then
				local nTargetLocation = J.GetCastLocation( bot, creep, nCastRange, nRadius )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation
				end
			end
		end
	end

	if #nEnemysHeroesInView == 0
		and not J.IsGoingOnSomeone( bot )
		and nSkillLV > 2
	then

		if nCanKillCreepsLocationAoE.count >= 2
			and ( nEnemysWeakestLaneCreeps2 ~= nil or nLV == 25 )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc
		end

		if nCanHurtCreepsLocationAoE.count >= 4
			and nEnemysWeakestLaneCreeps2 ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc
		end

	end

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderFrostbite()

	if not Frostbite:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, Frostbite:GetCastRange())
	local nCastPoint = Frostbite:GetCastPoint()
	local nSkillLV = Frostbite:GetLevel()
	local nDamage = ( 100 + nSkillLV * 50 )

	local nAllies =  J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE )

	local nEnemysHeroesInView = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	if #nEnemysHeroesInView <= 1 and nCastRange < bot:GetAttackRange() then nCastRange = bot:GetAttackRange() + 60 end
	local nEnemysHeroesInRange = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local nEnemysHeroesInBonus = J.GetNearbyHeroes(bot, nCastRange + 200, true, BOT_MODE_NONE )

	local nWeakestEnemyHeroInRange, nWeakestEnemyHeroHealth1 = X.cm_GetWeakestUnit( nEnemysHeroesInRange )
	local nWeakestEnemyHeroInBonus, nWeakestEnemyHeroHealth2 = X.cm_GetWeakestUnit( nEnemysHeroesInBonus )

	local nEnemysCreeps1 = bot:GetNearbyCreeps( nCastRange + 100, true )
	local nEnemysCreeps2 = bot:GetNearbyCreeps( 1400, true )

	local nEnemysStrongestCreeps1, nEnemysStrongestCreepsHealth1 = X.cm_GetStrongestUnit( nEnemysCreeps1 )
	local nEnemysStrongestCreeps2, nEnemysStrongestCreepsHealth2 = X.cm_GetStrongestUnit( nEnemysCreeps2 )

	local nTowers = bot:GetNearbyTowers( 900, true )

	if J.IsValid( nWeakestEnemyHeroInRange )
		and J.CanCastOnTargetAdvanced( nWeakestEnemyHeroInRange )
	then
		if J.WillMagicKillTarget( bot, nWeakestEnemyHeroInRange, nDamage, nCastPoint )
		then
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange
		end
	end

	for _, npcEnemy in pairs( nEnemysHeroesInBonus )
	do
		if J.IsValid( npcEnemy )
			and npcEnemy:IsChanneling()
			and npcEnemy:HasModifier( 'modifier_teleporting' )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end

	if J.IsInTeamFight( bot, 1200 )
		and  DotaTime() > 6 * 60
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL )
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage
					npcMostDangerousEnemy = npcEnemy
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy
		end

	end

	if bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and #nEnemysHeroesInRange >= 1
	then
		for _, npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 45 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_LANING and #nTowers == 0
	then
		if( nMP > 0.5 or bot:GetMana()> nKeepMana )
		then
			if J.IsValid( nWeakestEnemyHeroInRange )
				and not J.IsDisabled( nWeakestEnemyHeroInRange )
			then
				return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange
			end
		end

		if( nMP > 0.78 or bot:GetMana()> nKeepMana )
		then
			if J.IsValid( nWeakestEnemyHeroInBonus )
            and nWeakestEnemyHeroInBonus ~= nil
				and nHP > 0.6
				and #nTowers == 0
				and #nEnemysCreeps2 + #nEnemysHeroesInBonus <= 5
				and not J.IsDisabled( nWeakestEnemyHeroInBonus )
				and nWeakestEnemyHeroInBonus:GetCurrentMovementSpeed() < bot:GetCurrentMovementSpeed()
			then
				return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInBonus
			end
		end


		if J.IsValid( nEnemysHeroesInView[1] )
		then
			if J.GetAllyUnitCountAroundEnemyTarget( bot, nEnemysHeroesInView[1], 350 ) >= 5
				and not J.IsDisabled( nEnemysHeroesInView[1] )
				and not nEnemysHeroesInView[1]:IsMagicImmune()
				and nHP > 0.7
				and bot:GetMana()> nKeepMana
				and #nEnemysCreeps2 + #nEnemysHeroesInBonus <= 3
				and #nTowers == 0
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInView[1]
			end
		end

		if J.IsValid( nWeakestEnemyHeroInRange )
        and nWeakestEnemyHeroInRange ~= nil
		then
			if nWeakestEnemyHeroInRange:GetHealth()/nWeakestEnemyHeroInRange:GetMaxHealth() < 0.5
			then
				return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange
			end
		end
	end

	if nEnemysHeroesInRange[1] == nil
		and nEnemysCreeps1[1] ~= nil
	then
		for _, EnemyplayerCreep in pairs( nEnemysCreeps1 )
		do
			if J.IsValid( EnemyplayerCreep )
				and EnemyplayerCreep:GetTeam() == GetOpposingTeam()
				and EnemyplayerCreep:GetHealth() > 460
				and not EnemyplayerCreep:IsMagicImmune()
				and not EnemyplayerCreep:IsInvulnerable()
				and ( EnemyplayerCreep:IsDominated() or EnemyplayerCreep:IsMinion() )
			then
				return BOT_ACTION_DESIRE_HIGH, EnemyplayerCreep
			end
		end
	end

	if bot:GetActiveMode() ~= BOT_MODE_LANING
		and  bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and  bot:GetActiveMode() ~= BOT_MODE_ATTACK
		and  #nEnemysHeroesInView == 0
		and  #nAllies < 3
		and  nLV >= 5
	then

		if J.IsValid( nEnemysStrongestCreeps2 )
        and nEnemysStrongestCreeps2 ~= nil
			and ( DotaTime() > 10 * 60
				or ( nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_badguys_melee'
					and nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_badguys_ranged'
					and nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_goodguys_melee'
					and nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_goodguys_ranged' ) )
		then
			if ( nEnemysStrongestCreepsHealth2 > 460 or ( nEnemysStrongestCreepsHealth1 > 390 and nMP > 0.45 ) )
				and nEnemysStrongestCreepsHealth2 <= 1200
			then
				return BOT_ACTION_DESIRE_LOW, nEnemysStrongestCreeps2
			end
		end

		if J.IsValid( nEnemysStrongestCreeps1 )
        and nEnemysStrongestCreeps1 ~= nil
			and ( DotaTime() > 10 * 60
				or ( nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_badguys_melee'
					and nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_badguys_ranged'
					and nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_goodguys_melee'
					and nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_goodguys_ranged' ) )
		then
			if ( nEnemysStrongestCreepsHealth1 > 410 or ( nEnemysStrongestCreepsHealth1 > 360 and nMP > 0.45 ) )
				and nEnemysStrongestCreepsHealth1 <= 1200
			then
				return BOT_ACTION_DESIRE_LOW, nEnemysStrongestCreeps1
			end
		end

	end

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.CanCastOnTargetAdvanced( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 50 )
			and not J.IsDisabled( npcTarget )
			and not npcTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end


	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and J.IsInRange( npcEnemy, bot, nCastRange - 80 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end


	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 400
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsRoshan( npcTarget )
			and not J.IsDisabled( npcTarget )
			and not npcTarget:IsDisarmed()
			and J.IsInRange( npcTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end


	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderFreezingField()

	if not FreezingField:IsFullyCastable()
		or bot:DistanceFromFountain() < 300
	then
		return BOT_ACTION_DESIRE_NONE
	end


	local nRadius = FreezingField:GetAOERadius() * 0.88

	local nAllies =  J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE )

	local nEnemysHeroesInRange = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	local nWeakestEnemyHeroInRange, nWeakestEnemyHeroHealth1 = X.cm_GetWeakestUnit( nEnemysHeroesInRange )


	local aoeCanHurtCount = 0
	for _, enemy in pairs ( nEnemysHeroesInRange )
	do
		if J.IsValid( enemy )
			and J.CanCastOnNonMagicImmune( enemy )
			and ( J.IsDisabled( enemy )
				  or J.IsInRange( bot, enemy, nRadius * 0.82 - enemy:GetCurrentMovementSpeed() ) )
		then
			aoeCanHurtCount = aoeCanHurtCount + 1
		end
	end
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT
		or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() <= 0.85 )
	then
		if ( #nEnemysHeroesInRange >= 3 or aoeCanHurtCount >= 2 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and ( J.IsDisabled( npcTarget ) or J.IsInRange( bot, npcTarget, 280 ) )
			and npcTarget:GetHealth() <= npcTarget:GetActualIncomingDamage( bot:GetOffensivePower() * 1.5, DAMAGE_TYPE_MAGICAL )
			and GetUnitToUnitDistance( npcTarget, bot ) <= nRadius
			and npcTarget:GetHealth() > 400
			and #nAllies <= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating( bot ) and nHP > 0.38
	then
		local nEnemysHeroesNearby = J.GetNearbyHeroes(bot, 500, true, BOT_MODE_NONE )
		local nEnemysHeroesFurther = J.GetNearbyHeroes(bot, 1300, true, BOT_MODE_NONE )
		local npcTarget = nEnemysHeroesNearby[1]
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and not abilityQ:IsFullyCastable()
			and not abilityW:IsFullyCastable()
			and nHP > 0.38 * #nEnemysHeroesFurther
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderCrystalClone()
	if not CrystalClone:IsTrained()
	or not CrystalClone:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRange = bot:GetAttackRange()

	if J.IsRetreating(bot)
	and not J.IsRealInvisible(bot)
	and not bot:IsFacingLocation(GetAncient(GetTeam()):GetLocation(), 45)
	and not J.IsRealInvisible(bot)
	and bot:DistanceFromFountain() > 600
	and bot:WasRecentlyDamagedByAnyHero(4.0)
	then
		return BOT_ACTION_DESIRE_MODERATE
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.IsInRange(bot, botTarget, nRange - 150)
		and J.CanCastOnNonMagicImmune(botTarget)
		and bot:IsFacingLocation(botTarget:GetLocation(), 30)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.cm_GetWeakestUnit( nEnemyUnits )

	local nWeakestUnit = nil
	local nWeakestUnitLowestHealth = 10000
	for _, unit in pairs( nEnemyUnits )
	do
		if 	J.CanCastOnNonMagicImmune( unit )
		then
			if unit:GetHealth() < nWeakestUnitLowestHealth
			then
				nWeakestUnitLowestHealth = unit:GetHealth()
				nWeakestUnit = unit
			end
		end
	end

	return nWeakestUnit, nWeakestUnitLowestHealth
end

function X.cm_GetStrongestUnit( nEnemyUnits )

	local nStrongestUnit = nil
	local nStrongestUnitHealth = GetBot():GetAttackDamage()

	for _, unit in pairs( nEnemyUnits )
	do
		if 	unit ~= nil and unit:IsAlive()
			and not unit:HasModifier( 'modifier_fountain_glyph' )
			and not unit:IsIllusion()
			and not unit:IsMagicImmune()
			and not unit:IsInvulnerable()
			and unit:GetHealth() <= 1100
			and not unit:IsAncientCreep()
			and unit:GetMagicResist() < 1.05 - unit:GetHealth()/1100
			and not unit:WasRecentlyDamagedByAnyHero( 2.5 )
			and not J.IsOtherAllysTarget( unit )
			and string.find( unit:GetUnitName(), 'siege' ) == nil
			and ( nLV < 25 or unit:GetTeam() == TEAM_NEUTRAL )
		then
			if string.find( unit:GetUnitName(), 'ranged' ) ~= nil
				and unit:GetHealth() > GetBot():GetAttackDamage() * 2
			then
				return unit, 500
			end

			if unit:GetHealth() > nStrongestUnitHealth
			then
				nStrongestUnitHealth = unit:GetHealth()
				nStrongestUnit = unit
			end
		end
	end

	return nStrongestUnit, nStrongestUnitHealth
end


return X