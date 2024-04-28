local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						{--pos2
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {0, 10},
                            ['t10'] = {10, 0},
                        },
                        {--pos3
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {0, 10},
                            ['t10'] = {10, 0},
                        }
}

local tAllAbilityBuildList = {
						{1,2,1,2,1,6,2,2,1,3,6,3,3,3,6},--pos2
                        {2,1,2,3,2,6,2,1,1,1,6,3,3,3,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "outfit_mid"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
elseif sRole == "outfit_tank"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sUtility = {"item_crimson_guard", "item_pipe", "item_lotus_orb", "item_heavens_halberd"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mid'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_bottle",
    "item_helm_of_iron_will",
    "item_phase_boots",
    "item_magic_wand",
    "item_shivas_guard",--
    "item_blink",
    "item_black_king_bar",--
    "item_octarine_core",--
    "item_travel_boots",
    "item_aghanims_shard",
    "item_overwhelming_blink",--
    "item_refresher",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_tank'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_helm_of_iron_will",
    "item_phase_boots",
    "item_magic_wand",
    "item_shivas_guard",--
    "item_blink",
    "item_black_king_bar",--
    "item_octarine_core",--
    nUtility,--
    "item_aghanims_shard",
    "item_overwhelming_blink",--
    "item_refresher",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_priest'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mage'] = sRoleItemsBuyList['outfit_carry']

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos2SellList = {
    "item_quelling_blade",
    "item_bottle",
	"item_magic_wand",
}

Pos3SellList = {
	"item_quelling_blade",
    "item_magic_wand",
}

X['sSellList'] = {}

if sRole == "outfit_mid"
then
    X['sSellList'] = Pos2SellList
elseif sRole == "outfit_tank"
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

local Devour        = bot:GetAbilityByName('doom_bringer_devour')
local ScorchedEarth = bot:GetAbilityByName('doom_bringer_scorched_earth')
local InfernalBlade = bot:GetAbilityByName('doom_bringer_infernal_blade')
local Doom          = bot:GetAbilityByName('doom_bringer_doom')

local DevourAbility1 = bot:GetAbilityByName('doom_bringer_empty1')
local DevourAbility2 = bot:GetAbilityByName('doom_bringer_empty2')

local DevourAncientTalent = bot:GetAbilityByName('special_bonus_unique_doom_4')

local DevourDesire, DevourTarget
local ScorchedEarthDesire
local InfernalBladeDesire, InfernalBladeTarget
local DoomDesire, DoomTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    DoomDesire, DoomTarget = X.ConsiderDoom()
    if DoomDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Doom, DoomTarget)
        return
    end

    InfernalBladeDesire, InfernalBladeTarget = X.ConsiderInfernalBlade()
    if InfernalBladeDesire > 0
    then
        bot:Action_UseAbilityOnEntity(InfernalBlade, InfernalBladeTarget)
        return
    end

    ScorchedEarthDesire = X.ConsiderScorchedEarth()
    if ScorchedEarthDesire > 0
    then
        bot:Action_UseAbility(ScorchedEarth)
        return
    end

    DevourDesire, DevourTarget = X.ConsiderDevour()
    if DevourDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Devour, DevourTarget)
        return
    end
end

