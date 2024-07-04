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


if DOTA_ABILITY_BEHAVIOR_UNIT_TARGET == nil then DOTA_ABILITY_BEHAVIOR_UNIT_TARGET = 8 end
if DOTA_ABILITY_BEHAVIOR_NO_TARGET == nil then DOTA_ABILITY_BEHAVIOR_NO_TARGET = 4 end
if DOTA_ABILITY_BEHAVIOR_POINT == nil then DOTA_ABILITY_BEHAVIOR_POINT = 16 end
if DOTA_ABILITY_BEHAVIOR_AOE == nil then DOTA_ABILITY_BEHAVIOR_AOE = 32 end

if DOTA_UNIT_TARGET_HERO == nil then DOTA_UNIT_TARGET_HERO = 1 end
if DOTA_UNIT_TARGET_TEAM_FRIENDLY == nil then DOTA_UNIT_TARGET_TEAM_FRIENDLY = 1 end
if DOTA_UNIT_TARGET_TEAM_ENEMY == nil then DOTA_UNIT_TARGET_TEAM_ENEMY = 2 end
if DOTA_UNIT_TARGET_TEAM_BOTH == nil then DOTA_UNIT_TARGET_TEAM_BOTH = 3 end


function X.ConsiderStolenSpell(ability)
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
    castRDesire, castRTarget, sMotive = X.ConsiderSpellBehavior(ability)
    if ( castRDesire > 0 )
    then
        J.SetReportMotive( bDebugMode, sMotive )

        J.SetQueuePtToINT( bot, true )

        if X.IsAbilityForSinglePoint(ability) then
            bot:ActionQueue_UseAbilityOnLocation( ability, castRTarget )
        elseif X.IsAbilityForUnitTarget(ability) then
            bot:ActionQueue_UseAbilityOnEntity( ability, castRTarget )
        elseif X.IsAbilityForNoTarget(ability) then
            bot:ActionQueue_UseAbility( ability )
        elseif X.IsAbilityForAOE(ability) then
            bot:ActionQueue_UseAbilityOnLocation(ability, castRTarget)
        end

        return

    end


end

-- About ABILITY_BEHAVIOR: https://moddota.com/api/#!/vscripts/DOTA_ABILITY_BEHAVIOR
function X.ConsiderSpellBehavior(ability)

    local nCastRange = ability:GetCastRange() + 200
    local nCastPoint = ability:GetCastPoint()
    local nManaCost = ability:GetManaCost()
    local nRadius = 200 -- ability:GetSpecialValueInt( "xxx" )
    -- local nDamage = ability:GetSpecialValueInt( "damage" )
    -- local nDamage2 = ability:GetSpecialValueInt( "AbilityDamage" )
    -- local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange -80, true, BOT_MODE_NONE )

    if X.IsAbilityForTargetEnemy(ability) then
        -- print("Rubick considering using a spell to enemy team...")
        botTarget = J.GetProperTarget(bot)

        if J.IsValidHero( botTarget )
            and X.CanCastAbilityROnTarget( botTarget )
            and J.IsInRange( botTarget, bot, nCastRange )
            and J.IsAllowedToSpam( bot, nManaCost * 0.5 )
        then

            if X.IsAbilityForTargetHero(ability) then
                -- print("Rubick to use a spell on enemy hero target...")
                if X.IsAbilityForSinglePoint(ability) then
                    print("Rubick to use a spell on single point...")
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "打架"
                elseif X.IsAbilityForUnitTarget(ability) then
                    print("Rubick to use a spell on single point...")
                    return BOT_ACTION_DESIRE_HIGH, botTarget, "打架"
                end

            end

            if X.IsAbilityForNoTarget(ability) then
                print("Rubick to use a spell direcly...")
                return BOT_ACTION_DESIRE_HIGH, nil, "打架"
            end

            if X.IsAbilityForAOE(ability) then
                print("Rubick to use a spell as AOE...")
                local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
                local nTargetLocation = nCanHurtEnemyAoE.targetloc
                return BOT_ACTION_DESIRE_HIGH, nTargetLocation, '打架'
            end
        end
    end

    if X.IsAbilityForTargetAllies(ability) and not X.IsAbilityForTargetEnemy(ability) and X.IsAbilityForTargetHero(ability) then
        if DotaTime() >= lastCheck + 0.5 then
            local weakest = nil
            local minHP = 100000
            local allies = J.GetNearbyHeroes(bot, nCastRange, false, BOT_MODE_NONE )
            if #allies > 0 then
                for i=1, #allies do
                    if not allies[i]:HasModifier( "modifier_"..ability:GetName() )
                        and J.CanCastOnNonMagicImmune( allies[i] )
                        and allies[i]:GetHealth() <= minHP
                        and allies[i]:GetHealth() <= 0.65 * allies[i]:GetMaxHealth()
                    then
                        weakest = allies[i]
                        minHP = allies[i]:GetHealth()
                    end
                end
            end
            if weakest ~= nil 
            then
                print("Rubick to use a spell on allies...")
                return BOT_ACTION_DESIRE_HIGH, weakest, '辅助技能'
            end
            lastCheck = DotaTime()
        end

    end


    return BOT_ACTION_DESIRE_NONE
end

function X.IsAbilityForTargetHero(ability)
    local nTargetTypeFlags = ability:GetTargetType()
    return bit.band( DOTA_UNIT_TARGET_HERO, nTargetTypeFlags ) ~= 0
end

function X.IsAbilityForTargetEnemy(ability)
    local nTargetTeamFlags = ability:GetTargetTeam()
    return bit.band( DOTA_UNIT_TARGET_TEAM_ENEMY, nTargetTeamFlags ) ~= 0
end

function X.IsAbilityForTargetAllies(ability)
    local nTargetTeamFlags = ability:GetTargetTeam()
    return bit.band( DOTA_UNIT_TARGET_TEAM_FRIENDLY, nTargetTeamFlags ) ~= 0 or bit.band( DOTA_UNIT_TARGET_TEAM_BOTH, nTargetTeamFlags ) ~= 0  
end

-- Targeting a unit (a table)
function X.IsAbilityForUnitTarget(ability)
    local nBehaviorFlags = ability:GetBehavior()
    return bit.band( DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, nBehaviorFlags ) ~= 0
end

-- Targeting to a point (x, y)
function X.IsAbilityForSinglePoint(ability)
    local nBehaviorFlags = ability:GetBehavior()
    return bit.band( DOTA_ABILITY_BEHAVIOR_POINT, nBehaviorFlags ) ~= 0
end

function X.IsAbilityForNoTarget(ability)
    local nBehaviorFlags = ability:GetBehavior()
    return bit.band( DOTA_ABILITY_BEHAVIOR_NO_TARGET, nBehaviorFlags ) ~= 0
end

function X.IsAbilityForAOE(ability)
    local nBehaviorFlags = ability:GetBehavior()
    return bit.band( DOTA_ABILITY_BEHAVIOR_AOE, nBehaviorFlags ) ~= 0
end

function X.CanCastAbilityROnTarget( nTarget )

    if J.CanCastOnTargetAdvanced( nTarget )
        and not nTarget:HasModifier( "modifier_arc_warden_tempest_double" )
    then
        return J.CanCastOnNonMagicImmune( nTarget )
    end

    return false

end

return X