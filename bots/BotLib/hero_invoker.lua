local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
{--冰雷
    ['t25'] = {10, 0},
    ['t20'] = {10, 0},
    ['t15'] = {10, 0},
    ['t10'] = {10, 0}},
{--冰火
    ['t25'] = {0, 10},
    ['t20'] = {0, 10},
    ['t15'] = {10, 0},
    ['t10'] = {10, 0}}}

local tAllAbilityBuildList = {
						{2,1,2,1,3,1,2,1,2,2,3,3,3,3,3,3,2,2,1,1,1}, --冰雷核
                        {3,1,3,1,2,3,3,1,1,3,2,3,2,3,2,2,2,2,1,1,1} --冰火核
                        -- {1,2,2,3,2,1,2,1,2,1,2,1,2,1,1,3,3,3,3,3,3},--冰雷辅助
}

local nAbilityBuildList = tAllAbilityBuildList[1]

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList[1] )

local sRoleItemsBuyList = { }

-- 冰雷核
sRoleItemsBuyList['pos_2'] = {
	"item_ranged_carry_outfit",
    "item_urn_of_shadows",
    "item_spirit_vessel",
    -- "item_witch_blade",
    "item_orchid",
    "item_sphere",--
    "item_black_king_bar",--6
	"item_dragon_lance",
	"item_hurricane_pike",--3
    "item_aghanims_shard",
    "item_ultimate_scepter",
    "item_travel_boots",
    "item_bloodthorn",--5
    -- "item_devastator",--4
    "item_sheepstick",--2
    "item_moon_shard",
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--1
}

-- 冰火核
sRoleItemsBuyList['pos_2_qe'] = {
    "item_tango",
    "item_double_branches",

    "item_bracer",
    "item_magic_wand",
    "item_boots",
    "item_hand_of_midas",
    "item_power_treads",
    -- "item_cyclone", --瞎吹还喜欢走到吹起的点上，以后再改
    "item_orchid",
    "item_sphere",--
    "item_black_king_bar",--
    "item_travel_boots",
    "item_ultimate_scepter",
    "item_bloodthorn",--
	-- "item_hurricane_pike",--
    "item_sheepstick",--
    "item_aghanims_shard",
    -- "item_octarine_core",--
    "item_refresher",--
    "item_moon_shard",
    "item_ultimate_scepter_2",
    -- "item_wind_waker",--
    "item_travel_boots_2",--
}

sRoleItemsBuyList['pos_1'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_2']

X['sBuyList'] = sRoleItemsBuyList[sRole]

if Utils['GameStates']['invoker'] == nil then
    if (sRole == 'pos_2' or sRole == 'pos_1') and RandomInt( 1, 9 ) >= 3 then
        Utils['GameStates']['invoker'] = { roleType = 'pos_2_qe' }
    else
        Utils['GameStates']['invoker'] = { roleType = 'pos_2' }
    end
else
    if Utils['GameStates']['invoker'].roleType == 'pos_2_qe' then
        X['sBuyList'] = sRoleItemsBuyList['pos_2_qe']
        nAbilityBuildList = tAllAbilityBuildList[2]
        nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList[2] )
    end
