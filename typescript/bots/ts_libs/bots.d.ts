/**
 * The interfaces we defined in this script.
 */

import { Ability, Vector, Talent, Unit } from "bots/ts_libs/dota";

export interface BotSetup {
    sBuyList: string[];
    sSellList: string[];
    sSkillList: Array<Talent | Ability>;
    SkillsComplement(this: void): void;
    MinionThink(this: void, hMinionUnit: any): void;
}
export interface TalentTreeBuild {
    t10: [number, number];
    t15: [number, number];
    t20: [number, number];
    t25: [number, number];
}
export interface HeroMatchup {
    synergy: string[];
    counter: string[];
}

export type BotRole = "pos_1" | "pos_2" | "pos_3" | "pos_4" | "pos_5";
export type ItemBuilds = { [key in BotRole]: string[] };
export type SkillBuilds = { [key in BotRole]: number[] };
export type TalentBuilds = { [key in BotRole]: TalentTreeBuild };
export type HeroMatchups = { [key: string]: HeroMatchup };

export interface GameState {
    defendPings: {
        pingedTime: number;
    } | null;
    recentDefendTime: number;
    cachedVars: any;
    twinGates: Unit[];
}

export interface AvoidanceZone {
    center: Vector;
    radius: number;
    expirationTime: number;
}
