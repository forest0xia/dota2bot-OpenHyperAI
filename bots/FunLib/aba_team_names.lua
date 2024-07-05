local Dota2Teams = {}

-- Keep track of picked teams
-- This actually will not work due to Dire and Radiant runs the script at the same time in different sand box so they don't share data, not even the global vars.
local pickedTeams = {}
local defaultPostfix = 'OHA' -- Open Hyper AI.

-- List should have a least 4 teams for better performance.
local defaultTeams = {
    Radiant = {
        AzureRay = {"Eurus", "Paparazi", "Yang", "Fade", "Dy"},
        TSpirit = {"Yatoro雨", "TORONTOTOKYO", "Collapse", "Mira", "Miposhka"},
        Liquid = {"miCKe", "MATUMBAMAN", "qojqva", "Boxi", "Insania"},
        OG = {"ana", "Topson", "Ceb", "N0tail", "JerAx"},
        Nigma = {"Miracle-", "w33", "MinD_ContRoL", "KuroKy", "GH"},
    },
    Dire = {
        Secret = {"Nisha", "MATUMBAMAN", "zai", "Puppey", "YapzOr"},
        VirtusPro = {"RAMZES666", "No[o]ne", "9pasha", "Solo", "RodjER"},
        Fnatic = {"Raven", "Abed", "iceiceice", "DJ", "Jabz"},
        PSG_LGD = {"Ame", "Somnus丶M", "Chalice", "Fy", "xNova"},
        Aster = {"Monet", "Ori", "Xxs", "BoBoKa", "LaNm"}
    }
}

local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = RandomInt(1, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

local function generateTeam(availableTeams, overrides, teamType)
    local teamName
    local playerList = {}
    local randomNum = 2
    
    if overrides and #overrides > 0 then
        playerList = overrides
        teamName = teamType
    else
        -- repeat
            randomNum = RandomInt(1, #availableTeams)
            teamName = table.remove(availableTeams, randomNum)
        -- -- ensure a team can only pick from certain team names.
        -- until not pickedTeams[teamName]
        -- pickedTeams[teamName] = true
        playerList = defaultTeams[teamType][teamName]
    end

    shuffle(playerList)
    local team = {}
    for i = 1, 5 do
        if overrides and #overrides > 0 then
            table.insert(team, table.remove(playerList, 1))
        else
            table.insert(team, teamName .. "." .. table.remove(playerList)..'.'..defaultPostfix)
        end
    end
    return team
end

-- Example of overrides arg with specific player names for Radiant:
-- local playerNameOverrides = {
--     Radiant = {"p1", "p2", "p3", "p4", "p5"}
-- }
function Dota2Teams.generateTeams(overrides)

    local currentTeams
    if GetTeam() == TEAM_RADIANT then
        currentTeams = defaultTeams.Radiant
    else
        currentTeams = defaultTeams.Dire
    end

    local availableTeams = {}
    for teamName, _ in pairs(currentTeams) do
        table.insert(availableTeams, teamName)
    end

    shuffle(availableTeams)

    local radiantOverrides = overrides and overrides.Radiant or {}
    local direOverrides = overrides and overrides.Dire or {}

    local radiantTeam, direTeam
    if GetTeam() == TEAM_RADIANT then
        radiantTeam = generateTeam(availableTeams, radiantOverrides, "Radiant")
    else
        direTeam = generateTeam(availableTeams, direOverrides, "Dire")
    end

    return {
        Radiant = radiantTeam,
        Dire = direTeam
    }
end

return Dota2Teams
