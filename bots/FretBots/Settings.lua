-- Dependencies
 -- global debug flag
require 'bots.FretBots.Debug'
 -- Other Flags
require 'bots.FretBots.Flags'
 -- Timers
require 'bots.FretBots.Timers'
 -- Utilities
require 'bots.FretBots.Utilities'
-- Version
require 'bots.FretBots.Version'
-- HeroSounds
require('bots.FretBots.HeroSounds')

-- local debug flag
local thisDebug = false;
local isDebug = Debug.IsDebug() and thisDebug;
Settings = nil

-- Other local variables
local settingsTimerName = 'settingsTimerName'
-- number of human players
local players = 0
-- table to keep track of player votes
local playerVoted = {}
-- is voting closed
local isVotingClosed = false
-- Have voting directions been posted?
local isVotingOpened = false
-- Number of votes cast
local numVotes = 0
-- start abitrariy large, fix when chat listener is registered
local maxVotes = DOTA_MAX_PLAYERS
-- voting time elapsed (starts at -1 since the timer increments immediately)
local votingTimeElapsed = -1
-- The playerID of the host.  Used to whitelist chat commands.
local hostID = -1
-- default difficulty if no one votes
noVoteDifficulty = 2
-- Is repurcussion timer started?
local isRepurcussionTimerStarted = false
-- Instantiate ourself
if Settings == nil then
	Settings = dofile('bots.FretBots.SettingsDefault')
end

-- neutral item drop settings
AllNeutrals = dofile('bots.FretBots.SettingsNeutralItemTable')

-- cheat command list
local cheats = dofile('bots.FretBots.CheatList')

local currentAnnouncePrintTime = 0
local lastAnnouncePrintedTime = -2
local numberAnnouncePrinted = 0
local announcementGap = 2

-- RGB color and text. sample color pick web: https://htmlcolorcodes.com/
local announcementList = {
	{"#C0392B", "GLHF! Default bot scripts lack excitement. This script boosts bots with unfair advantages to make bot games more challenging:"},
	{"#9B59B6", "* You can vote for difficulty scale from 0 to 10, which affects the amount of bonus the bots will receive." },
	{"#2980B9", "* If difficulty >= 0, bots get bonus neutral items, and get fair bonus in gold, exp, stats, etc every minute."},
	{"#E59866", "* If difficulty >= 1, bots get above bonus upon their death; and also get new bonus in mana/hp regens."},
	{"#1ABC9C", "* As difficulty increments, bots get neutral items sooner and higher bonus amount."},
	{"#F39C12", "* If difficulty >= 5, when a player kills a bot, the player who made the kill receives a reduction in gold. This does not affect assisting players. Bots also provide less exp on death."},
	{"#7FB3D5", "* The higher the difficulty you vote, the more bonus the bots will get which can make the game more challenging." },
	{"#E74C3C", "* High difficulty can be overwhelming or even frustrating, please choose the right difficulty for you and your team." },
	{"#D4AC0D", "* Kudos to BeginnerAI, Fretbots, and ryndrb@; and thanks to Toph, hiro1134, -Calculated, Karma, Psychdoctor for sharing ideas." },
	-- {"#D4AC0D", "There are commands to play certain sounds like `ps love` or `ps dylm`. You can also explore other commands like `getroles`, `networth`, etc." }
}


-- Difficulty values voted for
difficulties = {}

-- Valid commands for altering settings from chat
local chatCommands =
{
	'nudge',
	'get',
	'set',
	'ddenable',
	'ddsuspend',
	'ddtoggle',
	'ddreset',
	'diff',
	'difficulty',
	'stats',
	'goodsound',
	'badsound',
	'asound',
	'csound',
	'esound',
	'playsound',
	'ps',				-- playsound alias
	'kb',				-- 'kill bot'
	'networth',
	'getroles',
	'me',				-- play a sound from your hero
	'vo',				-- 'voiceover': play a sound from another hero
	'voc',				-- does the same thing as 'vo c': plays caster voiceovers
}

