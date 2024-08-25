--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local jmz = require("bots.FunLib.jmz_func")
local ____dota = require("bots.lib.dota.index")
local BotActionDesire = ____dota.BotActionDesire
local BotMode = ____dota.BotMode
local bot = GetBot()
local Minion = dofile("bots/FunLib/aba_minion")
local talentList = jmz.Skill.GetTalentList(bot)
local AbilityList = jmz.Skill.GetAbilityList(bot)
local talentTreeList = {t25 = {10, 0}, t20 = {10, 0}, t15 = {0, 10}, t10 = {0, 10}}
local AllAbilityBuilds = {{
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
}}
local abilityBuild = jmz.Skill.GetRandomBuild(AllAbilityBuilds)
local talentBuildList = jmz.Skill.GetTalentBuild(talentTreeList)
local skillBuildList = jmz.Skill.GetSkillList(AbilityList, abilityBuild, talentList, talentBuildList)
local role = jmz.Item.GetRoleItemsBuyList(bot)
local abilityTether = bot:GetAbilityByName(AbilityList[1])
local abilitySpirits = bot:GetAbilityByName(AbilityList[2])
local abilityOvercharge = bot:GetAbilityByName(AbilityList[3])
local abilityRelocate = bot:GetAbilityByName(AbilityList[6])
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
local function HasHealingEffect(hero)
    local modifiers = {
        "modifier_tango_heal",
        "modifier_flask_healing",
        "modifier_clarity_potion",
        "modifier_item_urn_heal",
        "modifier_item_spirit_vessel_heal",
        "modifier_bottle_regeneration"
    }
    for ____, name in ipairs(modifiers) do
        if hero:HasModifier(name) then
            return true
        end
    end
    return false
end
local stateTetheredHero = nil
local function ShouldUseOvercharge(ally)
    local isAttacking = GameTime() - ally:GetLastAttackTime() < 0.33
    local attackTarget = ally:GetAttackTarget()
    return jmz.IsGoingOnSomeone(ally) or attackTarget and attackTarget:GetTeam() == GetOpposingTeam() and isAttacking or #ally:GetNearbyCreeps(200, true) > 2
end
local function considerTether()
    if not abilityTether:IsFullyCastable() then
        return {BotActionDesire.None, nil}
    end
    local castRange = abilityTether:GetCastRange()
    local allies = bot:GetNearbyHeroes(castRange, false, BotMode.None)
    for ____, ally in ipairs(allies) do
        do
            local __continue9
            repeat
                local canTargetAlly = ally ~= bot and ally:IsAlive() and not ally:IsMagicImmune()
                if not canTargetAlly then
                    __continue9 = true
                    break
                end
                if jmz.IsRetreating(bot) or jmz.GetHP(bot) < 0.25 then
                    if jmz.IsRetreating(ally) then
                        return {BotActionDesire.High, ally}
                    end
                    __continue9 = true
                    break
                end
                if jmz.GetHP(ally) < 0.75 or jmz.GetMP(bot) > 0.8 or HasHealingEffect(bot) or ShouldUseOvercharge(ally) then
                    return {BotActionDesire.High, ally}
                end
                __continue9 = true
            until true
            if not __continue9 then
                break
            end
        end
    end
    return {BotActionDesire.None, nil}
end
local function considerOvercharge()
    if not abilityOvercharge:IsFullyCastable() then
        return BotActionDesire.None
    end
    if bot:HasModifier("modifier_wisp_tether") and stateTetheredHero ~= nil and ShouldUseOvercharge(stateTetheredHero) then
        return BotActionDesire.High
    end
    return BotActionDesire.None
end
local function considerSpirits()
    if not abilitySpirits:IsFullyCastable() then
        return BotActionDesire.None
    end
    local nearbyEnemies = bot:GetNearbyHeroes(800, true, BotMode.None)
    if #nearbyEnemies >= 1 then
        return BotActionDesire.High
    end
    return BotActionDesire.None
end
local function considerRelocate()
    return {BotActionDesire.None, nil}
end
local ____exports = {
    SkillsComplement = function()
        if jmz.CanNotUseAbility(bot) or bot:IsInvisible() then
            return
        end
        local tetherDesire, tetherLocation = unpack(considerTether())
        if tetherDesire > 0 and tetherLocation then
            bot:Action_UseAbilityOnEntity(abilityTether, tetherLocation)
            stateTetheredHero = tetherLocation
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
        local relocateDesire, relocateTarget = unpack(considerRelocate())
        if relocateDesire and relocateTarget ~= nil then
            bot:Action_UseAbilityOnLocation(abilityRelocate, relocateTarget)
        end
    end,
    sSellList = {"item_magic_wand"},
    sBuyList = roleItemBuyList[role],
    MinionThink = function(hMinionUnit, _)
        if Minion.IsValidUnit(hMinionUnit) then
            Minion.IllusionThink(hMinionUnit)
        end
    end,
    bDefaultAbility = false,
    bDefaultItem = false,
    sSkillList = skillBuildList
}
return ____exports
