-- Currently bugged internally. Just adding her here in case Valve fixes her and (others) in the future...
-- Wasted my f- time...

local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos4,5
                        ['t25'] = {0, 10},
                        ['t20'] = {10, 0},
                        ['t15'] = {10, 0},
                        ['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,1,3,3,3,2,6,2,2,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
	"item_enchanted_mango",
	"item_blood_grenade",
	"item_priest_outfit",
	"item_mekansm",
	"item_glimmer_cape",--
    "item_maelstrom",
	"item_guardian_greaves",--
    "item_gungir",--
	"item_shivas_guard",--
	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_ultimate_scepter_2",
	"item_sheepstick",--
	"item_moon_shard",
	"item_octarine_core",--
}

sRoleItemsBuyList['pos_5'] = {
	"item_blood_grenade",

	'item_mage_outfit',
	'item_ancient_janggo',
	'item_glimmer_cape',
	'item_boots_of_bearing',
	'item_pipe',
	"item_shivas_guard",
	'item_cyclone',
	'item_sheepstick',
	"item_wind_waker",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_3'] = {
    "item_tango",
    "item_double_branches",
    "item_blight_stone",

    "item_tranquil_boots",
    "item_magic_wand",
    "item_mage_slayer",--
    "item_maelstrom",
    "item_force_staff",
    "item_gungir",--
    "item_boots_of_bearing",--
    "item_ultimate_scepter",
    "item_sheepstick",--
    "item_hurricane_pike",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_greater_crit",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = {
	"item_ranged_carry_outfit",
	"item_dragon_lance",
	"item_rod_of_atos",
	"item_maelstrom",
	"item_black_king_bar",
	"item_gungir",
	"item_travel_boots",
	"item_orchid",
	"item_bloodthorn",
    "item_force_staff",
	"item_hurricane_pike",
	"item_ultimate_scepter",
	"item_moon_shard",
	"item_travel_boots_2",
	"item_ultimate_scepter_2",
	"item_butterfly",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local AcornShot         = bot:GetAbilityByName('hoodwink_acorn_shot')
local Bushwhack         = bot:GetAbilityByName('hoodwink_bushwhack')
local Scurry            = bot:GetAbilityByName('hoodwink_scurry')
local HuntersBoomerang  = bot:GetAbilityByName('hoodwink_hunters_boomerang')
local Decoy             = bot:GetAbilityByName('hoodwink_decoy')
local Sharpshooter      = bot:GetAbilityByName('hoodwink_sharpshooter')

local AcornShotDesire, AcornShotLocation
local BushwhackDesire, BushwhackLocation
local ScurryDesire
local HuntersBoomerangDesire, HuntersBoomerangTarget
local DecoyDesire
local SharpshooterDesire, SharpshooterLocation

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    AcornShotDesire, AcornShotLocation = X.ConsiderAcornShot()
    if AcornShotDesire > 0
    then
        bot:Action_UseAbilityOnLocation(AcornShot, AcornShotLocation)
        return
    end

    BushwhackDesire, BushwhackLocation = X.ConsiderBushwhack()
    if BushwhackDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Bushwhack, BushwhackLocation)
        return
    end

    ScurryDesire = X.ConsiderScurry()
    if ScurryDesire > 0
    then
        bot:Action_UseAbility(Scurry)
        return
    end

    HuntersBoomerangDesire, HuntersBoomerangTarget = X.ConsiderHuntersBoomerang()
    if HuntersBoomerangDesire > 0
    then
        bot:Action_UseAbilityOnEntity(HuntersBoomerang, HuntersBoomerangTarget)
        return
    end

    DecoyDesire = X.ConsiderDecoy()
    if DecoyDesire > 0
    then
        bot:Action_UseAbility(Decoy)
        return
    end

    SharpshooterDesire, SharpshooterLocation = X.ConsiderSharpshooter()
    if SharpshooterDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Sharpshooter, SharpshooterLocation)
        return
    end
end

