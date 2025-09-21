--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
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

local function __TS__StringIncludes(self, searchString, position)
    if not position then
        position = 1
    else
        position = position + 1
    end
    local index = string.find(self, searchString, position, true)
    return index ~= nil
end

local function __TS__New(target, ...)
    local instance = setmetatable({}, target.prototype)
    instance:____constructor(...)
    return instance
end

local function __TS__Class(self)
    local c = {prototype = {}}
    c.prototype.__index = c.prototype
    c.prototype.constructor = c
    return c
end

local function __TS__ClassExtends(target, base)
    target.____super = base
    local staticMetatable = setmetatable({__index = base}, base)
    setmetatable(target, staticMetatable)
    local baseMetatable = getmetatable(base)
    if baseMetatable then
        if type(baseMetatable.__index) == "function" then
            staticMetatable.__index = baseMetatable.__index
        end
        if type(baseMetatable.__newindex) == "function" then
            staticMetatable.__newindex = baseMetatable.__newindex
        end
    end
    setmetatable(target.prototype, base.prototype)
    if type(base.prototype.__index) == "function" then
        target.prototype.__index = base.prototype.__index
    end
    if type(base.prototype.__newindex) == "function" then
        target.prototype.__newindex = base.prototype.__newindex
    end
    if type(base.prototype.__tostring) == "function" then
        target.prototype.__tostring = base.prototype.__tostring
    end
end

local Error, RangeError, ReferenceError, SyntaxError, TypeError, URIError
do
    local function getErrorStack(self, constructor)
        if debug == nil then
            return nil
        end
        local level = 1
        while true do
            local info = debug.getinfo(level, "f")
            level = level + 1
            if not info then
                level = 1
                break
            elseif info.func == constructor then
                break
            end
        end
        if __TS__StringIncludes(_VERSION, "Lua 5.0") then
            return debug.traceback(("[Level " .. tostring(level)) .. "]")
        else
            return debug.traceback(nil, level)
        end
    end
    local function wrapErrorToString(self, getDescription)
        return function(self)
            local description = getDescription(self)
            local caller = debug.getinfo(3, "f")
            local isClassicLua = __TS__StringIncludes(_VERSION, "Lua 5.0") or _VERSION == "Lua 5.1"
            if isClassicLua or caller and caller.func ~= error then
                return description
            else
                return (description .. "\n") .. tostring(self.stack)
            end
        end
    end
    local function initErrorClass(self, Type, name)
        Type.name = name
        return setmetatable(
            Type,
            {__call = function(____, _self, message) return __TS__New(Type, message) end}
        )
    end
    local ____initErrorClass_1 = initErrorClass
    local ____class_0 = __TS__Class()
    ____class_0.name = ""
    function ____class_0.prototype.____constructor(self, message)
        if message == nil then
            message = ""
        end
        self.message = message
        self.name = "Error"
        self.stack = getErrorStack(nil, self.constructor.new)
        local metatable = getmetatable(self)
        if metatable and not metatable.__errorToStringPatched then
            metatable.__errorToStringPatched = true
            metatable.__tostring = wrapErrorToString(nil, metatable.__tostring)
        end
    end
    function ____class_0.prototype.__tostring(self)
        return self.message ~= "" and (self.name .. ": ") .. self.message or self.name
    end
    Error = ____initErrorClass_1(nil, ____class_0, "Error")
    local function createErrorClass(self, name)
        local ____initErrorClass_3 = initErrorClass
        local ____class_2 = __TS__Class()
        ____class_2.name = ____class_2.name
        __TS__ClassExtends(____class_2, Error)
        function ____class_2.prototype.____constructor(self, ...)
            ____class_2.____super.prototype.____constructor(self, ...)
            self.name = name
        end
        return ____initErrorClass_3(nil, ____class_2, name)
    end
    RangeError = createErrorClass(nil, "RangeError")
    ReferenceError = createErrorClass(nil, "ReferenceError")
    SyntaxError = createErrorClass(nil, "SyntaxError")
    TypeError = createErrorClass(nil, "TypeError")
    URIError = createErrorClass(nil, "URIError")
