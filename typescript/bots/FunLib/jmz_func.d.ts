import { Talent, Unit } from "../ts_libs/dota";
import { BotRole, TalentTreeBuild } from "../ts_libs/bots";


/** @noSelf **/
interface ISkill {
    GetRandomBuild(builds: number[][]): number[];

    GetTalentBuild(talents: TalentTreeBuild): number[];

    GetTalentList(bot: Unit): Talent[];

    GetAbilityList(bot: Unit): string[];

    GetSkillList(
        abilities: string[],
        abilityBuild: number[],
        talentList: Talent[],
        talentBuild: number[]
    ): string[];
}

/** @noSelf **/
interface IItem {
    GetRoleItemsBuyList(bot: Unit): BotRole;
}

declare function IsInTeamFight(bot: Unit, radius: number): boolean;

declare function IsRetreating(bot: Unit): boolean;

declare function IsGoingOnSomeone(bot: Unit): boolean;

declare function CanNotUseAbility(bot: Unit): boolean;
declare function CanNotUseAction(bot: Unit): boolean;

declare function GetMP(bot: Unit): number;

declare function GetHP(bot: Unit): number;

declare function GetMostDefendLaneDesire(): LuaMultiReturn<[Lane, number]>;

declare function GetLastSeenEnemiesNearLoc(
    location: Vector,
    radius: number
): Unit[];

declare function AdjustLocationWithOffsetTowardsFountain(
    vector: Vector,
    distance: number
): Vector;

declare function GetNearbyLocationToTp(location: Vector): Vector;

declare function GetPosition(bot: Unit): number;

declare function IsInLaningPhase(): boolean;

declare function IsDoingRoshan(bot: Unit): boolean;

declare function IsDoingTormentor(bot: Unit): boolean;

declare function GetTormentorLocation(team: Team): Vector;

declare function GetAlliesNearLoc(location: Vector, radius: number): Unit[];

declare function GetEnemiesAroundAncient(): Unit[];

declare function IsPingCloseToValidTower(
    team: Team,
    ping: Ping
): LuaMultiReturn<[false, null] | [true, Lane]>;

declare function GetNumOfAliveHeroes(isEnemy: boolean): number;

declare function IsValid(target: Unit): boolean;

declare function GetHeroesNearLocation(
    enemy: boolean,
    location: Vector,
    radius: number
): Unit[];

declare function CanBeAttacked(unit: Unit): boolean;

declare function IsSuspiciousIllusion(unit: Unit): boolean;

declare const Skill: ISkill;
declare const Item: IItem;
