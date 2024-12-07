-- Dependencies
 -- global debug flag
require 'bots.FretBots.Debug'
 -- Other Flags
require 'bots.FretBots.Flags'
 -- Timers
require 'bots.FretBots.Timers'
 -- Utilities
require 'bots.FretBots.Utilities'
-- HeroSounds
require('bots.FretBots.HeroSounds')
local Customize = require('bots.Customize.general')
local Localization = require 'bots/FunLib/localization'
-- HeroSounds
local Chat = require('bots.FretBots.Chat')
if not Customize.Fretbots then Customize.Fretbots = { } end

-- default difficulty if no one votes
local DefaultDifficulty  = Customize.Fretbots.Default_Difficulty   or  2     -- [0, 10]
local DefaultAllyScale   = Customize.Fretbots.Default_Ally_Scale   or  0.5   -- [0,  1]

Settings = nil

-- Other local variables
local settingsTimerName = 'settingsTimerName'
-- table to keep track of player votes

-- max scales to vote
local difficultyMax = 10
local allyScaleMax = 1

local playerVoted = {}
-- is voting closed
local isVotingClosed = (Customize.Fretbots.Allow_To_Vote == false) or false
-- Have voting directions been posted?
local isVotingOpened = false
-- Number of votes cast
local numVotes = 0
-- start abitrariy large, fix when chat listener is registered
local maxVotes = DOTA_MAX_PLAYERS
-- voting time elapsed (starts at -1 since the timer increments immediately)
local votingTimeElapsed = -1
-- While the max difficulty can be 10+, if we use same max value for denominator later, it may decrease the difficulty.
local diffMaxDenominator = 10
-- Is repurcussion timer started?
local isRepurcussionTimerStarted = false
-- can players freely enter cheating commands?
local allowPlayersToCheat = false
local isVoteForAllyScale = false
local localeTimerName = 'localeTimerName'
local selectLocaleTimeElapsed = -1
local selectLocale = nil
local isSelectLocaleOpen = false
local hostID = Utilities:GetHostPlayerID()

-- Instantiate ourself
if Settings == nil then
	Settings = dofile('bots.FretBots.SettingsDefault')
end
Settings.difficultyMax = difficultyMax
Settings.diffMaxDenominator = diffMaxDenominator
Settings.allowPlayersToCheat = allowPlayersToCheat

-- neutral item drop settings
AllNeutrals = dofile('bots.FretBots.SettingsNeutralItemTable')

-- cheat command list
local cheats = dofile('bots.FretBots.CheatList')

local currentAnnouncePrintTime = 0
local lastAnnouncePrintedTime = -2
local numberAnnouncePrinted = 0
local announcementGap = 2

-- Difficulty values voted for
local VotedDifficulties = {}

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
	'gs',
	'badsound',
	'bs',
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
	'enablecheat',      -- enable players to cheat without getting punishment.
	'info',             -- basic info of the current difficulty and stats.
	'speak', 'sp',      -- speak specific language

}

Settings.isPlaySounds = Customize.Fretbots.Play_Sounds or Settings.isPlaySounds
Settings.isPlayerDeathSound = Customize.Fretbots.Player_Death_Sound or Settings.isPlayerDeathSound

function Settings:CalculateDifficultyScale(difficulty)
	-- no argument implies default, do nothing
	if difficulty == nil then return nil end
	-- Adjust bot skill values by the difficulty value
	local difficultyScale = 1 + ((difficulty - 5) / diffMaxDenominator)
	-- increase diff scale for diffculty > 5.
	if difficulty >= 5 and difficulty < diffMaxDenominator then
		difficultyScale = 1 + ((difficulty - 3.2) / diffMaxDenominator)
	elseif difficulty >= diffMaxDenominator then
		difficultyScale = 1 + (difficulty / diffMaxDenominator)
	end
	difficultyScale = Utilities:Round(difficultyScale, 2)
	return difficultyScale
end

-- Sets difficulty value
function Settings:Initialize(difficulty)
	Settings.difficultyScale = Settings:CalculateDifficultyScale(difficulty)
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
	if Settings.allowPlayersToCheat then return end

	for _, player in ipairs(AllHumanPlayers) do
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

