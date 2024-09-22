if modifier_seasonal_party_hat == nil then modifier_seasonal_party_hat = class({}) end

function modifier_seasonal_party_hat:IsHidden()
    return false -- Whether the modifier icon will show on the unit.
end

function modifier_seasonal_party_hat:IsDebuff() return false end
function modifier_seasonal_party_hat:IsPurgeException() return false end

function modifier_seasonal_party_hat:IsPurgable()
    return false -- The modifier cannot be dispelled.
end

function modifier_seasonal_party_hat:IsPermanent()
    return true -- The modifier is permanent.
end

function modifier_seasonal_party_hat:RemoveOnDeath()
    return false -- The modifier persists through death.
end

function modifier_seasonal_party_hat:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_seasonal_party_hat:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, -- For attack damage
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,      -- For spell damage
    }
    return funcs
end

function modifier_seasonal_party_hat:GetModifierBaseDamageOutgoing_Percentage(params)
    return 100 or 0 -- Increases attack damage by 100%
end

function modifier_seasonal_party_hat:GetModifierSpellAmplify_Percentage(params)
    return 100 or 0 -- Increases spell damage by 100%
end
