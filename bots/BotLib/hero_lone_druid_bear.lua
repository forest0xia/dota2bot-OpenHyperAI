local X = {}
local bear = GetBot()

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )

if Utils['LoneDruid'].bear == nil or not Utils['LoneDruid'].bear:IsAlive() then Utils['LoneDruid'].bear = bear end
bear.assignedRole = Utils['LoneDruid'].hero.assignedRole -- math.min(1, Utils['LoneDruid'].hero.assignedRole - 1)
bear.isBear = true

local sTalentList = J.Skill.GetTalentList( bear )
local sAbilityList = J.Skill.GetAbilityList( bear )
local sRole = J.Item.GetRoleItemsBuyList( bear )

local tTalentTreeList = {--pos2
                        ['t25'] = {0, 10},
                        ['t20'] = {0, 10},
                        ['t15'] = {0, 10},
                        ['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
                        {1,2,1,2,1,6,1,2,2,3,6,3,3,3,6},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = { }

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit, bot)
    Minion.MinionThink(hMinionUnit, bot)
end

-- Ability usage logic
local abilityQ = bear:GetAbilityByName(sAbilityList[1])
local SavageRoar = bear:GetAbilityByName('lone_druid_savage_roar_bear')

local castQDesire
local castSavageRoarDesire

local hEnemyList, hAllyList, botTarget, distanceFromHero
local hasUltimateScepter = false

function X.SkillsComplement()

    if J.CanNotUseAbility(bear) or bear:IsInvisible() then return end
    
    botTarget = J.GetProperTarget(Utils['LoneDruid'].hero)
    if botTarget ~= nil then bear:SetTarget(botTarget) end
    botTarget = J.GetProperTarget(bear)
    
    distanceFromHero = GetUnitToUnitDistance(Utils['LoneDruid'].hero, bear)

    if not hasUltimateScepter then
        hasUltimateScepter = J.Item.HasItem(bear, 'item_ultimate_scepter') or bear:HasModifier('modifier_item_ultimate_scepter_consumed')
    end

    if Utils['LoneDruid'].hero:IsAlive() and not (J.GetHP(bear) < 0.3 or J.IsRetreating(bear))
    and not (bear:IsChanneling() or bear:IsUsingAbility() or hasUltimateScepter) then
        if distanceFromHero > 1000 then
            bear:Action_ClearActions(false)
            bear:Action_MoveToLocation(Utils['LoneDruid'].hero:GetLocation())
        -- elseif distanceFromHero < 1000 and distanceFromHero > 400 and not (J.IsAttacking(bear) or J.IsGoingOnSomeone(bear)) then
        --     bear:Action_AttackMove(Utils['LoneDruid'].hero:GetLocation() + RandomVector(150))
        end
    end

    -- hEnemyList = J.GetNearbyHeroes(bear, 1600, true, BOT_MODE_NONE)
    -- hAllyList = J.GetNearbyHeroes(bear, 1600, false, BOT_MODE_NONE)

    castQDesire = X.ConsiderQ()
    if castQDesire > 0 then
        bear:Action_UseAbility(abilityQ)
        return
    end

    castSavageRoarDesire = X.ConsiderSavageRoar()
    if castSavageRoarDesire > 0 then
        bear:Action_UseAbility(SavageRoar)
        return
    end

end

function X.ConsiderQ()
    if not abilityQ:IsFullyCastable() then return 0 end
    if not Utils['LoneDruid'].hero:IsAlive() then return 0 end

    -- too far from hero
    if distanceFromHero > 3000
    and not J.Item.HasItem( bear, 'item_ultimate_scepter' ) then
        return BOT_ACTION_DESIRE_HIGH
    end

    -- hero is being attacked
    if Utils['LoneDruid'].hero:WasRecentlyDamagedByAnyHero(2)
    and J.GetHP(Utils['LoneDruid'].hero) < 0.9
    and distanceFromHero > 3000 then
        local nInRangeEnemy = J.GetNearbyHeroes(Utils['LoneDruid'].hero, 1000, true, BOT_MODE_NONE)
        if #nInRangeEnemy >= 1 then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSavageRoar()
    if not SavageRoar:IsFullyCastable() then return 0 end

    local nRadius = SavageRoar:GetSpecialValueInt('radius')

    if J.IsGoingOnSomeone(bear)
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bear, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsRetreating(bear)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bear,nRadius, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bear)
            and J.IsInRange(bear, enemyHero, nRadius)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsDoingRoshan(bear)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bear, botTarget, 500)
        and J.IsAttacking(bear)
        then
            if J.GetHP(bear) < 0.25
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingTormentor(bear)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bear, botTarget, 500)
        and J.IsAttacking(bear)
        then
            if J.GetHP(bear) < 0.25
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X