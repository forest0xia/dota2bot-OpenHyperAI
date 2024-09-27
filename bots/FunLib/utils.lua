--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ObjectEntries(obj)
    local result = {}
    local len = 0
    for key in pairs(obj) do
        len = len + 1
        result[len] = {key, obj[key]}
    end
    return result
end

local __TS__Symbol, Symbol
do
    local symbolMetatable = {__tostring = function(self)
        return ("Symbol(" .. (self.description or "")) .. ")"
    end}
    function __TS__Symbol(description)
        return setmetatable({description = description}, symbolMetatable)
    end
    Symbol = {
        asyncDispose = __TS__Symbol("Symbol.asyncDispose"),
        dispose = __TS__Symbol("Symbol.dispose"),
        iterator = __TS__Symbol("Symbol.iterator"),
        hasInstance = __TS__Symbol("Symbol.hasInstance"),
        species = __TS__Symbol("Symbol.species"),
        toStringTag = __TS__Symbol("Symbol.toStringTag")
    }
end

local function __TS__ArrayEntries(array)
    local key = 0
    return {
        [Symbol.iterator] = function(self)
            return self
        end,
        next = function(self)
            local result = {done = array[key + 1] == nil, value = {key, array[key + 1]}}
            key = key + 1
            return result
        end
    }
end

local __TS__Iterator
do
    local function iteratorGeneratorStep(self)
        local co = self.____coroutine
        local status, value = coroutine.resume(co)
        if not status then
            error(value, 0)
        end
        if coroutine.status(co) == "dead" then
            return
        end
        return true, value
    end
    local function iteratorIteratorStep(self)
        local result = self:next()
        if result.done then
            return
        end
        return true, result.value
    end
    local function iteratorStringStep(self, index)
        index = index + 1
        if index > #self then
            return
        end
        return index, string.sub(self, index, index)
    end
    function __TS__Iterator(iterable)
        if type(iterable) == "string" then
            return iteratorStringStep, iterable, 0
        elseif iterable.____coroutine ~= nil then
            return iteratorGeneratorStep, iterable
        elseif iterable[Symbol.iterator] then
            local iterator = iterable[Symbol.iterator](iterable)
            return iteratorIteratorStep, iterator
        else
            return ipairs(iterable)
        end
    end
end

local function __TS__Class(self)
    local c = {prototype = {}}
    c.prototype.__index = c.prototype
    c.prototype.constructor = c
    return c
end

local function __TS__New(target, ...)
    local instance = setmetatable({}, target.prototype)
    instance:____constructor(...)
    return instance
end

