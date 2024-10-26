--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ObjectValues(obj)
    local result = {}
    local len = 0
    for key in pairs(obj) do
        len = len + 1
        result[len] = obj[key]
    end
    return result
end

local function __TS__ArraySort(self, compareFn)
    if compareFn ~= nil then
        table.sort(
            self,
            function(a, b) return compareFn(nil, a, b) < 0 end
        )
    else
        table.sort(self)
    end
    return self
end

local function __TS__ArrayMap(self, callbackfn, thisArg)
    local result = {}
    for i = 1, #self do
        result[i] = callbackfn(thisArg, self[i], i - 1, self)
    end
    return result
end

local function __TS__CountVarargs(...)
    return select("#", ...)
end

local function __TS__SparseArrayNew(...)
    local sparseArray = {...}
    sparseArray.sparseLength = __TS__CountVarargs(...)
    return sparseArray
end

local function __TS__SparseArrayPush(sparseArray, ...)
    local args = {...}
    local argsLen = __TS__CountVarargs(...)
    local listLen = sparseArray.sparseLength
    for i = 1, argsLen do
        sparseArray[listLen + i] = args[i]
    end
    sparseArray.sparseLength = listLen + argsLen
end

local function __TS__SparseArraySpread(sparseArray)
    local _unpack = unpack or table.unpack
    return _unpack(sparseArray, 1, sparseArray.sparseLength)
end
-- End of Lua Library inline imports
local ____exports = {}
local GetHeroNetWorth, GetHeroOffensivePower, NormalizeSores, ItemOffensiveness, NET_WORTH_WEIGHT, OFFENSIVE_POWER_WEIGHT, LEVEL_WEIGHT
local ____dota = require(GetScriptDirectory().."/ts_libs/dota/index")
local UnitType = ____dota.UnitType
local AttributeType = ____dota.AttributeType
local ____utils = require(GetScriptDirectory().."/FunLib/utils")
local IsValidHero = ____utils.IsValidHero
function GetHeroNetWorth(hero)
    local totalNetWorth = 0
    do
        local i = 0
        while i <= 15 do
            local item = hero:GetItemInSlot(i)
            if item ~= nil then
                totalNetWorth = totalNetWorth + GetItemCost(item:GetName())
            end
            i = i + 1
        end
    end
    return totalNetWorth
end
function GetHeroOffensivePower(hero)
    local offensivePower = 0
    offensivePower = offensivePower + hero:GetAttackDamage()
    local primaryAttribute = hero:GetPrimaryAttribute()
    if primaryAttribute == AttributeType.Strength then
        offensivePower = offensivePower + hero:GetAttributeValue(AttributeType.Strength) * 2
    elseif primaryAttribute == AttributeType.Agility then
        offensivePower = offensivePower + hero:GetAttributeValue(AttributeType.Agility) * 2
    elseif primaryAttribute == AttributeType.Intellect then
        offensivePower = offensivePower + hero:GetAttributeValue(AttributeType.Intellect) * 2
    elseif primaryAttribute == AttributeType.All then
        offensivePower = offensivePower + (hero:GetAttributeValue(AttributeType.Strength) * 0.7 + hero:GetAttributeValue(AttributeType.Agility) * 0.7 + hero:GetAttributeValue(AttributeType.Intellect) * 0.7)
    end
    do
        local i = 0
        while i <= 8 do
            local item = hero:GetItemInSlot(i)
            if item ~= nil then
                local itemName = item:GetName()
                local offensiveValue = ItemOffensiveness[itemName]
                if offensiveValue ~= nil then
                    offensivePower = offensivePower + offensiveValue
                end
            end
            i = i + 1
        end
    end
    return offensivePower