-- Sets difficulty value
function Settings:Initialize(difficulty)
	-- no argument implies default, do nothing
	if difficulty == nil then return end
	-- Adjust bot skill values by the difficulty value
	Settings.difficultyScale = 1 + ((difficulty - 5) / 10)
	-- increase diff scale for diffculty > 5.
	if difficulty > 5 and difficulty < 10 then
		Settings.difficultyScale = 1 + ((difficulty - 3) / 10)
	elseif difficulty >= 10 then
		Settings.difficultyScale = 1 + (difficulty / 10)
	end
	Settings.difficultyScale = Utilities:Round(Settings.difficultyScale, 2)
	-- Print
	local msg = 'Difficulty Scale: '..Settings.difficultyScale
	Debug:Print(msg)
	-- Utilities:Print(msg, MSG_GOOD) -- scale value vs difficulty they voted can confuse players.
	-- Set Flag
	Flags.isSettingsFinalized = true
end

-- Starts timer for cheat repurcussions.  Once started for a player, runs once
-- per second indefinitely.
function Settings:StartRepurcussionTimer()
	local timerName = 'RepercussionTimer'
	Timers:CreateTimer(timerName, {endTime = 1, callback =  Settings['RepurcussionTimer']} )
end

-- Checks each player to see if they need a repurcussion
function Settings:RepurcussionTimer()
	for _, player in ipairs(Players) do
		if player.stats.repurcussionCount < player.stats.repurcussionTarget then
			if player:IsAlive() then
				player.stats.repurcussionCount = player.stats.repurcussionCount + 1
				player:ForceKill(true)
				local msg = PlayerResource:GetPlayerName(player.stats.id)..' is experiencing repurcussions: '
				msg = msg..player.stats.repurcussionCount..' of '..player.stats.repurcussionTarget
				Utilities:CheatWarning()
				Utilities:Print(msg, Utilities:GetPlayerColor(player.stats.id))
				if player.stats.repurcussionCount == player.stats.repurcussionTarget then
					msg = PlayerResource:GetPlayerName(player.stats.id)..' has been rehabilitated!'
					Utilities:Print(msg, Utilities:GetPlayerColor(player.stats.id))
				end
			end
		end
	end
	return 1
end

-- Periodically checks to see if settings have been chosen
function Settings:DifficultySelectTimer()
	-- increment elapsed time
	votingTimeElapsed = votingTimeElapsed + 1
	-- If voting is closed, apply settings, remove timer
	if isVotingClosed then
		Settings:ApplyVoteSettings()
		Timers:RemoveTimer(settingsTimerName)
		return nil
	end
	-- If voting not yet open, display directions
	if not isVotingOpen then
		-- local msg = 'Fret Bots! Now with more branding! Version: '..version..'\n'
		-- Utilities:Print(msg, MSG_GOOD)
		local msg = 'Difficulty voting is now open!'..' Default difficulty is currently: '..tostring(noVoteDifficulty)
		Utilities:Print(msg, MSG_GOOD)
		msg = 'Enter a number (0 through 10) in chat to vote.'
		Utilities:Print(msg, MSG_GOOD)
		isVotingOpen = true
		
	end

	if numberAnnouncePrinted < #announcementList + 1 then
		if currentAnnouncePrintTime - lastAnnouncePrintedTime >= announcementGap then
			local msg = announcementList[numberAnnouncePrinted]
			if msg ~= nil then
				Utilities:Print(msg[2], msg[1])
			end
			numberAnnouncePrinted = numberAnnouncePrinted + 1
			lastAnnouncePrintedTime = currentAnnouncePrintTime
		end
		currentAnnouncePrintTime = currentAnnouncePrintTime + 1
	end

	-- set voting closed
	if numVotes >= maxVotes or Settings:ShouldCloseVoting() then
		isVotingClosed = true
	end
	-- run again in 1 second
	return 1
end

-- Determine winner of voting and applies settings (or applies default difficulty)
function Settings:ApplyVoteSettings()
	local difficulty
	-- edge case: no one voted
	if #difficulties == 0 then
		difficulty = noVoteDifficulty
	-- otherwise, average the votes
	else
		local total = 0
		for _, value in ipairs(difficulties) do
			total = total + value
		end
		difficulty = total / #difficulties
		difficulty = Utilities:Round(difficulty, 1)
	end
	local msg = 'Difficulty Selected: '..difficulty
	Debug:Print(msg)
	Utilities:Print(msg, MSG_GOOD)
	Settings:Initialize(difficulty)
	Settings.difficulty = difficulty


end