local Set
do
    Set = __TS__Class()
    Set.name = "Set"
    function Set.prototype.____constructor(self, values)
        self[Symbol.toStringTag] = "Set"
        self.size = 0
        self.nextKey = {}
        self.previousKey = {}
        if values == nil then
            return
        end
        local iterable = values
        if iterable[Symbol.iterator] then
            local iterator = iterable[Symbol.iterator](iterable)
            while true do
                local result = iterator:next()
                if result.done then
                    break
                end
                self:add(result.value)
            end
        else
            local array = values
            for ____, value in ipairs(array) do
                self:add(value)
            end
        end
    end
    function Set.prototype.add(self, value)
        local isNewValue = not self:has(value)
        if isNewValue then
            self.size = self.size + 1
        end
        if self.firstKey == nil then
            self.firstKey = value
            self.lastKey = value
        elseif isNewValue then
            self.nextKey[self.lastKey] = value
            self.previousKey[value] = self.lastKey
            self.lastKey = value
        end
        return self
    end
    function Set.prototype.clear(self)
        self.nextKey = {}
        self.previousKey = {}
        self.firstKey = nil
        self.lastKey = nil
        self.size = 0
    end
    function Set.prototype.delete(self, value)
        local contains = self:has(value)
        if contains then
            self.size = self.size - 1
            local next = self.nextKey[value]
            local previous = self.previousKey[value]
            if next ~= nil and previous ~= nil then
                self.nextKey[previous] = next
                self.previousKey[next] = previous
            elseif next ~= nil then
                self.firstKey = next
                self.previousKey[next] = nil
            elseif previous ~= nil then
                self.lastKey = previous
                self.nextKey[previous] = nil
            else
                self.firstKey = nil
                self.lastKey = nil
            end
            self.nextKey[value] = nil
            self.previousKey[value] = nil
        end
        return contains
    end
    function Set.prototype.forEach(self, callback)
        for ____, key in __TS__Iterator(self:keys()) do
            callback(nil, key, key, self)
        end
    end
    function Set.prototype.has(self, value)
        return self.nextKey[value] ~= nil or self.lastKey == value
    end
    Set.prototype[Symbol.iterator] = function(self)
        return self:values()
    end
    function Set.prototype.entries(self)
        local nextKey = self.nextKey
        local key = self.firstKey
        return {
            [Symbol.iterator] = function(self)
                return self
            end,
            next = function(self)
                local result = {done = not key, value = {key, key}}
                key = nextKey[key]
                return result
            end
        }
    end
    function Set.prototype.keys(self)
        local nextKey = self.nextKey
        local key = self.firstKey
        return {
            [Symbol.iterator] = function(self)
                return self
            end,
            next = function(self)
                local result = {done = not key, value = key}
                key = nextKey[key]
                return result
            end
        }
    end
    function Set.prototype.values(self)
        local nextKey = self.nextKey
        local key = self.firstKey
        return {
            [Symbol.iterator] = function(self)
                return self
            end,
            next = function(self)
                local result = {done = not key, value = key}
                key = nextKey[key]
                return result
            end
        }
    end
    function Set.prototype.union(self, other)
        local result = __TS__New(Set, self)
        for ____, item in __TS__Iterator(other) do
            result:add(item)
        end
        return result
    end
    function Set.prototype.intersection(self, other)
        local result = __TS__New(Set)
        for ____, item in __TS__Iterator(self) do
            if other:has(item) then
                result:add(item)
            end
        end
        return result
    end
    function Set.prototype.difference(self, other)
        local result = __TS__New(Set, self)
        for ____, item in __TS__Iterator(other) do
            result:delete(item)
        end
        return result
    end
    function Set.prototype.symmetricDifference(self, other)
        local result = __TS__New(Set, self)
        for ____, item in __TS__Iterator(other) do
            if self:has(item) then
                result:delete(item)
            else
                result:add(item)
            end
        end
        return result
    end
    function Set.prototype.isSubsetOf(self, other)
        for ____, item in __TS__Iterator(self) do
            if not other:has(item) then
                return false
            end
        end
        return true
    end
    function Set.prototype.isSupersetOf(self, other)
        for ____, item in __TS__Iterator(other) do
            if not self:has(item) then
                return false
            end
        end
        return true
    end
    function Set.prototype.isDisjointFrom(self, other)
        for ____, item in __TS__Iterator(self) do
            if other:has(item) then
                return false
            end
        end
        return true
    end
    Set[Symbol.species] = Set
end

local function __TS__ArrayIsArray(value)
    return type(value) == "table" and (value[1] ~= nil or next(value) == nil)
end

local function __TS__ArrayConcat(self, ...)
    local items = {...}
    local result = {}
    local len = 0
    for i = 1, #self do
        len = len + 1
        result[len] = self[i]
    end
    for i = 1, #items do
        local item = items[i]
        if __TS__ArrayIsArray(item) then
            for j = 1, #item do
                len = len + 1
                result[len] = item[j]
            end
        else
            len = len + 1
            result[len] = item
        end
    end
    return result
end

local function __TS__ArraySome(self, callbackfn, thisArg)
    for i = 1, #self do
        if callbackfn(thisArg, self[i], i - 1, self) then
            return true
        end
    end
    return false
end

local function __TS__StringTrim(self)
    local result = string.gsub(self, "^[%s ﻿]*(.-)[%s ﻿]*$", "%1")
    return result
