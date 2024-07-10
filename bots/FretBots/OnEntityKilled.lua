-- Dependencies
 -- global debug flag
require 'bots.FretBots.Debug'
 -- Global flags
require 'bots.FretBots.Flags'
 -- Data Tables and helper functions
require 'bots.FretBots.DataTables'
-- Awards for bots
require 'bots.FretBots.AwardBonus'
-- Settings
require 'bots.FretBots.Settings'
-- Game State Tracker
require 'bots.FretBots.GameState'

-- local debug flag
local thisDebug = false;
local isDebug = Debug.IsDebug() and thisDebug;
local RADIANT			= 2
local DIRE				= 3

-- Instantiate ourself
if EntityKilled == nil then
	EntityKilled = {}
end

-- Event Listener
function EntityKilled:OnEntityKilled(event)
	-- Get Event Data
	local isHero, victim, killer = EntityKilled:GetEntityKilledEventData(event);
	-- Log Tower/Building kills to track game state
	if victim == nil or victim.stats == nil then return end
	if victim:IsTower() or victim:IsBuilding() then
		GameState:Update(victim)
	end
	-- Drop out for non hero kills
	if not isHero then return end;
	-- Do Table Update
	DataTables:DoDeathUpdate(victim, killer);
	if Settings.difficultyScale >= 0.6 then
		-- print('Enabled bots with bonus on death for diffculty scale = '..Settings.difficultyScale)
		-- Dynamic Adjustment (maybe)
		DynamicDifficulty:Adjust(victim)
		-- Give Awards (maybe)
		AwardBonus:Death(victim)
	end
	-- Sound if it is a player?
	if Settings.isPlayerDeathSound then
		Utilities:RandomSound(BAD_LIST)
	end
	-- Debug Print
	if isDebug then
		DeepPrintTable(victim)
	end
end

-- Event Listener
function EntityKilled:OnCombatlog(event)
	-- print("[BAREBONES] dota_combatlog")
	-- DeepPrintTable(event)
end

-- returns useful data about the kill event
function EntityKilled:GetEntityKilledEventData(event)
	-- Victim
	local victim = EntIndexToHScript(event.entindex_killed);
	-- Killer
	local killer = nil;
	if event.entindex_attacker ~= nil then
		killer = EntIndexToHScript( event.entindex_attacker )
	end
	-- IsHero
	local isHero = false;
	if victim:IsHero() and victim:IsRealHero() and not victim:IsIllusion() and not victim:IsClone() then
		isHero = true;

		if Settings.difficultyScale >= 1 then
			-- print('Enabled human killer gold reduction for diffculty scale = '..Settings.difficultyScale)
			-- 当击杀者是人类玩家时，给与击杀惩罚
			if killer == nil or killer.stats == nil or killer.stats.isBot then return end

			-- TODO: check if victim is SNK or was with SNK's ult available - the first death was not a real death don't modify real player gold.
			if victim:HasModifier("modifier_skeleton_king_reincarnation") or victim:HasModifier("modifier_aegis_regen") then
				-- print("Entity got killed, but not truly dead yet.")
				return
			end

			local goldPerLevel = -26
			local heroLevel = victim:GetLevel()
			-- 基于基础惩罚，死亡单位的等级，和难度来确定惩罚额度
			local goldBounty = math.floor(goldPerLevel * heroLevel/4 * (Settings.difficultyScale * 3) - math.random(1, 30))
			-- 给予击杀者赏金
			killer:ModifyGold(goldBounty, true, DOTA_ModifyGold_HeroKill)
			local msg = 'Balance Killer Award to ' .. PlayerResource:GetPlayerName(killer:GetPlayerID())..' for the kill. Gold: ' .. goldBounty
			Utilities:Print(msg, Utilities:GetPlayerColor(killer:GetPlayerID()))

		end
	end

	return isHero, victim, killer;
end

-- Registers Event Listener
function EntityKilled:RegisterEvents()
	if not Flags.isEntityKilledRegistered then
		ListenToGameEvent('entity_killed', Dynamic_Wrap(EntityKilled, 'OnEntityKilled'), EntityKilled)
		ListenToGameEvent("dota_combatlog", Dynamic_Wrap(EntityKilled, 'OnCombatlog'), EntityKilled)
		Flags.isEntityKilledRegistered = true;
		if true then
			print('EntityKilled Event Listener Registered.')
		end
	end
end

