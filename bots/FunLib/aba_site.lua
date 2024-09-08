local ____lualib = require("lualib_bundle")
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ObjectValues = ____lualib.__TS__ObjectValues
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local ____exports = {}
local ____dota = require("bots.ts_libs.dota.index")
local BotModeDesire = ____dota.BotModeDesire
local UnitType = ____dota.UnitType
local BotMode = ____dota.BotMode
local BotScriptEnums = ____dota.BotScriptEnums
local Team = ____dota.Team
local ____utils = require("bots.FunLib.utils")
local HasItem = ____utils.HasItem
local GetLocationToLocationDistance = ____utils.GetLocationToLocationDistance
local GetOffsetLocationTowardsTargetLocation = ____utils.GetOffsetLocationTowardsTargetLocation
local IsModeTurbo = ____utils.IsModeTurbo
local visionRad = 2000
local trueSightRad = 1000
local RADIANT_RUNE_WARD = Vector(2606, -1547, 0)
local RADIANT_T3TOPFALL = Vector(-6600, -3072, 0)
local RADIANT_T3MIDFALL = Vector(-4314, -3887, 0)
local RADIANT_T3BOTFALL = Vector(-3586, -6131, 0)
local RADIANT_T2TOPFALL = Vector(-4345, -1018, 663)
local RADIANT_T2MIDFALL = Vector(1283, -5109, 655)
local RADIANT_T2BOTFALL = Vector(-514, -3321, 655)
local RADIANT_T1TOPFALL = Vector(-4089, 1544, 535)
local RADIANT_T1MIDFALL = Vector(2818, -3047, 655)
local RADIANT_T1BOTFALL = Vector(5253, -4844, 0)
local RADIANT_MANDATE1 = Vector(-1243, -200, 0)
local RADIANT_MANDATE2 = RADIANT_RUNE_WARD
local DIRE_RUNE_WARD = Vector(2606, -1547, 0)
local DIRE_T3TOPFALL = Vector(3087, 5690, 0)
local DIRE_T3MIDFALL = Vector(4024, 3445, 0)
local DIRE_T3BOTFALL = Vector(6354, 2606, 0)
local DIRE_T2TOPFALL = Vector(514, 4107, 655)
local DIRE_T2MIDFALL = Vector(2047, -769, 655)
local DIRE_T2BOTFALL = Vector(4620, 788, 655)
local DIRE_T1TOPFALL = Vector(-2815, 3565, 256)
local DIRE_T1MIDFALL = Vector(-760, 2053, 655)
local DIRE_T1BOTFALL = Vector(5122, -1930, 527)
local DIRE_MANDATE1 = DIRE_RUNE_WARD
local DIRE_MANDATE2 = Vector(-463, 447, 0)
local RADIANT_AGGRESSIVETOP = DIRE_T2TOPFALL
local RADIANT_AGGRESSIVEMID1 = DIRE_T1MIDFALL
local RADIANT_AGGRESSIVEMID2 = DIRE_T2MIDFALL
local RADIANT_AGGRESSIVEBOT = DIRE_T2BOTFALL
local DIRE_AGGRESSIVETOP = RADIANT_T1TOPFALL
local DIRE_AGGRESSIVEMID1 = RADIANT_T2TOPFALL
local DIRE_AGGRESSIVEMID2 = RADIANT_T2MIDFALL
local DIRE_AGGRESSIVEBOT = RADIANT_T2BOTFALL
local WardSpotTowerFallRadiant = {
    RADIANT_T1TOPFALL,
    RADIANT_T1MIDFALL,
    RADIANT_T1BOTFALL,
    RADIANT_T2TOPFALL,
    RADIANT_T2MIDFALL,
    RADIANT_T2BOTFALL,
    RADIANT_T3TOPFALL,
    RADIANT_T3MIDFALL,
    RADIANT_T3BOTFALL
}
local WardSpotTowerFallDire = {
    DIRE_T1TOPFALL,
    DIRE_T1MIDFALL,
    DIRE_T1BOTFALL,
    DIRE_T2TOPFALL,
    DIRE_T2MIDFALL,
    DIRE_T2BOTFALL,
    DIRE_T3TOPFALL,
    DIRE_T3MIDFALL,
    DIRE_T3BOTFALL
}
local CStackLoc = {
    Vector(1854, -4469, 0),
    Vector(1249, -2416, 0),
    Vector(3471, -5841, 0),
    Vector(5153, -3620, 0),
    Vector(-1846, -2996, 0),
    Vector(-4961, 559, 0),
    Vector(-3873, -833, 0),
    Vector(-3146, 702, 0),
    Vector(1141, -3111, 0),
    Vector(660, 2300, 0),
    Vector(3666, 1836, 0),
    Vector(482, 4723, 0),
    Vector(3173, -861, 0),
    Vector(-3443, 6098, 0),
    Vector(-4353, 4842, 0),
    Vector(-1083, 3385, 0),
    Vector(-922, 4299, 0),
    Vector(4136, -1753, 0)
}
local nWatchTower_1 = nil
local nWatchTower_2 = nil
local allUnitList = GetUnitList(UnitType.All)
for ____, v in ipairs(allUnitList) do
    if v:GetUnitName() == "#DOTA_OutpostName_North" or v:GetUnitName() == "#DOTA_OutpostName_South" then
        if nWatchTower_1 == nil then
            nWatchTower_1 = v
        else
            nWatchTower_2 = v
        end
    end
