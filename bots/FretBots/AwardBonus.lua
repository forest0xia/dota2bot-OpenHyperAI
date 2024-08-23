-- Helpers to add bonuses to bots

-- Dependencies
require 'bots.FretBots.Settings'
require 'bots.FretBots.DataTables'
require 'bots.FretBots.Debug'
require 'bots.FretBots.Flags'
require 'bots.FretBots.GameState'
require 'bots.FretBots.Utilities'

-- local debug flag
local thisDebug = false;
local isDebug = Debug.IsDebug() and thisDebug;


-- Instantiate ourself
if AwardBonus == nil then
	AwardBonus = {}
end

-- constants for leveling
local xpPerLevel =
{
	0,
	230,
	600,
	1080,
	1660,
	2260,
	2980,
	3730,
	4620,
	5550,
	6520,
	7530,
	8580,
	9805,
	11055,
	12330,
	13630,
	14955,
	16455,
	18045,
	19645,
	21495,
	23595,
	25945,
	28545,
	32045,
	36545,
	42045,
	48545,
	56045
}

-- Gold
function AwardBonus:gold(bot, bonus)
	if bot.stats.awards.gold < Settings.awardCap.gold and bonus > 0 then
		PlayerResource:ModifyGold(bot.stats.id, bonus, false, 0)
		bot.stats.awards.gold = bot.stats.awards.gold + bonus
		Debug:Print('Awarding '..tostring(bonus)..' gold to '..bot.stats.name..'.')
		return true
	end
	return false
end

-- All stats
function AwardBonus:stats(bot, bonus)
	if bot.stats.awards.stats < Settings.awardCap.stats and bonus > 0 then
		-- clamp bonus
		local clamped = AwardBonus:Clamp(bonus, bot.stats.awards.stats, Settings.awardCap.stats)
		bot:ModifyStrength(clamped)
		bot:ModifyAgility(clamped)
		bot:ModifyIntellect(clamped)
		bot.stats.awards.stats = bot.stats.awards.stats + clamped
		Debug:Print('Awarding '..tostring(clamped)..' stats to '..bot.stats.name..'.')
		return true
	end
	return false
end

--Armor
function AwardBonus:armor(bot, bonus)
	if bot.stats.awards.armor < Settings.awardCap.armor and bonus > 0 then
		-- clamp bonus
		local clamped = AwardBonus:Clamp(bonus, bot.stats.awards.armor, Settings.awardCap.armor)
		local armor = bot:GetPhysicalArmorBaseValue()
		local base = bot:GetAgility() * (1/6)
		bot:SetPhysicalArmorBaseValue(armor - base + clamped)
		bot.stats.awards.armor = bot.stats.awards.armor + clamped
		Debug:Print('Awarding '..tostring(clamped)..' armor to '..bot.stats.name..'.')
		return true
	end
	return false
end

-- Magic Resist
function AwardBonus:magicResist(bot, bonus)
	if bot.stats.awards.magicResist < Settings.awardCap.magicResist and bonus > 0 then
		local clamped = AwardBonus:Clamp(bonus, bot.stats.awards.magicResist, Settings.awardCap.magicResist)
		local resistance
		resistance = bot:GetBaseMagicalResistanceValue()
		bot:SetBaseMagicalResistanceValue(resistance + clamped)
		bot.stats.awards.magicResist = bot.stats.awards.magicResist + clamped
		Debug:Print('Awarding '..tostring(clamped)..' magic resist to '..bot.stats.name..'.')
		return true
	end
	return false
end

