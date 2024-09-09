/*
 * Dota 2 scripting API globals functions and constants. https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
 */

import { Unit, Vector } from "./interfaces";
import { Team, UnitType } from ".";

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
    function GetTower(team: Team, tower: number): Unit | undefined;
    function GetUnitToUnitDistance(unit1: Unit, unit2: Unit): number;
    function GetUnitToLocationDistance(unit: Unit, location: Vector): number;
    function GetAncient(team: Team): Unit;
    function GetHeroKills(playerId: number): number;
    function GetHeroDeaths(playerId: number): number;
    function GetNeutralSpawners(): any;
}

export {};
