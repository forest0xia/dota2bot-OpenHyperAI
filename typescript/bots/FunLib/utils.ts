/**
 * The basic utilities file.
 * Here is a set of simple but critial utilities that should be able to get imported to any other files
 * without causing any circular dependency - meaning all of methods here can be shared in any other higher level
 * implementation files without worrying about nested or circular dependency.
 *
 * This file should NOT import any dependency libs or files that CAN cause circular dependency,
 * which means all libs imported should be raw/basic/global func, and all methods used in this file should be
 * raw basic methods from lower level implementations.
 *
 * We can gradually migrate functions into this file, and the bot script isn't a large project so we can
 * keep putting shared low level funtionalities in this file until it gets too big for to maintain.
 */
require("bots/ts_libs/utils/json");
import { Ability, Barracks, BotActionType, BotMode, Item, Lane, Ping, Team, Tower, Unit, UnitType, Vector } from "bots/ts_libs/dota";
import { GameState, AvoidanceZone } from "bots/ts_libs/bots";
import { Request } from "bots/ts_libs/utils/http_utils/http_req";
import { add, dot, length2D, length3D, multiply, sub } from "bots/ts_libs/utils/native-operators";
import { HeroName } from "bots/ts_libs/dota/heroes";

export const DebugMode = false;

export const ScriptID = 3246316298;

export const RadiantFountainTpPoint = Vector(-7172, -6652, 384);
export const DireFountainTpPoint = Vector(6982, 6422, 392);
export const RadiantRoshanLoc = Vector(-2984, 2349, 1092);
export const DireRoshanLoc = Vector(2980, -2816, 1107);
export const BarrackList: Barracks[] = [Barracks.TopMelee, Barracks.TopRanged, Barracks.MidMelee, Barracks.MidRanged, Barracks.BotMelee, Barracks.BotRanged];
export const WisdomRunes = {
    [Team.Radiant]: Vector(-8126, -320, 256),
    [Team.Dire]: Vector(8319, 266, 256),
};

// Bugged heroes, see: https://www.reddit.com/r/DotA2/comments/1ezxpav
export const BuggyHeroesDueToValveTooLazy = {
    [HeroName.Muerta]: true,
    [HeroName.Marci]: true,
    [HeroName.LoneDruidBear]: true,
    [HeroName.PrimalBeast]: true,
    [HeroName.DarkWillow]: true,
    [HeroName.ElderTitan]: true,
    [HeroName.Hoodwink]: true,
    [HeroName.IO]: true,
    [HeroName.Kez]: true,
};

export const HighGroundTowers = [Tower.Top3, Tower.Mid3, Tower.Bot3, Tower.Base1, Tower.Base2];

export const FirstTierTowers = [Tower.Top1, Tower.Mid1, Tower.Bot1];

export const SecondTierTowers = [Tower.Top2, Tower.Mid2, Tower.Bot2];

export const AllTowers = [Tower.Top1, Tower.Mid1, Tower.Bot1, Tower.Top2, Tower.Mid2, Tower.Bot2, Tower.Top3, Tower.Mid3, Tower.Bot3, Tower.Base1, Tower.Base2];

export const NonTier1Towers = [Tower.Top2, Tower.Mid2, Tower.Bot2, Tower.Top3, Tower.Mid3, Tower.Bot3, Tower.Base1, Tower.Base2];

export const CachedVarsCleanTime = 5;

/**
 * Data structure describing "special AOE" threats
 * and what conditions must be met before we consider them dangerous.
 */
interface AOEHeroThreat {
    // Minimum level the hero must be at to be considered dangerous
    minLevel: number;

    // Items the hero must have to be considered dangerous (e.g. item_bfury, item_blink, etc.)
    requiredItems: string[];

    // Modifiers the hero must have active
    // (e.g. "modifier_troll_warlord_battle_trance")
    requiredModifiers: string[];
}

/**
 * Some specific heroes with hugh potential AOE damages.
 * Map each "special AOE hero" to its threat conditions.
 */
const SpecialAOEHeroesDetails: Record<string, AOEHeroThreat> = {
    [HeroName.Axe]: {
        minLevel: 4,
        requiredItems: [], //["item_blink"],
        requiredModifiers: [], // e.g. no special modifier needed to be a threat
    },
    [HeroName.Enigma]: {
        minLevel: 6,
        requiredItems: [], //["item_blink"],
        // or maybe no item needed if you consider black hole a threat at all times
        requiredModifiers: [
            // Some teams prefer checking if Enigma has the black hole ability off cooldown,
            // but for simplicity, let's assume we just check if he's Enigma + blink?
        ],
    },
    [HeroName.Earthshaker]: {
        minLevel: 6,
        requiredItems: ["item_blink"],
        requiredModifiers: [], // Echo Slam threat
    },
    [HeroName.Invoker]: {
        minLevel: 9, // maybe require some levels for big combo
        requiredItems: [],
        requiredModifiers: [],
    },
    [HeroName.SandKing]: {
        minLevel: 6,
        requiredItems: ["item_blink"],
        requiredModifiers: [], // Epi center is the threat
    },
    [HeroName.TrollWarlord]: {
        minLevel: 6,
        requiredItems: ["item_bfury"],
        requiredModifiers: ["modifier_troll_warlord_battle_trance"],
    },
    // more to add ...
};

/**
 * A mapping from hero name to an array of important spell(s)
 * that have long cooldowns and can drastically change a team fight.
 */
