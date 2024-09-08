local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,1,2,1,6,1,2,2,2,6,3,3,3,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local nItemRand = RandomInt(1, 2) == 1 and "item_black_king_bar" or "item_sphere"

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_double_branches",
    "item_faerie_fire",

    "item_bottle",
    "item_power_treads",
    "item_magic_wand",
    "item_witch_blade",
    "item_cyclone",
    "item_blink",
    "item_aghanims_shard",
    "item_devastator",--
    "item_ultimate_scepter",
    "item_mjollnir",--
    nItemRand,--
    "item_overwhelming_blink",--
    "item_travel_boots",
    "item_ultimate_scepter_2",
    "item_wind_waker",--
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_double_branches",
    "item_double_branches",

    "item_power_treads",
    "item_magic_wand",
    "item_witch_blade",
    "item_cyclone",
    "item_blink",
    "item_aghanims_shard",
    "item_devastator",--
    "item_ultimate_scepter",
    "item_mjollnir",--
    nItemRand,--
    "item_overwhelming_blink",--
    "item_travel_boots",
    "item_ultimate_scepter_2",
    "item_wind_waker",--
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
    Minion.MinionThink(hMinionUnit, bot)
end

local IllusoryOrb   = bot:GetAbilityByName('puck_illusory_orb')
local WaningRift    = bot:GetAbilityByName('puck_waning_rift')
local PhaseShift    = bot:GetAbilityByName('puck_phase_shift')
local EtherealJaunt = bot:GetAbilityByName('puck_ethereal_jaunt')
local DreamCoil     = bot:GetAbilityByName('puck_dream_coil')

local IllusoryOrbDesire, IllusoryOrbLocation
local WaningRiftDesire, WaningRiftLocation
local PhaseShiftDesire
local EtherealJauntDesire
local DreamCoilDesire, DreamCoilLocation

local PhaseOrbDesire, PhaseOrbLocation

