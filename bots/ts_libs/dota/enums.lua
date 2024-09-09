--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local DESIRE_NONE = 0
local DESIRE_VERY_LOW = 0.1
local DESIRE_LOW = 0.25
local DESIRE_MODERATE = 0.5
local DESIRE_HIGH = 0.75
local DESIRE_VERY_HIGH = 0.9
local DESIRE_ABSOLUTE = 1
____exports.BotActionDesire = BotActionDesire or ({})
____exports.BotActionDesire.None = BOT_ACTION_DESIRE_NONE or DESIRE_NONE
____exports.BotActionDesire[____exports.BotActionDesire.None] = "None"
____exports.BotActionDesire.VeryLow = BOT_ACTION_DESIRE_VERYLOW or DESIRE_VERY_LOW
____exports.BotActionDesire[____exports.BotActionDesire.VeryLow] = "VeryLow"
____exports.BotActionDesire.Low = BOT_ACTION_DESIRE_LOW or DESIRE_LOW
____exports.BotActionDesire[____exports.BotActionDesire.Low] = "Low"
____exports.BotActionDesire.Moderate = BOT_ACTION_DESIRE_MODERATE or DESIRE_MODERATE
____exports.BotActionDesire[____exports.BotActionDesire.Moderate] = "Moderate"
____exports.BotActionDesire.High = BOT_ACTION_DESIRE_HIGH or DESIRE_HIGH
____exports.BotActionDesire[____exports.BotActionDesire.High] = "High"
____exports.BotActionDesire.VeryHigh = BOT_ACTION_DESIRE_VERYHIGH or DESIRE_VERY_HIGH
____exports.BotActionDesire[____exports.BotActionDesire.VeryHigh] = "VeryHigh"
____exports.BotActionDesire.Absolute = BOT_ACTION_DESIRE_ABSOLUTE or DESIRE_ABSOLUTE
____exports.BotActionDesire[____exports.BotActionDesire.Absolute] = "Absolute"
____exports.BotModeDesire = BotModeDesire or ({})
____exports.BotModeDesire.None = BOT_MODE_DESIRE_NONE or DESIRE_NONE
____exports.BotModeDesire[____exports.BotModeDesire.None] = "None"
____exports.BotModeDesire.VeryLow = BOT_MODE_DESIRE_VERYLOW or DESIRE_VERY_LOW
____exports.BotModeDesire[____exports.BotModeDesire.VeryLow] = "VeryLow"
____exports.BotModeDesire.Low = BOT_MODE_DESIRE_LOW or DESIRE_LOW
____exports.BotModeDesire[____exports.BotModeDesire.Low] = "Low"
____exports.BotModeDesire.Moderate = BOT_MODE_DESIRE_MODERATE or DESIRE_MODERATE
____exports.BotModeDesire[____exports.BotModeDesire.Moderate] = "Moderate"
____exports.BotModeDesire.High = BOT_MODE_DESIRE_HIGH or DESIRE_HIGH
____exports.BotModeDesire[____exports.BotModeDesire.High] = "High"
____exports.BotModeDesire.VeryHigh = BOT_MODE_DESIRE_VERYHIGH or DESIRE_VERY_HIGH
____exports.BotModeDesire[____exports.BotModeDesire.VeryHigh] = "VeryHigh"
____exports.BotModeDesire.Absolute = BOT_MODE_DESIRE_ABSOLUTE or DESIRE_ABSOLUTE
____exports.BotModeDesire[____exports.BotModeDesire.Absolute] = "Absolute"
____exports.BotMode = BotMode or ({})
____exports.BotMode.None = BOT_MODE_NONE or 0
____exports.BotMode[____exports.BotMode.None] = "None"
____exports.BotMode.Laning = BOT_MODE_LANING or 1
____exports.BotMode[____exports.BotMode.Laning] = "Laning"
____exports.BotMode.Attack = BOT_MODE_ATTACK or 2
____exports.BotMode[____exports.BotMode.Attack] = "Attack"
____exports.BotMode.Roam = BOT_MODE_ROAM or 3
____exports.BotMode[____exports.BotMode.Roam] = "Roam"
____exports.BotMode.Retreat = BOT_MODE_RETREAT or 4
____exports.BotMode[____exports.BotMode.Retreat] = "Retreat"
____exports.BotMode.SecretShop = BOT_MODE_SECRET_SHOP or 5
____exports.BotMode[____exports.BotMode.SecretShop] = "SecretShop"
____exports.BotMode.SideShop = BOT_MODE_SIDE_SHOP or 6
____exports.BotMode[____exports.BotMode.SideShop] = "SideShop"
____exports.BotMode.Rune = BOT_MODE_RUNE or 7
____exports.BotMode[____exports.BotMode.Rune] = "Rune"
____exports.BotMode.PushTowerTop = BOT_MODE_PUSH_TOWER_TOP or 8
____exports.BotMode[____exports.BotMode.PushTowerTop] = "PushTowerTop"
____exports.BotMode.PushTowerMid = BOT_MODE_PUSH_TOWER_MID or 9
____exports.BotMode[____exports.BotMode.PushTowerMid] = "PushTowerMid"
____exports.BotMode.PushTowerBot = BOT_MODE_PUSH_TOWER_BOT or 10
____exports.BotMode[____exports.BotMode.PushTowerBot] = "PushTowerBot"
____exports.BotMode.DefendTowerTop = BOT_MODE_DEFEND_TOWER_TOP or 11
____exports.BotMode[____exports.BotMode.DefendTowerTop] = "DefendTowerTop"
____exports.BotMode.DefendTowerMid = BOT_MODE_DEFEND_TOWER_MID or 12
____exports.BotMode[____exports.BotMode.DefendTowerMid] = "DefendTowerMid"
____exports.BotMode.DefendTowerBot = BOT_MODE_DEFEND_TOWER_BOT or 13
____exports.BotMode[____exports.BotMode.DefendTowerBot] = "DefendTowerBot"
____exports.BotMode.Assemble = BOT_MODE_ASSEMBLE or 14
____exports.BotMode[____exports.BotMode.Assemble] = "Assemble"
____exports.BotMode.TeamRoam = BOT_MODE_TEAM_ROAM or 16
____exports.BotMode[____exports.BotMode.TeamRoam] = "TeamRoam"
____exports.BotMode.Farm = BOT_MODE_FARM or 17
____exports.BotMode[____exports.BotMode.Farm] = "Farm"
____exports.BotMode.DefendAlly = BOT_MODE_DEFEND_ALLY or 18
____exports.BotMode[____exports.BotMode.DefendAlly] = "DefendAlly"
____exports.BotMode.EvasiveManeuvers = BOT_MODE_EVASIVE_MANEUVERS or 19
____exports.BotMode[____exports.BotMode.EvasiveManeuvers] = "EvasiveManeuvers"
____exports.BotMode.Roshan = BOT_MODE_ROSHAN or 20
____exports.BotMode[____exports.BotMode.Roshan] = "Roshan"
____exports.BotMode.Item = BOT_MODE_ITEM or 21
____exports.BotMode[____exports.BotMode.Item] = "Item"
____exports.BotMode.Ward = BOT_MODE_WARD or 22
____exports.BotMode[____exports.BotMode.Ward] = "Ward"
____exports.Team = Team or ({})
____exports.Team.Radiant = TEAM_RADIANT or 2
____exports.Team[____exports.Team.Radiant] = "Radiant"
____exports.Team.Dire = TEAM_DIRE or 3
____exports.Team[____exports.Team.Dire] = "Dire"
____exports.Team.Neutral = TEAM_NEUTRAL or 4
____exports.Team[____exports.Team.Neutral] = "Neutral"
____exports.Team.None = TEAM_NONE or 5
____exports.Team[____exports.Team.None] = "None"
____exports.Lane = Lane or ({})
____exports.Lane.None = LANE_NONE or 0
____exports.Lane[____exports.Lane.None] = "None"
____exports.Lane.Top = LANE_TOP or 1
____exports.Lane[____exports.Lane.Top] = "Top"
____exports.Lane.Mid = LANE_MID or 2
____exports.Lane[____exports.Lane.Mid] = "Mid"
____exports.Lane.Bot = LANE_BOT or 3
____exports.Lane[____exports.Lane.Bot] = "Bot"
____exports.UnitType = UnitType or ({})
____exports.UnitType.All = UNIT_LIST_ALL or 0
____exports.UnitType[____exports.UnitType.All] = "All"
____exports.UnitType.Allies = UNIT_LIST_ALLIES or 1
____exports.UnitType[____exports.UnitType.Allies] = "Allies"
____exports.UnitType.AlliedHeroes = UNIT_LIST_ALLIED_HEROES or 2
____exports.UnitType[____exports.UnitType.AlliedHeroes] = "AlliedHeroes"
____exports.UnitType.AlliedCreeps = UNIT_LIST_ALLIED_CREEPS or 3
____exports.UnitType[____exports.UnitType.AlliedCreeps] = "AlliedCreeps"
____exports.UnitType.AlliedWards = UNIT_LIST_ALLIED_WARDS or 4
____exports.UnitType[____exports.UnitType.AlliedWards] = "AlliedWards"
____exports.UnitType.AlliedBuildings = UNIT_LIST_ALLIED_BUILDINGS or 5
____exports.UnitType[____exports.UnitType.AlliedBuildings] = "AlliedBuildings"
____exports.UnitType.Enemies = UNIT_LIST_ENEMIES or 7
____exports.UnitType[____exports.UnitType.Enemies] = "Enemies"
____exports.UnitType.EnemyHeroes = UNIT_LIST_ENEMY_HEROES or 8
____exports.UnitType[____exports.UnitType.EnemyHeroes] = "EnemyHeroes"
____exports.UnitType.EnemyCreeps = UNIT_LIST_ENEMY_CREEPS or 9
____exports.UnitType[____exports.UnitType.EnemyCreeps] = "EnemyCreeps"
____exports.UnitType.EnemyWards = UNIT_LIST_ENEMY_WARDS or 10
____exports.UnitType[____exports.UnitType.EnemyWards] = "EnemyWards"
____exports.UnitType.EnemyBuildings = UNIT_LIST_ENEMY_BUILDINGS or 11
____exports.UnitType[____exports.UnitType.EnemyBuildings] = "EnemyBuildings"
____exports.UnitType.NeutralCreeps = UNIT_LIST_NEUTRAL_CREEPS or 13
____exports.UnitType[____exports.UnitType.NeutralCreeps] = "NeutralCreeps"
____exports.BotActionType = BotActionType or ({})
____exports.BotActionType.None = 0
____exports.BotActionType[____exports.BotActionType.None] = "None"
____exports.Tower = Tower or ({})
____exports.Tower.Top1 = TOWER_TOP_1 or 0
____exports.Tower[____exports.Tower.Top1] = "Top1"
____exports.Tower.Top2 = TOWER_TOP_2 or 1
____exports.Tower[____exports.Tower.Top2] = "Top2"
____exports.Tower.Top3 = TOWER_TOP_3 or 2
____exports.Tower[____exports.Tower.Top3] = "Top3"
____exports.Tower.Mid1 = TOWER_MID_1 or 3
____exports.Tower[____exports.Tower.Mid1] = "Mid1"
____exports.Tower.Mid2 = TOWER_MID_2 or 4
____exports.Tower[____exports.Tower.Mid2] = "Mid2"
____exports.Tower.Mid3 = TOWER_MID_3 or 5
____exports.Tower[____exports.Tower.Mid3] = "Mid3"
____exports.Tower.Bot1 = TOWER_BOT_1 or 6
____exports.Tower[____exports.Tower.Bot1] = "Bot1"
____exports.Tower.Bot2 = TOWER_BOT_2 or 7
____exports.Tower[____exports.Tower.Bot2] = "Bot2"
____exports.Tower.Bot3 = TOWER_BOT_3 or 8
____exports.Tower[____exports.Tower.Bot3] = "Bot3"
____exports.Tower.Base1 = TOWER_BASE_1 or 9
____exports.Tower[____exports.Tower.Base1] = "Base1"
____exports.Tower.Base2 = TOWER_BASE_2 or 10
____exports.Tower[____exports.Tower.Base2] = "Base2"
____exports.Barracks = Barracks or ({})
____exports.Barracks.TopMelee = BARRACKS_TOP_MELEE or 0
____exports.Barracks[____exports.Barracks.TopMelee] = "TopMelee"
____exports.Barracks.TopRanged = BARRACKS_TOP_RANGED or 1
____exports.Barracks[____exports.Barracks.TopRanged] = "TopRanged"
____exports.Barracks.MidMelee = BARRACKS_MID_MELEE or 2
____exports.Barracks[____exports.Barracks.MidMelee] = "MidMelee"
____exports.Barracks.MidRanged = BARRACKS_MID_RANGED or 3
____exports.Barracks[____exports.Barracks.MidRanged] = "MidRanged"
____exports.Barracks.BotMelee = BARRACKS_BOT_MELEE or 4
____exports.Barracks[____exports.Barracks.BotMelee] = "BotMelee"
____exports.Barracks.BotRanged = BARRACKS_BOT_RANGED or 5
____exports.Barracks[____exports.Barracks.BotRanged] = "BotRanged"
____exports.Rune = Rune or ({})
____exports.Rune.Power1 = RUNE_POWERUP_1 or 0
____exports.Rune[____exports.Rune.Power1] = "Power1"
____exports.Rune.Power2 = RUNE_POWERUP_2 or 1
____exports.Rune[____exports.Rune.Power2] = "Power2"
____exports.Rune.Bounty1 = RUNE_BOUNTY_1 or 2
____exports.Rune[____exports.Rune.Bounty1] = "Bounty1"
____exports.Rune.Bounty2 = RUNE_BOUNTY_2 or 3
____exports.Rune[____exports.Rune.Bounty2] = "Bounty2"
____exports.Rune.Bounty3 = RUNE_BOUNTY_3 or 4
____exports.Rune[____exports.Rune.Bounty3] = "Bounty3"
____exports.Rune.Bounty4 = RUNE_BOUNTY_4 or 5
____exports.Rune[____exports.Rune.Bounty4] = "Bounty4"
____exports.Shop = Shop or ({})
____exports.Shop.Home = SHOP_HOME or 0
____exports.Shop[____exports.Shop.Home] = "Home"
____exports.Shop.Side = SHOP_SIDE or 1
____exports.Shop[____exports.Shop.Side] = "Side"
____exports.Shop.Secret = SHOP_SECRET or 2
____exports.Shop[____exports.Shop.Secret] = "Secret"
____exports.Shop.Side2 = SHOP_SIDE2 or 4
____exports.Shop[____exports.Shop.Side2] = "Side2"
____exports.Shop.Secret2 = SHOP_SECRET2 or 5
____exports.Shop[____exports.Shop.Secret2] = "Secret2"
return ____exports
