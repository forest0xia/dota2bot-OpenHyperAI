local X = {}

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local RolesMap = require( GetScriptDirectory()..'/FunLib/aba_hero_roles_map' )
local EnemyRoles = require( GetScriptDirectory()..'/FunLib/enemy_role_estimation' )

----------------------------------------------------------------------------------------------------

-- The index in the list is the pick order, value is the role.
-- X.roleAssignment = { 2, 3, 1, 5, 4 }
X.roleAssignment = {
	TEAM_RADIANT = { 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5 },
	TEAM_DIRE = { 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5 }
}

X['invisHeroes'] = {
	['npc_dota_hero_templar_assassin'] = 1,
	['npc_dota_hero_clinkz'] = 1,
	['npc_dota_hero_mirana'] = 1,
	['npc_dota_hero_riki'] = 1,
	['npc_dota_hero_nyx_assassin'] = 1,
	['npc_dota_hero_bounty_hunter'] = 1,
	['npc_dota_hero_invoker'] = 1,
	['npc_dota_hero_sand_king'] = 1,
	['npc_dota_hero_treant'] = 1,
--	['npc_dota_hero_broodmother'] = 1,
	['npc_dota_hero_weaver'] = 1
}

function X.IsCarry( hero )
	return RolesMap.IsCarry( hero )
end
function X.IsDisabler( hero )
	return RolesMap.IsDisabler( hero )
end
function X.IsDurable( hero )
	return RolesMap.IsDurable( hero )
end
function X.HasEscape( hero )
	return RolesMap.HasEscape( hero )
end
function X.IsInitiator( hero )
	return RolesMap.IsInitiator( hero )
end
function X.IsJungler( hero )
	return RolesMap.IsJungler( hero )
end
function X.IsNuker( hero )
	return RolesMap.IsNuker( hero )
end
function X.IsSupport( hero )
	return RolesMap.IsSupport( hero )
end
function X.IsPusher( hero )
	return RolesMap.IsPusher( hero )
end
function X.IsRanged( hero )
	return RolesMap.IsRanged( hero )
end
function X.IsHealer( hero )
	return RolesMap.IsHealer( hero )
end

function X.IsMelee( attackRange )
	return attackRange <= 326
end

--OFFLANER
function X.CanBeOfflaner( hero )
	return RolesMap.IsInitiator( hero )
end

--MIDLANER
function X.CanBeMidlaner( hero )
	return RolesMap.IsCarry( hero )
end

--SAFELANER
function X.CanBeSafeLaneCarry( hero )
	return RolesMap.IsCarry( hero )
end

--SUPPORT
function X.CanBeSupport( hero )
	return RolesMap.IsSupport( hero )
end

function X.GetCurrentSuitableRole( bot, hero )

	local lane = bot:GetAssignedLane()
	if X.CanBeSupport( hero ) and lane ~= LANE_MID
	then
		return "support"
	elseif X.CanBeMidlaner( hero ) and lane == LANE_MID
	then
		return "midlaner"
	elseif X.CanBeSafeLaneCarry( hero )
			and ( ( GetTeam() == TEAM_RADIANT and lane == LANE_BOT ) or ( GetTeam() == TEAM_DIRE and lane == LANE_TOP ) )
	then
		return "carry"
	elseif X.CanBeOfflaner( hero )
			and ( ( GetTeam() == TEAM_RADIANT and lane == LANE_TOP ) or ( GetTeam() == TEAM_DIRE and lane == LANE_BOT ) )
	then
		return "offlaner"
	else
		return "unknown"
	end

end

-- best guess for e.g. enemy heroes
function X.GetBestEffortSuitableRole(hero)
	if X.CanBeSupport(hero) then
		return 4
	elseif X.CanBeMidlaner(hero) then
		return 2
	elseif X.CanBeSafeLaneCarry(hero) then
		return 1
	elseif X.CanBeOfflaner(hero) then
		return 3
	else
		return 3
	end
end

function X.CountValue( hero, role )
	local highest = 0
	local TeamMember = GetTeamPlayers( GetTeam() )
	return highest
end

X['invisEnemyExist'] = false
local globalEnemyCheck = false
local lastCheck = -90

