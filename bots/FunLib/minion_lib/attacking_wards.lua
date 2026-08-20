local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local U = require(GetScriptDirectory()..'/FunLib/minion_lib/utils')

local X = {}

function X.Think(bot, hMinionUnit)
	-- Use the WARD's own attack range, not the hero's. A stationary ward can only
	-- hit targets within its reach; the Shaman's range (inflated by Dragon Lance /
	-- Hurricane Pike / talents) would make it pick targets it can never attack.
	local thisMinionAttackRange = hMinionUnit:GetAttackRange()

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
		-- bOnce = false: sustained attack (a stationary ward should keep hitting
		-- a tower/creep, not fire a single shot every think tick).
		hMinionUnit:Action_AttackUnit(target, false)
		return
	end
end

return X
