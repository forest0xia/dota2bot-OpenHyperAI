--==============================================================================
-- VectorTargeting.lua
-- Server VScript OrderFilter bridge that injects DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION (30)
-- before bot casts of vector-targeted abilities.
--
-- Why this exists:
--   Bot VM (CDOTA_Bot_Script) only exposes Action_UseAbilityOnLocation (OrderType=5)
--   and Action_UseAbilityOnEntity (OrderType=6), neither of which carries a vector
--   direction/endpoint. Without a Server VScript ExecuteOrderFilter, vector abilities
--   cast by bots resolve with zero/default direction vectors.
--
-- Usage:
--   Requires Server VScript context (loaded automatically by FretBots and Buff).
--==============================================================================

local VectorTargeting = {}

local ORDER_CAST_POSITION = DOTA_UNIT_ORDER_CAST_POSITION or 5
local ORDER_CAST_TARGET = DOTA_UNIT_ORDER_CAST_TARGET or 6
local ORDER_VECTOR_TARGET_POSITION = DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION or 30

local TEAM_RADIANT = DOTA_TEAM_GOODGUYS or 2
local TEAM_DIRE = DOTA_TEAM_BADGUYS or 3

local DEFAULT_VECTOR_LENGTH = 450

-- Prevent recursive dispatch when ExecuteOrderFromTable triggers filters
local dispatching = {}
local cachedFountains = {}

local function IsFiniteNumber(x)
    return type(x) == 'number' and x == x and x ~= math.huge and x ~= -math.huge
end

local function IsValidVector(v)
    return v ~= nil and IsFiniteNumber(v.x) and IsFiniteNumber(v.y) and IsFiniteNumber(v.z)
end

local function SafeNorm2D(vec, fallback)
    if vec ~= nil and IsFiniteNumber(vec.x) and IsFiniteNumber(vec.y) then
        local len = math.sqrt(vec.x * vec.x + vec.y * vec.y)
        if len > 0.001 then
            return Vector(vec.x / len, vec.y / len, 0)
        end
    end
    if fallback ~= nil and IsFiniteNumber(fallback.x) and IsFiniteNumber(fallback.y) then
        local flen = math.sqrt(fallback.x * fallback.x + fallback.y * fallback.y)
        if flen > 0.001 then
            return Vector(fallback.x / flen, fallback.y / flen, 0)
        end
    end
    return Vector(1, 0, 0)
end

local function Perp2D(dir)
    local n = SafeNorm2D(dir, Vector(1, 0, 0))
    return Vector(-n.y, n.x, 0)
end

