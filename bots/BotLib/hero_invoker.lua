local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,1,2,1,2,1,2,1,2,3,3,3,3,3,3,3,2,2,1,1,1},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mid'] = {
    "item_tango",
    "item_double_branches",
    "item_double_circlet",

    "item_bracer",
    "item_urn_of_shadows",
    "item_boots",
    "item_magic_wand",
    "item_spirit_vessel",
    "item_hand_of_midas",
    "item_travel_boots",
    "item_aghanims_shard",
    "item_black_king_bar",--
    "item_octarine_core",--
    "item_sheepstick",--
    "item_ultimate_scepter",
    "item_refresher",--
    "item_wind_waker",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_priest'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mage'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_tank'] = sRoleItemsBuyList['outfit_carry']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
    "item_circlet",
    "item_bracer",
    "item_magic_wand",
    "item_spirit_vessel",
    "item_hand_of_midas",
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

local ComboDesire, ComboLocation

function X.SkillsComplement()
    if J.CanNotUseAbility(bot)
    then
        return
    end

    if J.HasItem(bot, 'item_octarine_core')
    then
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
    end

    ConsiderFirstSpell()

    ComboDesire, ComboLocation = X.ConsiderCombo()
    if ComboDesire > 0
    then
        bot:Action_ClearActions(false)

        if not IsAbilityActive(Tornado)
        then
            InvokeSpell(Wex, Wex, Quas)
        end

        if not IsAbilityActive(EMP)
        then
            InvokeSpell(Wex, Wex, Wex)
        end

        bot:ActionQueue_UseAbilityOnLocation(Tornado, ComboLocation)
        TornadoCastedTime = DotaTime()
        bot:ActionQueue_UseAbilityOnLocation(EMP, ComboLocation)
        EMPCastedTime = DotaTime()

        if not IsAbilityActive(ChaosMeteor)
        then
            InvokeSpell(Exort, Exort, Wex)
        end

        bot:ActionQueue_UseAbilityOnLocation(ChaosMeteor, ComboLocation)
        ChaosMeteorCastedTime = DotaTime()

        return
    end

    GhostWalkDesire = X.ConsiderGhostWalk()
    if GhostWalkDesire > 0
    then
        if not IsAbilityActive(GhostWalk)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Quas, Quas, Wex)
            bot:ActionQueue_UseAbility(GhostWalk)
        else
            bot:Action_UseAbility(GhostWalk)
        end

        GhostWalkCastedTime = DotaTime()
        return
    end

    TornadoDesire, TornadoLocation = X.ConsiderTornado()
    if TornadoDesire > 0
    then
        if not IsAbilityActive(Tornado)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Wex, Wex, Quas)
            bot:ActionQueue_UseAbilityOnLocation(Tornado, TornadoLocation)
        else
            bot:Action_UseAbilityOnLocation(Tornado, TornadoLocation)
        end

        TornadoCastedTime = DotaTime()
        return
    end

    EMPDesire, EMPLocation = X.ConsiderEMP()
    if EMPDesire > 0
    then
        if not IsAbilityActive(EMP)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Wex, Wex, Wex)
            bot:ActionQueue_UseAbilityOnLocation(EMP, EMPLocation)
        else
            bot:Action_UseAbilityOnLocation(EMP, EMPLocation)
        end

        EMPCastedTime = DotaTime()
        return
    end

    ChaosMeteorDesire, ChaosMeteorLocation = X.ConsiderChaosMeteor()
    if ChaosMeteorDesire > 0
    then
        if not IsAbilityActive(ChaosMeteor)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Exort, Exort, Wex)
            bot:ActionQueue_UseAbilityOnLocation(ChaosMeteor, ChaosMeteorLocation)
        else
            bot:Action_UseAbilityOnLocation(ChaosMeteor, ChaosMeteorLocation)
        end

        ChaosMeteorCastedTime = DotaTime()
        return
    end

    ColdSnapDesire, ColdSnapTarget = X.ConsiderColdSnap()
    if ColdSnapDesire > 0
    then
        if not IsAbilityActive(ColdSnap)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Quas, Quas, Quas)
            bot:ActionQueue_UseAbilityOnEntity(ColdSnap, ColdSnapTarget)
        else
            bot:Action_UseAbilityOnEntity(ColdSnap, ColdSnapTarget)
        end

        ColdSnapCastedTime = DotaTime()
        return
    end

    AlacrityDesire, AlacrityTarget = X.ConsiderAlacrity()
    if AlacrityDesire > 0
    then
        if not IsAbilityActive(Alacrity)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Wex, Wex, Exort)
            bot:ActionQueue_UseAbilityOnEntity(Alacrity, AlacrityTarget)
        else
            bot:Action_UseAbilityOnEntity(Alacrity, AlacrityTarget)
        end

        AlacrityCastedTime = DotaTime()
        return
    end

    SunstrikeDesire, SunstrikeLocation = X.ConsiderSunstrike()
    if SunstrikeDesire > 0
    then
        if not IsAbilityActive(Sunstrike)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Exort, Exort, Exort)
            if bot:HasScepter()
            then
                bot:ActionQueue_UseAbility(Sunstrike)
                bot:ActionQueue_UseAbility(Sunstrike)
            else
                bot:ActionQueue_UseAbilityOnLocation(Sunstrike, SunstrikeLocation)
            end
        else
            if bot:HasScepter()
            then
                bot:Action_UseAbility(Sunstrike)
                bot:Action_UseAbility(Sunstrike)
            else
                bot:Action_UseAbilityOnLocation(Sunstrike, SunstrikeLocation)
            end
        end

        SunstrikeCastedTime = DotaTime()
        return
    end

    DeafeningBlastDesire, DeafeningBlastLocation = X.ConsiderDeafeningBlast()
    if DeafeningBlastDesire > 0
    then
        if not IsAbilityActive(DeafeningBlast)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Quas, Wex, Exort)
            bot:ActionQueue_UseAbilityOnLocation(DeafeningBlast, DeafeningBlastLocation)
        else
            bot:Action_UseAbilityOnLocation(DeafeningBlast, DeafeningBlastLocation)
        end

        DeafeningBlastCastedTime = DotaTime()
        return
    end

    IceWallDesire = X.ConsiderIceWall()
    if IceWallDesire > 0
    then
        if not IsAbilityActive(IceWall)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Quas, Quas, Exort)
            bot:ActionQueue_UseAbility(IceWall)
        else
            bot:Action_UseAbility(IceWall)
        end

        IceWallCastedTime = DotaTime()
        return
    end

    ForgeSpiritDesire = X.ConsiderForgeSpirit()
    if ForgeSpiritDesire > 0
    then
        if not IsAbilityActive(ForgeSpirit)
        then
            bot:Action_ClearActions(false)
            InvokeSpell(Exort, Exort, Quas)
            bot:ActionQueue_UseAbility(ForgeSpirit)
        else
            bot:Action_UseAbility(ForgeSpirit)
        end

        ForgeSpiritCastedTime = DotaTime()
        return
    end
