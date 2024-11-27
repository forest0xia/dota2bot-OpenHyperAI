	-- Default settings table, returns the table, so use
	-- local <x> = require 'SettingsDefault' to include in another file.

	-- default settings here, override only what you change in Initialize()
	local settings =
	{
		-- Name of the settings group (difficulty)
		name = 'Standard',
		-- Printed to chat when voting
		description = "Bots are 1 full tier ahead on neutrals, and receive moderate death bonuses.",
		-- Used to track votes of the settings
		votes = 0,
		-- Color in which to print to chat
		color = '#00ff00',
		-- Change this to select the default difficulty (chosen if
		-- no one votes during difficulty voting time)
		defaultDifficulty = 'standard',
		-- game state in which voting should end
		voteEndState = DOTA_GAMERULES_STATE_PRE_GAME,
		-- voting ends when this amount of time has passed since voting began
		voteEndTime = 40,
		-- Warning timings for vote ending
		voteWarnTimes = {10,5},
		-- are multipliers multiplicative, or additive
		isMultiplicative = true,
		-- isPlaySounds set to false disables all sounds
		isPlaySounds = true,
		-- Taunt humans when they die with chatwheel sounds?
		isPlayerDeathSound = true,
		-- Set to true to enable dynamic role assignment (experimental)
		isDynamicRoleAssignment = true,
		-- Set to true to do annoying things to cheaters when they cheat
		isEnableCheatRepurcussions = true,
		-- Number of times to punish a cheater.  If this is < 0, then they will be punished indefinitely
		repurcussionsPerInfraction = 3,
		-- this represents a multiplier to all bonuses.  This allows each game to be slightly different
		skill =
		{
			-- percentages, by role (1, 2, 3, 4, 5).  A random number is chosen between the clamps
			variance =
			{
				{1.3, 1.5},
				{1.3, 1.5},
				{1.1, 1.5},
				{1.1, 1.5},
				{1.1, 1.5}
			},
			-- Warns players that the bot is very strong if they are over this threshold
			warningThreshold = 1.2,
			-- disable warnings altogether here
			isWarn = true
		},
		neutralItems =
		{
			-- duh
			enabled = true,
			-- Set to false to reroll on the entier table every time.  True makes the awards more like real
			-- jungle drops)
			isRemoveUsedItems = true,
			-- Max neutrals awarded per tier. You might be tempted to make this less than 5 to hinder the bots
			-- a bit, but note that the award method doesn't prioritize bot roles, so you might end up with a
			-- carry that doesn't have an item.
			maxPerTier = {5,5,5,5,5},
			-- adds this number to the awards as they come out (make this positive to give better items early
			-- make it negative to cause errors, probably.  If you want slower items just change the timings)
			tierOffset = 0,
			-- game time (seconds) at which awards are given.
			timings = {0, 420, 1020, 2020, 3600},
			-- default dota values, see NeutralItems:GetTimingDifficultyScaleShift()
			timingsDefault = {420, 1020, 1620, 2020, 3600},
			-- variance for timings (this number of seconds added to base timing per bot)
			variance = {30, 240},
			-- if true, announce awards to chat
			announce = true,
			-- Assign randomly, or roll specific per role down the line? (former is easier)
			assignRandomly = true
		},
		-- used for awarding bonus gold periodically.  The method that does this award calculates target
		-- gpm and then adds gold to the bot to attempt to force it to that level of gpm, modified by
		-- the clamps.
		-- exact formula: clamp( ( (targetGPM) + offset) * variance * bot.skill * scale) )
		gpm =
		{
			-- offset is a flat offset for the target award relative to the player with the same role
			offset 				= 0,
			-- award multiplied by a random number between these values
			variance 			= {1, 1},
			-- awards are clamped to these numbers. Note that if you make the minimum non-zero, then the
			-- bot's actual GPM will increase by that amount every minute (you don't want to do this)
			clamp 				= {0, 25},
			-- ignore clamps?
			clampOverride 		= false,
			-- scales (per role) for multipliers if necessary
			scale 				= {1.2, 1.1, 1.0, 0.9, 0.9},
			-- Add this to the max clamp per minute
			perMinuteScale 		= 0.5
		},
		-- see gpm, same idea
		xpm =
		{
			offset 				= 0,
			variance 			= {1, 1},
			clamp 				= {0, 25},
			clampOverride 		= false,
			scale 				= {1.2, 1.1, 1.0, 0.9, 0.9},
			perMinuteScale		= 0.5
		},
		deathBonus =
		{
			-- Order awards are given (useful when maxAwards is less than number of types)
			-- this also defines the names of the types (used to index tables for other settings)
			order = {'neutral', 'levels', 'stats', 'armor', 'magicResist', 'gold'},
			--The maximum number of awards per death
			maxAwards = 2,
			-- individual bonus enables
			enabled =
			{
				gold 			= true,
				armor 			= true,
				magicResist 	= true,
				levels 			= true,
				neutral 		= true,
				stats 			= true
			},
			-- Further option to only enable if the bots are behind in kills
			isEnabledOnlyWhenBehind =
			{
				gold 			= false,
				armor 			= false,
				magicResist 	= false,
				levels 			= false,
				neutral 		= false,
				stats 			= false
			},
			-- Enabled for humans, or just bots?
			isBotsOnly =
			{
				gold 			= true,
				armor 			= true,
				magicResist 	= true,
				levels 			= true,
				neutral 		= true,
				stats 			= true
			},
			-- bonuses always given once this threshold is reached.
			-- if this number is negative, mandatory awards are never given.
			deathStreakThreshold = -1,
			-- range for each award.  This is the base number, which gets scaled with skill / etc.
			-- clamps are applied to the scaled value
			range =
			{
				gold 			= {100, 500},
				armor 			= {1, 3},
				magicResist 	= {1, 2},
				levels 			= {0.5, 2},
				neutral 		= {30, 180},
				stats			= {1, 3}
			},
			-- (Seconds) Both ends of the range multiplied by gametime / this value.
			-- Adjust this to prevent large awards early.  Note that clamp has its
			-- own scaling, so you can, for example, grow quickly but still
			-- clamp late.
			-- If this is enabled and no default numbers changed, it should
			-- prevent early game OH SHIT moments, or provide late game OH SHIT moments.
			-- Default scales to nominal range at 30 minutes (and more beyond)
			rangeTimeScale  =
			{
				gold 		= 1800,
				armor 		= 1800,
				magicResist = 1800,
				levels 		= 1800,
				neutral 	= 1800,
				stats 		= 1800
			},
			isRangeTimeScaleEnable = false,
			-- bonus clamps.  Awards given are clamped between these values
			clamp =
			{
				gold 			= {100, 1500},
				armor 			= {1, 5},
				magicResist 	= {1, 3},
				levels 			= {0.5, 2},
				neutral 		= {30, 180},
				stats			= {1, 3}
			},
			-- if override is true, then the clamps aren't applied
			clampOverride =
			{
				gold 			= false,
				armor 			= false,
				magicResist 	= false,
				levels 			= false,
				neutral 		= false,
				stats 			= false
			},
			-- (Seconds) Upper clamp end scaled by this value.
			-- Note the lower clamp is never adjusted.
			-- Adjust this to allow even greater late game OH SHIT moments.
			-- Default scales to nominal range at 30 minutes (and more beyond)
			clampTimeScale =
			{
				gold 			= 1800,
				armor 			= 1800,
				magicResist 	= 1800,
				levels 			= 1800,
				neutral 		= 1800,
				stats 			= 1800
			},
			isClampTimeScaleEnable = false,
			-- chances per indivdual award.  current levels tracked in bot.stats.chance
			chance =
			{
				gold 			= 0.25,
				armor 			= 0.10,
				magicResist 	= 0.10,
				levels 			= 0.10,
				neutral 		= 0.15,
				stats 			= 0.10,
			},
			-- if accrue is true, chances accumulate per death
			accrue =
			{
				gold 			= true,
				armor 			= true,
				magicResist 	= true,
				levels 			= false,
				neutral 		= false,
				stats 			= true
			},
			-- flat offsets for bonus per type
			offset =
			{
				gold 			= 0,
				armor 			= 0,
				magicResist 	= 0,
				levels 			= 0,
				neutral 		= 0,
				stats 			= 0
			},
			-- Awards are rounded to this many decimal places after scaling
			round =
			{
				gold 			= 0,
				armor 			= 2,
				magicResist 	= 2,
				levels 			= 2,
				neutral 		= 0,
				stats 			= 0,
			},
			-- variance per type
			variance =
			{
				gold 			= {0.8, 1.2},
				armor 			= {0.8, 1.2},
				magicResist		= {0.8, 1.2},
				levels 			= {0.8, 1.2},
				neutral 		= {0.8, 1.2},
				stats			= {0.8, 1.2}
			},
			-- is this award always loud?
			isLoud =
			{
				gold 			= false,
				armor 			= false,
				magicResist 	= false,
				levels 			= true,
				neutral 		= false,
				stats 			= false
			},
			-- is this award loud if it gets clamped on the high side?
			isClampLoud =
			{
				gold 			= true,
				armor 			= false,
				magicResist 	= false,
				levels 			= false,
				neutral 		= false,
				stats 			= false
			},
			-- Awards multiplied by this (per role) if enabled
			scale =
			{
				gold 			= {1.2, 1.1, 1.0, 0.9, 0.9},
				armor 			= {1.2, 1.1, 1.0, 0.8, 0.6},
				magicResist 	= {1.2, 1.1, 1.0, 0.9, 0.9},
				levels 			= {1.2, 1.1, 1.0, 0.9, 0.9},
				neutral 		= {1.2, 1.1, 1.0, 0.9, 0.9},
				stats 			= {1.2, 1.1, 1.0, 0.9, 0.9},
			},
			-- Enable role scaling?
			scaleEnabled =
			{
				gold 			= true,
				armor 			= true,
				magicResist 	= true,
				levels 			= true,
				neutral 		= true,
				stats 			= true
			},
			-- bonuses not awarded if game time is less than this number (seconds)
			timeGate =
			{
				gold 			= -100,
				armor 			= -100,
				magicResist 	= -100,
				levels 			=  120,
				neutral 		= -100,
				stats 			= -100,
			},
			-- sets whether to announce in chat if awards have been given
			announce			= true
		},
		-- One Time awards (granted at game start)
		-- note that neutral is not the count, it is the tier
		-- still, it's probably better to just fix neutral timing rather than award one here
		gameStartBonus =
		{
				gold 			= 100,
				armor 			= 0.1,
				magicResist 	= 0.1,
				levels 			= 0.1,
				neutral       	= 0,
				stats 			= 1,
		},
		gameStartBonusTimesDifficulty =
		{
				gold 			= 60,
				armor 			= 1,
				magicResist 	= 1,
				levels 			= 0,
				neutral       	= 1,
				stats 			= 1
		},
		-- caps for awards per game
		awardCap =
		{
			gold 				= 30000,
			armor 				= 30,
			magicResist 		= 28,
			levels 				= 15,
			neutral 			= 1500,
			stats 				= 45,
		},
		-- Settings for dynamically adjusting difficulty
		dynamicDifficulty =
		{
			-- Set to false to disable completely.
			enabled 			= true,
			-- 'knobs' to turn to adjust difficulty dynamically.
			knobs =
			{
				'gpm',
				'xpm',
				'levels',
				'stats'
			},
			-- Settings related to kill deficits
			gpm =
			{
				-- Set to false to disable adjustments based on kills.
				enabled	= true,
				-- if the bots are this many kills behind, begin adjusting
				advantageThreshold = 2,
				-- Awards scaled by scale amount every <this many> kills beyond the threshold
				incrementEvery = 1,
				-- base bonus increased by this much when over threshold
				base = 22,
				-- incremental amounts are added to the base every time
				-- the increment amount is reached, i.e. if threshold is 5,
				-- incrementEvery is 2, and the bots are 9 kills behind,
				-- then the nudge will be base + (increment * 2)
				increment = 10,
				-- maximum for this bonus
				cap = 200,
				-- If true, adjustments are announced to chat.
				announce = false
			},
			xpm =
			{
				enabled				= false,
				advantageThreshold 	= 2,
				incrementEvery 		= 1,
				base				= 10,
				increment 			= 5,
				cap 				= 200,
				announce 			= false
			},
			levels =
			{
				enabled				= false,
				advantageThreshold	= 10,
				incrementEvery		= 2,
				base				= 1,
				increment 			= 1,
				cap 				= 3,
				announce 			= false,
				-- chanceAdjust is optional and will adjust the base chance for
				-- death awards for each knob.
				chanceAdjust =
				{
					enabled				= true,
					advantageThreshold	= 10,
					incrementEvery		= 0,
					base				= 1.0,
					increment 			= 0,
					cap 				= 1,
					announce 			= false,
				}
			},
			stats =
			{
				enabled					= true,
				advantageThreshold		= 7,
				incrementEvery			= 2,
				base					= 1,
				increment 				= 1,
				cap 					= 5,
				announce 				= false,
				-- chanceAdjust is optional and will adjust the base chance for
				-- death awards for each knob.
				chanceAdjust =
				{
					enabled				= true,
					advantageThreshold	= 7,
					incrementEvery		= 0,
					base				= 0.5,
					increment 			= 0,
					cap 				= 1,
					announce 			= false,
				}
			},
		},
		-- Settings for hero specific stuff (i.e. experimental LD bear item moving)
		heroSpecific =
		{
			loneDruid =
			{
				enabled = false
			}
		}
	}

	return settings