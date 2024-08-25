/*
 * Dota 2 scripting API globals functions and constants
 */

import { Unit } from 'bots/lib/dota/interfaces'

declare global {
    function GetBot(): Unit
    function GetOpposingTeam(): number
    function GameTime(): number

    function GetScriptDirectory(): string
}

export {}
