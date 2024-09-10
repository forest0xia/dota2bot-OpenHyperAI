## We love bot games!

We love bot games! There is currently a Valve side bug, [CRITICAL] in order to play the script you need to create a Lobby and select "Local Host" as Server Location. To enable enhanced challenging mode, follow the steps on Workshop page to correctly install this script. The bots in game should have names with suffix ".OHA" when installed correctly.

Bot script in Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3246316298

#### Script introduction in other languages:
1. [中文介绍](https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4764334012740794651/)
1. [Введение на русском](https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4764334012740807463/)
1. [Introducción en español](https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4764334012740863589/)
1. [Introdução em português](https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4764334012740872368/)
1. If you still have language problems, copy the content and paste to https://chatgpt.com/ or other tools to translate words to your language.

Thanks and kudos to all that contributed to make bot games fun and exciting.

#### The goal of this script is to: 
1. Share the most up to date functionalities that we've implemented/fixed to keep the bot games challenging, 
1. For players to have fun with chill by playing/practicing against the bots that can play ALL Dota2 heroes. 
1. Bots are meant to be for chill games, if you are looking for more competitive bots than the existing ones, please stop complaining and help us build it with constructive effort.


## Why it's enjoyable
0. Support 7.37
1. Support ALL 125 heroes! You will see bots playing Ringmaster, Invoker, Techies, Meepo, Lone Druid, Dark Willow, Hoodwink, io, Muerta, Primal Beast, etc. Just note that some of the newly added ones are not very strong and in progress to be further enhanced.
1. Bots are customizable . E.g. you can easily set ban / picks for bots, change their names, etc. Check out the file in [bots/Customize/general.lua](bots/Customize/general.lua), or in local Workshop directory: `<steam folder>\steamapps\workshop\content\570\3246316298\Customize\general.lua`
1. Dynamic difficulty. If you ever feel all existing bot scripts lack excitement. This script boosts bots with huge unfair advantages to make bot games a lot more challenging. You will need to copy the script into your local vscripts folder and then enable the Fretbots mode for this feature. See instructions below.
1. Support almost ALL game modes: https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4334231305373971730/
1. Improved code structure & general logic for decision making for ability casting, item usages, defending, roaming as well as farming.
1. Enhanced AI Chatbot. You can chat with bots in the game as if they were real and optimistic players. Integrated with ChatGPT. [Note: you need to enable Fretbot mode for this, check out How to Install section below.]
1. All supported heroes in this script can play any position roles. Heroes will go to any lane they are assigned. The laning or pos of the bot heroes will seem random in the game, but it's deterministic - check the Bot roles section below.
1. Fixed tons of bugs. Bugs that can cause bots to stay idle or cancel it's own channeling spells or stuck on weird states.

## How to install this script?
1. There is currently a bug on Valve side that new bot scripts can only work in Custom Lobby with "Local Host" as the Server Location.
2. This script can boost bots with huge unfair advantage that make the game much harder. You must manually install this script, please follow the instruction here: https://steamcommunity.com/workshop/filedetails/discussion/3246316298/6197594023017709799/

## Bot roles, lanings and positioning
1. In local lobby, the positions of the bots are the same as the order of the slots: 1, 2, 3, 4, 5 from top to bottom in the lobby.
1. Support multiple in-game commands:
   1. `!pos X` You can type: `!pos X` to swap the position with a bot. For example: `!pos 2` to swap role and lane with the bot that's going to mid.
   1. `!pick XXX` During hero selection phase, you can type: `!pick XXX` to pick a hero. For example: `!pick puck` to pick puck as ally.
      1. You can type: `/all !pick XXX` to pick hero for enemy. For example: `/all !pick puck` to pick puck as enemy.
      1. For complex hero names or names that may apply to multiple heroes, please use the full internal code name. For example: `!pick npc_dota_hero_keeper_of_the_light` .
      1. You can find a list of hero names here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Heroes_internal_names
   1. `!ban XXX` You can type: `!ban XXX` to ban a hero so the bots won't pick that hero. For example: `!ban puck` to prevent any bots from picking puck.
      1. For complex hero names or names that may apply to multiple heroes, please use the full internal code name. For example: `!ban npc_dota_hero_keeper_of_the_light` .
      1. You can find a list of hero names here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Heroes_internal_names
