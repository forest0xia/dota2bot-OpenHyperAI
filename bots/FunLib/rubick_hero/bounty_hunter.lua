local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local ShurikenToss
local Jinada
local ShadowWalk
local FriendlyShadow
local Track

local botTarget

local nMP, nHP, nLV, hEnemyList, hAllyList

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )

    if abilityName == 'bounty_hunter_wind_walk'
    then
        ShadowWalk = ability
        ShadowWalkDesire = X.ConsiderShadowWalk()
        if ShadowWalkDesire > 0
        then
            bot:Action_UseAbility(ShadowWalk)
            return
        end
    end

    if abilityName == 'bounty_hunter_wind_walk_ally'
    then
        FriendlyShadow = ability
        FriendlyShadowDesire, FriendlyShadowTarget = X.ConsiderFriendlyShadow()
        if FriendlyShadowDesire > 0
        then
            bot:Action_UseAbilityOnEntity(FriendlyShadow, FriendlyShadowTarget)
            return
        end
    end

    if abilityName == 'bounty_hunter_track'
    then
        Track = ability
        TrackDesire, TrackTarget = X.ConsiderTrack()
        if TrackDesire > 0
        then
            bot:Action_UseAbilityOnEntity(Track, TrackTarget)
            return
        end
    end

    if abilityName == 'bounty_hunter_shuriken_toss'
    then
        ShurikenToss = ability
        ShurikenTossDesire, ShurikenTossTarget = X.ConsiderShurikenToss()
        if ShurikenTossDesire > 0
        then
            bot:ActionQueue_UseAbilityOnEntity(ShurikenToss, ShurikenToss)
            return
        end
    end
end

