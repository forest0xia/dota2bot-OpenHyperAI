import { UnitType, Unit, AttributeType } from "bots/ts_libs/dota";
import { IsValidHero } from "bots/FunLib/utils";

const enemyHeroData: { [playerId: number]: EnemyHeroData } = {};

let cachedPositions: EnemyHeroPosition = {};
let updateEnemyHeroRolesTime = 0;
let updateEnemyRolesTimeGap = 3;

const ItemOffensiveness: { [itemName: string]: number } = {
    item_desolator: 60,
    item_desolator_2: 80,
    item_daedalus: 88,
    item_greater_crit: 88,
    item_bfury: 55,
    item_monkey_king_bar: 66,
    item_satanic: 25,
    item_butterfly: 30,
    item_abyssal_blade: 25,
    item_nullifier: 80,
    item_radiance: 60,
    item_bloodthorn: 70,
    item_silver_edge: 52,
    item_ethereal_blade: 40,
    item_rapier: 150,
    item_revenants_brooch: 45,
    item_overwhelming_blink: 25,
    item_swift_blink: 25,
    item_arcane_blink: 25,
    item_ultimate_scepter: 20,
    item_ultimate_scepter_2: 20,
    item_aeon_disk: 10,
    item_kaya: 16,
    item_kaya_and_sange: 24,
    item_yasha_and_kaya: 24,
    item_moon_shard: 60,
    item_dragon_lance: 14,
    item_hurricane_pike: 20,
    item_orchid: 25,
    item_dagon_5: 50,
    item_fallen_sky: 25,
    item_pirate_hat: 80,
    item_stormcrafter: 20,
    // Add more items
};

interface EnemyHeroData {
    hero: Unit;
    netWorth: number;
    offensivePower: number;
    level: number;
    totalScore: number;
}

export interface EnemyHeroPosition {
    [playerId: number]: number;
}

// Weights for each metric
const NET_WORTH_WEIGHT = 0.3;
const OFFENSIVE_POWER_WEIGHT = 0.3;
const LEVEL_WEIGHT = 0.4;

function UpdateEnemyHeroData(enemyHeroes: Unit[]): void {
    for (const hero of enemyHeroes) {
        if (IsValidHero(hero)) {
            const heroNetWorth = GetHeroNetWorth(hero);
            const heroOffensivePower = GetHeroOffensivePower(hero);
            const heroLevel = hero.GetLevel();
            const playerId = hero.GetPlayerID();

            // Calculate total weighted score
            const totalScore =
                heroNetWorth * NET_WORTH_WEIGHT +
                heroOffensivePower * OFFENSIVE_POWER_WEIGHT +
                heroLevel * LEVEL_WEIGHT;

            enemyHeroData[playerId] = {
                hero: hero,
                netWorth: heroNetWorth,
                offensivePower: heroOffensivePower,
                level: heroLevel,
                totalScore: totalScore,
            };
        }
    }
}

// Function to get enemy hero net worth
function GetHeroNetWorth(hero: Unit): number {
    let totalNetWorth = 0;
    // Sum the cost of all items in inventory, backpack, and stash
    for (let i = 0; i <= 15; i++) {
        // Slots 0 to 15
        const item = hero.GetItemInSlot(i);
        if (item !== null) {
            totalNetWorth += GetItemCost(item.GetName());
        }
    }
    // Include the hero's current gold. Not work for non-teammates.
    // totalNetWorth += hero.GetGold();
    return totalNetWorth;
}

// Estimate hero offensive power
function GetHeroOffensivePower(hero: Unit): number {
    let offensivePower = 0;
    // Base attack damage
    offensivePower += hero.GetAttackDamage();
    // Primary attribute contributes more to offensive power
    const primaryAttribute = hero.GetPrimaryAttribute();
    if (primaryAttribute === AttributeType.Strength) {
        offensivePower += hero.GetAttributeValue(AttributeType.Strength) * 2;
    } else if (primaryAttribute === AttributeType.Agility) {
        offensivePower += hero.GetAttributeValue(AttributeType.Agility) * 2;
    } else if (primaryAttribute === AttributeType.Intellect) {
        offensivePower += hero.GetAttributeValue(AttributeType.Intellect) * 2;
    } else if (primaryAttribute === AttributeType.All) {
        offensivePower +=
            hero.GetAttributeValue(AttributeType.Strength) * 0.7 +
            hero.GetAttributeValue(AttributeType.Agility) * 0.7 +
            hero.GetAttributeValue(AttributeType.Intellect) * 0.7;
    }
    // Include offensive items based on ItemOffensiveness table
    for (let i = 0; i <= 8; i++) {
        // Main inventory and backpack slots
        const item = hero.GetItemInSlot(i);
        if (item !== null) {
            const itemName = item.GetName();
            const offensiveValue = ItemOffensiveness[itemName];
            if (offensiveValue !== undefined) {
                offensivePower += offensiveValue;
            }
        }
    }
    return offensivePower;
}

function AssignPositions(): EnemyHeroPosition {
    const heroList: EnemyHeroData[] = [];
    for (const data of Object.values(enemyHeroData)) {
        heroList.push(data);
    }

    NormalizeSores(heroList);

    // Sort the list by totalScore in descending order
    heroList.sort((a, b) => b.totalScore - a.totalScore);

    // Assign positions
    const positions: EnemyHeroPosition = {};
    for (let index = 0; index < heroList.length; index++) {
        const data = heroList[index];
        let pos = index + 1; // Positions 1 to 5
        if (pos > 5) pos = 5; // Ensure position does not exceed 5
        if (IsValidHero(data.hero)) {
            positions[data.hero.GetPlayerID()] = pos;
        }
    }
    cachedPositions = positions;
    return cachedPositions;
}

function NormalizeSores(heroList: EnemyHeroData[]) {
    // Collect maximum values for normalization
    const netWorths = heroList.map(h => h.netWorth);
    const offensivePowers = heroList.map(h => h.offensivePower);
    const levels = heroList.map(h => h.level);

    const maxNetWorth = Math.max(...netWorths, 1); // Avoid division by zero
    const maxOffensivePower = Math.max(...offensivePowers, 1);
    const maxLevel = Math.max(...levels, 1);

    // Normalize metrics and calculate total score
    for (const data of heroList) {
        const normalizedNetWorth = data.netWorth / maxNetWorth;
        const normalizedOffensivePower =
            data.offensivePower / maxOffensivePower;
        const normalizedLevel = data.level / maxLevel;

        data.totalScore =
            normalizedNetWorth * NET_WORTH_WEIGHT +
            normalizedOffensivePower * OFFENSIVE_POWER_WEIGHT +
            normalizedLevel * LEVEL_WEIGHT;
    }
}

export function UpdateEnemyHeroPositions() {
    if (DotaTime() - updateEnemyHeroRolesTime > updateEnemyRolesTimeGap) {
        updateEnemyHeroRolesTime = DotaTime();
        const enemyHeroes = GetUnitList(UnitType.EnemyHeroes);
        UpdateEnemyHeroData(enemyHeroes);
        AssignPositions();
    }
}

export function GetEnemyPosition(playerId: number) {
    return cachedPositions[playerId];
}