end

local function __TS__ObjectGetOwnPropertyDescriptors(object)
    local metatable = getmetatable(object)
    if not metatable then
        return {}
    end
    return rawget(metatable, "_descriptors") or ({})
end

local function __TS__Delete(target, key)
    local descriptors = __TS__ObjectGetOwnPropertyDescriptors(target)
    local descriptor = descriptors[key]
    if descriptor then
        if not descriptor.configurable then
            error(
                __TS__New(
                    TypeError,
                    ((("Cannot delete property " .. tostring(key)) .. " of ") .. tostring(target)) .. "."
                ),
                0
            )
        end
        descriptors[key] = nil
        return true
    end
    target[key] = nil
    return true
end

local function __TS__ObjectKeys(obj)
    local result = {}
    local len = 0
    for key in pairs(obj) do
        len = len + 1
        result[len] = key
    end
    return result
end

local function __TS__ArrayForEach(self, callbackFn, thisArg)
    for i = 1, #self do
        callbackFn(thisArg, self[i], i - 1, self)
    end
end
-- End of Lua Library inline imports
local ____exports = {}
local ____dota = require(GetScriptDirectory().."/ts_libs/dota/index")
local Lane = ____dota.Lane
local UnitType = ____dota.UnitType
local globalCache = {}
local GLOBAL_CACHE_TTL = 0.5
local globalGameStateCache = nil
local globalUnitStateCache = nil
local globalLocationStateCache = nil
--- Get or update global game state cache
function ____exports.getGlobalGameState()
    local now = DotaTime()
    if globalGameStateCache and now - globalGameStateCache.lastUpdate < GLOBAL_CACHE_TTL then
        return globalGameStateCache
    end
    local jmz = require(GetScriptDirectory().."/FunLib/jmz_func")
    local team = GetTeam()
    local enemyTeam = GetOpposingTeam()
    local currentTime = DotaTime()
    local gameMode = GetGameMode()
    local adjustedTime = gameMode == 23 and currentTime * 2 or currentTime
    globalGameStateCache = {
        lastUpdate = now,
        currentTime = adjustedTime,
        gameMode = gameMode,
        team = team,
        enemyTeam = enemyTeam,
        ourAncient = GetAncient(team),
        enemyAncient = GetAncient(enemyTeam),
        aliveAllyCount = jmz.GetNumOfAliveHeroes(false),
        aliveEnemyCount = jmz.GetNumOfAliveHeroes(true),
        aliveAllyCoreCount = jmz.GetAliveCoreCount(false),
        aliveEnemyCoreCount = jmz.GetAliveCoreCount(true),
        teamNetworth = jmz.GetInventoryNetworth()[0],
        enemyNetworth = jmz.GetInventoryNetworth()[1],
        averageLevel = jmz.GetAverageLevel(team),
        hasAegis = jmz.DoesTeamHaveAegis(),
        isEarlyGame = jmz.IsEarlyGame(),
        isMidGame = jmz.IsMidGame(),
        isLateGame = jmz.IsLateGame(),
        isLaningPhase = jmz.IsInLaningPhase()
    }
    return globalGameStateCache
end
--- Get or update global unit state cache
function ____exports.getGlobalUnitState()
    local now = DotaTime()
    if globalUnitStateCache and now - globalUnitStateCache.lastUpdate < GLOBAL_CACHE_TTL then
        return globalUnitStateCache
    end
    local jmz = require(GetScriptDirectory().."/FunLib/jmz_func")
    globalUnitStateCache = {
        lastUpdate = now,
        enemyBuildings = GetUnitList(UnitType.EnemyBuildings),
        alliedHeroes = GetUnitList(UnitType.AlliedHeroes),
        enemyHeroes = __TS__ArrayFilter(
            GetUnitList(UnitType.Enemies),
            function(____, u) return jmz.IsValidHero(u) end
        ),
        alliedCreeps = GetUnitList(UnitType.AlliedCreeps),
        enemyCreeps = __TS__ArrayFilter(
            GetUnitList(UnitType.Enemies),
            function(____, u) return u:IsCreep() or u:IsAncientCreep() end
        )
    }
    return globalUnitStateCache
