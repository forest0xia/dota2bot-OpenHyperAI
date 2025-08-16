# We Love Bot Games!

We love bot games! 🎮

> **\[CRITICAL]** To play this script you must create a **Custom Lobby** and select **Local Host** as the server location.

Bots should have names ending with **“.OHA”** when installed correctly.

👉 [Steam Workshop Link](https://steamcommunity.com/sharedfiles/filedetails/?id=3246316298)

Thanks and kudos to everyone who contributed to making bot games fun and exciting!

---

## Script Goals

1. Keep bot games **challenging and up to date**.
2. Let players **practice against bots** that can play *all* Dota 2 heroes.
3. Provide **chill gameplay** – if you want highly competitive bots, please join us in improving them instead of complaining.

---

## Why It’s Enjoyable

* ✅ Supports Dota 2 **Patch 7.39**.
* ✅ Supports **all 126 heroes** (Kez, Ringmaster, Invoker, Techies, Meepo, Lone Druid, Muerta, Primal Beast, etc.). Some new heroes are still being tuned.
* ✅ **Customizable bots**: ban/picks, names, item builds, skill upgrades, etc.

  * [Customize/general.lua](bots/Customize/general.lua) – general settings.
  * [Customize/hero/viper.lua](bots/Customize/hero/viper.lua) – hero-specific settings.
  * Path depends on install method:

    * **Workshop only**: `<Steam\steamapps\workshop\content\570\3246316298\Customize>`
    * **Quick-install**: `<Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts\game\Customize>`
* ✅ **Dynamic difficulty (Fretbots mode)** – boosts bots with huge unfair advantages for real challenge.
* ✅ Supports **most game modes** (see [discussion](https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/72)).
* ✅ Improved decision-making: ability casting, items, roaming, farming, defense.
* ✅ **AI Chatbot**: chat with bots as if they were real optimistic players (requires Fretbots mode).
* ✅ Bots can **play any role/position** – deterministic laning assignment.
* ✅ Tons of **bug fixes** (idle bots, canceled channels, stuck states).

---

## How to Install

1. Create a **Custom Lobby** → select **Local Host** as **Server Location**.
2. To enable **Fretbots mode** (harder bots, neutral items, chatbot, etc.), you must **manually install** the script: [Instructions here](https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/68).

---

## Bot Roles & Positioning

* Lobby slot order = position assignment (1–5).
* Default role mapping:

  * **Pos1 & Pos5** → Safe Lane
  * **Pos2** → Mid Lane
  * **Pos3 & Pos4** → Offlane
* Customize picks, bans, and roles in [Customize/general.lua](bots/Customize/general.lua).

---

## In-Game Commands

* `!pos X` → Swap your lane/role with a bot (e.g., `!pos 2`).
* `!pick HERO` → Pick a hero for yourself.

  * `/all !pick HERO` → Pick hero for enemy.
  * Use internal names if needed (`!pick npc_dota_hero_keeper_of_the_light`). [List here](https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/71).
* `!Xpos Y` → Reassign other bots’ positions (e.g., `!3pos 5`).
* `!ban HERO` → Ban a hero from being picked.
* `!sp XX` → Set bot language (`!sp en`, `!sp zh`, `!sp ru`, `!sp ja`).
* **Batch commands** supported (e.g., `!pick io; !ban sniper`).

---

## Contribute

* Contributions welcome on [GitHub](https://github.com/forest0xia/dota2bot-OpenHyperAI).
* Custom item/skill builds don’t need PRs – just tweak locally.
* Future development is in **TypeScript** for better maintainability.
* Project structure (bots, Funlib, Customize, BotLib, typescript, game)：
```
root: <Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts>
│
└───bots: contains all lua files for the bot logic. This is the folder `3246316298` in Workshop.
│   │   hero_selection.lua
│   │   bot_generic.lua
│   │   ...
│   │
│   └───Funlib: contains the libraries/utils of this project
│   │   │   utils.lua
│   │   │   ...
│   │
│   └───Customize: contains the files for you to easily customzie the settings for bots in this project
│   │   │   general.lua: to customzie the settings for each bot teams
│   │   │   ...
│   │   │
│   │   └───hero: to easily customzie each of the bots in this project
│   │       │   viper.lua
│   │       │   ...
│   │
│   └───BotLib: contains the bot item purcahse, ability usage, etc logic for every bots.
│       │   hero_abaddon.lua
│       │   ...
│   
└───typescript: contains the scripts written in typescript (TS) to maintain this project in a more 
│   │           extendable way since TS supports types and can catch errors in compile time.
│   │
│   └───bots: the TS version of the script that's converted to LUA files into the `root/bots` folder.
│   │   │   ...
│   │
│   └───post-process: contains the scripts to do post-processing for the TS to LUA translation.
│   │   ...
│   
└───game: default setup from Value, including them here for custom mode setup.
│   │   botsinit.lua
│   │   ...
│   │
│   └───Customize: You can copy & paste the Customize folder from <root/bots> to <root/game> to avoid
│                  the custom settings getting replaced/overridden by workshop upgrades.
│   ...
---
```
---

## What’s Next

* Current bot playstyle is limited by Valve’s API. **We need ML/LLM bots like OpenAI Five!**
* Planned improvements:

  * Smarter laning, pushing, ganking.
  * Stronger spell casting (Invoker, Rubick, Morph, etc.).
  * Better support for bugged heroes (Dark Willow, IO, Lone Druid, Muerta, etc.).
  * Full mode support + patch fixes.
* [Open feature requests](https://github.com/forest0xia/dota2bot-OpenHyperAI/issues?q=is%3Aissue+is%3Aopen+%5BFeature+request%5D)

---

## Support

* Contribute on GitHub.
* Or [buy me a coffee ☕](https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/74).

---

## Useful Resources

* [Dota2 AI Development Tutorial (adamqqq)](https://www.adamqqq.com/ai/dota2-ai-devlopment-tutorial.html)
* [Valve Bot Scripting Intro](https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting)
* [Lua Bot APIs](https://docs.moddota.com/lua_bots/)
* [Ability Metadata](https://raw.githubusercontent.com/dotabuff/d2vpk/master/dota_pak01/scripts/npc/npc_abilities.txt)
* [Enums & APIs](https://moddota.com/api/#!/vscripts/dotaunitorder_t)
* [Modifier Names](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Modifier_Names)
* [Dota2 Data Mining](https://github.com/muk-as/DOTA2_WEB/blob/master/dota2_web/Items_cn.json)

---

## Credits

Built on top of Valve’s default bots + contributions from many talented authors:

* New Beginner AI ([dota2jmz@163.com](mailto:dota2jmz@163.com))
* Tinkering About ([ryndrb](https://github.com/ryndrb/dota2bot))
* Ranked Matchmaking AI ([adamqqq](https://github.com/adamqqqplay/dota2ai))
* fretbots ([fretmute](https://github.com/fretmute/fretbots))
* BOT Experiment (Furiospuppy)
* ExtremePush ([insraq](https://github.com/insraq/dota2bots))
* And all other contributors who made bot games better.