end

function X.ConsiderColdSnap()
    if not Quas:IsTrained()
    or (not ColdSnap:IsFullyCastable()
        or (not IsAbilityActive(ColdSnap)
            and DotaTime() < ColdSnapCastedTime + ColdSnapCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, ColdSnap:GetCastRange())
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and enemyHero:IsChanneling()
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.7 and bot:WasRecentlyDamagedByAnyHero(2.5)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderGhostWalk()
    if (not Quas:IsTrained() and not Wex:IsTrained())
    or (not GhostWalk:IsFullyCastable()
        or (not IsAbilityActive(GhostWalk)
            and DotaTime() < GhostWalkCastedTime + GhostWalkCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nEnemyTowers = bot:GetNearbyTowers(900, true)
    local nEnemyHeroes = bot:GetNearbyHeroes(900, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

    local timeOfDay = J.CheckTimeOfDay()
    local roshanRadiantLoc  = Vector(7625, -7511, 1092)
    local roshanDireLoc     = Vector(-7549, 7562, 1107)

	if	bot:DistanceFromFountain() > 600
    and nEnemyTowers ~= nil and #nEnemyTowers == 0
    and not bot:HasModifier('modifier_item_dustofappearance')
    and not bot:HasModifier('modifier_slardar_amplify_damage')
    and not bot:HasModifier('modifier_item_glimmer_cape')
    and not bot:IsInvulnerable()
    and not bot:IsMagicImmune()
	then
		if bot:IsSilenced()
        or bot:IsRooted()
        or J.IsStunProjectileIncoming(bot, bot:GetAttackRange())
		then
			return BOT_ACTION_DESIRE_HIGH
		end

        local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

		if (J.IsRetreating(bot)
		    and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH
		    and not bot:HasModifier('modifier_fountain_aura')
            and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and (#nInRangeEnemy > #nInRangeAlly)
                or J.GetHP(bot) < 0.8 and bot:WasRecentlyDamagedByAnyHero(2))
		or (botTarget == nil
			and nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
			and J.GetHP(bot) < 0.33 + ( 0.09 * #nEnemyHeroes ))
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if timeOfDay == 'day'
        and GetUnitToLocationDistance(bot, roshanRadiantLoc) > 3200
        then
            return BOT_ACTION_DESIRE_HIGH
        elseif timeOfDay == 'night'
        and GetUnitToLocationDistance(bot, roshanDireLoc) > 3200
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTornado()
    if (not Quas:IsTrained() and not Wex:IsTrained())
    or (not Tornado:IsFullyCastable()
        or (not IsAbilityActive(Tornado)
            and DotaTime() < TornadoCastedTime + TornadoCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, Tornado:GetCastRange())
    local nCastPoint = Tornado:GetCastPoint()
	local nRadius = Tornado:GetSpecialValueInt('area_of_effect')
	local nSpeed = Tornado:GetSpecialValueInt('travel_speed')
    local botTarget = J.GetProperTarget(bot)

    if  J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if nLocationAoE.count >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if  realEnemyCount ~= nil and #realEnemyCount >= 2
            and not IsTargetLocInBigUlt(nLocationAoE.targetloc)
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_eul_cyclone')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.45 and bot:WasRecentlyDamagedByAnyHero(3)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
        and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not nInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
        and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderEMP()
    if not Wex:IsTrained()
    or (not EMP:IsFullyCastable()
        or (not IsAbilityActive(EMP)
            and DotaTime() < EMPCastedTime + EMPCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, EMP:GetCastRange())
    local nCastPoint = EMP:GetCastPoint()
	local nRadius = EMP:GetSpecialValueInt('area_of_effect')
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

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

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
            if (botTarget:GetMana() / botTarget:GetMaxMana()) > 0.7
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.6 and bot:WasRecentlyDamagedByAnyHero(2.5)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
		then
            if (nInRangeEnemy[1]:GetMana() / nInRangeEnemy[1]:GetMaxMana()) > 0.51
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
            end
		end
	end

    if J.IsLaning(bot)
    then
        if  J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and nMana > 0.75
        and (botTarget:GetMana() / botTarget:GetMaxMana()) > 0.5
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderAlacrity()
    if (not Wex:IsTrained() and not Exort:IsTrained())
    or (not Alacrity:IsFullyCastable()
        or (not IsAbilityActive(Alacrity)
            and DotaTime() < AlacrityCastedTime + AlacrityCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, Alacrity:GetCastRange())
	local nAttackRange = bot:GetAttackRange()
    local botTarget = J.GetProperTarget(bot)

    local suitableTarget = nil
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
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 150, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanBeAttacked(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
            if suitableTarget ~= nil
            then
                if  suitableTarget == bot
                and J.IsInRange(bot, botTarget, nAttackRange)
                then
                    return BOT_ACTION_DESIRE_HIGH, suitableTarget
                end

                if  suitableTarget ~= bot
                and J.IsInRange(suitableTarget, botTarget, suitableTarget:GetAttackRange())
                and J.IsInRange(bot, suitableTarget, nCastRange)
                then
                    return BOT_ACTION_DESIRE_HIGH, suitableTarget
                end
            end
		end
	end

	if  (J.IsPushing(bot) or J.IsDefending(bot))
    and not bot:HasModifier('modifier_invoker_alacrity')
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(700, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
			return BOT_ACTION_DESIRE_HIGH, bot
		end

		local nEnemyTowers = bot:GetNearbyTowers(700, true)
		if  nEnemyTowers ~= nil and #nEnemyTowers > 0
        and suitableTarget ~= nil
        then
            if  suitableTarget == bot
            then
                return BOT_ACTION_DESIRE_HIGH, suitableTarget
            end

            if  suitableTarget ~= bot
            and J.IsInRange(suitableTarget, nEnemyTowers[1], suitableTarget:GetAttackRange())
            and J.IsInRange(bot, suitableTarget, nCastRange)
            then
                return BOT_ACTION_DESIRE_HIGH, suitableTarget
            end
		end
	end

    if  J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nAttackRange)

        if nNeutralCreeps ~= nil
            and (#nNeutralCreeps >= 3
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
    end

	if  J.IsDoingRoshan(bot)
    and suitableTarget ~= nil
	then
		if  J.IsRoshan(botTarget)
		and J.IsInRange(bot, botTarget, 700)
		then
			return BOT_ACTION_DESIRE_HIGH, suitableTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderChaosMeteor()
    if (not Wex:IsTrained() and not Exort:IsTrained())
    or (not ChaosMeteor:IsFullyCastable()
        or (not IsAbilityActive(ChaosMeteor)
            and DotaTime() < ChaosMeteorCastedTime + ChaosMeteorCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, ChaosMeteor:GetCastRange())
    local nCastPoint = ChaosMeteor:GetCastPoint()
	local nRadius = ChaosMeteor:GetSpecialValueInt('area_of_effect')
    local botTarget = J.GetProperTarget(bot)

	if  J.IsInTeamFight(bot, 1200)
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

	if  J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderSunstrike()
    if not Exort:IsTrained()
    or (not Sunstrike:IsFullyCastable()
        or (not IsAbilityActive(Sunstrike)
            and DotaTime() < SunstrikeCastedTime + SunstrikeCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nDelay = Sunstrike:GetSpecialValueFloat('delay')
    local nDamage = Sunstrike:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    if bot:HasScepter()
    then
        if J.IsInTeamFight(bot, 1200)
		then
			return BOT_ACTION_DESIRE_HIGH, 0
		end

		if J.IsGoingOnSomeone(bot)
		then
            local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
            local nInRangeEnemy = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)

			if  J.IsValidTarget(botTarget)
            and J.CanCastOnMagicImmune(botTarget)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
            and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
            and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
            and (botTarget:IsStunned()
                or botTarget:IsRooted()
                or botTarget:IsHexed()
                or botTarget:IsNightmared()
                or botTarget:HasModifier('modifier_enigma_black_hole_pull')
                or botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
                or J.IsTaunted(botTarget))
            and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
			then
				return BOT_ACTION_DESIRE_HIGH, 0
			end
		end
	else
		local nEnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
		for _, enemyHero in pairs(nEnemyHeroes)
        do
			if  J.IsValidHero(enemyHero)
			and J.CanCastOnMagicImmune(enemyHero)
			and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PURE)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
			end
		end

		if J.IsGoingOnSomeone(bot)
		then
            local nInRangeAlly = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
            local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

			if  J.IsValidTarget(botTarget)
            and J.CanCastOnMagicImmune(botTarget)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
            and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
            and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
            and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderForgeSpirit()
    if (not Quas:IsTrained() and not Exort:IsTrained())
    or (not ForgeSpirit:IsFullyCastable()
        or (not IsAbilityActive(ForgeSpirit)
            and DotaTime() < ForgeSpiritCastedTime + ForgeSpiritCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nAttackRange = bot:GetAttackRange()
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(700, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 700)
        and not J.IsInRange(bot, botTarget, nAttackRange)
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if  (J.IsPushing(bot) or J.IsDefending(bot))
    and not bot:HasModifier('modifier_invoker_alacrity')
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(700, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
			return BOT_ACTION_DESIRE_HIGH
		end

		local nEnemyTowers = bot:GetNearbyTowers(700, true)
		if  nEnemyTowers ~= nil and #nEnemyTowers > 0
        then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    if  J.IsFarming(bot)
    and nMana > 0.41
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nAttackRange + 75)

        if nNeutralCreeps ~= nil
            and (#nNeutralCreeps >= 3 or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(target)
        and J.IsInRange(bot, botTarget, nAttackRange)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderIceWall()
    if (not Quas:IsTrained() and not Exort:IsTrained())
    or (not IceWall:IsFullyCastable()
        or (not IsAbilityActive(IceWall)
            and DotaTime() < IceWallCastedTime + IceWallCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nAttackRange = bot:GetAttackRange()
    local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nAttackRange * 2, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nAttackRange + 150, true, BOT_MODE_NONE)

		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nAttackRange)
        and bot:IsFacingLocation(botTarget:GetLocation(), 30)
        and botTarget:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nAttackRange * 2, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nAttackRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.45 and bot:WasRecentlyDamagedByAnyHero(3)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
		then
            if  bot:IsFacingLocation(J.GetEscapeLoc(), 30)
            and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
            and J.IsRunning(nInRangeEnemy[1])
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDeafeningBlast()
    if (not Quas:IsTrained() and not Wex:IsTrained() and not Exort:IsTrained())
    or (not DeafeningBlast:IsFullyCastable()
        or (not IsAbilityActive(DeafeningBlast)
            and DotaTime() < DeafeningBlastCastedTime + DeafeningBlastCooldownTime))
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, DeafeningBlast:GetCastRange())
    local nCastPoint = DeafeningBlast:GetCastPoint()
	local nRadius = DeafeningBlast:GetSpecialValueInt('radius_end')
    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
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

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 150, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 100, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.45 and bot:WasRecentlyDamagedByAnyHero(3)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
        and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not nInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderCombo()
    if CanDoCombo()
    then
        local nCastRange = ChaosMeteor:GetCastRange()
        local nRadius = EMP:GetSpecialValueInt('area_of_effect')
        local botTarget = J.GetProperTarget(bot)

        if  J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

            if nLocationAoE.count >= 2
            then
                local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

                if  realEnemyCount ~= nil and #realEnemyCount >= 2
                and not IsTargetLocInBigUlt(nLocationAoE.targetloc)
                then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end

        if J.IsGoingOnSomeone(bot)
        then
            local nInRangeAlly = bot:GetNearbyHeroes(nCastRange + 150, false, BOT_MODE_NONE)
            local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange + bot:GetAttackRange(), true, BOT_MODE_NONE)

            if  J.IsValidTarget(botTarget)
            and J.CanCastOnNonMagicImmune(botTarget)
            and J.IsInRange(bot, botTarget, nCastRange)
            and not J.IsSuspiciousIllusion(botTarget)
            and not J.IsDisabled(botTarget)
            and not botTarget:HasModifier('modifier_brewmaster_storm_cyclone')
            and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
            and not botTarget:HasModifier('modifier_eul_cyclone')
            and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and nInRangeAlly ~= nil and nInRangeEnemy
            and #nInRangeAlly <= 1 and #nInRangeEnemy <= 2
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function CanDoCombo()
    if  Quas:IsTrained()
    and Wex:IsTrained()
    and Exort:IsTrained()
    and (Tornado:IsFullyCastable()
        or (not IsAbilityActive(Tornado)
            and DotaTime() > TornadoCastedTime + TornadoCooldownTime))
    and (EMP:IsFullyCastable()
        or (not IsAbilityActive(EMP)
            and DotaTime() > EMPCastedTime + EMPCooldownTime))
    and (not IsAbilityActive(ChaosMeteor)
        and DotaTime() > ChaosMeteorCastedTime + ChaosMeteorCooldownTime)
    then
        local nManaCost = Tornado:GetManaCost()
                        + EMP:GetManaCost()
                        + ChaosMeteor:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            return true
        end
    end

    return false
end

function IsTargetLocInBigUlt(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if  J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 300
		and (enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			or enemyHero:HasModifier('modifier_enigma_black_hole_pull'))
		then
			return true
		end
	end

	return false
end

--
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
end

function IsAbilityActive(ability)
    if ability:IsHidden()
    or not ability:IsTrained()
    then
        return false
    end

    return true
end

return X