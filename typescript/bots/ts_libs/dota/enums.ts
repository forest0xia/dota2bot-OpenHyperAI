/**
 * The enums from Dota2 bot scriping, and the enums we defined in this script on top of bot scriping.
 *
 * Official enums list, see: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting,
 * note this may not be up to date to the enums available in game since Vavle has not updated website for many years.
 */

// Collect and use the original enums from dota2 scripting in order to avoid accidentially changing or re-defining
// the value of the enum that potentially can cause discrepancy between code in this script vs dota2 game engine.
/** @compileMembersOnly */
declare enum BotScriptEnums {
    // Bot Modes
    BOT_MODE_NONE,
    BOT_MODE_LANING,
    BOT_MODE_ATTACK,
    BOT_MODE_ROAM,
    BOT_MODE_RUNE,
    BOT_MODE_RETREAT,
    BOT_MODE_SECRET_SHOP,
    BOT_MODE_SIDE_SHOP,
    BOT_MODE_PUSH_TOWER_TOP,
    BOT_MODE_PUSH_TOWER_MID,
    BOT_MODE_PUSH_TOWER_BOT,
    BOT_MODE_DEFEND_TOWER_TOP,
    BOT_MODE_DEFEND_TOWER_MID,
    BOT_MODE_DEFEND_TOWER_BOT,
    BOT_MODE_ASSEMBLE,
    BOT_MODE_TEAM_ROAM,
    BOT_MODE_FARM,
    BOT_MODE_DEFEND_ALLY,
    BOT_MODE_EVASIVE_MANEUVERS,
    BOT_MODE_ROSHAN,
    BOT_MODE_ITEM,
    BOT_MODE_WARD,
    // Action Desires
    // These can be useful for making sure all action desires are using a common language for talking about their desire.
    BOT_ACTION_DESIRE_NONE,
    BOT_ACTION_DESIRE_VERYLOW,
    BOT_ACTION_DESIRE_LOW,
    BOT_ACTION_DESIRE_MODERATE,
    BOT_ACTION_DESIRE_HIGH,
    BOT_ACTION_DESIRE_VERYHIGH,
    BOT_ACTION_DESIRE_ABSOLUTE,
    // Mode Desires
    // These can be useful for making sure all mode desires as using a common language for talking about their desire.
    BOT_MODE_DESIRE_NONE,
    BOT_MODE_DESIRE_VERYLOW,
    BOT_MODE_DESIRE_LOW,
    BOT_MODE_DESIRE_MODERATE,
    BOT_MODE_DESIRE_HIGH,
    BOT_MODE_DESIRE_VERYHIGH,
    BOT_MODE_DESIRE_ABSOLUTE,
    // Damage Types
    DAMAGE_TYPE_PHYSICAL,
    DAMAGE_TYPE_MAGICAL,
    DAMAGE_TYPE_PURE,
    DAMAGE_TYPE_ALL,
    //Unit Types
    UNIT_LIST_ALL,
    UNIT_LIST_ALLIES,
    UNIT_LIST_ALLIED_HEROES,
    UNIT_LIST_ALLIED_CREEPS,
    UNIT_LIST_ALLIED_WARDS,
    UNIT_LIST_ALLIED_BUILDINGS,
    UNIT_LIST_ENEMIES,
    UNIT_LIST_ENEMY_HEROES,
    UNIT_LIST_ENEMY_CREEPS,
    UNIT_LIST_ENEMY_WARDS,
    UNIT_LIST_NEUTRAL_CREEPS,
    UNIT_LIST_ENEMY_BUILDINGS,
    // Difficulties,
    DIFFICULTY_INVALID,
    DIFFICULTY_PASSIVE,
    DIFFICULTY_EASY,
    DIFFICULTY_MEDIUM,
    DIFFICULTY_HARD,
    DIFFICULTY_UNFAIR,
    // Attribute Types,
    ATTRIBUTE_INVALID,
    ATTRIBUTE_STRENGTH,
    ATTRIBUTE_AGILITY,
    ATTRIBUTE_INTELLECT,
    ATTRIBUTE_ALL,
    ATTRIBUTE_MAX,
    // Item Purchase Results,
    PURCHASE_ITEM_SUCCESS,
    PURCHASE_ITEM_OUT_OF_STOCK,
    PURCHASE_ITEM_DISALLOWED_ITEM,
    PURCHASE_ITEM_INSUFFICIENT_GOLD,
    PURCHASE_ITEM_NOT_AT_HOME_SHOP,
    PURCHASE_ITEM_NOT_AT_SIDE_SHOP,
    PURCHASE_ITEM_NOT_AT_SECRET_SHOP,
    PURCHASE_ITEM_INVALID_ITEM_NAME,
    // Game Modes,
    GAMEMODE_NONE,
    GAMEMODE_AP,
    GAMEMODE_CM,
    GAMEMODE_RD,
    GAMEMODE_SD,
    GAMEMODE_AR,
    GAMEMODE_REVERSE_CM,
    GAMEMODE_MO,
    GAMEMODE_CD,
    GAMEMODE_ABILITY_DRAFT,
    GAMEMODE_ARDM,
    GAMEMODE_1V1MID,
    GAMEMODE_ALL_DRAFT, //(aka Ranked All Pick),
    GAMEMODE_TURBO,
    GAMEMODE_MUTATION,
    GAMEMODE_COACHES_CHALLENGE,
    GAMEMODE_INTRO,
    GAMEMODE_HW,
    GAMEMODE_XMAS,
    GAMEMODE_TUTORIAL,
    GAMEMODE_LP,
    GAMEMODE_POOL1,
    GAMEMODE_FH,
    GAMEMODE_CUSTOM,
    GAMEMODE_EVENT,
    GAMEMODE_BD,