function X.UpdateInvisEnemyStatus( bot )

	if X['invisEnemyExist'] then return end

	if globalEnemyCheck == false
	then
		local players = GetTeamPlayers( GetOpposingTeam() )
		for i = 1, #players
		do
			if X["invisHeroes"][GetSelectedHeroName( players[i] )] == 1
			then
				X['invisEnemyExist'] = true
				break
			end
		end
		globalEnemyCheck = true
	elseif globalEnemyCheck == true
			and DotaTime() > 10 * 60
			and DotaTime() > lastCheck + 3.0
	then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE )
		if #enemies > 0
		then
			for i = 1, #enemies
			do
				if enemies[i] ~= nil
					and enemies[i]:CanBeSeen()
				then
					local SASlot = enemies[i]:FindItemSlot( "item_shadow_amulet" )
					local GCSlot = enemies[i]:FindItemSlot( "item_glimmer_cape" )
					local ISSlot = enemies[i]:FindItemSlot( "item_invis_sword" )
					local SESlot = enemies[i]:FindItemSlot( "item_silver_edge" )
					if SASlot >= 0 or GCSlot >= 0 or ISSlot >= 0 or SESlot >= 0
					then
						X['invisEnemyExist'] = true
						break
					end
				end
			end
		end
		lastCheck = DotaTime()
	end

end

X['supportExist'] = nil
function X.UpdateSupportStatus( bot )

	if X['supportExist']
	then
		return true
	end

	if X.GetPosition(bot) >= 4
	then
		X['supportExist'] = true
		return true
	end

	local TeamMember = GetTeamPlayers( GetTeam() )

	for i = 1, #TeamMember
	do
		local ally = GetTeamMember( i )
		if ally ~= nil
			and ally:IsHero()
			and X.GetPosition(ally) >= 4
		then
			X['supportExist'] = true
			return true
		end
	end

	return false

end

X['sayRate'] = false
function X.NotSayRate()
	return X['sayRate'] == false
end

X['sayJiDi'] = false
function X.NotSayJiDi()
	return X['sayJiDi'] == false
end

X['replyMemberID'] = nil
function X.GetReplyMemberID()

	if X['replyMemberID'] ~= nil then return X['replyMemberID'] end

	local tMemberIDList = GetTeamPlayers( GetTeam() )

	local nMemberCount = #tMemberIDList
	local nHumanCount = 0
	for i = 1, #tMemberIDList
	do
		if not IsPlayerBot( tMemberIDList[i] )
		then
			nHumanCount = nHumanCount + 1
		end
	end

	X['replyMemberID'] = tMemberIDList[RandomInt( nHumanCount + 1, nMemberCount )]

	return X['replyMemberID']

end


X['memberIDIndexTable'] = nil
function X.IsAllyMemberID( nID )

	if X['memberIDIndexTable'] == nil
	then
		local tMemberIDList = GetTeamPlayers( GetTeam() )
		if #tMemberIDList > 0
		then
			X['memberIDIndexTable'] = {}
			for i = 1, #tMemberIDList
			do
				X['memberIDIndexTable'][tMemberIDList[i]] = true
			end
		end
	end

	return X['memberIDIndexTable'][nID] == true

end


X['enemyIDIndexTable'] = nil
function X.IsEnemyMemberID( nID )

	if X['enemyIDIndexTable'] == nil
	then
		local tEnemyIDList = GetTeamPlayers( GetOpposingTeam() )
		if #tEnemyIDList > 0
		then
			X['enemyIDIndexTable'] = {}
			for i = 1, #tEnemyIDList
			do
				X['enemyIDIndexTable'][tEnemyIDList[i]] = true
			end
		else
			return false
		end
	end

	return X['enemyIDIndexTable'][nID] == true

end


X['sLastChatString'] = '-0'
X['sLastChatTime'] = -90
function X.SetLastChatString( sChatString )

	X['sLastChatString'] = sChatString
	X['sLastChatTime'] = DotaTime()

end

function X.ShouldTpToDefend()
	if X['sLastChatString'] == "-都来守家"
		and X['sLastChatTime'] >= DotaTime() - 10.0
	then
		return true
	end
	return false
end

X['fLastGiveTangoTime'] = -90

X['aegisHero'] = nil
function X.IsAllyHaveAegis()

	if X['aegisHero'] ~= nil
	   and X['aegisHero']:FindItemSlot( "item_aegis" ) < 0
	then X['aegisHero'] = nil end

	return X['aegisHero'] ~= nil

end


X['lastbbtime'] = -90
function X.ShouldBuyBack()
	return DotaTime() > X['lastbbtime'] + 1.0
end


X['lastFarmTpTime'] = -90
function X.ShouldTpToFarm()
	return DotaTime() > X['lastFarmTpTime'] + 4.0
end


X['lastPowerRuneTime'] = 90
function X.IsPowerRuneKnown()
	return math.floor( X['lastPowerRuneTime']/120 ) == math.floor( DotaTime()/120 )
end


X['campCount'] = 18
function X.GetCampCount()
	return X['campCount']