end

local function __TS__ArrayFilter(self, callbackfn, thisArg)
    local result = {}
    local len = 0
    for i = 1, #self do
        if callbackfn(thisArg, self[i], i - 1, self) then
            len = len + 1
            result[len] = self[i]
        end
    end
    return result
end
-- End of Lua Library inline imports
local ____exports = {}
local avoidanceZones
local ____dota = require("bots.ts_libs.dota.index")
local Barracks = ____dota.Barracks
local Lane = ____dota.Lane
local Team = ____dota.Team
local UnitType = ____dota.UnitType
local ____http_req = require("bots.ts_libs.utils.http_utils.http_req")
local Request = ____http_req.Request
local ____native_2Doperators = require("bots.ts_libs.utils.native-operators")
local add = ____native_2Doperators.add
local dot = ____native_2Doperators.dot
local length2D = ____native_2Doperators.length2D
local multiply = ____native_2Doperators.multiply
local sub = ____native_2Doperators.sub
function ____exports.GetLocationToLocationDistance(fLoc, sLoc)
    local x1 = fLoc.x
    local x2 = sLoc.x
    local y1 = fLoc.y
    local y2 = sLoc.y
    return math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1))
end
function ____exports.findSafePosition(currentPosition, targetPosition)
    local direction = sub(targetPosition, currentPosition):Normalized()
    local safeDistance = ____exports.getSafeDistance(currentPosition, targetPosition)
    return add(
        currentPosition,
        multiply(direction, safeDistance)
    )
end
function ____exports.getSafeDistance(currentPosition, targetPosition)
    local maxDistance = length2D(sub(targetPosition, currentPosition))
    for ____, zone in ipairs(avoidanceZones) do
        local projectedPoint = ____exports.projectPointOntoLine(currentPosition, targetPosition, zone.center)
        local distanceToZone = length2D(sub(projectedPoint, zone.center))
        if distanceToZone <= zone.radius then
            local distanceToAvoid = length2D(sub(projectedPoint, currentPosition)) - zone.radius
            return math.max(0, distanceToAvoid)
        end
    end
    return maxDistance
end
function ____exports.projectPointOntoLine(startPoint, endPoint, point)
    local lineDir = sub(endPoint, startPoint):Normalized()
    local toPoint = sub(point, startPoint)
    local projectionLength = dot(toPoint, lineDir)
    return add(
        startPoint,
        multiply(lineDir, projectionLength)
    )
end
require("bots.ts_libs.utils.json")
____exports.DebugMode = true
____exports.ScriptID = 3246316298
____exports.RadiantFountainTpPoint = Vector(-7172, -6652, 384)
____exports.DireFountainTpPoint = Vector(6982, 6422, 392)
____exports.BarrackList = {
    Barracks.TopMelee,
    Barracks.TopRanged,
    Barracks.MidMelee,
    Barracks.MidRanged,
    Barracks.BotMelee,
    Barracks.BotRanged
}
____exports.WisdomRunes = {
    [Team.Radiant] = Vector(-8126, -320, 256),
    [Team.Dire] = Vector(8319, 266, 256)
}
____exports.BuggyHeroesDueToValveTooLazy = {
    npc_dota_hero_muerta = true,
    npc_dota_hero_marci = true,
    npc_dota_hero_lone_druid_bear = true,
    npc_dota_hero_primal_beast = true,
    npc_dota_hero_dark_willow = true,
    npc_dota_hero_elder_titan = true,
    npc_dota_hero_hoodwink = true,
    npc_dota_hero_wisp = true
}
avoidanceZones = {}
____exports.GameStates = {defendPings = nil}
____exports.LoneDruid = {}
____exports.FrameProcessTime = 0.05
____exports.EstimatedEnemyRoles = {npc_dota_hero_any = {lane = Lane.Mid, role = 2}}
function ____exports.PrintTable(tbl, indent)
    if indent == nil then
        indent = 0
    end
    if tbl == nil then
        print("nil")
        return
    end
    for ____, ____value in ipairs(__TS__ObjectEntries(tbl)) do
        local key = ____value[1]
        local value = ____value[2]
        local prefix = (string.rep("  ", indent) .. tostring(key)) .. ": "
        if type(value) == "table" then
            if indent < 3 then
                print(prefix)
                ____exports.PrintTable(value, indent + 1)
            else
                print(prefix .. "[WARN] Table has deep nested tables in it, stop printing more nested tables.")
            end
        else
            print(prefix .. tostring(value))
        end
    end
