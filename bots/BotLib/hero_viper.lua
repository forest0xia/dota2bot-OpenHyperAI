----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						{--pos2
							['t25'] = {0, 10},
							['t20'] = {10, 0},
							['t15'] = {10, 0},
							['t10'] = {0, 10},
						},
						{--pos3
							['t25'] = {0, 10},
							['t20'] = {10, 0},
							['t15'] = {10, 0},
							['t10'] = {10, 0},
						}
}

local tAllAbilityBuildList = {
						{1,3,1,2,1,6,1,3,2,3,6,2,3,2,6},--pos2
						{1,3,1,3,1,6,1,2,3,3,6,2,2,2,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "pos_2"
then 
	nAbilityBuildList = tAllAbilityBuildList[1]
	nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList[1] )
else
	nAbilityBuildList = tAllAbilityBuildList[2]
	nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList[2] )
end

local sUtility = {"item_heavens_halberd", "item_lotus_orb", "item_pipe"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
	"item_faerie_fire",
	"item_clarity",
	"item_double_branches",
	"item_circlet",
	"item_slippers",

	"item_wraith_band",
	"item_magic_wand",
	"item_power_treads",
	"item_mage_slayer",--
	"item_dragon_lance",
	"item_manta",--
	"item_hurricane_pike",--
	"item_aghanims_shard",
	"item_kaya_and_sange",--
	"item_travel_boots",
	"item_shivas_guard",--
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_2'] = {
	"item_tango",
	"item_faerie_fire",
	"item_clarity",
	"item_double_branches",
	"item_circlet",
	"item_slippers",

	"item_bottle",
	"item_wraith_band",
	"item_magic_wand",
	"item_power_treads",
	"item_mage_slayer",--
	"item_dragon_lance",
	"item_manta",--
	"item_hurricane_pike",--
	"item_aghanims_shard",
	"item_kaya_and_sange",--
	"item_travel_boots",
	"item_shivas_guard",--
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_3'] = {
	"item_tango",
	"item_double_branches",
	"item_enchanted_mango",
	"item_double_circlet",

	"item_double_wraith_band",
	"item_boots",
	"item_magic_wand",
	"item_power_treads",
	"item_mage_slayer",--
	"item_dragon_lance",
	nUtility,--
	"item_black_king_bar",--
	"item_aghanims_shard",
	"item_hurricane_pike",--
	"item_sheepstick",--
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos2SellList = {
    "item_bottle",
    "item_wraith_band",
    "item_magic_wand",
}

Pos3SellList = {
    "item_wraith_band",
    "item_magic_wand",
}

X['sSellList'] = {}

if sRole == "pos_2"
then
    X['sSellList'] = Pos2SellList
else
    X['sSellList'] = Pos3SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )


X['bDeafaultAbility'] = true
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local PoisonAttack = bot:GetAbilityByName('viper_poison_attack')
local NetherToxin = bot:GetAbilityByName('viper_nethertoxin')
-- local CorrosiveSkin = bot:GetAbilityByName('viper_corrosive_skin')
local Nosedive = bot:GetAbilityByName( 'viper_nose_dive' )
local ViperStrike = bot:GetAbilityByName('viper_viper_strike')

