import { Ability, BotMode, Lane, Ping, Talent, Team, Unit, Vector } from "bots/ts_libs/dota";
import { BotRole, TalentTreeBuild } from "bots/ts_libs/bots";
import * as Util from "bots/FunLib/utils";

/** @noSelf **/
interface ISkill {
    GetRandomBuild(builds: number[][]): number[];

    GetTalentBuild(talents: TalentTreeBuild): number[];

    GetTalentList(bot: Unit): Talent[];

    GetAbilityList(bot: Unit): string[];

    GetSkillList(abilities: string[], abilityBuild: number[], talentList: Talent[], talentBuild: number[]): string[];
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
declare function GetTeamFountain(): Vector;

declare function GetMostDefendLaneDesire(): LuaMultiReturn<[Lane, number]>;

declare function GetLastSeenEnemiesNearLoc(location: Vector, radius: number): Unit[];

declare function AdjustLocationWithOffsetTowardsFountain(vector: Vector, distance: number): Vector;

declare function GetNearbyLocationToTp(location: Vector): Vector;

declare function GetPosition(bot: Unit | null): number;

declare function IsInLaningPhase(): boolean;

declare function IsDoingRoshan(bot: Unit): boolean;

declare function IsDoingTormentor(bot: Unit): boolean;

declare function GetTormentorLocation(team: Team): Vector;

declare function GetAlliesNearLoc(location: Vector, radius: number): Unit[];

declare function GetEnemiesAroundAncient(bot: Unit, radius: number | null): number;

declare function GetProperTarget(bot: Unit): Unit;

declare function IsPingCloseToValidTower(team: Team, ping: Ping, radius: number, duration: number): LuaMultiReturn<[false, null] | [true, Lane]>;

declare function GetNumOfAliveHeroes(isEnemy: boolean): number;

declare function IsValid(target: Unit): boolean;

declare function GetHeroesNearLocation(enemy: boolean, location: Vector, radius: number): Unit[];

declare function CanBeAttacked(unit: Unit): boolean;

declare function IsSuspiciousIllusion(unit: Unit): boolean;
declare function IsEarlyGame(): boolean;
declare function IsMidGame(): boolean;
declare function IsLateGame(): boolean;
declare function GetEnemiesNearLoc(location: Vector, radius: number): Unit[];
declare function GetAlliesNearLoc(location: Vector, radius: number): Unit[];
declare function IsCore(bot: Unit): boolean;
declare function IsSupport(bot: Unit): boolean;
declare function IsPvNMode(): boolean;
declare function GetMostPushLaneDesire(): Lane;
declare function GetMostDefendLaneDesire(): Lane;
declare function GetNumOfTeamTotalKills(isEnemy: boolean): number;
declare function GetNumOfAliveCore(isEnemy: boolean): number;
declare function GetAliveCoreCount(isEnemy: boolean): number;
declare function GetNumOfTeamTotalKills(isEnemy: boolean): number;
declare function GetNumOfAliveCore(isEnemy: boolean): number;
declare function GetAliveCoreCount(isEnemy: boolean): number;
declare function GetCurrentRoshanLocation(): Vector;
declare function GetTormentorWaitingLocation(team: Team): Vector;
declare function IsDefending(bot: Unit): boolean;
declare function GetHumanPing(): LuaMultiReturn<[any, any]>;
declare function GetEnemiesAroundLoc(location: Vector, radius: number): number;
declare function DoesTeamHaveAegis(): boolean;
declare function GetAverageLevel(bEnemy: boolean): number;
declare function GetInventoryNetworth(): LuaMultiReturn<[any, any]>;
declare function IsValidBuilding(unit: any): boolean;
declare function IsValidHero(unit: any): boolean;
declare function IsCore(unit: any): boolean;
declare function GetDistance(location1: Vector, location2: Vector): number;
declare function IsTormentor(unit: any): boolean;
declare function IsRoshan(unit: any): boolean;
declare function IsInRange(unit: any, target: any, range: number): boolean;
declare function GetRandomLocationWithinDist(location: Vector, minDist: number, maxDist: number): Vector;
declare function GetRandomLocationWithinDist(location: Vector, minDist: number, maxDist: number): Vector;
declare function IsChasingTarget(unit: any, target: any): boolean;
declare function IsMeepoClone(unit: any): boolean;
declare function GetAllyHeroesAttackingUnit(unit: any): Unit[];
declare function GetAllyCreepsAttackingUnit(unit: any): Unit[];
declare function GetLaneBuildingTier(lane: Lane): number;
declare function ShouldWaitForImportantItemsSpells(location: Vector): boolean;
declare function HasBackdoorProtect(target: any): boolean;
declare function IsAnyTargetBackdooredAt(bot: any, lane: Lane): boolean;
declare function CanCastAbility(ability: any): boolean;
declare function GetItem2(bot: Unit, itemName: string): any;
declare function GetRetreatingAlliesNearLoc(location: Vector, radius: number): Unit[];
declare function GetNearbyHeroes(unit: Unit, radius: number, includeEnemies: boolean, mode: BotMode): Unit[];
declare function WeAreStronger(bot: Unit, radius: number): boolean;
declare function IsAnyAllyDefending(bot: Unit, lane: Lane): boolean;
declare function RandomForwardVector(distance: number): Vector;

declare const Skill: ISkill;
declare const Item: IItem;
declare const Utils: typeof Util;