end
function ____exports.PrintUnitModifiers(unit)
    local modifierCount = unit:NumModifiers()
    do
        local i = 0
        while i < modifierCount do
            local modifierName = unit:GetModifierName(i)
            local stackCount = unit:GetModifierStackCount(i)
            print((((("Unit " .. unit:GetUnitName()) .. " has modifier ") .. tostring(modifierName)) .. " with stack count ") .. tostring(stackCount))
            i = i + 1
        end
    end
end
function ____exports.PrintPings(pingTimeGap)
    local listPings = {}
    local teamPlayers = GetTeamPlayers(GetTeam())
    for ____, ____value in __TS__Iterator(__TS__ArrayEntries(teamPlayers)) do
        local index = ____value[1]
        local _ = ____value[2]
        do
            local __continue13
            repeat
                local allyHero = GetTeamMember(index)
                if allyHero == nil or allyHero:IsIllusion() then
                    __continue13 = true
                    break
                end
                local ping = allyHero:GetMostRecentPing()
                if ping.time ~= 0 and GameTime() - ping.time < pingTimeGap then
                    listPings[#listPings + 1] = ping
                end
                __continue13 = true
            until true
            if not __continue13 then
                break
            end
        end
    end
end
function ____exports.PrintAllAbilities(unit)
    print("Get all abilities of bot " .. unit:GetUnitName())
    for index = 0, 10 do
        local ability = unit:GetAbilityInSlot(index)
        if ability and not ability:IsNull() then
            print((("Ability At Index " .. tostring(index)) .. ": ") .. ability:GetName())
        else
            print(("Ability At Index " .. tostring(index)) .. " is nil")
        end
    end
end
function ____exports.GetEnemyFountainTpPoint()
    if GetTeam() == Team.Dire then
        return ____exports.RadiantFountainTpPoint
    end
    return ____exports.DireFountainTpPoint
end
function ____exports.GetTeamFountainTpPoint()
    if GetTeam() == Team.Dire then
        return ____exports.DireFountainTpPoint
    end
    return ____exports.RadiantFountainTpPoint
end
function ____exports.Shuffle(tbl)
    do
        local i = #tbl - 1
        while i >= 1 do
            local j = RandomInt(1, i + 1)
            local temp = tbl[i + 1]
            tbl[i + 1] = tbl[j + 1]
            tbl[j + 1] = temp
            i = i - 1
        end
    end
    return tbl
end
function ____exports.SetFrameProcessTime(bot)
    if bot.frameProcessTime == nil then
        bot.frameProcessTime = ____exports.FrameProcessTime + math.fmod(
            bot:GetPlayerID() / 1000,
            ____exports.FrameProcessTime / 10
        ) * 2
    end
end
function ____exports.GetHumanPing()
    local teamPlayers = GetTeamPlayers(GetTeam())
    for ____, ____value in __TS__Iterator(__TS__ArrayEntries(teamPlayers)) do
        local index = ____value[1]
        local _ = ____value[2]
        local teamMember = GetTeamMember(index)
        if teamMember ~= nil and not teamMember:IsBot() then
            return teamMember, teamMember:GetMostRecentPing()
        end
    end
    return nil, nil
end
function ____exports.IsPingedByAnyPlayer(bot, pingTimeGap, minDistance, maxDistance)
    if not bot:IsAlive() then
        return nil
    end
    local pings = {}
    local teamPlayerIds = GetTeamPlayers(GetTeam())
    minDistance = minDistance or 1500
    maxDistance = maxDistance or 10000
    for ____, ____value in __TS__Iterator(__TS__ArrayEntries(teamPlayerIds)) do
        local index = ____value[1]
        local _ = ____value[2]
        do
            local __continue35
            repeat
                local teamMember = GetTeamMember(index)
                if teamMember == nil or teamMember:IsIllusion() or teamMember == bot then
                    __continue35 = true
                    break
                end
                local ping = teamMember:GetMostRecentPing()
                if ping ~= nil then
                    pings[#pings + 1] = ping
                end
                __continue35 = true
            until true
            if not __continue35 then
                break
            end
        end
    end
    for ____, ping in ipairs(pings) do
        local distanceToBot = ____exports.GetLocationToLocationDistance(
            ping.location,
            bot:GetLocation()
        )
        local withinRange = minDistance <= distanceToBot and distanceToBot <= maxDistance
        local withinTimeRange = GameTime() - ping.time < pingTimeGap
        if withinRange and withinTimeRange then
            print(("Bot " .. bot:GetUnitName()) .. " noticed the ping")
            return ping
        end
    end
    return nil
end
function ____exports.IsValidUnit(target)
    return target ~= nil and not target:IsNull() and target:CanBeSeen() and target:IsAlive()
end
function ____exports.IsValidHero(target)
    return ____exports.IsValidUnit(target) and target:IsHero()
end
function ____exports.IsValidCreep(target)
    return ____exports.IsValidUnit(target) and target:GetHealth() < 5000 and not target:IsHero() and (GetBot():GetLevel() > 9 or not target:IsAncientCreep())
end
function ____exports.IsValidBuilding(target)
    return ____exports.IsValidUnit(target) and target:IsBuilding()
end
function ____exports.HasItem(bot, itemName)
    local slot = bot:FindItemSlot(itemName)
    return slot >= 0 and slot <= 8
end
function ____exports.FindAllyWithName(name)
    for ____, ally in ipairs(GetUnitList(UnitType.AlliedHeroes)) do
        if ____exports.IsValidHero(ally) and ({string.find(
            ally:GetUnitName(),
            name
        )}) then
            return ally
        end
    end
    return nil
end
function ____exports.Deepcopy(orig)
    local originalType = type(orig)
    local copy
    if originalType == "table" then
        copy = {}
        for ____, ____value in ipairs(__TS__ObjectEntries(orig)) do
            local key = ____value[1]
            local value = ____value[2]
            copy[____exports.Deepcopy(key)] = ____exports.Deepcopy(value)
        end
        setmetatable(
            copy,
            ____exports.Deepcopy(getmetatable(orig))
        )
    else
        copy = orig
    end
    return copy
end
function ____exports.CombineTablesUnique(tbl1, tbl2)
    local set = __TS__New(Set)
    for ____, ____value in ipairs(__TS__ObjectEntries(tbl1)) do
        local _ = ____value[1]
        local value = ____value[2]
        set:add(value)
    end
    for ____, ____value in ipairs(__TS__ObjectEntries(tbl2)) do
        local _ = ____value[1]
        local value = ____value[2]
        set:add(value)
    end
    local result = {}
    for ____, element in __TS__Iterator(set) do
        result[#result + 1] = element
    end
    return result
end
function ____exports.MergeLists(a, b)
    return __TS__ArrayConcat(a, b)
end
function ____exports.RemoveValueFromTable(table_, valueToRemove)
    for index = #table_, 1, -1 do
        if table_[index] == valueToRemove then
            table.remove(table_, index)
        end
    end
end
function ____exports.NumActionTypeInQueue(bot, searchedActionType)
    local count = 0
    for index = 1, bot:NumQueuedActions() do
        local actionType = bot:GetQueuedActionType(index)
        if actionType == searchedActionType then
            count = count + 1
        end
    end
    return count
end
local humanCountCache = {}
function ____exports.NumHumanBotPlayersInTeam(team)
    if not (humanCountCache[team] ~= nil) then
        local humans = 0
        local bots = 0
        for ____, playerdId in ipairs(GetTeamPlayers(team)) do
            if IsPlayerBot(playerdId) then
                bots = bots + 1
            else
                humans = humans + 1
            end
        end
        humanCountCache[team] = {humans, bots}
    end
    return humanCountCache[team][1], humanCountCache[team][2]
end
function ____exports.IsWithoutSpellShield(npcEnemy)
    return not npcEnemy:HasModifier("modifier_item_sphere_target") and not npcEnemy:HasModifier("modifier_antimage_spell_shield") and not npcEnemy:HasModifier("modifier_item_lotus_orb_active")
end
function ____exports.SetContains(set, key)
    return set[key] ~= nil
end
function ____exports.AddToSet(set, key)
    set[key] = true
end
function ____exports.RemoveFromSet(set, key)
    set[key] = nil
end
function ____exports.HasValue(set, value)
    for _, element in ipairs(set) do
        if value == element then
            return true
        end
    end
    return false
end
function ____exports.CountBackpackEmptySpace(bot)
    local count = 3
    for ____, slot in ipairs({6, 7, 8}) do
        if bot:GetItemInSlot(slot) ~= nil then
            count = count - 1
        end
    end
    return count
end
function ____exports.FloatEqual(a, b)
    return math.abs(a - b) < 0.000001
end
local magicTable = {}
magicTable.__index = magicTable
function ____exports.NewTable()
    local a = {}
    setmetatable(a, magicTable)
    return a
end
function ____exports.ForEach(_, tb, action)
    for key, value in ipairs(tb) do
        action(key, value)
    end
end
function ____exports.Remove_Modify(table_, item)
    local filter = item
    if type(item) ~= "function" then
        filter = function(t) return t == item end
    end
    local i = 1
    local d = table_.length
    while i <= d do
        if filter(table_[i]) then
            table.remove(table_, i)
            d = d - 1
        else
            i = i + 1
        end
    end
end
function ____exports.AbilityBehaviorHasFlag(behavior, flag)
    return bit.band(behavior, flag) == flag
end
local everySecondsCallRegistry = {}
local function EveryManySeconds(second, oldFunction)
    local functionName = tostring(oldFunction)
    everySecondsCallRegistry[functionName] = {
        lastCallTime = DotaTime() + RandomInt(0, second * 1000) / 1000,
        interval = second,
        startup = true
    }
    return function(...)
        local callTable = everySecondsCallRegistry[functionName]
        if callTable.startup then
            callTable.startup = nil
            return oldFunction(...)
        elseif callTable.lastCallTime <= DotaTime() - callTable.interval then
            callTable.lastCallTime = DotaTime()
            return oldFunction(...)
        end
        return ____exports.NewTable()
    end
end
function ____exports.RecentlyTookDamage(bot, delta)
    return bot:WasRecentlyDamagedByAnyHero(delta) or bot:WasRecentlyDamagedByTower(delta) or bot:WasRecentlyDamagedByCreep(delta)
end
function ____exports.IsUnitWithName(unit, name)
    local result = {string.find(
        unit:GetUnitName(),
        name
    )}
    return result ~= nil
end
function ____exports.IsBear(unit)
    return ____exports.IsUnitWithName(unit, "lone_druid_bear")
end
function ____exports.GetOffsetLocationTowardsTargetLocation(initLoc, targetLoc, offsetDist)
    local direrction = sub(targetLoc, initLoc):Normalized()
    return add(
        initLoc,
        multiply(direrction, offsetDist)
    )
end
function ____exports.TimeNeedToHealHP(bot)
    return (bot:GetMaxHealth() - bot:GetHealth()) / bot:GetHealthRegen()
end
function ____exports.TimeNeedToHealMP(bot)
    return (bot:GetMaxMana() - bot:GetMana()) / bot:GetManaRegen()
end
function ____exports.HasAnyEffect(unit, ...)
    local effects = {...}
    return __TS__ArraySome(
        effects,
        function(____, effect) return unit:HasModifier(effect) end
    )
end
function ____exports.IsModeTurbo()
    for ____, u in ipairs(GetUnitList(UnitType.Allies)) do
        if u and u:GetUnitName() == "npc_dota_courier" and u:GetCurrentMovementSpeed() == 1100 then
            return true
        end
    end
    return false
end
function ____exports.DetermineEnemyBotRole(bot)
    local botName = bot:GetUnitName()
    local estimatedRole = ____exports.EstimatedEnemyRoles[botName]
    if estimatedRole == nil then
        print(("Enemy bot " .. botName) .. " role not cached yet.")
        return 3
    end
    return estimatedRole.role
end
function ____exports.QueryCounters(heroId)
    print("heroId=" .. tostring(heroId))
    Request:RawGetRequest(
        ("https://api.opendota.com/api/heroes/" .. tostring(heroId)) .. "/matchups",
        function(res)
            ____exports.PrintTable(res)
        end
    )
end
function ____exports.GetLoneDruid(bot)
    local res = ____exports.LoneDruid[bot:GetPlayerID()]
    if res == nil then
        ____exports.LoneDruid[bot:GetPlayerID()] = {}
        res = ____exports.LoneDruid[bot:GetPlayerID()]
    end
    return res
end
function ____exports.TrimString(str)
    return __TS__StringTrim(str)
end
--- TODO: AvoidanceZone work in progress.
-- 
-- Example: Adds a zone that expires after 10 seconds: addCustomAvoidanceZone(Vector(1000, 2000), 500, 10);
-- Example: Adds a zone lasts indefinitely: addCustomAvoidanceZone(Vector(1000, 2000), 500);
-- 
-- @param center
-- @param radius
-- @param duration
function ____exports.addCustomAvoidanceZone(center, radius, duration)
    local currentTime = DotaTime()
    local expirationTime = duration ~= nil and currentTime + duration or math.huge
    avoidanceZones[#avoidanceZones + 1] = {center = center, radius = radius, expirationTime = expirationTime}
end
function ____exports.cleanExpiredAvoidanceZones()
    local currentTime = DotaTime()
    avoidanceZones = __TS__ArrayFilter(
        avoidanceZones,
        function(____, zone) return zone.expirationTime > currentTime end
    )
end
function ____exports.getCustomAvoidanceZones()
    return avoidanceZones
end
function ____exports.isPositionInAvoidanceZone(position)
    for ____, zone in ipairs(avoidanceZones) do
        local distance = length2D(sub(position, zone.center))
        if distance <= zone.radius then
            return true
        end
    end
    return false
end
function ____exports.moveToPositionAvoidingZones(bot, targetPosition)
    if ____exports.isPositionInAvoidanceZone(targetPosition) then
        local safePosition = ____exports.findSafePosition(
            bot:GetLocation(),
            targetPosition
        )
        bot:Action_MoveToLocation(safePosition)
    else
        bot:Action_MoveToLocation(targetPosition)
    end
end
function ____exports.drawAvoidanceZones()
    for ____, zone in ipairs(avoidanceZones) do
        DebugDrawCircle(
            zone.center,
            zone.radius,
            0,
            255,
            0
        )
    end
end
function ____exports.findPathAvoidingZones(startPosition, endPosition)
    return {}
end
function ____exports.IsBuildingAttackedByEnemy(building)
    if building:WasRecentlyDamagedByAnyHero(2) or building:WasRecentlyDamagedByCreep(2) then
        return building
    end
    return nil
end
function ____exports.IsAnyBarrackAttackByEnemyHero()
    for ____, barrackE in ipairs(____exports.BarrackList) do
        local barrack = GetBarracks(
            GetTeam(),
            barrackE
        )
        if barrack ~= nil and barrack:GetHealth() > 0 then
            local bar = ____exports.IsBuildingAttackedByEnemy(barrack)
            if bar ~= nil then
                return bar
            end
        end
    end
    return nil
end
return ____exports
