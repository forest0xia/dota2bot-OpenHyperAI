# Bot Ward Placement by Game Progress

How the bots decide **where** to plant observer and sentry wards, phase by phase, for both
Radiant and Dire.

- **Spot data + selection logic:** `bots/FunLib/aba_ward_utility.lua`
- **Consumer (when to buy / walk / plant / deward):** `bots/mode_ward_generic.lua`

All coordinates below are the raw `Vector(x, y)` values from the spot tables. Named
map locations are **approximate** interpretations to make the tables readable.

---

## Map coordinate primer

The Dota map is roughly `-8000 … +8000` on each axis:

| Axis | Negative | Positive |
|------|----------|----------|
| **X** | West / left | East / right |
| **Y** | South / bottom | North / top |

- **Radiant** fountain is bottom-left → Radiant territory trends **negative** X/Y.
- **Dire** fountain is top-right → Dire territory trends **positive** X/Y.
- **Mid / river** is around the origin `(0, 0)`.

So an observer at `(-4000, 2500)` is on the **Radiant/west** side; one at `(4600, 750)` is
pushed into **Dire/east** territory.

---

## The core idea

Ward selection is driven by **three things**, in this order:

1. **Game phase** (`DotaTime`, `J.IsEarlyGame()`) — picks *which table* of spots is live.
2. **Tower frontier** — in mid/late game, defensive spots follow the **frontmost tower
   still standing** in each lane; aggressive spots unlock around **enemy towers you've
   destroyed**.
3. **Team advantage** (`GetTeamAdvantageState`) — biases the *choice among candidates*
   toward enemy territory when winning, your own side when losing, and **disables
   aggressive spots entirely when losing**.

