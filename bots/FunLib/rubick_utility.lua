local X = {}
local bot = GetBot()
local bDebugMode = ( 1 == 10 )
local Abaddon = require(GetScriptDirectory()..'/FunLib/rubick_hero/abaddon')
local AbyssalUnderlord = require(GetScriptDirectory()..'/FunLib/rubick_hero/abyssal_underlord')
local Alchemist = require(GetScriptDirectory()..'/FunLib/rubick_hero/alchemist')
local AncientApparition = require(GetScriptDirectory()..'/FunLib/rubick_hero/ancient_apparition')
local Antimage = require(GetScriptDirectory()..'/FunLib/rubick_hero/antimage')
local ArcWarden = require(GetScriptDirectory()..'/FunLib/rubick_hero/arc_warden')
local Axe = require(GetScriptDirectory()..'/FunLib/rubick_hero/axe')
local Bane = require(GetScriptDirectory()..'/FunLib/rubick_hero/bane')
local Batrider = require(GetScriptDirectory()..'/FunLib/rubick_hero/batrider')
local Beastmaster = require(GetScriptDirectory()..'/FunLib/rubick_hero/beastmaster')
local Bloodseeker = require(GetScriptDirectory()..'/FunLib/rubick_hero/bloodseeker')
local BountyHunter = require(GetScriptDirectory()..'/FunLib/rubick_hero/bounty_hunter')
local Brewmaster = require(GetScriptDirectory()..'/FunLib/rubick_hero/brewmaster')
local Bristleback = require(GetScriptDirectory()..'/FunLib/rubick_hero/bristleback')
local Broodmother = require(GetScriptDirectory()..'/FunLib/rubick_hero/broodmother')
local Centaur = require(GetScriptDirectory()..'/FunLib/rubick_hero/centaur')
local ChaosKnight = require(GetScriptDirectory()..'/FunLib/rubick_hero/chaos_knight')
local Chen = require(GetScriptDirectory()..'/FunLib/rubick_hero/chen')
local Clinkz = require(GetScriptDirectory()..'/FunLib/rubick_hero/clinkz')
local CrystalMaiden = require(GetScriptDirectory()..'/FunLib/rubick_hero/crystal_maiden')
local Clockwerk = require(GetScriptDirectory()..'/FunLib/rubick_hero/rattletrap')

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local botTarget = nil
local lastCheck = -90
local abilityProps = nil

if DOTA_ABILITY_BEHAVIOR_UNIT_TARGET == nil then DOTA_ABILITY_BEHAVIOR_UNIT_TARGET = 8 end
if DOTA_ABILITY_BEHAVIOR_NO_TARGET == nil then DOTA_ABILITY_BEHAVIOR_NO_TARGET = 4 end
if DOTA_ABILITY_BEHAVIOR_POINT == nil then DOTA_ABILITY_BEHAVIOR_POINT = 16 end
if DOTA_ABILITY_BEHAVIOR_AOE == nil then DOTA_ABILITY_BEHAVIOR_AOE = 32 end

if DOTA_UNIT_TARGET_HERO == nil then DOTA_UNIT_TARGET_HERO = 1 end
if DOTA_UNIT_TARGET_TEAM_FRIENDLY == nil then DOTA_UNIT_TARGET_TEAM_FRIENDLY = 1 end
if DOTA_UNIT_TARGET_TEAM_ENEMY == nil then DOTA_UNIT_TARGET_TEAM_ENEMY = 2 end
if DOTA_UNIT_TARGET_TEAM_BOTH == nil then DOTA_UNIT_TARGET_TEAM_BOTH = 3 end


function X.ConsiderStolenSpell(ability)
    botTarget = J.GetProperTarget(bot)

    Abaddon.ConsiderStolenSpell(ability)
    AbyssalUnderlord.ConsiderStolenSpell(ability)
    Alchemist.ConsiderStolenSpell(ability)
    AncientApparition.ConsiderStolenSpell(ability)
    Antimage.ConsiderStolenSpell(ability)
    ArcWarden.ConsiderStolenSpell(ability)
    Axe.ConsiderStolenSpell(ability)
    Bane.ConsiderStolenSpell(ability)
    Batrider.ConsiderStolenSpell(ability)
    Beastmaster.ConsiderStolenSpell(ability)
    Bloodseeker.ConsiderStolenSpell(ability)
    BountyHunter.ConsiderStolenSpell(ability)
    Brewmaster.ConsiderStolenSpell(ability)
    Bristleback.ConsiderStolenSpell(ability)
    Broodmother.ConsiderStolenSpell(ability)
    Centaur.ConsiderStolenSpell(ability)
    ChaosKnight.ConsiderStolenSpell(ability)
    Chen.ConsiderStolenSpell(ability)
    Clinkz.ConsiderStolenSpell(ability)
    CrystalMaiden.ConsiderStolenSpell(ability)
    Clockwerk.ConsiderStolenSpell(ability)
    --D's next


    -- default usage
    if ability:GetName() == 'rubick_empty1' or ability:GetName() == 'rubick_empty2'
        or not ability:IsFullyCastable()
    then return end

    -- print("Rubick considering default usage of the spell...")
    abilityProps = X.LoadAbilityProperties(ability)
    local castRDesire, castTarget, sMotive = X.ConsiderSpellBehavior(ability, abilityProps)
    if ( castRDesire > 0 )
    then
        J.SetReportMotive( bDebugMode, sMotive )
        J.SetQueuePtToINT( bot, true )
        if (abilityProps.isForSinglePoint and not abilityProps.isForUnitTarget) or abilityProps.isForAOE then
            bot:ActionQueue_UseAbilityOnLocation(ability, castTarget)
        elseif abilityProps.isForUnitTarget then
            bot:ActionQueue_UseAbilityOnEntity(ability, castTarget)
        elseif abilityProps.isForNoTarget then
            bot:ActionQueue_UseAbility(ability)
        end
        return
    end
