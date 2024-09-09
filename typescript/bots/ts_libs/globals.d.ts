/*
 * Dota 2 scripting API globals functions and constants
 */

import { Unit, Vector } from "./dota/interfaces";
import { Lane, Team, UnitType } from "./dota";

declare global {
    function print(...args: any[]): void;

    function GetBot(): Unit;

    function GetOpposingTeam(): Team;

    function GetTeam(): Team;

    function GetTeamPlayers(team: Team): number[];

    function GetTeamMember(playerNumberOnTeam: number): Unit | null;

    function GetUnitList(unitType: UnitType): Unit[];

    function GameTime(): number;

    function IsPlayerBot(playerId: number): boolean;

    function RandomInt(a: number, b: number): number;

    function GetScriptDirectory(): string;

    function Vector(x: number, y: number, z: number): Vector;

    function DotaTime(): number;

    function GetHeroLevel(playerId: number): number;
    function GetTower(team: Team, tower: number): Unit | null;
    function GetBarracks(team: Team, barracks: number): Unit | null;
    function GetUnitToUnitDistance(unit1: Unit, unit2: Unit): number;
    function GetUnitToLocationDistance(unit: Unit, location: Vector): number;
    function GetAncient(team: Team): Unit;
    function GetHeroKills(playerId: number): number;
    function GetHeroDeaths(playerId: number): number;
    function GetNeutralSpawners(): any;
    function GetLaneFrontLocation(
        team: Team,
        lane: Lane,
        deltaFromFront: number
    ): Vector;
    function RandomVector(length: number): Vector;
    function Clamp(value: number, min: number, max: number): number;
    function RemapValClamped(
        value: number,
        fromMin: number,
        fromMax: number,
        toMin: number,
        toMax: number
    ): number;
    function GetDefendLaneDesire(lane: Lane): number;
}

declare global {
    // TODO(Doctor): I declared tower enum globally for now,
    //  will move them into a proper enum later
    const TOWER_TOP_1: number;
    const TOWER_TOP_2: number;
    const TOWER_TOP_3: number;
    const TOWER_MID_1: number;
    const TOWER_MID_2: number;
    const TOWER_MID_3: number;
    const TOWER_BOT_1: number;
    const TOWER_BOT_2: number;
    const TOWER_BOT_3: number;
    const TOWER_BASE_1: number;
    const TOWER_BASE_2: number;

    const BARRACKS_TOP_MELEE: number;
    const BARRACKS_TOP_RANGED: number;
    const BARRACKS_MID_MELEE: number;
    const BARRACKS_MID_RANGED: number;
    const BARRACKS_BOT_MELEE: number;
    const BARRACKS_BOT_RANGED: number;
}

export {};
