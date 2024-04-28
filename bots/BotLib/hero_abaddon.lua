local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sOutfitType = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,2,1,2,6,2,1,1,1,6,3,3,3,6},--pos4,5
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = {
    "item_tango",
    "item_tango",
    "item_enchanted_mango",
    "item_enchanted_mango",
    "item_double_branches",
    "item_faerie_fire",
    "item_blood_grenade",

    "item_tranquil_boots",
    "item_magic_wand",
    "item_solar_crest",--
    "item_holy_locket",--
    "item_ultimate_scepter",
    "item_force_staff",--
    "item_boots_of_bearing",--
    "item_lotus_orb",--
    "item_wind_waker",--
    "item_aghanims_shard",
    "item_recipe_ultimate_scepter_2"
}

tOutFitList['outfit_mage'] = {
    "item_tango",
    "item_tango",
    "item_enchanted_mango",
    "item_enchanted_mango",
    "item_double_branches",
    "item_faerie_fire",
    "item_blood_grenade",

    "item_arcane_boots",
    "item_magic_wand",
    "item_solar_crest",--
    "item_holy_locket",--
    "item_ultimate_scepter",
    "item_force_staff",--
    "item_guardian_greaves",--
    "item_lotus_orb",--
    "item_wind_waker",--
    "item_aghanims_shard",
    "item_recipe_ultimate_scepter_2"
}


X['sBuyList'] = tOutFitList[sOutfitType]

Pos4SellList = {
	"item_magic_wand",
}

Pos5SellList = {
	"item_magic_wand",
}

X['sSellList'] = {}

if sOutfitType == "outfit_priest"
then
    X['sSellList'] = Pos4SellList
elseif sOutfitType == "outfit_mage"
then
    X['sSellList'] = Pos5SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )
	if Minion.IsValidUnit( hMinionUnit )
	then
		if hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end
end

local MistCoil          = bot:GetAbilityByName( 'abaddon_death_coil' )
local AphoticShield     = bot:GetAbilityByName( 'abaddon_aphotic_shield' )
-- local CurseOfAvernus    = bot:GetAbilityByName( 'abaddon_frostmourne' )
-- local BorrowedTimelocal = bot:GetAbilityByName( 'abaddon_borrowed_time' )

local MistCoilDesire, MistCoilTarget
local AphoticShieldDesire, AphoticShieldTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    or bot:IsInvisible()
    then
        return
    end

    AphoticShieldDesire, AphoticShieldTarget = X.ConsiderAphoticShield()
    if AphoticShieldDesire > 0
    then
        bot:Action_UseAbilityOnEntity(AphoticShield, AphoticShieldTarget)
        return
    end

    MistCoilDesire, MistCoilTarget = X.ConsiderMistCoil()
    if MistCoilDesire > 0
    then
        bot:Action_UseAbilityOnEntity(MistCoil, MistCoilTarget)
        return
    end
end

