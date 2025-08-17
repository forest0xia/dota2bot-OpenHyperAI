local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Defend = require( GetScriptDirectory()..'/FunLib/aba_defend')

local bot = GetBot()
local botName = bot:GetUnitName()

-- local nH, _ = J.Utils.NumHumanBotPlayersInTeam(GetOpposingTeam())
-- if nH == 0 then

if bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end

function GetDesire() return Defend.GetDefendDesire(bot, LANE_BOT) end
-- function OnEnd() Defend.OnEnd(bot, LANE_BOT) end
-- function Think() return Defend.DefendThink(bot, LANE_BOT) end

-- end