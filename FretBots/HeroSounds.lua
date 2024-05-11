-- Dependencies
require 'Fretbots.Utilities'
VoTypes				= dofile('Fretbots.VoiceoverTypes')
VoAttitudes 		= dofile('Fretbots.VoiceoverAttitudes')
VoHeroes			= dofile('Fretbots.VoiceoverHeroes')
-- This needs to happen after the above because HeroSoundsTable references the above as globals
local heroSounds	= dofile('Fretbots.HeroSoundsTable')

-- Instantiate the class
if HeroSounds == nil then
	HeroSounds = class({})
end

-- Attempts to play a hero sound by name. Returns false if this did not work.
function HeroSounds:PlaySoundByName(hero, soundName)
	-- longstanding tradtion has our sounds in all caps, help the player out here

	local success, result = pcall(function()
        local name = string.upper(soundName)
		if (heroSounds[hero] ~= nil) then
			local sounds = heroSounds[hero]
			if (sounds[name] ~= nil) then
				return HeroSounds:TryPlaySound(sounds[name])
			end
			return false
		end
		return false
    end)
	
	return success
end

-- Attempts to play a random sound that matches the attribute passed
function HeroSounds:PlaySoundByAttribute(hero, attributeValue)
	local success, result = pcall(function()
        local soundList = {}
		local attribute = string.upper(attributeValue)
		if (heroSounds[hero] ~= nil) then
			local sounds = heroSounds[hero]
			for _, sound in pairs(sounds) do
				if (HeroSounds:MatchesAttribute(sound, attribute)) then
					if (sound.sound ~= nil) then
						table.insert(soundList, sound.sound)
					end
				end
			end
			local size = Utilities:GetTableSize(soundList)
			if (size > 0) then
				Utilities:TestSound(soundList[math.random(size)])
			end
		end
    end)

	return success
end

-- Attempts to play a random sound that matches the attribute passed
function HeroSounds:PlayRandomSound(hero)
	local success, result = pcall(function()
        if (hero == nil) then
			return
		end
		if (heroSounds[hero] ~= nil) then
			local sounds = heroSounds[hero]
			local size = Utilities:GetTableSize(sounds)
			local sound = Utilities:RandomTableEntry(sounds)
			if (sound ~= nil) then
				HeroSounds:TryPlaySound(sound)
			end
		end
    end)
	return success
end


-- Determines if a sound matches an attribute
function HeroSounds:MatchesAttribute(sound, attribute)
	-- Sanity checks: Ensure sound is a table with the proper entries
	local success, result = pcall(function()
        if (type(sound) ~= 'table') then
			return false
		end
		if (VoAttitudes[attribute] ~= nil) then
			if (sound.attitude ~= nil) then
				if (type(sound.attitude ) ~= 'table') then
					return sound.attitude == VoAttitudes[attribute]
				else
					for _, item in pairs(sound.attitude) do
						if (item == VoAttitudes[attribute]) then
							return true
						end
					end
				end
			end
		end
		if (VoTypes[attribute] ~= nil) then
			if (sound.type ~= nil) then
				if (type(sound.type ) ~= 'table') then
					return sound.type == VoTypes[attribute]
				else
					for _, item in pairs(sound.type) do
						if (item == VoTypes[attribute]) then
							return true
						end
					end
				end
			end
		end
    end)
	return result
end

-- Attempts to translate an argument into a hero name
function HeroSounds:ParseHero(argument)
	local success, result = pcall(function()
        -- just to be fun and inconsistent, all of the hero aliases are lowercase
		local arg = string.lower(argument)
		if (VoHeroes[arg] ~= nil) then
			return VoHeroes[arg]
		else
			return nil
		end
    end)
	return result
end

-- Attempts to get a sound name from a sound entry
function HeroSounds:GetSoundName(sound)
	local success, result = pcall(function()
		-- if the entry is a table, it should have a .sound
		if (type(sound) == 'table') then
			return sound.sound
		else
			-- Otherwise, assume the value is the sound path
			-- clearly they need to get this right or TestSound will crash dota
			return sound
		end
    end)
	return result
end

-- Attempts to play a sound
function HeroSounds:TryPlaySound(sound)
	local success, result = pcall(function()
		local name = HeroSounds:GetSoundName(sound)
		if (name ~= nil) then
			Utilities:TestSound(name)
			return true
		end
    end)
	return success
end