function X.ConsiderMistCoil()
    if not MistCoil:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange  = MistCoil:GetCastRange()
	local nDamage     = MistCoil:GetSpecialValueInt('target_damage')
	local nSelfDamage = MistCoil:GetSpecialValueInt('self_damage')
    local nDamageType = DAMAGE_TYPE_MAGICAL

    local botTarget = bot:GetTarget()
    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)

    if J.HasAghanimsShard(bot)
    then
        nDamage = bot:GetAttackDamage()
        nDamageType = DAMAGE_TYPE_PHYSICAL
    end

	for _, npcAlly in pairs(nAllyHeroes)
	do
		if J.IsValidHero(npcAlly)
		and J.IsInRange(bot, npcAlly, nCastRange)
		and not npcAlly:HasModifier('modifier_legion_commander_press_the_attack')
		and not npcAlly:IsMagicImmune()
		and not npcAlly:IsInvulnerable()
		and npcAlly:CanBeSeen()
		then
			if J.GetHP(npcAlly) < 0.4
            and npcAlly:WasRecentlyDamagedByAnyHero(2.0)
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly
			end

			if J.IsGoingOnSomeone(npcAlly)
			then
				local allyTarget = J.GetProperTarget(npcAlly)

				if J.IsValidHero(allyTarget)
				and npcAlly:IsFacingLocation(allyTarget:GetLocation(), 20)
				and J.IsInRange(npcAlly, allyTarget, npcAlly:GetAttackRange())
                and J.GetHP(npcAlly) < 0.5
				then
					return BOT_ACTION_DESIRE_HIGH, npcAlly
				end
			end
		end
	end

    if J.IsRetreating(bot)
    and bot:GetHealth() > nSelfDamage
    and J.IsInRange(bot, botTarget, nCastRange)
	then
		local target = J.GetVulnerableWeakestUnit(bot, true, true, nCastRange)

		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end

    if J.IsValidHero(botTarget)
    and J.CanKillTarget(botTarget, nDamage, nDamageType)
    and J.IsInRange(bot, botTarget, nCastRange)
    then
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderAphoticShield()
    if not AphoticShield:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange  = AphoticShield:GetCastRange()
    local nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    for _, npcAlly in pairs(nAllyHeroes)
	do
        if J.IsValidHero(npcAlly)
        and not npcAlly:IsIllusion()
        and J.IsInRange(bot, npcAlly, nCastRange)
        and J.IsDisabled(npcAlly)
        then
            return BOT_ACTION_DESIRE_HIGH, npcAlly
        end

		if J.IsValidHero(npcAlly)
		and J.IsInRange(bot, npcAlly, nCastRange)
        and not npcAlly:HasModifier('modifier_abaddon_aphotic_shield')
		and not npcAlly:IsMagicImmune()
		and not npcAlly:IsInvulnerable()
        and not npcAlly:IsIllusion()
		and npcAlly:CanBeSeen()
        and J.IsNotSelf(bot, npcAlly)
		then
			if J.GetHP(npcAlly) < 0.5
            and npcAlly:WasRecentlyDamagedByAnyHero(2.0)
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly
			end

			if J.IsGoingOnSomeone(npcAlly)
			then
				local allyTarget = npcAlly:GetAttackTarget()

				if J.IsValidHero(allyTarget)
				and J.IsInRange(npcAlly, allyTarget, npcAlly:GetAttackRange())
				then
					return BOT_ACTION_DESIRE_HIGH, npcAlly
				end
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
    then
		local botTarget = bot:GetTarget()

		if J.IsValidHero(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        then
			if nEnemyHeroes ~= nil and nAllyHeroes ~= nil
            and #nEnemyHeroes > #nAllyHeroes
            then
                if #nAllyHeroes == 1
                and J.IsInRange(bot, nAllyHeroes[1], nCastRange)
                and not nAllyHeroes[1]:HasModifier('modifier_abaddon_aphotic_shield')
		        and not nAllyHeroes[1]:IsMagicImmune()
		        and not nAllyHeroes[1]:IsInvulnerable()
                and J.IsCore(nAllyHeroes[1])
                and not nAllyHeroes[1]:IsIllusion()
                then
                    return BOT_ACTION_DESIRE_HIGH, nAllyHeroes
                end

                if not bot:HasModifier('modifier_abaddon_aphotic_shield')
                and not bot:HasModifier("modifier_abaddon_borrowed_time")
                then
                    return BOT_ACTION_DESIRE_MODERATE, bot
                end
		    end
	    end

        if nAllyHeroes ~= nil and #nAllyHeroes == 0
        and J.IsInRange(bot, botTarget, nCastRange)
        and not bot:HasModifier('modifier_abaddon_aphotic_shield')
        and not bot:HasModifier("modifier_abaddon_borrowed_time")
        then
            return BOT_ACTION_DESIRE_MODERATE, bot
        end
    end

    if J.IsRetreating(bot)
    and not bot:HasModifier('modifier_abaddon_aphotic_shield')
    and not bot:HasModifier("modifier_abaddon_borrowed_time")
	then
        if (J.GetHP(bot) < 0.5 and bot:WasRecentlyDamagedByAnyHero(2.0))
        or J.IsDisabled(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

return X