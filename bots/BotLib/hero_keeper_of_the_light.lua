-- Credit goes to Furious Puppy for Bot Experiment

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,1,3,1,6,1,3,3,2,6,2,2,2,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
    "item_faerie_fire",
    "item_mantle",
    "item_circlet",
    "item_double_branches",
    "item_tango",

    "item_null_talisman",
    "item_travel_boots",
    "item_magic_wand",
    "item_spirit_vessel",
    "item_black_king_bar",--
    "item_octarine_core",--
    "item_ethereal_blade",--
    "item_sheepstick",--
    "item_ultimate_scepter",
    "item_dagon_2",
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
    "item_dagon_5",--
    "item_aghanims_shard",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_2'] 

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_2']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_null_talisman",
    "item_magic_wand",
    "item_spirit_vessel",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end
end

local Illuminate    = bot:GetAbilityByName('keeper_of_the_light_illuminate')
local IlluminateEnd = bot:GetAbilityByName('keeper_of_the_light_illuminate_end')
local BlindingLight = bot:GetAbilityByName('keeper_of_the_light_blinding_light')
local ChakraMagic   = bot:GetAbilityByName('keeper_of_the_light_chakra_magic')
local SolarBind     = bot:GetAbilityByName('keeper_of_the_light_radiant_bind')
local Recall        = bot:GetAbilityByName('keeper_of_the_light_recall')
local WillOWisp     = bot:GetAbilityByName('keeper_of_the_light_will_o_wisp')
local SpiritForm    = bot:GetAbilityByName('keeper_of_the_light_spirit_form')

local IlluminateSpirit    = bot:GetAbilityByName('keeper_of_the_light_spirit_form_illuminate')
local IlluminateEndSpirit = bot:GetAbilityByName('keeper_of_the_light_spirit_form_illuminate_end')

local IlluminateDesire, IlluminateLocation
local IlluminateEndDesire
local BlindingLightDesire, BlindingLightLocation
local ChakraMagicDesire, ChakraMagicTarget
local SolarBindDesire, SolarBindTarget
local RecallDesire, RecallTarget
local WillOWispDesire, WillOWispLocation
local SpiritFormDesire

local IlluminateCastedTime = -100

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    SpiritFormDesire = X.ConsiderSpiritForm()
    if SpiritFormDesire > 0
    then
        bot:Action_UseAbility(SpiritForm)
        return
    end

    SolarBindDesire, SolarBindTarget = X.ConsiderSolarBind()
    if SolarBindDesire > 0
    then
        bot:Action_UseAbilityOnEntity(SolarBind, SolarBindTarget)
        return
    end

    WillOWispDesire, WillOWispLocation = X.ConsiderWillOWisp()
    if WillOWispDesire > 0
    then
        bot:Action_UseAbilityOnLocation(WillOWisp, WillOWispLocation)
        return
    end

    BlindingLightDesire, BlindingLightLocation = X.ConsiderBlindingLight()
    if BlindingLightDesire > 0
    then
        bot:Action_UseAbilityOnLocation(BlindingLight, BlindingLightLocation)
        return
    end

    IlluminateDesire, IlluminateLocation = X.ConsiderIlluminate()
    if IlluminateDesire > 0
    then
        if bot:HasModifier('modifier_keeper_of_the_light_spirit_form')
        then
            bot:Action_UseAbilityOnLocation(IlluminateSpirit, IlluminateLocation)
        else
            bot:Action_UseAbilityOnLocation(Illuminate, IlluminateLocation)
        end

        -- IlluminateCastedTime = DotaTime()
        return
    end

    -- IlluminateEndDesire = X.ConsiderIlluminateEnd()
    -- if IlluminateEndDesire > 0
    -- then
    --     if bot:HasModifier('modifier_keeper_of_the_light_spirit_form')
    --     then
    --         bot:Action_UseAbility(IlluminateEndDesire)
    --     else
    --         bot:Action_UseAbility(IlluminateEnd)
    --     end

    --     return
    -- end

    ChakraMagicDesire, ChakraMagicTarget = X.ConsiderChakraMagic()
    if ChakraMagicDesire > 0
    then
        bot:Action_UseAbilityOnEntity(ChakraMagic, ChakraMagicTarget)
        return
    end

    RecallDesire, RecallTarget = X.ConsiderRecall()
    if RecallDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Recall, RecallTarget)
        return
    end
