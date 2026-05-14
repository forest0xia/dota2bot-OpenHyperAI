# Dota 2 Bot Scripting API Reference

> Comprehensive reference for the Valve bot scripting API used in custom lobby bot scripts. Detailed parameter descriptions, return value semantics, usage examples, and important caveats.
> Ref: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API
---

## Table of Contents

1. [Script Entry Points](#script-entry-points)
2. [Time Functions](#time-functions)
3. [Team, Players, and Bot Handles](#team-players-and-bot-handles)
4. [Hero Stats (by Player ID)](#hero-stats-by-player-id)
5. [Game State](#game-state)
6. [Map and World](#map-and-world)
7. [Distance Functions](#distance-functions)
8. [Lanes and Creep Equilibrium](#lanes-and-creep-equilibrium)
9. [Structures](#structures)
10. [Items (Global)](#items-global)
11. [Runes](#runes)
12. [Unit Queries](#unit-queries)
13. [Projectiles and Avoidance](#projectiles-and-avoidance)
14. [Team Desires](#team-desires)
15. [Roshan and Glyph](#roshan-and-glyph)
16. [Courier System](#courier-system)
17. [Hero Selection and Captains Mode](#hero-selection-and-captains-mode)
18. [Math and Random](#math-and-random)
19. [Callbacks](#callbacks)
20. [Debug and HTTP](#debug-and-http)
21. [Unit Functions (on unit handles)](#unit-functions)
22. [Ability / Item Functions (on ability/item handles)](#ability--item-functions)
23. [Action System](#action-system)
24. [Constants Reference](#constants-reference)

---

## Script Entry Points

Valve calls these functions from your script files at specific times. Define them in the appropriate file to override default bot behavior. Understanding the call order and frequency is critical for writing efficient bot code.

### Mode Scripts (`mode_[name]_generic.lua`)

```lua
function GetDesire()   -- Returns float 0.0-1.0 desire for this mode
function OnStart()     -- Called once when this mode becomes the active mode
function OnEnd()       -- Called once when this mode stops being the active mode
function Think()       -- Called every frame ONLY while this mode IS the active mode
```

> **Important:** `GetDesire()` is called **every frame for ALL modes simultaneously**. The mode returning the highest desire value wins and becomes the active mode. Only that mode's `Think()` is then called.

> **Returning nil from `GetDesire()`** causes the engine to fall through to Valve's built-in desire calculation for that mode. This lets you selectively override desire only when you want to.

```lua
-- Example: Override push desire only when we have a numbers advantage
function GetDesire()
    local bot = GetBot()
    local nearbyAllies = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local nearbyEnemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if #nearbyAllies >= #nearbyEnemies + 2 then
        return BOT_MODE_DESIRE_HIGH
    end
    return nil  -- fall through to default desire
end
```

### Per-Hero Scripts (`ability_item_usage_generic.lua` / `ability_item_usage_[hero].lua`)

```lua
function AbilityLevelUpThink()   -- Called to decide which ability to level up
function AbilityUsageThink()     -- Called each frame for ability usage decisions
function ItemUsageThink()        -- Called each frame for item usage decisions
function BuybackUsageThink()     -- Called to decide whether to buy back
function CourierUsageThink()     -- Called for courier management
```

> **Important:** All Think functions in ability/item usage scripts are called **every frame regardless of the current active mode**. They run independently from the mode system.

### Item Purchase (`item_purchase_generic.lua` / `item_purchase_[hero].lua`)

```lua
function ItemPurchaseThink()     -- Called each frame for item purchasing
```

> `ItemPurchaseThink()` runs independently from both the mode system and ability usage system.

### Team-Level Scripts

```lua
-- team_desires.lua
function TeamThink()                -- Override team-level desires (runs ONCE per frame, BEFORE individual bot Think)
function UpdatePushLaneDesires()    -- Return {top, mid, bot} push desires
function UpdateDefendLaneDesires()  -- Return {top, mid, bot} defend desires
function UpdateFarmLaneDesires()    -- Return {top, mid, bot} farm desires
function UpdateRoamDesire()        -- Return desire, target
function UpdateRoshanDesire()      -- Return desire

-- hero_selection.lua
function Think()                   -- Called during hero pick phase
```

> **Execution order each frame:** `TeamThink()` runs first at the team level, then each individual bot's mode `GetDesire()` functions run, then the winning mode's `Think()` runs, then ability/item Think functions run.

### Bot Think (`bot_generic.lua`)

```lua
function MinionThink(hMinionUnit)  -- Called for summoned unit AI (e.g., Necronomicon, Treants)
```

---

## Time Functions

Three distinct clocks exist and serve different purposes. Using the wrong one leads to subtle timing bugs.

### `DotaTime()`

**Returns:** `float` -- Game clock time in seconds.

This is the **primary timer for all game logic**. It matches the in-game clock visible to players.

- **Negative during pre-game countdown.** Starts counting up from a negative value during the strategy phase. Reaches 0.0 at the horn (creeps spawn).
- Pauses when the game is paused.
- Affected by game speed changes (e.g., demo mode fast-forward).

```lua
-- Wait until creeps have spawned
if DotaTime() < 0 then return end

-- Check if it's past the 10-minute mark
if DotaTime() > 600 then
    -- Late laning / mid game logic
end
```

### `GameTime()`

**Returns:** `float` -- Time since hero selection phase began.

- **Always positive** (starts ticking from hero selection).
- Pauses when the game is paused.
- Use for cooldown tracking or timers that need to span the pre-game period.

```lua
-- Track when we last did something, even during pre-game
local lastActionTime = GameTime()
```

> **When to use `GameTime()` vs `DotaTime()`:** Use `DotaTime()` for anything related to game events (rune spawns, Roshan timer, creep waves). Use `GameTime()` when you need a monotonically increasing timer that works during pre-game.

### `RealTime()`

**Returns:** `float` -- Real-world elapsed time in seconds.

- **Unaffected by pause or game speed changes.**
- Use exclusively for performance measurement and profiling.

```lua
-- Measure how long a computation takes
local startTime = RealTime()
-- ... expensive computation ...
local elapsed = RealTime() - startTime
if elapsed > 0.01 then
    print("WARNING: computation took " .. elapsed .. " seconds")
end
```

---

## Team, Players, and Bot Handles

### `GetBot()`

**Returns:** `hUnit` -- Handle to the current script's bot hero.

This is the most frequently called function in bot scripts. It returns the hero unit handle for the bot whose script is currently executing.

> **ARDM caveat:** In All Random Deathmatch mode, `GetBot()` may return a **different handle** after a hero swap on death. Never cache the result across death boundaries. Bot handles can become **stale** in ARDM when heroes swap.

```lua
local bot = GetBot()
local myHP = bot:GetHealth()
local myLoc = bot:GetLocation()
```

### `GetTeam()`

**Returns:** `int` -- The bot's team constant (`TEAM_RADIANT` or `TEAM_DIRE`).

### `GetOpposingTeam()`

**Returns:** `int` -- The enemy team constant.

### `GetTeamPlayers(nTeam)`

**Parameters:**
- `nTeam` (int): `TEAM_RADIANT` or `TEAM_DIRE`

**Returns:** `{int...}` -- Table of player IDs (0-9) on the specified team.

```lua
local enemies = GetTeamPlayers(GetOpposingTeam())
for _, playerID in ipairs(enemies) do
    if IsHeroAlive(playerID) then
        -- enemy is alive
    end
end
```

### `GetTeamMember(nIndex)`

**Parameters:**
- `nIndex` (int): **1-indexed** position (1 through 5).

**Returns:** `hUnit` or `nil` -- Handle to the Nth player on the bot's team.

- Returns `nil` if the player slot doesn't exist (e.g., fewer than 5 players).
- **Can return human players too**, not just bots.
- The index is 1-based, matching Dota's team slot numbering.

```lua
-- Iterate all team members safely
for i = 1, 5 do
    local member = GetTeamMember(i)
    if member ~= nil then
        -- do something with this teammate
    end
end
```

### `IsTeamPlayer(nPlayerID)`

**Parameters:**
- `nPlayerID` (int): Player ID (0-9).

**Returns:** `bool` -- True if the player is on our team.

### `IsPlayerBot(nPlayerID)`

**Parameters:**
- `nPlayerID` (int): Player ID (0-9).

**Returns:** `bool` -- True if this player is AI-controlled (not a human).

### `GetTeamForPlayer(nPlayerID)`

**Parameters:**
- `nPlayerID` (int): Player ID (0-9).

**Returns:** `int` -- `TEAM_RADIANT` or `TEAM_DIRE`.

---

## Hero Stats (by Player ID)

All functions in this section take a **player ID** (0-9), not a unit handle. This is an important distinction -- these work even when you don't have a unit handle for the hero.

### `IsHeroAlive(nPlayerID)`

**Parameters:**
- `nPlayerID` (int): Player ID (0-9). **Not a unit handle.**

**Returns:** `bool` -- True if the player's current hero is alive.

> **This is the authoritative alive check for a player slot.** In ARDM, this reflects the player's CURRENT hero, not previous dead heroes. Always prefer this over `unit:IsAlive()` when checking if a player is alive, especially in ARDM.

```lua
-- Check if a specific enemy is alive
local enemyPlayers = GetTeamPlayers(GetOpposingTeam())
for _, pid in ipairs(enemyPlayers) do
    if IsHeroAlive(pid) then
        -- this enemy player's hero is alive
    end
end
```

### `GetHeroLevel(nPlayerID)`

**Returns:** `int` -- Hero level (1-30).

### `GetHeroKills(nPlayerID)` / `GetHeroDeaths(nPlayerID)` / `GetHeroAssists(nPlayerID)`

**Returns:** `int` -- Kill / death / assist count for the player.

### `GetHeroLastSeenInfo(nPlayerID)`

**Returns:** `table` -- Table with fields: `location` (vector), `time_since_seen` (float, seconds since last observed).

- Returns stale data if the hero hasn't been seen recently.
- Useful for estimating enemy positions when they're in fog.

```lua
local info = GetHeroLastSeenInfo(enemyPlayerID)
if info.time_since_seen < 5.0 then
    -- fairly recent sighting, location is somewhat reliable
end
```

### `GetSelectedHeroName(nPlayerID)`

**Returns:** `string` -- Internal hero name (e.g., `"npc_dota_hero_axe"`).

---

## Game State

### `GetGameState()`

**Returns:** `int` -- Current game phase. One of the `GAME_STATE_*` constants.

```lua
if GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS then return end
```

### `GetGameStateTimeRemaining()`

**Returns:** `float` -- Seconds remaining until the next state transition (e.g., time left in strategy phase).

### `GetGameMode()`

**Returns:** `int` -- Game mode constant. See [Constants: Game Modes](#game-modes).

```lua
if GetGameMode() == GAMEMODE_ARDM then
    -- handle ARDM-specific logic (stale handles, hero swaps, etc.)
end
```

### `GetHeroPickState()`

**Returns:** `int` -- Current hero pick/ban phase state (`HEROPICK_STATE_*`).

### `GetTimeOfDay()`

**Returns:** `float` -- Day/night cycle position. `0.0` = midnight, `0.25` = dawn, `0.5` = noon, `0.75` = dusk.

```lua
local isNight = GetTimeOfDay() < 0.25 or GetTimeOfDay() > 0.75
if isNight then
    -- reduced vision, play more cautiously
end
```

---

## Map and World

### `GetWorldBounds()`

**Returns:** `minX, minY, maxX, maxY` (four floats) -- The map boundary coordinates.

### `IsLocationPassable(vLoc)`

**Parameters:**
- `vLoc` (vector): World position to test.

**Returns:** `bool` -- True if a unit can walk through this location (not blocked by terrain, cliffs, or buildings).

```lua
-- Check before trying to move somewhere
local targetLoc = Vector(1000, 2000)
if IsLocationPassable(targetLoc) then
    bot:Action_MoveToLocation(targetLoc)
end
```

### `IsLocationVisible(vLoc)`

**Returns:** `bool` -- True if the location is currently visible to the bot's team (in team vision).

### `IsRadiusVisible(vLoc, fRadius)`

**Returns:** `bool` -- True if the **entire** radius around the location is visible. More restrictive than `IsLocationVisible`.

### `GetHeightLevel(vLoc)`

**Returns:** `int` -- Terrain height level (1-5). Useful for high ground / low ground checks.

### `GetAllTrees()`

**Returns:** `{hTree...}` -- Table of all tree handles on the map. This is a large table; cache the result if called frequently.

### `GetTreeLocation(nTree)`

**Parameters:**
- `nTree` (handle/int): Tree handle from `GetAllTrees()` or `GetNearbyTrees()`.

**Returns:** `vector` -- World position of the tree.

---

## Distance Functions

### `GetUnitToUnitDistance(hA, hB)`

**Parameters:**
- `hA`, `hB` (hUnit): Two unit handles.

**Returns:** `float` -- **Edge-to-edge** distance between the two units.

> **Gotcha:** This subtracts both units' bounding radii from the center-to-center distance. A return value of 0 means the units are touching. This matches how ability cast ranges work in Dota.

### `GetUnitToUnitDistanceSqr(hA, hB)`

**Returns:** `float` -- Squared edge-to-edge distance. **Use this for comparisons** -- it avoids the expensive square root operation.

```lua
-- GOOD: Compare squared distances (fast)
if GetUnitToUnitDistanceSqr(bot, enemy) < 600 * 600 then
    -- within 600 range
end

-- BAD: Unnecessary sqrt
if GetUnitToUnitDistance(bot, enemy) < 600 then
    -- same check but slower
end
```

### `GetUnitToLocationDistance(hUnit, vLoc)` / `GetUnitToLocationDistanceSqr(hUnit, vLoc)`

**Returns:** `float` -- Distance (or squared distance) from a unit to a world point.

### `PointToLineDistance(vStart, vEnd, vPoint)`

**Parameters:**
- `vStart` (vector): Line segment start point.
- `vEnd` (vector): Line segment end point.
- `vPoint` (vector): The point to measure from.

**Returns:** Three values:
1. `dist` (float): Perpendicular distance from the point to the line segment.
2. `closest` (vector): The closest point on the line segment to `vPoint`.
3. `within` (bool): Whether the closest point falls within the segment (not past either endpoint).

```lua
local dist, closestPt, isWithin = PointToLineDistance(segStart, segEnd, myPos)
if isWithin and dist < 200 then
    -- we're close to the middle of this line segment
end
```

---

## Lanes and Creep Equilibrium

Lane constants: `LANE_TOP` = 1, `LANE_MID` = 2, `LANE_BOT` = 3.

### `GetLaneFrontAmount(nTeam, nLane, bIgnoreTowers)`

**Parameters:**
- `nTeam` (int): `TEAM_RADIANT` or `TEAM_DIRE`.
- `nLane` (int): `LANE_TOP`, `LANE_MID`, or `LANE_BOT`.
- `bIgnoreTowers` (bool): If true, estimates where creeps would be without tower influence.

**Returns:** `float` -- Creep equilibrium position as a ratio.
- `0.0` = your team's ancient.
- `1.0` = the enemy team's ancient.
- `0.5` = roughly the river / midpoint.

```lua
local frontAmount = GetLaneFrontAmount(GetTeam(), LANE_MID, false)
if frontAmount > 0.6 then
    -- creep wave is pushed past the river toward the enemy
end
```

### `GetLaneFrontLocation(nTeam, nLane, fDelta)`

**Parameters:**
- `nTeam` (int): Team.
- `nLane` (int): Lane.
- `fDelta` (float): Offset from the lane front.
  - **Negative** = shift toward your base.
  - **Positive** = shift toward the enemy base.
  - `0` = exactly at the lane front.

**Returns:** `vector` -- World position of the (offset) lane front.

```lua
-- Get a position slightly behind the creep wave (safe farm spot)
local safeFarmLoc = GetLaneFrontLocation(GetTeam(), LANE_MID, -500)
```

### `GetLocationAlongLane(nLane, fAmount)`

**Parameters:**
- `nLane` (int): Lane.
- `fAmount` (float): Ratio along the lane path (0.0 = Radiant ancient, 1.0 = Dire ancient).

**Returns:** `vector` -- World position at that ratio along the lane path.

### `GetAmountAlongLane(nLane, vLoc)`

**Parameters:**
- `nLane` (int): Lane.
- `vLoc` (vector): World position.

**Returns:** Two values:
1. `amount` (float): The closest ratio along the lane path (0.0 - 1.0).
2. `distance` (float): Perpendicular distance from `vLoc` to the lane path.

---

## Structures

### `GetTower(nTeam, nTower)`

**Parameters:**
- `nTeam` (int): `TEAM_RADIANT` or `TEAM_DIRE`.
- `nTower` (int): Tower constant (e.g., `TOWER_TOP_1`, `TOWER_MID_2`, `TOWER_BASE_1`).

**Returns:** `hUnit` -- Tower unit handle (may be nil or dead).

```lua
local topT1 = GetTower(GetTeam(), TOWER_TOP_1)
if topT1 ~= nil and topT1:IsAlive() then
    -- our top T1 is still standing
end
```

### `GetTowerAttackTarget(nTeam, nTower)`

**Returns:** `hUnit` or `nil` -- The unit the tower is currently attacking. `nil` if the tower isn't attacking anything.

### `GetBarracks(nTeam, nBarracks)`

**Returns:** `hUnit` -- Barracks handle (e.g., `BARRACKS_TOP_MELEE`).

### `GetShrine(nTeam, nShrine)`

**Returns:** `hUnit` -- Shrine handle.

### `GetAncient(nTeam)`

**Returns:** `hUnit` -- The Ancient/Throne unit handle.

### `GetShopLocation(nTeam, nShop)`

**Parameters:**
- `nShop` (int): `SHOP_HOME`, `SHOP_SIDE`, `SHOP_SECRET`, `SHOP_SIDE2`, `SHOP_SECRET2`.

**Returns:** `vector` -- World position of the shop.

### `GetRuneSpawnLocation(nRuneLoc)`

**Parameters:**
- `nRuneLoc` (int): `RUNE_POWERUP_1`, `RUNE_POWERUP_2`, `RUNE_BOUNTY_1` through `RUNE_BOUNTY_4`.

**Returns:** `vector` -- World position of the rune spawn point.

---

## Items (Global)

### `GetItemCost(sName)`

**Parameters:**
- `sName` (string): Internal item name (e.g., `"item_blink"`).

**Returns:** `int` -- Gold cost of the item.

### `GetItemComponents(sName)`

**Parameters:**
- `sName` (string): Internal item name.

**Returns:** `{{string...}...}` -- Nested table of recipe components. Each sub-table represents one recipe variant.

> **Always use this function** instead of hardcoding component arrays. Valve updates recipes between patches, and this function reads the current game data.

```lua
local components = GetItemComponents("item_mekansm")
-- components[1] = {"item_headdress", "item_buckler", "item_recipe_mekansm"}
```

### `IsItemPurchasedFromSecretShop(sName)` / `IsItemPurchasedFromSideShop(sName)`

**Returns:** `bool` -- Whether the item must be purchased at a secret/side shop.

### `GetItemStockCount(sName)`

**Returns:** `int` -- Current stock count. Some items have limited stock (e.g., Observer Wards, Gems).

### `GetDroppedItemList()`

**Returns:** `{table...}` -- Table of tables, each containing:
- `item` (hItem): Item handle.
- `owner` (int): Owning player ID (-1 if unowned).
- `playerid` (int): Player who dropped it.
- `location` (vector): World position.

---

## Runes

### `GetRuneType(nLoc)`

**Parameters:**
- `nLoc` (int): Rune location constant (`RUNE_POWERUP_1`, `RUNE_BOUNTY_1`, etc.).

**Returns:** `int` -- Rune type constant (`RUNE_DOUBLEDAMAGE`, `RUNE_HASTE`, `RUNE_BOUNTY`, etc.). Returns `RUNE_INVALID` if no rune or unknown.

### `GetRuneStatus(nLoc)`

**Returns:** `int` -- One of:
- `RUNE_STATUS_UNKNOWN` -- Haven't scouted this location.
- `RUNE_STATUS_AVAILABLE` -- Rune is confirmed present.
- `RUNE_STATUS_MISSING` -- Location scouted, no rune there.

### `GetRuneTimeSinceSeen(nLoc)`

**Returns:** `float` -- Seconds since the rune location was last observed by your team. Large values mean stale information.

```lua
-- Only go for rune if we know it's there
if GetRuneStatus(RUNE_POWERUP_1) == RUNE_STATUS_AVAILABLE then
    bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_POWERUP_1))
end
```

---

## Unit Queries

### `GetUnitList(nType)`

**Parameters:**
- `nType` (int): Unit type filter. One of the `UNIT_LIST_*` constants.

**Returns:** `{hUnit...}` -- Table of all matching unit handles **across the entire map**.

> **Performance warning:** This is an expensive function. It scans all units in the game. **Use `GetNearby*` functions instead whenever possible.** Only use `GetUnitList` when you genuinely need a global search (e.g., finding all enemy heroes regardless of distance).

```lua
-- Find all enemy heroes (expensive, use sparingly)
local allEnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)

-- BETTER: If you only need nearby enemies
local nearbyEnemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
```

### `GetNeutralSpawners()`

**Returns:** `{table...}` -- Table of tables, each containing:
- `team` (int): Which team's jungle.
- `type` (int): Camp type (small, medium, large, ancient).
- `speed` (float): Creep movement speed.
- `location` (vector): Camp spawn location.
- `min` (vector): Spawn box minimum corner.
- `max` (vector): Spawn box maximum corner.

### `GetIncomingTeleports()`

**Returns:** `{table...}` -- Active TP scroll teleportations, each containing:
- `playerid` (int): Who is teleporting.
- `location` (vector): TP destination.
- `time_remaining` (float): Seconds until arrival.

```lua
local tps = GetIncomingTeleports()
for _, tp in ipairs(tps) do
    if tp.time_remaining < 1.0 then
        -- someone is about to arrive
    end
end
```

---

## Projectiles and Avoidance

### `GetLinearProjectiles()`

**Returns:** `{table...}` -- All active linear (skillshot) projectiles, each containing:
- `location` (vector): Current projectile position.
- `caster` (hUnit): Who fired it.
- `playerid` (int): Caster's player ID.
- `ability` (hAbility): Source ability handle.
- `velocity` (vector): Direction and speed.
- `radius` (float): Projectile collision radius.
- `handle` (int): Unique projectile handle.

### `GetAvoidanceZones()`

**Returns:** `{table...}` -- Persistent area effects to avoid, each containing:
- `location` (vector): Center position.
- `playerid` (int): Source player ID.
- `ability` (hAbility): Source ability.
- `caster` (hUnit): Source unit.
- `radius` (float): Effect radius.

### `AddAvoidanceZone(vLocAndRadius, fDuration)`

**Parameters:**
- `vLocAndRadius` (vector): Position (x, y) and radius (z component).
- `fDuration` (float): How long the zone persists.

**Returns:** `int` -- Handle for later removal.

### `RemoveAvoidanceZone(hZone)`

**Parameters:**
- `hZone` (int): Handle returned by `AddAvoidanceZone`.

---

## Team Desires

These functions read the current team-level desires, typically set by `team_desires.lua`.

### `GetPushLaneDesire(nLane)` / `GetDefendLaneDesire(nLane)` / `GetFarmLaneDesire(nLane)`

**Parameters:**
- `nLane` (int): `LANE_TOP`, `LANE_MID`, or `LANE_BOT`.

**Returns:** `float` -- Desire value (0.0 - 1.0).

### `GetRoamDesire()`

**Returns:** `float` -- Team roam desire.

### `GetRoamTarget()`

**Returns:** `hUnit` -- The current roam target unit handle.

### `GetRoshanDesire()`

**Returns:** `float` -- Team Roshan desire.

---

## Roshan and Glyph

### `GetRoshanKillTime()`

**Returns:** `float` -- `DotaTime()` timestamp of the last Roshan kill. Returns 0 if Roshan hasn't been killed yet.

```lua
local roshTimer = DotaTime() - GetRoshanKillTime()
if GetRoshanKillTime() > 0 and roshTimer > 480 then
    -- Roshan may have respawned (8-11 min window)
end
```

### `GetGlyphCooldown()`

**Returns:** `float` -- Seconds remaining on the team's Glyph of Fortification cooldown. Returns 0 if ready.

---

## Courier System

### `IsCourierAvailable()`

**Returns:** `bool` -- True if a courier is alive and usable.

### `GetNumCouriers()`

**Returns:** `int` -- Number of couriers your team has.

### `GetCourier(nIndex)`

**Parameters:**
- `nIndex` (int): **0-indexed** courier index.

**Returns:** `hCourier` -- Courier unit handle.

```lua
-- Get the first (usually only) courier
local courier = GetCourier(0)
```

### `GetCourierState(hCourier)`

**Returns:** `int` -- One of the `COURIER_STATE_*` constants:
- `COURIER_STATE_IDLE` -- At base, doing nothing.
- `COURIER_STATE_AT_BASE` -- At base.
- `COURIER_STATE_MOVING` -- Moving (not delivering).
- `COURIER_STATE_DELIVERING_ITEMS` -- Actively delivering to a hero.
- `COURIER_STATE_RETURNING_TO_BASE` -- Heading back to base.
- `COURIER_STATE_DEAD` -- Courier is dead.

### `IsFlyingCourier(hCourier)`

**Returns:** `bool` -- True if the courier can fly.

### Courier Actions

Use `ActionImmediate_Courier(hCourier, nAction)` to command a courier. The most common action:

```lua
-- Deliver items from stash to your hero
local courier = GetCourier(0)
if GetCourierState(courier) == COURIER_STATE_IDLE then
    bot:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
end
```

> **Tip:** Check `GetStashValue()` and `GetCourierValue()` to decide whether it's worth using the courier.

---

## Hero Selection and Captains Mode

### Hero Selection

```lua
SelectHero(nPlayerID, sHeroName)              -- Select a hero for a player
IsPlayerInHeroSelectionControl(nPlayerID)      -- Does this player control hero selection?
```

### Captains Mode

```lua
IsInCMBanPhase()                -- Returns bool: currently in ban phase?
IsInCMPickPhase()               -- Returns bool: currently in pick phase?
GetCMPhaseTimeRemaining()       -- Returns float: seconds left in current phase
GetCMCaptain()                  -- Returns int: captain's player ID
SetCMCaptain(nPlayerID)         -- Set captain
IsCMBannedHero(sName)           -- Returns bool: is this hero banned?
IsCMPickedHero(nTeam, sName)    -- Returns bool: has this team picked this hero?
CMBanHero(sName)                -- Execute a ban
CMPickHero(sName)               -- Execute a pick
```

---

## Math and Random

### Math Utilities

```lua
Min(a, b)                                     -- Returns the smaller value
Max(a, b)                                     -- Returns the larger value
Clamp(val, min, max)                          -- Constrain val to [min, max]
RemapVal(val, fromMin, fromMax, toMin, toMax) -- Linear remap (unclamped -- can exceed output range!)
RemapValClamped(val, fromMin, fromMax, toMin, toMax)  -- Linear remap (clamped to output range)
```

> **Gotcha:** `RemapVal` does NOT clamp output. If `val` is outside `[fromMin, fromMax]`, the output will be outside `[toMin, toMax]`. Use `RemapValClamped` to guarantee the output stays in range.

```lua
-- Map health percentage (0-100) to flee desire (0.0-1.0), clamped
local hpPercent = bot:GetHealth() / bot:GetMaxHealth() * 100
local fleeDesire = RemapValClamped(hpPercent, 30, 80, 1.0, 0.0)
-- At 30% HP -> desire 1.0, at 80% HP -> desire 0.0
```

### Random

```lua
RandomInt(min, max)          -- Random integer in [min, max] (inclusive)
RandomFloat(min, max)        -- Random float in [min, max]
RandomVector(fLength)        -- Random 2D direction vector of given length
RollPercentage(nChance)      -- Returns true with nChance% probability (1-100)
```

```lua
if RollPercentage(25) then
    -- 25% chance to execute this block
end

-- Random scatter location
local scatterDir = RandomVector(200)
local scatterLoc = bot:GetLocation() + scatterDir
```

---

## Callbacks

Callbacks let you react to game events. They persist for the entire game duration -- install them once at initialization, not every frame.

### `InstallDamageCallback(nPlayerID, func)`

**Parameters:**
- `nPlayerID` (int): Player whose damage events to listen for.
- `func` (function): Called with `(hVictim, hAttacker, nDamage)`.

```lua
InstallDamageCallback(bot:GetPlayerID(), function(victim, attacker, damage)
    if damage > 200 then
        -- significant damage taken
    end
end)
```

### `InstallCastCallback(nPlayerID, func)`

**Parameters:**
- `nPlayerID` (int): Player whose casts to listen for.
- `func` (function): Called when the player casts an ability or uses an item.

### `InstallCourierDeathCallback(func)`

Called when any courier dies.

### `InstallRoshanDeathCallback(func)`

Called when Roshan is killed.

### `InstallChatCallback(func)`

**Parameters:**
- `func` (function): Called with a table containing:
  - `string` (string): The chat message text.
  - `playerid` (int): Who sent the message.
  - `teamonly` (bool): True if team chat, false if all chat.

```lua
InstallChatCallback(function(msg)
    if msg.string == "push mid" and msg.teamonly then
        -- teammate is requesting a mid push
    end
end)
```

> **Important:** Callbacks persist for the game duration. Do not reinstall them every frame or you will get duplicate calls.

---

## Debug and HTTP

### Debug Drawing

All debug draw functions render for **one frame only**. Call them every frame to maintain visibility.

```lua
DebugDrawLine(vStart, vEnd, r, g, b)       -- Draw a line (r,g,b = 0-255)
DebugDrawCircle(vCenter, fRadius, r, g, b)  -- Draw a circle
DebugDrawText(fX, fY, sText, r, g, b)      -- Render text overlay (screen coordinates)
DebugPause()                                -- Pause game execution (for debugging)
```

### HTTP Requests

```lua
CreateHTTPRequest(url)        -- Returns handle (localhost only)
CreateRemoteHTTPRequest(url)  -- Returns handle (remote servers)
```

> HTTP requests are sandboxed. `CreateHTTPRequest` only allows localhost connections. Use `CreateRemoteHTTPRequest` for external API calls.

---

## Unit Functions

All functions in this section are called on a unit handle: `bot:FunctionName(...)` or `hUnit:FunctionName(...)`.

### Identity

| Function | Returns | Description |
|---|---|---|
| `GetUnitName()` | `string` | Internal unit name (e.g., `"npc_dota_hero_axe"`, `"npc_dota_creep_goodguys_melee"`) |
| `GetPlayerID()` | `int` | Owning player ID. Returns -1 for non-player units (creeps, neutrals). |
| `GetTeam()` | `int` | Team affiliation (`TEAM_RADIANT`, `TEAM_DIRE`, `TEAM_NEUTRAL`) |
| `IsBot()` | `bool` | True if this is an AI-controlled player's hero |
| `GetDifficulty()` | `int` | Bot difficulty level (`DIFFICULTY_*`). Only meaningful for bot-controlled heroes. |

### Unit Classification

| Function | Returns | Description |
|---|---|---|
| `IsHero()` | `bool` | True for hero units (including illusions and clones) |
| `IsIllusion()` | `bool` | True for illusions only. Note: Meepo clones return false. |
| `IsCourier()` | `bool` | True for courier units |
| `IsCreep()` | `bool` | True for lane creeps |
| `IsAncientCreep()` | `bool` | True for ancient neutral creeps |
| `IsBuilding()` | `bool` | True for structures (towers, barracks, ancient) |
| `IsTower()` | `bool` | True specifically for towers |
| `IsFort()` | `bool` | True specifically for the Ancient building |
| `IsMinion()` | `bool` | True for bot-controlled summons (Treants, Necronomicon, etc.) |

### Health and Mana

| Function | Returns | Description |
|---|---|---|
| `GetHealth()` | `int` | Current HP |
| `GetMaxHealth()` | `int` | Maximum HP |
| `GetHealthRegen()` | `float` | Total HP regeneration per second (including all bonuses) |
| `GetBaseHealthRegen()` | `float` | Base HP regen before item/buff bonuses |
| `GetMana()` | `int` | Current mana |
| `GetMaxMana()` | `int` | Maximum mana |
| `GetManaRegen()` | `float` | Total mana regeneration per second |
| `GetBaseManaRegen()` | `float` | Base mana regen before bonuses |

### `IsAlive()`

**Returns:** `bool` -- True if this specific unit entity is alive.

> **ARDM warning:** A dead hero entity may still exist in memory while the player already has a new alive hero. For checking whether a *player* is alive, always use the global `IsHeroAlive(playerID)` instead.

### `GetRespawnTime()`

**Returns:** `float` -- Seconds until this hero respawns. Returns `-1` for non-hero units.

### `GetRemainingLifespan()`

**Returns:** `float` -- Remaining duration for temporary/summoned units (e.g., Treants, illusions). Returns a large number for permanent units.

### Buyback

| Function | Returns | Description |
|---|---|---|
| `HasBuyback()` | `bool` | Can this hero buy back? Returns `false` for enemy heroes (hidden info). |
| `GetBuybackCost()` | `int` | Gold required. Returns `-1` for enemy heroes. |
| `GetBuybackCooldown()` | `float` | Cooldown remaining. Returns `-1` for enemy heroes. |

> **Enemy buyback info is hidden.** All buyback functions return dummy values for enemy heroes because buyback status is not public information.

### Combat Stats

| Function | Returns | Description |
|---|---|---|
| `GetBaseDamage()` | `float` | Average base attack damage (no bonus damage) |
| `GetBaseDamageVariance()` | `float` | +/- damage variation from base |
| `GetAttackDamage()` | `float` | Total attack damage including all bonuses |
| `GetAttackRange()` | `int` | Current attack range in units |
| `GetAttackSpeed()` | `int` | Attack speed value |
| `GetSecondsPerAttack()` | `float` | Time for one full attack cycle (wind-up + backswing) |
| `GetAttackPoint()` | `float` | Attack animation wind-up time (damage dealt at this point) |
| `GetLastAttackTime()` | `float` | `GameTime()` timestamp of last attack |
| `GetAttackTarget()` | `hUnit` | Unit currently being attacked (nil if not attacking) |
| `GetAcquisitionRange()` | `int` | Range at which the unit auto-acquires targets |
| `GetAttackProjectileSpeed()` | `int` | Projectile speed for ranged attacks. 0 for melee. |

### Damage Calculation

### `GetActualIncomingDamage(nDmg, nType)`

**Parameters:**
- `nDmg` (int): Raw damage amount.
- `nType` (int): `DAMAGE_TYPE_PHYSICAL`, `DAMAGE_TYPE_MAGICAL`, or `DAMAGE_TYPE_PURE`.

**Returns:** `float` -- Damage after armor/magic resistance reduction.

```lua
-- Calculate if a nuke would kill the enemy
local actualDmg = enemy:GetActualIncomingDamage(300, DAMAGE_TYPE_MAGICAL)
if enemy:GetHealth() <= actualDmg then
    -- this nuke will kill them
end
```

### `GetEstimatedDamageToTarget(bAvailable, hTarget, fDuration, nDamageTypes)`

**Parameters:**
- `bAvailable` (bool): If true, only count abilities that are currently castable (off cooldown, have mana).
- `hTarget` (hUnit): Target unit to estimate damage against.
- `fDuration` (float): Time window in seconds for the estimate.
- `nDamageTypes` (int): Bitfield of damage types to include (`DAMAGE_TYPE_PHYSICAL`, `DAMAGE_TYPE_MAGICAL`, `DAMAGE_TYPE_ALL`).

**Returns:** `float` -- Estimated total damage output against the target.

| Function | Returns | Description |
|---|---|---|
| `GetAttackCombatProficiency(hTarget)` | `float` | Outgoing damage multiplier vs specific target |
| `GetDefendCombatProficiency(hAttacker)` | `float` | Incoming damage multiplier from specific attacker |
| `GetOffensivePower()` | `float` | Estimated total damage output (respects cooldowns/mana) |
| `GetRawOffensivePower()` | `float` | Damage output ignoring cooldowns and mana |

### Defense Stats

| Function | Returns | Description |
|---|---|---|
| `GetArmor()` | `float` | Current armor value (can be negative) |
| `GetMagicResist()` | `float` | Magic resistance as a fraction (0.25 = 25%) |
| `GetEvasion()` | `float` | Evasion chance as a fraction |
| `GetSpellAmp()` | `float` | Spell amplification as a fraction |

### Movement and Position

| Function | Returns | Description |
|---|---|---|
| `GetLocation()` | `vector` | Current world position |
| `GetFacing()` | `int` | Facing direction in degrees (0-359, 0 = east, 90 = north) |
| `GetBaseMovementSpeed()` | `int` | Base movement speed (before boots/buffs) |
| `GetCurrentMovementSpeed()` | `int` | Current effective movement speed |
| `GetVelocity()` | `vector` | Current velocity vector |
| `GetGroundHeight()` | `float` | Terrain height at unit's current position |
| `GetBoundingRadius()` | `float` | Unit's collision radius |

### `IsFacingLocation(vLoc, nDegrees)`

**Parameters:**
- `vLoc` (vector): Target location.
- `nDegrees` (int): Cone half-angle in degrees.

**Returns:** `bool` -- True if the unit is facing within the specified cone toward the location.

```lua
if bot:IsFacingLocation(enemy:GetLocation(), 30) then
    -- we're roughly facing the enemy (within 30 degrees)
end
```

### `GetExtrapolatedLocation(fTime)`

**Parameters:**
- `fTime` (float): Seconds into the future.

**Returns:** `vector` -- Predicted position assuming the unit continues its current movement.

### `GetMovementDirectionStability()`

**Returns:** `float` -- 0.0 (erratic movement) to 1.0 (stable straight-line movement). Useful for deciding whether to lead skillshots.

### Attributes and Level

| Function | Returns | Description |
|---|---|---|
| `GetLevel()` | `int` | Current hero level (1-30) |
| `GetPrimaryAttribute()` | `int` | `ATTRIBUTE_STRENGTH`, `ATTRIBUTE_AGILITY`, or `ATTRIBUTE_INTELLECT` |
| `GetAttributeValue(nAttrib)` | `int` | Value of the specified attribute. Returns `-1` for non-heroes. |
| `GetAbilityPoints()` | `int` | Unspent ability points |
| `HasScepter()` | `bool` | Has Aghanim's Scepter upgrade (buff or item)? |

### Economy

### `GetGold()`

**Returns:** `int` -- Current total gold (reliable + unreliable combined).

### `GetNetWorth()`

**Returns:** `int` -- Total net worth (gold + item values + everything).

### `GetStashValue()`

**Returns:** `int` -- Total value of items in the hero's stash. Useful for deciding when to use the courier.

### `GetCourierValue()`

**Returns:** `int` -- Total value of items assigned to this hero on the courier.

| Function | Returns | Description |
|---|---|---|
| `GetLastHits()` | `int` | Last hit count |
| `GetDenies()` | `int` | Deny count |
| `GetBountyXP()` | `int` | XP reward for killing this unit |
| `GetBountyGoldMin()` / `GetBountyGoldMax()` | `int` | Gold bounty range for killing this unit |
| `GetXPNeededToLevel()` | `int` | XP needed for next level. Returns `-1` for non-heroes. |

### Proximity to Shops

| Function | Returns | Description |
|---|---|---|
| `DistanceFromFountain()` | `int` | Distance to fountain. Returns `0` when in fountain range. |
| `DistanceFromSecretShop()` | `int` | Distance to nearest secret shop. `0` = in range. |
| `DistanceFromSideShop()` | `int` | Distance to nearest side shop. `0` = in range. |

```lua
-- Check if we can buy from secret shop
if bot:DistanceFromSecretShop() == 0 then
    bot:ActionImmediate_PurchaseItem("item_ultimate_orb")
end
```

### Vision

| Function | Returns | Description |
|---|---|---|
| `GetCurrentVisionRange()` | `int` | Active vision radius (changes with day/night) |
| `GetDayTimeVisionRange()` | `int` | Vision range during daytime |
| `GetNightTimeVisionRange()` | `int` | Vision range at night |
| `CanBeSeen()` | `bool` | Is this unit visible to the enemy team? |

### Status Effects

| Function | Returns | Notes |
|---|---|---|
| `IsStunned()` | `bool` | Unit is stunned |
| `IsRooted()` | `bool` | Unit is rooted (can't move, can still cast/attack) |
| `IsSilenced()` | `bool` | Unit is silenced (can't cast abilities) |
| `IsHexed()` | `bool` | Unit is hexed/polymorphed |
| `IsDisarmed()` | `bool` | Unit can't attack |
| `IsMuted()` | `bool` | Item passives disabled |
| `IsNightmared()` | `bool` | Bane Nightmare or similar |
| `IsBlind()` | `bool` | Attacks will miss |
| `IsInvulnerable()` | `bool` | Immune to all damage |
| `IsMagicImmune()` | `bool` | Immune to magic damage and most spells |
| `IsAttackImmune()` | `bool` | Cannot be attacked |
| `IsDominated()` | `bool` | Unit is dominated (Helm of the Overlord, etc.) |
| `IsEvadeDisabled()` | `bool` | Evasion disabled (MKB, etc.) |
| `IsBlockDisabled()` | `bool` | Damage block disabled |
| `IsUnableToMiss()` | `bool` | True Strike -- attacks cannot miss |
| `IsSpeciallyDeniable()` | `bool` | Can be denied by allies (e.g., under specific DoTs) |

### `IsInvisible()`

**Returns:** `bool` -- True if the unit **has an invisibility buff**.

> **Critical gotcha:** This does NOT mean the unit is undetected. A unit can be `IsInvisible() == true` AND still fully visible to enemies via Sentry Wards, Dust, Gem, or tower true sight. To check if a unit is actually unseen, you need different logic. This function only tells you the unit has an invis modifier active.

### Combat Analysis

| Function | Returns | Description |
|---|---|---|
| `GetStunDuration(bAvailable)` | `float` | Total available stun duration in seconds. `bAvailable=true` only counts ready abilities. |
| `GetSlowDuration(bAvailable)` | `float` | Total available slow duration. |
| `HasBlink(bAvailable)` | `bool` | Has a blink ability or item? |
| `HasMinistunOnAttack()` | `bool` | Has an attack mini-stun (e.g., MKB)? |
| `HasSilence(bAvailable)` | `bool` | Has a silence ability? |
| `HasInvisibility(bAvailable)` | `bool` | Has an invis ability? |
| `UsingItemBreaksInvisibility()` | `bool` | Would using an item break this unit's current invis? |

### Damage History

| Function | Returns | Description |
|---|---|---|
| `WasRecentlyDamagedByAnyHero(fInterval)` | `bool` | Damaged by any hero within `fInterval` seconds? |
| `TimeSinceDamagedByAnyHero()` | `float` | Seconds since last hero damage. Large value if never damaged. |
| `WasRecentlyDamagedByHero(hUnit, fInterval)` | `bool` | Damaged by a specific hero? |
| `WasRecentlyDamagedByCreep(fInterval)` | `bool` | Damaged by a creep? |
| `WasRecentlyDamagedByTower(fInterval)` | `bool` | Damaged by a tower? |

```lua
-- Flee if recently damaged by an enemy hero
if bot:WasRecentlyDamagedByAnyHero(3.0) then
    -- we took hero damage in the last 3 seconds
end
```

### Nearby Unit Detection

All `GetNearby*` functions are called on a unit handle and search around that unit.

> **Maximum radius is 1600.** Values above 1600 are silently clamped. If you need a larger search, use `GetUnitList()` and filter manually.

All return tables **sorted by distance** (closest first). Return an **empty table** (not nil) if none found.

### `GetNearbyHeroes(nRadius, bEnemies, nMode)`

**Parameters:**
- `nRadius` (int): Search radius (max 1600).
- `bEnemies` (bool): `true` = enemy heroes, `false` = allied heroes.
- `nMode` (int): Bot mode filter. **Pass `BOT_MODE_NONE` to get all heroes.** Other modes filter to only heroes in that mode.

**Returns:** `{hUnit...}` -- Table of hero handles sorted by distance.

```lua
-- Get all enemies within 1200 range
local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
if #enemies >= 3 then
    -- outnumbered, consider retreating
end
```

### `GetNearbyCreeps(nRadius, bEnemies)`

**Parameters:**
- `nRadius` (int): Search radius (max 1600).
- `bEnemies` (bool): `true` = enemy creeps, `false` = allied creeps.

**Returns:** `{hUnit...}` -- All creeps (lane + jungle + summons) within range.

### `GetNearbyLaneCreeps(nRadius, bEnemies)`

**Returns:** `{hUnit...}` -- **Only lane creeps** within range. Does not include jungle creeps or summoned units.

### `GetNearbyNeutralCreeps(nRadius)`

**Parameters:**
- `nRadius` (int): Search radius (max 1600).

**Returns:** `{hUnit...}` -- Neutral creeps within range.

> **Note:** This function does NOT take a `bEnemies` parameter. It always returns all nearby neutral creeps regardless of who "owns" them.

### `GetNearbyTowers(nRadius, bEnemies)` / `GetNearbyBarracks(nRadius, bEnemies)`

**Returns:** `{hUnit...}` -- Towers or barracks within range.

### `GetNearbyTrees(nRadius)`

**Returns:** `{int...}` -- Tree IDs (handles) within range. Use `GetTreeLocation(id)` to get positions.

### AoE Targeting

### `FindAoELocation(bEnemies, bHeroes, vBaseLocation, nMaxDistanceFromBase, nRadius, fTimeInFuture, nMaxHealth)`

**Parameters:**
- `bEnemies` (bool): Target enemies (`true`) or allies (`false`).
- `bHeroes` (bool): Target heroes (`true`) or creeps (`false`).
- `vBaseLocation` (vector): Center of the search area.
- `nMaxDistanceFromBase` (int): Search radius from `vBaseLocation`.
- `nRadius` (int): The AoE ability's effect radius.
- `fTimeInFuture` (float): Predict unit positions this many seconds ahead. Use 0 for instant spells.
- `nMaxHealth` (int): Only target units below this HP. Pass `0` for no HP filter (target any HP).

**Returns:** A table with:
- `count` (int): Number of units that would be hit.
- `targetloc` (vector): Optimal point to center the AoE.

```lua
-- Find best location for a 300-radius AoE spell on enemy heroes
local result = bot:FindAoELocation(true, true, bot:GetLocation(), 900, 300, 0.5, 0)
if result.count >= 2 then
    bot:Action_UseAbilityOnLocation(abilityHandle, result.targetloc)
end
```

### Modifiers (Buffs/Debuffs)

### `HasModifier(sName)`

**Parameters:**
- `sName` (string): The modifier's **internal name** (e.g., `"modifier_fountain_aura_buff"`, `"modifier_item_blade_mail_reflect"`).

**Returns:** `bool`

> **Gotcha:** The modifier name must be the exact internal name, not the display name. These are typically `modifier_[source]_[effect]` format.

### `GetModifierByName(sName)`

**Returns:** `int` -- Modifier index for use with other modifier functions. Returns -1 if not found.

### `GetModifierRemainingDuration(nIndex)`

**Parameters:**
- `nIndex` (int): Modifier index from `GetModifierByName()` or iteration. **Not the modifier name string.**

**Returns:** `float` -- Seconds remaining. Returns -1 for permanent modifiers.

```lua
-- Check remaining duration of a specific debuff
local modIndex = bot:GetModifierByName("modifier_crystal_maiden_frostbite")
if modIndex ~= -1 then
    local remaining = bot:GetModifierRemainingDuration(modIndex)
    -- remaining seconds of Frostbite
end
```

| Function | Returns | Description |
|---|---|---|
| `NumModifiers()` | `int` | Total number of active modifiers |
| `GetModifierList()` | `{string...}` | Table of all modifier names |
| `GetModifierName(nIndex)` | `string` | Modifier name by index |
| `GetModifierStackCount(nIndex)` | `int` | Stack count (e.g., Flesh Heap stacks) |
| `GetModifierSourceAbility(nIndex)` | `hAbility` | The ability that applied this modifier |
| `GetModifierAuxiliaryUnits(nIndex)` | `{hUnit...}` | Units associated with the modifier |

### Ping

### `GetMostRecentPing()`

**Returns:** A table with:
- `time` (float): `GameTime()` timestamp when the ping was placed.
- `location` (vector): World position of the ping.
- `normal_ping` (bool): `true` = "gather here" ping, `false` = danger/warning ping (X mark).
- `player_id` (int): Who placed the ping.

> **Only returns the single most recent ping**, not a history. If you need to track multiple pings, you must poll this function and store results yourself.

```lua
local ping = bot:GetMostRecentPing()
if ping.normal_ping and GameTime() - ping.time < 5.0 then
    -- teammate pinged "gather here" within the last 5 seconds
    bot:Action_MoveToLocation(ping.location)
end
```

### Incoming Projectiles

### `GetIncomingTrackingProjectiles()`

**Returns:** `{table...}` -- Tracking projectiles heading toward this unit, each containing:
- `location` (vector): Current projectile position.
- `caster` (hUnit): Who fired it.
- `playerid` (int): Caster's player ID.
- `ability` (hAbility): Source ability/item.
- `is_dodgeable` (bool): Can this be dodged by going invis/invulnerable?
- `is_attack` (bool): True if it's a basic attack projectile, false if ability.

```lua
local projectiles = bot:GetIncomingTrackingProjectiles()
for _, proj in ipairs(projectiles) do
    if proj.is_dodgeable and not proj.is_attack then
        -- incoming dodgeable spell projectile -- consider using Manta/BKB
    end
end
```

### Animation and Casting State

| Function | Returns | Description |
|---|---|---|
| `GetAnimActivity()` | `int` | Current animation (`ACTIVITY_*` constant) |
| `GetAnimCycle()` | `float` | Animation progress 0.0 to 1.0 |
| `IsChanneling()` | `bool` | Currently channeling an ability or item? |
| `IsUsingAbility()` | `bool` | Using any ability (casting, channeling, etc.)? |
| `IsCastingAbility()` | `bool` | In the cast animation specifically? |
| `GetCurrentActiveAbility()` | `hAbility` | The ability currently being cast/channeled (nil if none) |

### Bot Mode

| Function | Returns | Description |
|---|---|---|
| `GetActiveMode()` | `int` | Current bot mode (`BOT_MODE_*`) |
| `GetActiveModeDesire()` | `float` | Desire value of the current active mode (0.0-1.0) |
| `GetAssignedLane()` | `int` | Lane assigned to this bot (`LANE_TOP`, `LANE_MID`, `LANE_BOT`) |

### Ability and Item Access

### `GetAbilityByName(sName)`

**Parameters:**
- `sName` (string): Internal ability name (e.g., `"axe_berserkers_call"`).

**Returns:** `hAbility` or `nil` -- Ability handle if the hero has this ability, nil otherwise.

### `GetAbilityInSlot(nSlot)`

**Parameters:**
- `nSlot` (int): Ability slot index (0-23). Slots 0-5 are usually regular abilities, 10+ are talents.

**Returns:** `hAbility` or `nil`

### `GetItemInSlot(nSlot)`

**Parameters:**
- `nSlot` (int): Inventory slot index.
  - **0-5**: Main inventory.
  - **6-8**: Backpack.
  - **9-14**: Stash.
  - **15**: TP scroll slot.
  - **16**: Neutral item slot.

**Returns:** `hItem` or `nil`

### `FindItemSlot(sName)`

**Parameters:**
- `sName` (string): Internal item name (e.g., `"item_blink"`).

**Returns:** `int` -- Slot index where the item is found. Returns `-1` if not in inventory.

### `GetItemSlotType(nSlot)`

**Returns:** `int` -- `ITEM_SLOT_TYPE_MAIN`, `ITEM_SLOT_TYPE_BACKPACK`, or `ITEM_SLOT_TYPE_STASH`.

### Target Management

| Function | Returns | Description |
|---|---|---|
| `SetTarget(hUnit)` | -- | Store a temporary target reference on this bot |
| `GetTarget()` | `hUnit` | Retrieve the stored target |
| `GetAbilityTarget()` | `hUnit` | The unit targeted by the current ability being cast |
| `SetNextItemPurchaseValue(nGold)` | -- | Set gold goal for shop proximity logic (bot will walk to shop when gold is near this) |
| `GetNextItemPurchaseValue()` | `int` | Get the current purchase gold goal |

---

## Ability / Item Functions

All functions in this section are called on an ability or item handle: `hAbility:FunctionName(...)`.

### Identity

| Function | Returns | Description |
|---|---|---|
| `GetName()` | `string` | Internal ability/item name |
| `GetLevel()` | `int` | Current level (0 = not yet learned) |
| `GetMaxLevel()` | `int` | Maximum level |
| `GetCaster()` | `hUnit` | The unit that owns this ability |

### Classification

| Function | Returns | Description |
|---|---|---|
| `IsPassive()` | `bool` | Passive ability (no activation)? |
| `IsToggle()` | `bool` | Can be toggled on/off? |
| `IsItem()` | `bool` | Is this an item (vs an ability)? |
| `IsUltimate()` | `bool` | Is this the hero's ultimate? |
| `IsHidden()` | `bool` | Currently hidden/unavailable? |
| `IsTrained()` | `bool` | Has been leveled at least once? |
| `IsStealable()` | `bool` | Can Rubick steal this? |
| `IsStolen()` | `bool` | Is this a stolen ability (Rubick)? |
| `IsActivated()` | `bool` | Is currently active (e.g., toggled on)? |
| `IsAttributeBonus()` | `bool` | Is the old-style attribute bonus ability? |
| `ProcsMagicStick()` | `bool` | Will casting this trigger enemy Magic Stick/Wand charges? |

### `IsTalent()`

**Returns:** `bool` -- True for talent abilities (typically in slots 10+).

```lua
for i = 0, 23 do
    local ability = bot:GetAbilityInSlot(i)
    if ability ~= nil and ability:IsTalent() and ability:IsTrained() then
        -- this talent has been learned
    end
end
```

### Casting State and Costs

### `IsFullyCastable()`

**Returns:** `bool` -- True if the ability is **not on cooldown AND the caster has enough mana**. This is the primary "can I use this right now?" check.

### `IsCooldownReady()`

**Returns:** `bool` -- True if the ability is off cooldown (ignores mana).

### `GetCooldownTimeRemaining()`

**Returns:** `float` -- Seconds of cooldown remaining.

> **Enemy abilities always return 0.** You cannot see enemy cooldowns through the API. This function only works reliably for your own abilities and allied abilities.

| Function | Returns | Description |
|---|---|---|
| `GetCastRange()` | `int` | Maximum cast distance in units |
| `GetCastPoint()` | `float` | Cast animation time in seconds (delay before the spell fires) |
| `GetChannelTime()` | `float` | Channel duration in seconds (0 for non-channeled) |
| `GetManaCost()` | `int` | Mana cost to cast |
| `GetChannelledManaCostPerSecond()` | `int` | Ongoing mana cost per second during channeling |
| `IsOwnersManaEnough()` | `bool` | Does the caster have enough mana? |
| `IsInAbilityPhase()` | `bool` | Currently in the cast animation (before spell fires)? |
| `IsChanneling()` | `bool` | Currently channeling? |

### Effects and Damage

| Function | Returns | Description |
|---|---|---|
| `GetAbilityDamage()` | `int` | Base damage of the ability at current level |
| `GetDamageType()` | `int` | `DAMAGE_TYPE_PHYSICAL`, `DAMAGE_TYPE_MAGICAL`, or `DAMAGE_TYPE_PURE` |
| `GetDuration()` | `float` | Primary effect duration |
| `GetAOERadius()` | `int` | Area of effect radius (0 for single-target) |
| `GetEstimatedDamageToTarget(hTarget, fDur, nTypes)` | `float` | Predicted damage to a specific target |

### Targeting Behavior

### `GetBehavior()`

**Returns:** `int` -- **Bitfield** of behavior flags.

> **Critical:** This returns a bitfield, NOT a single enum value. You must use bitwise AND to check individual flags.

```lua
local behavior = ability:GetBehavior()

-- Check if ability is channeled
if bit.band(behavior, ABILITY_BEHAVIOR_CHANNELLED) ~= 0 then
    -- this is a channeled ability
end

-- Check if it's a no-target ability
if bit.band(behavior, ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
    bot:Action_UseAbility(ability)
end

-- Check if it's a point-target ability
if bit.band(behavior, ABILITY_BEHAVIOR_POINT) ~= 0 then
    bot:Action_UseAbilityOnLocation(ability, targetLoc)
end

-- Check if it targets units
if bit.band(behavior, ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
    bot:Action_UseAbilityOnEntity(ability, targetUnit)
end
```

| Function | Returns | Description |
|---|---|---|
| `GetTargetTeam()` | `int` | Target team flags bitfield (`ABILITY_TARGET_TEAM_*`) |
| `GetTargetType()` | `int` | Target type flags bitfield (`ABILITY_TARGET_TYPE_*`) |
| `GetTargetFlags()` | `int` | Target flag conditions bitfield (`ABILITY_TARGET_FLAG_*`) |

### Leveling

| Function | Returns | Description |
|---|---|---|
| `CanAbilityBeUpgraded()` | `bool` | Can be leveled right now? (checks hero level requirement + available points) |
| `GetHeroLevelRequiredToUpgrade()` | `int` | Minimum hero level needed to put a point in this ability |

### Charges

| Function | Returns | Description |
|---|---|---|
| `GetCurrentCharges()` | `int` | Current charge count (e.g., Magic Wand charges, Drum charges) |
| `GetInitialCharges()` | `int` | Charges the item starts with |
| `GetSecondaryCharges()` | `int` | Secondary charge pool (some abilities have two charge systems) |

### Toggle and Autocast

| Function | Returns | Description |
|---|---|---|
| `GetAutoCastState()` | `bool` | Is autocast currently enabled? |
| `GetToggleState()` | `bool` | Is the toggle currently on? |
| `ToggleAutoCast()` | -- | Toggle autocast on/off |

### Special Values (KV Data)

### `GetSpecialValueInt(sKey)` / `GetSpecialValueFloat(sKey)`

**Parameters:**
- `sKey` (string): The key name from `npc_abilities.txt` KeyValues data. **Must match exactly** (case-sensitive).

**Returns:** `int` or `float` -- The value at the current ability level.

```lua
-- Read a custom ability value
local stunDuration = ability:GetSpecialValueFloat("stun_duration")
local bonusDamage = ability:GetSpecialValueInt("bonus_damage")
```

> **The key must match the exact string in the KV data.** A typo will silently return 0. Double-check ability data files when using this.

### Item-Only Functions

| Function | Returns | Description |
|---|---|---|
| `CanBeDisassembled()` | `bool` | Can this item be disassembled into components? |
| `IsCombineLocked()` | `bool` | Is auto-combining locked for this item? |
| `GetPowerTreadsStat()` | `int` | Current Power Treads attribute (`ATTRIBUTE_STRENGTH`, `ATTRIBUTE_AGILITY`, `ATTRIBUTE_INTELLECT`) |

---

## Action System

Actions control what a bot physically does in the game world. Understanding the three action modes is critical for correct bot behavior.

### Three Action Modes

Every action function exists in three variants:

1. **`Action_*`** -- **CLEARS** the entire action queue and sets this as the new (and only) action.
2. **`ActionPush_*`** -- **INSERTS** at the front of the queue. The current action is paused and resumes after the pushed action completes.
3. **`ActionQueue_*`** -- **APPENDS** to the end of the queue. Executes after all currently queued actions finish.

```lua
-- These have very different effects:
bot:Action_MoveToLocation(locA)         -- STOP everything, move to A
bot:ActionQueue_MoveToLocation(locB)    -- After reaching A, move to B
bot:ActionPush_AttackUnit(enemy, true)  -- PAUSE moving to A, attack enemy once, then resume moving to A
```

### `Action_ClearActions(bStop)`

**Parameters:**
- `bStop` (bool):
  - `true` -- Issues an immediate halt command (unit stops moving/attacking instantly).
  - `false` -- Just clears the queue silently (unit finishes current action frame, then idles).

### Movement Actions

```lua
bot:Action_MoveToLocation(vLocation)    -- Move via pathfinding (navigates around terrain)
bot:Action_MoveDirectly(vLocation)      -- Move in a straight line (CAN GET STUCK on terrain/trees!)
bot:Action_MovePath(tWaypoints)         -- Move through a table of waypoints in order
bot:Action_MoveToUnit(hUnit)            -- Follow a unit continuously
bot:Action_AttackMove(vLocation)        -- Move toward location, attacking anything encountered
```

> **`MoveToLocation` vs `MoveDirectly`:** Always prefer `MoveToLocation` unless you have a specific reason to walk in a straight line. `MoveDirectly` does not pathfind and the bot WILL get stuck on cliffs, trees, and buildings.

### Combat Actions

### `Action_AttackUnit(hUnit, bOnce)`

**Parameters:**
- `hUnit` (hUnit): Target to attack.
- `bOnce` (bool):
  - `true` -- Attack exactly once, then stop.
  - `false` -- Keep attacking until the target dies or moves out of range.

```lua
-- Last-hit a creep (single attack)
bot:Action_AttackUnit(lowHPCreep, true)

-- Commit to fighting a hero
bot:Action_AttackUnit(enemy, false)
```

### Ability Actions

```lua
bot:Action_UseAbility(hAbility)                          -- No-target ability (e.g., Axe Berserker's Call)
bot:Action_UseAbilityOnEntity(hAbility, hTarget)         -- Unit-target ability (e.g., Lion Hex)
bot:Action_UseAbilityOnLocation(hAbility, vLocation)     -- Point-target ability (e.g., Lina LSA)
bot:Action_UseAbilityOnTree(hAbility, iTree)             -- Tree-target ability (e.g., Tango, Timberchain)
```

### Other Actions

```lua
bot:Action_PickUpRune(nRuneLoc)         -- Pick up a rune at the specified rune location constant
bot:Action_PickUpItem(hItem)            -- Pick up a dropped item
bot:Action_DropItem(hItem, vLocation)   -- Drop an item at a location
bot:Action_UseShrine(hShrine)           -- Use a shrine
bot:Action_Delay(fDelay)               -- Wait for fDelay seconds (do nothing)
```

### Immediate Actions (No Queue)

Immediate actions execute instantly without touching the action queue. They're used for economy, UI, and inventory operations.

### `ActionImmediate_PurchaseItem(sItemName)`

**Parameters:**
- `sItemName` (string): Internal item name (e.g., `"item_blink"`).

**Returns:** `int` -- One of the `PURCHASE_ITEM_*` constants:
- `PURCHASE_ITEM_SUCCESS` -- Purchased successfully.
- `PURCHASE_ITEM_INSUFFICIENT_GOLD` -- Not enough gold.
- `PURCHASE_ITEM_NOT_AT_HOME_SHOP` -- Must be at base shop.
- `PURCHASE_ITEM_NOT_AT_SECRET_SHOP` -- Must be at secret shop.
- `PURCHASE_ITEM_NOT_AT_SIDE_SHOP` -- Must be at side shop.
- `PURCHASE_ITEM_OUT_OF_STOCK` -- Item is out of stock.
- `PURCHASE_ITEM_INVALID_ITEM_NAME` -- Typo or invalid item name.
- `PURCHASE_ITEM_DISALLOWED_ITEM` -- Item is banned or unavailable in this mode.

```lua
local result = bot:ActionImmediate_PurchaseItem("item_tango")
if result ~= PURCHASE_ITEM_SUCCESS then
    -- handle failure
end
```

### `ActionImmediate_SellItem(hItem)`

Sells the item. Must be near a shop.

### `ActionImmediate_DisassembleItem(hItem)`

Disassembles the item into its components. Only works on items where `CanBeDisassembled()` returns true.

### `ActionImmediate_SetItemCombineLock(hItem, bLocked)`

Prevents (`true`) or allows (`false`) this item from auto-combining into recipes.

### `ActionImmediate_SwapItems(nSlot1, nSlot2)`

**Parameters:**
- `nSlot1`, `nSlot2` (int): Inventory slot indices.
  - **0-5**: Main inventory.
  - **6-8**: Backpack.
  - **9-14**: Stash.

```lua
-- Move an item from backpack (slot 6) to main inventory (slot 0)
bot:ActionImmediate_SwapItems(6, 0)
```

### `ActionImmediate_Courier(hCourier, nAction)`

**Parameters:**
- `hCourier` (hCourier): Courier handle from `GetCourier()`.
- `nAction` (int): Courier action constant (e.g., `COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS`).

### `ActionImmediate_Buyback()`

Buy back from death. Only works when dead and buyback is available.

### `ActionImmediate_Glyph()`

Activate Glyph of Fortification. Check `GetGlyphCooldown()` first.

### `ActionImmediate_LevelAbility(sAbilityName)`

**Parameters:**
- `sAbilityName` (string): The ability's **internal name string** (e.g., `"axe_berserkers_call"`).

### `ActionImmediate_Chat(sMessage, bAllChat)`

**Parameters:**
- `sMessage` (string): Chat message text.
- `bAllChat` (bool): `true` = all chat (visible to both teams), `false` = team chat only.

### `ActionImmediate_Ping(fX, fY, bNormalPing)`

**Parameters:**
- `fX`, `fY` (float): World coordinates to ping.
- `bNormalPing` (bool): `true` = "gather here" ping, `false` = danger/warning ping (X mark).

### Action Queue Inspection

```lua
bot:GetCurrentActionType()    -- Returns BOT_ACTION_TYPE_* constant for the current action
bot:NumQueuedActions()        -- Number of actions waiting in the queue
bot:GetQueuedActionType(n)    -- BOT_ACTION_TYPE_* for the Nth queued action (0-indexed)
```

---

## Constants Reference

### Teams

```
TEAM_RADIANT    TEAM_DIRE    TEAM_NEUTRAL    TEAM_NONE
```

### Lanes

```
LANE_NONE = 0    LANE_TOP = 1    LANE_MID = 2    LANE_BOT = 3
```

### Game Modes

```
GAMEMODE_AP              -- All Pick
GAMEMODE_CM              -- Captain's Mode
GAMEMODE_RD              -- Random Draft
GAMEMODE_SD              -- Single Draft
GAMEMODE_AR              -- All Random
GAMEMODE_REVERSE_CM      -- Reverse Captain's Mode
GAMEMODE_MO              -- Mid Only
GAMEMODE_CD              -- Captain's Draft
GAMEMODE_ABILITY_DRAFT
GAMEMODE_ARDM            -- All Random Deathmatch (value: 20)
GAMEMODE_1V1MID
GAMEMODE_ALL_DRAFT
GAMEMODE_TURBO           -- Turbo Mode (value: 23)
```

### Bot Modes

```
BOT_MODE_NONE               BOT_MODE_LANING            BOT_MODE_ATTACK
BOT_MODE_ROAM               BOT_MODE_RETREAT           BOT_MODE_SECRET_SHOP
BOT_MODE_SIDE_SHOP          BOT_MODE_PUSH_TOWER_TOP    BOT_MODE_PUSH_TOWER_MID
BOT_MODE_PUSH_TOWER_BOT    BOT_MODE_DEFEND_TOWER_TOP  BOT_MODE_DEFEND_TOWER_MID
BOT_MODE_DEFEND_TOWER_BOT  BOT_MODE_ASSEMBLE          BOT_MODE_TEAM_ROAM
BOT_MODE_FARM               BOT_MODE_DEFEND_ALLY       BOT_MODE_EVASIVE_MANEUVERS
BOT_MODE_ROSHAN             BOT_MODE_ITEM              BOT_MODE_WARD
```

### Desire Values

| Constant | Value | Alias |
|---|---|---|
| `BOT_MODE_DESIRE_NONE` | 0.0 | `BOT_ACTION_DESIRE_NONE` |
| `BOT_MODE_DESIRE_VERYLOW` | 0.1 | `BOT_ACTION_DESIRE_VERYLOW` |
| `BOT_MODE_DESIRE_LOW` | 0.25 | `BOT_ACTION_DESIRE_LOW` |
| `BOT_MODE_DESIRE_MODERATE` | 0.4-0.5 | `BOT_ACTION_DESIRE_MODERATE` |
| `BOT_MODE_DESIRE_HIGH` | 0.6-0.75 | `BOT_ACTION_DESIRE_HIGH` |
| `BOT_MODE_DESIRE_VERYHIGH` | 0.8-0.9 | `BOT_ACTION_DESIRE_VERYHIGH` |
| `BOT_MODE_DESIRE_ABSOLUTE` | 1.0 | `BOT_ACTION_DESIRE_ABSOLUTE` |

### Action Types

```
BOT_ACTION_TYPE_NONE             BOT_ACTION_TYPE_IDLE
BOT_ACTION_TYPE_MOVE_TO          BOT_ACTION_TYPE_MOVE_TO_DIRECTLY
BOT_ACTION_TYPE_ATTACK           BOT_ACTION_TYPE_ATTACKMOVE
BOT_ACTION_TYPE_USE_ABILITY      BOT_ACTION_TYPE_PICK_UP_RUNE
BOT_ACTION_TYPE_PICK_UP_ITEM     BOT_ACTION_TYPE_DROP_ITEM
BOT_ACTION_TYPE_SHRINE           BOT_ACTION_TYPE_DELAY
```

### Damage Types

```
DAMAGE_TYPE_PHYSICAL    DAMAGE_TYPE_MAGICAL    DAMAGE_TYPE_PURE    DAMAGE_TYPE_ALL
```

### Unit List Types

```
UNIT_LIST_ALL               UNIT_LIST_ALLIES            UNIT_LIST_ALLIED_HEROES
UNIT_LIST_ALLIED_CREEPS     UNIT_LIST_ALLIED_WARDS      UNIT_LIST_ALLIED_BUILDINGS
UNIT_LIST_ENEMIES           UNIT_LIST_ENEMY_HEROES      UNIT_LIST_ENEMY_CREEPS
UNIT_LIST_ENEMY_WARDS       UNIT_LIST_ENEMY_BUILDINGS    UNIT_LIST_NEUTRAL_CREEPS
```

### Game States

```
GAME_STATE_INIT                        GAME_STATE_WAIT_FOR_PLAYERS_TO_LOAD
GAME_STATE_HERO_SELECTION              GAME_STATE_STRATEGY_TIME
GAME_STATE_PRE_GAME                    GAME_STATE_GAME_IN_PROGRESS
GAME_STATE_POST_GAME                   GAME_STATE_DISCONNECT
GAME_STATE_WAIT_FOR_MAP_TO_LOAD
```

### Structures

```
-- Towers
TOWER_TOP_1    TOWER_TOP_2    TOWER_TOP_3
TOWER_MID_1    TOWER_MID_2    TOWER_MID_3
TOWER_BOT_1    TOWER_BOT_2    TOWER_BOT_3
TOWER_BASE_1   TOWER_BASE_2

-- Barracks
BARRACKS_TOP_MELEE     BARRACKS_TOP_RANGED
BARRACKS_MID_MELEE     BARRACKS_MID_RANGED
BARRACKS_BOT_MELEE     BARRACKS_BOT_RANGED

-- Shops
SHOP_HOME    SHOP_SIDE    SHOP_SECRET    SHOP_SIDE2    SHOP_SECRET2
```

### Runes

```
-- Types
RUNE_INVALID       RUNE_DOUBLEDAMAGE    RUNE_HASTE       RUNE_ILLUSION
RUNE_INVISIBILITY  RUNE_REGENERATION    RUNE_BOUNTY      RUNE_ARCANE

-- Status
RUNE_STATUS_UNKNOWN    RUNE_STATUS_AVAILABLE    RUNE_STATUS_MISSING

-- Locations
RUNE_POWERUP_1    RUNE_POWERUP_2
RUNE_BOUNTY_1     RUNE_BOUNTY_2     RUNE_BOUNTY_3     RUNE_BOUNTY_4
```

### Purchase Results

```
PURCHASE_ITEM_SUCCESS               PURCHASE_ITEM_OUT_OF_STOCK
PURCHASE_ITEM_DISALLOWED_ITEM       PURCHASE_ITEM_INSUFFICIENT_GOLD
PURCHASE_ITEM_NOT_AT_HOME_SHOP      PURCHASE_ITEM_NOT_AT_SIDE_SHOP
PURCHASE_ITEM_NOT_AT_SECRET_SHOP    PURCHASE_ITEM_INVALID_ITEM_NAME
```

### Difficulty Levels

```
DIFFICULTY_INVALID    DIFFICULTY_PASSIVE    DIFFICULTY_EASY
DIFFICULTY_MEDIUM     DIFFICULTY_HARD       DIFFICULTY_UNFAIR
```

### Attributes

```
ATTRIBUTE_INVALID    ATTRIBUTE_STRENGTH    ATTRIBUTE_AGILITY    ATTRIBUTE_INTELLECT
```

### Ability Behavior Flags (Bitfield)

```
ABILITY_BEHAVIOR_HIDDEN              ABILITY_BEHAVIOR_PASSIVE
ABILITY_BEHAVIOR_NO_TARGET           ABILITY_BEHAVIOR_UNIT_TARGET
ABILITY_BEHAVIOR_POINT               ABILITY_BEHAVIOR_AOE
ABILITY_BEHAVIOR_CHANNELLED          ABILITY_BEHAVIOR_NOT_LEARNABLE
ABILITY_BEHAVIOR_ITEM                ABILITY_BEHAVIOR_TOGGLE
ABILITY_BEHAVIOR_AUTOCAST            ABILITY_BEHAVIOR_IGNORE_BACKSWING
```

> **Remember:** These are bitfield flags. Always use `bit.band()` to test them, never `==`.
