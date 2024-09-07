declare const BOT_ACTION_DESIRE_ABSOLUTE: number;
declare const BOT_ACTION_DESIRE_HIGH: number;
declare const BOT_ACTION_DESIRE_LOW: number;
declare const BOT_ACTION_DESIRE_MODERATE: number;
declare const BOT_ACTION_DESIRE_NONE: number;
declare const BOT_ACTION_DESIRE_VERYHIGH: number;
declare const BOT_ACTION_DESIRE_VERYLOW: number;

declare const BOT_MODE_DESIRE_ABSOLUTE: number;
declare const BOT_MODE_DESIRE_HIGH: number;
declare const BOT_MODE_DESIRE_LOW: number;
declare const BOT_MODE_DESIRE_MODERATE: number;
declare const BOT_MODE_DESIRE_NONE: number;
declare const BOT_MODE_DESIRE_VERYHIGH: number;
declare const BOT_MODE_DESIRE_VERYLOW: number;

declare const BOT_MODE_NONE: number;
declare const BOT_MODE_LANING: number;
declare const BOT_MODE_ATTACK: number;
declare const BOT_MODE_ROAM: number;
declare const BOT_MODE_RETREAT: number;
declare const BOT_MODE_SECRET_SHOP: number;
declare const BOT_MODE_SIDE_SHOP: number;
declare const BOT_MODE_PUSH_TOWER_TOP: number;
declare const BOT_MODE_PUSH_TOWER_MID: number;
declare const BOT_MODE_PUSH_TOWER_BOT: number;
declare const BOT_MODE_DEFEND_TOWER_TOP: number;
declare const BOT_MODE_DEFEND_TOWER_MID: number;
declare const BOT_MODE_DEFEND_TOWER_BOT: number;
declare const BOT_MODE_ASSEMBLE: number;
declare const BOT_MODE_TEAM_ROAM: number;
declare const BOT_MODE_FARM: number;
declare const BOT_MODE_DEFEND_ALLY: number;
declare const BOT_MODE_EVASIVE_MANEUVERS: number;
declare const BOT_MODE_ROSHAN: number;
declare const BOT_MODE_ITEM: number;
declare const BOT_MODE_WARD: number;

declare const TEAM_RADIANT: number;
declare const TEAM_DIRE: number;
declare const TEAM_NEUTRAL: number;
declare const TEAM_NONE: number;

declare const LANE_NONE: number;
declare const LANE_TOP: number;
declare const LANE_MID: number;
declare const LANE_BOT: number;

declare const UNIT_LIST_ALL: number;
declare const UNIT_LIST_ALLIES: number;
declare const UNIT_LIST_ALLIED_HEROES: number;
declare const UNIT_LIST_ALLIED_CREEPS: number;
declare const UNIT_LIST_ALLIED_WARDS: number;
declare const UNIT_LIST_ALLIED_BUILDINGS: number;
declare const UNIT_LIST_ENEMIES: number;
declare const UNIT_LIST_ENEMY_HEROES: number;
declare const UNIT_LIST_ENEMY_CREEPS: number;
declare const UNIT_LIST_ENEMY_WARDS: number;
declare const UNIT_LIST_NEUTRAL_CREEPS: number;
declare const UNIT_LIST_ENEMY_BUILDINGS: number;

const DESIRE_NONE = 0.0;
const DESIRE_VERY_LOW = 0.1;
const DESIRE_LOW = 0.25;
const DESIRE_MODERATE = 0.5;
const DESIRE_HIGH = 0.75;
const DESIRE_VERY_HIGH = 0.9;
const DESIRE_ABSOLUTE = 1.0;

export enum BotActionDesire {
    None = BOT_ACTION_DESIRE_NONE || DESIRE_NONE,
    VeryLow = BOT_ACTION_DESIRE_VERYLOW || DESIRE_VERY_LOW,
    Low = BOT_ACTION_DESIRE_LOW || DESIRE_LOW,
    Moderate = BOT_ACTION_DESIRE_MODERATE || DESIRE_MODERATE,
    High = BOT_ACTION_DESIRE_HIGH || DESIRE_HIGH,
    VeryHigh = BOT_ACTION_DESIRE_VERYHIGH || DESIRE_VERY_HIGH,
    Absolute = BOT_ACTION_DESIRE_ABSOLUTE || DESIRE_ABSOLUTE,
}