end


X['hasRefreshDone'] = true
function X.IsCampRefreshDone()
	return X['hasRefreshDone'] == true
end


X['availableCampTable'] = {}
function X.GetAvailableCampCount()
	return #X['availableCampTable']
end


X['nStopWaitTime'] = RandomInt( 3, 8 )
function X.GetRuneActionTime()
	return X['nStopWaitTime']
end

function X.GetPositionForCM(bot)
	local role

	if GetTeam() ~= bot:GetTeam() then
		role = EnemyRoles.GetEnemyPosition(bot:GetPlayerID())
		if role then
			return role
		end
		print('[WARNING] Cannot determine the role of an enemy bot. Return default pos as 3')
		print("Stack Trace:", debug.traceback())
		return 3
	end

	local lane = bot:GetAssignedLane()
	if lane == LANE_MID then
		role = 2
	elseif lane == LANE_TOP then
		if bot:GetTeam() == TEAM_RADIANT then
			if X.CanBeOfflaner(bot) then
				role = 3
			else
				role = 4
			end
		else
			if X.CanBeSafeLaneCarry(bot) then
				role = 1
			else
				role = 5
			end
		end
	elseif lane == LANE_BOT then
		if bot:GetTeam() == TEAM_RADIANT then
			if X.CanBeSafeLaneCarry(bot) then
				role = 1
			else
				role = 5
			end
		else
			if X.CanBeOfflaner(bot) then
				role = 3
			else
				role = 4
			end
		end
	end
	if role == nil then
		role = 1
		print('[ERROR] Failed to determine role for bot '..bot:GetUnitName()..' in CM. It got assigned lane#: '..lane..'. Set it to pos: '..tostring(role))
	end
	return role
end

function X.GetRoleFromId(bot)
	local heroID = GetTeamPlayers(GetTeam())
	for i, v in pairs(heroID) do
		if GetSelectedHeroName(v) == bot:GetUnitName() then
			local team = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
			return X.roleAssignment[team][i]
		end
	end
	return nil
end

HeroPositions = { }
-- returns 1, 2, 3, 4, or 5 as the position of the hero in the team
function X.GetPosition(bot)
	local role = bot.assignedRole
	if role == nil and GetGameMode() == GAMEMODE_CM then
		local nH, nB = Utils.NumHumanBotPlayersInTeam(bot:GetTeam())
		if nH == 0 then
			role = X.GetPositionForCM(bot)
		end
	end
	local unitName = bot:GetUnitName()
	local playerId = bot:GetPlayerID()
	if role == nil or GetGameState() == GAME_STATE_PRE_GAME then
		local cRole = HeroPositions[playerId]
		if cRole ~= nil then
			role = cRole
		else
			local heroID = GetTeamPlayers(GetTeam())
			for i, v in pairs(heroID) do
				if v == playerId then
					local team = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
					role = X.roleAssignment[team][i]
				end
			end
			cRole = role
		end
	end

	bot.assignedRole = role

	if GetTeam() ~= bot:GetTeam() then
		role = EnemyRoles.GetEnemyPosition(bot:GetPlayerID())
		print('[WARNING] Trying to get role for enemy. The estimated role is: '.. role .. ', for bot: ' .. bot:GetUnitName())
		if role then
			return role
		end
		print('[WARNING] Cannot determine the role of an enemy bot. Return default pos as 3')
		print("Stack Trace:", debug.traceback())
		return 3
	end

	if role == nil and GetGameState() ~= GAME_STATE_PRE_GAME then
		if HeroPositions[playerId] == nil then
			HeroPositions[playerId] = X.GetRoleFromId(bot)
		end
		-- fallback to use Captain mode logic to determine roles
		role = HeroPositions[playerId] ~= nil and HeroPositions[playerId] or X.GetPositionForCM(bot)
		print("[ERROR] Failed to match bot role for bot: "..unitName..', PlayerID: '..playerId..', set it to play pos: '..tostring(role))
		print("Stack Trace:", debug.traceback())
	end
	return role
end

function X.IsPvNMode()

	return X.IsAllShadow()

end

function X.IsAllShadow()

	return false

end

function X.GetHighestValueRoles( bot )

	local maxVal = - 1
	local role = ""

	print( "========="..bot:GetUnitName().."=========" )
	for key, value in pairs( X.hero_roles[bot:GetUnitName()] ) do
		print( tostring( key ).." : "..tostring( value ) )
		if value >= maxVal then
			maxVal = value
			role = key
		end
	end

	print( "Highest value role => "..role.." : "..tostring( maxVal ) )

end

return X