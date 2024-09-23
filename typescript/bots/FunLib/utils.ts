/**
 *
 * Here is a set of simple but critial utilities that should be able to get imported to any other files without causing any circular dependency.
 * This lua file should NOT have any dependency libs or files if possible, to avoid circular dependency.
 *
 * Anything that can be shared in any files without worrying about nested or circular dependency can be added to this file.
 * Can gradually migrate functions into this file as well.
 *
 */

require('bots/ts_libs/utils/json');
import {
    BotActionType,
    Lane,
    Ping,
    Team,
    Unit,
    UnitType,
    Vector,
} from "../ts_libs/dota";
import { GameState, AvoidanceZone } from "bots/ts_libs/bots";
import { Request } from "bots/ts_libs/utils/http_utils/http_req";
import { add, dot, length2D, multiply, sub } from "bots/ts_libs/utils/native-operators";

export const DebugMode = false;

export const ScriptID = 3246316298;

export const RadiantFountainTpPoint = Vector(-7172, -6652, 384);
export const DireFountainTpPoint = Vector(6982, 6422, 392);

export const WisdomRunes = {
    [Team.Radiant]: Vector(-8126, -320, 256),
    [Team.Dire]: Vector(8319, 266, 256),
};

// Bugged heroes, see: https://www.reddit.com/r/DotA2/comments/1ezxpav
export const BuggyHeroesDueToValveTooLazy = {
    npc_dota_hero_muerta: true,
    npc_dota_hero_marci: true,
    npc_dota_hero_lone_druid_bear: true,
    npc_dota_hero_primal_beast: true,
    npc_dota_hero_dark_willow: true,
    npc_dota_hero_elder_titan: true,
    npc_dota_hero_hoodwink: true,
    npc_dota_hero_wisp: true,
};

// Global array to store avoidance zones
let avoidanceZones: AvoidanceZone[] = [];

// Some gaming state keepers to keep a record of different states to avoid recomupte or anything.
export const GameStates: GameState = {
    defendPings: null,
};
export const LoneDruid = { } as { [key: number]: any };
export const FrameProcessTime = 0.05;


export const EstimatedEnemyRoles = {
    // sample role entry
    npc_dota_hero_any: {
        lane: Lane.Mid,
        role: 2
    }
} as { [key: string]: any }

export function PrintTable(tbl: any | null, indent: number = 0) {
    if (tbl === null) {
        print("nil");
        return;
    }

    for (const [key, value] of Object.entries(tbl)) {
        const prefix = string.rep("  ", indent) + key + ": ";
        if (type(value) == "table") {
            if (indent < 3) {
                print(prefix);
                PrintTable(value, indent + 1);
            } else {
                print(
                    prefix +
                        "[WARN] Table has deep nested tables in it, stop printing more nested tables."
                );
            }
        } else {
            print(prefix + value);
        }
    }
}

export function PrintUnitModifiers(unit: Unit) {
    const modifierCount = unit.NumModifiers();
    for (let i = 0; i < modifierCount; i++) {
        const modifierName = unit.GetModifierName(i);
        const stackCount = unit.GetModifierStackCount(i);
        print(
            `Unit ${unit.GetUnitName()} has modifier ${modifierName} with stack count ${stackCount}`
        );
    }
}

export function PrintPings(pingTimeGap: number): void {
    const listPings = [];
    const teamPlayers = GetTeamPlayers(GetTeam());
    for (const [index, _] of teamPlayers.entries()) {
        const allyHero = GetTeamMember(index);
        if (allyHero === null || allyHero.IsIllusion()) {
            continue;
        }
        const ping = allyHero.GetMostRecentPing();
        if (ping.time !== 0 && GameTime() - ping.time < pingTimeGap) {
            listPings.push(ping);
        }
    }
}

