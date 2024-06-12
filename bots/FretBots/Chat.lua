local json = require('bots.FretBots.dkjson')
local heroNames = require('bots.FretBots.HeroNames')

-- OpenAI ApiKey
local API_KEY = ''

local recordedMessages = {}
local maxpromptsLength = 2

local inGameBots = {}
local function botNameListInTheGame()
    inGameBots = {}
    for i, unit in pairs(AllUnits) do
        if unit.stats.isBot then
            local kda = unit:GetKills()..'/'..unit:GetDeaths()..'/'..unit:GetAssists()
            table.insert(inGameBots, {team = unit.stats.team, name = unit.stats.name, level = unit:GetLevel(), kda = kda})
        end
    end
end

function ConstructRequest(text)
    -- if next(inGameBots) == nil then botNameListInTheGame() end -- only load bots once to save cpu.
    botNameListInTheGame()

    table.insert(recordedMessages, 1, { role = "user", content = 'Bot heroes in this game: ' .. json.encode(inGameBots)})
    table.insert(recordedMessages, { role = "user", content = text })

    -- Initialize data table
    local data = { prompts = {} }

    -- Copy global messages into data.prompts
    for _, message in ipairs(recordedMessages) do
        table.insert(data.prompts, message)
    end

    if #data.prompts > maxpromptsLength then
        for i = 1, #data.prompts - maxpromptsLength - 1 do
            table.remove(data.prompts, 1)
        end
    end

    -- for _, prompt in ipairs(data.prompts) do
    --     print('prompt='..tostring(prompt.content))
    -- end
    return data
end

function SendMessageToBackend(inputText, playerInfo)
    if playerInfo ~= nil then
        inputText = 'At game time '..tostring(math.floor(GameRules:GetGameTime()))..'s, player:'..json.encode(playerInfo)..' says: '..inputText
    end

    local jsonString = json.encode(ConstructRequest(inputText))
    -- local request = CreateHTTPRequest("POST", "http://127.0.0.1:5000/chat")
    local request = CreateHTTPRequest("POST", "https://chatgpt-dota2bot.onrender.com/chat")
    request:SetHTTPRequestHeaderValue("Content-Type", "application/json")
    request:SetHTTPRequestRawPostBody("application/json", jsonString)
    request:SetHTTPRequestHeaderValue("Authorization", API_KEY)

    request:Send(function(response)
        local res = response.Body
        local resFlag = true

        if response.StatusCode == 200 then
            local resJsonObj = nil
            local success, resJsonObj = pcall(function() return json.decode(res) end)
            if success and resJsonObj and resJsonObj.error then
                handleFailMessage(resJsonObj.error.type .. " : " .. resJsonObj.error.message .. " " .. tostring(resJsonObj.error.code))
                resFlag = false
            else
                handleResponseMessage(inputText, res)
            end

            if resFlag then
                table.insert(recordedMessages, { role = "assistant", content = res })
            end
        else
            handleFailMessage('Error occurred! Please try again later.')
        end
        
    end)
end

-- Helper functions
function handleFailMessage(message)
    print("API Failure: " .. message)
    -- Implement
end

local function getRandomBot()
    local val
	for team = 2, 3 do
    local temp = math.random(1, #AllBots[team])
    for idx, value in pairs(AllBots[team]) do
        val = value
        if idx == temp then
            return value
        end
    end
    end
    return val
end

local function splitHeroNameFromMessage(message)
    local hero_pattern = "(npc_dota_hero_[%w_]+)" 
    local before_hero, hero_name = message:match("^(.-)(" .. hero_pattern .. ")$")
    
    if before_hero and hero_name then
        return before_hero, hero_name
    else
        return message, nil  -- If no hero name is found, return the original message and nil
    end
end

function handleResponseMessage(inputText, message)
    -- print("API Response: " .. message)
    local foundBot = false
    local aiText, heroHame = splitHeroNameFromMessage(message)
    
    if heroHame then
        for _, bot in ipairs(AllUnits) do
            if bot.stats.isBot and bot.stats.internalName == heroHame then
                Say(bot, aiText, false)
                foundBot = true
            end
        end
    end
    if not foundBot or not heroHame then
        local aBot = getRandomBot()
        if aBot ~= nil then
            Say(aBot, aiText, false)
        end
    end
end
