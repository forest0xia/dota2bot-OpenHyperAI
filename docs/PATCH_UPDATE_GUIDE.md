# Dota 2 Bot Patch Update Guide

This is a step-by-step runbook for quickly updating the bot scripts when Valve releases a new Dota 2 patch. Designed to be followed by a developer or AI assistant without needing to re-read the entire codebase.

---

## Quick Start

Given a new patch URL like `https://www.dota2.com/patches/7.42`:

```
1. Fetch patch notes + d2vpkr data       (5 min, parallel)
2. Diff items: added/removed/changed      (5 min)
3. Update aba_item.lua                     (10 min)
4. Update hero item builds                 (15 min)
5. Handle ability renames/reworks          (15 min)
6. Update neutral items                    (10 min)
7. Add active-use logic for new items      (10 min)
8. Verify & commit                         (5 min)
```

---

## Phase 1: Data Gathering (Parallel)

Run all of these simultaneously:

### 1A. Fetch Patch Notes
```
URL: https://www.dota2.com/patches/X.XX
Extract: item changes, ability changes, new heroes, mechanic changes
```

### 1B. Fetch Current Shop Items (Source of Truth for item names)
```
URL: https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/shops.txt
Compare against: bots/FunLib/aba_item.lua sBasicItems/sSeniorItems/sTopItems
Output: list of ADDED items, REMOVED items
```

### 1C. Fetch Current Neutral Items (Source of Truth for neutral tiers)
```
URL: https://raw.githubusercontent.com/dotabuff/d2vpkr/master/dota/scripts/npc/neutral_items.txt
Compare against: bots/Buff/NeutralItems.lua + bots/FretBots/SettingsNeutralItemTable.lua
Output: list of new/removed/moved neutrals per tier
```

### 1D. Verify Ability Names via Liquipedia
For each hero with major ability changes:
```
URL: https://liquipedia.net/dota2/HERO_NAME
Check: exact Q/W/E/R names, whether abilities are learnable vs innate
WARNING: Patch note summaries can be WRONG. Always cross-check.
```

---

## Phase 2: Item Updates

### 2A. Core Item File (`bots/FunLib/aba_item.lua`)

**Add new basic items** to `sBasicItems` (~line 150-197):
```lua
'item_new_component_name',
```

**Add new upgrade items** to `sSeniorItems` (~line 199-234) or `sTopItems` (~line 236-320):
```lua
'item_new_upgrade_name',
```

**Add component definitions** (~line 600-830):
```lua
Item["item_new_upgrade"] = GetItemComponents('item_new_upgrade')[1]
```
> NEVER hardcode component arrays for basic items. NEVER override GetItemComponents unless the API is broken for that specific item.

