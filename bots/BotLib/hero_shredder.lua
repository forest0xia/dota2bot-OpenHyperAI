-- Credit goes to Furious Puppy for Bot Experiment

local X = {}
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
						{1,3,2,2,2,6,2,1,1,1,6,3,3,3,6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sLotusPipe = RandomInt( 1, 2 ) == 1 and "item_lotus_orb" or "item_pipe"

local tOutFitList = {}

tOutFitList['outfit_carry'] = tOutFitList['outfit_tank'] 

tOutFitList['outfit_mid'] = tOutFitList['outfit_tank']

tOutFitList['outfit_priest'] = tOutFitList['outfit_tank']

tOutFitList['outfit_mage'] = tOutFitList['outfit_tank']

tOutFitList['outfit_tank'] = {
    "item_tango",
    "item_double_branches",
	"item_circlet",
	"item_circlet",

    "item_magic_wand",
	"item_helm_of_iron_will",
	"item_ring_of_basilius",
    "item_arcane_boots",
	"item_veil_of_discord",
	"item_blink",
    "item_eternal_shroud",--
    "item_kaya_and_sange",--
	"item_shivas_guard",--
    sLotusPipe,--
	"item_travel_boots",
    "item_arcane_blink",--
	"item_travel_boots_2",--
    "item_aghanims_shard",
    "item_ultimate_scepter_2"
}

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
	"item_circlet",
    "item_magic_wand",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end
end

local WhirlingDeath 	= bot:GetAbilityByName( 'shredder_whirling_death' )
local TimberChain 		= bot:GetAbilityByName( 'shredder_timber_chain' )
local ReactiveArmor     = bot:GetAbilityByName( 'shredder_reactive_armor' )
local Chakram 			= bot:GetAbilityByName( 'shredder_chakram' )
local ChakramReturn 	= bot:GetAbilityByName( 'shredder_return_chakram' )
local Chakram2 			= bot:GetAbilityByName( 'shredder_chakram_2' )
local ChakramReturn2 	= bot:GetAbilityByName( 'shredder_return_chakram_2' )
local Flamethrower 		= bot:GetAbilityByName( 'shredder_flamethrower' )


local WhirlingDeathDesire = 0
local TimberChainDesire = 0
local ReactiveArmorDesire = 0
local ChakramDesire = 0
local ChakramReturnDesire = 0
local Chakram2Desire = 0
local ChakramReturn2Desire = 0
local FlamethrowerDesire = 0
local ClosingDesire = 0

local ultLoc
local ultETA1 = 0
local ultTime1 = 0

local ultLoc2
local ultETA2 = 0
local ultTime2 = 0

local function GetUltLoc(npcBot, enemy, nManaCost, nCastRange, s)

	local v=enemy:GetVelocity();
	local sv=GetDistance(Vector(0,0),v);
	if sv>800 then
		v=(v / sv) * enemy:GetCurrentMovementSpeed();
	end
	
	local x=npcBot:GetLocation();
	local y=enemy:GetLocation();
	
	local a=v.x*v.x + v.y*v.y - s*s;
	local b=-2*(v.x*(x.x-y.x) + v.y*(x.y-y.y));
	local c= (x.x-y.x)*(x.x-y.x) + (x.y-y.y)*(x.y-y.y);
	
	local t=math.max((-b+math.sqrt(b*b-4*a*c))/(2*a) , (-b-math.sqrt(b*b-4*a*c))/(2*a));
	
	local dest = (t+0.35)*v + y;

	if GetUnitToLocationDistance(npcBot,dest)>nCastRange or npcBot:GetMana()<100+nManaCost then
		return nil;
	end
	
	if enemy:GetMovementDirectionStability()<0.4 or ((not npcBot:IsFacingLocation(enemy:GetLocation(), 60)) ) then
		dest=VectorTowards(y, Fountain(GetOpposingTeam()),180);
	end

	if J.IsDisabled(enemy) then
		dest=enemy:GetLocation();
	end
	
	return dest;
	
end

function X.SkillsComplement()

	if J.CanNotUseAbility(bot) then return end

	ChakramReturnDesire = X.ConsiderChakramReturn()
	if (ChakramReturnDesire > 0)
	then
		ultLoc = bot:GetLocation()
		bot:Action_UseAbility(ChakramReturn)
		return
	end

	ChakramReturn2Desire = X.ConsiderChakramReturn2()
	if (ChakramReturn2Desire > 0)
	then
		ultLoc2 = bot:GetLocation()
		bot:Action_UseAbility(ChakramReturn2)
		return
	end

	ChakramDesire, ChakramLoc, eta = X.ConsiderChakram()
	if (ChakramDesire > 0)
	then
		ultLoc = ChakramLoc
		ultTime1 = DotaTime()
		ultETA1 = eta + 0.5
		bot:Action_UseAbilityOnLocation(Chakram, ChakramLoc)
		return
	end

	Chakram2Desire, Chakram2Loc, eta2 = X.ConsiderChakram2()
	if (Chakram2Desire > 0)
	then
		ultLoc2 = Chakram2Loc
		ultTime2 = DotaTime()
		ultETA2 = eta2 + 0.5
		bot:Action_UseAbilityOnLocation(Chakram2, Chakram2Loc)
		return
	end

	TimberChainDesire, TreeLoc = X.ConsiderTimberChain()
	if (TimberChainDesire > 0)
	then
		bot:Action_UseAbilityOnLocation(TimberChain, TreeLoc)
		return
	end

	WhirlingDeathDesire = X.ConsiderWhirlingDeath()
	if (WhirlingDeathDesire > 0)
	then
        bot:Action_UseAbility(WhirlingDeath)
		return
	end

	ReactiveArmorDesire = X.ConsiderReactiveArmor()
	if (ReactiveArmorDesire > 0)
	then
        bot:Action_UseAbility(ReactiveArmor)
		return
	end

	FlamethrowerDesire = X.ConsiderFlamethrower()
	if (FlamethrowerDesire > 0)
	then
		bot:Action_UseAbility(Flamethrower)
		return
	end

	ClosingDesire, target = X.ConsiderClosing()
	if (ClosingDesire > 0)
	then
		bot:Action_MoveToLocation(target)
		return
	end
end

function X.ConsiderWhirlingDeath()
	if (not WhirlingDeath:IsFullyCastable()) then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = WhirlingDeath:GetSpecialValueInt("whirling_radius")
	local nDamage = WhirlingDeath:GetSpecialValueInt("whirling_damage")
	local nMana = bot:GetMana() / bot:GetMaxMana()

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
		for _, npcEnemy in pairs(nEnemyHeroes)
		do
			if (bot:WasRecentlyDamagedByHero(npcEnemy, 1.0)
			and J.CanCastOnNonMagicImmune(npcEnemy))
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
		local nCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
		if nCreeps ~= nil and #nCreeps >= 3
		and nMana > 0.2
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()

		if J.IsValidTarget(npcTarget)
		and J.CanCastOnNonMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsFarming(bot)
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nRadius)

		if nCreeps ~= nil and #nCreeps >= 2
		and nMana > 0.2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsLaning(bot)
	then
		local target = bot:GetTarget()

		if J.IsValidTarget(target)
		and J.CanCastOnNonMagicImmune(target)
		and J.CanKillTarget(target, nDamage)
		and J.IsInRange(bot, target, nRadius)
		and nMana > 0.2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderTimberChain()
	if (not TimberChain:IsFullyCastable())
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = TimberChain:GetSpecialValueInt("chain_radius")
	local nSpeed = TimberChain:GetSpecialValueInt("speed")
	local nCastRange = J.GetProperCastRange(false, bot, TimberChain:GetCastRange())
	local nDamage = TimberChain:GetSpecialValueInt("damage")
	local nWhirlingDamage = WhirlingDeath:GetSpecialValueInt("whirling_damage")

	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, GetAncient(GetTeam()):GetLocation(), nCastRange)
	end

	if J.IsRetreating(bot)
	and bot:DistanceFromFountain() > 1000
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil
		and #nEnemyHeroes > 0
		then
			local RetreatTree = GetBestRetreatTree(bot, nCastRange)

			if RetreatTree ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, RetreatTree
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()

		if J.IsValidTarget(npcTarget)
		and J.CanCastOnNonMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nCastRange)
		and not AreTreesBetween(npcTarget:GetLocation(), nRadius)
		then
			local EngageTree = GetBestTree(bot, npcTarget, nCastRange, nRadius)

			if EngageTree ~= nil
			then

				if bot:GetLevel() < 6
				and not J.CanKillTarget(npcTarget, nDamage + nWhirlingDamage, DAMAGE_TYPE_PURE)
				then
					return BOT_ACTION_DESIRE_LOW, GetTreeLocation(EngageTree)
				end

				return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(EngageTree)
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderReactiveArmor()
	if not ReactiveArmor:IsFullyCastable()
	or ReactiveArmor:IsPassive()
	or not bot:HasScepter()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = 1000
	local nInRangeEnmyList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

	if J.GetHP(bot) < 0.3
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

		for _, npcEnemy in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(npcEnemy, 1.0)
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	and nInRangeEnmyList >= 2
	then
		local botTarget = bot:GetTarget()

		if J.IsValidHero(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and bot:WasRecentlyDamagedByAnyHero(2.0)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderChakram()
	if (not Chakram:IsFullyCastable() or Chakram:IsHidden())
	then
		return BOT_ACTION_DESIRE_NONE, 0, 0
	end

	local nRadius = Chakram:GetSpecialValueFloat("radius")
	local nSpeed = Chakram:GetSpecialValueFloat("speed")
	local nCastRange = J.GetProperCastRange(false, bot, Chakram:GetCastRange())
	local nManaCost = Chakram:GetManaCost()
	local nDamage = Chakram:GetSpecialValueInt("pass_damage")
	local nMana = bot:GetMana() / bot:GetMaxMana()

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
		for _, npcEnemy in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(npcEnemy, 1.0)
			then
				local loc = npcEnemy:GetLocation()
				local eta = GetUnitToLocationDistance(bot, loc) / nSpeed

				if J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PURE)
				then
					return BOT_ACTION_DESIRE_HIGH, loc, eta
				end

				return BOT_ACTION_DESIRE_LOW, loc, eta
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()
		if J.IsValidTarget(npcTarget)
		and J.CanCastOnNonMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nCastRange)
		then
			local loc = GetUltLoc(bot, npcTarget, nManaCost, nCastRange, nSpeed)
			if loc ~= nil
			then
				local eta = GetUnitToLocationDistance(bot, loc) / nSpeed
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation(), eta
			end
		end
	end

	if J.IsDefending(bot)
	or J.IsPushing(bot)
	or J.IsFarming(bot)
	then
		local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if locationAoE.count >= 2
		and nMana > 0.2
		then
			local loc = locationAoE.targetloc
			local eta = GetUnitToLocationDistance(bot, loc) / nSpeed

			return BOT_ACTION_DESIRE_MODERATE, loc, eta
		end
	end

	if J.IsLaning(bot)
	then
		local target = bot:GetTarget()

		if J.IsValidTarget(target)
		and J.CanCastOnNonMagicImmune(target)
		and J.IsInRange(nCastRange)
		and J.CanKillTarget(target, nDamage, DAMAGE_TYPE_PURE)
		then
			local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

			local loc = locationAoE.targetloc
			local eta = GetUnitToLocationDistance(bot, loc) / nSpeed

			return BOT_ACTION_DESIRE_HIGH, loc, eta
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderChakramReturn()
	if (ultLoc == 0 or ultLoc == nil)
	or not ChakramReturn:IsFullyCastable()
	or ChakramReturn:IsHidden()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if DotaTime() < ultTime1 + ultETA1
	or StillTraveling(1)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = Chakram:GetSpecialValueFloat( "radius" )
	local nDamage = Chakram:GetSpecialValueInt("pass_damage")
	local nManaCost = Chakram:GetManaCost()
	local nMana = bot:GetMana() / bot:GetMaxMana()

	local nUnits = 0
	local nNearbyCreeps = bot:GetNearbyLaneCreeps(1300, true)

	for _, c in pairs(nNearbyCreeps)
	do
		if GetUnitToLocationDistance(c, ultLoc) < nRadius  then
			nUnits = nUnits + 1
		end
	end

	if nMana < 0.15
	or GetUnitToLocationDistance(bot, ultLoc) > 1600
	or nUnits == 0
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsDefending(bot)
	or J.IsPushing(bot)
	then
		local nUnits = 0
		local nLowHPUnits = 0
		local nNearbyCreeps = bot:GetNearbyLaneCreeps(1300, true)

		for _, c in pairs(nNearbyCreeps)
		do
			if GetUnitToLocationDistance(c, ultLoc) < nRadius  then
				nUnits = nUnits + 1
			end

			if GetUnitToLocationDistance(c, ultLoc) < nRadius
			and c:GetHealth() <= nDamage then
				nLowHPUnits = nLowHPUnits + 1
			end
		end

		if nUnits == 0
		or nLowHPUnits >= 1
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	or J.IsGoingOnSomeone(bot)
	then
		local nUnits = 0
		local nNearbyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

		for _, h in pairs(nNearbyHeroes)
		do
			if GetUnitToLocationDistance(h, ultLoc) < nRadius
			then
				nUnits = nUnits + 1
			end
		end

		if nUnits == 0
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderChakram2()
	if not Chakram2:IsFullyCastable()
	or Chakram2:IsHidden()
	then
		return BOT_ACTION_DESIRE_NONE, 0, 0
	end

	local nRadius = Chakram2:GetSpecialValueFloat("radius")
	local nSpeed = Chakram2:GetSpecialValueFloat("speed")
	local nCastRange = J.GetProperCastRange(false, bot, Chakram2:GetCastRange())
	local nManaCost = Chakram2:GetManaCost()
	local nDamage = Chakram2:GetSpecialValueInt("pass_damage")
	local nMana = bot:GetMana() / bot:GetMaxMana()

	if J.IsRetreating(bot)
	then
		local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
		for _, npcEnemy in pairs(nEnemyHeroes)
		do
			if bot:WasRecentlyDamagedByHero(npcEnemy, 1.0)
			then
				local loc = npcEnemy:GetLocation()
				local eta = GetUnitToLocationDistance(bot, loc) / nSpeed

				if J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PURE)
				then
					return BOT_ACTION_DESIRE_MODERATE, loc, eta
				end

				return BOT_ACTION_DESIRE_LOW, loc, eta
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()
		if J.IsValidTarget(npcTarget)
		and J.CanCastOnNonMagicImmune(npcTarget)
		and J.IsInRange(npcTarget, bot, nCastRange)
		then
			local loc = GetUltLoc(bot, npcTarget, nManaCost, nCastRange, nSpeed)
			if loc ~= nil
			then
				local eta = GetUnitToLocationDistance(bot, loc) / nSpeed
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation(), eta
			end
		end
	end

	if J.IsDefending(bot)
	or J.IsPushing(bot)
	or J.IsFarming(bot)
	then
		local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if locationAoE.count >= 2
		and nMana > 0.2
		then
			local loc = locationAoE.targetloc
			local eta = GetUnitToLocationDistance(bot, loc) / nSpeed

			return BOT_ACTION_DESIRE_LOW, loc, eta
		end
	end

	if J.IsLaning(bot)
	then
		local target = bot:GetTarget()

		if J.IsValidTarget(target)
		and J.CanCastOnNonMagicImmune(target)
		and J.IsInRange(nCastRange)
		and J.CanKillTarget(target, nDamage, DAMAGE_TYPE_PURE)
		then
			local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

			local loc = locationAoE.targetloc
			local eta = GetUnitToLocationDistance(bot, loc) / nSpeed

			return BOT_ACTION_DESIRE_MODERATE, loc, eta
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderChakramReturn2()
	if (ultLoc2 == 0 or ultLoc2 == nil)
	or not ChakramReturn2:IsFullyCastable()
	or ChakramReturn2:IsHidden()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if DotaTime() < ultTime2 + ultETA2
	or StillTraveling(2)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = Chakram2:GetSpecialValueFloat( "radius" )
	local nDamage = Chakram2:GetSpecialValueInt("pass_damage")
	local nMana = bot:GetMana() / bot:GetMaxMana()

	local nUnits = 0
	local nNearbyCreeps = bot:GetNearbyLaneCreeps(1300, true)

	for _, c in pairs(nNearbyCreeps)
	do
		if GetUnitToLocationDistance(c, ultLoc2) < nRadius  then
			nUnits = nUnits + 1
		end
	end

	if nMana < 0.15
	or GetUnitToLocationDistance(bot, ultLoc2) > 1600
	or nUnits == 0
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsDefending(bot)
	or J.IsPushing(bot)
	then
		local nUnits = 0
		local nLowHPUnits = 0
		local nNearbyCreeps = bot:GetNearbyLaneCreeps(1300, true)

		for _, c in pairs(nNearbyCreeps)
		do
			if GetUnitToLocationDistance(c, ultLoc2) < nRadius  then
				nUnits = nUnits + 1
			end

			if GetUnitToLocationDistance(c, ultLoc2) < nRadius
			and c:GetHealth() <= nDamage then
				nLowHPUnits = nLowHPUnits + 1
			end
		end

		if nUnits == 0
		or nLowHPUnits >= 1
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	or J.IsGoingOnSomeone(bot)
	then
		local nUnits = 0
		local nNearbyHeroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

		for _, h in pairs(nNearbyHeroes)
		do
			if GetUnitToLocationDistance(h, ultLoc2) < nRadius
			then
				nUnits = nUnits + 1
			end
		end

		if nUnits == 0
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderClosing()
	if (not bot:HasModifier("modifier_shredder_chakram_disarm"))
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget()

		if J.IsValidTarget(npcTarget)
		and J.IsInRange(bot, npcTarget, 1000)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFlamethrower()
	if not ChakramReturn2:IsFullyCastable()
	or not J.HasAghanimsShard(bot)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRange = Flamethrower:GetSpecialValueInt('length')

	if J.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget()

		if J.IsValidTarget(target)
		and bot:IsFacingLocation(target:GetLocation(), 0)
		and J.IsInRange(bot, target, nRange)
		and J.CanCastOnNonMagicImmune(target)
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

