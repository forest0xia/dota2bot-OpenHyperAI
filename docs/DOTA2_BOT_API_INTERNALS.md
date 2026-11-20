# Dota 2 Bot VM & Server VScript Internals

Technical reference for undocumented, under-documented, and version-sensitive behavior in Dota 2's bot scripting engine (`server.dll`, verified against **Patch 7.42**). Pairs with [docs/ARCHITECTURE.md](ARCHITECTURE.md) when debugging engine edge cases, vector-targeted abilities, mode overrides, or cross-VM limitations.

---

## 1. Two Isolated Lua Virtual Machines

Dota 2 executes Lua in **two strictly separated scripting environments** inside `server.dll`:

| Aspect | Bot VM (`CDOTA_Bot_Script`) | Server VScript (`CScriptVM`) |
|--------|-----------------------------|------------------------------|
| **Loaded Scripts** | `bots/bot_*.lua`, `bots/hero_selection.lua`, `bots/team_desires.lua`, `bots/item_purchase_*.lua`, `bots/ability_item_usage_*.lua`, `bots/mode_*_*.lua` | Custom/lobby/cheat scripts loaded via `script_reload_code` (e.g. `bots/FretBots.lua`, `bots/Buff/Buff.lua`) |
| **Root Helper** | `GetScriptDirectory()` returns active bot folder (`"bots"`) | `GetScriptDirectory` is **undefined** unless shimmed (`Buff.lua` shims to `"bots"`) |
| **Unit Handle Type** | `CDOTA_Bot_Script` (`GetBot()`) | `CDOTA_BaseNPC` / `CDOTA_BaseNPC_Hero` (`EntIndexToHScript`, `PlayerResource`) |
| **Order Issuance** | Restricted to queued/immediate `Action_*` methods | Full `ExecuteOrderFromTable` + `GameRules:GetGameModeEntity():SetExecuteOrderFilter` |
| **World / Entity Queries** | Bot fog-of-war filtered globals (`GetUnitList`, `GetNeutralSpawners`) | Unfiltered server entities (`Entities:FindAllByClassname`, `FindUnitsInRadius`, `GetGroundHeight`) |
| **Communication** | One-way observation (game state changes made by VScript are visible to Bot VM) | Cannot be `require()`d directly from Bot VM; shares no Lua state/upvalues |

### Implication for Architecture
- Bot VM scripts **cannot** call `ExecuteOrderFromTable`, `SetExecuteOrderFilter`, `ToggleAltCast`, `FindUnitsInRadius`, or `Entities:*`.
- Features requiring server privileges (FretBots stat/XP/neutral grants, neutral item roll/distribution, and **vector-targeted ability injection**) live in `bots/FretBots/` and `bots/Buff/`, loaded in Server VScript context (`sv_cheats 1; script_reload_code bots/FretBots` or `bots/Buff/buff`).

---

## 2. All 32 `EDOTABotMode` Override Slots

During `CDOTA_Bot::Init`, the engine iterates `mode = 0..31` over `EDOTABotMode`, resolves each lowercase enum name via `GetBotModeName(mode)`, and if that C++ mode object exists on the bot, loads `mode_<lower>_generic.lua` (or hero-specific `mode_<lower>_<hero>.lua`) into `BotModeScriptScope`.

