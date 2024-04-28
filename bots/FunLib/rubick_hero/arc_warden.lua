local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local Flux
local MagneticField
local SparkWraith
-- local TempestDouble

local botTarget

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

    if abilityName == 'arc_warden_flux'
    then
        Flux = ability
        FluxDesire, FluxTarget = X.ConsiderFlux()
        if FluxDesire > 0
        then
            bot:Action_UseAbilityOnEntity(Flux, FluxTarget)
            return
        end
    end

    if abilityName == 'arc_warden_magnetic_field'
    then
        MagneticField = ability
        MagneticFieldDesire, MagneticFieldLocation = X.ConsiderMagneticField()
        if MagneticFieldDesire > 0
        then
            bot:Action_UseAbilityOnLocation(MagneticField, MagneticFieldLocation)
            return
        end
    end

    if abilityName == 'arc_warden_spark_wraith'
    then
        SparkWraith = ability
        SparkWraithDesire, SparkWraithLocation = X.ConsiderSparkWraith()
        if SparkWraithDesire > 0
        then
            bot:Action_UseAbilityOnLocation(SparkWraith, SparkWraithLocation)
            return
        end
    end
end

function X.ConsiderFlux()
	if not Flux:IsFullyCastable() then return 0	end

	local nCastRange = J.GetProperCastRange(false, bot, Flux:GetCastRange())
	local nDot = Flux:GetSpecialValueInt( "damage_per_second" )
	local nDuration = Flux:GetSpecialValueInt( "duration" )
	local nDamage = nDot * nDuration

	if J.IsValidHero( botTarget )
		and J.CanCastOnNonMagicImmune( botTarget )
		and J.CanCastOnTargetAdvanced( botTarget )
		and J.CanKillTarget( botTarget, nDamage, DAMAGE_TYPE_MAGICAL )
		and J.IsInRange( botTarget, bot, nCastRange )
	then
		return BOT_ACTION_DESIRE_HIGH, botTarget
	end


	if J.IsInTeamFight( bot, 1200 )
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL )
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage
					npcMostDangerousEnemy = npcEnemy
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy
		end
	end

	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		if J.IsRoshan( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_LOW, botTarget
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 40 )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end


	if J.IsRetreating( bot )
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
		local nEnemyHeroes = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE )
		local npcEnemy = tableNearbyEnemyHeroes[1]
		if J.IsValid( npcEnemy )
			and ( bot:IsFacingLocation( npcEnemy:GetLocation(), 10 ) or #nEnemyHeroes <= 1 )
			and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderMagneticField()
	if not MagneticField:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = MagneticField:GetSpecialValueInt( "radius" )
	local nCastRange = J.GetProperCastRange(false, bot, MagneticField:GetCastRange())

	if J.IsRetreating( bot )
		and not bot:HasModifier( "modifier_arc_warden_magnetic_field" )
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid( npcEnemy ) and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, bot:GetLocation()
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and not bot:HasModifier( "modifier_arc_warden_magnetic_field" )
	then
		local botTarget = bot:GetAttackTarget()
		if ( J.IsRoshan( botTarget ) and J.CanCastOnMagicImmune( botTarget ) and J.IsInRange( botTarget, bot, nCastRange ) )
		then
			return BOT_ACTION_DESIRE_LOW, bot:GetLocation()
		end
	end

	if bot:GetActiveMode() == BOT_MODE_FARM
		and not bot:HasModifier( "modifier_arc_warden_magnetic_field" )
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 600, nRadius, 0, 0 )
		if ( locationAoE.count >= 3 ) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then
		local locationAoE = bot:FindAoELocation( false, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
		if ( locationAoE.count >= 2 ) then
			local targetAllies = J.GetAlliesNearLoc( locationAoE.targetloc, nRadius )
			if J.IsValidHero( targetAllies[1] )
				and not targetAllies[1]:HasModifier( "modifier_arc_warden_magnetic_field" )
				and targetAllies[1]:GetAttackTarget() ~= nil
				and GetUnitToUnitDistance( targetAllies[1], targetAllies[1]:GetAttackTarget() ) <= targetAllies[1]:GetAttackRange() + 50
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
			end
		end
	end

	if J.IsDefending( bot ) or J.IsPushing( bot ) and not bot:HasModifier( "modifier_arc_warden_magnetic_field" )
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( 800, true )
		local tableNearbyEnemyTowers = bot:GetNearbyTowers( 800, true )
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 )
			or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 )
		then
			return BOT_ACTION_DESIRE_LOW, bot:GetLocation()
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		local botTarget = bot:GetTarget()
		if J.IsValidHero( botTarget ) and  J.IsInRange( botTarget, bot, nCastRange )
		then
			local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK )
			for _, npcAlly in pairs( tableNearbyAttackingAlliedHeroes )
			do
				if J.IsValid( npcAlly )
					and ( J.IsInRange( npcAlly, bot, nCastRange ) and not npcAlly:HasModifier( "modifier_arc_warden_magnetic_field" ) )
					and ( J.IsValid( npcAlly:GetAttackTarget() ) and GetUnitToUnitDistance( npcAlly, npcAlly:GetAttackTarget() ) <= npcAlly:GetAttackRange() )
				then
					return BOT_ACTION_DESIRE_MODERATE, npcAlly:GetLocation()
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderSparkWraith()
	if not SparkWraith:IsFullyCastable() then	return 0 end

	local nRadius = SparkWraith:GetSpecialValueInt( "radius" )
	local nCastRange = J.GetProperCastRange(false, bot, SparkWraith:GetCastRange())
	local nDamage = SparkWraith:GetSpecialValueInt( "spark_damage" )
	local nDelay = SparkWraith:GetSpecialValueInt( "activation_delay" ) + 0.1

	if J.IsValidHero( botTarget )
		and J.CanCastOnNonMagicImmune( botTarget )
	then
		if J.CanKillTarget( botTarget, nDamage, DAMAGE_TYPE_MAGICAL )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_MODERATE, botTarget:GetExtrapolatedLocation( nDelay )
		end
	end


	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		local botTarget = bot:GetAttackTarget()
		if J.IsRoshan( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.GetHP( botTarget ) > 0.2
		then
			return BOT_ACTION_DESIRE_LOW, botTarget:GetLocation()
		end
	end


	if J.IsInTeamFight( bot, 1200 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1000, nRadius, 0, 0 )
		if locationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end


	if J.IsGoingOnSomeone( bot )
	then

		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_MODERATE, botTarget:GetExtrapolatedLocation( nDelay )
		end

		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1400, nRadius, 2.0, 0 )
		if locationAoE.count >= 1
			and not bot:HasModifier( "modifier_silencer_curse_of_the_silent" )
		then
			local nCreep = J.GetVulnerableUnitNearLoc( bot, false, true, 1600, nRadius, locationAoE.targetloc )
			if nCreep == nil
				or bot:HasModifier( "modifier_arc_warden_tempest_double" )
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
			end
		end

	end

	if J.IsRetreating( bot )
		and bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_HIGH
		and not bot:HasModifier( "modifier_silencer_curse_of_the_silent" )
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid( npcEnemy ) and bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_FARM
		or J.IsPushing( bot )
		or J.IsDefending( bot )
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1400, nRadius, 2.0, 0 )
		if locationAoE.count > 2
			and not bot:HasModifier( "modifier_silencer_curse_of_the_silent" )
		then
			if bot:HasModifier( "modifier_arc_warden_tempest_double" )
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
			end

			local nLaneCreeps = bot:GetNearbyLaneCreeps( 1400, true )
			if #nLaneCreeps >= 2
			then
				if J.GetMP( bot ) > 0.62
				then
					return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
				end
			else
				if J.GetMP( bot ) > 0.75
				then
					return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
				end
			end
		end

	end


	if SparkWraith:GetLevel() >= 3 and bot:GetActiveMode() ~= BOT_MODE_LANING and J.IsAllowedToSpam( bot, 80 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1400, nRadius, 2.0, 0 )
		if locationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end


	if bot:GetLevel() >= 10
		and ( J.IsAllowedToSpam( bot, 80 ) or bot:HasModifier( "modifier_arc_warden_tempest_double" ) )
		and DotaTime() > 8 * 60
	then

		local nEnemysHerosCanSeen = GetUnitList( UNIT_LIST_ENEMY_HEROES )
		local nTargetHero = nil
		local nTargetHeroHealth = 99999
		for _, enemy in pairs( nEnemysHerosCanSeen )
		do
			if J.IsValidHero( enemy )
				and GetUnitToUnitDistance( bot, enemy ) <= nCastRange
				and enemy:GetHealth() < nTargetHeroHealth
			then
				nTargetHero = enemy
				nTargetHeroHealth = enemy:GetHealth()
			end
		end
		if nTargetHero ~= nil
		then
			for i=0, 350, 50
			do
				local castLocation = J.GetLocationTowardDistanceLocation( nTargetHero, J.GetEnemyFountain(), 350 - i )
				if GetUnitToLocationDistance( bot, castLocation ) <= nCastRange
				then
					return BOT_ACTION_DESIRE_MODERATE, castLocation
				end
			end
		end


		local nLaneCreeps = bot:GetNearbyLaneCreeps( 1600, true )
		if #nLaneCreeps >= 3
		then
			local targetCreep = nLaneCreeps[#nLaneCreeps]
			if J.IsValid( targetCreep )
			then
				local castLocation = J.GetFaceTowardDistanceLocation( targetCreep, 375 )
				return BOT_ACTION_DESIRE_MODERATE , castLocation
			end
		end

		local nEnemyHeroesInView = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
		local nEnemyLaneFront = J.GetNearestLaneFrontLocation( bot:GetLocation(), true, nRadius/2 )
		if #nEnemyHeroesInView == 0 and nEnemyLaneFront ~= nil
			and GetUnitToLocationDistance( bot, nEnemyLaneFront ) <= nCastRange + nRadius
			and GetUnitToLocationDistance( bot, nEnemyLaneFront ) >= 800
		then
			local castLocation = J.GetLocationTowardDistanceLocation( bot, nEnemyLaneFront, nCastRange )
			if GetUnitToLocationDistance( bot, nEnemyLaneFront ) < nCastRange
			then
				castLocation = nEnemyLaneFront
			end
			return BOT_ACTION_DESIRE_MODERATE , castLocation
		end
	end


	local castLocation = J.GetLocationTowardDistanceLocation( bot, J.GetEnemyFountain(), nCastRange )
	if bot:HasModifier( "modifier_arc_warden_tempest_double" )
		or ( J.GetMP( bot ) > 0.92 and bot:GetLevel() > 11 and not IsLocationVisible( castLocation ) )
		or ( J.GetMP( bot ) > 0.38 and J.GetDistanceFromEnemyFountain( bot ) < 4300 )
	then
		if IsLocationPassable( castLocation )
			and not bot:HasModifier( "modifier_silencer_curse_of_the_silent" )
		then
			return BOT_ACTION_DESIRE_MODERATE, castLocation
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

return X