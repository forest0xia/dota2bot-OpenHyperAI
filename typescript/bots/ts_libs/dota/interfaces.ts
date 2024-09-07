import { BotActionType, BotMode } from "./enums";

export interface Location {}

export interface Ping {
    time: number;
    location: Vector;
    normal_ping: undefined;
    player_id: number;
}

export interface Item {}

export interface Unit {
    // Seems to be internal to bot script?
    frameProcessTime: number | null;

    IsNull(): boolean;

    CanBeSeen(): boolean;

    GetAbilityByName(name: string): Ability;

    GetPlayerID(): number;

    GetUnitName(): string;

    GetAbilityCount(): number;

    GetAbilityByIndex(index: number): Ability | null;
    GetAbilityInSlot(index: number): Ability | null;

    IsInvisible(): boolean;

    IsAlive(): boolean;

    IsHero(): boolean;

    IsBot(): boolean;

    IsIllusion(): boolean;

    IsMagicImmune(): boolean;

    NumModifiers(): number;

    HasModifier(name: string): boolean;

    GetNearbyCreeps(range: number, enemy: boolean): undefined[];

    GetMostRecentPing(): Ping;

    GetLocation(): Vector;

    GetNearbyHeroes(
        range: number,
        includeEnemies: boolean,
        mode: BotMode
    ): Unit[];

    GetItemInSlot(slot: number): Item | null;
    NumQueuedActions(): number;

    GetQueuedActionType(index: number): BotActionType;

    Action_UseAbilityOnEntity(ability: Ability, target: Unit): void;

    Action_UseAbilityOnLocation(ability: Ability, location: Location): void;

    Action_UseAbility(ability: Ability): void;

    GetAttackTarget(): Unit | null;

    GetTeam(): number;

    GetLastAttackTime(): number;
    WasRecentlyDamagedByAnyHero(delta: number): boolean;
    WasRecentlyDamagedByTower(delta: number): boolean;
    WasRecentlyDamagedByCreep(delta: number): boolean;
    GetMaxHealth(): number;
    GetHealth(): number;
    GetHealthRegen(): number;
    GetMaxMana(): number;
    GetMana(): number;
    GetManaRegen(): number;
}

export interface Ability {
    IsFullyCastable(): boolean;

    GetCastRange(): number;

    IsNull(): boolean;

    GetName(): string;
}

export interface Talent {}