export const ImportantSpells: Record<string, string[]> = {
    // Strength
    [HeroName.Alchemist]: ["alchemist_chemical_rage"],
    [HeroName.Axe]: ["axe_culling_blade"],
    [HeroName.Bristleback]: ["bristleback_bristleback"],
    [HeroName.Centaur]: ["centaur_stampede"],
    [HeroName.ChaosKnight]: ["chaos_knight_phantasm"],
    [HeroName.Dawnbreaker]: ["dawnbreaker_solar_guardian"],
    [HeroName.Doom]: ["doom_bringer_doom"],
    [HeroName.DragonKnight]: ["dragon_knight_elder_dragon_form"],
    [HeroName.EarthSpirit]: ["earth_spirit_magnetize"],
    [HeroName.Earthshaker]: ["earthshaker_echo_slam"],
    [HeroName.ElderTitan]: ["elder_titan_earth_splitter"],
    // huskar missing from list – add as needed
    [HeroName.Kunkka]: ["kunkka_ghostship"],
    [HeroName.LegionCommander]: ["legion_commander_duel"],
    [HeroName.Lifestealer]: ["life_stealer_rage"],
    [HeroName.Mars]: ["mars_arena_of_blood"],
    [HeroName.NightStalker]: ["night_stalker_darkness"],
    [HeroName.Omniknight]: ["omniknight_guardian_angel"],
    [HeroName.PrimalBeast]: ["primal_beast_pulverize"],
    // pudge, slardar, spirit_breaker missing
    [HeroName.Sven]: ["sven_gods_strength"],
    [HeroName.Tidehunter]: ["tidehunter_ravage"],
    // timbersaw, tiny missing
    [HeroName.TreantProtector]: ["treant_overgrowth"],
    // tusk missing
    [HeroName.Undying]: ["undying_tombstone", "undying_flesh_golem"],
    // Wraith King’s internal name was once skeleton_king. Keep as needed:
    [HeroName.WraithKing]: ["skeleton_king_reincarnation"],

    // Agility
    [HeroName.Antimage]: ["antimage_mana_void"],
    // arc_warden missing
    [HeroName.Bloodseeker]: ["bloodseeker_rupture"],
    // bounty_hunter missing
    [HeroName.Clinkz]: ["clinkz_burning_barrage"],
    // drow_ranger, ember_spirit missing
    [HeroName.FacelessVoid]: ["faceless_void_chronosphere"],
    [HeroName.Gyrocopter]: ["gyrocopter_flak_cannon"],
    [HeroName.Hoodwink]: ["hoodwink_sharpshooter"],
    [HeroName.Juggernaut]: ["juggernaut_omni_slash"],
    // keeling? Possibly a custom or incomplete
    [HeroName.Luna]: ["luna_eclipse"],
    [HeroName.Medusa]: ["medusa_stone_gaze"],
    // meepo missing
    [HeroName.MonkeyKing]: ["monkey_king_wukongs_command"],
    // morphling missing
    [HeroName.NagaSiren]: ["naga_siren_song_of_the_siren"],
    // phantom_assassin, phantom_lancer missing
    [HeroName.Razor]: ["razor_static_link"],
    // riki missing
    [HeroName.ShadowFiend]: ["nevermore_requiem"],
    [HeroName.Slark]: ["slark_shadow_dance"],
    // sniper missing
    [HeroName.Spectre]: ["spectre_haunt_single", "spectre_haunt"],
    // templar_assassin missing
    [HeroName.Terrorblade]: ["terrorblade_metamorphosis", "terrorblade_sunder"],
    [HeroName.TrollWarlord]: ["troll_warlord_battle_trance"],
    [HeroName.Ursa]: ["ursa_enrage"],
    [HeroName.Viper]: ["viper_viper_strike"],
    [HeroName.Weaver]: ["weaver_time_lapse"],

    // Intelligence
    [HeroName.AncientApparition]: ["ancient_apparition_ice_blast"],
    [HeroName.CrystalMaiden]: ["crystal_maiden_freezing_field"],
    [HeroName.DeathProphet]: ["death_prophet_exorcism"],
    [HeroName.Disruptor]: ["disruptor_static_storm"],
    // enchantress missing
    [HeroName.Grimstroke]: ["grimstroke_dark_portrait", "grimstroke_soul_chain"],
    [HeroName.Jakiro]: ["jakiro_macropyre"],
    // keeper_of_the_light, leshrac missing
    [HeroName.Lich]: ["lich_chain_frost"],
    [HeroName.Lina]: ["lina_laguna_blade"],
    [HeroName.Lion]: ["lion_finger_of_death"],
    [HeroName.Muerta]: ["muerta_pierce_the_veil"],
    // furion (nature’s prophet) missing
    [HeroName.Necrophos]: ["necrolyte_ghost_shroud", "necrolyte_reapers_scythe"],
    [HeroName.Oracle]: ["oracle_false_promise"],
    [HeroName.OutworldDestroyer]: ["obsidian_destroyer_sanity_eclipse"],
    [HeroName.Puck]: ["puck_dream_coil"],
    [HeroName.Pugna]: ["pugna_life_drain"],
    [HeroName.QueenOfPain]: ["queenofpain_sonic_wave"],
    [HeroName.Ringmaster]: ["ringmaster_wheel"], // likely custom hero
    // rubick missing
    [HeroName.ShadowDeamon]: ["shadow_demon_disruption", "shadow_demon_demonic_cleanse", "shadow_demon_demonic_purge"],
    [HeroName.ShadowShaman]: ["shadow_shaman_mass_serpent_ward"],
    [HeroName.Silencer]: ["silencer_global_silence"],
    [HeroName.SkywrathMage]: ["skywrath_mage_mystic_flare"],
    // storm_spirit, tinker missing
    [HeroName.Warlock]: ["warlock_fatal_bonds", "warlock_golem"],
    [HeroName.WitchDoctor]: ["witch_doctor_voodoo_switcheroo", "witch_doctor_death_ward"],
    [HeroName.Zeus]: ["zuus_thundergods_wrath"],

    // Universal
    [HeroName.Abaddon]: ["abaddon_borrowed_time"],
    [HeroName.Bane]: ["bane_fiends_grip"],
    [HeroName.Batrider]: ["batrider_flaming_lasso"],
    [HeroName.Beastmaster]: ["beastmaster_primal_roar"],
    [HeroName.Brewmaster]: ["brewmaster_primal_split"],
    [HeroName.Broodmother]: ["broodmother_insatiable_hunger"],
    [HeroName.Chen]: ["chen_hand_of_god"],
    // clockwerk missing
    [HeroName.DarkSeer]: ["dark_seer_wall_of_replica"],
    [HeroName.DarkWillow]: ["dark_willow_terrorize"],
    // dazzle missing
    [HeroName.Enigma]: ["enigma_black_hole"],
    // invoker, io, lone_druid missing
    [HeroName.Lycan]: ["lycan_shapeshift"],
    [HeroName.Magnus]: ["magnataur_reverse_polarity"],
    [HeroName.Marci]: ["marci_unleash"],
    // mirana, nyx_assassin missing
    [HeroName.Pangolier]: ["pangolier_gyroshell"],
    [HeroName.Phoenix]: ["phoenix_supernova"],
    [HeroName.SandKing]: ["sandking_epicenter"],
    [HeroName.Snapfire]: ["snapfire_mortimer_kisses"],
    // techies missing
    [HeroName.VengefulSpirit]: ["vengefulspirit_nether_swap"],
    [HeroName.Venomancer]: ["venomancer_noxious_plague"],
    // visage, void_spirit missing
    [HeroName.Windrunner]: ["windrunner_focusfire"],
    [HeroName.WinterWyvern]: ["winter_wyvern_cold_embrace", "winter_wyvern_winters_curse"],
};

export const ImportantItems: string[] = ["item_black_king_bar", "item_refresher"];

// Global array to store avoidance zones
let avoidanceZones: AvoidanceZone[] = [];

// Some gaming state keepers to keep a record of different states to avoid recomupte or anything.
export const GameStates: GameState = {
    defendPings: null,
    recentDefendTime: -200,
    cachedVars: null,
};
export const LoneDruid = {} as { [key: number]: any };
export const FrameProcessTime = 0.05;

export const EstimatedEnemyRoles = {
    // sample role entry
    npc_dota_hero_any: {
        lane: Lane.Mid,
        role: 2,
    },
} as { [key: string]: any };

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
                print(prefix + "[WARN] Table has deep nested tables in it, stop printing more nested tables.");
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
        print(`Unit ${unit.GetUnitName()} has modifier ${modifierName} with stack count ${stackCount}`);
    }
}