local IsRetreatOrb = false

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    PhaseOrbDesire, PhaseOrbLocation, PhaseDuration = X.ConsiderPhaseOrb()
    if PhaseOrbDesire > 0
    then
        bot:Action_ClearActions(false)
        bot:ActionQueue_UseAbilityOnLocation(IllusoryOrb, PhaseOrbLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbility(PhaseShift)
        bot:ActionQueue_Delay(PhaseDuration - 0.3)
        bot:ActionQueue_UseAbility(EtherealJaunt)
        return
    end

    IllusoryOrbDesire, IllusoryOrbLocation = X.ConsiderIllusoryOrb()
    if IllusoryOrbDesire > 0
    then
        bot:Action_UseAbilityOnLocation(IllusoryOrb, IllusoryOrbLocation)
        return
    end

    PhaseShiftDesire = X.ConsiderPhaseShift()
    if PhaseShiftDesire > 0
    then
        bot:Action_UseAbility(PhaseShift)
        return
    end

    EtherealJauntDesire = X.ConsiderEtherealJaunt()
    if EtherealJauntDesire > 0
    then
        bot:Action_UseAbility(EtherealJaunt)
        return
    end

    DreamCoilDesire, DreamCoilLocation = X.ConsiderDreamCoil()
    if DreamCoilDesire > 0
    then
        bot:Action_UseAbilityOnLocation(DreamCoil, DreamCoilLocation)
        return
    end

    WaningRiftDesire, WaningRiftLocation = X.ConsiderWaningRift()
    if WaningRiftDesire > 0
    then
        bot:Action_UseAbilityOnLocation(WaningRift, WaningRiftLocation)
        return
    end
end

function X.ConsiderIllusoryOrb()
    if not IllusoryOrb:IsFullyCastable()
    or bot:HasModifier('modifier_puck_phase_shift')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, IllusoryOrb:GetCastRange())
    local nCastPoint = IllusoryOrb:GetCastPoint()
	local nRadius = IllusoryOrb:GetSpecialValueInt('radius')
    local nDamage = IllusoryOrb:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
    end

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
	end

    if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end
        end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1000, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and #nTargetInRangeAlly > #nInRangeAlly
            then
                IsRetreatOrb = true
                local loc = J.GetEscapeLoc()
		        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
            else
                IsRetreatOrb = false
            end
        end
    end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nLocationAoE.count >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        if nLocationAoE.count >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsFarming(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep() and nLocationAoE.count >= 2))
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and nLocationAoE.count >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    if J.IsLaning(bot)
	then
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			-- if  J.IsValid(creep)
			-- and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			-- and creep:GetHealth() <= nDamage
			-- then
			-- 	local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

			-- 	if  nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
            --     and J.GetMP(bot) > 0.35
			-- 	then
			-- 		return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
			-- 	end
			-- end

            if  J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                canKill = canKill + 1
                table.insert(creepList, creep)
            end
		end

        if  canKill >= 2
        and J.GetMP(bot) > 0.25
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderWaningRift()
    if not WaningRift:IsFullyCastable()
    or bot:HasModifier('modifier_puck_phase_shift')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastPoint = WaningRift:GetCastPoint()
	local nRadius = WaningRift:GetSpecialValueInt('radius')
    local nDamage = WaningRift:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius + 200, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
    end

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nRadius)
	end

    if J.IsInTeamFight(bot, 1200)
    then
        local realEnemyCount = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

        if realEnemyCount ~= nil and #realEnemyCount >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)

        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end
        end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.65 and bot:WasRecentlyDamagedByAnyHero(2)))
            then
                local loc = J.GetEscapeLoc()
		        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nRadius)
            end
        end
    end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), bot:GetAttackRange() + 150, nRadius, 0, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nLocationAoE.count >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsFarming(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), bot:GetAttackRange() + 150, nRadius, 0, 0)

        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep() and nLocationAoE.count >= 2))
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and nLocationAoE.count >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    if J.IsLaning(bot)
	then
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			-- if  J.IsValid(creep)
			-- and creep:GetHealth() <= nDamage
			-- then
			-- 	local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

			-- 	if  nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
            --     and J.GetMP(bot) > 0.35
			-- 	then
			-- 		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			-- 	end
			-- end

            if  J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                canKill = canKill + 1
                table.insert(creepList, creep)
            end
		end

        if  canKill >= 2
        and J.GetMP(bot) > 0.25
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderPhaseShift()
    if not PhaseShift:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nDuration = PhaseShift:GetSpecialValueInt('duration')

    if J.IsStunProjectileIncoming(bot, 600)
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsUnitTargetProjectileIncoming(bot, 400)
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if  not bot:HasModifier('modifier_sniper_assassinate')
	and not bot:IsMagicImmune()
	then
		if J.IsWillBeCastUnitTargetSpell(bot, 400)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local blink = bot:GetItemInSlot(bot:FindItemSlot('item_blink'))
		if  blink ~= nil
        and blink:GetCooldownTimeRemaining() < nDuration
        then
			return BOT_ACTION_DESIRE_HIGH
		end

		local nProjectiles = GetLinearProjectiles()
		for _, p in pairs(nProjectiles)
		do
			if  p ~= nil
            and p.ability:GetName() == 'puck_illusory_orb'
            then
				if GetUnitToLocationDistance(bot, p.location) < 300
                then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

    local realEnemyCount = J.GetEnemiesNearLoc(bot:GetLocation(), 800)
    local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)

    if  realEnemyCount ~= nil and #realEnemyCount >= 2
    and nInRangeAlly ~= nil and #realEnemyCount > #nInRangeAlly
    and bot:WasRecentlyDamagedByAnyHero(1.5)
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderEtherealJaunt()
    if not EtherealJaunt:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nAttackRange = bot:GetAttackRange()
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and not J.IsInRange(bot, botTarget, nAttackRange)
		then
			local nProjectiles = GetLinearProjectiles()

            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)
            local nTargetInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)

            if  nTargetInRangeEnemy ~= nil and nTargetInRangeAlly ~= nil
            and #nTargetInRangeEnemy >= #nTargetInRangeAlly
            then
                local nTargetInRangeTower = botTarget:GetNearbyTowers(700, false)

                for _, p in pairs(nProjectiles)
                do
                    if  p ~= nil
                    and p.ability:GetName() == 'puck_illusory_orb'
                    and not J.IsLocationInChrono(p.location)
                    then
                        if J.IsInLaningPhase()
                        then
                            if nTargetInRangeTower ~= nil and #nTargetInRangeTower == 0
                            then
                                if GetUnitToLocationDistance(botTarget, p.location) < nAttackRange * 1.15
                                then
                                    return BOT_ACTION_DESIRE_HIGH
                                end
                            end
                        else
                            if GetUnitToLocationDistance(botTarget, p.location) < nAttackRange * 1.15
                            then
                                local nInRangeAlly = J.GetAlliesNearLoc(p.location, 700)
                                local nInRangeEnemy = J.GetEnemiesNearLoc(p.location, 700)

                                if #nInRangeAlly >= #nInRangeEnemy
                                then
                                    if  #nInRangeAlly <= 1 and #nInRangeEnemy == 1
                                    and nTargetInRangeTower ~= nil and #nTargetInRangeAlly == 0
                                    then
                                        return BOT_ACTION_DESIRE_HIGH
                                    end

                                    if #nInRangeAlly >= 2
                                    then
                                        return BOT_ACTION_DESIRE_HIGH
                                    end
                                end
                            end
                        end
                    end
                end
            end
		end
	end

    if  J.IsRetreating(bot)
    and IsRetreatOrb
	then
		local nProjectiles = GetLinearProjectiles()

		for _, p in pairs(nProjectiles)
        do
            if  p.ability:GetName() == 'puck_illusory_orb'
            and not J.IsLocationInChrono(p.location)
            then
                if GetUnitToLocationDistance(bot, p.location) > 600
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDreamCoil()
    if not DreamCoil:IsFullyCastable()
    or bot:HasModifier('modifier_puck_phase_shift')
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, DreamCoil:GetCastRange())
	local nRadius = DreamCoil:GetSpecialValueInt('coil_radius')
    local nDuration = DreamCoil:GetSpecialValueInt('coil_duration')

    if J.IsInTeamFight(bot, 1200)
    then
		local nLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
        local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if  realEnemyCount ~= nil and #realEnemyCount >= 2
        and not J.IsLocationInChrono(nLocationAoE.targetloc)
        and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

		if  J.IsValidTarget(strongestTarget)
		and J.CanCastOnNonMagicImmune(strongestTarget)
        and not J.IsSuspiciousIllusion(strongestTarget)
        and not J.IsDisabled(strongestTarget)
        and not J.IsLocationInChrono(strongestTarget:GetLocation())
        and not J.IsLocationInBlackHole(strongestTarget:GetLocation())
        and not strongestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not strongestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not strongestTarget:HasModifier('modifier_oracle_false_promise_timer')
		then
			local nTargetInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                if  #nInRangeAlly == 1 and #nTargetInRangeAlly == 0
                and J.GetHP(strongestTarget) > 0.55
                and J.IsAttacking(bot)
                then
                    return BOT_ACTION_DESIRE_HIGH, strongestTarget:GetLocation()
                end

                if  #nInRangeAlly == 2 and #nTargetInRangeAlly == 0
                and J.GetHP(strongestTarget) > 0.2
                and J.IsRunning(strongestTarget)
                and not strongestTarget:IsFacingLocation(bot:GetLocation(), 90)
                then
                    return BOT_ACTION_DESIRE_HIGH, strongestTarget:GetLocation()
                end
            end
		end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
        local nInRangeTower = bot:GetNearbyTowers(700, false)

        if  nInRangeAlly ~= nil and realEnemyCount ~= nil
        then
            if  nInRangeTower ~= nil and #nInRangeTower == 0
            and #realEnemyCount > #nInRangeAlly
            and #realEnemyCount >= 3 and #nInRangeAlly <= 1
            and GetUnitToLocationDistance(bot, nLocationAoE.targetloc) < 700
            and GetUnitToLocationDistance(bot, GetAncient(GetTeam()):GetLocation()) > 3200
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function CanDoPhaseOrb()
    if  PhaseShift:IsFullyCastable()
    and IllusoryOrb:IsFullyCastable()
    then
        local nManaCost = PhaseShift:GetManaCost() + IllusoryOrb:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end

function X.ConsiderPhaseOrb()
    if CanDoPhaseOrb()
    then
        local nCastRange = J.GetProperCastRange(false, bot, IllusoryOrb:GetCastRange())
        local nDuration = PhaseShift:GetSpecialValueInt('duration')

        local realEnemyCount = J.GetEnemiesNearLoc(bot:GetLocation(), 800)
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)

        if  realEnemyCount ~= nil and #realEnemyCount >= 2
        and nInRangeAlly ~= nil and #realEnemyCount >= #nInRangeAlly
        then
            local loc = J.GetEscapeLoc()
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange), nDuration
        end

        if J.IsRetreating(bot)
        then
            local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and J.IsValidHero(nInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
            then
                local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1000, false, BOT_MODE_NONE)

                if  nTargetInRangeAlly ~= nil
                and #nTargetInRangeAlly > #nInRangeAlly
                then
                    local loc = J.GetEscapeLoc()
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange), nDuration
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

return X