**Comment out removed items** (don't delete -- keep for reference):
```lua
-- Item['item_removed_name'] removed from game in 7.XX
```

**Update sSellList** if new components replace old ones:
```lua
'item_new_component', 'item_old_component',
```

### 2B. Hero Item Builds (`bots/BotLib/hero_*.lua`)

```bash
# Find all heroes referencing a removed item
grep -rn "item_removed_name" bots/BotLib/
```

Replace with role-appropriate alternatives:
| Hero Role | Good Replacements |
|-----------|-------------------|
| Tank/Offlane | item_pipe, item_crimson_guard, item_heart |
| Caster/Magic | item_bloodstone, item_octarine_core |
| Support | item_glimmer_cape, item_solar_crest |
| Carry/Physical | item_butterfly, item_satanic, item_manta |

Add new items to heroes where they fit (check Liquipedia for item stats to decide):
```lua
sRoleItemsBuyList['pos_X'] = {
    ...,
    "item_new_item",--
    ...,
}
```

### 2C. Support Files

```bash
# Check fallback builds
grep -rn "item_removed_name" bots/FunLib/advanced_item_strategy.lua

# Check map logic
grep -rn "item_removed_name" bots/FunLib/aba_site.lua
```

---

## Phase 3: Ability Updates

### 3A. Find Broken Ability References

```bash
# For each renamed ability:
grep -rn "old_ability_name" bots/BotLib/ bots/FunLib/spell_list.lua bots/FunLib/spell_prob_list.lua bots/FunLib/rubick_hero/
```

### 3B. Handle Renames

Update all 4 locations:
1. `bots/BotLib/hero_[name].lua` -- `GetAbilityByName` calls
2. `bots/FunLib/spell_list.lua` -- ability weight entries
3. `bots/FunLib/spell_prob_list.lua` -- probability entries
4. `bots/FunLib/rubick_hero/[name].lua` -- Rubick spell-steal

Use fallback chains when the exact new name is uncertain:
```lua
local ability = bot:GetAbilityByName('new_name')
                or bot:GetAbilityByName('alt_name')
                or (sAbilityList[N] and bot:GetAbilityByName(sAbilityList[N]))
```

### 3C. Handle Innate Transitions

If a previously-learnable ability became innate (verify on Liquipedia!):

1. **Update build order** -- remove references to the now-missing index:
```lua
-- Before (3 learnable + ult): {1,3,1,2,1,6,1,2,2,2,6,3,3,3,6}
-- After  (2 learnable + ult): {1,2,1,2,1,6,1,2,2,2,6,1,1,1,6}
```

2. **Nil-guard the ability variable**:
```lua
local abilityE = sAbilityList[3] and bot:GetAbilityByName(sAbilityList[3]) or nil
```

3. **Guard the casting block**:
```lua
if abilityE ~= nil then
    castEDesire = X.ConsiderE()
    if castEDesire > 0 then ... end
end
```

4. **Guard the Consider function**:
```lua
function X.ConsiderE()
    if abilityE == nil or not abilityE:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE
    end
    ...
end
```

### 3D. Handle Targeting Changes

If ability changed from unit-target to point-target (or vice versa):
```lua
-- Old: bot:Action_UseAbilityOnEntity(ability, target)
-- New: bot:Action_UseAbilityOnLocation(ability, location)
```

Rewrite the corresponding `Consider` function to return the correct target type.

---

## Phase 4: Neutral Item Updates

### 4A. Update Buff Mode (`bots/Buff/NeutralItems.lua`)

Replace the 5 tier arrays to match d2vpkr `neutral_items.txt`:
```lua
local Tier1NeutralItems = {
    --[[Display Name]]  "item_internal_name",
    ...
}
```

### 4B. Update FretBots Mode (`bots/FretBots/SettingsNeutralItemTable.lua`)

Add new items with role weights:
```lua
{name="item_xxx", tier=N, ranged=1, melee=1, roles={1,1,1,1,1}, realName="Display Name"},
```

Role weight guidelines:
- Physical carry item: `ranged=1, melee=3, roles={3,3,1,0,0}`
- Magic/support item: `ranged=1, melee=1, roles={1,1,1,3,3}`
- Tank/offlane item: `ranged=0, melee=2, roles={1,1,3,1,1}`
- Universal: `ranged=1, melee=1, roles={1,1,1,1,1}`

### 4C. Add Active-Use Logic (`bots/ability_item_usage_generic.lua`)

Only for neutral items with ACTIVE abilities. Check Liquipedia for each new neutral item.

```lua
X.ConsiderItemDesire["item_xxx"] = function(hItem)
    local sCastType = 'none'  -- or 'unit' or 'ground'
    -- ... logic ...
    return BOT_ACTION_DESIRE_HIGH, target, sCastType, nil
end
```

---

## Phase 5: New Heroes

If the patch adds a new hero:

1. **Create** `bots/BotLib/hero_[name].lua` -- copy an existing hero with similar role as template
2. **Add to** `bots/FretBots/HeroNames.lua`:
```lua
npc_dota_hero_[name] = 'Display Name',
```
3. **Add to** `bots/FunLib/aba_hero_roles_map.lua`:
```lua
[HeroName.NewHero] = {carry=X, disabler=X, durable=X, ...}
```
4. **Add abilities to** `bots/FunLib/spell_list.lua`

---

## Phase 6: Map / Mechanic Changes

Some patches change map positions or game mechanics. Watch for:

### Roshan / Tormentor Position Swaps
Patch notes like "Roshan's pit preference has switched" or "Tormentor's spawn preference has switched" mean the **day/night position mapping** inverted.

Files to update:
- **`FunLib/jmz_func.lua`**: `GetCurrentRoshanLocation()`, `GetTormentorLocation()`, `GetTormentorWaitingLocation()` -- swap the day/night return values
- **`FunLib/aba_site.lua`**: Static `roshan` vector (~line 224) -- update to new default position

The coordinate vectors themselves don't change, only which time-of-day maps to which location.

### Other Map Changes
- Rune positions: `FunLib/aba_site.lua` `top_power_rune` / `bot_power_rune`
- Wisdom rune positions: `FunLib/utils.lua` `WisdomRunes`
- Fountain positions: `FunLib/jmz_func.lua` `RadiantFountain` / `DireFountain`
- Watchtower positions: `FunLib/aba_site.lua` `nWatchTower_1` / `nWatchTower_2`

### Timing Changes
- Neutral item tier timings: `Buff/NeutralItems.lua` and `FretBots/NeutralItems.lua`
- Siege creep timing: `mode_laning_generic.lua` or push modes
- Roshan respawn timing: `mode_roshan_generic.lua`

---

## CRITICAL: TypeScript Sources

Some Lua files are **generated from TypeScript** via TSTL. If you edit the Lua output without also editing the `.ts` source, your changes will be **overwritten** on the next TS build.

**Always check:** Does a `.ts` file exist at the same relative path under `typescript/bots/`?

Key TS-generated files that commonly need patch updates:
- `aba_site.ts` → `aba_site.lua` (map positions like Roshan location)
- `advanced_item_strategy.ts` → `advanced_item_strategy.lua` (fallback item builds)
- `spell_prob_list.ts` → `spell_prob_list.lua` (ability cast probabilities)
- `utils.ts` → `utils.lua` (Roshan/fountain coordinates)
- `aba_hero_roles_map.ts` → `aba_hero_roles_map.lua` (hero role scores for new heroes)

**Pure Lua files** (no TS source, edit directly): `jmz_func.lua`, `aba_item.lua`, `aba_skill.lua`, `spell_list.lua`, `ability_item_usage_generic.lua`, all `BotLib/hero_*.lua`, all `Buff/*.lua`, all `FretBots/*.lua`.

See `docs/ARCHITECTURE.md` Section 13 for the complete mapping table.

---

## Verification Checklist

Before committing:

- [ ] `grep` for any remaining references to removed items/abilities
- [ ] Every new item in `sTopItems` has a `GetItemComponents` entry
- [ ] Every new neutral item is in BOTH Buff and FretBots files
- [ ] Ability builds only reference indices that exist in the filtered `sAbilityList`
- [ ] No hardcoded component arrays for basic shop items
- [ ] Active items have `ConsiderItemDesire` functions

---

## Key Principle: Verify Before You Trust

Patch note summaries (from any source, including AI) can be wrong about:
- Whether an ability is learnable vs. innate
- Exact internal ability names
- Whether items have actives or are passive-only

**Always cross-reference with Liquipedia and d2vpkr before making changes.**
When uncertain, use dynamic `sAbilityList[N]` references with name fallback chains.
