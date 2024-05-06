# Beginner-AI and Fretbots Enhanced
 A beta dota script. Derived from https://github.com/p6668/beginner-ai-and-fretbots which is based on three other bot scripts:
- fretbots: https://github.com/fretmute/fretbots
- beginner AI: https://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
- new heroes from: https://github.com/ryndrb/dota2bot


### Useful resources:
- Posts shared by Ranked Matchmaking AI author: https://www.adamqqq.com/ai/dota2-ai-devlopment-tutorial.html
- Official Bot side script intro: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
- Lua (Bots side) APIs: https://docs.moddota.com/lua_bots/
- Ability metadata: https://raw.githubusercontent.com/dotabuff/d2vpk/master/dota_pak01/scripts/npc/npc_abilities.txt
- Lua APIs, modes, and enum values: https://moddota.com/api/#!/vscripts/dotaunitorder_t
- Bot modifier names: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Modifier_Names
- Dota2 data mining (details of items, abilities, heroes): https://github.com/muk-as/DOTA2_WEB/blob/master/dota2_web/Items_cn.json


### Things to be updated (not ranked by priority):
- Bots should be less aggressive to chase people into towers, human will take advantage of that to continuely lowering bot's hp and get the kill.
- Bots should respect the TPs while chasing people.
- Bots should have regens in laning phase. Don't stay in lane if ph is too low. e.g. not calling in regen like omni would have 1400 hp and sit in lane on 200 till they tp back and take a free kill
- Better Tormentor strategy with human players
- Bot should rethink about dot damage on them. they run away from dot damage without considering why. e.g. dark seer ion shell you can chase a bot from their t1 to your t1 by simply walking behind them and they take the path most directly away from it. 
- Bots should take exp runes. [exp rune is not officially supported as of 5.5.2024]
- Bots are ignoreing some abilities or modifiers that have relatively long duration and can end up deal with high dmg, spells like dazzle’s first ability modifier.

### Things fixed
- Bots are now more flexible with different laning or roles. They were not able to purchase items if they were assigned with different role or laning.
- Added/Improved a bunch of hero support so bots can have better performance on more heroes with better strategy of the ability usage, item purcahse, etc, such as Invoker casting abilities and making combos.
- When Fretbot is enabled. A list of unfair settings get applied in addition to what was provided by Frebot originally:
  - The bots get bonus mana/hp regens and provide less exp on death.
  - When a player kills a bot, the player who made the kill receives a reduction in gold. This does not affect assisting players.
- Bots with refresher won't directly use refresher immidiately, this is to prevent e.g. Void, Enigma using ult immidiately twice. The logic is now also overridable in each bot files.
- [updated, need to test] Don't kill couriers if bot is targeting a dieing hero or is retreating.
- [updated, need to test] Don't focus on some minions over heroes.
- Bots won't stay on some ability effects for lone. e.g. jakiro_macropyre_burn, dark_seer_wall, sandking_sand_storm, warlock_upheaval, etc. Bots have the intension to run away from those effects.
