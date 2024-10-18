local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end

local Utils = require( GetScriptDirectory()..'/FunLib/utils')
local Push = require( GetScriptDirectory()..'/FunLib/aba_push')

if Utils.BuggyHeroesDueToValveTooLazy[botName] then
    function GetDesire() return Push.GetPushDesire(bot, LANE_BOT) end
    function Think() Push.PushThink(bot, LANE_BOT) end
end