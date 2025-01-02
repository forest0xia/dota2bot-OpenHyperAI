import { writeFileSync } from "fs";

// Simple sleep helper (in milliseconds)
function sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
}

const GAP_BETWEEN_API_CALLS = 300; // add a gap (ms) to work as client side throttling.
const API_ENDPOINT = "https://api.stratz.com/graphql";

const STRATZ_API_KEY = process.env.STRATZ_API_KEY;
if (!STRATZ_API_KEY) {
    throw new Error("No STRATZ_API_KEY environment variable found. Please set it first.");
}

const GRAPHQL_HEADERS = {
    "User-Agent": "STRATZ_API",
    Authorization: `Bearer ${STRATZ_API_KEY}`,
    "Content-Type": "application/json",
};

async function graphqlRequest(query: string): Promise<any> {
    const response = await fetch(API_ENDPOINT, {
        method: "POST",
        headers: GRAPHQL_HEADERS,
        body: JSON.stringify({ query }),
    });

    if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Request failed with status ${response.status}: ${errorText}`);
    }

    return response.json();
}

async function generateLuaTable(): Promise<void> {
    try {
        // 1) Grab hero definitions
        const heroResponse = await graphqlRequest(allHeroesQuery);
        const heroArray: Array<{ id: number; name: string }> = heroResponse.data.constants.heroes || [];

        let luaOutput = "local hHeroNeutralsMatchup = {\n";

        // 2) Retrieve neutral item stats for each hero
        for (const hero of heroArray) {
            // Optional: Wait 1 second (or any suitable duration) before each request
            await sleep(GAP_BETWEEN_API_CALLS); // <-- Throttling: adjust this delay as needed

            const { id: heroId, name: heroName } = hero;
            console.log(`Retrieving data for hero: ${heroName}`);

            const neutralStatsResponse = await graphqlRequest(buildNeutralItemsQuery(heroId));
            const neutralStats = neutralStatsResponse.data.heroStats.itemNeutral || [];

            const tierMap: Record<string, Array<any>> = {};
            for (const entry of neutralStats) {
                const tier = entry.item?.stat?.neutralItemTier;
                if (tier == null) continue;
                tierMap[tier] = tierMap[tier] || [];
                tierMap[tier].push(entry);
            }

            luaOutput += `  ['${heroName}'] = {\n`;

            // Sort tiers numerically
            const sortedTiers = Object.keys(tierMap).sort((a, b) => Number(a) - Number(b));
            for (const tier of sortedTiers) {
                const itemsInTier = tierMap[tier].sort((a, b) => b.equippedMatchCount - a.equippedMatchCount);
                const totalUsage = itemsInTier.reduce((sum, obj) => sum + obj.equippedMatchCount, 0);

                if (totalUsage > 0) {
                    luaOutput += `    ['${tier}'] = {`;
                    for (const itemStat of itemsInTier) {
                        const itemName = itemStat.item.name;
                        const usage = itemStat.equippedMatchCount;
                        const pickPercentage = ((usage / totalUsage) * 100).toFixed(2);
                        luaOutput += `['${itemName}']=${pickPercentage}, `;
                    }
                    luaOutput = luaOutput.replace(/, $/, "");
                    luaOutput += `},\n`;
                }
            }

            luaOutput += "  },\n";
        }

        luaOutput += "}\nreturn hHeroNeutralsMatchup\n";
        writeFileSync("bots/FretBots/static_neutrals_matchup.lua", luaOutput, { encoding: "utf-8" });

        console.log("Successfully created 'static_neutrals_matchup.lua'!");
    } catch (error) {
        console.error("An error occurred while generating the Lua table:", error);
    }
}

/**
 * GraphQL query to retrieve all heroes.
 */
const allHeroesQuery = `
  {
    constants {
      heroes {
        id
        name
      }
    }
  }
`;

/**
 * Build a query for fetching neutral item statistics for a specific hero.
 */
function buildNeutralItemsQuery(heroId: number): string {
    return `
    {
      heroStats {
        itemNeutral(heroId: ${heroId}, bracketBasicIds: [DIVINE_IMMORTAL]) {
          itemId
          equippedMatchCount
          item {
            name
            stat {
              neutralItemTier
            }
          }
        }
      }
    }
  `;
}

generateLuaTable();