-- HELPER FUNCS

-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function AreTreesBetween(loc,r)
	local npcBot=GetBot();
	
	local trees=npcBot:GetNearbyTrees(GetUnitToLocationDistance(npcBot,loc));
	--check if there are trees between us
	for _,tree in pairs(trees) do
		local x=GetTreeLocation(tree);
		local y=npcBot:GetLocation();
		local z=loc;
		
		if x~=y then
			local a=1;
			local b=1;
			local c=0;
		
			if x.x-y.x ==0 then
				b=0;
				c=-x.x;
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end
		
			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b));
			if d<=r and GetUnitToLocationDistance(npcBot,loc)> GetDistance(x,loc)+50 then
				return true;
			end
		end
	end
	return false;
end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function Fountain(team)
	if team==TEAM_RADIANT then
		return Vector(-7093,-6542);
	end
	return Vector(7015,6534);
end

-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function VectorTowards(s,t,d)
	local f=t-s;
	f=f / GetDistance(f,Vector(0,0));
	return s+(f*d);
end

function GetBestRetreatTree(npcBot, nCastRange)
	local trees=npcBot:GetNearbyTrees(nCastRange);
	
	local dest=VectorTowards(npcBot:GetLocation(), Fountain(GetTeam()),1000);
	
	local BestTree=nil;
	local maxdis=0;
	
	for _,tree in pairs(trees) do
		local loc=GetTreeLocation(tree);
		
		if (not AreTreesBetween(loc,100)) and 
			GetUnitToLocationDistance(npcBot,loc)>maxdis and 
			GetUnitToLocationDistance(npcBot,loc)<nCastRange and 
			GetDistance(loc,dest)<880 
		then
			maxdis=GetUnitToLocationDistance(npcBot,loc);
			BestTree=loc;
		end
	end
	
	if BestTree~=nil and maxdis>250 then
		return BestTree;
	end
	
	return nil;
