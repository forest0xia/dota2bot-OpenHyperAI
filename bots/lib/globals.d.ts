import { Unit } from 'bots/lib/dota/interfaces'

declare global {
    function GetBot(): Unit
    function GetOpposingTeam(): number
    function GameTime(): number

    function GetScriptDirectory(): string

    const BOT_ACTION_DESIRE_NONE: number
    const BOT_ACTION_DESIRE_HIGH: number

    const BOT_MODE_NONE: undefined
}

export {}
