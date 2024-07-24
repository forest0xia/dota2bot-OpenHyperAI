-- Currently bugged internally. Just adding her here in case Valve fixes her and (others) in the future...
-- She won't be selected.

local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,4,1,2,2,2,4,3,3,3,4},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_double_tango",
    "item_enchanted_mango",
    "item_double_branches",
    "item_blood_grenade",

    "item_boots",
    "item_magic_wand",
    "item_tranquil_boots",
    "item_cyclone",
    "item_aghanims_shard",
    "item_force_staff",--
    "item_aether_lens",--
    "item_boots_of_bearing",--
    "item_ultimate_scepter",--
    "item_octarine_core",--
    "item_wind_waker",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_double_tango",
    "item_enchanted_mango",
    "item_double_branches",
    "item_blood_grenade",

    "item_boots",
    "item_magic_wand",
    "item_arcane_boots",
    "item_cyclone",
    "item_aghanims_shard",
    "item_force_staff",--
    "item_aether_lens",--
    "item_guardian_greaves",--
    "item_ultimate_scepter",--
    "item_octarine_core",--
    "item_wind_waker",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
    "item_double_tango",
    "item_enchanted_mango",
    "item_double_branches",

    "item_boots",
    "item_magic_wand",
    "item_tranquil_boots",
    "item_cyclone",
    "item_aghanims_shard",
    "item_force_staff",--
    "item_aether_lens",--
    "item_boots_of_bearing",--
    "item_ultimate_scepter",--
    "item_octarine_core",--
    "item_wind_waker",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos4SellList = {
	"item_magic_wand",
}

Pos5SellList = {
	"item_magic_wand",
}

X['sSellList'] = {}

if sRole == "pos_5"
then
    X['sSellList'] = Pos5SellList
else
    X['sSellList'] = Pos4SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
	Minion.MinionThink(hMinionUnit, bot)
end

local BrambleMaze   = bot:GetAbilityByName('dark_willow_bramble_maze')
local ShadowRealm   = bot:GetAbilityByName('dark_willow_shadow_realm')
local CurseCrown    = bot:GetAbilityByName('dark_willow_cursed_crown')
local Bedlam        = bot:GetAbilityByName('dark_willow_bedlam')
local Terrorize     = bot:GetAbilityByName('dark_willow_terrorize')

local BrambleMazeDesire, BrambleMazeLocation
local ShadowRealmDesire
local CurseCrownDesire, CurseCrownTarget
local BedlamDesire, BedlamTarget
local TerrorizeDesire, TerrorizeLocation

local BedlamTime    = 0
local TerrorizeTime = 0

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    BrambleMazeDesire, BrambleMazeLocation = X.ConsiderBrambleMaze()
    if BrambleMazeDesire > 0
    then
        bot:Action_UseAbilityOnLocation(BrambleMaze, BrambleMazeLocation)
        return
    end

    BedlamDesire, BedlamTarget = X.ConsiderBedlam()
    if BedlamDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Bedlam, BedlamTarget)
        BedlamTime = DotaTime()
        return
    end

    ShadowRealmDesire = X.ConsiderShadowRealm()
    if ShadowRealmDesire > 0
    then
        bot:Action_UseAbility(ShadowRealm)
    end

    CurseCrownDesire, CurseCrownTarget = X.ConsiderCurseCrown()
    if CurseCrownDesire > 0
    then
        bot:Action_UseAbilityOnEntity(CurseCrown, CurseCrownTarget)
        return
    end

    TerrorizeDesire, TerrorizeLocation = X.ConsiderTerrorize()
    if TerrorizeDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Terrorize, TerrorizeLocation)
        TerrorizeTime = DotaTime()
        return
    end
end

