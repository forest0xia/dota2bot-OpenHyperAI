-- Credit goes to Furious Puppy for Bot Experiment

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sOutfitType = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
							['t25'] = {10, 0},
							['t20'] = {10, 0},
							['t15'] = {0, 10},
							['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
							{2, 1, 1, 2, 1, 6, 1, 2, 2, 3, 6, 3, 3, 3, 6},--pos3
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sCrimsonPipe = RandomInt( 1, 2 ) == 1 and "item_crimson_guard" or "item_pipe"

local tOutFitList = {}

tOutFitList['outfit_tank'] = {
    "item_tango",
	"item_double_branches",
    "item_quelling_blade",
	"item_gauntlets",
	"item_circlet",

	"item_bracer",
	"item_bracer",
	"item_boots",
	"item_magic_wand",
    "item_phase_boots",
    "item_blink",
    "item_black_king_bar",--
    "item_aghanims_shard",
    sCrimsonPipe,--
    "item_shivas_guard",--
    "item_refresher",--
    "item_travel_boots",
    "item_overwhelming_blink",--
	"item_travel_boots_2",--
    "item_moon_shard",
    "item_ultimate_scepter_2"
}

tOutFitList['outfit_carry'] = tOutFitList['outfit_tank'] 

tOutFitList['outfit_mid'] = tOutFitList['outfit_tank']

tOutFitList['outfit_priest'] = tOutFitList['outfit_tank']

tOutFitList['outfit_mage'] = tOutFitList['outfit_tank']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
    "item_quelling_blade",
	"item_bracer",
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

local SpearOfMars 	= bot:GetAbilityByName( 'mars_spear' )
local GodsRebuke 	= bot:GetAbilityByName( 'mars_gods_rebuke' )
local Bulwark 		= bot:GetAbilityByName( 'mars_bulwark' )
local ArenaOfBlood 	= bot:GetAbilityByName( 'mars_arena_of_blood' )

local SpearOfMarsDesire = 0
local GodsRebukeDesire = 0
local BulwarkDesire = 0
local ArenaOfBloodDesire = 0

function X.SkillsComplement()
	if J.CanNotUseAbility( bot ) then return end

	ArenaOfBloodDesire, ArenaLoc = X.ConsiderArenaOfBlood()
	if ArenaOfBloodDesire > 0
	then
		bot:Action_UseAbilityOnLocation(ArenaOfBlood, ArenaLoc)
		return
	end

	GodsRebukeDesire, GodsRebukeLoc = X.ConsiderGodsRebuke()
	if GodsRebukeDesire > 0
	then
		bot:Action_UseAbilityOnLocation(GodsRebuke, GodsRebukeLoc)
		return
	end

	SpearOfMarsDesire, SpearLoc = X.ConsiderSpearOfMars()
	if SpearOfMarsDesire > 0
	then
		bot:Action_UseAbilityOnLocation(SpearOfMars, SpearLoc)
		return
	end

	BulwarkDesire = X.ConsiderBulwark()
	if BulwarkDesire > 0
	then
		bot:Action_UseAbility(Bulwark)
		return
	end
end

function X.ConsiderSpearOfMars()
	if not J.CanBeCast(SpearOfMars) then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local castRange = J.GetProperCastRange(false, bot, SpearOfMars:GetCastRange())
	local castPoint = SpearOfMars:GetCastPoint()
	local manaCost  = SpearOfMars:GetManaCost()
	local nRadius   = SpearOfMars:GetSpecialValueInt('spear_width')
	local nSpeed    = SpearOfMars:GetSpecialValueInt('spear_speed')
	local nDamage   = SpearOfMars:GetSpecialValueInt('damage')

	local nEnemyHeroes = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE)

	for _, npcEnemy in pairs(nEnemyHeroes)
	do
		if J.IsValidTarget(npcEnemy)
		and J.CanCastOnNonMagicImmune(npcEnemy)
		and J.IsInRange(bot, npcEnemy, castRange)
		and npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, npcEnemy:GetLocation()
		end
	end

	if J.IsRetreating(bot)
	then
		if nEnemyHeroes ~= nil
		and #nEnemyHeroes > 0
		and bot:WasRecentlyDamagedByAnyHero(2.0)
		then
			local enemy = J.GetLowestHPUnit(nEnemyHeroes, false)

			if J.IsValidTarget(enemy)
			and J.CanCastOnNonMagicImmune(enemy)
			and J.IsInRange(bot, enemy, castRange)
			then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
			end
		end
	end

	if (J.IsPushing(bot) or J.IsDefending(bot))
	and J.AllowedToSpam(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius, 0, 0)

		if locationAoE.count >= 3
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), castRange, nRadius, 0, 0)

		if nEnemyHeroes ~= nil
		and #nEnemyHeroes > 0
		then
			local unitCount = J.CountVulnerableUnit(nEnemyHeroes, locationAoE, nRadius, 2)

			if unitCount >= 2
			then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local target  = bot:GetTarget()

		if J.IsValidTarget(target)
		and J.CanCastOnNonMagicImmune(target)
		and J.IsInRange(target, bot, castRange)
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetProperLocation(target, (GetUnitToUnitDistance(bot, target) / nSpeed) + castPoint)
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderGodsRebuke()
    if not J.CanBeCast(GodsRebuke)
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local castRange = J.GetProperCastRange(false, bot, GodsRebuke:GetCastRange())
	local castPoint = GodsRebuke:GetCastPoint()
	local manaCost  = GodsRebuke:GetManaCost()
	local nRadius   = GodsRebuke:GetSpecialValueInt( "radius" )
	local nDamage   = bot:GetAttackDamage() * GodsRebuke:GetSpecialValueInt('crit_mult') / 100
	local nHealth 	= bot:GetHealth() / bot:GetMaxHealth()

	local target  = bot:GetTarget()
	local nEnemyHeroes = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE)

	if J.IsRetreating(bot)
	then
		if nEnemyHeroes ~= nil
		and #nEnemyHeroes > 0
		and bot:WasRecentlyDamagedByAnyHero(2.0)
		then
			local enemy = J.GetLowestHPUnit(nEnemyHeroes, false)

			if J.IsValidTarget(enemy)
			and not J.IsDisabled(enemy)
            then
				if nHealth < 0.3
				then
					return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation()
				end

				return BOT_ACTION_DESIRE_MODERATE, enemy:GetLocation()
			end
		end
	end

	if (J.IsPushing(bot) or J.IsDefending(bot))
	and J.AllowedToSpam(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), castRange, nRadius / 2, 0, 0)

		if locationAoE.count >= 3
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), castRange-150, nRadius/2, castPoint, 0)

		if nEnemyHeroes ~= nil
		and #nEnemyHeroes > 0
		then
			local unitCount = J.CountNotStunnedUnits(nEnemyHeroes, locationAoE, nRadius, 2)

			if unitCount >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(target)
		and J.CanCastOnNonMagicImmune(target)
		and J.IsInRange(target, bot, castRange - 200)
        and not J.IsDisabled(target)
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
		end
	end

	if J.IsFarming(bot)
	then
		local neutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
		local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), castRange, nRadius / 2, 0, 0)

		if neutralCreeps ~= nil
		and #neutralCreeps >= 2
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBulwark()
    if not J.CanBeCast(Bulwark)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRange = Bulwark:GetSpecialValueInt("soldier_offset")

	if J.IsRetreating(bot)
	and bot:WasRecentlyDamagedByAnyHero(3.0)
	and Bulwark:GetToggleState() == false
	then
		local allies = bot:GetNearbyHeroes(1300, false, BOT_MODE_ATTACK)

		if #allies > 1
		then
			local numFacing = 0
			local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)

			for i = 1, #enemies do
				if J.IsValidTarget(enemies[i])
				and J.CanCastOnMagicImmune(enemies[i])
				and bot:WasRecentlyDamagedByHero(enemies[i], 2)
				and bot:IsFacingLocation(enemies[i]:GetLocation(), 20)
				then
					numFacing = numFacing + 1
				end
			end
			if numFacing >= 1
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	and Bulwark:GetToggleState() == true
	and J.IsInRange(bot, bot:GetTarget(), nRange - 100)
	then
		if bot:HasScepter()
		then
			return BOT_ACTION_DESIRE_MODERATE
		end

		return BOT_ACTION_DESIRE_LOW
	end

	local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
	if enemies ~= nil
	and #enemies == 0
	and Bulwark:GetToggleState() == true
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderArenaOfBlood()
    if not J.CanBeCast(ArenaOfBlood)
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local castRange = J.GetProperCastRange(false, bot, ArenaOfBlood:GetCastRange())
	local castPoint = ArenaOfBlood:GetCastPoint()
	local manaCost  = ArenaOfBlood:GetManaCost()
	local nRadius   = ArenaOfBlood:GetSpecialValueInt("radius")
	local nDamage   = ArenaOfBlood:GetSpecialValueInt('spear_damage')

	local target  = bot:GetTarget()
	local nEnemyHeroes = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE)

	if J.IsRetreating(bot)
	then
		local nAllyHeroes = bot:GetNearbyHeroes(castRange, false, BOT_MODE_ATTACK)

		if nAllyHeroes ~= nil
		and nEnemyHeroes ~= nil
		and #nAllyHeroes > 1
		and #nEnemyHeroes > 0
		and bot:WasRecentlyDamagedByAnyHero(2.0)
		then
			return BOT_ACTION_DESIRE_MODERATE, bot:GetLocation()
		end
	end

	if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), castRange, nRadius / 2, 0, 0)
		local unitCount = J.CountVulnerableUnit(nEnemyHeroes, locationAoE, nRadius, 2)

		if (unitCount >= 2)
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(target)
		and J.CanCastOnNonMagicImmune(target)
		and J.IsInRange(target, bot, castRange)
		and not J.IsCore(target)
		then
			local targetAllies = target:GetNearbyHeroes(2 * nRadius, false, BOT_MODE_NONE)

			if #targetAllies >= 2
			then
				return BOT_ACTION_DESIRE_MODERATE, J.GetProperLocation(target, castPoint)
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

return X