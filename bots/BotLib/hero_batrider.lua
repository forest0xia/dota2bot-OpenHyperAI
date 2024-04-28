local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sOutfitType   = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						{--pos2
                            ['t25'] = {10, 0},
                            ['t20'] = {10, 0},
                            ['t15'] = {10, 0},
                            ['t10'] = {0, 10},
                        },
                        {--pos3
                            ['t25'] = {10, 0},
                            ['t20'] = {10, 0},
                            ['t15'] = {0, 10},
                            ['t10'] = {0, 10},
                        }
}

local tAllAbilityBuildList = {
						{1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},--pos2
                        {1,2,1,3,1,6,1,3,3,3,2,6,2,2,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sOutfitType == "outfit_mid"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
elseif sOutfitType == "outfit_tank"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local tOutFitList = {}

tOutFitList['outfit_carry'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mid'] = {
    "item_tango",
    "item_double_branches",
    "item_double_branches",
    "item_faerie_fire",

    "item_bottle",
    "item_magic_wand",
    "item_travel_boots",
    "item_blink",
    "item_black_king_bar",--
    "item_octarine_core",--
    "item_shivas_guard",--
    "item_ultimate_scepter",
    "item_refresher",--
    "item_overwhelming_blink",--
    "item_recipe_ultimate_scepter_2",
    "item_travel_boots_2",--
    "item_aghanims_shard",
    "item_moon_shard",
}

tOutFitList['outfit_tank'] = {
    "item_tango",
    "item_gauntlets",
    "item_circlet",
    "item_double_branches",

    "item_bracer",
    "item_boots",
    "item_magic_wand",
    "item_wind_lace",
    "item_veil_of_discord",
    "item_blink",
    "item_black_king_bar",--
    "item_travel_boots",
    "item_shivas_guard",--
    "item_ultimate_scepter",
    "item_octarine_core",--
    "item_refresher",--
    "item_overwhelming_blink",--
    "item_recipe_ultimate_scepter_2",
    "item_travel_boots_2",--
    "item_aghanims_shard",
    "item_moon_shard",
}

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

Pos2SellList = {
    "item_branches",
	"item_bottle",
    "item_magic_wand",
}

Pos3SellList = {
	"item_magic_wand",
}

X['sSellList'] = {}

if sOutfitType == "outfit_mid"
then
    X['sSellList'] = Pos2SellList
elseif sOutfitType == "outfit_tank"
then
    X['sSellList'] = Pos3SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local StickyNapalm  = bot:GetAbilityByName('batrider_sticky_napalm')
local Flamebreak    = bot:GetAbilityByName('batrider_flamebreak')
local Firefly       = bot:GetAbilityByName('batrider_firefly')
local FlamingLasso  = bot:GetAbilityByName('batrider_flaming_lasso')

local StickyNapalmDesire, StickyNapalmLocation
local FlamebreakDesire, FlamebreakLocation
local FireflyDesire
local FlamingLassoDesire, FlamingLassoTarget

local Blink = nil
local BlinkDesire
local BlinkLocation

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    or bot:IsInvisible()
    then
        return
    end

    FireflyDesire = X.ConsiderFirefly()
    if FireflyDesire > 0
    then
        bot:Action_UseAbility(Firefly)
        return
    end

    FlamingLassoDesire, FlamingLassoTarget = X.ConsiderFlamingLasso()
    if FlamingLassoDesire > 0
    then
        BlinkDesire, Blink, BlinkLocation = ConsiderBlink()
        if BlinkDesire > 0
        then
            bot:Action_UseAbilityOnLocation(Blink, BlinkLocation)
        end

        bot:Action_UseAbilityOnEntity(FlamingLasso, FlamingLassoTarget)
        return
    end

    FlamebreakDesire, FlamebreakLocation = X.ConsiderFlamebreak()
    if FlamebreakDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Flamebreak, FlamebreakLocation)
        return
    end

    StickyNapalmDesire, StickyNapalmLocation = X.ConsiderStickyNapalm()
    if StickyNapalmDesire > 0
    then
        bot:Action_UseAbilityOnLocation(StickyNapalm, StickyNapalmLocation)
        return
    end
end

function X.ConsiderStickyNapalm()
    if not StickyNapalm:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = StickyNapalm:GetCastRange()
    local nCastPoint = StickyNapalm:GetCastPoint()
    local nRadius = StickyNapalm:GetSpecialValueInt('radius')
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
		then
            if J.IsRunning(botTarget)
            and not botTarget:IsFacingLocation(bot:GetLocation(), 30)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end

			return BOT_ACTION_DESIRE_MODERATE, botTarget:GetExtrapolatedLocation(nCastPoint)
		end
	end

    if J.IsRetreating(bot)
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(enemyHero, 1.0)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
			end
		end
	end

    if J.IsDoingRoshan(bot)
	then
		local botAttackTarget = bot:GetAttackTarget()

		if J.IsRoshan(botAttackTarget)
        and J.CanCastOnMagicImmune(botAttackTarget)
        and J.IsInRange(botAttackTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, botAttackTarget:GetLocation()
		end
	end

    if (J.IsDefending(bot) or J.IsPushing(bot))
    and nMana > 0.75
    then
        local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )

        if nLocationAoE.count >= 4 and #nLaneCreeps >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsLaning(bot)
    and nMana > 0.65
    then
        local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

        if nLocationAoE.count >= 3 and #nLaneCreeps >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsFarming(bot)
    and nMana > 0.45
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

        if nLocationAoE.count >= 2 and #nNeutralCreeps >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFlamebreak()
    if not Flamebreak:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = Flamebreak:GetCastRange()
    local nCastPoint = Flamebreak:GetCastPoint()
    local nRadius = Flamebreak:GetSpecialValueInt('explosion_radius')
    local nSpeed = Flamebreak:GetSpecialValueInt('speed')
    local botTarget = J.GetProperTarget(bot)
    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(botTarget, bot, 1000)
		then
			local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint

			return BOT_ACTION_DESIRE_MODERATE, botTarget:GetExtrapolatedLocation(nDelay)
		end
	end

    if J.IsRetreating(bot)
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(enemyHero, 1)
			then
				if GetUnitToUnitDistance(bot, enemyHero) < nRadius
                then
					return BOT_ACTION_DESIRE_MODERATE, bot:GetLocation()
				else
					return BOT_ACTION_DESIRE_MODERATE, enemyHero:GetExtrapolatedLocation(nCastPoint)
				end
			end
		end
	end

    if J.IsDefending(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

        if nLocationAoE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFirefly()
    if not Firefly:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local botTarget = J.GetProperTarget(bot)
    local nEnemyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

    if J.IsStuck(bot)
    or bot:HasModifier('modifier_batrider_flaming_lasso_self')
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsRetreating(bot)
	then
		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(enemyHero, 1)
            and (J.GetHP(bot) < 0.51 or #nEnemyHeroes >= 2 or not J.WeAreStronger(bot, 1000))
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

    if J.IsInTeamFight(bot, 1000)
	then
		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderFlamingLasso()
    if not FlamingLasso:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = FlamingLasso:GetCastRange()
    local nDuration = FlamingLasso:GetSpecialValueInt('duration')
    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(botTarget, bot, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
		then
            if J.IsCore(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            else
                return BOT_ACTION_DESIRE_LOW, botTarget
            end
		end
	end

    if J.IsInTeamFight(bot, 1200)
	then
        local botStrongestTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)

        if J.IsValidTarget(botStrongestTarget
        and J.CanCastOnMagicImmune(botStrongestTarget))
        and J.IsInRange(bot, botStrongestTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botStrongestTarget)
        then
			return BOT_ACTION_DESIRE_HIGH, botStrongestTarget
		end

		-- for _, enemyHero in pairs(nEnemyHeroes)
		-- do
		-- 	if J.CanCastOnMagicImmune(enemyHero)
        --     and J.IsInRange(bot, enemyHero, nCastRange)
        --     and not J.IsSuspiciousIllusion(enemyHero)
		-- 	then
        --         local enemyPos = J.GetPosition(enemyHero)

		-- 		if (enemyPos == 1 or enemyPos == 2) or J.IsCore(enemyHero)
        --         then
        --             return BOT_ACTION_DESIRE_HIGH, botTarget
        --         else
        --             return BOT_ACTION_DESIRE_VERYLOW, botTarget
        --         end
		-- 	end
		-- end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function ConsiderBlink()
    local blink = nil
    local nCastRange = 1200

    for i = 0, 5 do
		local item = bot:GetItemInSlot(i)

		if item ~= nil
        and (item:GetName() == "item_blink" or item:GetName() == "item_overwhelming_blink" or item:GetName() == "item_arcane_blink" or item:GetName() == "item_swift_blink")
        then
			blink = item
			break
		end
	end

    if blink ~= nil and blink:IsFullyCastable()
    and FlamingLasso:IsFullyCastable()
    and J.IsGoingOnSomeone(bot)
	then
		local botTarget = bot:GetTarget()

		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsInRange(bot, botTarget, nCastRange - 600)
		then
			return BOT_ACTION_DESIRE_HIGH, blink, botTarget:GetExtrapolatedLocation(0.1)
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil, 0
end

return X