-- Levels
function AwardBonus:levels(bot, levels)
	if bot.stats.awards.levels < Settings.awardCap.levels and levels > 0 then
		-- get current level and XP
		local currentLevel = PlayerResource:GetLevel(bot.stats.id)
		-- if bot is level 30, exit
		if currentLevel == 30 then
			Debug:Print(bot.stats.name..': Already level 30, cannot award levels.')
			return
		end
		local currentXP = bot:GetCurrentXP()
		local currentLevelXP = xpPerLevel[currentLevel]
		local targetLevel = math.ceil(levels)
		-- Sanity check
		local target = currentLevel + targetLevel
		if target > 30 then target = 30 end
		local targetLevelXP = xpPerLevel[target]
		-- get the average amount of experience per level difference
		local averageXP = (targetLevelXP - currentLevelXP) / targetLevel
		-- award average XP per level times levels
		local awardXP = Utilities:Round(averageXP * levels)
		bot:AddExperience(awardXP, 0, false, true)
		bot.stats.awards.levels = bot.stats.awards.levels + levels
		Debug:Print('Awarding '..tostring(levels)..' levels to '..bot.stats.name..'.')
		return true
	end
	return false
end

-- neutral
function AwardBonus:neutral(bot, bonus)
	if bot.stats.awards.neutral < Settings.awardCap.neutral then
		local tier = bot.stats.neutralTier + bonus
		local isSuccess
		bot.stats.neutralTiming = bot.stats.neutralTiming - bonus
		if bot.stats.neutralTiming < 0 then
			bot.stats.neutralTiming = 0
		end
		bot.stats.awards.neutral = bot.stats.awards.neutral + bonus
		--Debug:Print('Awarding neutral to '..bot.stats.name..'.')
		return true, bonus
	else
		Debug:Print('Bot has reached the neutral award limit of '..Settings.awardCap.neutral)
		return false
	end
end

-- XP
function AwardBonus:Experience(bot, bonus)
	if bonus > 0 then
		bot:AddExperience(bonus, 0, false, true)
		Debug:Print('Awarding '..tostring(bonus)..' experience to '..bot.stats.name..'.')
	end
end

-- Gives the bot his death awrds, if there are any
function AwardBonus:Death(bot)
	local awardsTable = {}
	table.insert(awardsTable, bot)
	-- Drop out for edge cases (LD bear, AW clone)
	if not DataTables:IsRealHero(bot) then
		Debug:Print(bot:GetName()..' is not a real hero unit. No Death Award given.')
		return
	end
	-- to be printed to players
	local msg = bot.stats.name .. ' Death Bonus Awarded:'
	local isAwarded = false
	local isLoudWarning = false
	-- accrue chances
	AwardBonus:AccruetDeathBonusChances(bot)
	-- track awards
	local awards = 0
	-- loop over bonuses in order
	for _, award in ipairs(Settings.deathBonus.order) do
		-- this event gets fired for humans too, so drop out here if we don't want to give rewards to humans
		if not bot.stats.isBot and Settings.deathBonus.isBotsOnly[award] then
			return
		end
		-- check if enabled
		if Settings.deathBonus.enabled[award] then
			local isAward = AwardBonus:ShouldAward(bot,award)
			-- increment awards if awarded
			if isAward then
				awards = awards + 1
			end
			-- if this award is greater than max, then break
			if awards > Settings.deathBonus.maxAwards then
				if isDebug then print(bot.stats.name..': Max awards of '..Settings.deathBonus.maxAwards..' reached.') end
				break
			end
			-- make the award
			if isAward then
				local value = 0
				local isLoud = false
				local isSuccess
				local name
				-- Get value
				value, isLoud  = AwardBonus:GetValue(bot, award)
				-- Sanity check
				if value <= 0 then break end
				-- Attempt to assign the award
				isSuccess, name = AwardBonus[award](AwardBonus, bot, value)
				-- if success, set isAwarded, isLoudWarning, Clear chance, Update message
				if isSuccess then
					if name == nil then
						table.insert(awardsTable, {award, value})
					else
						table.insert(awardsTable, {award, name})
					end
					isAwarded = true
					isLoudWarning = (isLoud or isLoudWarning)
					if name == nil then
						msg = msg .. ' '..award..': '..value
					else
						-- special case for neutrals, they return the name of the neutral
						msg = msg .. ' '..award..': '..name
					end
					if isDebug then
						--print(bot.stats.name..': Awarded '..award..': '..value)
					end
					-- Clear the chance for this award (if accrued)
					if Settings.deathBonus.accrue[award] then
						bot.stats.chance[award] = 0
					end
				end
			end
		end
	end
	if Settings.deathBonus.announce then
		if isAwarded and not isLoudWarning then
			Utilities:Print(awardsTable, MSG_AWARD, ATTENTION)
			--Utilities:Print(msg, MSG_WARNING, ATTENTION)
		elseif isAwarded and isLoudWarning then
			Utilities:Print(awardsTable, MSG_AWARD, BAD_LIST)
		 --Utilities:Print(msg, MSG_BAD, BAD_LIST)
		end
	end