local function Dist2D(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

local function GetTeamFountainPos(team)
    if cachedFountains[team] then
        return cachedFountains[team]
    end
    if Entities and Entities.FindAllByClassname then
        local ok, fountains = pcall(Entities.FindAllByClassname, Entities, 'ent_dota_fountain')
        if ok and fountains then
            for _, f in ipairs(fountains) do
                if f and not f:IsNull() and f:GetTeamNumber() == team then
                    cachedFountains[team] = f:GetAbsOrigin()
                    return cachedFountains[team]
                end
            end
        end
    end
    if team == TEAM_RADIANT then
        cachedFountains[team] = Vector(-7200, -6700, 384)
    elseif team == TEAM_DIRE then
        cachedFountains[team] = Vector(6868, 6306, 384)
    else
        cachedFountains[team] = Vector(0, 0, 128)
    end
    return cachedFountains[team]
end

local function GetEnemyTeam(team)
    if team == TEAM_RADIANT then return TEAM_DIRE end
    if team == TEAM_DIRE then return TEAM_RADIANT end
    return TEAM_DIRE
end

local function FindNearbyUnits(origin, casterTeam, targetTeam, radius, unitType)
    if not FindUnitsInRadius then return {} end
    local ok, units = pcall(
        FindUnitsInRadius,
        casterTeam,
        origin,
        nil,
        radius,
        targetTeam or (DOTA_UNIT_TARGET_TEAM_ENEMY or 2),
        unitType or (DOTA_UNIT_TARGET_HERO or 1),
        DOTA_UNIT_TARGET_FLAG_NO_INVIS or 128,
        FIND_CLOSEST or 1,
        false
    )
    if ok and type(units) == 'table' then
        return units
    end
    return {}
end

local function GetUnitsCentroid(units)
    if not units or #units == 0 then return nil end
    local sx, sy, sz, count = 0, 0, 0, 0
    for _, u in ipairs(units) do
        if u and not u:IsNull() and u:IsAlive() then
            local p = u:GetAbsOrigin()
            if IsValidVector(p) then
                sx = sx + p.x
                sy = sy + p.y
                sz = sz + p.z
                count = count + 1
            end
        end
    end
    if count == 0 then return nil end
    return Vector(sx / count, sy / count, sz / count)
end

local function GetUnitHealthPct(unit)
    if not unit or unit:IsNull() then return 100 end
    if unit.GetHealthPercent then
        return unit:GetHealthPercent()
    end
    local maxHP = unit:GetMaxHealth()
    if maxHP and maxHP > 0 then
        return (unit:GetHealth() / maxHP) * 100
    end
    return 100
end

local function ClampGround(pos, unit, fallbackZ)
    local z = fallbackZ or (pos and pos.z) or 128
    if GetGroundHeight and pos then
        local ok, gz = pcall(GetGroundHeight, pos, unit)
        if ok and IsFiniteNumber(gz) then
            z = gz
        end
    end
    return Vector(pos.x, pos.y, z)
end

local function MakeEndpoint(startPos, dir, length, unit)
    local norm = SafeNorm2D(dir, Vector(1, 0, 0))
    local dist = length or DEFAULT_VECTOR_LENGTH
    local raw = Vector(startPos.x + norm.x * dist, startPos.y + norm.y * dist, startPos.z)
    return ClampGround(raw, unit, startPos.z)
end

--==============================================================================
-- Ability-specific tactical vector endpoint calculators
-- Each returns a world endpoint Vector(x, y, z) from startPos.
--==============================================================================
local VECTOR_HANDLERS = {}

-- Muerta Dead Shot (UNIT_TARGET): fear/ricochet direction away from target toward allies or another enemy
VECTOR_HANDLERS['muerta_dead_shot'] = function(unit, ability, startPos, targetEnt)
    local team = unit:GetTeamNumber()
    local enemies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_ENEMY, 650, DOTA_UNIT_TARGET_HERO)
    for _, e in ipairs(enemies) do
        if e and e ~= targetEnt and not e:IsNull() and e:IsAlive() and Dist2D(e:GetAbsOrigin(), startPos) > 40 then
            -- Ricochet toward a second enemy hero if close
            return MakeEndpoint(startPos, e:GetAbsOrigin() - startPos, 450, unit)
        end
    end
    local allies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_FRIENDLY, 1200, DOTA_UNIT_TARGET_HERO)
    local allyCenter = GetUnitsCentroid(allies)
    if allyCenter and Dist2D(allyCenter, startPos) > 40 then
        return MakeEndpoint(startPos, allyCenter - startPos, 450, unit)
    end
    local unitPos = unit:GetAbsOrigin()
    if Dist2D(unitPos, startPos) > 40 then
        return MakeEndpoint(startPos, unitPos - startPos, 450, unit)
    end
    return MakeEndpoint(startPos, GetTeamFountainPos(team) - startPos, 450, unit)
end
VECTOR_HANDLERS['item_muertas_gun'] = VECTOR_HANDLERS['muerta_dead_shot']

-- Marci Rebound (UNIT_TARGET friendly): launch from ally toward enemy, or toward ally fountain when low HP
VECTOR_HANDLERS['marci_companion_run'] = function(unit, ability, startPos, targetEnt)
    local team = unit:GetTeamNumber()
    local unitHP = GetUnitHealthPct(unit)
    local allyFountain = GetTeamFountainPos(team)

    if unitHP <= 35 then
        return MakeEndpoint(startPos, allyFountain - startPos, 600, unit)
    end

    local enemies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_ENEMY, 950, DOTA_UNIT_TARGET_HERO)
    if #enemies > 0 and not enemies[1]:IsNull() then
        local enemyPos = enemies[1]:GetAbsOrigin()
        if Dist2D(enemyPos, startPos) > 40 then
            return MakeEndpoint(startPos, enemyPos - startPos, 600, unit)
        end
    end

    local unitPos = unit:GetAbsOrigin()
    return MakeEndpoint(startPos, startPos - unitPos, 600, unit)
end

-- Brewmaster Fire Pull (UNIT_TARGET BOTH): drag enemy toward allies/fountain, or pull ally toward fountain
VECTOR_HANDLERS['brewmaster_fire_pull'] = function(unit, ability, startPos, targetEnt)
    local team = unit:GetTeamNumber()
    local allyFountain = GetTeamFountainPos(team)
    if targetEnt and not targetEnt:IsNull() and targetEnt:GetTeamNumber() == team then
        return MakeEndpoint(startPos, allyFountain - startPos, 450, unit)
    end
    local allies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_FRIENDLY, 1200, DOTA_UNIT_TARGET_HERO)
    local allyCenter = GetUnitsCentroid(allies)
    if allyCenter and Dist2D(allyCenter, startPos) > 40 then
        return MakeEndpoint(startPos, allyCenter - startPos, 450, unit)
    end
    return MakeEndpoint(startPos, allyFountain - startPos, 450, unit)
