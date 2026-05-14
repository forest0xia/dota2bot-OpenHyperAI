local bot = GetBot()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not string.find(bot:GetUnitName(), "hero") or bot:IsIllusion() then return end

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )

local PING_RECENCY = 8        -- respond to pings within this many seconds
local ASSEMBLE_DURATION = 5    -- stay in assemble mode for this long after ping
local ASSEMBLE_DESIRE = 0.85   -- desire value when assembling
local ARRIVE_RADIUS = 500      -- close enough to ping location
local MAX_RESPOND_DIST = 3200  -- only respond if within this distance

local assembleLoc = nil
local assembleExpireTime = 0

function GetDesire()
	if not bot:IsAlive() then return BOT_MODE_DESIRE_NONE end

	-- Check for recent human normal pings (not danger pings)
	local human, ping = J.GetHumanPing()
	if human ~= nil and ping ~= nil
	and ping.normal_ping
	and ping.time ~= 0
	and GameTime() - ping.time < PING_RECENCY
	then
		local dist = GetUnitToLocationDistance(bot, ping.location)
		-- Only respond if we're not already very close and not too far away
		if dist > ARRIVE_RADIUS and dist < MAX_RESPOND_DIST then
			assembleLoc = ping.location
			assembleExpireTime = GameTime() + ASSEMBLE_DURATION
			J.ModeAnnounce(bot, 'say_assemble', ASSEMBLE_DURATION)
			return ASSEMBLE_DESIRE
		end
	end

	-- Continue moving to assembly point if still active
	if assembleLoc ~= nil and GameTime() < assembleExpireTime then
		local dist = GetUnitToLocationDistance(bot, assembleLoc)
		if dist <= ARRIVE_RADIUS then
			assembleLoc = nil
			return BOT_MODE_DESIRE_NONE
		end
		return ASSEMBLE_DESIRE
	end

	assembleLoc = nil
	return BOT_MODE_DESIRE_NONE
end

function OnEnd()
	assembleLoc = nil
	assembleExpireTime = 0
end

function Think()
	if J.CanNotUseAction(bot) then return end
	if assembleLoc == nil then return end

	local dist = GetUnitToLocationDistance(bot, assembleLoc)
	if dist <= ARRIVE_RADIUS then
		assembleLoc = nil
		return
	end

	bot:Action_MoveToLocation(assembleLoc)
end