end

-- Increments the chance of all accruing bonus awards
function AwardBonus:AccruetDeathBonusChances(bot)
	for _, award in pairs(Settings.deathBonus.order) do
		if bot.stats.chance[award] ~= nil and Settings.deathBonus.chance[award] ~= nil then
			if Settings.deathBonus.accrue[award] then
				bot.stats.chance[award] = bot.stats.chance[award] + Settings.deathBonus.chance[award]
			end
		end
	end
end

-- Returns a numerical value to award
function AwardBonus:GetValue(bot, award)
	local isLoud = false
	local dotaTime
	local debugTable = {}
	debugTable.award = award
	debugTable.range = {Settings.deathBonus.range[award][1], Settings.deathBonus.range[award][2]}
	-- base bonus is always the same
	local base = Utilities:RandomDecimal(Settings.deathBonus.range[award][1], Settings.deathBonus.range[award][2])
	debugTable.baseAward = base
	-- if range scaling is enabled, then scale
	if Settings.deathBonus.isRangeTimeScaleEnable then
		base = base * Utilities:GetTime() / Settings.deathBonus.rangeTimeScale[award]
		debugTable.rangeScale = Settings.deathBonus.rangeTimeScale[award]
	end
	--scale base by multiplier
	local variance = Utilities:GetVariance(Settings.deathBonus.variance[award])
	local roleScale = 1
	if Settings.deathBonus.scaleEnabled[award] then
		roleScale = Settings.deathBonus.scale[award][bot.stats.role]
	end
	local multiplier = AwardBonus:GetMultiplier(bot.stats.skill, roleScale, variance)
	local scaled = base * multiplier
	-- add offset
	scaled = scaled + Settings.deathBonus.offset[award]
	debugTable.scaled = scaled
	-- Round and maybe clamp
	local clamped = 0
	if Settings.deathBonus.clampOverride[award] then
		clamped = Utilities:Round(scaled, Settings.deathBonus.round[award])
	else
		-- base clamp
		local upperClamp = Settings.deathBonus.clamp[award][2]
		-- Perhaps scale upper clamp, if enabled
		if Settings.deathBonus.isClampTimeScaleEnable then
			dotaTime =  Utilities:GetTime()
			upperClamp = upperClamp * Utilities:GetTime() / Settings.deathBonus.clampTimeScale[award]
		end
		-- round clamp (adjustments are probably dumb decimals)
		upperClamp = Utilities:Round(upperClamp, Settings.deathBonus.round[award])
		debugTable.clamps = {Settings.deathBonus.clamp[award][1], upperClamp}
		local rounded = Utilities:Round(scaled, Settings.deathBonus.round[award])
		clamped = Utilities:Clamp(rounded, Settings.deathBonus.clamp[award][1], upperClamp)
		debugTable.rounded = rounded
	end
	-- Final check: don't award anything that would put them over the cap.
	if (bot.stats.awards[award] + clamped) >= Settings.awardCap[award] then
		clamped = Settings.awardCap[award] - bot.stats.awards[award]
	end
	-- Great! We did all the work.  Are the bots far enough ahead that we want to throttle?
	local throttle, botTeam = GameState:GetThrottle()
	if throttle ~= nil and bot.stats.team == botTeam then
		local preThrottle = clamped
		clamped = clamped * throttle
		clamped = Utilities:Round(clamped, Settings.deathBonus.round[award])
		Debug:Print(bot.stats.name..': Throttled '..award..' award: '..throttle..' * '..preThrottle)
	end
	debugTable.clamped = clamped
	-- set isLoud
	isLoud = (Settings.deathBonus.isClampLoud[award] and clamped == Settings.deathBonus.clamp[award][2])
					 or
					 Settings.deathBonus.isLoud[award]
	--Debug:DeepPrint(debugTable)
	return clamped, isLoud