    // Teams,
    TEAM_RADIANT,
    TEAM_DIRE,
    TEAM_NEUTRAL,
    TEAM_NONE,
    // Lanes,
    LANE_NONE,
    LANE_TOP,
    LANE_MID,
    LANE_BOT,
    // Game States,
    GAME_STATE_INIT,
    GAME_STATE_WAIT_FOR_PLAYERS_TO_LOAD,
    GAME_STATE_HERO_SELECTION,
    GAME_STATE_STRATEGY_TIME,
    GAME_STATE_PRE_GAME,
    GAME_STATE_GAME_IN_PROGRESS,
    GAME_STATE_POST_GAME,
    GAME_STATE_DISCONNECT,
    GAME_STATE_TEAM_SHOWCASE,
    GAME_STATE_CUSTOM_GAME_SETUP,
    GAME_STATE_WAIT_FOR_MAP_TO_LOAD,
    GAME_STATE_LAST,
    // Hero Pick States,
    HEROPICK_STATE_NONE,
    HEROPICK_STATE_AP_SELECT,
    HEROPICK_STATE_SD_SELECT,
    HEROPICK_STATE_CM_INTRO,
    HEROPICK_STATE_CM_CAPTAINPICK,
    HEROPICK_STATE_CM_BAN1,
    HEROPICK_STATE_CM_BAN2,
    HEROPICK_STATE_CM_BAN3,
    HEROPICK_STATE_CM_BAN4,
    HEROPICK_STATE_CM_BAN5,
    HEROPICK_STATE_CM_BAN6,
    HEROPICK_STATE_CM_BAN7,
    HEROPICK_STATE_CM_BAN8,
    HEROPICK_STATE_CM_BAN9,
    HEROPICK_STATE_CM_BAN10,
    HEROPICK_STATE_CM_SELECT1,
    HEROPICK_STATE_CM_SELECT2,
    HEROPICK_STATE_CM_SELECT3,
    HEROPICK_STATE_CM_SELECT4,
    HEROPICK_STATE_CM_SELECT5,
    HEROPICK_STATE_CM_SELECT6,
    HEROPICK_STATE_CM_SELECT7,
    HEROPICK_STATE_CM_SELECT8,
    HEROPICK_STATE_CM_SELECT9,
    HEROPICK_STATE_CM_SELECT10,
    HEROPICK_STATE_CM_PICK,
    HEROPICK_STATE_AR_SELECT,
    HEROPICK_STATE_MO_SELECT,
    HEROPICK_STATE_FH_SELECT,
    HEROPICK_STATE_CD_INTRO,
    HEROPICK_STATE_CD_CAPTAINPICK,
    HEROPICK_STATE_CD_BAN1,
    HEROPICK_STATE_CD_BAN2,
    HEROPICK_STATE_CD_BAN3,
    HEROPICK_STATE_CD_BAN4,
    HEROPICK_STATE_CD_BAN5,
    HEROPICK_STATE_CD_BAN6,
    HEROPICK_STATE_CD_SELECT1,
    HEROPICK_STATE_CD_SELECT2,
    HEROPICK_STATE_CD_SELECT3,
    HEROPICK_STATE_CD_SELECT4,
    HEROPICK_STATE_CD_SELECT5,
    HEROPICK_STATE_CD_SELECT6,
    HEROPICK_STATE_CD_SELECT7,
    HEROPICK_STATE_CD_SELECT8,
    HEROPICK_STATE_CD_SELECT9,
    HEROPICK_STATE_CD_SELECT10,
    HEROPICK_STATE_CD_PICK,
    HEROPICK_STATE_BD_SELECT,
    HERO_PICK_STATE_ABILITY_DRAFT_SELECT,
    HERO_PICK_STATE_ARDM_SELECT,
    HEROPICK_STATE_ALL_DRAFT_SELECT,
    HERO_PICK_STATE_CUSTOMGAME_SELECT,
    HEROPICK_STATE_SELECT_PENALTY,
    // Rune Types,
    RUNE_INVALID, //(used as return value),
    RUNE_DOUBLEDAMAGE,
    RUNE_HASTE,
    RUNE_ILLUSION,
    RUNE_INVISIBILITY,
    RUNE_REGENERATION,
    RUNE_BOUNTY,
    RUNE_ARCANE,
    // Rune Status,
    RUNE_STATUS_UNKNOWN,
    RUNE_STATUS_AVAILABLE,
    RUNE_STATUS_MISSING,
    // Rune Locations,
    RUNE_POWERUP_1,
    RUNE_POWERUP_2,
    RUNE_BOUNTY_1,
    RUNE_BOUNTY_2,
    RUNE_BOUNTY_3,
    RUNE_BOUNTY_4,
    // Item Slot Types,
    ITEM_SLOT_TYPE_INVALID,
    ITEM_SLOT_TYPE_MAIN,
    ITEM_SLOT_TYPE_BACKPACK,
    ITEM_SLOT_TYPE_STASH,
    // Action Types,
    BOT_ACTION_TYPE_NONE,
    BOT_ACTION_TYPE_IDLE,
    BOT_ACTION_TYPE_MOVE_TO,
    BOT_ACTION_TYPE_MOVE_TO_DIRECTLY,
    BOT_ACTION_TYPE_ATTACK,
    BOT_ACTION_TYPE_ATTACKMOVE,
    BOT_ACTION_TYPE_USE_ABILITY,
    BOT_ACTION_TYPE_PICK_UP_RUNE,
    BOT_ACTION_TYPE_PICK_UP_ITEM,
    BOT_ACTION_TYPE_DROP_ITEM,
    BOT_ACTION_TYPE_SHRINE,
    BOT_ACTION_TYPE_DELAY,
    // Courier Actions and States,
    COURIER_ACTION_BURST,
    COURIER_ACTION_ENEMY_SECRET_SHOP,
    COURIER_ACTION_RETURN,
    COURIER_ACTION_SECRET_SHOP,
    COURIER_ACTION_SIDE_SHOP,
    COURIER_ACTION_SIDE_SHOP2,
    COURIER_ACTION_TAKE_STASH_ITEMS,
    COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS,
    COURIER_ACTION_TRANSFER_ITEMS,
    COURIER_STATE_IDLE,
    COURIER_STATE_AT_BASE,
    COURIER_STATE_MOVING,
    COURIER_STATE_DELIVERING_ITEMS,
    COURIER_STATE_RETURNING_TO_BASE,
    COURIER_STATE_DEAD,
    // Towers,
    TOWER_TOP_1,
    TOWER_TOP_2,
    TOWER_TOP_3,
    TOWER_MID_1,
    TOWER_MID_2,
    TOWER_MID_3,
    TOWER_BOT_1,
    TOWER_BOT_2,
    TOWER_BOT_3,
    TOWER_BASE_1,
    TOWER_BASE_2,
    // Barracks,
    BARRACKS_TOP_MELEE,
    BARRACKS_TOP_RANGED,
    BARRACKS_MID_MELEE,
    BARRACKS_MID_RANGED,
    BARRACKS_BOT_MELEE,
    BARRACKS_BOT_RANGED,
    // Shrines,
    SHRINE_BASE_1,
    SHRINE_BASE_2,
    SHRINE_BASE_3,
    SHRINE_BASE_4,
    SHRINE_BASE_5,
    SHRINE_JUNGLE_1,
    SHRINE_JUNGLE_2,
    // Shops,
    SHOP_HOME,
    SHOP_SIDE,
    SHOP_SECRET,
    SHOP_SIDE2,
    SHOP_SECRET2,
    // Ability Target Teams,
    ABILITY_TARGET_TEAM_NONE,
    ABILITY_TARGET_TEAM_FRIENDLY,
    ABILITY_TARGET_TEAM_ENEMY,
    // Ability Target Types,
    ABILITY_TARGET_TYPE_NONE,
    ABILITY_TARGET_TYPE_HERO,
    ABILITY_TARGET_TYPE_CREEP,
    ABILITY_TARGET_TYPE_BUILDING,
    ABILITY_TARGET_TYPE_COURIER,
    ABILITY_TARGET_TYPE_OTHER,
    ABILITY_TARGET_TYPE_TREE,
    ABILITY_TARGET_TYPE_BASIC,
    ABILITY_TARGET_TYPE_ALL,
    // Ability Target Flags,
    ABILITY_TARGET_FLAG_NONE,
    ABILITY_TARGET_FLAG_RANGED_ONLY,
    ABILITY_TARGET_FLAG_MELEE_ONLY,
    ABILITY_TARGET_FLAG_DEAD,
    ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
    ABILITY_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,
    ABILITY_TARGET_FLAG_INVULNERABLE,
    ABILITY_TARGET_FLAG_FOW_VISIBLE,
    ABILITY_TARGET_FLAG_NO_INVIS,
    ABILITY_TARGET_FLAG_NOT_ANCIENTS,
    ABILITY_TARGET_FLAG_PLAYER_CONTROLLED,
    ABILITY_TARGET_FLAG_NOT_DOMINATED,
    ABILITY_TARGET_FLAG_NOT_SUMMONED,
    ABILITY_TARGET_FLAG_NOT_ILLUSIONS,
    ABILITY_TARGET_FLAG_NOT_ATTACK_IMMUNE,
    ABILITY_TARGET_FLAG_MANA_ONLY,
    ABILITY_TARGET_FLAG_CHECK_DISABLE_HELP,
    ABILITY_TARGET_FLAG_NOT_CREEP_HERO,
    ABILITY_TARGET_FLAG_OUT_OF_WORLD,
    ABILITY_TARGET_FLAG_NOT_NIGHTMARED,
    ABILITY_TARGET_FLAG_PREFER_ENEMIES,
    // Ability Behavior Bitfields,
    ABILITY_BEHAVIOR_NONE,
    ABILITY_BEHAVIOR_HIDDEN,
    ABILITY_BEHAVIOR_PASSIVE,
    ABILITY_BEHAVIOR_NO_TARGET,
    ABILITY_BEHAVIOR_UNIT_TARGET,
    ABILITY_BEHAVIOR_POINT,
    ABILITY_BEHAVIOR_AOE,
    ABILITY_BEHAVIOR_NOT_LEARNABLE,
    ABILITY_BEHAVIOR_CHANNELLED,
    ABILITY_BEHAVIOR_ITEM,
    ABILITY_BEHAVIOR_TOGGLE,
    ABILITY_BEHAVIOR_DIRECTIONAL,
    ABILITY_BEHAVIOR_IMMEDIATE,
    ABILITY_BEHAVIOR_AUTOCAST,
    ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET,
    ABILITY_BEHAVIOR_OPTIONAL_POINT,
    ABILITY_BEHAVIOR_OPTIONAL_NO_TARGET,
    ABILITY_BEHAVIOR_AURA,
    ABILITY_BEHAVIOR_ATTACK,
    ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT,
    ABILITY_BEHAVIOR_ROOT_DISABLES,
    ABILITY_BEHAVIOR_UNRESTRICTED,
    ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE,
    ABILITY_BEHAVIOR_IGNORE_CHANNEL,
    ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT,
    ABILITY_BEHAVIOR_DONT_ALERT_TARGET,
    ABILITY_BEHAVIOR_DONT_RESUME_ATTACK,
    ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN,
    ABILITY_BEHAVIOR_IGNORE_BACKSWING,
    ABILITY_BEHAVIOR_RUNE_TARGET,
    ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL,
    ABILITY_BEHAVIOR_VECTOR_TARGETING,
    ABILITY_BEHAVIOR_LAST_RESORT_POINT,
    // Misc Constants,
    GLYPH_COOLDOWN,
    // Animation Activities,
    ACTIVITY_IDLE,
    ACTIVITY_IDLE_RARE,
    ACTIVITY_RUN,
    ACTIVITY_ATTACK,
    ACTIVITY_ATTACK2,
    ACTIVITY_ATTACK_EVENT,
    ACTIVITY_DIE,
    ACTIVITY_FLINCH,
    ACTIVITY_FLAIL,
    ACTIVITY_DISABLED,
    ACTIVITY_CAST_ABILITY_1,
    ACTIVITY_CAST_ABILITY_2,
    ACTIVITY_CAST_ABILITY_3,
    ACTIVITY_CAST_ABILITY_4,
    ACTIVITY_CAST_ABILITY_5,
    ACTIVITY_CAST_ABILITY_6,
    ACTIVITY_OVERRIDE_ABILITY_1,
    ACTIVITY_OVERRIDE_ABILITY_2,
    ACTIVITY_OVERRIDE_ABILITY_3,
    ACTIVITY_OVERRIDE_ABILITY_4,
    ACTIVITY_CHANNEL_ABILITY_1,
    ACTIVITY_CHANNEL_ABILITY_2,
    ACTIVITY_CHANNEL_ABILITY_3,
    ACTIVITY_CHANNEL_ABILITY_4,
    ACTIVITY_CHANNEL_ABILITY_5,
    ACTIVITY_CHANNEL_ABILITY_6,
    ACTIVITY_CHANNEL_END_ABILITY_1,
    ACTIVITY_CHANNEL_END_ABILITY_2,
    ACTIVITY_CHANNEL_END_ABILITY_3,
    ACTIVITY_CHANNEL_END_ABILITY_4,
    ACTIVITY_CHANNEL_END_ABILITY_5,
    ACTIVITY_CHANNEL_END_ABILITY_6,
    ACTIVITY_CONSTANT_LAYER,
    ACTIVITY_CAPTURE,
    ACTIVITY_SPAWN,
    ACTIVITY_KILLTAUNT,
    ACTIVITY_TAUNT,

