# Bot Difficulty Improvement Plan (v2)

Fresh investigation of the codebase (post-implementation of the previous plan). Each item
below is grounded in something actually found in the code — a dead function, a missing
behavior, or a reactive-only system. Sorted by **development risk** (ascending), then
**impact on difficulty** (descending).

> The previous plan's items (level-spike aggression, barracks buyback, mid-push on wipe,
> enemy-cooldown push windows, observer wards during push, kill-commitment coordination)
> are implemented and are **not** repeated here. This list is entirely new opportunities.

---

## Summary Table

| # | Feature | Risk | Impact | Status |
|---|---------|------|--------|--------|
| 1 | Activate coordinated focus-fire | Very Low | High | ✓ Done |
| 2 | Anti-juke chase commitment | Low | Medium | ✓ Done |
| 3 | Neutral camp stacking | Low-Med | High | ✓ Done |
| 4 | Active dewarding of enemy vision | Low-Med | Medium | ✓ Done |
| 5 | Proactive Roshan coordination | Medium | High | Pending |
| 6 | Creep pulling for lane control | Medium | Medium | Pending |
| 7 | Proactive ally-saving | Med-High | High | Pending |
| 8 | Late-game priority ladder (>30 min) | Low | High | ✓ Done |

---

## 1. Activate the coordinated focus-fire system (it already exists, unused)
**Risk: Very Low** | **Impact: High** | ✓ **Done**

> **Implemented.** `mode_attack_generic` override's `Think()` now calls
> `J.GetBestTeamTarget`; the hero-specific multipliers (Sniper ×4, Lina ×3, …) and
> the tower-hugging de-prioritization were folded into `J.ScoreEnemyTarget` via a
> `J.HeroTargetPriority` table. Invalid-target returns use a `J.SCORE_INVALID_TARGET`
> sentinel so an all-untargetable enemy list correctly falls through to the
> weakest-unit fallback. Files: `bots/FunLib/jmz_func.lua`,
> `bots/FunLib/override_generic/mode_attack_generic.lua`.

`FunLib/jmz_func.lua` contains a fully written team-target scoring system —
`J.GetBestTeamTarget(bot, enemyHeroes, allyHeroes)` and its helper
`J.ScoreEnemyTarget(bot, enemy, alliesNearby)` (~line 3591). It scores enemies by
killability, offensive threat, distance, **how many allies are already attacking that
target** (`+12` per ally → natural convergence), core-vs-support priority, blade-mail
avoidance, and threats currently hitting us. There is even a comment stating "Cross-bot
coordination happens naturally: all bots running the same scoring algorithm … converge
on the same target."

**The problem:** `grep` shows `GetBestTeamTarget` is **never called anywhere**. It is
completely dead code. Meanwhile `override_generic/mode_attack_generic.lua:Think()` uses
its own *independent* inline `enemyScore` formula per bot, so five bots frequently split
damage across five different targets instead of collapsing one hero at a time.

**What to change:**
- In `bots/FunLib/override_generic/mode_attack_generic.lua`, in `Think()`'s target loop
  (~line 300), replace the inline `enemyScore` selection with a call to
  `J.GetBestTeamTarget(bot, nEnemyHeroes, tAllyHeroes)`.
- Keep the existing hero-specific multipliers (Sniper ×4, Lina ×3, etc.) by folding them
  into `ScoreEnemyTarget` as a lookup table so no tuning is lost.

**What could break:** The scoring function is already validated logic; the risk is only
in the swap. Keep the current `GetAttackableWeakestUnit` fallback for when it returns nil.
Because target choice converges via the Valve `GetAttackTarget()` API, no shared mutable
state is introduced — nothing to desync.

---

## 2. Anti-juke chase commitment (finish the computation you're already doing)
**Risk: Low** | **Impact: Medium** | ✓ **Done**

