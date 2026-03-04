local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						{--pos4
					['t25'] = {0, 10},
					['t20'] = {10, 0},
					['t15'] = {10, 0},
					['t10'] = {10, 0},
						},
						{--pos5
					['t25'] = {0, 10},
					['t20'] = {10, 0},
					['t15'] = {10, 0},
					['t10'] = {10, 0},
						},
}

local tAllAbilityBuildList = {
						{2,1,3,1,1,6,1,3,3,3,6,2,2,2,6},--pos4
						{2,1,3,1,1,6,1,3,3,3,6,2,2,2,6},--pos5
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_5"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
else
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
	"item_enchanted_mango",
	"item_blood_grenade",
	"item_priest_outfit",
	"item_force_staff",
	"item_mekansm",
	"item_glimmer_cape",--
	"item_aghanims_shard",
	"item_guardian_greaves",--
	"item_hurricane_pike",--
--	"item_wraith_pact",
	"item_shivas_guard",--
	"item_ultimate_scepter",
	"item_ultimate_scepter_2",
	"item_sheepstick",--
	"item_refresher",--
	"item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
    "item_double_tango",
    "item_faerie_fire",
    "item_enchanted_mango",
    "item_blood_grenade",

    "item_boots",
    "item_urn_of_shadows",
    "item_tranquil_boots",
	"item_pipe",
    "item_spirit_vessel",--
    "item_glimmer_cape",--
    "item_pavise",
    "item_solar_crest",--
    "item_boots_of_bearing",--
    "item_octarine_core",--
    "item_sheepstick",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
	'item_mage_outfit',
	"item_glimmer_cape",
	"item_boots_of_bearing",
	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_veil_of_discord",--
	"item_cyclone",
	"item_shivas_guard",--
	"item_refresher",--
	"item_ultimate_scepter_2",
	"item_sheepstick",--
	"item_wind_waker",--
	"item_moon_shard",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = {
	"item_crystal_maiden_outfit",
    "item_kaya",
	"item_force_staff",
	"item_kaya_and_sange",--
	"item_rod_of_atos",
	"item_aghanims_shard",
	"item_hurricane_pike",--
	"item_shivas_guard",--
	"item_octarine_core",--
	"item_gungir",--
	"item_moon_shard",
	"item_ultimate_scepter",
	"item_ultimate_scepter_2",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_1'] = {
	"item_crystal_maiden_outfit",
    "item_kaya",
	"item_force_staff",
	"item_kaya_and_sange",--
    "item_dagon_2",
	"item_rod_of_atos",
	"item_aghanims_shard",
	"item_dagon_5",--
	"item_hurricane_pike",--
	"item_shivas_guard",--
	-- "item_sheepstick",--
	"item_gungir",--
	"item_moon_shard",
	"item_ultimate_scepter",
	"item_ultimate_scepter_2",
	"item_travel_boots_2",--
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end



local CatchyLick        = bot:GetAbilityByName('largo_catchy_lick')
local Frogstomp         = bot:GetAbilityByName('largo_frogstomp')
local CroakOfGenius     = bot:GetAbilityByName('largo_croak_of_genius')
local AmphibianRhapsody = bot:GetAbilityByName('largo_amphibian_rhapsody')
local BullbellyBlitz    = bot:GetAbilityByName('largo_song_fight_song')
local HotfeetHustle     = bot:GetAbilityByName('largo_song_double_time')
local IslandElixir      = bot:GetAbilityByName('largo_song_good_vibrations')

local CatchyLickDesire, CatchyLickTarget
local FrogstompDesire, FrogstompLocation
local CroakOfGeniusDesire, CroakOfGeniusTarget
local AmphibianRhapsodyDesire

local songs = {
    strumTime = 0,
    song1 = BullbellyBlitz,
    song2 = BullbellyBlitz,
    wasInWindow = false,
}

local bAttacking = false
local botTarget, botHP
local nAllyHeroes, nEnemyHeroes

function X.SkillsComplement()
    if not bot:HasModifier('modifier_largo_amphibian_rhapsody_self') then
        songs.strumTime = 0
        songs.wasInWindow = false
    else
        if AmphibianRhapsody and AmphibianRhapsody:IsTrained() and songs.strumTime > 0 then
            local nStrumInterval = AmphibianRhapsody:GetSpecialValueInt('rhythm_interval')
            if DotaTime() >= songs.strumTime + nStrumInterval then
                songs.strumTime = songs.strumTime + nStrumInterval
            end
        end
    end

    if J.CanNotUseAbility(bot) then return end

	bAttacking = J.IsAttacking(bot)
    botHP = J.GetHP(bot)
    botTarget = J.GetProperTarget(bot)
    nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    CroakOfGeniusDesire, CroakOfGeniusTarget = X.ConsiderCroakOfGenius()
    if CroakOfGeniusDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(CroakOfGenius, CroakOfGeniusTarget)
        return
    end

    CatchyLickDesire, CatchyLickTarget = X.ConsiderCatchLick()
    if CatchyLickDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(CatchyLick, CatchyLickTarget)
        return
    end

    FrogstompDesire, FrogstompLocation = X.ConsiderFrogstomp()
    if FrogstompDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(Frogstomp, FrogstompLocation)
        return
    end

    AmphibianRhapsodyDesire = X.ConsiderAmphibianRhapsody()
    if AmphibianRhapsodyDesire > 0 then
        bot:Action_UseAbility(AmphibianRhapsody)
        return
    end
end

function X.ConsiderCatchLick()
    if not J.CanCastAbility(CatchyLick) then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = CatchyLick:GetCastRange()
    local nPullDistance = CatchyLick:GetSpecialValueInt('pull_distance')
    local nPullDistanceAlly = CatchyLick:GetSpecialValueInt('pull_distance_ally')
    local nDamage = CatchyLick:GetSpecialValueInt('damage')
    local nManaCost = CatchyLick:GetManaCost()
	local fManaAfter = J.GetManaAfter(nManaCost)
	local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {Frogstomp, CroakOfGenius})

	for _, allyHero in pairs(nAllyHeroes) do
		if J.IsValidHero(allyHero)
		and bot ~= allyHero
		and J.IsInRange(bot, allyHero, nPullDistanceAlly + 300)
		and not J.IsInRange(bot, allyHero, nPullDistanceAlly * 0.8)
		and not J.IsDisabled(allyHero)
		and not J.IsSuspiciousIllusion(allyHero)
		and not J.IsRealInvisible(allyHero)
		and not allyHero:IsChanneling()
		then
			if J.IsGoingOnSomeone(allyHero) then
				local allyHeroTarget = J.GetProperTarget(allyHero)
				if  J.IsValidHero(allyHeroTarget)
				and allyHeroTarget:IsFacingLocation(allyHeroTarget:GetLocation(), 15)
				and GetUnitToUnitDistance(allyHero, allyHeroTarget) > allyHero:GetAttackRange() + 50
				and GetUnitToUnitDistance(allyHero, allyHeroTarget) < allyHero:GetAttackRange() + 700
				and not J.IsSuspiciousIllusion(allyHeroTarget)
				and not allyHeroTarget:IsFacingLocation(allyHero:GetLocation(), 40)
				and #nAllyHeroes >= 3
				then
					local tResult = PointToLineDistance(allyHeroTarget:GetLocation(), allyHero:GetLocation(), bot:GetLocation())
					if tResult and tResult.within and tResult.distance <= 600 then
						return BOT_ACTION_DESIRE_HIGH, allyHero
					end

					tResult = PointToLineDistance(bot:GetLocation(), allyHero:GetLocation(), allyHeroTarget:GetLocation())
					if tResult and tResult.within and tResult.distance <= 600 then
						return BOT_ACTION_DESIRE_HIGH, allyHero
					end
				end
			end

			local nInRangeEnemy = J.GetEnemiesNearLoc(allyHero:GetLocation(), 900)
			if  J.IsRetreating(allyHero)
			and #nInRangeEnemy > 0
			and allyHero:IsFacingLocation(J.GetTeamFountain(), 30)
			and allyHero:DistanceFromFountain() > 1200
			and allyHero:WasRecentlyDamagedByAnyHero(5.0)
			then
				local tResult = PointToLineDistance(J.GetTeamFountain(), allyHero:GetLocation(), bot:GetLocation())
				if tResult and tResult.within and tResult.distance <= 600 then
					return BOT_ACTION_DESIRE_HIGH, allyHero
				end
			end

			if J.IsStuck(allyHero) then
				return BOT_ACTION_DESIRE_HIGH, allyHero
			end
		end

        if  J.IsValidHero(allyHero)
        and J.IsInRange(bot, allyHero, nCastRange)
        and not allyHero:IsMagicImmune()
        and not allyHero:IsIllusion()
        and not allyHero:IsChanneling()
        and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and allyHero:WasRecentlyDamagedByAnyHero(2.0)
        then
            -- dispel some stuff
            local bIsGoingOnSomeone = J.IsGoingOnSomeone(allyHero)
            local bIsRetreating = J.IsRetreating(allyHero)
            if (J.GetModifierTime(allyHero, 'modifier_bane_nightmare') > 2)
            or (J.GetModifierTime(allyHero, 'modifier_axe_battle_hunger') > 2 and bIsRetreating)
            or (J.GetModifierTime(allyHero, 'modifier_bristleback_viscous_nasal_goo') > 2 and J.IsRunning(allyHero))
            or (J.GetModifierTime(allyHero, 'modifier_earth_spirit_magnetize') > 2 and not bIsGoingOnSomeone)
            or (J.GetModifierTime(allyHero, 'modifier_phoenix_fire_spirit_burn') > 2 and bIsGoingOnSomeone)
            or (J.GetModifierTime(allyHero, 'modifier_life_stealer_open_wounds') > 2 and bIsRetreating)
            or (J.GetModifierTime(allyHero, 'modifier_faceless_void_time_dilation_slow') > 2 and bIsGoingOnSomeone)
            or (J.GetModifierTime(allyHero, 'modifier_warlock_fatal_bonds') > 2)
            or (J.GetModifierTime(allyHero, 'modifier_arc_warden_flux') > 2 and bIsRetreating)
            or (J.GetModifierTime(allyHero, 'modifier_venomancer_venomous_gale') > 2 and bIsRetreating)
            or (J.GetModifierTime(allyHero, 'modifier_stunned') > 2)
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
        end
	end

    for _, enemyHero in pairs(nEnemyHeroes) do
        if J.IsValidHero(enemyHero)
        and J.CanBeAttacked(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            -- dispel some stuff
            if botHP < 0.9 then
                if (J.GetModifierTime(enemyHero, 'modifier_earthshaker_enchant_totem') > 2)
                or (J.GetModifierTime(enemyHero, 'modifier_legion_commander_overwhelming_odds') > 2)
                or (J.GetModifierTime(enemyHero, 'modifier_legion_commander_press_the_attack') > 2)
                or (J.GetModifierTime(enemyHero, 'modifier_ogre_magi_bloodlust') > 2)
                or (J.GetModifierTime(enemyHero, 'modifier_shredder_reactive_armor_bomb') > 2)
                or (J.GetModifierTime(enemyHero, 'modifier_ursa_overpower') > 2)
                or (J.GetModifierTime(enemyHero, 'modifier_necrolyte_sadist_active') > 2)
                or (J.GetModifierTime(enemyHero, 'modifier_pugna_decrepify') > 2)
                or (J.GetModifierTime(enemyHero, 'modifier_warlock_shadow_word') > 2)
                or (J.GetModifierTime(enemyHero, 'modifier_abaddon_aphotic_shield') > 2)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsInRange(bot, botTarget, nPullDistance)
        and J.IsChasingTarget(bot, botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	local nEnemyCreeps = bot:GetNearbyCreeps(Min(nCastRange + 300, 1600), true)

    if J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot) then
        if #nAllyHeroes <= 2 and #nEnemyHeroes == 0 and bAttacking and fManaAfter > fManaThreshold1 + 0.1 then
            local hTarget = nil
            local hTargetScore = 0
            for _, creep in pairs(nEnemyCreeps) do
                if  J.IsValid(creep)
                and J.CanBeAttacked(creep)
                and not J.IsRoshan(creep)
                and not J.IsTormentor(creep)
                and not J.IsOtherAllysTarget(creep)
                and creep:GetHealth() > 0
                then
                    local creepScore = creep:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_MAGICAL) / creep:GetHealth()
                    if creepScore > hTargetScore then
                        hTarget = creep
                        hTargetScore = creepScore
                    end
                end
            end

            if hTarget then
                return BOT_ACTION_DESIRE_HIGH, hTarget
            end
        end
    end

	if J.IsLaning(bot) and J.IsInLaningPhase() and fManaAfter > fManaThreshold1 then
		for _, creep in pairs(nEnemyCreeps) do
			if  J.IsValid(creep)
            and J.CanBeAttacked(creep)
            and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
			and (J.IsCore(bot) or not J.IsThereCoreInLocation(creep:GetLocation(), 650))
			and not J.IsOtherAllysTarget(creep)
			then
                local sCreepName = creep:GetUnitName()
                if string.find(sCreepName, 'ranged') then
                    local nLocationAoE = bot:FindAoELocation(true, true, creep:GetLocation(), 0, 600, 0, 0)
                    if nLocationAoE.count > 0 or J.IsUnitTargetedByTower(creep, false) then
                        return BOT_ACTION_DESIRE_HIGH, creep
                    end
                end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderFrogstomp()
    if not J.CanCastAbility(Frogstomp) then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = Frogstomp:GetCastRange()
    local nRadius = Frogstomp:GetSpecialValueInt('radius')
    local nManaCost = Frogstomp:GetManaCost()
	local fManaAfter = J.GetManaAfter(nManaCost)
	local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {CatchyLick, CroakOfGenius})

    for _, enemyHero in pairs(nEnemyHeroes) do
        if J.IsValidHero(enemyHero)
        and J.CanBeAttacked(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and enemyHero:IsChanneling()
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
        end
    end

    if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.CanCastOnNonMagicImmune(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            if J.IsDisabled(botTarget)
            or botTarget:GetCurrentMovementSpeed() <= 250
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and J.IsRunning(bot) then
        for _, enemyHero in pairs(nEnemyHeroes) do
            if  J.IsValidHero(enemyHero)
			and J.CanBeAttacked(enemyHero)
            and J.IsInRange(bot, enemyHero, nRadius * 2)
            and not J.IsInRange(bot, enemyHero, nRadius * 0.8)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsDisabled(enemyHero)
            and bot:WasRecentlyDamagedByHero(enemyHero, 3.0)
            then
                return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + enemyHero:GetLocation()) / 2
            end
        end
	end

    local nEnemyCreeps = bot:GetNearbyCreeps(Min(nCastRange + 300, 1600), true)

    if J.IsPushing(bot) and #nAllyHeroes <= 2 and bAttacking and fManaAfter > fManaThreshold1 and #nEnemyHeroes == 0 then
        for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 4) then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
    end

    if J.IsDefending(bot) and bAttacking and fManaAfter > fManaThreshold1 then
        for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 4)
                or (nLocationAoE.count >= 3 and string.find(creep:GetUnitName(), 'upgraded'))
                then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
    end

    if J.IsFarming(bot) and bAttacking and fManaAfter > fManaThreshold1 then
        for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 3)
                or (nLocationAoE.count >= 2 and creep:IsAncientCreep())
                or (nLocationAoE.count >= 1 and creep:GetHealth() >= 550)
                then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
    end

    if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and bAttacking
        and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and bAttacking
        and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderCroakOfGenius()
    if not J.CanCastAbility(CroakOfGenius) then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = CroakOfGenius:GetCastRange()

    local hTarget = nil
    local hTargetDamage = 0
    for _, allyHero in pairs(nAllyHeroes) do
        if J.IsValidHero(allyHero)
        and J.IsInRange(bot, allyHero, nCastRange + 300)
        and J.IsGoingOnSomeone(allyHero)
        and not allyHero:IsIllusion()
        and not allyHero:IsSilenced()
        and not allyHero:HasModifier('modifier_doom_bringer_doom_aura_enemy')
        and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not allyHero:HasModifier('modifier_largo_croak_of_genius_buff')
        and not allyHero:HasModifier('modifier_silencer_curse_of_the_silent')
        and not allyHero:HasModifier('modifier_teleporting')
        then
            local allyHeroTarget = J.GetProperTarget(allyHero)
            if  J.IsValidHero(allyHeroTarget)
            and J.CanBeAttacked(allyHeroTarget)
            and not J.IsSuspiciousIllusion(allyHeroTarget)
            then
                local allyHeroDamage = allyHero:GetEstimatedDamageToTarget(true, allyHeroTarget, 5.0, DAMAGE_TYPE_MAGICAL)
                if allyHeroDamage > hTargetDamage then
                    hTarget = allyHero
                    hTargetDamage = allyHeroDamage
                end
            end
        end
    end

    if hTarget then
        return BOT_ACTION_DESIRE_HIGH, hTarget
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

