local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sOutfitType   = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
                        {--pos1
                            ['t25'] = {0, 10},
                            ['t20'] = {10, 0},
                            ['t15'] = {0, 10},
                            ['t10'] = {0, 10},
                        },
                        {--pos2
                            ['t25'] = {0, 10},
                            ['t20'] = {10, 0},
                            ['t15'] = {0, 10},
                            ['t10'] = {0, 10},
                        }
}

local tAllAbilityBuildList = {
                        {2,3,2,3,3,6,2,2,1,1,6,1,1,3,6},--pos1
                        {2,3,2,3,3,6,2,2,1,1,1,6,1,3,6},--pos2
}

local nAbilityBuildList
local nTalentBuildList

if sOutfitType == "outfit_carry"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
elseif sOutfitType == "outfit_mid"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local tOutFitList = {}

tOutFitList['outfit_carry'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_magic_wand",
    "item_falcon_blade",
    "item_power_treads",
    "item_desolator",--
    "item_orchid",
    "item_dragon_lance",
    "item_aghanims_shard",
    "item_black_king_bar",--
    "item_bloodthorn",--
    "item_hurricane_pike",--
    "item_greater_crit",--
    "item_butterfly",--
    "item_moon_shard",
    "item_ultimate_scepter",
    "item_recipe_ultimate_scepter_2",
}

tOutFitList['outfit_mid'] = {
    "item_tango",
    "item_double_branches",
    "item_magic_stick",

    "item_bottle",
    "item_magic_wand",
    "item_power_treads",
    "item_desolator",--
    "item_orchid",
    "item_dragon_lance",
    "item_aghanims_shard",
    "item_black_king_bar",--
    "item_bloodthorn",--
    "item_hurricane_pike",--
    "item_sheepstick",--
    "item_butterfly",--
    "item_moon_shard",
    "item_ultimate_scepter",
    "item_recipe_ultimate_scepter_2",
}

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

Pos1SellList = {
	"item_quelling_blade",
    "item_magic_wand",
    "item_falcon_blade",
    "item_power_treads",
}

Pos2SellList = {
	"item_bottle",
    "item_magic_wand",
    "item_power_treads",
}

X['sSellList'] = {}

if sOutfitType == "outfit_carry"
then
    X['sSellList'] = Pos1SellList
elseif sOutfitType == "outfit_mid"
then
    X['sSellList'] = Pos2SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local Strafe            = bot:GetAbilityByName('clinkz_strafe')
local TarBomb           = bot:GetAbilityByName('clinkz_tar_bomb')
local DeathPact         = bot:GetAbilityByName('clinkz_death_pact')
local BurningBarrage    = bot:GetAbilityByName('clinkz_burning_barrage')
local BurningArmy       = bot:GetAbilityByName('clinkz_burning_army')
local SkeletonWalk      = bot:GetAbilityByName('clinkz_wind_walk')

local StrafeDesire
local TarBombDesire, TarBombTarget
local DeathPactDesire, DeathPactTarget
local BurningBarrageDesire, BurningBarrageLocation
local BurningArmyDesire, BurningArmyLocation
local SkeletonWalkDesire

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    SkeletonWalkDesire = X.ConsiderSkeletonWalk()
    if SkeletonWalkDesire > 0
    then
        bot:Action_UseAbility(SkeletonWalk)
        return
    end

    BurningBarrageDesire, BurningBarrageLocation = X.ConsiderBurningBarrage()
    if BurningBarrageDesire > 0
    then
        bot:Action_UseAbilityOnLocation(BurningBarrage, BurningBarrageLocation)
        return
    end

    DeathPactDesire, DeathPactTarget = X.ConsiderDeathPact()
    if DeathPactDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DeathPact, DeathPactTarget)
        return
    end

    StrafeDesire = X.ConsiderStrafe()
    if StrafeDesire > 0
    then
        bot:Action_UseAbility(Strafe)
        return
    end

    TarBombDesire, TarBombTarget = X.ConsiderTarBomb()
    if TarBombDesire > 0
    then
        bot:Action_UseAbilityOnEntity(TarBomb, TarBombTarget)
        return
    end

    BurningArmyDesire, BurningArmyLocation = X.ConsiderBurningArmy()
    if BurningArmyDesire > 0
    then
        bot:Action_UseAbilityOnLocation(BurningArmy, BurningArmyLocation)
        return
    end
