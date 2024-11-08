local X = {}
local bot = GetBot()
local bDebugMode = ( 1 == 10 )

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
	{3,1,1,2,1,6,1,3,3,3,6,2,2,2,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",

    "item_magic_wand",
    "item_wraith_band",
    "item_power_treads",
	"item_maelstrom",
    "item_yasha",
    "item_black_king_bar",--
    "item_sange_and_yasha",--
	"item_mjollnir",--
    "item_aghanims_shard",
    "item_monkey_king_bar",--
    "item_satanic",--
    "item_moon_shard",
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	"item_black_king_bar",
	"item_quelling_blade",
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_heavens_halberd", 'item_quelling_blade'} end

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

npc_dota_hero_kez

[VScript] Ability At Index 0: kez_echo_slash
[VScript] Ability At Index 1: kez_grappling_claw
[VScript] Ability At Index 2: kez_kazurai_katana
[VScript] Ability At Index 3: kez_switch_weapons
[VScript] Ability At Index 4: generic_hidden
[VScript] Ability At Index 5: kez_raptor_dance
[VScript] Ability At Index 6: kez_falcon_rush
[VScript] Ability At Index 7: kez_talon_toss
[VScript] Ability At Index 8: kez_shodo_sai
[VScript] Ability At Index 9: kez_ravens_veil
[VScript] Ability At Index 10: kez_shodo_sai_parry_cancel

--]]

local SwitchWeapons = bot:GetAbilityByName( 'kez_switch_weapons' )
local EchoSlash = bot:GetAbilityByName( 'kez_echo_slash' )
local GrapplingClaw = bot:GetAbilityByName( 'kez_grappling_claw' )
local KazuraiKatana = bot:GetAbilityByName( 'kez_kazurai_katana' )
local RaptorDance = bot:GetAbilityByName( 'kez_raptor_dance' )
local FalconRush = bot:GetAbilityByName( 'kez_falcon_rush' )
local TalonToss = bot:GetAbilityByName( 'kez_talon_toss' )
local ShodoSai = bot:GetAbilityByName( 'kez_shodo_sai' )
local ShodoSaiParryCancel = bot:GetAbilityByName( 'kez_shodo_sai_parry_cancel' )
local RavensVeil = bot:GetAbilityByName( 'kez_ravens_veil' )

local nKeepMana = 220
local nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive,
castEchoSlashDesire, castGrapplingClawDesire, castGrapplingClawTarget, castRaptorDanceDesire