end

-- Determines if an award should be given
function AwardBonus:ShouldAward(bot,award)
	-- trivial case
	if bot.stats.chance[award] >= 1 then
		if isDebug then print(bot.stats.name..': Chance for '..award..' was 1 or greater.') end
		return true
	end
	-- check timeGate
	local gameTime = Utilities:GetTime()
	if gameTime < Settings.deathBonus.timeGate[award] then
		local msg = ''
		msg = msg..bot.stats.name..': '..award
		msg = msg..' bonus not given because the time gate has not been met: '
		msg = msg..gameTime..', '.. Settings.deathBonus.timeGate[award]
		Debug:Print(msg)
		return false
	end
	-- Don't award if they're already at the cap
	if bot.stats.awards[award] >= Settings.awardCap[award] then
	return false
	end
	-- almost as trivial case: check if deathStreakThreshold is enabled
	if Settings.deathBonus.deathStreakThreshold >= 0 then
		if bot.stats.deathStreak >= Settings.deathBonus.deathStreakThreshold then
			if isDebug then print(bot.stats.name..': automatic '..award..' bonus due to death streak of '..bot.stats.deathStreak..'.') end
			return true
		end
	end
	-- otherwise roll for it
	local roll = math.random()
	local isAward = roll < bot.stats.chance[award]
	--Debug:Print('Death Award: '..award..': roll: '..roll..' chance: '..bot.stats.chance[award])
	return isAward
end

-- Returns total multiplier for the bonus
-- this is either strictly multiplicative, or additive
function AwardBonus:GetMultiplier(skill, scale, variance)
	local turboMultiplier = 1
	if Utilities:IsTurboMode() then -- turbo is too ez for players, in fact the higher difficulty in turbo the easier the game becomes. so so be making it harder for players.
		turboMultiplier = 1.5
	end
	if Settings.isMultiplicative then
		return skill * scale * variance * Settings.difficultyScale * turboMultiplier
	else
		return skill + scale + variance + Settings.difficultyScale + turboMultiplier - 3
	end
end

-- Returns amounts to award to achieve target GPM/XPM
function AwardBonus:GetPerMinuteBonus(bot, gpm, xpm)
	local botGPM = Utilities:Round(PlayerResource:GetGoldPerMin(bot.stats.id))
	bot.stats.netWorth = PlayerResource:GetNetWorth(bot.stats.id)
	local gpmBonus, debugTable = AwardBonus:GetSpecificPerMinuteBonus(bot, botGPM, gpm, Settings.gpm)
	local botXPM = Utilities:Round(PlayerResource:GetXPPerMin(bot.stats.id))
	local xpmBonus, debugTable = AwardBonus:GetSpecificPerMinuteBonus(bot, botXPM, xpm, Settings.xpm)

	if bot.newDeathXp ~= nil and bot:GetDeathXP() ~= bot.newDeathXp then
		bot:SetCustomDeathXP(bot.newDeathXp)
	end

	if Settings.difficulty >= 1 then
		-- 增加基础回蓝，按照难度和分钟数翻倍
		-- print('Enabled bots with extra regens for diffculty scale = '..Settings.difficultyScale)
		if Utilities:IsTurboMode() then
			bot:SetBaseManaRegen((0.4 + Settings.difficultyScale) * Utilities:GetAbsoluteTime() / 60)
		else
			bot:SetBaseManaRegen((0.2 + Settings.difficultyScale) * Utilities:GetAbsoluteTime() / 60)
		end
	end

	return gpmBonus, xpmBonus
end

