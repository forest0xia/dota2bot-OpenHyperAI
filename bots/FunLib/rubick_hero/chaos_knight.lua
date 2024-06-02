local bot
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local ChaosBolt
local RealityRift
local Phantasm

local nHP, hEnemyHeroList

local botTarget

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )

    if abilityName == 'chaos_knight_phantasm'
    then
        Phantasm = ability
        PhantasmDesire = X.ConsiderPhantasm()
        if PhantasmDesire > 0
        then
            bot:ActionQueue_UseAbility(Phantasm)
            return
        end
    end

    if abilityName == 'chaos_knight_reality_rift'
    then
        RealityRift = ability
        RealityRiftDesire, RealityRiftTarget = X.ConsiderRealityRift()
        if RealityRiftDesire > 0
        then
            bot:Action_UseAbilityOnEntity(RealityRift, RealityRiftTarget)
            return
        end
    end

    if abilityName == 'chaos_knight_chaos_bolt'
    then
        ChaosBolt = ability
        ChaosBoltDesire, ChaosBoltTarget = X.ConsiderChaosBolt()
        if ChaosBoltDesire > 0
        then
            bot:Action_UseAbilityOnEntity(ChaosBolt, ChaosBoltTarget)
            return
        end
    end
end

function X.ConsiderChaosBolt()

	if not ChaosBolt:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = J.GetProperCastRange(false, bot, ChaosBolt:GetCastRange())
	local nSkillLV = ChaosBolt:GetLevel()
	local nDamage = 30 + nSkillLV * 30 + 120 * 0.38

	local nEnemysHeroesInCastRange = J.GetNearbyHeroes(bot, nCastRange + 99, true, BOT_MODE_NONE )
	local nEnemysHeroesInView = J.GetNearbyHeroes(bot, 880, true, BOT_MODE_NONE )

	if #nEnemysHeroesInCastRange > 0 then
		for i=1, #nEnemysHeroesInCastRange do
			if J.IsValid( nEnemysHeroesInCastRange[i] )
				and J.CanCastOnNonMagicImmune( nEnemysHeroesInCastRange[i] )
				and J.CanCastOnTargetAdvanced( nEnemysHeroesInCastRange[i] )
				and nEnemysHeroesInCastRange[i]:GetHealth() < nEnemysHeroesInCastRange[i]:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL )
				and not ( GetUnitToUnitDistance( nEnemysHeroesInCastRange[i], bot ) <= bot:GetAttackRange() + 60 )
				and not J.IsDisabled( nEnemysHeroesInCastRange[i] )
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInCastRange[i]
			end
		end
	end

	if #nEnemysHeroesInView > 0 then
		for i=1, #nEnemysHeroesInView do
			if J.IsValid( nEnemysHeroesInView[i] )
				and J.CanCastOnNonMagicImmune( nEnemysHeroesInView[i] )
				and J.CanCastOnTargetAdvanced( nEnemysHeroesInView[i] )
				and nEnemysHeroesInView[i]:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInView[i]
			end
		end
	end

	if J.IsInTeamFight( bot, 1200 )
		and DotaTime() > 4 * 60
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		for _, npcEnemy in pairs( nEnemysHeroesInCastRange )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL )
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

	if J.IsGoingOnSomeone( bot )
	then
		local target = J.GetProperTarget( bot )
		if J.IsValidHero( target )
			and J.CanCastOnNonMagicImmune( target )
			and J.CanCastOnTargetAdvanced( target )
			and J.IsInRange( target, bot, nCastRange )
			and not J.IsDisabled( target )
			and not target:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end

	if J.IsRetreating( bot )
	then
		if J.IsValid( nEnemysHeroesInCastRange[1] )
			and J.CanCastOnNonMagicImmune( nEnemysHeroesInCastRange[1] )
			and J.CanCastOnTargetAdvanced( nEnemysHeroesInCastRange[1] )
			and not J.IsDisabled( nEnemysHeroesInCastRange[1] )
			and not nEnemysHeroesInCastRange[1]:IsDisarmed()
			and GetUnitToUnitDistance( bot, nEnemysHeroesInCastRange[1] ) <= nCastRange - 60
		then
			return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInCastRange[1]
		end
	end


	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() > 400
	then
		local target =  bot:GetAttackTarget()

		if target ~= nil and target:IsAlive()
			and J.GetHP( target ) > 0.2
			and not J.IsDisabled( target )
			and not target:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_LOW, target
		end
	end

	return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderRealityRift()

	if not RealityRift:IsFullyCastable() or bot:IsRooted() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = J.GetProperCastRange(false, bot, RealityRift:GetCastRange())

	if J.IsGoingOnSomeone( bot )
	then
		local target = J.GetProperTarget( bot )
		if J.IsValidHero( target )
			and J.IsInRange( target, bot, nCastRange + 50 )
			and ( not J.IsInRange( bot, target, 200 ) or not target:HasModifier( 'modifier_chaos_knight_reality_rift' ) )
			and J.CanCastOnNonMagicImmune( target )
			and J.CanCastOnTargetAdvanced( target )
			and not J.IsDisabled( target )
		then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end


	if J.IsRetreating( bot )
	then
		local enemies = J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE )
		local creeps = bot:GetNearbyLaneCreeps( nCastRange, true )

		if enemies[1] ~= nil and creeps[1] ~= nil
		then
			for _, creep in pairs( creeps )
			do
				if enemies[1]:IsFacingLocation( bot:GetLocation(), 30 )
					and bot:IsFacingLocation( creep:GetLocation(), 30 )
					and GetUnitToUnitDistance( bot, creep ) >= 650
				then
					return BOT_ACTION_DESIRE_LOW, creep
				end
			end
		end
	end


	if hEnemyHeroList[1] == nil
		and bot:GetAttackDamage() >= 150
	then
		local nCreeps = bot:GetNearbyLaneCreeps( 1000, true )
		for i=1, #nCreeps
		do
			local creep = nCreeps[#nCreeps -i + 1]
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.IsKeyWordUnit( "ranged", creep )
				and GetUnitToUnitDistance( bot, creep ) >= 350
			then
				return BOT_ACTION_DESIRE_LOW, creep
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() > 400
	then
		local target =  bot:GetAttackTarget()
		if target ~= nil
			and not J.IsDisabled( target )
			and not target:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_LOW, target
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderPhantasm()

	if not Phantasm:IsFullyCastable() or bot:DistanceFromFountain() < 500 then return BOT_ACTION_DESIRE_NONE end

	local nNearbyEnemyHeroes = J.GetEnemyList( bot, 1600 )
	local nNearbyEnemyTowers = bot:GetNearbyTowers( 700, true )
	local nNearbyEnemyBarracks = bot:GetNearbyBarracks( 400, true )
	local nNearbyAlliedCreeps = bot:GetNearbyLaneCreeps( 1000, false )
	local nCastRange = 900

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnMagicImmune( botTarget )
			--and #nNearbyAllyHeroes - #nNearbyEnemyHeroes <= 2
			and ( J.GetHP( botTarget ) > 0.5
				  or nHP < 0.7
				  or #nNearbyEnemyHeroes >= 2 )

		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end


	if J.IsInTeamFight( bot, 1200 )
	then
		if #nNearbyEnemyHeroes >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end


	if J.IsPushing( bot )
		and DotaTime() > 8 * 30
	then
		if ( #nNearbyEnemyTowers >= 1 or #nNearbyEnemyBarracks >= 1 )
			and #nNearbyAlliedCreeps >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end


	if bot:GetActiveMode() == BOT_MODE_RETREAT
		and nHP >= 0.5
		and J.IsValidHero( nNearbyEnemyHeroes[1] )
		and GetUnitToUnitDistance( bot, nNearbyEnemyHeroes[1] ) <= 700
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	return BOT_ACTION_DESIRE_NONE
end

return X