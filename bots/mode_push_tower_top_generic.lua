local Push = require( GetScriptDirectory()..'/FunLib/aba_push')

function GetDesire()
    return Push.GetPushDesire(GetBot(), LANE_TOP)
end

function Think()
    Push.PushThink(GetBot(), LANE_TOP)
end