export function PrintAllAbilities(unit: Unit) {
    print(`Get all abilities of bot ${unit.GetUnitName()}`);
    for (let index of $range(0, 10)) {
        const ability = unit.GetAbilityInSlot(index);
        if (ability && !ability.IsNull()) {
            print(`Ability At Index ${index}: ${ability.GetName()}`);
        } else {
            print(`Ability At Index ${index} is nil`);
        }
    }
}

export function GetEnemyFountainTpPoint(): Vector {
    if (GetTeam() == Team.Dire) {
        return RadiantFountainTpPoint;
    }
    return DireFountainTpPoint;
}

export function GetTeamFountainTpPoint(): Vector {
    if (GetTeam() == Team.Dire) {
        return DireFountainTpPoint;
    }
    return RadiantFountainTpPoint;
}

export function Shuffle<T>(tbl: T[]): T[] {
    for (let i = tbl.length - 1; i >= 1; i--) {
        const j = RandomInt(1, i + 1); // Possibly? A bug with +1, couldn't wrap my head around ts/lua indexes
        const temp = tbl[i];
        tbl[i] = tbl[j];
        tbl[j] = temp;
    }
    return tbl;
}

export function SetFrameProcessTime(bot: Unit): void {
    if (bot.frameProcessTime === null) {
        bot.frameProcessTime =
            FrameProcessTime +
            math.fmod(bot.GetPlayerID() / 1000, FrameProcessTime / 10) * 2;
    }
}

export function GetHumanPing(): LuaMultiReturn<[Unit, Ping] | [null, null]> {
    const teamPlayers = GetTeamPlayers(GetTeam());
    for (const [index, _] of teamPlayers.entries()) {
        const teamMember = GetTeamMember(index);
        if (teamMember !== null && !teamMember.IsBot()) {
            return $multi(teamMember, teamMember.GetMostRecentPing());
        }
    }
    return $multi(null, null);
}

export function IsPingedByAnyPlayer(
    bot: Unit,
    pingTimeGap: number,
    minDistance: number | null,
    maxDistance: number | null
): Ping | null {
    if (!bot.IsAlive()) {
        return null;
    }

    const pings = [];
    const teamPlayerIds = GetTeamPlayers(GetTeam());

    minDistance = minDistance || 1500;
    maxDistance = maxDistance || 10000;

    for (const [index, _] of teamPlayerIds.entries()) {
        const teamMember = GetTeamMember(index);
        if (
            teamMember === null ||
            teamMember.IsIllusion() ||
            teamMember === bot
        ) {
            continue;
        }

        const ping = teamMember.GetMostRecentPing();
        if (ping !== null) {
            pings.push(ping);
        }
    }

    for (const ping of pings) {
        const distanceToBot = GetLocationToLocationDistance(
            ping.location,
            bot.GetLocation()
        );
        const withinRange =
            minDistance <= distanceToBot && distanceToBot <= maxDistance;
        const withinTimeRange = GameTime() - ping.time < pingTimeGap;
        if (
            withinRange &&
            withinTimeRange
            // && ping.player_id != -1
        ) {
            print(`Bot ${bot.GetUnitName()} noticed the ping`);
            return ping;
        }
    }
    return null;
}

// check if the target is a valid unit. can be hero, creep, or building.
export function IsValidUnit(target: Unit): boolean {
    return (
        target !== null &&
        !target.IsNull() &&
        target.CanBeSeen() &&
        target.IsAlive()
    );
}

// check if the target is a valid hero.
export function IsValidHero(target: Unit): boolean {
    return IsValidUnit(target) && target.IsHero();
}

export function IsValidCreep(target: Unit): boolean {
    return (
        IsValidUnit(target) &&
        target.GetHealth() < 5000 &&
        !target.IsHero() &&
        (GetBot().GetLevel() > 9 || !target.IsAncientCreep())
    );
};

// check if the target is a valid building.
export function IsValidBuilding(target: Unit): boolean {
    return IsValidUnit(target) && target.IsBuilding();
}

