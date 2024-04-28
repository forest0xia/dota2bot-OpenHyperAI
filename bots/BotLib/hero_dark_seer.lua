local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,3,2,1,2,6,2,3,3,3,1,6,1,1,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

local sUtility = {"item_crimson_guard", "item_pipe", "item_lotus_orb", "item_heavens_halberd"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mid'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_tank'] = {
    "item_tango",
    "item_quelling_blade",
    "item_double_branches",
    "item_circlet",
    "item_gauntlets",

    "item_magic_wand",
    "item_bracer",
    "item_arcane_boots",
    "item_shivas_guard",--
    "item_blink",
    nUtility,--
    "item_ultimate_scepter",
    "item_guardian_greaves",--
    "item_black_king_bar",--
    "item_aghanims_shard",
    "item_refresher",--
    "item_ultimate_scepter_2",
    "item_arcane_blink",--
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_priest'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mage'] = sRoleItemsBuyList['outfit_carry']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_quelling_blade",
    "item_magic_wand",
    "item_bracer",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local Vacuum            = bot:GetAbilityByName('dark_seer_vacuum')
local IonShell          = bot:GetAbilityByName('dark_seer_ion_shell')
local Surge             = bot:GetAbilityByName('dark_seer_surge')
-- local NormalPunch       = bot:GetAbilityByName('dark_seer_normal_punch')
local WallOfReplica     = bot:GetAbilityByName('dark_seer_wall_of_replica')

local VacuumDesire, VacuumLocation
local IonShellDesire, IonShellTarget
local SurgeDesire, SurgeTarget
local WallOfReplicaDesire, WallOfReplicaLocation

local VacuumWallDesire

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    VacuumWallDesire, Loc = X.ConsiderVacuumWall()
    if  VacuumWallDesire > 0
    and J.IsInTeamFight(bot, 1200)
    then
        bot:Action_ClearActions(false)

        BlinkDesire, Blink, BlinkLocation = ConsiderBlink()
        if BlinkDesire > 0
        then
            bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
            bot:ActionQueue_UseAbilityOnLocation(Vacuum, Loc)
            bot:ActionQueue_UseAbilityOnLocation(WallOfReplica, Loc)
        else
            bot:ActionQueue_UseAbilityOnLocation(Vacuum, Loc)
            bot:ActionQueue_UseAbilityOnLocation(WallOfReplica, Loc)
        end

        return
    end

    VacuumDesire, VacuumLocation = X.ConsiderVacuum()
    if VacuumDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Vacuum, VacuumLocation)
        return
    end

    WallOfReplicaDesire, WallOfReplicaLocation = X.ConsiderWallOfReplica()
    if WallOfReplicaDesire > 0
    then
        bot:Action_UseAbilityOnLocation(WallOfReplica, WallOfReplicaLocation)
        return
    end

    SurgeDesire, SurgeTarget = X.ConsiderSurge()
    if SurgeDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Surge, SurgeTarget)
        return
    end

    IonShellDesire, IonShellTarget = X.ConsiderIonShell()
    if IonShellDesire > 0
    then
        bot:Action_UseAbilityOnEntity(IonShell, IonShellTarget)
        return
    end
end

