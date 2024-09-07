local ____lualib = require("lualib_bundle")
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayJoin = ____lualib.__TS__ArrayJoin
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ArrayEntries = ____lualib.__TS__ArrayEntries
local __TS__Iterator = ____lualib.__TS__Iterator
local Set = ____lualib.Set
local __TS__New = ____lualib.__TS__New
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local __TS__ArraySome = ____lualib.__TS__ArraySome
local ____exports = {}
local print, orig_print
local ____dota = require("bots.lib.dota.index")
local Team = ____dota.Team
local UnitType = ____dota.UnitType
function print(...)
    local args = {...}
    if not ____exports.DebugMode then
        return
    end
    local output = __TS__ArrayJoin(
        __TS__ArrayMap(
            args,
            function(____, v) return tostring(v) end
        ),
        "\t"
    )
    orig_print(output)
end
function ____exports.GetLocationToLocationDistance(fLoc, sLoc)
    local x1 = fLoc.x
    local x2 = sLoc.x
    local y1 = fLoc.y
    local y2 = sLoc.y
    return math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1))
end
____exports.DebugMode = false
____exports.ScriptID = 3246316298
local RadiantFountainTpPoint = Vector(-7172, -6652, 384)
local DireFountainTpPoint = Vector(6982, 6422, 392)
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
____exports.GameStates = {}
____exports.LoneDruid = {}
____exports.FrameProcessTime = 0.05
orig_print = print
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
        do
            local __continue7
            repeat
                local prefix = (string.rep("  ", indent) .. tostring(key)) .. ": "
                if type(value) ~= "table" then
                    print(prefix .. tostring(value))
                    __continue7 = true
                    break
                end
                if indent <= 2 then
                    print(prefix)
                    ____exports.PrintTable(value, indent + 1)
                else
                    print(prefix .. "[WARN] Table has deep nested tables in it, stop printing more nested tables.")
                end
                __continue7 = true
            until true
            if not __continue7 then
                break
            end
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
        return RadiantFountainTpPoint
    end
    return DireFountainTpPoint
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
    for ____, ____value in __TS__Iterator(__TS__ArrayEntries(teamPlayerIds)) do
        local index = ____value[1]
        local _ = ____value[2]
        do
            local __continue33
            repeat
                local teamMember = GetTeamMember(index)
                if teamMember == nil or teamMember:IsIllusion() or teamMember == bot then
                    __continue33 = true
                    break
                end
                local ping = teamMember:GetMostRecentPing()
                if ping ~= nil then
                    pings[#pings + 1] = ping
                end
                __continue33 = true
            until true
            if not __continue33 then
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
        if withinRange and withinTimeRange and ping.player_id ~= -1 then
            print(("Bot " .. bot:GetUnitName()) .. " noticed the ping")
            return ping
        end
    end
    return nil
end
function ____exports.IsValidUnit(target)
    return target ~= nil and not target:IsNull() and target:CanBeSeen() and target:IsAlive()
end
function ____exports.FindAllyWithName(name)
    for ____, ally in ipairs(GetUnitList(UnitType.AlliedHeroes)) do
        if ____exports.IsValidUnit(ally) and ally:IsHero() and ({string.find(
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
    if originalType ~= "table" then
        return orig
    end
    local copy = {}
    for ____, ____value in ipairs(__TS__ObjectEntries(orig)) do
        local key = ____value[1]
        local value = ____value[2]
        copy[____exports.Deepcopy(key)] = ____exports.Deepcopy(value)
    end
    setmetatable(
        copy,
        ____exports.Deepcopy(getmetatable(orig))
    )
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
function ____exports.HasActionTypeInQueue(bot, searchedActionType)
    for index = 1, bot:NumQueuedActions() do
        local actionType = bot:GetQueuedActionType(index)
        if actionType == searchedActionType then
            return true
        end
    end
    return nil
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
local function subVectors(a, b)
    return a - b
end
local function addVectors(a, b)
    return a + b
end
local function multiplyVectors(a, b)
    return a * b
end
function ____exports.GetOffsetLocationTowardsTargetLocation(initLoc, targetLoc, offsetDist)
    local direrction = subVectors(targetLoc, initLoc):Normalized()
    return addVectors(
        initLoc,
        multiplyVectors(direrction, offsetDist)
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
return ____exports
