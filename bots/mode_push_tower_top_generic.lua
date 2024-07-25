local Utils = require( GetScriptDirectory()..'/FunLib/utils')
local Push = require( GetScriptDirectory()..'/FunLib/aba_push')

local bot = GetBot()
local botName = bot:GetUnitName()

if Utils.BuggyHeroesDueToValveTooLazy[botName] then
    function GetDesire() return Push.GetPushDesire(bot, LANE_TOP) end
    function Think() Push.PushThink(bot, LANE_TOP) end
end