local songs__ = {BullbellyBlitz, HotfeetHustle, IslandElixir}
function X.ConsiderAmphibianRhapsody()
    if not J.CanCastAbility(AmphibianRhapsody) then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = AmphibianRhapsody:GetSpecialValueInt('radius')
    local bCanPlayDouble = AmphibianRhapsody:GetSpecialValueInt('double_song') > 0
    local fManaThreshold1 = J.GetManaThreshold(bot, 150, {CatchyLick, Frogstomp, CroakOfGenius})
    local botMP = J.GetMP(bot)

    local bIsToggled = AmphibianRhapsody:GetToggleState()

    repeat
          songs.song1 = songs__[RandomInt(1, 3)]
          songs.song2 = songs__[RandomInt(1, 3)]
    until songs.song1 ~= songs.song2

    if bCanPlayDouble and botMP > fManaThreshold1 then
        if J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200) then
            for _, enemyHero in pairs(nEnemyHeroes) do
                if  J.IsValidHero(enemyHero)
                and J.CanBeAttacked(enemyHero)
                and J.IsInRange(bot, enemyHero, nRadius)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
                and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    if not bIsToggled then
                        return BOT_ACTION_DESIRE_HIGH
                    else
                        X.Strum(songs.song1, songs.song2)
                        return BOT_ACTION_DESIRE_NONE
                    end
                end
            end
        end
    end

    for _, allyHero in pairs(nAllyHeroes) do
        if  J.IsValidHero(allyHero)
        and J.IsInRange(bot, allyHero, nRadius)
        and not allyHero:IsIllusion()
        and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not allyHero:HasModifier('modifier_teleporting')
        then
            local allyHeroHp = J.GetHP(allyHero)
            local allyTarget = J.GetProperTarget(allyHero)

            if J.IsGoingOnSomeone(allyHero) and bot ~= allyHero then
                if  J.IsValidHero(allyTarget)
                and J.CanBeAttacked(allyTarget)
                and J.IsInRange(allyHero, allyTarget, Max(allyHero:GetAttackRange(), 800))
                and not J.IsSuspiciousIllusion(allyTarget)
                then
                    if not J.CanCastAbility(Frogstomp) then
                        if botMP > fManaThreshold1 + 0.1 then
                            if not bIsToggled then
                                return BOT_ACTION_DESIRE_HIGH
                            else
                                if (J.IsChasingTarget(allyHero, allyTarget))
                                or (J.IsInTeamFight(bot, 1200) and allyHero:WasRecentlyDamagedByAnyHero(2.0))
                                or (allyHero:GetCurrentMovementSpeed() <= 250)
                                then
                                    X.Strum(HotfeetHustle, nil)
                                elseif allyHeroHp < 0.55 and X.IsGoodToHeal(allyHero) then
                                    X.Strum(IslandElixir, nil)
                                else
                                    X.Strum(BullbellyBlitz, nil)
                                end

                                return BOT_ACTION_DESIRE_NONE
                            end
                        end
                    end
                end
            end

            if not J.IsRealInvisible(bot) then
                if (J.IsRetreating(allyHero) and allyHeroHp < 0.65 and not J.CanCastAbility(Frogstomp)) then
                    if botMP > fManaThreshold1 + 0.1 then
                        if not bIsToggled then
                            return BOT_ACTION_DESIRE_HIGH
                        else
                            if allyHero:GetCurrentMovementSpeed() <= 250 and not allyHero:IsRooted() then
                                X.Strum(HotfeetHustle, nil)
                            else
                                if X.IsGoodToHeal(allyHero) then
                                    X.Strum(IslandElixir, nil)
                                end
                            end

                            return BOT_ACTION_DESIRE_NONE
                        end
                    end
                end

                if allyHeroHp < 0.5 and X.IsGoodToHeal(allyHero) then
                    if botMP > fManaThreshold1 + 0.1 then
                        if not bIsToggled then
                            return BOT_ACTION_DESIRE_HIGH
                        else
                            X.Strum(IslandElixir, nil)
                        end

                        return BOT_ACTION_DESIRE_NONE
                    end
                end
            end

            if bot ~= allyHero and J.IsCore(allyHero) and botMP > fManaThreshold1 + 0.1 then
                if J.IsDoingRoshan(allyHero) and J.IsDoingRoshan(bot) then
                    if  J.IsRoshan(allyTarget)
                    and J.CanBeAttacked(allyTarget)
                    and J.IsInRange(allyHero, allyTarget, 1200)
                    then
                        if not bIsToggled and J.IsAttacking(allyHero) then
                            return BOT_ACTION_DESIRE_HIGH
                        else
                            X.Strum(BullbellyBlitz, nil)
                        end

                        return BOT_ACTION_DESIRE_NONE
                    end
                end

                if J.IsDoingTormentor(allyHero) and J.IsDoingTormentor(bot) then
                    if  J.IsTormentor(allyTarget)
                    and J.IsInRange(allyHero, allyTarget, 1200)
                    then
                        if not bIsToggled and J.IsAttacking(allyHero) then
                            return BOT_ACTION_DESIRE_HIGH
                        else
                            if bCanPlayDouble then
                                X.Strum(BullbellyBlitz, IslandElixir)
                            else
                                X.Strum(BullbellyBlitz, nil)
                            end
                        end

                        return BOT_ACTION_DESIRE_NONE
                    end
                end
            end
        end
    end

	if bIsToggled and math.floor(DotaTime()) % 2 == 0 then
		return BOT_ACTION_DESIRE_HIGH
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.IsGoodToHeal(hUnit)
    return  not hUnit:HasModifier('modifier_abaddon_borrowed_time')
        and not hUnit:HasModifier('modifier_doom_bringer_doom_aura_enemy')
        and not hUnit:HasModifier('modifier_ice_blast')
        and not hUnit:HasModifier('modifier_necrolyte_reapers_scythe')
        and hUnit:GetUnitName() ~= 'npc_dota_hero_medusa'
        and hUnit:GetUnitName() ~= 'npc_dota_hero_huskar'
end

function X.Strum(song1, song2)
    local fGracePeriod = AmphibianRhapsody:GetSpecialValueFloat('rhythm_grace_period')
    local now = DotaTime()

    local inWindow = (songs.strumTime == 0)
                  or ((now >= songs.strumTime - fGracePeriod)) and (now <= songs.strumTime + fGracePeriod)

    if inWindow and not songs.wasInWindow then
        if song1 and song2 == nil then
            bot:Action_UseAbility(song1)
            if songs.strumTime == 0 then songs.strumTime = DotaTime() end
        elseif song1 and song2 and song1 ~= song2 then
            bot:ActionPush_UseAbility(song1)
            bot:ActionPush_UseAbility(song2)
            if songs.strumTime == 0 then songs.strumTime = DotaTime() end
        end
    end

    songs.wasInWindow = inWindow
end

return X