end

function GetBestTree(npcBot, enemy, nCastRange, hitRadios)
   
	--find a tree behind enemy
	local bestTree=nil;
	local mindis=10000;

	local trees=npcBot:GetNearbyTrees(nCastRange);
	
	for _,tree in pairs(trees) do
		local x=GetTreeLocation(tree);
		local y=npcBot:GetLocation();
		local z=enemy:GetLocation();
		
		if x~=y then
			local a=1;
			local b=1;
			local c=0;
		
			if x.x-y.x ==0 then
				b=0;
				c=-x.x;
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end
		
			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b));
			if d<=hitRadios and mindis>GetUnitToLocationDistance(enemy,x) and (GetUnitToLocationDistance(enemy,x)<=GetUnitToLocationDistance(npcBot,x)) then
				bestTree=tree;
				mindis=GetUnitToLocationDistance(enemy,x);
			end
		end
	end
	
	return bestTree;

end

function StillTraveling(cType)
	local proj = GetLinearProjectiles();
	for _,p in pairs(proj)
	do
		if p ~= nil and (( cType == 1 and p.ability:GetName() == "shredder_chakram" ) or (  cType == 2 and p.ability:GetName() == "shredder_chakram_2" ) ) then
			return true; 
		end
	end
	return false;
end

return X