end

function X.ConsiderIlluminate()
    if not Illuminate:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = Illuminate:GetCastRange()
    local nTravelDist = Illuminate:GetSpecialValueInt('range')
    local nMaxDamage = Illuminate:GetSpecialValueInt('total_damage')
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    if nCastRange > 1600 then nCastRange = 1600 end

    local nEnemyHeroes = bot:GetNearbyHeroes(nTravelDist, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nMaxDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nTravelDist, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nTravelDist)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and bot:IsFacingLocation(botTarget:GetLocation(), 15)
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(800)
        if  nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]:GetLocation()
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nTravelDist, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]:GetLocation()
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nTravelDist, true)
        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]:GetLocation()
        end
    end

    if  J.IsLaning(bot)
    and nMana > 0.33
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nTravelDist, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        then
            local nInRangeEnemy = nEnemyLaneCreeps[1]:GetNearbyHeroes(600, false, BOT_MODE_NONE)
            if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]:GetLocation()
            end
        end

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep))
			and creep:GetHealth() <= nMaxDamage
			then
                local nNearbyTower = creep:GetNearbyTowers(700, true)
				local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

				if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
                and nNearbyTower ~= nil and #nNearbyTower == 0
				then
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
				end
			end

            local lowHealthCreepCount = 0
            local creepList = {}
            if  J.IsValid(creep)
            and creep:GetHealth() <= nMaxDamage
            then
                lowHealthCreepCount = lowHealthCreepCount + 1
                table.insert(creepList, creep)
            end

            if lowHealthCreepCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

-- function X.ConsiderIlluminateEnd()
--     if IlluminateEnd:IsHidden()
--     or not IlluminateEnd:IsFullyCastable()
--     then
--         return BOT_ACTION_DESIRE_NONE
--     end

--     local nCastRange = Illuminate:GetCastRange()
--     local nTravelDist = Illuminate:GetSpecialValueInt('range')
--     local nChannelTime = Illuminate:GetSpecialValueInt('max_channel_time')
--     local nMaxDamage = Illuminate:GetSpecialValueInt('total_damage')
--     local botTarget = J.GetProperTarget(bot)

--     if nCastRange > 1600 then nCastRange = 1600 end

--     local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
--     for _, enemyHero in pairs(nEnemyHeroes)
--     do
--         if  J.IsValidHero(enemyHero)
--         and J.CanCastOnNonMagicImmune(enemyHero)
--         and not J.IsSuspiciousIllusion(enemyHero)
--         and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
--         and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
--         and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
--         and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
--         then
--             local nDamage = RemapValClamped(IlluminateCastedTime, IlluminateCastedTime, IlluminateCastedTime + nChannelTime, 0, nMaxDamage)

--             if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
--             then
--                 return BOT_ACTION_DESIRE_HIGH
--             end
--         end
--     end

--     if J.IsGoingOnSomeone()
--     then
--         local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
--         local nInRangeEnemy = bot:GetNearbyHeroes(nTravelDist, true, BOT_MODE_NONE)

--         if  J.IsValidTarget(botTarget)
--         and J.CanCastOnNonMagicImmune(botTarget)
--         and J.IsInRange(bot, botTarget, nTravelDist)
--         and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
--         and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
--         and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
--         and bot:IsFacingLocation(botTarget:GetLocation(), 15)
--         and nInRangeAlly ~= nil and nInRangeEnemy
-- 		then
--             if  #nInRangeEnemy >= 2
--             and bot:WasRecentlyDamagedByAnyHero(2)
--             then
--                 return BOT_ACTION_DESIRE_HIGH
--             end

--             if  #nInRangeEnemy == 1
--             and bot:WasRecentlyDamagedByAnyHero(2)
--             and J.GetHP(bot) < 0.49
--             then
--                 return BOT_ACTION_DESIRE_HIGH
--             end
-- 		end
--     end

--     if J.IsLaning(bot)
-- 	then
-- 		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

