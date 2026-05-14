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
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,2,1,2,6,2,3,3,3,6,1,1,1,6},--pos1,3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRandomItem_1 = RandomInt( 1, 9 ) > 6 and "item_black_king_bar" or "item_heavens_halberd"

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
	"item_double_branches",
	"item_quelling_blade",

	"item_magic_wand",
	"item_bracer",
	"item_power_treads",
	"item_ultimate_scepter",
	"item_black_king_bar",--
	"item_aghanims_shard",
	"item_sange_and_yasha",--
	"item_basher",
	"item_satanic",--
	"item_abyssal_blade",--
	"item_assault",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_travel_boots_2",--
}
sRoleItemsBuyList['pos_3'] = {
	"item_tango",
	"item_double_branches",
	"item_quelling_blade",

	"item_magic_wand",
	"item_bracer",
	"item_arcane_boots",
	"item_blade_mail",
	"item_crimson_guard",--
	"item_black_king_bar",--
	sRandomItem_1,--
	"item_aghanims_shard",
	"item_assault",--
	"item_ultimate_scepter_2",
	"item_wind_waker",--
	"item_moon_shard",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = {
	"item_tango",
	"item_double_branches",
	"item_quelling_blade",

	"item_bottle",
	"item_magic_wand",
	"item_bracer",
	"item_power_treads",
	"item_ultimate_scepter",
	"item_black_king_bar",--
	"item_aghanims_shard",
	"item_sange_and_yasha",--
	"item_assault",--
	"item_satanic",--
	"item_basher",
	"item_ultimate_scepter_2",
	"item_abyssal_blade",--
	"item_moon_shard",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_4'] = {
	'item_priest_outfit',
	"item_hand_of_midas",
	"item_mekansm",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
	"item_lotus_orb",
	"item_mjollnir",--
	"item_ultimate_scepter",
	"item_sheepstick",
	"item_mystic_staff",
	"item_ultimate_scepter_2",
	"item_shivas_guard",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
	'item_mage_outfit',
	"item_hand_of_midas",
	"item_glimmer_cape",

    "item_pavise",
	"item_pipe",--
    "item_solar_crest",--
	"item_lotus_orb",--
	"item_aghanims_shard",
	"item_spirit_vessel",--
	"item_ultimate_scepter",
	"item_shivas_guard",--
	"item_mystic_staff",
	"item_ultimate_scepter_2",
    "item_moon_shard",
	"item_sheepstick",--
}


X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_power_treads", "item_quelling_blade",

	"item_basher", "item_quelling_blade",
	"item_satanic", "item_magic_wand",
	"item_assault", "item_bracer",
	"item_assault", "item_bottle",
	"item_satanic", "item_bracer",
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

--[[

npc_dota_hero_bristleback

"Ability1"		"bristleback_viscous_nasal_goo"
"Ability2"		"bristleback_quill_spray"
"Ability3"		"bristleback_bristleback"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"bristleback_warpath"
"Ability10"		"special_bonus_movement_speed_20"
"Ability11"		"special_bonus_mp_regen_3"
"Ability12"		"special_bonus_hp_250"
"Ability13"		"special_bonus_unique_bristleback"
"Ability14"		"special_bonus_hp_regen_25"
"Ability15"		"special_bonus_unique_bristleback_2"
"Ability16"		"special_bonus_spell_lifesteal_15"
"Ability17"		"special_bonus_unique_bristleback_3"

modifier_bristleback_viscous_nasal_goo
modifier_bristleback_quillspray_thinker
modifier_bristleback_quill_spray
modifier_bristleback_quill_spray_stack
modifier_bristleback_bristleback
modifier_bristleback_warpath
modifier_bristleback_warpath_stack

--]]
local ViscousNasalGoo = bot:GetAbilityByName('bristleback_viscous_nasal_goo')
local QuillSpray = bot:GetAbilityByName('bristleback_quill_spray')
local Bristleback = bot:GetAbilityByName('bristleback_bristleback')
local Hairball = bot:GetAbilityByName('bristleback_hairball')
local Warpath = bot:GetAbilityByName('bristleback_warpath')

local ViscousNasalGooDesire, ViscousNasalGooTarget
local QuillSprayDesire
local HairballDesire, HairballTarget
local BristlebackDesire, BristlebackLocation
local WarpathDesire

local bAttacking = false
local botTarget, botHP
local nAllyHeroes, nEnemyHeroes

function X.SkillsComplement()
	bot = GetBot()

	if J.CanNotUseAbility(bot) then return end

	bAttacking = J.IsAttacking(bot)
	botHP = J.GetHP(bot)
	botTarget = J.GetProperTarget(bot)
	nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	HairballDesire, HairballTarget = X.ConsiderHairball()
	if HairballDesire > 0 then
		J.SetQueuePtToINT(bot, true)
		bot:ActionQueue_UseAbilityOnLocation(Hairball, HairballTarget)
		return
	end

	BristlebackDesire, BristlebackLocation = X.ConsiderBristleback()
	if BristlebackDesire > 0 then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnLocation(Bristleback, BristlebackLocation)
		return
	end

	ViscousNasalGooDesire, ViscousNasalGooTarget = X.ConsiderViscousNasalGoo()
    if ViscousNasalGooDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(ViscousNasalGoo, ViscousNasalGooTarget)
        return
    end

	WarpathDesire = X.ConsiderWarpath()
	if WarpathDesire > 0 then
		bot:Action_UseAbility(Warpath)
		return
	end

	QuillSprayDesire = X.ConsiderQuillSpray()
	if QuillSprayDesire > 0 then
		J.SetQueuePtToINT(bot, true)
		bot:ActionQueue_UseAbility(QuillSpray)
		return
	end
end

function X.ConsiderViscousNasalGoo()
	if not J.CanCastAbility(ViscousNasalGoo) then
		return BOT_ACTION_DESIRE_NONE, nil
	end
	for _, enemyHero in pairs(nEnemyHeroes) do
		if J.IsValidHero(enemyHero)
		and J.GetHP(bot) < 0.6
		and J.GetHP(bot) < J.GetHP(enemyHero)
		and J.IsInRange(bot, enemyHero, 900)
		and enemyHero:IsFacingLocation(bot:GetLocation(), 40)
		then
			return BOT_ACTION_DESIRE_NONE, nil
		end
	end

	local nCastRange = J.GetProperCastRange(false, bot, ViscousNasalGoo:GetCastRange())
	local nManaCost = ViscousNasalGoo:GetManaCost()
	local fManaAfter = J.GetManaAfter(nManaCost)
	local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {Bristleback, Hairball})

	if J.IsInTeamFight(bot, 1200) then
		if J.IsValidHero(nEnemyHeroes[1])
		and J.CanBeAttacked(nEnemyHeroes[1])
        and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
		and not nEnemyHeroes[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
		end
	end

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
		and J.CanBeAttacked(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
		if J.IsValidHero(nEnemyHeroes[1]) and J.IsInRange(bot, nEnemyHeroes[1], nCastRange) then
			if J.IsInTeamFight(bot, 1200) or not J.IsInLaningPhase() then
				return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
			end

			if  J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
            and J.CanCastOnTargetAdvanced(nEnemyHeroes[1])
            and bot:WasRecentlyDamagedByHero(nEnemyHeroes[1], 3.0)
			then
				if J.IsChasingTarget(nEnemyHeroes[1], bot)
				or (#nEnemyHeroes > #nAllyHeroes and nEnemyHeroes[1]:GetAttackTarget() == bot)
				then
					return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
				end
			end
		end

		for _, allyHero in pairs(nAllyHeroes) do
			if bot ~= allyHero
			and J.IsValidHero(allyHero)
			and J.IsRetreating(allyHero)
			and allyHero:WasRecentlyDamagedByAnyHero(3.0)
			and not J.IsSuspiciousIllusion(allyHero)
			and not J.IsRealInvisible(allyHero)
			and not J.IsRealInvisible(bot)
			then
				for _, enemyHero in ipairs(nEnemyHeroes) do
					if J.IsValidHero(enemyHero)
					and J.IsInRange(bot, enemyHero, nCastRange)
					and J.CanCastOnNonMagicImmune(enemyHero)
					and J.CanCastOnTargetAdvanced(enemyHero)
					and J.IsChasingTarget(enemyHero, allyHero)
					and not J.IsDisabled(enemyHero)
					then
						return BOT_ACTION_DESIRE_HIGH, enemyHero
					end
				end
			end
		end
	end

    if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
		and fManaAfter > 0.4
		and fManaAfter > fManaThreshold1
		and bAttacking
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
		and fManaAfter > 0.4
		and fManaAfter > fManaThreshold1
		and bAttacking
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderQuillSpray()
	if not J.CanCastAbility(QuillSpray) then
		return BOT_ACTION_DESIRE_NONE
	end

	if QuillSpray:GetAutoCastState() == true then
		QuillSpray:ToggleAutoCast()
	end

	local nRadius = QuillSpray:GetSpecialValueInt('radius')
	local fManaAfter = J.GetManaAfter(QuillSpray:GetManaCost())

	if J.IsInTeamFight(bot, 1200) then
		if J.IsValidHero(nEnemyHeroes[1]) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 100)
		and J.CanBeAttacked(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
		for _, enemyHero in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero)
			and J.CanBeAttacked(enemyHero)
            and J.IsInRange(bot, enemyHero, nRadius)
            and (bot:WasRecentlyDamagedByHero(enemyHero, 4.0) or enemyHero:HasModifier('modifier_bristleback_quill_spray'))
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	local nEnemyCreeps = bot:GetNearbyCreeps(nRadius, true)

	if J.IsPushing(bot )
    or J.IsDefending(bot)
    or J.IsGoingOnSomeone(bot)
    or J.IsFarming(bot)
	then
		if J.CanBeAttacked(nEnemyCreeps[1]) and fManaAfter > 0.25 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsFarming(bot) and fManaAfter > 0.25 then
		if J.IsValid(botTarget)
		and J.CanBeAttacked(botTarget)
		and botTarget:IsCreep()
		then
			if botTarget:GetHealth() > bot:GetAttackDamage() * 3 then
				return BOT_ACTION_DESIRE_HIGH
			end

			if J.IsValid(nEnemyCreeps[1]) and J.CanBeAttacked(nEnemyCreeps[1]) and #nEnemyCreeps >= 2 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsDoingRoshan(bot) and bAttacking then
		if J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot) and bAttacking then
		if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if fManaAfter > 0.9
	and not J.IsInLaningPhase()
	and bot:DistanceFromFountain() > 2400
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBristleback()
	if not J.CanCastAbility(Bristleback)
	or not bot:HasScepter()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = 350
	local nManaCost = Bristleback:GetManaCost()
	local fManaAfter = J.GetManaAfter(nManaCost)
	local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {Bristleback, Hairball})

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
        and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and not J.IsChasingTarget(bot, botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
		for _, enemyHero in ipairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero)
			and J.CanBeAttacked(enemyHero)
			and J.IsInRange(bot, enemyHero, nRadius)
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			and enemyHero:GetAttackTarget() == bot
			then
				local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
				local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
				if not (#nInRangeEnemy >= #nInRangeAlly + 2) then
					return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
				end
			end
		end
	end

	local nEnemyCreeps = bot:GetNearbyCreeps(800, true)

	if J.IsPushing(bot) and fManaAfter > fManaThreshold1 + 0.1 and bAttacking and #nAllyHeroes <= 1 and #nEnemyHeroes == 0 then
		for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 5) then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
	end

	if J.IsFarming(bot) and fManaAfter > fManaThreshold1 and bAttacking then
		for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 5)
				or (nLocationAoE.count >= 2 and creep:IsAncientCreep())
				then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
	end

    if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nRadius * 2)
		and fManaAfter > fManaThreshold1
		and bAttacking
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius * 2)
		and fManaAfter > fManaThreshold1
		and bAttacking
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderHairball()
	if not J.CanCastAbility(Hairball) then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, Hairball:GetCastRange())
    local nRadius = Hairball:GetSpecialValueInt('radius')
	local nManaCost = Hairball:GetManaCost()
	local fManaAfter = J.GetManaAfter(nManaCost)
	local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {Bristleback})

    if J.IsInTeamFight(bot, 1400) then
        local vAoELocation = J.GetAoeEnemyHeroLocation(bot, nCastRange, nRadius, 2)
        if vAoELocation ~= nil and fManaAfter > fManaThreshold1 then
            return BOT_ACTION_DESIRE_HIGH, vAoELocation
        end
    end

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidHero(botTarget)
		and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.CanCastOnNonMagicImmune(botTarget)
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		and fManaAfter > fManaThreshold1
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
		for _, enemyHero in ipairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero)
			and J.CanBeAttacked(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and J.IsInRange(bot, enemyHero, nCastRange)
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				if J.IsChasingTarget(enemyHero, bot)
				or (#nEnemyHeroes > #nAllyHeroes and enemyHero:GetAttackTarget() == bot)
				then
					return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + enemyHero:GetLocation()) / 2
				end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderWarpath()
	if not J.CanCastAbility(Warpath) then
		return BOT_ACTION_DESIRE_NONE
	end

	local nInRangeAlly = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 800)

	if J.IsInTeamFight(bot, 1200) then
		if #nInRangeEnemy > #nInRangeAlly or (botHP < 0.5 and bot:WasRecentlyDamagedByAnyHero(4.0)) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
		for _, enemyHero in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero) and J.IsInRange(bot, enemyHero, 500) and J.IsChasingTarget(enemyHero, bot) then
				if (J.GetTotalEstimatedDamageToTarget(nEnemyHeroes, bot, 8.0) > bot:GetHealth() * 1.15)
				or (#nEnemyHeroes > #nAllyHeroes and botHP < 0.4)
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X