local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local Enfeeble
local BrainSap
local Nightmare
local FiendsGrip

local botTarget

local abilityWFirstType
local nMP, nLV, hEnemyList, hAllyList

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )

    if abilityName == 'bane_enfeeble'
    then
        Enfeeble = ability
        EnfeebleDesire, EnfeebleTarget = X.ConsiderEnfeeble()
        if EnfeebleDesire > 0
        then
            bot:ActionQueue_UseAbilityOnEntity(Enfeeble, EnfeebleTarget)
            return
        end
    end

    if abilityName == 'bane_brain_sap'
    then
        BrainSap = ability
        BrainSapDesire, BrainSapTarget = X.ConsiderBrainSap()
        if BrainSapDesire > 0
        then
            BrainSap = ability

            if abilityWFirstType == nil
            and BrainSap:IsTrained()
            then
                abilityWFirstType = BrainSap:GetTargetType()
            end

            if abilityWFirstType ~= nil
                and abilityWFirstType ~= BrainSap:GetTargetType()
            then
                bot:ActionQueue_UseAbilityOnEntity(BrainSap, BrainSap:GetLocation())
            else
                bot:ActionQueue_UseAbilityOnEntity(BrainSap, BrainSapTarget)
            end
            return
        end
    end

    if abilityName == 'bane_fiends_grip'
    then
        FiendsGrip = ability
        FiendsGripDesire, FiendsGripTarget = X.ConsiderFiendsGrip()
        if FiendsGripDesire > 0
        then
            J.SetQueueToInvisible(bot)
            bot:ActionQueue_UseAbilityOnEntity(FiendsGrip, FiendsGripTarget)
            return
        end
    end

    if abilityName == 'bane_nightmare'
    then
        Nightmare = ability
        NightmareDesire, NightmareTarget = X.ConsiderNightmare()
        if NightmareDesire > 0
        then
            bot:ActionQueue_UseAbilityOnEntity(Nightmare, NightmareTarget)
            return
        end
    end
end