export function HasItem(bot: Unit, itemName: string): boolean {
    const slot = bot.FindItemSlot(itemName);
    return slot >= 0 && slot <= 8;
}

export function FindAllyWithName(name: string): Unit | null {
    for (const ally of GetUnitList(UnitType.AlliedHeroes)) {
        if (IsValidHero(ally) && string.find(ally.GetUnitName(), name)) {
            return ally;
        }
    }
    return null;
}

export function GetLocationToLocationDistance(
    fLoc: Vector,
    sLoc: Vector
): number {
    const x1 = fLoc.x;
    const x2 = sLoc.x;
    const y1 = fLoc.y;
    const y2 = sLoc.y;
    return math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1));
}

export function Deepcopy<T extends ArrayLike<unknown>>(orig: T): T {
    const originalType = type(orig);
    let copy;
    if (originalType == "table") {
        copy = {} as T;
        for (const [key, value] of Object.entries(orig)) {
            // @ts-ignore
            copy[Deepcopy(key)] = Deepcopy(value);
        }
        setmetatable(
            copy as object,
            Deepcopy(getmetatable(orig) as any) as object
        );
    } else {
        // number, string, boolean, etc.
        copy = orig;
    }
    return copy;
}

export function CombineTablesUnique<T extends object>(tbl1: T, tbl2: T): any[] {
    const set = new Set();

    for (const [_, value] of Object.entries(tbl1)) {
        set.add(value);
    }
    for (const [_, value] of Object.entries(tbl2)) {
        set.add(value);
    }

    const result = [];
    for (const element of set) {
        result.push(element);
    }
    return result;
}

export function MergeLists<T>(a: T[], b: T[]): T[] {
    return a.concat(b);
}

export function RemoveValueFromTable(table_: unknown[], valueToRemove: any) {
    for (const index of $range(table_.length, 1, -1)) {
        if (table_[index - 1] === valueToRemove) {
            table.remove(table_, index);
        }
    }
}

export function NumActionTypeInQueue(
    bot: Unit,
    searchedActionType: BotActionType
) {
    let count: number = 0
    for (const index of $range(1, bot.NumQueuedActions())) {
        const actionType = bot.GetQueuedActionType(index);
        if (actionType === searchedActionType) {
            count++;
        }
    }
    return count;
}

const humanCountCache: { [key in Team]: [number, number] } = {};

export function NumHumanBotPlayersInTeam(
    team: Team
): LuaMultiReturn<[number, number]> {
    if (!(team in humanCountCache)) {
        let humans = 0;
        let bots = 0;

        for (let playerdId of GetTeamPlayers(team)) {
            if (IsPlayerBot(playerdId)) {
                bots += 1;
            } else {
                humans += 1;
            }
        }
        humanCountCache[team] = [humans, bots];
    }
    return $multi(humanCountCache[team][0], humanCountCache[team][1]);
}

export function IsWithoutSpellShield(npcEnemy: Unit): boolean {
    return (
        !npcEnemy.HasModifier("modifier_item_sphere_target") &&
        !npcEnemy.HasModifier("modifier_antimage_spell_shield") &&
        !npcEnemy.HasModifier("modifier_item_lotus_orb_active")
    );
}

export function SetContains(set: any, key: string): boolean {
    return set[key] != null;
}

export function AddToSet(set: any, key: string): void {
    set[key] = true;
}

export function RemoveFromSet(set: any, key: string): void {
    set[key] = null;
}

export function HasValue(set: any, value: any) {
    for (const [_, element] of ipairs(set)) {
        if (value == element) {
            return true;
        }
    }
    return false;
}

export function CountBackpackEmptySpace(bot: Unit) {
    let count = 3;
    for (const slot of [6, 7, 8]) {
        if (bot.GetItemInSlot(slot) !== null) {
            count--;
        }
    }
    return count;
}

export function FloatEqual(a: number, b: number) {
    return math.abs(a - b) < 0.000001;
}