local PoisonAttackDesire, PoisonAttackTarget
local NetherToxinDesire, NetherToxinLocation
local NosediveDesire, NosediveLocation
local ViperStrikeDesire, ViperStrikeTarget

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	botTarget = J.GetProperTarget(bot)

	ViperStrikeDesire, ViperStrikeTarget = X.ConsiderViperStrike()
	if ViperStrikeDesire > 0
	then
		if J.HasPowerTreads(bot)
		then
			J.SetQueuePtToINT(bot, true)
			bot:ActionQueue_UseAbilityOnEntity(ViperStrike, ViperStrikeTarget)
		else
			bot:Action_UseAbilityOnEntity(ViperStrike, ViperStrikeTarget)
		end

		return
	end

	NosediveDesire, NosediveLocation = X.ConsiderNosedive()
	if NosediveDesire > 0
	then
		if J.HasPowerTreads(bot)
		then
			J.SetQueuePtToINT(bot, true)
			bot:ActionQueue_UseAbilityOnLocation(Nosedive, NosediveLocation)
		else
			bot:Action_UseAbilityOnLocation(Nosedive, NosediveLocation)
		end

		return
	end

	NetherToxinDesire, NetherToxinLocation = X.ConsiderNetherToxin()
	if NetherToxinDesire > 0
	then
		if J.HasPowerTreads(bot)
		then
			J.SetQueuePtToINT(bot, true)
			bot:ActionQueue_UseAbilityOnLocation(NetherToxin, NetherToxinLocation)
		else
			bot:Action_UseAbilityOnLocation(NetherToxin, NetherToxinLocation)
		end

		return
	end

	PoisonAttackDesire, PoisonAttackTarget = X.ConsiderPoisonAttack()
	if PoisonAttackDesire > 0
	then
		bot:Action_UseAbilityOnEntity(PoisonAttack, PoisonAttackTarget)
		return
	end
end

