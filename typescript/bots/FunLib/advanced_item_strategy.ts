/**
 * Advanced Item Strategy System - TypeScript Version
 * Comprehensive item purchase strategy based on hero stat dimensions and enemy composition
 * Generates a complete item list for bots to purchase based on available gold
 */

import { HeroName } from "bots/ts_libs/dota/heroes";
import { HeroRolesMap, IsRanged } from "./aba_hero_roles_map";

// Type definitions for Dota 2 API
declare const GetTeamMember: (team: number, index: number) => any;
declare const GetOpposingTeam: () => number;
declare const DotaTime: () => number;

// Position types (pos_1 to pos_5) - these define the primary roles
export type Position = "pos_1" | "pos_2" | "pos_3" | "pos_4" | "pos_5";

// Range types
export type RangeType = "melee" | "ranged";

// Damage types
export type DamageType = "physical" | "magical";

// Starting items by position and range type
const STARTING_ITEMS: Record<Position, Record<RangeType, string[]>> = {
    pos_1: {
        melee: ["item_tango", "item_double_branches", "item_quelling_blade", "item_circlet"],
        ranged: ["item_tango", "item_double_branches", "item_slippers", "item_circlet"],
    },
    pos_2: {
        melee: ["item_tango", "item_double_branches", "item_faerie_fire", "item_circlet"],
        ranged: ["item_tango", "item_double_branches", "item_faerie_fire", "item_circlet"],
    },
    pos_3: {
        melee: ["item_tango", "item_double_branches", "item_quelling_blade"],
        ranged: ["item_tango", "item_double_branches", "item_circlet"],
    },
    pos_4: {
        melee: ["item_tango", "item_double_branches", "item_enchanted_mango", "item_blood_grenade"],
        ranged: ["item_tango", "item_double_branches", "item_enchanted_mango", "item_blood_grenade"],
    },
    pos_5: {
        melee: ["item_tango", "item_tango", "item_double_branches", "item_enchanted_mango", "item_blood_grenade"],
        ranged: ["item_tango", "item_tango", "item_double_branches", "item_enchanted_mango", "item_blood_grenade"],
    },
};

// Core items that all heroes need
const CORE_ITEMS = ["item_magic_wand", "item_boots"];

// Boots by position
const BOOTS_BY_POSITION: Record<Position, string[]> = {
    pos_1: ["item_power_treads"], // Carry - damage focused
    pos_2: ["item_power_treads"], // Mid - damage focused
    pos_3: ["item_phase_boots"], // Offlane - mobility and initiation
    pos_4: ["item_arcane_boots"], // Support - mana and utility
    pos_5: ["item_tranquil_boots"], // Hard Support - sustain and utility
};

