local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sOutfitType = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
					{--pos1
                        ['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
                    },
                    {--pos2
                        ['t25'] = {10, 0},
                        ['t20'] = {0, 10},
                        ['t15'] = {10, 0},
                        ['t10'] = {10, 0},
                    },
}

local tAllAbilityBuildList = {
						{3,1,3,2,3,6,3,1,1,1,6,2,2,2,6},--pos1
                        {3,1,1,2,1,6,1,2,2,2,6,3,3,3,6},--pos2
}

local nAbilityBuildList
local nTalentBuildList

if sOutfitType == "outfit_carry"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
elseif sOutfitType == "outfit_mid"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local tOutFitList = {}

tOutFitList['outfit_carry'] = {
    "item_tango",
    "item_quelling_blade",
    "item_slippers",
    "item_circlet",
    "item_double_branches",

    "item_wraith_band",
    "item_magic_wand",
    "item_hand_of_midas",
    "item_power_treads",
    "item_echo_sabre",
    "item_blink",
    "item_black_king_bar",--
    "item_aghanims_shard",
    "item_greater_crit",--
    "item_butterfly",--
    "item_satanic",--
    "item_moon_shard",
    "item_swift_blink",--
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
}

tOutFitList['outfit_mid'] = {
    "item_tango",
    "item_double_branches",
    "item_faerie_fire",
    "item_quelling_blade",

    "item_bottle",
    "item_power_treads",
    "item_magic_wand",
    "item_blink",
    "item_echo_sabre",
    "item_aghanims_shard",
    "item_black_king_bar",--
    "item_greater_crit",--
    "item_assault",--
    "item_moon_shard",
    "item_satanic",--
    "item_swift_blink",--
    "item_travel_boots_2",--

    "item_ultimate_scepter_2",
}

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
    "item_quelling_blade",
    "item_bottle",
    "item_magic_wand",
    "item_echo_sabre",
    "item_wraith_band",
    "item_hand_of_midas",
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

local Avalanche     = bot:GetAbilityByName("tiny_avalanche")
local Toss          = bot:GetAbilityByName("tiny_toss")
local TreeGrab      = bot:GetAbilityByName("tiny_tree_grab")
local TreeThrow     = bot:GetAbilityByName("tiny_toss_tree")
local TreeVolley    = bot:GetAbilityByName("tiny_tree_channel")

local AvalancheDesire   = 0
local TossDesire        = 0
local TreeGrabDesire    = 0
local TreeThrowDesire   = 0
local TreeVolleyDesire  = 0

function X.SkillsComplement()
    AvalancheDesire, avalancheTarget    = X.ConsiderAvalanche()
    TossDesire, tossTarget              = X.ConsiderToss()
    TreeGrabDesire, treeGrabTarget      = X.ConsiderTreeGrab()
    TreeThrowDesire, treeThrowTarget    = X.ConsiderTreeThrow()
    TreeVolleyDesire, treeVolleyTarget  = X.ConsiderTreeVolley()

	if AvalancheDesire > 0 then
		bot:Action_UseAbilityOnLocation(Avalanche, avalancheTarget)
		return
	end

	if TossDesire > 0 then
		bot:Action_UseAbilityOnEntity(Toss, tossTarget)
		return
	end

	if TreeGrabDesire > 0 then
		bot:Action_UseAbilityOnTree(TreeGrab, treeGrabTarget)
		return
	end

	if TreeThrowDesire > 0 then
		bot:Action_UseAbilityOnEntity(TreeThrow, treeThrowTarget)
		return
	end

	if TreeVolleyDesire > 0 then
		bot:Action_UseAbilityOnLocation(TreeVolley, treeVolleyTarget)
		return
	end

end