    HEROPICK_STATE_INTRO_SELECT_UNUSED,
    HEROPICK_STATE_RD_SELECT_UNUSED,
    HEROPICK_STATE_CM_BAN11,
    HEROPICK_STATE_CM_BAN12,
    HEROPICK_STATE_COUNT,
}

const DESIRE_NONE = 0.0;
const DESIRE_VERY_LOW = 0.1;
const DESIRE_LOW = 0.25;
const DESIRE_MODERATE = 0.5;
const DESIRE_HIGH = 0.75;
const DESIRE_VERY_HIGH = 0.9;
const DESIRE_ABSOLUTE = 1.0;

export enum BotActionDesire {
    None = BotScriptEnums.BOT_ACTION_DESIRE_NONE || DESIRE_NONE,
    VeryLow = BotScriptEnums.BOT_ACTION_DESIRE_VERYLOW || DESIRE_VERY_LOW,
    Low = BotScriptEnums.BOT_ACTION_DESIRE_LOW || DESIRE_LOW,
    Moderate = BotScriptEnums.BOT_ACTION_DESIRE_MODERATE || DESIRE_MODERATE,
    High = BotScriptEnums.BOT_ACTION_DESIRE_HIGH || DESIRE_HIGH,
    VeryHigh = BotScriptEnums.BOT_ACTION_DESIRE_VERYHIGH || DESIRE_VERY_HIGH,
    Absolute = BotScriptEnums.BOT_ACTION_DESIRE_ABSOLUTE || DESIRE_ABSOLUTE,
}

