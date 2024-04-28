local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
                        {--pos4
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {10, 0},
                            ['t10'] = {0, 10},
                        },
                        {--pos5
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {10, 0},
                            ['t10'] = {0, 10},
                        }
}

local tAllAbilityBuildList = {
                        {2,1,2,1,2,6,2,3,3,3,6,3,1,1,6},--pos4
                        {1,2,2,3,2,6,3,1,1,1,6,3,3,3,6},--pos5
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "outfit_priest"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
elseif sRole == "outfit_mage"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sRoleItemsBuyList = {}

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mid'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_tank'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_priest'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",

    "item_ring_of_basilius",
    "item_magic_wand",
    "item_boots",
    "item_vladmir",--
    "item_ancient_janggo",
    "item_solar_crest",--
    "item_aghanims_shard",
    "item_boots_of_bearing",--
    "item_glimmer_cape",--
    "item_holy_locket",--
    "item_assault",--
    "item_ultimate_scepter",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_mage'] = {
    "item_double_tango",
    "item_double_branches",
    "item_blood_grenade",

    "item_ring_of_basilius",
    "item_magic_wand",
    "item_boots",
    "item_vladmir",--
    "item_mekansm",
    "item_pipe",--
    "item_aghanims_shard",
    "item_guardian_greaves",--
    "item_glimmer_cape",--
    "item_holy_locket",--
    "item_assault",--
    "item_ultimate_scepter",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos4SellList = {
	
}

Pos5SellList = {
	
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

local Penitence         = bot:GetAbilityByName('chen_penitence')
local HolyPersuasion    = bot:GetAbilityByName('chen_holy_persuasion')
local DivineFavor       = bot:GetAbilityByName('chen_divine_favor')
local HandOfGod         = bot:GetAbilityByName('chen_hand_of_god')

local PenitenceDesire, PenitenceTarget
local HolyPersuasionDesire, HolyPersuasionTarget
local DivineFavorDesire, DivineFavorTarget
local HandOfGodDesire

local nChenCreeps = {}

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    PenitenceDesire, PenitenceTarget = X.ConsiderPenitence()
    if PenitenceDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Penitence, PenitenceTarget)
        return
    end

    DivineFavorDesire, DivineFavorTarget = X.ConsiderDivineFavor()
    if DivineFavorDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DivineFavor, DivineFavorTarget)
        return
    end

    HandOfGodDesire = X.ConsiderHandOfGod()
    if HandOfGodDesire > 0
    then
        bot:Action_UseAbility(HandOfGod)
        return
    end

    HolyPersuasionDesire, HolyPersuasionTarget = X.ConsiderHolyPersuasion()
    if HolyPersuasionDesire > 0
    then
        bot:Action_UseAbilityOnEntity(HolyPersuasion, HolyPersuasionTarget)
        return
    end
end

