local bot
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local MorphReplicate
local MorphedHero = nil
local botTarget

-- Later Stuff
function X.ConsiderMorphedSpells(target)
    bot = GetBot()
    botTarget = J.GetProperTarget(bot)
    MorphedHero = target


end

return X