export enum BotModeDesire {
    None = BotScriptEnums.BOT_MODE_DESIRE_NONE || DESIRE_NONE,
    VeryLow = BotScriptEnums.BOT_MODE_DESIRE_VERYLOW || DESIRE_VERY_LOW,
    Low = BotScriptEnums.BOT_MODE_DESIRE_LOW || DESIRE_LOW,
    Moderate = BotScriptEnums.BOT_MODE_DESIRE_MODERATE || DESIRE_MODERATE,
    High = BotScriptEnums.BOT_MODE_DESIRE_HIGH || DESIRE_HIGH,
    VeryHigh = BotScriptEnums.BOT_MODE_DESIRE_VERYHIGH || DESIRE_VERY_HIGH,
    Absolute = BotScriptEnums.BOT_MODE_DESIRE_ABSOLUTE || DESIRE_ABSOLUTE,
}

export enum BotMode {
    None = BotScriptEnums.BOT_MODE_NONE || 0,
    Laning = BotScriptEnums.BOT_MODE_LANING || 1,
    Attack = BotScriptEnums.BOT_MODE_ATTACK || 2,
    Roam = BotScriptEnums.BOT_MODE_ROAM || 3,
    Retreat = BotScriptEnums.BOT_MODE_RETREAT || 4,
    SecretShop = BotScriptEnums.BOT_MODE_SECRET_SHOP || 5,
    SideShop = BotScriptEnums.BOT_MODE_SIDE_SHOP || 6,
    Rune = BotScriptEnums.BOT_MODE_RUNE || 7,
    PushTowerTop = BotScriptEnums.BOT_MODE_PUSH_TOWER_TOP || 8,
    PushTowerMid = BotScriptEnums.BOT_MODE_PUSH_TOWER_MID || 9,
    PushTowerBot = BotScriptEnums.BOT_MODE_PUSH_TOWER_BOT || 10,
    DefendTowerTop = BotScriptEnums.BOT_MODE_DEFEND_TOWER_TOP || 11,
    DefendTowerMid = BotScriptEnums.BOT_MODE_DEFEND_TOWER_MID || 12,
    DefendTowerBot = BotScriptEnums.BOT_MODE_DEFEND_TOWER_BOT || 13,
    Assemble = BotScriptEnums.BOT_MODE_ASSEMBLE || 14,
    TeamRoam = BotScriptEnums.BOT_MODE_TEAM_ROAM || 16,
    Farm = BotScriptEnums.BOT_MODE_FARM || 17,
    DefendAlly = BotScriptEnums.BOT_MODE_DEFEND_ALLY || 18,
    EvasiveManeuvers = BotScriptEnums.BOT_MODE_EVASIVE_MANEUVERS || 19,
    Roshan = BotScriptEnums.BOT_MODE_ROSHAN || 20,
    Item = BotScriptEnums.BOT_MODE_ITEM || 21,
    Ward = BotScriptEnums.BOT_MODE_WARD || 22,
}