// Items by position - focused on actual gameplay roles
const ITEMS_BY_POSITION: Record<Position, Record<RangeType, string[]>> = {
    pos_1: {
        // Carry (pos 1) - Primary damage dealer
        melee: [
            "item_wraith_band",
            "item_hand_of_midas",
            "item_bfury",
            "item_manta",
            "item_black_king_bar",
            "item_skadi",
            "item_butterfly",
            "item_abyssal_blade",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
        ranged: [
            "item_wraith_band",
            "item_hand_of_midas",
            "item_dragon_lance",
            "item_manta",
            "item_black_king_bar",
            "item_skadi",
            "item_butterfly",
            "item_bloodthorn",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
    },
    pos_2: {
        // Mid (pos 2) - Secondary damage dealer
        melee: [
            "item_bottle",
            "item_hand_of_midas",
            "item_blink",
            "item_black_king_bar",
            "item_cyclone",
            "item_octarine_core",
            "item_cyclone",
            "item_black_king_bar",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
        ranged: [
            "item_bottle",
            "item_hand_of_midas",
            "item_cyclone",
            "item_black_king_bar",
            "item_force_staff",
            "item_octarine_core",
            "item_cyclone",
            "item_black_king_bar",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
    },
    pos_3: {
        // Offlane (pos 3) - Initiator/Stunner
        melee: [
            "item_bracer",
            "item_blink",
            "item_lotus_orb",
            "item_black_king_bar",
            "item_heavens_halberd",
            "item_heart",
            "item_assault",
            "item_abyssal_blade",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
        ranged: [
            "item_bracer",
            "item_blink",
            "item_lotus_orb",
            "item_black_king_bar",
            "item_heavens_halberd",
            "item_heart",
            "item_assault",
            "item_heavens_halberd",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
    },
    pos_4: {
        // Support (pos 4) - Utility support
        melee: [
            "item_urn_of_shadows",
            "item_medallion_of_courage",
            "item_glimmer_cape",
            "item_force_staff",
            "item_guardian_greaves",
            "item_sheepstick",
            "item_guardian_greaves",
            "item_heavens_halberd",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
        ranged: [
            "item_urn_of_shadows",
            "item_medallion_of_courage",
            "item_glimmer_cape",
            "item_force_staff",
            "item_guardian_greaves",
            "item_sheepstick",
            "item_guardian_greaves",
            "item_cyclone",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
    },
    pos_5: {
        // Hard Support (pos 5) - Pure support
        melee: [
            "item_urn_of_shadows",
            "item_medallion_of_courage",
            "item_glimmer_cape",
            "item_force_staff",
            "item_boots_of_bearing",
            "item_sheepstick",
            "item_boots_of_bearing",
            "item_heavens_halberd",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
        ranged: [
            "item_urn_of_shadows",
            "item_medallion_of_courage",
            "item_glimmer_cape",
            "item_force_staff",
            "item_boots_of_bearing",
            "item_sheepstick",
            "item_boots_of_bearing",
            "item_cyclone",
            "item_travel_boots_2",
            "item_moon_shard",
            "item_ultimate_scepter_2",
        ],
    },
};

// Counter items for specific enemy threats
const COUNTER_ITEMS = {
    // Against high evasion
    evasion: ["item_monkey_king_bar", "item_bloodthorn"],

    // Against magic damage
    magic_heavy: ["item_black_king_bar", "item_pipe_of_insight", "item_lotus_orb"],

    // Against illusions
    illusion_heavy: ["item_maelstrom", "item_mjollnir", "item_radiance", "item_battlefury"],

    // Against invisibility
    invisibility: ["item_dust", "item_gem", "item_ward_sentry"],

    // Against specific heroes
    heroes: {
        [HeroName.PhantomAssassin]: ["item_monkey_king_bar", "item_bloodthorn"],
        [HeroName.Riki]: ["item_dust", "item_gem", "item_ward_sentry"],
        [HeroName.Antimage]: ["item_cyclone", "item_black_king_bar"],
    },
};

// Items that don't take inventory slots
const NON_SLOT_ITEMS = ["item_moon_shard", "item_ultimate_scepter_2", "item_aghanims_shard"];

// Helper functions
function getHeroRoles(heroName: HeroName) {
    return HeroRolesMap[heroName] || {};
}

function isRanged(heroName: HeroName): boolean {
    return IsRanged(heroName);
}

// Hero-specific item modifications based on role stats and hero characteristics
const HERO_SPECIFIC_MODIFICATIONS: Partial<
    Record<
        HeroName,
        {
            replaceItems?: Record<string, string[]>;
            addItems?: string[];
            removeItems?: string[];
        }
    >
> = {
    [HeroName.OgreMagi]: {
        addItems: ["item_hand_of_midas"], // Ogre Magi benefits from Midas
    },
    [HeroName.Slark]: {
        replaceItems: {
            item_bfury: ["item_diffusal_blade"], // Slark prefers Diffusal over BFury
        },
    },
};

function getEnemyHeroes(): HeroName[] {
    const enemies: HeroName[] = [];
    for (let i = 1; i <= 5; i++) {
        const enemy = GetTeamMember(GetOpposingTeam(), i);
        if (enemy && enemy.IsHero()) {
            enemies.push(enemy.GetUnitName() as HeroName);
        }
    }
    return enemies;
}

function applyHeroSpecificModifications(heroName: HeroName, build: string[]): string[] {
    const modifications = HERO_SPECIFIC_MODIFICATIONS[heroName];
    if (!modifications) {
        return build;
    }

    let modifiedBuild = [...build];

    // Apply item replacements
    if (modifications.replaceItems) {
        for (const [oldItem, newItems] of Object.entries(modifications.replaceItems)) {
            const index = modifiedBuild.indexOf(oldItem);
            if (index !== -1) {
                modifiedBuild.splice(index, 1, ...newItems);
            }
        }
    }

    // Add hero-specific items
    if (modifications.addItems) {
        modifiedBuild.push(...modifications.addItems);
    }

    // Remove hero-specific items
    if (modifications.removeItems) {
        for (const item of modifications.removeItems) {
            const index = modifiedBuild.indexOf(item);
            if (index !== -1) {
                modifiedBuild.splice(index, 1);
            }
        }
    }

    return modifiedBuild;
}

function getRoleBasedItems(heroName: HeroName, _position: Position): string[] {
    const roles = getHeroRoles(heroName);
    const additionalItems: string[] = [];

    // Add items based on role stats
    if (roles.initiator && roles.initiator >= 2) {
        additionalItems.push("item_blink");
    }

    if (roles.disabler && roles.disabler >= 2) {
        additionalItems.push("item_cyclone");
    }

    if (roles.healer && roles.healer >= 2) {
        additionalItems.push("item_guardian_greaves");
    }

    if (roles.nuker && roles.nuker >= 2) {
        additionalItems.push("item_octarine_core");
    }

    if (roles.durable && roles.durable >= 2) {
        additionalItems.push("item_heart");
    }

    if (roles.pusher && roles.pusher >= 2) {
        additionalItems.push("item_assault");
    }

    return additionalItems;
}

function hasEnemyThreat(enemies: HeroName[], threatType: string): boolean {
    for (const enemy of enemies) {
        if (threatType === "evasion") {
            if (enemy === HeroName.PhantomAssassin || enemy === HeroName.Windrunner || enemy === HeroName.Weaver || enemy === HeroName.Brewmaster) {
                return true;
            }
        } else if (threatType === "magic_heavy") {
            const roles = getHeroRoles(enemy);
            if (roles.nuker && roles.nuker >= 2) {
                return true;
            }
        } else if (threatType === "illusion_heavy") {
            if (enemy === HeroName.PhantomLancer || enemy === HeroName.ChaosKnight || enemy === HeroName.Terrorblade || enemy === HeroName.NagaSiren) {
                return true;
            }
        } else if (threatType === "invisibility") {
            if (enemy === HeroName.Riki || enemy === HeroName.BountyHunter || enemy === HeroName.Clinkz || enemy === HeroName.NyxAssassin) {
                return true;
            }
        }
    }
    return false;
}

// Removed getGamePhase function as we no longer use timing-based categories

// Main class for Advanced Item Strategy
export class AdvancedItemStrategy {
    /**
     * Generate item build based on position and range type
     */
    static GetItemBuild(bot: any, position: Position): string[] {
        const heroName = bot.GetUnitName() as HeroName;
        const enemies = getEnemyHeroes();

        const build: string[] = [];
        const isHeroRanged = isRanged(heroName);
        const rangeType: RangeType = isHeroRanged ? "ranged" : "melee";

        // Add starting items
        if (STARTING_ITEMS[position] && STARTING_ITEMS[position][rangeType]) {
            build.push(...STARTING_ITEMS[position][rangeType]);
        }

        // Add core items
        build.push(...CORE_ITEMS);

        // Add appropriate boots
        if (BOOTS_BY_POSITION[position]) {
            build.push(...BOOTS_BY_POSITION[position]);
        }

        // Add position-based items
        if (ITEMS_BY_POSITION[position] && ITEMS_BY_POSITION[position][rangeType]) {
            build.push(...ITEMS_BY_POSITION[position][rangeType]);
        }

        // Add role-based items based on hero stats
        const roleItems = getRoleBasedItems(heroName, position);
        build.push(...roleItems);

        // Add counter items based on enemy threats
        if (hasEnemyThreat(enemies, "evasion")) {
            build.push(...COUNTER_ITEMS.evasion);
        }

        if (hasEnemyThreat(enemies, "magic_heavy")) {
            build.push(...COUNTER_ITEMS.magic_heavy);
        }

        if (hasEnemyThreat(enemies, "illusion_heavy")) {
            build.push(...COUNTER_ITEMS.illusion_heavy);
        }

        if (hasEnemyThreat(enemies, "invisibility")) {
            build.push(...COUNTER_ITEMS.invisibility);
        }

        // Add specific hero counters
        for (const enemy of enemies) {
            if (COUNTER_ITEMS.heroes[enemy as keyof typeof COUNTER_ITEMS.heroes]) {
                build.push(...COUNTER_ITEMS.heroes[enemy as keyof typeof COUNTER_ITEMS.heroes]);
            }
        }

        // Apply hero-specific modifications
        return applyHeroSpecificModifications(heroName, build);
    }

    /**
     * Generate sell list based on item build
     */
    static GetSellList(_bot: any, _itemBuild: string[]): string[] {
        // Items that should be sold when better items are purchased
        const sellPairs: string[] = [
            // When getting better boots, sell basic boots
            "item_travel_boots_2",
            "item_boots",

            // When getting ultimate scepter 2, sell ultimate scepter
            "item_ultimate_scepter_2",
            "item_ultimate_scepter",

            // When getting better items, sell early game items
            "item_skadi",
            "item_wraith_band",

            "item_butterfly",
            "item_magic_wand",

            "item_abyssal_blade",
            "item_quelling_blade",

            "item_octarine_core",
            "item_bottle",

            "item_sheepstick",
            "item_urn_of_shadows",
        ];

        return sellPairs;
    }

    /**
     * Get 6-slot late game build (excluding non-slot items)
     */
    static GetLateGame6Slot(bot: any, position: Position): string[] {
        const heroName = bot.GetUnitName() as HeroName;
        const isHeroRanged = isRanged(heroName);
        const rangeType: RangeType = isHeroRanged ? "ranged" : "melee";

        const build: string[] = [];

        if (ITEMS_BY_POSITION[position] && ITEMS_BY_POSITION[position][rangeType]) {
            for (const item of ITEMS_BY_POSITION[position][rangeType]) {
                // Only add items that take inventory slots
                if (!NON_SLOT_ITEMS.includes(item)) {
                    build.push(item);
                }
            }
        }

        // Ensure we have exactly 6 items
        while (build.length > 6) {
            build.pop();
        }

        while (build.length < 6) {
            build.push("item_moon_shard"); // Fill with moon shard if needed
        }

        return build;
    }

    /**
     * Get non-slot items for late game
     */
    static GetNonSlotItems(bot: any, position: Position): string[] {
        const heroName = bot.GetUnitName() as HeroName;
        const isHeroRanged = isRanged(heroName);
        const rangeType: RangeType = isHeroRanged ? "ranged" : "melee";

        const nonSlotItems: string[] = [];

        if (ITEMS_BY_POSITION[position] && ITEMS_BY_POSITION[position][rangeType]) {
            for (const item of ITEMS_BY_POSITION[position][rangeType]) {
                if (NON_SLOT_ITEMS.includes(item)) {
                    nonSlotItems.push(item);
                }
            }
        }

        return nonSlotItems;
    }

    /**
     * Get counter items for specific enemy threats
     */
    static GetCounterItems(enemies: HeroName[]): string[] {
        const counterItems: string[] = [];

        if (hasEnemyThreat(enemies, "evasion")) {
            counterItems.push(...COUNTER_ITEMS.evasion);
        }

        if (hasEnemyThreat(enemies, "magic_heavy")) {
            counterItems.push(...COUNTER_ITEMS.magic_heavy);
        }

        if (hasEnemyThreat(enemies, "illusion_heavy")) {
            counterItems.push(...COUNTER_ITEMS.illusion_heavy);
        }

        if (hasEnemyThreat(enemies, "invisibility")) {
            counterItems.push(...COUNTER_ITEMS.invisibility);
        }

        // Add specific hero counters
        for (const enemy of enemies) {
            if (COUNTER_ITEMS.heroes[enemy as keyof typeof COUNTER_ITEMS.heroes]) {
                counterItems.push(...COUNTER_ITEMS.heroes[enemy as keyof typeof COUNTER_ITEMS.heroes]);
            }
        }

        return counterItems;
    }

    /**
     * Get position-specific items (simplified - position determines role)
     */
    static GetPositionSpecificItems(bot: any, position: Position): string[] {
        return this.GetItemBuild(bot, position);
    }

    /**
     * Get range-specific items (melee vs ranged)
     */
    static GetRangeSpecificItems(bot: any, position: Position): string[] {
        // Range-specific items are already included in the position-based builds
        return this.GetItemBuild(bot, position);
    }
}

export default AdvancedItemStrategy;
