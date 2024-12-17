--[[
This is a place for you to customize the Open Hyper AI bots. 

1. You can customize each individual heroes so they can behave the way you personally preferred - good for your experimental games,
   and you can keep overridding the setup by overridding the files for yourself at any time for any style. 
   To customize the setup for another hero, just add a new file with the hero's unit name but without the prefix `npc_dota_hero_`.
   Hero unit names list: https://steamcommunity.com/workshop/filedetails/discussion/3246316298/4848777260032086340/
2. When modiftying this file, be VERY careful to the spelling, punctuation and variable names - it's very easy to cause 
   syntax errors and could be hard for you to debug.
3. In the case you saw the bots cannot purchase items, fail to upgrade abilities, or having some random names or picks (heroes not what you have set or without "OHA" name suffix), 
   that means you had made some mistakes/errors while modifying this file. 
4. In any case this file got messed up and caused the bots to malfunction, you can try to delete this customized hero file.
5. If you think the setup you made is better and should be shared to all other players, don't hesitate to contributing to our Github repo.

- Github repo: https://github.com/forest0xia/dota2bot-OpenHyperAI
- Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3246316298
--]]


-- The variable to hold the settings. Only modify if you know exactly what you are doing.
local Hero = { }

-- Set it to true to turn on ALL of the custom settings in this file, or set it to false to turn off the settings.
Hero.Enable = false

-- The ability upgrade order of the bot. 1 means the first ability, 2 means the second ability, ..., 6 means the ultimate ability.
-- Be very careful when changing the values, if you misplace 1 ability it can cause the bot failing to upgrade all the other abilities.
Hero.AbilityUpgrade = {1,3,1,2,1,6,1,3,2,3,6,2,3,2,6}

-- The talent upgrade choices. There are 4 tiers of talents to choose when the bot reaches level 10, 15, 20, and 25.
-- "l" means choose the talent on the "left" side; "r" means choose the talent on the "right" side.
Hero.Talent = {"r", "l", "l", "r"}

-- The items this bot will purchase in game. Note if you cutomize this list, the bot will purchase these items no matter what its position is in the game.
Hero.PurchaseList = {
	"item_tango",
	"item_faerie_fire",
	"item_clarity",
	"item_double_branches",
	"item_circlet",
	"item_slippers",

	"item_bottle",
	"item_magic_wand",
	"item_wraith_band",
	"item_power_treads",
	"item_mage_slayer",--
	"item_orchid",
	"item_bloodthorn",--
	"item_dragon_lance",
    "item_force_staff",
	"item_hurricane_pike",--
	"item_aghanims_shard",
	"item_kaya_and_sange",--
	"item_travel_boots",
	"item_shivas_guard",--
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

-- The items this bot will sell in game. Note the items should be paired together - when the bot gets the first item in the pair, the bot sells the second item.
Hero.SellList = {
    "item_bloodthorn", "item_circlet",
}

return Hero