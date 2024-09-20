--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local jmz = require("bots.FunLib.jmz_func")
local ____dota = require("bots.ts_libs.dota.index")
local BotActionDesire = ____dota.BotActionDesire
local BotMode = ____dota.BotMode
local UnitType = ____dota.UnitType
local ____aba_buff = require("bots.FunLib.aba_buff")
local hero_is_healing = ____aba_buff.hero_is_healing
local ____utils = require("bots.FunLib.utils")
local GetTeamFountainTpPoint = ____utils.GetTeamFountainTpPoint
local HasAnyEffect = ____utils.HasAnyEffect
local IsValidHero = ____utils.IsValidHero
local bot = GetBot()
local minion = dofile("bots/FunLib/aba_minion")
local role = jmz.Item.GetRoleItemsBuyList(bot)
local defaultAbilityBuild = {
    1,
    3,
    1,
    3,
    1,
    6,
    1,
    3,
    3,
    2,
    6,
    2,
    2,
    2,
    6
}
local allAbilitiesList = jmz.Skill.GetAbilityList(bot)
local roleSkillBuildList = {
    pos_1 = defaultAbilityBuild,
    pos_2 = defaultAbilityBuild,
    pos_3 = defaultAbilityBuild,
    pos_4 = defaultAbilityBuild,
    pos_5 = defaultAbilityBuild
}
local skillBuildList = roleSkillBuildList[role]
local allTalentsList = jmz.Skill.GetTalentList(bot)
local defaultTalentTree = {t25 = {10, 0}, t20 = {10, 0}, t15 = {0, 10}, t10 = {0, 10}}
local roleTalentBuildList = {
    pos_1 = defaultTalentTree,
    pos_2 = defaultTalentTree,
    pos_3 = defaultTalentTree,
    pos_4 = defaultTalentTree,
    pos_5 = defaultTalentTree
}
local talentBuildList = jmz.Skill.GetTalentBuild(roleTalentBuildList[role])
local fullSkillBuildList = jmz.Skill.GetSkillList(allAbilitiesList, skillBuildList, allTalentsList, talentBuildList)
local defaultBuild = {
    "item_tango",
    "item_faerie_fire",
    "item_gauntlets",
    "item_gauntlets",
    "item_gauntlets",
    "item_boots",
    "item_armlet",
    "item_black_king_bar",
    "item_sange",
    "item_ultimate_scepter",
    "item_heavens_halberd",
    "item_travel_boots",
    "item_satanic",
    "item_aghanims_shard",
    "item_assault",
    "item_travel_boots_2",
    "item_ultimate_scepter_2",
    "item_moon_shard"
}
local roleItemBuyList = {
    pos_1 = defaultBuild,
    pos_2 = defaultBuild,
    pos_3 = defaultBuild,
    pos_4 = {
        "item_priest_outfit",
        "item_mekansm",
        "item_glimmer_cape",
        "item_guardian_greaves",
        "item_spirit_vessel",
        "item_shivas_guard",
        "item_sheepstick",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    },
    pos_5 = {
        "item_blood_grenade",
        "item_mage_outfit",
        "item_ancient_janggo",
        "item_glimmer_cape",
        "item_boots_of_bearing",
        "item_pipe",
        "item_shivas_guard",
        "item_cyclone",
        "item_sheepstick",
        "item_wind_waker",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }
}
local itemBuildList = roleItemBuyList[role]
local sellList = {"item_black_king_bar", "item_quelling_blade"}
local abilityTether = bot:GetAbilityByName(allAbilitiesList[1])
local abilitySpirits = bot:GetAbilityByName(allAbilitiesList[2])
local abilityOvercharge = bot:GetAbilityByName(allAbilitiesList[3])
local abilityRelocate = bot:GetAbilityByName(allAbilitiesList[6])
local abilityBreakTether = bot:GetAbilityByName("wisp_tether_break")
local nearbyEnemies = {}
local function HasHealingEffect(hero)
    return HasAnyEffect(
        hero,
        "modifier_tango_heal",
        unpack(hero_is_healing)
    )
end
bot.stateTetheredHero = bot.stateTetheredHero
local function ShouldUseOvercharge(ally)
    local isAttacking = GameTime() - ally:GetLastAttackTime() < 0.33
    local attackTarget = ally:GetAttackTarget()
    return jmz.IsGoingOnSomeone(ally) or attackTarget and attackTarget:GetTeam() == GetOpposingTeam() and isAttacking or #ally:GetNearbyCreeps(200, true) > 2