-- Check whether it's time to vote for ally bots bonus scale. 
-- Should only work if there are bots in one and only one team with humans - wont't make sense to nurf ally bots again for both sides after picking the difficulty.
function IsTimeToVoteForAllyBonusScale()
	local bots, humans = {[2]={},[3]={}}, {[2]={},[3]={}}
    local playerCount = PlayerResource:GetPlayerCount()
	-- since all humans should be in 1 team when this feature takes effect, safe to use any human's team.
	local allyTeam = 2
    for playerID = 0, playerCount - 1 do
        local player = PlayerResource:GetPlayer(playerID)
		if player then
			local team = PlayerResource:GetTeam(playerID)
			if PlayerResource:GetSteamID(playerID) == PlayerResource:GetSteamID(100) then
				table.insert(bots[team], player)
			elseif team >= 2 and team <= 3 then
				table.insert(humans[team], player)
				allyTeam = team
			else
				print('Cannot start voting for ally bonus. Invalid player team: '..team)
			end
		end
	end

	local isRadiantMixedTeam = #bots[2] > 0 and #humans[2] > 0
	local isDireMixedTeam = #bots[3] > 0 and #humans[3] > 0
	local isOnlyOneTeamMixed = Utilities:xor(isRadiantMixedTeam, isDireMixedTeam)

	Settings.allyScaleTeam = allyTeam

	return isOnlyOneTeamMixed
end

function Settings:LocaleSelectTimer()
	selectLocaleTimeElapsed = selectLocaleTimeElapsed + 1
	if not isSelectLocaleOpen then
		local msg = 'Current language/locale is: "'..Customize.Localization .. '". The host can select a language by typing one of: "en" for English, "zh" for 中文, "ru" for русский, and "ja" for 日本語'
		Utilities:Print(msg, MSG_GOOD)
		isSelectLocaleOpen = true
	end

	if selectLocale or selectLocaleTimeElapsed >= 6 then
		selectLocale = selectLocale or 'default'
		Utilities:Print('Language/locale selected: ' .. selectLocale, MSG_GOOD)
		Timers:RemoveTimer(localeTimerName)
		isSelectLocaleOpen = false
		Timers:CreateTimer(settingsTimerName, {endTime = 1, callback =  Settings['DifficultySelectTimer']} )
	end
	return 1
end

-- Periodically checks to see if settings have been chosen
function Settings:DifficultySelectTimer()
	-- increment elapsed time
	votingTimeElapsed = votingTimeElapsed + 1
	-- If voting is closed, apply settings, remove timer
	if isVotingClosed then
		Timers:RemoveTimer(settingsTimerName)
		Settings:ApplyVoteSettings()
		return nil
	end
	-- If voting not yet open, display directions
	if not isVotingOpened and not isVotingClosed then
		local msg = Localization.Get('fret_diff_open')..tostring(DefaultDifficulty)
		Utilities:Print(msg, MSG_GOOD)
		msg = string.format(Localization.Get('fret_diff_vote_hint'), difficultyMax)
		Utilities:Print(msg, MSG_GOOD)
		isVotingOpened = true
	end

	local announcementList = Localization.Get('fretbots_wel_msgs')
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
	if isVoteForAllyScale then
		local allyScale
		-- edge case: no one voted
		if #VotedDifficulties == 0 then
			allyScale = DefaultAllyScale
		-- otherwise, average the votes
		else
			local total = 0
			for _, value in ipairs(VotedDifficulties) do
				total = total + value
			end
			allyScale = total / #VotedDifficulties
			allyScale = Utilities:Round(allyScale, 3)
		end

		local msg = Localization.Get("fret_ally_scale_ended")..allyScale
		Debug:Print(msg)
		Utilities:Print(msg, MSG_GOOD)
		Settings.allyScale = allyScale

		Chat:SendHttpRequest('start', Utilities:GetPInfo(), Chat.StartCallback)
		return
	end

	local difficulty
	-- edge case: no one voted
	if #VotedDifficulties == 0 then
		difficulty = DefaultDifficulty
	-- otherwise, average the votes
	else
		local total = 0
		for _, value in ipairs(VotedDifficulties) do
			total = total + value
		end
		difficulty = total / #VotedDifficulties
		difficulty = Utilities:Round(difficulty, 1)
	end

	local msg = Localization.Get("fret_diff_selected")..difficulty
	Debug:Print(msg)
	Utilities:Print(msg, MSG_GOOD)
	Settings:Initialize(difficulty)
	Settings.difficulty = difficulty

	-- Vote again for ally bot difficulty scale.
	if Customize.Fretbots.Allow_To_Vote and IsTimeToVoteForAllyBonusScale() then
		isVoteForAllyScale = true
		isVotingClosed = false
		Settings.voteEndState = DOTA_GAMERULES_STATE_GAME_IN_PROGRESS
		Settings.voteEndTime = 30
		votingTimeElapsed = -1
		VotedDifficulties = {}
		numVotes = 0
		playerVoted = {}

		msg = Localization.Get('fret_ally_scale_open')..tostring(DefaultAllyScale)
		Utilities:Print(msg, MSG_WARNING)
		msg = string.format(Localization.Get('fret_ally_vote_hint'), allyScaleMax)
		Utilities:Print(msg, MSG_WARNING)

		Timers:CreateTimer(settingsTimerName, {endTime = 1, callback =  Settings['DifficultySelectTimer']} )
	else
		Settings.allyScale = DefaultAllyScale
		Chat:SendHttpRequest('start', Utilities:GetPInfo(), Chat.StartCallback)
	end
