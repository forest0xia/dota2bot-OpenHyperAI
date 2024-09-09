/**
 * The Dota2 bot scriping interfaces from Valve. https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
 */

import { BotActionType, BotMode, Team } from "./enums";

export interface Location {}

// https://developer.valvesoftware.com/wiki/Category:Vector
// update for add/sub/div later.
export interface Vector {
    x: number;
    y: number;
    z: number;
    Normalized(): Vector;
}

export interface Ping {
    time: number;
    location: Vector;
    normal_ping: undefined;
    player_id: number;
}

export interface Item {
    GetName(): string;
}

export interface Unit {
    // Seems to be internal to bot script?
    frameProcessTime: number | null;
    assignedRole: number | null;

    IsNull(): boolean;

    CanBeSeen(): boolean;

    GetPlayerID(): number;

    GetUnitName(): string;

    GetAbilityCount(): number;

    GetAbilityByIndex(index: number): Ability | null;
    GetAbilityInSlot(index: number): Ability | null;

    IsInvisible(): boolean;

    IsAlive(): boolean;
    
    IsBuilding(): boolean;

    IsHero(): boolean;

    IsBot(): boolean;

    IsIllusion(): boolean;

    IsMagicImmune(): boolean;

    NumModifiers(): number;

    GetModifierName(nModifier: number): number;

    GetModifierStackCount(nModifier: number): number;

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

    GetTeam(): Team;

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

    
    GetLevel(): number;
    IsAncientCreep(): boolean;
    HasModifier(modifierName: string): boolean;
    GetActiveMode(): number;
    GetAbilityByName(abilityName: string): Ability;
    GetAttackRange(): number;
    GetCurrentVisionRange(): number;
    GetNetWorth(): number;
    FindItemSlot(itemName: string): number;
    GetNearbyLaneCreeps(radius: number, enemyTeam: boolean): Unit[];
    GetNearbyTowers(radius: number, enemyTeam: boolean): Unit[];
    GetAttackDamage(): number;
    GetActiveModeDesire(): number;
    GetGold(): number;
    GetCurrentMovementSpeed(): number;

}

export interface Ability {
    IsFullyCastable(): boolean;
    IsHidden(): boolean;

    GetCastRange(): number;

    IsNull(): boolean;

    GetName(): string;
    
    IsTrained(): boolean;
    GetManaCost(): number;
}

export interface Talent {}