export enum BotModeDesire {
    None = BOT_MODE_DESIRE_NONE || DESIRE_NONE,
    VeryLow = BOT_MODE_DESIRE_VERYLOW || DESIRE_VERY_LOW,
    Low = BOT_MODE_DESIRE_LOW || DESIRE_LOW,
    Moderate = BOT_MODE_DESIRE_MODERATE || DESIRE_MODERATE,
    High = BOT_MODE_DESIRE_HIGH || DESIRE_HIGH,
    VeryHigh = BOT_MODE_DESIRE_VERYHIGH || DESIRE_VERY_HIGH,
    Absolute = BOT_MODE_DESIRE_ABSOLUTE || DESIRE_ABSOLUTE,
}

export enum BotMode {
    None = BOT_MODE_NONE || 0,
    Laning = BOT_MODE_LANING || 1,
    Attack = BOT_MODE_ATTACK || 2,
    Roam = BOT_MODE_ROAM || 3,
    Retreat = BOT_MODE_RETREAT || 4,
    SecretShop = BOT_MODE_SECRET_SHOP || 5,
    SideShop = BOT_MODE_SIDE_SHOP || 6,
    PushTowerTop = BOT_MODE_PUSH_TOWER_TOP || 9,
    PushTowerMid = BOT_MODE_PUSH_TOWER_MID || 9,
    PushTowerBot = BOT_MODE_PUSH_TOWER_BOT || 10,
    DefendTowerTop = BOT_MODE_DEFEND_TOWER_TOP || 11,
    DefendTowerMid = BOT_MODE_DEFEND_TOWER_MID || 12,
    DefendTowerBot = BOT_MODE_DEFEND_TOWER_BOT || 13,
    Assemble = BOT_MODE_ASSEMBLE || 14,
    TeamRoam = BOT_MODE_TEAM_ROAM || 16,
    Farm = BOT_MODE_FARM || 17,
    DefendAlly = BOT_MODE_DEFEND_ALLY || 18,
    EvasiveManeuvers = BOT_MODE_EVASIVE_MANEUVERS || 19,
    Roshan = BOT_MODE_ROSHAN || 20,
    Item = BOT_MODE_ITEM || 21,
    Ward = BOT_MODE_WARD || 22,
}

export enum Team {
    Radiant = TEAM_RADIANT || 2,
    Dire = TEAM_DIRE || 3,
    Neutral = TEAM_NEUTRAL || 4,
    None = TEAM_NONE || 5,
}

export enum Lane {
    None = LANE_NONE || 0,
    Top = LANE_TOP || 1,
    Mid = LANE_MID || 2,
    Bot = LANE_BOT || 3,
}

export enum UnitType {
    All = UNIT_LIST_ALL || 0,
    Allies = UNIT_LIST_ALLIES || 1,
    AlliedHeroes = UNIT_LIST_ALLIED_HEROES || 2,
    AlliedCreeps = UNIT_LIST_ALLIED_CREEPS || 3,
    AlliedWards = UNIT_LIST_ALLIED_WARDS || 4,
    AlliedBuildings = UNIT_LIST_ALLIED_BUILDINGS || 5,
    Enemies = UNIT_LIST_ENEMIES || 7,
    EnemyHeroes = UNIT_LIST_ENEMY_HEROES || 8,
    EnemyCreeps = UNIT_LIST_ENEMY_CREEPS || 9,
    EnemyWards = UNIT_LIST_ENEMY_WARDS || 10,
    EnemyBuildings = UNIT_LIST_ENEMY_BUILDINGS || 11,
    NeutralCreeps = UNIT_LIST_NEUTRAL_CREEPS || 13,
}

export enum BotActionType {
    None = 0, // TODO: Add Actions
}
