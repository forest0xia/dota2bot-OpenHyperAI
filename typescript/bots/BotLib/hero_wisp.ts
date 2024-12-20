import * as jmz from "bots/FunLib/jmz_func";
import { BotSetup, BotRole, ItemBuilds, SkillBuilds, TalentBuilds, TalentTreeBuild } from "bots/ts_libs/bots";
import { BotActionDesire, BotMode, Location, Talent, Unit, UnitType } from "bots/ts_libs/dota";
import { hero_is_healing } from "bots/FunLib/aba_buff";
import { GetTeamFountainTpPoint, HasAnyEffect, IsValidHero } from "bots/FunLib/utils";

const bot = GetBot();
// @ts-ignore
const minion = dofile("bots/FunLib/aba_minion");

const role: BotRole = jmz.Item.GetRoleItemsBuyList(bot);

// Construct for normal ability skills.
const defaultAbilityBuild = [1, 3, 1, 3, 1, 6, 1, 3, 3, 2, 6, 2, 2, 2, 6]; // Pos 5 Build
const allAbilitiesList: string[] = jmz.Skill.GetAbilityList(bot);
const roleSkillBuildList: SkillBuilds = {
    pos_1: defaultAbilityBuild,
    pos_2: defaultAbilityBuild,
    pos_3: defaultAbilityBuild,
    pos_4: defaultAbilityBuild,
    pos_5: defaultAbilityBuild,
};
const skillBuildList = roleSkillBuildList[role];

// Construct for talent skills.
const allTalentsList: Talent[] = jmz.Skill.GetTalentList(bot);
const defaultTalentTree: TalentTreeBuild = {
    t25: [10, 0],
    t20: [10, 0],
    t15: [0, 10],
    t10: [0, 10],
};
const roleTalentBuildList: TalentBuilds = {
    pos_1: defaultTalentTree,
    pos_2: defaultTalentTree,
    pos_3: defaultTalentTree,
    pos_4: defaultTalentTree,
    pos_5: defaultTalentTree,
};
const talentBuildList = jmz.Skill.GetTalentBuild(roleTalentBuildList[role]);

// Aggregate all talents and abilities to a single consective skill build list.
const fullSkillBuildList = jmz.Skill.GetSkillList(allAbilitiesList, skillBuildList, allTalentsList, talentBuildList);

// Construct for items build.
const defaultBuild = [
    "item_tango",
    "item_faerie_fire",
    "item_gauntlets",
    "item_gauntlets",
    "item_gauntlets",
    //
    "item_boots",
    "item_armlet",
    "item_black_king_bar",
    "item_sange",
    "item_ultimate_scepter",
    "item_heavens_halberd",
    "item_travel_boots",
    "item_satanic",
    "item_aghanims_shard",
    "item_assault",
    "item_travel_boots_2",
    "item_ultimate_scepter_2",
    "item_moon_shard",
];
const roleItemBuyList: ItemBuilds = {
    pos_1: defaultBuild,
    pos_2: defaultBuild,
    pos_3: defaultBuild,
    pos_4: [
        "item_priest_outfit",
        "item_mekansm",
        "item_glimmer_cape",
        "item_guardian_greaves",
        "item_spirit_vessel",
        "item_shivas_guard",
        "item_sheepstick",
        "item_moon_shard",
        "item_ultimate_scepter_2",
    ],
    pos_5: [
        "item_blood_grenade",
        "item_mage_outfit",
        "item_ancient_janggo",
        "item_glimmer_cape",
        "item_pipe",
        "item_boots_of_bearing",
        "item_shivas_guard",
        "item_cyclone",
        "item_sheepstick",
        "item_wind_waker",
        "item_moon_shard",
        "item_ultimate_scepter_2",
    ],
};
const itemBuildList: string[] = roleItemBuyList[role];

const sellList: string[] = ["item_black_king_bar", "item_quelling_blade"];

const abilityTether = bot.GetAbilityByName(allAbilitiesList[0]);
const abilitySpirits = bot.GetAbilityByName(allAbilitiesList[1]);
const abilityOvercharge = bot.GetAbilityByName(allAbilitiesList[2]);
const abilityRelocate = bot.GetAbilityByName(allAbilitiesList[5]);
const abilityBreakTether = bot.GetAbilityByName("wisp_tether_break");

let nearbyEnemies: Unit[] = [];

function HasHealingEffect(hero: Unit) {
    return HasAnyEffect(hero, "modifier_tango_heal", ...hero_is_healing);
}

bot.stateTetheredHero = bot.stateTetheredHero;

function ShouldUseOvercharge(ally: Unit) {
    const isAttacking = GameTime() - ally.GetLastAttackTime() < 0.33;
    const attackTarget = ally.GetAttackTarget();
    return jmz.IsGoingOnSomeone(ally) || (attackTarget && attackTarget.GetTeam() === GetOpposingTeam() && isAttacking) || ally.GetNearbyCreeps(200, true).length > 2;
}

