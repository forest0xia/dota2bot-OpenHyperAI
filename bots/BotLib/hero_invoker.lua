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
						-- {2,1,2,1,2,1,2,1,2,3,3,3,3,3,3,3,2,2,1,1,1},--pos2
                        {3,1,3,1,2,3,3,1,3,1,3,2,3,2,2,2,2,2,1,1,1},--pos2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_2'] = {
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
    "item_octarine_core",--
    "item_sheepstick",--
    "item_ultimate_scepter",
    "item_refresher",--
    "item_wind_waker",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
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

local ColdSnapCooldownTime          = 20
local GhostWalkCooldownTime         = 35
local TornadoCooldownTime           = 30
local EMPCooldownTime               = 30
local AlacrityCooldownTime          = 17
local ChaosMeteorCooldownTime       = 55
local SunstrikeCooldownTime         = 25
local ForgeSpiritCooldownTime       = 30
local IceWallCooldownTime           = 25
local DeafeningBlastCooldownTime    = 40
local CataclysmCooldownTime         = 100

local ColdSnapCastedTime          = -100
local GhostWalkCastedTime         = -100
local TornadoCastedTime           = -100
local EMPCastedTime               = -100
local AlacrityCastedTime          = -100
local ChaosMeteorCastedTime       = -100
local SunstrikeCastedTime         = -100
local ForgeSpiritCastedTime       = -100
local IceWallCastedTime           = -100
local DeafeningBlastCastedTime    = -100
local CataclysmCastedTime         = -100


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

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    if bot:HasModifier(modifier_invoker_ghost_walk_self) and J.GetHP(bot) < 0.7 then return end

    botTarget = J.GetProperTarget(bot)
    TornadoLiftTime = Tornado:GetSpecialValueFloat('lift_duration')

    CheckForCooldownReductions()

    ConsiderFirstSpell()

    -- 预留技能; 预留球; 让没在cd的技能位置靠前
    X.ConsiderPreCast()


    ------- 尝试把连招串联起来，判断是否用了可以连招的前置技能 -------
    -- 如果前置技能进入cd，且距离使用它的时间刚刚过去（大招cd时间+delta）时间之内，则可以认为马上可以切下一个连招技能
    local deltaTime = 0.3
    
    if DotaTime() - TornadoCastedTime <= Invoke:GetCooldown() + deltaTime then
        ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
        if ChaosMeteorDesire > 0 then X.CastChaosMeteor(ChaosMeteorLocation) return end
        
        EMPDesire, EMPLocation = X.ConsiderEMP()
        if EMPDesire > 0 then  X.CastEMP(EMPLocation) return end

        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end
    end

    if DotaTime() - ChaosMeteorCastedTime <= Invoke:GetCooldown() + deltaTime then
        DeafeningBlastDesire, DeafeningBlastLocation = X.ConsiderDeafeningBlast()
        if DeafeningBlastDesire > 0 then X.CastDeafeningBlast(DeafeningBlastLocation) return end

        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end
    end

    if DotaTime() - ColdSnapCastedTime <= Invoke:GetCooldown() + deltaTime then
        TornadoDesire, TornadoLocation = X.ConsiderTornado()
        if TornadoDesire > 0 then X.CastTornado(TornadoLocation) return end

        ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
        if ChaosMeteorDesire > 0 then X.CastChaosMeteor(ChaosMeteorLocation) return end
        
        AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
        if AlacrityDesire > 0 then X.CastAlacrity(AlacrityTarget) return end
    end

    if DotaTime() - AlacrityCooldownTime <= Invoke:GetCooldown() + deltaTime then
        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end

        ForgeSpiritDesire = X.ConsiderForgeSpirit()
        if ForgeSpiritDesire > 0 then X.CastForgeSpirit() return end
    end

    if DotaTime() - ForgeSpiritCooldownTime <= Invoke:GetCooldown() + deltaTime then
        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end

        AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
        if AlacrityDesire > 0 then X.CastAlacrity(AlacrityTarget) return end
    end

    if DotaTime() - IceWallCooldownTime <= Invoke:GetCooldown() + deltaTime then
        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end

        AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
        if AlacrityDesire > 0 then X.CastAlacrity(AlacrityTarget) return end

        EMPDesire, EMPLocation = X.ConsiderEMP()
        if EMPDesire > 0 then  X.CastEMP(EMPLocation) return end
    end

    if DotaTime() - DeafeningBlastCastedTime <= Invoke:GetCooldown() + deltaTime then
        SunstrikeDesire, SunstrikeLocation = X.ConsiderSunstrike()
        if SunstrikeDesire > 0 then X.CastSunstrike(SunstrikeLocation) return end

        ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
        if ColdSnapDesire > 0 then  X.CastColdSnap(ColdSnapTarget) return end
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
end

