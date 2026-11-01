// dota-bot benchmark orchestrator: plays N local bot-vs-bot matches, dota-bot on one side and Valve's own bots on the
// other (sides alternate), the same five drawn heroes on both teams (Radiant gets them when the bots are added; the
// custom game swaps each Dire hero for its slot's one after it spawns, and a match without the same five per side is
// not valid), and
// records each winner from Dota's Game State Integration (GSI). The match runs in the local custom game
// tools/bench/addon ("dotabench"), which keeps the human out of the teams, adds the bots and speeds the match up.
//   node tools/bench/orquestador.mjs [--partidas 2] [--dificultad 4] [--velocidad 4] [--etiqueta texto]
//                                    [--variantes base,empuje] [--modo turbo] [--observar] [--lado dire]
//                                    [--dota "<dota 2 beta>"]
//                                    [--muestra-gsi <file>]
// --variantes interleaves versions of dota-bot (VARIANTS) in one series: per block of heroes, every variant plays
// both sides, and the order flips every block, so heroes, side, Dota's version and the PC's load hit every variant
// alike. Each match is a row of bench/series.csv; "valida" says whether it can be counted.
//
// Limits, on purpose (Pedro, 2026-10-28: «solamente y acotado a steam y dota y lo que queremos»):
// - Starts only <dota>/game/bin/win64/dota2.exe with fixed arguments, and only stops the dota2.exe it started.
// - Does not start Steam (it must already be running) and refuses to run if any dota2.exe is already open.
// - Listens only on 127.0.0.1 and only accepts GSI posts carrying its own token.
// - Writes only: the GSI config in <dota>/game/dota/cfg/gamestate_integration/, bots/Customize/bench_valve_team.lua
//   (which team plays with Valve's bots), bots/Customize/bench_variant.lua (with --variantes: the variant dota-bot
//   plays; deleted when each match ends), tools/bench/addon/scripts/vscripts/bench_partida.lua (heroes, difficulty,
//   speed; deleted at the end too), bench/series.csv and bench/lineas/ (per-match timelines, read from its own
//   Dota's <dota>/game/dota/console.log), with --observar bench/observaciones/ (per-match observer lines from that
//   same log; and bots/Customize/bench_observe.lua, deleted when each match ends, so the bots log their mode), and,
//   only with --muestra-gsi <file> (debugging), the last raw GSI post in
//   that file. It reads <dota>/game/dota/steam.inf (Dota's version) and the PC's CPU and memory through Node's os
//   module. The team file lives only from launch until the
//   horn (scripts load before it); both temporary files are deleted when it ends, also on Ctrl+C, closing the window
//   or an error. A hard kill of this script (Task Manager) leaves its Dota open and the GSI config in place
//   (harmless), and bench_partida.lua (only dotabench reads it; the next match overwrites it); during a match's first
//   minutes it could also leave the team file, which makes that team play with
//   Valve's bots in any local game until the next run deletes it (or delete bots/Customize/bench_valve_team.lua).
//   With --variantes it can also leave bots/Customize/bench_variant.lua at any point of a match: until the next run
//   deletes it (or you do), dota-bot plays that variant in any local game. With --observar it can likewise leave
//   bots/Customize/bench_observe.lua: the bots then print and log their mode in any local game (they play the same).
import { spawn, execFile } from "node:child_process";
import { createServer } from "node:http";
import { existsSync, writeFileSync, unlinkSync, appendFileSync, mkdirSync, readFileSync, statSync, realpathSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import os from "node:os";
import { fileURLToPath } from "node:url";

export const TOKEN = "dota-bot-bench"; // not a secret: only tells our GSI posts apart · fabrica:permitido
export const PORT = 3911;
const RADIANT = 2;
const DIRE = 3;
const root = fileURLToPath(new URL("../..", import.meta.url));
const VALVE_TEAM_FILE = join(root, "bots", "Customize", "bench_valve_team.lua");
const VARIANT_FILE = join(root, "bots", "Customize", "bench_variant.lua");
const OBSERVE_FILE = join(root, "bots", "Customize", "bench_observe.lua"); // --observar: the bots log their mode
const MATCH_FILE = join(root, "tools", "bench", "addon", "scripts", "vscripts", "bench_partida.lua");
// bench/partidas.csv holds the runs before 2026-10-29 (they cannot prove the human stayed out); new runs go here.
const CSV = join(root, "bench", "series.csv");
const COLUMNS = ["fecha", "etiqueta", "partida", "bloque", "variante", "valida", "motivo", "dificultad", "dotabot",
  "ganador", "resultado", "minutos", "kills_radiant", "kills_dire", "humano", "heroes", "ventaja_oro_max",
  "minuto_10k", "torres_fin", "dota_version", "cpu_media", "cpu_max", "mem_libre", "modo", "codigo", "rival"];

// Measurement protocol (DECISIONES 2026-10-31): a match that reaches this game minute stops as "tope" (valid, with no
// winner, so dota-bot did not win it; counted apart in the summary), and a series stops once more than this share of
// its matches (from the fifth on) is not valid.
export const GAME_CAP_MIN = 60;
export const MAX_INVALID_SHARE = 0.2;

// The code a match played: "commit@trees", where trees are git's tree ids of bots/ and tools/bench/ (what plays and
// what judges), with "+cambios" when they had uncommitted changes (the bots read bots/ live, so such a match did not
// play any commit). A commit of documents only changes the commit, not the trees, so it does not split a series.
// Read-only git, in this repository.
export function codeState(sha, porcelain, trees = "") {
  const tree = trees.trim().split(/\s+/).map((t) => t.slice(0, 7)).join(".");
  return `${sha.trim().slice(0, 12)}@${tree}${porcelain.trim() ? "+cambios" : ""}`;
}

// The part of a code state that must stay the same through a series: the trees.
export function codeTree(codigo) {
  return String(codigo ?? "").split("@")[1]?.replace("+cambios", "") ?? "";
}

// Whether the series must stop: from the fifth match on, more than MAX_INVALID_SHARE of them not valid.
export function tooManyInvalid(results) {
  const bad = results.filter((r) => r.valida !== "si").length;
  return results.length >= 5 && bad / results.length > MAX_INVALID_SHARE;
}

// Versions of dota-bot a series can interleave (FunLib/bench_variant.lua reads them in the bots' VM).
export const VARIANTS = {
  base: { empuje: false, thinkless: 1 }, // before PR #11: push caps not relaxed with a 10k lead
  // The same as base under another name, for an A/A series: how far two identical arms land apart (the noise) and how
  // much the side alone gives (DECISIONES 2026-10-31).
  base_b: { empuje: false, thinkless: 1 },
  empuje: { empuje: true, thinkless: 1 }, // PR #11
  thinkless0: { empuje: true, thinkless: 0 }, // PR #11 and bots think every frame
  // "remate" (Pedro, 2026-10-30): the whole team pushes one lane with a 5k lead; grupo_farm also keeps farming at 6k+.
  grupo: { grupo: true, thinkless: 1 },
  grupo_farm: { grupo: true, farm: true, thinkless: 1 },
  // Level 2, the sweet spot of the group push (Pedro, 2026-10-31): the same group push from different leads.
  grupo_5k: { grupo: true, grupo_umbral: 5000, thinkless: 1 },
  grupo_15k: { grupo: true, grupo_umbral: 15000, thinkless: 1 },
  // Team brain (Pedro, 2026-10-30; trabajo/cerebro-equipo.md): team_desires.lua + FunLib/team_brain.lua.
  cerebro: { cerebro: true, thinkless: 1 },
  // Team brain v2 and builds from data together (Pedro, 2026-10-30: «son dos cambios no tan grandes que podrian ir
  // juntos»); the brain's v2 changes replace v1's, so "cerebro" now also plays v2.
  cerebro_builds: { cerebro: true, builds: true, thinkless: 1 },
  // Fixing Dire (2026-10-31): the whole team defends the base against two or more heroes.
  cerebro_def: { cerebro: true, builds: true, defensa_total: true, thinkless: 1 },
  // ...and also groups to push only with the fight around the team clearly in favour.
  cerebro_prud: { cerebro: true, builds: true, defensa_total: true, prudente: true, thinkless: 1 },
  // Finding where the brain's extra deaths come from (2026-10-31), one piece off in each:
  cerebro_sinbuilds: { cerebro: true, defensa_total: true, thinkless: 1 },
  cerebro_sinpelea: { cerebro: true, builds: true, defensa_total: true, sin_pelea: true, thinkless: 1 },
  builds: { builds: true, thinkless: 1 },
  // OHA's own Turbo logic (the GetGameMode() == 23 switches) off again in the imitated Turbo (2026-10-31: with it on,
  // dota-bot lost 6 of 6 as Dire).
  base_sinturbo: { sin_turbo_oha: true, thinkless: 1 },
  // Phases and "how far the game is" by the state of the match instead of the clock (Pedro, 2026-10-31).
  base_estado: { fase_estado: true, thinkless: 1 },
  // Level 1 (DECISIONES 2026-10-31): ultimates need a reason (an enemy hero in reach, an ally to save, a building to
  // push), FunLib/ult_gate.lua.
  filtro_ultis: { filtro_ultis: true, thinkless: 1 },
  // Level 1: an attacked tier 1/2 tower is defended only by enough allies arriving in time, else conceded,
  // FunLib/tower_defense.lua.
  defensa_t12: { defensa_t12: true, thinkless: 1 },
  // Both level 1 fixes together, for the level 2 series.
  nivel1: { filtro_ultis: true, defensa_t12: true, thinkless: 1 },
  // Only to check that the bots apply the variant: they almost stop casting, which shows in the casts per team.
  sonda: { empuje: true, thinkless: 1000 },
};

export function variantLua(name) {
  const fields = Object.entries(VARIANTS[name]).map(([k, v]) => `${k} = ${v}`).join(", ");
  return `-- written by tools/bench/orquestador.mjs for one match; deleted when it ends\nreturn { name = "${name}", ${fields} }\n`;
}

// --rival dotabot: dota-bot against dota-bot in the same match, one variant per team (Pedro, 2026-10-31: against
// Valve the base bot already wins ~91%, so wins there can only show a change got worse). FunLib/bench_variant.lua gives
// each team its own entry of "teams".
export function rivalVariantLua(radiant, dire) {
  const fields = (name) => Object.entries(VARIANTS[name]).map(([k, v]) => `${k} = ${v}`).join(", ");
  return `-- written by tools/bench/orquestador.mjs for one match; deleted when it ends\nreturn { name = "${rivalName(radiant, dire)}", teams = { [2] = { name = "${radiant}", ${fields(radiant)} }, [3] = { name = "${dire}", ${fields(dire)} } } }\n`;
}
export const rivalName = (radiant, dire) => `${radiant}-vs-${dire}`;

// Match i of a dota-bot against dota-bot series of variants [a, b]: pairs of matches share a hero draw and swap sides,
// and the side that starts flips every pair. The row is written from a's point of view (dotabot = a's side).
export function rivalSchedule(i, variants) {
  const [a, b] = variants;
  const block = Math.floor(i / 2);
  const aRadiant = (i % 2 === 0) === (block % 2 === 0);
  return { block, dotabot: aRadiant ? "radiant" : "dire", variant: a,
    radiant: aRadiant ? a : b, dire: aRadiant ? b : a };
}

// Match i (0-based) of a series with these variants: block of 2 x variants matches sharing one hero draw, where every
// variant plays once on each side; the side that starts and the variant order flip every block.
export function schedule(i, variants) {
  const n = Math.max(variants.length, 1);
  const block = Math.floor(i / (2 * n));
  const pos = i % (2 * n);
  const even = block % 2 === 0;
  const order = even ? variants : [...variants].reverse();
  const first = even ? "radiant" : "dire";
  const dotabot = pos < n ? first : first === "radiant" ? "dire" : "radiant";
  return { block, dotabot, valveTeam: dotabot === "radiant" ? DIRE : RADIANT, variant: order[pos % n] ?? "" };
}

// Whether a match can be counted, and why not. The variant is confirmed by the custom game reading the same file at
// pre-game; that the bots apply it was checked once with the "sonda" variant (bench/README.md) and each match logs
// casts per team. (The bots' print does reach the log, but only in observer mode: OHA silences it otherwise.)
export function validity({ outcome, roster, variant, loggedVariant, version, firstVersion, modo = "normal", loggedModo,
  espejo = "", start, codigo, firstCodigo, couriers, intrusos, tardios, esperado, killsAtStart = null }) {
  // A match stopped at the cap counts, as a match dota-bot did not win (Pedro, 2026-10-31): dropping it would drop
  // exactly the matches an arm cannot close, a different number per arm.
  if (outcome !== "final" && outcome !== "tope") return "sin final";
  if (codigo === undefined || codigo.endsWith("+cambios")) return "código sin commit";
  if (!codeTree(codigo) || codeTree(codigo) !== codeTree(firstCodigo)) {
    return `el código cambió en la serie (${firstCodigo} -> ${codigo})`;
  }
  if (modo !== loggedModo) return `modo ${loggedModo || "sin registro"} en el log`;
  if (roster.radiant !== 5 || roster.dire !== 5) return `reparto ${roster.radiant ?? 0}-${roster.dire ?? 0}`;
  // Each team plays exactly its drawn group, read from the heroes really controlled once all have spawned: the same
  // match-up on both sides, not the same heroes, which the engine never gives (DECISIONES 2026-10-31). "--espejo no"
  // (Dire random) is for debugging only: never valid.
  if (espejo === "no") return "espejo apagado";
  if (!start || start.radiant !== 5 || start.dire !== 5) return "sin registro de inicio";
  if (!esperado || !sameSet(start.heroesRadiant, esperado.radiant) || !sameSet(start.heroesDire, esperado.dire)) {
    return "héroes distintos de los sorteados";
  }
  // Valve's team really played by Valve (S6): without dota-bot's load lines it cannot be checked, so it is not valid.
  if (!Array.isArray(intrusos)) return "sin registro de carga: no se comprueba quién juega cada héroe";
  if (intrusos.length) return `dota-bot jugó en el equipo de Valve (pid ${intrusos.join(",")})`;
  if (!Array.isArray(tardios)) return "sin registro de aparición de héroes";
  if (tardios.length) return `héroe aparecido tras el inicio (${tardios.join(",")})`;
  // Five couriers alive per side at minute 1, Turbo ones (1100) in turbo: S1 (no couriers) must not come back.
  if (!couriers || couriers.radiant !== 5 || couriers.dire !== 5) {
    return `couriers ${couriers?.radiant ?? 0}-${couriers?.dire ?? 0}`;
  }
  if (modo === "turbo" && Math.min(couriers.slowRadiant, couriers.slowDire) < 1100) {
    return `couriers lentos ${couriers.slowRadiant}-${couriers.slowDire}`;
  }
  // A kill before the horn is play, not a bias (90 s of pre-game, as in Dota): each one may move the gap toward the
  // killer's side by anything from 0 (the start snapshot was taken just before it, series n2-nivel1 match 12) to
  // KILL_NW_GAP (assist gold and the victim's loss: 641-955 measured), never more, so a bias that coincides with a
  // kill is still bounded (review 2026-11-01).
  const kills = killsAtStart ?? { radiant: 0, dire: 0 };
  const gap = start.nwRadiant - start.nwDire;
  const low = -START_NW_GAP - (kills.dire ?? 0) * KILL_NW_GAP;
  const high = START_NW_GAP + (kills.radiant ?? 0) * KILL_NW_GAP;
  if (!Number.isFinite(gap) || gap < low || gap > high) {
    return `patrimonio inicial ${start.nwRadiant}-${start.nwDire}`;
  }
  if (roster.humano !== "fuera" && roster.humano !== "heroe-quitado") return `humano ${roster.humano || "?"}`;
  if (loggedVariant === null || loggedVariant === undefined) return "variante sin registro en el log";
  if ((variant || "") !== loggedVariant) return `variante ${loggedVariant || "ninguna"} en el log`;
  if (version !== firstVersion) return `Dota cambió de versión (${firstVersion} -> ${version})`;
  return "";
}

// Per variant: wins over the valid matches of complete blocks only (a block counts when all its matches are valid),
// so a lost match cannot unbalance heroes or sides between variants.
export function summarize(results, variants) {
  const size = 2 * Math.max(variants.length, 1);
  const byBlock = new Map();
  for (const r of results) byBlock.set(r.bloque, [...(byBlock.get(r.bloque) ?? []), r]);
  const complete = [...byBlock.values()].filter((b) => b.length === size && b.every((r) => r.valida === "si")).flat();
  return (variants.length ? variants : [""]).map((v) => {
    const rows = complete.filter((r) => r.variante === v);
    return { variante: v, ganadas: rows.filter((r) => r.ganador === r.dotabot).length, validas: rows.length,
      jugadas: results.filter((r) => r.variante === v).length,
      topes: results.filter((r) => r.variante === v && r.resultado === "tope").length };
  });
}
const TIMELINES = join(root, "bench", "lineas");
const OBSERVATIONS = join(root, "bench", "observaciones");
const DIFFICULTIES = ["passive", "easy", "medium", "hard", "unfair"];

// One hero per position, from the heroes Valve's own bots were built for (their original pool, as recalled; not yet
// checked against "BotImplemented" in the game's npc_heroes.txt), so the Valve side is not crippled by an unsupported
// hero. Both teams ask for the same five; only Radiant keeps them (Dire picks its own, seen 2026-10-30).
export const HERO_POOL = [
  ["juggernaut", "phantom_assassin", "luna", "sven", "chaos_knight", "drow_ranger", "skeleton_king"],
  ["lina", "zuus", "sniper", "viper", "death_prophet", "razor", "necrolyte"],
  ["axe", "bristleback", "tidehunter", "dragon_knight", "sand_king", "kunkka"],
  ["lion", "jakiro", "vengefulspirit", "bane", "skywrath_mage"],
  ["crystal_maiden", "witch_doctor", "lich", "warlock", "dazzle", "oracle"],
];

export function drawHeroes(random = Math.random, avoid = []) {
  return HERO_POOL.map((pool) => {
    const free = pool.filter((h) => !avoid.includes("npc_dota_hero_" + h));
    const from = free.length ? free : pool;
    return "npc_dota_hero_" + from[Math.floor(random() * from.length)];
  });
}

// Lua read by the custom game (tools/bench/addon/scripts/vscripts/addon_game_mode.lua).
// turbo: the custom game imitates Turbo (Dota's real Turbo cannot run in a custom game: forcing game mode 23 changes
// nothing and the VScript API has no switch for it, both checked 2026-10-29).
export function matchConfigLua(heroes, difficulty, timescale, turbo = false, observar = false, heroesDire = null) {
  const list = heroes.map((h) => `"${h}"`).join(", ");
  // heroes_dire: Dire's own drawn heroes, none shared with Radiant's: the engine never gives the same hero to both
  // teams (0 of 112 matches did), so each team asks for its own and nothing is swapped. Without it ("--espejo no",
  // debugging) Dire asks for Radiant's and gets random ones.
  const dire = heroesDire ? `heroes_dire = { ${heroesDire.map((h) => `"${h}"`).join(", ")} }, ` : "";
  return `-- written by tools/bench/orquestador.mjs for one match; deleted when it ends\nreturn { difficulty = "${DIFFICULTIES[difficulty]}", timescale = ${timescale}, turbo = ${turbo}, observar = ${observar}, ${dire}heroes = { ${list} } }\n`;
}

// Which drawn group each side asks for (DECISIONES 2026-10-31): dota-bot (or variant a, against dota-bot) always gets
// the block's first draw and its rival the second, whatever the side. espejo "no": Dire left to the engine.
export function sideGroups(dotabot, heroes, rivals, espejo = "") {
  if (espejo === "no") return { radiant: heroes, dire: null };
  return dotabot === "radiant" ? { radiant: heroes, dire: rivals } : { radiant: rivals, dire: heroes };
}

// With --observar: the custom game's lines and the engine's lines about the bots (script errors, slow bot functions,
// invalid orders, buildings, bot skill builds and ward spots), kept per match in bench/observaciones/.
const OBSERVED = ["[dotabench]", "[bench]", "[Error]", "[ERROR]", "[WARN]", "[Reload]", "[PosSwap]", "[ARDM]",
  "Stack Trace", "GetNearbyHeroes", "LoadScript", "bot scripting using", "Script Runtime Error", "Script function '",
  "invalid order", "Building:", "in its bot skill build", "Bot ward spot", "XP Fountain"];
export function observationLines(text) {
  return text.split(/\r?\n/).filter((line) => OBSERVED.some((k) => line.includes(k))).join("\n") + "\n";
}

export function launchArgs() {
  return [
    // No window or resolution flags: they could stick in the owner's video settings.
    "-console", "-condebug", "-novid", "-gamestateintegration",
    "+sv_cheats", "1", "+sv_lan", "1", "+dota_launch_custom_game", "dotabench", "dota",
  ];
}

export function gsiConfig() {
  return `"dota-bot benchmark"
{
    "uri"       "http://127.0.0.1:${PORT}/"
    "timeout"   "5.0"
    "buffer"    "0.5"
    "throttle"  "1.0"
    "heartbeat" "30.0"
    "data"
    {
        "provider" "1"
        "map"      "1"
        "player"   "1"
    }
    "auth"
    {
        "token" "${TOKEN}"
    }
}
`;
}

// Reduces a GSI post to what the benchmark needs; null if it is not ours or has no map.
export function readGsi(payload) {
  if (!payload || payload.auth?.token !== TOKEN || !payload.map) return null;
  const m = payload.map;
  return {
    state: m.game_state ?? "",
    winner: m.win_team === "radiant" || m.win_team === "dire" ? m.win_team : null,
    clock: Number(m.clock_time ?? 0),
    radiantKills: Number(m.radiant_score ?? 0),
    direKills: Number(m.dire_score ?? 0),
    human: payload.player?.team_name ?? "",
  };
}

// The custom game logs "[dotabench] timeline event=minute|end min=.. rk=.. ..." lines (addon_game_mode.lua).
// Kills already made at the horn, per team: the timeline's minute-0 line ("timeline event=minute min=0 rk=1 dk=0").
export function killsBeforeHorn(rows) {
  const first = rows.find((r) => r.event === "minute" && r.min === 0);
  return { radiant: first?.rk ?? 0, dire: first?.dk ?? 0 };
}

// The most net worth one kill before the horn puts between the teams (measured 641 to 955, Turbo gold x2).
export const KILL_NW_GAP = 1100;

export function parseTimeline(text) {
  const rows = [];
  for (const line of text.split(/\r?\n/)) {
    const at = line.indexOf("[dotabench] timeline ");
    if (at < 0) continue;
    const row = {};
    for (const pair of line.slice(at + 21).trim().split(/\s+/)) {
      const [k, v] = pair.split("=");
      if (k && v !== undefined) row[k] = k === "event" ? v : Number(v);
    }
    rows.push(row);
  }
  return rows;
}

// From dota-bot's side: its biggest net worth lead, the first minute it led by 10k, and towers standing at the end.
export function summarizeTimeline(rows, dotabot) {
  if (!rows.length) return { ventaja_oro_max: "", minuto_10k: "", torres_fin: "" };
  const lead = (r) => (dotabot === "radiant" ? r.rnw - r.dnw : r.dnw - r.rnw);
  const last = rows[rows.length - 1];
  const first10k = rows.find((r) => lead(r) >= 10000);
  return {
    ventaja_oro_max: Math.max(...rows.map(lead)),
    minuto_10k: first10k ? first10k.min : "",
    torres_fin: `${last.rt}-${last.dt}`,
  };
}

// The custom game logs who really plays ("[dotabench] roster team=2 pid=1 bot=1 hero=npc_dota_hero_luna") and
// whether the human got a hero it had to remove. humano: "fuera" (clean), "heroe-quitado" (removed, the match still
// counts) or "en-equipo" (a human slot played the match: discard it). heroes: as selected, Radiant / Dire (the
// heroes really controlled are checked from the start lines).
export function parseRoster(text) {
  const teams = { 2: [], 3: [] };
  let humanInTeam = false;
  let removed = false;
  for (const line of text.split(/\r?\n/)) {
    if (line.includes("[dotabench] human hero removed")) removed = true;
    // hero= can be empty: a bot with no hero yet.
    const m = line.match(/\[dotabench\] roster team=(\d) pid=(\d+) bot=(\d) hero=(\S*)/);
    if (!m) continue;
    if (m[3] === "0") humanInTeam = true;
    teams[m[1]]?.push(m[4].replace("npc_dota_hero_", ""));
  }
  if (!teams[2].length && !teams[3].length) return { humano: "", heroes: "", radiant: 0, dire: 0 };
  return {
    humano: humanInTeam ? "en-equipo" : removed ? "heroe-quitado" : "fuera",
    heroes: `${teams[2].join(" ")} / ${teams[3].join(" ")}`,
    radiant: teams[2].length,
    dire: teams[3].length,
  };
}

// Once every hero has spawned ("[dotabench] start team=2 pid=1 hero=npc_dota_hero_luna nw=601"): the heroes really
// controlled, by their entity, and each team's starting net worth.
export function parseStart(text) {
  const teams = { 2: [], 3: [] };
  for (const line of text.split(/\r?\n/)) {
    const m = line.match(/\[dotabench\] start team=(\d) pid=\d+ hero=(\S+) nw=(-?\d+)/);
    if (m) teams[m[1]]?.push({ hero: m[2].replace("npc_dota_hero_", ""), nw: Number(m[3]) });
  }
  const nw = (t) => teams[t].reduce((a, p) => a + p.nw, 0);
  return { radiant: teams[2].length, dire: teams[3].length, heroesRadiant: teams[2].map((p) => p.hero),
    heroesDire: teams[3].map((p) => p.hero), nwRadiant: nw(2), nwDire: nw(3) };
}

// The same heroes, in any order ("npc_dota_hero_" prefixes ignored); "none" never matches.
export function sameSet(a, b) {
  const norm = (l) => (l ?? []).map((h) => String(h).replace("npc_dota_hero_", "")).sort().join(" ");
  return Array.isArray(a) && Array.isArray(b) && a.length > 0 && !a.includes("none") && norm(a) === norm(b);
}

// Bot heroes that appeared after the horn ("[dotabench] spawn pid=1 team=2 hero=... t=3.2"; a pid counts by its first
// spawn, since a real-hero copy such as Dazzle's Nothl Projection spawns mid-game): they lose lane time, and the first
// bot added used to do it in most matches. Returns "pid@t".
export function lateSpawns(text) {
  const lines = text.split(/\r?\n/);
  const bots = new Set();
  for (const line of lines) {
    const r = line.match(/\[dotabench\] roster team=\d pid=(\d+) bot=1/);
    if (r) bots.add(r[1]);
  }
  const last = new Map();
  for (const line of lines) {
    const m = line.match(/\[dotabench\] spawn pid=(\d+) team=\d hero=\S+ t=(-?[\d.]+)/);
    if (m && bots.has(m[1])) last.set(m[1], Math.min(last.get(m[1]) ?? Infinity, Number(m[2])));
  }
  return [...last].filter(([, t]) => t > 0).map(([pid, t]) => `${pid}@${t}`);
}

// Players of Valve's team (2 Radiant, 3 Dire) whose hero dota-bot's scripts played: only dota-bot writes
// "[bench] load pid=N team=T" (once per bot, always) and "[bench] mode t=... pid=N" (observer mode). Valve's team
// is told by roster lines.
export function valveIntruders(text, valveTeam) {
  const lines = text.split(/\r?\n/);
  const valvePids = new Set();
  const intruders = new Set();
  for (const line of lines) {
    const r = line.match(/\[dotabench\] roster team=(\d) pid=(\d+)/);
    if (r && Number(r[1]) === valveTeam) valvePids.add(r[2]);
  }
  for (const line of lines) {
    const m = line.match(/\[bench\] (?:mode t=\S+|load) pid=(\d+)/);
    if (m && valvePids.has(m[1])) intruders.add(m[1]);
  }
  return [...intruders].sort((a, b) => a - b);
}

// Couriers alive per team at minute 1 ("[dotabench] couriers team=3 n=5 speeds=1100/1100/..."): radiant, dire and
// the slowest speed on each side.
export function parseCouriers(text) {
  const out = { radiant: 0, dire: 0, slowRadiant: 0, slowDire: 0 };
  for (const line of text.split(/\r?\n/)) {
    const m = line.match(/\[dotabench\] couriers team=(\d) n=(\d+) speeds=(\S*)/);
    if (!m) continue;
    const min = m[3] ? Math.min(...m[3].split("/").map(Number)) : 0;
    const slow = Number.isFinite(min) ? min : 0; // a speed that is not a number fails the turbo check
    if (m[1] === "2") Object.assign(out, { radiant: Number(m[2]), slowRadiant: slow });
    if (m[1] === "3") Object.assign(out, { dire: Number(m[2]), slowDire: slow });
  }
  return out;
}

// Largest gap in starting net worth between the teams that still counts as the same start (purchase timing).
export const START_NW_GAP = 300;

// The variant file the custom game found at the start ("[dotabench] variant name=base ..." or "variant none").
export function parseVariant(text) {
  const m = text.match(/\[dotabench\] variant (?:name=(\S+)|none)/);
  return m ? m[1] ?? "" : null;
}

// The mode the custom game applied ("[dotabench] turbo on ..." or "turbo off"); "" if it logged neither.
export function parseModo(text) {
  const m = text.match(/\[dotabench\] turbo (on|off)/);
  return m ? (m[1] === "on" ? "turbo" : "normal") : "";
}

// Dota's build, from <dota>/game/dota/steam.inf.
export function parseVersion(inf) {
  return inf.match(/ClientVersion=(\d+)/)?.[1] ?? "";
}

export function timelineCsv(rows) {
  const cols = ["min", "rk", "dk", "rt", "dt", "rb", "db", "rhp", "dhp", "rnw", "dnw", "rc", "dc", "event"];
  return [cols.join(","), ...rows.map((r) => cols.map((c) => r[c] ?? "").join(","))].join("\n") + "\n";
}

export function isFinished(s) {
  return s !== null && s.state === "DOTA_GAMERULES_STATE_POST_GAME" && s.winner !== null;
}

export function csvRow(r) {
  return COLUMNS.map((c) => String(r[c] ?? "").replaceAll(",", ";")).join(",");
}

function parseArgs(argv) {
  const opt = { partidas: 2, dificultad: 4, velocidad: 4, etiqueta: "oha-vs-valve", dota: "C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta", maxMin: 75 };
  for (let i = 0; i < argv.length; i += 2) {
    const [k, v] = [argv[i], argv[i + 1]];
    if (k === "--partidas") opt.partidas = Number(v);
    else if (k === "--dificultad") opt.dificultad = Number(v);
    else if (k === "--velocidad") opt.velocidad = Number(v);
    else if (k === "--etiqueta") opt.etiqueta = v;
    else if (k === "--variantes") opt.variantes = String(v).split(",");
    else if (k === "--modo") opt.modo = v;
    else if (k === "--dota") opt.dota = v;
    else if (k === "--muestra-gsi") opt.muestra = v; // debugging: keeps the last raw GSI post in this file
    else if (k === "--observar") { opt.observar = true; i -= 1; } // a flag: takes no value
    else if (k === "--lado") opt.lado = v; // debugging one side: dota-bot always plays it (no side balance)
    else if (k === "--espejo") opt.espejo = v; // "no", debugging only: Dire keeps the random heroes the engine gives it
    else if (k === "--rival") opt.rival = v; // "valve" (default) or "dotabot": both teams dota-bot, one variant each
    else throw new Error(`Opción desconocida: ${k}`);
  }
  if (!Number.isInteger(opt.partidas) || opt.partidas < 1 || opt.partidas > 50) throw new Error("--partidas: 1 a 50");
  if (!Number.isInteger(opt.dificultad) || opt.dificultad < 0 || opt.dificultad > 4) throw new Error("--dificultad: 0 a 4");
  if (!Number.isInteger(opt.velocidad) || opt.velocidad < 1 || opt.velocidad > 8) throw new Error("--velocidad: 1 a 8");
  if (!/^[\w.-]{1,40}$/.test(opt.etiqueta)) throw new Error("--etiqueta: letras, números, . _ -");
  opt.variantes ??= [];
  opt.modo ??= "normal";
  if (!["normal", "turbo"].includes(opt.modo)) throw new Error("--modo: normal o turbo");
  if (opt.lado !== undefined && !["radiant", "dire"].includes(opt.lado)) throw new Error("--lado: radiant o dire");
  opt.rival ??= "valve";
  if (!["valve", "dotabot"].includes(opt.rival)) throw new Error("--rival: valve o dotabot");
  if (opt.rival === "dotabot" && ((opt.variantes ?? []).length !== 2 || opt.lado !== undefined)) {
    throw new Error("--rival dotabot: exactamente dos --variantes (la que se prueba primero) y sin --lado");
  }
  for (const v of opt.variantes) if (!Object.hasOwn(VARIANTS, v)) throw new Error(`--variantes: ${Object.keys(VARIANTS).join(", ")}`);
  if (new Set(opt.variantes).size !== opt.variantes.length) throw new Error("--variantes: sin repetir");
  const block = opt.rival === "dotabot" ? 2 : 2 * Math.max(opt.variantes.length, 1);
  if (opt.variantes.length && opt.partidas % block !== 0) throw new Error(`--partidas: múltiplo de ${block} con esas variantes`);
  opt.block = block;
  return opt;
}

// Whole-machine CPU use (all processes, Dota included) since the previous sample, from Node's os module.
function cpuSampler() {
  const total = () => os.cpus().reduce((a, c) => {
    const t = c.times;
    return { busy: a.busy + t.user + t.nice + t.sys + t.irq, all: a.all + t.user + t.nice + t.sys + t.irq + t.idle };
  }, { busy: 0, all: 0 });
  let prev = total();
  return () => {
    const now = total();
    const pct = now.all > prev.all ? (100 * (now.busy - prev.busy)) / (now.all - prev.all) : 0;
    prev = now;
    return pct;
  };
}

function gitOut(args) {
  return new Promise((ok) => execFile("git", ["-C", root, ...args], (err, out) => ok(err ? "?" : out)));
}

async function currentCode() {
  return codeState(await gitOut(["rev-parse", "HEAD"]),
    await gitOut(["--no-optional-locks", "status", "--porcelain", "--untracked-files=all", "--", "bots", "tools/bench"]),
    await gitOut(["rev-parse", "HEAD:bots", "HEAD:tools/bench"]));
}

function running(image) {
  return new Promise((ok, fail) =>
    execFile("tasklist", ["/FI", `IMAGENAME eq ${image}`, "/FO", "CSV", "/NH"], (err, out) =>
      err ? fail(err) : ok(out.toLowerCase().includes(`"${image.toLowerCase()}"`))));
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function main(argv) {
  const opt = parseArgs(argv);
  const exe = resolve(opt.dota, "game/bin/win64/dota2.exe");
  const gsiDir = resolve(opt.dota, "game/dota/cfg/gamestate_integration");
  const gsiFile = join(gsiDir, "gamestate_integration_dotabot.cfg");
  const consoleLog = resolve(opt.dota, "game/dota/console.log");
  if (!existsSync(exe)) throw new Error(`No encuentro ${exe}; usa --dota`);
  if (!existsSync(gsiDir)) throw new Error(`No existe ${gsiDir}`);
  if (!existsSync(resolve(opt.dota, "game/dota_addons/dotabench/addoninfo.txt"))) {
    throw new Error("Falta el custom game dotabench en Dota: corre pwsh tools/instalar.ps1");
  }
  if (!(await running("steam.exe"))) throw new Error("Steam no está abierto; ábrelo y vuelve a correr esto.");
  if (await running("dota2.exe")) throw new Error("Ya hay un Dota abierto; ciérralo primero (no lo toco).");
  for (const f of [VALVE_TEAM_FILE, VARIANT_FILE, OBSERVE_FILE]) {
    if (!existsSync(f)) continue;
    // Only this script writes them: a leftover means an earlier run was killed hard.
    unlinkSync(f);
    console.log(`Aviso: quedaba ${f} de una corrida interrumpida; lo borré.`);
  }
  const steamInf = resolve(opt.dota, "game/dota/steam.inf");
  const dotaVersion = () => { try { return parseVersion(readFileSync(steamInf, "utf8")); } catch { return ""; } };
  const firstVersion = dotaVersion();
  if (!firstVersion) throw new Error(`No leo la versión de Dota en ${steamInf}; sin ella no puedo validar la serie.`);

  let latest = null;
  let lastPost = 0;
  const server = createServer((req, res) => {
    req.on("error", () => {});
    if (req.method !== "POST") return res.writeHead(405).end();
    let body = "";
    req.on("data", (c) => {
      body += c;
      if (body.length > 256 * 1024) req.destroy();
    });
    req.on("end", () => {
      res.writeHead(200).end();
      try {
        const payload = JSON.parse(body);
        const s = readGsi(payload);
        if (s) [latest, lastPost] = [s, Date.now()];
        if (s && opt.muestra) writeFileSync(opt.muestra, JSON.stringify(payload, null, 1));
      } catch {}
    });
  });
  await new Promise((ok, fail) => server.once("error", fail).listen(PORT, "127.0.0.1", ok));

  // On Windows a killed child keeps exitCode null (signalCode is set), so liveness comes from the 'exit' event.
  let child = null;
  let childAlive = false;
  const removeTeamFile = () => {
    try { if (existsSync(VALVE_TEAM_FILE)) unlinkSync(VALVE_TEAM_FILE); } catch {}
  };
  const removeVariantFile = () => {
    try { if (existsSync(VARIANT_FILE)) unlinkSync(VARIANT_FILE); } catch {}
    try { if (existsSync(OBSERVE_FILE)) unlinkSync(OBSERVE_FILE); } catch {}
  };
  // Synchronous on purpose: it also runs from process.on('exit'), after an uncaught error or process.exit().
  const cleanup = () => {
    try { if (childAlive) child.kill(); } catch {}
    removeTeamFile();
    removeVariantFile();
    try { if (existsSync(MATCH_FILE)) unlinkSync(MATCH_FILE); } catch {}
    try { if (existsSync(gsiFile)) unlinkSync(gsiFile); } catch {}
    try { server.close(); } catch {}
  };
  process.on("exit", cleanup);
  for (const sig of ["SIGINT", "SIGHUP", "SIGBREAK", "SIGTERM"]) {
    process.on(sig, () => {
      console.log("\nInterrumpido: cierro mi Dota y borro mis archivos temporales.");
      process.exit(130);
    });
  }

  try {
    writeFileSync(gsiFile, gsiConfig());
    mkdirSync(dirname(CSV), { recursive: true });
    if (!existsSync(CSV)) appendFileSync(CSV, COLUMNS.join(",") + "\n");
    else {
      // New columns go at the end: rewrite only the header, older rows just leave them empty.
      const [head, ...rest] = readFileSync(CSV, "utf8").split("\n");
      if (head.trim() !== COLUMNS.join(",")) writeFileSync(CSV, [COLUMNS.join(","), ...rest].join("\n"));
    }
    // Dota plays the clone its junctions point to (tools/instalar.ps1): from any other worktree, the files this script
    // writes and the commit it records would not be what plays.
    const real = (p) => { try { return realpathSync(p).toLowerCase(); } catch { return "?" + p; } };
    if (real(resolve(opt.dota, "game/dota_addons/dotabench")) !== real(join(root, "tools/bench/addon"))
      || real(join(root, "tools/bench/addon/scripts/vscripts/bots")) !== real(join(root, "bots"))) {
      throw new Error("Dota no juega este clon (las junctions de tools/instalar.ps1 apuntan a otro); paro.");
    }
    const firstCodigo = await currentCode();
    console.log(`Código de la serie: ${firstCodigo}`);
    if (/\?|\+cambios/.test(firstCodigo)) {
      throw new Error(`El código de bots/, del custom game o del orquestador no tiene commit (${firstCodigo}); ninguna partida valdría. Paro.`);
    }
    const results = [];
    let heroes = [];
    let rivals = [];
    for (let i = 0; i < opt.partidas; i++) {
      if (await running("dota2.exe")) throw new Error("Hay un Dota abierto que no es mío; paro sin tocarlo.");
      const rival = opt.rival === "dotabot";
      const planned = rival ? rivalSchedule(i, opt.variantes) : schedule(i, opt.variantes);
      const codigoAntes = await currentCode();
      const { block } = planned;
      const dotabot = opt.lado ?? planned.dotabot;
      const valveTeam = dotabot === "radiant" ? DIRE : RADIANT;
      // The variant the custom game must find in the log: one per match, or "a-vs-b" when both teams are dota-bot.
      const variant = rival ? rivalName(planned.radiant, planned.dire) : planned.variant;
      removeVariantFile();
      if (rival) {
        writeFileSync(VARIANT_FILE, rivalVariantLua(planned.radiant, planned.dire));
      } else {
        writeFileSync(VALVE_TEAM_FILE, `-- written by tools/bench/orquestador.mjs for one match; deleted when it ends\nreturn ${valveTeam}\n`);
        if (variant) writeFileSync(VARIANT_FILE, variantLua(variant));
      }
      if (opt.observar) writeFileSync(OBSERVE_FILE, "-- written by tools/bench/orquestador.mjs for one match; deleted when it ends\nreturn true\n");
      if (i % opt.block === 0) { heroes = drawHeroes(); rivals = drawHeroes(Math.random, heroes); }
      const groups = sideGroups(dotabot, heroes, rivals, opt.espejo ?? "");
      const esperado = { radiant: groups.radiant, dire: groups.dire ?? [] };
      writeFileSync(MATCH_FILE, matchConfigLua(groups.radiant, opt.dificultad, opt.velocidad, opt.modo === "turbo", Boolean(opt.observar), groups.dire));
      latest = null;
      lastPost = 0;
      const names = (l) => l.map((h) => h.replace("npc_dota_hero_", "")).join(" ");
      const short = `${names(heroes)} contra ${names(rivals)}`;
      console.log(rival
        ? `Partida ${i + 1}/${opt.partidas}: ${planned.radiant} en radiant contra ${planned.dire} en dire; héroes ${short}.`
        : `Partida ${i + 1}/${opt.partidas}${variant ? ` (variante ${variant})` : ""}: dota-bot en ${dotabot}, Valve en ${valveTeam === RADIANT ? "radiant" : "dire"}; héroes ${short}.`);
      const cpu = cpuSampler();
      const cpuSamples = [];
      let nextSample = Date.now() + 30_000;
      const started = Date.now();
      child = spawn(exe, launchArgs(), { cwd: dirname(exe), stdio: "ignore" });
      childAlive = true;
      child.on("exit", () => { childAlive = false; });
      let launchError = null;
      child.on("error", (e) => { childAlive = false; launchError = e; });
      let outcome = "timeout";
      while (Date.now() - started < opt.maxMin * 60_000) {
        await sleep(2000);
        if (Date.now() >= nextSample) { cpuSamples.push(cpu()); nextSample += 30_000; }
        if (launchError) throw new Error(`No pude lanzar Dota: ${launchError.message}`);
        if (!childAlive) { outcome = "dota-cerrado"; break; }
        if (!lastPost && Date.now() - started > 8 * 60_000) { outcome = "sin-gsi"; break; }
        // The team file stays until the match ends: a hero that loads its scripts late (spawned after the horn, or
        // swapped by the old mirror) ran dota-bot's on Valve's team without it (S6, 2026-10-31; it used to be
        // removed at the horn). A hard kill leaves it behind until the next run (bench/README.md).
        if (isFinished(latest)) { outcome = "final"; break; }
        if ((latest?.clock ?? 0) >= GAME_CAP_MIN * 60) { outcome = "tope"; break; }
      }
      removeTeamFile();
      removeVariantFile();
      const memFree = Math.round((100 * os.freemem()) / os.totalmem());
      if (childAlive) {
        await sleep(3000);
        child.kill();
        const deadline = Date.now() + 30_000;
        while (childAlive && Date.now() < deadline) await sleep(500);
        if (childAlive) throw new Error("Mi Dota no se cerró en 30 s; paro.");
      }
      if (outcome === "dota-cerrado" && (await running("dota2.exe"))) {
        throw new Error("Mi Dota se cerró pero hay otro dota2.exe abierto; paro sin tocarlo.");
      }
      // The custom game's per-minute timeline, from this launch's console.log (-condebug rewrites it each launch).
      const fecha = new Date().toISOString().slice(0, 16);
      let timeline = [];
      let roster = { humano: "", heroes: "", radiant: 0, dire: 0 };
      let start = null;
      let couriers = null;
      let intrusos = null;
      let tardios = null;
      let loggedVariant = null;
      let loggedModo = "";
      try {
        // A log older than this launch belongs to another match (Dota failed before rewriting it).
        if (statSync(consoleLog).mtimeMs >= started) {
          const log = readFileSync(consoleLog, "utf8");
          timeline = parseTimeline(log);
          roster = parseRoster(log);
          start = parseStart(log);
          couriers = parseCouriers(log);
          // Without dota-bot's load lines (older bots/) there is nothing to check who played each hero.
          intrusos = rival ? [] : /\[bench\] load pid=/.test(log) ? valveIntruders(log, valveTeam) : null;
          tardios = /\[dotabench\] spawn /.test(log) ? lateSpawns(log) : null;
          loggedVariant = parseVariant(log);
          loggedModo = parseModo(log);
          if (opt.observar) {
            mkdirSync(OBSERVATIONS, { recursive: true });
            writeFileSync(join(OBSERVATIONS, `${opt.etiqueta}-${fecha.replace(/[-:T]/g, "")}-${i + 1}.log`), observationLines(log));
          }
        }
      } catch {}
      const version = dotaVersion();
      // The bots read bots/ live: a change during the match means it played no single commit.
      const codigoDespues = await currentCode();
      const codigo = codigoAntes.endsWith("+cambios") || codeTree(codigoAntes) !== codeTree(codigoDespues)
        ? `${codigoDespues.replace("+cambios", "")}+cambios` : codigoDespues;
      const motivo = validity({ outcome, roster, variant, loggedVariant, version, firstVersion, modo: opt.modo, loggedModo,
        espejo: opt.espejo ?? "", start, codigo, firstCodigo, couriers, intrusos, tardios, esperado,
        killsAtStart: killsBeforeHorn(timeline) });
      if (timeline.length) {
        mkdirSync(TIMELINES, { recursive: true });
        writeFileSync(join(TIMELINES, `${opt.etiqueta}-${fecha.replace(/[-:T]/g, "")}-${i + 1}.csv`), timelineCsv(timeline));
      }
      const s = latest ?? {};
      const row = {
        fecha, etiqueta: opt.etiqueta, partida: i + 1, bloque: block + 1, variante: rival ? planned.variant : variant,
        valida: motivo ? "no" : "si", motivo, dificultad: opt.dificultad,
        dotabot, ganador: outcome === "final" ? s.winner : "", resultado: outcome,
        minutos: s.clock ? Math.round(s.clock / 60) : "", kills_radiant: s.radiantKills ?? "",
        kills_dire: s.direKills ?? "", humano: roster.humano, heroes: roster.heroes || short,
        ...summarizeTimeline(timeline, dotabot),
        dota_version: version,
        cpu_media: cpuSamples.length ? Math.round(cpuSamples.reduce((a, b) => a + b, 0) / cpuSamples.length) : "",
        cpu_max: cpuSamples.length ? Math.round(Math.max(...cpuSamples)) : "",
        mem_libre: memFree,
        modo: opt.modo,
        codigo,
        rival: opt.rival,
      };
      appendFileSync(CSV, csvRow(row) + "\n");
      results.push(row);
      console.log(`  ${outcome}${row.ganador ? `: gana ${row.ganador} (${row.ganador === dotabot ? "dota-bot" : "Valve"})` : ""}${motivo ? ` · NO VÁLIDA: ${motivo}` : ""}`);
      if (outcome === "sin-gsi") { console.log("Dota no envió datos por GSI; paro."); break; }
      if (tooManyInvalid(results)) {
        console.log(`Más del ${MAX_INVALID_SHARE * 100} % de las partidas no son válidas; paro para investigar.`);
        break;
      }
      await sleep(8000);
    }
    if (opt.rival === "dotabot") {
      // Rows are written from the first variant's side: its wins are the matches it won against the second.
      const [s] = summarize(results, [opt.variantes[0]]);
      // A capped match has no winner: neither variant won it, so it shows apart (not as a win for the second).
      console.log(`${opt.variantes[0]} ganó ${s.ganadas} de ${s.validas} partidas válidas contra ${opt.variantes[1]} (jugó ${s.jugadas}; ${s.topes} llegaron al tope de ${GAME_CAP_MIN} min sin ganador). Detalle en bench/series.csv.`);
    } else for (const s of summarize(results, opt.variantes)) {
      console.log(`${s.variante ? `Variante ${s.variante}: ` : ""}dota-bot ganó ${s.ganadas} de ${s.validas} partidas válidas de bloques completos (jugó ${s.jugadas}; ${s.topes} llegaron al tope de ${GAME_CAP_MIN} min). Detalle en bench/series.csv.`);
    }
  } finally {
    cleanup();
  }
}

const self = fileURLToPath(import.meta.url).toLowerCase();
if (process.argv[1] && resolve(process.argv[1]).toLowerCase() === self) {
  main(process.argv.slice(2)).catch((e) => {
    console.error(e.message);
    process.exit(1);
  });
}
