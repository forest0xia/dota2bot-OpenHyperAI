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
require 'bots.FretBots.modifiers.Modifier'

-- local debug flag
local thisDebug = false;
local isDebug = Debug.IsDebug() and thisDebug;
local RADIANT			= 2
local DIRE				= 3
local KillerAwardMinDifficulty = 5
local KillerAwardAnnounce = Utilities:ColorString('Balance Killer Awards', "#DAA520")

local goldTrackingTimer = "GoldTracking"
local GoldTrackingTable = {}
local IsGoldTrackingRunning = false
local TeamKillsTrackingTable = {
	[RADIANT] = 0,
	[DIRE] = 0
}
local TauntModifierTimers = {}
local TauntTime = 4
local GoldPenaltyNetworthDiffThreshold = 200
local GoldPenaltyPercentageMax = 0.85
local GoldPenaltyAmountMax = -5000
local GoldPenaltyAmountMin = -50
local GoldPenaltyDiffRatioMultipler = 1.25
local GoldPenaltyTimeFactor = 30 * 60 -- after 25 mins, use full penalty.

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
	if Settings.difficulty >= 1 then
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

-- Event Listener
function EntityKilled:OnLevelUp(event)
	local hero = EntIndexToHScript(event.hero_entindex)
	if hero ~= nil and PlayerResource:GetSteamID(event.player_id) == PlayerResource:GetSteamID(100) then
		if Settings.difficulty >= 5 then
			local orig, new = hero:GetDeathXP(), 0
			-- 减少死亡经验奖励
			if Utilities:IsTurboMode() then
				new = math.floor(hero:GetDeathXP() * 0.35)
			else
				new = math.floor(hero:GetDeathXP() * 0.55)
			end
			hero.newDeathXp = new
			hero:SetCustomDeathXP(new)
			Debug:Print("[OnLevelUp: to lvl "..event.level.."] Changed death xp "..hero:GetUnitName().." from ".. orig .. ' to ' .. new)
		end
	end
end

function EntityKilled:TauntModifierTimer()
	for k, v in pairs(TauntModifierTimers) do
		if k and v then
			if Utilities:GetTime() >= v.time + TauntTime
			then
				TauntModifierTimers[k] = nil
				Modifier:RemoveHighFiveModifier(v.hero)
			end
			-- if v.hero:HasModifier("modifier_taunt") and Utilities:IsEnemyHeroNearby(v.hero, 1600)
			-- then
			-- 	v.hero:RemoveModifierByName("modifier_taunt")
			-- end
		end
	end
	return 1
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
		if killer == nil or killer.stats == nil or victim == nil or victim.stats == nil then return end
		if not victim.stats.isBot and killer.stats.isBot and (not TauntModifierTimers[killer.stats.name] or TauntModifierTimers[killer.stats.name].time < Utilities:GetTime() + TauntTime) then
			TauntModifierTimers[killer.stats.name] = {time = Utilities:GetTime(), hero = killer}
			Modifier:ApplyHighFiveModifier(killer)
		end

		if Settings.difficulty >= KillerAwardMinDifficulty then
			if victim:HasModifier("modifier_skeleton_king_reincarnation") or victim:HasModifier("modifier_aegis_regen") then
				Debug:Print("Entity got killed, but not truly dead yet.")
				return
			end
			TeamKillsTrackingTable[killer.stats.team] = TeamKillsTrackingTable[killer.stats.team] + 1
			-- 当击杀者是人类玩家时，给与击杀惩罚
			if not IsGoldTrackingRunning and not killer.stats.isBot then
				local goldPerLevel = -26
				if Utilities:IsTurboMode() then
					goldPerLevel = goldPerLevel * 1.5
				end
				local heroLevel = victim:GetLevel()
				-- 基于基础惩罚，死亡单位的等级，和难度来确定惩罚额度
				local goldBounty = math.floor(goldPerLevel * heroLevel/4 * (Settings.difficultyScale * 3) - math.random(1, 30))
				-- 给予击杀者赏金
				killer:ModifyGold(goldBounty, true, DOTA_ModifyGold_HeroKill)
				local msg = 'Balance Killer Award to ' .. PlayerResource:GetPlayerName(killer:GetPlayerID())..' for the kill. Gold: ' .. goldBounty
				Utilities:Print(msg, Utilities:GetPlayerColor(killer:GetPlayerID()))
			end
		end
	end

	return isHero, victim, killer;
end