-- Returns true if voting should close due to game state
function Settings:ShouldCloseVoting()
	-- voting ends immediately if we reach voteEndState
	local state =  GameRules:State_Get()
	if state > Settings.voteEndState then
		return true
	end
	-- Warn about impending closure if necessary
	Utilities:Warn(Settings.voteEndTime - votingTimeElapsed,
									Settings.voteWarnTimes,
									"Voting ends in %d seconds!")
	-- Voting ends a set number of seconds after it begins
	if votingTimeElapsed >= Settings.voteEndTime then
		return true
	end
	return false
end

-- Register a chat listener for settings voting
function Settings:RegisterChatEvent()
	if not Flags.isPlayerChatRegistered then
		-- set max number of vote
		maxVotes = Utilities:GetNumberOfHumans()
		ListenToGameEvent("player_chat", Dynamic_Wrap(Settings, 'OnPlayerChat'), Settings)
		print('Settings: PlayerChat event listener registered.')
		Flags.isPlayerChatRegistered = true
	end
end

-- Monitors chat for votes on settings
function Settings:OnPlayerChat(event)
	-- Get event data
	local playerID, rawText = Settings:GetChatEventData(event)
	-- Check to see if they're cheating
	Settings:DoChatCheatParse(playerID, rawText)
	-- Remove dashes (potentially)
	local text = Utilities:CheckForDash(rawText)
	-- Handle votes if we're still in the voting phase
	if not isVotingClosed then
		Settings:DoChatVoteParse(playerID, text)
	end
	-- if Settings have been chosen then monitor for commands to change them
	if Flags.isSettingsFinalized then
		-- Some commands are available for everyone
		Settings:DoUserChatCommandParse(text, playerID)
		if playerID == hostID or Debug:IsPlayerIDFret(playerID) then
			-- check for 'light' commands
			local isSuccess = Settings:DoSuperUserChatCommandParse(text)
			-- if not that, then try to pcall arbitrary text
			Utilities:PCallText(text)
		end
	end
end

-- Parse for commands anyone can use
function Settings:DoUserChatCommandParse(text, id)
	local tokens = Utilities:Tokenize(text)
	local command = Settings:GetCommand(tokens)
	-- No command, return false
	if command == nil then return false end
	-- Random good sound
	if command == 'goodsound' then
		Utilities:RandomSound(GOOD_LIST)
		return true
	end
	-- Random bad sound
	if command == 'badsound' then
		Utilities:RandomSound(BAD_LIST)
		return true
	end
	-- Random Asian soundboard
	if command == 'asound' then
		Utilities:RandomSound(ASIAN_LIST)
		return true
	end
	-- Random CIS soundboard
	if command == 'csound' then
		Utilities:RandomSound(CIS_LIST)
		return true
	end
	-- Random English soundboard
	if command == 'esound' then
		Utilities:RandomSound(ENGLISH_LIST)
		return true
	end
	-- Play Specific Sound
	if command == 'playsound' or command == 'ps' then
		Utilities:PlaySound(tokens[2])
		return true
	end
	-- Display team net worths
	if command == 'networth' then
		Debug:Print('Net Worth!')
		Settings:DoDisplayNetWorth()
		return true
	end
	-- get prints a setting to chat
	if command == 'get' then
		Settings:DoGetCommand(tokens)
		return true
	end
	-- print stats
	if command == 'stats' then
		Settings:DoGetStats(tokens)
		return true
	end
	-- dump bot roles
	if command == 'getroles' then
		RoleDetermination:AnnounceRoles()
		return true
	end
	-- Play sounds from the player's hero
	-- one expected argument here, either a name of a sound or an attribute
	if command == 'me' then
		local player = DataTables:GetPlayerById(id)
		local hero = player.stats.internalName
		if (tokens[2] ~= nil) then
			-- Only one of these will work
			local success = HeroSounds:PlaySoundByName(hero, tokens[2])
			-- Try an attribute token if the hero didn't work
			if (success == false) then
				HeroSounds:PlaySoundByAttribute(hero, tokens[2])
			end
		else
			HeroSounds:PlayRandomSound(hero)
		end
		return true
	end
	-- Play sounds from other players' heroes, or casters
	-- two expected arguments here, hero, and either a name of a sound or an attribute
	-- if only hero is passed it plays a random one from that table
	if command == 'vo' then
		if (tokens[2] ~= nil) then
			local hero = HeroSounds:ParseHero(tokens[2])
			if (hero ~= nil) then
				if (tokens[3] ~= nil) then
					-- Only one of these will work
					local success = HeroSounds:PlaySoundByName(hero, tokens[3])
					-- Try an attribute token if the hero didn't work
					if (success == false) then
						HeroSounds:PlaySoundByAttribute(hero, tokens[3])
					end
				else
					HeroSounds:PlayRandomSound(hero)
				end
			end
		end
		return true
	end
	-- 'voc' is handled the same way as 'vo c' would be
	if command == 'voc' then
		local hero = HeroSounds:ParseHero('c')
		if (hero ~= nil) then
			if (tokens[2] ~= nil) then
				-- Only one of these will work
				local success = HeroSounds:PlaySoundByName(hero, tokens[2])
				-- Try an attribute token if the hero didn't work
				if (success == false) then
					HeroSounds:PlaySoundByAttribute(hero, tokens[2])
				end
			else
				HeroSounds:PlayRandomSound(hero)
			end
		end
		return true
	end
	return false