function X.ConsiderVacuum()
    if not Vacuum:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, Vacuum:GetCastRange())
    local nRadius = Vacuum:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)
    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if nLocationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
    and not CanDoVacuumWall()
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier("modifier_legion_commander_duel")
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsRetreating(bot)
    and not CanDoVacuumWall()
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if  bot:WasRecentlyDamagedByHero(enemyHero, 2.0)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsRealInvisible(bot)
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderIonShell()
	if not IonShell:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, IonShell:GetCastRange())
    local nRadius = IonShell:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)
    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

    if J.IsInTeamFight(bot, 1200)
    or J.IsGoingOnSomeone(bot)
	then
		local target = nil
		local maxTargetCount = 1

        if nAllyHeroes ~= nil and #nAllyHeroes >= 1
        then
            for _, allyHero in pairs(nAllyHeroes)
            do
                if J.IsValid(allyHero)
                and not allyHero:IsIllusion()
                and not allyHero:HasModifier("modifier_dark_seer_ion_shell")
                then
                    local nAllyCount = 0
                    local nAllyEnemyHeroes = allyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                    local nAllyEnemyCreeps = allyHero:GetNearbyCreeps(1200, true)

                    for _, allyEnemyHero in pairs(nAllyEnemyHeroes)
                    do
                        if  allyEnemyHero ~= nil
                        and allyEnemyHero:IsAlive()
                        and allyEnemyHero:GetAttackTarget() == allyHero
                        and not J.IsSuspiciousIllusion(allyEnemyHero)
                        and allyHero:GetAttackRange() <= 326
                        then
                            nAllyCount = nAllyCount + 1
                        end
                    end

                    for _, creep in pairs(nAllyEnemyCreeps)
                    do
                        if  creep ~= nil
                        and creep:IsAlive()
                        and creep:GetAttackTarget() == allyHero
                        and creep:GetAttackRange() <= 326
                        then
                            nAllyCount = nAllyCount + 1
                        end
                    end

                    if nAllyCount > maxTargetCount
                    then
                        maxTargetCount = nAllyCount
                        target = allyHero
                    end
                end
            end
        else
            if  J.IsValidTarget(botTarget)
            and J.IsInRange(bot, botTarget, nRadius)
            and not J.IsSuspiciousIllusion(botTarget)
            and not bot:HasModifier("modifier_dark_seer_ion_shell")
            then
                target = bot
            end
        end

        if target ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, target
        end
	end

    if J.IsRetreating(bot)
    then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nRadius)
            and J.GetHP(bot) < 0.5
            and bot:WasRecentlyDamagedByHero(enemyHero, 2.5)
            and not bot:HasModifier("modifier_dark_seer_ion_shell")
            and not J.IsRealInvisible(bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
    end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
        if nEnemyHeroes[1] == nil
        then
            local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, false)
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

            if  nAllyLaneCreeps ~= nil and nEnemyLaneCreeps ~= nil
            and #nAllyLaneCreeps >= 1 and #nEnemyLaneCreeps == 0
            then
                local targetCreep = nil
                local targetDis = 0

                for _, creep in pairs(nAllyLaneCreeps)
                do
                    if  J.IsValid(creep)
                    and J.GetHP(creep) > 0.75
                    and creep:DistanceFromFountain() > targetDis
                    and creep:GetAttackRange() <= 326
                    then
                        targetCreep = creep
                        targetDis = creep:DistanceFromFountain()
                    end
                end

                if targetCreep ~= nil
                then
                    return BOT_ACTION_DESIRE_HIGH, targetCreep
                end
            end
        end
	end

    if J.IsFarming(bot)
    then
        local botAttackTarget = bot:GetAttackTarget()
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius + bot:GetAttackRange())

        if  J.IsValid(botAttackTarget)
        and botAttackTarget:IsCreep()
        and nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
        then
            if not bot:HasModifier("modifier_dark_seer_ion_shell")
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
    end

    if J.IsDoingRoshan(bot)
	then
		local botAttackTarget = bot:GetAttackTarget()

		if  J.IsRoshan(botAttackTarget)
        and J.IsInRange(bot, botAttackTarget, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSurge()
	if not Surge:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, Surge:GetCastRange())
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 1200)
        and not J.IsSuspiciousIllusion(botTarget)
		then
            local nAllyHeroes = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			local tToMeDist = GetUnitToUnitDistance(bot, botTarget)
			local targetHero = bot

			for _, allyHero in pairs(nAllyHeroes)
            do
                local allyTarget = J.GetProperTarget(allyHero)
				local dist = GetUnitToUnitDistance(allyHero, botTarget)

				if  dist < tToMeDist
                and dist < nCastRange
                and J.IsValidTarget(allyTarget)
                and not J.IsSuspiciousIllusion(allyTarget)
                and allyHero:IsFacingLocation(allyTarget:GetLocation(), 30)
                then
					tToMeDist = dist
					targetHero = allyHero
				end
			end

			return BOT_ACTION_DESIRE_HIGH, targetHero
		end
	end

	if J.IsRetreating(bot)
	then
        if  bot:WasRecentlyDamagedByAnyHero(2.5)
        and J.GetHP(bot) < 0.75
        and not J.IsRealInvisible(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
	end

	local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
    do
		if  J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and not allyHero:IsIllusion()
        and not J.IsDisabled(allyHero)
		then
            return BOT_ACTION_DESIRE_HIGH, allyHero
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderWallOfReplica()
	if not WallOfReplica:IsFullyCastable()
    or CanDoVacuumWall()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = WallOfReplica:GetCastRange()
	local nCastPoint = WallOfReplica:GetCastPoint()
	local nVacuumRadius = Vacuum:GetSpecialValueInt('radius')

	if J.IsInTeamFight(bot, 1200)
	then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nVacuumRadius, nCastPoint, 0)

        if nLocationAoE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderVacuumWall()
    if CanDoVacuumWall()
    then
        local nWallOfReplicaCastPoint = WallOfReplica:GetCastPoint()
        local nVacuumCastRange = Vacuum:GetCastRange()
        local nVacuumRadius = Vacuum:GetSpecialValueInt('radius')
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nVacuumCastRange, nVacuumRadius, nWallOfReplicaCastPoint, 0)

        if  nLocationAoE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoVacuumWall()
    if  Vacuum:IsFullyCastable()
    and WallOfReplica:IsFullyCastable()
    then
        local manaCost = Vacuum:GetManaCost() + WallOfReplica:GetManaCost()

        if  bot:GetMana() >= manaCost
        then
            return true
        end
    end

    return false
end

function ConsiderBlink()
    local Blink = nil

    for i = 0, 5 do
		local item = bot:GetItemInSlot(i)

		if item ~= nil
        and (item:GetName() == "item_blink" or item:GetName() == "item_overwhelming_blink" or item:GetName() == "item_arcane_blink" or item:GetName() == "item_swift_blink")
        then
			Blink = item
			break
		end
	end

    if  Blink ~= nil
    and Blink:IsFullyCastable()
    and Vacuum:IsFullyCastable()
    and WallOfReplica:IsFullyCastable()
	then
        local nWallOfReplicaCastPoint = WallOfReplica:GetCastPoint()
        local nVacuumCastRange = Vacuum:GetCastRange()
        local nVacuumRadius = Vacuum:GetSpecialValueInt('radius')
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nVacuumCastRange, nVacuumRadius, nWallOfReplicaCastPoint, 0)

        if  nLocationAoE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, Blink, nLocationAoE.targetloc
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil, 0
end

return X