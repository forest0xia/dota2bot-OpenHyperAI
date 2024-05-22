local json = require('bots.FretBots.dkjson')
local heroNames = require('bots.FretBots.HeroNames')

-- OpenAI ApiKey
local API_KEY = ''

local recordedMessages = {}
local maxpromptsLength = 12

function ConstructRequest(text)
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

function SendMessageToBackend(text)
    local jsonString = json.encode(ConstructRequest(text))
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
                handleResponseMessage(text, res)
            end

            if resFlag then
                table.insert(recordedMessages, { role = "assistant", content = res })
            end
        else
            handleFailMessage('Error occurred! Please try again later.')
        end
        
    end)
end

-- if any word in words contains a valid hero name that exist in the tableHeroes
function ContainsName(words, tableHeroes)
    -- Split the input string into words
    local function split(inputstr, sep)
        if sep == nil then
            sep = "%s"
        end
        local t = {}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
        end
        return t
    end

    -- List of words to ignore
    local ignoreWords = { npc = true, dota = true, hero = true }

    -- Get the list of words from the input string
    local wordList = split(words)

    -- Filtered list to check against tableHeroes keys
    local filteredWords = {}

    -- Iterate over the words and filter out ignored words
    for _, word in ipairs(wordList) do
        local lowerWord = string.lower(word)
        if not ignoreWords[lowerWord] then
            table.insert(filteredWords, lowerWord)
        end
    end

    -- Check if any filtered word is a key in tableHeroes
    for heroKey in pairs(tableHeroes) do
        for _, word in ipairs(filteredWords) do
            if string.find(heroKey, word) then
                return heroKey
            end
        end
    end

    -- Return nil if no match is found
    return nil
end

-- Helper functions
function handleFailMessage(message)
    print("API Failure: " .. message)
    -- Implement
end

local function getRandomBot(t)
    local temp = math.random(1, #Bots)
    local idx = 1
    local val
    for key, value in pairs(t) do
        val = value
        if idx >= temp then
            return value
        end
    end
    return val
end

function handleResponseMessage(inputText, message)
    print("API Response: " .. message)
    local relatedHero = ContainsName(inputText, heroNames)
    local foundBot = false
    if relatedHero then
        for _, bot in ipairs(AllUnits) do
            if bot.stats.isBot and bot.stats.internalName == relatedHero then
                print('Text mentions a hero in the bots in this game: '..relatedHero)
                Say(bot, message, false)
                foundBot = true
            end
        end
    end
    if not foundBot or not relatedHero then
        Say(getRandomBot(Bots), message, false)
    end
end
