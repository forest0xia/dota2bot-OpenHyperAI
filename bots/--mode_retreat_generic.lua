local bot = GetBot()
local botName = bot:GetUnitName()

if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not string.find(bot:GetUnitName(), "hero") or bot:IsIllusion() then
	return
end

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local targetBot = J.GetProperTarget( bot )

function GetDesire()

	-- if pinged to defend base.
	local ping = Utils.IsPingedToDefenseByAnyPlayer(bot, 3)
	if ping ~= nil then
		return BOT_ACTION_DESIRE_VERYHIGH
	end

	-- 有特殊增益状态不要跑
	if not bot:IsAlive()
	or bot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
	or J.IsHaveAegis( bot )
	or bot:HasModifier("modifier_item_satanic_unholy")
	or bot:HasModifier("modifier_abaddon_borrowed_time")
	or bot:HasModifier("modifier_oracle_false_promise_timer")
	or ( bot:GetCurrentMovementSpeed() < 240 and not bot:HasModifier("modifier_arc_warden_spark_wraith_purge") )
	or (J.GetModifierTime(bot, 'modifier_dazzle_shallow_grave') > 2.5
		or J.GetModifierTime(bot, 'modifier_oracle_false_promise_timer') > 2.5)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local weAreStronger = J.WeAreStronger(bot, 1200)

    if J.GetHP(bot) <= 0.3
	and Utils.RecentlyTookDamage(bot, 3)
	and botName ~= 'npc_dota_hero_huskar'
    then
        return BOT_ACTION_DESIRE_HIGH;
    end

    local mates = J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE);
    local enemies = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE);

	if J.IsLaning( bot ) or bot:GetLevel() <= 10 then
		if not weAreStronger and J.GetHP(bot) < 0.7 then
			if bot:HasModifier('modifier_maledict') -- 防止中了巫医毒还继续吃伤害
			or bot:HasModifier('modifier_dazzle_poison_touch')
			or bot:HasModifier('modifier_slark_essence_shift_debuff') -- 防止不停被小鱼偷属性
			then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end

		-- 别被近战近身
		for _, enemy in pairs(enemies) do
			if enemy ~= nil
			and enemy:GetAttackRange() < 400
			and bot:GetAttackRange() > 400
			and GetUnitToUnitDistance( bot, enemy ) < enemy:GetAttackRange() + 260
			and J.GetHP(enemy) > J.GetHP(bot) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end

	end

	if targetBot ~= nil then
		local distanceToTarget = GetUnitToUnitDistance( bot, targetBot )
		local towers = bot:GetNearbyTowers( 1000, true )
		-- 别被遛进塔
		if towers ~= nil and #towers >= 1
		and distanceToTarget >= towers[1]:GetAttackRange() + 50
		and J.GetHP(targetBot) > 0.3
		and not (bot:IsStunned() or bot:IsHexed() or J.IsInRange(bot, targetBot, bot:GetAttackRange())) then
			return BOT_ACTION_DESIRE_VERYHIGH;
		end
	end

	if weAreStronger then
		return BOT_ACTION_DESIRE_NONE
	elseif #mates < #enemies or (targetBot ~= nil and J.GetHP(targetBot) > J.GetHP(bot)) then
        return BOT_ACTION_DESIRE_HIGH
	end

    if J.GetHP(bot) < 0.2
	and Utils.RecentlyTookDamage(bot, 3)
	and #enemies >= 1
    then
        return BOT_ACTION_DESIRE_VERYHIGH;
    end

	-- if halfway back to fountain
	if bot:DistanceFromFountain() < 5000 and (J.GetHP(bot) < 0.67 or J.GetMP(bot) < 0.3)
	and bot:GetActiveModeDesire() <= BOT_ACTION_DESIRE_HIGH then
        return BOT_ACTION_DESIRE_VERYHIGH;
	end

    return BOT_ACTION_DESIRE_NONE;
end
