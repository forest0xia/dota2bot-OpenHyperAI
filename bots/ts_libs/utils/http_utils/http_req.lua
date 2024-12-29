--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__Class(self)
    local c = {prototype = {}}
    c.prototype.__index = c.prototype
    c.prototype.constructor = c
    return c
end
-- End of Lua Library inline imports
local ____exports = {}
--- In game Http request layer.
-- 
-- Will be used to:
-- 1. Interact with backend services enpowered with machine learning AI. ML AI is the way out.
-- 2. Dynamically load hero builds from 3rd party sources like dotabuff in game.
-- 
-- Please feel very welcome to help us utilize the existing functionality to build more challenging bots!
local JSON = require(GetScriptDirectory().."/ts_libs/utils/json")
____exports.Request = __TS__Class()
local Request = ____exports.Request
Request.name = "Request"
function Request.prototype.____constructor(self)
end
function Request.HttpPost(self, postData, api, callback)
    if self.UUID ~= nil then
        return ____exports.Request:RawPostRequest((____exports.Request.BASE_URL .. "/") .. api, callback, postData)
    else
        return self:GetUUID(callback)
    end
end
function Request.GetUUID(self, callback)
    return ____exports.Request:RawPostRequest(____exports.Request.BASE_URL .. "/uuid", callback)
end
function Request.RawPostRequest(self, url, callback, postData)
    local reqData = JSON.encode(postData)
    local req = CreateRemoteHTTPRequest(url)
    req:SetHTTPRequestRawPostBody("application/json", reqData)
    req:Send(function(result)
        print((("Raw " .. url) .. " Result: ") .. tostring(result))
        local resultData = JSON.decode(result)
        print("Jsonified result: " .. tostring(resultData))
        if callback then
            callback(result)
        end
    end)
    return req
end
function Request.RawGetRequest(self, url, callback)
    local req = CreateRemoteHTTPRequest(url)
    req:Send(function(result)
        print((("Raw " .. url) .. " Result: ") .. tostring(result))
        if callback then
            callback(result)
        end
    end)
    return req
end
Request.UUID = nil
Request.BASE_URL = "http://127.0.0.1:5000/"
return ____exports
