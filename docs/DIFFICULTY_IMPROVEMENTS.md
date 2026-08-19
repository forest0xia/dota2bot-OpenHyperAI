# Bot Difficulty Improvement Plan

Ordered from easiest/safest to most complex/risky. Each entry notes which files to touch
and what could break.

---

## 1. Laning aggression at level power spikes ✓ DONE
**Risk: Very Low** | **Impact: Medium**

Bots play the same passive desire value throughout laning regardless of their level. At
levels 2, 3, and 6 a bot often has a new ability or an ult online — these are kill windows
that currently go unused.

**What to change:**
- `bots/mode_laning_generic.lua` — in `GetDesire()`, after the `botLV` check, add a
  temporary desire boost (e.g. `+0.15`) when `botLV` is exactly 2, 3, or 6 and an enemy
  is within harassment range. Reset after 45 seconds so it doesn't persist forever.

**What could break:** Nothing outside laning mode. Worst case bots slightly overextend
during the spike window.

---

## 2. Buyback on high-ground defense (not just ancient) ✓ DONE
**Risk: Low** | **Impact: Medium**

Current logic in `ability_item_usage_generic.lua:BuybackUsageComplement()` only triggers
buyback when the ancient HP is below 80% or the bot is level 24+. Bots ignore buyback
during a barracks siege where the game is still very much alive.

**What to change:**
- Same function — add a check: if enemy is inside our base (past T3 tier), ally alive count
  is ≤ 2, respawn time is > 30s, and bot has buyback gold → buyback. Gate it behind
  `J.IsMidGame() or J.IsLateGame()` to avoid wasting it too early.

**What could break:** Bots might buyback in some edge cases where it's wasteful. Safe to
tune with a higher respawn-time threshold.

---

## 3. Force mid push when entire enemy team is dead ✓ DONE
**Risk: Low** | **Impact: High**

When all 5 enemies are dead simultaneously, bots have a free window to march mid and
take objectives, but currently no logic capitalises on it: the level gate (`< 6`) can
block it early, the HP-scaling factor cuts desire after a fight, and lane choice is not
forced to mid.

**What to change:**
- `typescript/bots/FunLib/aba_push.ts` (+ compiled `bots/FunLib/aba_push.lua`) — add an
  early-return at the top of `GetPushDesireHelper`, before the level gate and the HP
  multiplication, checking `aliveEnemyCount === 0 && aliveAllyCount >= 4`:
  - Return `0.9` for `Lane.Mid` → guarantees mid push wins the mode auction.
  - Return `BotModeDesire.VeryLow` for top/bot → all bots converge on mid instead of
    splitting across three lanes.
- Add a minimum average-level guard (e.g. `>= 4`) so it doesn't fire at the very start
  of a game where bots genuinely shouldn't push.

**What could break:** Only `aba_push.ts`/`aba_push.lua` are touched. Worst case: bots
march mid during an early wipe when a comeback is still impossible (mitigated by the
level guard). The lane-forcing only applies while `aliveEnemyCount === 0`, so it
self-cancels the moment the first enemy respawns.

---

## 4. Wait for enemy key cooldowns before pushing ✓ DONE
**Risk: Low** | **Impact: High**

`utils.lua` already has `HasTeamMemberWithCriticalSpellInCooldown` and
`HasTeamMemberWithCriticalItemInCooldown` to check *our* team. The inverse — "enemy just
used their teamfight ult, push now" — does not exist. This would be a pure read-only
signal that feeds the push desire.

**What to change:**
- Add `HasEnemyKeyAbilityOnCooldown(targetLoc)` to `utils.lua`, mirroring the existing
  functions but iterating enemy heroes. Key abilities to track: Black Hole, Reverse
  Polarity, Ravage, Chronosphere, Overgrowth, etc. (extend `spell_list.lua` with a
  `criticalUlts` tag).
- In `aba_push.lua` / `aba_push.ts` — if the function returns true and bots are grouped,
  bump push desire by `+0.2` for 15 seconds.