-- determines an amount to award to reach a specifc per minute amount
function AwardBonus:GetSpecificPerMinuteBonus(bot, pmBot, roleTable, settings)
	local debugTable = {}
	-- Ensure there is a target amount for this bot
	if roleTable[bot.stats.role] == nil then
		-- In case no player with the same role, pick the first available player (first one, highest one)
		local idx = 1
		repeat
			roleTable[bot.stats.role] = roleTable[idx]
			idx = idx + 1
		until(roleTable[bot.stats.role] ~= nil or idx >= 5)
		-- Debug:Print(bot.stats.name..', with role '..bot.stats.role..', does not have a corresponding human player for the same role')

		-- -- return 0, 'No human counterpart for '..bot.stats.name..'.'
	end

	local scale = settings.scale[bot.stats.role]
	
	-- In case no human player detected at all or bonus below base line, just base on difficulty scale.
	local defaultScale = (100 - bot.stats.role * 10) * scale -- gpm or xpm
	if #AllBots[bot.stats.team] < 5 then -- less for human side bots
		defaultScale = defaultScale / 1.2
	end
	local baseLineBonus = Settings.difficulty * defaultScale
	if roleTable[bot.stats.role] == nil or roleTable[bot.stats.role] < baseLineBonus then
		-- Debug:Print(bot.stats.name..', with role '..bot.stats.role..' now use default per mins amount: '..pmPlayer..' based on difficulty: '..Settings.difficulty )
		roleTable[bot.stats.role] = baseLineBonus
	end

	-- counterparts PM
	local pmPlayer = roleTable[bot.stats.role]
	-- add offset to get the target
	local pmTarget = pmPlayer + settings.offset
	-- Get individual multipliers
	local skill = bot.stats.skill
	local variance = Utilities:GetVariance(settings.variance)
	-- Get total multiplier
	local multiplier = AwardBonus:GetMultiplier(skill, scale, variance) * 1.315
	-- multiply
	pmTarget = Utilities:Round(pmTarget * multiplier)
	-- if the bot is already better than this, do not give award
	if pmBot > pmTarget then
		return 0 , bot.stats.name..' is above the target PM: '..tostring(pmBot)..', '..tostring(pmTarget)
	end
	-- get PM difference
	local pmDifference = pmTarget - pmBot
	-- clamp?
	local pmClamped = 0
	if not settings.clampOverride then
		-- Adjust clamp per mintue
		local minutes =  Utilities:Round(Utilities:GetTime()/60)
		local adjustedClamp = settings.clamp[2]
		if settings.perMinuteScale ~= 0 then
			adjustedClamp = adjustedClamp + settings.perMinuteScale * minutes
		end
		pmClamped = Utilities:RoundedClamp(pmDifference, settings.clamp[1], adjustedClamp)
	else
		pmClamped = Utilities:Round(pmDifference)
	end
	-- Figure out how much gold this is to provide the bump
	local bonus = Utilities:Round(pmClamped * (Utilities:GetTime() / 60))
	-- New and Improved! Throttle if bots are too far ahead
	local throttle, botTeam = GameState:GetThrottle()
	if throttle ~= nil and bot.stats.team == botTeam then
		bonus = bonus * throttle
		bonus = Utilities:Round(bonus)
		Debug:Print(bot.stats.name..': Throttled award: '..pmBot..': '..throttle)
	end
	-- debug data
	debugTable.name = bot.stats.name
	debugTable.role = bot.stats.role
	debugTable.pmPlayer = pmPlayer
	debugTable.pmBot = pmBot
	debugTable.pmTarget = pmTarget
	debugTable.skill = skill
	debugTable.scale = scale
	debugTable.variance = variance
	debugTable.multiplier = multiplier
	debugTable.adjustedClamp = adjustedClamp
	debugTable.pmClamped = pmClamped
	debugTable.bonus = bonus
	return bonus, debugTable
end