function considerTether(): LuaMultiReturn<[number, Unit | null]> {
    if (!bot.HasModifier("modifier_wisp_tether")) {
        bot.stateTetheredHero = null;
    }
    if (!abilityTether.IsFullyCastable() || !abilityBreakTether.IsHidden()) {
        return $multi(BotActionDesire.None, null);
    }
    const castRange = abilityTether.GetCastRange();
    const allies = bot.GetNearbyHeroes(castRange, false, BotMode.None);

    for (const ally of allies) {
        const canTargetAlly = ally != bot && ally.IsAlive() && !ally.IsMagicImmune();
        if (!canTargetAlly) {
            continue;
        }
        if (jmz.IsRetreating(bot) || jmz.GetHP(bot) < 0.25) {
            if (jmz.IsRetreating(ally)) {
                return $multi(BotActionDesire.High, ally);
            }
            continue;
        }
        if (jmz.GetHP(ally) < 0.75 || jmz.GetMP(bot) > 0.8 || HasHealingEffect(bot) || ShouldUseOvercharge(ally)) {
            return $multi(BotActionDesire.High, ally);
        }
    }

    return $multi(BotActionDesire.None, null);
}

function considerOvercharge(): number {
    if (!abilityOvercharge.IsFullyCastable()) {
        return BotActionDesire.None;
    }
    if (bot.HasModifier("modifier_wisp_tether") && bot.stateTetheredHero !== null && ShouldUseOvercharge(bot.stateTetheredHero)) {
        return BotActionDesire.High;
    }
    return BotActionDesire.None;
}

function considerSpirits(): number {
    if (!abilitySpirits.IsFullyCastable()) {
        return BotActionDesire.None;
    }
    if (nearbyEnemies.length >= 1) {
        return BotActionDesire.High;
    }
    return BotActionDesire.None;
}

function considerRelocate(): LuaMultiReturn<[number, Location | null]> {
    if (bot.HasModifier("modifier_wisp_tether") && bot.stateTetheredHero !== null && (jmz.GetHP(bot.stateTetheredHero) <= 0.2 || jmz.GetHP(bot) <= 0.2)) {
        const allyNearbyEnemies = bot.stateTetheredHero.GetNearbyHeroes(1200, true, BotMode.None);
        if (
            (allyNearbyEnemies.length >= 1 && jmz.GetHP(bot.stateTetheredHero) < jmz.GetHP(allyNearbyEnemies[0])) ||
            (nearbyEnemies.length >= 1 && jmz.GetHP(bot) < jmz.GetHP(nearbyEnemies[0]))
        ) {
            return $multi(BotActionDesire.High, GetTeamFountainTpPoint());
        }
    }
    if (!bot.HasModifier("modifier_wisp_tether")) {
        if (nearbyEnemies.length >= 1 && jmz.GetHP(bot) < jmz.GetHP(nearbyEnemies[0])) {
            return $multi(BotActionDesire.High, GetTeamFountainTpPoint());
        }
    }

    for (const ally of GetUnitList(UnitType.AlliedHeroes)) {
        if (IsValidHero(ally) && jmz.IsInTeamFight(ally, 1200) && GetUnitToUnitDistance(bot, ally) > 3000 && ally.WasRecentlyDamagedByAnyHero(2)) {
            return $multi(BotActionDesire.High, ally.GetLocation());
        }
    }

    return $multi(BotActionDesire.None, null);
}

function SkillsComplement() {
    if (jmz.CanNotUseAbility(bot) || bot.IsInvisible()) {
        return;
    }

    nearbyEnemies = bot.GetNearbyHeroes(1600, true, BotMode.None);

    const [tetherDesire, tetherTarget] = considerTether();
    if (tetherDesire > 0 && tetherTarget) {
        bot.Action_UseAbilityOnEntity(abilityTether, tetherTarget);
        bot.stateTetheredHero = tetherTarget;
        return;
    }

    const overchargeDesire = considerOvercharge();
    if (overchargeDesire > 0) {
        bot.Action_UseAbility(abilityOvercharge);
        return;
    }
    const spiritsDesire = considerSpirits();
    if (spiritsDesire > 0) {
        bot.Action_UseAbility(abilitySpirits);
        return;
    }
    const [relocateDesire, relocateTarget] = considerRelocate();
    if (relocateDesire && relocateTarget !== null) {
        bot.Action_UseAbilityOnLocation(abilityRelocate, relocateTarget);
    }
}

function MinionThink(hMinionUnit: any) {
    if (minion.IsValidUnit(hMinionUnit)) {
        minion.IllusionThink(hMinionUnit);
    }
}

export = {
    SkillsComplement: SkillsComplement,
    MinionThink: MinionThink,
    sSellList: sellList,
    sBuyList: itemBuildList,
    sSkillList: fullSkillBuildList,
} satisfies BotSetup;
