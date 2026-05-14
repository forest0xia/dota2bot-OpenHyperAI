import { GameState, HeroPickState, Lane, Team } from "bots/ts_libs/dota";
import { CanBeOfflaner, CanBeMidlaner, CanBeSupport, CanBeSafeLaneCarry } from "bots/FunLib/aba_role";
import { HeroName } from "bots/ts_libs/dota/heroes";

const UnImplementedHeroes: string[] = [];

interface PairsHeroMap {
    [heroName: string]: string;
}

interface TeamHeroRoleMap {
    [team: string]: PairsHeroMap;
}

let ListPickedHeroes: string[] = [];
let AllHeroesSelected = false;
let BanCycle = 1;
let PickCycle = 1;
let NeededTime = 28;
const Min = 15;
const Max = 20;
const CMdebugMode = true;

const UnavailableHeroes: string[] = ["npc_dota_hero_techies"];

const HeroLanes: { [team: string]: { [i: number]: number } } = {
    TEAM_RADIANT: {
        1: Lane.Bot,
        2: Lane.Mid,
        3: Lane.Top,
        4: Lane.Top,
        5: Lane.Bot,
    },
    TEAM_DIRE: {
        1: Lane.Top,
        2: Lane.Mid,
        3: Lane.Bot,
        4: Lane.Bot,
        5: Lane.Top,
    },
};

let allBotHeroes: HeroName[] = [];

export const PairsHeroNameNRole: TeamHeroRoleMap = {
    TEAM_RADIANT: {},
    TEAM_DIRE: {},
};

let humanPick: HeroName[] = [];

// Picking logic for Captain's Mode Game Mode
export function CaptainModeLogic(SupportedHeroes: HeroName[]) {
    allBotHeroes = SupportedHeroes;

    if (GetGameState() !== GameState.HeroSelection) {
        return;
    }

    if (!CMdebugMode) {
        NeededTime = RandomInt(Min, Max);
    } else if (CMdebugMode) {
        NeededTime = 25;
    }

    const state = GetHeroPickState();
    if (state === HeroPickState.CmCaptainPick) {
        PickCaptain();
    } else if (state >= HeroPickState.CmBan1 && state <= 20 && GetCMPhaseTimeRemaining() <= NeededTime) {
        BansHero();
        NeededTime = 0;
    } else if (state >= HeroPickState.CmSelect1 && state <= HeroPickState.CmSelect10 && GetCMPhaseTimeRemaining() <= NeededTime) {
        PicksHero();
        NeededTime = 0;
    } else if (state === HeroPickState.CmPick) {
        SelectsHero();
    }
}

// Pick the captain
export function PickCaptain() {
    if (!IsHumanPlayerExist() || DotaTime() > -1) {
        if (GetCMCaptain() === -1) {
            const CaptBot = GetFirstBot();
            if (CaptBot !== null && CaptBot !== undefined) {
                print("CAPTAIN PID : " + CaptBot);
                SetCMCaptain(CaptBot);
            }
        }
    }
}

// Check if human player exist in team
export function IsHumanPlayerExist(): boolean {
    const Players = GetTeamPlayers(GetTeam());
    for (const id of Players) {
        if (!IsPlayerBot(id)) {
            return true;
        }
    }
    return false;
}

// Get the first bot to be the captain
export function GetFirstBot(): number | null {
    let BotId: number | null = null;
    const Players = GetTeamPlayers(GetTeam());
    for (const id of Players) {
        if (IsPlayerBot(id)) {
            BotId = id;
            return BotId;
        }
    }
    return BotId;
}

// Ban hero function
function BansHero() {
    if (!IsPlayerBot(GetCMCaptain()) || !IsPlayerInHeroSelectionControl(GetCMCaptain())) {
        return;
    }
    const BannedHero = RandomHero();
    print(BannedHero + " is banned");
    CMBanHero(BannedHero);
    BanCycle = BanCycle + 1;
}

// Pick hero function
function PicksHero() {
    if (!IsPlayerBot(GetCMCaptain()) || !IsPlayerInHeroSelectionControl(GetCMCaptain())) {
        return;
    }

    const sTeamName = GetTeam() === Team.Radiant ? "TEAM_RADIANT" : "TEAM_DIRE";
    let PickedHero = RandomHero() as HeroName;
    if (PickCycle === 1) {
        while (!CanBeOfflaner(PickedHero)) {
            PickedHero = RandomHero();
        }
        PairsHeroNameNRole[sTeamName][PickedHero] = "offlaner";
    } else if (PickCycle === 2) {
        while (!CanBeSupport(PickedHero)) {
            PickedHero = RandomHero();
        }
        PairsHeroNameNRole[sTeamName][PickedHero] = "support";
    } else if (PickCycle === 3) {
        while (!CanBeMidlaner(PickedHero)) {
            PickedHero = RandomHero();
        }
        PairsHeroNameNRole[sTeamName][PickedHero] = "midlaner";
    } else if (PickCycle === 4) {
        while (!CanBeSupport(PickedHero)) {
            PickedHero = RandomHero();
        }
        PairsHeroNameNRole[sTeamName][PickedHero] = "support";
    } else if (PickCycle === 5) {
        while (!CanBeSafeLaneCarry(PickedHero)) {
            PickedHero = RandomHero();
        }
        PairsHeroNameNRole[sTeamName][PickedHero] = "carry";
    }

    print(PickedHero + " is picked");
    CMPickHero(PickedHero);
    PickCycle = PickCycle + 1;
}

