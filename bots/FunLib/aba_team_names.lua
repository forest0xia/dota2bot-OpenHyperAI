local Dota2Teams = {}

-- List should have a least 4 teams for better performance.
local defaultTeams = {
    AzureRay = {"Eurus", "Paparazi", "Yang", "Fade", "Dy"},
    TSpirit = {"Yatoro雨", "TORONTOTOKYO", "Collapse", "Mira", "Miposhka"},
    Liquid = {"miCKe", "MATUMBAMAN", "qojqva", "Boxi", "Insania"},
    OG = {"ana", "Topson", "Ceb", "N0tail", "JerAx"},
    Nigma = {"Miracle-", "w33", "MinD_ContRoL", "KuroKy", "GH"},
    Secret = {"Nisha", "MATUMBAMAN", "zai", "Puppey", "YapzOr"},
    VirtusPro = {"RAMZES666", "No[o]ne", "9pasha", "Solo", "RodjER"},
    Fnatic = {"Raven", "Abed", "iceiceice", "DJ", "Jabz"},
    PSG_LGD = {"Ame", "Somnus丶M", "Chalice", "Fy", "xNova"},
    Aster = {"Monet", "Ori", "Xxs", "BoBoKa", "LaNm"}
}

-- Keep track of picked teams
local pickedTeams = {}

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
    local mody = teamType == "Radiant" and 2 or 3
    
    if overrides and #overrides > 0 then
        playerList = overrides
        teamName = teamType
    else
        repeat
            randomNum = RandomInt(1, #availableTeams)
            teamName = table.remove(availableTeams, randomNum)
        -- ensure a team can only pick from certain team names.
        until not pickedTeams[teamName] and math.fmod(randomNum, 2) == (mody - 2)
        pickedTeams[teamName] = true
        playerList = defaultTeams[teamName]
    end

    shuffle(playerList)
    local team = {}
    for i = 1, 5 do
        if overrides and #overrides > 0 then
            table.insert(team, table.remove(playerList, 1))
        else
            table.insert(team, teamName .. "." .. table.remove(playerList))
        end
    end
    return team
end

-- Example of overrides arg with specific player names for Radiant:
-- local playerNameOverrides = {
--     Radiant = {"p1", "p2", "p3", "p4", "p5"}
-- }
function Dota2Teams.generateTeams(overrides)
    local availableTeams = {}
    for teamName, _ in pairs(defaultTeams) do
        table.insert(availableTeams, teamName)
    end

    shuffle(availableTeams)

    local radiantOverrides = overrides and overrides.Radiant or {}
    local direOverrides = overrides and overrides.Dire or {}

    local radiantTeam = generateTeam(availableTeams, radiantOverrides, "Radiant")
    local direTeam = generateTeam(availableTeams, direOverrides, "Dire")

    return {
        Radiant = radiantTeam,
        Dire = direTeam
    }
end

return Dota2Teams