end

-- Enraged Wildkin Hurricane (UNIT_TARGET BOTH): push away if caster/ally injured, else pull enemy toward allies
VECTOR_HANDLERS['enraged_wildkin_hurricane'] = function(unit, ability, startPos, targetEnt)
    local team = unit:GetTeamNumber()
    local allyFountain = GetTeamFountainPos(team)
    if targetEnt and not targetEnt:IsNull() and targetEnt:GetTeamNumber() == team then
        return MakeEndpoint(startPos, allyFountain - startPos, 450, unit)
    end
    if GetUnitHealthPct(unit) <= 40 then
        return MakeEndpoint(startPos, startPos - unit:GetAbsOrigin(), 450, unit)
    end
    local allies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_FRIENDLY, 1200, DOTA_UNIT_TARGET_HERO)
    local allyCenter = GetUnitsCentroid(allies)
    if allyCenter and Dist2D(allyCenter, startPos) > 40 then
        return MakeEndpoint(startPos, allyCenter - startPos, 450, unit)
    end
    return MakeEndpoint(startPos, allyFountain - startPos, 450, unit)
end

-- Tusk Walrus Kick (UNIT_TARGET ENEMY): kick enemy away when retreating, else toward allied team / fountain
VECTOR_HANDLERS['tusk_walrus_kick'] = function(unit, ability, startPos, targetEnt)
    local team = unit:GetTeamNumber()
    if GetUnitHealthPct(unit) <= 40 then
        return MakeEndpoint(startPos, startPos - unit:GetAbsOrigin(), 500, unit)
    end
    local allies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_FRIENDLY, 1200, DOTA_UNIT_TARGET_HERO)
    local allyCenter = GetUnitsCentroid(allies)
    if allyCenter and Dist2D(allyCenter, startPos) > 60 then
        return MakeEndpoint(startPos, allyCenter - startPos, 500, unit)
    end
    return MakeEndpoint(startPos, GetTeamFountainPos(team) - startPos, 500, unit)
end

-- Pangolier Swashbuckle (POINT): dash to startPos, then slash through nearest enemy hero/creep cluster
VECTOR_HANDLERS['pangolier_swashbuckle'] = function(unit, ability, startPos)
    local team = unit:GetTeamNumber()
    local unitPos = unit:GetAbsOrigin()
    local enemies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_ENEMY, 900, DOTA_UNIT_TARGET_HERO)
    local targetCenter = GetUnitsCentroid(enemies)
    if not targetCenter and #enemies > 0 and not enemies[1]:IsNull() then
        targetCenter = enemies[1]:GetAbsOrigin()
    end
    if targetCenter and Dist2D(targetCenter, startPos) > 35 then
        return MakeEndpoint(startPos, targetCenter - startPos, 600, unit)
    end
    local creeps = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_ENEMY, 750, DOTA_UNIT_TARGET_BASIC)
    local creepCenter = GetUnitsCentroid(creeps)
    if creepCenter and Dist2D(creepCenter, startPos) > 35 then
        return MakeEndpoint(startPos, creepCenter - startPos, 600, unit)
    end
    return MakeEndpoint(startPos, startPos - unitPos, 600, unit)
end

-- Dark Seer Wall of Replica (POINT): orient wall broadside across approach/enemy spread
VECTOR_HANDLERS['dark_seer_wall_of_replica'] = function(unit, ability, startPos)
    local team = unit:GetTeamNumber()
    local enemies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_ENEMY, 800, DOTA_UNIT_TARGET_HERO)
    if #enemies >= 2 then
        -- Span along the spread between the two farthest enemy heroes if possible
        local p1 = enemies[1]:GetAbsOrigin()
        local p2 = enemies[#enemies]:GetAbsOrigin()
        if Dist2D(p1, p2) > 40 then
            return MakeEndpoint(startPos, p2 - p1, 450, unit)
        end
    end
    local axis = startPos - unit:GetAbsOrigin()
    if Dist2D(startPos, unit:GetAbsOrigin()) < 40 then
        axis = GetTeamFountainPos(GetEnemyTeam(team)) - GetTeamFountainPos(team)
    end
    return MakeEndpoint(startPos, Perp2D(axis), 450, unit)
end

-- Void Spirit Aether Remnant (POINT): gaze directly through nearest enemy hero from placement pos
VECTOR_HANDLERS['void_spirit_aether_remnant'] = function(unit, ability, startPos)
    local team = unit:GetTeamNumber()
    local enemies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_ENEMY, 650, DOTA_UNIT_TARGET_HERO)
    if #enemies > 0 and not enemies[1]:IsNull() then
        local enemyPos = enemies[1]:GetAbsOrigin()
        if Dist2D(enemyPos, startPos) > 30 then
            return MakeEndpoint(startPos, enemyPos - startPos, 450, unit)
        end
    end
    local axis = startPos - unit:GetAbsOrigin()
    return MakeEndpoint(startPos, axis, 450, unit)
