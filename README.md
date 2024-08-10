### We love bot games!

Thanks and kudos to all that contributed to make bot games fun and exciting.
The goal of this script is to share the most up to date functionalities that we've implemented or fixed to keep the bot games challenging.

This script is based on Valve's default bot script and many other people's work and their scripts. That being said, this is a partial override not completely take over bot script. It takes the advantages of some other existing bot scripts and aims to be a better off script than the existing ones. We hope the bot's decision making and team strategies are more effective and brings more joy to you.

Bot script in Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3246316298

### Why it's enjoyable
0. Support 7.36
1. Support ALL 124 heroes! You will see bots playing Invoker, Techies, Meepo, Lone Druid, Dark Willow, Hoodwink, io, Muerta, Primal Beast, etc. Just note that some of the newly added ones are not very strong and in progress to be further enhanced.
1. All supported heroes in this script can play any position roles. Heroes will go to any lane they are assigned. The laning or pos of the bot heroes will seem random in the game, but it's deterministic - check the Bot roles section below.
1. Dynamic difficulty. If you ever feel all existing bot scripts lack excitement. This script boosts bots with huge unfair advantages to make bot games a lot more challenging. You will need to copy the script into your local vscripts folder and then enable the Fretbots mode for this feature. See instructions below.
1. Support multiple modes: All Pick, Turbo, Captain Mode, Random Draft, Single Draft, All Random, Mid Only, Least Played, and 1V1 mid. 
   1. For 1V1 mid: Enemy will pick the same hero after your pick. This way you can play 1:1 SF mid, or any mid heroes you like to practice against bot with the same hero.
   1. For 1V1 mid: Other bots, if you have any other empty slots filled with bots, will all go to top.
   1. For Captain mode, the role swap "!pos X" is not supported. Follow lobby order and be the captain.
1. Improved code structure & general logic for decision making for ability and item usages as well as roaming and farming.
1. Fixed tons of bugs. Bugs that can cause bots to stay idle or cancel it's own channeling spells or stuck on weird state.
1. Enhanced AI Chatbot. You can chat with bots in the game as if they were real and optimistic players. Integrated with ChatGPT. [Note: you need to enable Fretbot mode for this, check out How to Install section below.]
1. Bots are customizable easily. E.g. you can change bot names, bot ban/picks, etc. Check out the file in `bots/Customize/general.lua`

### How to install this script?
1. There is currently a bug on Valve side that new bot scripts can only work in Custom Lobby with "Local Host" as the Server Location.
2. This script can boost bots with huge unfair advantage that make the game much harder. You must manually install this script, please follow the instruction here: https://steamcommunity.com/workshop/filedetails/discussion/3246316298/6197594023017709799/

### Bot roles, lanings and positioning
1. In local lobby, the positions of the bots are the same as the order of the slots: 1, 2, 3, 4, 5 from top to bottom in the lobby.
1. During hero selection phase, you can type: `!pick XXX` to pick a hero. For example: `!pick puck` to pick puck as ally.
1.  You can type: `/all !pick XXX` to pick hero for enemy. For example: `/all !pick puck` to pick puck as enemy.
   1. For complex hero names or names that may apply to multiple heroes, please use the full internal code name. For example: `!pick npc_dota_hero_keeper_of_the_light` .
   1. You can find a list of hero names here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Heroes_internal_names
1. You can type: `!ban XXX` to ban a hero so the bots won't pick that hero. For example: `!ban puck` to prevent any bots from picking puck.
1. You can type: `!pos X` to swap the position with a bot. For example: `!pos 2` to swap role and lane with the bot that's going to mid.
1. Pos1 and Pos5 bots go to safe lane. Pos3 and Pos4 bots go offlane. Pos2 bot goes to mid lane.

### What's next
1. This is a script derived from Tinkering About (by @ryndrb). But the code has diverged significantly w.r.t roles, item selection, farming, laning, rosh/runes strategies, as well as the local support with Fretbots. So the future maintenance will keep diverging.
2. More heroes support.
3. Better decision making on pushing and ganking.
4. Better spell casting for certain heroes like Invoker, Rubick, etc.
5. More code bug fixes.
6. Better laning logic to avoid bots feeding too much in the early game.
7. Figure out how to better support the Bugged-Heroes: Dark Willow, Elder Titan, Hoodwink, io, Lone Druid, Marci, Muerta, Primal Beast. Note that they are buggy due to problems on the Valves side, not script developers.

### Supporting me
If you'd like to buy me a coffee: https://www.buymeacoffee.com/forest.dota

### Useful resources:
- Posts shared by Ranked Matchmaking AI author: https://www.adamqqq.com/ai/dota2-ai-devlopment-tutorial.html
- Official Bot side script intro: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
- Lua (Bots side) APIs: https://docs.moddota.com/lua_bots/
- Ability metadata: https://raw.githubusercontent.com/dotabuff/d2vpk/master/dota_pak01/scripts/npc/npc_abilities.txt
- Lua APIs, modes, and enum values: https://moddota.com/api/#!/vscripts/dotaunitorder_t
- Bot modifier names: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Modifier_Names
- Dota2 data mining (details of items, abilities, heroes): https://github.com/muk-as/DOTA2_WEB/blob/master/dota2_web/Items_cn.json

### Credits to
- New beginner ai (by dota2jmz@163.com).
- Tinkering ABout (by ryndrb: https://github.com/ryndrb/dota2bot or https://steamcommunity.com/sharedfiles/filedetails/?id=3139791706)
- Ranked Matchmaking AI (by adamqqq)
- fretbots (by fretmute)
- BOT Experiment (by Furiospuppy)
- ExtremePush (https://github.com/insraq/dota2bots)
- All other bot script authors/contributors that had made bot scripts interesting.

### Things to be updated (not ranked by priority, ChatGPT translated to English):
- AM in place blink
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
- Fix `!pos X` command for Dire side when player skips some slots in local lobby and still wants to swap role with a bot.
- Better support for role switching in captain mode.