end


-- Parse commands for superusers
function Settings:DoSuperUserChatCommandParse(text)
	local tokens = Utilities:Tokenize(text)
	local command = Settings:GetCommand(tokens)
	-- No command, return false
	if command == nil then return false end
	-- Otherwise process
	--set writes to something
	if command == 'set' then
		Settings:DoSetCommand(tokens)
	end
	--set writes to something
	if command == 'nudge' then
		Settings:DoNudgeCommand(tokens)
	end
	-- Toggle dynamic difficulty
	if command == 'ddtoggle' then
		Settings:DoDDToggleCommand()
	end
	-- suspend dynamic difficulty
	if command == 'ddsuspend' then
		Settings:DoDDSuspendCommand()
	end
	-- reset dynamic difficulty (this restores default GPM/XPM)
	if command == 'ddreset' then
		Settings:DoDDResetCommand()
	end
	-- enable dynamic difficulty
	if command == 'ddenable' then
		Settings:DoDDEnableCommand(tokens)
	end
	-- enable dynamic difficulty
	if command == 'difficulty' or command == 'diff' then
		Settings:DoSetDifficultyCommand(tokens)
	end
	-- Kill a bot
	if command == 'kb' then
		Settings:DoKillBotCommand(tokens)
	end
	return true
end

-- Display net worths
function Settings:DoDisplayNetWorth()
	local msg = ''
	local botMsg = ''
	local botTeamNetWorth = 0
	local playerTeamNetWorth = 0
	local netWorth = 0
	local roundedNetWorth = 0
	for _, bot in ipairs(Bots) do
		netWorth = PlayerResource:GetNetWorth(bot.stats.id)
		botTeamNetWorth = netWorth + botTeamNetWorth
		roundedNetWorth = Utilities:Round(netWorth, -2)
		roundedNetWorth = roundedNetWorth / 1000
		botMsg = Utilities:ColorString(bot.stats.name ..': '..tostring(roundedNetWorth)..'k', Utilities:GetPlayerColor(bot.stats.id))
		msg = msg..'  '..botMsg
	end
	Utilities:Print(msg)
	for _, player in ipairs(Players) do
		netWorth = PlayerResource:GetNetWorth(player.stats.id)
		playerTeamNetWorth = netWorth + playerTeamNetWorth
	end
	roundedNetWorth = Utilities:Round(playerTeamNetWorth, -2)
	roundedNetWorth = roundedNetWorth / 1000
	msg = 'Player Team Net Worth: '..tostring(roundedNetWorth)..'k'
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
	roundedNetWorth = Utilities:Round(botTeamNetWorth, -2)
	roundedNetWorth = roundedNetWorth / 1000
	msg = 'Bot Team Net Worth: '..tostring(roundedNetWorth)..'k'
	Utilities:Print(msg, MSG_CONSOLE_BAD)
end


-- Gets stats
function Settings:DoGetStats(tokens)
	-- tokens[2] will contain the stat to display
	local stat = tokens[2]
	for _, bot in ipairs(Bots) do
		local value = bot.stats.awards[stat]
		if value ~= nil then
			local msg = ''
			msg = msg..bot.stats.name..': '..stat..': '..value
			Utilities:Print(msg,MSG_CONSOLE_GOOD)
		end
	end
end