function X.ConsiderAvalanche()
    if not Avalanche:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange 		= J.GetProperCastRange(false, bot, Avalanche:GetCastRange())
	local nCastPoint 		= Avalanche:GetCastPoint()
	local manaCost  		= Avalanche:GetManaCost()
	local nRadius   		= Avalanche:GetSpecialValueInt("radius")
	local avalancheDamage 	= Avalanche:GetAbilityDamage()
	local tossDamage	 	= Toss:GetAbilityDamage()

	local eHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	for _, e in pairs(eHeroes)
	do
		if J.CanCastOnNonMagicImmune(e)
		and e:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, e:GetLocation()
		end
	end

	if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = J.GetProperTarget(bot)
		if J.IsValidTarget(target)
		and J.IsInRange(bot, target, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
		end
	end

	if (J.IsPushing(bot) or J.IsDefending(bot)) and J.CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
		if (locationAoE.count >= 3) then
			local target = J.GetProperTarget(bot)
			if J.IsValidTarget(target)
			and J.IsInRange(bot, target, nCastRange)
			then
				return BOT_ACTION_DESIRE_MODERATE, target:GetLocation()
			end
		end
	end

	if J.IsLaning(bot)
	then
		local eHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		for _, e in pairs(eHeroes)
		do
			if J.CanCastOnNonMagicImmune(e)
			and Toss:IsFullyCastable()
			and J.CanKillTarget(e, avalancheDamage + tossDamage, DAMAGE_TYPE_MAGICAL)
			then
				return BOT_ACTION_DESIRE_HIGH, e:GetLocation()
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget()
		if J.IsValidTarget(target)
		and J.CanCastOnNonMagicImmune(target)
		and J.IsInRange(target, bot, nCastRange)
		and not J.IsDisabled(target)
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderToss()
    if not Toss:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, Toss:GetCastRange())
	local nCastPoint = Toss:GetCastPoint()
	local manaCost  = Toss:GetManaCost()
	local nDamage  = Avalanche:GetSpecialValueInt("avalanche_damage")
	local nDamage2  = Toss:GetSpecialValueInt("toss_damage")
	local nRadius   = Toss:GetSpecialValueInt( "grab_radius" )
	
	local eHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	for _, e in pairs(eHeroes)
	do
		if J.CanCastOnNonMagicImmune(e)
		and e:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, e
		end
	end

	if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		if Avalanche:IsFullyCastable()
		then
			local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			for i = 1, #enemies do
				if J.IsValidTarget(enemies[i])
				and J.CanCastOnNonMagicImmune(enemies[i])
				and enemies[i]:GetHealth() < nDamage + nDamage2
			then
					return BOT_ACTION_DESIRE_MODERATE, enemies[i]
				end
			end
		else
			local loc = J.GetEscapeLoc()
			local furthestTarget = J.GetFurthestUnitToLocationFrommAll(bot, nCastRange, loc)
			if furthestTarget ~= nil and GetUnitToUnitDistance(furthestTarget, bot) > nRadius
			then
				local tTarget = J.GetClosestUnitToLocationFrommAll2(bot, nRadius, bot:GetLocation())
				if J.IsValidTarget(tTarget) and tTarget:GetTeam() ~= bot:GetTeam()
				then
					return BOT_ACTION_DESIRE_LOW, furthestTarget
				end
			elseif furthestTarget ~= nil and GetUnitToUnitDistance(furthestTarget, bot) <= nRadius
			then
				local tTarget = J.GetClosestUnitToLocationFrommAll2(bot, nRadius, bot:GetLocation())
				if J.IsValidTarget(tTarget) and tTarget:GetTeam() ~= bot:GetTeam()
				then
					return BOT_ACTION_DESIRE_LOW, tTarget
				end
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	and J.CanCastOnNonMagicImmune(bot)
	then
		local target = bot:GetTarget()
		if J.IsValidTarget(target) and J.CanCastOnNonMagicImmune(target)
		then
			if J.IsInRange(target, bot, nRadius)
			then
				return BOT_ACTION_DESIRE_LOW, target
			elseif J.IsInRange(target, bot, nCastRange)
			then
				local aCreep = bot:GetNearbyLaneCreeps(nRadius, false)
				local eCreep = bot:GetNearbyLaneCreeps(nRadius, true)
				if #aCreep >= 1 or #eCreep >= 1
				then
					return BOT_ACTION_DESIRE_LOW, target
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderTreeGrab()
	if not TreeGrab:IsFullyCastable()
	or bot:HasModifier("modifier_tiny_tree_grab")
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	if not J.IsRetreating(bot)
	and bot:GetHealth() > 0.15
	and bot:DistanceFromFountain() > 1000
	then
		local trees = bot:GetNearbyTrees(500)
		if #trees > 0
		and (IsLocationVisible(GetTreeLocation(trees[1]))
		or IsLocationPassable(GetTreeLocation(trees[1])))
		then
			return BOT_ACTION_DESIRE_HIGH, trees[1]
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderTreeThrow()
	if not TreeThrow:IsFullyCastable()
	or not bot:HasModifier("modifier_tiny_tree_grab")
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, TreeThrow:GetCastRange())
	local nAttackCount = TreeThrow:GetSpecialValueInt('attack_count')
	local nDamage = bot:GetAttackDamage()

	if J.IsRetreating(bot)
	and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = J.GetVulnerableWeakestUnit(bot, true, true, nCastRange)
		if J.IsValidTarget(target)
		then
			if nAttackCount > 1
			and J.CanKillTarget(target, nDamage, DAMAGE_TYPE_PHYSICAL)
			then
				return BOT_ACTION_DESIRE_HIGH, target
			end

			return BOT_ACTION_DESIRE_LOW, target
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if J.IsValidTarget(target) and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(target, bot, 0.3*nCastRange) == false and J.IsInRange(target, bot, nCastRange) == true
			and bot:GetAttackDamage() >= target:GetHealth()
		then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderTreeVolley()
	if not TreeVolley:IsFullyCastable()
	or bot:HasScepter() == false
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, TreeVolley:GetCastRange())
	local nRadius =  TreeVolley:GetSpecialValueInt('tree_grab_radius')
	local nRadius2 =  TreeVolley:GetSpecialValueInt('splash_radius')

	if J.IsInTeamFight(bot, 1300)
	then
		local trees = bot:GetNearbyTrees(nRadius)
		if #trees >= 3
		then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius2, 0, 0 )
			if (locationAoE.count >= 2)
			then
				local target = J.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius2, locationAoE.targetloc, bot)
				if target ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
				end
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if J.IsValidTarget(target)
		and J.CanCastOnNonMagicImmune(target)
		and J.IsInRange(target, bot, nCastRange)
		then
			local trees = bot:GetNearbyTrees(nRadius)
			if #trees >= 3
			then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

return X