local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

if J.GetCoresMaxNetworth() > 12000 then
    local Push = require( GetScriptDirectory()..'/FunLib/aba_push')
    function GetDesire()
        bot.PushLaneDesire[LANE_BOT] = Push.GetPushDesire(bot, LANE_BOT)
        return bot.PushLaneDesire[LANE_BOT]
    end
    function Think() Push.PushThink(bot, LANE_BOT) end
end