| ID | Engine Mode Name | Lua Override Filename (`bots/`) | Lua Constant | Status / Notes |
|---:|---|---|---|----|
| 0 | `NONE` | `mode_none_generic.lua` | `BOT_MODE_NONE` | Default idle slot |
| 1 | `LANING` | `mode_laning_generic.lua` | `BOT_MODE_LANING` | Active override in OHA |
| 2 | `ATTACK` | `mode_attack_generic.lua` | `BOT_MODE_ATTACK` | Active override in OHA |
| 3 | `ROAM` | `mode_roam_generic.lua` | `BOT_MODE_ROAM` | Active override in OHA |
| 4 | `RETREAT` | `mode_retreat_generic.lua` | `BOT_MODE_RETREAT` | Active override in OHA |
| 5 | `SECRET_SHOP` | `mode_secret_shop_generic.lua` | `BOT_MODE_SECRET_SHOP` | Active override in OHA |
| 6 | `SIDE_SHOP` | `mode_side_shop_generic.lua` | `BOT_MODE_SIDE_SHOP` | Repurposed by OHA for Tormentor |
| 7 | `RUNE` | `mode_rune_generic.lua` | `BOT_MODE_RUNE` | Undocumented constant in old docs, exists in VM |
| 8 | `PUSH_TOWER_TOP` | `mode_push_tower_top_generic.lua` | `BOT_MODE_PUSH_TOWER_TOP` | Active override in OHA |
| 9 | `PUSH_TOWER_MID` | `mode_push_tower_mid_generic.lua` | `BOT_MODE_PUSH_TOWER_MID` | Active override in OHA |
| 10 | `PUSH_TOWER_BOT` | `mode_push_tower_bot_generic.lua` | `BOT_MODE_PUSH_TOWER_BOT` | Active override in OHA |
| 11 | `DEFEND_TOWER_TOP` | `mode_defend_tower_top_generic.lua` | `BOT_MODE_DEFEND_TOWER_TOP` | Active override in OHA |
| 12 | `DEFEND_TOWER_MID` | `mode_defend_tower_mid_generic.lua` | `BOT_MODE_DEFEND_TOWER_MID` | Active override in OHA |
| 13 | `DEFEND_TOWER_BOT` | `mode_defend_tower_bot_generic.lua` | `BOT_MODE_DEFEND_TOWER_BOT` | Active override in OHA |
| 14 | `ASSEMBLE` | `mode_assemble_generic.lua` | `BOT_MODE_ASSEMBLE` | Active override in OHA |
| 15 | `ASSEMBLE_WITH_HUMANS` | `mode_assemble_with_humans_generic.lua` | `BOT_MODE_ASSEMBLE_WITH_HUMANS` | Undocumented constant |
| 16 | `TEAM_ROAM` | `mode_team_roam_generic.lua` | `BOT_MODE_TEAM_ROAM` | Active override in OHA |
| 17 | `FARM` | `mode_farm_generic.lua` | `BOT_MODE_FARM` | Active override in OHA |
| 18 | `DEFEND_ALLY` | `mode_defend_ally_generic.lua` | `BOT_MODE_DEFEND_ALLY` | Active override in OHA |
| 19 | `EVASIVE_MANEUVERS` | `mode_evasive_maneuvers_generic.lua` | `BOT_MODE_EVASIVE_MANEUVERS` | Active override in OHA |
| 20 | `ROSHAN` | `mode_roshan_generic.lua` | `BOT_MODE_ROSHAN` | Active override in OHA |
| 21 | `ITEM` | `mode_item_generic.lua` | `BOT_MODE_ITEM` | Active override in OHA |
| 22 | `WARD` | `mode_ward_generic.lua` | `BOT_MODE_WARD` | Active override in OHA |
| 23 | `COMPANION` | `mode_companion_generic.lua` | — | No Lua `BOT_MODE_*` constant exported |
| 24 | `TUTORIAL_BOSS` | `mode_tutorial_boss_generic.lua` | — | Used in scripted tutorials |
| 25 | `MINION` | `mode_minion_generic.lua` | — | Default minion handling |
| 26 | `OUTPOST` | `mode_outpost_generic.lua` | `BOT_MODE_OUTPOST` | Active in OHA (`BOT_MODE_OUTPOST = 26`) |
| 27 | `BOT_CHALLENGE_MODE_ENDGAME` | `mode_bot_challenge_mode_endgame_generic.lua` | — | Engine slot present |
| 28 | `WATCHER` | `mode_watcher_generic.lua` | — | C++ `Think` exists; no `GetDesire` export / Lua constant |
| 29 | `WISDOM_SHRINE` | `mode_wisdom_shrine_generic.lua` | — | Engine mode (`CDOTA_BotMode_WisdomShrine`); no Lua `BOT_MODE_*` constant |
| 30 | `LOTUS_POOL` | `mode_lotus_pool_generic.lua` | — | Engine mode (`CDOTA_BotMode_LotusPool`); no Lua `BOT_MODE_*` constant |
| 31 | `DEWARD` | `mode_deward_generic.lua` | — | Engine mode (`CDOTA_BotMode_Deward`); no Lua `BOT_MODE_*` constant |