end
____exports.nWatchTowerList = {nWatchTower_1, nWatchTower_2}
____exports.nTowerList = {
    TOWER_TOP_1,
    TOWER_MID_1,
    TOWER_BOT_1,
    TOWER_TOP_2,
    TOWER_MID_2,
    TOWER_BOT_2,
    TOWER_TOP_3,
    TOWER_MID_3,
    TOWER_BOT_3,
    TOWER_BASE_1,
    TOWER_BASE_2
}
____exports.nRuneList = {RUNE_POWERUP_1, RUNE_POWERUP_2, RUNE_BOUNTY_1, RUNE_BOUNTY_2}
____exports.nShopList = {
    SHOP_HOME,
    SHOP_SIDE,
    SHOP_SIDE2,
    SHOP_SECRET,
    SHOP_SECRET2
}
____exports.top_power_rune = Vector(-1767, 1233, 0)
____exports.bot_power_rune = Vector(2597, -2014, 0)
____exports.roshan = Vector(-2862, 2260, 0)
____exports.dire_ancient = Vector(5517, 4981, 0)
____exports.radiant_ancient = Vector(-5860, -5328, 0)
____exports.radiant_base = Vector(-7200, -6666, 0)
____exports.dire_base = Vector(7137, 6548, 0)
____exports.GetDistance = function(s, t)
    return GetLocationToLocationDistance(s, t)
end
____exports.GetXUnitsTowardsLocation = function(hUnit, vLocation, nDistance)
    return GetOffsetLocationTowardsTargetLocation(
        hUnit:GetLocation(),
        vLocation,
        nDistance
    )
end
____exports.GetNearestWatchTower = function(bot)
    if GetUnitToUnitDistance(bot, nWatchTower_1) < GetUnitToUnitDistance(bot, nWatchTower_2) then
        return nWatchTower_1
    end
    return nWatchTower_2
end
____exports.GetAllWatchTower = function()
    return ____exports.nWatchTowerList
end
____exports.GetMandatorySpot = function()
    local MandatorySpotRadiant = {RADIANT_MANDATE1, RADIANT_MANDATE2}
    local MandatorySpotDire = {DIRE_MANDATE1, DIRE_MANDATE2}
    if DotaTime() < 2 * 60 then
        return GetTeam() == Team.Radiant and ({RADIANT_MANDATE1}) or ({DIRE_MANDATE2})
    end
    if DotaTime() > 12 * 60 then
        return GetTeam() == Team.Radiant and ({
            RADIANT_MANDATE1,
            RADIANT_MANDATE2,
            RADIANT_T1TOPFALL,
            RADIANT_T1MIDFALL,
            RADIANT_T1BOTFALL
        }) or ({
            DIRE_MANDATE1,
            DIRE_MANDATE2,
            DIRE_T1TOPFALL,
            DIRE_T1MIDFALL,
            DIRE_T1BOTFALL
        })
    end
    return GetTeam() == Team.Radiant and MandatorySpotRadiant or MandatorySpotDire
