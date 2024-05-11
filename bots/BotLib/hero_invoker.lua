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
    "item_refresher",--3
    "item_moon_shard",
    "item_sheepstick",--2
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
local Cataclysm         = "Cataclysm" -- placeholder, Cataclysm is actually the ability Sunstrike but acts differently

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

local previouslyRecordedMana = -1
local octarineCoreCooldownReductionsCheck = false

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

    -- K头第一
    CataclysmDesire = X.ConsiderCataclysm()
    if CataclysmDesire > 0 then X.CastInvokerSpell(Cataclysm) return end
    SunstrikeDesire, SunstrikeLocation = X.ConsiderSunstrike()
    if SunstrikeDesire > 0 then X.CastInvokerSpell(Sunstrike, SunstrikeLocation) return end


    ------- 尝试把连招串联起来，判断是否用了可以连招的前置技能 -------
    -- 如果前置技能进入cd，且距离使用它的时间刚刚过去delta时间之内，则可以试试是否能马上切或放下一个连招技能
    local deltaTime = 2
    

    -- 火的等级大于4级优先考虑陨石连招
    if Exort:GetLevel() >= 4 then
        -- TornadoDesire, TornadoLocation = X.ConsiderTornado()
        -- if TornadoDesire > 0 then X.CastInvokerSpell(Tornado, TornadoLocation) return end

        ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
        if ChaosMeteorDesire > 0 then X.CastInvokerSpell(ChaosMeteor, ChaosMeteorLocation) return end
    
        DeafeningBlastDesire, DeafeningBlastLocation = X.ConsiderDeafeningBlast()
        if DeafeningBlastDesire > 0 then X.CastInvokerSpell(DeafeningBlast, DeafeningBlastLocation) return end
    end

    
    if DotaTime() - AbilityCastedTimes['Tornado'] <= deltaTime then
        EMPDesire, EMPLocation = X.ConsiderEMP()
        if EMPDesire > 0 then  X.CastInvokerSpell(EMP, EMPLocation) return end

        ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
        if ChaosMeteorDesire > 0 then X.CastInvokerSpell(ChaosMeteor, ChaosMeteorLocation) return end
    end

    if DotaTime() - AbilityCastedTimes['ChaosMeteor'] <= deltaTime then
        DeafeningBlastDesire, DeafeningBlastLocation = X.ConsiderDeafeningBlast()
        if DeafeningBlastDesire > 0 then X.CastInvokerSpell(DeafeningBlast, DeafeningBlastLocation) return end

        CataclysmDesire = X.ConsiderCataclysm()
        if CataclysmDesire > 0 then X.CastInvokerSpell(Cataclysm) return end

        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastInvokerSpell(ColdSnap, ColdSnapTarget) return end
    end

    if DotaTime() - AbilityCastedTimes['ColdSnap'] <= deltaTime then
        AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
        if AlacrityDesire > 0 then X.CastInvokerSpell(Alacrity, AlacrityTarget) return end

        ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
        if ChaosMeteorDesire > 0 then X.CastInvokerSpell(ChaosMeteor, ChaosMeteorLocation) return end
        
        TornadoDesire, TornadoLocation = X.ConsiderTornado()
        if TornadoDesire > 0 then X.CastInvokerSpell(Tornado, TornadoLocation) return end
    end

    if DotaTime() - AbilityCastedTimes['Alacrity'] <= deltaTime then
        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastInvokerSpell(ColdSnap, ColdSnapTarget) return end

        ForgeSpiritDesire = X.ConsiderForgeSpirit()
        if ForgeSpiritDesire > 0 then X.CastInvokerSpell(ForgeSpirit) return end
    end

    if DotaTime() - AbilityCastedTimes['ForgeSpirit'] <= deltaTime then
        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastInvokerSpell(ColdSnap, ColdSnapTarget) return end

        AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
        if AlacrityDesire > 0 then X.CastInvokerSpell(Alacrity, AlacrityTarget) return end
    end

    if DotaTime() - AbilityCastedTimes['IceWall'] <=  deltaTime then
        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastInvokerSpell(ColdSnap, ColdSnapTarget) return end

        ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
        if ChaosMeteorDesire > 0 then X.CastInvokerSpell(ChaosMeteor, ChaosMeteorLocation) return end

        EMPDesire, EMPLocation = X.ConsiderEMP()
        if EMPDesire > 0 then  X.CastInvokerSpell(EMP, EMPLocation) return end
    end

    if DotaTime() - AbilityCastedTimes['DeafeningBlast'] <= deltaTime then
        SunstrikeDesire, SunstrikeLocation = X.ConsiderSunstrike()
        if SunstrikeDesire > 0 then X.CastInvokerSpell(Sunstrike, SunstrikeLocation) return end

        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastInvokerSpell(ColdSnap, ColdSnapTarget) return end
    end


    ------- 考虑正常单独地使用技能 -------

    ForgeSpiritDesire = X.ConsiderForgeSpirit()
    if ForgeSpiritDesire > 0 then X.CastInvokerSpell(ForgeSpirit) return end

    ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
    if ColdSnapDesire > 0 then  X.CastInvokerSpell(ColdSnap, ColdSnapTarget) return end

    AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
    if AlacrityDesire > 0 then X.CastInvokerSpell(Alacrity, AlacrityTarget) return end

    TornadoDesire, TornadoLocation = X.ConsiderTornado()
    if TornadoDesire > 0 then X.CastInvokerSpell(Tornado, TornadoLocation) return end
    
    -- 如果要逃跑，先判断吹风再用隐身
    GhostWalkDesire = X.ConsiderGhostWalk()
    if GhostWalkDesire > 0 then X.CastInvokerSpell(GhostWalk) return end

    EMPDesire, EMPLocation = X.ConsiderEMP()
    if EMPDesire > 0 then  X.CastInvokerSpell(EMP, EMPLocation) return end

    IceWallDesire = X.ConsiderIceWall()
    if IceWallDesire > 0 then X.CastInvokerSpell(IceWall) return end


    -- 物理攻击消耗敌人. 对线消耗

    if J.IsLaning(bot)
    and bot:GetLevel() >= 2
    and DotaTime() < 600 -- 前10分钟
    and J.GetHP(bot) > 0.75
    and not J.IsRetreating(bot)
    and not J.IsGoingOnSomeone(bot)
    and not J.IsInTeamFight(bot, 1200) then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(300, true)
		local nEnemyTowers = bot:GetNearbyTowers(700, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3 and nEnemyTowers ~= nil and #nEnemyTowers >= 1
        then
			return
		end

        local nEnemyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if J.IsValidHero(enemyHero)
            and J.GetHP(bot) >= J.GetHP(enemyHero)
            and (bot:HasModifier(modifier_invoker_alacrity)
            or enemyHero:HasModifier(modifier_invoker_cold_snap_freeze))
            then
                bot:ActionQueue_AttackUnit(enemyHero, true)
                return
            end
            
            if J.IsValidHero(enemyHero)
            and J.GetHP(bot) >= J.GetHP(enemyHero)
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
                X.InvokeActualSpell(ColdSnap)
            elseif abilityF == Tornado then
                X.InvokeActualSpell(Tornado)
            elseif abilityF == GhostWalk then
                X.InvokeActualSpell(GhostWalk)
            elseif abilityF == IceWall then
                X.InvokeActualSpell(IceWall)
            elseif abilityF == EMP then
                X.InvokeActualSpell(EMP)
            elseif abilityF == Alacrity then
                X.InvokeActualSpell(Alacrity)
            elseif abilityF == Sunstrike then
                X.InvokeActualSpell(Sunstrike)
            elseif abilityF == ForgeSpirit then
                X.InvokeActualSpell(ForgeSpirit)
            elseif abilityF == ChaosMeteor then
                X.InvokeActualSpell(ChaosMeteor)
            elseif abilityF == DeafeningBlast then
                X.InvokeActualSpell(DeafeningBlast)
            end
        end
    end

    if DotaTime() - lastTimeChangeModifierAbilities > 1 then

        -- -- idle spells. Maybe buggy. some conditions not seem to work properly.
        if J.IsGoingOnSomeone(bot)
        and not J.IsAttacking(bot)
        and not bot:WasRecentlyDamagedByAnyHero(4)
        and Invoke:IsFullyCastable() then
            local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            if nEnemyHeroes == nil or #nEnemyHeroes <= 0 then
                if X.IsAbilityPossiblyBeCasted(Tornado) and not X.IsAbilityAvailableOnSlots(Tornado) then
                    print('Invoke Tornado as idel spell')
                    X.InvokeActualSpell(Tornado)
                end
                if X.IsAbilityPossiblyBeCasted(ColdSnap) and not X.IsAbilityAvailableOnSlots(ColdSnap) then
                    print('Invoke ColdSnap as idel spell')
                    X.InvokeActualSpell(ColdSnap)
                end

            end
        end

        -- 切满3个一样的球
        if J.GetHP(bot) < 0.6 then
            if Wex:IsTrained()
            and J.IsRetreating(bot)
            and (bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_exort_instance')) then
                X.QueueElements(Wex, Wex, Wex)
            elseif Quas:IsTrained()
            and (bot:HasModifier('modifier_invoker_wex_instance') or bot:HasModifier('modifier_invoker_exort_instance')) then
                X.QueueElements(Quas, Quas, Quas)
            end
        else
            if Wex:IsTrained() then
                if (not Exort:IsTrained() or Wex:GetLevel() >= Exort:GetLevel())
                and (bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_exort_instance')) then
                    X.QueueElements(Wex, Wex, Wex)
                elseif (bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_wex_instance')) then
                    X.QueueElements(Exort, Exort, Exort)
                end
            elseif Exort:IsTrained() and (bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_wex_instance')) then
                X.QueueElements(Exort, Exort, Exort)
            end
        end
        lastTimeChangeModifierAbilities = DotaTime()
    end
end

function X.InvokeElements(Orb1, Orb2, Orb3)
    bot:ActionPush_UseAbility(Orb1)
    bot:ActionPush_UseAbility(Orb2)
    bot:ActionPush_UseAbility(Orb3)
end

function X.QueueElements(Orb1, Orb2, Orb3)
    bot:ActionQueue_UseAbility(Orb1)
    bot:ActionQueue_UseAbility(Orb2)
    bot:ActionQueue_UseAbility(Orb3)
end

-- 卡尔特殊判断，因为卡尔不太需要关注大招cd而主要关注某一些特殊技能（在或不在当前可见技能栏中）的cd
function X.CanUseRefresherShard()
    local ChaosMeteorMana = ChaosMeteor:GetManaCost()
    local SunstrikeMana = Sunstrike:GetManaCost()

	local nInRangeEnmyList = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )

    if Sunstrike:GetCooldownTimeRemaining() >= 10 -- 技能快好了的话没必要刷新
    and Sunstrike:GetCooldownTimeRemaining()/Sunstrike:GetCooldown() <= 0.95 -- 不想马上就刷新因为可能可以再连一些技能，或者技能已经快好了
    and X.IsAbilityAvailableOnSlots(Sunstrike)
    and bot:GetMana() >= (SunstrikeMana * 2 + SunstrikeMana) then
        local cataclysmDesire, _ = X.GoodTimeToUseCataclysmGlobally()
        if cataclysmDesire > 0 then
            return true
            end
    end
    
    if ChaosMeteor:GetCooldownTimeRemaining() >= 10 -- 技能快好了的话没必要刷新
    and ChaosMeteor:GetCooldownTimeRemaining()/ChaosMeteor:GetCooldown() <= 0.9 -- 不想马上就刷新因为可能可以再连一些技能，或者技能已经快好了
    and X.IsAbilityAvailableOnSlots(ChaosMeteor)
    and #nInRangeEnmyList > 0
    and ( J.IsGoingOnSomeone( bot ) or J.IsInTeamFight( bot ) )
    and bot:GetMana() >= (ChaosMeteorMana * 2 + ChaosMeteorMana) then
        return true
    end

    return false
end

function X.ConsiderClearActions()
    if DotaTime() <= 10 then return end

    -- Invoker enqueues a lot, e.g. for any new spell it possibly needs to enqueue 3 basics and 1 Invoke and 1 Delay. 太多queued可能导致行为延迟过大而错放技能

    local nActions = bot:NumQueuedActions()

    if nActions > 0 then
        if nActions >= 6 then
            print("Clear Invokers queued actions")
            bot:Action_ClearActions(false)
            return
        end

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
    end
end

-- cast/use a spell available on the slots
function X.CastInvokerSpell(ability, target)
    local abilityName
    if type(ability) == "string" and ability == 'Cataclysm' then
        abilityName = ability
    else
        abilityName = ability:GetName()
    end
    
    -- print(DotaTime()..' - Invoker checking to cast '..abilityName) -- can be annoying since this line gets printed a lot if e.g. no enough mana or before invoker trains all elements

    if X.IsAbilityReadyForInvoke(ability) then
        X.InvokeActualSpell(ability)
    elseif X.IsAbilityReadyForCast(ability)
    then
        print(DotaTime()..' - Invoker has it on slot, going to cast '..abilityName)

        -- bot:ActionPush_Delay(ability:GetCastPoint())
        if ability == ForgeSpirit
            or ability == IceWall
            or ability == GhostWalk then
                if ability == GhostWalk then
                    bot:Action_ClearActions(true)
                end
                bot:ActionPush_UseAbility(ability)
        elseif ability == DeafeningBlast
            or ability == Sunstrike
            or ability == ChaosMeteor
            or ability == EMP
            or ability == Tornado then
                bot:ActionPush_UseAbilityOnLocation(ability, target)
        elseif ability == Alacrity
            or ability == ColdSnap then
                bot:ActionPush_UseAbilityOnEntity(ability, target)
        elseif ability == Cataclysm then
            bot:ActionPush_UseAbilityOnEntity(Sunstrike, bot)
        else
            print(DotaTime()..' - [ERROR] Tried to cast unsupported spell: '..abilityName)
            print("Stack Trace:", debug.traceback())
        end
        print(DotaTime()..' - Invoker tried to cast '..abilityName)
    else
        -- print(DotaTime()..' - Invoker trying to cast a spell that is not ready: '..abilityName)
    end
end

function X.ConsiderColdSnap()
    if not X.IsAbilityPossiblyBeCasted(ColdSnap)
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
            or enemyHero:HasModifier('modifier_item_spirit_vessel_damage') -- 配合大骨灰
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
    if not X.IsAbilityPossiblyBeCasted(GhostWalk)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if (J.IsRetreating(bot) or J.GetHP(bot) <= 0.15) and (bot:DistanceFromFountain() > 800 or bot:HasModifier('modifier_teleporting'))
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

        if bot:WasRecentlyDamagedByAnyHero(3) and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTornado()
    local deltaTime = 1.5
    if not X.IsAbilityPossiblyBeCasted(Tornado)
        -- 同时也确保不要在刚刚放了陨石或者推波之后马上用吹风
        and (DotaTime() - AbilityCastedTimes['ChaosMeteor'] <= deltaTime and DotaTime() - AbilityCastedTimes['DeafeningBlast'] <= deltaTime)
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
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_invoker_chaos_meteor_burn')
        and not botTarget:HasModifier('modifier_invoker_deafening_blast_disarm')
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
		
        if enemyHero ~= nil and J.GetMP(bot) > 0.7
		then
            local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint), '对线消耗'
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1 and nInRangeEnemy[1] ~= nil then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, 0 end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange + 200)
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
            if bot:WasRecentlyDamagedByAnyHero(2)
            and ((nInRangeAlly == nil or #nInRangeAlly == 0)
            or (nTargetInRangeAlly ~= nil and #nTargetInRangeAlly >= #nInRangeAlly)) then
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
    if not X.IsAbilityPossiblyBeCasted(EMP)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    EMPDelay = EMP:GetSpecialValueFloat('delay')

	local nCastRange = EMP:GetCastRange() + 300
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
                    if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
                            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
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
        and J.GetMP(botTarget) > 0.3
        and bot:GetMana() - EMP:GetManaCost() >= saveManaInLaning
        then
            if J.IsRunning(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(0.5 + nCastPoint)
            else
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderAlacrity()
    if not X.IsAbilityPossiblyBeCasted(Alacrity)
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

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanBeAttacked(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeEnemy = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
            if J.IsInRange(suitableTarget, botTarget, 1200)
            and ((nInRangeEnemy ~= nil and #nInRangeEnemy >=2 and not X.IsAbilityPossiblyBeCasted(ChaosMeteor)) -- 如果附近多人, 优先考虑陨石
                or (nInRangeEnemy == nil or #nInRangeEnemy <= 1)) -- 如果附近就一个敌人
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
        and J.IsInRange(suitableTarget, botTarget, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH, suitableTarget
		end
	end

    if J.IsDoingTormentor(bot)
    and suitableTarget ~= nil
	then
		if  J.IsTormentor(botTarget)
        and J.IsInRange(suitableTarget, botTarget, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH, suitableTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderChaosMeteor()
    if not X.IsAbilityPossiblyBeCasted(ChaosMeteor)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = ChaosMeteor:GetCastRange() + 300
    local nCastPoint = ChaosMeteor:GetCastPoint()
    local nLandTime = ChaosMeteor:GetSpecialValueFloat('land_time')
	local nRadius = ChaosMeteor:GetSpecialValueInt('area_of_effect')
    local nManaCost = ChaosMeteor:GetManaCost()

        
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
        or enemyHero:HasModifier('modifier_magnataur_reverse_polarity')
        or enemyHero:HasModifier('modifier_tidehunter_ravage')
        or J.IsTaunted(enemyHero)
        or J.GetHP(enemyHero) <= 0.75) then

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

	if J.IsGoingOnSomeone(bot) or J.IsLaning( bot )
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

            if J.IsRunning(botTarget) then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nLandTime + nCastPoint)
            else
                if J.IsValidHero(botTarget) then
                    local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius + 300, nLandTime + nCastPoint, 0)
                    if  nLocationAoE.count >= 2 then
                        local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius + 300)
                        if realEnemyCount ~= nil and #realEnemyCount >= 1 then
                            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                        end
                    end
                end
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

    if J.IsInTeamFight(bot) then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius + 300, nLandTime + nCastPoint, 0)
        if  nLocationAoE.count >= 2 then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius + 300)
            if realEnemyCount ~= nil and #realEnemyCount >= 2 then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
        
        for _, enemyHero in pairs(nInRangeEnemy) do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_item_aeon_disk_buff') then
                -- if hero is under temp damage immute control
                if enemyHero:HasModifier(modifier_invoker_tornado) then
                    if DotaTime() >= AbilityCastedTimes['Tornado'] + TornadoLiftTime - (nLandTime + nCastPoint)
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                    end
                elseif X.CheckTempModifiers(TempNonMovableModifierNames, enemyHero, (nLandTime + nCastPoint)) > 0 then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                end
    
                if J.IsRunning(enemyHero) then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nLandTime + nCastPoint)
                else
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
    end

	--推进时对小兵用
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
    and J.IsAllowedToSpam( bot, nManaCost * 0.8 )
    and bot:GetLevel() <= 15
    then
        local nInRangeAlly = bot:GetNearbyHeroes(1400, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        if (nInRangeAlly == nil or #nInRangeAlly == 0) and (nInRangeEnemy == nil or #nInRangeEnemy == 0) then
            local laneCreepList = bot:GetNearbyLaneCreeps( 1400, true )
            if #laneCreepList >= 5
                and J.IsValid( laneCreepList[1] )
                and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
            then
                local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 100, 0, 0 )
                if locationAoEHurt.count >= 4
                then
                    return BOT_ACTION_DESIRE_HIGH, locationAoEHurt.targetloc, "带线"
                end
            end
        end
    end
    
	--对线
	if J.IsLaning( bot )
	then
        
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 5
        then
			return BOT_ACTION_DESIRE_HIGH, bot
		end

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
            print(DotaTime().." - Target has modifier "..mName..", the remaining time: " .. tostring(remaining) .. " seconds, delay: "..tostring(nDelay))
            if remaining ~= nil and (DotaTime() >= DotaTime() + remaining - nDelay )
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCataclysm()
    if not X.IsAbilityPossiblyBeCasted(Cataclysm)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local desire, _ = X.GoodTimeToUseCataclysmGlobally()
    if desire > 0 then
        return BOT_ACTION_DESIRE_HIGH, 0
    end

    if J.IsInTeamFight(bot, 1600)
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local nNotMovingEnemyCount = 0

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and (enemyHero:IsStunned()
                or enemyHero:IsRooted()
                or enemyHero:IsHexed()
                or enemyHero:IsNightmared()
                or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
                or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze'))
                or enemyHero:HasModifier('modifier_magnataur_reverse_polarity')
                or enemyHero:HasModifier('modifier_tidehunter_ravage')
                or J.IsTaunted(enemyHero)
            then
                nNotMovingEnemyCount = nNotMovingEnemyCount + 1
            end
        end

        if nNotMovingEnemyCount >= 2
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
        and J.GetHP(botTarget) <= 0.5
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
            or botTarget:HasModifier('modifier_magnataur_reverse_polarity')
            or botTarget:HasModifier('modifier_tidehunter_ravage')
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

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.GoodTimeToUseCataclysmGlobally()
    local nDamage = Sunstrike:GetSpecialValueInt('damage')

    local nEnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        -- 敌人可以被大天火击杀
        if J.IsValidHero(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage * 2, DAMAGE_TYPE_PURE)
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
            or enemyHero:HasModifier('modifier_bane_fiends_grip')
            or enemyHero:HasModifier('modifier_legion_commander_duel')
            or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or enemyHero:HasModifier('modifier_magnataur_reverse_polarity')
            or enemyHero:HasModifier('modifier_tidehunter_ravage')
            or J.IsTaunted(enemyHero))
        then
            return BOT_ACTION_DESIRE_HIGH, 0
        end
        
        -- 敌人被长时间大招固定控制
        if enemyHero:HasModifier('modifier_bane_fiends_grip')
        or enemyHero:HasModifier('modifier_legion_commander_duel')
        or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
        or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze') then
            return BOT_ACTION_DESIRE_HIGH, 0
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderSunstrike()
    if not X.IsAbilityPossiblyBeCasted(Sunstrike)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nDelay = Sunstrike:GetSpecialValueFloat('delay')
    local nCastPoint = 0 -- Sunstrike:GetCastPoint()
    local nDamage = Sunstrike:GetSpecialValueInt('damage')

    local nEnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        -- 敌人可以被天火击杀
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
            -- 敌人被控制
            if enemyHero:IsStunned()
            or enemyHero:IsRooted()
            or enemyHero:IsHexed()
            or enemyHero:IsNightmared()
            or enemyHero:IsChanneling()
            or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or enemyHero:HasModifier('modifier_magnataur_reverse_polarity')
            or enemyHero:HasModifier('modifier_tidehunter_ravage')
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
            
            -- 杀掉残血tp
			if enemyHero:HasModifier( 'modifier_teleporting' ) then
                local remaining = J.GetModifierTime(enemyHero, 'modifier_teleporting')
                if remaining ~= nil and (DotaTime() >= DotaTime() + remaining - nDelay - nCastPoint)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end

        -- 敌人被长时间大招控制
        if J.IsValidHero(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and (enemyHero:HasModifier('modifier_bane_fiends_grip')
        or enemyHero:HasModifier('modifier_legion_commander_duel')
        or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
        or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze'))
        or enemyHero:HasModifier('modifier_magnataur_reverse_polarity')
        or enemyHero:HasModifier('modifier_tidehunter_ravage') then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
        
        -- 敌人是否有即将结束的无敌状态能在天火延迟后被击杀
        if J.IsValidHero(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PURE)
        and not J.IsSuspiciousIllusion(enemyHero) then
            if X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, (nDelay + nCastPoint)) > 0 then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidHero(botTarget)
        and J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_PURE)
        and not J.IsSuspiciousIllusion(botTarget) then
            if X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, (nDelay + nCastPoint)) > 0 then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end

        if J.IsValidHero(botTarget)
        and J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_PURE)
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
	-- if J.IsLaning( bot )
	-- then
    --     local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
    --     local enemyHero
    --     if nInRangeEnemy ~= nil and nInRangeEnemy[1] ~= nil and #nInRangeEnemy <= 2 then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end
		
	-- 	local nEnemyLaneCreeps = enemyHero:GetNearbyLaneCreeps(300, true)
	-- 	if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps <= 1
    --     and enemyHero ~= nil and J.GetMP(bot) > 0.6 and J.GetHP(enemyHero) < 0.75
	-- 	then
	-- 		return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint), '对线消耗'
	-- 	end
	-- end
    
    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderForgeSpirit()
    if not X.IsAbilityPossiblyBeCasted(ForgeSpirit)
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
    if not X.IsAbilityPossiblyBeCasted(IceWall)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nSpawnDistance = IceWall:GetSpecialValueInt('wall_place_distance')
    local nCastRange = 200
    local nRadius = 1000

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
    
    if J.IsInTeamFight(bot) then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange + 200, nRadius, 0, 0)

        if  nLocationAoE.count >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
        
        local nInRangeEnemy = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
        if nInRangeEnemy ~= nil then
            for _, enemyHero in pairs(nInRangeEnemy) do
                if J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange) then
                    if J.IsRunning(enemyHero) then
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(1)
                    else
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                    end
                end
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
    if not X.IsAbilityPossiblyBeCasted(DeafeningBlast)
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
        and (not J.IsDisabled(botTarget) or botTarget:HasModifier('modifier_invoker_chaos_meteor_burn'))
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_eul_cyclone')
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

            if J.IsRunning(botTarget) then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
            end
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
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
        and not nInRangeEnemy[1]:HasModifier('modifier_eul_cyclone')
        and not nInRangeEnemy[1]:HasModifier(modifier_invoker_tornado)
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

function X.InvokeActualSpell(ability)
    print(DotaTime()..' - Invoker going to invoke '..ability:GetName())

    if ability == DeafeningBlast then
        X.InvokeSpell(Quas, Wex, Exort)
    elseif ability == ChaosMeteor then
        X.InvokeSpell(Exort, Exort, Wex)
    elseif ability == ForgeSpirit then
        X.InvokeSpell(Exort, Exort, Quas)
    elseif ability == Sunstrike then
        X.InvokeSpell(Exort, Exort, Exort)
    elseif ability == Alacrity then
        X.InvokeSpell(Wex, Wex, Exort)
    elseif ability == EMP then
        X.InvokeSpell(Wex, Wex, Wex)
    elseif ability == IceWall then
        X.InvokeSpell(Quas, Quas, Exort)
    elseif ability == GhostWalk then
        X.InvokeSpell(Quas, Quas, Wex)
    elseif ability == Tornado then
        X.InvokeSpell(Wex, Wex, Quas)
    elseif ability == ColdSnap then
        X.InvokeSpell(Quas, Quas, Quas)
    else
        print('[ERROR] Tried to invoke unsupported ability: '..ability:GetName())
		print("Stack Trace:", debug.traceback())
    end
    print(DotaTime()..' - Invoker tried to invoke '..ability:GetName())
end

function X.InvokeSpell(Orb1, Orb2, Orb3)
    bot:ActionPush_UseAbility(Invoke)
    bot:ActionPush_UseAbility(Orb1)
    bot:ActionPush_UseAbility(Orb2)
    bot:ActionPush_UseAbility(Orb3)
    
    -- X.InvokeElements(Orb1, Orb2, Orb3)
    -- bot:ActionQueue_Delay(0.1)
end

-- Check if the ability is ready to be invoked+casted, including those that are not displayed on the ability panel list.
-- First the bot should consider if it can cast the ability, if not, consider invoke the ability. Secondly, only if bot already has the ability on slots, the bot can then consider casting it - to avoid overridding/conflicting actions.
function X.IsAbilityReadyForInvoke(ability)
    return not X.IsAbilityAvailableOnSlots(ability) and X.IsAbilityPossiblyBeCasted(ability) and Invoke:IsFullyCastable()
end

-- check if the ability is actually castble at the moment without doing anything else.
function X.IsAbilityReadyForCast(ability)
    return X.IsAbilityAvailableOnSlots(ability) and X.IsAbilityPossiblyBeCasted(ability) and ability:IsFullyCastable()
end

-- check if the ability could be casted if assuming it's available on slots right now, so we can consider invoke it or cast it.
function X.IsAbilityPossiblyBeCasted(ability)
    if not X.HaveElementsTrainedToInvokeAbility(ability) then return false end

    local sAbility, tAbility
    if type(ability) == "string" and ability == 'Cataclysm' then
        sAbility = ability
        tAbility = Sunstrike
    else
        sAbility = AbilityNameMap[ability:GetName()]
        tAbility = ability
    end
    return DotaTime() >= AbilityCastedTimes[sAbility] + AbilityCooldownTimes[sAbility] and bot:GetMana() >= tAbility:GetManaCost()
end

-- check if Invoker has trained the required basic elements for invoking the spell
function X.HaveElementsTrainedToInvokeAbility(ability)
    if ability == DeafeningBlast then
        return Quas:IsTrained() and Wex:IsTrained() and Exort:IsTrained()
    elseif ability == ChaosMeteor then
        return Wex:IsTrained() and Exort:IsTrained()
    elseif ability == ForgeSpirit then
        return Quas:IsTrained() and Exort:IsTrained()
    elseif ability == Sunstrike then
        return Exort:IsTrained()
    elseif type(ability) == "string" and ability == Cataclysm then
        return bot:HasScepter() and X.HaveElementsTrainedToInvokeAbility(Sunstrike)
    elseif ability == Alacrity then
        return Wex:IsTrained() and Exort:IsTrained()
    elseif ability == EMP then
        return Wex:IsTrained()
    elseif ability == IceWall then
        return Quas:IsTrained() and Exort:IsTrained()
    elseif ability == GhostWalk then
        return Quas:IsTrained() and Wex:IsTrained()
    elseif ability == Tornado then
        return Quas:IsTrained() and Wex:IsTrained()
    elseif ability == ColdSnap then
        return Quas:IsTrained()
    else
        print('[ERROR] Checks invokability on an unsupported ability')
		print("Stack Trace:", debug.traceback())
    end
    
    return nil
end

-- check if the available on the skill slots already
function X.IsAbilityAvailableOnSlots(ability)
    local abilityD = bot:GetAbilityInSlot(3)  -- First invoked slot
    local abilityF = bot:GetAbilityInSlot(4)  -- Second invoked slot
    return ability == abilityD or ability == abilityF
end

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
            -- if timePassedSinceLastCast < ability:GetCooldown() * (1 - detectP) or not AbilityCastedTimes[sAbility] == -100 then return end -- 防止重复记录. 防止重复记录。不精确，有时会漏
            -- 通过时间和mana使用情况来做双重验证是否用了技能
            if DotaTime() - AbilityLastRecordedCastTimes[sAbility] <= 1 -- 一秒内仅记录一次
            or timePassedSinceLastCast >= ability:GetCooldown() * 0.5 -- 或者已经过了蛮久的时间了，这时候肯定不是重复记录而是某种原因能再次使用技能
            or AbilityLastRecordedCastTimes[sAbility] == -100 then -- TODO: AbilityLastRecordedCastTimes 现在可以优化掉了，有空再重构一些代码
                local deltaMana = previouslyRecordedMana - ability:GetManaCost()
                local manaRange = 20 -- 后期回蓝太快可能导致使用情况的计算错漏。设置太大值的话前中期碰到同时被消蓝的情况也可能有计算错漏
                if bot:GetMana() <= deltaMana + manaRange and bot:GetMana() >= deltaMana - manaRange then
                    print(DotaTime()..' - Invoker just used ability ' .. sAbility .. ', reset the cooldown tracking time.')
                    AbilityCastedTimes[sAbility] = DotaTime()
                    AbilityLastRecordedCastTimes[sAbility] = DotaTime()
                end
            end
        end
    end
    previouslyRecordedMana = bot:GetMana()
end

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