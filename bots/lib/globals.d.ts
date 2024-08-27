/*
 * Dota 2 scripting API globals functions and constants
 */

import { Unit } from 'bots/lib/dota/interfaces'
import { Team, UnitType } from 'bots/lib/dota'

declare global {
    function GetBot(): Unit

    function GetOpposingTeam(): Team

    function GetTeam(): Team

    function GetTeamPlayers(team: Team): number[]

    function GetTeamMember(playerNumberOnTeam: number): Unit | null

    function GetUnitList(unitType: UnitType): Unit[]

    function GameTime(): number

    function IsPlayerBot(playerId: number): boolean

    function RandomInt(a: number, b: number): number

    function GetScriptDirectory(): string

    /** @customConstructor Vector */
    class Vector {
        public x: number
        public y: number
        public z: number

        constructor(x: number, y: number, z: number)

        Normalized(): Vector
    }

    //**
    // Returns the game time. Matches game clock. Pauses with game pause. */
    function DotaTime(): number
}

export {}