export function PrintPings(pingTimeGap: number): void {
    const listPings = [];
    const teamPlayers = GetTeamPlayers(GetTeam());

    // for (const [_, zone] of GetAvoidanceZones().entries()) {
    //     PrintTable(zone);
    // }

    for (const [index, _] of teamPlayers.entries()) {
        const allyHero = GetTeamMember(index);
        if (allyHero === null || allyHero.IsIllusion()) {
            continue;
        }
        const ping = allyHero.GetMostRecentPing();
        if (ping.time !== 0 && GameTime() - ping.time < pingTimeGap) {
            listPings.push(ping);

            // // print units and modifiers.
            // for (const unit of GetUnitList(UnitType.All)) {
            //     if (
            //         IsValidHero(unit) &&
            //         GetLocationToLocationDistance(
            //             ping.location,
            //             unit.GetLocation()
            //         ) < 400
            //     ) {
            //         print(unit.GetUnitName());
            //         PrintUnitModifiers(unit);
            //     }
            // }
        }
    }
    if (listPings.length > 0) {
        PrintTable(listPings);
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

/**
 * Get the direction of the team side.
 * @param team - The team to get the direction for.
 * @returns The direction of the team side.
 */
export function GetTeamSideDirection(team: number): Vector {
    // Radiant side => roughly bottom-left
    // Dire side    => roughly top-right
    if (team === Team.Radiant) {
        // e.g. direction (-1, -1) normalized
        return Vector(-1, -1, 0).Normalized();
    } else {
        // e.g. direction (1, 1) normalized
        return Vector(1, 1, 0).Normalized();
    }
}

/**
 * Shuffle an array.
 * @param tbl - The array to shuffle.
 * @returns The shuffled array.
 */
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
        bot.frameProcessTime = FrameProcessTime + +(math.fmod(bot.GetPlayerID() / 1000, FrameProcessTime / 10) * 2).toFixed(2);
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

export function IsPingedByAnyPlayer(bot: Unit, pingTimeGap: number, minDistance: number | null, maxDistance: number | null): Ping | null {
    if (!bot.IsAlive()) {
        return null;
    }

    const pings = [];
    const teamPlayerIds = GetTeamPlayers(GetTeam());

    minDistance = minDistance || 1500;
    maxDistance = maxDistance || 10000;

    for (const [index, _] of teamPlayerIds.entries()) {
        const teamMember = GetTeamMember(index);
        if (teamMember === null || teamMember.IsIllusion() || teamMember === bot) {
            continue;
        }

        const ping = teamMember.GetMostRecentPing();
        if (ping !== null) {
            pings.push(ping);
        }
    }

    for (const ping of pings) {
        const distanceToBot = GetLocationToLocationDistance(ping.location, bot.GetLocation());
        const withinRange = minDistance <= distanceToBot && distanceToBot <= maxDistance;
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

export function SetCachedVars(key: string, value: any) {
    if (!GameStates.cachedVars) {
        GameStates.cachedVars = {};
    }
    GameStates.cachedVars[key] = value;
    GameStates.cachedVars[`${key}-Time`] = DotaTime();
}

export function GetCachedVars(key: string, withinTime: number) {
    if (!GameStates.cachedVars || !GameStates.cachedVars[key]) {
        return null;
    }
    if (DotaTime() - GameStates.cachedVars[`${key}-Time`] <= withinTime) {
        return GameStates.cachedVars[key];
    }
    return null;
}

export function CleanupCachedVars() {
    if (!GameStates.cachedVars) {
        return;
    }
    for (const key in GameStates.cachedVars) {
        if (key.endsWith("-Time")) {
            const originalKey = key.slice(0, -5);
            if (DotaTime() - GameStates.cachedVars[key] > CachedVarsCleanTime) {
                delete GameStates.cachedVars[originalKey];
                delete GameStates.cachedVars[key];
            }
        }
    }
}

export function GetDistanceFromAncient(bot: Unit, enemy: boolean): number {
    const ancient = GetAncient(enemy ? GetOpposingTeam() : GetTeam());
    return GetUnitToUnitDistance(bot, ancient);
}

/**
 * Check if the target is a valid unit. can be hero, creep, or building.
 * @param target - The unit to check.
 * @returns True if the target is a valid unit, false otherwise.
 */
export function IsValidUnit(target: Unit): boolean {
    return target !== null && !target.IsNull() && target.CanBeSeen() && target.IsAlive() && !target.IsInvulnerable();
}

/**
 * Check if the target is a valid hero.
 * @param target - The unit to check.
 * @returns True if the target is a valid hero, false otherwise.
 */
export function IsValidHero(target: Unit): boolean {
    return IsValidUnit(target) && target.IsHero();
}

/**
 * Check if the target is a valid creep.
 * @param target - The unit to check.
 * @returns True if the target is a valid creep, false otherwise.
 */
export function IsValidCreep(target: Unit): boolean {
    return IsValidUnit(target) && target.GetHealth() < 5000 && !target.IsHero() && (GetBot().GetLevel() > 9 || !target.IsAncientCreep());
}

/**
 * Check if the target is a valid building.
 * @param target - The unit to check.
 * @returns True if the target is a valid building, false otherwise.
 */
export function IsValidBuilding(target: Unit): boolean {
    return IsValidUnit(target) && target.IsBuilding();
}

/**
 * Check if the bot has the item in its inventory.
 * @param bot - The bot to check.
 * @param itemName - The name of the item to check.
 * @returns True if the bot has the item, false otherwise.
 */
export function HasItem(bot: Unit, itemName: string): boolean {
    const slot = bot.FindItemSlot(itemName);
    return slot >= 0 && slot <= 8;
}

/**
 * Find an ally with the given name.
 * @param name - The name of the ally to find.
 * @returns The ally if found, null otherwise.
 */
export function FindAllyWithName(name: string): Unit | null {
    for (const ally of GetUnitList(UnitType.AlliedHeroes)) {
        if (IsValidHero(ally) && string.find(ally.GetUnitName(), name)) {
            return ally;
        }
    }
    return null;
}

/**
 * Get the distance between two locations.
 * @param fLoc - The first location.
 * @param sLoc - The second location.
 * @returns The distance between the two locations.
 */
export function GetLocationToLocationDistance(fLoc: Vector, sLoc: Vector): number {
    const x1 = fLoc.x;
    const x2 = sLoc.x;
    const y1 = fLoc.y;
    const y2 = sLoc.y;
    return math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1));
}

/**
 * Deep copy an object.
 * @param orig - The object to copy.
 * @returns The copied object.
 */
export function Deepcopy<T extends ArrayLike<unknown>>(orig: T): T {
    const originalType = type(orig);
    let copy;
    if (originalType == "table") {
        copy = {} as T;
        for (const [key, value] of Object.entries(orig)) {
            // @ts-ignore
            copy[Deepcopy(key)] = Deepcopy(value);
        }
        setmetatable(copy as object, Deepcopy(getmetatable(orig) as any) as object);
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

export function RemoveValueFromTable(table_: unknown[], valueToRemove: any, removeAll: boolean) {
    for (const index of $range(table_.length, 1, -1)) {
        if (table_[index - 1] === valueToRemove) {
            // table.remove(table_, index);
            delete table_[index - 1];
            if (!removeAll) {
                return;
            }
        }
    }
}

export function NumActionTypeInQueue(bot: Unit, searchedActionType: BotActionType) {
    let count: number = 0;
    for (const index of $range(1, bot.NumQueuedActions())) {
        const actionType = bot.GetQueuedActionType(index);
        if (actionType === searchedActionType) {
            count++;
        }
    }
    return count;
}

const humanCountCache: { [key in Team]: [number, number] } = {};

export function NumHumanBotPlayersInTeam(team: Team): LuaMultiReturn<[number, number]> {
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

export function GetNearbyAllyAverageHpPercent(bot: Unit, radius: number): number {
    let averageHpPercent = 0;
    const teamPlayers = GetTeamPlayers(bot.GetTeam());
    for (let playerdId of teamPlayers) {
        const ally = GetTeamMember(playerdId);
        if (ally && ally.IsAlive() && GetUnitToUnitDistance(ally, bot) <= radius) {
            averageHpPercent += ally.GetHealth() / ally.GetMaxHealth();
        }
    }

    return averageHpPercent / teamPlayers.length;
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

export function AbilityBehaviorHasFlag(behavior: number, flag: number): boolean {
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
    return bot.WasRecentlyDamagedByAnyHero(delta) || bot.WasRecentlyDamagedByTower(delta) || bot.WasRecentlyDamagedByCreep(delta);
}

export function IsUnitWithName(unit: Unit, name: string): boolean {
    const result = string.find(unit.GetUnitName(), name);
    return result !== null;
}

export function IsBear(unit: Unit) {
    return IsUnitWithName(unit, "lone_druid_bear");
}

export function GetOffsetLocationTowardsTargetLocation(initLoc: Vector, targetLoc: Vector, offsetDist: number) {
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
        if (u && u.GetUnitName() === "npc_dota_courier" && u.GetCurrentMovementSpeed() === 1100) {
            return true;
        }
    }
    return false;
}

// TODO: To guess the role of an enemy bot. Role should be determine around 1-2mins in the game based on lanes. In mid-late game, re-determine by networth.
export function DetermineEnemyBotRole(bot: Unit): number {
    const botName = bot.GetUnitName();
    const estimatedRole = EstimatedEnemyRoles[botName];
    if (estimatedRole == null) {
        print(`Enemy bot ${botName} role not cached yet.`);
        return 3;
    }

    return estimatedRole.role;
}

// TODO: Just trying. Does not work.
export function QueryCounters(heroId: number) {
    print("heroId=" + heroId);
    Request.RawGetRequest(`https://api.opendota.com/api/heroes/${heroId}/matchups`, function (res) {
        PrintTable(res);
    });
}
export function InitiStats() {
    Request.GetUUID(function (uuid) {
        print("uuid=" + uuid);
    });
}

export function GetLoneDruid(bot: Unit): any {
    let res = LoneDruid[bot.GetPlayerID()];
    if (res === null) {
        LoneDruid[bot.GetPlayerID()] = {};
        res = LoneDruid[bot.GetPlayerID()];
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

export function getCustomAvoidanceZones(): Array<{
    center: Vector;
    radius: number;
}> {
    return avoidanceZones;
}

const specialOffensiveHeroes = [HeroName.ArcWarden, HeroName.Phoenix, HeroName.Terrorblade];
export function IsSpecialOffensiveHero(name: string): boolean {
    return name in specialOffensiveHeroes;
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

export function findPathAvoidingZones(
    // @ts-ignore
    startPosition: Vector,
    // @ts-ignore
    endPosition: Vector
): Vector[] {
    // Implement A* pathfinding algorithm here
    // Each node should check for collision with avoidance zones
    // Return a path array of Vectors that avoids the zones
    return [];
}

export function IsBuildingAttackedByEnemy(building: Unit): Unit | null {
    for (const hero of GetUnitList(UnitType.EnemyHeroes)) {
        if (IsValidHero(hero) && GetUnitToUnitDistance(building, hero) <= hero.GetAttackRange() + 200 && hero.GetAttackTarget() == building) {
            return building;
        }
    }
    // if (building.WasRecentlyDamagedByAnyHero(2) || building.WasRecentlyDamagedByCreep(2)) {
    //     return building
    // }
    return null;
}

export function IsAnyBarrackAttackByEnemyHero(): Unit | null {
    for (const barrackE of BarrackList) {
        const barrack = GetBarracks(GetTeam(), barrackE);
        if (barrack != null && barrack.GetHealth() > 0) {
            const bar = IsBuildingAttackedByEnemy(barrack);
            if (bar != null) {
                return bar;
            }
        }
    }
    return null;
}

export function IsAnyBarracksOnLaneAlive(bEnemy: boolean, lane: Lane): boolean {
    let barracks: (Unit | null)[] = [];
    let team = GetTeam();
    if (bEnemy) {
        team = GetOpposingTeam();
    }

    if (lane == Lane.Top) {
        barracks = [GetBarracks(team, Barracks.TopMelee), GetBarracks(team, Barracks.TopRanged)];
    } else if (lane == Lane.Mid) {
        barracks = [GetBarracks(team, Barracks.MidMelee), GetBarracks(team, Barracks.MidRanged)];
    } else if (lane == Lane.Bot) {
        barracks = [GetBarracks(team, Barracks.BotMelee), GetBarracks(team, Barracks.BotRanged)];
    }
    return IsAnyOfTheBuildingsAlive(barracks);
}

export function IsAnyOfTheBuildingsAlive(buildings: (Unit | null)[]): boolean {
    for (const building of buildings) {
        if (building != null && (!building.CanBeSeen() || building.GetHealth() > 0)) {
            return true;
        }
    }
    return false;
}

// @ts-ignore
let IsHumanPlayerInTeamCache: { [key: number]: boolean } = {
    [Team.Radiant]: null,
    [Team.Dire]: null,
};

export function IsHumanPlayerInAnyTeam(): boolean {
    return IsHumanPlayerInTeam(Team.Radiant) || IsHumanPlayerInTeam(Team.Dire);
}

export function IsHumanPlayerInTeam(team: Team): boolean {
    if (IsHumanPlayerInTeamCache[team] !== null) {
        return IsHumanPlayerInTeamCache[team];
    }

    for (let playerdId of GetTeamPlayers(team)) {
        if (!IsPlayerBot(playerdId)) {
            IsHumanPlayerInTeamCache[team] = true;
            return true;
        }
    }
    IsHumanPlayerInTeamCache[team] = false;
    return false;
}

/**
 * Get the enemy hero by player id.
 * @param id - The player id to check.
 * @returns The enemy hero if found, null otherwise.
 */
export function GetEnemyHeroByPlayerId(id: number): Unit | null {
    for (const hero of GetUnitList(UnitType.EnemyHeroes)) {
        if (IsValidHero(hero) && hero.GetPlayerID() == id) {
            return hero;
        }
    }
    return null;
}

/**
 * Check if the unit is truely invisible.
 * @param unit - The unit to check.
 * @returns True if the unit is truely invisible, false otherwise.
 */
export function IsTruelyInvisible(unit: Unit): boolean {
    return unit.IsInvisible() && !unit.HasModifier("modifier_item_dustofappearance") && !RecentlyTookDamage(unit, 1.5); // use 1.5s because invisibility may have delayed effect.
}

/**
 * Check if the unit has a modifier containing a specific name.
 * @param unit - The unit to check.
 * @param name - The name to check.
 * @returns True if the unit has a modifier containing the name, false otherwise.
 */
export function HasModifierContainsName(unit: Unit, name: string): boolean {
    if (!IsValidUnit(unit)) {
        return false;
    }
    const modifierCount = unit.NumModifiers();
    for (let i = 0; i < modifierCount; i++) {
        const modifierName = unit.GetModifierName(i);
        if (modifierName.indexOf(name) > -1) {
            return true;
        }
    }
    return false;
}

/**
 * Check if the unit is near an enemy second tier tower.
 * @param unit - The unit to check.
 * @param range - The range to check.
 * @returns True if the unit is near an enemy second tier tower, false otherwise.
 */
export function IsNearEnemySecondTierTower(unit: Unit, range: number): boolean {
    for (const towerId of SecondTierTowers) {
        const tower = GetTower(GetOpposingTeam(), towerId);
        if (tower !== null && IsValidBuilding(tower) && GetUnitToUnitDistance(unit, tower) < range) {
            return true;
        }
    }
    return false;
}

/**
 * Get the enemy ids near non-tier 1 towers.
 * @param range - The range to check.
 * @returns An object with tower ids as keys and their corresponding enemy ids.
 */
export function GetEnemyIdsNearNonTier1Towers(range: number) {
    let result = {} as { [key: number]: { tower: Unit; enemyIds: number[] } };
    for (const towerId of NonTier1Towers) {
        const tower = GetTower(GetTeam(), towerId);
        if (tower !== null && IsValidBuilding(tower)) {
            const eIds = GetLastSeenEnemyIdsNearLocation(tower.GetLocation(), range);
            result[towerId] = {
                tower: tower,
                enemyIds: eIds,
            };
        }
    }
    return result;
}

/**
 * Get the non-tier 1 tower with the least enemies around.
 * @param range - The range to check.
 * @returns The non-tier 1 tower with the least enemies around.
 */
export function GetNonTier1TowerWithLeastEnemiesAround(range: number): Unit | null {
    const towerEneCounts = GetEnemyIdsNearNonTier1Towers(range);
    let minCount = 999;
    let minCountTower = null;
    for (const towerId of NonTier1Towers) {
        const te = towerEneCounts[towerId];
        if (te !== null && te.enemyIds.length <= minCount) {
            minCountTower = te.tower;
            minCount = te.enemyIds.length;
        }
    }
    // if 0, no enemy near those towers anymore.
    if (minCount != 0) {
        return minCountTower;
    }
    return null;
}

/**
 * Get the closest tower or barrack to attack.
 * @param unit - The unit to check.
 * @returns The closest tower or barrack to attack.
 */
export function GetClosestTowerOrBarrackToAttack(unit: Unit): Unit | null {
    let closestBuilding: Unit | null = null;
    let closestDistance: number = Number.MAX_VALUE;

    for (const barrackE of BarrackList) {
        const barrack = GetBarracks(GetOpposingTeam(), barrackE);
        if (
            barrack != null &&
            barrack.GetHealth() > 0 &&
            !(
                barrack.HasModifier("modifier_fountain_glyph") ||
                barrack.HasModifier("modifier_invulnerable") ||
                barrack.HasModifier("modifier_backdoor_protection_active")
            )
        ) {
            const distance = GetUnitToUnitDistance(unit, barrack);
            if (distance < closestDistance) {
                closestDistance = distance;
                closestBuilding = barrack;
            }
        }
    }
    for (const towerId of HighGroundTowers) {
        const tower = GetTower(GetOpposingTeam(), towerId);
        if (
            tower !== null &&
            IsValidBuilding(tower) &&
            !(tower.HasModifier("modifier_fountain_glyph") || tower.HasModifier("modifier_invulnerable") || tower.HasModifier("modifier_backdoor_protection_active"))
        ) {
            const distance = GetUnitToUnitDistance(unit, tower);
            if (distance < closestDistance) {
                closestDistance = distance;
                closestBuilding = tower;
            }
        }
    }

    return closestBuilding;
}

/**
 * Check if the unit is near an enemy high ground tower.
 * @param unit - The unit to check.
 * @param range - The range to check.
 * @returns True if the unit is near an enemy high ground tower, false otherwise.
 */
export function IsNearEnemyHighGroundTower(unit: Unit, range: number): boolean {
    for (const towerId of HighGroundTowers) {
        const tower = GetTower(GetOpposingTeam(), towerId);
        if (tower !== null && IsValidBuilding(tower) && GetUnitToUnitDistance(unit, tower) < range) {
            return true;
        }
    }
    return false;
}

/**
 * Check if the team is pushing second tier or high ground.
 * @param bot - The bot to check.
 * @returns True if the team is pushing second tier or high ground, false otherwise.
 */
export function IsTeamPushingSecondTierOrHighGround(bot: Unit): boolean {
    const cacheKey = "IsTeamPushingSecondTierOrHighGround" + bot.GetTeam();
    const cachedRes = GetCachedVars(cacheKey, 0.5);
    if (cachedRes !== null) {
        return cachedRes;
    }
    const res =
        bot.GetNearbyHeroes(2000, false, BotMode.None).length > 2 &&
        (IsNearEnemySecondTierTower(bot, 2000) || IsNearEnemyHighGroundTower(bot, 3000) || GetUnitToUnitDistance(bot, GetAncient(GetOpposingTeam())) < 3000);
    SetCachedVars(cacheKey, res);
    return res;
}

/**
 * Get the number of alive heroes.
 * @param bEnemy - Whether to count enemy heroes.
 * @returns The number of alive heroes.
 */
export function GetNumOfAliveHeroes(bEnemy: boolean): number {
    let count = 0;
    let nTeam = GetTeam();
    if (bEnemy) {
        nTeam = GetOpposingTeam();
    }
    for (let playerdId of GetTeamPlayers(nTeam)) {
        if (IsHeroAlive(playerdId)) {
            count += 1;
        }
    }

    // print(`count alive hero for enemy: ${bEnemy} is ${count}`);
    return count;
}

/**
 * Count the missing enemy heroes.
 * @returns The number of missing enemy heroes.
 */
export function CountMissingEnemyHeroes(): number {
    const cacheKey = "CountMissingEnemyHeroes" + GetTeam();
    const cachedRes = GetCachedVars(cacheKey, 0.5);
    if (cachedRes !== null) {
        return cachedRes;
    }

    let count = 0;
    for (let playerdId of GetTeamPlayers(GetOpposingTeam())) {
        if (IsHeroAlive(playerdId)) {
            const lastSeenInfo = GetHeroLastSeenInfo(playerdId);
            if (lastSeenInfo !== null && lastSeenInfo[0] !== null) {
                const firstInfo = lastSeenInfo[0];
                if (firstInfo.time_since_seen >= 2.5) {
                    count += 1;
                    continue;
                }
                // const enemyHero = GetEnemyHeroByPlayerId(playerdId);
                // if (
                //     enemyHero &&
                //     enemyHero.HasModifier("modifier_teleporting")
                // ) {
                //     count += 1;
                // }
            }
        }
    }
    // print(`count missing alive hero for enemy: ${count}`);
    SetCachedVars(cacheKey, count);
    return count;
}

/**
 * Find an ally with at least a certain distance away from a bot.
 * @param bot - The bot to check.
 * @param nDistance - The minimum distance to check.
 * @returns The ally if found, null otherwise.
 */
export function FindAllyWithAtLeastDistanceAway(bot: Unit, nDistance: number) {
    if (bot.GetTeam() !== GetTeam()) {
        print("[ERROR] Wrong usage of the method");
        return null;
    }

    const teamPlayers = GetTeamPlayers(GetTeam());
    for (const [index, _] of teamPlayers.entries()) {
        const teamMember = GetTeamMember(index);
        if (teamMember !== null && teamMember.IsAlive() && GetUnitToUnitDistance(teamMember, bot) >= nDistance) {
            return teamMember;
        }
    }
    return null;
}

/**
 * Get the last seen enemy ids near a location.
 * @param vLoc - The location to check.
 * @param nDistance - The distance to check.
 * @returns An array of enemy ids.
 */
export function GetLastSeenEnemyIdsNearLocation(vLoc: Vector, nDistance: number): number[] {
    let enemies = [];
    for (let playerdId of GetTeamPlayers(GetOpposingTeam())) {
        if (IsHeroAlive(playerdId)) {
            const lastSeenInfo = GetHeroLastSeenInfo(playerdId);
            if (lastSeenInfo !== null && lastSeenInfo[0] !== null) {
                const firstInfo = lastSeenInfo[0];
                if (GetLocationToLocationDistance(firstInfo.location, vLoc) <= nDistance && firstInfo.time_since_seen <= 3) {
                    enemies.push(playerdId);
                }
            }
        }
    }

    enemies = enemies.concat(GetEnemyIdsInTpToLocation(vLoc, nDistance));

    return enemies;
}

/**
 * Get the enemy ids in teleport to a location.
 * @param vLoc - The location to check.
 * @param nDistance - The distance to check.
 * @returns An array of enemy ids.
 */
export function GetEnemyIdsInTpToLocation(vLoc: Vector, nDistance: number): number[] {
    const enemies = [];
    for (let tp of GetIncomingTeleports()) {
        if (tp !== null && GetLocationToLocationDistance(vLoc, tp.location) <= nDistance && !IsTeamPlayer(tp.playerid)) {
            enemies.push(tp.playerid);
        }
    }
    return enemies;
}

/**
 * Check if the given enemy hero meets the "threat conditions" for special AOE.
 *
 * @param enemy - The enemy hero unit.
 * @param threatInfo - The conditions for that hero (level, items, modifiers).
 * @returns true if the enemy meets the condition, otherwise false.
 */
function DoesHeroMeetThreatConditions(enemy: Unit, threatInfo: AOEHeroThreat): boolean {
    // Check level requirement
    if (enemy.GetLevel() < threatInfo.minLevel) {
        return false;
    }

    // Check items
    for (const itemName of threatInfo.requiredItems) {
        // If the hero does not have at least one instance of 'itemName', fail
        if (!HasItem(enemy, itemName)) {
            return false;
        }
    }

    // Check required modifiers
    for (const modName of threatInfo.requiredModifiers) {
        // If the hero does not have 'modName' active, fail
        if (!enemy.HasModifier(modName)) {
            return false;
        }
    }

    return true;
}

/**
 * Determine if there's at least one dangerous "Special AOE hero" nearby
 * that meets the threat conditions for big combos.
 *
 * @param bot - The bot unit to check around.
 * @param nRadius - The search radius (e.g. 500 or 2000).
 * @returns true if we found at least one special AOE threat in range.
 */
export function IsAnySpecialAOEThreatNearby(bot: Unit, nRadius: number): boolean {
    // 1) Grab the list of nearby enemy heroes
    // const nearbyEnemies = bot.GetNearbyHeroes(radius, true, BotMode.None);
    // if (!nearbyEnemies || nearbyEnemies.length === 0) {
    //     return false;
    // }

    // 2) Iterate each enemy hero
    for (const enemy of GetUnitList(UnitType.EnemyHeroes)) {
        const enemyName = enemy.GetUnitName() as HeroName; // cast as HeroName if needed

        // 3) If this hero is in our "special AOE hero" mapping, check conditions
        if (IsValidHero(enemy) && enemyName in SpecialAOEHeroesDetails) {
            const threatInfo = SpecialAOEHeroesDetails[enemyName];

            // 4) If the hero meets threat conditions => we should spread out
            if (bot.GetNearbyHeroes(nRadius, false, BotMode.None).length <= 1 && bot.GetNearbyLaneCreeps(nRadius, false).length <= 2) {
                return false;
            }
            // Don't need to check if enemy is in a nearby range since enemy can have blink
            if (DoesHeroMeetThreatConditions(enemy, threatInfo)) {
                // print(`Special potential AOE threat detected for ${bot.GetUnitName()} against ${enemyName}.`);
                // PrintTable(threatInfo);
                return true;
            }
        }
    }

    // No threatening special AOE heroes found
    return false;
}

/**
 * Check if the bots should spread out.
 * @param bot - The bot to check.
 * @param minDistance - The minimum distance to check.
 * @returns True if the bots should spread out, false otherwise.
 */
export function ShouldBotsSpreadOut(bot: Unit, minDistance: number): boolean {
    const cacheKey = "ShouldBotsSpreadOut" + bot.GetPlayerID();
    const cachedRes = GetCachedVars(cacheKey, 0.1);
    if (cachedRes !== null) {
        return cachedRes;
    }

    let bResult = false;
    const threatNearby = IsAnySpecialAOEThreatNearby(bot, minDistance);
    if (threatNearby) {
        bResult = true;
    }
    SetCachedVars(cacheKey, bResult);
    return bResult;
}

/**
 * Get the nearby ally units.
 * @param bot - The bot to check.
 * @param allyDistanceThreshold - The distance threshold to check for allies.
 * @returns An array of ally units.
 */
export function GetNearbyAllyUnits(bot: Unit, allyDistanceThreshold: number): Unit[] {
    const cacheKey = "GetNearbyAllyUnits" + bot.GetPlayerID();
    const cachedRes = GetCachedVars(cacheKey, 0.1);
    if (cachedRes !== null) {
        return cachedRes;
    }
    const hNearbyAllies = bot.GetNearbyHeroes(allyDistanceThreshold, false, BotMode.None);
    const hNearbyLaneCreeps = bot.GetNearbyLaneCreeps(allyDistanceThreshold, false);
    const hNearbyUnits = hNearbyAllies.concat(hNearbyLaneCreeps);
    SetCachedVars(cacheKey, hNearbyUnits);
    return hNearbyUnits;
}

/**
 * Smart spread out the bots.
 * Emphasizes moving away from allies/enemies quickly while still
 * giving a mild pull toward fountain side if needed.
 *
 * @param bot - The bot to move.
 * @param allyDistanceThreshold - Distance threshold to check for allies.
 * @param minDistance - The minimum distance to keep from allies.
 * @param avoidEnemyUnits - The enemy units to avoid.
 * @param onlyAvoidEnemyUnits - If true, only avoid enemy units (ignore allies).
 */
export function SmartSpreadOut(bot: Unit, allyDistanceThreshold: number, minDistance: number, avoidEnemyUnits: Unit[] = [], onlyAvoidEnemyUnits: boolean = false) {
    let hNearbyUnits: Unit[] = [];
    if (onlyAvoidEnemyUnits) {
        hNearbyUnits = avoidEnemyUnits;
    } else {
        hNearbyUnits = GetNearbyAllyUnits(bot, allyDistanceThreshold).concat(avoidEnemyUnits);
    }

    // 2) Get the direction that moves the bot away from any nearby allies/enemies:
    const dirAwayFromAlly = SpreadBotApartDir(bot, minDistance, hNearbyUnits);
    if (!dirAwayFromAlly) {
        // If there is no particular direction needed, move back to fountain
        bot.Action_MoveToLocation(add(GetTeamFountainTpPoint(), RandomVector(50)));
        return;
    }

    // Current location
    const botLoc = bot.GetLocation();

    // 3) A mild pull in the direction of our "team side"
    //    (this helps ensure we don't drift too far forward if no enemies are nearby).
    //    If you want to completely remove fountain logic, set fountainWeight to 0.
    const awayFromAllyWeight = 0.7; // Primary emphasis: spread away from allies/enemies
    const fountainWeight = 0.3; // Mild emphasis toward bot's own side
    let teamFountainDir = GetTeamSideDirection(GetTeam());

    // If absolutely no enemies to avoid, we could reduce the fountain direction:
    if (avoidEnemyUnits.length === 0) {
        teamFountainDir = multiply(teamFountainDir, 0.5);
    }

    // 4) Combine directions with weights, then normalize
    const combinedDir = add(multiply(dirAwayFromAlly, awayFromAllyWeight), multiply(teamFountainDir, fountainWeight)).Normalized();

    // 5) Multiply by desired spread distance:
    let finalDir = multiply(combinedDir, minDistance);

    // 6) Ensure we do NOT move toward the enemy fountain
    const enemyFountainDir = sub(GetEnemyFountainTpPoint(), botLoc).Normalized();

    // If finalDir is pointing in the same general direction as the enemy fountain, fix it
    if (dot(finalDir.Normalized(), enemyFountainDir) > 0) {
        // Override: push away from enemy fountain instead
        // or at least pull back with the 'team side' direction
        finalDir = multiply(teamFountainDir, minDistance);
    }

    let targetLoc = add(botLoc, finalDir);

    // 7) Another fail-safe check: if the bot is already quite close to the enemy base,
    //    do not proceed further in that direction.
    if (GetDistanceFromAncient(bot, true) < 2600) {
        // If the chosen target is still forward, override
        if (dot(sub(targetLoc, botLoc), enemyFountainDir) > 0) {
            finalDir = multiply(teamFountainDir, minDistance);
            targetLoc = add(botLoc, finalDir);
        }
    }

    // 8) Move the bot to the new target location with a small random offset
    bot.Action_MoveToLocation(add(targetLoc, RandomVector(50)));
}

/**
 * Spread the bot apart from the allies.
 * @param bot - The bot to check.
 * @param minDistance - The distance to check.
 * @param hNearbyUnits - The units to check.
 * @returns The direction to spread the bot apart.
 */
export function SpreadBotApartDir(bot: Unit, minDistance: number, hNearbyUnits: Unit[]): Vector | null {
    const botLoc = bot.GetLocation();

    for (const unit of hNearbyUnits) {
        if (IsValidUnit(unit) && unit !== bot && GetUnitToUnitDistance(bot, unit) <= minDistance) {
            // dir = botLoc - ally:GetLocation() in Lua
            const dir = sub(botLoc, unit.GetLocation());
            // dir:Normalized() * distance in Lua
            return multiply(dir.Normalized(), minDistance);
        }
    }

    return null;
}

/**
 * Spread the bot apart from the allies.
 * @param bot - The bot to check.
 * @param minDistance - The distance to check.
 * @param hNearbyUnits - The units to check.
 * @returns The direction to spread the bot apart.
 */
export function SpreadBotApartDir_2(bot: Unit, minDistance: number, hNearbyUnits: Unit[]): Vector | null {
    const cacheKey = "SpreadBotApartDir" + bot.GetPlayerID();
    const cachedRes = GetCachedVars(cacheKey, 0.1);
    if (cachedRes !== null) {
        return cachedRes;
    }

    const botLoc = bot.GetLocation();

    // We'll accumulate a combined direction vector here.
    // Start it at the zero vector.
    let combinedDir = Vector(0, 0, 0);

    // 1) Check each unit and, if within minDistance, add the direction away from that unit.
    for (const unit of hNearbyUnits) {
        if (IsValidUnit(unit) && unit !== bot) {
            const dist = GetUnitToUnitDistance(bot, unit);
            if (dist <= minDistance) {
                // Direction from 'unit' to 'bot'
                // In Lua: dir = botLoc - unit:GetLocation()
                const dir = sub(botLoc, unit.GetLocation());
                // Accumulate it in combinedDir
                combinedDir = add(combinedDir, dir);
            }
        }
    }

    // 2) Check the length of our summed direction.
    const dirLength = length3D(combinedDir);
    if (dirLength < 1e-5) {
        // Either no units in range or they balanced each other out
        SetCachedVars(cacheKey, null);
        return null;
    }

    // 3) Normalize and multiply to get a final direction of length minDistance.
    //    i.e., direction * minDistance
    const finalDir = multiply(combinedDir.Normalized(), minDistance);
    SetCachedVars(cacheKey, finalDir);
    return finalDir;
}

/**
 * Get the ally ids in teleport to a location.
 * @param vLoc - The location to check.
 * @param nDistance - The distance to check.
 * @returns An array of ally ids.
 */
export function GetAllyIdsInTpToLocation(vLoc: Vector, nDistance: number): number[] {
    const allies = [];
    for (let tp of GetIncomingTeleports()) {
        if (tp !== null && GetLocationToLocationDistance(vLoc, tp.location) <= nDistance && IsTeamPlayer(tp.playerid)) {
            allies.push(tp.playerid);
        }
    }
    return allies;
}

/**
 * Check if the bot is pushing a tower in danger.
 * @param bot - The bot to check.
 * @returns True if the bot is pushing a tower in danger, false otherwise.
 */
export function IsBotPushingTowerInDanger(bot: Unit): boolean {
    const enemyTowerNearby = bot.GetNearbyTowers(1100, true).length >= 1; // want to come a bit closer to the tower and be cautious while seducing enemy to defend.
    if (!enemyTowerNearby) {
        return false;
    }

    const nearbyAllies = bot.GetNearbyHeroes(1600, false, BotMode.None);
    const countAliveEnemies = GetNumOfAliveHeroes(true);

    const nearbyEnemy = GetLastSeenEnemyIdsNearLocation(bot.GetLocation(), 2000);

    if (enemyTowerNearby && nearbyAllies.length < countAliveEnemies && nearbyEnemy.length >= nearbyAllies.length) {
        return true;
    }
    return false;
}

/**
 * Get the distance to the closest enemy tower.
 * @param bot - The bot to check.
 * @returns The distance to the closest enemy tower.
 */
export function GetDistanceToCloestEnemyTower(bot: Unit): LuaMultiReturn<[number, Unit | null]> {
    let cTower = null;
    let cDistance = 99999;
    for (const towerId of AllTowers) {
        const tower = GetTower(GetOpposingTeam(), towerId);
        if (
            tower !== null &&
            IsValidBuilding(tower) &&
            !(tower.HasModifier("modifier_fountain_glyph") || tower.HasModifier("modifier_invulnerable") || tower.HasModifier("modifier_backdoor_protection_active"))
        ) {
            const tDistance = GetUnitToUnitDistance(bot, tower);
            if (tDistance < cDistance) {
                cTower = tower;
                cDistance = tDistance;
            }
        }
    }
    return $multi(cDistance, cTower);
}

/**
 * Get circular points around a center point.
 * @param vCenter - The center point.
 * @param nRadius - The radius of the circle.
 * @param numPoints - The number of points to get.
 * @returns An array of vectors representing the points.
 */
export function GetCirclarPointsAroundCenterPoint(vCenter: Vector, nRadius: number, numPoints: number): Vector[] {
    const points: Vector[] = [vCenter];
    const angleStep = 360 / numPoints;

    for (let i = 1; i <= numPoints; i++) {
        const angleRad = angleStep * i * (Math.PI / 180); // Convert degrees to radians
        const point: Vector = Vector(vCenter.x + nRadius * Math.cos(angleRad), vCenter.y + nRadius * Math.sin(angleRad), vCenter.z);
        points.push(point);
    }

    return points;
}

/**
 * Check if the ability is valid.
 * @param ability - The ability to check.
 * @returns True if the ability is valid, false otherwise.
 */
export function IsValidAbility(ability: Ability): boolean {
    if (ability === null || ability.IsNull() || ability.GetName() === "" || ability.IsHidden() || !ability.IsTrained() || !ability.IsActivated()) {
        return false;
    }
    return true;
}

/**
 * Check if the bot has a critical spell with a cooldown greater than nDuration.
 * @param bot - The bot to check.
 * @param nDuration - The duration to check against.
 * @returns True if the bot has a critical spell with a cooldown greater than nDuration, false otherwise.
 */
export function HasCriticalSpellWithCooldown(bot: Unit, nDuration: number): boolean {
    const cacheKey = "HasCriticalSpellWithCooldown" + bot.GetPlayerID() + nDuration;
    const cachedRes = GetCachedVars(cacheKey, 2);
    if (cachedRes !== null) {
        return cachedRes;
    }
    const heroName = bot.GetUnitName();
    if (heroName in ImportantSpells) {
        const ability = bot.GetAbilityByName(ImportantSpells[heroName][0]);
        if (IsValidAbility(ability) && ability.GetCooldownTimeRemaining() > nDuration) {
            SetCachedVars(cacheKey, true);
            return true;
        }
    }
    SetCachedVars(cacheKey, false);
    return false;
}

/**
 * Get an item from the bot's active inventory.
 * @param bot - The bot to check.
 * @param itemName - The name of the item to get.
 * @returns The item if found, null otherwise.
 */
export function GetItem(bot: Unit, itemName: string): Item | null {
    return GetItemFromCountedInventory(bot, itemName, 6);
}

/**
 * Get an item from the bot's full inventory.
 * @param bot - The bot to check.
 * @param itemName - The name of the item to get.
 * @returns The item if found, null otherwise.
 */
export function GetItemFromFullInventory(bot: Unit, itemName: string): Item | null {
    return GetItemFromCountedInventory(bot, itemName, 16);
}

/**
 * Get an item from the bot's inventory with a specific total slots count.
 * @param bot - The bot to check.
 * @param itemName - The name of the item to get.
 * @param count - The number of slots in inventory to check.
 * @returns The item if found, null otherwise.
 */
export function GetItemFromCountedInventory(bot: Unit, itemName: string, count: number): Item | null {
    const cacheKey = "GetItemFromCountedInventory" + bot.GetPlayerID() + itemName + count;
    const cachedRes = GetCachedVars(cacheKey, 2);
    if (cachedRes !== null) {
        return cachedRes;
    }
    for (let i = 0; i < count; i++) {
        const item = bot.GetItemInSlot(i);

        if (item && item.GetName() === itemName) {
            SetCachedVars(cacheKey, item);
            return item;
        }
    }
    SetCachedVars(cacheKey, null);
    return null;
}

/**
 * Check if the team has a member with a critical spell in cooldown when the bot walks & arrives to the location.
 * @param bot - The bot to check.
 * @param targetLoc - The location to check.
 * @returns True if the team has a member with a critical spell in cooldown, false otherwise.
 */
export function HasTeamMemberWithCriticalSpellInCooldown(targetLoc: Vector): boolean {
    const cacheKey = "HasTeamMemberWithCriticalSpellInCooldown" + GetTeam();
    const cachedRes = GetCachedVars(cacheKey, 2);
    if (cachedRes !== null) {
        return cachedRes;
    }
    for (const [index, _] of GetTeamPlayers(GetTeam()).entries()) {
        const teamMember = GetTeamMember(index);
        if (teamMember !== null && teamMember.IsAlive()) {
            const nDuration = GetUnitToLocationDistance(teamMember, targetLoc) / teamMember.GetCurrentMovementSpeed();
            if (HasCriticalSpellWithCooldown(teamMember, nDuration)) {
                SetCachedVars(cacheKey, true);
                // print("HasTeamMemberWithCriticalSpellInCooldown: " + tostring(teamMember.GetUnitName()) + " " + tostring(nDuration));
                return true;
            }
        }
    }
    SetCachedVars(cacheKey, false);
    return false;
}

/**
 * Check if the team has a member with a critical item in cooldown when the bot walks & arrives to the location.
 * @param bot - The bot to check.
 * @param targetLoc - The location to check.
 * @returns True if the team has a member with a critical item in cooldown, false otherwise.
 */
export function HasTeamMemberWithCriticalItemInCooldown(targetLoc: Vector): boolean {
    const cacheKey = "HasTeamMemberWithCriticalItemInCooldown" + GetTeam();
    const cachedRes = GetCachedVars(cacheKey, 2);
    if (cachedRes !== null) {
        return cachedRes;
    }
    for (const [index, _] of GetTeamPlayers(GetTeam()).entries()) {
        const teamMember = GetTeamMember(index);
        if (teamMember !== null && teamMember.IsAlive()) {
            const nDuration = GetUnitToLocationDistance(teamMember, targetLoc) / teamMember.GetCurrentMovementSpeed();
            for (const itemName of ImportantItems) {
                const item = GetItem(teamMember, itemName);
                if (item && item.GetCooldownTimeRemaining() > nDuration) {
                    SetCachedVars(cacheKey, true);
                    return true;
                }
            }
        }
    }
    SetCachedVars(cacheKey, false);
    return false;
}