end
____exports.GetWardSpotWhenTowerFall = function()
    local wardSpot = {}
    do
        local i = 0
        while i < #____exports.nTowerList do
            local tower = GetTower(
                GetTeam(),
                ____exports.nTowerList[i + 1]
            )
            if not tower then
                wardSpot[#wardSpot + 1] = GetTeam() == Team.Radiant and WardSpotTowerFallRadiant[i + 1] or WardSpotTowerFallDire[i + 1]
            end
            i = i + 1
        end
    end
    return wardSpot
end
____exports.GetAggressiveSpot = function()
    local AggressiveDire = {DIRE_AGGRESSIVETOP, DIRE_AGGRESSIVEMID1, DIRE_AGGRESSIVEMID2, DIRE_AGGRESSIVEBOT}
    local AggressiveRadiant = {RADIANT_AGGRESSIVETOP, RADIANT_AGGRESSIVEMID1, RADIANT_AGGRESSIVEMID2, RADIANT_AGGRESSIVEBOT}
    return GetTeam() == Team.Radiant and AggressiveRadiant or AggressiveDire
end
____exports.GetItemWard = function(bot)
    do
        local i = 0
        while i < 9 do
            local item = bot:GetItemInSlot(i)
            if item and (item:GetName() == "item_ward_observer" or item:GetName() == "item_ward_sentry" or item:GetName() == "item_ward_dispenser") then
                return item
            end
            i = i + 1
        end
    end
    return nil
end
____exports.GetAvailableSpot = function(bot)
    local temp = {}
    if DotaTime() < 38 * 60 then
        __TS__ArrayForEach(
            ____exports.GetMandatorySpot(),
            function(____, s)
                if not ____exports.IsCloseToAvailableWard(s) then
                    temp[#temp + 1] = s
                end
            end
        )
    end
    __TS__ArrayForEach(
        ____exports.GetWardSpotWhenTowerFall(),
        function(____, s)
            if not ____exports.IsCloseToAvailableWard(s) then
                temp[#temp + 1] = s
            end
        end
    )
    if DotaTime() > 10 * 60 then
        __TS__ArrayForEach(
            ____exports.GetAggressiveSpot(),
            function(____, s)
                if GetUnitToLocationDistance(bot, s) <= 1200 and not ____exports.IsCloseToAvailableWard(s) then
                    temp[#temp + 1] = s
                end
            end
        )
    end
    return temp
end
____exports.IsCloseToAvailableWard = function(wardLoc)
    local WardList = GetUnitList(UnitType.AlliedWards)
    for ____, ward in ipairs(WardList) do
        if ____exports.IsObserver(ward) and GetUnitToLocationDistance(ward, wardLoc) <= visionRad then
            return true
        end
    end
    return false
end
____exports.IsLocationHaveTrueSight = function(vLocation)
    local WardList = GetUnitList(UnitType.AlliedWards)
    for ____, ward in ipairs(WardList) do
        if ____exports.IsSentry(ward) and GetUnitToLocationDistance(ward, vLocation) <= trueSightRad then
            return true
        end
    end
    local nearbyTowers = GetBot():GetNearbyTowers(1600, false)
    for ____, tower in ipairs(nearbyTowers) do
        if GetUnitToLocationDistance(tower, vLocation) < trueSightRad then
            return true
        end
    end
    return false
end
____exports.GetClosestSpot = function(bot, spotList)
    local closestSpot = nil
    local closestDist = 100000
    for ____, spot in ipairs(spotList) do
        local dist = GetUnitToLocationDistance(bot, spot)
        if dist < closestDist then
            closestDist = dist
            closestSpot = spot
        end
    end
    return closestSpot, closestDist
end
____exports.IsObserver = function(ward)
    return ward:GetUnitName() == "npc_dota_observer_wards"
end
____exports.IsSentry = function(ward)
    return ward:GetUnitName() == "npc_dota_sentry_wards"
end
____exports.GetCampMoveToStack = function(id)
    return CStackLoc[id + 1]
end
____exports.GetCampStackTime = function(camp)
    if camp.cattr.speed == "fast" then
        return 56
    elseif camp.cattr.speed == "slow" then
        return 55
    end
    return 56
end
____exports.IsEnemyCamp = function(camp)
    return camp.team ~= GetTeam()
end
____exports.IsAncientCamp = function(camp)
    return camp.type == "ancient"
end
____exports.IsSmallCamp = function(camp)
    return camp.type == "small"
end
____exports.IsMediumCamp = function(camp)
    return camp.type == "medium"
end
____exports.IsLargeCamp = function(camp)
    return camp.type == "large"
end
____exports.RefreshCamp = function(bot)
    local camps = GetNeutralSpawners()
    local allCampList = {}
    local totalSum = 0
    local count = 0
    for ____, id in ipairs(GetTeamPlayers(GetTeam())) do
        totalSum = totalSum + GetHeroLevel(id)
        count = count + 1
    end
    local averageLevel = totalSum / count
    for ____, aCamp in ipairs(__TS__ObjectValues(camps)) do
        local camp = aCamp
        if (averageLevel <= 7 or bot:GetAttackDamage() <= 80) and not ____exports.IsEnemyCamp(camp) and not ____exports.IsLargeCamp(camp) and not ____exports.IsAncientCamp(camp) then
            allCampList[#allCampList + 1] = {idx = camp.idx, cattr = camp}
        elseif averageLevel <= 11 and not ____exports.IsEnemyCamp(camp) and not ____exports.IsAncientCamp(camp) then
            allCampList[#allCampList + 1] = {idx = camp.idx, cattr = camp}
        elseif averageLevel <= 14 and not ____exports.IsEnemyCamp(camp) then
            allCampList[#allCampList + 1] = {idx = camp.idx, cattr = camp}
        else
            allCampList[#allCampList + 1] = {idx = camp.idx, cattr = camp}
        end
    end
    return allCampList, #allCampList
end
____exports.GetPosition = function(bot)
    if bot.assignedRole then
        return bot.assignedRole
    end
    return 1
end
____exports.IsSpecialFarmer = function(bot)
    return ____exports.GetPosition(bot) == 1
end
____exports.IsShouldFarmHero = function(bot)
    return ____exports.GetPosition(bot) <= 1
end
____exports.IsValidCreep = function(nUnit)
    return nUnit ~= nil and nUnit:IsAlive() and nUnit:GetHealth() < 5000 and (GetBot():GetLevel() > 9 or not nUnit:IsAncientCreep())
end
____exports.HasArmorReduction = function(nUnit)
    return nUnit:HasModifier("modifier_templar_assassin_meld_armor") or nUnit:HasModifier("modifier_item_medallion_of_courage_armor_reduction") or nUnit:HasModifier("modifier_item_solar_crest_armor_reduction") or nUnit:HasModifier("modifier_slardar_amplify_damage")
end
____exports.GetClosestNeutralSpwan = function(bot, availableCampList)
    local minDist = 15000
    local closestCamp = nil
    for ____, camp in ipairs(availableCampList) do
        local dist = GetUnitToLocationDistance(bot, camp.cattr.location)
        if ____exports.IsEnemyCamp(camp) then
            dist = dist * 1.5
        end
        if ____exports.IsTheClosestOne(bot, camp.cattr.location) and dist < minDist and (bot:GetLevel() >= 10 or not ____exports.IsAncientCamp(camp)) then
            minDist = dist
            closestCamp = camp
        end
    end
    return closestCamp
end
____exports.IsTheClosestOne = function(bot, loc)
    local minDist = GetUnitToLocationDistance(bot, loc)
    local closestMember = bot
    for ____, id in ipairs(GetTeamPlayers(GetTeam())) do
        local member = GetTeamMember(id)
        if member and member:IsAlive() and member:GetActiveMode() == BotMode.Farm then
            local memberDist = GetUnitToLocationDistance(member, loc)
            if memberDist < minDist then
                minDist = memberDist
                closestMember = member
            end
        end
    end
    return closestMember == bot
end
____exports.GetNearestCreep = function(creepList)
    if ____exports.IsValidCreep(creepList[1]) then
        return creepList[1]
    end
    return nil
end
____exports.GetMaxHPCreep = function(creepList)
    local maxHP = 0
    local targetCreep = nil
    for ____, creep in ipairs(creepList) do
        if not creep:IsNull() and ____exports.HasArmorReduction(creep) then
            return creep
        end
        if ____exports.IsValidCreep(creep) and creep:GetHealth() > maxHP then
            maxHP = creep:GetHealth()
            targetCreep = creep
        end
    end
    return targetCreep
end
____exports.GetMinHPCreep = function(creepList)
    local minHP = 4000
    local targetCreep = nil
    for ____, creep in ipairs(creepList) do
        if not creep:IsNull() and ____exports.HasArmorReduction(creep) then
            return creep
        end
        if ____exports.IsValidCreep(creep) and creep:GetHealth() < minHP then
            minHP = creep:GetHealth()
            targetCreep = creep
        end
    end
    return targetCreep
end
____exports.FindFarmNeutralTarget = function(creepList)
    local bot = GetBot()
    local botName = bot:GetUnitName()
    local targetCreep = nil
    if ____exports.ConsiderFarmNeutralType[botName] ~= nil then
        local farmType = ____exports.ConsiderFarmNeutralType[botName]()
        if farmType == "nearest" then
            targetCreep = ____exports.GetNearestCreep(creepList)
        elseif farmType == "maxHP" then
            targetCreep = ____exports.GetMaxHPCreep(creepList)
        else
            targetCreep = ____exports.GetMinHPCreep(creepList)
        end
    end
    if HasItem(bot, "item_bfury") or HasItem(bot, "item_maelstrom") or HasItem(bot, "item_mjollnir") or HasItem(bot, "item_radiance") then
        targetCreep = ____exports.GetMaxHPCreep(creepList)
    end
    return targetCreep or ____exports.GetMinHPCreep(creepList)
end
____exports.ConsiderFarmNeutralType = {
    npc_dota_hero_templar_assassin = function() return "nearest" end,
    npc_dota_hero_sven = function() return "nearest" end,
    npc_dota_hero_drow_ranger = function() return "nearest" end,
    npc_dota_hero_phantom_lancer = function() return "nearest" end,
    npc_dota_hero_naga_siren = function() return "maxHP" end,
    npc_dota_hero_viper = function() return "maxHP" end,
    npc_dota_hero_huskar = function() return "maxHP" end,
    npc_dota_hero_phantom_assassin = function()
        local bot = GetBot()
        return HasItem(bot, "item_bfury") and "nearest" or "minHP"
    end,
    npc_dota_hero_medusa = function()
        local bot = GetBot()
        local farmAbility = bot:GetAbilityByName("medusa_split_shot")
        return farmAbility:IsTrained() and "maxHP" or "minHP"
    end,
    npc_dota_hero_luna = function()
        local bot = GetBot()
        local farmAbility = bot:GetAbilityByName("luna_moon_glaive")
        return farmAbility:IsTrained() and "maxHP" or "minHP"
    end,
    npc_dota_hero_tidehunter = function()
        local bot = GetBot()
        local farmAbility = bot:GetAbilityByName("tidehunter_anchor_smash")
        local ultimateAbility = bot:GetAbilityByName("tidehunter_ravage")
        if farmAbility:IsTrained() and ultimateAbility:IsTrained() and bot:GetMana() > ultimateAbility:GetManaCost() + 200 then
            return "maxHP"
        end
        return "minHP"
    end,
    npc_dota_hero_nevermore = function()
        local bot = GetBot()
        return bot:GetMana() > 200 and bot:GetLevel() >= 13 and "maxHP" or "minHP"
    end,
    npc_dota_hero_dragon_knight = function()
        return GetBot():GetAttackRange() > 330 and "maxHP" or "minHP"
    end
}
____exports.GetFarmLaneTarget = function(creepList)
    local bot = GetBot()
    local botName = bot:GetUnitName()
    local targetCreep = nil
    local nearbyAllies = bot:GetNearbyLaneCreeps(1000, false)
    if botName ~= "npc_dota_hero_medusa" and #nearbyAllies > 0 then
        targetCreep = ____exports.GetNearestCreep(creepList)
    end
    if botName == "npc_dota_hero_medusa" then
        targetCreep = ____exports.GetMinHPCreep(creepList)
    end
    return targetCreep or ____exports.GetMaxHPCreep(creepList)
end
____exports.IsSuitableFarmMode = function(mode)
    return mode ~= BotMode.Rune and mode ~= BotMode.Attack and mode ~= BotMode.SecretShop and mode ~= BotMode.SideShop and mode ~= BotMode.DefendAlly and mode ~= BotMode.EvasiveManeuvers
end
____exports.IsModeSuitableToFarm = function(bot)
    local mode = bot:GetActiveMode()
    local botLevel = bot:GetLevel()
    if botLevel <= 8 and (mode == BotMode.PushTowerTop or mode == BotMode.PushTowerMid or mode == BotMode.PushTowerBot or mode == BotMode.Laning) then
        local enemyAncient = GetAncient(GetOpposingTeam())
        if GetUnitToUnitDistance(bot, enemyAncient) > 6300 then
            return false
        end
    end
    if ____exports.IsSpecialFarmer(bot) and botLevel >= 8 and botLevel <= 24 and ____exports.IsSuitableFarmMode(mode) and mode ~= BotMode.Roshan and mode ~= BotMode.TeamRoam and mode ~= BotMode.Laning and mode ~= BotMode.Ward then
        return true
    end
    if ____exports.IsSuitableFarmMode(mode) and mode ~= BotMode.Ward and mode ~= BotMode.Laning and mode ~= BotMode.DefendTowerTop and mode ~= BotMode.DefendTowerMid and mode ~= BotMode.DefendTowerBot and mode ~= BotMode.Assemble and mode ~= BotMode.TeamRoam and mode ~= BotMode.Roshan and botLevel >= 8 then
        return true
    end
    return false
end
____exports.IsTimeToFarm = function(bot)
    if DotaTime() < 5 * 60 or DotaTime() > 90 * 60 then
        return false
    end
    local botName = bot:GetUnitName()
    if bot:GetActiveMode() == BotMode.PushTowerTop or bot:GetActiveMode() == BotMode.PushTowerMid or bot:GetActiveMode() == BotMode.PushTowerBot then
        local enemyAncient = GetAncient(GetOpposingTeam())
        local allyList = bot:GetNearbyHeroes(1400, false, BotMode.None)
        local enemyAncientDistance = GetUnitToUnitDistance(bot, enemyAncient)
        if enemyAncientDistance < 2800 and enemyAncientDistance > 1400 and bot:GetActiveModeDesire() < BotModeDesire.High and #allyList <= 1 then
            return true
        end
        if ____exports.IsShouldFarmHero(bot) then
            if bot:GetActiveModeDesire() < BotModeDesire.Moderate and enemyAncientDistance > 1600 and enemyAncientDistance < 5600 and #allyList <= 1 then
                return true
            end
        end
    end
    if ____exports.ConsiderIsTimeToFarm[botName] ~= nil and ____exports.ConsiderIsTimeToFarm[botName]() then
        return true
    end
    return false
end
____exports.UpdateAvailableCamp = function(bot, preferredCamp, availableCampList)
    if preferredCamp ~= nil then
        do
            local i = 0
            while i < #availableCampList do
                if availableCampList[i + 1].cattr.location == preferredCamp.cattr.location or GetUnitToLocationDistance(bot, availableCampList[i + 1].cattr.location) < 500 then
                    __TS__ArraySplice(availableCampList, i, 1)
                    return availableCampList, nil
                end
                i = i + 1
            end
        end
    end
    return availableCampList, nil
end
local lastCreep = nil
____exports.UpdateCommonCamp = function(creep, availableCampList)
    if lastCreep ~= creep then
        lastCreep = creep
        do
            local i = 0
            while i < #availableCampList do
                if GetUnitToLocationDistance(creep, availableCampList[i + 1].cattr.location) < 500 then
                    __TS__ArraySplice(availableCampList, i, 1)
                    return availableCampList
                end
                i = i + 1
            end
        end
    end
    return availableCampList
end
____exports.GetAroundAllyCount = function(bot, nRadius)
    local nCount = 0
    do
        local i = 1
        while i <= 5 do
            local member = GetTeamMember(i)
            if member and member:IsAlive() and GetUnitToUnitDistance(bot, member) <= nRadius then
                nCount = nCount + 1
            end
            i = i + 1
        end
    end
    return nCount
end
____exports.IsInLaningPhase = function()
    return IsModeTurbo() and DotaTime() < 8 * 60 or DotaTime() < 12 * 60
end
____exports.ConsiderIsTimeToFarm = {}
____exports.ConsiderIsTimeToFarm.npc_dota_hero_luna = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    local currentTime = DotaTime()
    if currentTime > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 23000) then
        return true
    end
    if not HasItem(bot, "item_black_king_bar") and botNetWorth < 18000 then
        return true
    end
    if not HasItem(bot, "item_satanic") and botNetWorth < 28000 then
        if ____exports.GetAroundAllyCount(bot, 1200) <= 2 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_luna = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    local currentTime = DotaTime()
    if currentTime > 15 * 60 and (bot:GetLevel() < 25 or botNetWorth < 22000) then
        return true
    end
    if HasItem(bot, "item_gloves") and not HasItem(bot, "item_hand_of_midas") and bot:GetGold() > 800 then
        return true
    end
    if HasItem(bot, "item_yasha") and not HasItem(bot, "item_manta") and bot:GetGold() > 1000 then
        return true
    end
    if HasItem(bot, "item_hand_of_midas") and ____exports.GetAroundAllyCount(bot, 1200) <= 3 and botNetWorth <= 26000 then
        return true
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_axe = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 7 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_echo_sabre") and botNetWorth < 12000 then
        return true
    end
    if not HasItem(bot, "item_heart") and botNetWorth < 21000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_bloodseeker = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 22000) then
        return true
    end
    if not HasItem(bot, "item_black_king_bar") and botNetWorth < 16000 then
        return true
    end
    if not HasItem(bot, "item_abyssal_blade") and botNetWorth < 26000 then
        if ____exports.GetAroundAllyCount(bot, 1200) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_bristleback = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    local botKills = GetHeroKills(bot:GetPlayerID())
    local botDeaths = GetHeroDeaths(bot:GetPlayerID())
    local allyCount = ____exports.GetAroundAllyCount(bot, 1200)
    if botKills >= botDeaths + 4 and botDeaths <= 3 then
        return false
    end
    if bot:GetLevel() >= 10 and allyCount <= 2 and botNetWorth < 15000 then
        return true
    end
    if bot:GetLevel() >= 20 and allyCount <= 1 and botNetWorth < 21000 then
        return true
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_chaos_knight = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_bristleback
____exports.ConsiderIsTimeToFarm.npc_dota_hero_clinkz = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_templar_assassin
____exports.ConsiderIsTimeToFarm.npc_dota_hero_dragon_knight = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if not HasItem(bot, "item_assault") and botNetWorth < 22000 then
        local allyCount = ____exports.GetAroundAllyCount(bot, 1200)
        if bot:GetAttackRange() > 300 and allyCount <= 2 then
            return true
        end
        if bot:GetMana() > 450 and bot:GetCurrentVisionRange() < 1000 and allyCount < 2 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_drow_ranger = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if bot:GetLevel() >= 6 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if HasItem(bot, "item_mask_of_madness") and botNetWorth < 9999 then
        return true
    end
    if HasItem(bot, "item_blade_of_alacrity") and not HasItem(bot, "item_ultimate_scepter") then
        return true
    end
    if HasItem(bot, "item_shadow_amulet") and not HasItem(bot, "item_invis_sword") and bot:GetGold() > 400 then
        return true
    end
    if HasItem(bot, "item_yasha") and not HasItem(bot, "item_manta") and bot:GetGold() > 1000 then
        return true
    end
    if HasItem(bot, "item_ultimate_scepter") and botNetWorth < 23000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 2 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_huskar = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_hurricane_pike") and botNetWorth < 18000 then
        return true
    end
    if not HasItem(bot, "item_black_king_bar") and botNetWorth < 26000 then
        if ____exports.GetAroundAllyCount(bot, 1100) < 2 then
            return true
        end
    end
    if bot:GetLevel() > 20 and botNetWorth < 23333 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_juggernaut = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_black_king_bar") and botNetWorth < 20000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 2 then
            return true
        end
    end
    if not HasItem(bot, "item_satanic") and botNetWorth < 24000 then
        if ____exports.GetAroundAllyCount(bot, 1000) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_kunkka = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_bristleback
____exports.ConsiderIsTimeToFarm.npc_dota_hero_luna = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_huskar
____exports.ConsiderIsTimeToFarm.npc_dota_hero_mirana = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_templar_assassin
____exports.ConsiderIsTimeToFarm.npc_dota_hero_medusa = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_black_king_bar") and botNetWorth < 16000 then
        return true
    end
    if not HasItem(bot, "item_satanic") and botNetWorth < 28000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_nevermore = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 22000) then
        return true
    end
    if not HasItem(bot, "item_skadi") and botNetWorth < 16000 then
        return true
    end
    if not HasItem(bot, "item_sphere") and botNetWorth < 28000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 2 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_omniknight = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_bristleback
____exports.ConsiderIsTimeToFarm.npc_dota_hero_ogre_magi = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_bristleback
____exports.ConsiderIsTimeToFarm.npc_dota_hero_phantom_assassin = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_desolator") and botNetWorth < 16000 then
        return true
    end
    if not HasItem(bot, "item_black_king_bar") and botNetWorth < 24000 then
        if ____exports.GetAroundAllyCount(bot, 1000) <= 2 then
            return true
        end
    end
    if not HasItem(bot, "item_satanic") and botNetWorth < 26000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_phantom_lancer = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 23000) then
        return true
    end
    if not HasItem(bot, "item_skadi") and botNetWorth < 18000 then
        return true
    end
    if not HasItem(bot, "item_sphere") and botNetWorth < 22000 then
        if ____exports.GetAroundAllyCount(bot, 1300) <= 3 then
            return true
        end
    end
    if not HasItem(bot, "item_heart") and botNetWorth < 26000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_naga_siren = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_phantom_lancer
____exports.ConsiderIsTimeToFarm.npc_dota_hero_razor = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 7 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_black_king_bar") and botNetWorth < 15000 then
        return true
    end
    if not HasItem(bot, "item_satanic") and botNetWorth < 25000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_sand_king = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_bristleback
____exports.ConsiderIsTimeToFarm.npc_dota_hero_slardar = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_bristleback
____exports.ConsiderIsTimeToFarm.npc_dota_hero_legion_commander = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 7 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_echo_sabre") and botNetWorth < 12000 then
        return true
    end
    if not HasItem(bot, "item_heart") and botNetWorth < 21000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_slark = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_invis_sword") and botNetWorth < 18000 then
        return true
    end
    if not HasItem(bot, "item_silver_edge") and botNetWorth < 21000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 2 then
            return true
        end
    end
    if not HasItem(bot, "item_abyssal_blade") and botNetWorth < 25000 then
        if ____exports.GetAroundAllyCount(bot, 1300) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_skeleton_king = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_bristleback
____exports.ConsiderIsTimeToFarm.npc_dota_hero_sven = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_black_king_bar") then
        return true
    end
    if not HasItem(bot, "item_satanic") and botNetWorth < 22000 then
        if ____exports.GetAroundAllyCount(bot, 1000) <= 2 then
            return true
        end
    end
    if not HasItem(bot, "item_greater_crit") and botNetWorth < 26000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_sniper = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if bot:GetLevel() >= 10 and not HasItem(bot, "item_monkey_king_bar") and botNetWorth < 22000 then
        local botKills = GetHeroKills(bot:GetPlayerID())
        local botDeaths = GetHeroDeaths(bot:GetPlayerID())
        if botKills - 3 <= botDeaths and botDeaths > 2 and ____exports.GetAroundAllyCount(bot, 1200) <= 2 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_templar_assassin = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if DotaTime() > 9 * 60 and (bot:GetLevel() < 25 or botNetWorth < 20000) then
        return true
    end
    if not HasItem(bot, "item_black_king_bar") and botNetWorth < 16000 then
        return true
    end
    if not HasItem(bot, "item_hurricane_pike") and botNetWorth < 20000 then
        if ____exports.GetAroundAllyCount(bot, 1300) <= 3 then
            return true
        end
    end
    if not HasItem(bot, "item_satanic") and botNetWorth < 26000 then
        if ____exports.GetAroundAllyCount(bot, 1100) <= 1 then
            return true
        end
    end
    return false
end
____exports.ConsiderIsTimeToFarm.npc_dota_hero_tidehunter = ____exports.ConsiderIsTimeToFarm.npc_dota_hero_sven
____exports.ConsiderIsTimeToFarm.npc_dota_hero_viper = function()
    local bot = GetBot()
    local botNetWorth = bot:GetNetWorth()
    if bot:GetLevel() >= 10 and not HasItem(bot, "item_mjollnir") and botNetWorth < 20000 then
        local botKills = GetHeroKills(bot:GetPlayerID())
        local botDeaths = GetHeroDeaths(bot:GetPlayerID())
        local allyCount = ____exports.GetAroundAllyCount(bot, 1300)
        if botKills - 4 <= botDeaths and botDeaths > 2 and allyCount < 3 then
            return true
        end
        if bot:GetMana() > 650 and bot:GetCurrentVisionRange() < 1000 and allyCount <= 1 then
            return true
        end
    end
    return false
end
return ____exports