end

function X.ConsiderSpellBehavior(ability, props)
    if not props.isReady then return BOT_ACTION_DESIRE_NONE end

    local nCastRange = props.castRange + 200
    local nManaCost = props.manaCost
    local nRadius = 250 -- Optional: Adjust based on ability specifics

    -- Determine target for enemy abilities
    if props.isForTargetEnemy or not props.isForTargetAllies then
        if J.IsValidHero(botTarget)
            and X.CanCastAbilityROnTarget(botTarget)
            and J.IsInRange(botTarget, bot, nCastRange)
            and J.IsAllowedToSpam(bot, nManaCost * 0.5) then

            if props.isForUnitTarget then
                print("Rubick using a single-target spell on enemy hero...")
                return BOT_ACTION_DESIRE_HIGH, botTarget, "打架"
            end

            if (abilityProps.isForSinglePoint and not abilityProps.isForUnitTarget) then
                print("Rubick using a point-target spell on enemy location...")
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "打架"
            end

            if props.isForNoTarget then
                print("Rubick using a no-target spell...")
                return BOT_ACTION_DESIRE_HIGH, nil, "打架"
            end

            if props.isForAOE then
                print("Rubick using an AoE spell...")
                local nCanHurtEnemyAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
                if nCanHurtEnemyAoE.count >= 2 then
                    return BOT_ACTION_DESIRE_HIGH, nCanHurtEnemyAoE.targetloc, "打架"
                end
            end
        end
    end

    -- Determine target for ally abilities
    if (props.isForTargetAllies or not props.isForTargetEnemy) and props.isForTargetHero then
        if DotaTime() >= lastCheck + 0.5 then
            local weakest = nil
            local minHP = 100000
            local allies = J.GetNearbyHeroes(bot, nCastRange, false, BOT_MODE_NONE)

            for _, ally in ipairs(allies) do
                if not ally:HasModifier("modifier_" .. ability:GetName())
                    and J.CanCastOnNonMagicImmune(ally)
                    and ally:GetHealth() <= minHP
                    and ally:GetHealth() <= 0.65 * ally:GetMaxHealth() then
                    weakest = ally
                    minHP = ally:GetHealth()
                end
            end

            if weakest then
                print("Rubick using a supportive spell on ally...")
                return BOT_ACTION_DESIRE_HIGH, weakest, "辅助技能"
            end
            lastCheck = DotaTime()
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.CanCastAbilityROnTarget( nTarget )

    if J.CanCastOnTargetAdvanced( nTarget )
        and not nTarget:HasModifier( "modifier_arc_warden_tempest_double" )
    then
        return J.CanCastOnNonMagicImmune( nTarget )
    end

    return false

end

-- About ABILITY_BEHAVIOR: https://moddota.com/api/#!/vscripts/DOTA_ABILITY_BEHAVIOR
function X.LoadAbilityProperties(ability)
    local targetType = ability:GetTargetType()
    local targetTeam = ability:GetTargetTeam()
    local behavior = ability:GetBehavior()

    return {
        targetType = targetType,
        targetTeam = targetTeam,
        behavior = behavior,
        castRange = ability:GetCastRange(),
        manaCost = ability:GetManaCost(),
        cooldownRemaining = ability:GetCooldownTimeRemaining(),
        isReady = ability:IsCooldownReady() and ability:IsFullyCastable(),
        aoeRadius = ability:GetAOERadius() or 0,
        isForTargetHero = bit.band(DOTA_UNIT_TARGET_HERO, targetType) ~= 0,
        isForTargetEnemy = bit.band(DOTA_UNIT_TARGET_TEAM_ENEMY, targetTeam) ~= 0,
        isForTargetAllies = bit.band(DOTA_UNIT_TARGET_TEAM_FRIENDLY, targetTeam) ~= 0,
        isForUnitTarget = bit.band(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, behavior) ~= 0,
        isForSinglePoint = bit.band(DOTA_ABILITY_BEHAVIOR_POINT, behavior) ~= 0,
        isForNoTarget = bit.band(DOTA_ABILITY_BEHAVIOR_NO_TARGET, behavior) ~= 0,
        isForAOE = bit.band(DOTA_ABILITY_BEHAVIOR_AOE, behavior) ~= 0
    }
end

return X