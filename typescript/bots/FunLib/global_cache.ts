/**
 * Global Performance Cache System
 * Provides shared caching across all bot modules to reduce redundant API calls
 */

import { Lane, Team, Unit, UnitType, Vector } from "bots/ts_libs/dota";

interface GlobalCacheEntry {
    lastUpdate: number;
    data: any;
}

interface GlobalGameState {
    lastUpdate: number;
    currentTime: number;
    gameMode: number;
    team: Team;
    enemyTeam: Team;
    ourAncient: Unit | null;
    enemyAncient: Unit | null;
    aliveAllyCount: number;
    aliveEnemyCount: number;
    aliveAllyCoreCount: number;
    aliveEnemyCoreCount: number;
    teamNetworth: number;
    enemyNetworth: number;
    averageLevel: number;
    hasAegis: boolean;
    isEarlyGame: boolean;
    isMidGame: boolean;
    isLateGame: boolean;
    isLaningPhase: boolean;
}

interface GlobalUnitState {
    lastUpdate: number;
    enemyBuildings: Unit[];
    alliedHeroes: Unit[];
    enemyHeroes: Unit[];
    alliedCreeps: Unit[];
    enemyCreeps: Unit[];
}

interface GlobalLocationState {
    lastUpdate: number;
    laneFronts: Record<Lane, Vector>;
    teamFountain: Vector;
    enemyFountain: Vector;
    roshanLocation: Vector;
    tormentorLocation: Vector;
    tormentorWaitingLocation: Vector;
}

// Global cache storage
const globalCache: Record<string, GlobalCacheEntry> = {};
const GLOBAL_CACHE_TTL = 0.5; // 500ms TTL for global cache

// Specific cache objects
let globalGameStateCache: GlobalGameState | null = null;
let globalUnitStateCache: GlobalUnitState | null = null;
let globalLocationStateCache: GlobalLocationState | null = null;

/**
 * Get or update global game state cache
 */
export function getGlobalGameState(): GlobalGameState {
    const now = DotaTime();
    if (globalGameStateCache && now - globalGameStateCache.lastUpdate < GLOBAL_CACHE_TTL) {
        return globalGameStateCache;
    }

    // Import jmz here to avoid circular dependencies
    const jmz = require("bots/FunLib/jmz_func");

    const team = GetTeam();
    const enemyTeam = GetOpposingTeam();
    const currentTime = DotaTime();
    const gameMode = GetGameMode();

    // Adjust time for turbo mode
    const adjustedTime = gameMode === 23 ? currentTime * 2 : currentTime;

    globalGameStateCache = {
        lastUpdate: now,
        currentTime: adjustedTime,
        gameMode,
        team,
        enemyTeam,
        ourAncient: GetAncient(team),
        enemyAncient: GetAncient(enemyTeam),
        aliveAllyCount: jmz.GetNumOfAliveHeroes(false),
        aliveEnemyCount: jmz.GetNumOfAliveHeroes(true),
        aliveAllyCoreCount: jmz.GetAliveCoreCount(false),
        aliveEnemyCoreCount: jmz.GetAliveCoreCount(true),
        teamNetworth: jmz.GetInventoryNetworth()[0],
        enemyNetworth: jmz.GetInventoryNetworth()[1],
        averageLevel: jmz.GetAverageLevel(team),
        hasAegis: jmz.DoesTeamHaveAegis(),
        isEarlyGame: jmz.IsEarlyGame(),
        isMidGame: jmz.IsMidGame(),
        isLateGame: jmz.IsLateGame(),
        isLaningPhase: jmz.IsInLaningPhase(),
    };

    return globalGameStateCache;
}

/**
 * Get or update global unit state cache
 */