**What could break:** The function is purely additive to desire. The enemy spell list
needs to be maintained when new heroes are added. No existing logic is touched.

---

## 5. Observer wards on enemy territory during pushes ✓ DONE
**Risk: Low-Medium** | **Impact: High**

The spot database (`WardLocationsAfterEnemyTowerFall__Radiant/Dire`) already contains
observer ward locations deep in enemy territory, including the two classic mid spots
(enemy river rune and enemy jungle entry). The ward placement system in
`mode_ward_generic.lua` is already fully functional with safety checks. The only thing
blocking it is one gate that kills warding during high-ground pushes — exactly when
those spots are most needed.

**What to change:**
- `bots/mode_ward_generic.lua:37` — remove or invert the
  `IsTeamPushingSecondTierOrHighGround` early return so supports actively look for ward
  spots *during* a push rather than suppressing warding entirely.
- Add a distance cap in `GetClosestObserverWardSpot`: when the team is pushing, skip
  spots farther than ~1500 units from the bot so the support doesn't detach from the
  group to make a solo trip deep into enemy territory.

**What could break:** A support may occasionally slow down the push by ~3-5 seconds to
place a nearby ward. The existing `IsEnemyCloserToWardLocation` and
`WasRecentlyDamagedByAnyHero` guards already prevent dangerous placements. No new spot
data needed — the mid spots and push spots are already in the tables.

---

## 6. Purchase and place sentries before a high-ground push
**Risk: Low-Medium** | **Impact: Medium**

Bots currently commit to high-ground pushes without vision of the enemy high ground.
Sentry wards placed at ramp entry points before the push give vision of ambushes and
trigger the existing AoE danger zone avoidance.

**What to change:**
- `bots/FunLib/aba_ward_utility.lua` — add `GetHighGroundWardSpots(lane)` that returns
  the 1-2 canonical ramp ward locations per lane (hard-coded vectors, same pattern as
  existing ward spots).
- `item_purchase_generic.lua` — when push desire is high and `DotaTime() > 20min`, if
  the designated support bot has no sentry in inventory, add `item_ward_sentry` to the
  front of its buy queue.
- The ward placement mode already exists; just needs the new spots.

