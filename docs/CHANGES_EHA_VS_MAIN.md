# Branch comparison: `eha` vs `main`

Full audit of every change on `eha` relative to `main` (`git diff main...eha`, 25 files,
~1167 insertions / ~623 deletions). Each entry lists **what changed**, the **files**, the
**difficulty impact**, and a **verdict** (does it make the bots stronger, weaker, or is it
neutral/cosmetic). Anything that changes or risks breaking bot *behavior* is flagged.

Commits included: `d822633 danger aoe zones`, `ea38b84 excessive healing`,
`2b27caf ru locale`, `2b0a67b remove human-related giveaway + plan`,
`8176216 power spikes lead to push`, `f7b86a1 improves '3-5'`,
`f640216 help mid if 2+ allies pushing`, `11266b7 difficulty improvements 6-8`,
`5ba4575 wards and target selection`, `4635422 suppress farm in late game`.

---

## Summary table

| # | Change | Files | Verdict |
|---|--------|-------|---------|
| 1 | Coordinated focus-fire target selection | `override_generic/mode_attack_generic.lua`, `jmz_func.lua` | 🟢 Stronger |
| 2 | Kill-commitment signal (dive disabled low-HP targets) | `mode_attack_generic.lua`, `jmz_func.lua`, `utils.lua`, `bots.d.ts` | 🟢 Stronger |
| 3 | Anti-juke: break off un-finishable solo chase | `mode_retreat_generic.lua`, `jmz_func.lua` | 🟢 Stronger |
| 4 | Dangerous-AoE avoidance (retreat / roam) | `jmz_func.lua`, `mode_retreat_generic.lua`, `mode_team_roam_generic.lua` | 🟢 Stronger |
| 5 | Pre-emptive BKB vs channeled ults | `jmz_func.lua`, `ability_item_usage_generic.lua` | 🟢 Stronger |
| 6 | Level power-spike laning aggression (lvl 2/3/6) | `mode_laning_generic.lua` | 🟢 Stronger |
| 7 | Push when enemy key ult on cooldown | `utils.lua`, `aba_push.*` | 🟢 Stronger |
| 8 | Remove human "giveaway" push delay | `aba_push.*` | 🟢 Stronger |
| 9 | Push coordination: force-mid on wipe / converge mid | `aba_push.*` | 🟢 Stronger |
| 10 | Mid-lane push bias in mid/late game | `aba_push.*` | 🟢 Mild stronger |
| 11 | Late-game priority ladder (farm off / ancient / push floor) | `mode_farm_generic.lua`, `aba_defend.*`, `aba_push.*` | 🟢 Stronger |
| 12 | Base-siege emergency buyback | `ability_item_usage_generic.lua` | 🟢 Stronger (minor risk) |
| 13 | Neutral camp stacking (supports) | `aba_site.*`, `mode_farm_generic.lua` | 🟢 Stronger |
| 14 | Ward overhaul: dewarding + territory-aware placement | `mode_ward_generic.lua`, `aba_ward_utility.lua` | 🟢 Stronger |
| 15 | Better lane sustain: buy regen longer, use tango/bottle earlier | `item_purchase_generic.lua`, `ability_item_usage_generic.lua` | 🟢 Stronger (minor gold cost) |
| 16 | Heal to higher HP before re-engaging lane | `mode_retreat_generic.lua` | 🟡 Trade-off |
| 17 | Ignore dangerous no-bounty summons (bear, golem, tombstone, brewlings); prioritize Undying zombies | `aba_special_units.lua` | 🟡 Mixed |
| 18 | All bots grab nearest bounty rune at start | `mode_rune_generic.lua` | 🟡 Mild regression risk |
| 19 | Default locale → Russian, English flavor/info text removed | `Customize/general.lua`, `localization.lua`, `aba_team_names.lua` | ⚪ Cosmetic (English chat regressed) |

No changes cause a hard crash / syntax break. The behavior-affecting risks are #16–#18
(trade-offs) and #19 (cosmetic English regression). Details below.

