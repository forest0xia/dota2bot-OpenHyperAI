import { BotMode } from 'bots/lib/dota/enums'

export interface Location {}

export interface Unit {
    GetAbilityByName(name: string): Ability

    IsInvisible(): boolean

    IsAlive(): boolean

    IsHero(): boolean

    IsMagicImmune(): boolean

    HasModifier(name: string): boolean

    GetNearbyCreeps(range: number, enemy: boolean): undefined[]

    GetLocation(): Location

    GetNearbyHeroes(
        range: number,
        includeEnemies: boolean,
        mode: BotMode
    ): Unit[]

    Action_UseAbilityOnEntity(ability: Ability, target: Unit): void

    Action_UseAbilityOnLocation(ability: Ability, location: Location): void

    Action_UseAbility(ability: Ability): void

    GetAttackTarget(): Unit | null

    GetTeam(): number

    GetLastAttackTime(): number
}

export interface Ability {
    IsFullyCastable(): boolean

    GetCastRange(): number
}

export interface Talent {}
