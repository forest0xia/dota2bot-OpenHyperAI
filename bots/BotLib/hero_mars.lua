-- Credit goes to Furious Puppy for Bot Experiment

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
							['t15'] = {0, 10},
							['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
							{2,1,1,2,1,6,1,2,2,3,6,3,3,3,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sUtility = {"item_pipe", "item_lotus_orb", "item_heavens_halberd", "item_crimson_guard"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
	"item_double_branches",
    "item_quelling_blade",

	"item_double_bracer",
	"item_boots",
	"item_magic_wand",
    "item_phase_boots",
	"item_soul_ring",
    "item_blink",
	"item_cyclone",
    "item_black_king_bar",--
    "item_aghanims_shard",
    nUtility,--
    "item_octarine_core",--
	"item_wind_waker",--
    "item_travel_boots",
    "item_overwhelming_blink",--
	"item_travel_boots_2",--
    "item_moon_shard",
    "item_ultimate_scepter_2"
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_quelling_blade",
	"item_bracer",
	"item_magic_wand",
	"item_soul_ring",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local SpearOfMars 	= bot:GetAbilityByName('mars_spear')
local GodsRebuke 	= bot:GetAbilityByName('mars_gods_rebuke')
local Bulwark 		= bot:GetAbilityByName('mars_bulwark')
local ArenaOfBlood 	= bot:GetAbilityByName('mars_arena_of_blood')

local SpearOfMarsDesire, SpearOfMarsLocation
local GodsRebukeDesire, GodsRebukeLocation
local BulwarkDesire
local ArenaOfBloodDesire, ArenaOfBloodLocation

local SpearToAllyDesire, SpearToAllyLocation

local Blink
local BlinkLocation

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

	botTarget = J.GetProperTarget(bot)

	SpearToAllyDesire, SpearToAllyLocation = X.ConsiderSpearToAlly()
	if SpearToAllyDesire > 0
	then
		bot:Action_ClearActions(false)
		bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
		bot:ActionQueue_Delay(0.1)
		bot:ActionQueue_UseAbilityOnLocation(SpearOfMars, SpearToAllyLocation)
		return
	end

	ArenaOfBloodDesire, ArenaOfBloodLocation = X.ConsiderArenaOfBlood()
	if ArenaOfBloodDesire > 0
	then
		bot:Action_UseAbilityOnLocation(ArenaOfBlood, ArenaOfBloodLocation)
		return
	end

	GodsRebukeDesire, GodsRebukeLocation = X.ConsiderGodsRebuke()
	if GodsRebukeDesire > 0
	then
		bot:Action_UseAbilityOnLocation(GodsRebuke, GodsRebukeLocation)
		return
	end

	SpearOfMarsDesire, SpearOfMarsLocation = X.ConsiderSpearOfMars()
	if SpearOfMarsDesire > 0
	then
		bot:Action_UseAbilityOnLocation(SpearOfMars, SpearOfMarsLocation)
		return
	end

	BulwarkDesire = X.ConsiderBulwark()
	if BulwarkDesire > 0
	then
		bot:Action_UseAbility(Bulwark)
		return
	end
end

function X.ConsiderSpearOfMars()
	if not SpearOfMars:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, SpearOfMars:GetCastRange())
	local nCastPoint = SpearOfMars:GetCastPoint()
	local nRadius = SpearOfMars:GetSpecialValueInt('spear_width')
	local nSpeed = SpearOfMars:GetSpecialValueInt('spear_speed')
	local nDamage = SpearOfMars:GetSpecialValueInt('damage')
	local nAbilityLevel = SpearOfMars:GetLevel()

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
			end

			if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			and not enemyHero:HasModifier('modifier_oracle_false_promise')
			and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
			then
				local eta = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(eta)
			end
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if  J.IsGoingOnSomeone(bot)
	and not CanSpearToAlly()
	then
		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
				if J.IsInLaningPhase()
				then
					if bot:GetEstimatedDamageToTarget(true, botTarget, 3, DAMAGE_TYPE_ALL) >= botTarget:GetHealth()
					then
						local eta = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
						return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(eta)
					end
				else
					local eta = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
					return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(eta)
				end
			end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
        do
			if  J.IsValidHero(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and J.IsChasingTarget(enemyHero, bot)
			and J.IsInRange(bot, enemyHero, nCastRange / 1.5)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_legion_commander_duel')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

				if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and ((#nTargetInRangeAlly > #nInRangeAlly)
					or bot:WasRecentlyDamagedByHero(enemyHero, 1.5))
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
				end
			end
        end

        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end
        end
	end

	if  J.IsPushing(bot) or J.IsDefending(bot)
	and nAbilityLevel >= 3
	and J.GetMP(bot) > 0.8
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		and nLocationAoE.count >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	-- if J.IsLaning(bot)
	-- then
	-- 	local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

	-- 	for _, creep in pairs(nEnemyLaneCreeps)
	-- 	do
	-- 		if  J.IsValid(creep)
	-- 		and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
	-- 		and creep:GetHealth() <= nDamage
	-- 		then
	-- 			local nCreepInRangeHero = creep:GetNearbyHeroes(creep:GetCurrentVisionRange(), true, BOT_MODE_NONE)

	-- 			if  nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
	-- 			and GetUnitToUnitDistance(creep, nCreepInRangeHero[1]) <= 400
	-- 			and J.GetMP(bot) > 0.75
	-- 			and J.GetHP(nCreepInRangeHero[1]) > 0.65
	-- 			then
	-- 				return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
	-- 			end
	-- 		end
	-- 	end
	-- end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        if  J.IsValidHero(allyHero)
		and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and not allyHero:IsIllusion()
		and J.GetMP(bot) > 0.75
        then
			local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
				local eta = (GetUnitToUnitDistance(bot, nAllyInRangeEnemy[1]) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(eta + 1)
            end
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
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderGodsRebuke()
    if not GodsRebuke:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nRadius = GodsRebuke:GetSpecialValueInt('radius')
	local nDamage = bot:GetAttackDamage() * GodsRebuke:GetSpecialValueInt('crit_mult') / 100
	local nAbilityLevel = GodsRebuke:GetLevel()

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
		and J.CanCastOnMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nRadius)
		and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		and not enemyHero:HasModifier('modifier_oracle_false_promise')
		and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
		end
	end

	if J.IsInTeamFight(bot, 1300)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nRadius, nRadius, 0, 0)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 75)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_aphotic_shield')
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end

			if  J.IsValidHero(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and J.IsInRange(bot, enemyHero, nRadius)
			and J.IsChasingTarget(enemyHero, bot)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			and SpearOfMars:IsTrained() and not SpearOfMars:IsFullyCastable()
			then
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

				if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and ((#nTargetInRangeAlly > #nInRangeAlly)
					or bot:WasRecentlyDamagedByHero(enemyHero, 2))
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
				end
			end
        end
	end

	if  J.IsPushing(bot) or J.IsDefending(bot)
	and nAbilityLevel >= 3
	and J.GetMP(bot) > 0.5
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
		end
	end

	if  J.IsFarming(bot)
	and nAbilityLevel >= 3
	and J.GetMP(bot) > 0.5
	then
        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
        end
	end

	if  J.IsLaning(bot)
	and J.GetMP(bot) > 0.33
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
		local aveCreepHealth = 0
		local creepList = {}

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
		then
			for _, creep in pairs(nEnemyLaneCreeps)
			do
				if  J.IsValid(creep)
				and J.CanBeAttacked(creep)
				then
					aveCreepHealth = aveCreepHealth + creep:GetHealth()
					table.insert(creepList, creep)

					local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)
					if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
					and creep:GetHealth() <= nDamage
					then
						return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
					end
				end
			end

			if  #creepList >= 1
			and (aveCreepHealth / #creepList) <= nDamage
			then
				return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
			end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,600, false, BOT_MODE_NONE)

        if  J.IsRoshan(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and nInRangeAlly ~= nil and #nInRangeAlly >= 2
        and J.IsAttacking(nInRangeAlly[1])
        and J.IsAttacking(nInRangeAlly[2])
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBulwark()
    if not Bulwark:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRange = Bulwark:GetSpecialValueInt('soldier_offset')

	if  J.IsRetreating(bot)
	and not Bulwark:GetToggleState()
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)

		if #nInRangeAlly >= 1
		then
			local numFacing = 0
			local nInRangeEnemy = J.GetNearbyHeroes(bot,bot:GetCurrentVisionRange(), true, BOT_MODE_NONE)

			for _, enemyHero in pairs(nInRangeEnemy)
			do
				if  J.IsValidHero(enemyHero)
				and J.CanCastOnMagicImmune(enemyHero)
				and bot:IsFacingLocation(enemyHero:GetLocation(), 15)
				and not J.IsSuspiciousIllusion(enemyHero)
				and not J.IsDisabled(enemyHero)
				then
					numFacing = numFacing + 1
				end
			end

			if  numFacing >= 1
			and nInRangeEnemy ~= nil
			and #nInRangeEnemy > #nInRangeAlly
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	if  J.IsGoingOnSomeone(bot)
	and J.IsInRange(bot, botTarget, nRange)
	and Bulwark:GetToggleState()
	then
		if bot:HasScepter()
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	local nEnemyHeroes = J.GetNearbyHeroes(bot,bot:GetCurrentVisionRange(), true, BOT_MODE_NONE)
	if  nEnemyHeroes ~= nil and #nEnemyHeroes == 0
	and Bulwark:GetToggleState()
	then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderArenaOfBlood()
    if not ArenaOfBlood:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, ArenaOfBlood:GetCastRange())
	local nCastPoint = ArenaOfBlood:GetCastPoint()
	local nRadius = ArenaOfBlood:GetSpecialValueInt('radius')
	local nDuration = ArenaOfBlood:GetSpecialValueInt('duration')

	if J.IsInTeamFight(bot, 1300)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
		and not J.IsLocationInChrono(nLocationAoE.targetloc)
		and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
		and not J.IsLocationInArena(nLocationAoE.targetloc, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange + nRadius)
		and J.IsCore(botTarget)
		and (J.IsAttacking(bot) or J.IsChasingTarget(bot, botTarget))
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsLocationInChrono(botTarget:GetLocation())
		and not J.IsLocationInBlackHole(botTarget:GetLocation())
		and not J.IsLocationInArena(botTarget:GetLocation(), nRadius)
		then
			local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			and not (#nInRangeAlly >= #nInRangeEnemy + 2)
			and bot:GetEstimatedDamageToTarget(true, botTarget, nDuration, DAMAGE_TYPE_ALL) >= botTarget:GetHealth()
			then
				return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
			end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nInRangeEnemy)
        do
			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and J.IsValidHero(enemyHero)
			and J.IsChasingTarget(enemyHero, bot)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not nInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
			and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

				if  nTargetInRangeAlly ~= nil
				and #nTargetInRangeAlly > #nInRangeAlly + 2
				and #nInRangeAlly <= 1
				then
					local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
					local nTargetLocInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

					if  nTargetLocInRangeEnemy ~= nil and #nTargetLocInRangeEnemy >= 1
					and not J.IsLocationInChrono(nLocationAoE.targetloc)
					and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
					and not J.IsLocationInArena(nLocationAoE.targetloc, nRadius)
					then
						return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
					end
				end
			end
        end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSpearToAlly()
    if CanSpearToAlly()
    then
		local nCastPoint = SpearOfMars:GetCastPoint()
		local nSpeed = SpearOfMars:GetSpecialValueInt('spear_speed')

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, 1199)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			and #nInRangeAlly >= 1
			then
				local eta = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) / nCastPoint
				BlinkLocation = botTarget:GetExtrapolatedLocation(eta)
				return BOT_ACTION_DESIRE_HIGH, nInRangeAlly[#nInRangeAlly]:GetLocation()
			end
		end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanSpearToAlly()
    if  SpearOfMars:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = SpearOfMars:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end

function HasBlink()
    local blink = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if item ~= nil
        and (item:GetName() == "item_blink" or item:GetName() == "item_overwhelming_blink" or item:GetName() == "item_arcane_blink" or item:GetName() == "item_swift_blink")
        then
			blink = item
			break
		end
	end

    if  blink ~= nil
    and blink:IsFullyCastable()
	then
        Blink = blink
        return true
	end

    return false
end

return X