export enum Team {
    Radiant = BotScriptEnums.TEAM_RADIANT || 2,
    Dire = BotScriptEnums.TEAM_DIRE || 3,
    Neutral = BotScriptEnums.TEAM_NEUTRAL || 4,
    None = BotScriptEnums.TEAM_NONE || 5,
}

export enum Lane {
    None = BotScriptEnums.LANE_NONE || 0,
    Top = BotScriptEnums.LANE_TOP || 1,
    Mid = BotScriptEnums.LANE_MID || 2,
    Bot = BotScriptEnums.LANE_BOT || 3,
}

export enum UnitType {
    All = BotScriptEnums.UNIT_LIST_ALL || 0,
    Allies = BotScriptEnums.UNIT_LIST_ALLIES || 1,
    AlliedHeroes = BotScriptEnums.UNIT_LIST_ALLIED_HEROES || 2,
    AlliedCreeps = BotScriptEnums.UNIT_LIST_ALLIED_CREEPS || 3,
    AlliedWards = BotScriptEnums.UNIT_LIST_ALLIED_WARDS || 4,
    AlliedBuildings = BotScriptEnums.UNIT_LIST_ALLIED_BUILDINGS || 5,
    Enemies = BotScriptEnums.UNIT_LIST_ENEMIES || 7,
    EnemyHeroes = BotScriptEnums.UNIT_LIST_ENEMY_HEROES || 8,
    EnemyCreeps = BotScriptEnums.UNIT_LIST_ENEMY_CREEPS || 9,
    EnemyWards = BotScriptEnums.UNIT_LIST_ENEMY_WARDS || 10,
    EnemyBuildings = BotScriptEnums.UNIT_LIST_ENEMY_BUILDINGS || 11,
    NeutralCreeps = BotScriptEnums.UNIT_LIST_NEUTRAL_CREEPS || 13,
}