---

## 🟢 Clear strength gains

### 1. Coordinated focus-fire target selection
`override_generic/mode_attack_generic.lua` replaced its per-bot inline `enemyScore`
target loop with a single shared `J.GetBestTeamTarget(bot, nEnemyHeroes, tAllyHeroes)`.
The old hero multipliers (Sniper ×4, Lina ×3, Bristleback-facing, Enchantress, etc.) and
the "under-tower de-prioritization" moved into `J.ScoreEnemyTarget` /
`J.HeroTargetPriority` in `jmz_func.lua`. An invalid-target sentinel
(`J.SCORE_INVALID_TARGET`) ensures an all-untargetable enemy list falls through to the
weakest-unit fallback instead of picking a protected hero.

**Impact:** All five bots now converge on one target instead of splitting damage across
five. This is one of the biggest amateur-vs-strong gaps. **Verdict: 🟢 Stronger.**

### 2. Kill-commitment signal
`jmz_func.lua` adds `J.SetKillTarget` / `J.GetKillTarget` (3s shared signal via
`Utils.GameStates.killTarget`). `mode_attack_generic.lua` sets it when an enemy is
stunned/rooted and below 30% HP, and, at the top of `GetDesire`, commits with
`BOT_MODE_DESIRE_ABSOLUTE` to a signalled target within 1200 (unless the bot itself is
being focused by a tower).

**Impact:** Bots reliably finish kills on disabled low-HP heroes instead of drifting off.
**Verdict: 🟢 Stronger.**

### 3. Anti-juke chase break-off
`mode_retreat_generic.lua` now reads the per-bot `bot._chaseFatigue` (populated by the
focus-fire scorer): if not in a team fight, not clearly stronger, target chased 5s+, still
>50% HP, >900 units away, and no ally within 600 of the target → return
`BOT_MODE_DESIRE_HIGH` to disengage.

**Impact:** Stops solo bots tunnel-visioning a fleeing hero into the enemy fountain.
**Verdict: 🟢 Stronger.**

### 4. Dangerous-AoE avoidance
`jmz_func.lua` adds `J.IsLocationInDangerousAoe(loc)` with a `DANGER_AOE_ZONES` table
(Sniper shrapnel, Riki smoke, Warlock upheaval, Jakiro macropyre — thinker-modifier scan
with a debuff fallback). Wired into `mode_retreat_generic.lua` (retreat when standing in a
zone with enemies near or below 60% HP) and `mode_team_roam_generic.lua` (replaces the old
upheaval-only check).

**Impact:** Bots step out of persistent AoE instead of tanking it. **Verdict: 🟢 Stronger.**
*Caveat:* thinker-modifier names for upheaval/macropyre are noted as uncertain in-code and
should be verified in-game; if a name is wrong that zone simply isn't avoided (no crash).

### 5. Pre-emptive BKB
`jmz_func.lua` adds `J.ShouldPreActivateBKB` (checks nearby enemies channeling/casting a
dangerous ult: Black Hole, Fiend's Grip, Freezing Field, Death Ward, Epicenter,
Chronosphere, RP, Rain of Chaos, Supernova). `ability_item_usage_generic.lua` BKB logic
now pops BKB pre-emptively (`BOT_ACTION_DESIRE_HIGH`).

**Impact:** BKB used *before* the disable lands rather than after. **Verdict: 🟢 Stronger.**

### 6. Level power-spike laning aggression
`mode_laning_generic.lua` tracks levels 2/3/6 and, for 45s after hitting them, returns a
`0.6` laning desire when enemies are in range and HP > 40%.

**Impact:** Bots press their genuine power spikes. **Verdict: 🟢 Stronger.**

### 7. Push when enemy key ult is down
`utils.lua` adds `HasEnemyKeyAbilityOnCooldown()` (scans `ImportantSpells` per enemy).
`aba_push` adds +0.2 push desire when it's true and 3+ allies are grouped.

**Impact:** Bots exploit cooldown windows. **Verdict: 🟢 Stronger.**

