# Dota 2 Bot Architecture Guide

This document is the single source of truth for understanding, maintaining, and updating the dota2bot-OpenHyperAI codebase. It is designed so that a developer (or AI assistant) can quickly make targeted updates without re-scanning the entire repository.

Last verified against: **Patch 7.41a** (March 2026)

---

## Table of Contents

1. [Directory Structure](#1-directory-structure)
2. [Naming Conventions](#2-naming-conventions)
3. [Hero Bot Files](#3-hero-bot-files)
4. [Skill / Ability System](#4-skill--ability-system)
5. [Item System](#5-item-system)
6. [Neutral Item System](#6-neutral-item-system)
7. [Item Active-Use System](#7-item-active-use-system)
8. [Bot Behavior Modes](#8-bot-behavior-modes)
9. [FretBots (Enhanced Difficulty)](#9-fretbots-enhanced-difficulty)
10. [Customization System](#10-customization-system)
11. [Patch Update Checklist](#11-patch-update-checklist)
12. [External Data Sources](#12-external-data-sources)
13. [Common Pitfalls](#13-common-pitfalls)

---

## 1. Directory Structure

```
vscripts/
├── bots/                              # Main bot logic (Workshop folder 3246316298)
│   ├── bot_generic.lua                # Bot initialization entry point
│   ├── hero_selection.lua             # Hero picking/banning logic
│   ├── item_purchase_generic.lua      # Item purchasing state machine
│   ├── ability_item_usage_generic.lua # Ability casting + item active-use logic (~8000 lines)
│   ├── mode_*_generic.lua             # Behavior modes (laning, farm, push, retreat, etc.)
│   │
│   ├── BotLib/                        # all hero-specific files (one per hero)
│   │   ├── hero_abaddon.lua
│   │   ├── hero_axe.lua
│   │   └── ... (hero_[internal_name].lua)
│   │
│   ├── FunLib/                        # Core utility libraries
│   │   ├── jmz_func.lua              # Main aggregator (loads all sub-libraries as J.*)
│   │   ├── aba_item.lua              # Item lists, components, sell/buy logic
│   │   ├── aba_skill.lua             # Ability slot reading, skill build system
│   │   ├── aba_role.lua              # Role/position assignment (pos 1-5)
│   │   ├── aba_hero_roles_map.lua    # Hero role scores (carry/support/initiator/etc.)
│   │   ├── aba_site.lua              # Map positioning, farm timing, location logic
│   │   ├── spell_list.lua            # Ability weight database (all heroes)
│   │   ├── spell_prob_list.lua       # Ability probability weights
│   │   ├── advanced_item_strategy.lua # Fallback item builds by position
│   │   ├── aba_chat.lua              # Chatbot + item/hero name localization
│   │   ├── aba_minion.lua            # Minion/summon control
│   │   ├── aba_special_units.lua     # Special unit interactions
│   │   ├── morphling_utility.lua     # Morphling replicate helper
│   │   └── rubick_hero/              # Rubick spell-steal hero-specific logic
│   │       ├── beastmaster.lua
│   │       └── ...
│   │
│   ├── Buff/                          # Buff mode (enhanced neutral items)
│   │   └── NeutralItems.lua           # Neutral item tier lists + distribution logic
│   │
│   ├── FretBots/                      # Enhanced difficulty mode
│   │   ├── SettingsDefault.lua        # Default difficulty settings
│   │   ├── SettingsNeutralItemTable.lua # Neutral item configs with role weights
│   │   ├── HeroNames.lua             # Hero name localizations (en/zh/ru/ja)
│   │   ├── NeutralItems.lua          # Neutral item distribution timing/logic
│   │   └── matchups_data.lua         # Hero matchup database
│   │
│   ├── Customize/                     # User customization
│   │   ├── general.lua               # Global settings (bans, picks, difficulty)
│   │   └── hero/                     # Per-hero overrides
│   │       └── viper.lua             # Example
│   │
│   └── ts_libs/                       # TypeScript-generated constants
│       └── dota/heroes.lua           # HeroName enum
│
├── typescript/                        # TypeScript source (compiles to Lua)
├── game/                              # Valve default setup + permanent customization
└── docs/                              # Developer documentation (this file)
```

---

## 2. Naming Conventions

| Element          | Format                          | Example                              |
|------------------|---------------------------------|--------------------------------------|
| Hero internal    | `npc_dota_hero_[name]`          | `npc_dota_hero_crystal_maiden`       |
| Hero file        | `hero_[name].lua`               | `hero_crystal_maiden.lua`            |
| Ability          | `[hero]_[ability]`              | `crystal_maiden_crystal_nova`        |
| Item             | `item_[name]`                   | `item_black_king_bar`                |
| Modifier         | `modifier_[source]_[name]`      | `modifier_item_blink_dagger_cd`      |
| Talent           | `special_bonus_[type]_[value]`  | `special_bonus_hp_250`               |
| Position         | `pos_[1-5]`                     | `pos_1` (carry), `pos_5` (hard sup)  |

**Important:** These names are set by Valve and can change between patches. Always verify against [d2vpkr](https://github.com/dotabuff/d2vpkr) or in-game.

---

## 3. Hero Bot Files

Each file in `BotLib/hero_[name].lua` follows this exact structure:

```lua
-- 1. IMPORTS
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local sAbilityList = J.Skill.GetAbilityList(bot)   -- Dynamic slot reading

-- 2. TALENT BUILD
local tTalentTreeList = {
    ['t25'] = {0, 10},   -- 0=left talent, 10=right talent
    ['t20'] = {10, 0},
    ['t15'] = {0, 10},
    ['t10'] = {10, 0},
}

-- 3. ABILITY BUILD ORDER
local tAllAbilityBuildList = {
    {1,2,1,2,1,6,1,2,2,2,6,3,3,3,6},  -- Indices into sAbilityList
}
-- 1-5 = regular abilities (filtered, no innates), 6 = ultimate (always)

-- 4. ITEM BUILDS BY POSITION
sRoleItemsBuyList['pos_1'] = { "item_tango", "item_phase_boots", ... }
sRoleItemsBuyList['pos_2'] = { ... }
-- ... pos_3 through pos_5

-- 5. SELL LIST
X['sSellList'] = { "item_quelling_blade", ... }

-- 6. ABILITY REFERENCES
local abilityQ = bot:GetAbilityByName('hero_ability_q')
-- or: local abilityQ = bot:GetAbilityByName(sAbilityList[1])

-- 7. SKILLS COMPLEMENT (ability casting logic)
function X.SkillsComplement()
    -- Priority-ordered ability usage
end

-- 8. CONSIDER FUNCTIONS (one per ability)
function X.ConsiderQ()
    return desire, target
end
```

### Key Rules

- **`tAllAbilityBuildList` indices are NOT slot numbers.** They index into the filtered `sAbilityList` built by `aba_skill.lua`. Index 1 = first non-innate ability, 6 = ultimate.
- **If an ability becomes innate** (non-learnable) in a patch, it is filtered out of `sAbilityList` and all higher indices shift down. The build order MUST be updated.
- **Use `sAbilityList[N]` for ability references** when possible (resilient to renames). Only use hardcoded `GetAbilityByName('hero_ability_name')` when you need to check specific modifiers or special logic.
- **When unsure about an ability name after a rename**, chain fallbacks:
  ```lua
  local ability = bot:GetAbilityByName('new_name')
                  or bot:GetAbilityByName('old_name')
                  or (sAbilityList[N] and bot:GetAbilityByName(sAbilityList[N]))
  ```

---

## 4. Skill / Ability System

**Core file:** `FunLib/aba_skill.lua`

### GetAbilityList(bot) -- Dynamic Slot Reader

1. Iterates slots 0-10 via `bot:GetAbilityInSlot(slot)`
2. Filters out:
   - `generic_hidden` (placeholder slots) -- except inserts as placeholder if not slot 0
   - Abilities with `DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE` AND `IsHidden()` (innates)
   - Talent abilities (slots 10+)
3. Places ultimate abilities at index **6** in the returned `sAbilityList`
4. Regular abilities get sequential indices 1, 2, 3, ...

### GetSkillList() -- Build Order Resolver

Takes `sAbilityList` + `nAbilityBuildList` (the `{1,2,1,...}` array) and produces the final skill-up sequence. References `sAbilityList[nAbilityBuildList[i]]` to get the actual ability name.

### Implications for Patch Updates

- If an ability **moves from learnable to innate**: the ability disappears from `sAbilityList`, indices shift, and the build order breaks. You must update `tAllAbilityBuildList` to only reference existing indices.
- If an ability is **renamed**: `GetAbilityByName('old_name')` returns nil. Update all references.
- If an ability's **targeting type changes** (e.g., unit-target to point-target): Update the `Action_UseAbilityOnEntity` / `Action_UseAbilityOnLocation` calls.

### Modifier files

- `FunLib/spell_list.lua` -- Ability weight database keyed by `npc_dota_hero_[name]`. Used for generic ability evaluation.
- `FunLib/spell_prob_list.lua` -- Probability weights for ability casting decisions.
- `FunLib/rubick_hero/[hero].lua` -- Rubick spell-steal logic per hero. Must be updated if ability names change.

---

## 5. Item System

**Core file:** `FunLib/aba_item.lua` (~830 lines)

### Item Lists (order of importance)

| List Name        | Purpose                                    | Line Range |
|------------------|--------------------------------------------|------------|
| `sBasicItems`    | Basic shop components (branches, boots...) | ~150-197   |
| `sSeniorItems`   | Mid-tier items (blink, arcane boots...)    | ~199-234   |
| `sTopItems`      | All finished items the bot can buy         | ~236-320   |
| `sSellList`      | Item pairs: "if you buy X, sell Y"         | ~391-450   |
| `sNeedDebugItemList` | Items that need special use-logic      | ~18-155    |
| `sNotSellItemList` | Items the bot should never sell           | ~486-530   |
| `tEarlyItem`     | Early-game consumables/stat items          | ~322-345   |

### Item Component System

Each item has a component definition:
```lua
Item['item_bfury'] = GetItemComponents('item_bfury')[1]
```

- `GetItemComponents()` is a **Valve API** that returns the current game's recipe.
- **Use this for all upgrade items.** It auto-updates when the game client patches.
- Only hardcode component arrays when the API returns wrong data (rare): `item_phase_boots`, `item_power_treads`, `item_ultimate_scepter`.
- **NEVER** hardcode component arrays for basic shop items (items with no sub-components like `item_splintmail`, `item_shawl`). They are leaf nodes.

### Item Purchase Flow

`item_purchase_generic.lua`:
1. Loads hero's `sBuyList` from the BotLib file
2. Processes in reverse order (highest priority first)
3. Checks if the bot already owns the item
4. Breaks items into components via the component definitions
5. Purchases components from the correct shop (main/secret/side)
6. Auto-sells items from `sSellList` when inventory is full

### Self-Defined Items ("Outfits")

Some heroes use virtual item names like `item_sven_outfit` that map to real items via `tDefineItemRealName` (~line 842+). These represent early-game item bundles.

---

## 6. Neutral Item System

Neutral items are handled by **two separate systems** depending on the game mode.

### Buff Mode (`Buff/NeutralItems.lua`)

- Defines `Tier1NeutralItems` through `Tier5NeutralItems` arrays
- Items are distributed to bots based on game time
- Simple random selection from the tier pool
- Includes enhancement items (enchantments) per tier

### FretBots Mode (`FretBots/SettingsNeutralItemTable.lua` + `FretBots/NeutralItems.lua`)

- More sophisticated role-aware item distribution
- Each item has: `name`, `tier`, `ranged` weight, `melee` weight, `roles` array `{pos1,pos2,pos3,pos4,pos5}`
- `GetBotDesireForItem()` scores items based on attack type + role + tier
- Timing system with difficulty scaling and variance

### Updating Neutral Items

When Valve rotates the neutral item pool:
1. Check `https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/neutral_items.txt` for the current tier lists
2. Update both `Buff/NeutralItems.lua` and `FretBots/SettingsNeutralItemTable.lua`
3. Comment out removed items (keep for reference), add new ones
4. Items that moved tiers: remove from old tier, add to new tier
5. For FretBots, assign sensible role weights based on item type:
   - Physical damage: `roles={3,3,1,0,0}` (carry/mid)
   - Magic/support: `roles={1,1,1,3,3}` (support)
   - Tank: `roles={1,1,3,1,1}` (offlane)
   - Universal: `roles={1,1,1,1,1}`

---

## 7. Item Active-Use System

**Core file:** `ability_item_usage_generic.lua` (~8000 lines)

Every item with an active ability has a `ConsiderItemDesire` function:

```lua
X.ConsiderItemDesire["item_name"] = function(hItem)
    -- Return: desire, target, castType, motive
    -- desire: BOT_ACTION_DESIRE_NONE / _MODERATE / _HIGH
    -- castType: 'unit' | 'ground' | 'none' (self-cast)
    return BOT_ACTION_DESIRE_NONE
end
```

### Adding a New Active Item

1. Find a similar existing item as a template
2. Add the function near similar items in the file
3. Common patterns:
   - **Self-cast buff** (BKB, Mask of Madness): `sCastType = 'none'`, check combat conditions
   - **Unit-target ally** (Glimmer Cape, Mekansm): iterate `hAllyList`, check HP/danger
   - **Unit-target enemy** (Orchid, Abyssal): check `botTarget` validity and range
   - **Ground-target AoE** (Pipe, Shiva's): check enemy count in range
   - **Urn-like** (heal or damage): check charges, target ally for heal / enemy for damage

### Helper Functions Used

- `J.GetNearbyHeroes(bot, range, isEnemy, mode)` -- Get heroes in range
- `J.IsValid(unit)` / `J.IsValidHero(unit)` -- Validity checks
- `J.IsInRange(unit1, unit2, range)` -- Distance check
- `J.CanCastOnNonMagicImmune(unit)` / `J.CanCastOnMagicImmune(unit)` -- Immunity checks
- `J.IsRetreating(bot)` / `J.IsGoingOnSomeone(bot)` -- Behavior checks
- `J.GetHP(unit)` / `J.GetMP(unit)` -- Health/mana percentage (0-1)
- `J.IsDisabled(unit)` -- Stun/root/silence check
- `bot:HasModifier('modifier_name')` -- Buff/debuff check

---

## 8. Bot Behavior Modes

Located in `mode_*_generic.lua` files:

| File                         | Purpose                        |
|------------------------------|--------------------------------|
| `mode_laning_generic.lua`    | Early laning, last-hitting     |
| `mode_farm_generic.lua`      | Jungle/creep farming           |
| `mode_roam_generic.lua`      | Solo ganking                   |
| `mode_team_roam_generic.lua` | Group ganking                  |
| `mode_attack_generic.lua`    | General attacking              |
| `mode_retreat_generic.lua`   | Defensive retreat              |
| `mode_defend_tower_*.lua`    | Tower defense (top/mid/bot)    |
| `mode_push_tower_*.lua`      | Tower pushing                  |
| `mode_roshan_generic.lua`    | Roshan hunt                    |
| `mode_rune_generic.lua`      | Rune pickup                    |
| `mode_ward_generic.lua`      | Ward placement                 |
| `mode_outpost_generic.lua`   | Outpost control                |

These files generally don't need updating for item/ability patches, only for game mechanic changes (e.g., timing changes, map changes).

---

## 9. FretBots (Enhanced Difficulty)

FretBots mode gives bots unfair advantages (extra gold, XP, stats) for challenging gameplay.

Key files:
- `FretBots/SettingsDefault.lua` -- Bonus values (gold, XP multipliers)
- `FretBots/HeroNames.lua` -- Hero name localizations for chat
- `FretBots/matchups_data.lua` -- Hero matchup database (14876 lines)
- `FretBots/NeutralItems.lua` -- Item distribution with timing/difficulty scaling

---

## 10. Customization System

### General Settings (`Customize/general.lua`)
```lua
Customize = {
    Enable = true,
    Localization = "en",
    Ban = {},
    Radiant_Heros = {'Random', 'Random', 'Random', 'Random', 'Random'},
    Dire_Heros = {'Random', 'Random', 'Random', 'Random', 'Random'},
    Allow_Repeated_Heroes = false,
}
```

### Per-Hero Overrides (`Customize/hero/[name].lua`)
```lua
return {
    Enable = true,
    AbilityUpgrade = {1,2,1,2,1,6,...},  -- Custom skill build
    Talent = {t10={0,10}, ...},           -- Custom talents
    PurchaseList = {"item_...", ...},      -- Custom item build
    SellList = {"item_...", ...},          -- Custom sell list
}
```

Loaded by `J.SetUserHeroInit()` in each hero file. Permanent customization goes in `game/Customize/` to survive workshop updates.

---

## 11. Patch Update Checklist

When a new Dota 2 patch drops, follow these steps in order:

### Step 1: Gather Data (parallel)

- [ ] Fetch patch notes from `https://www.dota2.com/patches/X.XX`
- [ ] Fetch current shop items from `https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/shops.txt`
- [ ] Fetch current neutral items from `https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/neutral_items.txt`
- [ ] Cross-check ability/item names against **Liquipedia** (`https://liquipedia.net/dota2/HERO_NAME`) -- patch note summaries can be inaccurate about exact internal names

### Step 2: Update Shop Items (`FunLib/aba_item.lua`)

- [ ] `sBasicItems` list: Add new basic components
- [ ] `sSeniorItems` list: Add/remove mid-tier items
- [ ] `sTopItems` list: Add all new purchasable items
- [ ] Component definitions: Add `GetItemComponents('item_name')[1]` for new upgrade items
- [ ] `sSellList`: Add sell-pair entries for new components replacing old ones
- [ ] Comment out (don't delete) removed items with `-- removed from game` note

### Step 3: Update Hero Item Builds (`BotLib/hero_*.lua`)

- [ ] `grep` for removed item names across all BotLib files
- [ ] Replace with appropriate alternatives based on hero role
- [ ] Add new items to suitable hero builds

### Step 4: Handle Ability Changes

- [ ] **Renames**: `grep` for old `GetAbilityByName('old_name')` calls, update to new names
- [ ] **Replaced abilities**: Rewrite casting logic if targeting changed
- [ ] **Innate transitions**: If a previously-learnable ability became innate:
  - Update `tAllAbilityBuildList` (remove references to the now-missing index)
  - Add nil guards for the ability variable
  - Comment out the Consider function for that ability
- [ ] Update `spell_list.lua`, `spell_prob_list.lua`, `rubick_hero/*.lua`
- [ ] **Always verify against Liquipedia** -- patch note summaries can be wrong

### Step 5: Add Item Active-Use Logic (`ability_item_usage_generic.lua`)

- [ ] For each new item with an ACTIVE ability, add a `ConsiderItemDesire` function
- [ ] Check Liquipedia for targeting type (unit/ground/self-cast)
- [ ] Copy a similar existing item as a template
- [ ] Passive-only items don't need logic here

### Step 6: Update Neutral Items

- [ ] `Buff/NeutralItems.lua`: Update all 5 tier arrays
- [ ] `FretBots/SettingsNeutralItemTable.lua`: Update with role weights
- [ ] Add `ConsiderItemDesire` for new neutral items with active abilities
- [ ] Comment out removed neutrals, add new ones, move items between tiers

### Step 7: Update Support Files

- [ ] `FunLib/advanced_item_strategy.lua`: Replace removed items in fallback builds
- [ ] `FunLib/aba_site.lua`: Update `HasItem()` checks for removed items
- [ ] `FretBots/HeroNames.lua`: Add new heroes (if any)
- [ ] `FunLib/aba_hero_roles_map.lua`: Add role scores for new heroes

### Step 8: New Heroes (if any)

- [ ] Create `BotLib/hero_[name].lua` following existing hero file template
- [ ] Add to `FretBots/HeroNames.lua`
- [ ] Add to `FunLib/aba_hero_roles_map.lua`
- [ ] Add abilities to `spell_list.lua`

---

## 12. External Data Sources

| Source | URL | Purpose |
|--------|-----|---------|
| **d2vpkr shops.txt** | `https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/shops.txt` | Authoritative item internal names |
| **d2vpkr neutral_items.txt** | `https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/neutral_items.txt` | Current neutral item pool by tier |
| **d2vpkr npc_heroes.txt** | `https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/npc_heroes.txt` | Hero ability slot definitions |
| **Liquipedia** | `https://liquipedia.net/dota2/HERO_NAME` | Ability details, targeting, descriptions |
| **Official patch notes** | `https://www.dota2.com/patches/X.XX` | Patch change summary |
| **Valve Bot API docs** | `https://docs.moddota.com/lua_bots/` | Bot scripting API reference |

### Trust Hierarchy

1. **d2vpkr** (extracted game data) > **Liquipedia** (community-maintained) > **patch notes** (summaries, can have errors)
2. **Always verify ability names** before editing code. Patch note summaries (even AI-generated ones) can be wrong about whether an ability is innate vs. learnable, or about exact internal names.
3. When in doubt, use **dynamic `sAbilityList[N]` references** instead of hardcoded ability names.

---

## 13. Common Pitfalls

### 1. Hardcoding component arrays for basic items
**Wrong:** `Item['item_splintmail'] = { 'item_chainmail', 'item_blades_of_attack' }`
**Right:** Just add `item_splintmail` to `sBasicItems`. It's a leaf item with no sub-components.

### 2. Overriding GetItemComponents with hardcoded arrays
`GetItemComponents()` is a game API that returns correct data once the client updates. Only hardcode when the API is known to return wrong data (very rare).

### 3. Trusting patch note summaries for ability names
Patch notes use display names ("Summon Razorback"), but the code needs internal names (`beastmaster_call_of_the_wild_razorback` or `beastmaster_summon_razorback`). These can differ. Always verify on Liquipedia or d2vpkr.

### 4. Forgetting to update multiple files for ability renames
An ability rename requires updates in:
- `BotLib/hero_[name].lua` (GetAbilityByName + Consider function)
- `FunLib/spell_list.lua` (ability weights)
- `FunLib/spell_prob_list.lua` (probability weights)
- `FunLib/rubick_hero/[name].lua` (Rubick spell-steal logic)

### 5. Assuming innate = removed
Innate abilities are NOT removed. They still exist in the game but are `NOT_LEARNABLE`. They are filtered out of `sAbilityList` by `aba_skill.lua`. The ability can still apply modifiers that other code checks for (`bot:HasModifier(...)`).

### 6. Not nil-guarding ability references
When referencing `sAbilityList[N]` where N might not exist (because an ability became innate), always guard:
```lua
local abilityE = sAbilityList[3] and bot:GetAbilityByName(sAbilityList[3]) or nil
if abilityE ~= nil then ... end
```

### 7. Editing FretBots but not Buff (or vice versa)
Neutral items exist in TWO files. Always update both `Buff/NeutralItems.lua` AND `FretBots/SettingsNeutralItemTable.lua`.

### 8. Adding items to sTopItems but not GetItemComponents
Every item in `sTopItems` that is an upgrade item needs a corresponding `GetItemComponents` entry, or the purchase system won't know how to buy it.
