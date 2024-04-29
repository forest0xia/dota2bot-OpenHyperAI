local Push = require( GetScriptDirectory()..'/FunLib/aba_push')

function GetDesire()
    return Push.GetPushDesire(GetBot(), LANE_BOT)
end

function Think()
    Push.PushThink(GetBot(), LANE_BOT)
end