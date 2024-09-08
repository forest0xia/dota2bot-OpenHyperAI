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

declare function GetMP(bot: Unit): number;

declare function GetHP(bot: Unit): number;

declare const Skill: ISkill;
declare const Item: IItem;