function X.ConsiderBrambleMaze()
    if not BrambleMaze:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = BrambleMaze:GetCastRange()
	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValid(enemyHero)
		and (enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero))
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
			return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsMoving(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	if  J.IsRetreating(bot)
    and	J.IsValid(nEnemyHeroes[1])
    and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
    and not J.IsDisabled(nEnemyHeroes[1])
    and not J.IsRealInvisible(bot)
    and not J.IsSuspiciousIllusion(nEnemyHeroes[1])
	then
		return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]:GetLocation()
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderShadowRealm()
    if not ShadowRealm:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRangeBonus = ShadowRealm:GetSpecialValueInt('attack_range_bonus')
    local nAttackRange = bot:GetAttackRange()
    local nEnemyHeroes = J.GetNearbyHeroes(bot,nAttackRange + nRangeBonus, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		if  J.GetHP(bot) < 0.5
        and J.IsValidHero(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not J.IsRealInvisible(bot)
        and nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  (J.IsRetreating(bot) or (J.IsRetreating(bot) and J.GetHP(bot) < 0.6 and bot:WasRecentlyDamagedByAnyHero(2)))
    and not J.IsRealInvisible(bot)
    and nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
	then
        if (J.DidEnemyCastAbility() or J.GetHP(bot) < 0.5 or J.IsStunProjectileIncoming(bot, 800))
        then
            return BOT_ACTION_DESIRE_HIGH
        end

		return BOT_ACTION_DESIRE_MODERATE
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCurseCrown()
	if not CurseCrown:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, CurseCrown:GetCastRange())
    local nMana = bot:GetMana() / bot:GetMaxMana()
	local nEnemysHeroesInRange = J.GetNearbyHeroes(bot,nCastRange + 50, true, BOT_MODE_NONE)
	local nEnemysHeroesInBonus = J.GetNearbyHeroes(bot,nCastRange + 150, true, BOT_MODE_NONE)
	local nWeakestEnemyHeroInRange = J.GetWeakestUnit(nEnemysHeroesInRange)
	local nWeakestEnemyHeroInBonus = J.GetWeakestUnit(nEnemysHeroesInBonus)

	local nTowers = bot:GetNearbyTowers(900, true)

	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0
		local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 100, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsDisabled(enemyHero)
			then
				local npcEnemyDamage = enemyHero:GetEstimatedDamageToTarget(false, bot, 3.5, DAMAGE_TYPE_ALL)

				if npcEnemyDamage > nMostDangerousDamage
				then
					nMostDangerousDamage = npcEnemyDamage
					npcMostDangerousEnemy = enemyHero
				end
			end
		end

		if npcMostDangerousEnemy ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsRetreating(bot)
	then
		for _, enemyHero in pairs(nEnemysHeroesInRange)
		do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and bot:WasRecentlyDamagedByHero(enemyHero, 3.5)
            and bot:IsFacingLocation(enemyHero:GetLocation(), 45)
            and not J.IsDisabled(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end
		end
	end

	if  bot:WasRecentlyDamagedByAnyHero(2)
    and nEnemysHeroesInRange[1] ~= nil
    and #nEnemysHeroesInRange >= 1
	then
		for _, enemyHero in pairs(nEnemysHeroesInRange)
		do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and bot:IsFacingLocation(enemyHero:GetLocation(), 30)
            and not J.IsDisabled(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end
		end
	end


	if (J.IsLaning(bot) and #nTowers == 0) or DotaTime() > 12 * 60
	then
		if nMana > 0.7
		then
			if  J.IsValidHero(nWeakestEnemyHeroInRange)
            and not J.IsDisabled(nWeakestEnemyHeroInRange)
			then
                return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange
			end
		end

		if nMana > 0.88
		then
			local nEnemysCreeps = bot:GetNearbyCreeps(1200, true)

			if  J.IsValidHero(nWeakestEnemyHeroInBonus)
            and J.GetHP(bot) > 0.6
            and #nTowers == 0
            and ((#nEnemysCreeps + #nEnemysHeroesInBonus ) <= 5 or DotaTime() > 12 * 60)
            and not J.IsDisabled(nWeakestEnemyHeroInBonus)
			then
                return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInBonus
			end
		end

		if  J.IsValidHero(nWeakestEnemyHeroInRange)
        and J.GetHP(nWeakestEnemyHeroInRange) < 0.4
		then
            return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBedlam()
    if not Bedlam:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    if Terrorize:IsTrained()
    then
        local nFearDuration = Bedlam:GetSpecialValueInt('destination_status_duration')
        if DotaTime() - TerrorizeTime <= nFearDuration
        then
            return BOT_ACTION_DESIRE_NONE, nil
        end
    end

    local nCastRange = J.GetProperCastRange(false, bot, Bedlam:GetCastRange())
    local botTarget = J.GetProperTarget(bot)

	if J.IsInTeamFight(bot, 1200)
	then
        local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)

        if nAllyHeroes ~= nil and #nAllyHeroes >= 1
        then
            local allyTarget = nAllyHeroes[1]

            for _, allyHero in pairs(nAllyHeroes)
            do
                local maxHealth = 0

                if  allyHero:GetHealth() > maxHealth
                and allyHero:GetAttackRange() <= 326
                and J.IsCore(allyHero)
                then
                    maxHealth = allyHero:GetHealth()
                    allyTarget = allyHero
                end
            end

            return BOT_ACTION_DESIRE_HIGH, allyTarget
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
        local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 100, true, BOT_MODE_NONE)

        if  nAllyHeroes ~= nil and #nAllyHeroes <= 1
        and nEnemyHeroes ~= nil and #nEnemyHeroes <= 1
        and J.IsValidTarget(botTarget)
        then
            local allyTarget = nAllyHeroes[1]

            for _, allyHero in pairs(nAllyHeroes)
            do
                local maxHealth = 0

                if  allyHero:GetHealth() > maxHealth
                and allyHero:GetAttackRange() <= 326
                and J.IsInRange(allyHero, botTarget, 300)
                then
                    maxHealth = allyHero:GetHealth()
                    allyTarget = allyHero
                end
            end

            return BOT_ACTION_DESIRE_HIGH, allyTarget
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderTerrorize()
    if not Terrorize:IsFullyCastable()
    or DotaTime() - BedlamTime <= 5
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, Terrorize:GetCastRange())
	local nRadius   = Terrorize:GetSpecialValueInt('destination_radius')

	if J.IsInTeamFight(bot, 1200)
	then
        local nTeamFightLocation = J.GetTeamFightLocation(bot)
		local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
        local nDisabledAllies = 0
        local nInArenaEnemy = 0
        local IsCoreAllyInChronosphere = false
        local nChronodAlly = nil

        if nTeamFightLocation ~= nil
        then
            nAllyHeroes = J.GetAlliesNearLoc(nTeamFightLocation, nRadius)
        end

        -----
        local nEnemyHeroes = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and enemyHero:HasModifier('modifier_mars_arena_of_blood')
            then
                nInArenaEnemy = nInArenaEnemy + 1
            end
        end

        if nInArenaEnemy >= 2
        then
			local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

			if nLocationAoE.count >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
		end
        -----

		for _, allyHero in pairs(nAllyHeroes)
        do
			if  J.IsValidHero(allyHero)
            and J.IsDisabled(false, allyHero)
            and not allyHero:IsIllusion()
            then
				nDisabledAllies = nDisabledAllies + 1
			end

            -----
            if  J.IsValidHero(allyHero)
            and J.IsCore(allyHero)
            and allyHero:HasModifier('modifier_faceless_void_chronosphere')
            then
                local nNearbyEnemyWithAlly = J.GetNearbyHeroes(allyHero, 400, true, BOT_MODE_NONE)

                if nNearbyEnemyWithAlly ~= nil and #nNearbyEnemyWithAlly >= 1
                then
                    IsCoreAllyInChronosphere = true
                    nChronodAlly = allyHero
                    break
                end
            end
            -----
		end

        -----
        if  nChronodAlly ~= nil
        and IsCoreAllyInChronosphere
        then
            return BOT_ACTION_DESIRE_HIGH, ChronodAlly:GetLocation()
        end
        -----

		if nDisabledAllies >= 2
        then
			local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

			if nLocationAoE.count >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if  bot:WasRecentlyDamagedByAnyHero(2.0)
        and #nEnemyHeroes >= 2
		then
			local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

			if nLocationAoE.count >= 2
			then
				return BOT_ACTION_DESIRE_MODERATE, nLocationAoE.targetloc
			end
		end
	end

    local nAllyHeroes = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero) or (J.IsRetreating(allyHero) and J.GetHP(allyHero) < 0.4)
        and J.IsCore(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, allyHero:GetLocation(), nCastRange, nRadius, 0, 0)

			if nLocationAoE.count >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

return X