1. You can change bot ban/picks, and roles, etc easily and permanently. Check out the file in [bots/Customize/general.lua](bots/Customize/general.lua)
1. Pos1 and Pos5 bots go to safe lane. Pos3 and Pos4 bots go offlane. Pos2 bot goes to mid lane.

## If you want to contribute to this script
1. Please feel very welcome to contribute to the Github repo any time you like. Just update the logic and create a pull request.
1. Future development work for this script will be written in typescript as possible: [typescript/README](typescript/README.md).
1. The typescipt source code is as well work-in-progress, feel free to convert more lua files to ts, and add libs/modules as you feel necessary.

## What's next
0. Ultimately, the bots play style is static/fixed with the current AI approach provided by Valve at the moment. We need machine learning AI bots! Just like the AIs we’ve seen from OpenAI Five.
1. Follow up on https://www.reddit.com/r/DotA2/comments/1ezxpav/a_note_to_valve_official_regarding_bot_scripts/
1. Maybe traning machine learning AI.
1. Better decision making on laning, pushing and ganking.
1. Better spell casting for certain heroes like Invoker, Rubick, etc.
1. Support all game modes.
1. More code bug fixes.
1. Figure out how to better support the Bugged-Heroes: Dark Willow, Elder Titan, Hoodwink, io, Lone Druid, Marci, Muerta, Primal Beast. Note that they are buggy due to problems on the Valves side, not script developers.

## Support the script
If you'd like to buy me a coffee: https://steamcommunity.com/workshop/filedetails/discussion/3246316298/6553383644012991605/

## Useful resources:
- Posts shared by Ranked Matchmaking AI author: https://www.adamqqq.com/ai/dota2-ai-devlopment-tutorial.html
- Official Bot side script intro: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
- Lua (Bots side) APIs: https://docs.moddota.com/lua_bots/
- Ability metadata: https://raw.githubusercontent.com/dotabuff/d2vpk/master/dota_pak01/scripts/npc/npc_abilities.txt
- Lua APIs, modes, and enum values: https://moddota.com/api/#!/vscripts/dotaunitorder_t
- Bot modifier names: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Modifier_Names
- Dota2 data mining (details of items, abilities, heroes): https://github.com/muk-as/DOTA2_WEB/blob/master/dota2_web/Items_cn.json

## Credits to
This script is based on Valve's default bot script and many other people's work and their scripts. That being said, this is a partial override not completely take over bot script. It takes the advantages of some other existing bot scripts and aims to be a better off script than the existing ones. We hope the bot's decision making and team strategies are more effective and brings more joy to you.