**What could break:** Support bots may sometimes delay their regular item purchases.
Keep it gated behind a gold threshold (e.g. don't buy sentries if core items are missing).

---

## 7. Active BKB / Linken timing improvement ✓ DONE
**Risk: Medium** | **Impact: High**

Bots currently activate BKB reactively (after a spell hits them). Better behavior: track
when a key enemy channeled or cast-time ability starts and pop BKB before it lands. The
Dota API exposes `bot:WasRecentlyDamagedByHero()` and ability cast events are visible
through hero modifier tracking.

**What to change:**
- `bots/FunLib/aba_skill.lua` — add a `ShouldPreActivateBKB(bot)` function that checks:
  is a nearby enemy hero currently in a cast animation for a known channeled ability
  (Black Hole, Fiends Grip, etc.)? Use `GetAbilityLastActivatedTime` or modifier
  presence (`modifier_black_hole_thinker` appearing) as the trigger.
- In `ability_item_usage_generic.lua`, call it before the existing BKB check.

**What could break:** Per-ability modifier names must be kept in sync with patches.
Could cause BKB to pop a frame too early in edge cases. Separate flag per bot so one
bot's decision doesn't cascade. Well isolated.

---

## 8. Kill commitment coordination ("we have them stunned — finish it") ✓ DONE
**Risk: Medium-High** | **Impact: High**

Currently each bot independently evaluates whether to chase a kill. This means bots
often peel off a 15% HP enemy because the bot's own HP is mediocre, while an ally with
full HP does nothing. A lightweight shared signal fixes this.

**What to change:**
- Add a table `J.Utils.GameStates.killTarget = { unit, expiresAt }` (similar to the
  existing `defendPings` pattern) set whenever a bot lands a stun/root on an enemy hero
  below 30% HP.
- Other bots within 1200 range check this signal: if set and they can reach the target,
  override retreat desire with an attack desire for 3 seconds.
- Clear the signal when the target dies or the timer expires.

**What could break:** Bots may dive towers to finish a kill if the target retreats under
one. Need a "don't commit if enemy tower is shooting at us" guard (which already exists
in push logic — reuse `IsInDangerWithinTower`). Medium risk because it touches the
retreat/attack desire balance.

---

## 9. Split push with TP back threat
**Risk: High** | **Impact: High**

One sidelane bot pushes while 4 others group mid. If enemies send 2+ heroes to stop the
split, the splitter TPs to the group. This requires a coordinator role and cross-mode
communication.

**What to change:**
- Add a `SplitPushCoordinator` singleton in `jmz_func.lua` (similar to `J.Role`) that
  designates one bot as the splitter when: team is level 11+, mid lane has 4+ allies,
  and a sidelane T1 is still up on one side.
- The splitter's `GetPushDesire` is boosted for the non-mid lane; its `GetFarmDesire`
  is zeroed.
- If `GetIncomingTeleports()` shows 2+ enemies heading to the splitter's lane, it
  triggers `mode_retreat_generic` then teleports to the team fight using existing
  `GetPushTPLocation`.

**What could break:** The coordinator state can desync if bots die mid-rotation. Need
a clean reset path. Cross-mode state is the biggest risk — if the splitter's farm/laning
modes don't correctly yield to the coordinator, it can get stuck. Extensive guards needed.

---

## 10. Coordinated smoke ganks
**Risk: Very High** | **Impact: Very High**

This is the most impactful and the most complex. Requires a new mode, group formation,
shared target selection, timed de-smoke approach, and handoff to the fight modes.

**What to change:**
- New file `bots/FunLib/aba_smoke_gank.lua` with `GetSmokeGankDesire(bot)` and
  `SmokeGankThink(bot)`.
- `GetDesire` logic: return high desire only when: 3+ allies are grouped within 800
  range, a smoke is in one of their inventories, an enemy is isolated (visible or
  last-seen within 60s) more than 1500 from any ally, and it is past 5 minutes.
- `Think` logic: the smoke carrier uses the item, all grouped bots walk toward the
  last-seen enemy location in formation (stay within 400 of each other), pause 150
  units outside enemy vision range, then one bot initiates (highest stun ability),
  others follow within 0.3s.
- The smoke breaks on proximity — the bot API does not give direct control over when
  to de-smoke, so approach distance must be tuned carefully per hero (range vs melee).
- Register in `mode_attack_generic.lua` as an override that yields once the fight starts.

**What could break:** Everything. Group formation can break if one bot has a different
active mode with higher desire. The approach pathing may walk through vision accidentally.
De-smoke timing varies by hero attack range. The 0.3s follow window may be too tight
given the think-rate throttle. Requires a separate test lobby and full regression of
fight/farm/push behaviors after integration.

---

## Summary table

| # | Feature | Files touched | Risk | Impact | Done |
|---|---------|--------------|------|--------|------|
| 1 | Level spike laning aggression | mode_laning_generic.lua | Very Low | Medium | ✓ |
| 2 | Buyback on barracks siege | ability_item_usage_generic.lua | Low | Medium | ✓ |
| 3 | Force mid push on full enemy wipe | aba_push.ts + aba_push.lua | Low | High | ✓ |
| 4 | Enemy ult cooldown → push window | utils.lua, aba_push.ts | Low | High | ✓ |
| 5 | Observer wards on enemy territory | mode_ward_generic.lua | Low-Med | High | ✓ |
| 6 | Sentry wards before HG push | aba_ward_utility.lua, item_purchase_generic.lua | Low-Med | Medium | |
| 7 | BKB/Linken pre-activation | jmz_func.lua, ability_item_usage_generic.lua | Medium | High | ✓ |
| 8 | Kill commitment coordination | jmz_func.lua, mode_attack_generic.lua | Med-High | High | ✓ |
| 9 | Split push + TP threat | jmz_func.lua (new coordinator) | High | High | |
| 10 | Coordinated smoke ganks | new aba_smoke_gank.lua + registration | Very High | Very High | |
