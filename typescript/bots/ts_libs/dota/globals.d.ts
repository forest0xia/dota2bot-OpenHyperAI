/*
 * Dota 2 scripting API globals functions and constants. https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
 */

import { Unit, Vector } from "./interfaces";
import { Lane, Team, UnitType } from ".";

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

    function GetSelectedHeroName(nPlayerID: number): string;

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

    interface HTTPRequest {
        SetHTTPRequestRawPostBody(contentType: string, body: string): void;
        Send(callback: (result: { [key: string]: any }) => void): void;
    }

    function CreateRemoteHTTPRequest(url: string): HTTPRequest;
}

export {};
