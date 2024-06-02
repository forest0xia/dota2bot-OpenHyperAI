local bot
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local Penitence
local HolyPersuasion
local DivineFavor
local HandOfGod

local botTarget

local nChenCreeps = {}

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

    if abilityName == 'chen_hand_of_god'
    then
        HandOfGod = ability
        HandOfGodDesire = X.ConsiderHandOfGod()
        if HandOfGodDesire > 0
        then
            bot:Action_UseAbility(HandOfGod)
            return
        end
    end

    if abilityName == 'chen_penitence'
    then
        Penitence = ability
        PenitenceDesire, PenitenceTarget = X.ConsiderPenitence()
        if PenitenceDesire > 0
        then
            bot:Action_UseAbilityOnEntity(Penitence, PenitenceTarget)
            return
        end
    end

    if abilityName == 'chen_holy_persuasion'
    then
        HolyPersuasion = ability
        HolyPersuasionDesire, HolyPersuasionTarget = X.ConsiderHolyPersuasion()
        if HolyPersuasionDesire > 0
        then
            bot:Action_UseAbilityOnEntity(HolyPersuasion, HolyPersuasionTarget)
            return
        end
    end

    if abilityName == 'chen_divine_favor'
    then
        DivineFavor = ability
        DivineFavorDesire, DivineFavorTarget = X.ConsiderDivineFavor()
        if DivineFavorDesire > 0
        then
            bot:Action_UseAbilityOnEntity(DivineFavor, DivineFavorTarget)
            return
        end
    end
end

function X.ConsiderPenitence()
    if not Penitence:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Penitence:GetCastRange())
    local nAttackRange = bot:GetAttackRange()

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.5)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and allyHero:GetCurrentMovementSpeed() < nAllyInRangeEnemy[1]:GetCurrentMovementSpeed()
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if  J.IsChasingTarget(bot, botTarget)
                and bot:GetCurrentMovementSpeed() < botTarget:GetCurrentMovementSpeed()
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                end

                nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1600)
                if  J.IsInRange(bot, botTarget, nAttackRange)
                and J.IsAttacking(bot)
                and J.GetHeroCountAttackingTarget(nInRangeAlly, botTarget) >= 2
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                end
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                and bot:GetCurrentMovementSpeed() < enemyHero:GetCurrentMovementSpeed()
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

	if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
	then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 800)

		if  (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and nInRangeAlly ~= nil and #nInRangeAlly >= 1
        and J.GetHeroCountAttackingTarget(nInRangeAlly, botTarget) >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderHolyPersuasion()
	if not HolyPersuasion:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

    local nCastRange = J.GetProperCastRange(false, bot, HolyPersuasion:GetCastRange())
    local nMaxUnit = HolyPersuasion:GetSpecialValueInt('max_units')
    local nMaxLevel = HolyPersuasion:GetSpecialValueInt('level_req')
	local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)

    local unitTable = {}
    for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
        if string.find(unit:GetUnitName(), 'neutral')
        and unit:HasModifier('modifier_chen_holy_persuasion')
        then
            table.insert(unitTable, unit)
        end
    end

    nChenCreeps = unitTable

    local nGoodCreep = {
        "npc_dota_neutral_alpha_wolf",
        "npc_dota_neutral_centaur_khan",
        "npc_dota_neutral_polar_furbolg_ursa_warrior",
        "npc_dota_neutral_dark_troll_warlord",
        "npc_dota_neutral_satyr_hellcaller",
        "npc_dota_neutral_enraged_wildkin",
        "npc_dota_neutral_warpine_raider",
    }

    if nMaxLevel < 5
    then
        for _, creep in pairs(nNeutralCreeps)
        do
            if J.IsValid(creep)
            then
                return BOT_ACTION_DESIRE_HIGH, creep
            end
        end
    else
        if nChenCreeps ~= nil and #nChenCreeps < nMaxUnit
        then
            for _, creep in pairs(nNeutralCreeps)
            do
                if J.IsValid(creep)
                and creep:GetLevel() <= nMaxLevel
                then
                    for _, gCreep in pairs(nGoodCreep)
                    do
                        if creep:GetUnitName() == gCreep
                        then
                            return BOT_ACTION_DESIRE_HIGH, creep
                        end
                    end
                end
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDivineFavor()
    if not DivineFavor:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, DivineFavor:GetCastRange())
    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)

	for _, allyHero in pairs(nAllyHeroes)
	do
		if  J.IsValidHero(allyHero)
		and J.IsInRange(bot, allyHero, nCastRange)
        and not allyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not allyHero:HasModifier('modifier_legion_commander_press_the_attack')
        and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not allyHero:HasModifier('modifier_chen_penitence_attack_speed_buff')
        and not allyHero:HasModifier('modifier_chen_divine_favor_armor_buff')
        and not allyHero:IsIllusion()
		and not allyHero:IsInvulnerable()
		then
			if J.IsGoingOnSomeone(allyHero)
			then
				local allyTarget = J.GetProperTarget(allyHero)

				if  J.IsValidTarget(allyTarget)
                and J.IsCore(allyHero)
				and J.IsInRange(allyHero, allyTarget, allyHero:GetCurrentVisionRange())
                and not J.IsSuspiciousIllusion(allyTarget)
				then
					return BOT_ACTION_DESIRE_HIGH, allyHero
				end
			end

            local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

            if  J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.5)
            then
                if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
                and J.IsValidHero(nAllyInRangeEnemy[1])
                and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
                and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
                and not J.IsDisabled(nAllyInRangeEnemy[1])
                and not J.IsTaunted(nAllyInRangeEnemy[1])
                and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
                and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
                end
            end
		end
	end

    if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
	then
		if  (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
		then
            local target = J.GetAttackableWeakestUnit(bot, nCastRange, true, false)

            if target ~= nil
            then
                return BOT_ACTION_DESIRE_HIGH, target
            end
        end
	end

    if J.IsInTeamFight(bot, 1200)
    then
        local totDist = 0

        for _, creep in pairs(nChenCreeps)
        do
            local dist = GetUnitToUnitDistance(bot, creep)
            if dist > 1600
            then
                totDist = totDist + dist
            end
        end

        if nChenCreeps ~= nil and #nChenCreeps > 0
        then
            if (totDist / #nChenCreeps) > 1600
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
    end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly and #nInRangeAlly <= 1)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderHandOfGod()
	if not HandOfGod:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE
	end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)

    if nTeamFightLocation ~= nil
    then
        local nAllyList = J.GetAlliesNearLoc(nTeamFightLocation, 1600)

        for _, allyHero in pairs(nAllyList)
        do
            if  J.IsValidHero(allyHero)
            and J.IsCore(allyHero)
            and J.GetHP(allyHero) < 0.5
            and not allyHero:IsIllusion()
            and not allyHero:IsAttackImmune()
			and not allyHero:IsInvulnerable()
            and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not allyHero:HasModifier('modifier_oracle_false_promise_timer')
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsCore(allyHero)
        and J.GetHP(allyHero) < 0.5
        and allyHero:WasRecentlyDamagedByAnyHero(1)
        and not allyHero:IsIllusion()
        and not allyHero:IsAttackImmune()
		and not allyHero:IsInvulnerable()
        and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not allyHero:HasModifier('modifier_oracle_false_promise_timer')
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

return X