> **Implemented.** The `_chaseFatigue` tracking now runs live via #1. In addition,
> `mode_retreat_generic` raises retreat desire to break off a solo over-chase when
> we're not in a team fight, not clearly stronger, the target has been chased 5s+,
> is still above half HP, has slipped past 900 units, and no ally is within 600 of
> it. File: `bots/mode_retreat_generic.lua`.

`ScoreEnemyTarget` maintains `bot._chaseFatigue[enemyID]` — tracking how long a bot has
chased a target and whether the target's distance is *increasing*. It already applies a
score penalty when a bot has chased a healthy enemy for >4s or the gap is widening. But
since item #1's function is never called, this tracking never runs, so bots currently
tunnel-vision on a fleeing hero into the enemy fountain.

**What to change:**
- Comes online automatically once #1 is wired in (same code path).
- Additionally, in `mode_retreat_generic.lua` / the disengage path, read the same
  `_chaseFatigue` signal: if the bot has been chasing >5s with the target gaining
  distance and no ally has it in kill range, raise retreat desire so the bot breaks off
  instead of overcommitting.

**What could break:** A bot might disengage from a genuinely catchable target 0.5s early.
Gate the disengage bump behind "no ally within 600 of the target" so it only fires on
true solo over-chases.

---

## 3. Neutral camp stacking
**Risk: Low-Medium** | **Impact: High** | ✓ **Done**

> **Implemented.** Added `GetStackDesire` + `GetStackableCamp` to `aba_site`
> (TS source + generated Lua). Supports (pos 4/5) get a moderate farm-mode desire in
> the `:48–:59` window when safe and post-laning; farm-mode `Think()` approaches the
> nearest own-jungle camp, aggros the neutrals, and at `:57` drags them toward our
> ancient to clear the box. Box-geometry-free heuristic (pull toward ancient); cores
> are never affected. Files: `typescript/bots/FunLib/aba_site.ts`,
> `bots/FunLib/aba_site.lua`, `bots/mode_farm_generic.lua`.
>
> *Limitation:* generic pull direction is imperfect for a few camps and stacking is
> post-laning only (farm mode returns NONE during laning). Verify in-game.

`GetNeutralSpawners()` is available and is already used in several hero files and
`aba_site.lua`, but only to *farm* camps with AoE abilities — no bot ever **stacks** a
camp. Stacking is one of the biggest amateur-vs-strong-bot gaps: it multiplies jungle
gold for cores and gives supports something productive to do at lane downtime.

**What to change:**
- Add `GetStackableCampLocation(bot)` to `FunLib/aba_site.lua` returning the pull-aggro
  spot for the nearest reachable neutral camp when game-clock seconds are in the stack
  window (~:53 for most camps, ~:49 for the ancient/large camps).
- Add a lightweight `GetStackDesire(bot)` used in the farm-mode auction: supports and the
  mid hero get moderate desire to walk to the aggro spot and attack-move the camp out at
  the right second, then leave.
- Prefer stacking the camps nearest the team's farming half of the jungle.

**What could break:** A support could waste ~8s mistiming a stack. Bounded to a small
window; if the camp isn't clear by :55 the bot abandons. No effect outside farm mode.
Ancient-camp stacks need the bot to actually be able to damage-and-leave without dying —
gate ancient stacks behind a minimum level.

---

## 4. Active dewarding of enemy vision
**Risk: Low-Medium** | **Impact: Medium** | ✓ **Done**

> **Implemented.** Added `GetSuspectedEnemyWardSpots` (mirror of our ward tables for
> the enemy team), `GetClosestDewardSpot`, and `GetNearbyEnemyWard` to
> `aba_ward_utility`. `mode_ward_generic` now, when a support is advanced into
> contested ground with no enemy hero within 1000, attacks a revealed enemy ward or
> drops a sentry at the nearest suspected spot (within 1200) to expose it, then stays
> a few seconds to finish the kill. Files: `bots/FunLib/aba_ward_utility.lua`,
> `bots/mode_ward_generic.lua`.

