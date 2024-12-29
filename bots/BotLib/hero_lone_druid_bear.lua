local X = {}
local bear = GetBot()

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )

if Utils.GetLoneDruid(bear).bear == nil or not Utils.GetLoneDruid(bear).bear:IsAlive() then Utils.GetLoneDruid(bear).bear = bear end
bear.assignedRole = Utils.GetLoneDruid(bear).hero.assignedRole -- math.min(1, Utils['LoneDruid'].hero.assignedRole - 1)
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

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

-- Ability usage logic
local abilityQ = bear:GetAbilityByName(sAbilityList[1])
local SavageRoar = bear:GetAbilityByName('lone_druid_savage_roar_bear')

local castQDesire
local castSavageRoarDesire

local hEnemyList, hAllyList, botTarget, distanceFromHero

function X.SkillsComplement()

    if J.CanNotUseAbility(bear) or bear:IsInvisible() then return end

    botTarget = J.GetProperTarget(Utils.GetLoneDruid(bear).hero)
    if botTarget ~= nil then bear:SetTarget(botTarget) end
    botTarget = J.GetProperTarget(bear)

    distanceFromHero = GetUnitToUnitDistance(Utils.GetLoneDruid(bear).hero, bear)

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
    if not Utils.GetLoneDruid(bear).hero:IsAlive() then return 0 end

    if J.GetHP(bear) < 0.9 and bear:DistanceFromFountain() < 450 then return 0 end

    -- too far from hero
    if distanceFromHero > 3000
    and J.GetHP(bear) > 0.25
    and not J.IsRetreating(bear)
    and not J.Item.HasItem( bear, 'item_ultimate_scepter' ) then
        return BOT_ACTION_DESIRE_HIGH
    end

    -- hero is being attacked
    if Utils.GetLoneDruid(bear).hero:WasRecentlyDamagedByAnyHero(2)
    and J.GetHP(Utils.GetLoneDruid(bear).hero) < 0.9
    and J.GetHP(bear) > 0.25
    and not J.IsRetreating(bear)
    and distanceFromHero > 3000 then
        local nInRangeEnemy = J.GetNearbyHeroes(Utils.GetLoneDruid(bear).hero, 1000, true, BOT_MODE_NONE)
        if #nInRangeEnemy >= 1 then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSavageRoar()
    if not SavageRoar:IsFullyCastable() then return 0 end

    local nRadius = SavageRoar:GetSpecialValueInt('radius')
    local nInRangeEnemy = J.GetNearbyHeroes(bear, nRadius, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nInRangeEnemy) do
		if J.IsValidTarget(enemyHero)
        -- and J.IsInRange(bear, enemyHero, nRadius)
        and (J.IsChasingTarget(enemyHero, bear)
            or J.IsAttacking(enemyHero)
            or J.IsMoving(enemyHero)
            or enemyHero:IsChanneling()
            or enemyHero:IsUsingAbility())
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
        and J.CanCastOnNonMagicImmune( enemyHero )
        and J.CanCastOnTargetAdvanced( enemyHero )
		then
            return BOT_ACTION_DESIRE_HIGH
		end
    end

    if J.IsGoingOnSomeone(bear)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bear, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingRoshan(bear)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bear, botTarget, 500)
        and J.IsAttacking(bear)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bear)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bear, botTarget, 500)
        and J.IsAttacking(bear)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X