if NeutralItems == nil
then
    NeutralItems = {}
end

local isTierOneDone   = false
local isTierTwoDone   = false
local isTierThreeDone = false
local isTierFourDone  = false
local isTierFiveDone  = false
local DOTA_ITEM_NEUTRAL_SLOT = 16

local Tier1NeutralItems = {
    --[[Trusty Shovel]]         "item_trusty_shovel",
    --[[Arcane Ring]]           "item_arcane_ring",
    -- --[[Fairy's Trinket]]       "item_mysterious_hat",
    --[[Pig Pole]]              "item_unstable_wand",
    --[[Safety Bubble]]         "item_safety_bubble",
    --[[Seeds of Serenity]]     "item_seeds_of_serenity",
    --[[Lance of Pursuit]]      "item_lance_of_pursuit",
    --[[Occult Bracelet]]       "item_occult_bracelet",
    --[[Duelist Gloves]]        "item_duelist_gloves",
    --[[Broom Handle]]          "item_broom_handle",
    --[[Royal Jelly]]           "item_royal_jelly",
    --[[Faded Broach]]          "item_faded_broach",
    --[[Spark Of Courage]]      "item_spark_of_courage",
    --[[Ironwood Tree]]         "item_ironwood_tree",
}

local Tier2NeutralItems = {
    --[[Dragon Scale]]          "item_dragon_scale",
    --[[Whisper of the Dread]]  "item_whisper_of_the_dread",
    --[[Pupil's Gift]]          "item_pupils_gift",
    --[[Grove Bow]]             "item_grove_bow",
    --[[Philosopher's Stone]]   "item_philosophers_stone",
    --[[Bullwhip]]              "item_bullwhip",
    --[[Orb of Destruction]]    "item_orb_of_destruction",
    --[[Specialist's Array]]    "item_specialists_array",
    --[[Eye of the Vizier]]     "item_eye_of_the_vizier",
    --[[Vampire Fangs]]         "item_vampire_fangs",
    --[[Gossamer's Cape]]       "item_gossamer_cape",
    --[[Light Collector]]       "item_light_collector",
    --[[Iron Talon]]            "item_iron_talon",
}

local Tier3NeutralItems = {
    --[[Defiant Shell]]         "item_defiant_shell",
    --[[Paladin Sword]]         "item_paladin_sword",
    --[[Nemesis Curse]]         "item_nemesis_curse",
    --[[Vindicator's Axe]]      "item_vindicators_axe",
    --[[Dandelion Amulet]]      "item_dandelion_amulet",
    --[[Craggy Coat]]           "item_craggy_coat",
    --[[Enchanted Quiver]]      "item_enchanted_quiver",
    --[[Elven Tunic]]           "item_elven_tunic",
    --[[Cloack of Flames]]      "item_cloak_of_flames",
    --[[Ceremonial Robe]]       "item_ceremonial_robe",
    --[[Psychic Headband]]      "item_psychic_headband",
    --[[Doubloon]]              "item_doubloon",
    --[[Vambrace]]              "item_vambrace",
}

local Tier4NeutralItems = {
    --[[Timeless Relic]]        "item_timeless_relic",
    --[[Ascetic Cap]]           "item_ascetic_cap",
    --[[Aviana's Feather]]      "item_avianas_feather",
    --[[Ninja Gear]]            "item_ninja_gear",
    --[[Telescope]]             "item_spy_gadget",
    --[[Trickster Cloak]]       "item_trickster_cloak",
    --[[Stormcrafter]]          "item_stormcrafter",
    --[[Ancient Guardian]]      "item_ancient_guardian",
    --[[Havoc Hammer]]          "item_havoc_hammer",
    --[[Mind Breaker]]          "item_mind_breaker",
    -- --[[Martyr's Plate]]        "item_martyrs_plate",
    --[[Rattlecage]]            "item_rattlecage",
    --[[Ogre Seal Totem]]       "item_ogre_seal_totem",
}

local Tier5NeutralItems = {
    --[[Force Boots]]           "item_force_boots",
    --[[Stygian Desolator]]     "item_desolator_2",
    --[[Seer Stone]]            "item_seer_stone",
    --[[Mirror Shield]]         "item_mirror_shield",
    --[[Apex]]                  "item_apex",
    --[[Book of the Dead]]      "item_demonicon",
    --[[Arcanist's Armor]]      "item_force_field",
    --[[Pirate Hat]]            "item_pirate_hat",
    --[[Giant's Ring]]          "item_giants_ring",
    --[[Unwavering Condition]]  "item_unwavering_condition",
    --[[Book of Shadows]]       "item_book_of_shadows",
    --[[Magic Lamp]]            "item_panic_button",
}

local enhancements = {
    -- Tier 1 enhancements
    { name = "item_enhancement_mystical", tier = 1, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
    { name = "item_enhancement_brawny",    tier = 1, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
    { name = "item_enhancement_alert",     tier = 1, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
    { name = "item_enhancement_tough",     tier = 1, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
    { name = "item_enhancement_quickened", tier = 1, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },

    -- Tier 2 enhancements
    { name = "item_enhancement_mystical", tier = 2, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
    { name = "item_enhancement_brawny",    tier = 2, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
    { name = "item_enhancement_alert",     tier = 2, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
    { name = "item_enhancement_tough",     tier = 2, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
    { name = "item_enhancement_quickened", tier = 2, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },
    { name = "item_enhancement_keen_eyed", tier = 2, roles = {1, 1, 1, 1, 2}, realName = "Keen Eyed Enhancement" },
    { name = "item_enhancement_vast",      tier = 2, roles = {1, 1, 1, 1, 1}, realName = "Vast Enhancement" },
    { name = "item_enhancement_greedy",    tier = 2, roles = {1, 1, 1, 2, 2}, realName = "Greedy Enhancement" },
    { name = "item_enhancement_vampiric",  tier = 2, roles = {1, 1, 1, 1, 1}, realName = "Vampiric Enhancement" },

    -- Tier 3 enhancements
    { name = "item_enhancement_mystical", tier = 3, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
    { name = "item_enhancement_brawny",    tier = 3, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
    { name = "item_enhancement_alert",     tier = 3, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
    { name = "item_enhancement_tough",     tier = 3, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
    { name = "item_enhancement_quickened", tier = 3, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },
    { name = "item_enhancement_keen_eyed", tier = 3, roles = {1, 1, 1, 1, 2}, realName = "Keen Eyed Enhancement" },
    { name = "item_enhancement_vast",      tier = 3, roles = {1, 1, 1, 1, 1}, realName = "Vast Enhancement" },
    { name = "item_enhancement_greedy",    tier = 3, roles = {1, 1, 1, 2, 2}, realName = "Greedy Enhancement" },
    { name = "item_enhancement_vampiric",  tier = 3, roles = {1, 1, 1, 1, 1}, realName = "Vampiric Enhancement" },

    -- Tier 4 enhancements
    { name = "item_enhancement_mystical", tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Mystical Enhancement" },
    { name = "item_enhancement_brawny",    tier = 4, roles = {1, 1, 3, 2, 2}, realName = "Brawny Enhancement" },
    { name = "item_enhancement_alert",     tier = 4, roles = {1, 2, 1, 1, 1}, realName = "Alert Enhancement" },
    { name = "item_enhancement_tough",     tier = 4, roles = {1, 1, 2, 2, 1}, realName = "Tough Enhancement" },
    { name = "item_enhancement_quickened", tier = 4, roles = {1, 1, 1, 2, 1}, realName = "Quickened Enhancement" },
    { name = "item_enhancement_vampiric",  tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Vampiric Enhancement" },
    { name = "item_enhancement_timeless", tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Timeless Enhancement" },
    { name = "item_enhancement_titanic",  tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Titanic Enhancement" },
    { name = "item_enhancement_crude",    tier = 4, roles = {1, 1, 1, 1, 1}, realName = "Crude Enhancement" },

    -- Tier 5 enhancements
    { name = "item_enhancement_timeless", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Timeless Enhancement" },
    { name = "item_enhancement_titanic",  tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Titanic Enhancement" },
    { name = "item_enhancement_crude",    tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Crude Enhancement" },
    { name = "item_enhancement_feverish", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Feverish Enhancement" },
    { name = "item_enhancement_fleetfooted", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Fleetfooted Enhancement" },
    { name = "item_enhancement_audacious", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Audacious Enhancement" },
    { name = "item_enhancement_evolved",  tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Evolved Enhancement" },
    { name = "item_enhancement_boundless", tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Boundless Enhancement" },
    { name = "item_enhancement_wise",     tier = 5, roles = {1, 1, 1, 1, 1}, realName = "Wise Enhancement" },
}

function NeutralItems:GetRandomEnhanByTier(tier)
    local filtered = {}
    for _, enh in ipairs(enhancements) do
        if enh.tier == tier then
            table.insert(filtered, enh)
        end
    end

    if #filtered == 0 then
        return nil  -- No enhancement found for this tier
    end

    -- Return a random enhancement from the filtered list.
    return filtered[math.random(#filtered)]
end


-- Just give out random for now.
-- Will work out a decent algorithm later to better assign suitable items.
function NeutralItems.GiveNeutralItems(TeamRadiant, TeamDire)
    local isTurboMode = Helper.IsTurboMode()

    -- Tier 1 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 3.5 * 60 or Helper.DotaTime() >= 7 * 60)
    and not isTierOneDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 1 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.GiveItem(Tier1NeutralItems[RandomInt(1, #Tier1NeutralItems)], h, isTierOneDone, 1)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier1NeutralItems[RandomInt(1, #Tier1NeutralItems)], h, isTierOneDone, 1)
        end

        isTierOneDone = true
    end

    -- Tier 2 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 8.5 * 60 or Helper.DotaTime() >= 17 * 60)
    and not isTierTwoDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 2 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.GiveItem(Tier2NeutralItems[RandomInt(1, #Tier2NeutralItems)], h, isTierOneDone, 2)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier2NeutralItems[RandomInt(1, #Tier2NeutralItems)], h, isTierOneDone, 2)
        end

        isTierTwoDone = true
    end

    -- Tier 3 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 13.5 * 60 or Helper.DotaTime() >= 27 * 60)
    and not isTierThreeDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 3 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.GiveItem(Tier3NeutralItems[RandomInt(1, #Tier3NeutralItems)], h, isTierTwoDone, 3)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier3NeutralItems[RandomInt(1, #Tier3NeutralItems)], h, isTierTwoDone, 3)
        end

        isTierThreeDone = true
    end

    -- Tier 4 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 18.5 * 60 or Helper.DotaTime() >= 37 * 60)
    and not isTierFourDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 4 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.GiveItem(Tier4NeutralItems[RandomInt(1, #Tier4NeutralItems)], h, isTierThreeDone, 4)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier4NeutralItems[RandomInt(1, #Tier4NeutralItems)], h, isTierThreeDone, 4)
        end

        isTierFourDone = true
    end

    -- Tier 5 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 30 * 60 or Helper.DotaTime() >= 60 * 60)
    and not isTierFiveDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 5 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.GiveItem(Tier5NeutralItems[RandomInt(1, #Tier5NeutralItems)], h, isTierFourDone, 5)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier5NeutralItems[RandomInt(1, #Tier5NeutralItems)], h, isTierFourDone, 5)
        end

        isTierFiveDone = true
    end
end

function NeutralItems.GiveItem(itemName, hero, isTierDone, nTier)
    NeutralItems:RemoveEnhan(hero)
    if hero:HasRoomForItem(itemName, true, true)
    then
        local item = CreateItem(itemName, hero, hero)
        item:SetPurchaseTime(0)

        if NeutralItems.HasNeutralItem(hero)
        and isTierDone
        then
            hero:RemoveItem(hero:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT))
            NeutralItems:RemoveEnhan(hero)
            hero:AddItem(item)
        else
            hero:AddItem(item)
        end
        local enhancement = NeutralItems:GetRandomEnhanByTier(nTier)
        if enhancement then
            local enha = CreateItem(enhancement.name, hero, hero)
            enha:SetPurchaseTime(0)
            hero:AddItem(enha)
        end
    end
end

function NeutralItems:RemoveEnhan(unit)
	for idx = 1, 20 do
		local currentItem = unit:GetItemInSlot(idx)
		if currentItem ~= nil then
			if string.find(currentItem:GetName(), "item_enhancement") then
				unit:RemoveItem(currentItem)
				-- return
			end
		end
	end
end

function NeutralItems.HasNeutralItem(hero)
    if not hero then
        return false
    end

    local item = hero:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT)
    if item then
        return true
    end

    return false
end

return NeutralItems