function X.SkillsComplement()
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes( bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )

	castEchoSlashDesire, sMotive = X.ConsiderEchoSlash()
	if castEchoSlashDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( EchoSlash )
		return
	end

	castGrapplingClawDesire, castGrapplingClawTarget, sMotive = X.ConsiderGrapplingClaw()
	if ( castGrapplingClawDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( GrapplingClaw, castGrapplingClawTarget )
		return
	end

	castRaptorDanceDesire, sMotive = X.ConsiderRaptorDance()
	if castRaptorDanceDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( RaptorDance )
		return
	end
end

function X.ConsiderEchoSlash()
	if not EchoSlash:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = EchoSlash:GetCastRange()
	local nRadius = EchoSlash:GetSpecialValueInt( "katana_radius" )
	local nDamagePer = EchoSlash:GetSpecialValueInt( "katana_echo_damage" )
	local nDamage = nDamagePer * bot:GetAttackDamage() * 2
    local nCastPoint = EchoSlash:GetCastPoint()

	--击杀
	for _, npcEnemy in pairs( hEnemyList )
	do
		if J.IsValidHero( npcEnemy )
		and bot:IsFacingLocation(J.GetCorrectLoc(npcEnemy, nCastPoint), 15)
		and J.IsInRange( npcEnemy, bot, nRadius + nCastRange )
		and J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PHYSICAL)
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q击杀'..J.Chat.GetNormName( npcEnemy )
		end
	end

	--撤退
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValidHero( npcEnemy )
			and npcEnemy:IsFacingLocation(bot:GetLocation(), 20)
			and J.IsInRange( npcEnemy, bot, 500 )
			and nHP < 0.5
			then
				return BOT_ACTION_DESIRE_HIGH, 'Q撤退'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end

	if J.IsInLaningPhase() and nMP < 0.3 then return BOT_ACTION_DESIRE_NONE end

	--打架攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
		and bot:IsFacingLocation(J.GetCorrectLoc(botTarget, nCastPoint), 15)
		and J.IsInRange( botTarget, bot, nRadius + nCastRange )
		and J.CanCastOnNonMagicImmune( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q-攻击:'..J.Chat.GetNormName( botTarget )
		end
	end
	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderGrapplingClaw()
	if not GrapplingClaw:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = GrapplingClaw:GetCastRange()

	--撤退
	if J.IsRetreating(bot)
	and bot:DistanceFromFountain() > 600
	then
		if hAllyList ~= nil and hEnemyList ~= nil
		and ((#hEnemyList > #hAllyList)
			or (J.GetHP(bot) and bot:WasRecentlyDamagedByAnyHero(3)))
		and J.IsValidHero(hEnemyList[1])
		and J.IsInRange(bot, hEnemyList[1], 500)
		and not J.IsSuspiciousIllusion(hEnemyList[1])
		and not J.IsDisabled(hEnemyList[1])
		then
			local nTargetTree = J.GetBestRetreatTree(bot, nCastRange)

			if nTargetTree ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetTree, "w撤退"
			end
		end
	end

	if J.IsInLaningPhase() and nMP < 0.3 then return BOT_ACTION_DESIRE_NONE end

	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
		and J.IsInRange( botTarget, bot, nCastRange + 100 )
		and not J.IsInRange( botTarget, bot, 250 )
		and J.IsChasingTarget(bot, botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "w打架"..J.Chat.GetNormName( botTarget )
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderRaptorDance()
	if not RaptorDance:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end

	local nRadius = RaptorDance:GetSpecialValueInt( "radius" )
	local nBaseDamage = RaptorDance:GetSpecialValueInt( "base_damage" )
	local nStrikes = RaptorDance:GetSpecialValueInt( "strikes" )
	local nMaxHealthDamagePct = RaptorDance:GetSpecialValueInt( "max_health_damage_pct" )

	--kill
	for _, npcEnemy in pairs( hEnemyList )
	do
		if J.IsValidHero( npcEnemy )
		and J.IsInRange(bot, botTarget, nRadius)
		then
			local nDamage = nBaseDamage + nStrikes * bot:GetAttackDamage() + nMaxHealthDamagePct * botTarget:GetMaxHealth()
			if J.CanKillTarget( npcEnemy, nDamage, DAMAGE_TYPE_PURE )
			then
				return BOT_ACTION_DESIRE_HIGH, 'r击杀'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end

	if J.IsRetreating(bot)
	then
		if hAllyList ~= nil and hEnemyList
		and #hEnemyList >= #hAllyList
		and J.GetHP(bot) < 0.5 and J.GetHP(bot) > 0.15 and bot:WasRecentlyDamagedByAnyHero(3)
		and J.IsValidHero(hEnemyList[1])
		and J.IsInRange(bot, hEnemyList[1], nRadius)
		and not J.IsSuspiciousIllusion(hEnemyList[1])
		and not hEnemyList[1]:HasModifier('modifier_abaddon_aphotic_shield')
		and not hEnemyList[1]:HasModifier('modifier_abaddon_borrowed_time')
		and not hEnemyList[1]:HasModifier('modifier_dazzle_shallow_grave')
		and not hEnemyList[1]:HasModifier('modifier_oracle_false_promise_timer')
		and not hEnemyList[1]:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsInLaningPhase() and nMP < 0.3 then return BOT_ACTION_DESIRE_NONE end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_aphotic_shield')
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		and hAllyList ~= nil and hEnemyList ~= nil
		and #hAllyList >= #hEnemyList
		then
			return BOT_ACTION_DESIRE_HIGH, "q打架"
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, 0, nRadius, 2)
		if nAoeLoc ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, "q团战"
		end
	end
	return BOT_ACTION_DESIRE_NONE
end

return X