end

-- Disruptor Kinetic Fence (POINT): wall perpendicular between enemy and caster/retreating allies
VECTOR_HANDLERS['disruptor_kinetic_fence'] = function(unit, ability, startPos)
    local team = unit:GetTeamNumber()
    local enemies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_ENEMY, 750, DOTA_UNIT_TARGET_HERO)
    local axis = startPos - unit:GetAbsOrigin()
    if #enemies > 0 and not enemies[1]:IsNull() then
        local enemyPos = enemies[1]:GetAbsOrigin()
        local allies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_FRIENDLY, 1000, DOTA_UNIT_TARGET_HERO)
        local allyCenter = GetUnitsCentroid(allies) or unit:GetAbsOrigin()
        if Dist2D(enemyPos, allyCenter) > 40 then
            axis = enemyPos - allyCenter
        end
    end
    return MakeEndpoint(startPos, Perp2D(axis), 450, unit)
end

-- Windrunner Gale Force (POINT): push pursuing enemies away when injured, else push toward allies
VECTOR_HANDLERS['windrunner_gale_force'] = function(unit, ability, startPos)
    local team = unit:GetTeamNumber()
    local allyFountain = GetTeamFountainPos(team)
    local allies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_FRIENDLY, 1000, DOTA_UNIT_TARGET_HERO)
    local anyLowAlly = GetUnitHealthPct(unit) <= 45
    if not anyLowAlly then
        for _, a in ipairs(allies) do
            if a and not a:IsNull() and GetUnitHealthPct(a) <= 45 then
                anyLowAlly = true
                break
            end
        end
    end
    if anyLowAlly then
        return MakeEndpoint(startPos, GetTeamFountainPos(GetEnemyTeam(team)) - startPos, 500, unit)
    end
    local allyCenter = GetUnitsCentroid(allies)
    if allyCenter and Dist2D(allyCenter, startPos) > 40 then
        return MakeEndpoint(startPos, allyCenter - startPos, 500, unit)
    end
    return MakeEndpoint(startPos, allyFountain - startPos, 500, unit)
end

-- Tinker Deploy Turrets (POINT): aim cone toward nearest enemy cluster
VECTOR_HANDLERS['tinker_deploy_turrets'] = function(unit, ability, startPos)
    local team = unit:GetTeamNumber()
    local enemies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_ENEMY, 900, DOTA_UNIT_TARGET_HERO)
    local targetCenter = GetUnitsCentroid(enemies)
    if targetCenter and Dist2D(targetCenter, startPos) > 35 then
        return MakeEndpoint(startPos, targetCenter - startPos, 400, unit)
    end
    return MakeEndpoint(startPos, startPos - unit:GetAbsOrigin(), 400, unit)
end

-- Clinkz Burning Army / Broodmother Sticky Snare / Magnus Greater Shockwave / Shadow Shaman Serpentine
VECTOR_HANDLERS['clinkz_burning_army'] = function(unit, ability, startPos)
    local axis = startPos - unit:GetAbsOrigin()
    return MakeEndpoint(startPos, Perp2D(axis), 450, unit)
end

VECTOR_HANDLERS['broodmother_sticky_snare'] = function(unit, ability, startPos)
    local axis = startPos - unit:GetAbsOrigin()
    return MakeEndpoint(startPos, Perp2D(axis), 450, unit)
end

VECTOR_HANDLERS['magnataur_greater_shockwave'] = function(unit, ability, startPos)
    local team = unit:GetTeamNumber()
    local enemies = FindNearbyUnits(startPos, team, DOTA_UNIT_TARGET_TEAM_ENEMY, 900, DOTA_UNIT_TARGET_HERO)
    local targetCenter = GetUnitsCentroid(enemies)
    if targetCenter and Dist2D(targetCenter, startPos) > 35 then
        return MakeEndpoint(startPos, targetCenter - startPos, 500, unit)
    end
    return MakeEndpoint(startPos, startPos - unit:GetAbsOrigin(), 500, unit)