function X.InvokeColdSnap()
    print("Invoker invoking ColdSnap")
    InvokeSpell(Quas, Quas, Quas)
end

function X.InvokeTornado()
    print("Invoker invoking Tornado")
    InvokeSpell(Wex, Wex, Quas)
end

function X.InvokeGhostWalk()
    print("Invoker invoking GhostWalk")
    InvokeSpell(Quas, Quas, Wex)
end

function X.InvokeIceWall()
    print("Invoker invoking IceWall")
    InvokeSpell(Quas, Quas, Exort)
end

function X.InvokeEMP()
    print("Invoker invoking EMP")
    InvokeSpell(Wex, Wex, Wex)
end

function X.InvokeAlacrity()
    print("Invoker invoking Alacrity")
    InvokeSpell(Wex, Wex, Exort)
end

function X.InvokeSunstrike()
    print("Invoker invoking Sunstrike")
    InvokeSpell(Exort, Exort, Exort)
end

function X.InvokeForgeSpirit()
    print("Invoker invoking ForgeSpirit")
    InvokeSpell(Exort, Exort, Quas)
end

function X.InvokeChaosMeteor()
    print("Invoker invoking ChaosMeteor")
    InvokeSpell(Exort, Exort, Wex)
end

function X.InvokeDeafeningBlast()
    print("Invoker invoking DeafeningBlast")
    InvokeSpell(Quas, Wex, Exort)
end

local lastTimeChangeModifierAbilities = 0