end
local function considerTether()
    if not bot:HasModifier("modifier_wisp_tether") then
        bot.stateTetheredHero = nil
    end
    if not abilityTether:IsFullyCastable() or not abilityBreakTether:IsHidden() then
        return BotActionDesire.None, nil
    end
    local castRange = abilityTether:GetCastRange()
    local allies = bot:GetNearbyHeroes(castRange, false, BotMode.None)
    for ____, ally in ipairs(allies) do
        do
            local __continue7
            repeat
                local canTargetAlly = ally ~= bot and ally:IsAlive() and not ally:IsMagicImmune()
                if not canTargetAlly then
                    __continue7 = true
                    break
                end
                if jmz.IsRetreating(bot) or jmz.GetHP(bot) < 0.25 then
                    if jmz.IsRetreating(ally) then
                        return BotActionDesire.High, ally
                    end
                    __continue7 = true
                    break
                end
                if jmz.GetHP(ally) < 0.75 or jmz.GetMP(bot) > 0.8 or HasHealingEffect(bot) or ShouldUseOvercharge(ally) then
                    return BotActionDesire.High, ally
                end
                __continue7 = true
            until true
            if not __continue7 then
                break
            end
        end
    end
    return BotActionDesire.None, nil
end
local function considerOvercharge()
    if not abilityOvercharge:IsFullyCastable() then
        return BotActionDesire.None
    end
    if bot:HasModifier("modifier_wisp_tether") and bot.stateTetheredHero ~= nil and ShouldUseOvercharge(bot.stateTetheredHero) then
        return BotActionDesire.High
    end
    return BotActionDesire.None
end
local function considerSpirits()
    if not abilitySpirits:IsFullyCastable() then
        return BotActionDesire.None
    end
    if #nearbyEnemies >= 1 then
        return BotActionDesire.High
    end
    return BotActionDesire.None
end
local function considerRelocate()
    if bot:HasModifier("modifier_wisp_tether") and bot.stateTetheredHero ~= nil and (jmz.GetHP(bot.stateTetheredHero) <= 0.2 or jmz.GetHP(bot) <= 0.2) then
        local allyNearbyEnemies = bot.stateTetheredHero:GetNearbyHeroes(1200, true, BotMode.None)
        if #allyNearbyEnemies >= 1 and jmz.GetHP(bot.stateTetheredHero) < jmz.GetHP(allyNearbyEnemies[1]) or #nearbyEnemies >= 1 and jmz.GetHP(bot) < jmz.GetHP(nearbyEnemies[1]) then
            return BotActionDesire.High, GetTeamFountainTpPoint()
        end
    end
    if not bot:HasModifier("modifier_wisp_tether") then
        if #nearbyEnemies >= 1 and jmz.GetHP(bot) < jmz.GetHP(nearbyEnemies[1]) then
            return BotActionDesire.High, GetTeamFountainTpPoint()
        end
    end
    for ____, ally in ipairs(GetUnitList(UnitType.AlliedHeroes)) do
        if IsValidHero(ally) and jmz.IsInTeamFight(ally, 1200) and GetUnitToUnitDistance(bot, ally) > 3000 and ally:WasRecentlyDamagedByAnyHero(2) then
            return BotActionDesire.High, ally:GetLocation()
        end
    end
    return BotActionDesire.None, nil
end
local function SkillsComplement()
    if jmz.CanNotUseAbility(bot) or bot:IsInvisible() then
        return
    end
    nearbyEnemies = bot:GetNearbyHeroes(1600, true, BotMode.None)
    local tetherDesire, tetherTarget = considerTether()
    if tetherDesire > 0 and tetherTarget then
        bot:Action_UseAbilityOnEntity(abilityTether, tetherTarget)
        bot.stateTetheredHero = tetherTarget
        return
    end
    local overchargeDesire = considerOvercharge()
    if overchargeDesire > 0 then
        bot:Action_UseAbility(abilityOvercharge)
        return
    end
    local spiritsDesire = considerSpirits()
    if spiritsDesire > 0 then
        bot:Action_UseAbility(abilitySpirits)
        return
    end
    local relocateDesire, relocateTarget = considerRelocate()
    if relocateDesire and relocateTarget ~= nil then
        bot:Action_UseAbilityOnLocation(abilityRelocate, relocateTarget)
    end
end
local function MinionThink(hMinionUnit)
    if minion.IsValidUnit(hMinionUnit) then
        minion.IllusionThink(hMinionUnit)
    end
end
local ____exports = {
    SkillsComplement = SkillsComplement,
    MinionThink = MinionThink,
    sSellList = sellList,
    sBuyList = itemBuildList,
    sSkillList = fullSkillBuildList
}
return ____exports
