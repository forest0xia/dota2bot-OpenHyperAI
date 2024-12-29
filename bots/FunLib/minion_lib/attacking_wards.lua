local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local U = require(GetScriptDirectory()..'/FunLib/minion_lib/utils')

local X = {}

function X.Think(bot, hMinionUnit)
	local thisMinionAttackRange = bot:GetAttackRange()

	local target = U.GetWeakestHero(thisMinionAttackRange, hMinionUnit)
	if target == nil
	then
		target = U.GetWeakestCreep(thisMinionAttackRange, hMinionUnit)
		if target == nil
		then
			target = U.GetWeakestTower(thisMinionAttackRange, hMinionUnit)
		end
	end

	if target ~= nil and not U.IsNotAllowedToAttack(target)
	then
		hMinionUnit:Action_AttackUnit(target, true)
		return
	end
end

return X