end

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

	"item_ultimate_scepter",
	"item_magic_wand",

	"item_sheepstick",
	"item_hand_of_midas",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    if Utils.IsUnitWithName(hMinionUnit, 'forged_spirit') then
        local botTarget = J.GetProperTarget(bot)
        local unitTarget = hMinionUnit:GetAttackTarget()
        if unitTarget == nil then hMinionUnit:GetTarget() end
        
        -- 如果没塔 或者 目标血量低，则攻击目标
        local nEnemyTowers = bot:GetNearbyTowers(700, true)
        if botTarget ~= nil and (#nEnemyTowers < 1 or J.GetHP(botTarget) < 0.2) then
            if botTarget ~= nil then
                hMinionUnit:Action_AttackUnit(botTarget, false)
                return
            end
        end

        -- 可带线push
        if unitTarget ~= nil and (#nEnemyTowers < 1 or J.GetHP(unitTarget) < 0.2) then
            if unitTarget ~= nil then
                hMinionUnit:Action_AttackUnit(unitTarget, false)
                return
            end
            -- 没固定目标，fallback
            Minion.MinionThink(hMinionUnit)
        end
        
        -- 如果不是冒死也要杀死目前的情况，不要送
        if J.GetHP(hMinionUnit) < 0.5 and botTarget ~= nil and J.IsInRange(hMinionUnit, botTarget, botTarget:GetAttackRange()) then
            hMinionUnit:Action_MoveToLocation(J.GetTeamFountain())
            return
        end

        -- 没合适目标进攻，回到卡尔身边
        -- todo: 小心巫妖大，或者卡自己位
        if J.IsLaning(bot) or J.IsFarming(bot) then
            if GetUnitToUnitDistance(hMinionUnit, bot) > 500 then
                hMinionUnit:Action_AttackMove(bot:GetLocation() + RandomVector(220))
            end
        end
    else
        Minion.MinionThink(hMinionUnit)
    end
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
    Cataclysm = 100,

    -- to persist the verified cd after the ability is actually invoked, in case of any unknown neutral items or other cd reductions.
    Verified = { }
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

-- local AbilityLastRecordedCastTimes = AbilityCastedTimes

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
-- local InvokerCombos = 
-- {
--     -- Combo Name,      Enemy modifiers,        Combo Abilities in order,       Description
--     {ComboName_RightClick, {}, {ColdSnap, Alacrity, ForgeSpirit}, "cast cold snap, alacrity or forge spirit when right click enemy hero or building"},
--     {ComboName_EulMB, {modifier_wind_waker, modifier_item_wind_waker, modifier_item_cyclone, modifier_eul_cyclone}, {Sunstrike, ChaosMeteor, DeafeningBlast, ColdSnap}, "if target in cyclone, cast deafening blast after chaos meteor"},
--     {ComboName_TMB, {}, {Tornado, ChaosMeteor, DeafeningBlast, ColdSnap}, "cast deafening blast after chaos meteor"},
--     {ComboName_TEC, {}, {Tornado, EMP}, "cast tornado, emp"},
--     -- {ComboName_DoT, {}, {ColdSnap, Alacrity, ForgeSpirit}, "cast cold snap on enemy who is affected by DoT, like chaos meteor, urn, ice wall, etc."},
--     {ComboName_EulC, {modifier_wind_waker, modifier_item_wind_waker, modifier_item_cyclone, modifier_eul_cyclone}, {ColdSnap, Sunstrike, EMP}, "if target in cyclone, cold snap, cast sun strike and EMP"},
--     {ComboName_ColdSnap, {}, {ColdSnap, Sunstrike, EMP}, "cold snap, cast sun strike and EMP"},
--     {ComboName_TS, {}, {Tornado, Sunstrike}, "Tornado, follow by sun strike or Cataclysm"},

--     {ComboName_FixedPosition, {}, {Sunstrike, ChaosMeteor, DeafeningBlast}, "cast sun strike, chaos meteor, DeafeningBlast on fixed enemies."},
--     {ComboName_Slowed, {}, {Sunstrike, ChaosMeteor, EMP, DeafeningBlast}, "cast sun strike, chaos meteor, EMP on slowed enemies."},
--     {ComboName_KillSteal, {}, {DeafeningBlast, Sunstrike}, "cast deafening blast, tornado or sun strike to predicted position to KS"},
--     {ComboName_LinkenBreaker, {}, {ColdSnap}, "cast cold snap to break linken sphere"},
--     {ComboName_Interrupt, {}, {ColdSnap, Tornado}, "interrupt enemy's tp or channelling spell with tornado or cold snap"},
--     {ComboName_Defend, {}, {Tornado, DeafeningBlast, GhostWalk}, "If enemies are too close, auto cast (1) tornado, (2) blast, (3) cold snap, or (4) ghost walk to escape."},
--     {ComboName_IceWallHelper, {}, {IceWall}, "cast ice wall if it can affect an enemy."},

--     {ComboName_SpellProtect, {}, {}, "Protect uncast spell by moving casted spell to second slot"},
--     {ComboName_InstanceHelper, {}, {}, "switch instances, EEE when attacking, WWW when running"},
-- }

local EMPDelay
local TornadoLiftTime

local botTarget

local saveManaInLaning = 280

local previouslyRecordedMana = -1
-- local octarineCoreCooldownReductionsCheck = false

local nEnemyHeroes, nAllyHeroes, isInLaningPhase

function X.SkillsComplement()

    CheckAbilityUsage()
    if J.CanNotUseAbility(bot) then return end

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)
    isInLaningPhase = J.IsInLaningPhase(bot)

    if bot:HasModifier(modifier_invoker_ghost_walk_self)
    and (bot:WasRecentlyDamagedByAnyHero(6)
    or (J.GetHP(bot) <= 0.8 or #nEnemyHeroes >= #nAllyHeroes + 1)) then
        return
    end

    botTarget = J.GetProperTarget(bot)
    TornadoLiftTime = Tornado:GetSpecialValueFloat('lift_duration')
    -- CheckForCooldownReductions()

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

    -- 逃命第二
    GhostWalkDesire = X.ConsiderGhostWalk()
    if GhostWalkDesire > 0 then X.CastInvokerSpell(GhostWalk) return end

    ------- 尝试把连招串联起来，判断是否用了可以连招的前置技能 -------
    -- 如果前置技能进入cd，且距离使用它的时间刚刚过去delta时间之内，则可以试试是否能马上切或放下一个连招技能
    local deltaTime = 2

    -- 雷的等级大于4级优先考虑磁暴消耗
    if Wex:GetLevel() >= 4 then
        TornadoDesire, TornadoLocation = X.ConsiderTornado()
        if TornadoDesire > 0 then X.CastInvokerSpell(Tornado, TornadoLocation) return end
        EMPDesire, EMPLocation = X.ConsiderEMP()
        if EMPDesire > 0 then  X.CastInvokerSpell(EMP, EMPLocation) return end
    end

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

    EMPDesire, EMPLocation = X.ConsiderEMP()
    if EMPDesire > 0 then  X.CastInvokerSpell(EMP, EMPLocation) return end

    IceWallDesire = X.ConsiderIceWall()
    if IceWallDesire > 0 then X.CastInvokerSpell(IceWall) return end


    -- 物理攻击消耗敌人. 对线消耗

    if isInLaningPhase
    and bot:GetLevel() >= 2
    and bot:GetLevel() <= 12
    and J.GetHP(bot) > 0.75
    and #nEnemyHeroes <= #nAllyHeroes
    and not J.IsRetreating(bot)
    and not J.IsGoingOnSomeone(bot)
    and not J.IsInTeamFight(bot, 1200) then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(300, true)
		local nEnemyTowers = bot:GetNearbyTowers(700, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps > 3 and nEnemyTowers ~= nil and #nEnemyTowers >= 1
        then
			return
		end

        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if J.IsValidHero(enemyHero)
            and J.GetHP(bot) >= J.GetHP(enemyHero)
            and bot:GetAttackTarget() ~= enemyHero
            and (bot:HasModifier(modifier_invoker_alacrity)
            or enemyHero:HasModifier(modifier_invoker_cold_snap_freeze)
            or enemyHero:HasModifier(modifier_invoker_chaos_meteor_burn))
            then
                bot:ActionQueue_AttackUnit(enemyHero, true)
                return
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
            if nEnemyHeroes == nil or #nEnemyHeroes <= 0 then
                if X.CanAbilityPossiblyBeCasted(Tornado) and not X.IsAbilityAvailableOnSlots(Tornado) then
                    print('Invoke Tornado as idel spell')
                    X.InvokeActualSpell(Tornado)
                end
                if X.CanAbilityPossiblyBeCasted(ColdSnap) and not X.IsAbilityAvailableOnSlots(ColdSnap) then
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

    if Sunstrike:GetCooldownTimeRemaining() >= 10 -- 技能快好了的话没必要刷新
    and (Sunstrike:GetCooldownTimeRemaining()/Sunstrike:GetCooldown() <= 0.7 -- 不想马上就刷新因为可能可以再连一些技能，或者技能已经快好了
        or X.CanAbilityPossiblyBeCasted(Cataclysm)
    )
    and X.IsAbilityAvailableOnSlots(Sunstrike)
    and bot:GetMana() >= (SunstrikeMana * 2 + SunstrikeMana) then
        local cataclysmDesire, _ = X.GoodTimeToUseCataclysmGlobally()
        if cataclysmDesire > 0 then
            return true
            end
    end
    
    if ChaosMeteor:GetCooldownTimeRemaining() >= 10 -- 技能快好了的话没必要刷新
    and ChaosMeteor:GetCooldownTimeRemaining()/ChaosMeteor:GetCooldown() <= 0.7 -- 不想马上就刷新因为可能可以再连一些技能，或者技能已经快好了
    and X.IsAbilityAvailableOnSlots(ChaosMeteor)
    and #nEnemyHeroes > 0
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
    local sAbility
    if type(ability) == "string" and ability == 'Cataclysm' then
        sAbility = ability
        ability = Sunstrike
    else
        sAbility = ability:GetName()
    end
    
    print(DotaTime()..' - Invoker checking to cast '..sAbility) -- can be annoying since this line gets printed a lot if e.g. no enough mana or before invoker trains all elements

    if X.IsAbilityReadyForInvoke(ability) then
        X.InvokeActualSpell(ability)
    end
    if X.IsAbilityReadyForCast(ability)
    then
        print(DotaTime()..' - Invoker has it on slot, going to cast '..sAbility)
        bot:Action_ClearActions(false)

        -- bot:ActionQueue_Delay(ability:GetCastPoint())
        if sAbility == Cataclysm then
            bot:ActionQueue_UseAbilityOnEntity(ability, bot)
        elseif ability == ForgeSpirit
            or ability == IceWall
            or ability == GhostWalk then
                bot:ActionQueue_UseAbility(ability)
        elseif ability == DeafeningBlast
            or ability == Sunstrike
            or ability == ChaosMeteor
            or ability == EMP
            or ability == Tornado then
                bot:ActionQueue_UseAbilityOnLocation(ability, target)
        elseif ability == Alacrity
            or ability == ColdSnap then
                bot:ActionQueue_UseAbilityOnEntity(ability, target)
        else
            print(DotaTime()..' - [ERROR] Tried to cast unsupported spell: '..sAbility)
            print("Stack Trace:", debug.traceback())
        end
        print(DotaTime()..' - Invoker tried to cast '..sAbility)
    else
        -- print(DotaTime()..' - Invoker trying to cast a spell that is not ready: '..abilityName..', '.. tostring(X.IsAbilityAvailableOnSlots(ability)) ..', '..tostring(ability:IsFullyCastable()))
    end
end

function X.ConsiderColdSnap()
    if not X.CanAbilityPossiblyBeCasted(ColdSnap)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local castDeltaRange = 60
	local nCastRange = J.GetProperCastRange(false, bot, ColdSnap:GetCastRange())

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange - castDeltaRange)
        and (not isInLaningPhase or (isInLaningPhase and J.GetManaAfter(ColdSnap:GetManaCost()) > 0.5) or J.GetHP(enemyHero) < 0.5)
        and (
            enemyHero:IsChanneling() -- 打断技能
            or enemyHero:HasModifier('modifier_item_urn_damage') -- 配合骨灰
            or enemyHero:HasModifier('modifier_item_spirit_vessel_damage') -- 配合大骨灰
            or enemyHero:HasModifier('modifier_invoker_chaos_meteor_burn') -- 配合陨石
            or J.IsChasingTarget(bot, enemyHero)
        )
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange - castDeltaRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and (not isInLaningPhase
            or (isInLaningPhase and J.GetManaAfter(ColdSnap:GetManaCost()) > 0.5 and J.IsAttacking(bot))
            or (isInLaningPhase and J.GetMP(bot) > 0.5 and J.IsAttacking(botTarget)) -- 妨碍补刀
            or J.GetHP(botTarget) < 0.5)
		then
            return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	--对线
	if J.IsLaning( bot )
	then
        local enemyHero
        if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1 then enemyHero = nEnemyHeroes[1] else return BOT_ACTION_DESIRE_NONE, nil end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        -- and J.IsAttacking(bot, enemyHero)
        and J.IsInRange(bot, enemyHero, bot:GetAttackRange() - castDeltaRange)
        and not J.IsSuspiciousIllusion(enemyHero)
        and bot:GetMana() - ColdSnap:GetManaCost() >= saveManaInLaning
        and ((J.GetManaAfter(ColdSnap:GetManaCost()) > 0.4 and J.IsAttacking(bot))
            or (J.GetMP(bot) > 0.5 and J.IsAttacking(enemyHero)) -- 妨碍补刀
        )
		then
            return BOT_ACTION_DESIRE_HIGH, enemyHero, "对线消耗:"..J.Chat.GetNormName( enemyHero )
		end
	end

	if J.IsRetreating(bot)
	then
        local enemyHero
        if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1 then enemyHero = nEnemyHeroes[1] else return BOT_ACTION_DESIRE_NONE, nil end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsChasingTarget(enemyHero, bot)
        and GetUnitToUnitDistance(enemyHero, bot) > enemyHero:GetAttackRange() - 200
        and J.IsInRange(bot, enemyHero, nCastRange - castDeltaRange)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
            if bot:WasRecentlyDamagedByAnyHero(2)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderGhostWalk()
    if not X.CanAbilityPossiblyBeCasted(GhostWalk)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    if J.IsRetreating(bot) or (J.GetHP(bot) <= 0.4 and #nEnemyHeroes >= #nAllyHeroes) then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if J.IsValidHero(enemyHero)
            and (J.IsChasingTarget(enemyHero, bot)
            or GetUnitToUnitDistance(enemyHero, bot) < enemyHero:GetAttackRange() + 100)
            and ((isInLaningPhase and bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(bot) < 0.7) or not isInLaningPhase)
            and not J.IsAttacking(bot)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsStunProjectileIncoming( bot, 1200 ) then
        return BOT_ACTION_DESIRE_HIGH
    end

    -- 可能被抓了
    if #nEnemyHeroes >= 2 and #nEnemyHeroes > #nAllyHeroes
    and J.IsValidHero(nEnemyHeroes[1])
    and nEnemyHeroes[1]:GetLevel() >= bot:GetLevel() - 2 then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTornado()
    local deltaTime = 4
    if not X.CanAbilityPossiblyBeCasted(Tornado)
        -- 同时也确保不要在刚刚放了陨石或者推波之后马上用吹风
        or (DotaTime() - AbilityCastedTimes['ChaosMeteor'] <= deltaTime
            or DotaTime() - AbilityCastedTimes['DeafeningBlast'] <= deltaTime
            or DotaTime() - AbilityCastedTimes['Sunstrike'] <= deltaTime
            or DotaTime() - AbilityCastedTimes['Cataclysm'] <= deltaTime)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, Tornado:GetCastRange())
    local nCastPoint = Tornado:GetCastPoint()
	local nRadius = Tornado:GetSpecialValueInt('area_of_effect')
	local nSpeed = Tornado:GetSpecialValueInt('travel_speed')

    if J.IsInTeamFight(bot, 1200) then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
        local nInRangeAlly = J.GetAlliesNearLoc(nLocationAoE.targetloc, nRadius)

        local targetloc = J.GetCenterOfUnits(nInRangeEnemy)
        local toTargetLocDistance = GetUnitToLocationDistance(bot, targetloc)
		if #nInRangeEnemy >=2 and #nInRangeAlly < #nInRangeEnemy
        and not J.IsLocationInChrono(targetloc)
        and not J.IsLocationInBlackHole(targetloc)
        and toTargetLocDistance <= nCastRange
        and toTargetLocDistance > bot:GetAttackRange()
        then
            return BOT_ACTION_DESIRE_HIGH, targetloc
		end
	end

    -- 打断技能
    if botTarget ~= nil and botTarget:IsChanneling()
    and J.IsValidHero(botTarget)
    and J.CanCastOnNonMagicImmune(botTarget)
    and J.IsInRange(bot, botTarget, nCastRange)
    then
        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
    end

    if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and (not isInLaningPhase or (isInLaningPhase and J.GetManaAfter(Tornado:GetManaCost()) > 0.5) or J.GetHP(botTarget) < 0.5)
        and not J.IsInRange(bot, botTarget, bot:GetAttackRange())
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
            if J.IsRunning(botTarget) then
                local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, nDelay)
            else
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

	--对线消耗
	if J.IsLaning( bot ) and (bot:GetMana() - Tornado:GetManaCost() >= saveManaInLaning) then
        local enemyHero
        if nEnemyHeroes ~= nil and #nEnemyHeroes <= 2 and nEnemyHeroes[1] ~= nil then enemyHero = nEnemyHeroes[1] else return BOT_ACTION_DESIRE_NONE, nil end
		
        if enemyHero ~= nil and J.GetMP(bot) > 0.7
		then
            local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(enemyHero, nDelay), '对线消耗'
		end
	end

    if J.IsRetreating(bot) then
        local enemyHero
        if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1 and nEnemyHeroes[1] ~= nil then enemyHero = nEnemyHeroes[1] else return BOT_ACTION_DESIRE_NONE, 0 end
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsChasingTarget(enemyHero, bot)
        and J.IsInRange(bot, enemyHero, nCastRange - 200)
        and (not isInLaningPhase or (isInLaningPhase and J.GetHP(bot) < 0.7))
		then
            if bot:WasRecentlyDamagedByAnyHero(3) then
                local nInRangeEnemy2 = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)
                if nInRangeEnemy2 ~= nil and #nInRangeEnemy2 >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy2)
                else
                    local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
                    return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(enemyHero, nDelay)
                end
            end
		end
	end

    if J.IsDefending(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and not J.IsLocationInChrono(nLocationAoE.targetloc)
        and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderEMP()
    if not X.CanAbilityPossiblyBeCasted(EMP)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    EMPDelay = EMP:GetSpecialValueFloat('delay')

	local nCastRange = EMP:GetCastRange()
    local nCastPoint = EMP:GetCastPoint()
	local nRadius = EMP:GetSpecialValueInt('area_of_effect')
    local nDelay = EMPDelay + nCastPoint

	if J.IsInTeamFight(bot, 1300)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nDelay, 0)
		if nLocationAoE.count >= 2
        and GetUnitToLocationDistance(bot, nLocationAoE.targetloc) <= nCastRange
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
        and (not isInLaningPhase or (isInLaningPhase and J.GetManaAfter(EMP:GetManaCost()) > 0.5) or J.GetHP(botTarget) < 0.5)
		and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_eul_cyclone')
		then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nDelay, 0)
            if nLocationAoE.count >= 1
            and GetUnitToLocationDistance(bot, nLocationAoE.targetloc) <= nCastRange
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
		end
	end

    if J.IsValidHero(botTarget)
    and J.CanCastOnNonMagicImmune(botTarget)
    and J.IsInRange(bot, botTarget, nCastRange)
    and (not isInLaningPhase or (isInLaningPhase and J.GetManaAfter(EMP:GetManaCost()) > 0.5) or J.GetHP(botTarget) < 0.5)
    and botTarget:HasModifier(modifier_invoker_tornado)
    then
        return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, nDelay)
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderAlacrity()
    if not X.CanAbilityPossiblyBeCasted(Alacrity)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, Alacrity:GetCastRange())

    local suitableTarget = bot
	local nMaxDamage = 0
    local nAllyHeroes = J.GetNearbyHeroes(bot, nCastRange, false)
	for _, allyHero in pairs(nAllyHeroes)
	do
		if J.IsValidHero(allyHero)
        and J.IsAttacking(allyHero)
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
        and J.IsAttacking(bot)
        and J.CanBeAttacked(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and (not isInLaningPhase or (isInLaningPhase and J.GetManaAfter(Alacrity:GetManaCost()) > 0.5) or J.GetHP(botTarget) < 0.5)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            if J.IsInRange(suitableTarget, botTarget, nCastRange)
            and ((nEnemyHeroes ~= nil and #nEnemyHeroes >=2 and not X.CanAbilityPossiblyBeCasted(ChaosMeteor)) -- 如果附近多人, 优先考虑陨石
                or (nEnemyHeroes ~= nil and #nEnemyHeroes == 1)) -- 如果附近就一个敌人
            then
                return BOT_ACTION_DESIRE_HIGH, suitableTarget
            end
		end
	end

	if J.IsPushing(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(700, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
        then
			return BOT_ACTION_DESIRE_HIGH, bot
		end

		local nEnemyTowers = bot:GetNearbyTowers(700, true)

		if nEnemyTowers ~= nil and #nEnemyTowers >= 1
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
    and bot:GetMana() - Alacrity:GetManaCost() >= saveManaInLaning
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(700, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
        and J.IsAttacking(bot)
        then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
        
        local enemyHero
        if nEnemyHeroes ~= nil and #nEnemyHeroes <=2 and nEnemyHeroes[1] ~= nil then enemyHero = nEnemyHeroes[1] else return BOT_ACTION_DESIRE_NONE, nil end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsAttacking(bot)
        and botTarget == enemyHero
		then
            return BOT_ACTION_DESIRE_HIGH, bot, "对线消耗:"..J.Chat.GetNormName( enemyHero )
		end
	end

    if J.IsFarming(bot)
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
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, suitableTarget
		end
	end

    if J.IsDoingTormentor(bot)
    and suitableTarget ~= nil
	then
		if J.IsTormentor(botTarget)
        and J.IsInRange(suitableTarget, botTarget, 1000)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, suitableTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderCmToTarget(target, nDelay, nTravelDistance, nRadius)
    if (J.IsValidHero(target)
        or (J.IsValidTarget(target) and (J.Unit.IsUnitWithName(target, "roshan") or J.Unit.IsUnitWithName(target, "boss")))) -- can be roshan or others
    and J.CanCastOnNonMagicImmune(target)
    and not J.IsSuspiciousIllusion(target)
    and (not isInLaningPhase or (isInLaningPhase and J.GetManaAfter(ChaosMeteor:GetManaCost()) > 0.5) or J.GetHP(target) < 0.5)
    and not target:HasModifier('modifier_abaddon_borrowed_time')
    and (J.GetHP(target) <= 0.9 and J.GetHP(target) > 0.15) or target:GetMovementDirectionStability() >= 0.75
    then
        -- if hero is under temp damage immute control
        if target:HasModifier(modifier_invoker_tornado) then
            if DotaTime() >= AbilityCastedTimes['Tornado'] + TornadoLiftTime - nDelay
            then
                return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(target:GetLocation(), target)
            end
        elseif X.CheckTempModifiers(TempNonMovableModifierNames, target, nDelay) > 0 then
            return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(target:GetLocation(), target)
        end

        if target:IsStunned()
        or target:IsRooted()
        or target:IsHexed()
        or target:IsChanneling()
        or X.IsUnderLongDurationStun(target) then
            if J.IsRunning(target) then
                return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(target, nDelay)
            end
        end

        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nTravelDistance, nRadius, nDelay, 0)
        if nLocationAoE.count >= 2 then
            return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(nLocationAoE.targetloc, target)
        end
        return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(J.GetCorrectLoc(target, nDelay), target)
    end

    return 0, nil
end

function X.ConsiderChaosMeteor()
    if not X.CanAbilityPossiblyBeCasted(ChaosMeteor)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, ChaosMeteor:GetCastRange())
    local nLandTime = ChaosMeteor:GetSpecialValueFloat('land_time')
	local nRadius = ChaosMeteor:GetSpecialValueInt('area_of_effect')
	local nTravelDistance = ChaosMeteor:GetSpecialValueInt('travel_distance')
    -- local nCastPoint = ChaosMeteor:GetCastPoint()
    -- local nManaCost = ChaosMeteor:GetManaCost()
    local nDelay = nLandTime -- + nCastPoint

    if DotaTime() - AbilityCastedTimes['Tornado'] <= TornadoLiftTime - nLandTime then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    if J.IsInTeamFight(bot, 1200) then
		local nLocationAoE = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nLocationAoE ~= nil
        and GetUnitToLocationDistance(bot, nLocationAoE) <= nCastRange
        and J.GetEnemiesAroundLoc(nLocationAoE, nRadius) >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(nLocationAoE, nil)
		end
    end

    if not J.IsRetreating(bot) then
        for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
        do
            if J.IsInRange(bot, enemyHero, nCastRange) then
                local desire, target = X.ConsiderCmToTarget(enemyHero, nDelay, nTravelDistance, nRadius)
                if desire > 0 then
                    return desire, target
                end
            end
        end
    end

	if J.IsGoingOnSomeone(bot)
    and J.IsValidTarget(botTarget)
    and J.IsAttacking(bot)
    and J.IsInRange(bot, botTarget, nCastRange)
	then
        local desire, target = X.ConsiderCmToTarget(botTarget, nDelay, nTravelDistance, nRadius)
        if desire > 0 then
            return desire, target
        end
	end

	--推进时对小兵用
	-- if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
    -- and J.IsAllowedToSpam( bot, nManaCost * 0.8 )
    -- and bot:GetLevel() <= 18 then
    --     if (nAllyHeroes == nil or #nAllyHeroes == 0) and (nEnemyHeroes == nil or #nEnemyHeroes == 0) then
    --         local laneCreepList = bot:GetNearbyLaneCreeps( 1400, true )
    --         if #laneCreepList >= 5
    --             and J.IsValid( laneCreepList[1] )
    --             and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
    --         then
    --             local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
    --             if locationAoEHurt.count >= 4
    --             then
    --                 return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(locationAoEHurt.targetloc, nil)
    --             end
    --         end
    --     end
    -- end

	--对线
	if J.IsLaning( bot ) then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1400, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 5
        then
			local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 500 )
			if locationAoEKill.count >= 3 then
				return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(locationAoEKill.targetloc, nil)
			end
		end

        local enemyHero
        if nEnemyHeroes ~= nil and #nEnemyHeroes <=2 and nEnemyHeroes[1] ~= nil then enemyHero = nEnemyHeroes[1] else return BOT_ACTION_DESIRE_NONE, nil end

        if J.IsValidHero(enemyHero)
        and J.IsAttacking(bot)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and not J.IsSuspiciousIllusion(enemyHero)
        and J.GetHP(enemyHero) <= 0.8
		then
            if J.IsRunning(enemyHero) then
                return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(J.GetCorrectLoc(enemyHero, nDelay), enemyHero)
            else
                return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(enemyHero:GetLocation(), enemyHero)
            end
		end
	end

    if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(botTarget:GetLocation(), botTarget)
		end
	end

    if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, 700)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, X.AdjustCMLocation(botTarget:GetLocation(), botTarget)
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

-- 稍微调整陨石目标位置，吃多一点砸中和滚中的伤害。也能让石头多滚一会，多一点时间切/放其他技能连击
function X.AdjustCMLocation(loc, target)
    if target == nil or J.IsChasingTarget(bot, target) then
        return loc
    end

    local deltaDistance = 250
    local distance = GetUnitToUnitDistance(bot, target)
    -- 往自己这边跑，则往身前放
    if target:IsFacingLocation( bot:GetLocation(), 20 ) and J.IsRunning( target ) and distance < deltaDistance then
        return Utils.GetOffsetLocationTowardsTargetLocation(target:GetLocation(), bot:GetLocation(), distance + 120)
    end

    if distance < deltaDistance + 50 then
        return loc
    end
    return Utils.GetOffsetLocationTowardsTargetLocation(loc, bot:GetLocation(), deltaDistance)
end

function X.CheckTempModifiers(modifierNames, botTarget, nDelay)
    local countMo = 0
    if botTarget == nil then return BOT_ACTION_DESIRE_NONE, countMo end

    for _, mName in pairs(modifierNames) do
        if botTarget:HasModifier(mName) then
            countMo = countMo + 1
            local remaining = J.GetModifierTime(botTarget, mName)
            print(DotaTime().." - Target has modifier "..mName..", the remaining time: " .. tostring(remaining) .. " seconds, delay: "..tostring(nDelay))
            if remaining > 0 and remaining <= nDelay
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end
    -- if no such modifiers, should be ok to directly cast ability.
    if countMo == 0 then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

-- 7.39 facet changed
function X.ConsiderCataclysm() return BOT_ACTION_DESIRE_NONE, 0 end
function X.ConsiderCataclysm_()
    if not X.CanAbilityPossiblyBeCasted(Cataclysm) then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local desire, _ = X.GoodTimeToUseCataclysmGlobally()
    if desire > 0 then
        return BOT_ACTION_DESIRE_HIGH, 0
    end

    local nCastPoint = Sunstrike:GetCastPoint()
    local nDelay = Sunstrike:GetSpecialValueFloat('delay') + nCastPoint

    if J.IsGoingOnSomeone(bot)
    then
        -- if J.IsValidHero(botTarget) then
        --     -- if hero is already under control
        --     local tornadoTime = J.GetModifierTime( botTarget, modifier_invoker_tornado )
        --     if tornadoTime > 0 and tornadoTime <= nDelay then
        --         return BOT_ACTION_DESIRE_HIGH, 0
        --     elseif X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, nDelay) > 0 then
        --         return BOT_ACTION_DESIRE_HIGH, 0
        --     end
        -- end

        if J.IsValidHero(botTarget)
        and J.GetHP(botTarget) <= 0.85
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_eul_cyclone')
        and not botTarget:HasModifier(modifier_invoker_tornado)
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not botTarget:HasModifier('modifier_item_aeon_disk_buff')
        and (X.IsUnderLongDurationStun(botTarget)
            or botTarget:IsStunned()
            or botTarget:IsRooted())
        then
            return BOT_ACTION_DESIRE_HIGH, 0
        end

    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.GoodTimeToUseCataclysmGlobally()
    local nDamage = Sunstrike:GetSpecialValueInt('damage')
    local nCastPoint = Sunstrike:GetCastPoint()
    local nDelay = Sunstrike:GetSpecialValueFloat('delay') + nCastPoint

    for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
    do
        -- 敌人可以被大天火击杀
        if J.IsValidHero(enemyHero)
        and nDamage * 2 > enemyHero:GetHealth()
        and not J.IsSuspiciousIllusion(enemyHero)
        and (X.IsUnderLongDurationStun(enemyHero)
            or enemyHero:IsStunned()
            or enemyHero:IsRooted())
        then
            -- if J.IsValidHero(botTarget) then
            --     -- if hero is already under control
            --     local tornadoTime = J.GetModifierTime( botTarget, modifier_invoker_tornado )
            --     if tornadoTime > 0 and tornadoTime <= nDelay then
            --         return BOT_ACTION_DESIRE_HIGH, 0
            --     elseif X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, nDelay) > 0 then
            --         return BOT_ACTION_DESIRE_HIGH, 0
            --     end
            -- end

            return BOT_ACTION_DESIRE_HIGH, 0
        end

        -- 不能被即可击杀，但是被大招控制了
        if J.IsValidHero(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_brewmaster_storm_cyclone')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_eul_cyclone')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not enemyHero:HasModifier('modifier_item_aeon_disk_buff')
        and not J.IsSuspiciousIllusion(enemyHero)
        and (X.IsUnderLongDurationStun(enemyHero)
            or enemyHero:IsStunned()
            or enemyHero:IsRooted())
        then
            return BOT_ACTION_DESIRE_HIGH, 0
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

-- 敌人被长时间大招固定控制
function X.IsUnderLongDurationStun(enemyHero)
    return enemyHero:HasModifier('modifier_bane_fiends_grip')
    or enemyHero:HasModifier('modifier_legion_commander_duel')
    or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
    or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
    or enemyHero:HasModifier('modifier_magnataur_reverse_polarity')
    or enemyHero:HasModifier('modifier_tidehunter_ravage')
end

function X.ConsiderSunstrike()
    if not X.CanAbilityPossiblyBeCasted(Sunstrike)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nDelay = Sunstrike:GetSpecialValueFloat('delay')
    local nCastPoint = 0 -- Sunstrike:GetCastPoint()
    local nDamage = Sunstrike:GetSpecialValueInt('damage')

    local nAllEnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _, enemyHero in pairs(nAllEnemyHeroes)
    do
        if J.IsValidHero(enemyHero) and not J.IsSuspiciousIllusion(enemyHero) then
            -- Check if we can kill the enemy with Sunstrike
            if nDamage * 1.2 > enemyHero:GetHealth()
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_brewmaster_storm_cyclone')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_eul_cyclone')
            and not enemyHero:HasModifier(modifier_invoker_tornado)
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            and not enemyHero:HasModifier('modifier_item_aeon_disk_buff')
            then
                if nDamage > enemyHero:GetHealth() then
                    -- 残血tp
                    if enemyHero:HasModifier( 'modifier_teleporting' ) then
                        local remaining = J.GetModifierTime(enemyHero, 'modifier_teleporting')
                        if remaining ~= nil and remaining > nDelay + 0.05
                        then
                            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                        else
                            -- tp 马上完成，则天火对方泉水
                            return BOT_ACTION_DESIRE_HIGH, Utils.GetEnemyFountainTpPoint()
                        end
                    end

                    -- Predict the enemy's location
                    local targetLoc = J.GetCorrectLoc(enemyHero, nDelay + nCastPoint)
                    return BOT_ACTION_DESIRE_HIGH, targetLoc
                end

                -- If allies are nearby, assume they will help
                if #J.GetHeroesNearLocation(false, enemyHero:GetLocation(), 300) >= 1 and (not isInLaningPhase or nDamage > enemyHero:GetHealth()) then
                    local targetLoc = J.GetCorrectLoc(enemyHero, nDelay + nCastPoint)
                    return BOT_ACTION_DESIRE_HIGH, targetLoc
                end
            end
        end
    end

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
    if not X.CanAbilityPossiblyBeCasted(ForgeSpirit)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 1200)
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end
    
    if (J.IsLaning( bot ) or J.IsFarming(bot))
    and J.IsAttacking(bot)
    and bot:GetMana() - ForgeSpirit:GetManaCost() >= saveManaInLaning
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
		if J.IsRoshan(botTarget)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderIceWall()
    if not X.CanAbilityPossiblyBeCasted(IceWall)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nSpawnDistance = IceWall:GetSpecialValueInt('wall_place_distance')
    local nSimpleIceWallCheckDistance = 300
    local nCastRange = 300
    local nRadius = 1000

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
        and J.IsInRange(bot, botTarget, nSimpleIceWallCheckDistance)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsRunning(botTarget)
        and (not isInLaningPhase or (isInLaningPhase and J.GetMP(bot) > 0.7) or J.GetHP(botTarget) < 0.3)
        and bot:IsFacingLocation(botTarget:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
		then
            return BOT_ACTION_DESIRE_HIGH
		end

        if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
        and J.IsValidHero(nEnemyHeroes[1])
        and X.CheckTempModifiers(TempNonMovableModifierNames, nEnemyHeroes[1], 1) > 0
        and J.IsInRange(bot, nEnemyHeroes[1], nSimpleIceWallCheckDistance)
        and (not isInLaningPhase or (isInLaningPhase and J.GetMP(bot) > 0.7) or J.GetHP(nEnemyHeroes[1]) < 0.3)
        and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
        and bot:IsFacingLocation(nEnemyHeroes[1]:GetLocation(), 30) then
            return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]:GetLocation()
        end
	end

    if J.IsInTeamFight(bot, 1200) then
		local nLocationAoE = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nLocationAoE ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE
		end
        if nEnemyHeroes ~= nil then
            for _, enemyHero in pairs(nEnemyHeroes) do
                if J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nSimpleIceWallCheckDistance) then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(enemyHero, 0.5)
                end
                if X.CheckTempModifiers(TempNonMovableModifierNames, enemyHero, 1) > 0
                and J.IsInRange(bot, enemyHero, nSimpleIceWallCheckDistance)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and bot:IsFacingLocation(enemyHero:GetLocation(), 30) then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
    end

    if J.IsRetreating(bot)
	then
        if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
        and J.IsValidHero(nEnemyHeroes[1])
        and J.IsInRange(bot, nEnemyHeroes[1], nSimpleIceWallCheckDistance)
        and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
        and J.IsChasingTarget(nEnemyHeroes[1], bot)
        and bot:WasRecentlyDamagedByAnyHero(2)
        and not J.IsSuspiciousIllusion(nEnemyHeroes[1])
        and not J.IsDisabled(nEnemyHeroes[1])
        and (J.GetHP(bot) < 0.6 or J.GetTotalEstimatedDamageToTarget(nEnemyHeroes, bot) > bot:GetHealth())
        and not isInLaningPhase
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDeafeningBlast()
    if not X.CanAbilityPossiblyBeCasted(DeafeningBlast)
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
    
    local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

    if J.IsInTeamFight(bot, 1500)
    -- and not ChaosMeteor:IsFullyCastable() -- 等陨石进cd了再考虑用推波
    then
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        local targetloc = J.GetCenterOfUnits(nInRangeEnemy)
		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and not J.IsLocationInChrono(targetloc)
        and GetUnitToLocationDistance(bot, targetloc) <= nCastRange
        then
            return BOT_ACTION_DESIRE_HIGH, targetloc
		end
	end

    if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and (not isInLaningPhase or (isInLaningPhase and J.GetManaAfter(DeafeningBlast:GetManaCost()) > 0.5) or J.GetHP(botTarget) < 0.5)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_eul_cyclone')
        and (botTarget:HasModifier("modifier_invoker_chaos_meteor_burn") or (
            bot:IsFacingLocation(botTarget:GetLocation(), 30)
            and #nAllyHeroes >= #nEnemyHeroes
        ))
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
                return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, nDelay)
            end
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsRetreating(bot)
    and J.IsValidHero(nEnemyHeroes[1])
    and J.IsChasingTarget(nEnemyHeroes[1], bot)
    and bot:WasRecentlyDamagedByAnyHero(2)
    and J.IsInRange(bot, nEnemyHeroes[1], nCastRange - 300) then
        return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]:GetLocation()
	end

	--击杀
	for _, npcEnemy in pairs( nEnemyHeroes )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.Utils.IsWithoutSpellShield( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL )
		then
            -- if hero is already under control
            local nDelay = (GetUnitToUnitDistance(bot, npcEnemy) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(npcEnemy, nDelay)
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
    local abilityName

    if type(ability) == "string" and ability == 'Cataclysm' then
        abilityName = ability
    else
        abilityName = ability:GetName()
    end

    print(DotaTime()..' - Invoker going to invoke '..abilityName)

    if abilityName == Cataclysm or ability == Sunstrike then
        X.InvokeSpell(Exort, Exort, Exort)
    elseif ability == DeafeningBlast then
        X.InvokeSpell(Quas, Wex, Exort)
    elseif ability == ChaosMeteor then
        X.InvokeSpell(Exort, Exort, Wex)
    elseif ability == ForgeSpirit then
        X.InvokeSpell(Exort, Exort, Quas)
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
        print('[ERROR] Tried to invoke unsupported ability: '..abilityName)
		print("Stack Trace:", debug.traceback())
    end
    print(DotaTime()..' - Invoker tried to invoke '..abilityName)
end

function X.InvokeSpell(Orb1, Orb2, Orb3)
    bot:ActionPush_UseAbility(Invoke)
    bot:ActionPush_UseAbility(Orb1)
    bot:ActionPush_UseAbility(Orb2)
    bot:ActionPush_UseAbility(Orb3)
end

-- Check if the ability is ready to be invoked+casted, including those that are not displayed on the ability panel list.
-- First the bot should consider if it can cast the ability, if not, consider invoke the ability. Secondly, only if bot already has the ability on slots, the bot can then consider casting it - to avoid overridding/conflicting actions.
function X.IsAbilityReadyForInvoke(ability)
    return not X.IsAbilityAvailableOnSlots(ability) and X.CanAbilityPossiblyBeCasted(ability) and Invoke:IsFullyCastable()
end

-- check if the ability is actually castble at the moment without doing anything else.
function X.IsAbilityReadyForCast(ability)
    return X.IsAbilityAvailableOnSlots(ability) and ability:IsFullyCastable()
end

-- check if the ability could be casted if assuming it's available on slots right now, so we can consider invoke it or cast it.
function X.CanAbilityPossiblyBeCasted(_ability)
    local sAbility, tAbility
    if type(_ability) == "string" and _ability == 'Cataclysm' then
        sAbility = _ability
        tAbility = Sunstrike
    else
        sAbility = AbilityNameMap[_ability:GetName()]
        tAbility = _ability
    end

    if not X.HaveElementsTrainedToInvokeAbility(_ability) then return false end
    return tAbility:IsFullyCastable()

end

-- check if Invoker has trained the required basic elements for invoking the spell
function X.HaveElementsTrainedToInvokeAbility(ability)
    if type(ability) == "string" and ability == Cataclysm then
        return bot:HasScepter() and X.HaveElementsTrainedToInvokeAbility(Sunstrike)
    elseif ability == DeafeningBlast then
        return Quas:IsTrained() and Wex:IsTrained() and Exort:IsTrained()
    elseif ability == ChaosMeteor then
        return Wex:IsTrained() and Exort:IsTrained()
    elseif ability == ForgeSpirit then
        return Quas:IsTrained() and Exort:IsTrained()
    elseif ability == Sunstrike then
        return Exort:IsTrained()
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
    return not ability:IsHidden()
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
            local timePassedSinceLastCast = DotaTime() - AbilityCastedTimes[sAbility]
            -- if timePassedSinceLastCast < ability:GetCooldown() * (1 - detectP) or not AbilityCastedTimes[sAbility] == -100 then return end -- 防止重复记录. 防止重复记录。不精确，有时会漏
            -- 通过时间和mana使用情况来做双重验证是否用了技能
            if DotaTime() - AbilityCastedTimes[sAbility] <= 1 -- 一秒内仅记录一次
            or timePassedSinceLastCast >= ability:GetCooldown() * 0.5 -- 或者已经过了蛮久的时间了，这时候肯定不是重复记录而是某种原因能再次使用技能
            or AbilityCastedTimes[sAbility] == -100 then
                local deltaMana = previouslyRecordedMana - ability:GetManaCost()
                local manaRange = 20 -- 后期回蓝太快可能导致使用情况的计算错漏。设置太大值的话前中期碰到同时被消蓝的情况也可能有计算错漏
                if bot:GetMana() <= deltaMana + manaRange and bot:GetMana() >= deltaMana - manaRange then
                    if ability == Sunstrike and ability:GetCooldownTimeRemaining() > 50 then
                        sAbility = 'Cataclysm'
                    end
                    print(DotaTime()..' - Invoker just used ability ' .. sAbility .. ', reset the cooldown tracking time.')
                    AbilityCastedTimes[sAbility] = DotaTime()
                end
            end
        end
    end
    previouslyRecordedMana = bot:GetMana()
end

return X