export enum BotActionType {
    None = 0, // TODO: Add Actions
}

export enum Tower {
    Top1 = BotScriptEnums.TOWER_TOP_1 || 0,
    Top2 = BotScriptEnums.TOWER_TOP_2 || 1,
    Top3 = BotScriptEnums.TOWER_TOP_3 || 2,
    Mid1 = BotScriptEnums.TOWER_MID_1 || 3,
    Mid2 = BotScriptEnums.TOWER_MID_2 || 4,
    Mid3 = BotScriptEnums.TOWER_MID_3 || 5,
    Bot1 = BotScriptEnums.TOWER_BOT_1 || 6,
    Bot2 = BotScriptEnums.TOWER_BOT_2 || 7,
    Bot3 = BotScriptEnums.TOWER_BOT_3 || 8,
    Base1 = BotScriptEnums.TOWER_BASE_1 || 9,
    Base2 = BotScriptEnums.TOWER_BASE_2 || 10,
}

export enum Barracks {
    TopMelee = BotScriptEnums.BARRACKS_TOP_MELEE || 0,
    TopRanged = BotScriptEnums.BARRACKS_TOP_RANGED || 1,
    MidMelee = BotScriptEnums.BARRACKS_MID_MELEE || 2,
    MidRanged = BotScriptEnums.BARRACKS_MID_RANGED || 3,
    BotMelee = BotScriptEnums.BARRACKS_BOT_MELEE || 4,
    BotRanged = BotScriptEnums.BARRACKS_BOT_RANGED || 5,
}

export enum Rune {
    Power1 = BotScriptEnums.RUNE_POWERUP_1 || 0,
    Power2 = BotScriptEnums.RUNE_POWERUP_2 || 1,
    Bounty1 = BotScriptEnums.RUNE_BOUNTY_1 || 2,
    Bounty2 = BotScriptEnums.RUNE_BOUNTY_2 || 3,
    Bounty3 = BotScriptEnums.RUNE_BOUNTY_3 || 4,
    Bounty4 = BotScriptEnums.RUNE_BOUNTY_4 || 5,
}

export enum Shop {
    Home = BotScriptEnums.SHOP_HOME || 0,
    Side = BotScriptEnums.SHOP_SIDE || 1,
    Secret = BotScriptEnums.SHOP_SECRET || 2,
    Side2 = BotScriptEnums.SHOP_SIDE2 || 4,
    Secret2 = BotScriptEnums.SHOP_SECRET2 || 5,
}

export enum AttributeType {
    Strength = BotScriptEnums.ATTRIBUTE_STRENGTH || 0,
    Agility = BotScriptEnums.ATTRIBUTE_AGILITY || 1,
    Intellect = BotScriptEnums.ATTRIBUTE_INTELLECT || 2,
    All = BotScriptEnums.ATTRIBUTE_ALL || 3,
    Max = BotScriptEnums.ATTRIBUTE_MAX || 4,
    Invalid = BotScriptEnums.ATTRIBUTE_INVALID || -1,
}

