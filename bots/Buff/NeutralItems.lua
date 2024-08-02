if NeutralItems == nil
then
    NeutralItems = {}
end

local isTierOneDone   = false
local isTierTwoDone   = false
local isTierThreeDone = false
local isTierFourDone  = false
local isTierFiveDone  = false

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
            NeutralItems.GiveItem(Tier1NeutralItems[RandomInt(1, #Tier1NeutralItems)], h, isTierOneDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier1NeutralItems[RandomInt(1, #Tier1NeutralItems)], h, isTierOneDone)
        end

        isTierOneDone = true
    end

    -- Tier 2 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 8.5 * 60 or Helper.DotaTime() >= 17 * 60)
    and not isTierTwoDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 2 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.GiveItem(Tier2NeutralItems[RandomInt(1, #Tier2NeutralItems)], h, isTierOneDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier2NeutralItems[RandomInt(1, #Tier2NeutralItems)], h, isTierOneDone)
        end

        isTierTwoDone = true
    end

    -- Tier 3 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 13.5 * 60 or Helper.DotaTime() >= 27 * 60)
    and not isTierThreeDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 3 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.GiveItem(Tier3NeutralItems[RandomInt(1, #Tier3NeutralItems)], h, isTierTwoDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier3NeutralItems[RandomInt(1, #Tier3NeutralItems)], h, isTierTwoDone)
        end

        isTierThreeDone = true
    end

    -- Tier 4 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 18.5 * 60 or Helper.DotaTime() >= 37 * 60)
    and not isTierFourDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 4 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.GiveItem(Tier4NeutralItems[RandomInt(1, #Tier4NeutralItems)], h, isTierThreeDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier4NeutralItems[RandomInt(1, #Tier4NeutralItems)], h, isTierThreeDone)
        end

        isTierFourDone = true
    end

    -- Tier 5 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 30 * 60 or Helper.DotaTime() >= 60 * 60)
    and not isTierFiveDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 5 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.GiveItem(Tier5NeutralItems[RandomInt(1, #Tier5NeutralItems)], h, isTierFourDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.GiveItem(Tier5NeutralItems[RandomInt(1, #Tier5NeutralItems)], h, isTierFourDone)
        end

        isTierFiveDone = true
    end
end

function NeutralItems.GiveItem(itemName, hero, isTierDone)
    if hero:HasRoomForItem(itemName, true, true)
    then
        local item = CreateItem(itemName, hero, hero)
        item:SetPurchaseTime(0)

        if NeutralItems.HasNeutralItem(hero)
        and isTierDone
        then
            hero:RemoveItem(hero:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT))
            hero:AddItem(item)
        else
            hero:AddItem(item)
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