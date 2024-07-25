local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
                        ['t25'] = {0, 10},
                        ['t20'] = {10, 0},
                        ['t15'] = {0, 10},
                        ['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
                             {1,2,3,2,2,6,2,1,1,1,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
    "item_priest_outfit",
    "item_urn_of_shadows",
    "item_mekansm",
    "item_glimmer_cape",
    "item_guardian_greaves",
    "item_spirit_vessel",
    "item_veil_of_discord",
    "item_shivas_guard",
    "item_sheepstick",
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_5'] = {
    "item_blood_grenade",
    'item_mage_outfit',
    'item_ancient_janggo',
    'item_glimmer_cape',
    'item_boots_of_bearing',
    'item_pipe',
    'item_veil_of_discord',
    "item_shivas_guard",
    'item_cyclone',
    'item_sheepstick',
    "item_wind_waker",
    "item_moon_shard",
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_3'] = {
	"item_tango",
	"item_faerie_fire",
	"item_gauntlets",
	"item_gauntlets",
	"item_gauntlets",

	"item_boots",
	"item_armlet",
	"item_black_king_bar",--
	"item_sange",
	"item_ultimate_scepter",
	"item_heavens_halberd",--
	"item_travel_boots",
	"item_satanic",--
	"item_aghanims_shard",
	"item_assault",--
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
	"item_sheepstick",--
	"item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then
    X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {}
end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit, bot)

    if Minion.IsValidUnit( hMinionUnit ) then
        Minion.IllusionThink( hMinionUnit )
    end

end

local abilityTether = bot:GetAbilityByName( sAbilityList[1] )
local abilitySpirits = bot:GetAbilityByName( sAbilityList[2] )
local abilityOvercharge = bot:GetAbilityByName( sAbilityList[3] )
local abilityRelocate = bot:GetAbilityByName( sAbilityList[6] )

local castTetherDesire, castTetherTarget = 0
local castSpiritsDesire, castSpiritsTarget = 0
local castOverchargeDesire, castOverchargeTarget = 0
local castRelocateDesire, castRelocateLocation = 0

function X.SkillsComplement()

    if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

    local aether = J.IsItemAvailable( 'item_aether_lens' )
    local aetherRange = 0
    if aether ~= nil then aetherRange = 250 end

    castTetherDesire, castTetherTarget = X.ConsiderTether()
    if castTetherDesire > 0 then
        bot:Action_UseAbilityOnEntity( abilityTether, castTetherTarget )
        return
    end

    castSpiritsDesire = X.ConsiderSpirits()
    if castSpiritsDesire > 0 then
        bot:Action_UseAbility( abilitySpirits )
        return
    end

    castOverchargeDesire = X.ConsiderOvercharge()
    if castOverchargeDesire > 0 then
        bot:Action_UseAbility( abilityOvercharge )
        return
    end

    castRelocateDesire, castRelocateLocation = X.ConsiderRelocate()
    if castRelocateDesire > 0 then
        bot:Action_UseAbilityOnLocation( abilityRelocate, castRelocateLocation )
        return
    end

end

function X.ConsiderTether()
    if not abilityTether:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = abilityTether:GetCastRange()

    local nAllies = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE )
    for _, ally in pairs(nAllies) do
        if ally ~= nil and ally:IsAlive() and not ally:IsMagicImmune() then
            if J.GetHP(ally) < 0.6 then
                return BOT_ACTION_DESIRE_HIGH, ally
            end
        end
    end

    if nAllies[2] ~= nil and J.IsInRange(bot, nAllies[2], nCastRange) then
        return BOT_ACTION_DESIRE_HIGH, nAllies[2]
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSpirits()
    if not abilitySpirits:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE
    end

    local nEnemies = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE )
    if #nEnemies >= 1 then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderOvercharge()
    if not abilityOvercharge:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE
    end

    if bot:HasModifier('modifier_wisp_tether') then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderRelocate()
    if not abilityRelocate:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nEnemies = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
    local nAllies = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )
    if #nEnemies >= 3 and #nAllies >= 2 then
        return BOT_ACTION_DESIRE_HIGH, nEnemies[1]:GetLocation()
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X
