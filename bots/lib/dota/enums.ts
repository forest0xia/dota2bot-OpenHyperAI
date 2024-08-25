declare const BOT_ACTION_DESIRE_ABSOLUTE: number
declare const BOT_ACTION_DESIRE_HIGH: number
declare const BOT_ACTION_DESIRE_LOW: number
declare const BOT_ACTION_DESIRE_MODERATE: number
declare const BOT_ACTION_DESIRE_NONE: number
declare const BOT_ACTION_DESIRE_VERYHIGH: number
declare const BOT_ACTION_DESIRE_VERYLOW: number

declare const BOT_MODE_DESIRE_ABSOLUTE: number
declare const BOT_MODE_DESIRE_HIGH: number
declare const BOT_MODE_DESIRE_LOW: number
declare const BOT_MODE_DESIRE_MODERATE: number
declare const BOT_MODE_DESIRE_NONE: number
declare const BOT_MODE_DESIRE_VERYHIGH: number
declare const BOT_MODE_DESIRE_VERYLOW: number

declare const BOT_MODE_NONE: number
declare const BOT_MODE_LANING: number
declare const BOT_MODE_ATTACK: number
declare const BOT_MODE_ROAM: number
declare const BOT_MODE_RETREAT: number
declare const BOT_MODE_SECRET_SHOP: number
declare const BOT_MODE_SIDE_SHOP: number
declare const BOT_MODE_PUSH_TOWER_TOP: number
declare const BOT_MODE_PUSH_TOWER_MID: number
declare const BOT_MODE_PUSH_TOWER_BOT: number
declare const BOT_MODE_DEFEND_TOWER_TOP: number
declare const BOT_MODE_DEFEND_TOWER_MID: number
declare const BOT_MODE_DEFEND_TOWER_BOT: number
declare const BOT_MODE_ASSEMBLE: number
declare const BOT_MODE_TEAM_ROAM: number
declare const BOT_MODE_FARM: number
declare const BOT_MODE_DEFEND_ALLY: number
declare const BOT_MODE_EVASIVE_MANEUVERS: number
declare const BOT_MODE_ROSHAN: number
declare const BOT_MODE_ITEM: number
declare const BOT_MODE_WARD: number

export enum BotActionDesire {
    None = BOT_ACTION_DESIRE_NONE,
    VeryLow = BOT_ACTION_DESIRE_VERYLOW,
    Low = BOT_ACTION_DESIRE_LOW,
    Moderate = BOT_ACTION_DESIRE_MODERATE,
    High = BOT_ACTION_DESIRE_HIGH,
    VeryHigh = BOT_ACTION_DESIRE_VERYHIGH,
    Absolute = BOT_ACTION_DESIRE_ABSOLUTE,
}

export enum BotModeDesire {
    None = BOT_MODE_DESIRE_NONE,
    VeryLow = BOT_MODE_DESIRE_VERYLOW,
    Low = BOT_MODE_DESIRE_LOW,
    Moderate = BOT_MODE_DESIRE_MODERATE,
    High = BOT_MODE_DESIRE_HIGH,
    VeryHigh = BOT_MODE_DESIRE_VERYHIGH,
    Absolute = BOT_MODE_DESIRE_ABSOLUTE,
}

export enum BotMode {
    None = BOT_MODE_NONE,
    Laning = BOT_MODE_LANING,
    Attack = BOT_MODE_ATTACK,
    Roam = BOT_MODE_ROAM,
    Retreat = BOT_MODE_RETREAT,
    SecretShop = BOT_MODE_SECRET_SHOP,
    SideShop = BOT_MODE_SIDE_SHOP,
    PushTowerTop = BOT_MODE_PUSH_TOWER_TOP,
    PushTowerMid = BOT_MODE_PUSH_TOWER_MID,
    PushTowerBot = BOT_MODE_PUSH_TOWER_BOT,
    DefendTowerTop = BOT_MODE_DEFEND_TOWER_TOP,
    DefendTowerMid = BOT_MODE_DEFEND_TOWER_MID,
    DefendTowerBot = BOT_MODE_DEFEND_TOWER_BOT,
    Assemble = BOT_MODE_ASSEMBLE,
    TeamRoam = BOT_MODE_TEAM_ROAM,
    Farm = BOT_MODE_FARM,
    DefendAlly = BOT_MODE_DEFEND_ALLY,
    EvasiveManeuvers = BOT_MODE_EVASIVE_MANEUVERS,
    Roshan = BOT_MODE_ROSHAN,
    Item = BOT_MODE_ITEM,
    Ward = BOT_MODE_WARD,
}