end

function X.ConsiderStrafe()
    if not Strafe:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE
	end

    local nAttackRange = bot:GetAttackRange()

    if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nAttackRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier("modifier_abaddon_borrowed_time")
        and not botTarget:HasModifier("modifier_dazzle_shallow_grave")
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDoingRoshan(bot)
	then
		local botAttackTarget = bot:GetAttackTarget()

		if J.IsRoshan(botAttackTarget)
        and J.IsInRange(bot, botAttackTarget, nAttackRange)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsFarming(bot)
	then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1200)

		if nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		then
			return BOT_ACTION_DESIRE_HIGH
		end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTarBomb()
    if not TarBomb:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

    local nLevel = TarBomb:GetLevel()
    local nCastRange = TarBomb:GetCastRange()
    local nCastPoint = TarBomb:GetCastPoint()
    local nDamage = 40 + (20 * nLevel - 1)
    local nRadius = 325
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)
    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidTarget(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier("modifier_abaddon_borrowed_time")
        and not enemyHero:HasModifier("modifier_dazzle_shallow_grave")
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    for _, allyHero in pairs(nAllyHeroes)
    do
        local allyTarget = allyHero:GetTarget()

        if  J.IsValidTarget(allyTarget)
        and J.CanCastOnNonMagicImmune(allyTarget)
        and J.IsRetreating(allyHero)
        and J.GetHP(allyHero) < 0.5
        and nMana > 0.25
        and allyHero:WasRecentlyDamagedByAnyHero(4)
        and not allyHero:IsIllusion()
        and not J.IsSuspiciousIllusion(allyTarget)
        and not allyTarget:HasModifier("modifier_abaddon_borrowed_time")
        and not allyTarget:HasModifier("modifier_dazzle_shallow_grave")
        then
            return BOT_ACTION_DESIRE_HIGH, allyTarget
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier("modifier_abaddon_borrowed_time")
        and not botTarget:HasModifier("modifier_dazzle_shallow_grave")
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsRetreating(bot)
    then
        if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
        then
            if  J.IsValidTarget(nEnemyHeroes[1])
            and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
            and bot:WasRecentlyDamagedByHero(nEnemyHeroes[1], 2)
            and not J.IsSuspiciousIllusion(nEnemyHeroes[1])
            and not nEnemyHeroes[1]:HasModifier("modifier_abaddon_borrowed_time")
            and not nEnemyHeroes[1]:HasModifier("modifier_dazzle_shallow_grave")
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
            end
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nLocationAoECreeps = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nLocationAoEHeroes = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local botAttackTarget = bot:GetAttackTarget()

        if nLocationAoECreeps.count >= 4
        and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
        end

        if nLocationAoEHeroes.count >= 1
        and nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
        end

        if botAttackTarget ~= nil
        and botAttackTarget:IsBuilding()
        and J.CanBeAttacked(botAttackTarget)
        and J.IsInRange(bot, botAttackTarget, nCastRange)
        then
            return BOT_ACTION_DESIRE_HIGH, botAttackTarget
        end
    end

    if J.IsFarming(bot)
    then
        local nLocationAoECreeps = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)

        if nLocationAoECreeps.count >= 3
        and (nNeutralCreeps ~= nil and #nNeutralCreeps >= 3)
        and nMana > 0.5
        then
            return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
        end
    end

    if J.IsLaning(bot)
    then
        local nLocationAoECreeps = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        for _, creep in pairs(nEnemyLaneCreeps)
        do
            if J.IsKeyWordUnit("ranged", creep)
            or J.IsKeyWordUnit("siege", creep)
            then
                if creep:GetHealth() <= nDamage
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE, creep
                end
            end
        end

        if nLocationAoECreeps.count >= 2
        and (nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2)
        and nMana > 0.47
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
        end
    end

    if J.IsDoingRoshan(bot)
    then
        local botAttackTarget = bot:GetAttackTarget()

        if J.IsRoshan(botAttackTarget)
        and J.CanCastOnNonMagicImmune(botAttackTarget)
        and J.IsInRange(bot, botAttackTarget, nCastRange + nRadius)
        then
            return BOT_ACTION_DESIRE_HIGH, botAttackTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDeathPact()
    if not DeathPact:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = DeathPact:GetCastRange()
    local nCreepList = bot:GetNearbyCreeps(nCastRange, true)
    local nMaxLevel = DeathPact:GetSpecialValueInt("creep_level")

    local creep = GetMostHPCreepLevel(nCreepList, nMaxLevel)
    if creep ~= nil
    and not bot:WasRecentlyDamagedByAnyHero(2)
    and not bot:HasModifier("modifier_clinkz_death_pact")
    and not creep:IsAncientCreep()
    then
        return BOT_ACTION_DESIRE_HIGH, creep
    end

    if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 1600)
		then
			local targetCreep = GetMostHPCreepLevel(nCreepList, nMaxLevel)

			if targetCreep ~= nil
            and not bot:HasModifier("modifier_clinkz_death_pact")
            and not targetCreep:IsAncientCreep()
            then
				return BOT_ACTION_DESIRE_HIGH, targetCreep
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local targetCreep = GetMostHPCreepLevel(nCreepList, nMaxLevel)

		if targetCreep ~= nil
        and not bot:WasRecentlyDamagedByAnyHero(2)
        and not bot:HasModifier("modifier_clinkz_death_pact")
        and not targetCreep:IsAncientCreep()
        then
			return BOT_ACTION_DESIRE_LOW, targetCreep
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSkeletonWalk()
    if not SkeletonWalk:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local timeOfDay = J.CheckTimeOfDay()
    local roshanRadiantLoc  = Vector(7625, -7511, 1092)
    local roshanDireLoc     = Vector(-7549, 7562, 1107)

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsValidTarget(botTarget)
        and GetUnitToUnitDistance(bot, botTarget) > 1600
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

		if (nEnemyHeroes ~= nil and #nEnemyHeroes >= 1)
        or not J.WeAreStronger(bot, 1200)
        or J.GetHP(bot) < 0.5
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if timeOfDay == 'day'
        and GetUnitToLocationDistance(bot, roshanRadiantLoc) > 3200
        then
            return BOT_ACTION_DESIRE_HIGH
        elseif timeOfDay == 'night'
        and GetUnitToLocationDistance(bot, roshanDireLoc) > 3200
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

--Aghanim's Shard
function X.ConsiderBurningBarrage()
    if not BurningBarrage:IsTrained()
    or not BurningBarrage:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, BurningBarrage:GetCastRange())

	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, 200, 0, 0)

		if locationAoE.count >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange - 100)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier("modifier_abaddon_borrowed_time")
        and not botTarget:HasModifier("modifier_dazzle_shallow_grave")
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsFarming(bot)
    then
        local nLocationAoECreeps = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, 200, 0, 0)
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)

        if nLocationAoECreeps.count >= 2
        and (nNeutralCreeps ~= nil and #nNeutralCreeps >= 2)
        and nNeutralCreeps[1]:IsAncientCreep()
        then
            return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]:GetLocation()
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nLocationAoECreeps = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, 200, 0, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		if  nLocationAoECreeps.count >= 4
        and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]:GetLocation()
		end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

--Aghanim's Scepter
function X.ConsiderBurningArmy()
    if not BurningBarrage:IsTrained()
    or not BurningBarrage:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nAttackRange = bot:GetAttackRange()
	local nCastRange = BurningArmy:GetCastRange()
    local nSpawnRange = 900

	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nSpawnRange, 0, 0)

		if locationAoE.count >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + nAttackRange)
        and not J.IsSuspiciousIllusion(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

-- Helper Funcs
function GetMostHPCreepLevel(creeList, level)
	local mostHpCreep = nil
	local maxHP = 0

	for _, creep in pairs(creeList)
	do
		local uHp = creep:GetHealth()
        local lvl = creep:GetLevel()

		if uHp > maxHP
        and lvl <= level
        and not J.IsKeyWordUnit("flagbearer", creep)
		then
			mostHpCreep = creep
			maxHP = uHp
		end
	end

	return mostHpCreep
end

return X