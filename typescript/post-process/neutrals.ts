// neutrals.ts
import fs from "node:fs";
import path from "node:path";
import puppeteer, { Browser } from "puppeteer";
import * as cheerio from "cheerio";
import { hero_name_table, neutral_name_table, enhancement_name_table } from "./names";

type TierKey = number;
type ItemKey = string;

interface ItemsData {
    neutral: Record<TierKey, Record<ItemKey, number>>;
    enhancement: Record<TierKey, Record<ItemKey, number>>;
}

const DOTABUFF_PATCH_QUERY = "patch_7.39";
const USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36";

async function withBrowser<T>(fn: (browser: Browser) => Promise<T>): Promise<T> {
    const browser = await puppeteer.launch({
        headless: true, // cross-version safe
        args: ["--no-sandbox", "--disable-gpu"],
    });
    try {
        return await fn(browser);
    } finally {
        await browser.close();
    }
}

async function fetchHtml(url: string, browser: Browser): Promise<string> {
    const page = await browser.newPage();
    await page.setUserAgent(USER_AGENT);
    await page.goto(url, { waitUntil: "domcontentloaded" });
    // Allow a short settle time like the Python sleep(5)
    try {
        // Dotabuff pages render a sortable table we parse
        await page.waitForSelector("table.sortable", { timeout: 1000 });
    } catch {
        // ignore if it never appears—parsers already handle "no table" gracefully
    }
    const html = await page.content();
    await page.close();
    return html;
}

function parseItemsTable(html: string): ItemsData | null {
    const $ = cheerio.load(html);
    const table = $("table.sortable").first();
    if (!table.length) return null;

    // raw buckets by seen tier
    const raw: ItemsData = { neutral: {}, enhancement: {} };

    const rows = table.find("tr").toArray().slice(1);
    for (const row of rows) {
        const cols = $(row).find("td");
        if (cols.length >= 3) {
            const itemName = $(cols[1]).text().trim();
            const matchesTxt = $(cols[2]).text().trim().replace(/,/g, "");
            const matches = Number(matchesTxt);
            if (!Number.isFinite(matches)) continue;

            // Try neutral then enhancement
            const sources: Array<[Record<number, Record<string, { visibleName: string } | { visibleName: string; tier_unique: number }>>, "neutral" | "enhancement"]> = [
                [neutral_name_table, "neutral"],
                [enhancement_name_table, "enhancement"],
            ];

            for (const [tableSpec, key] of sources) {
                for (const tierStr of Object.keys(tableSpec)) {
                    const tier = Number(tierStr);
                    for (const [itemKey, data] of Object.entries(tableSpec[tier])) {
                        if (data.visibleName === itemName) {
                            if (!raw[key][tier]) raw[key][tier] = {};
                            raw[key][tier][itemKey] = matches;
                        }
                    }
                }
            }
        }
    }

    const items: ItemsData = { neutral: {}, enhancement: {} };

    // Normalize neutral: per tier percentages
    const totalMatchesPerTier: Record<number, number> = {};
    for (const [tierStr, itemsInTier] of Object.entries(raw.neutral)) {
        const sum = Object.values(itemsInTier).reduce((a, b) => a + b, 0);
        totalMatchesPerTier[Number(tierStr)] = sum;
    }
    for (const [tierStr, itemsInTier] of Object.entries(raw.neutral)) {
        const tier = Number(tierStr);
        const total = totalMatchesPerTier[tier] ?? 0;
        items.neutral[tier] = {};
        for (const [itemKey, m] of Object.entries(itemsInTier)) {
            items.neutral[tier][itemKey] = total > 0 ? round2((m / total) * 100) : 0;
        }
    }

    // Enhancement: map to tier_unique, then normalize like Python
    for (const [tierStr, itemsInTier] of Object.entries(raw.enhancement)) {
        const tier = Number(tierStr);
        items.enhancement[tier] = {};

        // map each itemKey to its canonical tier_unique
        const itemKeyToTierUnique: Record<string, number> = {};
        for (const itemKey of Object.keys(itemsInTier)) {
            let found = false;
            for (const [nameTierStr, nameGroup] of Object.entries(enhancement_name_table)) {
                for (const [k, v] of Object.entries(nameGroup)) {
                    if (k === itemKey) {
                        itemKeyToTierUnique[itemKey] = v.tier_unique;
                        found = true;
                        break;
                    }
                }
                if (found) break;
            }
            if (!found) itemKeyToTierUnique[itemKey] = tier;
        }

        // compute totals per tier_unique (sum of raw matches for that group)
        const tierUniqueTotals: Record<number, number> = {};
        for (const itemKey of Object.keys(itemsInTier)) {
            const tu = itemKeyToTierUnique[itemKey];
            if (!(tu in tierUniqueTotals)) {
                let sum = 0;
                const group = enhancement_name_table[tu] ?? {};
                for (const [k, v] of Object.entries(group)) {
                    if (v.tier_unique === tu) {
                        const rawForTier = raw.enhancement[tu] ?? {};
                        if (k in rawForTier) sum += rawForTier[k];
                    }
                }
                tierUniqueTotals[tu] = sum;
            }
        }

        // percentage within tier_unique
        for (const [itemKey, m] of Object.entries(itemsInTier)) {
            const total = tierUniqueTotals[itemKeyToTierUnique[itemKey]] ?? 0;
            const pct = total > 0 ? (m / total) * 100 : 0;
            items.enhancement[tier][itemKey] = pct;
        }

        // normalize current seen tier so values sum to 100
        const subtotal = Object.values(items.enhancement[tier]).reduce((a, b) => a + b, 0);
        if (subtotal > 0) {
            for (const k of Object.keys(items.enhancement[tier])) {
                items.enhancement[tier][k] = round2((items.enhancement[tier][k] / subtotal) * 100);
            }
        }
    }

    return items;
}

