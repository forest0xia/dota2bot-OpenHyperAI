# FuncLib — Bot Library Structure

```
FuncLib/
├── func_utils.lua              Orchestrator — loads all general_utils modules, returns Fu table
├── README.md
│
├── general_utils/              Core utility functions (305 functions)
│   ├── unit_check.lua          14 funcs — IsValid, IsSuspiciousIllusion, IsMeepoClone, CanBeAttacked
│   ├── hero_state.lua          27 funcs — IsDisabled, IsTaunted, modifiers, CanNotUseAction
│   ├── math_helper.lua         12 funcs — GetHP, GetMP, ToNearest500, CombineTwoTable
│   ├── combat.lua              22 funcs — WillKillTarget, WeAreStronger, GetArmorReducers
│   ├── targeting.lua           16 funcs — GetProperTarget, GetAttackableWeakestUnit
│   ├── positioning.lua         31 funcs — GetCastLocation, VectorTowards, IsHeroBetweenMe*
│   ├── team_info.lua           46 funcs — GetNearbyHeroes, GetEnemyList, GetAlliesNearLoc
│   ├── bot_mode.lua            15 funcs — IsRetreating, IsPushing, IsInTeamFight
│   ├── item_ability.lua        34 funcs — HasItem, CanCastAbility, SetQueueToInvisible
│   ├── map_info.lua            32 funcs — GetTeamFountain, IsRoshanAlive, CheckTimeOfDay
│   ├── lane_strategy.lua        6 funcs — GetMostPushLaneDesire, GetDefendLaneDesire
│   ├── projectile.lua          12 funcs — IsProjectileIncoming, DidEnemyCastAbility
│   ├── hero_info.lua           23 funcs — GetPosition, IsCore, GetClosestAlly
│   ├── special_units.lua        7 funcs — GetSpecialUnits, GetTechiesMines
│   └── init_debug.lua           8 funcs — SetUserHeroInit, CheckBotIdleState, ModeAnnounce
│
├── data/                       Static data tables — no game logic
│   ├── buff.lua                Modifier/buff name lists
│   ├── chat_table.lua          Chat reply keyword/response templates
│   ├── hero_names.lua          Hero internal name → display name mapping (cn/en)
│   ├── hero_pos_weights.lua    Hero position weight data
│   ├── hero_roles_map.lua      Hero-to-role mapping
│   ├── item_names.lua          Item internal name → display name mapping (cn/en)
│   ├── matchups.lua            Hero matchup data
│   ├── site.lua                Map locations, ward spots, tower data
│   ├── spell_list.lua          Spell/ability data tables
│   ├── spell_prob_list.lua     Spell probability data
│   └── team_names.lua          Bot team name lists
│
├── systems/                    Core bot systems — game logic modules
│   ├── cache.lua               Global state caching
│   ├── chat.lua                Chat/communication system (replies, name display)
│   ├── custom_loader.lua       User customization loader
│   ├── defend.lua              Tower/base defense logic
│   ├── global_overrides.lua    Valve API overrides
│   ├── item.lua                Item purchase/usage system
│   ├── item_strategy.lua       Advanced item build strategy
│   ├── localization.lua        Multi-language support (en/zh/ru/ja)
│   ├── push.lua                Tower push logic
│   ├── role.lua                Role/position assignment
│   ├── skill.lua               Skill/ability build system
│   ├── utils.lua               Shared utility functions
│   ├── version.lua             Version info
│   ├── ward.lua                Ward placement logic
│   └── override_generic/       Mode override scripts
│       ├── mode_attack_generic.lua
│       └── mode_laning_generic.lua
│
└── hero/                       Hero-specific utilities
    ├── captain_mode.lua        Captain's mode pick/ban logic
    ├── enemy_role_estimation.lua  Enemy role detection
    ├── hero_skill.lua          Per-hero skill usage
    ├── hero_sub_units.lua      Hero sub-unit management
    ├── minion.lua              Minion/summon control entry point
    ├── morphling.lua           Morphling-specific logic
    ├── rubick.lua              Rubick spell steal logic
    ├── special_units.lua       Special unit targeting (wards, golems, etc.)
    ├── techies.lua             Techies mine logic
    ├── minion_lib/             Per-hero minion AI
    │   ├── utils.lua, attacking_wards.lua, familiars.lua,
    │   ├── illusions.lua, jugg.lua, minion_with_skill.lua,
    │   ├── primal_split.lua, vengeful_spirit.lua
    └── rubick_hero/            Per-hero Rubick stolen spell logic
        └── abaddon.lua ... rattletrap.lua (21 heroes)
```

## Usage

```lua
local Fu = require( GetScriptDirectory()..'/FuncLib/func_utils' )
Fu.IsValid(target)
Fu.GetHP(bot)
```

`func_utils.lua` creates the `Fu` table, loads sub-libraries from `data/` and `systems/`, then loads each module from `general_utils/` which populates `Fu` with 305 functions.

## Sub-libraries on Fu

| Field          | Source                      |
| -------------- | --------------------------- |
| `Fu.Site`      | `data/site.lua`             |
| `Fu.Buff`      | `data/buff.lua`             |
| `Fu.Item`      | `systems/item.lua`          |
| `Fu.Role`      | `systems/role.lua`          |
| `Fu.Skill`     | `systems/skill.lua`         |
| `Fu.Chat`      | `systems/chat.lua`          |
| `Fu.Utils`     | `systems/utils.lua`         |
| `Fu.Customize` | `systems/custom_loader.lua` |