### Mode Slot Gotchas
- **Missing Lua constants for modes 28–31**: Calling `bot:GetActiveMode()` returns numeric `29`, `30`, or `31` even though no `BOT_MODE_WISDOM_SHRINE` / `BOT_MODE_LOTUS_POOL` / `BOT_MODE_DEWARD` globals exist. Guard numeric values (`>= 28`) or provide Lua fallback definitions when writing mode checks.
- **Map objective overrides in OHA**: `mode_rune_generic.lua` handles Wisdom Shrines and `mode_side_shop_generic.lua` handles Tormentor alongside `mode_outpost_generic.lua`.

---

## 3. Vector-Targeted Abilities (`DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION`)

### Why Bot VM Fails Alone
In `CDOTA_Bot_Script`, only two positional/unit cast constructors exist:
- `Action_UseAbilityOnLocation(hAbility, vLocation)` -> `DOTA_UNIT_ORDER_CAST_POSITION` (`5`)
- `Action_UseAbilityOnEntity(hAbility, hUnit)` -> `DOTA_UNIT_ORDER_CAST_TARGET` (`6`)

Neither Bot VM action accepts a second vector endpoint. When a bot casts an ability with `DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING` from Bot VM alone, `m_vVectorTargetPosition` remains unset/stale.

### Engine Vector Order Contract
In `DOTA_ExecuteOrders`, human clients transmit two paired orders for vector-targeted casts:
1. **`OrderType = 30` (`DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION`)** with `AbilityIndex` and `Position = endPos` (plus `TargetIndex` for unit-target spells).
   - For point-vector abilities (`pangolier_swashbuckle`, `void_spirit_aether_remnant`, `dark_seer_wall_of_replica`, `disruptor_kinetic_fence`, `windrunner_gale_force`, `tinker_deploy_turrets`, etc.) and most unit-vector abilities (`marci_companion_run`, `tusk_walrus_kick`, `enraged_wildkin_hurricane`), the handler writes `Position` (world endpoint) into the ability's vector-target field.
   - **Important distinction (`muerta_dead_shot`)**: When `TargetIndex` is provided on `OrderType = 30`, `CDOTA_Ability_Muerta_DeadShot` automatically computes `Position - TargetEntity:GetAbsOrigin()` and stores the relative direction vector; if `TargetIndex` is omitted, it writes raw `Position` directly without subtracting `TargetAbsOrigin`. Passing `TargetIndex` whenever the incoming order is `CAST_TARGET` (`6`) keeps both paths correct.
2. **`OrderType = 5` (`CAST_POSITION`)** or **`OrderType = 6` (`CAST_TARGET`)** immediately executes using the vector endpoint just stored.

### How `bots/FretBots/VectorTargeting.lua` Bridges It
- Loaded automatically by `bots/FretBots.lua` and `bots/Buff/Buff.lua` via `VectorTargeting:Initialize()`.
- Registers a single `GameRules:GetGameModeEntity():SetExecuteOrderFilter` callback guarded by `_G.__OHA_VECTOR_FILTER_REGISTERED`.
- **Human safety**: Checks `PlayerResource:IsFakeClient(playerID)` on both `unit:GetPlayerOwnerID()` and `issuer_player_id_const`, immediately returning `true` unchanged for real human players.
- **Filter table layout gotcha**: `filterTable.units` keys generated by C++ `ExecuteOrderFilter` are **decimal strings** (`"0"`, `"1"`, ...) rather than Lua 1-based integers (`units["0"] or units[0] or units[1]`).
- **Synchronous re-entry**: Emits `ExecuteOrderFromTable` with `OrderType = 30`, `Position = endPos` (and `TargetIndex` if `CAST_TARGET`) right before returning `true` for the original `CAST_POSITION`/`CAST_TARGET` order, protected by a per-`(unitIndex, abilityIndex)` `dispatching` guard.