// Add to list human picked heroes
export function AddToList() {
    if (!IsPlayerBot(GetCMCaptain())) {
        for (const h of allBotHeroes) {
            if (IsCMPickedHero(GetTeam(), h) && !AlreadyInTable(h)) {
                humanPick.push(h);
            }
        }
    }
}

// Check if selected hero already picked by human
function AlreadyInTable(hero_name: string): boolean {
    for (const h of humanPick) {
        if (hero_name === h) {
            return true;
        }
    }
    return false;
}

// Check if the randomed hero doesn't available for captain's mode
function IsUnavailableHero(name: string): boolean {
    for (const uh of UnavailableHeroes) {
        if (name === uh) {
            return true;
        }
    }
    return false;
}

// Random hero which is non picked, non banned, or non human picked heroes if the human is the captain
function RandomHero(): HeroName {
    let hero = allBotHeroes[RandomInt(1, allBotHeroes.length) - 1];
    while (IsUnavailableHero(hero) || IsCMPickedHero(GetTeam(), hero) || IsCMPickedHero(GetOpposingTeam(), hero) || IsCMBannedHero(hero)) {
        hero = allBotHeroes[RandomInt(1, allBotHeroes.length) - 1];
    }
    return hero;
}

// Check if the human already pick the hero in captain's mode
function WasHumansDonePicking(): boolean {
    const Players = GetTeamPlayers(GetTeam());
    for (const id of Players) {
        if (!IsPlayerBot(id)) {
            const selected = GetSelectedHeroName(id);
            if (selected == null || selected === "") {
                return false;
            }
        }
    }
    return true;
}

// Select the rest of the heroes that the human players don't pick in captain's mode
function SelectsHero() {
    if (!AllHeroesSelected && (WasHumansDonePicking() || GetCMPhaseTimeRemaining() < 1)) {
        const Players = GetTeamPlayers(GetTeam());
        const RestBotPlayers: number[] = [];
        GetTeamSelectedHeroes();

        // Remove heroes already selected by humans
        for (const id of Players) {
            const hero_name = GetSelectedHeroName(id);
            if (hero_name !== null && hero_name !== "") {
                UpdateSelectedHeroes(hero_name);
                print(hero_name + " Removed");
            } else {
                RestBotPlayers.push(id);
            }
        }

        for (let i = 0; i < RestBotPlayers.length; i++) {
            SelectHero(RestBotPlayers[i], ListPickedHeroes[i]);
        }

        AllHeroesSelected = true;
    }
}

// Get the team picked heroes
function GetTeamSelectedHeroes() {
    for (const sName of allBotHeroes) {
        if (IsCMPickedHero(GetTeam(), sName)) {
            ListPickedHeroes.push(sName);
        }
    }
    for (const sName of UnImplementedHeroes) {
        if (IsCMPickedHero(GetTeam(), sName)) {
            ListPickedHeroes.push(sName);
        }
    }
}

// Update team picked heroes after human players select their desired hero
function UpdateSelectedHeroes(selected: string) {
    for (let i = 0; i < ListPickedHeroes.length; i++) {
        if (ListPickedHeroes[i] === selected) {
            ListPickedHeroes.splice(i, 1);
            break;
        }
    }
}

// ----------------------------------------- CAPTAIN'S MODE LANE ASSIGNMENT -----------------------------------------
// let doneLaneAssignementOnce = false;
let RoleAssignment: { [team: string]: { [index: number]: number } } = {
    TEAM_RADIANT: {},
    TEAM_DIRE: {},
};
// let playerSwitchedRoles = false;

export function CMLaneAssignment(roleAssign: { [team: string]: { [i: number]: number } }) {
    //, switchedRoles: boolean) {
    const sTeamName = GetTeam() === Team.Radiant ? "TEAM_RADIANT" : "TEAM_DIRE";

    RoleAssignment = roleAssign;
    // playerSwitchedRoles = switchedRoles; // TODO: role assignment to be improved

    if (IsPlayerBot(GetCMCaptain())) {
        FillLaneAssignmentTable();
    } else {
        // FillLAHumanCaptain(); // TODO if needed
    }
    return HeroLanes[sTeamName];
}