`aba_ward_utility.lua` tracks the plant time of our *own* observers (the
`plant_time_obs`/"got dewarded" logic) but there is no behavior that hunts and removes
*enemy* wards. Strong teams deny vision before pushing or ganking. The sentry-purchase
plumbing already exists.

**What to change:**
- Add `GetSuspectedEnemyWardSpots()` to `aba_ward_utility.lua` returning the canonical
  enemy ward locations for the current push/gank target area (reuse the existing spot
  tables — enemy spots are the mirror of ours).
- In `mode_ward_generic.lua`, when a support carries a sentry and the team is pushing or
  smoke-ganking through a contested area, add desire to detour ≤1200 units to a suspected
  ward spot, drop a sentry, and attack-clear any revealed ward.
- Gate behind "no visible enemy hero within 1000" so the support doesn't deward into a
  waiting team.

**What could break:** A support may spend a sentry on an empty spot. Acceptable — sentries
are cheap. The ≤1200 detour cap keeps it from detaching from the group (same guard used
for the already-shipped observer-during-push feature).

---

## 5. Proactive Roshan coordination
**Risk: Medium** | **Impact: High**

`mode_roshan_generic.lua` is almost entirely **reactive**: it only produces high desire
when Roshan is *already* below 50% HP with no enemies nearby, or opportunistically. There
is no logic that decides "we have a power spike / the enemy carry is dead / we hold Aegis
advantage — let's start Roshan now." So bots rarely initiate Rosh as an objective.

**What to change:**
- Add `GetProactiveRoshanDesire(bot)` returning elevated desire when: it's day (or the
  team can fight through night), the whole team can group at the pit, `aliveEnemyCount`
  is reduced (≥1–2 enemies dead) or the team is clearly stronger (`J.WeAreStronger`), and
  the team has the sustain to take the pit (a core with lifesteal/high DPS present).
- On trigger, pull the grouped cores + supports to the pit via the existing team-assemble
  path, and hand the designated carry the Aegis (bots already pick up Aegis reactively).
- Suppress if enemy smoke/TP signals suggest a contest the team would lose.

**What could break:** A mistimed Rosh call can throw a game. Guard hard: require ≥4 allies
alive and grouped, and abort the moment ≥2 enemies appear within 1600 of the pit (the
reactive code already has an enemies-near-pit check to reuse).

---

## 6. Creep pulling for lane equilibrium
**Risk: Medium** | **Impact: Medium**

There is no creep-pull logic anywhere in the repo. Offlane/support bots let the lane push
into the enemy tower, denying their own core safe last hits and XP. Pulling resets the
equilibrium and denies the enemy the wave.

**What to change:**
- Add a `GetPullCampLocation(lane, team)` helper (hard-coded aggro spots for the
  small/large pull camps per side) to `aba_site.lua`.
- Add `GetPullDesire(bot)` for pos-4/pos-5 bots during laning: fire when the pull-camp
  timing lines up with the lane creep wave arriving, the bot is the designated support,
  and no enemy is contesting the camp.
- Sequence in the pull think: attack the camp at the right second, then body-pull the
  lane creeps into it.

**What could break:** Pull timing is the hardest part — a mistimed pull just clears the
camp with no lane effect (harmless) or briefly pulls the support out of position. Only
supports participate; cores never pull. Bounded to the laning phase.

---

## 7. Proactive ally-saving (defensive items on allies)
**Risk: Med-High** | **Impact: High**

`ability_item_usage_generic.lua` has extensive *offensive/self* item logic, but a grep
for ally-targeted defensive saves (Force Staff on a diving ally, Glimmer Cape on a
focused ally, save-TP) finds nothing. Bots watch a teammate die at 10% HP while holding
a Force Staff. This is a hallmark of coordinated play.

**What to change:**
- Add ally-targeted `ConsiderItemDesire` branches for the classic save items:
  `item_force_staff` / `item_hurricane_pike` (push a low-HP diving ally to safety),
  `item_glimmer_cape` (invis a focused ally), `item_lotus_orb`/`item_greaves` (cleanse),
  `item_solar_crest`/`item_medallion` (armor a focused core).
