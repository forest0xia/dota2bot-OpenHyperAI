local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos1
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,3,2,3,2,3,2,2,1,1,1,6,6,6},--pos1
						{3,1,3,2,3,6,3,2,2,2,6,1,1,1,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
	"item_double_branches",
	"item_slippers",
	"item_circlet",
	"item_quelling_blade",

	"item_wraith_band",
	"item_power_treads",
	"item_magic_wand",
	"item_mask_of_madness",
	"item_manta",--
	"item_black_king_bar",--
	"item_aghanims_shard",
	"item_angels_demise",--
	"item_satanic",--
	"item_butterfly",--
	"item_travel_boots",
	"item_moon_shard",
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_quelling_blade",
	"item_wraith_band",
	"item_magic_wand",
	"item_mask_of_madness",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_ranged_carry' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local LucentBeam 	= bot:GetAbilityByName('luna_lucent_beam')
local MoonGlaives 	= bot:GetAbilityByName('luna_moon_glaive')
-- local LunarBlessing = bot:GetAbilityByName('luna_lunar_blessing')
local Eclipse 		= bot:GetAbilityByName('luna_eclipse')
local talent6 		= bot:GetAbilityByName(sTalentList[6])

local LucentBeamDesire, LucentBeamTarget
local MoonGlaivesDesire
local EclipseDesire

local talent6BonusDamage = 0

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

	botTarget = J.GetProperTarget(bot)
	J.ConsiderTarget()

	if talent6:IsTrained() then talent6BonusDamage = talent6:GetSpecialValueInt('value') end

	MoonGlaivesDesire = X.ConsiderMoonGlaives()
	if MoonGlaivesDesire > 0
	then
		bot:Action_UseAbility(MoonGlaives)
		return
	end

	EclipseDesire = X.ConsiderEclipse()
	if EclipseDesire > 0
	then
		if J.HasPowerTreads(bot)
		then
			J.SetQueuePtToINT(bot, false)

			if bot:HasScepter()
			then
				bot:ActionQueue_UseAbilityOnEntity(Eclipse, bot)
			else
				bot:ActionQueue_UseAbility(Eclipse)
			end
		else
			if bot:HasScepter()
			then
				bot:Action_UseAbilityOnEntity(Eclipse, bot)
			else
				bot:Action_UseAbility(Eclipse)
			end
		end

		return
	end

	LucentBeamDesire, LucentBeamTarget = X.ConsiderLucentBeam()
	if LucentBeamDesire > 0
	then
		if J.HasPowerTreads(bot)
		then
			J.SetQueuePtToINT(bot, false)
			bot:ActionQueue_UseAbilityOnEntity(LucentBeam, LucentBeamTarget)
		else
			bot:Action_UseAbilityOnEntity(LucentBeam, LucentBeamTarget)
		end

		return
	end
end

function X.ConsiderLucentBeam()
	if not LucentBeam:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, LucentBeam:GetCastRange())
	local nAbilityLevel = LucentBeam:GetLevel()
	local nDamage = LucentBeam:GetSpecialValueInt('beam_damage') + talent6BonusDamage

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 300, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.CanCastOnTargetAdvanced(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end

			if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
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
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if J.IsValidHero(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and J.CanCastOnTargetAdvanced(enemyHero)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			then
				local npcEnemyHealth = enemyHero:GetHealth()
				if npcEnemyHealth < npcWeakestEnemyHealth
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = enemyHero
				end
			end
		end

		if npcWeakestEnemy ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.CanCastOnTargetAdvanced(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange + 75)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end
		end
	end

	if  J.IsRetreating(bot)
	and bot:GetActiveModeDesire() > 0.5
    then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
			and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
			and not J.IsRealInvisible(bot)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

	if J.IsLaning(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + 200, true)
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and J.CanBeAttacked(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
			and not J.IsInRange(bot, creep, bot:GetAttackRange() + 80)
			then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
		end

		if nAbilityLevel >= 2
		or J.GetMP(bot) > 0.9
		then
			for _, creep in pairs(nEnemyLaneCreeps)
			do
				if  J.IsValid(creep)
				and J.CanBeAttacked(creep)
				and J.IsKeyWordUnit('melee', creep)
				and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
				and not J.IsInRange(bot, creep, bot:GetAttackRange() + 80)
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end

	if J.IsFarming(bot)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange + 100)
		local targetCreep = J.GetMostHpUnit(nNeutralCreeps)

		if  J.IsValid(targetCreep)
		and (#nNeutralCreeps >= 2 or GetUnitToUnitDistance(targetCreep, bot) <= 400)
		and not J.IsRoshan(targetCreep)
		and not J.CanKillTarget(targetCreep, bot:GetAttackDamage() * 1.68, DAMAGE_TYPE_PHYSICAL)
		and not J.CanKillTarget(targetCreep, nDamage - 10, DAMAGE_TYPE_MAGICAL)
		and J.GetManaAfter(LucentBeam:GetManaCost()) * bot:GetMana() > Eclipse:GetManaCost() * 2
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep
		end
	end

	if J.IsDoingRoshan(bot)
    then
		-- Remove Spell Block
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
		and J.IsAttacking(bot)
        and not J.IsDisabled(botTarget)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

	local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and J.IsCore(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and allyHero:GetActiveModeDesire() >= 0.5
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderMoonGlaives()
	if not MoonGlaives:IsTrained()
	or not MoonGlaives:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = 175
	local nEnemyHeroes = J.GetNearbyHeroes(bot,700, true, BOT_MODE_NONE)

	if  J.GetHP(bot) < 0.5
	and bot:WasRecentlyDamagedByAnyHero(1)
	and nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and bot:WasRecentlyDamagedByAnyHero(1)
		and not J.IsDisabled(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsRetreating(bot)
    then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
			and J.IsInRange(bot, enemyHero, 700)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end

	if J.IsFarming(bot)
	then
		local nCreeps = bot:GetNearbyCreeps(nRadius, true)

		if  nCreeps ~= nil
		and (#nCreeps >= 3 or (#nCreeps >= 2 and nCreeps[1]:IsAncientCreep()))
		and J.CanBeAttacked(nCreeps[1])
		and J.IsAttacking(bot)
		and J.GetManaAfter(MoonGlaives:GetManaCost()) * bot:GetMana() > Eclipse:GetManaCost() * 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
		and J.IsAttacking(bot)
        and not J.IsDisabled(botTarget)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderEclipse()
	if not Eclipse:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = Eclipse:GetSpecialValueInt('radius')
	local nDamage = LucentBeam:GetSpecialValueInt('beam_damage')

	if J.IsInTeamFight(bot, 1200)
	then
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius + 75)
		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
		then
			local canKillACore = false
			for _, enemyHero in pairs(nInRangeEnemy)
			do
				if  J.IsValidHero(enemyHero)
				and J.CanCastOnNonMagicImmune(enemyHero)
				and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
				-- and J.IsCore(enemyHero)
				and not J.IsSuspiciousIllusion(enemyHero)
				and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
				and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
				and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
				and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
				then
					canKillACore = true
					break
				end
			end

			if canKillACore
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		and not (botTarget:GetHealth() <= bot:GetAttackDamage() * 4)
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			and not (#nInRangeAlly >= #nInRangeEnemy + 3)
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X