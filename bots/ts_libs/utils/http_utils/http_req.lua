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
local RawPostBodyRequest
function RawPostBodyRequest(url, callback, postData)
    local reqData = JSON:stringify(postData)
    local req = CreateRemoteHTTPRequest(url)
    req:SetHTTPRequestRawPostBody("application/json", reqData)
    req:Send(function(result)
        print((("Raw " .. url) .. " Result: ") .. tostring(result))
        if callback then
            callback(result)
        end
    end)
    return req
end
____exports.Request = __TS__Class()
local Request = ____exports.Request
Request.name = "Request"
function Request.prototype.____constructor(self)
end
function Request.HttpPost(self, postData, api, callback)
    if self.UUID ~= nil then
        return RawPostBodyRequest((____exports.Request.BASE_URL .. "/") .. api, callback, postData)
    else
        return self:GetUUID(callback)
    end
end
function Request.GetUUID(self, callback)
    return RawPostBodyRequest(____exports.Request.BASE_URL .. "/uuid", callback)
end
Request.UUID = nil
Request.BASE_URL = "https://OHA.com"
return ____exports