-- Punishes humans for abusing bot AI to get kills before the horn around runes
function AwardBonus:PunishForAbuse()
	local state =  GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_PRE_GAME then
		local msg = 'Bot rune AI abuse is a bad idea!'
		Utilities:Print(msg, MSG_BAD, BAD_LIST)
		for team = 2, 3 do
			for _, bot in ipairs(AllBots[team]) do
				local awardsTable = {}
				table.insert(awardsTable, bot)
				local isSuccess = AwardBonus['levels'](AwardBonus, bot, 17)
				-- if success, set isAwarded, isLoudWarning, Clear chance, Update message
				if isSuccess then
					table.insert(awardsTable, {'levels', 17})
				end
				local isSuccess = AwardBonus['stats'](AwardBonus, bot, 25)
				-- if success, set isAwarded, isLoudWarning, Clear chance, Update message
				if isSuccess then
					table.insert(awardsTable, {'stats', 25})
				end
				Utilities:Print(awardsTable, MSG_AWARD, BAD_LIST)
			end
		end
	end
end

-- returns true if the award is at or past the award cap for a given bot
function AwardBonus:IsAwardCapped(bot, award)
	return Settings.deathBonus.awardCap[award]
end

-- returns the base armor value for this hero at their current level
function AwardBonus:GetBaseArmor(bot)
	-- obviously they aren't gaining the bonus from level 1
	local levelsGained = bot:GetLevel() - 1
	local agilityGain = bot.stats.agilityGain
	local gainedAgility = levelsGained * agilityGain
	local baseAgility = bot.stats.BaseAgility
   	local baseArmor = bot.stats.baseArmor
   	local armor = baseArmor + ((baseAgility + gainedAgility) / 6)
   	return armor
end

-- Clamps a number to a max level
function AwardBonus:Clamp(bonus, awarded, max)
	local maxBonus = max - awarded
	if bonus > maxBonus then
		return maxBonus
	end
	return bonus
end

-- Returns the base strength, gained strength of this unit at their current level, and strength awarded
function AwardBonus:GetStrength(unit)
	local levelsGained = unit:GetLevel() - 1
	local statGained = levelsGained * unit.stats.strengthGain
	local baseStrength = unit.stats.baseStrength
	local awards =  unit.stats.awards.stats
   	return baseStrength, statGained, awards
end

-- Returns the base agility, gained agility of this unit at their current level, and agility awarded
function AwardBonus:GetAgility(unit)
	local levelsGained = unit:GetLevel() - 1
	local statGained = levelsGained * unit.stats.AgilityGain
	local baseAgility = unit.stats.baseAgility
	local awards =  unit.stats.awards.stats
   	return baseAgility, statGained, awards
end

-- Returns the base intellect, gained intellect of this unit at their current level, and intellect awarded
function AwardBonus:GetIntellect(unit)
	local levelsGained = unit:GetLevel() - 1
	local statGained = levelsGained * unit.stats.intellectGain
   	local baseIntellect = unit.stats.baseIntellect
   	local awards =  unit.stats.awards.stats
   	return baseIntellect, statGained, awards
end

-- returns the base armor value for this unit at their current level
function AwardBonus:GetBaseArmor(unit)
	-- unit.stats.baseArmor had the gain from the base already, so only calculate from statGained and awards
	local strengthGained
	local strengthAwards
	_, strengthGained, strengthAwards = AwardBonus:GetStrength(unit)
   	local armor = unit.stats.baseArmor + ((strengthGained + strengthAwards) / 6)
   	return armor
end

-- returns the base armor value for this unit at their current level
function AwardBonus:GetBaseMagicResist(unit)
	-- unit.stats.baseMagicResist had the gain from the base already, so only calculate from statGained and awards
	local intGained
	local intAwards
	_, intGained, intAwards = AwardBonus:GetIntellect(unit)
   	local magicResist = unit.stats.baseMagicResist + ((intGained + intAwards) * 0.1) + unit.stats.awards.magicResist
    local msg = ''
    msg = msg..'Base MR: '..tostring(Utilities:Round(unit.stats.baseMagicResist))..'  '
    msg = msg..'MR from Int: '..tostring(Utilities:Round(((intGained + intAwards) * 0.1)))..'  '
    msg = msg..'MR from Awards: '..tostring(Utilities:Round(unit.stats.awards.magicResist))..'  '
    msg = msg..'Adjusted MR: '..tostring(Utilities:Round(magicResist))..'  '
    Utilities:Print(msg, MSG_GOOD)
   	return magicResist
end