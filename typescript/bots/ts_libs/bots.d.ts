/*
 * Internal/Project type definitions
 */

import { Ability, Talent } from "./dota";

export interface BotBehavior {
    sBuyList: string[];
    sSellList: string[];
    bDefaultItem: boolean;
    bDefaultAbility: boolean;
    sSkillList: Array<Talent | Ability>;

    SkillsComplement(this: void): void;

    MinionThink(this: void, hMinionUnit: any, bot: any): void;
}

export type BotRole = "pos_1" | "pos_2" | "pos_3" | "pos_4" | "pos_5";

export type ItemBuilds = { [key in BotRole]: string[] };

export interface GameState {
    defendPings: {
        pingedTime: number;
    } | null;
}