function X.ConsiderEnfeeble()
	if not Enfeeble:IsFullyCastable() then return 0 end

	local nSkillLV = Enfeeble:GetLevel()
	local nCastRange = J.GetProperCastRange(false, bot, Enfeeble:GetCastRange())
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and not botTarget:HasModifier( 'modifier_bane_enfeeble' )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 50 )
		then
			if nSkillLV >= 2 or nMP > 0.6
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end
		end

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_bane_enfeeble' )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderBrainSap()
	if not BrainSap:IsFullyCastable() then return 0 end

	local nSkillLV = BrainSap:GetLevel()
	local nCastRange = BrainSap:GetCastRange()
	local nCastPoint = BrainSap:GetCastPoint()
	local nManaCost = BrainSap:GetManaCost()
	local nDamage = BrainSap:GetSpecialValueInt( 'brain_sap_damage' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )

	local nLostHealth = bot:GetMaxHealth() - bot:GetHealth()

	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end

		end
	end


	if nLV <= 7 and nMP < 0.72
		and nLostHealth < nDamage * 0.8
	then return BOT_ACTION_DESIRE_NONE end

	if J.IsInTeamFight( bot, 1200 )
	then
		local nWeakestEnemy = nil
		local nWeakestEnemyHealth = 99999

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				if ( npcEnemyHealth < nWeakestEnemyHealth )
				then
					nWeakestEnemyHealth = npcEnemyHealth
					nWeakestEnemy = npcEnemy
				end
			end
		end

		if ( nWeakestEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemy
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 50 )
		then
			if nSkillLV >= 2 or nMP > 0.78 or J.GetHP( botTarget ) < 0.38
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end
		end
	end

	if bot:WasRecentlyDamagedByAnyHero( 3.0 ) and nLV >= 10
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nInRangeEnemyList >= 1
		and nLostHealth >= nDamage
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 45 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	if J.IsRetreating( bot ) and nLostHealth > nDamage
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) or nLostHealth > nDamage * 2 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end

		if #hEnemyList == 0 and nLV >= 10
			and not bot:WasRecentlyDamagedByAnyHero( 3.0 )
			and nLostHealth > nDamage * 1.5
		then
			local creepList = bot:GetNearbyCreeps( 1000, true )
			for _, creep in pairs( creepList )
			do
				if J.IsValid( creep )
					and J.CanCastOnNonMagicImmune( creep )
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end

	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local targetCreep = botTarget

		if J.IsValid( targetCreep )
			and J.IsInRange( bot, targetCreep, nCastRange + 100 )
			and targetCreep:GetTeam() == TEAM_NEUTRAL
			and not J.IsRoshan( targetCreep )
			and ( targetCreep:GetMagicResist() < 0.3 or nMP > 0.8 )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 2, DAMAGE_TYPE_PHYSICAL )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep
		end
	end


	--推进时对小兵用
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and nSkillLV >= 3 and DotaTime() > 8 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1200, true )
		local keyWord = "ranged"
		for _, creep in pairs( laneCreepList )
		do
			if J.IsValid( creep )
				and ( J.IsKeyWordUnit( keyWord, creep ) or nMP > 0.6 )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				and not J.CanKillTarget( creep, bot:GetAttackDamage() * 1.38, DAMAGE_TYPE_PHYSICAL )
			then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
		end
	end


	--肉山
	if J.IsDoingRoshan( bot )
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange - 200 )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	--通用消耗敌人或受到伤害时保护自己
	if ( #hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 12
		and nLostHealth > nDamage
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderNightmare()
    if not Nightmare:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end

	local nCastRange = J.GetProperCastRange(false, bot, Nightmare:GetCastRange())

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange + 150, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and enemyHero:IsChanneling()
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_legion_commander_duel')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local target = nil
		local dmg = 0
		local nEnemyCount = 0

        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
			then
				nEnemyCount = nEnemyCount + 1
				if  J.CanCastOnTargetAdvanced(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:IsDisarmed()
                and not enemyHero:HasModifier('modifier_legion_commander_duel')
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				then
					local npcEnemyPower = enemyHero:GetEstimatedDamageToTarget( true, bot, 6.0, DAMAGE_TYPE_ALL )
					if npcEnemyPower > dmg
					then
						dmg = npcEnemyPower
						target = enemyHero
					end
				end
			end
		end

		if target ~= nil and nEnemyCount >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		then
            local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
			for _, enemyHero in pairs(nInRangeEnemy)
			do
				if  J.IsValid(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                and enemyHero:GetPlayerID() ~= botTarget:GetPlayerID()
                and not enemyHero:IsDisarmed()
                and not J.IsDisabled(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not enemyHero:HasModifier('modifier_legion_commander_duel')
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero
				end
			end

			if  J.IsInRange(bot, botTarget, nCastRange)
            and J.CanCastOnNonMagicImmune(botTarget)
            and J.CanCastOnTargetAdvanced(botTarget)
            and J.IsChasingTarget(bot, botTarget)
            and not J.IsDisabled(botTarget)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:HasModifier('modifier_legion_commander_duel')
            and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

				if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
                and #nInRangeAlly >= #nInRangeEnemy
                and not (#nInRangeAlly >= #nInRangeEnemy + 2)
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget
				end
			end
		end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.7
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:IsDisarmed()
			then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and (#nTargetInRangeAlly > #nInRangeAlly
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderFiendsGrip()
    if not FiendsGrip:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end

	local nCastRange = J.GetProperCastRange(false, bot, FiendsGrip:GetCastRange())
	local nDamage = FiendsGrip:GetSpecialValueInt('fiend_grip_damage') * 6

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange + 150, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
			if enemyHero:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end

			if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PURE)
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

	if J.IsInTeamFight(bot, 1200)
	then
		local target = nil
		local dmg = 0

        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange + 150, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_legion_commander_duel')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				local currDmg = enemyHero:GetEstimatedDamageToTarget(true, bot, 6.0, DAMAGE_TYPE_ALL)
				if currDmg > dmg
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
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:IsAttackImmune()
        and not botTarget:IsInvulnerable()
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X