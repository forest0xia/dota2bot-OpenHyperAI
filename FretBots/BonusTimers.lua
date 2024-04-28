-- Registers a timer function that's used to do things at certain points during the game

-- This registers the Timer helpers
require 'FretBots.Timers'
 -- global debug flag
require 'FretBots.Debug'
-- DataTables and associated globals
require 'FretBots.DataTables'
-- Settings
require 'FretBots.Settings'
-- Utilities
require 'FretBots.Utilities'
-- Award functions
require 'FretBots.AwardBonus'
-- Flags for tracking status
require 'FretBots.Flags'
-- Neutral Item Helpers
require 'FretBots.NeutralItems'

-- local debug flag
local thisDebug = false;
local isDebug = Debug.IsDebug() and thisDebug;
local isDebugChat = isDebug and true

-- announce bonuses to chat?
local isChat = true;

-- Instantiate ourself
if BonusTimers == nil then
	BonusTimers = {}
end

-- timer names
local names =
{
	neutralItemFindTimer = 'NeutralItemFindTimer',
	perMinuteTimer = 'PerMinuteTimer',
	neutralItemDoleTimer = 'NeutralItemDoleTimer',
}
local inits =
{
	neutralItemFindTimer  = false,
	perMinuteTimer        = false,
	neutralItemDoleTimer  = false
}

-- Internal flags for flagging if stuff has been done
-- set to true if any given tier has been awarded
local tiersAwarded = {false,false,false,false,false}
-- current award instance (irrespective of offset). used to index timings
local award = 1
-- default neutral timer find interval
local neutralFindInterval = 1
-- default neutral timer dole interval
local neutralDolenterval = 10
-- max tier
local maxTier = 5
-- Per Minute Timer Interval
local perMinuteTimerInterval = 60
-- amount of neutrals found per tier
local tierAwards = {0,0,0,0,0}
-- current neutral items available to dole
NeutralStash = {{},{},{},{},{}}
-- all items ever found
AwardedNeutrals = {}

