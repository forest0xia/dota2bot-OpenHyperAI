------------------------------------------CAPTAIN'S MODE GAME MODE-------------------------------------------
local UnImplementedHeroes = {

};

local role = require( GetScriptDirectory()..'/FunLib/aba_role' )
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )

local X = { }
local ListPickedHeroes = {};
local AllHeroesSelected = false;
local BanCycle = 1;
local PickCycle = 1;
local NeededTime = 28;
local Min = 15;
local Max = 20;
local CMdebugMode = true;
local UnavailableHeroes = {
	"npc_dota_hero_techies"
}
local HeroLanes = {
	TEAM_RADIANT = {
		[1] = LANE_BOT,
		[2] = LANE_MID,
		[3] = LANE_TOP,
		[4] = LANE_TOP,
		[5] = LANE_BOT,
	},
	TEAM_DIRE = {
		[1] = LANE_TOP,
		[2] = LANE_MID,
		[3] = LANE_BOT,
		[4] = LANE_BOT,
		[5] = LANE_TOP,
	 }
};

local allBotHeroes = { }

local PairsHeroNameNRole = {
	TEAM_RADIANT = { },
	TEAM_DIRE = { }
};
local humanPick = {};

--Picking logic for Captain's Mode Game Mode
function X.CaptainModeLogic(SupportedHeroes)
	allBotHeroes = SupportedHeroes

	if (GetGameState() ~= GAME_STATE_HERO_SELECTION) then
		return
	end
	if not CMdebugMode then
		NeededTime = RandomInt(Min, Max);
		--end
	elseif CMdebugMode then
		NeededTime = 25;
	end
	if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then
		PickCaptain();
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= 20 and GetCMPhaseTimeRemaining() <= NeededTime then
		BansHero();
		NeededTime = 0
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and
		GetCMPhaseTimeRemaining() <= NeededTime then
		PicksHero();
		NeededTime = 0
	elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
		SelectsHero();
	end
end

--Pick the captain
function PickCaptain()
	if not IsHumanPlayerExist() or DotaTime() > -1 then
		if GetCMCaptain() == -1 then
			local CaptBot = GetFirstBot();
			if CaptBot ~= nil then
				print("CAPTAIN PID : " .. CaptBot)
				SetCMCaptain(CaptBot)
			end
		end
	end
end

--Check if human player exist in team
function IsHumanPlayerExist()
	local Players = GetTeamPlayers(GetTeam())
	for _, id in pairs(Players) do
		if not IsPlayerBot(id) then
			return true;
		end
	end
	return false;
end

--Get the first bot to be the captain
function GetFirstBot()
	local BotId = nil;
	local Players = GetTeamPlayers(GetTeam())
	for _, id in pairs(Players) do
		if IsPlayerBot(id) then
			BotId = id;
			return BotId;
		end
	end
	return BotId;
end

--Ban hero function
function BansHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end
	local BannedHero = RandomHero();
	print(tostring(BannedHero) .. " is banned")
	CMBanHero(BannedHero);
	BanCycle = BanCycle + 1;
end