function X.ConsiderShurikenToss()


	if not ShurikenToss:IsFullyCastable() then return 0 end

	local nSkillLV = ShurikenToss:GetLevel()
	local nCastRange = J.GetProperCastRange(false, bot, ShurikenToss:GetCastRange())
	local nCastPoint = ShurikenToss:GetCastPoint()
	local nManaCost = ShurikenToss:GetManaCost()
	local nDamage = ShurikenToss:GetSpecialValueInt( 'bonus_damage' )
	local nDamageType = DAMAGE_TYPE_MAGICAL


	local nRadius = ShurikenToss:GetSpecialValueInt( "bounce_aoe" )
	local nEnemyUnitList = J.GetAroundBotUnitList( bot, nCastRange + 100, true )
	local nTrackEnemyList = {}

	for _, npcEnemy in pairs( hEnemyList )
	do
		if npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
		then
			nTrackEnemyList[#nTrackEnemyList + 1] = npcEnemy
		end

		if npcEnemy:IsChanneling()
			and not npcEnemy:IsMagicImmune()
		then
			if npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
			then
				for _, nUnit in pairs( nEnemyUnitList )
				do
					if J.IsValid( nUnit )
						and J.CanCastOnTargetAdvanced( nUnit )
						and not nUnit:IsMagicImmune()
					then
						return BOT_ACTION_DESIRE_HIGH, nUnit
					end
				end
			end

			if J.IsInRange( bot, npcEnemy, nCastRange + 200 )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end

		if J.CanCastOnNonMagicImmune( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint + GetUnitToUnitDistance( bot, npcEnemy )/1000 )
		then
			if npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
			then
				for _, nUnit in pairs( nEnemyUnitList )
				do
					if J.IsValid( nUnit )
						and J.CanCastOnTargetAdvanced( nUnit )
						and not nUnit:IsMagicImmune()
					then
						return BOT_ACTION_DESIRE_HIGH, nUnit
					end
				end
			end

			if J.IsInRange( bot, npcEnemy, nCastRange + 200 )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	if #nTrackEnemyList >= 2
	then
		local nBestUnit = nil
		local nMaxBounceCount = 1.2
		for _, nUnit in pairs( nEnemyUnitList )
		do
			if J.IsValid( nUnit )
				and not nUnit:IsMagicImmune()
				and J.CanCastOnTargetAdvanced( nUnit )
			then
				local nBounceCount = 0

				if not nUnit:HasModifier( "modifier_bounty_hunter_track" )
				then
					if nUnit:IsHero()
					then
						nBounceCount = nBounceCount + 1
					else
						nBounceCount = nBounceCount + 0.1
					end
				end

				for _, npcEnemy in pairs( nTrackEnemyList )
				do 
					if J.IsInRange( nUnit, npcEnemy, nRadius - 80 )
					then
						nBounceCount = nBounceCount + 1
					end
				end

				if nBounceCount > nMaxBounceCount
				then
					nBestUnit = nUnit
					nMaxBounceCount = nBounceCount
				end
			end
		end

		if nBestUnit ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nBestUnit
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + nRadius + 100 )
			and J.CanCastOnNonMagicImmune( botTarget )
		then
			if botTarget:HasModifier( "modifier_bounty_hunter_track" )
			then
				for _, nUnit in pairs( nEnemyUnitList )
				do
					if J.IsInRange( nUnit, npcEnemy, nRadius - 100 )
						and not nUnit:IsMagicImmune()
						and J.CanCastOnTargetAdvanced( nUnit )
						and not nUnit:HasModifier( "modifier_bounty_hunter_track" )
					then
						return BOT_ACTION_DESIRE_HIGH, nUnit
					end
				end
			end

			if J.IsInRange( bot, botTarget, nCastRange )
				and J.CanCastOnTargetAdvanced( botTarget )
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end
		end
	end

	if ( bot:GetActiveMode() == BOT_MODE_LANING or ( nLV <= 7 and #hAllyList <= 2 ) )
		and bot:GetMana() >= 150
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 300, true )
		local keyWord = "ranged"
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.IsKeyWordUnit( keyWord, creep )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint + GetUnitToUnitDistance( bot, creep )/1100 )
				and GetUnitToUnitDistance( creep, bot ) > 300
			then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
		end
	end

	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.52 )
		and ( bot:GetAttackDamage() < 300 or nMP > 0.7 )
		and nSkillLV >= 2 and DotaTime() > 7 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 350, true )
		local keyWord = "ranged"
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and J.IsKeyWordUnit( keyWord, creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint + GetUnitToUnitDistance( bot, creep )/1100 )
				and not J.CanKillTarget( creep, bot:GetAttackDamage() * 1.2, DAMAGE_TYPE_PHYSICAL )
			then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
		end
	end

	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local nCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 200 )

		local targetCreep = J.GetMostHpUnit( nCreeps )

		if J.IsValid( targetCreep )
			and not J.IsRoshan( targetCreep )
			and ( #nCreeps >= 2 or GetUnitToUnitDistance( targetCreep, bot ) <= 400 )
			and bot:IsFacingLocation( targetCreep:GetLocation(), 40 )
			and ( targetCreep:GetMagicResist() < 0.3 or nMP > 0.9 )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 1.68, DAMAGE_TYPE_PHYSICAL )
			and not J.CanKillTarget( targetCreep, nDamage - 50, nDamageType )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep
		end
	end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 460
	then
		if J.IsRoshan( botTarget )
			and J.GetHP( botTarget ) > 0.2
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderShadowWalk()


	if not ShadowWalk:IsFullyCastable() then return 0 end


	local nSkillLV = ShadowWalk:GetLevel()

	if J.IsGoingOnSomeone( bot )
		and ( nLV >= 7 or DotaTime() > 6 * 60 or nSkillLV >= 2 )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, 2500 )
			and ( not J.IsInRange( bot, botTarget, 1000 )
					or J.IsChasingTarget( bot, botTarget ) )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and ( #hEnemyList >= 1 or nHP < 0.2 )
		and bot:DistanceFromFountain() > 800
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsInEnemyArea( bot ) and nLV >= 7 and nMP >= 280
	then
		local nEnemies = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
		local nEnemyTowers = bot:GetNearbyTowers( 1600, true )
		if #nEnemies == 0 and nEnemyTowers == 0
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderTrack()


	if not Track:IsFullyCastable() then return 0 end

	local nCastRange = J.GetProperCastRange(false, bot, Track:GetCastRange())
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + 100 )
	local nCastTarget = nil

	local nMinHealth = 999999
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and not npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
			and not npcEnemy:HasModifier( "modifier_arc_warden_tempest_double" )
			and J.CanCastAbilityOnTarget( npcEnemy, false )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and npcEnemy:GetHealth() < nMinHealth
		then
			nCastTarget = npcEnemy
			nMinHealth = npcEnemy:GetHealth()
		end
	end
	if nCastTarget ~= nil
	then
		return BOT_ACTION_DESIRE_HIGH, nCastTarget
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderFriendlyShadow()
	if not FriendlyShadow:IsTrained()
	or not FriendlyShadow:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, FriendlyShadow:GetCastRange())
	local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)

	for _, ally in pairs(nAllyHeroes) do
		if J.IsGoingOnSomeone(ally)
		and J.IsInRange(bot, ally, nCastRange)
		and J.IsNotSelf(bot, ally)
		and not J.IsRealInvisible(ally)
		then
			return BOT_ACTION_DESIRE_HIGH, ally
		end

		if J.IsRetreating(ally)
		and ally:WasRecentlyDamagedByAnyHero(3.0)
		and ally:DistanceFromFountain() > 800
		and J.IsInRange(bot, ally, nCastRange)
		and J.IsNotSelf(bot, ally)
		and not J.IsRealInvisible(ally)
		and #hEnemyList >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, ally
		end

		if J.IsInEnemyArea(bot)
		then
			local nEnemies = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
			local nEnemyTowers = bot:GetNearbyTowers(1600, true)

			if nEnemies ~= nil and nEnemyTowers ~= nil
			and #nEnemies == 0 and #nEnemyTowers == 0
			and J.IsInRange(bot, ally, nCastRange)
			and J.IsNotSelf(bot, ally)
			and not J.IsRealInvisible(ally)
			then
				return BOT_ACTION_DESIRE_HIGH, ally
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

return X