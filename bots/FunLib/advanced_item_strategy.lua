--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ArrayIndexOf(self, searchElement, fromIndex)
    if fromIndex == nil then
        fromIndex = 0
    end
    local len = #self
    if len == 0 then
        return -1
    end
    if fromIndex >= len then
        return -1
    end
    if fromIndex < 0 then
        fromIndex = len + fromIndex
        if fromIndex < 0 then
            fromIndex = 0
        end
    end
    for i = fromIndex + 1, len do
        if self[i] == searchElement then
            return i - 1
        end
    end
    return -1
end

local function __TS__CountVarargs(...)
    return select("#", ...)
end

local function __TS__ArraySplice(self, ...)
    local args = {...}
    local len = #self
    local actualArgumentCount = __TS__CountVarargs(...)
    local start = args[1]
    local deleteCount = args[2]
    if start < 0 then
        start = len + start
        if start < 0 then
            start = 0
        end
    elseif start > len then
        start = len
    end
    local itemCount = actualArgumentCount - 2
    if itemCount < 0 then
        itemCount = 0
    end
    local actualDeleteCount
    if actualArgumentCount == 0 then
        actualDeleteCount = 0
    elseif actualArgumentCount == 1 then
        actualDeleteCount = len - start
    else
        actualDeleteCount = deleteCount or 0
        if actualDeleteCount < 0 then
            actualDeleteCount = 0
        end
        if actualDeleteCount > len - start then
            actualDeleteCount = len - start
        end
    end
    local out = {}
    for k = 1, actualDeleteCount do
        local from = start + k
        if self[from] ~= nil then
            out[k] = self[from]
        end
    end
    if itemCount < actualDeleteCount then
        for k = start + 1, len - actualDeleteCount do
            local from = k + actualDeleteCount
            local to = k + itemCount
            if self[from] then
                self[to] = self[from]
            else
                self[to] = nil
            end
        end
        for k = len - actualDeleteCount + itemCount + 1, len do
            self[k] = nil
        end
    elseif itemCount > actualDeleteCount then
        for k = len - actualDeleteCount, start + 1, -1 do
            local from = k + actualDeleteCount
            local to = k + itemCount
            if self[from] then
                self[to] = self[from]
            else
                self[to] = nil
            end
        end
    end
    local j = start + 1
    for i = 3, actualArgumentCount do
        self[j] = args[i]
        j = j + 1
    end
    for k = #self, len - actualDeleteCount + itemCount + 1, -1 do
        self[k] = nil
    end
    return out
end

local function __TS__ObjectEntries(obj)
    local result = {}
    local len = 0
    for key in pairs(obj) do
        len = len + 1
        result[len] = {key, obj[key]}
    end
    return result
end

local function __TS__ArrayPushArray(self, items)
    local len = #self
    for i = 1, #items do
        len = len + 1
        self[len] = items[i]
    end
    return len
end

local function __TS__Class(self)
    local c = {prototype = {}}
    c.prototype.__index = c.prototype
    c.prototype.constructor = c
    return c
end

local function __TS__ArrayIncludes(self, searchElement, fromIndex)
    if fromIndex == nil then
        fromIndex = 0
    end
    local len = #self
    local k = fromIndex
    if fromIndex < 0 then
        k = len + fromIndex
    end
    if k < 0 then
        k = 0
    end
    for i = k + 1, len do
        if self[i] == searchElement then
            return true
        end
    end
    return false
