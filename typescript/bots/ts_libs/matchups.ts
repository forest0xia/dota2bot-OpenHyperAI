export interface HeroMatchup {
    synergy: string[];
    counter: string[];
}

export type HeroMatchups = { [key: string]: HeroMatchup };
