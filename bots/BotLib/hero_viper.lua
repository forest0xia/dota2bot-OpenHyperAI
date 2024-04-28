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
local sOutfitType = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						{--pos2
							['t25'] = {0, 10},
							['t20'] = {0, 10},
							['t15'] = {10, 0},
							['t10'] = {10, 0},
						},
						{--pos3
							['t25'] = {0, 10},
							['t20'] = {10, 0},
							['t15'] = {10, 0},
							['t10'] = {0, 10},
						}
}

local tAllAbilityBuildList = {
						{1,3,1,2,1,6,1,3,2,3,6,2,3,2,6},--pos2
						{1,3,1,3,1,6,1,2,3,3,6,2,2,2,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sOutfitType == "outfit_mid"
then 
	nAbilityBuildList = tAllAbilityBuildList[1]
	nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList[1] )
elseif sOutfitType == "outfit_tank" 
then 
	nAbilityBuildList = tAllAbilityBuildList[2]
	nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList[2] )
end

local sRandomItem_1 = RandomInt( 1, 2 ) == 1 and "item_sphere" or "item_black_king_bar"

local sRandomItem_2 = RandomInt( 1, 9 ) > 6 and "item_monkey_king_bar" or "item_butterfly"

local tOutFitList = {}

tOutFitList['outfit_carry'] = tOutFitList['outfit_mid']

tOutFitList['outfit_mid'] = {

	"item_tango",
	"item_double_branches",
	"item_clarity",
	"item_clarity",
	"item_circlet",
	"item_slippers",

	"item_wraith_band",
	"item_power_treads",
	"item_magic_wand",
	"item_dragon_lance",
	"item_skadi",--
	"item_black_king_bar",--
	"item_heart",--
	"item_ultimate_scepter",
	"item_butterfly",--
	"item_hurricane_pike",--
	"item_ultimate_scepter_2",
	"item_travel_boots_2",--
	"item_moon_shard",
	"item_aghanims_shard",

}

tOutFitList['outfit_priest'] = tOutFitList['outfit_mid']

tOutFitList['outfit_mage'] = tOutFitList['outfit_mid']

tOutFitList['outfit_tank'] = {
	"item_tango",
	"item_double_branches",
	"item_circlet",
	"item_circlet",

	"item_wraith_band",
	"item_wraith_band",
	"item_boots",
	"item_magic_wand",
	"item_arcane_boots",
	"item_hurricane_pike",--
	"item_black_king_bar",--
	"item_aghanims_shard",
	"item_shivas_guard",--
	"item_guardian_greaves",--
	"item_travel_boots",
	"item_lotus_orb",--
	"item_travel_boots_2",--
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
	"item_wraith_band",
	"item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )


X['bDeafaultAbility'] = true
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_viper

"Ability1"		"viper_poison_attack"
"Ability2"		"viper_nethertoxin"
"Ability3"		"viper_corrosive_skin"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"viper_viper_strike"
"Ability10"		"special_bonus_attack_speed_20"
"Ability11"		"special_bonus_spell_lifesteal_8"
"Ability12"		"special_bonus_attack_range_100"
"Ability13"		"special_bonus_unique_viper_1"
"Ability14"		"special_bonus_unique_viper_2"
"Ability15"		"special_bonus_unique_viper_4"
"Ability16"		"special_bonus_unique_viper_3"
"Ability17"		"special_bonus_attack_damage_120"

modifier_viper_poison_attack
modifier_viper_poison_attack_slow
modifier_viper_nethertoxin_thinker
modifier_viper_nethertoxin
modifier_viper_corrosive_skin
modifier_viper_corrosive_skin_slow
modifier_viper_viper_strike_slow

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent5 = bot:GetAbilityByName( sTalentList[5] )
local Nosedive = bot:GetAbilityByName( 'viper_nose_dive' )

local castQDesire, castQTarget = 0
local castWDesire, castWLocation = 0
local castRDesire, castRTarget = 0
local castRQDesire, castRQTarget = 0
local NosediveDesire, NosediveLocation

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList
local talentBonusDamage = 0

local lastRQTime = 0

function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end


	nKeepMana = 400
	talentBonusDamage = 0
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	nLV = bot:GetLevel()
	hEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )


	--计算天赋可能带来的变化
	if talent5:IsTrained() then talentBonusDamage = talentBonusDamage + 500 end


	castRQDesire, castRQTarget = X.ConsiderRQ()
	if ( castRQDesire > 0 )
	then

		lastRQTime = DotaTime()

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRQTarget )
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castRQTarget )
		return

	end


	castRDesire, castRTarget = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return
	end

	NosediveDesire, NosediveLocation = X.ConsiderNosedive()
	if (NosediveDesire > 0)
	then
		J.SetQueuePtToINT(bot, true)
		bot:ActionQueue_UseAbilityOnLocation(Nosedive, NosediveLocation)
		return
	end

	castWDesire, castWLocation = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
	end

	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		bot:Action_ClearActions( false )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return

	end