end
-- End of Lua Library inline imports
local ____exports = {}
local ____heroes = require(GetScriptDirectory().."/ts_libs/dota/heroes")
local HeroName = ____heroes.HeroName
local ____aba_hero_roles_map = require(GetScriptDirectory().."/FunLib/aba_hero_roles_map")
local HeroRolesMap = ____aba_hero_roles_map.HeroRolesMap
local IsRanged = ____aba_hero_roles_map.IsRanged
local STARTING_ITEMS = {
    pos_1 = {melee = {"item_tango", "item_double_branches", "item_quelling_blade", "item_circlet"}, ranged = {"item_tango", "item_double_branches", "item_slippers", "item_circlet"}},
    pos_2 = {melee = {"item_tango", "item_double_branches", "item_faerie_fire", "item_circlet"}, ranged = {"item_tango", "item_double_branches", "item_faerie_fire", "item_circlet"}},
    pos_3 = {melee = {"item_tango", "item_double_branches", "item_quelling_blade"}, ranged = {"item_tango", "item_double_branches", "item_circlet"}},
    pos_4 = {melee = {"item_tango", "item_double_branches", "item_enchanted_mango", "item_blood_grenade"}, ranged = {"item_tango", "item_double_branches", "item_enchanted_mango", "item_blood_grenade"}},
    pos_5 = {melee = {
        "item_tango",
        "item_tango",
        "item_double_branches",
        "item_enchanted_mango",
        "item_blood_grenade"
    }, ranged = {
        "item_tango",
        "item_tango",
        "item_double_branches",
        "item_enchanted_mango",
        "item_blood_grenade"
    }}
}
local CORE_ITEMS = {"item_magic_wand", "item_boots"}
local BOOTS_BY_POSITION = {
    pos_1 = {"item_power_treads"},
    pos_2 = {"item_power_treads"},
    pos_3 = {"item_phase_boots"},
    pos_4 = {"item_arcane_boots"},
    pos_5 = {"item_tranquil_boots"}
}
local ITEMS_BY_POSITION = {
    pos_1 = {melee = {
        "item_wraith_band",
        "item_hand_of_midas",
        "item_bfury",
        "item_manta",
        "item_black_king_bar",
        "item_skadi",
        "item_butterfly",
        "item_abyssal_blade",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }, ranged = {
        "item_wraith_band",
        "item_hand_of_midas",
        "item_dragon_lance",
        "item_manta",
        "item_black_king_bar",
        "item_skadi",
        "item_butterfly",
        "item_bloodthorn",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }},
    pos_2 = {melee = {
        "item_bottle",
        "item_hand_of_midas",
        "item_blink",
        "item_black_king_bar",
        "item_cyclone",
        "item_octarine_core",
        "item_cyclone",
        "item_black_king_bar",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }, ranged = {
        "item_bottle",
        "item_hand_of_midas",
        "item_cyclone",
        "item_black_king_bar",
        "item_force_staff",
        "item_octarine_core",
        "item_cyclone",
        "item_black_king_bar",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }},
    pos_3 = {melee = {
        "item_bracer",
        "item_blink",
        "item_lotus_orb",
        "item_black_king_bar",
        "item_heavens_halberd",
        "item_heart",
        "item_assault",
        "item_abyssal_blade",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }, ranged = {
        "item_bracer",
        "item_blink",
        "item_lotus_orb",
        "item_black_king_bar",
        "item_heavens_halberd",
        "item_heart",
        "item_assault",
        "item_heavens_halberd",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }},
    pos_4 = {melee = {
        "item_urn_of_shadows",
        "item_solar_crest",
        "item_glimmer_cape",
        "item_force_staff",
        "item_guardian_greaves",
        "item_sheepstick",
        "item_guardian_greaves",
        "item_heavens_halberd",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }, ranged = {
        "item_urn_of_shadows",
        "item_solar_crest",
        "item_glimmer_cape",
        "item_force_staff",
        "item_guardian_greaves",
        "item_sheepstick",
        "item_guardian_greaves",
        "item_cyclone",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }},
    pos_5 = {melee = {
        "item_urn_of_shadows",
        "item_solar_crest",
        "item_glimmer_cape",
        "item_force_staff",
        "item_boots_of_bearing",
        "item_sheepstick",
        "item_boots_of_bearing",
        "item_heavens_halberd",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }, ranged = {
        "item_urn_of_shadows",
        "item_solar_crest",
        "item_glimmer_cape",
        "item_force_staff",
        "item_boots_of_bearing",
        "item_sheepstick",
        "item_boots_of_bearing",
        "item_cyclone",
        "item_travel_boots_2",
        "item_moon_shard",
        "item_ultimate_scepter_2"
    }}
}
local COUNTER_ITEMS = {
    evasion = {"item_monkey_king_bar", "item_bloodthorn"},
    magic_heavy = {"item_black_king_bar", "item_pipe_of_insight", "item_lotus_orb"},
    illusion_heavy = {"item_maelstrom", "item_mjollnir", "item_radiance", "item_battlefury"},
    invisibility = {"item_dust", "item_gem", "item_ward_sentry"},
    heroes = {[HeroName.PhantomAssassin] = {"item_monkey_king_bar", "item_bloodthorn"}, [HeroName.Riki] = {"item_dust", "item_gem", "item_ward_sentry"}, [HeroName.Antimage] = {"item_cyclone", "item_black_king_bar"}}
}
local NON_SLOT_ITEMS = {"item_moon_shard", "item_ultimate_scepter_2", "item_aghanims_shard"}
local function getHeroRoles(heroName)
    return HeroRolesMap[heroName] or ({})
end
local function isRanged(heroName)
    return IsRanged(heroName)
