require 'bots.FretBots.Debug'
require 'bots.FretBots.DataTables'
require 'bots.FretBots.Settings'
require 'bots.FretBots.modifiers.modifier_seasonal_party_hat'

if Modifier == nil then
	Modifier = {}
end

function Modifier:ApplyGlobalModifier(unit)
    if unit and unit:IsAlive() and not unit:HasModifier("modifier_seasonal_party_hat") and unit.stats then
        unit:AddNewModifier(unit, nil, "modifier_seasonal_party_hat", {})
		Debug:Print('Added modifier to:'..unit.stats.name)
    end
end

function Modifier:ApplySpecialModifiers(unit)
    if unit and unit:IsAlive() and unit.stats then
        if not unit:HasModifier("modifier_special_bonus_cooldown_reduction") then
            unit:AddNewModifier(unit, nil, "modifier_special_bonus_cooldown_reduction", {})
            Debug:Print('Added modifier_special_bonus_cooldown_reduction to:'..unit.stats.name)
        end
        if not unit:HasModifier("modifier_special_bonus_respawn_reduction") then
            unit:AddNewModifier(unit, nil, "modifier_special_bonus_respawn_reduction", {})
            Debug:Print('Added modifier_special_bonus_respawn_reduction to:'..unit.stats.name)
        end
        -- if not unit:HasModifier("modifier_seasonal_party_hat") then
        --     unit:AddNewModifier(unit, nil, "modifier_seasonal_party_hat", {})
        --     Debug:Print('Added modifier_seasonal_party_hat to:'..unit.stats.name)
        -- end
    end
end

function Modifier:ApplyHighFiveModifier(unit)
    if unit and unit:IsAlive() and unit.stats then
        if not unit:HasModifier("modifier_plus_high_five_requested") then
            unit:AddNewModifier(unit, nil, "modifier_plus_high_five_requested", {})
            Debug:Print('Added modifier_plus_high_five_requested to:'..unit.stats.name)
        end
        if not unit:HasModifier("modifier_taunt") and not Utilities:IsEnemyHeroNearby(unit, 1600) then
            unit:AddNewModifier(unit, nil, "modifier_taunt", {})
            Debug:Print('Added modifier_taunt to:'..unit.stats.name)
        end
    end
end

function Modifier:RemoveHighFiveModifier(unit)
    if unit and unit.stats then
        if unit:HasModifier("modifier_plus_high_five_requested") then
            unit:RemoveModifierByName("modifier_plus_high_five_requested")
        end
        if unit:HasModifier("modifier_taunt") then
            unit:RemoveModifierByName("modifier_taunt")
        end
    end
end

function Modifier:Initialize()
    for team = 2, 3 do
		for _, unit in pairs(AllBots[team]) do
            if unit ~= nil and unit.stats ~= nil then
                Modifier:ApplySpecialModifiers(unit)
            end
        end
    end
	Debug:Print('Registering modifier event for bots.')
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(Modifier, 'OnNPCSpawned'), Modifier)
end

function Modifier:OnNPCSpawned(event)
    local spawnedUnit = EntIndexToHScript(event.entindex)
    Modifier:ApplySpecialModifiers(spawnedUnit)
end