Every candidate spot is then filtered (see [Filters](#filters--cooldowns)) and the bot
walks to the **closest** surviving candidate.

---

## Phase 1 — Pre-game (`DotaTime < 0`)

Source: `X.GetGameStartWardSpots()`. Exactly **two** observer spots, planted during the
horn/pre-creep window. The mid spot is **randomized** each game from three options.

### Radiant
| # | Location | Approx. spot |
|---|----------|--------------|
| 1 (random) | `(-249, -1046)` **or** `(-1615, -122)` **or** `(355, -1645)` | Mid river / mid highground |
| 2 | `(1638, -4640)` | Bottom lane (Radiant safelane) river |

### Dire
| # | Location | Approx. spot |
|---|----------|--------------|
| 1 (random) | `(-471, 360)` **or** `(1141, -458)` **or** `(-926, 1274)` | Mid river / mid highground |
| 2 | `(-1472, 3815)` | Top lane (Dire safelane) river |

**Result:** each team opens with one **mid vision** ward and one **safelane** ward.

---

## Phase 2 — Laning / early game (`J.IsEarlyGame()`)

Source: `X.GetEarlyGameWardSpots()` → the six `*_LANE_PHASE_*` spots. These give lane +
rune + jungle-entrance vision during the laning stage. They stay eligible until a phase
change, and each spot has a **6-minute replant cooldown** once used.

### Radiant lane-phase spots
| # | Location | Approx. area |
|---|----------|--------------|
| 1 | `(-4014, 2569)` | Top lane / Radiant offlane |
| 2 | `(-7552, 3967)` | Deep top-left (Dire safelane / pull camps) — aggressive |
| 3 | `(-1615, -122)` | Mid / river |
| 4 | `(-868, -783)` | Mid river (Radiant side) |
| 5 | `(3097, -4069)` | Bottom lane river (Radiant safelane) |
| 6 | `(7614, -5381)` | Deep bottom-right (Dire offlane) — aggressive |

### Dire lane-phase spots
| # | Location | Approx. area |
|---|----------|--------------|
| 1 | `(-4310, 3639)` | Top lane river (Dire safelane) |
| 2 | `(-7490, 4741)` | Deep top-left (Dire safelane / pull camps) |
| 3 | `(-2159, 1987)` | Mid / river |
| 4 | `(1141, -458)` | Mid river (Dire side) |
| 5 | `(3810, -4562)` | Bottom lane (Radiant safelane / Dire offlane) |
| 6 | `(7512, -4630)` | Deep bottom-right (Dire offlane) |

**Pattern (both sides):** 2 mid/river wards, aggressive vision into the enemy safelane
jungle, and defensive vision covering their own safelane.

---

## Phase 3 — Mid / late game (tower-frontier warding)

Once out of the early game, spots come from **tower-keyed tables**. There are two kinds:

### 3a. Defensive spots — follow your surviving front tower
Table: `WardLocationsBeforeAllyTowerFall__{Radiant,Dire}`, keyed by tower
(`TOWER_TOP_1 … TOWER_BOT_3`).

A tower's spot group becomes active only when it is the **frontmost tower still standing**
in its lane:

- All **T1** up → ward around **T1** (`_1`) spots.
- A lane's **T1 falls** → that lane's **T2** (`_2`) spots activate (you fall back).
- **T2 falls** → **T3** (`_3`) spots activate (base defense).

So defensive vision **retreats with your towers**, lane by lane. Radiant defensive spots sit
on Radiant/negative territory; Dire's on Dire/positive territory.

*Example — Radiant, all T1 up:* candidates include mid-T1 spots like `(2255, -1892)`,
`(-416, 224)`, `(-2606, 1702)` (mid river / Radiant jungle mouths) plus the top-T1 and
bot-T1 groups.

### 3b. Aggressive spots — unlock around enemy towers you destroy
Table: `WardLocationsAfterEnemyTowerFall__{Radiant,Dire}`, keyed by the **enemy** tower.

When you **destroy an enemy tower**, its spot group opens up so you can ward the newly
contested enemy territory (deep vision, their jungle, their high ground). Radiant's
aggressive spots are on Dire/positive territory; Dire's on Radiant/negative territory.

*Example — Radiant after taking Dire's mid T1:* spots like `(4613, 755)`, `(3006, -347)`,
`(3454, 965)` — pushed into Dire's mid jungle.

> **Aggressive spots are suppressed when the team is `losing`** (see below). Defensive
> spots are always eligible.

---

## Team-advantage steering (`X.GetTeamAdvantageState`)

Cached ~2s per bot. Returns `winning` / `even` / `losing` from three signals:

1. **>2 enemy heroes roaming our territory** → immediately `losing` (defensive panic).
2. **Lane-push fronts** — each lane whose front is ≥1500 deeper into enemy territory scores
   `+1`, deeper into ours scores `-1`.
3. **Tower control** — count standing towers, **T2/T3 worth double**. A ≥2 lead → `+1`,
   ≥2 deficit → `-1`.

Final: score `≥2` = `winning`, `≤-2` = `losing`, else `even`.

Effects:
- **Aggressive (enemy-side) observer spots are only generated when *not* `losing`.**
- In `X.GetClosestObserverWardSpot`, the chosen spot's distance is **halved (made more
  attractive)** if it's an enemy-side spot while `winning`, or an own-side spot while
  `losing` — steering placement toward the correct half of the map.
- While the team is **pushing T2/high ground**, spots more than **1500 units** from the bot
  are skipped so the support stays with the group instead of wandering off to ward.

---

## Observer + sentry pairing

**Every observer the bots plant is paired with a sentry at the same spot.** This is enforced
in `mode_ward_generic.lua`:

- **If the bot carries both** (or a combined `item_ward_dispenser`): it plants the observer,
  then immediately drops a sentry at the same location (small random offset). The pending
  sentry is tracked in `hPendingSentryLoc` and completed at top priority on the next tick(s),
  so an observer is never left uncovered.
- **If the bot has both, it never drops a lone sentry** at a "sentry spot" — the standalone
  sentry-spot placement only runs when the bot has **no** observer (`ObserverWard == nil`).
- **Observer-only** (somehow holding an observer but no sentry): the bot **holds** the
  observer and waits — it will not place it until a sentry is also available.
- **Sentry-only**: placing a lone sentry at sentry spots is allowed (see below).
- **Dewarding is exempt** (a blind sentry drop to reveal an enemy ward is still allowed).

**Purchasing** (`item_purchase_generic.lua`, pos 5): whenever the observer carrier buys
observers it also tops up **sentries** (kept up to 2 charges, dispenser-aware via
`Item.GetWardCharges`) so it always has a sentry to pair. There is no rush — wards are bought
to stash / delivered by courier.

## Sentry wards (`X.GetPossibleSentryWardSpots`) — lone-sentry carriers

Used only by bots carrying sentries **without** an observer (e.g. pos 4). Sentries are **not**
placed everywhere observers can go. A tower/lane spot becomes a sentry candidate only when
**either**:

- that spot was **recently dewarded** (`plant_time_obs` set within the last 360s), **or**
- there is an **allied observer within 400 units** (protect / extend our own obs).

…and the spot has **no allied sentry within `nMinSentrySeparation`** (2400), **no existing
true-sight**, and (early game) is passable.

---

## Dewarding

Three helpers drive active deward behavior:

| Function | Purpose |
|----------|---------|
| `X.GetSuspectedEnemyWardSpots()` | The enemy's likely spots = **mirror** of our `BeforeAllyTowerFall` table (their side wards their own territory to watch us push in). |
| `X.GetClosestDewardSpot(bot, maxDist)` | Nearest suspected enemy spot for a **blind sentry drop** to reveal a hidden observer. |
| `X.GetNearbyEnemyWard(bot, radius)` | Nearest **already-revealed**, attackable enemy ward to walk up and destroy. |

---

## Filters & cooldowns

Every candidate observer spot must pass:

- `IsLocationPassable(spot.location)` — valid ground.
- **No allied observer** within `nMinObserverSeparation` (= `nVisionRadius * 2` = 3200) —
  keeps observers from clustering so vision spreads across the map (circles touch, no
  overlap). Raise this constant to spread observers further apart.
- **No enemy sentry** within 1100 — don't plant into detection.
- **Replant cooldown**: `plant_time_obs == 0` or `DotaTime() > plant_time_obs + 360`
  (6 min) — a spot isn't reused for 6 minutes after it was last warded.

Sentry candidates: no allied sentry within `nMinSentrySeparation` (= 2400), no existing true
sight, plus the observer-adjacency / recently-dewarded condition above. Both separation
constants live at the top of `aba_ward_utility.lua`.

---

## End-to-end flow (per warding support)

```
DotaTime < 0 ........... GetGameStartWardSpots()      (2 fixed opener spots)
J.IsEarlyGame() ........ GetEarlyGameWardSpots()      (6 lane-phase spots)
otherwise .............. tower-frontier tables:
                           - BeforeAllyTowerFall  (defensive, our front tower)
                           - AfterEnemyTowerFall  (aggressive, enemy towers we took)
                             └─ skipped when advState == 'losing'
   -> filter all candidates (passable / no overlap / no enemy sentry / cooldown)
   -> GetClosestObserverWardSpot: nearest, weighted by advState, skip far spots on a push
   -> walk & plant   (mode_ward_generic.lua)
Sentries: GetPossibleSentryWardSpots -> nearest (defend own obs / re-ward dewarded spots)
Deward: blind sentry on suspected mirror spot, or attack a revealed enemy ward
```

---

## Data-quality notes

A batch of table-definition defects that silently dropped or corrupted ward spots have
been **fixed** in `aba_ward_utility.lua`:

- **Missing comma** in `WardLocationsBeforeAllyTowerFall__Radiant[TOWER_MID_3][3]`
  (`Vector(-2414 -3802)` → `Vector(-2414, -3802)`) — was parsed as a single argument.
- **Duplicate integer keys** (the second silently overwrote the first), now renumbered:
  - `BeforeAllyTowerFall__Dire[TOWER_MID_1]` — second `[4]` → `[5]`.
  - `BeforeAllyTowerFall__Dire[TOWER_TOP_3]` — second `[4]` → `[5]`.
  - `AfterEnemyTowerFall__Dire[TOWER_TOP_2]` — duplicate `[1]` → `[1][2][3][4]`.
  - `AfterEnemyTowerFall__Dire[TOWER_MID_3]` — key `[3]` (skipping `[2]`) → `[2]`.

**Remaining, harmless:** `AfterEnemyTowerFall__Dire[TOWER_TOP_3][1]` uses a 3-component
`Vector(-6401, -4286, 256)`. The `z` component is ignored by placement (`pairs()` +
`GetUnitToLocationDistance` / `IsLocationPassable` use x/y only), so it is a cosmetic
copy/paste artifact, not a defect.
