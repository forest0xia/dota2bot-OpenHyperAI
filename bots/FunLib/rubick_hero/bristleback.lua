local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local ViscousNasalGoo
local QuillSpray
local HairBall
local Bristleback

local botTarget

local nMP, nLV, hEnemyList

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

	nMP = bot:GetMana()/bot:GetMaxMana()
	nLV = bot:GetLevel()
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )

    if abilityName == 'bristleback_hairball'
    then
        HairBall = ability
        HairBallDesire, HairBallLocation = X.ConsiderHairBall()
        if HairBallDesire > 0
        then
            bot:Action_UseAbilityOnLocation(HairBall, HairBallLocation)
            return
        end
    end

    if abilityName == 'bristleback_bristleback'
    then
        Bristleback = ability
        BristlebackDesire, BristlebackLocation = X.ConsiderBristleback()
        if BristlebackDesire > 0
        then
            bot:Action_UseAbilityOnLocation(Bristleback, BristlebackLocation)
            return
        end
    end

    if abilityName == 'bristleback_viscous_nasal_goo'
    then
        ViscousNasalGoo = ability
        ViscousNasalGooDesire, ViscousNasalGooTarget = X.ConsiderViscousNasalGoo()
        if ViscousNasalGooDesire > 0
        then
            bot:Action_UseAbilityOnEntity(ViscousNasalGoo, ViscousNasalGooTarget)
            return
        end
    end

    if abilityName == 'bristleback_quill_spray'
    then
        QuillSpray = ability
        QuillSprayDesire = X.ConsiderQuillSpray()
        if QuillSprayDesire > 0
        then
            bot:Action_UseAbility(QuillSpray)
            return
        end
    end
end

function X.ConsiderViscousNasalGoo()

	if ( not ViscousNasalGoo:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = ViscousNasalGoo:GetSpecialValueInt( 'radius_scepter' )
	local nCastRange = J.GetProperCastRange(false, bot, ViscousNasalGoo:GetCastRange())
	local nManaCost = ViscousNasalGoo:GetManaCost()

	local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	local nEnemyHeroes = J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE )

	if J.IsRetreating( bot )
	then
		local npcEnemy = tableNearbyEnemyHeroes[1]
		if J.IsValid( npcEnemy )
		then
			if bot:HasScepter()
			then
				return BOT_ACTION_DESIRE_LOW, npcEnemy
			end

			if J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and ( bot:IsFacingLocation( npcEnemy:GetLocation(), 10 ) or #nEnemyHeroes <= 1 )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or nLV >= 10 )
			then
				return BOT_ACTION_DESIRE_LOW, npcEnemy
			end
		end
	end

	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		if ( J.IsRoshan( botTarget ) and J.CanCastOnMagicImmune( botTarget ) and J.IsInRange( botTarget, bot, nCastRange ) )
		then
			return BOT_ACTION_DESIRE_LOW, botTarget
		end
	end

	if J.IsInTeamFight( bot, 1400 ) and bot:HasScepter()
	then
		if tableNearbyEnemyHeroes ~= nil
			and #tableNearbyEnemyHeroes >= 1
			and J.IsValidHero( tableNearbyEnemyHeroes[1] )
			and J.CanCastOnNonMagicImmune( tableNearbyEnemyHeroes[1] )
		then
			return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1]
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nRadius )
			and J.CanCastOnTargetAdvanced( botTarget )
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, botTarget
		end

		if J.IsValid( botTarget )
			and #hEnemyList == 0
			and J.IsAllowedToSpam( bot, nManaCost )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nRadius )
			and not J.CanKillTarget( botTarget, bot:GetAttackDamage() * 1.68, DAMAGE_TYPE_PHYSICAL )
		then
			local nCreeps = bot:GetNearbyCreeps( 800, true )
			if #nCreeps >= 1
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, botTarget
			end
		end

	end

	return BOT_ACTION_DESIRE_NONE, 0

end


function X.ConsiderQuillSpray()

	if not QuillSpray:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = QuillSpray:GetSpecialValueInt( "radius" )
	local nManaCost = QuillSpray:GetManaCost()

	local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )

	if J.IsRetreating( bot ) and #tableNearbyEnemyHeroes > 0
	then
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
				or npcEnemy:HasModifier( "modifier_bristleback_quill_spray" )
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	if J.IsPushing( bot )
		or J.IsDefending( bot )
		or ( J.IsGoingOnSomeone( bot ) and nLV >= 6 )
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( nRadius, true )
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 and J.IsAllowedToSpam( bot, nManaCost ) ) then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsFarming( bot ) and nLV > 5
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
		then
			if botTarget:GetHealth() > bot:GetAttackDamage() * 2.28
			then
				return BOT_ACTION_DESIRE_HIGH
			end

			local nCreeps = bot:GetNearbyCreeps( nRadius, true )
			if ( #nCreeps >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then
		if #tableNearbyEnemyHeroes >= 1
		then
			return BOT_ACTION_DESIRE_LOW
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nRadius-100 )
		then
			return BOT_ACTION_DESIRE_MODERATE
		end

		if J.IsValidHero( botTarget )
			and J.IsAllowedToSpam( bot, nManaCost )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nRadius )
		then
			local nCreeps = bot:GetNearbyCreeps( 800, true )
			if #nCreeps >= 1
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		if ( J.IsRoshan( botTarget ) and J.CanCastOnMagicImmune( botTarget ) and J.IsInRange( bot, botTarget, nRadius ) )
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if nMP > 0.95
		and nLV >= 6
		and bot:DistanceFromFountain() > 2400
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		return BOT_ACTION_DESIRE_LOW
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderBristleback()
	if Bristleback:IsPassive()
    or not Bristleback:IsTrained()
	or not Bristleback:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	if J.IsInTeamFight( bot, 1400 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, 700, 700, 2 )
		if nAoeLoc ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nAoeLoc
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local targetHero = J.GetProperTarget( bot )
		if J.IsValidHero( targetHero )
		and J.IsInRange( bot, targetHero, 700 )
		and J.CanCastOnNonMagicImmune( targetHero )
		then
			return BOT_ACTION_DESIRE_HIGH, targetHero:GetLocation()
		end
	end

	if J.IsRetreating( bot )
	then
		local nEnemyHeroes = J.GetNearbyHeroes(bot, 700, true, BOT_MODE_NONE )
		if nEnemyHeroes ~= nil and #nEnemyHeroes > 0
		then
			local targetHero = nEnemyHeroes[1]
			if J.IsValidHero( targetHero )
			and J.CanCastOnNonMagicImmune( targetHero )
			then
				return BOT_ACTION_DESIRE_MODERATE, targetHero:GetLocation()
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderHairBall()

	if not HairBall:IsTrained()
		or not HairBall:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = 700
	local nCastRange = J.GetProperCastRange(false, bot, HairBall:GetCastRange())

	if J.IsRetreating( bot )
	then
		local enemyHeroList = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
		local targetHero = enemyHeroList[1]
		if J.IsValidHero( targetHero )
			and J.CanCastOnNonMagicImmune( targetHero )
		then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end		
	end
	

	if J.IsInTeamFight( bot, 1400 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nAoeLoc
		end		
	end
	

	if J.IsGoingOnSomeone( bot )
	then
		local targetHero = J.GetProperTarget( bot )
		if J.IsValidHero( targetHero )
			and J.IsInRange( bot, targetHero, nCastRange )
			and J.CanCastOnNonMagicImmune( targetHero )
		then
			return BOT_ACTION_DESIRE_HIGH, targetHero:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end

return X