end

-- Returns true if voting should close due to game state
function Settings:ShouldCloseVoting()
	-- voting ends immediately if we reach voteEndState
	local state =  GameRules:State_Get()
	if state > Settings.voteEndState then
		return true
	end
	if Settings.voteEndTime - votingTimeElapsed == 10 then
		if #VotedDifficulties <= 0 and (Settings.difficulty == DefaultDifficulty or not Settings.difficulty) and not isVoteForAllyScale then
			local msg = string.format(Localization.Get('fret_default_diff_hint'), DefaultDifficulty)
			Utilities:Print(msg, MSG_GOOD)
		end
	end

	-- Warn about impending closure if necessary
	Utilities:Warn(Settings.voteEndTime - votingTimeElapsed,
									Settings.voteWarnTimes,
									Localization.Get('fret_voting_ends'))
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
	local playerID, rawText, teamonly = Settings:GetChatEventData(event)
	-- Check to see if they're cheating
	if not Settings.allowPlayersToCheat then
		Settings:DoChatCheatParse(playerID, rawText)
	end
	-- Remove dashes (potentially)
	local text = Utilities:CheckForDash(rawText)
	text = Utilities:CheckForExcl(rawText)
	-- Handle votes if we're still in the voting phase
	if isSelectLocaleOpen then
		Settings:DoLocaleVoteParse(playerID, text)
	elseif isVotingOpened and not isVotingClosed then
		Settings:DoChatVoteParse(playerID, text)
	end

	Settings:OpenAIResponse(text, playerID, teamonly)

	-- if Settings have been chosen then monitor for commands to change them
	if Flags.isSettingsFinalized then
		-- Some commands are available for everyone
		Settings:DoUserChatCommandParse(text, playerID)
		if playerID == hostID then
			-- check for 'light' commands
			local isSuccess = Settings:DoSuperUserChatCommandParse(text)
			-- if not that, then try to pcall arbitrary text
			Utilities:PCallText(text)
		end
	end
end

local function startsWithExclamation(str)
	return str:sub(1, 1) == "!"
end

function Settings:OpenAIResponse(text, playerID, teamonly)
	-- TODO: should only response to player that talk to ALL players or to bots in the team. This is to avoid spamming when the players are talking to other players not to bots.

	-- do not handle team only message to avoid spamming.
	if teamonly == 1 then return end

	if not startsWithExclamation(text) then
		for _, player in ipairs(AllUnits) do
			if player.stats.id == playerID and not player.stats.isBot then
				-- local kda = player:GetKills()..'/'..player:GetDeaths()..'/'..player:GetAssists()
				Chat:SendMessageToBackend(text, { name = player.stats.name, game_difficulty = tostring(Settings.difficulty) .. ' out of ' .. Settings.difficultyMax,
					team = player.stats.team == 2 and 'Radiant' or 'Dire', steamId = tostring(player.stats.steamId) }) -- level = player:GetLevel(), kda = kda })
			end
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
	if command == 'goodsound' or command == 'gs' then
		Utilities:RandomSound(GOOD_LIST)
		return true
	end
	-- Random bad sound
	if command == 'badsound' or command == 'bs' then
		Utilities:RandomSound(BAD_LIST)
		return true
	end
	if command == 'enablecheat' then
		if id == hostID then
			Settings.allowPlayersToCheat = not Settings.allowPlayersToCheat
			Utilities:Print('Free to cheat: '..tostring(Settings.allowPlayersToCheat), MSG_GOOD)
		else
			Utilities:Print('Only the host of this game can enable cheat settings', MSG_WARNING)
		end
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
	-- print info
	if command == 'info' then
		Settings:DoDisplayNetWorth()
		local msg = Localization.Get('fret_select_diff')..tostring(Settings.difficulty)
		if Settings.allyScale ~= nil then
			msg = msg .. Localization.Get('fret_select_ally_scale') .. Settings.allyScale
		end
		Utilities:Print(msg, MSG_GOOD)
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
	if command == 'speak' or command == 'sp' then
		Settings:DoLocale(tokens)
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
	for team = 2, 3 do
	for _, bot in ipairs(AllBots[team]) do
		netWorth = PlayerResource:GetNetWorth(bot.stats.id)
		botTeamNetWorth = netWorth + botTeamNetWorth
		roundedNetWorth = Utilities:Round(netWorth, -2)
		roundedNetWorth = roundedNetWorth / 1000
		botMsg = Utilities:ColorString(bot.stats.name ..': '..tostring(roundedNetWorth)..'k', Utilities:GetPlayerColor(bot.stats.id))
		msg = msg..'  '..botMsg
	end