export enum GameState {
    Init = BotScriptEnums.GAME_STATE_INIT || 0,
    WaitForPlayersToLoad = BotScriptEnums.GAME_STATE_WAIT_FOR_MAP_TO_LOAD || 1,
    CustomGameSetup = BotScriptEnums.GAME_STATE_CUSTOM_GAME_SETUP || 2,
    HeroSelection = BotScriptEnums.GAME_STATE_HERO_SELECTION || 3,
    StrategyTime = BotScriptEnums.GAME_STATE_STRATEGY_TIME || 4,
    TeamShowcase = BotScriptEnums.GAME_STATE_TEAM_SHOWCASE || 5,
    WaitForMapToLoad = BotScriptEnums.GAME_STATE_WAIT_FOR_MAP_TO_LOAD || 6,
    PreGame = BotScriptEnums.GAME_STATE_PRE_GAME || 7,
    GameInProgress = BotScriptEnums.GAME_STATE_GAME_IN_PROGRESS || 8,
    PostGame = BotScriptEnums.GAME_STATE_POST_GAME || 9,
    Disconnect = BotScriptEnums.GAME_STATE_DISCONNECT || 10,
}

export enum HeroPickState {
    None = BotScriptEnums.HEROPICK_STATE_NONE || 0,
    ApSelect = BotScriptEnums.HEROPICK_STATE_AP_SELECT || 1,
    SdSelect = BotScriptEnums.HEROPICK_STATE_SD_SELECT || 2,
    IntroSelectUnused = BotScriptEnums.HEROPICK_STATE_INTRO_SELECT_UNUSED || 3,
    RdSelectUnused = BotScriptEnums.HEROPICK_STATE_RD_SELECT_UNUSED || 4,
    CmIntro = BotScriptEnums.HEROPICK_STATE_CM_INTRO || 5,
    CmCaptainPick = BotScriptEnums.HEROPICK_STATE_CM_CAPTAINPICK || 6,
    CmBan1 = BotScriptEnums.HEROPICK_STATE_CM_BAN1 || 7,
    CmBan2 = BotScriptEnums.HEROPICK_STATE_CM_BAN2 || 8,
    CmBan3 = BotScriptEnums.HEROPICK_STATE_CM_BAN3 || 9,
    CmBan4 = BotScriptEnums.HEROPICK_STATE_CM_BAN4 || 10,
    CmBan5 = BotScriptEnums.HEROPICK_STATE_CM_BAN5 || 11,
    CmBan6 = BotScriptEnums.HEROPICK_STATE_CM_BAN6 || 12,
    CmBan7 = BotScriptEnums.HEROPICK_STATE_CM_BAN7 || 13,
    CmBan8 = BotScriptEnums.HEROPICK_STATE_CM_BAN8 || 14,
    CmBan9 = BotScriptEnums.HEROPICK_STATE_CM_BAN9 || 15,
    CmBan10 = BotScriptEnums.HEROPICK_STATE_CM_BAN10 || 16,
    CmBan11 = BotScriptEnums.HEROPICK_STATE_CM_BAN11 || 17,
    CmBan12 = BotScriptEnums.HEROPICK_STATE_CM_BAN12 || 18,
    CmSelect1 = BotScriptEnums.HEROPICK_STATE_CM_SELECT1 || 19,
    CmSelect2 = BotScriptEnums.HEROPICK_STATE_CM_SELECT2 || 20,
    CmSelect3 = BotScriptEnums.HEROPICK_STATE_CM_SELECT3 || 21,
    CmSelect4 = BotScriptEnums.HEROPICK_STATE_CM_SELECT4 || 22,
    CmSelect5 = BotScriptEnums.HEROPICK_STATE_CM_SELECT5 || 23,
    CmSelect6 = BotScriptEnums.HEROPICK_STATE_CM_SELECT6 || 24,
    CmSelect7 = BotScriptEnums.HEROPICK_STATE_CM_SELECT7 || 25,
    CmSelect8 = BotScriptEnums.HEROPICK_STATE_CM_SELECT8 || 26,
    CmSelect9 = BotScriptEnums.HEROPICK_STATE_CM_SELECT9 || 27,
    CmSelect10 = BotScriptEnums.HEROPICK_STATE_CM_SELECT10 || 28,
    CmPick = BotScriptEnums.HEROPICK_STATE_CM_PICK || 29,
    ArSelect = BotScriptEnums.HEROPICK_STATE_AR_SELECT || 30,
    MoSelect = BotScriptEnums.HEROPICK_STATE_MO_SELECT || 31,
    FhSelect = BotScriptEnums.HEROPICK_STATE_FH_SELECT || 32,
    CdIntro = BotScriptEnums.HEROPICK_STATE_CD_INTRO || 33,
    CdCaptainPick = BotScriptEnums.HEROPICK_STATE_CD_CAPTAINPICK || 34,
    CdBan1 = BotScriptEnums.HEROPICK_STATE_CD_BAN1 || 35,
    CdBan2 = BotScriptEnums.HEROPICK_STATE_CD_BAN2 || 36,
    CdBan3 = BotScriptEnums.HEROPICK_STATE_CD_BAN3 || 37,
    CdBan4 = BotScriptEnums.HEROPICK_STATE_CD_BAN4 || 38,
    CdBan5 = BotScriptEnums.HEROPICK_STATE_CD_BAN5 || 39,
    CdBan6 = BotScriptEnums.HEROPICK_STATE_CD_BAN6 || 40,
    CdSelect1 = BotScriptEnums.HEROPICK_STATE_CD_SELECT1 || 41,
    CdSelect2 = BotScriptEnums.HEROPICK_STATE_CD_SELECT2 || 42,
    CdSelect3 = BotScriptEnums.HEROPICK_STATE_CD_SELECT3 || 43,
    CdSelect4 = BotScriptEnums.HEROPICK_STATE_CD_SELECT4 || 44,
    CdSelect5 = BotScriptEnums.HEROPICK_STATE_CD_SELECT5 || 45,
    CdSelect6 = BotScriptEnums.HEROPICK_STATE_CD_SELECT6 || 46,
    CdSelect7 = BotScriptEnums.HEROPICK_STATE_CD_SELECT7 || 47,
    CdSelect8 = BotScriptEnums.HEROPICK_STATE_CD_SELECT8 || 48,
    CdSelect9 = BotScriptEnums.HEROPICK_STATE_CD_SELECT9 || 49,
    CdSelect10 = BotScriptEnums.HEROPICK_STATE_CD_SELECT10 || 50,
    CdPick = BotScriptEnums.HEROPICK_STATE_CD_PICK || 51,
    BdSelect = BotScriptEnums.HEROPICK_STATE_BD_SELECT || 52,
    AbilityDraftSelect = BotScriptEnums.HERO_PICK_STATE_ABILITY_DRAFT_SELECT || 53,
    ArdmSelect = BotScriptEnums.HERO_PICK_STATE_ARDM_SELECT || 54,
    AllDraftSelect = BotScriptEnums.HEROPICK_STATE_ALL_DRAFT_SELECT || 55,
    CustomGameSelect = BotScriptEnums.HERO_PICK_STATE_CUSTOMGAME_SELECT || 56,
    SelectPenalty = BotScriptEnums.HEROPICK_STATE_SELECT_PENALTY || 57,
    Count = BotScriptEnums.HEROPICK_STATE_COUNT || 58,
}

