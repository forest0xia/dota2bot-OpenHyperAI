local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local SPL = require( GetScriptDirectory()..'/FunLib/spell_list' )
local M = dofile( GetScriptDirectory()..'/FunLib/morphling_utility' )
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

if sRole == "pos_2"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
else
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
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
    "item_moon_shard",
    "item_satanic",--
    "item_disperser",--
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = {
	"item_mid_outfit",
    "item_lifesteal",
    "item_manta",--
    "item_angels_demise",--
    "item_black_king_bar",--
    sItems,--
    "item_aghanims_shard",
    "item_moon_shard",
    "item_satanic",--
    "item_disperser",--
    "item_ultimate_scepter_2",
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

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Waveform              = bot:GetAbilityByName('morphling_waveform')
local AdaptiveStrikeAGI     = bot:GetAbilityByName('morphling_adaptive_strike_agi')
local AdaptiveStrikeSTR     = bot:GetAbilityByName('morphling_adaptive_strike_str')
local AttributeShiftAGI     = bot:GetAbilityByName('morphling_morph_agi')
local AttributeShiftSTR     = bot:GetAbilityByName('morphling_morph_str')
local Morph                 = bot:GetAbilityByName('morphling_replicate')
local MorphReplicate        = bot:GetAbilityByName('morphling_morph_replicate')

local WaveformDesire, WaveformLocation
local AdaptiveStrikeAGIDesire, AdaptiveStrikeAGITarget
local AdaptiveStrikeSTRDesire, AdaptiveStrikeSTRTarget
local AtttributeShiftDesire
local MorphDesire, MorphTarget

local MorphedHeroName = ''

local botTarget
local botHP, botMP
local nAllyHeroes, nEnemyHeroes

local bFlowFacet = false

if bot.IsMorphling == nil then bot.IsMorphling = true end

local nAGIRatio = 1
local nSTRRatio = 1

local AGI_BASE = 24
local STR_BASE = 23
local AGI_GROWTH_RATE = 3.9
local STR_GROWTH_RATE = 3.2

-- do similar thing as Rubick's
-- TODO: Update some bot fields from select heroes to not give errors
local heroAbilityUsage = {}
local function HandleSpell(spell)
    if spell == nil then return end

    local heroName = SPL.GetSpellHeroName(spell:GetName())

    if heroName == nil then return end

    if not heroAbilityUsage[heroName]
    then
        heroAbilityUsage[heroName] = dofile(GetScriptDirectory()..'/BotLib/'..string.gsub(heroName, 'npc_dota_', ''))
    end

    local heroSpells = heroAbilityUsage[heroName]
    if heroSpells and heroSpells.SkillsComplement
    then
        heroSpells.SkillsComplement()
    end
end

local nMorphTime = {0, math.huge}

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    botTarget = J.GetProperTarget(bot)
    botHP = J.GetHP(bot)
    botMP = J.GetMP(bot)

    bFlowFacet = bot:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH and true or false

    if bot:GetAbilityInSlot(0) == Waveform then bot.IsMorphling = true else bot.IsMorphling = false end

    if bot:HasModifier('modifier_morphling_replicate_manager') then
        -- Replicate back if it's a good hero
        local nCooldownTime = M.GetMorphLength(bot, MorphedHeroName)
        if DotaTime() > nMorphTime[2] + nCooldownTime + (0.25 + 0.1) then
            local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
            if bot.IsMorphling == true then
                if J.IsGoingOnSomeone(bot)
                and J.IsValidHero(botTarget)
                and J.IsInRange(bot, botTarget, 900)
                then
                    bot:Action_UseAbility(MorphReplicate)
                    nMorphTime[1] = DotaTime()
                    return
                end

                if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and M.IsGoodToMorphBack(MorphedHeroName)
                and Waveform:GetCooldownTimeRemaining() > 3
                then
                    if J.IsValidHero(nInRangeEnemy[1])
                    and J.IsChasingTarget(nInRangeEnemy[1], bot)
                    then
                        bot:Action_UseAbility(MorphReplicate)
                        nMorphTime[1] = DotaTime()
                        return
                    end
                end
            end
        end

        -- give 3 seconds to cast any spells
        if DotaTime() < nMorphTime[1] + 3 + (0.25 + 0.1) then
            if bot.IsMorphling == false and not MorphReplicate:IsHidden() and J.CanCastAbility(MorphReplicate) and MorphedHeroName ~= '' then
                for i = 0, 6 do
                    local hAbility = bot:GetAbilityInSlot(i)
                    if hAbility ~= nil and not hAbility ~= MorphReplicate then
                        HandleSpell(hAbility)
                    end
                end
            end
        else
            if bot.IsMorphling == false and not MorphReplicate:IsHidden() and J.CanCastAbility(MorphReplicate) then
                bot:Action_UseAbility(MorphReplicate)
                nMorphTime[2] = DotaTime()
                return
            end
        end
    else
        nMorphTime = {0, math.huge}
        MorphedHeroName = ''
    end

    if bot.IsMorphling then
        X.SetRatios()

        AtttributeShiftDesire, Type = X.ConsiderAtttributeShift()
        if AtttributeShiftDesire > 0
        then
            if Type == 'agi'
            then
                bot:Action_UseAbility(AttributeShiftAGI)
            else
                bot:Action_UseAbility(AttributeShiftSTR)
            end
            return
        end

        WaveformDesire, WaveformLocation = X.ConsiderWaveform()
        if WaveformDesire > 0
        then
            J.SetQueuePtToINT(bot, false)
            bot:ActionQueue_UseAbilityOnLocation(Waveform, WaveformLocation)
            return
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
            J.SetQueuePtToINT(bot, false)
            bot:ActionQueue_UseAbilityOnEntity(AdaptiveStrikeAGI, AdaptiveStrikeAGITarget)
            return
        end

        MorphDesire, MorphTarget = X.ConsiderMorph()
        if MorphDesire > 0
        then
            bot:Action_UseAbilityOnEntity(Morph, MorphTarget)
            nMorphTime[1] = DotaTime()
            MorphedHeroName = MorphTarget:GetUnitName()
            return
        end
    end
end

function X.ConsiderWaveform()
    if not J.CanCastAbility(Waveform) then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, Waveform:GetCastRange())
	local nCastPoint = Waveform:GetCastPoint()
	local nSpeed = Waveform:GetSpecialValueInt('speed')
    local nDamage = Waveform:GetSpecialValueInt('#AbilityDamage')
    local nRadius = Waveform:GetSpecialValueInt('width')
    local nManaAfter = J.GetManaAfter(Waveform:GetManaCost())

    local vTeamFountain = J.GetTeamFountain()

	if J.IsStuck(bot) then
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, vTeamFountain, nCastRange)
	end

    if not J.IsRealInvisible(bot) then
        if J.IsStunProjectileIncoming(bot, 500)
        or J.IsUnitTargetProjectileIncoming(bot, 500)
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, vTeamFountain, nCastRange)
        end

        if  not bot:HasModifier('modifier_sniper_assassinate')
        and not bot:IsMagicImmune()
        then
            if J.IsWillBeCastUnitTargetSpell(bot, 400)
            then
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, vTeamFountain, nCastRange)
            end
        end
    end

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
        and J.CanBeAttacked(botTarget)
        and not J.IsInRange(bot, botTarget, bot:GetAttackRange())
		and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
            local nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)
            local nInRangeAlly2 = J.GetAlliesNearLoc(bot:GetLocation(), 650)
            local nInRangeEnemy2 = J.GetEnemiesNearLoc(botTarget:GetLocation(), 650)
            local bStronger = J.WeAreStronger(bot, 1200)

            if #nInRangeAlly >= #nInRangeEnemy and #nInRangeAlly2 >= #nInRangeEnemy2 and bStronger then
                local vLocation = J.GetCorrectLoc(botTarget, (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint)
                local bTowerNearby = botTarget:HasModifier('modifier_tower_aura_bonus')

                if GetUnitToLocationDistance(bot, vLocation) <= nCastRange then
                    if IsLocationPassable(vLocation) then
                        if J.IsInLaningPhase() then
                            if not bTowerNearby then
                                return BOT_ACTION_DESIRE_HIGH, vLocation
                            end
                        else
                            return BOT_ACTION_DESIRE_HIGH, vLocation
                        end
                    end
                end

                if GetUnitToLocationDistance(bot, vLocation) > nCastRange and GetUnitToLocationDistance(bot, vLocation) < nCastRange + 350 then
                    if IsLocationPassable(vLocation) then
                        if J.IsInLaningPhase() then
                            if not bTowerNearby then
                                return BOT_ACTION_DESIRE_HIGH, vLocation
                            end
                        else
                            return BOT_ACTION_DESIRE_HIGH, vLocation
                        end
                    end
                end
            end
		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
		for _, enemyHero in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
                local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), 1000)

                if ((J.IsInLaningPhase() and #nInRangeEnemy >= #nInRangeAlly + 1) or (#nInRangeEnemy > #nInRangeAlly and not J.WeAreStronger(bot, 1200)))
                or (botHP < 0.75 and J.IsChasingTarget(enemyHero, bot) and not J.IsInTeamFight(bot, 1200))
                then
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, vTeamFountain, nCastRange)
                end

			end
        end
	end

    local bAttacking = J.IsAttacking(bot)

	if J.IsPushing(bot) and bAttacking and not J.IsThereCoreNearby(1000) and nManaAfter > 0.35 then
        local nEnemyCreeps = bot:GetNearbyCreeps(nCastRange, true)
        if J.CanBeAttacked(nEnemyCreeps[1]) and not J.IsRunning(nEnemyCreeps[1]) then
            local nLocationAoE = bot:FindAoELocation(true, false, nEnemyCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
            if nLocationAoE.count >= 4 then
                local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, 1200)
                if #nInRangeEnemy <= 1 then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
	end

	if J.IsFarming(bot) and bAttacking and nManaAfter > 0.4 and bot:GetLevel() < 18 then
        local nEnemyCreeps = bot:GetNearbyCreeps(nCastRange, true)
        if J.CanBeAttacked(nEnemyCreeps[1])
        and not J.IsRunning(nEnemyCreeps[1])
        then
            local nLocationAoE = bot:FindAoELocation(true, false, nEnemyCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
            if (nLocationAoE.count >= 3 or (nLocationAoE.count >= 2 and nEnemyCreeps[1]:IsAncientCreep())) then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
	end

	if J.IsDoingRoshan(bot) and nManaAfter > 0.75 then
		local roshLoc = J.GetCurrentRoshanLocation()
        if GetUnitToLocationDistance(bot, roshLoc) > nCastRange then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, roshLoc, nCastRange)
			if #nEnemyHeroes == 0 and IsLocationPassable(targetLoc) then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end
        end
    end

    if J.IsDoingTormentor(bot) and nManaAfter > 0.75 then
		local tormentorLoc = J.GetTormentorLocation()
        if GetUnitToLocationDistance(bot, tormentorLoc) > 1600 then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, tormentorLoc, nCastRange)
			if #nEnemyHeroes == 0 and IsLocationPassable(targetLoc) then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end
        end
    end

    local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, nDamage)
    if nLocationAoE.count >= 5 and #nEnemyHeroes == 0 and nManaAfter > 0.45 then
        return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderAdaptiveStrikeAGI()
    if not J.CanCastAbility(AdaptiveStrikeAGI) then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, AdaptiveStrikeAGI:GetCastRange())
    local nCastPoint = AdaptiveStrikeAGI:GetCastPoint()
	local nMinAGI = AdaptiveStrikeAGI:GetSpecialValueFloat('damage_min')
	local nMaxAGI = AdaptiveStrikeAGI:GetSpecialValueFloat('damage_max')
	local nCurrAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY)
	local nCurrSTR = bot:GetAttributeValue(ATTRIBUTE_STRENGTH)
	local nDamage = AdaptiveStrikeAGI:GetSpecialValueInt('damage_base')
    local nSpeed = AdaptiveStrikeAGI:GetSpecialValueInt('projectile_speed')
    local nManaAfter = J.GetManaAfter(AdaptiveStrikeAGI:GetManaCost())
    local nManaThreshold = (150 / bot:GetMana())
    local bUsingMax = nCurrAGI > nCurrSTR * 1.5

	if bUsingMax then
		nDamage = nDamage + nMaxAGI * nCurrAGI
	else
		nDamage = nDamage + nMinAGI * nCurrAGI
	end

	for _, enemyHero in pairs(nEnemyHeroes) do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        then
            if enemyHero:HasModifier('modifier_teleporting') then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
            if J.WillKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL, nDelay)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_troll_warlord_battle_trance')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
	end

    if J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot) and bUsingMax then
        local hTarget = nil
        local hTargetDamage = 0
        for _, enemyHero in pairs(nEnemyHeroes) do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            and not enemyHero:HasModifier('modifier_troll_warlord_battle_trance')
            then
                if J.IsInEtherealForm(enemyHero) then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end

                local enemyHeroDamage = enemyHero:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_MAGICAL)
                if enemyHeroDamage > hTargetDamage then
                    hTarget = enemyHero
                    hTargetDamage = enemyHeroDamage
                end
            end
        end

        if hTarget then
            return BOT_ACTION_DESIRE_HIGH, hTarget
        end
    end

	if J.IsGoingOnSomeone(bot) and bUsingMax then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_ursa_enrage')
		then
            return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and not bUsingMax then
		for _, enemyHero in pairs(nEnemyHeroes) do
			if  J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
			then
                if (botHP < 0.75 and bot:WasRecentlyDamagedByAnyHero(3.0))
                or (J.IsChasingTarget(enemyHero, bot) and #nEnemyHeroes > #nAllyHeroes)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
			end
        end
	end

    if J.IsFarming(bot) and nManaAfter > nManaThreshold and (bFlowFacet or bUsingMax) then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
        local creepTarget = nil
        local creepTargetDamage = 0
        for _, creep in pairs(nNeutralCreeps) do
            if J.IsValid(creep)
            and J.CanBeAttacked(creep)
            and J.GetHP(creep) > 0.4
            then
                local creepDamage = creep:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_MAGICAL)
                if creepDamage > creepTargetDamage then
                    creepTarget = creep
                    creepTargetDamage = creepDamage
                end
            end
        end

        if creepTarget then
            return BOT_ACTION_DESIRE_HIGH, creepTarget
        end
    end

    if J.IsLaning(bot) and nManaAfter > nManaThreshold then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		for _, creep in pairs(nEnemyLaneCreeps) do
			if  J.IsValid(creep)
            and J.CanBeAttacked(creep)
			and (not bFlowFacet and (J.IsKeyWordUnit('ranged', creep)
                    or J.IsKeyWordUnit('siege', creep)
                    or J.IsKeyWordUnit('flagbearer', creep))
                or nManaAfter > 0.5)
			then
                local nDelay = (GetUnitToUnitDistance(bot, creep) / nSpeed) + nCastPoint
                if J.WillKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL, nDelay) then
                    if J.IsValidHero(nEnemyHeroes[1])
                    and not J.IsSuspiciousIllusion(nEnemyHeroes[1])
                    and GetUnitToUnitDistance(creep, nEnemyHeroes[1]) < 600
                    then
                        return BOT_ACTION_DESIRE_HIGH, creep
                    end
                end
			end
		end
	end

	if J.IsDoingRoshan(bot) and bUsingMax then
		if  J.IsRoshan(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.CanBeAttacked(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    if J.IsDoingTormentor(bot) and bUsingMax then
		if  J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderAdaptiveStrikeSTR()
    if not J.CanCastAbility(AdaptiveStrikeSTR)
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
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
	end

    if  J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
        do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
			and not J.IsDisabled(enemyHero)
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

function X.ConsiderAtttributeShift()
    if not J.CanCastAbility(AttributeShiftAGI)
    or not J.CanCastAbility(AttributeShiftSTR)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local botNetworth = bot:GetNetWorth()
    local botAttackRange = bot:GetAttackRange()
    local bToggleState__AGI = AttributeShiftAGI:GetToggleState()
    local bToggleState__STR = AttributeShiftSTR:GetToggleState()

    local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
    local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
    local nEnemyTowers = bot:GetNearbyTowers(1100, true)
    local bStronger = J.WeAreStronger(bot, 1600)

    local nCurrAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY)
	local nCurrSTR = bot:GetAttributeValue(ATTRIBUTE_STRENGTH)
    local nCurrAGIRatio = nCurrAGI / nCurrSTR * 1.5

    local nNearbyEnemyCount = 0
    for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
        if IsHeroAlive(id) then
            local info = GetHeroLastSeenInfo(id)
            if info ~= nil then
                local dInfo = info[1]
                if dInfo ~= nil and GetUnitToLocationDistance(bot, dInfo.location) < 3200 and dInfo.time_since_seen <= 5.0 then
                    nNearbyEnemyCount = nNearbyEnemyCount + 1
                end
            end
        end
    end

    if (J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(4.0)) then
        if bot:WasRecentlyDamagedByAnyHero(1.0) then
            if bToggleState__STR == false then
                return BOT_ACTION_DESIRE_HIGH, 'str'
            end
            return BOT_ACTION_DESIRE_NONE, ''
        end

        if bot:HasModifier('modifier_fountain_aura_buff') and #nInRangeEnemy == 0 then
            if nAGIRatio < 0.5 then
                if bToggleState__AGI == false then
                    return BOT_ACTION_DESIRE_HIGH, 'agi'
                end
                return BOT_ACTION_DESIRE_NONE, ''
            else
                if nAGIRatio > 0.5 + 0.02 then
                    if bToggleState__STR == false then
                        return BOT_ACTION_DESIRE_HIGH, 'str'
                    end
                    return BOT_ACTION_DESIRE_NONE, ''
                end
            end
            return BOT_ACTION_DESIRE_NONE, ''
        end

        if bToggleState__STR == true then
            return BOT_ACTION_DESIRE_HIGH, 'str'
        end
        return BOT_ACTION_DESIRE_NONE, ''
    end

    if bFlowFacet then
        -- balance ratio to do some right-click damage
        -- challenging to play around his ult (use spells), so can't take advantage of the spell amp

        if botNetworth > 30000 then
            if nCurrAGIRatio < 1.0 then
                if bToggleState__AGI == false then
                    return BOT_ACTION_DESIRE_HIGH, 'agi'
                end
                return BOT_ACTION_DESIRE_NONE, ''
            else
                if nCurrAGIRatio > 1.0 + 0.02 then
                    if bToggleState__STR == false then
                        return BOT_ACTION_DESIRE_HIGH, 'str'
                    end
                    return BOT_ACTION_DESIRE_NONE, ''
                end
            end
        else
            local ratio = J.IsInLaningPhase() and 0.4 or 0.6
            if botNetworth > 20000 then
                ratio = 0.5
            end

            if nAGIRatio < ratio then
                if bToggleState__AGI == false then
                    return BOT_ACTION_DESIRE_HIGH, 'agi'
                end
                return BOT_ACTION_DESIRE_NONE, ''
            end

            if nAGIRatio > ratio + 0.02 then
                if bToggleState__STR == false then
                    return BOT_ACTION_DESIRE_HIGH, 'str'
                end
                return BOT_ACTION_DESIRE_NONE, ''
            end
        end
    else
        if J.IsGoingOnSomeone(bot) then
            if J.IsValidHero(botTarget)
            and (J.CanBeAttacked(botTarget) or #nInRangeEnemy > 1)
            and J.IsInRange(bot, botTarget, botAttackRange + 300)
            and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local ratio = RemapValClamped(botNetworth, 5000, 25000, 0.5, 0.85)

                if #nInRangeEnemy > #nInRangeAlly and not bStronger then
                    ratio = ratio * 0.75
                end

                if nAGIRatio < ratio and botHP > 0.3 then
                    if bToggleState__AGI == false then
                        return BOT_ACTION_DESIRE_HIGH, 'agi'
                    end
                    return BOT_ACTION_DESIRE_NONE, ''
                else
                    if nAGIRatio > ratio + 0.02 then
                        if bToggleState__STR == false then
                            return BOT_ACTION_DESIRE_HIGH, 'str'
                        end
                        return BOT_ACTION_DESIRE_NONE, ''
                    end
                end
            end
        end

        if J.IsPushing(bot) then
            local ratio = RemapValClamped(botNetworth, 5000, 20000, 0.5, 0.75)
            if #nInRangeEnemy > #nInRangeAlly and not bStronger then
                ratio = ratio * 0.75
            end

            if nAGIRatio < ratio and botHP > 0.3 then
                if bToggleState__AGI == false then
                    return BOT_ACTION_DESIRE_HIGH, 'agi'
                end
                return BOT_ACTION_DESIRE_NONE, ''
            else
                if nAGIRatio > ratio + 0.02 then
                    if bToggleState__STR == false then
                        return BOT_ACTION_DESIRE_HIGH, 'str'
                    end
                    return BOT_ACTION_DESIRE_NONE, ''
                end
            end
        end

        if J.IsLaning(bot) and J.IsInLaningPhase() then
            local ratio = RemapValClamped(bot:GetLevel(), 1, 6, 0.55, 0.6)

            if nAGIRatio < ratio then
                if bToggleState__AGI == false then
                    return BOT_ACTION_DESIRE_HIGH, 'agi'
                end
                return BOT_ACTION_DESIRE_NONE, ''
            else
                if nAGIRatio > ratio + 0.02 then
                    if bToggleState__STR == false then
                        return BOT_ACTION_DESIRE_HIGH, 'str'
                    end
                    return BOT_ACTION_DESIRE_NONE, ''
                end
            end
        end

        if J.IsFarming(bot) and botHP > 0.3 then
            local ratio = RemapValClamped(botNetworth, 5000, 20000, 0.55, 0.85)
            if nAGIRatio < ratio then
                if bToggleState__AGI == false then
                    return BOT_ACTION_DESIRE_HIGH, 'agi'
                end
                return BOT_ACTION_DESIRE_NONE, ''
            else
                if nAGIRatio > ratio + 0.02 then
                    if bToggleState__STR == false then
                        return BOT_ACTION_DESIRE_HIGH, 'str'
                    end
                    return BOT_ACTION_DESIRE_NONE, ''
                end
            end
        end

        if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot) then
            if (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
            and J.CanBeAttacked(botTarget)
            and J.IsInRange(bot, botTarget, 1000)
            then
                local ratio = RemapValClamped(botNetworth, 5000, 20000, 0.5, 0.85)
                if nAGIRatio < ratio and botHP > 0.35 then
                    if bToggleState__AGI == false then
                        return BOT_ACTION_DESIRE_HIGH, 'agi'
                    end
                    return BOT_ACTION_DESIRE_NONE, ''
                else
                    if nAGIRatio > ratio + 0.02 then
                        if bToggleState__STR == false then
                            return BOT_ACTION_DESIRE_HIGH, 'str'
                        end
                        return BOT_ACTION_DESIRE_NONE, ''
                    end
                end
            end
        end
    end

    if bToggleState__STR == true then
        return BOT_ACTION_DESIRE_HIGH, 'str'
    end

    if bToggleState__AGI == true then
        return BOT_ACTION_DESIRE_HIGH, 'agi'
    end

    return BOT_ACTION_DESIRE_NONE, ''
end

function X.ConsiderMorph()
    if not J.CanCastAbility(Morph)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Morph:GetCastRange())
    local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange)

	if J.IsGoingOnSomeone(bot)
	then
        local target = nil
        local targetScore = 0

        if (J.IsEarlyGame() and #nInRangeEnemy > 0)
        or #nInRangeEnemy > 1
        then
            for _, enemyHero in pairs(nInRangeEnemy) do
                if J.IsValidHero(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                then
                    local score = M.GetMorphEngageScore(enemyHero:GetUnitName())
                    if score > targetScore then
                        target = enemyHero
                        targetScore = score
                    end
                end
            end
        end

        if target ~= nil then
            return BOT_ACTION_DESIRE_HIGH, target
        end
	end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
    and bot:WasRecentlyDamagedByAnyHero(3.0)
    and Waveform:GetCooldownTimeRemaining() > 3
	then
        local target = nil
        local targetScore = 0

        for _, enemyHero in pairs(nInRangeEnemy) do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            then
                local score = M.GetMorphRetreatScore(enemyHero:GetUnitName())
                if score > targetScore then
                    target = enemyHero
                    targetScore = score
                end
            end
        end

        if target ~= nil then
            return BOT_ACTION_DESIRE_HIGH, target
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.SetRatios()
    local count = 0
    local nAddedAGI = 0
    local nAddedSTR = 0

    local primaryAttribute = bot:GetPrimaryAttribute()

    local itemIndex = {0,1,2,3,4,5,16,17}
    for i = 1, #itemIndex do
        local hItem = bot:GetItemInSlot(itemIndex[i])
        if hItem then
            local sItemName = hItem:GetName()
            if string.find(sItemName, 'item_power_treads') then
                local bonusStats = hItem:GetSpecialValueInt('bonus_stat')
                local treadsState = hItem:GetPowerTreadsStat()
                if treadsState == ATTRIBUTE_AGILITY then
                    nAddedAGI = nAddedAGI + bonusStats
                elseif treadsState == ATTRIBUTE_STRENGTH then
                    nAddedSTR = nAddedSTR + bonusStats
                end
            end

            if string.find(sItemName, 'evolved') then
                local primaryStat = hItem:GetSpecialValueInt('primary_stat')
                if primaryAttribute == ATTRIBUTE_AGILITY then
                    nAddedAGI = nAddedAGI + primaryStat
                elseif primaryAttribute == ATTRIBUTE_STRENGTH then
                    nAddedSTR = nAddedSTR + primaryStat
                end
            end

            local allStats = hItem:GetSpecialValueInt('bonus_all_stats')

			nAddedAGI = nAddedAGI + hItem:GetSpecialValueInt('bonus_agility') + allStats
            nAddedSTR = nAddedSTR + hItem:GetSpecialValueInt('bonus_strength') + allStats
        end
    end

    -- Stats
    count = 0
    if bot:GetLevel() >= 26 then count = 7
    elseif bot:GetLevel() >= 24 then count = 6
    elseif bot:GetLevel() >= 23 then count = 5
    elseif bot:GetLevel() >= 22 then count = 4
    elseif bot:GetLevel() >= 21 then count = 3
    elseif bot:GetLevel() >= 19 then count = 2
    elseif bot:GetLevel() >= 17 then count = 1
    end

    -- morphling's primary in flow is str
    -- but accumulation's x3 applies to agility...
    -- nAddedAGI = nAddedAGI + count * 3 + count * 2 -- from innate
    -- nAddedSTR = nAddedSTR + count * 2 -- from innate
    if primaryAttribute == ATTRIBUTE_AGILITY then
        nAddedAGI = nAddedAGI + count * 3 + count * 2 -- from innate
        nAddedSTR = nAddedSTR + count * 2 -- from innate
    elseif primaryAttribute == ATTRIBUTE_STRENGTH then
        nAddedAGI = nAddedAGI + count * 2 -- from innate
        nAddedSTR = nAddedSTR + count * 3 + count * 2 -- from innate
    end

    -- Stats Talents
    local talent__AGI = bot:GetAbilityInSlot(14)
	local talent__STR = bot:GetAbilityInSlot(16)

    if talent__AGI ~= nil and talent__AGI:IsTrained() then
        nAddedAGI = nAddedAGI + talent__AGI:GetSpecialValueInt('value')
    end

    if talent__STR ~= nil and talent__STR:IsTrained() then
        nAddedSTR = nAddedSTR + talent__STR:GetSpecialValueInt('value')
    end

    local nBaseAGI = AGI_BASE + AGI_GROWTH_RATE * (bot:GetLevel() - 1)
    local nBaseSTR = STR_BASE + STR_GROWTH_RATE * (bot:GetLevel() - 1)

    local nTotalAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY)
    local nTotalSTR = bot:GetAttributeValue(ATTRIBUTE_STRENGTH)

    local nShiftedAGI = nTotalAGI - nBaseAGI
    local nShiftedSTR = nTotalSTR - nBaseSTR

    local nEffAGI = nBaseAGI + nShiftedAGI - nAddedAGI
    local nEffSTR = nBaseSTR + nShiftedSTR - nAddedSTR

    nAGIRatio = nEffAGI / (nEffAGI + nEffSTR)
    nSTRRatio = nEffSTR / (nEffAGI + nEffSTR)

    -- if math.floor(DotaTime()) % 3 == 0 then
    --     print(nAGIRatio, nSTRRatio)
    --     print(nEffAGI, nEffSTR)
    --     print(nAddedAGI, nAddedSTR)
    --     print('===')
    -- end
end

-- set builds
function X.SetItemBuild()
    bFlowFacet = bot:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH and true or false

    local index = 1
    if bFlowFacet then index = 2 end

    sSelectedBuild = HeroBuild[sRole][index]

    X['sBuyList'] = sSelectedBuild.buy_list
    X['sSellList'] = sSelectedBuild.sell_list
end

function X.SetAbilityBuild()
    bFlowFacet = bot:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH and true or false

    local index = 1
    if bFlowFacet then index = 2 end

    sSelectedBuild = HeroBuild[sRole][index]

    nTalentBuildList = J.Skill.GetTalentBuild(J.Skill.GetRandomBuild(sSelectedBuild.talent))
    nAbilityBuildList = J.Skill.GetRandomBuild(sSelectedBuild.ability)

    X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
end

return X