-- Asserts a difficulty level
function Settings:DoSetDifficultyCommand(tokens)
	-- tokens[2] will contain the difficulty
	local difficultyName = tokens[2]
	local difficulty = {}
	-- check if it's valid
	local isValid = false
	for key, value in pairs(Difficulties) do
		if value.name == difficultyName then
			isValid = true
			difficulty = value
		end
	end
	if isValid then
		local msg ='Assigning difficulty: '..tostring(difficultyName)
		Utilities:Print(msg, difficulty.color)
		Utilities:DeepCopy(difficulty, Settings)
	else
		local msg = tostring(difficulty)..' is not a valid difficulty.'
		Utilities:Print(msg, MSG_CONSOLE_GOOD)
	end
end

-- Toggles Dynamic difficulty
function Settings:DoDDToggleCommand()
	DynamicDifficulty:Toggle()
	local msg ='Dynamic Difficulty Enable Toggled: '..
							tostring(Settings.dynamicDifficulty.enabled)
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Enables Dynamic difficulty
function Settings:DoDDEnableCommand(tokens)
	Settings.dynamicDifficulty.enabled = true
	local msg ='Dynamic Difficulty Enabled.'
	-- check for additional settings commands
	if tokens[2] ~= nil then
		local number = tonumber(tokens[2])
		if number ~= nil then
			-- Assign threshold
			Settings.dynamicDifficulty.gpm.advantageThreshold = number
			Settings.dynamicDifficulty.xpm.advantageThreshold = number
			msg = msg..' advantageThreshold set to '..tokens[2]..'. '
		end
	end
	-- check for additional settings commands
	if tokens[3] ~= nil then
		local number = tonumber(tokens[3])
		if number ~= nil then
			-- Assign incrementEvery
			Settings.dynamicDifficulty.gpm.incrementEvery = number
			Settings.dynamicDifficulty.xpm.incrementEvery = number
			msg = msg..' incrementEvery set to '..tokens[3]..'. '
		end
	end
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Resets Dynamic difficulty (GPM/XPM to default)
function Settings:DoDDResetCommand()
	DynamicDifficulty:Reset()
	Settings.dynamicDifficulty.enabled = false
	local msg ='Dynamic Difficulty Reset and Disabled. Default Bonus Offsets Restored:'..
							' GPM: '..Settings.gpm.offset..
							' XPM: '..Settings.xpm.offset
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Suspends Dynamic difficulty
function Settings:DoDDSuspendCommand()
	DynamicDifficulty:Suspend()
	local msg ='Dynamic Difficulty Suspended. Current Bonus Offsets:'..
							' GPM: '..Settings.gpm.offset..
							' XPM: '..Settings.xpm.offset
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
end

-- Executes the 'get' command
function Settings:DoGetCommand(tokens)
	-- tokens[2] will be the target object string
	local target = Settings:GetObject(tokens[2])
	if target ~= nil then
		Utilities:TableToChat(target, MSG_CONSOLE_GOOD)
	end
end