export enum GameMode {
    None = BotScriptEnums.GAMEMODE_NONE || 0,
    Ap = BotScriptEnums.GAMEMODE_AP || 1,
    Cm = BotScriptEnums.GAMEMODE_CM || 2,
    Rd = BotScriptEnums.GAMEMODE_RD || 3,
    Sd = BotScriptEnums.GAMEMODE_SD || 4,
    Ar = BotScriptEnums.GAMEMODE_AR || 5,
    Intro = BotScriptEnums.GAMEMODE_INTRO || 6,
    Hw = BotScriptEnums.GAMEMODE_HW || 7,
    ReverseCm = BotScriptEnums.GAMEMODE_REVERSE_CM || 8,
    Xmas = BotScriptEnums.GAMEMODE_XMAS || 9,
    Tutorial = BotScriptEnums.GAMEMODE_TUTORIAL || 10,
    Mo = BotScriptEnums.GAMEMODE_MO || 11,
    Lp = BotScriptEnums.GAMEMODE_LP || 12,
    Pool1 = BotScriptEnums.GAMEMODE_POOL1 || 13,
    Fh = BotScriptEnums.GAMEMODE_FH || 14,
    Custom = BotScriptEnums.GAMEMODE_CUSTOM || 15,
    Cd = BotScriptEnums.GAMEMODE_CD || 16,
    Bd = BotScriptEnums.GAMEMODE_BD || 17,
    AbilityDraft = BotScriptEnums.GAMEMODE_ABILITY_DRAFT || 18,
    Event = BotScriptEnums.GAMEMODE_EVENT || 19,
    Ardm = BotScriptEnums.GAMEMODE_ARDM || 20,
    OneVsOneMid = BotScriptEnums.GAMEMODE_1V1MID || 21,
    AllDraft = BotScriptEnums.GAMEMODE_ALL_DRAFT || 22,
    Turbo = BotScriptEnums.GAMEMODE_TURBO || 23,
    Mutation = BotScriptEnums.GAMEMODE_MUTATION || 24,
    CoachesChallenge = BotScriptEnums.GAMEMODE_COACHES_CHALLENGE || 25,
}
