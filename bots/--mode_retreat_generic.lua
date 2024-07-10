local bot = GetBot()

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
	
	if not bot:IsAlive() or bot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
	   or J.IsHaveAegis( bot )
	   or bot:HasModifier("modifier_item_satanic_unholy")
	   or bot:HasModifier("modifier_abaddon_borrowed_time")
	   or ( bot:GetCurrentMovementSpeed() < 240 and not bot:HasModifier("modifier_arc_warden_spark_wraith_purge") )
	then
		return BOT_ACTION_DESIRE_NONE
	end

    if J.GetHP(bot) <= 0.4
	and (bot:WasRecentlyDamagedByAnyHero(2) or bot:WasRecentlyDamagedByTower(2) or bot:WasRecentlyDamagedByCreep(2))
    then
        return BOT_ACTION_DESIRE_HIGH;
    end
	
    local mates = J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE);
    local enemies = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE);

	if J.WeAreStronger(bot, 1200) then
		return BOT_ACTION_DESIRE_NONE
	elseif #mates < #enemies or (targetBot ~= nil and J.GetHP(targetBot) > J.GetHP(bot)) then
        return BOT_ACTION_DESIRE_HIGH
	end

    if J.GetHP(bot) <= 0.1
	and (bot:WasRecentlyDamagedByAnyHero(2) or bot:WasRecentlyDamagedByTower(2) or bot:WasRecentlyDamagedByCreep(2))
    then
        return BOT_ACTION_DESIRE_VERYHIGH;
    end

    return BOT_ACTION_DESIRE_NONE;
end