end
function NormalizeSores(heroList)
    local netWorths = __TS__ArrayMap(
        heroList,
        function(____, h) return h.netWorth end
    )
    local offensivePowers = __TS__ArrayMap(
        heroList,
        function(____, h) return h.offensivePower end
    )
    local levels = __TS__ArrayMap(
        heroList,
        function(____, h) return h.level end
    )
    local ____array_0 = __TS__SparseArrayNew(unpack(netWorths))
    __TS__SparseArrayPush(____array_0, 1)
    local maxNetWorth = math.max(__TS__SparseArraySpread(____array_0))
    local ____array_1 = __TS__SparseArrayNew(unpack(offensivePowers))
    __TS__SparseArrayPush(____array_1, 1)
    local maxOffensivePower = math.max(__TS__SparseArraySpread(____array_1))
    local ____array_2 = __TS__SparseArrayNew(unpack(levels))
    __TS__SparseArrayPush(____array_2, 1)
    local maxLevel = math.max(__TS__SparseArraySpread(____array_2))
    for ____, data in ipairs(heroList) do
        local normalizedNetWorth = data.netWorth / maxNetWorth
        local normalizedOffensivePower = data.offensivePower / maxOffensivePower
        local normalizedLevel = data.level / maxLevel
        data.totalScore = normalizedNetWorth * NET_WORTH_WEIGHT + normalizedOffensivePower * OFFENSIVE_POWER_WEIGHT + normalizedLevel * LEVEL_WEIGHT
    end
end
local enemyHeroData = {}
local cachedPositions = {}
local updateEnemyHeroRolesTime = 0
local updateEnemyRolesTimeGap = 3
ItemOffensiveness = {
    item_desolator = 60,
    item_desolator_2 = 80,
    item_daedalus = 88,
    item_greater_crit = 88,
    item_bfury = 55,
    item_monkey_king_bar = 66,
    item_satanic = 25,
    item_butterfly = 30,
    item_abyssal_blade = 25,
    item_nullifier = 80,
    item_radiance = 60,
    item_bloodthorn = 70,
    item_silver_edge = 52,
    item_ethereal_blade = 40,
    item_rapier = 150,
    item_revenants_brooch = 45,
    item_overwhelming_blink = 25,
    item_swift_blink = 25,
    item_arcane_blink = 25,
    item_ultimate_scepter = 20,
    item_ultimate_scepter_2 = 20,
    item_aeon_disk = 10,
    item_kaya = 16,
    item_kaya_and_sange = 24,
    item_yasha_and_kaya = 24,
    item_moon_shard = 60,
    item_dragon_lance = 14,
    item_hurricane_pike = 20,
    item_orchid = 25,
    item_dagon_5 = 50,
    item_fallen_sky = 25,
    item_pirate_hat = 80,
    item_stormcrafter = 20
}
NET_WORTH_WEIGHT = 0.3
OFFENSIVE_POWER_WEIGHT = 0.3
LEVEL_WEIGHT = 0.4
local function UpdateEnemyHeroData(enemyHeroes)
    for ____, hero in ipairs(enemyHeroes) do
        if IsValidHero(hero) then
            local heroNetWorth = GetHeroNetWorth(hero)
            local heroOffensivePower = GetHeroOffensivePower(hero)
            local heroLevel = hero:GetLevel()
            local playerId = hero:GetPlayerID()
            local totalScore = heroNetWorth * NET_WORTH_WEIGHT + heroOffensivePower * OFFENSIVE_POWER_WEIGHT + heroLevel * LEVEL_WEIGHT
            enemyHeroData[playerId] = {
                hero = hero,
                netWorth = heroNetWorth,
                offensivePower = heroOffensivePower,
                level = heroLevel,
                totalScore = totalScore
            }
        end
    end
end
local function AssignPositions()
    local heroList = {}
    for ____, data in ipairs(__TS__ObjectValues(enemyHeroData)) do
        heroList[#heroList + 1] = data
    end
    NormalizeSores(heroList)
    __TS__ArraySort(
        heroList,
        function(____, a, b) return b.totalScore - a.totalScore end
    )
    do
        local index = 0
        while index < #heroList do
            local data = heroList[index + 1]
            local pos = index + 1
            if pos > 5 then
                pos = 5
            end
            if IsValidHero(data.hero) then
                cachedPositions[data.hero:GetPlayerID()] = pos
            end
            index = index + 1
        end
    end
    return cachedPositions
end
function ____exports.UpdateEnemyHeroPositions()
    if DotaTime() - updateEnemyHeroRolesTime > updateEnemyRolesTimeGap then
        updateEnemyHeroRolesTime = DotaTime()
        local enemyHeroes = GetUnitList(UnitType.EnemyHeroes)
        UpdateEnemyHeroData(enemyHeroes)
        AssignPositions()
    end
end
function ____exports.GetEnemyPosition(playerId)
    return cachedPositions[playerId]
end
return ____exports
