local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local MU = dofile( GetScriptDirectory()..'/FunLib/morphling_utility' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						{--pos1
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {10, 0},
                            ['t10'] = {10, 0},
                        },
                        {--pos2
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {0, 10},
                            ['t10'] = {10, 0},
                        }
}

local tAllAbilityBuildList = {
						{4,2,2,1,2,4,2,1,1,1,6,6,4,4,6},--pos1
                        {4,2,2,1,2,4,2,1,1,1,6,6,4,4,6},--pos2
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_1"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
else
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local nItems = {"item_butterfly", "item_skadi", "item_mjollnir"}
local sItems = nItems[RandomInt(1, #nItems)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_wraith_band",
    "item_boots_of_elves",
    "item_magic_wand",
    "item_power_treads",
    "item_lifesteal",
    "item_manta",--
    "item_angels_demise",--
    "item_black_king_bar",--
    "item_butterfly",--
    "item_aghanims_shard",
    "item_satanic",--
    "item_disperser",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",

    "item_wraith_band",
    "item_bottle",
    "item_magic_wand",
    "item_boots_of_elves",
    "item_power_treads",
    "item_lifesteal",
    "item_manta",--
    "item_angels_demise",--
    "item_black_king_bar",--
    sItems,--
    "item_aghanims_shard",
    "item_satanic",--
    "item_disperser",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",

    "item_wraith_band",
    "item_magic_wand",
    "item_boots_of_elves",
    "item_power_treads",
    "item_lifesteal",
    "item_manta",--
    "item_angels_demise",--
    "item_black_king_bar",--
    sItems,--
    "item_aghanims_shard",
    "item_satanic",--
    "item_disperser",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos1SellList = {
    "item_quelling_blade",
    "item_wraith_band",
    "item_power_treads",
    "item_magic_wand",
}

Pos2SellList = {
    "item_wraith_band",
    "item_bottle",
    "item_power_treads",
    "item_magic_wand",
}

X['sSellList'] = {}

if sRole == "pos_1"
then
    X['sSellList'] = Pos1SellList
else
    X['sSellList'] = Pos2SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Waveform              = bot:GetAbilityByName('morphling_waveform')
local AdaptiveStrikeAGI     = bot:GetAbilityByName('morphling_adaptive_strike_agi')
local AdaptiveStrikeSTR     = bot:GetAbilityByName('morphling_adaptive_strike_str')
local AtttributeShiftAGI    = bot:GetAbilityByName('morphling_morph_agi')
local AtttributeShiftSTR    = bot:GetAbilityByName('morphling_morph_str')
local Morph                 = bot:GetAbilityByName('morphling_replicate')
local MorphReplicate        = bot:GetAbilityByName('morphling_morph_replicate')

local WaveformDesire, WaveformLocation
local AdaptiveStrikeAGIDesire, AdaptiveStrikeAGITarget
local AdaptiveStrikeSTRDesire, AdaptiveStrikeSTRTarget
local AtttributeShiftAGIDesire
local AtttributeShiftSTRDesire
local MorphDesire, MorphTarget

local ShiftingSTRTime = 0

local MorphedHero = nil

local botTarget

if bot.IsMorphling == nil then bot.IsMorphling = true end

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    -- Later Stuff ^^
    -- if bot:GetAbilityInSlot(0) == Waveform then bot.IsMorphling = true else bot.IsMorphling = false end

    -- if  not bot.IsMorphling
    -- and not MorphReplicate:IsHidden()
    -- and MorphedHero ~= nil
    -- then
    --     MU.ConsiderMorphedSpells(MorphedHero)
    --     return
    -- end

    -- if  not bot.IsMorphling
    -- and not MorphReplicate:IsHidden()
    -- then
    --     bot:Action_UseAbility(MorphReplicate)
    --     return
    -- end

    if bot.IsMorphling
    then
        AtttributeShiftSTRDesire = X.ConsiderAtttributeShiftSTR()
        if AtttributeShiftSTRDesire > 0
        then
            bot:Action_UseAbility(AtttributeShiftSTR)
            ShiftingSTRTime = DotaTime()
            return
        end

        AtttributeShiftAGIDesire = X.ConsiderAtttributeShiftAGI()
        if AtttributeShiftAGIDesire > 0
        then
            local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
            then
                if DotaTime() > ShiftingSTRTime + 5
                then
                    bot:Action_UseAbility(AtttributeShiftAGI)
                end
            else
                bot:Action_UseAbility(AtttributeShiftAGI)
            end

            return
        end

        WaveformDesire, WaveformLocation = X.ConsiderWaveform()
        if WaveformDesire > 0
        then
            if J.HasItem(bot, 'item_power_treads')
            or J.HasItem(bot, 'item_power_treads_agi')
            or J.HasItem(bot, 'item_power_treads_int')
            or J.HasItem(bot, 'item_power_treads_str')
            then
                J.SetQueuePtToINT(bot, false)
                bot:ActionQueue_UseAbilityOnLocation(Waveform, WaveformLocation)
                return
            else
                bot:Action_UseAbilityOnLocation(Waveform, WaveformLocation)
                return
            end
        end

        AdaptiveStrikeSTRDesire, AdaptiveStrikeSTRTarget = X.ConsiderAdaptiveStrikeSTR()
        if AdaptiveStrikeSTRDesire > 0
        then
            bot:Action_UseAbilityOnEntity(AdaptiveStrikeSTR, AdaptiveStrikeSTRTarget)
            return
        end

        AdaptiveStrikeAGIDesire, AdaptiveStrikeAGITarget = X.ConsiderAdaptiveStrikeAGI()
        if AdaptiveStrikeAGIDesire > 0
        then
            if J.HasItem(bot, 'item_power_treads')
            or J.HasItem(bot, 'item_power_treads_agi')
            or J.HasItem(bot, 'item_power_treads_int')
            or J.HasItem(bot, 'item_power_treads_str')
            then
                J.SetQueuePtToINT(bot, false)
                bot:ActionQueue_UseAbilityOnEntity(AdaptiveStrikeAGI, AdaptiveStrikeAGITarget)
                return
            else
                bot:Action_UseAbilityOnEntity(AdaptiveStrikeAGI, AdaptiveStrikeAGITarget)
                return
            end
        end

        -- MorphDesire, MorphTarget = X.ConsiderMorph()
        -- if MorphDesire > 0
        -- then
        --     MorphedHero = MorphTarget
        --     bot:Action_UseAbilityOnEntity(Morph, MorphTarget)
        --     return
        -- end
    end
end

function X.ConsiderWaveform()
    if not Waveform:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, Waveform:GetCastRange())
	local nCastPoint = Waveform:GetCastPoint()
	local nSpeed = Waveform:GetSpecialValueInt('speed')
    local nDamage = Waveform:GetAbilityDamage()

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
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
            local nInRangeAlly = enemyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
			local nInRangeEnemy = enemyHero:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
            local eta = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                local nEnemyTowers = enemyHero:GetNearbyTowers(700, false)
                if J.IsInLaningPhase()
                then
                    if  nEnemyHeroes ~= nil
                    and (#nEnemyTowers == 0
                        or (#nEnemyTowers >= 1
                            and J.IsValidBuilding(nEnemyTowers[1])
                            and nEnemyTowers[1] ~= nil
                            and nEnemyTowers[1] ~= bot))
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(eta)
                    end
                else
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(eta)
                end
            end
        end
	end

	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
	end

	if J.IsStunProjectileIncoming(bot, 600)
	or J.IsUnitTargetProjectileIncoming(bot, 400)
    then
        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
    end

	if  not bot:HasModifier('modifier_sniper_assassinate')
	and not bot:IsMagicImmune()
	then
		if J.IsWillBeCastUnitTargetSpell(bot, 400)
		then
			return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:IsAttackImmune()
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			local eta = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
			local loc = J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetExtrapolatedLocation(eta), nCastRange)

            if J.IsInRange(bot, botTarget, nCastRange)
            then
                loc = botTarget:GetLocation()
            end

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			and IsLocationPassable(loc)
            and not J.IsLocationInChrono(loc)
			and not J.IsLocationInArena(loc, 600)
			then
				if GetUnitToLocationDistance(bot, loc) > bot:GetAttackRange() * 2
				then
					if J.IsInLaningPhase()
					then
						local nEnemyTowers = botTarget:GetNearbyTowers(700, false)
						if nEnemyTowers ~= nil and #nEnemyTowers == 0
						then
							return BOT_ACTION_DESIRE_HIGH, loc
						end
					else
						return BOT_ACTION_DESIRE_HIGH, loc
					end
				end
			end
		end
	end

	if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
        do
			if  J.IsValidHero(enemyHero)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not J.IsRealInvisible(bot)
			then
				local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
				local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

				if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and ((#nTargetInRangeAlly > #nInRangeAlly)
					or bot:WasRecentlyDamagedByAnyHero(1.5))
				then
					return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
				end
			end
        end
	end

	if J.IsPushing(bot)
	then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 600)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)

		if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        and nInRangeAlly ~= nil and #nInRangeAlly <= 1
		and GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nEnemyLaneCreeps)) > bot:GetAttackRange()
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
		then
            local nEnemyTowers = nEnemyLaneCreeps[#nEnemyLaneCreeps]:GetNearbyTowers(700, false)
            if nEnemyTowers ~= nil and #nEnemyTowers == 0
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
		end
	end

	if  J.IsFarming(bot)
    and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
	then
        if  bot.farmLocation ~= nil
        and J.GetManaAfter(Waveform:GetManaCost()) * bot:GetMana() > Waveform:GetManaCost() * 2
        then
            if GetUnitToLocationDistance(bot, bot.farmLocation) > nCastRange + 150
            then
                local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, bot.farmLocation, nCastRange)
                if  IsLocationPassable(targetLoc)
                and J.GetManaAfter(Waveform:GetManaCost()) * bot:GetMana() > Waveform:GetManaCost() * 2
                then
                    return BOT_ACTION_DESIRE_HIGH, targetLoc
                end
            end
        end
	end

	if J.IsLaning(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		if  J.GetManaAfter(Waveform:GetManaCost()) > 0.85
		and J.IsInLaningPhase()
		and bot:DistanceFromFountain() > 100
		and bot:DistanceFromFountain() < 6000
		and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
		then
			local nLane = bot:GetAssignedLane()
			local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(), nLane, 0)
			local nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocation)

			if nDistFromLane > nCastRange
			then
				local nLocation = J.Site.GetXUnitsTowardsLocation(bot, nLaneFrontLocation, nCastRange)
				if IsLocationPassable(nLocation)
				then
					return BOT_ACTION_DESIRE_HIGH, nLocation
				end
			end
		end
	end

	if J.IsDoingRoshan(bot)
    then
		local roshLoc = J.GetCurrentRoshanLocation()
        if GetUnitToLocationDistance(bot, roshLoc) > nCastRange
        then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, roshLoc, nCastRange)
			local nInRangeEnemy = J.GetEnemiesNearLoc(roshLoc, 1600)

			if  nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and IsLocationPassable(targetLoc)
            and J.GetManaAfter(Waveform:GetManaCost()) * bot:GetMana() > Waveform:GetManaCost() * 2
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end
        end
    end

    if J.IsDoingTormentor(bot)
    then
		local tormentorLoc = J.GetTormentorLocation(GetTeam())
        if GetUnitToLocationDistance(bot, tormentorLoc) > nCastRange
        then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, tormentorLoc, nCastRange)
			local nInRangeEnemy = J.GetEnemiesNearLoc(targetLoc, 1600)

			if  nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and IsLocationPassable(targetLoc)
            and J.GetManaAfter(Waveform:GetManaCost()) * bot:GetMana() > Waveform:GetManaCost() * 2
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end

        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderAdaptiveStrikeAGI()
    if not AdaptiveStrikeAGI:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, AdaptiveStrikeAGI:GetCastRange())
	local nMinAGI = AdaptiveStrikeAGI:GetSpecialValueFloat('damage_min')
	local nMaxAGI = AdaptiveStrikeAGI:GetSpecialValueFloat('damage_max')
	local nCurrAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY)
	local nCurrSTR = bot:GetAttributeValue(ATTRIBUTE_STRENGTH)
	local nDamage = 0

	if nCurrAGI > nCurrSTR * 1.5
    then
		nDamage = nMaxAGI * nCurrAGI
	else
		nDamage = nMinAGI * nCurrAGI
	end

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
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
        and not enemyHero:HasModifier('modifier_item_aeon_disk_buff')
        and not enemyHero:HasModifier('modifier_item_sphere_target')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + 150)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not botTarget:HasModifier('modifier_item_aeon_disk_buff')
        and not botTarget:HasModifier('modifier_item_sphere_target')
		then
			local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
                if J.HasItem(bot, 'item_phylactery') or J.HasItem(bot, 'item_angels_demise')
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                else
                    if J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_MAGICAL)
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget
                    end
                end
			end
		end
	end

    if  J.IsLaning(bot)
    and J.IsInLaningPhase()
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
			then

				if  (bot:GetTarget() ~= creep or bot:GetAttackTarget() ~= creep)
                and J.GetManaAfter(AdaptiveStrikeAGI:GetManaCost()) * bot:GetMana() > Waveform:GetManaCost()
                and J.CanBeAttacked(creep)
				then
                    if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                    and J.IsValidHero(nInRangeEnemy[1])
                    and nInRangeEnemy[1]:GetAttackTarget() ~= bot
                    and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
                    and not J.IsDisabled(nInRangeEnemy[1])
                    and not bot:WasRecentlyDamagedByTower(1)
                    and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) < nInRangeEnemy[1]:GetAttackRange()
                    then
                        return BOT_ACTION_DESIRE_HIGH, creep
                    end
				end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderAdaptiveStrikeSTR()
    if not AdaptiveStrikeSTR:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, AdaptiveStrikeSTR:GetCastRange())

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and enemyHero:IsChanneling()
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
        do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not J.IsRealInvisible(bot)
			then
				local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
				local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

				if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and ((#nTargetInRangeAlly > #nInRangeAlly)
					or bot:WasRecentlyDamagedByAnyHero(1.5))
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero
				end
			end
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderAtttributeShiftAGI()
    if not AtttributeShiftAGI:IsFullyCastable()
    or bot:HasModifier('modifier_morphling_morph_str')
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nCurrAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY)
	local nCurrSTR = bot:GetAttributeValue(ATTRIBUTE_STRENGTH)

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange() + 500)
		and not J.IsSuspiciousIllusion(botTarget)
		then
			local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
                if  ((nCurrAGI) / (nCurrAGI + nCurrSTR)) < 0.8
                and J.GetHP(bot) > 0.35
                then
                    if AtttributeShiftAGI:GetToggleState() == false
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    else
                        if ((nCurrAGI) / (nCurrAGI + nCurrSTR)) >= 0.8
                        then
                            if AtttributeShiftAGI:GetToggleState() == true
                            then
                                return BOT_ACTION_DESIRE_HIGH
                            end
                        end

                        return BOT_ACTION_DESIRE_NONE
                    end
                end
			end
		end
	end

	if J.IsRetreating(bot)
	then
        return BOT_ACTION_DESIRE_NONE
	end

    if  J.IsPushing(bot)
    and J.GetHP(bot) > 0.3
    then
        if ((nCurrAGI) / (nCurrAGI + nCurrSTR)) < 0.85
        then
            if AtttributeShiftAGI:GetToggleState() == false
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if ((nCurrAGI) / (nCurrAGI + nCurrSTR)) >= 0.85
                then
                    if AtttributeShiftAGI:GetToggleState() == true
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if  J.IsLaning(bot)
    and J.IsInLaningPhase()
    and J.GetHP(bot) > 0.3
    and not bot:WasRecentlyDamagedByAnyHero(1)
    and not bot:WasRecentlyDamagedByTower(1)
    then
        local nRatio = RemapValClamped(bot:GetHealth(), bot:GetMaxHealth() * 0.5, bot:GetMaxHealth(), 0.5, 0.77)
        if ((nCurrAGI) / (nCurrAGI + nCurrSTR)) < nRatio
        then
            if AtttributeShiftAGI:GetToggleState() == false
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if ((nCurrAGI) / (nCurrAGI + nCurrSTR)) >= nRatio
                then
                    if AtttributeShiftAGI:GetToggleState() == true
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if  J.IsFarming(bot)
    and J.GetHP(bot) > 0.3
    then
        local nRatio = RemapValClamped(bot:GetHealth(), bot:GetMaxHealth() * 0.5, bot:GetMaxHealth(), 0.5, 0.88)
        if ((nCurrAGI) / (nCurrAGI + nCurrSTR)) < nRatio
        then
            if AtttributeShiftAGI:GetToggleState() == false
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if ((nCurrAGI) / (nCurrAGI + nCurrSTR)) >= nRatio
                then
                    if AtttributeShiftAGI:GetToggleState() == true
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if  bot:DistanceFromFountain() < 1200
    and bot:HasModifier('modifier_fountain_aura_buff')
    and J.GetHP(bot) > 0.2
    and not bot:WasRecentlyDamagedByAnyHero(1)
    then
        if ((nCurrAGI) / (nCurrAGI + nCurrSTR)) < 0.85
        then
            if AtttributeShiftAGI:GetToggleState() == false
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end

        return BOT_ACTION_DESIRE_NONE
    end

    if AtttributeShiftAGI:GetToggleState() == true
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderAtttributeShiftSTR()
    if not AtttributeShiftSTR:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCurrAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY)
	local nCurrSTR = bot:GetAttributeValue(ATTRIBUTE_STRENGTH)

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange() + 500)
		and not J.IsSuspiciousIllusion(botTarget)
		then
			local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
                if J.GetHP(bot) < 0.35
                then
                    if AtttributeShiftSTR:GetToggleState() == false
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    else
                        return BOT_ACTION_DESIRE_NONE
                    end
                end
			end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
        do
			if  J.IsValidHero(enemyHero)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsRealInvisible(bot)
			then
				local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
				local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

				if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and ((#nTargetInRangeAlly > #nInRangeAlly)
					or bot:WasRecentlyDamagedByAnyHero(0.5))
				then
                    if J.GetHP(bot) < 0.3
                    then
                        if AtttributeShiftSTR:GetToggleState() == false
                        then
                            return BOT_ACTION_DESIRE_HIGH
                        else
                            return BOT_ACTION_DESIRE_NONE
                        end
                    else
                        if bot:GetHealth() > J.GetTotalEstimatedDamageToTarget(nInRangeEnemy, bot)
                        then
                            if AtttributeShiftSTR:GetToggleState() == true
                            then
                                return BOT_ACTION_DESIRE_HIGH
                            else
                                return BOT_ACTION_DESIRE_NONE
                            end
                        end

                        return BOT_ACTION_DESIRE_NONE
                    end
				end
			end
        end
	end

    if  J.IsFarming(bot)
    and J.GetHP(bot) < 0.3
    then
        if AtttributeShiftAGI:GetToggleState() == false
        then
            return BOT_ACTION_DESIRE_HIGH
        else
            return BOT_ACTION_DESIRE_NONE
        end
    end

    if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
    then
        if  (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, 1000)
        then
            if J.GetHP(bot) < 0.35
            then
                if AtttributeShiftSTR:GetToggleState() == false
                then
                    return BOT_ACTION_DESIRE_HIGH
                else
                    return BOT_ACTION_DESIRE_NONE
                end
            end
        end
    end

    if AtttributeShiftSTR:GetToggleState() == true
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderMorph()
    if not Morph:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Morph:GetCastRange())

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnMagicImmune(enemyHero)
            and DoesTargetHeroHaveDirectStun(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
    and Waveform:GetCooldownTimeRemaining() > 5
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
        do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnMagicImmune(enemyHero)
            and DoesTargetHeroHaveEscape(enemyHero)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsRealInvisible(bot)
			then
				local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
				local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

				if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and ((#nTargetInRangeAlly > #nInRangeAlly)
					or bot:WasRecentlyDamagedByAnyHero(0.5))
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero
				end
			end
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

-- Helper Funcs

local sEscapeHeroes = {
    ['npc_dota_hero_abaddon']               = false,
    ['npc_dota_hero_abyssal_underlord']     = false,
    ['npc_dota_hero_alchemist']             = false,
    ['npc_dota_hero_ancient_apparition']    = false,
    ['npc_dota_hero_antimage']              = true,
    ['npc_dota_hero_arc_warden']            = false,
    ['npc_dota_hero_axe']                   = false,
    ['npc_dota_hero_bane']                  = false,
    ['npc_dota_hero_batrider']              = false,
    ['npc_dota_hero_beastmaster']           = false,
    ['npc_dota_hero_bloodseeker']           = false,
    ['npc_dota_hero_bounty_hunter']         = false,
    ['npc_dota_hero_brewmaster']            = false,
    ['npc_dota_hero_bristleback']           = false,
    ['npc_dota_hero_broodmother']           = false,
    ['npc_dota_hero_centaur']               = false,
    ['npc_dota_hero_chaos_knight']          = false,
    ['npc_dota_hero_chen']                  = false,
    ['npc_dota_hero_clinkz']                = false,
    ['npc_dota_hero_crystal_maiden']        = false,
    ['npc_dota_hero_dark_seer']             = true,
    ['npc_dota_hero_dark_willow']           = false,
    ['npc_dota_hero_dawnbreaker']           = true,
    ['npc_dota_hero_dazzle']                = false,
    ['npc_dota_hero_disruptor']             = false,
    ['npc_dota_hero_death_prophet']         = false,
    ['npc_dota_hero_doom_bringer']          = false,
    ['npc_dota_hero_dragon_knight']         = false,
    ['npc_dota_hero_drow_ranger']           = false,
    ['npc_dota_hero_earth_spirit']          = true,
    ['npc_dota_hero_earthshaker']           = false,
    ['npc_dota_hero_elder_titan']           = false,
    ['npc_dota_hero_ember_spirit']          = false,
    ['npc_dota_hero_enchantress']           = false,
    ['npc_dota_hero_enigma']                = false,
    ['npc_dota_hero_faceless_void']         = true,
    ['npc_dota_hero_furion']                = false,
    ['npc_dota_hero_grimstroke']            = false,
    ['npc_dota_hero_gyrocopter']            = false,
    ['npc_dota_hero_hoodwink']              = true,
    ['npc_dota_hero_huskar']                = false,
    -- ['npc_dota_hero_invoker']               = true,
    ['npc_dota_hero_jakiro']                = false,
    ['npc_dota_hero_juggernaut']            = true,
    ['npc_dota_hero_keeper_of_the_light']   = false,
    ['npc_dota_hero_kunkka']                = false,
    ['npc_dota_hero_legion_commander']      = true,
    ['npc_dota_hero_leshrac']               = false,
    ['npc_dota_hero_lich']                  = false,
    ['npc_dota_hero_life_stealer']          = true,
    ['npc_dota_hero_lina']                  = false,
    ['npc_dota_hero_lion']                  = false,
    ['npc_dota_hero_lone_druid']            = false,
    ['npc_dota_hero_luna']                  = false,
    ['npc_dota_hero_lycan']                 = false,
    ['npc_dota_hero_magnataur']             = true,
    ['npc_dota_hero_marci']                 = false,
    ['npc_dota_hero_mars']                  = false,
    ['npc_dota_hero_medusa']                = false,
    ['npc_dota_hero_meepo']                 = false,
    ['npc_dota_hero_mirana']                = true,
    -- ['npc_dota_hero_morphling']             = true,
    ['npc_dota_hero_monkey_king']           = false,
    ['npc_dota_hero_naga_siren']            = false,
    ['npc_dota_hero_necrolyte']             = false,
    ['npc_dota_hero_nevermore']             = false,
    ['npc_dota_hero_night_stalker']         = false,
    ['npc_dota_hero_nyx_assassin']          = false,
    ['npc_dota_hero_obsidian_destroyer']    = false,
    ['npc_dota_hero_ogre_magi']             = false,
    ['npc_dota_hero_omniknight']            = false,
    ['npc_dota_hero_oracle']                = false,
    ['npc_dota_hero_pangolier']             = true,
    ['npc_dota_hero_phantom_lancer']        = true,
    ['npc_dota_hero_phantom_assassin']      = true,
    ['npc_dota_hero_phoenix']               = true,
    ['npc_dota_hero_primal_beast']          = true,
    ['npc_dota_hero_puck']                  = true,
    ['npc_dota_hero_pudge']                 = false,
    ['npc_dota_hero_pugna']                 = false,
    ['npc_dota_hero_queenofpain']           = true,
    ['npc_dota_hero_rattletrap']            = false,
    ['npc_dota_hero_razor']                 = false,
    ['npc_dota_hero_riki']                  = false,
    ['npc_dota_hero_rubick']                = false,
    ['npc_dota_hero_sand_king']             = true,
    ['npc_dota_hero_shadow_demon']          = false,
    ['npc_dota_hero_shadow_shaman']         = false,
    ['npc_dota_hero_shredder']              = true,
    ['npc_dota_hero_silencer']              = false,
    ['npc_dota_hero_skeleton_king']         = false,
    ['npc_dota_hero_skywrath_mage']         = false,
    ['npc_dota_hero_slardar']               = true,
    ['npc_dota_hero_slark']                 = true,
    ["npc_dota_hero_snapfire"]              = true,
    ['npc_dota_hero_sniper']                = false,
    ['npc_dota_hero_spectre']               = true,
    ['npc_dota_hero_spirit_breaker']        = true,
    ['npc_dota_hero_storm_spirit']          = false,
    ['npc_dota_hero_sven']                  = false,
    ['npc_dota_hero_techies']               = true,
    ['npc_dota_hero_terrorblade']           = false,
    ['npc_dota_hero_templar_assassin']      = false,
    ['npc_dota_hero_tidehunter']            = false,
    ['npc_dota_hero_tinker']                = false,
    ['npc_dota_hero_tiny']                  = false,
    ['npc_dota_hero_treant']                = false,
    ['npc_dota_hero_troll_warlord']         = false,
    ['npc_dota_hero_tusk']                  = false,
    ['npc_dota_hero_undying']               = false,
    ['npc_dota_hero_ursa']                  = true,
    ['npc_dota_hero_vengefulspirit']        = false,
    ['npc_dota_hero_venomancer']            = false,
    ['npc_dota_hero_viper']                 = false,
    ['npc_dota_hero_visage']                = false,
    ['npc_dota_hero_void_spirit']           = true,
    ['npc_dota_hero_warlock']               = false,
    ['npc_dota_hero_weaver']                = true,
    ['npc_dota_hero_windrunner']            = true,
    ['npc_dota_hero_winter_wyvern']         = false,
    ['npc_dota_hero_wisp']                  = false,
    ['npc_dota_hero_witch_doctor']          = false,
    ['npc_dota_hero_zuus']                  = false,
}
function DoesTargetHeroHaveEscape(target)
    return sEscapeHeroes[target:GetUnitName()]
end

local sDirectStunHeroes = {
    ['npc_dota_hero_abaddon']               = false,
    ['npc_dota_hero_abyssal_underlord']     = false,
    ['npc_dota_hero_alchemist']             = true,
    ['npc_dota_hero_ancient_apparition']    = false,
    ['npc_dota_hero_antimage']              = false,
    ['npc_dota_hero_arc_warden']            = false,
    ['npc_dota_hero_axe']                   = false,
    ['npc_dota_hero_bane']                  = true,
    ['npc_dota_hero_batrider']              = false,
    ['npc_dota_hero_beastmaster']           = false,
    ['npc_dota_hero_bloodseeker']           = false,
    ['npc_dota_hero_bounty_hunter']         = false,
    ['npc_dota_hero_brewmaster']            = false,
    ['npc_dota_hero_bristleback']           = false,
    ['npc_dota_hero_broodmother']           = false,
    ['npc_dota_hero_centaur']               = true,
    ['npc_dota_hero_chaos_knight']          = true,
    ['npc_dota_hero_chen']                  = false,
    ['npc_dota_hero_clinkz']                = false,
    ['npc_dota_hero_crystal_maiden']        = false,
    ['npc_dota_hero_dark_seer']             = false,
    ['npc_dota_hero_dark_willow']           = false,
    ['npc_dota_hero_dawnbreaker']           = false,
    ['npc_dota_hero_dazzle']                = false,
    ['npc_dota_hero_disruptor']             = false,
    ['npc_dota_hero_death_prophet']         = false,
    ['npc_dota_hero_doom_bringer']          = false,
    ['npc_dota_hero_dragon_knight']         = true,
    ['npc_dota_hero_drow_ranger']           = false,
    ['npc_dota_hero_earth_spirit']          = false,
    ['npc_dota_hero_earthshaker']           = true,
    ['npc_dota_hero_elder_titan']           = false,
    ['npc_dota_hero_ember_spirit']          = true,
    ['npc_dota_hero_enchantress']           = false,
    ['npc_dota_hero_enigma']                = false,
    ['npc_dota_hero_faceless_void']         = false,
    ['npc_dota_hero_furion']                = false,
    ['npc_dota_hero_grimstroke']            = false,
    ['npc_dota_hero_gyrocopter']            = true,
    ['npc_dota_hero_hoodwink']              = false,
    ['npc_dota_hero_huskar']                = false,
    ['npc_dota_hero_invoker']               = false,
    ['npc_dota_hero_jakiro']                = true,
    ['npc_dota_hero_juggernaut']            = false,
    ['npc_dota_hero_keeper_of_the_light']   = false,
    ['npc_dota_hero_kunkka']                = false,
    ['npc_dota_hero_legion_commander']      = false,
    ['npc_dota_hero_leshrac']               = true,
    ['npc_dota_hero_lich']                  = false,
    ['npc_dota_hero_life_stealer']          = false,
    ['npc_dota_hero_lina']                  = true,
    ['npc_dota_hero_lion']                  = true,
    ['npc_dota_hero_lone_druid']            = false,
    ['npc_dota_hero_luna']                  = true,
    ['npc_dota_hero_lycan']                 = false,
    ['npc_dota_hero_magnataur']             = false,
    ['npc_dota_hero_marci']                 = false,
    ['npc_dota_hero_mars']                  = true,
    ['npc_dota_hero_medusa']                = false,
    ['npc_dota_hero_meepo']                 = false,
    ['npc_dota_hero_mirana']                = true,
    -- ['npc_dota_hero_morphling']          = true,
    ['npc_dota_hero_monkey_king']           = true,
    ['npc_dota_hero_naga_siren']            = false,
    ['npc_dota_hero_necrolyte']             = false,
    ['npc_dota_hero_nevermore']             = false,
    ['npc_dota_hero_night_stalker']         = false,
    ['npc_dota_hero_nyx_assassin']          = true,
    ['npc_dota_hero_obsidian_destroyer']    = true,
    ['npc_dota_hero_ogre_magi']             = true,
    ['npc_dota_hero_omniknight']            = false,
    ['npc_dota_hero_oracle']                = false,
    ['npc_dota_hero_pangolier']             = false,
    ['npc_dota_hero_phantom_lancer']        = false,
    ['npc_dota_hero_phantom_assassin']      = false,
    ['npc_dota_hero_phoenix']               = false,
    ['npc_dota_hero_primal_beast']          = false,
    ['npc_dota_hero_puck']                  = false,
    ['npc_dota_hero_pudge']                 = false,
    ['npc_dota_hero_pugna']                 = false,
    ['npc_dota_hero_queenofpain']           = false,
    ['npc_dota_hero_rattletrap']            = false,
    ['npc_dota_hero_razor']                 = false,
    ['npc_dota_hero_riki']                  = false,
    ['npc_dota_hero_rubick']                = true,
    ['npc_dota_hero_sand_king']             = true,
    ['npc_dota_hero_shadow_demon']          = true,
    ['npc_dota_hero_shadow_shaman']         = true,
    ['npc_dota_hero_shredder']              = false,
    ['npc_dota_hero_silencer']              = false,
    ['npc_dota_hero_skeleton_king']         = true,
    ['npc_dota_hero_skywrath_mage']         = false,
    ['npc_dota_hero_slardar']               = true,
    ['npc_dota_hero_slark']                 = false,
    ["npc_dota_hero_snapfire"]              = false,
    ['npc_dota_hero_sniper']                = false,
    ['npc_dota_hero_spectre']               = false,
    ['npc_dota_hero_spirit_breaker']        = false,
    ['npc_dota_hero_storm_spirit']          = false,
    ['npc_dota_hero_sven']                  = true,
    ['npc_dota_hero_techies']               = true,
    ['npc_dota_hero_terrorblade']           = false,
    ['npc_dota_hero_templar_assassin']      = false,
    ['npc_dota_hero_tidehunter']            = false,
    ['npc_dota_hero_tinker']                = false,
    ['npc_dota_hero_tiny']                  = true,
    ['npc_dota_hero_treant']                = false,
    ['npc_dota_hero_troll_warlord']         = false,
    ['npc_dota_hero_tusk']                  = false,
    ['npc_dota_hero_undying']               = false,
    ['npc_dota_hero_ursa']                  = false,
    ['npc_dota_hero_vengefulspirit']        = true,
    ['npc_dota_hero_venomancer']            = false,
    ['npc_dota_hero_viper']                 = false,
    ['npc_dota_hero_visage']                = false,
    ['npc_dota_hero_void_spirit']           = false,
    ['npc_dota_hero_warlock']               = false,
    ['npc_dota_hero_weaver']                = false,
    ['npc_dota_hero_windrunner']            = true,
    ['npc_dota_hero_winter_wyvern']         = false,
    ['npc_dota_hero_wisp']                  = false,
    ['npc_dota_hero_witch_doctor']          = true,
    ['npc_dota_hero_zuus']                  = false,
}
function DoesTargetHeroHaveDirectStun(target)
    return sDirectStunHeroes[target:GetUnitName()]
end

return X