- Tinkering ABout (by @ryndrb: https://github.com/ryndrb/dota2bot or https://steamcommunity.com/sharedfiles/filedetails/?id=3139791706). This is a script derived from Tinkering ABout. But the code has diverged significantly w.r.t roles, item selection, farming, laning, roaming, push, defend, rosh/runes strategies, as well as the local support with Fretbots. Presumably the future maintenance will keep diverging even more.
- New beginner ai (by dota2jmz@163.com).
- Ranked Matchmaking AI (by adamqqq)
- fretbots (by fretmute)
- BOT Experiment (by Furiospuppy)
- ExtremePush (https://github.com/insraq/dota2bots)
- All other bot script authors/contributors that had made bot scripts interesting.

## Things to be updated (not ranked by priority, ChatGPT translated to English):
- less farming, more group push in late games.
- focus more on tower and base in push.
- use tango or something to escape from Prophet first spell trees
- Bots should be less aggressive to chase people into towers, human will take advantage of that to continuely lowering bot's hp and get the kill.
- Bots should respect the TPs while chasing people.
- Bot should rethink about dot damage on them. they run away from dot damage without considering why. e.g. dark seer ion shell you can chase a bot from their t1 to your t1 by simply walking behind them and they take the path most directly away from it. 
- Bots should take exp runes. [exp rune is not officially supported as of 5.5.2024]
- Bots are ignoreing some abilities or modifiers that have relatively long duration and can end up deal with high dmg, spells like dazzle’s first ability modifier.
- Calculate Enigma's ultimate damage. 1600 range, lasts 4 seconds, plus Decay. Engage if it can kill, even if alone.
- Use ultimate if it can hit all visible people and can take at least one with it.
- Don't just focus on attacking Brewmaster's ultimate summons.
- Enigma can use ultimate on just one. If it has been a long time since the last use, or if the target is one of the top two strongest visible enemies.
- Or if you are slowed, with more than two enemies nearby. Being attacked. Health below 75%.
- If already at half health and running away, continue to retreat rather than turning back.
- During laning phase, don't use Sun Strike. Now focusing on Cold Snap and Lightning in the early game. In mid and late game, Sun Strike only on controlled targets or to secure kills.
- Don't use Sun Strike when nearly at full health. Don't use Carl's Sun Strike just for channelling.
- Sun Strike release is very confusing. Check if the position or target is wrong.
- Sun Strike always fails to connect, consider removing cast point.
- Prioritize global Sun Strike conditions. If there's Enigma's ult or similar, prioritize using big Sun Strike, or with Batrider's pull.
- Don't ignore illusion damage.
- If retreating, calculate the total nearby illusions, decide whether to Wind Walk or go invisible. If possible, calculate total damage. In late game, can't judge escape skills based on health alone.
- First 3 minutes. If within 300 range there are Slark, Pudge, retreat to 500 before fighting them.
- If there is a Witch Doctor's Maledict nearby, and the state lasts more than half, being attacked and health less than half. Don't continue to tank damage, retreat. If you're going to die but TP might save you, then TP.
- Dodge shadow demon's skills. Similar to dodging Pudge's hooks.
- Carry Gem/more dusts/wards in the late game.
- Expand the search range for the weakest. Look for hiding mages, Witch Doctor, or Sniper.
- Why would you act alone in the late game?
- If dead late game, or resurrected and the enemy 5 are near the high ground, and your side has fewer people alive or less than the enemy, don't engage.
- If Jakiro's ultimate ignores magic immunity, then retreat even if under BKB.
- If your side has all 5 heroes, or more people, in good condition, have pushed high, and most of the enemy are dead, do not retreat or farm. Continue to hit towers or barracks. Unless the enemy is within 500 range, don't be distracted.
- If there are no allies nearby, don't go to open outposts alone.
- Carl sell Ashes.
- Skeleton King sell Armlet and Phase.
- If Refresher Orb was just used. If there are more than 3 allies and more than 2 enemies nearby, don't use Cyclone. Consider other combo skills directly.
- If you have the state of Wraith King's Aghanim's, it proves you died, don't retreat.
- Random role location.
- In the first 5 minutes, if stacked by Huskar's spears 3 layers or more, health less than half and the enemy won't be killed immediately, or the enemy has more health, retreat until the spears expire. Similarly for Monkey King, Slardar, etc. In late game, if stacked many layers, just TP.
- In the first 5 minutes, don't roam, especially as a mid-laner.
- If being attacked by a tower, and there's a small creep nearby, and all are within tower range, attack the enemy's small creep.
- If no enemy heroes nearby and your side's status is below 75, don't get attacked by the tower.
- Random ward locations.
- If Carl, don't use Ashes to heal, even if very low on health, unless there are many charges.
- Roshan cannot be seen. Check Roshan's status only when within attack range.
- If inside a Static Storm, activate BKB.
- After 25 minutes, if more than 2 enemies are nearby, prioritize using Meteor to push waves. After 30 minutes, regardless of the number of people, prioritize Meteor push wave QQQ, then use other skills.
- Lina and Quick Sprint use less after 30 minutes, unless out of other skills.
- Rubick, if it's a single point and not a target, then location. If it is a target, then unit.
- Invoker shouldn't always be farming.
- Carl, if there are people nearby and you have very low health, retreat unconditionally. Because Carl's full-screen abilities will cancel previous retreat commands.
- Bots won't immediately use items from their backpack. Better backpack managment needed to 1, swap items for e.g. healings and swap back when used.
- Don't go to outpost alone or use smoke.
- Bots should be able to dynamically change the item-build-list and skill-talent-build list to refect the role swapping with player - in case player uses !pos to swap roles.