-- If no desire actions, get some abilities actived on the skill list so they can be casted as soon as needed later.
function X.ConsiderPreCast()

    -- temp don't consider pre cast if not all basic skills are trained.
    if not (Quas:IsTrained()
        and Wex:IsTrained()
        and Exort:IsTrained()) then
        return
    end

    -- reverse the abilities in slots to keep not-in-cd ability
    local abilityD = bot:GetAbilityInSlot(3)  -- First invoked slot
    local abilityF = bot:GetAbilityInSlot(4)  -- Second invoked slot
    if abilityD ~= nil and abilityF ~= nil
    and not abilityD:IsFullyCastable()
    and abilityF:IsFullyCastable()and Invoke:IsFullyCastable() then
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

    if DotaTime() - lastTimeChangeModifierAbilities > 1 then

        -- idle spells. Buggy. some conditions not seem to work properly
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


        if J.GetHP(bot) < 0.6 then
            if J.IsRetreating(bot) and (bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_exort_instance')) then
                bot:ActionQueue_UseAbility(Wex)
                bot:ActionQueue_UseAbility(Wex)
                bot:ActionQueue_UseAbility(Wex)
                bot:ActionQueue_Delay(0.1)
                lastTimeChangeModifierAbilities = DotaTime()
            elseif bot:HasModifier('modifier_invoker_wex_instance') or bot:HasModifier('modifier_invoker_exort_instance') then
                bot:ActionQueue_UseAbility(Quas)
                bot:ActionQueue_UseAbility(Quas)
                bot:ActionQueue_UseAbility(Quas)
                bot:ActionQueue_Delay(0.1)
                lastTimeChangeModifierAbilities = DotaTime()
            end
        elseif bot:HasModifier('modifier_invoker_quas_instance') or bot:HasModifier('modifier_invoker_wex_instance') then
            bot:ActionQueue_UseAbility(Exort)
            bot:ActionQueue_UseAbility(Exort)
            bot:ActionQueue_UseAbility(Exort)
            bot:ActionQueue_Delay(0.1)
            lastTimeChangeModifierAbilities = DotaTime()
        end
    end
end

-- function X.ConsiderCombo()
--     if not (Quas:IsTrained()
--         and Wex:IsTrained()
--         and Exort:IsTrained()) then
--         return BOT_ACTION_DESIRE_NONE, 0
--     end

--     local canInvoke_ColdSnap       = X.CanInvoke_ColdSnap()
--     local canInvoke_Tornado        = X.CanInvoke_Tornado()
--     local canInvoke_EMP            = X.CanInvoke_EMP()
--     local canInvoke_Alacrity       = X.CanInvoke_Alacrity()
--     local canInvoke_Sunstrike      = X.CanInvoke_Sunstrike()
--     local canInvoke_Cataclysm      = X.CanInvoke_Cataclysm()
--     local canInvoke_GhostWalk      = X.CanInvoke_GhostWalk()
--     local canInvoke_ChaosMeteor    = X.CanInvoke_ChaosMeteor()
--     local canInvoke_ForgeSpirit    = X.CanInvoke_ForgeSpirit()
--     local canInvoke_DeafeningBlast = X.CanInvoke_DeafeningBlast()
--     local canInvoke_IceWall        = X.CanInvoke_IceWall()

--     for _, combo in ipairs(InvokerCombos) do
--         local name, modifiers, abilities
--         name = combo[1]
--         modifiers = combo[2]
--         abilities = combo[3]

--         for _, ability in ipairs(abilities) do
--             if (ability == ColdSnap and not canInvoke_ColdSnap) 
--                 or (ability == Tornado and not canInvoke_Tornado) 
--                 or (ability == EMP and not canInvoke_EMP) 
--                 or (ability == Alacrity and not canInvoke_Alacrity)
--                 or (ability == Sunstrike and not canInvoke_Sunstrike)
--                 or (ability == Sunstrike and not canInvoke_Cataclysm)
--                 or (ability == GhostWalk and not canInvoke_GhostWalk)
--                 or (ability == ChaosMeteor and not canInvoke_ChaosMeteor)
--                 or (ability == ForgeSpirit and not canInvoke_ForgeSpirit)
--                 or (ability == DeafeningBlast and not canInvoke_DeafeningBlast)
--                 or (ability == IceWall and not canInvoke_IceWall) then
--                 name[2] = false
--             end
--         end
--         -- print("Invoker considering combo: "..name[1]..", available: "..tostring(name[2]))
--     end


--     --对线消耗或补刀
--     if J.IsLaning( bot )
--     then
--         --对线消耗
--         if ComboName_RightClick[2] then
--             X.CastForgeSpirit()
--             ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
--             if ColdSnapDesire > 0
--             then
--                 X.CastColdSnap(ColdSnapTarget)
--                 return
--             end
--             AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
--             if AlacrityDesire > 0
--             then
--                 X.CastAlacrity(AlacrityTarget)
--                 return
--             end
--         elseif ComboName_TEC[2] then
--             TornadoDesire, TornadoLocation = X.ConsiderTornado()
--             if TornadoDesire > 0
--             then
--                 X.CastTornado(TornadoLocation)
--                 return
--             end

--             EMPDesire, EMPLocation = X.ConsiderEMP()
--             if EMPDesire > 0
--             then
--                 X.CastEMP(EMPLocation)
--                 return
--             end

--             ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
--             if ColdSnapDesire > 0
--             then
--                 X.CastColdSnap(ColdSnapTarget)
--                 return
--             end
--         end
--     end


--     --打架时先手
--     if J.IsGoingOnSomeone( bot ) or J.IsInTeamFight(bot, 1200)
--     then
--         if ComboName_EulMB[2] then
--             print("Invoker considering combo: "..ComboName_EulMB[1])
--             ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
--             if ChaosMeteorDesire > 0
--             then
--                 X.CastChaosMeteor(ChaosMeteorLocation)
--                 return
--             end
--             DeafeningBlastDesire, DeafeningBlastLocation = X.ConsiderDeafeningBlast()
--             if DeafeningBlastDesire > 0
--             then
--                 X.CastDeafeningBlast(DeafeningBlastLocation)
--                 return
--             end
--             SunstrikeDesire, SunstrikeLocation = X.ConsiderSunstrike()
--             if SunstrikeDesire > 0
--             then
--                 X.CastSunstrike(SunstrikeLocation)
--                 return
--             end
--             ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
--             if ColdSnapDesire > 0
--             then
--                 X.CastColdSnap(ColdSnapTarget)
--                 return
--             end
--         elseif ComboName_RightClick[2] then
--             print("Invoker considering combo: "..ComboName_RightClick[1])
--             X.CastForgeSpirit()
--             ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
--             if ColdSnapDesire > 0
--             then
--                 X.CastColdSnap(ColdSnapTarget)
--                 return
--             end
--             AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
--             if AlacrityDesire > 0
--             then
--                 X.CastAlacrity(AlacrityTarget)
--                 return
--             end
--         elseif ComboName_TMB[2] then
--             print("Invoker considering combo: "..ComboName_TMB[1])
--             TornadoDesire, TornadoLocation = X.ConsiderTornado()
--             if TornadoDesire > 0
--             then
--                 X.CastTornado(TornadoLocation)
--                 return
--             end

--             ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
--             if ChaosMeteorDesire > 0
--             then
--                 X.CastChaosMeteor(ChaosMeteorLocation)
--                 return
--             end
--             DeafeningBlastDesire, DeafeningBlastLocation = X.ConsiderDeafeningBlast()
--             if DeafeningBlastDesire > 0
--             then
--                 X.CastDeafeningBlast(DeafeningBlastLocation)
--                 return
--             end
--         elseif ComboName_TEC[2] then
--             print("Invoker considering combo: "..ComboName_TEC[1])
--             TornadoDesire, TornadoLocation = X.ConsiderTornado()
--             if TornadoDesire > 0
--             then
--                 X.CastTornado(TornadoLocation)
--                 return
--             end
--             EMPDesire, EMPLocation = X.ConsiderEMP()
--             if EMPDesire > 0
--             then
--                 X.CastEMP(EMPLocation)
--                 return
--             end
--         elseif ComboName_FixedPosition[2] then
--             print("Invoker considering combo: "..ComboName_FixedPosition[1])
--             SunstrikeDesire, SunstrikeLocation = X.ConsiderSunstrike()
--             if SunstrikeDesire > 0
--             then
--                 X.CastSunstrike(SunstrikeLocation)
--                 return
--             end
--             ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
--             if ChaosMeteorDesire > 0
--             then
--                 X.CastChaosMeteor(ChaosMeteorLocation)
--                 return
--             end
--             DeafeningBlastDesire, DeafeningBlastLocation = X.ConsiderDeafeningBlast()
--             if DeafeningBlastDesire > 0
--             then
--                 X.CastDeafeningBlast(DeafeningBlastLocation)
--                 return
--             end

--         end
--     end



    -- if CanDoCombo()
    -- then
    --     local nCastRange = ChaosMeteor:GetCastRange()
    --     local nRadius = EMP:GetSpecialValueInt('area_of_effect')

    --     local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
    --     local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

    --     if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
    --     and not J.IsLocationInChrono(J.GetCenterOfUnits(nInRangeEnemy))
    --     then
    --         return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
    --     end
    -- end

--     return BOT_ACTION_DESIRE_NONE, 0
-- end

-- function CanDoCombo()
--     if  Quas:IsTrained()
--     and Wex:IsTrained()
--     and Exort:IsTrained()
--     and (Tornado:IsFullyCastable()
--         or (not IsAbilityActive(Tornado)
--             and DotaTime() > TornadoCastedTime + TornadoCooldownTime))
--     and (EMP:IsFullyCastable()
--         or (not IsAbilityActive(EMP)
--             and DotaTime() > EMPCastedTime + EMPCooldownTime))
--     and (not IsAbilityActive(ChaosMeteor)
--         and DotaTime() > ChaosMeteorCastedTime + ChaosMeteorCooldownTime)
--     then
--         local nManaCost = Tornado:GetManaCost()
--                         + EMP:GetManaCost()
--                         + ChaosMeteor:GetManaCost()

--         if bot:GetMana() >= nManaCost
--         then
--             return true
--         end
--     end

--     return false
-- end

function X.CastForgeSpirit()
    print(DotaTime()..' - Invoker going to cast ForgeSpirit')

    if not IsAbilityActive(ForgeSpirit)
    then
        X.InvokeForgeSpirit()
    end

    -- bot:Action_ClearActions(false)
    -- bot:ActionQueue_Delay(0.1)
    bot:Action_UseAbility(ForgeSpirit)

    print(DotaTime()..' - Invoker tried to cast ForgeSpirit')
    ForgeSpiritCastedTime = DotaTime()
end

function X.CastIceWall()
    print(DotaTime()..' - Invoker going to cast IceWall')
    if not IsAbilityActive(IceWall)
    then
        X.InvokeIceWall()
    end

    -- bot:Action_ClearActions(false)
    bot:Action_UseAbility(IceWall)

    print(DotaTime()..' - Invoker tried to cast IceWall')
    IceWallCastedTime = DotaTime()
end

function X.CastDeafeningBlast(DeafeningBlastLocation)
    print(DotaTime()..' - Invoker going to cast DeafeningBlast')
    if not IsAbilityActive(DeafeningBlast)
    then
        X.InvokeDeafeningBlast()
    end

    -- bot:Action_ClearActions(false)
    bot:Action_UseAbilityOnLocation(DeafeningBlast, DeafeningBlastLocation)
    print(DotaTime()..' - Invoker tried to cast DeafeningBlast')
    DeafeningBlastCastedTime = DotaTime()
end

function X.CastSunstrike(SunstrikeLocation)
    print(DotaTime()..' - Invoker going to cast Sunstrike')
    if not IsAbilityActive(Sunstrike)
    then
        X.InvokeSunstrike()
    end

    -- bot:Action_ClearActions(false)
    bot:Action_UseAbilityOnLocation(Sunstrike, SunstrikeLocation)

    print(DotaTime()..' - Invoker tried to cast Sunstrike')
    SunstrikeCastedTime = DotaTime()
end

function X.CastCataclysm()
    print(DotaTime()..' - Invoker going to cast Cataclysm')
    if bot:HasScepter()
    then
        if not IsAbilityActive(Sunstrike)
        then
            X.InvokeSunstrike()
        end
        -- bot:Action_ClearActions(false)
        bot:Action_UseAbilityOnLocation(Sunstrike, bot)
        
        print(DotaTime()..' - Invoker tried to cast Cataclysm')
        CataclysmCastedTime = DotaTime()
    end
end

function X.CastAlacrity(AlacrityTarget)
    print(DotaTime()..' - Invoker going to cast Alacrity')
    if not IsAbilityActive(Alacrity)
    then
        X.InvokeAlacrity()
    end
    -- bot:Action_ClearActions(false)
    bot:Action_UseAbilityOnEntity(Alacrity, AlacrityTarget)
    print(DotaTime()..' - Invoker tried to use Alacrity')

    AlacrityCastedTime = DotaTime()
end

function X.CastColdSnap(ColdSnapTarget)
    print(DotaTime()..' - Invoker going to cast ColdSnap')
    if not IsAbilityActive(ColdSnap)
    then
        X.InvokeColdSnap()
    end
    -- bot:Action_ClearActions(false)
    bot:Action_UseAbilityOnEntity(ColdSnap, ColdSnapTarget)
    print(DotaTime()..' - Invoker tried to use ColdSnap')

    ColdSnapCastedTime = DotaTime()
end

function X.CastChaosMeteor(ChaosMeteorLocation)
    print(DotaTime()..' - Invoker going to cast ChaosMeteor')
    if not IsAbilityActive(ChaosMeteor)
    then
        X.InvokeChaosMeteor()
    end
    -- bot:Action_ClearActions(false)
    bot:Action_UseAbilityOnLocation(ChaosMeteor, ChaosMeteorLocation)
    print(DotaTime()..' - Invoker tried to use ChaosMeteor')

    ChaosMeteorCastedTime = DotaTime()
end

function X.CastEMP(EMPLocation)
    print(DotaTime()..' - Invoker going to cast EMP')
    if not IsAbilityActive(EMP)
    then
        X.InvokeEMP()
    end

    -- bot:Action_ClearActions(false)
    bot:Action_UseAbilityOnLocation(EMP, EMPLocation)

    print(DotaTime()..' - Invoker tried to use EMP')
    EMPCastedTime = DotaTime()
end

function X.CastTornado(TornadoLocation)
    print(DotaTime()..' - Invoker going to cast Tornado')
    if not IsAbilityActive(Tornado)
    then
        X.InvokeTornado()
    end

    -- bot:Action_ClearActions(false)
    bot:Action_UseAbilityOnLocation(Tornado, TornadoLocation)
    print(DotaTime()..' - Invoker tried to use Tornado')
    TornadoCastedTime = DotaTime()
end

function X.CastGhostWalk()
    print(DotaTime()..' - Invoker going to cast GhostWalk')
    if not IsAbilityActive(GhostWalk)
    then
        X.InvokeGhostWalk()
    end

    -- bot:Action_ClearActions(false)
    bot:Action_UseAbility(GhostWalk)
    print(DotaTime()..' - Invoker tried to use GhostWalk')
    GhostWalkCastedTime = DotaTime()
end

function X.CanInvoke_ColdSnap()
    if not Quas:IsTrained()
    or (not ColdSnap:IsFullyCastable()
        or (not IsAbilityActive(ColdSnap)
            and (DotaTime() < ColdSnapCastedTime + ColdSnapCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderColdSnap()
    if not X.CanInvoke_ColdSnap()
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
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + castDeltaRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1400, false, BOT_MODE_NONE)

            if nInRangeEnemy ~= nil and #nInRangeEnemy <= 1 
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
        if nInRangeEnemy ~= nil and #nInRangeEnemy <= 2 then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
        and not J.IsTaunted(enemyHero)
		then
            return BOT_ACTION_DESIRE_HIGH, enemyHero, "对线消耗:"..J.Chat.GetNormName( enemyHero )
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1 then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

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

function X.CanInvoke_GhostWalk()
    if (not Quas:IsTrained() and not Wex:IsTrained())
    or (not GhostWalk:IsFullyCastable()
        or (not IsAbilityActive(GhostWalk)
            and (DotaTime() < GhostWalkCastedTime + GhostWalkCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderGhostWalk()
    if not X.CanInvoke_GhostWalk()
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

function X.CanInvoke_Tornado()
    if (not Quas:IsTrained() and not Wex:IsTrained())
    or (not Tornado:IsFullyCastable()
        or (not IsAbilityActive(Tornado)
            and (DotaTime() < TornadoCastedTime + TornadoCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderTornado()
    if not X.CanInvoke_Tornado()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, Tornado:GetCastRange())
    local nCastPoint = Tornado:GetCastPoint()
	local nRadius = Tornado:GetSpecialValueInt('area_of_effect')
	local nSpeed = Tornado:GetSpecialValueInt('travel_speed')
    local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint

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
		if  J.IsValidTarget(botTarget)
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
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy <= 2 and nInRangeEnemy[1] ~= nil then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end
		
        if enemyHero ~= nil and J.GetMP(bot) > 0.4
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

function X.CanInvoke_EMP()
    if not Wex:IsTrained()
    or (not EMP:IsFullyCastable()
        or (not IsAbilityActive(EMP)
            and (DotaTime() < EMPCastedTime + EMPCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderEMP()
    if not X.CanInvoke_EMP()
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
                    if DotaTime() > TornadoCastedTime + TornadoLiftTime - EMPDelay - nCastPoint
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
                    if DotaTime() > TornadoCastedTime + TornadoLiftTime - EMPDelay
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

function X.CanInvoke_Alacrity()
    if (not Wex:IsTrained() and not Exort:IsTrained())
    or (not Alacrity:IsFullyCastable()
        or (not IsAbilityActive(Alacrity)
            and (DotaTime() < AlacrityCastedTime + AlacrityCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderAlacrity()
    if not X.CanInvoke_Alacrity()
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
        if nInRangeEnemy ~= nil and #nInRangeEnemy <=2 then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

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

function X.CanInvoke_ChaosMeteor()
    if (not Wex:IsTrained() and not Exort:IsTrained())
    or (not ChaosMeteor:IsFullyCastable()
        or (not IsAbilityActive(ChaosMeteor)
            and (DotaTime() < ChaosMeteorCastedTime + ChaosMeteorCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderChaosMeteor()
    if not X.CanInvoke_ChaosMeteor()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, ChaosMeteor:GetCastRange())
    local nCastPoint = ChaosMeteor:GetCastPoint()
    local nLandTime = ChaosMeteor:GetSpecialValueFloat('land_time')
	local nRadius = ChaosMeteor:GetSpecialValueInt('area_of_effect')

	if J.IsGoingOnSomeone(bot) or J.IsLaning( bot )
	then
		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_item_aeon_disk_buff')
		then

            -- if hero is already under control
            local nDelay = nLandTime
            if botTarget:HasModifier(modifier_invoker_tornado) then
                if DotaTime() >= TornadoCastedTime + TornadoLiftTime - (nDelay + nCastPoint)
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                end
            elseif X.CheckTempModifiers(TempNonMovableModifierNames, botTarget, (nDelay + nCastPoint)) > 0 then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end


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
		end
	end

	--对线
	if J.IsLaning( bot )
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
        local enemyHero
        if nInRangeEnemy ~= nil and #nInRangeEnemy <=2 then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

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

    if  J.IsDoingTormentor(bot)
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

function X.CanInvoke_Cataclysm()
    if not bot:HasScepter() 
    or not Exort:IsTrained()
    or (not Sunstrike:IsFullyCastable()
        or (not IsAbilityActive(Sunstrike)
            and DotaTime() < SunstrikeCastedTime + SunstrikeCooldownTime)
        or (not IsAbilityActive(Sunstrike)
            and DotaTime() < CataclysmCastedTime + CataclysmCooldownTime))
    then
        return false
    end

    return true
end

function X.CheckTempModifiers(modifierNames, botTarget, nDelay)
    for _, mName in pairs(modifierNames)
    do
        if botTarget:HasModifier(mName) then
            local modifier = botTarget:GetModifierByName(mName)
            if modifier then
                local remaining = botTarget:GetModifierRemainingDuration(modifier)
                print("Target has modifier "..mName..", the remaining time: " .. remaining .. " seconds")
                if remaining ~= nil and (DotaTime() >= DotaTime() + remaining - nDelay )
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCataclysm()
    if not X.CanInvoke_Cataclysm()
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
                if DotaTime() >= TornadoCastedTime + TornadoLiftTime - (nDelay + nCastPoint)
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

function X.CanInvoke_Sunstrike()
    if not Exort:IsTrained()
    or (not Sunstrike:IsFullyCastable()
        or (not IsAbilityActive(Sunstrike)
            and (DotaTime() < SunstrikeCastedTime + SunstrikeCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderSunstrike()
    if not X.CanInvoke_Sunstrike()
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
                    if DotaTime() > TornadoCastedTime + TornadoLiftTime - nDelay - nCastPoint
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
        and enemyHero ~= nil and J.GetMP(bot) > 0.45
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

function X.CanInvoke_ForgeSpirit()
    if (not Quas:IsTrained() and not Exort:IsTrained())
    or (not ForgeSpirit:IsFullyCastable()
        or (not IsAbilityActive(ForgeSpirit)
            and (DotaTime() < ForgeSpiritCastedTime + ForgeSpiritCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderForgeSpirit()
    if not X.CanInvoke_ForgeSpirit()
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

function X.CanInvoke_IceWall()
    if (not Quas:IsTrained() and not Exort:IsTrained())
    or (not IceWall:IsFullyCastable()
        or (not IsAbilityActive(IceWall)
            and (DotaTime() < IceWallCastedTime + IceWallCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderIceWall()
    if not X.CanInvoke_IceWall()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nSpawnDistance = IceWall:GetSpecialValueInt('wall_place_distance')

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
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

function X.CanInvoke_DeafeningBlast()
    if (not Quas:IsTrained() and not Wex:IsTrained() and not Exort:IsTrained())
    or (not DeafeningBlast:IsFullyCastable()
        or (not IsAbilityActive(DeafeningBlast)
            and (DotaTime() < DeafeningBlastCastedTime + DeafeningBlastCooldownTime or not Invoke:IsFullyCastable())))
    then
        return false
    end

    return true
end

function X.ConsiderDeafeningBlast()
    if not X.CanInvoke_DeafeningBlast()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, DeafeningBlast:GetCastRange())
    local nCastPoint = DeafeningBlast:GetCastPoint()
    local nDamage = DeafeningBlast:GetSpecialValueInt('damage')
	local nRadius = DeafeningBlast:GetSpecialValueInt('radius_end')
    local nSpeed = DeafeningBlast:GetSpecialValueInt('travel_speed')
    if (nSpeed == nil) then
        nSpeed = 200
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

    -- if hero is already under control
    local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint

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

            if botTarget:HasModifier(modifier_invoker_tornado) then
                if DotaTime() >= TornadoCastedTime + TornadoLiftTime - nDelay
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
        if nInRangeEnemy ~= nil and #nInRangeEnemy <= 2 then enemyHero = nInRangeEnemy[1] else return BOT_ACTION_DESIRE_NONE, nil end

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

function ConsiderFirstSpell()
    if bot:GetLevel() == 1
    then
        if Quas:IsTrained()
            and not IsAbilityActive(ColdSnap)
        then
            InvokeSpell(Quas, Quas, Quas)
        elseif Wex:IsTrained()
            and not IsAbilityActive(EMP)
        then
            InvokeSpell(Wex, Wex, Wex)
        elseif Exort:IsTrained()
            and not IsAbilityActive(Sunstrike)
        then
            InvokeSpell(Exort, Exort, Exort)
        end

        return
    end
end

function InvokeSpell(Orb1, Orb2, Orb3)
    bot:ActionQueue_UseAbility(Orb1)
    bot:ActionQueue_UseAbility(Orb2)
    bot:ActionQueue_UseAbility(Orb3)
    bot:ActionQueue_UseAbility(Invoke)
    bot:ActionQueue_Delay(0.1)
end

function IsAbilityActive(ability)
    local abilityD = bot:GetAbilityInSlot(3)  -- First invoked slot
    local abilityF = bot:GetAbilityInSlot(4)  -- Second invoked slot

    if ability == abilityD or ability == abilityF then
        return true
    end

    if ability:IsHidden()
    or not ability:IsTrained() then
        return false
    end

    return true
end

local octarineCoreCooldownReductionsCheck = false
function CheckForCooldownReductions()
    if  J.HasItem(bot, 'item_octarine_core') and octarineCoreCooldownReductionsCheck == false then
        ColdSnapCooldownTime        = ColdSnapCooldownTime * 0.75
        GhostWalkCooldownTime       = GhostWalkCooldownTime * 0.75
        TornadoCooldownTime         = TornadoCooldownTime * 0.75
        EMPCooldownTime             = EMPCooldownTime * 0.75
        AlacrityCooldownTime        = AlacrityCooldownTime * 0.75
        ChaosMeteorCooldownTime     = ChaosMeteorCooldownTime * 0.75
        SunstrikeCooldownTime       = SunstrikeCooldownTime * 0.75
        ForgeSpiritCooldownTime     = ForgeSpiritCooldownTime * 0.75
        IceWallCooldownTime         = IceWallCooldownTime * 0.75
        DeafeningBlastCooldownTime  = DeafeningBlastCooldownTime * 0.75
        CataclysmCooldownTime       = CataclysmCooldownTime * 0.75
        octarineCoreCooldownReductionsCheck = true
    end

    if not J.HasItem(bot, 'item_octarine_core') then
        ColdSnapCooldownTime          = 20
        GhostWalkCooldownTime         = 35
        TornadoCooldownTime           = 30
        EMPCooldownTime               = 30
        AlacrityCooldownTime          = 17
        ChaosMeteorCooldownTime       = 55
        SunstrikeCooldownTime         = 25
        ForgeSpiritCooldownTime       = 30
        IceWallCooldownTime           = 25
        DeafeningBlastCooldownTime    = 40
        CataclysmCooldownTime         = 100
        octarineCoreCooldownReductionsCheck = false
    end

    -- 中立物品也得查
end

return X