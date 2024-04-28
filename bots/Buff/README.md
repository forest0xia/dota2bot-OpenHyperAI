This script is insprired by Fretbots. It runs in conjuction with the bot script. When playing with AP, bots are typically underfarmed and (underleveled), due to their tendency to roam and not really farm much.
So, I made this to increase their GPM and XPM accordingly based on their role (cores only). I only care about increasing their GPM and XPM, hence I'm not using Fretbots.

I also added a functionality for bots to get neutral items. It is random for now.

# To Use (for anyone randomly finding this)
1. Launch DotA 2 with console enabled.
2. For local host only, so Create a Lobby. Make sure that `Enable Cheats` is checked. 
3. After the map finished loading, open the console, and type: `sv_cheats 1` then `script_reload_code bots/Buff/buff`.
4. The script is now running (The last command should only be run once).

It can be used with other bot scripts, just change some stuff accordingly, to suit whichever script. Or use fretbots.

It would've been nice to call this within the bot script, but I don't think it is possible.