end
	Utilities:Print(msg)
	for _, player in ipairs(AllHumanPlayers) do
		netWorth = PlayerResource:GetNetWorth(player.stats.id)
		playerTeamNetWorth = netWorth + playerTeamNetWorth
	end
	roundedNetWorth = Utilities:Round(playerTeamNetWorth, -2)
	roundedNetWorth = roundedNetWorth / 1000
	msg = string.format(Localization.Get('fret_player_total_networth'), roundedNetWorth)
	Utilities:Print(msg, MSG_CONSOLE_GOOD)
	roundedNetWorth = Utilities:Round(botTeamNetWorth, -2)
	roundedNetWorth = roundedNetWorth / 1000
	msg = string.format(Localization.Get('fret_bot_total_networth'), roundedNetWorth)
	Utilities:Print(msg, MSG_CONSOLE_BAD)
end


-- Gets stats
function Settings:DoGetStats(tokens)
	-- tokens[2] will contain the stat to display
	local stat = tokens[2]
	for team = 2, 3 do
	for _, bot in ipairs(AllBots[team]) do
		local value = bot.stats.awards[stat]
		if value ~= nil then
			local msg = ''
			msg = msg..bot.stats.name..': '..stat..': '..value
			Utilities:Print(msg,MSG_CONSOLE_GOOD)
		end
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

function Settings:DoLocale(tokens)
	DynamicDifficulty:Reset()
	if tokens[2] ~= nil then
		local locale = tostring(tokens[2])
		Settings:ApplyLocale(locale)
	end
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
	if stringTarget == 'diff' then
		stringTarget = 'difficulty'
	end
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
			Utilities:Print('Set `'..stringTarget..'` successfully: '..
											Utilities:Inspect(value), MSG_CONSOLE_GOOD)
		-- Otherwise a literal
		else
			if Settings:SetValue(stringTarget, value) then
				Utilities:Print('Set `'..stringTarget..'` successfully: '..
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

function Settings:DoLocaleVoteParse(playerID, text)
	if playerID == hostID and Localization.Supported(text) then
		Settings:ApplyLocale(text)
	end
end

function Settings:ApplyLocale(locale)
	selectLocale = locale
	Customize.Localization = locale
	Utilities:Print('Set localization to: ' .. locale, MSG_CONSOLE_GOOD)
	Utilities:UpdateCasterLocale()
end

-- Parses chat message for valid settings votes and handles them.
function Settings:DoChatVoteParse(playerID, text)
	local min, max = 0, difficultyMax
	if isVoteForAllyScale then
		max = allyScaleMax
	end

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
			if difficulty > max then
				 difficulty = max
			elseif difficulty < min then
				difficulty = min
			end
			difficulty = Utilities:Round(difficulty, 1)
			-- save voted value
			table.insert(VotedDifficulties, difficulty)
			-- increment number of votes
			numVotes = numVotes + 1
			-- let players know the vote counted
			if isVoteForAllyScale then
				local msg = string.format(Localization.Get('fret_vote_for_ally'), PlayerResource:GetPlayerName(playerID), tostring(difficulty))
				Utilities:Print(msg, Utilities:GetPlayerColor(playerID))
			else
				local msg = string.format(Localization.Get('fret_vote_for'), PlayerResource:GetPlayerName(playerID), tostring(difficulty))
				Utilities:Print(msg, Utilities:GetPlayerColor(playerID))
			end
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
		if tokens[1] == 'difficulty' then
			Settings.difficulty = value
			Settings.difficultyScale = Settings:CalculateDifficultyScale(value)
			print('New difficulty: ' .. tostring(Settings.difficulty) .. '. New difficultyScale: ' .. tostring(Settings.difficultyScale))
		end
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
	local teamonly = event.teamonly
	return playerID, text, teamonly
end

-- this callback gets run once when game state enters DOTA_GAMERULES_STATE_HERO_SELECTION
-- this prevents us from attempting to get the number of players before they have all loaded
function Settings:InitializationTimer()
	-- Register settings vote timer and chat event monitor
	Debug:Print('Begining Settings Initialization.')
	Settings:RegisterChatEvent()
	Timers:CreateTimer(localeTimerName, {endTime = 1, callback =  Settings['LocaleSelectTimer']} )
end

--Don't run initialization until all players have loaded into the game.
-- I'm not sure if things like GetPlayerCount() track properly before this,
-- and am not willing to test since this facility is in place and is easier.
if not Flags.isSettingsInitialized then
	Utilities:RegsiterGameStateListener(Settings, 'InitializationTimer', DOTA_GAMERULES_STATE_HERO_SELECTION )
	Flags.isSettingsInitialized = true
end