// Lane Assignment if the captain is not human
function FillLaneAssignmentTable() {
    const TeamMember = GetTeamPlayers(GetTeam());
    const sTeamName = GetTeam() === Team.Radiant ? "TEAM_RADIANT" : "TEAM_DIRE";
    const supportAlreadyAssigned: { [team: string]: boolean } = {
        TEAM_RADIANT: false,
        TEAM_DIRE: false,
    };

    for (let i = 0; i < TeamMember.length; i++) {
        const unit = GetTeamMember(i + 1);
        if (unit !== null && unit.IsHero()) {
            const unit_name = unit.GetUnitName();
            const roleName = PairsHeroNameNRole[sTeamName][unit_name];
            if (roleName === "support") {
                if (GetTeam() === Team.Radiant) {
                    if (!supportAlreadyAssigned.TEAM_RADIANT) {
                        HeroLanes[sTeamName][i + 1] = Lane.Bot;
                        supportAlreadyAssigned.TEAM_RADIANT = true;
                        RoleAssignment[sTeamName][i + 1] = 5;
                    } else {
                        HeroLanes[sTeamName][i + 1] = Lane.Top;
                        RoleAssignment[sTeamName][i + 1] = 4;
                    }
                } else {
                    if (!supportAlreadyAssigned.TEAM_DIRE) {
                        HeroLanes[sTeamName][i + 1] = Lane.Top;
                        supportAlreadyAssigned.TEAM_DIRE = true;
                        RoleAssignment[sTeamName][i + 1] = 5;
                    } else {
                        HeroLanes[sTeamName][i + 1] = Lane.Bot;
                        RoleAssignment[sTeamName][i + 1] = 4;
                    }
                }
            } else if (roleName === "midlaner") {
                HeroLanes[sTeamName][i + 1] = Lane.Mid;
                RoleAssignment[sTeamName][i + 1] = 2;
            } else if (roleName === "offlaner") {
                if (GetTeam() === Team.Radiant) {
                    HeroLanes[sTeamName][i + 1] = Lane.Top;
                } else {
                    HeroLanes[sTeamName][i + 1] = Lane.Bot;
                }
                RoleAssignment[sTeamName][i + 1] = 3;
            } else if (roleName === "carry") {
                if (GetTeam() === Team.Radiant) {
                    HeroLanes[sTeamName][i + 1] = Lane.Bot;
                } else {
                    HeroLanes[sTeamName][i + 1] = Lane.Top;
                }
                RoleAssignment[sTeamName][i + 1] = 1;
            }
            // doneLaneAssignementOnce = true;
        }
    }
}

// Fill the lane assignment if the captain is human
// function FillLAHumanCaptain() {
//     const sTeamName = GetTeam() === Team.Radiant ? 'TEAM_RADIANT' : 'TEAM_DIRE';
//     const TeamMember = GetTeamPlayers(GetTeam());
//     for (let i = 0; i < TeamMember.length; i++) {
//         const unit = GetTeamMember(i + 1);
//         if (unit !== null && unit.IsHero()) {
//             const unit_name = unit.GetUnitName();
//             const key = GetFromHumanPick(unit_name);
//             if (key !== null && key !== undefined) {
//                 if (key === 1) {
//                     if (GetTeam() === Team.Dire) {
//                         HeroLanes[sTeamName][i + 1] = Lane.Bot;
//                     } else {
//                         HeroLanes[sTeamName][i + 1] = Lane.Top;
//                     }
//                 } else if (key === 2) {
//                     if (GetTeam() === Team.Dire) {
//                         HeroLanes[sTeamName][i + 1] = Lane.Bot;
//                     } else {
//                         HeroLanes[sTeamName][i + 1] = Lane.Top;
//                     }
//                 } else if (key === 3) {
//                     HeroLanes[sTeamName][i + 1] = Lane.Mid;
//                     RoleAssignment[sTeamName][i + 1] = 2;
//                 } else if (key === 4) {
//                     if (GetTeam() === Team.Dire) {
//                         HeroLanes[sTeamName][i + 1] = Lane.Top;
//                     } else {
//                         HeroLanes[sTeamName][i + 1] = Lane.Bot;
//                     }
//                 } else if (key === 5) {
//                     if (GetTeam() === Team.Dire) {
//                         HeroLanes[sTeamName][i + 1] = Lane.Top;
//                     } else {
//                         HeroLanes[sTeamName][i + 1] = Lane.Bot;
//                     }
//                 }
//             }
//         }
//     }
// }

// Get human picked heroes if the captain is human player
// function GetFromHumanPick(hero_name: string): number | null {
//     for (let key = 0; key < humanPick.length; key++) {
//         if (hero_name === humanPick[key]) {
//             return key + 1; // +1 to mimic Lua's 1-based indexing if needed
//         }
//     }
//     return null;
// }
