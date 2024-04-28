local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetOutfitType( bot )

local tTalentTreeList = {--pos4,5
                        ['t25'] = {0, 10},
                        ['t20'] = {0, 10},
                        ['t15'] = {10, 0},
                        ['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,3,3,3,6,3,1,1,1,6,2,2,2,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

local sRoleItemsBuyList = {}

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mid'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_tank'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_priest'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_enchanted_mango",

    "item_tranquil_boots",
    "item_magic_wand",
    "item_blink",
    "item_aghanims_shard",
    "item_aether_lens",--
    "item_glimmer_cape",--
    "item_cyclone",
    "item_boots_of_bearing",--
    "item_octarine_core",--
    "item_wind_waker",--
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_mage'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",
    "item_enchanted_mango",

    "item_arcane_boots",
    "item_magic_wand",
    "item_blink",
    "item_aghanims_shard",
    "item_aether_lens",--
    "item_glimmer_cape",--
    "item_cyclone",
    "item_guardian_greaves",--
    "item_octarine_core",--
    "item_wind_waker",--
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos4SellList = {
	"item_magic_wand",
}

Pos5SellList = {
    "item_magic_wand",
}

X['sSellList'] = {}

if sRole == "outfit_priest"
then
    X['sSellList'] = Pos4SellList
elseif sRole == "outfit_mage"
then
    X['sSellList'] = Pos5SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Fissure       = bot:GetAbilityByName('earthshaker_fissure')
local EnchantTotem  = bot:GetAbilityByName('earthshaker_enchant_totem')
local Aftershock    = bot:GetAbilityByName('earthshaker_aftershock')
local EchoSlam      = bot:GetAbilityByName('earthshaker_echo_slam')

local FissureDesire, FissureLocation
local EnchantTotemDesire, EnchantTotemLocation, WantToJump
local EchoSlamDesire

local TotemSlamDesire, TotemSlamLocation

local Blink
local BlinkLocation

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    or bot:NumQueuedActions() > 0
    then
        return
    end

    TotemSlamDesire, TotemSlamLocation = X.ConsiderTotemSlam()
    if TotemSlamDesire > 0
    then
        local nLeapDuration = EnchantTotem:GetSpecialValueFloat('scepter_leap_duration')

        bot:Action_ClearActions(false)
        bot:ActionQueue_UseAbilityOnLocation(EnchantTotem, TotemSlamLocation)
        bot:ActionQueue_Delay(nLeapDuration)
        bot:ActionQueue_UseAbility(EchoSlam)
        return
    end

    EchoSlamDesire = X.ConsiderEchoSlam()
    if EchoSlamDesire > 0
    then
        if HasBlink()
        then
            bot:Action_ClearActions(false)
            bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
            bot:ActionQueue_Delay(0.3)
            bot:ActionQueue_UseAbility(EchoSlam)
        else
            bot:Action_UseAbility(EchoSlam)
        end

        return
    end

    EnchantTotemDesire, EnchantTotemLocation, WantToJump = X.ConsiderEnchantTotem()
    if EnchantTotemDesire > 0
    then
        if WantToJump
        then
            bot:Action_UseAbilityOnLocation(EnchantTotem, EnchantTotemLocation)
        else
            if bot:HasScepter()
            then
                bot:Action_UseAbility(EnchantTotem)
                bot:Action_UseAbility(EnchantTotem)
            else
                bot:Action_UseAbility(EnchantTotem)
            end
        end

        return
    end

    FissureDesire, FissureLocation = X.ConsiderFissure()
    if FissureDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Fissure, FissureLocation)
        return
    end
end

function X.ConsiderFissure()
    if not Fissure:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, Fissure:GetCastRange())
	local nCastPoint = Fissure:GetCastPoint()
	local nRadius = Fissure:GetSpecialValueInt('fissure_radius')
    local nDamage = Fissure:GetSpecialValueInt('fissure_damage')
    local nAbilityLevel = Fissure:GetLevel()
	local nManaCost = Fissure:GetManaCost()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
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

            if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end
        end
    end

    local nAllyHeroes  = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  J.IsRetreating(allyHero)
        and not allyHero:IsIllusion()
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetLocation()
            end
        end
    end

	if J.IsInTeamFight(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if nLocationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
		then
            local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
            local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and ((#nInRangeAlly <= 1 and #nInRangeEnemy <= 1)
                or (#nInRangeEnemy > #nInRangeAlly and J.WeAreStronger(bot, 1000)))
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end
		end
	end

	if J.IsRetreating(bot)
    then
        local nInRangeAlly  = bot:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  (nInRangeAlly ~= nil and nInRangeEnemy ~= nil and #nInRangeEnemy > #nInRangeAlly)
        and (#nInRangeEnemy >= 2 or J.GetHP(bot) < 0.5)
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
        end
    end

	if  J.IsPushing(bot) or J.IsDefending(bot)
    and J.IsAllowedToSpam(bot, nManaCost)
    and nAbilityLevel >= 3
    and #nEnemyHeroes == 0
    and not J.IsThereCoreNearby(nCastRange)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1300, true)

		if  #nEnemyLaneCreeps >= 5
		and J.IsValid(nEnemyLaneCreeps[1])
		and J.CanBeAttacked(nEnemyLaneCreeps[1])
		then
			local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius + 75, nCastPoint, 0)

			if nLocationAoE.count >= 3
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderEnchantTotem()
    if not EnchantTotem:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0, false
    end

    local nCastRange = bot:HasScepter() and EnchantTotem:GetSpecialValueInt('distance_scepter') or 0
	local nCastPoint = EnchantTotem:GetCastPoint()
	local manaCost = EnchantTotem:GetManaCost()
	local nRadius = Aftershock:GetSpecialValueInt('aftershock_range')
    local botTarget = J.GetProperTarget(bot)

	if bot:HasScepter() and J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange), true
	end

	if J.IsInTeamFight(bot)
	then
		if bot:HasScepter()
        then
            local nLeapDuration = EnchantTotem:GetSpecialValueFloat('scepter_leap_duration')
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nLeapDuration, 0)

            if nLocationAoE.count >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, true
            end
		else
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nRadius, nRadius, nCastPoint, 0)

            if nLocationAoE.count >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, 0, false
            end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeEnemy <= 1
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
		then
			if bot:HasScepter()
            then
				if  J.IsInRange(bot, botTarget, nCastRange)
				and not J.IsInRange(bot, botTarget, nRadius)
                and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
                then
					return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), true
                else
                    if J.IsInRange(bot, botTarget, nRadius)
                    then
                        return BOT_ACTION_DESIRE_HIGH, 0, false
                    end
				end
			else
                if J.IsInRange(bot, botTarget, nRadius)
                then
                    return BOT_ACTION_DESIRE_HIGH, 0, false
                end
			end
		end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly  = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

        if  (nInRangeAlly ~= nil and nInRangeEnemy ~= nil and #nInRangeEnemy > #nInRangeAlly)
        and (#nInRangeEnemy >= 2 or J.GetHP(bot) < 0.5)
        and J.IsValidHero(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        then
            if bot:HasScepter()
            then
                local loc = J.GetEscapeLoc()
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
            else
                if  GetUnitToUnitDistance(bot, nInRangeEnemy[1]) < nRadius
                and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
                then
                    return BOT_ACTION_DESIRE_HIGH, 0, false
                end
            end
        end
    end

    if  (J.IsDefending(bot) or J.IsPushing(bot))
    and J.CanSpamSpell(bot, manaCost)
    and not bot:HasModifier('modifier_earthshaker_enchant_totem')
    and not J.IsThereCoreNearby(800)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if bot:HasScepter()
        then
            local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0, 0)

            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and nLocationAoE.count >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, true
            end
        else
            nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

            if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, 0, false
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        then
            return BOT_ACTION_DESIRE_HIGH, 0, false
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, false
end

function X.ConsiderEchoSlam()
    if not EchoSlam:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = EchoSlam:GetSpecialValueInt('echo_slam_echo_range')

	if J.IsInTeamFight(bot, 1200)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nRadius / 2, true, BOT_MODE_NONE)

        if HasBlink()
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1199, nRadius / 2, 0, 0)

            if nLocationAoE.count >= 3
            then
                BlinkLocation = nLocationAoE.targetloc
                return BOT_ACTION_DESIRE_HIGH
            end
        end

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTotemSlam()
    if CanDoTotemSlam()
    then
        local nCastRange = EnchantTotem:GetSpecialValueInt('distance_scepter')
        local nRadius = EchoSlam:GetSpecialValueInt('echo_slam_echo_range')
        local nLeapDuration = EnchantTotem:GetSpecialValueFloat('scepter_leap_duration')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius / 2, nLeapDuration, 0)

            if  nLocationAoE.count >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoTotemSlam()
    if  bot:HasScepter()
    and EnchantTotem:IsFullyCastable()
    and EchoSlam:IsFullyCastable()
    then
        local manaCost = EnchantTotem:GetManaCost() + EchoSlam:GetManaCost()

        if  bot:GetMana() >= manaCost
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