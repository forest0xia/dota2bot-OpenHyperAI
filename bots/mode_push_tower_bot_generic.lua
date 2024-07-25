local Utils = require( GetScriptDirectory()..'/FunLib/utils')
local Push = require( GetScriptDirectory()..'/FunLib/aba_push')

local bot = GetBot()
local botName = bot:GetUnitName()

if Utils.BuggyHeroesDueToValveTooLazy[botName] then
    function GetDesire() return Push.GetPushDesire(bot, LANE_BOT) end
    function Think() Push.PushThink(bot, LANE_BOT) end
end