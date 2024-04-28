local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sOutfitType = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,3,3,3,6,3,1,1,1,2,6,2,2,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRandomItem_1 = RandomInt( 1, 9 ) > 6 and "item_satanic" or "item_butterfly"

local tOutFitList = {}

tOutFitList['outfit_carry'] = {
    "item_tango",
    "item_double_branches",
    "item_quelling_blade",
	"item_slippers",
	"item_circlet",

    "item_wraith_band",
    "item_power_treads",
    "item_magic_wand",
    "item_mask_of_madness",
    "item_mjollnir",--
    "item_black_king_bar",--
    "item_skadi",--
    "item_aghanims_shard",
	"item_butterfly",--
    "item_refresher",--
    "item_travel_boots",
    "item_moon_shard",
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
    "item_quelling_blade",
    "item_wraith_band",
    "item_magic_wand",
    "item_mask_of_madness",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		if hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

local TimeWalk 			= bot:GetAbilityByName( "faceless_void_time_walk" )
local TimeDilation 		= bot:GetAbilityByName( "faceless_void_time_dilation" )
local Chronosphere 		= bot:GetAbilityByName( "faceless_void_chronosphere" )
local TimeWalkReverse 	= bot:GetAbilityByName( "faceless_void_time_walk_reverse" )

local TimeWalkDesire
local TimeDilationDesire
local ChronosphereDesire
local TimeWalkReverseDesire

local hasTimeWalked = false
local hasChronod = false
local timeSinceTimeWalked = 0

function X.SkillsComplement()

    if J.CanNotUseAbility( bot ) then return end

	TimeWalkDesire, TimeWalkLoc = X.ConsiderTimeWalk()
    if (TimeWalkDesire > 0)
	then
        J.SetQueuePtToINT(bot, false)
		hasTimeWalked = true
		timeSinceTimeWalked = DotaTime()
		bot:Action_UseAbilityOnLocation(TimeWalk, TimeWalkLoc)
		return
	end

	TimeDilationDesire = X.ConsiderTimeDilation()
	if (TimeDilationDesire > 0)
	then
        J.SetQueuePtToINT(bot, false)
		bot:Action_UseAbility(TimeDilation)
		return
	end

	TimeWalkReverseDesire = X.ConsiderTimeWalkReverse()
	if (TimeWalkReverseDesire > 0)
	then
		hasTimeWalked = false
		hasChronod = false
		bot:Action_UseAbility(TimeWalkReverse)
		return
	end

	ChronosphereDesire, ChronoLoc = X.ConsiderChronosphere()
    if (ChronosphereDesire > 0)
	then
		hasChronod = true
		bot:Action_UseAbilityOnLocation(Chronosphere, ChronoLoc)
		return
	end
end

function X.ConsiderTimeWalk()
	if not TimeWalk:IsFullyCastable()
	or bot:IsRooted()
	or bot:HasModifier("modifier_faceless_void_chronosphere_speed")
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange 	= TimeWalk:GetSpecialValueInt("range")
	local nCastPoint 	= TimeWalk:GetCastPoint()
	local nAttackRange 	= bot:GetAttackRange()

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
	end

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

		if bot:WasRecentlyDamagedByAnyHero(2.0)
		or bot:WasRecentlyDamagedByTower(2.0)
		or (nEnemyHeroes ~= nil and #nEnemyHeroes > 1)
		then
			local loc = J.GetEscapeLoc()
		    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()

		if J.IsValidTarget(npcTarget)
		and J.CanCastOnMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nCastRange)
		and not J.IsInRange(npcTarget, bot, nAttackRange)
		then
			local nEnemyHeroes = npcTarget:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
			local nAlliesHeroes = npcTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

			if #nEnemyHeroes <= #nAlliesHeroes
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation((GetUnitToUnitDistance(npcTarget, bot) / 3000) + nCastPoint)
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderTimeDilation()

	if not TimeDilation:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = TimeDilation:GetSpecialValueInt("radius");

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
		for _, npcEnemy in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(npcEnemy, 2.0)
			and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil
		and #nEnemyHeroes >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()

		if J.IsValidTarget(npcTarget)
		and J.CanCastOnNonMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderChronosphere()
	if not Chronosphere:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = Chronosphere:GetSpecialValueInt("radius")
	local nDuration = Chronosphere:GetSpecialValueInt("duration")
	local nCastRange = Chronosphere:GetCastRange()
	local nAttackDamage = bot:GetAttackDamage()
	local nAttackSpeed = bot:GetAttackSpeed()

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		local nAllyHeroes = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil
		and #nAllyHeroes >= 2
		then
			for _, npcEnemy in pairs(nEnemyHeroes)
			do
				if bot:WasRecentlyDamagedByHero(npcEnemy, 2.0)
				and not J.IsSuspiciousIllusion(npcEnemy)
				then
					local allies = J.GetAlliesNearLoc(npcEnemy:GetLocation(), nRadius)
					if #allies < 2
					then
						return BOT_ACTION_DESIRE_LOW, npcEnemy:GetLocation()
					end
				end
			end
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if locationAoE.count >= 2
		then
            return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()
		if J.IsValidTarget(npcTarget)
		and J.CanCastOnMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nCastRange)
		and not J.IsSuspiciousIllusion(npcTarget)
		then
            local nEnemyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

            if nEnemyHeroes ~= nil
			and #nEnemyHeroes == 1
            then
                if J.IsCore(npcTarget)
				and J.CanKillTarget(npcTarget, nAttackDamage * nAttackSpeed * nDuration, DAMAGE_TYPE_PHYSICAL)
                then
                    return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
				elseif not J.IsCore(npcTarget)
				then
					return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation()
                end
            end

            return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderTimeWalkReverse()
	if not TimeWalkReverse:IsTrained()
	or not TimeWalkReverse:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local BotTarget = bot:GetTarget()

	if hasTimeWalked
	and not hasChronod
	and DotaTime() - timeSinceTimeWalked() < 1.5
	and (J.IsDefending(bot) or J.IsPushing(bot))
	and (BotTarget ~= nil and BotTarget:IsHero())
	then
		return BOT_ACTION_DESIRE_MODERATE
	end

	return BOT_ACTION_DESIRE_NONE
end

return X