### All 7.42 `VECTOR_TARGETING` Abilities Supported
- **Unit-targeted (`UNIT_TARGET | VECTOR_TARGETING`)**: `muerta_dead_shot`, `marci_companion_run`, `brewmaster_fire_pull`, `enraged_wildkin_hurricane`, `tusk_walrus_kick`, `item_muertas_gun`
- **Point-targeted (`POINT | VECTOR_TARGETING`)**: `pangolier_swashbuckle`, `dark_seer_wall_of_replica`, `void_spirit_aether_remnant`, `disruptor_kinetic_fence`, `windrunner_gale_force`, `tinker_deploy_turrets`, `clinkz_burning_army`, `broodmother_sticky_snare`, `magnataur_greater_shockwave`, `shadow_shaman_serpentine`

---

## 4. `Action_UseAbility` Order-Type Bitmask & Traps

When Bot VM executes `Action_UseAbility(hAbility)`, `server.dll` does **not** blindly send `DOTA_UNIT_ORDER_CAST_NO_TARGET` (`8`). Instead it inspects the ability's `DOTA_ABILITY_BEHAVIOR` 64-bit flags in priority order:

1. **Autocast toggle** (`IsAutoCast` / autocastable state check) -> emits `DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO` (`41` when autocast toggles? Actually `DOTA_UNIT_ORDER_CAST_TOGGLE` / autocast path depending on `ShouldAutoCast`).
2. **`DOTA_ABILITY_BEHAVIOR_TOGGLE` (`bit 8`)** -> emits `DOTA_UNIT_ORDER_CAST_TOGGLE` (`9`).
3. **`DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET` (`bit 12`)** -> when used as self-no-target casts via alternate branch (`20`).
4. **`DOTA_ABILITY_BEHAVIOR_SKIP_FOR_KEYBINDS` (`bit 40`, `0x10000000000`)** -> emits `OrderType = 40` (`DOTA_UNIT_ORDER_CONSUME_ITEM` / consume ability)!
   - **Trap**: Any consumable/eatable item or special ability flagged with behavior bit `40` routes through `OrderType = 40` instead of `8`.
5. **`DOTA_ABILITY_BEHAVIOR_NO_TARGET` (`bit 1`)** -> emits `DOTA_UNIT_ORDER_CAST_NO_TARGET` (`8`).

### `ALT_CASTABLE` Abilities (Bit 39)
- `CDOTABaseAbility` in **Server VScript** exposes `ToggleAltCast()`, `SetAltCastState(bool)`, `GetAltCastState()`, and `ShouldAltCast()`.
- **Bot VM (`CDOTA_Bot_Script`) exposes NONE of these methods**, nor any constant `ABILITY_BEHAVIOR_ALT_CASTABLE` (`bit 39`) or `Action_*` to emit `DOTA_UNIT_ORDER_CAST_TOGGLE_ALT` (`41`).
- Consequently, `NO_TARGET | ALT_CASTABLE` abilities cast strictly using their current toggle state unless toggled via Server VScript (`ExecuteOrderFromTable` with `OrderType = 41`).

