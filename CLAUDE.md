# Dota 2 Bot Scripts - Project Guide

## Project Overview

This is **dota2bot-OpenHyperAI** -- Lua/TypeScript bot scripts for Dota 2 custom lobbies, supporting **Patch 7.42** and **127 heroes**.

## Key Documentation

- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** -- Codebase architecture, file map, TypeScript-to-Lua pipeline, neutral/item/skill systems, common pitfalls
- **[docs/PATCH_UPDATE_GUIDE.md](docs/PATCH_UPDATE_GUIDE.md)** -- Step-by-step runbook for updating when a new Dota 2 patch releases
- **[docs/DOTA2_BOT_API_INTERNALS.md](docs/DOTA2_BOT_API_INTERNALS.md)** -- Undocumented `CDOTA_Bot_Script` Bot VM & Server VScript internals (all 32 `EDOTABotMode` slots, `VectorTargeting` `OrderType = 30`, `ALT_CASTABLE` traps, missing `ATTRIBUTE_ALL`)

**Read these docs first before making changes.**

## Common Tasks

### Check for New Patches

1. Fetch `https://www.dota2.com/datafeed/patchnoteslist?language=english`
2. Compare latest version against "Last updated for" in `docs/PATCH_UPDATE_GUIDE.md`
3. If newer patch exists, follow the update process below

### Patch Update Workflow

1. Read `docs/PATCH_UPDATE_GUIDE.md` first
2. Extract authoritative KV data directly from the local Dota 2 VPK (`pak01_dir.vpk` via `Source2Viewer-CLI`) when `d2vpkr` lags behind live patches, and fetch `https://www.dota2.com/datafeed/patchnotes?version=X.XX&language=english`
3. **Categorize changes**: STRUCTURAL (code changes) vs NUMBER-ONLY (game API handles) vs TALENT SWAPS
4. **Always verify ability/item internal names against VPK (`npc_abilities.txt`, `items.txt`, `neutral_items.txt`, `shops.txt`, `npc_heroes.txt`, `npc_units.txt`)** or Liquipedia -- patch note summaries alone omit/alter internal names
5. Update in order: shop items -> neutrals (4 tiers + enchantments) & XP table -> map coordinates/entities -> hero builds/abilities/minions -> `ConsiderItemDesire` item actives -> TypeScript build
6. **Always update `.ts` sources** for TS-generated Lua files, run `npm run build:lua`, and restore untouched `.lua` files if TSTL only changed CRLF/LF line endings

### Vector-Targeted Abilities

- Bot VM cannot issue vector endpoints natively. `bots/FretBots/VectorTargeting.lua` (loaded in Server VScript by `bots/FretBots.lua` and `bots/Buff/Buff.lua`) intercepts fake-client casts via `SetExecuteOrderFilter` and injects `DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION` (`30`) before cast execution.
- See `docs/DOTA2_BOT_API_INTERNALS.md` Section 3 before adding or modifying vector-targeted abilities.

### Add a New Hero

1. Copy a similar existing hero from `bots/BotLib/` as template
2. Add to `bots/FretBots/HeroNames.lua`, `typescript/bots/FunLib/aba_hero_roles_map.ts` -> `.lua`, `bots/FunLib/spell_list.lua`, `typescript/bots/FunLib/spell_prob_list.ts` -> `.lua`
3. See "New Heroes" section in `docs/PATCH_UPDATE_GUIDE.md`

### Verification Before Committing

1. Run `npm run build:lua` cleanly (0 TypeScript errors) and verify `git diff` touches only intended files
2. Validate all modified `.lua` files for syntax errors, dead/removed item/ability references, and localization parity
3. Smoke-test in local `dota2.exe` (`-novid -nosound`) AI vs AI match and check console output/logs for zero Lua script errors

## Important Rules

- **Use `GetItemComponents()` for upgrade item recipes** -- don't hardcode component arrays unless Valve's API returns wrong data
- **Use `sAbilityList[N]` references** when possible -- resilient to ability renames, and nil-guard optional abilities
- **Always update BOTH neutral item files** (`bots/Buff/NeutralItems.lua` AND `bots/FretBots/SettingsNeutralItemTable.lua`, 4 tiers in 7.42) and keep XP tables synchronized (`bots/Buff/Experience.lua` AND `bots/FretBots/AwardBonus.lua`, 66,600 XP at lvl 30 in 7.42)
- **Guard `ATTRIBUTE_ALL` numerically (`== 3`)** in Bot VM -- the global constant `ATTRIBUTE_ALL` does not exist
- **Never commit release version bumps (`version.ts`)** unless publishing a Workshop release (maintainer updates version via `npm run release`)
- **Test in-game** after structural/map/vector changes