function X.ConsiderDevour()
    if not Devour:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = Devour:GetCastRange()
	local nMaxLevel = Devour:GetSpecialValueInt('creep_level')
    local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)

    if Devour:GetAutoCastState()
    and (DevourAbility1:IsTrained() and not DevourAbility2:IsTrained()
        or not DevourAbility1:IsTrained() and DevourAbility2:IsTrained()
        or not DevourAbility1:IsTrained() and not DevourAbility2:IsTrained())
    then
        Devour:ToggleAutoCast()
    else
        if  not Devour:GetAutoCastState()
        and (DevourAbility1:IsTrained() and DevourAbility2:IsTrained())
        then
            Devour:ToggleAutoCast()
        end
    end

    local nGoodCreep = {
        "npc_dota_neutral_ghost",
        "npc_dota_neutral_centaur_khan",
        "npc_dota_neutral_satyr_hellcaller",
        "npc_dota_neutral_mud_golem",
        "npc_dota_neutral_enraged_wildkin",
        "npc_dota_neutral_dark_troll_warlord",
        "npc_dota_neutral_warpine_raider",
        "npc_dota_neutral_polar_furbolg_ursa_warrior",
    }

    if nMaxLevel < 5
    then
        for _, creep in pairs(nNeutralCreeps)
        do
            if J.IsValid(creep)
            then
                return BOT_ACTION_DESIRE_HIGH, creep
            end
        end
    else
        for _, creep in pairs(nNeutralCreeps)
        do
            if  J.IsValid(creep)
            and creep:GetLevel() <= nMaxLevel
            and not Devour:GetAutoCastState()
            then
                if  creep:IsAncientCreep()
                and DevourAncientTalent:IsTrained()
                and creep:GetUnitName() == 'npc_dota_neutral_black_dragon'
                then
                    return BOT_ACTION_DESIRE_HIGH, creep
                end

                for _, gCreep in pairs(nGoodCreep)
                do
                    if  creep:GetUnitName() == gCreep
                    then
                        return BOT_ACTION_DESIRE_HIGH, creep
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderScorchedEarth()
    if not ScorchedEarth:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = ScorchedEarth:GetSpecialValueInt('radius')
    local nAllyHeroes = bot:GetNearbyHeroes(nRadius + 200, false, BOT_MODE_NONE)
    local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
		then
            if J.IsInTeamFight(bot, 1200)
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if  nAllyHeroes ~= nil and nEnemyHeroes ~= nil
                and #nAllyHeroes >= #nEnemyHeroes
                and (#nEnemyHeroes <= 1 and #nAllyHeroes <= 2)
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
		end
	end

	if J.IsRetreating(bot)
	then
        if bot:WasRecentlyDamagedByAnyHero(2)
        and nAllyHeroes ~= nil and nEnemyHeroes ~= nil
        and #nAllyHeroes < #nEnemyHeroes
        and (#nEnemyHeroes >= 2 or (#nEnemyHeroes == 1 and J.GetHP(bot) < 0.7))
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderInfernalBlade()
    if not InfernalBlade:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = InfernalBlade:GetCastRange()
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local nAbilityLevel = InfernalBlade:GetLevel()
    local botTarget = J.GetProperTarget(bot)
    local nDamagePct = InfernalBlade:GetSpecialValueInt('burn_damage_pct') / 100
    local nDuration = InfernalBlade:GetSpecialValueInt('burn_duration')

	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange + 70, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
            if enemyHero:IsChanneling()
            or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if  J.WillKillTarget(enemyHero, enemyHero:GetMaxHealth() * nDamagePct, DAMAGE_TYPE_MAGICAL, nDuration)
            and GetUnitToUnitDistance(bot, enemyHero) <= nCastRange
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + 80)
        and not J.IsDisabled(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    if J.IsRetreating(bot)
	then
        local nEnemyHeroesR = bot:GetNearbyHeroes(nCastRange + 50, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nEnemyHeroesR)
		do
			if  J.IsValidHero(enemyHero)
            and (bot:WasRecentlyDamagedByHero(enemyHero, 2)
                or nMana > 0.75
                or GetUnitToUnitDistance(bot, enemyHero) <= 350)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end
		end
	end

	if J.IsFarming(bot)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange + 150)
		local targetCreep = J.GetMostHpUnit(nNeutralCreeps)

		if  J.IsValid(targetCreep)
        and (targetCreep:IsCreep() or (targetCreep:IsAncientCreep() and DevourAncientTalent:IsTrained()))
        and #nNeutralCreeps >= 2
        and nAbilityLevel >= 3
        and nMana > 0.71
        and not J.IsOtherAllysTarget(targetCreep)
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        and not botTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDoom()
	if not Doom:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = Doom:GetCastRange()
    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0
        local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if  J.IsValid(enemyHero)
            and J.CanCastOnMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:IsDisarmed()
            and not enemyHero:HasModifier('modifier_doom_bringer_doom')
			then
				local npcEnemyDamage = enemyHero:GetEstimatedDamageToTarget(false, bot, 3.0, DAMAGE_TYPE_ALL)
				if npcEnemyDamage > nMostDangerousDamage
				then
					nMostDangerousDamage = npcEnemyDamage
					npcMostDangerousEnemy = enemyHero
				end
			end
		end

		if  npcMostDangerousEnemy ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy
		end
	end

    if  J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsCore(botTarget)
        and not botTarget:HasModifier('modifier_doom_bringer_doom')
		then
            local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
			local nAllyHeroes = botTarget:GetNearbyHeroes(nCastRange + 200, false, BOT_MODE_NONE)

			if  (nAllyHeroes ~= nil and nEnemyHeroes ~= nil)
            and (#nEnemyHeroes <= 1 and #nAllyHeroes <= 1)
            and #nAllyHeroes >= #nEnemyHeroes
            then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

return X