--Pick hero function
function PicksHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end

	local sTeamName = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
	local PickedHero = RandomHero();
	if PickCycle == 1 then
		while not role.CanBeOfflaner(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[sTeamName][PickedHero] = "offlaner";
	elseif PickCycle == 2 then
		while not role.CanBeSupport(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[sTeamName][PickedHero] = "support";
	elseif PickCycle == 3 then
		while not role.CanBeMidlaner(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[sTeamName][PickedHero] = "midlaner";
	elseif PickCycle == 4 then
		while not role.CanBeSupport(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[sTeamName][PickedHero] = "support";
	elseif PickCycle == 5 then
		while not role.CanBeSafeLaneCarry(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[sTeamName][PickedHero] = "carry";
	end

	print(PickedHero .. " is picked")
	CMPickHero(PickedHero);
	PickCycle = PickCycle + 1;
end

--Add to list human picked heroes
function X.AddToList()
	if not IsPlayerBot(GetCMCaptain()) then
		for _, h in pairs(allBotHeroes) do
			if IsCMPickedHero(GetTeam(), h) and not AlreadyInTable(h) then
				table.insert(humanPick, h)
			end
		end
	end
end

--Check if selected hero already picked by human
function AlreadyInTable(hero_name)
	for _, h in pairs(humanPick) do
		if hero_name == h then
			return true
		end
	end
	return false
end

--Check if the randomed hero doesn't available for captain's mode
function IsUnavailableHero(name)
	for _, uh in pairs(UnavailableHeroes) do
		if name == uh then
			return true;
		end
	end
	return false;
end

--Check if a hero hasn't implemented yet
function IsUnImplementedHeroes(name)
	for _, unh in pairs(UnImplementedHeroes) do
		if name == unh then
			return true;
		end
	end
	return false;
end

--Random hero which is non picked, non banned, or non human picked heroes if the human is the captain
function RandomHero()
	local hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
	while (
		IsUnavailableHero(hero) or IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or
			IsCMBannedHero(hero)) do
		hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
	end
	return hero;
end

--Check if the human already pick the hero in captain's mode
function WasHumansDonePicking()
	local Players = GetTeamPlayers(GetTeam())
	for _, id in pairs(Players) do
		if not IsPlayerBot(id) then
			if GetSelectedHeroName(id) == nil or GetSelectedHeroName(id) == "" then
				return false;
			end
		end
	end
	return true;
end

--Select the rest of the heroes that the human players don't pick in captain's mode
function SelectsHero()
	if not AllHeroesSelected and (WasHumansDonePicking() or GetCMPhaseTimeRemaining() < 1) then
		local Players = GetTeamPlayers(GetTeam())
		local RestBotPlayers = {};
		GetTeamSelectedHeroes();

		for _, id in pairs(Players) do
			local hero_name = GetSelectedHeroName(id);
			if hero_name ~= nil and hero_name ~= "" then
				UpdateSelectedHeroes(hero_name)
				print(hero_name .. " Removed")
			else
				table.insert(RestBotPlayers, id)
			end
		end

		for i = 1, #RestBotPlayers do
			SelectHero(RestBotPlayers[i], ListPickedHeroes[i])
		end

		AllHeroesSelected = true;
	end
end

--Get the team picked heroes
function GetTeamSelectedHeroes()
	for _, sName in pairs(allBotHeroes) do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end
	end
	for _, sName in pairs(UnImplementedHeroes) do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end
	end
end

--Update team picked heroes after human players select their desired hero
function UpdateSelectedHeroes(selected)
	for i = 1, #ListPickedHeroes do
		if ListPickedHeroes[i] == selected then
			table.remove(ListPickedHeroes, i);
		end
	end
end

-------------------------------------------------------------------------------------------------------

---------------------------------------------------------CAPTAIN'S MODE LANE ASSIGNMENT------------------------------------------------
local doneLaneAssignementOnce = false
local roleAssignment, playerSwitchedRoles = { TEAM_RADIANT = {}, TEAM_DIRE = {} }, false
function X.CMLaneAssignment(roleAssign, switchedRoles)
	local sTeamName = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'

	roleAssignment = roleAssign -- TODO: role assignment to be improved
	-- playerSwitchedRoles = switchedRoles -- TODO: role assignment to be improved

	-- if playerSwitchedRoles then
	-- 	return roleAssignment[sTeamName]
	-- end

	-- if not doneLaneAssignementOnce then
	-- 	if not IsPlayerBot(GetCMCaptain()) then
	-- 		FillLAHumanCaptain()
	-- 	end
	-- 	FillLaneAssignmentTable();
	-- end

	if IsPlayerBot(GetCMCaptain()) then
		FillLaneAssignmentTable();
	else
		-- FillLAHumanCaptain()
	end
	return HeroLanes[sTeamName];
end

--Lane Assignment if the captain is not human
function FillLaneAssignmentTable()
	local TeamMember = GetTeamPlayers(GetTeam());
	local sTeamName = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
	local supportAlreadyAssigned = {
		TEAM_RADIANT = false,
		TEAM_DIRE = false
	};
	for i = 1, #TeamMember do
		local unit = GetTeamMember(i)
		if unit ~= nil and unit:IsHero() then
			local unit_name = unit:GetUnitName();
			if PairsHeroNameNRole[sTeamName][unit_name] == "support" then
				if GetTeam() == TEAM_RADIANT then
					if not supportAlreadyAssigned.TEAM_RADIANT then
						HeroLanes[sTeamName][i] = LANE_BOT;
						supportAlreadyAssigned.TEAM_RADIANT = true
						roleAssignment[sTeamName][i] = 5
					else
						HeroLanes[sTeamName][i] = LANE_TOP;
						roleAssignment[sTeamName][i] = 4
					end
				else
					if not supportAlreadyAssigned.TEAM_DIRE then
						HeroLanes[sTeamName][i] = LANE_TOP;
						supportAlreadyAssigned.TEAM_DIRE = true
						roleAssignment[sTeamName][i] = 5
					else
						HeroLanes[sTeamName][i] = LANE_BOT;
						roleAssignment[sTeamName][i] = 4
					end
				end
			elseif PairsHeroNameNRole[sTeamName][unit_name] == "midlaner" then
				HeroLanes[sTeamName][i] = LANE_MID;
				roleAssignment[sTeamName][i] = 2
			elseif PairsHeroNameNRole[sTeamName][unit_name] == "offlaner" then
				if GetTeam() == TEAM_RADIANT then
					HeroLanes[sTeamName][i] = LANE_TOP;
				else
					HeroLanes[sTeamName][i] = LANE_BOT;
				end
				roleAssignment[sTeamName][i] = 3
			elseif PairsHeroNameNRole[sTeamName][unit_name] == "carry" then
				if GetTeam() == TEAM_RADIANT then
					HeroLanes[sTeamName][i] = LANE_BOT;
				else
					HeroLanes[sTeamName][i] = LANE_TOP;
				end
				roleAssignment[sTeamName][i] = 1
			end
			doneLaneAssignementOnce = true
		end
	end
end

--Fill the lane assignment if the captain is human
local AvailableRoles = {
	TEAM_RADIANT = { "carry", "midlaner", "offlaner", "support1", "support2" },
	TEAM_DIRE = { "carry", "midlaner", "offlaner", "support1", "support2" }
}
function FillLAHumanCaptain()
	local sTeamName = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'
	local TeamMember = GetTeamPlayers(GetTeam());
	for i = 1, #TeamMember do
		if GetTeamMember(i) ~= nil and GetTeamMember(i):IsHero() then
			local unit_name = GetTeamMember(i):GetUnitName();
			local key = GetFromHumanPick(unit_name);
			if key ~= nil then
				if key == 1 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[sTeamName][i] = LANE_BOT;
					else
						HeroLanes[sTeamName][i] = LANE_TOP;
					end
					-- roleAssignment[sTeamName][i] = 3
				elseif key == 2 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[sTeamName][i] = LANE_BOT;
					else
						HeroLanes[sTeamName][i] = LANE_TOP;
					end
					-- roleAssignment[sTeamName][i] = 4
				elseif key == 3 then
					HeroLanes[i] = LANE_MID;
					roleAssignment[sTeamName][i] = 2
				elseif key == 4 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[sTeamName][i] = LANE_TOP;
					else
						HeroLanes[sTeamName][i] = LANE_BOT;
					end
					-- roleAssignment[sTeamName][i] = 5
				elseif key == 5 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[sTeamName][i] = LANE_TOP;
					else
						HeroLanes[sTeamName][i] = LANE_BOT;
					end
					-- roleAssignment[sTeamName][i] = 1
				end
			end
		end
	end
end

--Get human picked heroes if the captain is human player
function GetFromHumanPick(hero_name)
	local i = nil;
	for key, h in pairs(humanPick) do
		if hero_name == h then
			i = key;
		end
	end
	return i;
end

X.PairsHeroNameNRole = PairsHeroNameNRole

return X
