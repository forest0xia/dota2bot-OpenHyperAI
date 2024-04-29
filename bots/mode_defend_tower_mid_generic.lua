local Defend = require( GetScriptDirectory()..'/FunLib/aba_defend')

function GetDesire()
    return Defend.GetDefendDesire(GetBot(), LANE_MID)
end

-- function Think()
--     Defend.DefendThink(GetBot(), LANE_MID)
-- end