- Trigger when a valid ally is below ~35% HP, is being attacked/targeted by an enemy
  hero, and the save meaningfully changes the outcome (e.g. Force pushes them out of
  enemy attack range or toward the fountain/allies).
- Optionally add a save-TP: a nearby ally with a free TP blinks/TPs to a dying core when
  it can arrive in time (higher risk — defer if the item-save version proves enough).

**What could break:** Save items are high-value; a bot could waste a Glimmer on a bait or
Force an ally the *wrong* direction (into the enemy). Direction logic must resolve
"toward safety" carefully (reuse the existing `VectorAway`/fountain-direction helpers).
Rate-limit to one save attempt per few seconds per bot so multiple supports don't all
blow saves on the same target. Touches the shared item-consider auction, hence the higher
risk rating.

---

## Notes on sequencing

- **Do #1 and #2 first.** They activate code that already exists — the highest
  impact-to-effort ratio in this list and near-zero architectural risk.
- **#3 and #4** are self-contained farm/ward-mode additions with no cross-mode coupling.
- **#5, #6, #7** touch objective timing, laning equilibrium, and the shared item auction
  respectively — each needs a dedicated test lobby and regression of the mode it lives in.

---

## 8. Late-game priority ladder (>30 min)
**Risk: Low** | **Impact: High** | ✓ **Done**

After 30 min (`J.IsLateGame()`; turbo 18 min) the team should follow a strict ladder
rather than keep farming: **#1** protect the Ancient (from heroes *and* creeps), **#2**
protect towers (T2+) if the Ancient is safe, **#3** group-push the weakest lane (mid on a
tie), **#4** kill the enemy Ancient once that lane's rax falls, **#5** otherwise cycle to
the next weakest lane. Implemented as an additive layer over the existing push/defend
desire auction (reuses `WhichLaneToPush` and `GetDefendDesire`), so all current safety
tuning still applies.

**What changed:**
- **Farm suppressed to near-zero** (`mode_farm_generic.lua`): in late game `nFarmCap` is
  clamped to `0.03` so farm always loses to the defend/push floors below. A tiny non-zero
  value is kept so a bot with nothing else to do still clears a nearby wave.
- **Ancient creep-defense with a defender cap** (`aba_defend.ts` → `.lua`): the old base
  threat was hero-started (creeps could only *extend* it), so a pure mega-creep siege with
  no heroes never raised defense. New late-game block: if weighted creep pressure at the
  Ancient ≥ 2 and no enemy heroes are near, only the **1-2 closest heroes**
  (`IsAmongClosestAlliesTo`, deterministic/tie-broken by player id; 2 defenders once the
  wave is very large) peel off to hold it at a `0.9` desire floor. Every other hero returns
  `VeryLow` here and falls through to pushing — realising "1-2 stand in the Ancient, 3-4
  push the enemy line to recover the creep equilibrium." Tower (T2+) creep-defense is still
  covered by the existing `ShouldDefend` creep-weight path (priority #2).
- **Weakest-lane push floor** (`aba_push.ts` → `.lua`): in late game the lane chosen by
  `WhichLaneToPush` (already biased toward the lowest enemy tier, mid on a tie) gets a real
  desire floor (`0.3–0.7` by HP, capped by `nMaxDesire`) instead of the tiny mid fallback,
  so the team groups and commits. Because `nMaxDesire` already folds in every safety gate
  (deep-push, low-HP, outnumbered) and the unsafe cases return earlier, the floor can never
  push the bot into a losing fight. #4/#5 (kill Ancient / cycle lanes) are handled by the
  existing `PushThink` Ancient-endgame logic plus `WhichLaneToPush` re-selection.

**What could break:** In late game bots will nearly stop jungling — intended, but verify a
fed core isn't pulled off a won lane by a single small creep wave at base (the ≥2 creep
weight gate and 1-defender cap are tuned to avoid this). Pure-creep Ancient defense and the
push floor share the desire auction, so regression-test a mega-creep game in a lobby.
