local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,1,3,3,6,3,2,2,2,1,6,1,1,6},--pos1, bugged in 7.37 as the facet can't get auto selected for this bot.
						-- {2,3,3,3,6,3,2,2,2,6,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRandom = RandomInt(1, 2) == 1 and "item_radiance" or "item_desolator"

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_branches",
    "item_faerie_fire",
    "item_quelling_blade",
    "item_double_gauntlets",

    "item_orb_of_corrosion",
    "item_phase_boots",
    "item_armlet",
    sRandom,--
    "item_aghanims_shard",
    "item_assault",--
    "item_basher",
    "item_nullifier",--
    "item_monkey_king_bar",--
    "item_travel_boots",
    "item_abyssal_blade",--
    "item_travel_boots_2",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_branches",
    "item_quelling_blade",
    "item_gauntlets",
    "item_orb_of_corrosion",
    "item_armlet",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
    Minion.MinionThink(hMinionUnit, bot)
end

local Rage          = bot:GetAbilityByName('life_stealer_rage')
-- local Feast         = bot:GetAbilityByName('life_stealer_feast')
-- local GhoulFrenzy   = bot:GetAbilityByName('life_stealer_ghoul_frenzy')
local OpenWounds    = bot:GetAbilityByName('life_stealer_open_wounds')
local Infest        = bot:GetAbilityByName('life_stealer_infest')
local Consume       = bot:GetAbilityByName('life_stealer_consume')

local announceCount, lastAnnouncedTime = 0, GameTime()

local RageDesire
local OpenWoundsDesire, OpenWoundsTarget
local InfestDesire, InfestTarget
local ConsumeDesire

function X.SkillsComplement()
    if not bot:HasModifier('modifier_life_stealer_infest')
    then
        if J.CanNotUseAbility(bot) then return end
    end

    ConsumeDesire = X.ConsiderConsume()
    if ConsumeDesire > 0
    then
        bot:Action_UseAbility(Consume)
        return
    end

    InfestDesire, InfestTarget = X.ConsiderInfest()
    if InfestDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Infest, InfestTarget)
        return
    end

    Rage = bot:GetAbilityByName('life_stealer_rage')
    if Rage and not Rage:IsNull() and not Rage:IsHidden() then
		if bot.needRefreshAbilitiesFor737 then
			Chronosphere = bot:GetAbilityByName('life_stealer_rage')
			sAbilityList = J.Skill.GetAbilityList( bot )
			J.Utils.PrintTable(sAbilityList)
			X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
			bot:ActionImmediate_Chat( "I now have my Rage back. Thanks!", true )
			bot.needRefreshAbilitiesFor737 = false
		end

        RageDesire = X.ConsiderRage()
        if RageDesire > 0
        then
            bot:Action_UseAbility(Rage)
            return
        end
    elseif not bot:HasModifier('modifier_life_stealer_infest') then
		bot.needRefreshAbilitiesFor737 = true
		if announceCount <= 2 and GameTime() - lastAnnouncedTime > 15 + bot:GetPlayerID() then
			lastAnnouncedTime = GameTime()
			announceCount = announceCount + 1
            bot:ActionImmediate_Chat( "Due to Valve bug in 7.37. I lost Rage. Please enable Fretbots mode in this script to fix this problem. Check Workshop page if you need help.", true )
		end
    end

    OpenWoundsDesire, OpenWoundsTarget = X.ConsiderOpenWounds()
    if OpenWoundsDesire > 0
    then
        bot:Action_UseAbilityOnEntity(OpenWounds, OpenWoundsTarget)
        return
    end
end

function X.ConsiderRage()
    if not Rage:IsFullyCastable()
    or bot:HasModifier('modifier_life_stealer_infest')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = 1000
	local nEnemyHeroes = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE)

	if  nEnemyHeroes ~= nil and #nEnemyHeroes > 0
    and not bot:IsMagicImmune()
    and not bot:IsInvulnerable()
    and not bot:HasModifier('modifier_item_lotus_orb_active')
    and not bot:HasModifier('modifier_antimage_spell_shield')
    and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot))
	then
		if bot:IsRooted()
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		if  bot:IsSilenced()
        and J.GetEnemyCount(bot, 600) >= 2
        and not bot:HasModifier('modifier_item_mask_of_madness_berserk')
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		if J.IsNotAttackProjectileIncoming(bot, 350)
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		if J.IsWillBeCastUnitTargetSpell(bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		if J.IsWillBeCastPointSpell(bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		if J.GetEnemyCount(bot, 850) >= 3
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderOpenWounds()
    if not OpenWounds:IsFullyCastable()
    or bot:HasModifier('modifier_life_stealer_infest')
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = OpenWounds:GetCastRange()
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 125, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.62 and bot:WasRecentlyDamagedByAnyHero(2)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
        end
    end

	if  J.IsFarming(bot)
    and J.GetHP(bot) < 0.49
	then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)

		if  nNeutralCreeps ~= nil and #nNeutralCreeps >= 1
        and J.IsAttacking(bot)
        and J.CanBeAttacked(nNeutralCreeps[1])
        and J.GetHP(nNeutralCreeps[1]) >= 0.75
        then
            return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
        end
	end

	if J.IsDoingRoshan(bot)
	then
        if  J.IsRoshan(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsAttacking(bot)
        and J.GetHP(bot) < 0.54
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderInfest()
    if Infest:IsHidden()
    or not Infest:IsFullyCastable()
    or bot:HasModifier('modifier_life_stealer_infest')
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nAttackRange = bot:GetAttackRange()
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 1000)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			local target = nil

			for _, allyHero in pairs(nInRangeAlly)
			do
				if  J.IsNotSelf(bot, allyHero)
                and allyHero:GetAttackRange() <= 324
				then
					target = allyHero
				end
			end

			if target ~= nil
            then
				return BOT_ACTION_DESIRE_HIGH, target
			end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByAnyHero(2.5)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 500)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
		then
            local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(800, false)
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(800, true)

            for _, allyHero in pairs(nInRangeAlly)
            do
                if  J.IsNotSelf(bot, allyHero)
                and J.IsInRange(bot, allyHero, 3 * nAttackRange)
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end

            for _, creep in pairs(nAllyLaneCreeps)
            do
                if  J.IsInRange(bot, creep, 3 * nAttackRange)
                then
                    return BOT_ACTION_DESIRE_HIGH, creep
                end
            end

            for _, creep in pairs(nEnemyLaneCreeps)
            do
                if  J.IsInRange(bot, creep, 3 * nAttackRange)
                then
                    return BOT_ACTION_DESIRE_HIGH, creep
                end
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderConsume()
    if Consume:IsHidden()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nDamage = Infest:GetSpecialValueInt('damage')
	local nRadius = Infest:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 200)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end

        nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius - 100, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, enemyHero, nRadius - 100)
            and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if J.GetHP(bot) > 0.75
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if J.GetHP(bot) > 0.75
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

return X