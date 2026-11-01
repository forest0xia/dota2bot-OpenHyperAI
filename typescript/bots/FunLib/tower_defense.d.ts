import { Unit } from "bots/ts_libs/dota";

// Tower defense with judgement (bots/FunLib/tower_defense.lua, hand-written Lua; benchmark variant "defensa_t12").
/** @noSelf **/
export declare function Enabled(): boolean;
/** @noSelf **/
export declare function DefendDesire(bot: Unit, lane: number): number | undefined;
