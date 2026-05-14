-- Dependencies
 -- global debug flag
require "bots.FretBots.Debug"
 -- Global flags
require "bots.FretBots.Flags"
 -- Data Tables and helper functions
require "bots.FretBots.DataTables"

-- local debug flag
local thisDebug = false;
local isDebug = Debug.IsDebug() and thisDebug;

-- Instantiate ourself
if EntityHurt == nil then
	EntityHurt = {}
end

-- Event Listener
function EntityHurt:OnEntityHurt(event)
	-- Get Event Data
	isHero = EntityHurt:GetIsHero(event)
	-- Drop out for non hero damage
	if not isHero then return end
	-- Get other event data
	victim, attacker, damage, damageType = EntityHurt:GetEntityHurtEventData(event)
	-- drop out if somehow there is no victim
	if victim == nil then return end
	-- drop out of the victim has no stats table
	if victim.stats == nil then return end
	-- Add damage to the victim's table
	victim.stats.damageTable[damageType] = victim.stats.damageTable[damageType] + damage
	-- Debug Print
	if isDebug then
		-- print('Damage Table for ' .. victim.stats.name)
		DeepPrintTable(victim.stats.damageTable)
	end
end

-- returns true if the victim was a hero
function EntityHurt:GetIsHero(event)
	-- IsHero
	local isHero = false;
	local victim = EntIndexToHScript(event.entindex_killed);
	if victim:IsHero() and victim:IsRealHero() and not victim:IsIllusion() and not victim:IsClone() then
		isHero = true;
	end
	return isHero;
end

-- returns other useful data from the event
function EntityHurt:GetEntityHurtEventData(event)

	local attacker = nil;
	local victim = nil;
	if event.entindex_attacker ~= nil and event.entindex_killed ~= nil then
		attacker = EntIndexToHScript(event.entindex_attacker)
		victim = EntIndexToHScript(event.entindex_killed)
	end
	-- Lifted from Anarchy. Props!
	-- Damage Type
	local damageType = nil;
	if event.entindex_inflictor~=nil then
		inflictor_table=EntIndexToHScript(event.entindex_inflictor):GetAbilityKeyValues()
		if inflictor_table['AbilityUnitDamageType'] == nil then -- assume item damage is magical
			damageType='DAMAGE_TYPE_MAGICAL'
		else
			damageType=tostring(inflictor_table['AbilityUnitDamageType'])
		end
	else
		damageType=tostring('DAMAGE_TYPE_PHYSICAL')
	end
	-- get damage value
	local damage=event.damage
	return victim, attacker, damage, damageType;
end

-- Registers Event Listener
function EntityHurt:RegisterEvents()
	if not Flags.isEntityHurtRegistered then
		ListenToGameEvent("entity_hurt", Dynamic_Wrap(EntityHurt, 'OnEntityHurt'), EntityHurt)
		Flags.isEntityHurtRegistered = true;
		if isDebug then
			print("EntityHurt Event Listener Registered.")
		end
	end
end