function X.ConsiderAcornShot()
    if not AcornShot:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, AcornShot:GetCastRange())
	local nCastPoint = AcornShot:GetCastPoint()
	local nRadius = AcornShot:GetSpecialValueInt('bounce_range')
    local nDamage = AcornShot:GetSpecialValueInt('acorn_shot_damage') * (bot:GetAttackDamage() * 0.75)
    local nSpeed = AcornShot:GetSpecialValueInt('projectile_speed')
    local nAbilityLevel = AcornShot:GetLevel()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanBeAttacked(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
		end
    end

    local nAllyHeroes  = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, nCastRange, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and (J.IsRetreating(allyHero)
            and J.GetHP(allyHero) < 0.75
            and allyHero:WasRecentlyDamagedByAnyHero(2))
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            then
                local nDelay = (GetUnitToUnitDistance(bot, nAllyInRangeEnemy[1]) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(nDelay)
            end
        end
    end

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
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.65 and bot:WasRecentlyDamagedByAnyHero(2.5)))
        and J.IsValidHero(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
		end
	end

	if  (J.IsPushing(bot) or J.IsDefending(bot))
    and (J.HasItem(bot, 'item_maelstrom') or J.HasItem(bot, 'item_gungir') or J.HasItem(bot, 'item_mjollnir'))
    and nAbilityLevel >= 3
    and not J.IsThereCoreNearby(600)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nLocationAoE.count >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    -- Always Point Target
    if not AcornShot:GetAutoCastState()
    then
        AcornShot:ToggleAutoCast()
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderBushwhack()
    if not Bushwhack:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, Bushwhack:GetCastRange())
    local nCastPoint = Bushwhack:GetCastPoint()
    local nDamage = Bushwhack:GetSpecialValueInt('total_damage')
	local nRadius = Bushwhack:GetSpecialValueInt('trap_radius')
    local nSpeed = Bushwhack:GetSpecialValueInt('projectile_speed')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
            local nTrees = enemyHero:GetNearbyTrees(nRadius - 25)

            if nTrees ~= nil and #nTrees > 0
            then
                if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end

                if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
                and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
                and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
                and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
                and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
                then
                    local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
                end
            end
		end
    end

    local nAllyHeroes  = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, nCastRange, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and (J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(2.5))
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            then
                local nTrees = nAllyInRangeEnemy[1]:GetNearbyTrees(nRadius - 25)

                if nTrees ~= nil and #nTrees > 0
                then
                    local nDelay = (GetUnitToUnitDistance(bot, nAllyInRangeEnemy[1]) / nSpeed) + nCastPoint
                    return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(nDelay)
                end
            end
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

        if nLocationAoE.count >= 2
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and GetUnitToLocationDistance(enemyHero, nLocationAoE.targetloc) <= nRadius
                then
                    local nTrees = enemyHero:GetNearbyTrees(nRadius - 25)

                    if nTrees ~= nil and #nTrees > 0
                    then
                        local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
                    end
                end
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
		then
			local nTrees = botTarget:GetNearbyTrees(nRadius - 25)

			if nTrees ~= nil and #nTrees > 0
            then
                local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
			end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.65 and bot:WasRecentlyDamagedByAnyHero(2.5)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
		then
            local nTrees = nInRangeEnemy[1]:GetNearbyTrees(nRadius - 25)

            if nTrees ~= nil and #nTrees > 0
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderScurry()
    if not Scurry:IsFullyCastable()
    or bot:HasModifier('modifier_hoodwink_scurry_active')
    or J.IsRealInvisible(bot)
    then
        return BOT_ACTION_DESIRE_NONE
    end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,600, true, BOT_MODE_NONE)
        local loc = J.GetEscapeLoc()

        if bot:IsFacingLocation(loc, 30)
        then
            if  nInRangeAlly ~= nil and nInRangeEnemy
            and ((#nInRangeEnemy > #nInRangeAlly)
                or (J.GetHP(bot) < 0.55 and bot:WasRecentlyDamagedByAnyHero(2)))
            and J.IsValidHero(nInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
            and not J.IsDisabled(nInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            if J.GetHP(bot) < 0.55 and bot:WasRecentlyDamagedByTower(2.5)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSharpshooter()
    if not Sharpshooter:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = 1600
	local nAttackRange = bot:GetAttackRange()
	local nSpeed = Sharpshooter:GetSpecialValueInt('arrow_speed')
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsInRange(bot, botTarget, nAttackRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed)
			local stability = botTarget:GetMovementDirectionStability()
			local loc = botTarget:GetExtrapolatedLocation(nDelay)

			if stability < 0.95
            then
				loc = botTarget:GetLocation()
			end

			return BOT_ACTION_DESIRE_HIGH, loc
		end
	end

	if J.IsDefending(bot)
	then
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nInRangeEnemy)
        do
			if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
			then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderHuntersBoomerang()
    if not HuntersBoomerang:IsTrained()
    or not HuntersBoomerang:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, HuntersBoomerang:GetCastRange())
    local nRadius = HuntersBoomerang:GetSpecialValueInt('radius')
    local nCastPoint = HuntersBoomerang:GetCastPoint()

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

        if nLocationAoE.count >= 2
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
                and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
                and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
                and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
                and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and GetUnitToLocationDistance(enemyHero, nLocationAoE.targetloc) <= nRadius
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDecoy()
    if not Decoy:IsTrained()
    or not Decoy:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nEnemyTowers = bot:GetNearbyTowers(900, true)
    local nEnemyHeroes = J.GetNearbyHeroes(bot,900, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

	if	bot:DistanceFromFountain() > 600
    and nEnemyTowers ~= nil and #nEnemyTowers == 0
    and not bot:HasModifier('modifier_item_dustofappearance')
    and not bot:HasModifier('modifier_slardar_amplify_damage')
    and not bot:HasModifier('modifier_item_glimmer_cape')
    and not bot:IsInvulnerable()
    and not bot:IsMagicImmune()
	then
		if bot:IsSilenced()
        or bot:IsRooted()
        or J.IsStunProjectileIncoming(bot, bot:GetAttackRange())
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		if (J.IsRetreating(bot)
		    and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH
		    and not bot:HasModifier('modifier_fountain_aura'))
		or (botTarget == nil
			and nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
			and J.GetHP(bot) < 0.33 + ( 0.09 * #nEnemyHeroes ))
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

return X