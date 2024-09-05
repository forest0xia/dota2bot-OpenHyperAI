local json = require('bots.FretBots.dkjson')
local heroNames = require('bots.FretBots.HeroNames')
require 'bots.FretBots.Utilities'
require 'bots.FretBots.Timers'

local Chat = { }
-- OpenAI ApiKey
local API_KEY = ''

local recordedMessages = {}
local maxpromptsLength = 3
local inGameBots = {}
local countErrorMsg = 0
local chatTimerName = "chat"
local chatVersionDetermineTime = -45

function Chat:SendMessageToBackend(inputText, playerInfo)
    local inputContent
    if playerInfo ~= nil then
        inputContent = {player = playerInfo, said = inputText } -- 'At game time '..tostring(math.floor(GameRules:GetGameTime()))..'s, player:'..json.encode(playerInfo)..' says: '..inputText
    end
    local inputData = ConstructChatBotRequest(json.encode(inputContent))
    Chat:SendHttpRequest('chat', inputData)
end

function Chat:SendHttpRequest(api, inputData, callback)
    local jsonString = json.encode(inputData)

    -- local request = CreateHTTPRequest("POST", "http://127.0.0.1:5000/"..api)
    local request = CreateHTTPRequest("POST", "https://chatgpt-with-dota2bot.onrender.com/"..api)
    request:SetHTTPRequestHeaderValue("Content-Type", "application/json")
    request:SetHTTPRequestRawPostBody("application/json", jsonString)
    request:SetHTTPRequestHeaderValue("Authorization", API_KEY)

    request:Send(function(response)
        local res = response.Body

        if response.StatusCode == 200 then
            local success, resJsonObj = pcall(function() return json.decode(res) end)
            if success and resJsonObj and resJsonObj.error then
                handleFailMessage(resJsonObj.error.type .. " : " .. resJsonObj.error.message .. " " .. tostring(resJsonObj.error.code), false)
            else
                handleResponseMessage(jsonString, res)
                if callback then callback(resJsonObj) end
            end
        else
            local success, resJsonObj = pcall(function() return json.decode(res) end)
            if success and resJsonObj and resJsonObj.error then
                handleFailMessage('Error: ' .. resJsonObj.message, true)
            else
                handleFailMessage('Error occurred! Please try again later.', false)
            end
        end
    end)
end

function Chat.StartCallback(resJsonObj)
	if resJsonObj.updates_behind > 0 then
        print('Script is out of date.')
        Timers:CreateTimer(chatTimerName, {endTime = 1, callback = Chat['NotifyUpdate']} )
    end
end

function Chat:NotifyUpdate()
	local gameTime = Utilities:GetAbsoluteTime()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME and gameTime > chatVersionDetermineTime then
        Utilities:Print('New version of the script is available! Feel free to update your script later. Check out Open Hyper AI (OHA) Workshop page if you need help.', MSG_WARNING)
		Timers:RemoveTimer(chatTimerName)
        return nil
    end
	return 1
end

local function botNameListInTheGame()
    inGameBots = {}
    for i, unit in pairs(AllUnits) do
        if unit.stats.isBot then
            -- local kda = unit:GetKills()..'/'..unit:GetDeaths()..'/'..unit:GetAssists()
            table.insert(inGameBots, {team = unit.stats.team == 2 and 'Radiant' or 'Dire', name = unit.stats.name, }) -- level = unit:GetLevel(), kda = kda})
        end
    end
end

function ConstructChatBotRequest(inputContent)
    -- if next(inGameBots) == nil then botNameListInTheGame() end -- only load bots once to save cpu.
    botNameListInTheGame()

    table.insert(recordedMessages, 1, { role = "user", content = 'Bot players in this game:' .. json.encode(inGameBots)})
    table.insert(recordedMessages, { role = "user", content = inputContent })

    -- Initialize data table
    local data = { prompts = {} }

    -- Copy global messages into data.prompts
    for _, message in ipairs(recordedMessages) do
        table.insert(data.prompts, message)
    end

    if #data.prompts > maxpromptsLength then
        for i = 1, #data.prompts - maxpromptsLength - 1 do
            table.remove(data.prompts, 2)
        end
    end

    -- for _, prompt in ipairs(data.prompts) do
    --     print('prompt='..tostring(prompt.content))
    -- end
    return data
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

function handleFailMessage(message, isBotSay)
    print("API Failure: " .. message)
    countErrorMsg = countErrorMsg + 1
    if isBotSay and countErrorMsg <= 2 then
        local aBot = getRandomBot()
        if aBot ~= nil then
            Say(aBot, message, false)
        end
    else
        print("[ERROR] Cannot get valid repsonse from Chat server. Hide the errors to avoid spams.")
    end
    if countErrorMsg >= 5 then
        -- Reset count every 5 times so users can get re-notified about the error.
        countErrorMsg = 0
    end
end

function handleResponseMessage(inputText, message)
    -- print("API Response: " .. message)
    local foundBot = false
    local aiText, heroHame = splitHeroNameFromMessage(message)
    
    if heroHame then
        for team = 2, 3 do
            for _, bot in ipairs(AllBots[team]) do
                if bot.stats.isBot and bot.stats.internalName == heroHame then
                    Say(bot, aiText, false)
                    foundBot = true
                end
            end
        end
    end
    if not heroHame then
        return
    end

    if not foundBot then
        local aBot = getRandomBot()
        if aBot ~= nil then
            Say(aBot, aiText, false)
        end
    end
    
    table.insert(recordedMessages, { role = "assistant", content = message })
end

return Chat