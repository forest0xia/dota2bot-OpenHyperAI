// @ts-ignore
import * as jmz from '../FunLib/jmz_func.lua'
import { BotBehavior, BotRole } from 'bots/lib/bots'
import { Talent, Unit } from "bots/lib/dota";

const bot = GetBot()
// @ts-ignore
const Minion = dofile('bots/FunLib/aba_minion')

const talentList: Talent[] = jmz.Skill.GetTalentList(bot)
const AbilityList: string[] = jmz.Skill.GetAbilityList(bot)

const talentTreeList = {
    t25: [10, 0],
    t20: [10, 0],
    t15: [0, 10],
    t10: [0, 10],
}
const AllAbilityBuilds = [
    [1, 3, 1, 3, 1, 6, 1, 3, 3, 2, 6, 2, 2, 2, 6], // Pos 5 Build
]

const abilityBuild = jmz.Skill.GetRandomBuild(AllAbilityBuilds)

const talentBuildList = jmz.Skill.GetTalentBuild(talentTreeList)

const skillBuildList = jmz.Skill.GetSkillList(
        AbilityList,
        abilityBuild,
        talentList,
        talentBuildList
)

const role: BotRole = jmz.Item.GetRoleItemsBuyList(bot)

const abilityTether = bot.GetAbilityByName(AbilityList[0])
const abilitySpirits = bot.GetAbilityByName(AbilityList[1])
const abilityOvercharge = bot.GetAbilityByName(AbilityList[2])
const abilityRelocate = bot.GetAbilityByName(AbilityList[5])

const defaultBuild = [
    'item_tango',
    'item_faerie_fire',
    'item_gauntlets',
    'item_gauntlets',
    'item_gauntlets',
    //
    'item_boots',
    'item_armlet',
    'item_black_king_bar',
    'item_sange',
    'item_ultimate_scepter',
    'item_heavens_halberd',
    'item_travel_boots',
    'item_satanic',
    'item_aghanims_shard',
    'item_assault',
    'item_travel_boots_2',
    'item_ultimate_scepter_2',
    'item_moon_shard',
]
const roleItemBuyList: { [key in BotRole]: string[] } = {
    pos_1: defaultBuild,
    pos_2: defaultBuild,
    pos_3: defaultBuild,
    pos_4: [
        'item_priest_outfit',
        'item_mekansm',
        'item_glimmer_cape',
        'item_guardian_greaves',
        'item_spirit_vessel',
        'item_shivas_guard',
        'item_sheepstick',
        'item_moon_shard',
        'item_ultimate_scepter_2',
    ],
    pos_5: [
        'item_blood_grenade',
        'item_mage_outfit',
        'item_ancient_janggo',
        'item_glimmer_cape',
        'item_boots_of_bearing',
        'item_pipe',
        'item_shivas_guard',
        'item_cyclone',
        'item_sheepstick',
        'item_wind_waker',
        'item_moon_shard',
        'item_ultimate_scepter_2',
    ],
}

function HasHealingEffect(hero: Unit) {
    const modifiers = [
        'modifier_tango_heal',
        'modifier_flask_healing',
        'modifier_clarity_potion', // Kinda useful for wisp's tether
        'modifier_item_urn_heal',
        'modifier_item_spirit_vessel_heal',
        'modifier_bottle_regeneration',
    ]
    for (const name of modifiers) {
        if (hero.HasModifier(name)) {
            return true
        }
    }
    return false
}

let stateTetheredHero: Unit | null = null

function ShouldUseOvercharge(ally: Unit) {
    const isAttacking = GameTime() - ally.GetLastAttackTime() < 0.33
    return (
            jmz.IsGoingOnSomeone(ally) ||
            (ally.GetAttackTarget().GetTeam() === GetOpposingTeam() &&
                    isAttacking) ||
            ally.GetNearbyCreeps(200, true).length > 2
    )
}

function considerTether(): [number, Unit | null] {
    if (!abilityTether.IsFullyCastable()) {
        return [BOT_ACTION_DESIRE_NONE, null]
    }
    const castRange = abilityTether.GetCastRange()
    const allies = bot.GetNearbyHeroes(castRange, false, BOT_MODE_NONE)

    for (const ally of allies) {
        const canTargetAlly =
                ally != bot && ally.IsAlive() && !ally.IsMagicImmune()
        if (!canTargetAlly) {
            continue
        }
        if (jmz.IsRetreating(bot)) {
            if (jmz.IsRetreating(ally)) {
                return [BOT_ACTION_DESIRE_HIGH, ally]
            }
            continue
        }
        if (
                jmz.GetHP(ally) < 0.75 ||
                jmz.GetMP(bot) > 0.8 ||
                HasHealingEffect(bot) ||
                ShouldUseOvercharge(ally)
        ) {
            return [BOT_ACTION_DESIRE_HIGH, ally]
        }
    }

    return [BOT_ACTION_DESIRE_NONE, null]
}

function considerOvercharge(): number {
    if (!abilityOvercharge.IsFullyCastable()) {
        return BOT_ACTION_DESIRE_NONE
    }
    if (
            bot.HasModifier('modifier_wisp_tether') &&
            stateTetheredHero !== null &&
            ShouldUseOvercharge(stateTetheredHero)
    ) {
        return BOT_ACTION_DESIRE_HIGH
    }
    return BOT_ACTION_DESIRE_NONE
}

export = {
    SkillsComplement() {
        if (jmz.CanNotUseAbility(bot) || bot.IsInvisible()) {
            return
        }
        const [tetherDesire, tetherLocation] = considerTether()
        if (tetherDesire > 0 && tetherLocation) {
            bot.Action_UseAbilityOnEntity(abilityTether, tetherLocation)
            stateTetheredHero = tetherLocation
            return
        }

        const overchargeDesire = considerOvercharge()
        if (overchargeDesire > 0) {
            bot.Action_UseAbility(abilityOvercharge)
            return
        }
        // TODO: Relocate and Spirits implementation
    },
    sSellList: ['item_magic_wand'],
    sBuyList: roleItemBuyList[role],
    MinionThink(hMinionUnit: any, bot: any) {
        if (Minion.IsValidUnit(hMinionUnit)) {
            Minion.IllusionThink(hMinionUnit)
        }
    },
    bDefaultAbility: false,
    bDefaultItem: false,
    sSkillList: skillBuildList,
} satisfies BotBehavior