function X.ConsiderPoisonAttack()
	if not PoisonAttack:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, PoisonAttack:GetCastRange())
	local nAttackRange = bot:GetAttackRange()
	local nDamage = PoisonAttack:GetSpecialValueInt('damage')
	local nDuration = PoisonAttack:GetSpecialValueInt('duration')

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage * nDuration, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:IsMagicImmune()
		and not botTarget:IsInvulnerable()
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
			and J.GetManaAfter(PoisonAttack:GetManaCost()) * bot:GetMana() > ViperStrike:GetManaCost()
            then
                if  J.IsInRange(bot, botTarget, nAttackRange)
				and not botTarget:IsAttackImmune()
				then
					if PoisonAttack:GetAutoCastState() == false
					then
						PoisonAttack:ToggleAutoCast()
						return BOT_ACTION_DESIRE_NONE, nil
					else
						return BOT_ACTION_DESIRE_NONE, nil
					end
				end

				if  J.IsInRange(bot, botTarget, nCastRange)
				and not J.IsInRange(bot, botTarget, nAttackRange)
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget
				end
            end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if  J.IsValidHero(nInRangeEnemy[1])
		and J.IsChasingTarget(nInRangeEnemy[1], bot)
		and not nInRangeEnemy[1]:HasModifier('modifier_viper_poison_attack_slow')
		and not nInRangeEnemy[1]:IsMagicImmune()
		and not nInRangeEnemy[1]:IsInvulnerable()
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
		end
	end

	if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
			if  PoisonAttack:GetAutoCastState() == false
			and J.GetMP(bot) > 0.25
			then
				PoisonAttack:ToggleAutoCast()
				return BOT_ACTION_DESIRE_NONE, nil
			else
				if  PoisonAttack:GetAutoCastState() == true
				and J.GetMP(bot) < 0.25
				then
					PoisonAttack:ToggleAutoCast()
					return BOT_ACTION_DESIRE_NONE, nil
				end

				return BOT_ACTION_DESIRE_NONE, nil
			end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
			if  PoisonAttack:GetAutoCastState() == false
			and J.GetMP(bot) > 0.25
			then
				PoisonAttack:ToggleAutoCast()
				return BOT_ACTION_DESIRE_NONE, nil
			else
				if  PoisonAttack:GetAutoCastState() == true
				and J.GetMP(bot) < 0.25
				then
					PoisonAttack:ToggleAutoCast()
					return BOT_ACTION_DESIRE_NONE, nil
				end

				return BOT_ACTION_DESIRE_NONE, nil
			end
        end
    end

	local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nAllyInRangeEnemy)
        do
            if  J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(2)
            and not allyHero:IsIllusion()
            then
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and J.IsChasingTarget(enemyHero, allyHero)
                and not J.IsDisabled(enemyHero)
                and not J.IsTaunted(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				and not enemyHero:HasModifier('modifier_viper_poison_attack_slow')
				then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

	if PoisonAttack:GetAutoCastState() == true
	then
		PoisonAttack:ToggleAutoCast()
		return BOT_ACTION_DESIRE_NONE, nil
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderNetherToxin()
	if not NetherToxin:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, NetherToxin:GetCastRange())
	local nRadius = NetherToxin:GetSpecialValueInt('radius')
	local nAbilityLevel = NetherToxin:GetLevel()

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		and not botTarget:HasModifier('modifier_viper_nethertoxin')
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
				if J.IsInRange(bot, botTarget, nCastRange)
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
				end

				if  J.IsInRange(bot, botTarget, nCastRange + nRadius)
				and not J.IsInRange(bot, botTarget, nCastRange)
				then
					return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
				end
			end
		end
	end

	if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.5
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(0.5)
                end
            end
        end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
		if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		and not J.IsRunning(nEnemyLaneCreeps[1])
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
		end
    end

	if  J.IsFarming(bot)
	and J.GetManaAfter(NetherToxin:GetManaCost()) * bot:GetMana() > ViperStrike:GetManaCost()
	and nAbilityLevel >= 2
    then
		if J.IsAttacking(bot)
		then
			local nNeutralCreeps = bot:GetNearbyNeutralCreeps(bot:GetAttackRange() + 200)
			local nCreepCount = J.GetNearbyAroundLocationUnitCount(true, false, nRadius, J.GetCenterOfUnits(nNeutralCreeps))

			if  nNeutralCreeps ~= nil and #nNeutralCreeps >= 1
			and J.GetManaAfter(NetherToxin:GetManaCost()) * bot:GetMana() > ViperStrike:GetManaCost()
			then
				if J.IsBigCamp(nNeutralCreeps)
				or nNeutralCreeps[1]:IsAncientCreep()
				then
					if  #nNeutralCreeps >= 2
					and nCreepCount >= 2
					then
						return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
					end
				else
					if  #nNeutralCreeps >= 3
					and nCreepCount >= 2
					then
						return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
					end
				end
			end

			local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(bot:GetAttackRange() + 200, true)
			nCreepCount = J.GetNearbyAroundLocationUnitCount(true, false, nRadius, J.GetCenterOfUnits(nEnemyLaneCreeps))
			if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
			and nCreepCount >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
			end
		end
    end

	if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
		and not botTarget:IsMagicImmune()
		and not botTarget:HasModifier('modifier_viper_nethertoxin')
        then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
		and not botTarget:HasModifier('modifier_viper_nethertoxin')
        then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderViperStrike()
	if not ViperStrike:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = ViperStrike:GetCastRange()
	local nDamage = ViperStrike:GetSpecialValueInt('damage')
	local nDuration = ViperStrike:GetSpecialValueInt('duration')

	local nEnemysHerosInCastRange = J.GetNearbyHeroes(bot, nCastRange + 80 , true, BOT_MODE_NONE )
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit(bot, true, true, nCastRange + 80)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidTarget(enemyHero)
			and J.CanCastOnTargetAdvanced(enemyHero)
            and (nDamage + nDuration) < enemyHero:GetHealth()
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_item_aeon_disk_buff')
            and not enemyHero:HasModifier('modifier_item_blade_mail_reflect')
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                then
                    if enemyHero:GetUnitName() == 'npc_dota_hero_bristleback'
					or enemyHero:GetUnitName() == 'npc_dota_hero_spectre'
					or enemyHero:GetUnitName() == 'npc_dota_hero_huskar'
					or enemyHero:GetUnitName() == 'npc_dota_hero_dragon_knight'
					or enemyHero:GetUnitName() == 'npc_dota_hero_tidehunter'
					or enemyHero:GetUnitName() == 'npc_dota_hero_phantom_assassin'
					or enemyHero:GetUnitName() == 'npc_dota_hero_antimage'
					or enemyHero:GetUnitName() == 'npc_dota_hero_mars'
					or enemyHero:GetUnitName() == 'npc_dota_hero_centaur'
					or enemyHero:GetUnitName() == 'npc_dota_hero_necrolyte'
					then
						return BOT_ACTION_DESIRE_HIGH, enemyHero
					end
                end
            end
        end
	end

	if  J.IsValidHero(nEnemysHerosInCastRange[1])
	and not J.IsSuspiciousIllusion(nEnemysHerosInCastRange[1])
	then
		if nWeakestEnemyHeroInCastRange ~= nil
		then
			if  nWeakestEnemyHeroInCastRange:GetHealth() < nWeakestEnemyHeroInCastRange:GetActualIncomingDamage(nDamage * nDuration, DAMAGE_TYPE_MAGICAL)
			and J.CanCastOnNonMagicImmune(nWeakestEnemyHeroInCastRange)
			and not J.IsSuspiciousIllusion(nWeakestEnemyHeroInCastRange)
			and not nWeakestEnemyHeroInCastRange:HasModifier('modifier_abaddon_borrowed_time')
			and not nWeakestEnemyHeroInCastRange:HasModifier('modifier_dazzle_shallow_grave')
			and not nWeakestEnemyHeroInCastRange:HasModifier('modifier_necrolyte_reapers_scythe')
			and not nWeakestEnemyHeroInCastRange:HasModifier('modifier_oracle_false_promise_timer')
			and not nWeakestEnemyHeroInCastRange:HasModifier('modifier_item_sphere_target')
			then
				return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInCastRange
			end

			if J.IsValidHero(botTarget)
			then
				if  J.IsInRange(bot, botTarget, nCastRange + 75)
				and J.CanCastOnNonMagicImmune(botTarget)
				and J.CanCastOnTargetAdvanced(botTarget)
				and not J.IsSuspiciousIllusion(botTarget)
				and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
				and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
				and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
				and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
				and not botTarget:HasModifier('modifier_item_sphere_target')
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget
				else
					if J.CanCastOnTargetAdvanced(nWeakestEnemyHeroInCastRange)
					then
						return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInCastRange
					end
				end
			end
		end

		if  J.CanCastOnNonMagicImmune(nEnemysHerosInCastRange[1])
		and J.CanCastOnTargetAdvanced(nEnemysHerosInCastRange[1])
		and not nEnemysHerosInCastRange[1]:HasModifier('modifier_abaddon_borrowed_time')
		and not nEnemysHerosInCastRange[1]:HasModifier('modifier_dazzle_shallow_grave')
		and not nEnemysHerosInCastRange[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		and not nEnemysHerosInCastRange[1]:HasModifier('modifier_oracle_false_promise_timer')
		and not nEnemysHerosInCastRange[1]:HasModifier('modifier_item_sphere_target')
		then
			return BOT_ACTION_DESIRE_HIGH, nEnemysHerosInCastRange[1]
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
		and J.IsInRange(bot, botTarget, 500)
		and J.IsAttacking(bot)
		and not botTarget:HasModifier('modifier_roshan_spell_block')
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderNosedive()
	if not Nosedive:IsTrained()
	or not Nosedive:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, Nosedive:GetCastRange())
	local nRadius = 500

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:IsMagicImmune()
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)

                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
					if J.IsInRange(bot, botTarget, nCastRange)
					then
						return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
					end

					if  J.IsInRange(bot, botTarget, nCastRange + nRadius)
					and not J.IsInRange(bot, botTarget, nCastRange)
					then
						return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
					end
                end

				if J.IsInRange(bot, botTarget, nCastRange)
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
				end

				if  J.IsInRange(bot, botTarget, nCastRange + nRadius)
				and not J.IsInRange(bot, botTarget, nCastRange)
				then
					return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
				end
            end
		end
	end

	if  J.IsRetreating(bot)
	and bot:GetActiveModeDesire() > 0.75
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
			and bot:IsFacingLocation(J.GetTeamFountain(), 30)
			and bot:DistanceFromFountain() > 600
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
			and not J.IsRealInvisible(bot)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
                end
            end
        end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

return X