end
--- Get or update global location state cache
function ____exports.getGlobalLocationState()
    local now = DotaTime()
    if globalLocationStateCache and now - globalLocationStateCache.lastUpdate < GLOBAL_CACHE_TTL then
        return globalLocationStateCache
    end
    local jmz = require(GetScriptDirectory().."/FunLib/jmz_func")
    local team = GetTeam()
    globalLocationStateCache = {
        lastUpdate = now,
        laneFronts = {
            [Lane.Top] = GetLaneFrontLocation(team, Lane.Top, 0),
            [Lane.Mid] = GetLaneFrontLocation(team, Lane.Mid, 0),
            [Lane.Bot] = GetLaneFrontLocation(team, Lane.Bot, 0)
        },
        teamFountain = jmz.GetTeamFountain(),
        enemyFountain = jmz.GetTeamFountain(),
        roshanLocation = jmz.GetCurrentRoshanLocation(),
        tormentorLocation = jmz.GetTormentorLocation(team),
        tormentorWaitingLocation = jmz.GetTormentorWaitingLocation(team)
    }
    return globalLocationStateCache
end
--- Generic cache function for arbitrary data
function ____exports.getCachedData(key, ttl, fetchFn)
    local now = DotaTime()
    local cached = globalCache[key]
    if cached and now - cached.lastUpdate < ttl then
        return cached.data
    end
    local data = fetchFn()
    globalCache[key] = {lastUpdate = now, data = data}
    return data
end
--- Clear old cache entries to prevent memory leaks
function ____exports.cleanupGlobalCache()
    local now = DotaTime()
    local maxAge = 10
    __TS__ArrayForEach(
        __TS__ObjectKeys(globalCache),
        function(____, key)
            if now - globalCache[key].lastUpdate > maxAge then
                __TS__Delete(globalCache, key)
            end
        end
    )
end
--- Clear all caches (useful for testing or when game state changes significantly)
function ____exports.clearAllCaches()
    __TS__ArrayForEach(
        __TS__ObjectKeys(globalCache),
        function(____, key)
            __TS__Delete(globalCache, key)
        end
    )
    globalGameStateCache = nil
    globalUnitStateCache = nil
    globalLocationStateCache = nil
end
--- Get cached allies near location
function ____exports.getCachedAlliesNearLoc(location, radius)
    local key = (((((("allies_" .. tostring(math.floor(location.x))) .. "_") .. tostring(math.floor(location.y))) .. "_") .. tostring(radius)) .. "_") .. tostring(math.floor(DotaTime() * 2))
    return ____exports.getCachedData(
        key,
        0.5,
        function()
            local jmz = require(GetScriptDirectory().."/FunLib/jmz_func")
            return jmz.GetAlliesNearLoc(location, radius)
        end
    )
end
--- Get cached enemies near location
function ____exports.getCachedEnemiesNearLoc(location, radius)
    local key = (((((("enemies_" .. tostring(math.floor(location.x))) .. "_") .. tostring(math.floor(location.y))) .. "_") .. tostring(radius)) .. "_") .. tostring(math.floor(DotaTime() * 2))
    return ____exports.getCachedData(
        key,
        0.5,
        function()
            local jmz = require(GetScriptDirectory().."/FunLib/jmz_func")
            return jmz.GetEnemiesNearLoc(location, radius)
        end
    )
end
local lastCleanupTime = 0
function ____exports.autoCleanupCache()
    local now = DotaTime()
    if now - lastCleanupTime > 30 then
        ____exports.cleanupGlobalCache()
        lastCleanupTime = now
    end
end
return ____exports