function X.ConsiderPenitence()
    if not Penitence:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = Penitence:GetCastRange()
    local nAttackRange = bot:GetAttackRange()
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + nAttackRange)
		then
            if DotaTime() < 10
            then
                if J.GetHP(botTarget) < 0.44
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                else
                    return BOT_ACTION_DESIRE_LOW, botTarget
                end
            else
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
		end
	end

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(enemyHero, 1.0)
            and J.CanCastOnNonMagicImmune(enemyHero)
			then
                if J.GetHP(bot) < 0.33
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                else
                    return BOT_ACTION_DESIRE_MODERATE, enemyHero
                end
			end
		end
	end

	if J.IsDoingRoshan(bot)
	then
		local botAttackTarget = bot:GetAttackTarget()

		if J.IsRoshan(botAttackTarget)
        and J.CanCastOnNonMagicImmune(botAttackTarget)
        and J.IsInRange(bot, botAttackTarget, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, botAttackTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderHolyPersuasion()
	if not HolyPersuasion:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

    local nCastRange = HolyPersuasion:GetCastRange()
    local nMaxUnit = HolyPersuasion:GetSpecialValueInt('max_units')
    local nMaxLevel = HolyPersuasion:GetSpecialValueInt('level_req')
	local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)

    local unitTable = {}
    for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
        if string.find(unit:GetUnitName(), 'neutral')
        and unit:HasModifier('modifier_chen_holy_persuasion')
        then
            table.insert(unitTable, unit)
        end
    end

    nChenCreeps = unitTable

    local nGoodCreep = {
        "npc_dota_neutral_alpha_wolf",
        "npc_dota_neutral_centaur_khan",
        "npc_dota_neutral_polar_furbolg_ursa_warrior",
        "npc_dota_neutral_dark_troll_warlord",
        "npc_dota_neutral_satyr_hellcaller",
        "npc_dota_neutral_enraged_wildkin",
        "npc_dota_neutral_warpine_raider",
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
        if nChenCreeps ~= nil and #nChenCreeps < nMaxUnit
        then
            for _, creep in pairs(nNeutralCreeps)
            do
                if J.IsValid(creep)
                and creep:GetLevel() <= nMaxLevel
                then
                    for _, gCreep in pairs(nGoodCreep)
                    do
                        if creep:GetUnitName() == gCreep
                        then
                            return BOT_ACTION_DESIRE_HIGH, creep
                        end
                    end
                end
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDivineFavor()
    if not DivineFavor:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = DivineFavor:GetCastRange()
    local nAttackRange = bot:GetAttackRange()
    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange + nAttackRange, false, BOT_MODE_NONE)

	for _, allyHero in pairs(nAllyHeroes)
	do
		if J.IsValidHero(allyHero)
		and J.IsInRange(bot, allyHero, nCastRange)
		and not allyHero:HasModifier('modifier_legion_commander_press_the_attack')
        and not allyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not allyHero:HasModifier('modifier_chen_penitence_attack_speed_buff')
        and not allyHero:HasModifier('modifier_chen_divine_favor_armor_buff')
		and not allyHero:IsMagicImmune()
		and not allyHero:IsInvulnerable()
		and allyHero:CanBeSeen()
		then
            if J.IsInTeamFight(bot, 1200)
            then
                if J.IsCore(allyHero)
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end

			if J.IsGoingOnSomeone(allyHero)
			then
				local allyTarget = J.GetProperTarget(allyHero)

				if J.IsValidHero(allyTarget)
                and J.IsCore(allyHero)
				and allyHero:IsFacingLocation(allyTarget:GetLocation(), 30)
				then
					return BOT_ACTION_DESIRE_HIGH, allyHero
				end
			end

            if J.IsRetreating(allyHero)
            and J.GetHP(allyHero) < 0.5
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
		end
	end

    if J.IsInTeamFight(bot, 1200)
    then
        local totDist = 0

        for _, creep in pairs(nChenCreeps)
        do
            local dist = GetUnitToUnitDistance(bot, creep)
            if dist > 1600
            then
                totDist = totDist + dist
            end
        end

        if nChenCreeps ~= nil and #nChenCreeps > 0
        then
            if (totDist / #nChenCreeps) > 1600
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderHandOfGod()
	if not HandOfGod:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE
	end

    if J.IsInTeamFight(bot, 1200)
    then
        if J.GetHP(bot) < 0.33
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)

    if nTeamFightLocation ~= nil
    then
        local nAllyList = J.GetAlliesNearLoc(nTeamFightLocation, 1200)

        for _, allyHero in pairs(nAllyList)
        do
            if J.IsCore(allyHero)
            and J.GetHP(allyHero) < 0.5
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    local nTeamList =  GetTeamPlayers(GetTeam())

	for i = 1, #nTeamList
	do
		local allyHero = GetTeamMember(i)

        if J.IsRetreating(allyHero)
        and allyHero:GetActiveModeDesire() >= BOT_ACTION_DESIRE_HIGH
		and allyHero:IsAlive()
        and allyHero:WasRecentlyDamagedByAnyHero(2.0)
        and J.GetHP(allyHero) < 0.5
        and J.IsCore(allyHero)
		then
            return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X