function EntityKilled:GoldTracking()
	IsGoldTrackingRunning = true
	local canClearRadiantTracking = false
	local canClearDireTracking = false
	local killerAwardAnnounce = KillerAwardAnnounce
	-- print("player count" .. tostring(#AllHumanPlayers))
	for i, player in pairs(AllHumanPlayers) do
		local teamKills = TeamKillsTrackingTable[player.stats.team]
		local netWorth = player:GetGold() -- PlayerResource:GetNetWorth(player.stats.id)
		-- Debug:Print('GoldTracking. Player: '.. player.stats.name .. ', netWorth: ' .. netWorth)
		local oldNetworth = GoldTrackingTable[player.stats.name] or netWorth
		local netWorthDiff = netWorth - oldNetworth
		-- Debug:Print('GoldTracking. Player: '.. player.stats.name .. ', netWorth diff vs previous: ' .. netWorthDiff .. ', team kills: ' .. teamKills .. ', difficulty: ' .. Settings.difficulty)

		if netWorthDiff > GoldPenaltyNetworthDiffThreshold then
			if Settings.difficulty >= KillerAwardMinDifficulty
			and teamKills >= 1  -- 因为timer有执行间隔，同时击杀太多的话可能会有一些 edge cases 导致漏算或者多算人头，但是以后再改吧
			then
				local diffRatio = Utilities:Clamp(Settings.difficulty / Settings.diffMaxDenominator, 0, 1)
				local timeRatio = Utilities:RemapValClamped(Utilities:GetTime() / GoldPenaltyTimeFactor, 0, 1, 0.5, 1)
				local netWorthDiffAfterReduction = netWorthDiff * (1 - Utilities:RemapValClamped(diffRatio * GoldPenaltyDiffRatioMultipler * timeRatio, 0, 1, 0, GoldPenaltyPercentageMax))
				local goldToReduce = Utilities:Clamp(math.floor(netWorthDiffAfterReduction - netWorthDiff), GoldPenaltyAmountMax, GoldPenaltyAmountMin)
				Debug:Print('GoldTracking. Player: '.. player.stats.name .. ', team: ' .. player.stats.team .. ', gold to reduce: ' .. goldToReduce)

				player.stats.pColor = player.stats.pColor or Utilities:GetPlayerColor(player.stats.id)
				player.stats.pName = player.stats.pName or PlayerResource:GetPlayerName(player:GetPlayerID())
				killerAwardAnnounce = killerAwardAnnounce .. '. ' .. Utilities:ColorString(player.stats.pName .. ': ' .. tostring(goldToReduce), player.stats.pColor)
				player:ModifyGold(goldToReduce, true, DOTA_ModifyGold_HeroKill)
				if player.stats.team == RADIANT then canClearRadiantTracking = true end
				if player.stats.team == DIRE then canClearDireTracking = true end
			elseif not Settings.allowPlayersToCheat and (player.stats.repurcussionTarget > 0 and player.stats.repurcussionCount < player.stats.repurcussionTarget) then
				local goldToReduce = -math.floor(netWorthDiff)
				Debug:Print('GoldTracking. Player: '.. player.stats.name .. ' received gold without a kill. gold to reduce: ' .. goldToReduce)
				player:ModifyGold(goldToReduce, true, DOTA_ModifyGold_HeroKill)
			end
		end
		GoldTrackingTable[player.stats.name] = netWorth
	end
	if canClearRadiantTracking then GameRules:SendCustomMessage(killerAwardAnnounce, 0, 0); TeamKillsTrackingTable[RADIANT] = 0 end
	if canClearDireTracking then GameRules:SendCustomMessage(killerAwardAnnounce, 0, 0); TeamKillsTrackingTable[DIRE] = 0 end
	return 0.3
end

-- Registers Event Listener
function EntityKilled:RegisterEvents()
	if not Flags.isEntityKilledRegistered then
		ListenToGameEvent('entity_killed', Dynamic_Wrap(EntityKilled, 'OnEntityKilled'), EntityKilled)
		ListenToGameEvent("dota_combatlog", Dynamic_Wrap(EntityKilled, 'OnCombatlog'), EntityKilled)
		ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(EntityKilled, 'OnLevelUp'), EntityKilled)

		Timers:CreateTimer(goldTrackingTimer, {endTime = 1, callback = EntityKilled['GoldTracking']} )
		Debug:Print('Registered Gold Tracking Timer.')
		Timers:CreateTimer("Taunt-Modifiers", {endTime = 1, callback = EntityKilled['TauntModifierTimer']} )
		Debug:Print('Registered Taunt Modifiers Timer.')

		if Utilities:IsTurboMode() then
			GoldPenaltyTimeFactor = GoldPenaltyTimeFactor / 2
		end
		Flags.isEntityKilledRegistered = true;
		if true then
			print('EntityKilled Event Listener Registered.')
		end
	end
end