end
local HERO_SPECIFIC_MODIFICATIONS = {[HeroName.OgreMagi] = {addItems = {"item_hand_of_midas"}}, [HeroName.Slark] = {replaceItems = {item_bfury = {"item_diffusal_blade"}}}}
local function getEnemyHeroes()
    local enemies = {}
    do
        local i = 1
        while i <= 5 do
            local enemy = GetTeamMember(
                GetOpposingTeam(),
                i
            )
            if enemy and enemy.IsHero() then
                enemies[#enemies + 1] = enemy.GetUnitName()
            end
            i = i + 1
        end
    end
    return enemies
end
local function applyHeroSpecificModifications(heroName, build)
    local modifications = HERO_SPECIFIC_MODIFICATIONS[heroName]
    if not modifications then
        return build
    end
    local modifiedBuild = {unpack(build)}
    if modifications.replaceItems then
        for ____, ____value in ipairs(__TS__ObjectEntries(modifications.replaceItems)) do
            local oldItem = ____value[1]
            local newItems = ____value[2]
            local index = __TS__ArrayIndexOf(modifiedBuild, oldItem)
            if index ~= -1 then
                __TS__ArraySplice(
                    modifiedBuild,
                    index,
                    1,
                    unpack(newItems)
                )
            end
        end
    end
    if modifications.addItems then
        __TS__ArrayPushArray(modifiedBuild, modifications.addItems)
    end
    if modifications.removeItems then
        for ____, item in ipairs(modifications.removeItems) do
            local index = __TS__ArrayIndexOf(modifiedBuild, item)
            if index ~= -1 then
                __TS__ArraySplice(modifiedBuild, index, 1)
            end
        end
    end
    return modifiedBuild
end
local function getRoleBasedItems(heroName, _position)
    local roles = getHeroRoles(heroName)
    local additionalItems = {}
    if roles.initiator and roles.initiator >= 2 then
        additionalItems[#additionalItems + 1] = "item_blink"
    end
    if roles.disabler and roles.disabler >= 2 then
        additionalItems[#additionalItems + 1] = "item_cyclone"
    end
    if roles.healer and roles.healer >= 2 then
        additionalItems[#additionalItems + 1] = "item_guardian_greaves"
    end
    if roles.nuker and roles.nuker >= 2 then
        additionalItems[#additionalItems + 1] = "item_octarine_core"
    end
    if roles.durable and roles.durable >= 2 then
        additionalItems[#additionalItems + 1] = "item_heart"
    end
    if roles.pusher and roles.pusher >= 2 then
        additionalItems[#additionalItems + 1] = "item_assault"
    end
    return additionalItems
end
local function hasEnemyThreat(enemies, threatType)
    for ____, enemy in ipairs(enemies) do
        if threatType == "evasion" then
            if enemy == HeroName.PhantomAssassin or enemy == HeroName.Windrunner or enemy == HeroName.Weaver or enemy == HeroName.Brewmaster then
                return true
            end
        elseif threatType == "magic_heavy" then
            local roles = getHeroRoles(enemy)
            if roles.nuker and roles.nuker >= 2 then
                return true
            end
        elseif threatType == "illusion_heavy" then
            if enemy == HeroName.PhantomLancer or enemy == HeroName.ChaosKnight or enemy == HeroName.Terrorblade or enemy == HeroName.NagaSiren then
                return true
            end
        elseif threatType == "invisibility" then
            if enemy == HeroName.Riki or enemy == HeroName.BountyHunter or enemy == HeroName.Clinkz or enemy == HeroName.NyxAssassin then
                return true
            end
        end
    end
    return false
end
____exports.AdvancedItemStrategy = __TS__Class()
local AdvancedItemStrategy = ____exports.AdvancedItemStrategy
AdvancedItemStrategy.name = "AdvancedItemStrategy"
function AdvancedItemStrategy.prototype.____constructor(self)
end
function AdvancedItemStrategy.GetItemBuild(self, bot, position)
    local heroName = bot.GetUnitName()
    local enemies = getEnemyHeroes()
    local build = {}
    local isHeroRanged = isRanged(heroName)
    local rangeType = isHeroRanged and "ranged" or "melee"
    if STARTING_ITEMS[position] and STARTING_ITEMS[position][rangeType] then
        __TS__ArrayPushArray(build, STARTING_ITEMS[position][rangeType])
    end
    __TS__ArrayPushArray(build, CORE_ITEMS)
    if BOOTS_BY_POSITION[position] then
        __TS__ArrayPushArray(build, BOOTS_BY_POSITION[position])
    end
    if ITEMS_BY_POSITION[position] and ITEMS_BY_POSITION[position][rangeType] then
        __TS__ArrayPushArray(build, ITEMS_BY_POSITION[position][rangeType])
    end
    local roleItems = getRoleBasedItems(heroName, position)
    __TS__ArrayPushArray(build, roleItems)
    if hasEnemyThreat(enemies, "evasion") then
        __TS__ArrayPushArray(build, COUNTER_ITEMS.evasion)
    end
    if hasEnemyThreat(enemies, "magic_heavy") then
        __TS__ArrayPushArray(build, COUNTER_ITEMS.magic_heavy)
    end
    if hasEnemyThreat(enemies, "illusion_heavy") then
        __TS__ArrayPushArray(build, COUNTER_ITEMS.illusion_heavy)
    end
    if hasEnemyThreat(enemies, "invisibility") then
        __TS__ArrayPushArray(build, COUNTER_ITEMS.invisibility)
    end
    for ____, enemy in ipairs(enemies) do
        if COUNTER_ITEMS.heroes[enemy] then
            __TS__ArrayPushArray(build, COUNTER_ITEMS.heroes[enemy])
        end
    end
    return applyHeroSpecificModifications(heroName, build)
end
function AdvancedItemStrategy.GetSellList(self, _bot, _itemBuild)
    local sellPairs = {
        "item_travel_boots_2",
        "item_boots",
        "item_ultimate_scepter_2",
        "item_ultimate_scepter",
        "item_skadi",
        "item_wraith_band",
        "item_butterfly",
        "item_magic_wand",
        "item_abyssal_blade",
        "item_quelling_blade",
        "item_octarine_core",
        "item_bottle",
        "item_sheepstick",
        "item_urn_of_shadows"
    }
    return sellPairs
end
function AdvancedItemStrategy.GetLateGame6Slot(self, bot, position)
    local heroName = bot.GetUnitName()
    local isHeroRanged = isRanged(heroName)
    local rangeType = isHeroRanged and "ranged" or "melee"
    local build = {}
    if ITEMS_BY_POSITION[position] and ITEMS_BY_POSITION[position][rangeType] then
        for ____, item in ipairs(ITEMS_BY_POSITION[position][rangeType]) do
            if not __TS__ArrayIncludes(NON_SLOT_ITEMS, item) then
                build[#build + 1] = item
            end
        end
    end
    while #build > 6 do
        table.remove(build)
    end
    while #build < 6 do
        build[#build + 1] = "item_moon_shard"
    end
    return build
end
function AdvancedItemStrategy.GetNonSlotItems(self, bot, position)
    local heroName = bot.GetUnitName()
    local isHeroRanged = isRanged(heroName)
    local rangeType = isHeroRanged and "ranged" or "melee"
    local nonSlotItems = {}
    if ITEMS_BY_POSITION[position] and ITEMS_BY_POSITION[position][rangeType] then
        for ____, item in ipairs(ITEMS_BY_POSITION[position][rangeType]) do
            if __TS__ArrayIncludes(NON_SLOT_ITEMS, item) then
                nonSlotItems[#nonSlotItems + 1] = item
            end
        end
    end
    return nonSlotItems
end
function AdvancedItemStrategy.GetCounterItems(self, enemies)
    local counterItems = {}
    if hasEnemyThreat(enemies, "evasion") then
        __TS__ArrayPushArray(counterItems, COUNTER_ITEMS.evasion)
    end
    if hasEnemyThreat(enemies, "magic_heavy") then
        __TS__ArrayPushArray(counterItems, COUNTER_ITEMS.magic_heavy)
    end
    if hasEnemyThreat(enemies, "illusion_heavy") then
        __TS__ArrayPushArray(counterItems, COUNTER_ITEMS.illusion_heavy)
    end
    if hasEnemyThreat(enemies, "invisibility") then
        __TS__ArrayPushArray(counterItems, COUNTER_ITEMS.invisibility)
    end
    for ____, enemy in ipairs(enemies) do
        if COUNTER_ITEMS.heroes[enemy] then
            __TS__ArrayPushArray(counterItems, COUNTER_ITEMS.heroes[enemy])
        end
    end
    return counterItems
end
function AdvancedItemStrategy.GetPositionSpecificItems(self, bot, position)
    return self:GetItemBuild(bot, position)
end
function AdvancedItemStrategy.GetRangeSpecificItems(self, bot, position)
    return self:GetItemBuild(bot, position)
end
____exports.default = ____exports.AdvancedItemStrategy
return ____exports