const magicTable: any = {};
magicTable.__index = magicTable;

export function NewTable(): any {
    const a = {};
    setmetatable(a, magicTable);
    return a;
}

export function ForEach(_: any, tb: any, action: Function) {
    for (const [key, value] of ipairs(tb)) {
        action(key, value);
    }
}

export function Remove_Modify(table_: any, item: any) {
    let filter = item;
    if (type(item) !== "function") {
        filter = (t: any) => t == item;
    }
    let i = 1;
    let d = table_.length;
    while (i <= d) {
        if (filter(table_[i])) {
            table.remove(table_, i);
            d--;
        } else {
            i++;
        }
    }
}

export function AbilityBehaviorHasFlag(
    behavior: number,
    flag: number
): boolean {
    // @ts-ignore
    return bit.band(behavior, flag) == flag;
}

interface RegistryMember {
    lastCallTime: number;
    interval: number;
    startup: boolean | null;
}

const everySecondsCallRegistry: { [key: string]: RegistryMember } = {};
//**Doesn't seem to be used*/
// @ts-ignore
function EveryManySeconds(second: number, oldFunction: Function) {
    const functionName = tostring(oldFunction);
    everySecondsCallRegistry[functionName] = {
        lastCallTime: DotaTime() + RandomInt(0, second * 1000) / 1000,
        interval: second,
        startup: true,
    };

    return function (...args: any[]) {
        const callTable = everySecondsCallRegistry[functionName];
        if (callTable.startup) {
            callTable.startup = null;
            return oldFunction(...args);
        } else if (callTable.lastCallTime <= DotaTime() - callTable.interval) {
            callTable.lastCallTime = DotaTime();
            return oldFunction(...args);
        }
        return NewTable();
    };
}

export function RecentlyTookDamage(bot: Unit, delta: number): boolean {
    return (
        bot.WasRecentlyDamagedByAnyHero(delta) ||
        bot.WasRecentlyDamagedByTower(delta) ||
        bot.WasRecentlyDamagedByCreep(delta)
    );
}

export function IsUnitWithName(unit: Unit, name: string): boolean {
    const result = string.find(unit.GetUnitName(), name);
    return result !== null;
}

export function IsBear(unit: Unit) {
    return IsUnitWithName(unit, "lone_druid_bear");
}

export function GetOffsetLocationTowardsTargetLocation(
    initLoc: Vector,
    targetLoc: Vector,
    offsetDist: number
) {
    const direrction = sub(targetLoc, initLoc).Normalized();
    return add(initLoc, multiply(direrction, offsetDist));
}

export function TimeNeedToHealHP(bot: Unit): number {
    return (bot.GetMaxHealth() - bot.GetHealth()) / bot.GetHealthRegen();
}

export function TimeNeedToHealMP(bot: Unit): number {
    return (bot.GetMaxMana() - bot.GetMana()) / bot.GetManaRegen();
}

export function HasAnyEffect(unit: Unit, ...effects: string[]) {
    return effects.some(effect => unit.HasModifier(effect));
}

export function IsModeTurbo(): boolean {
    for (const u of GetUnitList(UnitType.Allies)) {
        if (
            u &&
            u.GetUnitName() === "npc_dota_courier" &&
            u.GetCurrentMovementSpeed() === 1100
        ) {
            return true;
        }
    }
    return false;
}

// TODO: To guess the role of an enemy bot. Role should be determine around 1-2mins in the game based on lanes. In mid-late game, re-determine by networth.
export function DetermineEnemyBotRole(bot: Unit): number {
    const botName = bot.GetUnitName()
    const estimatedRole = EstimatedEnemyRoles[botName]
    if (estimatedRole == null) {
        print(`Enemy bot ${botName} role not cached yet.`)
        return 3
    }

    return estimatedRole.role
}