-- Executes the 'set' command
function Settings:DoSetCommand(tokens)
	-- tokens[2] will be the target object string
	if tokens[2] == nil then
		Utilities:Print('Set requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end
	local stringTarget = tokens[2]
	local target = Settings:GetObject(stringTarget)
	if target == nil then
		Utilities:Print('Set requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end
	-- tokens[3] is target value
	if tokens[3] == nil then
		Utilities:Print('Set requires a value argument.', MSG_CONSOLE_BAD)
		return
	end
	local value = Utilities:TableFromString(tokens[3])
	if value == nil then
		Utilities:Print('Invalid value for set command.', MSG_CONSOLE_BAD)
		return
	end
	if Settings:IsValidSet(target, value) then
		-- tables
		if type(value) == 'table' then
			Utilities:DeepCopy(value, target)
			Utilities:Print(stringTarget..' set successfully: '..
											Utilities:Inspect(value), MSG_CONSOLE_GOOD)
		-- Otherwise a literal
		else
			if Settings:SetValue(stringTarget, value) then
				Utilities:Print(stringTarget..' set successfully: '..
											tostring(value), MSG_CONSOLE_GOOD)
			else
				Utilities:Print('Unable to set '..stringTarget..'.', MSG_CONSOLE_BAD)
			end
		end
	else
		Utilities:Print('Invalid value for set command.', MSG_CONSOLE_BAD)
		return
	end
end

-- Executes the 'nudge' command
function Settings:DoNudgeCommand(tokens)
	-- All sorts of testing!
	-- tokens[2] will be the target object string
	if tokens[2] == nil then
		Utilities:Print('Nudge requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end
	local stringTarget = tokens[2]
	local target = Settings:GetObject(stringTarget)
	if target == nil then
		Utilities:Print('Nudge requires a target object argument.', MSG_CONSOLE_BAD)
		return
	end
	if type(target) ~= 'table' and type(target) ~= 'number'then
		Utilities:Print('Nudge targets must be tables or numbers.', MSG_CONSOLE_BAD)
		return
	end
	-- tokens[3] is target value
	if tokens[3] == nil then
		Utilities:Print('Nudge requires a value argument.', MSG_CONSOLE_BAD)
		return
	end
	local value = Utilities:TableFromString(tokens[3])
	if value == nil then
		Utilities:Print('Invalid value for nudge command.', MSG_CONSOLE_BAD)
		return
	end
	if type(value) ~= 'number' then
		Utilities:Print('Nudge values must be numbers', MSG_CONSOLE_BAD)
		return
	end
	-- Ok, we think we can apply this
	-- Nudge simply adds the value to each value of a table (or directly to a number)
	if type(target) == 'table' then
		-- create offset table values
		local valTable = {}
		for _, val in ipairs(target) do
			table.insert(valTable, val + value)
		end
		Utilities:DeepCopy(valTable, target)
		Utilities:Print(stringTarget..' nudged successfully: '..
									Utilities:Inspect(target), MSG_CONSOLE_GOOD)
	else
		local val = target + value
		Settings:SetValue(stringTarget, val)
		Utilities:Print(stringTarget..' nudged successfully: '..
									val, MSG_CONSOLE_GOOD)
	end
end

-- Executes the 'kb' command
function Settings:DoKillBotCommand(tokens)
	-- tokens[2] will be the target object string (if it exists)
	-- trivial case - no tokens[2]
	if tokens[2] == nil then
		Debug:KillBot()
	elseif tonumber(tokens[2]) ~= nil then
		Debug:KillBot(tonumber(tokens[2]))
	else
		Debug:KillBot(tokens[2])
	end
end

-- Parses chat message for valid settings votes and handles them.
function Settings:DoChatVoteParse(playerID, text)
		-- return if the player is not on a team
	if not Utilities:IsTeamPlayer(playerID) then return end
	-- if no vote from the player, check if he's voting for a difficulty
	if playerVoted[tostring(playerID)] == nil then
		-- If voted for difficulty, reflect that
		local difficulty = tonumber(text)
		if difficulty ~= nil then
			-- players can only vote once
			playerVoted[tostring(playerID)] = true
			-- coerce (if necessary)
			if difficulty > 10 then
				 difficulty = 10
			elseif difficulty < 0 then
				difficulty = 0
			end
			difficulty = Utilities:Round(difficulty, 1)
			-- save voted value
			table.insert(difficulties, difficulty)
			-- increment number of votes
			numVotes = numVotes + 1
			-- let players know the vote counted
			local msg = PlayerResource:GetPlayerName(playerID)..' voted: '..difficulty..'.'
			Utilities:Print(msg, Utilities:GetPlayerColor(playerID))
		end
	end
end

-- Checks to see if a player is entering cheat commands
function Settings:DoChatCheatParse(playerId, text)
	local tokens = Utilities:Tokenize(text)
	for _, cheat in pairs(cheats) do
		-- tokens 1 is the potential cheat code
		-- I am an idiot use .lower!
		if string.lower(tokens[1]) == string.lower(cheat) then
			local msg = PlayerResource:GetPlayerName(playerId)..' is cheating: '..text
			Utilities:CheatWarning()
			Utilities:Print(msg, Utilities:GetPlayerColor(playerId))
			-- Start repurcussion timer if necessary
			if Settings.isEnableCheatRepurcussions then
				-- Don't do this before Stats exist
				if Flags.isStatsInitialized == false then
					return
				end
				if isRepurcussionTimerStarted == false then
					Settings:StartRepurcussionTimer()
					isRepurcussionTimerStarted = true
				end
				-- Add repurcussions to this player
				local player = DataTables:GetPlayerById(playerId)
				if player ~= nil then
					if Settings.repurcussionsPerInfraction >= 0 then
						player.stats.repurcussionTarget = player.stats.repurcussionTarget + Settings.repurcussionsPerInfraction
					else
						player.stats.repurcussionTarget = 65535
					end
				end
			end
		end
	end
end

-- returns true if target and value share the same properties, e.g.
-- both are a literal, or a table of literals with the same number
-- of entries
function Settings:IsValidSet(target, value)
	if type(target) == 'number' and type(value) == 'number' then
		return true
	end
	if type(target) == 'string' and type(value) == 'string' then
		return true
	end
	if type(target) == 'boolean' and type(value) == 'boolean' then
		return true
	end
	-- tables are a little harder
	if type(target) == 'table' and type(value) == 'table' then
		-- number mismatch is a fail
		if #target ~= #value then
			return false
		end
		local isGood = true
		-- iterate over values inside then
		for key, val in pairs(target) do
			if value[key] == nil then
				return false
			end
			-- if value is another table, recurse
			if type(value) == 'table' then
				isGood = isGood and Settings:IsValidSet(target[key], value[key])
			else
				isGood = isGood and type(value[key]) == type(target[key])
			end
		end
		return isGood
	end
	return false
end

-- Parses chat text and converts to a Settings object
-- Since Settings is deeply nested, if I were to chat
-- 'gpm' and look up Settings[gpm], that would work, but
-- if I wanted gpm.Clamp, Settings[gpm.Clamp] fails.
function Settings:GetObject(objectText)
	local tokens = Utilities:Tokenize(objectText, '.')
	-- Just in case
	if tokens == nil then return end
	-- drill to target object
	local currentObject = Settings
	for _, token in ipairs(tokens) do
		currentObject = currentObject[token]
		-- drop out if it doesn't exist
		if currentObject == nil then
			return
		end
	end
	return currentObject
end

-- Sets the value of a non-table Settings entry
function Settings:SetValue(objectText, value)
	local tokens = Utilities:Tokenize(objectText, '.')
	-- Just in case
	if tokens == nil then return false end
	-- this is ugly
	if #tokens == 1 then
		Settings[tokens[1]] = value
	elseif #tokens == 2 then
		Settings[tokens[1]][tokens[2]] = value
	elseif #tokens == 3 then
		Settings[tokens[1]][tokens[2]][tokens[3]] = value
	elseif #tokens == 4 then
		Settings[tokens[1]][tokens[2]][tokens[3]][tokens[4]] = value
	elseif #tokens == 5 then
		Settings[tokens[1]][tokens[2]][tokens[3]][tokens[4]][tokens[5]] = value
	elseif #tokens == 6 then
		Settings[tokens[1]][tokens[2]][tokens[3]][tokens[4]][tokens[5]][tokens[6]] = value
	else
		return false
	end
	return true
end

-- Parses chat tokens and returns a valid command if there was one.  Nil otherwise.
function Settings:GetCommand(tokens)
	for _, command in pairs(chatCommands) do
		if string.lower(tokens[1]) == string.lower(command) then
			return command
		end
	end
	return
end

-- Parse chat event information
function Settings:GetChatEventData(event)
	local playerID = event.playerid
	local text = event.text
	return playerID, text
end

-- set host ID to whitelist settings commands
function Settings:SetHostPlayerID()
	hostID = Utilities:GetHostPlayerID()
end

-- this callback gets run once when game state enters DOTA_GAMERULES_STATE_HERO_SELECTION
-- this prevents us from attempting to get the number of players before they have all loaded
function Settings:InitializationTimer()
	-- Register settings vote timer and chat event monitor
	Debug:Print('Begining Settings Initialization.')
	Settings:RegisterChatEvent()
	Timers:CreateTimer(settingsTimerName, {endTime = 1, callback =  Settings['DifficultySelectTimer']} )
end

--Don't run initialization until all players have loaded into the game.
-- I'm not sure if things like GetPlayerCount() track properly before this,
-- and am not willing to test since this facility is in place and is easier.
if not Flags.isSettingsInitialized then
	Utilities:RegsiterGameStateListener(Settings, 'InitializationTimer', DOTA_GAMERULES_STATE_HERO_SELECTION )
	Flags.isSettingsInitialized = true
end