### Aghanim's Scepter / Shard Modal Upgrades
- Abilities/upgrades that put the hero into a modal selection wait modifier (`modifier_item_aghanims_scepter_wait_for_upgrade_selected` / `modifier_item_aghanims_shard_wait_for_upgrade_selected`, such as Invoker's 7.41+ Scepter/Shard upgrades) expect a `DOTA_CM_ChooseAghanimUpgrade` client message from Panorama UI.
- **Bot VM has zero client-message UI APIs** to pick a choice, leaving bots stuck holding the wait modifier or wasting gold. Always guard such items out of bot buy lists (`hero_invoker.lua` skips `item_ultimate_scepter` / `item_aghanims_shard`).

---

## 5. Missing Constants & Undocumented Bot VM APIs

### Missing `ATTRIBUTE_ALL` Constant (CRITICAL)
Bot VM registers only:
```lua
ATTRIBUTE_INVALID   = -1
ATTRIBUTE_STRENGTH  = 0
ATTRIBUTE_AGILITY   = 1
ATTRIBUTE_INTELLECT = 2
```
**`ATTRIBUTE_ALL` does NOT exist in Bot VM Lua.** Universal heroes (`DOTA_ATTRIBUTE_ALL`) return integer **`3`** from `bot:GetPrimaryAttribute()`. Comparing against `ATTRIBUTE_ALL` evaluates `== nil` (`false`). Always check numerically:
```lua
local ATTRIBUTE_ALL = 3
if unit:GetPrimaryAttribute() == ATTRIBUTE_ALL then ... end
```

### Undocumented Bot VM Globals Present at Runtime
- **Handle / Projectile resolution**: `GetBotByHandle(nHandle)`, `GetLinearProjectileByHandle(nHandle)`, `GetUnitPotentialValue(unit, vLoc, fRadius)`
- **Pathing / Avoidance**: `GeneratePath(vStart, vEnd, tAvoidZones, fnDone)`, `AddConditionalAvoidanceZone(vLoc, fRadius, fnActive)`
- **Map / Couriers / Runes**: `GetCourierForPlayer(nPlayerID)`, `COURIER_ACTION_RETURN_STASH_ITEMS`, `GetShrine(nTeam, nIndex)`, `GetOutpost(...)`, `GetShrineCooldown(hShrine)`, `IsShrineHealing(hShrine)`, `GetRuneTimeSinceSeen(nRune)`, `GetAllTrees()`, `GetTimeOfDay()`, `GetWorldBounds()`, `GetGameStateTimeRemaining()`, `RemapVal(...)`
- **Additional `UNIT_LIST_*` & `RUNE_*` constants**: `UNIT_LIST_ALLIED_OTHER`, `UNIT_LIST_ENEMY_OTHER`, `UNIT_LIST_THINKERS`, `RUNE_WATER`, `RUNE_XP`, `RUNE_SHIELD`, `DIFFICULTY_NPX`, `GAME_STATE_PLAYER_DRAFT`, `BOT_MODE_ASSEMBLE_WITH_HUMANS`, `BOT_MODE_OUTPOST` (`26`), `BOT_MODE_RUNE` (`7`), `ABILITY_TARGET_TEAM_BOTH`
- **Callbacks / HTTP / Debug**: `InstallDamageCallback`, `InstallCastCallback`, `InstallCourierDeathCallback`, `InstallRoshanDeathCallback`, `InstallChatCallback`, `CreateLocalHostHTTPRequestBotVM(sUrl)`, `DebugDrawLine`, `DebugDrawText`

### Undocumented `CDOTA_Bot_Script` / Ability Methods
- **Talents**: `bot:GetTalent(nSlot, nLevel)` (returns talent ability handle)
- **Path Actions**: `Action_MovePath(tWaypoints)`, `ActionPush_MovePath(tWaypoints)`, `ActionQueue_MovePath(tWaypoints)`, `ActionPush_Delay(fTime)`, `ActionQueue_Delay(fTime)`, plus `ActionPush_*` / `ActionQueue_*` variants of move/attack/cast/rune/item/drop/tree actions
- **Damage & Regeneration Queries**: `GetHealthRegenPerStr()`, `GetManaRegenPerInt()`, `IsSpeciallyUndeniable()`, `TimeSinceDamagedByHero(hHero)`, `TimeSinceDamagedByPlayer(nID)`, `TimeSinceDamagedByTower()`, `TimeSinceDamagedByCreep()`
- **Ability**: `hAbility:GetCooldown()` (base cooldown; documented scripts only listed `GetCooldownTimeRemaining()`)