// TODO: Just trying. Does not work.
export function QueryCounters(heroId: number) {
    print("heroId=" + heroId)
    Request.RawGetRequest(`https://api.opendota.com/api/heroes/${heroId}/matchups`, function(res) {
        PrintTable(res)
    })
}

export function GetLoneDruid(bot: Unit): any {
    let res = LoneDruid[bot.GetPlayerID()]
    if (res === null) {
        LoneDruid[bot.GetPlayerID()] = {}
        res = LoneDruid[bot.GetPlayerID()]
    }
    return res;
}

export function TrimString(str: string): string {
	return str.trim();
}

/**
 * TODO: AvoidanceZone work in progress.
 * 
 * Example: Adds a zone that expires after 10 seconds: addCustomAvoidanceZone(Vector(1000, 2000), 500, 10);
 * Example: Adds a zone lasts indefinitely: addCustomAvoidanceZone(Vector(1000, 2000), 500);
 * @param center 
 * @param radius 
 * @param duration 
 */
export function addCustomAvoidanceZone(center: Vector, radius: number, duration?: number): void {
    const currentTime = DotaTime();
    const expirationTime = duration !== undefined ? currentTime + duration : Number.POSITIVE_INFINITY;

    avoidanceZones.push({ center, radius, expirationTime });
}

export function cleanExpiredAvoidanceZones(): void {
    const currentTime = DotaTime();
    avoidanceZones = avoidanceZones.filter(zone => zone.expirationTime > currentTime);
}

export function getCustomAvoidanceZones(): Array<{ center: Vector; radius: number }> {
    return avoidanceZones;
}

export function isPositionInAvoidanceZone(position: Vector): boolean {
    for (const zone of avoidanceZones) {
        const distance = length2D(sub(position, zone.center));
        if (distance <= zone.radius) {
            return true;
        }
    }
    return false;
}

export function moveToPositionAvoidingZones(bot: Unit, targetPosition: Vector): void {
    if (isPositionInAvoidanceZone(targetPosition)) {
        const safePosition = findSafePosition(bot.GetLocation(), targetPosition);
        bot.Action_MoveToLocation(safePosition);
    } else {
        bot.Action_MoveToLocation(targetPosition);
    }
}

export function findSafePosition(currentPosition: Vector, targetPosition: Vector): Vector {
    // Move towards the target but stop before entering the avoidance zone
    const direction = sub(targetPosition, currentPosition).Normalized();
    const safeDistance = getSafeDistance(currentPosition, targetPosition);
    return add(currentPosition, multiply(direction, safeDistance));
}

export function getSafeDistance(currentPosition: Vector, targetPosition: Vector): number {
    const maxDistance = length2D(sub(targetPosition, currentPosition));
    for (const zone of avoidanceZones) {
        const projectedPoint = projectPointOntoLine(currentPosition, targetPosition, zone.center);
        const distanceToZone = length2D(sub(projectedPoint, zone.center));
        if (distanceToZone <= zone.radius) {
            const distanceToAvoid = length2D(sub(projectedPoint, currentPosition)) - zone.radius;
            return Math.max(0, distanceToAvoid);
        }
    }
    return maxDistance;
}

export function projectPointOntoLine(startPoint: Vector, endPoint: Vector, point: Vector): Vector {
    const lineDir = sub(endPoint, startPoint).Normalized();
    const toPoint = sub(point, startPoint);
    const projectionLength = dot(toPoint, lineDir);
    return add(startPoint, multiply(lineDir, projectionLength));
}

export function drawAvoidanceZones(): void {
    for (const zone of avoidanceZones) {
        DebugDrawCircle(zone.center, zone.radius, 0, 255, 0);
    }
}

// @ts-ignore
export function findPathAvoidingZones(startPosition: Vector, endPosition: Vector): Vector[] {
    // Implement A* pathfinding algorithm here
    // Each node should check for collision with avoidance zones
    // Return a path array of Vectors that avoids the zones
    return [];
}