export function getGlobalUnitState(): GlobalUnitState {
    const now = DotaTime();
    if (globalUnitStateCache && now - globalUnitStateCache.lastUpdate < GLOBAL_CACHE_TTL) {
        return globalUnitStateCache;
    }

    // Import jmz here to avoid circular dependencies
    const jmz = require("bots/FunLib/jmz_func");

    globalUnitStateCache = {
        lastUpdate: now,
        enemyBuildings: GetUnitList(UnitType.EnemyBuildings),
        alliedHeroes: GetUnitList(UnitType.AlliedHeroes),
        enemyHeroes: GetUnitList(UnitType.Enemies).filter(u => jmz.IsValidHero(u)),
        alliedCreeps: GetUnitList(UnitType.AlliedCreeps),
        enemyCreeps: GetUnitList(UnitType.Enemies).filter(u => u.IsCreep() || u.IsAncientCreep()),
    };

    return globalUnitStateCache;
}

/**
 * Get or update global location state cache
 */
export function getGlobalLocationState(): GlobalLocationState {
    const now = DotaTime();
    if (globalLocationStateCache && now - globalLocationStateCache.lastUpdate < GLOBAL_CACHE_TTL) {
        return globalLocationStateCache;
    }

    // Import jmz here to avoid circular dependencies
    const jmz = require("bots/FunLib/jmz_func");

    const team = GetTeam();

    globalLocationStateCache = {
        lastUpdate: now,
        laneFronts: {
            [Lane.Top]: GetLaneFrontLocation(team, Lane.Top, 0),
            [Lane.Mid]: GetLaneFrontLocation(team, Lane.Mid, 0),
            [Lane.Bot]: GetLaneFrontLocation(team, Lane.Bot, 0),
        },
        teamFountain: jmz.GetTeamFountain(),
        enemyFountain: jmz.GetTeamFountain(), // Note: GetEnemyFountain doesn't exist
        roshanLocation: jmz.GetCurrentRoshanLocation(),
        tormentorLocation: jmz.GetTormentorLocation(team),
        tormentorWaitingLocation: jmz.GetTormentorWaitingLocation(team),
    };

    return globalLocationStateCache;
}

/**
 * Generic cache function for arbitrary data
 */
export function getCachedData<T>(key: string, ttl: number, fetchFn: () => T): T {
    const now = DotaTime();
    const cached = globalCache[key];

    if (cached && now - cached.lastUpdate < ttl) {
        return cached.data as T;
    }

    const data = fetchFn();
    globalCache[key] = {
        lastUpdate: now,
        data: data,
    };

    return data;
}

/**
 * Clear old cache entries to prevent memory leaks
 */
export function cleanupGlobalCache(): void {
    const now = DotaTime();
    const maxAge = 10; // 10 seconds max age

    Object.keys(globalCache).forEach(key => {
        if (now - globalCache[key].lastUpdate > maxAge) {
            delete globalCache[key];
        }
    });
}

/**
 * Clear all caches (useful for testing or when game state changes significantly)
 */
export function clearAllCaches(): void {
    Object.keys(globalCache).forEach(key => {
        delete globalCache[key];
    });
    globalGameStateCache = null;
    globalUnitStateCache = null;
    globalLocationStateCache = null;
}

/**
 * Get cached allies near location
 */
export function getCachedAlliesNearLoc(location: Vector, radius: number): Unit[] {
    const key = `allies_${Math.floor(location.x)}_${Math.floor(location.y)}_${radius}_${Math.floor(DotaTime() * 2)}`;
    return getCachedData(key, 0.5, () => {
        const jmz = require("bots/FunLib/jmz_func");
        return jmz.GetAlliesNearLoc(location, radius);
    });
}

/**
 * Get cached enemies near location
 */
export function getCachedEnemiesNearLoc(location: Vector, radius: number): Unit[] {
    const key = `enemies_${Math.floor(location.x)}_${Math.floor(location.y)}_${radius}_${Math.floor(DotaTime() * 2)}`;
    return getCachedData(key, 0.5, () => {
        const jmz = require("bots/FunLib/jmz_func");
        return jmz.GetEnemiesNearLoc(location, radius);
    });
}

// Auto-cleanup every 30 seconds
let lastCleanupTime = 0;
export function autoCleanupCache(): void {
    const now = DotaTime();
    if (now - lastCleanupTime > 30) {
        cleanupGlobalCache();
        lastCleanupTime = now;
    }
}