end

VECTOR_HANDLERS['shadow_shaman_serpentine'] = function(unit, ability, startPos)
    local axis = startPos - unit:GetAbsOrigin()
    return MakeEndpoint(startPos, Perp2D(axis), 450, unit)
end

--==============================================================================
-- Server Order Filter
--==============================================================================
function VectorTargeting:OrderFilter(filterTable)
    if not filterTable then return true end

    local orderType = filterTable.order_type
    if orderType ~= ORDER_CAST_POSITION and orderType ~= ORDER_CAST_TARGET then
        return true
    end

    local abilityIndex = filterTable.entindex_ability
    if not abilityIndex or abilityIndex <= 0 then
        return true
    end

    local ability = EntIndexToHScript and EntIndexToHScript(abilityIndex)
    if not ability or ability:IsNull() or not ability.GetAbilityName then
        return true
    end

    local abilityName = ability:GetAbilityName()
    local handler = VECTOR_HANDLERS[abilityName]
    if not handler then
        return true
    end

    local units = filterTable.units
    local unitIndex = units and (units['0'] or units[0] or units[1])
    if not unitIndex or unitIndex <= 0 then
        return true
    end

    local unit = EntIndexToHScript(unitIndex)
    if not unit or unit:IsNull() then
        return true
    end

    -- Never alter vector-target input from real human players
    local playerID = -1
    if unit.GetPlayerOwnerID then
        playerID = unit:GetPlayerOwnerID()
    elseif filterTable.issuer_player_id_const ~= nil then
        playerID = filterTable.issuer_player_id_const
    end

    if playerID ~= nil and playerID >= 0 and PlayerResource and PlayerResource.IsFakeClient then
        if not PlayerResource:IsFakeClient(playerID) then
            return true
        end
    elseif filterTable.issuer_player_id_const ~= nil and filterTable.issuer_player_id_const >= 0
        and PlayerResource and PlayerResource.IsFakeClient then
        if not PlayerResource:IsFakeClient(filterTable.issuer_player_id_const) then
            return true
        end
    end

    local dispatchKey = tostring(unitIndex) .. ':' .. tostring(abilityIndex)
    if dispatching[dispatchKey] then
        return true
    end

    local targetEnt = nil
    local startPos = nil
    if orderType == ORDER_CAST_TARGET and filterTable.entindex_target and filterTable.entindex_target > 0 then
        targetEnt = EntIndexToHScript(filterTable.entindex_target)
        if targetEnt and not targetEnt:IsNull() then
            startPos = targetEnt:GetAbsOrigin()
        end
    end
    if not IsValidVector(startPos) then
        startPos = Vector(
            filterTable.position_x or 0,
            filterTable.position_y or 0,
            filterTable.position_z or 0
        )
    end

    local okCalc, endPos = pcall(handler, unit, ability, startPos, targetEnt)
    if not okCalc or not IsValidVector(endPos) or Dist2D(startPos, endPos) < 20 then
        endPos = MakeEndpoint(startPos, startPos - unit:GetAbsOrigin(), DEFAULT_VECTOR_LENGTH, unit)
    end

    if ExecuteOrderFromTable then
        dispatching[dispatchKey] = true
        local vectorOrder = {
            UnitIndex = unitIndex,
            OrderType = ORDER_VECTOR_TARGET_POSITION,
            AbilityIndex = abilityIndex,
            Position = endPos,
            Queue = false,
        }
        if orderType == ORDER_CAST_TARGET and filterTable.entindex_target and filterTable.entindex_target > 0 then
            vectorOrder.TargetIndex = filterTable.entindex_target
        end
        local okExec, errExec = pcall(ExecuteOrderFromTable, vectorOrder)
        dispatching[dispatchKey] = nil
        if not okExec then
            print('[VectorTargeting] ExecuteOrderFromTable error (' .. tostring(abilityName) .. '): ' .. tostring(errExec))
        end
    end

    return true
end

function VectorTargeting:Initialize()
    if _G.__OHA_VECTOR_FILTER_REGISTERED then
        return
    end
    if GameRules and GameRules.GetGameModeEntity then
        local mode = GameRules:GetGameModeEntity()
        if mode and mode.SetExecuteOrderFilter and Dynamic_Wrap then
            mode:SetExecuteOrderFilter(Dynamic_Wrap(VectorTargeting, 'OrderFilter'), VectorTargeting)
            _G.__OHA_VECTOR_FILTER_REGISTERED = true
            print('[VectorTargeting] Server ExecuteOrderFilter registered for bot vector-targeted abilities.')
        end
    end
end

return VectorTargeting