### 8. Removed the human "giveaway" push delay
`aba_push` deleted the block that returned near-zero push desire before 16 min whenever a
human was on the enemy team.

**Impact:** Bots no longer hand humans a free early game — they push on merit.
**Verdict: 🟢 Stronger (harder for human opponents).**

### 9. Push coordination
`aba_push` adds two early returns in `GetPushDesireHelper`: (a) all enemies dead + 4+
allies alive + avg level ≥4 → force mid at `0.9`, sidelanes `VeryLow`; (b) post-laning and
not outnumbered with 2+ allies already near mid front → converge mid at `0.82`.

**Impact:** The team collapses onto one lane on a wipe instead of scattering.
**Verdict: 🟢 Stronger.**

### 10. Mid bias in `WhichLaneToPush`
After the laning phase, `midLaneScore *= 0.7` (lower score = more attractive).

**Impact:** Prefers the primary win-condition lane. **Verdict: 🟢 Mild stronger** (slight
risk of ignoring a genuinely weaker sidelane, but tier-based scoring still dominates).

### 11. Late-game priority ladder (>30 min)
- `mode_farm_generic.lua`: `nFarmCap` clamped to `0.03` in late game — farming stops.
- `aba_defend.*`: new block holds the **Ancient vs a pure creep siege** (mega creeps, no
  heroes) — only the 1–2 closest heroes (`IsAmongClosestAlliesTo`) defend at `0.9`, the
  rest fall through to pushing.
- `aba_push.*`: late-game floor on the `WhichLaneToPush` lane (`0.3–0.7` by HP, capped by
  `nMaxDesire`) so the team groups and pushes instead of idling.

**Impact:** Implements the requested ladder (protect ancient → protect towers → push
weakest lane → kill enemy ancient / cycle). **Verdict: 🟢 Stronger.** *Needs a mega-creep
lobby test to confirm defenders hold while the rest push.*

### 12. Base-siege emergency buyback
`ability_item_usage_generic.lua`: in mid/late game, if enemies are within 3000 of our
Ancient, ≤2 allies alive, and respawn > 45s → immediate `ActionImmediate_Buyback()`.

**Impact:** Bots buy back to defend a base throw. **Verdict: 🟢 Stronger.** *Minor risk:*
can spend buyback on an already-lost base; gated by the ≤2-alive / >45s-respawn conditions.

### 13. Neutral camp stacking
`aba_site.*` adds `GetStackDesire` (pos 4/5, after 1:30, sec ≥48, safe) and
`GetStackableCamp` (nearest own-jungle non-ancient camp, pull toward own ancient).
`mode_farm_generic.lua` executes: walk to camp, aggro, drag out at sec ≥57.

**Impact:** Supports create extra team farm at lane downtime. **Verdict: 🟢 Stronger.**
*Caveat:* generic "pull toward ancient" direction is imperfect for a few camps (documented
limitation) — a mistimed stack just wastes ~8s.

### 14. Ward system overhaul
`aba_ward_utility.lua` + `mode_ward_generic.lua`: adds active **dewarding** (attack a
revealed enemy ward, or blind-drop a sentry on a suspected mirror spot then finish it),
**territory-aware placement** (`GetTeamAdvantageState` → aggressive enemy-side spots when
winning, defensive own-side when losing, and suppresses aggressive spots when losing), and
keeps supports with the group during a push (skip far spots). Ward-item detection now
handles carrying observer + sentry simultaneously.

**Impact:** Denies enemy vision and places wards where they matter by game state — a
hallmark of strong play. **Verdict: 🟢 Stronger.** Largest single behavioral surface here;
worth a dedicated ward-mode regression test.

### 15. Better lane sustain
`item_purchase_generic.lua`: buys flask/regen until level **12** (was 6) and when HP <
**0.85** (was 0.5). `ability_item_usage_generic.lua`: tango triggers at ~85% max-HP loss
(HP-scaled, was a flat 200) and bottle self-heal at HP < **0.8** (was 0.5, threshold
scaled to 20% max HP).