end

function X.ConsiderRQ()

	if not abilityQ:IsFullyCastable()
		or not abilityR:IsFullyCastable()
		or bot:HasScepter()
		or lastRQTime > DotaTime() - 10
	then return 0 end

	if bot:GetMana() < abilityQ:GetManaCost() + abilityR:GetManaCost() then return 0 end

	local nCastRange = abilityR:GetCastRange()
	local nAttackRange = bot:GetAttackRange() + 50

	local npcTarget = J.GetProperTarget( bot )

	local nEnemysHerosInCastRange = bot:GetNearbyHeroes( nCastRange + 80 , true, BOT_MODE_NONE )
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit( bot, true, true, nCastRange + 80 )


	if J.IsValid( nEnemysHerosInCastRange[1] )
	then
		--当前目标, 最近目标和最弱目标
		if( nWeakestEnemyHeroInCastRange ~= nil )
		then

			if J.IsValidHero( npcTarget )
			then
				if J.IsInRange( npcTarget, bot, nCastRange + 80 )
					and J.CanCastOnNonMagicImmune( npcTarget )
					and J.CanCastOnTargetAdvanced( npcTarget )
					and not npcTarget:IsAttackImmune()
				then
					return BOT_ACTION_DESIRE_HIGH, npcTarget
				else
					if not nWeakestEnemyHeroInCastRange:IsAttackImmune()
						and not nWeakestEnemyHeroInCastRange:IsMagicImmune()
						and J.CanCastOnTargetAdvanced( nWeakestEnemyHeroInCastRange )
					then
						return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInCastRange
					end
				end
			end
		end

		if J.CanCastOnNonMagicImmune( nEnemysHerosInCastRange[1] )
			and J.CanCastOnTargetAdvanced( nEnemysHerosInCastRange[1] )
			and not nEnemysHerosInCastRange[1]:IsAttackImmune()
		then
			return BOT_ACTION_DESIRE_HIGH, nEnemysHerosInCastRange[1]
		end
	end

	return 0

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() or bot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end

	local nSkillLV = abilityQ:GetLevel()
	local nAttackRange = bot:GetAttackRange() + ( nSkillLV - 1 ) * 40
	local nAttackDamage = bot:GetAttackDamage()

	local nTowers = bot:GetNearbyTowers( 1000, true )

	local nEnemysHerosInAttackRange = bot:GetNearbyHeroes( nAttackRange, true, BOT_MODE_NONE )

	local nAlleyLaneCreeps = bot:GetNearbyLaneCreeps( 310, false )

	local npcTarget = J.GetProperTarget( bot )


	if J.IsRetreating( bot )
	then
		local enemys = bot:GetNearbyHeroes( nAttackRange, true, BOT_MODE_NONE )
		if enemys[1] ~= nil and enemys[1]:IsAlive()
			and bot:IsFacingLocation( enemys[1]:GetLocation(), 90 )
			and not enemys[1]:HasModifier( "modifier_viper_poison_attack_slow" )
			and not enemys[1]:IsMagicImmune()
			and not enemys[1]:IsInvulnerable()
			and not enemys[1]:IsAttackImmune()
		then
			return BOT_ACTION_DESIRE_HIGH, enemys[1]
		end
	end


	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	then
		local nAttackTarget = bot:GetAttackTarget()
		if J.IsValid( nAttackTarget )
			and not nAttackTarget:HasModifier( "modifier_viper_poison_attack_slow" )
		then
			castRTarget = nAttackTarget
			return BOT_ACTION_DESIRE_HIGH, castRTarget
		end
	end


	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end

	if bot:GetMana() <= 128 and abilityR:GetCooldownTimeRemaining() <= 0.1 then return 0 end

	local nRadius = abilityW:GetSpecialValueInt( "radius" )
	local nCastRange = abilityW:GetCastRange()
	local nCastPoint = abilityW:GetCastPoint()
	local nSkillLV = abilityW:GetLevel()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetSpecialValueInt( "duration" ) * abilityW:GetSpecialValueInt( "damage" )

	local nEnemysLaneCreepsInSkillRange = bot:GetNearbyLaneCreeps( nCastRange + nRadius, true )
	local nEnemysHeroesInSkillRange = bot:GetNearbyHeroes( nCastRange + nRadius + 30, true, BOT_MODE_NONE )

	local nCanHurtCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0.8, 0 )
	if nCanHurtCreepsLocationAoE == nil
		or  J.GetInLocLaneCreepCount( bot, 1600, nRadius, nCanHurtCreepsLocationAoE.targetloc ) <= 1
	then
		 nCanHurtCreepsLocationAoE.count = 0
	end
	local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius-30, 0.8, 0 )

	local npcTarget = J.GetProperTarget( bot )


	if #nEnemysHeroesInSkillRange >= 2
		and nCanHurtHeroLocationAoE.cout ~= nil
		and nCanHurtHeroLocationAoE.cout >= 2
		and bot:GetActiveMode() ~= BOT_MODE_LANING
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or bot:GetActiveModeDesire() < 0.7 )
	then
		return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc
	end

	if J.IsValidHero( npcTarget )
		and J.CanCastOnNonMagicImmune( npcTarget )
		and not npcTarget:HasModifier( "modifier_viper_nethertoxin" )
		and J.IsInRange( npcTarget, bot, nCastRange + 100 )
		and ( nSkillLV >= 3 or bot:GetMana() >= nKeepMana )
	then
		local targetFutureLoc = J.GetCorrectLoc( npcTarget, nCastPoint + 1.2 )
		if npcTarget:GetLocation() ~= targetFutureLoc
		then
			return BOT_ACTION_DESIRE_HIGH, targetFutureLoc
		end

		local castDistance = GetUnitToUnitDistance( bot, npcTarget )
		if npcTarget:IsFacingLocation( bot:GetLocation(), 45 )
		then
			if castDistance > 300
			then
				castDistance = castDistance - 100
			end

			return BOT_ACTION_DESIRE_HIGH, J.GetUnitTowardDistanceLocation( bot, npcTarget, castDistance )
		end

		if bot:IsFacingLocation( npcTarget:GetLocation(), 45 )
		then
			if castDistance + 100 <= nCastRange
			then
				castDistance = castDistance + 200
			else
				castDistance = nCastRange + 100
			end

			return BOT_ACTION_DESIRE_HIGH, J.GetUnitTowardDistanceLocation( bot, npcTarget, castDistance )
		end

		return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()

	end


	if ( bot:GetActiveMode() == BOT_MODE_RETREAT and not bot:IsMagicImmune() )
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 200, nRadius, 0.8, 0 )
		if nCanHurtHeroLocationAoENearby.count >= 1
			and bot:IsFacingLocation( nCanHurtHeroLocationAoENearby.targetloc, 60 )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc
		end
	end


	if #hEnemyHeroList == 0
		and nSkillLV >= 2
		and bot:GetActiveMode() ~= BOT_MODE_ATTACK
		and bot:GetActiveMode() ~= BOT_MODE_LANING
		and bot:GetMana() >= nKeepMana
		and #nEnemysLaneCreepsInSkillRange >= 2
		and ( nCanHurtCreepsLocationAoE.count >= 5 - nMP * 2.1 )
	then
		local nAllies = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )
		if J.IsValid( nEnemysLaneCreepsInSkillRange[1] ) and #nAllies < 3
			and not nEnemysLaneCreepsInSkillRange[1]:HasModifier( "modifier_viper_nethertoxin" )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc
		end
	end

	if J.IsFarming( bot )
		and nSkillLV >= 2
		and J.IsAllowedToSpam( bot, nManaCost * 0.3 )
	then
		if J.IsValid( npcTarget )
			and npcTarget:GetTeam() == TEAM_NEUTRAL
			and not npcTarget:HasModifier( "modifier_viper_nethertoxin" )
		then
			local nAoe = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if nAoe.count >= 5 - nMP * 2.5
				and J.GetNearbyAroundLocationUnitCount( true, false, nRadius, nAoe.targetloc ) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, nAoe.targetloc
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	then
		local nAttackTarget = bot:GetAttackTarget()
		if J.IsValid( nAttackTarget )
			and not nAttackTarget:HasModifier( "modifier_viper_nethertoxin" )
		then
			return BOT_ACTION_DESIRE_HIGH, nAttackTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

	local nCastRange = abilityR:GetCastRange()
	local nAttackRange = bot:GetAttackRange()
	local nDamage = ( abilityR:GetLevel() * 40 + 20 ) * 5 + talentBonusDamage

	local nEnemysHerosInCastRange = bot:GetNearbyHeroes( nCastRange + 80 , true, BOT_MODE_NONE )
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit( bot, true, true, nCastRange + 80 )
	local npcTarget = J.GetProperTarget( bot )
	local castRTarget = nil


	if J.IsValid( nEnemysHerosInCastRange[1] )
	then
		--最弱目标和当前目标
		if( nWeakestEnemyHeroInCastRange ~= nil )
		then
			if nWeakestEnemyHeroInCastRange:GetHealth() < nWeakestEnemyHeroInCastRange:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL )
			then
				castRTarget = nWeakestEnemyHeroInCastRange
				return BOT_ACTION_DESIRE_HIGH, castRTarget
			end

			if J.IsValidHero( npcTarget )
			then
				if J.IsInRange( npcTarget, bot, nCastRange + 80 )
					and J.CanCastOnNonMagicImmune( npcTarget )
					and J.CanCastOnTargetAdvanced( npcTarget )
				then
					castRTarget = npcTarget
					return BOT_ACTION_DESIRE_HIGH, castRTarget
				else
					if J.CanCastOnTargetAdvanced( nWeakestEnemyHeroInCastRange )
					then
						castRTarget = nWeakestEnemyHeroInCastRange
						return BOT_ACTION_DESIRE_HIGH, castRTarget
					end
				end
			end
		end

		if J.CanCastOnNonMagicImmune( nEnemysHerosInCastRange[1] )
			and J.CanCastOnTargetAdvanced( nEnemysHerosInCastRange[1] )
		then
			castRTarget = nEnemysHerosInCastRange[1]
			return BOT_ACTION_DESIRE_HIGH, castRTarget
		end
	end


	if bot:GetActiveMode() == BOT_MODE_ROSHAN and bot:HasScepter()
	then
		local nAttackTarget = bot:GetAttackTarget()
		if nAttackTarget ~= nil and nAttackTarget:IsAlive()
			and nAttackTarget:HasModifier( "modifier_viper_poison_attack_slow" )
		then
			return BOT_ACTION_DESIRE_HIGH, nAttackTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderNosedive()
	if not Nosedive:IsTrained()
	and not Nosedive:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, Nosedive:GetCastRange())
	local nCastPoint = Nosedive:GetCastPoint()
	local nRadius   = 500
	local botTarget  = J.GetProperTarget(bot)
	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_ATTACK)

	if J.IsRetreating(bot)
	then
		if (#nEnemyHeroes >= #nAllyHeroes or not J.WeAreStronger(bot, nRadius))
		and not J.IsRealInvisible(bot)
		and bot:IsFacingLocation(GetAncient(GetTeam()):GetLocation(), 30)
		and bot:DistanceFromFountain() > 600
		and bot:WasRecentlyDamagedByAnyHero(4.0)
		then
			local loc = J.GetEscapeLoc()
			local location = J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)

			return BOT_ACTION_DESIRE_HIGH, location
		end
	end

	if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius / 2, 0, 0)
		local unitCount = J.CountVulnerableUnit(nEnemyHeroes, locationAoE, nRadius, 2)

		if unitCount >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(botTarget, bot, nCastRange)
		then
			local targetAllies = botTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE)
			if #targetAllies >= 1
			then
				return BOT_ACTION_DESIRE_HIGH, J.GetProperLocation(botTarget, nCastPoint)
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

return X