function round2(n: number): number {
    return Math.round(n * 100) / 100;
}

async function getHeroItems(heroUrlName: string, browser: Browser): Promise<ItemsData | null> {
    const url = `https://www.dotabuff.com/heroes/${heroUrlName}/items?date=${DOTABUFF_PATCH_QUERY}`;
    const html = await fetchHtml(url, browser);
    return parseItemsTable(html);
}

async function main() {
    const itemsDict: Record<string, ItemsData> = {};

    await withBrowser(async browser => {
        // simple linear loop (you can parallelize with care for rate limits)
        for (const [internalName, data] of Object.entries(hero_name_table)) {
            console.log(`Fetching items for ${internalName}...`);
            try {
                const items = await getHeroItems(data.urlName, browser);
                if (items) {
                    itemsDict[internalName] = items;
                } else {
                    console.warn(`No items found for ${internalName}.`);
                }
            } catch (e) {
                console.error(`Error on ${internalName}:`, e);
            }
        }
    });

    // Write Lua (mirrors Python)
    const outPath = path.resolve(
        __dirname, // typescript/post-process
        "../../bots/FretBots/neutrals_data.lua"
    );

    const lines: string[] = [];
    lines.push("-----");
    lines.push("-- This file is generated by typescript/post-process/neutrals.ts");
    lines.push("-----\n");
    lines.push("local heroList = {");
    for (const [hero, itemData] of Object.entries(itemsDict)) {
        lines.push(`    ['${hero}'] = {`);
        for (const typeKey of ["neutral", "enhancement"] as const) {
            lines.push(`       ['${typeKey}'] = {`);
            for (const [tier, items2] of Object.entries(itemData[typeKey])) {
                const pairs = Object.entries(items2)
                    .map(([name, chance]) => `['${name}'] = ${round2(chance)}`)
                    .join(", ");
                lines.push(`           [${tier}] = {${pairs}},`);
            }
            lines.push("        },");
        }
        lines.push("    },");
    }
    lines.push("}\n\nreturn heroList\n");

    fs.writeFileSync(outPath, lines.join("\n"), "utf-8");
    console.log("\nneutrals_data.lua has been generated!");
}

if (require.main === module) {
    // Run as script
    main().catch(e => {
        console.error("Fatal error:", e);
        process.exit(1);
    });
}