**Impact:** Bots stay healthier in lane and contest more. **Verdict: 🟢 Stronger.**
*Trade-off:* slightly more gold on consumables and faster tango/bottle-charge consumption.

---

## 🟡 Trade-offs / mixed

### 16. Heal to higher HP before re-engaging lane
`mode_retreat_generic.lua`: in the laning phase the re-engage HP gate rose from **25%** to
**75%** (60% if actively healing), and the "far from fountain, no enemies" desire-reduction
now only applies at HP ≥ 50%.

**Impact:** Bots survive far more (fewer avoidable deaths) **but spend more time off-lane
healing**, which can cost last-hits/XP and cede lane pressure. Net effect depends on the
matchup. **Verdict: 🟡 Trade-off — safer but less lane uptime.** Watch that bots don't
yo-yo out of a winning lane.

### 17. Ignore dangerous no-bounty summons; prioritize Undying zombies
`aba_special_units.lua`: dangerous, tanky, temporary summons with no good kill reward now
all return `BOT_ACTION_DESIRE_NONE` ("never engage") — **Lone Druid bear**, **Warlock
golem**, **Undying Tombstone**, and **Brewmaster Primal Split brewlings**. Conversely,
**Undying zombies** (weak, they slow and drain the bot) are now a high-priority kill when
not retreating: `0.9` in attack range, `0.8` within +200, `0.5` otherwise (previously
gated at `0.6/0.25` and only when allies weren't outnumbered).

**Impact:** Bots stop wasting time/HP on tanky summons that expire on their own and instead
clear the cheap, annoying zombies. **Good** for golem / tombstone / brewlings (temporary,
high HP). **Questionable for the Lone Druid bear**, where killing the bear is a real
tempo/gold objective; blanket-ignoring it may let it free-farm/hit. *Note:* ignoring
brewlings forgoes ending Primal Split early by killing one. **Verdict: 🟡 Mixed** — likely
positive overall, mild negative vs Lone Druid.

### 18. All bots grab the nearest bounty rune at start
`mode_rune_generic.lua`: replaced the lane-based split (some to bounty, some to
power/water) with "every bot moves to the nearest bounty rune."

**Impact:** Simpler and fine at 0:00 (only bounties spawn), but it removes power/water-rune
contest and can **clump bots** at one rune. **Verdict: 🟡 Mild regression risk** — verify
mid still gets its rune and bots don't over-collapse on one bounty.

---

## ⚪ Cosmetic / non-gameplay

### 19. Localization → Russian; English content trimmed
- `Customize/general.lua`: `Customize.Localization = "ru"` (was `"en"`).
- `localization.lua`: `LanguageCode = 'ru'`; ~401 lines of English chat removed
  (trash-talk lines, `-info`/difficulty-info block, version/update notices,
  `pos_select_closed`, tormentor prompt, etc.).
- `aba_team_names.lua`: postfix `OHA` → `EHA`; removed the large Chinese-mythology team
  name pool.

**Impact:** No effect on bot combat strength. **Verdict: ⚪ Cosmetic**, but note this is a
**regression for English games** — flavor chat and the in-game difficulty/version info
messages are gone, and the default spoken language is now Russian. Re-add the English
strings (or restore `"en"` default) if English output is still wanted.

---

## Notes / follow-ups

- **No syntax/crash breaks found.** One cosmetic oddity: in generated `aba_push.lua` the
  `if jmz.IsDefending(bot)...` line lost its indentation when the human-giveaway block was
  removed — harmless in Lua.
- **TS/Lua sync:** `aba_push`, `aba_defend`, `aba_site`, `utils` were edited in both the
  `.ts` source and the generated `.lua`, and `bots.d.ts` gained `killTarget`. Consistent.
- **Recommended in-game tests:** mega-creep late game (#11), ward mode incl. dewarding
  (#14), Lone Druid matchup (#17), and rune start (#18).
</content>
</invoke>
