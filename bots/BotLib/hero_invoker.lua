local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,1,2,1,3,1,2,1,2,2,3,3,3,3,3,3,2,2,1,1,1},--冰雷核
                        -- {3,1,3,1,2,3,3,1,3,1,3,2,3,2,2,2,2,2,1,1,1},--冰火核
                        -- {1,2,2,3,2,1,2,1,2,1,2,1,2,1,1,3,3,3,3,3,3},--冰雷辅助
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

-- 冰雷核
sRoleItemsBuyList['pos_2'] = {
    "item_tango",
    "item_double_branches",
    "item_double_circlet",

    "item_bracer",
    "item_urn_of_shadows",
    "item_boots",
    "item_magic_wand",
    "item_spirit_vessel",
    "item_witch_blade",
    "item_travel_boots",
    "item_black_king_bar",--6
    "item_orchid",
    "item_aghanims_shard",
    "item_ultimate_scepter",
    "item_bloodthorn",--5
    "item_devastator",--4
    "item_ultimate_scepter_2",
    "item_octarine_core",--3
    "item_sheepstick",--2
    "item_moon_shard",
    "item_travel_boots_2",--1
}

-- 冰火核
sRoleItemsBuyList['pos_2_qe'] = {
    "item_tango",
    "item_double_branches",
    "item_double_circlet",

    "item_bracer",
    "item_urn_of_shadows",
    "item_boots",
    "item_magic_wand",
    "item_spirit_vessel",
    "item_cyclone",
    "item_travel_boots",
    "item_black_king_bar",--
    "item_aghanims_shard",
    "item_ultimate_scepter",
    "item_octarine_core",--
    "item_ultimate_scepter_2",
    "item_sheepstick",--
    "item_refresher",--
    "item_wind_waker",--
    "item_travel_boots_2",--
    "item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_2']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_circlet",
    "item_bracer",
    "item_magic_wand",
    "item_spirit_vessel",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Quas      = bot:GetAbilityByName('invoker_quas')
local Wex       = bot:GetAbilityByName('invoker_wex')
local Exort     = bot:GetAbilityByName('invoker_exort')
local Invoke    = bot:GetAbilityByName('invoker_invoke')

local ColdSnap          = bot:GetAbilityByName('invoker_cold_snap')
local GhostWalk         = bot:GetAbilityByName('invoker_ghost_walk')
local Tornado           = bot:GetAbilityByName('invoker_tornado')
local EMP               = bot:GetAbilityByName('invoker_emp')
local Alacrity          = bot:GetAbilityByName('invoker_alacrity')
local ChaosMeteor       = bot:GetAbilityByName('invoker_chaos_meteor')
local Sunstrike         = bot:GetAbilityByName('invoker_sun_strike')
local ForgeSpirit       = bot:GetAbilityByName('invoker_forge_spirit')
local IceWall           = bot:GetAbilityByName('invoker_ice_wall')
local DeafeningBlast    = bot:GetAbilityByName('invoker_deafening_blast')

local modifier_wind_waker = "modifier_wind_waker"
local modifier_item_wind_waker = "modifier_item_wind_waker"
local modifier_item_cyclone = "modifier_item_cyclone"
local modifier_eul_cyclone = "modifier_eul_cyclone"
local modifier_invoker_cold_snap = "modifier_invoker_cold_snap"
local modifier_invoker_cold_snap_freeze = "modifier_invoker_cold_snap_freeze"
local modifier_invoker_ghost_walk_self = "modifier_invoker_ghost_walk_self"
local modifier_invoker_ghost_walk_enemy = "modifier_invoker_ghost_walk_enemy"
local modifier_invoker_tornado = "modifier_invoker_tornado"
local modifier_invoker_emp = "modifier_invoker_emp"
local modifier_invoker_emp_pull_thinker = "modifier_invoker_emp_pull_thinker"
local modifier_invoker_emp_pull = "modifier_invoker_emp_pull"
local modifier_invoker_alacrity = "modifier_invoker_alacrity"
local modifier_invoker_chaos_meteor_land = "modifier_invoker_chaos_meteor_land"
local modifier_invoker_chaos_meteor_burn = "modifier_invoker_chaos_meteor_burn"
local modifier_invoker_ice_wall_thinker = "modifier_invoker_ice_wall_thinker"
local modifier_invoker_ice_wall_slow_aura = "modifier_invoker_ice_wall_slow_aura"
local modifier_invoker_deafening_blast_disarm = "modifier_invoker_deafening_blast_disarm"
local modifier_invoker_attack_visuals = "modifier_invoker_attack_visuals"

local TempNonMovableModifierNames = {
    modifier_invoker_tornado,
    'modifier_item_cyclone',
    'modifier_eul_cyclone',
    'modifier_wind_waker', -- movability depends on whether who uses the item.
    'modifier_item_wind_waker',
    'modifier_brewmaster_storm_cyclone'
}
local TempMovableModifierNames = {
    'modifier_abaddon_borrowed_time',
    'modifier_dazzle_shallow_grave',
    'modifier_wind_waker', -- movability depends on whether who uses the item.
    'modifier_item_wind_waker',
    'modifier_oracle_false_promise_timer',
    'modifier_item_aeon_disk_buff'
}

local ColdSnapDesire, ColdSnapTarget
local GhostWalkDesire
local TornadoDesire, TornadoLocation
local EMPDesire, EMPLocation
local AlacrityDesire, AlacrityTarget
local ChaosMeteorDesire, ChaosMeteorLocation
local SunstrikeDesire, SunstrikeLocation
local ForgeSpiritDesire
local IceWallDesire
local DeafeningBlastDesire, DeafeningBlastLocation

local AbilityCooldownTimes = {
    ColdSnap = 20,
    GhostWalk = 35,
    Tornado = 30,
    EMP = 30,
    Alacrity = 17,
    ChaosMeteor = 55,
    Sunstrike = 25,
    ForgeSpirit = 30,
    IceWall = 25,
    DeafeningBlast = 40,
    Cataclysm = 100
}

local AbilityCastedTimes = {
    ColdSnap = -100,
    GhostWalk = -100,
    Tornado = -100,
    EMP = -100,
    Alacrity = -100,
    ChaosMeteor = -100,
    Sunstrike = -100,
    ForgeSpirit = -100,
    IceWall = -100,
    DeafeningBlast = -100,
    Cataclysm = -100,
}

local AbilityLastRecordedCastTimes = AbilityCastedTimes

local AbilityNameMap = {
    invoker_cold_snap = 'ColdSnap',
    invoker_ghost_walk = 'GhostWalk',
    invoker_tornado = 'Tornado',
    invoker_emp = 'EMP',
    invoker_alacrity = 'Alacrity',
    invoker_chaos_meteor = 'ChaosMeteor',
    invoker_sun_strike = 'Sunstrike',
    invoker_forge_spirit = 'ForgeSpirit',
    invoker_ice_wall = 'IceWall',
    invoker_deafening_blast = 'DeafeningBlast'
}

-- Combo name, combo avability
local ComboName_RightClick = {"Right Click Combo", true}
local ComboName_EulMB = {"Eul/Cyclone, Meteor & Blast Combo", true}
local ComboName_TMB= {"Tornado, Meteor & Blast Combo", true}
local ComboName_DoT = {"DoT Combo", true}
local ComboName_TEC = {"Tornado & emp", true}
local ComboName_EulC = {"Eul/Cyclone, Cold Snap Combo", true}
local ComboName_ColdSnap = {"Cold Snap Combo", true}
local ComboName_FixedPosition = {"Fixed Position Combo", true}
local ComboName_Slowed = {"Slowed Combo", true}
local ComboName_InstanceHelper = {"Instance Helper", true}
local ComboName_KillSteal = {"Kill Steal", true}
local ComboName_LinkenBreaker = {"Linken Breaker", true}
local ComboName_Interrupt = {"Interrupt", true}
local ComboName_SpellProtect = {"Spell Protection", true}
local ComboName_Defend = {"Defend", true}
local ComboName_IceWallHelper = {"Ice Wall Helper", true}
local ComboName_TS = {"Tornado & Sunstrike/Cataclysm", true}

-- Notes of some invoker combos
local InvokerCombos = 
{
    -- Combo Name,      Enemy modifiers,        Combo Abilities in order,       Description
    {ComboName_RightClick, {}, {ColdSnap, Alacrity, ForgeSpirit}, "cast cold snap, alacrity or forge spirit when right click enemy hero or building"},
    {ComboName_EulMB, {modifier_wind_waker, modifier_item_wind_waker, modifier_item_cyclone, modifier_eul_cyclone}, {Sunstrike, ChaosMeteor, DeafeningBlast, ColdSnap}, "if target in cyclone, cast deafening blast after chaos meteor"},
    {ComboName_TMB, {}, {Tornado, ChaosMeteor, DeafeningBlast, ColdSnap}, "cast deafening blast after chaos meteor"},
    {ComboName_TEC, {}, {Tornado, EMP}, "cast tornado, emp"},
    -- {ComboName_DoT, {}, {ColdSnap, Alacrity, ForgeSpirit}, "cast cold snap on enemy who is affected by DoT, like chaos meteor, urn, ice wall, etc."},
    {ComboName_EulC, {modifier_wind_waker, modifier_item_wind_waker, modifier_item_cyclone, modifier_eul_cyclone}, {ColdSnap, Sunstrike, EMP}, "if target in cyclone, cold snap, cast sun strike and EMP"},
    {ComboName_ColdSnap, {}, {ColdSnap, Sunstrike, EMP}, "cold snap, cast sun strike and EMP"},
    {ComboName_TS, {}, {Tornado, Sunstrike}, "Tornado, follow by sun strike or Cataclysm"},

    {ComboName_FixedPosition, {}, {Sunstrike, ChaosMeteor, DeafeningBlast}, "cast sun strike, chaos meteor, DeafeningBlast on fixed enemies."},
    {ComboName_Slowed, {}, {Sunstrike, ChaosMeteor, EMP, DeafeningBlast}, "cast sun strike, chaos meteor, EMP on slowed enemies."},
    {ComboName_KillSteal, {}, {DeafeningBlast, Sunstrike}, "cast deafening blast, tornado or sun strike to predicted position to KS"},
    {ComboName_LinkenBreaker, {}, {ColdSnap}, "cast cold snap to break linken sphere"},
    {ComboName_Interrupt, {}, {ColdSnap, Tornado}, "interrupt enemy's tp or channelling spell with tornado or cold snap"},
    {ComboName_Defend, {}, {Tornado, DeafeningBlast, GhostWalk}, "If enemies are too close, auto cast (1) tornado, (2) blast, (3) cold snap, or (4) ghost walk to escape."},
    {ComboName_IceWallHelper, {}, {IceWall}, "cast ice wall if it can affect an enemy."},

    {ComboName_SpellProtect, {}, {}, "Protect uncast spell by moving casted spell to second slot"},
    {ComboName_InstanceHelper, {}, {}, "switch instances, EEE when attacking, WWW when running"},
}

local EMPDelay
local TornadoLiftTime

local botTarget

local saveManaInLaning = 280

function X.SkillsComplement()
    CheckAbilityUsage()

    if J.CanNotUseAbility(bot) then return end
    if bot:HasModifier(modifier_invoker_ghost_walk_self) and J.GetHP(bot) < 0.7 then return end

    botTarget = J.GetProperTarget(bot)
    TornadoLiftTime = Tornado:GetSpecialValueFloat('lift_duration')
    CheckForCooldownReductions()

    ConsiderFirstSpell()
    
    -- 有时候queue的action太多了，新的指令可能不会被很快执行
    X.ConsiderClearActions()

    -- 预留让没在cd的技能位置靠前。换占线的3球。这个阶段切球最好不要让大招进入CD
    X.ConsiderPreInvoke()

    -- TODO: Implement the method, refactor the following logic.
    -- X.ConsiderInvoke()


    ------- 尝试把连招串联起来，判断是否用了可以连招的前置技能 -------
    -- 如果前置技能进入cd，且距离使用它的时间刚刚过去delta时间之内，则可以试试是否能马上切或放下一个连招技能
    local deltaTime = 1
    
    if DotaTime() - AbilityCastedTimes['Tornado'] <= deltaTime then
        ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
        if ChaosMeteorDesire > 0 then X.CastChaosMeteor(ChaosMeteorLocation) return end
        
        EMPDesire, EMPLocation = X.ConsiderEMP()
        if EMPDesire > 0 then  X.CastEMP(EMPLocation) return end

        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end
    end

    if DotaTime() - AbilityCastedTimes['ChaosMeteor'] <= deltaTime then
        DeafeningBlastDesire, DeafeningBlastLocation = X.ConsiderDeafeningBlast()
        if DeafeningBlastDesire > 0 then X.CastDeafeningBlast(DeafeningBlastLocation) return end

        CataclysmDesire = X.ConsiderCataclysm()
        if CataclysmDesire > 0 then X.CastCataclysm() return end

        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end
    end

    if DotaTime() - AbilityCastedTimes['ColdSnap'] <= deltaTime then
        TornadoDesire, TornadoLocation = X.ConsiderTornado()
        if TornadoDesire > 0 then X.CastTornado(TornadoLocation) return end

        ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
        if ChaosMeteorDesire > 0 then X.CastChaosMeteor(ChaosMeteorLocation) return end
        
        AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
        if AlacrityDesire > 0 then X.CastAlacrity(AlacrityTarget) return end
    end

    if DotaTime() - AbilityCastedTimes['Alacrity'] <= deltaTime then
        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end

        ForgeSpiritDesire = X.ConsiderForgeSpirit()
        if ForgeSpiritDesire > 0 then X.CastForgeSpirit() return end
    end

    if DotaTime() - AbilityCastedTimes['ForgeSpirit'] <= deltaTime then
        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end

        AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
        if AlacrityDesire > 0 then X.CastAlacrity(AlacrityTarget) return end
    end

    if DotaTime() - AbilityCastedTimes['IceWall'] <=  deltaTime then
        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end

        AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
        if AlacrityDesire > 0 then X.CastAlacrity(AlacrityTarget) return end

        EMPDesire, EMPLocation = X.ConsiderEMP()
        if EMPDesire > 0 then  X.CastEMP(EMPLocation) return end
    end

    if DotaTime() - AbilityCastedTimes['DeafeningBlast'] <= deltaTime then
        SunstrikeDesire, SunstrikeLocation = X.ConsiderSunstrike()
        if SunstrikeDesire > 0 then X.CastSunstrike(SunstrikeLocation) return end

        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end
    end



    if Exort:GetLevel() >= 4 then -- 火大于4级优先考虑陨石连招
        TornadoDesire, TornadoLocation = X.ConsiderTornado()
        if TornadoDesire > 0
        then
            X.CastTornado(TornadoLocation)
            return
        end

        ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
        if ChaosMeteorDesire > 0
        then
            X.CastChaosMeteor(ChaosMeteorLocation)
            return
        end
    
        DeafeningBlastDesire, DeafeningBlastLocation = X.ConsiderDeafeningBlast()
        if DeafeningBlastDesire > 0
        then
            X.CastDeafeningBlast(DeafeningBlastLocation)
            return
        end
    end

    ------- 考虑正常单独地使用技能 -------

    ForgeSpiritDesire = X.ConsiderForgeSpirit()
    if ForgeSpiritDesire > 0
    then
        X.CastForgeSpirit()
        return
    end

    ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
    if ColdSnapDesire > 0
    then
        X.CastColdSnap(ColdSnapTarget)
        return
    end

    AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
    if AlacrityDesire > 0
    then
        X.CastAlacrity(AlacrityTarget)
        return
    end

    TornadoDesire, TornadoLocation = X.ConsiderTornado()
    if TornadoDesire > 0
    then
        X.CastTornado(TornadoLocation)
        return
    end


    -- 如果要逃跑，先判断吹风再用隐身
    GhostWalkDesire = X.ConsiderGhostWalk()
    if GhostWalkDesire > 0
    then
        X.CastGhostWalk()
        return
    end

    EMPDesire, EMPLocation = X.ConsiderEMP()
    if EMPDesire > 0
    then
        X.CastEMP(EMPLocation)
        return
    end

    CataclysmDesire = X.ConsiderCataclysm()
    if CataclysmDesire > 0
    then
        X.CastCataclysm()
        return
    end

    SunstrikeDesire, SunstrikeLocation = X.ConsiderSunstrike()
    if SunstrikeDesire > 0
    then
        X.CastSunstrike(SunstrikeLocation)
        return
    end

    IceWallDesire = X.ConsiderIceWall()
    if IceWallDesire > 0
    then
        X.CastIceWall()
        return
    end


    -- 物理攻击消耗敌人

    if J.GetHP(bot) > 0.75 and not J.IsRetreating(bot) and not J.IsGoingOnSomeone(bot) and not J.IsInTeamFight(bot, 1200) then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(300, true)
		local nEnemyTowers = bot:GetNearbyTowers(700, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3 and nEnemyTowers ~= nil and #nEnemyTowers >= 1
        then
			return
		end

        local nEnemyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            -- 对线消耗
            if J.IsLaning(bot)
            and J.IsValidHero(enemyHero)
            and bot:GetLevel() >= 2
            and J.GetHP(bot) >= J.GetHP(enemyHero)
            and (bot:HasModifier(modifier_invoker_alacrity)
            or enemyHero:HasModifier(modifier_invoker_cold_snap_freeze))
            then
                bot:ActionQueue_AttackUnit(enemyHero, true)
                return
            end

            if J.IsValidHero(enemyHero)
            and bot:GetLevel() >= 2
            and J.GetHP(bot) > J.GetHP(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
                local nInRangeEnemy = enemyHero:GetNearbyHeroes(1400, false, BOT_MODE_NONE)
    
                if nInRangeEnemy ~= nil and #nInRangeEnemy <= 1
                or (nInRangeAlly ~= nil and nInRangeEnemy ~= nil and #nInRangeAlly >= #nInRangeEnemy)
                then
                    bot:ActionQueue_AttackUnit(enemyHero, true)
                    return
                end
            end
        end
    end
end


-- 先考虑切 (Invoke) 好2个技能。再考虑用任何切出的技能。
-- 切记不要在技能还没出现在技能栏中时，就在代码中queue或者直接action去使用技能。这样会导致bot无法cast那个技能，因为在执行那一行指令的瞬间 (0.033s a frame)，那个技能并不存在，从而导致bot错过了在那个瞬间释放技能。
-- 因为任何一个切球的动作或者Invoke，都在action queue中排列着，都要等动画etc。多余的序列多导致不必要的行为延迟。尤其是当技能还不在技能栏中却要queue该技能时，会出现 queued action type = -1 的情况。

-- 申明一下关键术语：
-- Invoke/切技能，是指用大招召唤出指定的技能，而非使用指定的被召唤技能。
-- Cast/释放技能，是指使用/释放/扔出指定的被召唤技能。

-- 技能Invoke优先级：
-- 2个能combo的没cd的技能
-- 和上一个刚使用的技能能combo的技能
-- 没在cd中的技能
-- cd时间在Invoke cd时间之内的

-- a somewhat better strategy can be using matrix to calculate weighted fields for decisition making. but it means a lot of calculation EVERY frame.
-- nCreep, nEnemyHero, nTower, nDistance, bTeamFight, bOnSomeone, bTargetHero, nTargetHp, nTargetMp, bInAttackRange, bHasModifier..., nModifierRemainTime..., bLaning, bRetreating, bDefending, 
function X.ConsiderInvoke()
    if not Invoke:IsFullyCastable() then return end
    -- TODO: Implement the logic.

end

local lastTimeChangeModifierAbilities = 0

-- If no desire actions, get some abilities actived on the skill list so they can be casted as soon as needed later.
-- 预留技能; 预留球; 让没在cd的技能位置靠前。
-- 注意，这个阶段不能让大招进入CD，不然会影响其他技能的使用判断，因为这里不做太多技能使用的条件判定，缺少正确取舍
function X.ConsiderPreInvoke()

    -- temp don't consider cast-save if not all basic skills are trained.
    if Quas:IsTrained()
        and Wex:IsTrained()
        and Exort:IsTrained() then

        -- reverse the abilities in slots to keep not-in-cd ability longer
        local abilityD = bot:GetAbilityInSlot(3)  -- First invoked slot
        local abilityF = bot:GetAbilityInSlot(4)  -- Second invoked slot
        if abilityD ~= nil and abilityF ~= nil
        and not abilityD:IsFullyCastable()
        and abilityF:IsFullyCastable() and Invoke:IsFullyCastable() then
            -- bot:Action_ClearActions(false)
            if abilityF == ColdSnap then
                X.InvokeColdSnap()
            elseif abilityF == Tornado then
                X.InvokeTornado()
            elseif abilityF == GhostWalk then
                X.InvokeGhostWalk()
            elseif abilityF == IceWall then
                X.InvokeIceWall()
            elseif abilityF == EMP then
                X.InvokeEMP()
            elseif abilityF == Alacrity then
                X.InvokeAlacrity()
            elseif abilityF == Sunstrike then
                X.InvokeSunstrike()
            elseif abilityF == ForgeSpirit then
                X.InvokeForgeSpirit()
            elseif abilityF == ChaosMeteor then
                X.InvokeChaosMeteor()
            elseif abilityF == DeafeningBlast then
                X.InvokeDeafeningBlast()
            end
        end
    end

    if DotaTime() - lastTimeChangeModifierAbilities > 1 then

        -- idle spells. Buggy. some conditions not seem to work properly.
        -- if not J.IsAttacking(bot)
        -- and not J.IsGoingOnSomeone(bot)
        -- and not J.IsDefending(bot)
        -- and not J.IsLaning(bot)
        -- and not J.IsPushing(bot)
        -- and not bot:WasRecentlyDamagedByAnyHero(2)
        -- and Invoke:IsFullyCastable() then
        --     if not IsAbilityActive(Tornado) and Tornado:IsFullyCastable()
        --     then
        --         print('Invoke Tornado as idel spell')
        --         X.InvokeTornado()
        --     end
        
        --     if not IsAbilityActive(ColdSnap) and ColdSnap:IsFullyCastable()
        --     then
        --         print('Invoke ColdSnap as idel spell')
        --         X.InvokeColdSnap()
        --     end
        -- end


        -- 切满3个一样的球
        if J.GetHP(bot) < 0.6 then
            if Wex:IsTrained()
            and J.IsRetreating(bot)
            and (bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_exort_instance')) then
                bot:ActionQueue_UseAbility(Wex)
                bot:ActionQueue_UseAbility(Wex)
                bot:ActionQueue_UseAbility(Wex)
            elseif Quas:IsTrained()
            and (bot:HasModifier('modifier_invoker_wex_instance') or bot:HasModifier('modifier_invoker_exort_instance')) then
                bot:ActionQueue_UseAbility(Quas)
                bot:ActionQueue_UseAbility(Quas)
                bot:ActionQueue_UseAbility(Quas)
            end
        else
            if Wex:IsTrained()
            and Exort:IsTrained() then
                if Wex:GetLevel() >= Exort:GetLevel() and (bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_exort_instance')) then
                    bot:ActionQueue_UseAbility(Wex)
                    bot:ActionQueue_UseAbility(Wex)
                    bot:ActionQueue_UseAbility(Wex)
                elseif bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_wex_instance') then
                    bot:ActionQueue_UseAbility(Exort)
                    bot:ActionQueue_UseAbility(Exort)
                    bot:ActionQueue_UseAbility(Exort)
                end
            elseif Exort:IsTrained() and (bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_wex_instance')) then
                bot:ActionQueue_UseAbility(Exort)
                bot:ActionQueue_UseAbility(Exort)
                bot:ActionQueue_UseAbility(Exort)
            end
        end
        lastTimeChangeModifierAbilities = DotaTime()
    end
end

function X.ConsiderClearActions()
    if DotaTime() <= 10 then return end

    -- Invoker enqueues a lot, e.g. for any new spell it possibly needs to enqueue 3 basics and 1 Invoke and 1 Delay. 太多queued可能导致行为延迟过大而错放技能

    local nActions = bot:NumQueuedActions()

    if nActions > 0 then
        for i=1, nActions do
            local aType = bot:GetQueuedActionType(i)
            print("Enqueued actions i="..i..", type="..tostring(aType))
            if aType == -1 then
                print("Invokers has queued invalid action (-1). Clear action queue.")
                bot:Action_ClearActions(false)
                return
            end
        end

        -- -- 只有当第一个action是 -1 时才clean queue。以免导致它之前的动作被撤销
        -- if bot:GetQueuedActionType(1) == -1 then
        --     print("Invokers has queued invalid action (-1). Clear action queue.")
        --     bot:Action_ClearActions(false)
        -- end

        if nActions >= 6 then
            print("Clear Invokers queued actions")
            bot:Action_ClearActions(false)
            return
        end
    end
end

function X.CastForgeSpirit()
    print(DotaTime()..' - Invoker going to cast ForgeSpirit')

    if X.IsAbilityAvailableOnSlots(ForgeSpirit)
    then
        bot:ActionQueue_UseAbility(ForgeSpirit)
        print(DotaTime()..' - Invoker tried to cast ForgeSpirit')
    else
        X.InvokeForgeSpirit()
    end
end

function X.CastIceWall()
    print(DotaTime()..' - Invoker going to cast IceWall')

    if X.IsAbilityAvailableOnSlots(IceWall)
    then
        bot:ActionQueue_UseAbility(IceWall)
        print(DotaTime()..' - Invoker tried to cast IceWall')
    else
        X.InvokeIceWall()
    end
end

function X.CastDeafeningBlast(DeafeningBlastLocation)
    print(DotaTime()..' - Invoker going to cast DeafeningBlast')

    if X.IsAbilityAvailableOnSlots(DeafeningBlast)
    then
        bot:ActionQueue_UseAbilityOnLocation(DeafeningBlast, DeafeningBlastLocation)
        print(DotaTime()..' - Invoker tried to cast DeafeningBlast')
    else
        X.InvokeDeafeningBlast()
    end
end

function X.CastSunstrike(SunstrikeLocation)
    print(DotaTime()..' - Invoker going to cast Sunstrike')
    
    if X.IsAbilityAvailableOnSlots(Sunstrike)
    then
        bot:ActionQueue_UseAbilityOnLocation(Sunstrike, SunstrikeLocation)
        print(DotaTime()..' - Invoker tried to cast Sunstrike')
    else
        X.InvokeSunstrike()
    end
end

function X.CastCataclysm()
    print(DotaTime()..' - Invoker going to cast Cataclysm')
    
    if X.IsAbilityAvailableOnSlots(Sunstrike)
    then
        bot:ActionQueue_UseAbilityOnEntity(Sunstrike, bot)
        print(DotaTime()..' - Invoker tried to cast Cataclysm')
    else
        X.InvokeSunstrike()
    end
end

function X.CastAlacrity(AlacrityTarget)
    print(DotaTime()..' - Invoker going to cast Alacrity')
    
    if X.IsAbilityAvailableOnSlots(Alacrity)
    then
        bot:ActionQueue_UseAbilityOnEntity(Alacrity, AlacrityTarget)
        print(DotaTime()..' - Invoker tried to cast Alacrity')
    else
        X.InvokeAlacrity()
    end
end

function X.CastColdSnap(ColdSnapTarget)
    print(DotaTime()..' - Invoker going to cast ColdSnap')
    
    if X.IsAbilityAvailableOnSlots(ColdSnap)
    then
        bot:ActionQueue_UseAbilityOnEntity(ColdSnap, ColdSnapTarget)
        print(DotaTime()..' - Invoker tried to cast ColdSnap')
    else
        X.InvokeColdSnap()
    end
end

function X.CastChaosMeteor(ChaosMeteorLocation)
    print(DotaTime()..' - Invoker going to cast ChaosMeteor')
    
    if X.IsAbilityAvailableOnSlots(ChaosMeteor)
    then
        bot:ActionQueue_UseAbilityOnLocation(ChaosMeteor, ChaosMeteorLocation)
        print(DotaTime()..' - Invoker tried to cast ChaosMeteor')
        return
    else
        X.InvokeChaosMeteor()
    end
end

function X.CastEMP(EMPLocation)
    print(DotaTime()..' - Invoker going to cast EMP')
    
    if X.IsAbilityAvailableOnSlots(EMP)
    then
        bot:ActionQueue_UseAbilityOnLocation(EMP, EMPLocation)
        print(DotaTime()..' - Invoker tried to cast EMP')
    else
        X.InvokeEMP()
    end
end

function X.CastTornado(TornadoLocation)
    print(DotaTime()..' - Invoker going to cast Tornado')
    
    if X.IsAbilityAvailableOnSlots(Tornado)
    then
        bot:ActionQueue_UseAbilityOnLocation(Tornado, TornadoLocation)
        print(DotaTime()..' - Invoker tried to cast Tornado')
    else
        X.InvokeTornado()
    end
end

function X.CastGhostWalk()
    print(DotaTime()..' - Invoker going to cast GhostWalk')

    bot:Action_ClearActions(false)

    if X.IsAbilityAvailableOnSlots(GhostWalk)
    then
        bot:ActionQueue_UseAbility(GhostWalk)
        print(DotaTime()..' - Invoker tried to cast GhostWalk')
    else
        X.InvokeGhostWalk()
    end

end

function X.ConsiderColdSnap()
    if not X.CanInvoke_ColdSnap() and not X.IsAbilityReadyForCast(ColdSnap)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local castDeltaRange = 200
	local nCastRange = J.GetProperCastRange(false, bot, ColdSnap:GetCastRange())

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange + castDeltaRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and (
            enemyHero:IsChanneling() -- 打断技能
            or enemyHero:HasModifier('modifier_item_urn_damage') -- 配合骨灰
            or enemyHero:HasModifier('modifier_item_spirit_vessel_damage') -- 配合骨灰
            or enemyHero:HasModifier('modifier_invoker_chaos_meteor_burn') -- 配合陨石
        )
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + castDeltaRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1400, false, BOT_MODE_NONE)

            if nInRangeEnemy ~= nil and #nInRangeEnemy <= 2
            or (nInRangeAlly ~= nil and nInRangeEnemy ~= nil and #nInRangeAlly >= #nInRangeEnemy)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
		end
	end

	--对线
	if J.IsLaning( bot )
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy <= 2 and nInRangeEnemy[1] ~= nil then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.IsInRange(bot, enemyHero, 650)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
        and not J.IsTaunted(enemyHero)
        and bot:GetMana() - ColdSnap:GetManaCost() >= saveManaInLaning
		then
            return BOT_ACTION_DESIRE_HIGH, enemyHero, "对线消耗:"..J.Chat.GetNormName( enemyHero )
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1 and nInRangeEnemy[1] ~= nil then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
        and not J.IsTaunted(enemyHero)
		then
            if bot:WasRecentlyDamagedByAnyHero(2)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_roshan_spell_block')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderGhostWalk()
    if not X.CanInvoke_GhostWalk() and not X.IsAbilityReadyForCast(GhostWalk)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.IsRetreating(bot) and bot:DistanceFromFountain() > 600 
    then
        local nInRangeAlly = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and (#nInRangeEnemy > #nInRangeAlly
            or bot:WasRecentlyDamagedByAnyHero(1.5))
        then
            if #nInRangeEnemy > #nInRangeAlly
            or bot:WasRecentlyDamagedByAnyHero(1.5)
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            if  #nInRangeEnemy >= 1
            and J.GetHP(bot) < 0.5 + (0.1 * #nInRangeEnemy)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    -- local RoshanLocation = J.GetCurrentRoshanLocation()
    -- local TormentorLocation = J.GetTormentorLocation(GetTeam())

    -- if J.IsDoingRoshan(bot)
    -- then
    --     if GetUnitToLocationDistance(bot, RoshanLocation) > 3200
    --     then
    --         return BOT_ACTION_DESIRE_HIGH
    --     end
    -- end

    -- if J.IsDoingTormentor(bot)
    -- then
    --     if GetUnitToLocationDistance(bot, TormentorLocation) > 3200
    --     then
    --         return BOT_ACTION_DESIRE_HIGH
    --     end
    -- end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTornado()
    if not X.CanInvoke_Tornado() and not X.IsAbilityReadyForCast(Tornado)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, Tornado:GetCastRange())
    local nCastPoint = Tornado:GetCastPoint()
	local nRadius = Tornado:GetSpecialValueInt('area_of_effect')
	local nSpeed = Tornado:GetSpecialValueInt('travel_speed')

    if  J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and not J.IsLocationInChrono(J.GetCenterOfUnits(nInRangeEnemy))
        and not J.IsLocationInBlackHole(J.GetCenterOfUnits(nInRangeEnemy))
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
		end
	end

    if J.IsGoingOnSomeone(bot) or J.IsLaning( bot )
	then

		if  J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_eul_cyclone')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier(modifier_invoker_tornado)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint

            if ((nInRangeAlly ~= nil and #nInRangeAlly >= 1)
            or (nInRangeEnemy ~= nil and nInRangeAlly ~= nil and #nInRangeAlly >= #nInRangeEnemy)
            or (nInRangeEnemy ~= nil and #nInRangeEnemy == 0))
            and not (#nInRangeAlly >= #nInRangeEnemy + 2)
            then
                if J.IsRunning(botTarget)
                then

                    --  can kill enemy
                    if botTarget:GetHealth() <= bot:GetEstimatedDamageToTarget(true, botTarget, 5, DAMAGE_TYPE_ALL)
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
                    end

                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
                else
                    --  can kill enemy
                    if botTarget:GetHealth() <= bot:GetEstimatedDamageToTarget(true, botTarget, 5, DAMAGE_TYPE_ALL)
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
                    end

                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                end
            end
		end
	end

	--对线消耗
	if J.IsLaning( bot )
    and bot:GetMana() - Tornado:GetManaCost() >= saveManaInLaning
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy <= 2 and nInRangeEnemy[1] ~= nil then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end
		
        if enemyHero ~= nil and J.GetMP(bot) > 0.5
		then
            local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint), '对线消耗'
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1 and nInRangeEnemy[1] ~= nil then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, 0 end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
        and not enemyHero:HasModifier('modifier_brewmaster_storm_cyclone')
        and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
        and not enemyHero:HasModifier('modifier_eul_cyclone')
        and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not enemyHero:HasModifier('modifier_legion_commander_duel')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and (#nTargetInRangeAlly > #nInRangeAlly
                or bot:WasRecentlyDamagedByAnyHero(2))
            then
                local nInRangeEnemy2 = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)
                if nInRangeEnemy2 ~= nil and #nInRangeEnemy2 >= 2
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy2)
                else
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end

            end
		end
	end

    if J.IsDefending(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and not J.IsLocationInChrono(nLocationAoE.targetloc)
        and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        local enemyHero

        if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1 and nAllyInRangeEnemy[1] ~= nil  then
            enemyHero = nAllyInRangeEnemy[1]
        
            if  J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(2)
            and not allyHero:IsIllusion()
            then
                if J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and enemyHero:IsFacingLocation(allyHero:GetLocation(), 30)
                and not J.IsDisabled(enemyHero)
                and not J.IsTaunted(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not enemyHero:HasModifier('modifier_legion_commander_duel')
                and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
                and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    if J.IsRunning(enemyHero)
                    then
                        if enemyHero == nil or not J.IsValidHero(enemyHero) then return BOT_ACTION_DESIRE_NONE, 0 end

                        local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
                        local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetExtrapolatedLocation(nDelay), nRadius)

                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
                            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
                        end
                    else
                        local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
                            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                        end
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderEMP()
    if not X.CanInvoke_EMP() and not X.IsAbilityReadyForCast(EMP)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    EMPDelay = EMP:GetSpecialValueFloat('delay')

	local nCastRange = J.GetProperCastRange(false, bot, EMP:GetCastRange()) + 200
    local nCastPoint = EMP:GetCastPoint()
	local nRadius = EMP:GetSpecialValueInt('area_of_effect')

	if J.IsInTeamFight(bot, 1300)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if nLocationAoE.count >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
		end
	end

	if J.IsGoingOnSomeone(bot) or J.IsLaning( bot )
	then
		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_eul_cyclone')
        and not botTarget:HasModifier('modifier_legion_commander_duel')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
            local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

            if (nInRangeAlly ~= nil and #nInRangeAlly >= 1)
            or (nInRangeEnemy ~= nil and nInRangeAlly ~= nil and #nInRangeAlly >= #nInRangeEnemy)
            or (nInRangeEnemy ~= nil and #nInRangeEnemy == 0)
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)

                if botTarget:HasModifier(modifier_invoker_tornado) then
                    if DotaTime() > AbilityCastedTimes['Tornado'] + TornadoLiftTime - EMPDelay - nCastPoint
                    then
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
                            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                        end
                    end
                else
                    if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                    else
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                    end
                end
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1 and nInRangeEnemy[1] ~= nil then
            enemyHero = nInRangeEnemy[1]
        else 
            return BOT_ACTION_DESIRE_NONE, 0
        end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and not J.IsDisabled(enemyHero)
        and not enemyHero:HasModifier('modifier_brewmaster_storm_cyclone')
        and not enemyHero:HasModifier('modifier_eul_cyclone')
        and not enemyHero:HasModifier('modifier_legion_commander_duel')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and (#nTargetInRangeAlly > #nInRangeAlly
                or bot:WasRecentlyDamagedByAnyHero(1.5))
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)

                if enemyHero:HasModifier(modifier_invoker_tornado) then
                    if DotaTime() > AbilityCastedTimes['Tornado'] + TornadoLiftTime - EMPDelay
                    then
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
                            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                        end
                    end
                else
                    if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                    else
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                    end
                end
            end
		end
	end

    if  J.IsLaning(bot)
    and J.IsInLaningPhase()
    then
        if  J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.GetMP(bot) > 0.75
        and J.GetMP(botTarget) > 0.3
        and bot:GetMana() - EMP:GetManaCost() >= saveManaInLaning
        then
            if J.IsRunning(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(0.5)
            else
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderAlacrity()
    if not X.CanInvoke_Alacrity() and not X.IsAbilityReadyForCast(Alacrity)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, Alacrity:GetCastRange())

    local suitableTarget = bot
	local nMaxDamage = 0
    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
	do
		if  J.IsValidHero(allyHero)
        and not allyHero:IsIllusion()
        and not J.IsDisabled(allyHero)
        and not J.IsWithoutTarget(allyHero)
        and not allyHero:HasModifier('modifier_invoker_alacrity')
        and allyHero:GetAttackDamage() > nMaxDamage
		then
			suitableTarget = allyHero
			nMaxDamage = allyHero:GetAttackDamage()
		end
	end

    if J.IsGoingOnSomeone(bot) or J.IsLaning( bot )
	then
		if J.IsValidTarget(botTarget)
        and J.CanBeAttacked(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            if J.IsInRange(suitableTarget, botTarget, 1200)
            then
                return BOT_ACTION_DESIRE_HIGH, suitableTarget
            end
		end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, bot
		end

		local nEnemyTowers = bot:GetNearbyTowers(1000, true)

		if  nEnemyTowers ~= nil and #nEnemyTowers >= 1
        and suitableTarget ~= nil
        then
            local nAttackTarget = suitableTarget:GetAttackTarget()

            if J.IsValidBuilding(nAttackTarget)
            and J.IsAttacking(suitableTarget)
            and not suitableTarget:HasModifier('modifier_invoker_alacrity')
            then
                return BOT_ACTION_DESIRE_HIGH, suitableTarget
            end
		end
	end

	--对线
	if J.IsLaning( bot )
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
        
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy <=2 and nInRangeEnemy[1] ~= nil then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
		then
            return BOT_ACTION_DESIRE_HIGH, bot, "对线消耗:"..J.Chat.GetNormName( enemyHero )
		end
	end

    if J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)
    then
        if J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
    end

	if J.IsDoingRoshan(bot)
    and suitableTarget ~= nil
	then
		if J.IsRoshan(botTarget)
        and J.IsAttacking(suitableTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, suitableTarget
		end
	end

    if J.IsDoingTormentor(bot)
    and suitableTarget ~= nil
	then
		if  J.IsTormentor(botTarget)
        and J.IsAttacking(suitableTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, suitableTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderChaosMeteor()
    if not X.CanInvoke_ChaosMeteor() and not X.IsAbilityReadyForCast(ChaosMeteor)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, ChaosMeteor:GetCastRange())
    local nCastPoint = ChaosMeteor:GetCastPoint()
    local nLandTime = ChaosMeteor:GetSpecialValueFloat('land_time')
	local nRadius = ChaosMeteor:GetSpecialValueInt('area_of_effect')

        
    local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
    
    for _, enemyHero in pairs(nInRangeEnemy) do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_item_aeon_disk_buff')
        and (enemyHero:IsStunned()
        or enemyHero:IsRooted()
        or enemyHero:IsHexed()
        or enemyHero:IsNightmared()
        or enemyHero:IsChanneling()
        or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
        or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
        or J.IsTaunted(enemyHero) or J.GetHP(enemyHero) <= 0.75) then

            -- if hero is under temp damage immute control
            local nDelay = nLandTime
            if enemyHero:HasModifier(modifier_invoker_tornado) then
                if DotaTime() >= AbilityCastedTimes['Tornado'] + TornadoLiftTime - (nDelay + nCastPoint)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            elseif X.CheckTempModifiers(TempNonMovableModifierNames, enemyHero, (nDelay + nCastPoint)) > 0 then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end

            if J.IsRunning(enemyHero) then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nLandTime + nCastPoint)
            else
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end
        end
    end

	if J.IsGoingOnSomeone(bot) or J.IsLaning( bot ) or J.IsInTeamFight(bot)
	then
		if J.IsValidTarget(botTarget) -- can be roshan or others
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_item_aeon_disk_buff')
		then

            -- if hero is under temp damage immute control
            local nDelay = nLandTime
            if botTarget:HasModifier(modifier_invoker_tornado) then
                if DotaTime() >= AbilityCastedTimes['Tornado'] + TornadoLiftTime - (nDelay + nCastPoint)
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                end
            elseif X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, (nDelay + nCastPoint)) > 0 then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end

            if J.IsValidHero(botTarget) then
                local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if (nInRangeAlly ~= nil and #nInRangeAlly >= 1)
                or (nInRangeEnemy ~= nil and nInRangeAlly ~= nil and #nInRangeAlly >= #nInRangeEnemy)
                or (nInRangeEnemy ~= nil and #nInRangeEnemy <= 2)
                then
                    if J.IsRunning(botTarget) then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nLandTime + nCastPoint)
                    else
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                    end
                    
                end
            else
                if J.IsRunning(botTarget) then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nLandTime + nCastPoint)
                else
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                end
            end

		end
	end

	--对线
	if J.IsLaning( bot )
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy <=2 and nInRangeEnemy[1] ~= nil then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
        and not J.IsTaunted(enemyHero)
		then
            if J.IsRunning(enemyHero) then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nLandTime + nCastPoint), "对线消耗:"..J.Chat.GetNormName( enemyHero )
            else
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation(), "对线消耗:"..J.Chat.GetNormName( enemyHero )
            end
		end
	end

    if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and J.GetMP(bot) > 0.5
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if  J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, 700)
        and J.IsAttacking(bot)
        and J.GetMP(bot) > 0.5
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.CheckTempModifiers(modifierNames, botTarget, nDelay)
    for _, mName in pairs(modifierNames)
    do
        if botTarget:HasModifier(mName) then
            local remaining = J.GetModifierTime(botTarget, mName)
            print(DotaTime().."Target has modifier "..mName..", the remaining time: " .. tostring(remaining) .. " seconds, delay: "..tostring(nDelay))
            if remaining ~= nil and (DotaTime() >= DotaTime() + remaining - nDelay )
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCataclysm()
    if not X.CanInvoke_Cataclysm() and not X.IsAbilityReadyForCast(Cataclysm)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    if J.IsInTeamFight(bot, 1600)
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local nNotMovingEnemyCount = 0

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and (enemyHero:IsStunned()
                or enemyHero:IsRooted()
                or enemyHero:IsHexed()
                or enemyHero:IsNightmared()
                or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
                or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze'))
                or J.IsTaunted(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                nNotMovingEnemyCount = nNotMovingEnemyCount + 1
            end
        end

        if nNotMovingEnemyCount >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, 0
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidHero(botTarget) then
            -- if hero is already under control
            local nDelay = Sunstrike:GetSpecialValueFloat('delay')
            local nCastPoint = Sunstrike:GetCastPoint()
            if botTarget:HasModifier(modifier_invoker_tornado) then
                if DotaTime() >= AbilityCastedTimes['Tornado'] + TornadoLiftTime - (nDelay + nCastPoint)
                then
                    return BOT_ACTION_DESIRE_HIGH, 0
                end
            elseif X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, (nDelay + nCastPoint)) > 0 then
                return BOT_ACTION_DESIRE_HIGH, 0
            end
        end

        if J.IsValidHero(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_eul_cyclone')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not botTarget:HasModifier('modifier_item_aeon_disk_buff')
        and (botTarget:IsStunned()
            or botTarget:IsRooted()
            or botTarget:IsHexed()
            or botTarget:IsNightmared()
            or botTarget:HasModifier('modifier_enigma_black_hole_pull')
            or botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or J.IsTaunted(botTarget))
        then
            return BOT_ACTION_DESIRE_HIGH, 0
            -- local nInRangeAlly = botTarget:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
            -- local nInRangeEnemy = botTarget:GetNearbyHeroes(1400, false, BOT_MODE_NONE)

            -- if ((nInRangeAlly ~= nil and #nInRangeAlly >= 1) or (#nInRangeEnemy ~= nil and #nInRangeEnemy == 0))
            -- or (nInRangeEnemy ~= nil and nInRangeAlly ~= nil and #nInRangeAlly >= #nInRangeEnemy and not (#nInRangeAlly >= #nInRangeEnemy + 3))
            -- then
            --     return BOT_ACTION_DESIRE_HIGH, 0
            -- end
        end

    end

    local nEnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and not J.IsInRange(bot, enemyHero, 1000)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_brewmaster_storm_cyclone')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_eul_cyclone')
        and not enemyHero:HasModifier(modifier_invoker_tornado)
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not enemyHero:HasModifier('modifier_item_aeon_disk_buff')
        and (enemyHero:IsStunned()
            or enemyHero:IsRooted()
            or enemyHero:IsHexed()
            or enemyHero:IsNightmared()
            or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or J.IsTaunted(enemyHero))
        then
            return BOT_ACTION_DESIRE_HIGH, 0
        end
    end
    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderSunstrike()
    if not X.CanInvoke_Sunstrike() and not X.IsAbilityReadyForCast(Sunstrike)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nDelay = Sunstrike:GetSpecialValueFloat('delay')
    local nCastPoint = Sunstrike:GetCastPoint()
    local nDamage = Sunstrike:GetSpecialValueInt('damage')

    local nEnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PURE)
        and not J.IsSuspiciousIllusion(enemyHero) 
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_brewmaster_storm_cyclone')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_eul_cyclone')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not enemyHero:HasModifier('modifier_item_aeon_disk_buff')
        then
            if enemyHero:IsStunned()
            or enemyHero:IsRooted()
            or enemyHero:IsHexed()
            or enemyHero:IsNightmared()
            or enemyHero:IsChanneling()
            or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or J.IsTaunted(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end

            if J.IsRunning(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint)
            else
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end
        end
        
        if J.IsValidHero(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PURE)
        and not J.IsSuspiciousIllusion(enemyHero) then
            if X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, (nDelay + nCastPoint)) > 0 then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidHero(botTarget)
        and not J.IsSuspiciousIllusion(botTarget) then
            if X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, (nDelay + nCastPoint)) > 0 then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end

        if  J.IsValidTarget(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_eul_cyclone')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not botTarget:HasModifier('modifier_item_aeon_disk_buff')
        then
            local nInRangeAlly = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
            local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

            if ((nInRangeAlly ~= nil and #nInRangeAlly >= 1) or (#nInRangeEnemy ~= nil and #nInRangeEnemy == 0))
            or (nInRangeEnemy ~= nil and nInRangeAlly ~= nil and #nInRangeAlly >= #nInRangeEnemy)
            then
                if botTarget:HasModifier(modifier_invoker_tornado)
                then
                    if DotaTime() > AbilityCastedTimes['Tornado'] + TornadoLiftTime - nDelay - nCastPoint
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                    end
                else
                    if J.IsRunning(botTarget) then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay + nCastPoint)
                    end
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                end
            end
        end
    end

    
	--对线消耗
	if J.IsLaning( bot )
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and nInRangeEnemy[1] ~= nil and #nInRangeEnemy <= 2 then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end
		
		local nEnemyLaneCreeps = enemyHero:GetNearbyLaneCreeps(300, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps <= 1
        and enemyHero ~= nil and J.GetMP(bot) > 0.6 and J.GetHP(enemyHero) < 0.75
		then
			return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint), '对线消耗'
		end
	end
    
    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderForgeSpirit()
    if not X.CanInvoke_ForgeSpirit() and not X.IsAbilityReadyForCast(ForgeSpirit)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 1200)
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end
    
    if J.IsLaning( bot ) or J.IsFarming(bot)
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
        if J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(target)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if  J.IsTormentor(target)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderIceWall()
    if not X.CanInvoke_IceWall() and not X.IsAbilityReadyForCast(IceWall)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nSpawnDistance = IceWall:GetSpecialValueInt('wall_place_distance')

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nSpawnDistance)
        and bot:IsFacingLocation(botTarget:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if ((nInRangeAlly ~= nil and #nInRangeAlly >= 1) or (#nInRangeEnemy ~= nil and #nInRangeEnemy == 0))
            or (nInRangeEnemy ~= nil and nInRangeAlly ~= nil and #nInRangeAlly >= #nInRangeEnemy)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
		then
            local nInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = nInRangeEnemy[1]:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if nInRangeEnemy ~= nil
            and ((nInRangeAlly ~= nil and #nInRangeEnemy >= #nInRangeAlly)
                or bot:WasRecentlyDamagedByAnyHero(2))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(target)
        and J.IsInRange(bot, botTarget, nSpawnDistance)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if  J.IsTormentor(target)
        and J.IsInRange(bot, botTarget, nSpawnDistance)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDeafeningBlast()
    if not X.CanInvoke_DeafeningBlast() and not X.IsAbilityReadyForCast(DeafeningBlast)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, DeafeningBlast:GetCastRange())
    local nCastPoint = DeafeningBlast:GetCastPoint()
    local nDamage = DeafeningBlast:GetSpecialValueInt('damage')
	local nRadius = DeafeningBlast:GetSpecialValueInt('radius_end')
    local nSpeed = DeafeningBlast:GetSpecialValueInt('travel_speed')
    if (nSpeed == nil) then
        nSpeed = 1000
    end

    if J.IsInTeamFight(bot, 1500)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and not J.IsLocationInChrono(J.GetCenterOfUnits(nInRangeEnemy))
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_eul_cyclone')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            -- if hero is already under control
            local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint

            if botTarget:HasModifier(modifier_invoker_tornado) then
                if DotaTime() >= AbilityCastedTimes['Tornado'] + TornadoLiftTime - nDelay
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                end
            elseif X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, nDelay) > 0 then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end



            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
            
            if (nInRangeAlly ~= nil and #nInRangeAlly >= 1)
            or (nInRangeAlly ~= nil and nInRangeEnemy ~= nil and #nInRangeAlly >= #nInRangeEnemy)
            or (nInRangeEnemy == nil or nInRangeEnemy ~= nil and #nInRangeEnemy <= 2)
            then
                if J.IsRunning(botTarget) then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
                end
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end
    
	--对线
	if J.IsLaning( bot )
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy <= 2 and nInRangeEnemy[1] ~= nil then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

        local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
        and not J.IsTaunted(enemyHero)
		then
            if J.IsRunning(enemyHero) then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay), "对线消耗:"..J.Chat.GetNormName( enemyHero )
            else
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation(), "对线消耗:"..J.Chat.GetNormName( enemyHero )
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_brewmaster_storm_cyclone')
        and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
        and not nInRangeEnemy[1]:HasModifier('modifier_eul_cyclone')
        and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not nInRangeEnemy[1]:HasModifier(modifier_invoker_tornado)
        and not nInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
        and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and (#nTargetInRangeAlly > #nInRangeAlly
                or bot:WasRecentlyDamagedByAnyHero(2))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
            end
		end
	end

    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange + 300)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_brewmaster_storm_cyclone')
        and not enemyHero:HasModifier('modifier_eul_cyclone')
        and not enemyHero:HasModifier(modifier_invoker_tornado)
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not enemyHero:HasModifier('modifier_item_aeon_disk_buff')
		then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
		end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.CanInvoke_ColdSnap()
    return Quas:IsTrained() and X.IsAbilityReadyForInvoke(ColdSnap)
end

function X.CanInvoke_GhostWalk()
    return Quas:IsTrained() and Wex:IsTrained() and X.IsAbilityReadyForInvoke(GhostWalk)
end

function X.CanInvoke_Tornado()
    return Quas:IsTrained() and Wex:IsTrained() and X.IsAbilityReadyForInvoke(Tornado)
end

function X.CanInvoke_EMP()
    return Wex:IsTrained() and X.IsAbilityReadyForInvoke(EMP)
end

function X.CanInvoke_Alacrity()
    return Wex:IsTrained() and Exort:IsTrained() and X.IsAbilityReadyForInvoke(Alacrity)
end

function X.CanInvoke_ChaosMeteor()
    return Wex:IsTrained() and Exort:IsTrained() and X.IsAbilityReadyForInvoke(ChaosMeteor)
end

function X.CanInvoke_Cataclysm()
    return bot:HasScepter() and X.CanInvoke_Sunstrike()
    and (DotaTime() >= AbilityCastedTimes['Cataclysm'] + AbilityCooldownTimes['Cataclysm'] and Invoke:IsFullyCastable())
end

function X.CanInvoke_Sunstrike()
    return Exort:IsTrained() and X.IsAbilityReadyForInvoke(Sunstrike)
end

function X.CanInvoke_ForgeSpirit()
    return Quas:IsTrained() and Exort:IsTrained() and X.IsAbilityReadyForInvoke(ForgeSpirit)
end

function X.CanInvoke_IceWall()
    return Quas:IsTrained() and Exort:IsTrained() and X.IsAbilityReadyForInvoke(IceWall)
end

function X.CanInvoke_DeafeningBlast()
    return Quas:IsTrained() and Wex:IsTrained() and Exort:IsTrained() and X.IsAbilityReadyForInvoke(DeafeningBlast)
end

function ConsiderFirstSpell()
    if bot:GetLevel() == 1
    then
        if Quas:IsTrained()
            and not X.IsAbilityAvailableOnSlots(ColdSnap)
        then
            X.InvokeSpell(Quas, Quas, Quas)
        elseif Wex:IsTrained()
            and not X.IsAbilityAvailableOnSlots(EMP)
        then
            X.InvokeSpell(Wex, Wex, Wex)
        elseif Exort:IsTrained()
            and not X.IsAbilityAvailableOnSlots(Sunstrike)
        then
            X.InvokeSpell(Exort, Exort, Exort)
        end

        return
    end
end

function X.InvokeColdSnap()
    print("Invoker invoking ColdSnap")
    X.InvokeSpell(Quas, Quas, Quas)
end

function X.InvokeTornado()
    print("Invoker invoking Tornado")
    X.InvokeSpell(Wex, Wex, Quas)
end

function X.InvokeGhostWalk()
    print("Invoker invoking GhostWalk")
    X.InvokeSpell(Quas, Quas, Wex)
end

function X.InvokeIceWall()
    print("Invoker invoking IceWall")
    X.InvokeSpell(Quas, Quas, Exort)
end

function X.InvokeEMP()
    print("Invoker invoking EMP")
    X.InvokeSpell(Wex, Wex, Wex)
end

function X.InvokeAlacrity()
    print("Invoker invoking Alacrity")
    X.InvokeSpell(Wex, Wex, Exort)
end

function X.InvokeSunstrike()
    print("Invoker invoking Sunstrike")
    X.InvokeSpell(Exort, Exort, Exort)
end

function X.InvokeForgeSpirit()
    print("Invoker invoking ForgeSpirit")
    X.InvokeSpell(Exort, Exort, Quas)
end

function X.InvokeChaosMeteor()
    print("Invoker invoking ChaosMeteor")
    X.InvokeSpell(Exort, Exort, Wex)
end

function X.InvokeDeafeningBlast()
    print("Invoker invoking DeafeningBlast")
    X.InvokeSpell(Quas, Wex, Exort)
end

function X.InvokeSpell(Orb1, Orb2, Orb3)
    bot:ActionQueue_UseAbility(Orb1)
    bot:ActionQueue_UseAbility(Orb2)
    bot:ActionQueue_UseAbility(Orb3)
    bot:ActionQueue_UseAbility(Invoke)
    bot:ActionQueue_Delay(0.1)
end

-- Check if the ability is ready to be invoked+casted, including those that are not displayed on the ability panel list.
-- First the bot should consider if it can cast the ability, if not, consider invoke the ability. Secondly, only if bot already has the ability on slots, the bot can then consider casting it - to avoid overridding/conflicting actions.
function X.IsAbilityReadyForInvoke(ability)
    local sAbility = AbilityNameMap[ability:GetName()]
    return not X.IsAbilityAvailableOnSlots(ability) and DotaTime() >= AbilityCastedTimes[sAbility] + AbilityCooldownTimes[sAbility] and Invoke:IsFullyCastable() and bot:GetMana() >= ability:GetManaCost()
end

function X.IsAbilityReadyForCast(ability)
    return X.IsAbilityAvailableOnSlots(ability) and ability:IsFullyCastable() and bot:GetMana() >= ability:GetManaCost()
end

function X.IsAbilityAvailableOnSlots(ability)
    local abilityD = bot:GetAbilityInSlot(3)  -- First invoked slot
    local abilityF = bot:GetAbilityInSlot(4)  -- Second invoked slot
    return ability == abilityD or ability == abilityF
end

-- function ApplyActionQueue_AttackUnitOverride(unit)
--     local original_ActionQueue_AttackUnit = unit.ActionQueue_AttackUnit

--     unit.ActionQueue_AttackUnit = function(self, hTarget, bOnce)
--         print('ask invoker to attack unit')
--         return original_ActionQueue_AttackUnit(self, hTarget, bOnce)
--     end
-- end
function ApplyActionQueue_UseAbilityOnLocationOverride(unit)
    local original_ActionQueue_UseAbilityOnLocation = unit.ActionQueue_UseAbilityOnLocation

    unit.ActionQueue_UseAbilityOnLocation = function(self, hAbility, location)
        print('Invoker to queue an ability on location')
        unit:Action_ClearActions(false)
        local res = original_ActionQueue_UseAbilityOnLocation(self, hAbility, location)
        unit:ActionQueue_Delay(hAbility:GetCastPoint())
        return res
    end
end
function ApplyActionQueue_UseAbilityOverride(unit)
    local original_ActionQueue_UseAbility = unit.ActionQueue_UseAbility

    unit.ActionQueue_UseAbility = function(self, hAbility)
        if not (Quas or Wex or Exort or Invoke) then
            print('Invoker to queue an ability')
            unit:Action_ClearActions(false)
        end
        local res = original_ActionQueue_UseAbility(self, hAbility)
        if hAbility:GetCastPoint() ~= nil and hAbility:GetCastPoint() > 0 then
            unit:ActionQueue_Delay(hAbility:GetCastPoint())
            end
        return res
    end
end
function ApplyActionQueue_UseAbilityOnEntityOverride(unit)
    local original_ActionQueue_UseAbilityOnEntity = unit.ActionQueue_UseAbilityOnEntity

    unit.ActionQueue_UseAbilityOnEntity = function(self, hAbility, target)
        print('Invoker to queue an ability on entity')
        unit:Action_ClearActions(false)
        local res = original_ActionQueue_UseAbilityOnEntity(self, hAbility, target)
        unit:ActionQueue_Delay(hAbility:GetCastPoint())
        return res
    end
end

-- ApplyActionQueue_AttackUnitOverride(bot)
ApplyActionQueue_UseAbilityOnLocationOverride(bot)
ApplyActionQueue_UseAbilityOverride(bot)
ApplyActionQueue_UseAbilityOnEntityOverride(bot)

-- don't need to worry about the use of refresher here, this only need to keep tracking on the usage of the ability.
function CheckAbilityUsage()
    -- Check if the spell is just used.
    local abilities = { bot:GetAbilityInSlot(3), bot:GetAbilityInSlot(4) }
    for i, ability in pairs(abilities) do
        local pCD = ability:GetCooldownTimeRemaining()/ability:GetCooldown()
        local detectP = 0.9
        if X.IsAbilityAvailableOnSlots(ability) and not ability:IsCooldownReady() and pCD >= detectP then
            local sAbility = AbilityNameMap[ability:GetName()]
            local timePassedSinceLastCast = DotaTime() - AbilityLastRecordedCastTimes[sAbility]

            if timePassedSinceLastCast <= ability:GetCooldown() * (1 - detectP) then return end -- 防止重复记录。不精确，有时会漏
            -- if timePassedSinceLastCast < 0.1 or not AbilityCastedTimes[sAbility] == -100 then return end -- 防止重复记录

            print(DotaTime()..' - Invoker just used ability ' .. sAbility .. ', reset the cooldown tracking time.')
            AbilityCastedTimes[sAbility] = DotaTime()
            AbilityLastRecordedCastTimes[sAbility] = DotaTime()
        end
    end
end

local octarineCoreCooldownReductionsCheck = false

function CheckForCooldownReductions()
    
    -- [TODO] Need to check with the usage of refresh as well

    if J.HasItem(bot, 'item_octarine_core') and octarineCoreCooldownReductionsCheck == false then
        AbilityCooldownTimes['ColdSnap']        = AbilityCooldownTimes['ColdSnap'] * 0.75
        AbilityCooldownTimes['GhostWalk']       = AbilityCooldownTimes['GhostWalk'] * 0.75
        AbilityCooldownTimes['Tornado']         = AbilityCooldownTimes['Tornado'] * 0.75
        AbilityCooldownTimes['EMP']             = AbilityCooldownTimes['EMP'] * 0.75
        AbilityCooldownTimes['Alacrity']        = AbilityCooldownTimes['Alacrity'] * 0.75
        AbilityCooldownTimes['ChaosMeteor']     = AbilityCooldownTimes['ChaosMeteor'] * 0.75
        AbilityCooldownTimes['Sunstrike']       = AbilityCooldownTimes['Sunstrike'] * 0.75
        AbilityCooldownTimes['ForgeSpirit']     = AbilityCooldownTimes['ForgeSpirit'] * 0.75
        AbilityCooldownTimes['IceWall']         = AbilityCooldownTimes['IceWall'] * 0.75
        AbilityCooldownTimes['DeafeningBlast']  = AbilityCooldownTimes['DeafeningBlast'] * 0.75
        AbilityCooldownTimes['Cataclysm']       = AbilityCooldownTimes['Cataclysm'] * 0.75
        octarineCoreCooldownReductionsCheck = true
    end

    if not J.HasItem(bot, 'item_octarine_core') then
        AbilityCooldownTimes['ColdSnap']          = 20
        AbilityCooldownTimes['GhostWalk']         = 35
        AbilityCooldownTimes['Tornado']           = 30
        AbilityCooldownTimes['EMP']               = 30
        AbilityCooldownTimes['Alacrity']          = 17
        AbilityCooldownTimes['ChaosMeteor']       = 55
        AbilityCooldownTimes['Sunstrike']         = 25
        AbilityCooldownTimes['ForgeSpirit']       = 30
        AbilityCooldownTimes['IceWall']           = 25
        AbilityCooldownTimes['DeafeningBlast']    = 40
        AbilityCooldownTimes['Cataclysm']         = 100
        octarineCoreCooldownReductionsCheck = false
    end

    -- 中立物品也得查
end

return X