-- 		for _, creep in pairs(nEnemyLaneCreeps)
-- 		do
-- 			if  J.IsValid(creep)
-- 			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep))
-- 			then
--                 local nDamage = RemapValClamped(IlluminateCastedTime, IlluminateCastedTime, IlluminateCastedTime + nChannelTime, 0, nMaxDamage)
-- 				local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

-- 				if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
-- 				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
--                 and creep:GetHealth() <= nDamage
-- 				then
-- 					return BOT_ACTION_DESIRE_HIGH
-- 				end
-- 			end
-- 		end
-- 	end

--     return BOT_ACTION_DESIRE_NONE
-- end

function X.ConsiderBlindingLight()
    if not BlindingLight:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = BlindingLight:GetCastRange()
	local nCastPoint = BlindingLight:GetCastPoint()
    local nDamage = BlindingLight:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
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

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_legion_commander_duel')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
		end
	end

	if  J.IsRetreating(bot)
    and not SolarBind:IsFullyCastable()
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and (#nInRangeEnemy > #nInRangeAlly
            or (J.GetHP(bot) < 0.6 or bot:WasRecentlyDamagedByAnyHero(2)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            if J.IsInRange(bot, nInRangeEnemy[1], 400)
            then
                return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
            end

			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetExtrapolatedLocation(nCastPoint)
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  J.IsRetreating(allyHero)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], 400)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero:GetLocation()
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderChakraMagic()
    if not ChakraMagic:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = ChakraMagic:GetCastRange()
    local nMana = bot:GetMana() / bot:GetMana()

	if nMana < 0.75
    then
		return BOT_ACTION_DESIRE_HIGH, bot
	else
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

		for _, allHero in pairs(nInRangeAlly)
        do
			if  (allHero:GetMana() / allHero:GetMaxMana()) < 0.6
			then
				return BOT_ACTION_DESIRE_HIGH, allHero
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSolarBind()
    if not SolarBind:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = SolarBind:GetCastRange()
    local nDuration = SolarBind:GetSpecialValueInt('duration')
    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and strongestTarget ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, strongestTarget
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

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

	if  J.IsRetreating(bot)
    and not BlindingLight:IsFullyCastable()
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 150, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and (#nInRangeEnemy > #nInRangeAlly
            or (J.GetHP(bot) < 0.45 or bot:WasRecentlyDamagedByAnyHero(2)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], bot:GetAttackRange())
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
        end
	end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  J.IsRetreating(allyHero)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], 400)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSpiritForm()
    if not SpiritForm:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local botTarget = J.GetProperTarget(bot)

	if J.IsInTeamFight(bot, 1200)
	then
		local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            local realEnemyCount = J.GetEnemiesNearLoc(nInRangeEnemy[1]:GetLocation(), 1200)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 700)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderRecall()
    if Recall:IsHidden()
    or not Recall:IsTrained()
    or not Recall:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if  J.IsValidHero(allyHero)
        and not allyHero:IsIllusion()
        and not allyHero:WasRecentlyDamagedByAnyHero(2.5)
        then
            if  J.IsRetreating(allyHero)
            and J.IsRunning(allyHero)
            and J.GetHP(allyHero) < 0.5
            and allyHero:DistanceFromFountain() > 2000
            and bot:DistanceFromFountain() < 1600
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
        end

        if J.IsPushing(bot)
        then
            local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and #nInRangeAlly >= 2
            and GetUnitToUnitDistance(bot, allyHero) > 3200
            and not J.IsFarming(allyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderWillOWisp()
    if WillOWisp:IsHidden()
    or not WillOWisp:IsTrained()
    or not WillOWisp:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = 725
	local nCastRange = WillOWisp:GetCastRange()
    local botTarget = J.GetProperTarget(bot)

	if J.IsInTeamFight(bot, 1200)
	then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if  nLocationAoE.count >= 2
        and not IsTargetLocInBigUlt(nLocationAoE.targetloc)
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
        and #nInRangeEnemy >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function IsTargetLocInBigUlt(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if  J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 300
		and (enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			or enemyHero:HasModifier('modifier_enigma_black_hole_pull'))
		then
			return true
		end
	end

	return false
end

return X