-- master table (items don't get removed from this one)
local masterNeutralTable = dofile('Fretbots.SettingsNeutralItemTable')

-- returns true if we've found every item we can
function BonusTimers:IsFindingDone()
	for i, count in ipairs(tierAwards) do
		if count < Settings.neutralItems.maxPerTier[i] then
			return false
		end
	end
	return true
end

-- Awards neutral items to bots based on Settings
function BonusTimers:NeutralItemFindTimer()
	local gameTime = Utilities:GetAbsoluteTime()
	-- Don't do anything if time is negative
	if gameTime < 0 then return math.ceil(gameTime * -1) end
	-- Stop if we've given all bots tier 5 items
	if BonusTimers:IsFindingDone() then
		Timers:RemoveTimer(names.neutralItemFindTimer)
		Utilities:Print('NeutralItemFindTimer done.  Unregistering.', MSG_CONSOLE_GOOD)
		return nil
	end
	-- Logic to do things here, we'll use this method primarily for giving neutrals to bots
	local interval = 0
	-- loop over all bots
	for _, bot in pairs(Bots) do
		-- if time is greater than stats.neutralTiming, we try to award an item
		-- negative numbers disable the award
		local tier =  bot.stats.neutralsFound + 1
		if gameTime > bot.stats.neutralTiming and
			 bot.stats.neutralTiming >= 0 and
			 bot.stats.neutralTiming ~= nil and
			 tierAwards[tier] < Settings.neutralItems.maxPerTier[tier] then
			-- Register NeutralItemDoleTimer (This will only happen once)
			------ 7.33 Edits - This is now unnecessary
			----if not inits.neutralItemDoleTimer then
			----  print('Item dropped! Registering NeutralItemDoleTimer.')
			----  Timers:CreateTimer(names.neutralItemDoleTimer, {callback =  BonusTimers['NeutralItemDoleTimer']} )
			----  inits.neutralItemDoleTimer = true
			----end
			------ End 7.33 Edits
			-- Increment tiers 'found' for this bot
			bot.stats.neutralsFound = tier
			-- Check if tier still has items to award
			if tierAwards[tier] < Settings.neutralItems.maxPerTier[tier] then
				-- increment awards
				tierAwards[tier] = tierAwards[tier] + 1
				-- Get the neediest bot
				local neediest = NeutralItems:NeediestBotForToken(tier)
				------ 7.33 Edits - This is now obsolete
				------ Based on settings, award this bot a suitable item directly, or
				------ just roll one randomly and leave it for the doler
				----local item
				----if Settings.neutralItems.assignRandomly then
				----  item = NeutralItems:SelectRandomItem(tier)
				------ harder: just get the bot an item we know they like
				----else
				----  item = NeutralItems:SelectRandomItem(tier, neediest)
				----end
				------ End 7.33 Edits
				-- Get the table for this tier for this bot
				local items = NeutralItems:GetTokenTableForTier(tier)
				-- sanity check
				if items ~= nil then
					-- Debug
					for _, item in ipairs(items) do
						local desire = NeutralItems:GetBotDesireForItem(neediest, item)
						Debug:Print(neediest.stats.name..': '..' item: '..item.realName.. ' : '..desire)
					end
					-- Select the best item
					local bestItem
					local bestDesire = 0
					for _, item in ipairs(items) do
						if bestItem == nil then
							bestItem = item
							bestDesire = NeutralItems:GetBotDesireForItem(neediest, item)
							Debug:Print(neediest.stats.name..': '..item.realName..': '..tostring(bestDesire))
						else
							local desire = NeutralItems:GetBotDesireForItem(neediest, item)
							Debug:Print(neediest.stats.name..': '..item.realName..': '..tostring(desire))
							if desire > bestDesire then
								bestItem = item
								bestDesire = desire
							end
						end
					end
					-- Give it
					NeutralItems:GiveToUnit(neediest, bestItem)
					-- perhaps announce the item has been found
					if Settings.neutralItems.announce then
						Utilities:AnnounceNeutral(neediest, bestItem, MSG_NEUTRAL_FIND)
					end
					-- put the item in the stash
					--table.insert(NeutralStash[tier], item)
					-- add the item to the list of awarded items
					-- ##TODO: Query returns to make sure we only put items in the stash
					-- that we created, rather than items the bot may have picked up
					-- on its own in game.  This would probably have holes anyway, since
					-- we can't tell items apart
					--table.insert(AwardedNeutrals, item)
				end
				-- Set time for next find
				NeutralItems:SetBotFindTier(bot, tier + 1)
			end
			-- Close the tier if we hit the limit
			if tierAwards[tier] >= Settings.neutralItems.maxPerTier[tier] then
				NeutralItems:CloseBotFindTier(tier)
			end
		end
	end
	return neutralFindInterval
end

-- converts an ingame name into an item object.
function BonusTimers:GetItemFromName(name)
	for _, item in ipairs(masterNeutralTable) do
		if item.name == name then return item end
	end
end

-- Manages giving items to bots from the stash
function BonusTimers:NeutralItemDoleTimer()
	repeat
		-- Do we have something to do?
		local itemToDole = BonusTimers:GetNextItemToDole()
		if itemToDole ~= nil then
			-- Items in stash only get one chance to be doled, so remove it whether
			-- we actually assign it or not
			BonusTimers:RemoveItemFromStash(itemToDole)
			-- try to find a bot that wants it
			for _, bot in ipairs(Bots) do
				-- Bot wants?
				local botWants, newDesire, currentDesire = NeutralItems:DoesBotPreferItem(bot, itemToDole)
				if botWants then

					--Debug:Print(bot.stats.name..': Wants '..itemToDole.realName..': '..newDesire..', '..currentDesire)
					-- update assignment table
					bot.stats.assignedNeutral = itemToDole
					-- Give item, check for replacement
					local replacedItemName = NeutralItems:GiveToUnit(bot, itemToDole)
					-- if bot had an item . . .
					if replacedItemName ~= nil then
						local item = BonusTimers:GetItemFromName(replacedItemName)
						-- announce, maybe
						if Settings.neutralItems.announce then
							--##Temporarily disabled because it's annoying
							--Utilities:AnnounceNeutral(bot, item, MSG_NEUTRAL_RETURN)
						end
						-- return old item to stash
						table.insert(NeutralStash[item.tier], item)
					end
					-- announce item taking, maybe
					if Settings.neutralItems.announce then
						Utilities:AnnounceNeutral(bot, itemToDole, MSG_NEUTRAL_TAKE)
					end
					break
				end
			end
		end
	until itemToDole == nil
	return neutralDolenterval
end

-- Returns the next item to dole, or nil
function BonusTimers:GetNextItemToDole()
	for tier = maxTier, 1, -1 do
		if #NeutralStash[tier] > 0 then
			return NeutralStash[tier][1]
		end
	end
end

-- removes a specific item from the stash
function BonusTimers:RemoveItemFromStash(item)
	for _, tierStash in ipairs(NeutralStash) do
		for i, stashItem in ipairs(tierStash) do
			if stashItem == item then
				table.remove(tierStash,i)
				return
			end
		end
	end
end

-- timer for adjusting gpm/xpm
function BonusTimers:PerMinuteTimer()
	-- inform we've registered
	if not inits.perMinuteTimer then
		print('PerMinuteTimer method registered')
		inits.perMinuteTimer = true
	end
	-- if no bots, unregister
	if Bots == nil then
		Timers:RemoveTimer(names.perMinuteTimer)
		return nil
	end
	local isApply = false

	-- Get GPM/XPM tables
	local gpm, xpm = DataTables:GetPerMinuteTables()
	-- loop over all bots
	for _, bot in pairs(Bots) do
		if bot ~= nil then
			-- GPM bonus
			local goldBonus, xpBonus = AwardBonus:GetPerMinuteBonus(bot, gpm, xpm)
			if goldBonus > 0 then
				AwardBonus:gold(bot, goldBonus)
			end
			if xpBonus > 0 then
				AwardBonus:Experience(bot, xpBonus)
			end
		end
	end
	-- return interval
	return perMinuteTimerInterval
end

-- One time bonus given to bots at game start
function BonusTimers:GameStartBonus()
	local msg = 'Bots given starting bonuses:'
	local awarded = false
	for _, bot in pairs(Bots) do
		-- HP regen
		bot:SetBaseHealthRegen(3 * Settings.difficultyScale)
		-- Mana regen
		bot:SetBaseManaRegen(3 * Settings.difficultyScale)
		-- bot:SetHPRegenGain(5 * Settings.difficultyScale)
		-- bot:SetManaRegenGain(5 * Settings.difficultyScale)
	end
	-- Gold
	if Settings.gameStartBonus.gold  > 0 then
		msg = msg .. ' Gold: '.. Settings.gameStartBonus.gold
		awarded = true
		for _, bot in pairs(Bots) do
			AwardBonus:gold(bot, Settings.gameStartBonus.gold)
		end
	end
	-- Armor
	if Settings.gameStartBonus.armor  > 0 then
		msg = msg .. ' Armor: '.. Settings.gameStartBonus.armor
		awarded = true
		for _, bot in pairs(Bots) do
			AwardBonus:armor(bot, Settings.gameStartBonus.armor)
		end
	end
	-- magicResist
	if Settings.gameStartBonus.magicResist  > 0 then
		msg = msg .. ' Magic Resist: '.. Settings.gameStartBonus.magicResist
		awarded = true
		for _, bot in pairs(Bots) do
			AwardBonus:magicResist(bot, Settings.gameStartBonus.magicResist)
		end
	end
	-- Levels
	if Settings.gameStartBonus.levels  > 0 then
		msg = msg .. ' Levels: '.. Settings.gameStartBonus.levels
		awarded = true
		for _, bot in pairs(Bots) do
			AwardBonus:levels(bot, Settings.gameStartBonus.levels)
		end
	end
	-- Levels
	if Settings.gameStartBonus.levels  > 0 then
		msg = msg .. ' Levels: '.. Settings.gameStartBonus.levels
		awarded = true
		for _, bot in pairs(Bots) do
			AwardBonus:levels(bot, Settings.gameStartBonus.levels)
		end
	end
	-- Stats
	if Settings.gameStartBonus.stats  > 0 then
		msg = msg .. ' Stats: '.. Settings.gameStartBonus.stats
		awarded = true
		for _, bot in pairs(Bots) do
			AwardBonus:stats(bot, Settings.gameStartBonus.stats)
		end
	end
	-- neutral
	if Settings.gameStartBonus.neutral  > 0 then
		msg = msg .. ' Neutral: '.. Settings.gameStartBonus.neutral
		awarded = true
		for _, bot in pairs(Bots) do
			AwardBonus:neutral(bot, Settings.gameStartBonus.neutral)
		end
	end
	if awarded then
		Utilities:Print(msg, MSG_WARNING, ATTENTION)
	end
end

-- registers the bonus timner listeners
function BonusTimers:Register()
	-- Game start bonus - Special case that happens one time when BonusTimers are registered
	BonusTimers:GameStartBonus()
	-- Register NeutralItemFindTimer
	if not inits.neutralItemFindTimer then
		if isDebug then
			DeepPrintTable(Settings.neutralItems)
		end
		print('Registering NeutralItemFindTimer.')
		Timers:CreateTimer(names.neutralItemFindTimer, {callback =  BonusTimers['NeutralItemFindTimer']} )
		inits.neutralItemFindTimer = true
	end
	-- Register per minute timer (first executed one minute after game start so we're
	-- not dividing by a decimal and inflating GPM/XPM
	if not inits.perMinuteTimer then
		print('Registering PerMinuteTimer.')
		Timers:CreateTimer(names.perMinuteTimer, {endTime = perMinuteTimerInterval, callback =  BonusTimers['PerMinuteTimer']} )
		inits.perMinuteTimer = true
	end
end

-- OnGameRulesStateChange callback -- registers timers we only want to run after the game starts
function BonusTimers:OnGameRulesStateChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		BonusTimers:Register()
	end
end

-- Registers timers (or listens to events that register timers)
function BonusTimers:Initialize()
	if not Flags.isBonusTimersInitialized then
		-- Determine where we are
		local state =  GameRules:State_Get()
		-- various ways to implement based on game state
		-- Are we entering this after the horn blew?
		if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			 -- then immediately register listeners
			 BonusTimers:Register()
			 print('Game already in progress.  Registering BonusTimers.')
		-- is game over? Return if so
		elseif state == DOTA_GAMERULES_STATE_POST_GAME or state == DOTA_GAMERULES_STATE_DISCONNECT then
			return
		-- otherwise we are pre-horn and should register a game state listener
		-- that will register once the horn sounds
		else
			ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( BonusTimers, "OnGameRulesStateChange" ), self)
			print('Game not in progress.  Registering BonusTimer GameState Listener.')
		end
		Flags.isBonusTimersInitialized = true
	end
end

