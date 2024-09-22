local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
	{--pos4,5
	['t25'] = {0, 10},
	['t20'] = {10, 0},
	['t15'] = {0, 10},
	['t10'] = {10, 0},
},
	{--pos1,3
	['t25'] = {0, 10},
	['t20'] = {0, 10},
	['t15'] = {10, 0},
	['t10'] = {10, 0},
}
}

local tAllAbilityBuildList = {
    {2,3,2,3,2,3,2,3,6,1,1,1,1,6,6},--pos1
    {2,1,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos3
}


local nAbilityBuildList

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList[1])

if sRole == "pos_1"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
else
    nAbilityBuildList   = tAllAbilityBuildList[2]
end

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_bristleback_outfit",
	"item_blade_mail",--
	"item_heavens_halberd",--
	"item_lotus_orb",--
	"item_black_king_bar",--
	"item_aghanims_shard",
	"item_travel_boots",
	"item_abyssal_blade",--
	-- "item_heart",--
	"item_moon_shard",
    "item_ultimate_scepter_2",
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_3'] = {
	"item_tank_outfit",
	"item_vanguard",
	"item_crimson_guard",--
	"item_aghanims_shard",
	"item_heavens_halberd",--
    "item_shivas_guard",--
	"item_assault",--
	"item_travel_boots",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_heart",--
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = {
	'item_priest_outfit',
	"item_mekansm",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
	"item_lotus_orb",
	"item_gungir",--
	--"item_holy_locket",
	"item_ultimate_scepter",
	"item_sheepstick",
	"item_mystic_staff",
	"item_ultimate_scepter_2",
	"item_shivas_guard",
    "item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
	'item_mage_outfit',
	"item_glimmer_cape",

    "item_pavise",
    "item_solar_crest",--
	"item_lotus_orb",--
	"item_pipe",--
	
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
	"item_travel_boots",
	"item_quelling_blade",

	"item_abyssal_blade",
	"item_magic_wand",
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

local EchoStomp             = bot:GetAbilityByName('elder_titan_echo_stomp')
local AstralSpirit          = bot:GetAbilityByName('elder_titan_ancestral_spirit')
local MoveAstralSpirit      = bot:GetAbilityByName('elder_titan_move_spirit')
local ReturnAstralSpirit    = bot:GetAbilityByName('elder_titan_return_spirit')
local NaturalOrder          = bot:GetAbilityByName('elder_titan_natural_order')
local EarthSplitter         = bot:GetAbilityByName('elder_titan_earth_splitter')

local botTarget

local touchedUnits = { }
bot.theAstralSpirit = nil
local targetTouchUnits = nil
local nEnemyHeroes, nAllyHeroes

function X.MinionThink(hMinionUnit)
	if J.Utils.IsUnitWithName(hMinionUnit, 'elder_titan_ancestral_spirit') and SpiritShouldBeAvailable() then
        bot.theAstralSpirit = hMinionUnit

		if EchoStomp:IsInAbilityPhase() or bot:IsChanneling() then bot:Action_ClearActions(false); return end
		if bot:IsUsingAbility() or bot:IsCastingAbility() then return end
		if hMinionUnit:IsUsingAbility() or hMinionUnit:IsCastingAbility() then return end

        if ConsiderEchoStomp(bot.theAstralSpirit) > 0 then
            bot:Action_UseAbility(EchoStomp)
            return
        end

		if ConsiderReturnMinion() > 0 then
			bot:Action_UseAbility(ReturnAstralSpirit)
            return
        end
	end

    Minion.MinionThink(hMinionUnit)
end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) or bot:IsCastingAbility() or bot:IsChanneling() then return end

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)

    botTarget = J.GetProperTarget(bot)

	if ConsiderEchoStomp(bot) > 0 then
		bot:Action_UseAbility(EchoStomp)
		return
	end

    local AstralSpiritDesire, AstralSpiritLocation = ConsiderAstralSpirit()
    if AstralSpiritDesire > 0 then
		J.SetQueuePtToINT(bot, false)
		touchedUnits = { }
        targetTouchUnits = nil
		bot:ActionQueue_UseAbilityOnLocation(AstralSpirit, AstralSpiritLocation)
    end

    local EarthSplitterDesire, EarthSplitterLocation = ConsiderEarthSplitter()
    if EarthSplitterDesire > 0 then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnLocation(EarthSplitter, EarthSplitterLocation)
    end
	
    local castMoveAstralSpiritDesire, castMoveAstralSpiritLocation = ConsiderMoveAstralSpirit();
	if castMoveAstralSpiritDesire > 0
    then
        bot:Action_UseAbilityOnLocation(MoveAstralSpirit, castMoveAstralSpiritLocation);
        return;
    end
end

function ConsiderAstralSpirit()
	if not AstralSpirit:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    if bot:IsUsingAbility() or bot:IsCastingAbility() then return BOT_ACTION_DESIRE_NONE end
	if bot:HasModifier('modifier_elder_titan_ancestral_spirit_buff') then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = AstralSpirit:GetSpecialValueInt('AbilityCastRange')

	if J.IsValidTarget(botTarget) and (J.IsInTeamFight(bot, 1600) or J.IsGoingOnSomeone(bot) or J.IsPushing(bot))
	then
        if J.IsInRange(bot, botTarget, nCastRange) then
			local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, 500, 0, 0)
			if locationAoE.count >= #nEnemyHeroes - 1 then
                return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
			end
        end
	end
	return BOT_ACTION_DESIRE_NONE
end

function SpiritShouldBeAvailable()
    return not ReturnAstralSpirit:IsHidden() and ReturnAstralSpirit:GetCooldownTimeRemaining() == 0
end

function ConsiderMoveAstralSpirit()
    if not MoveAstralSpirit:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    if not SpiritShouldBeAvailable() then return BOT_ACTION_DESIRE_NONE end
    if bot.theAstralSpirit == nil then return BOT_ACTION_DESIRE_NONE end

    if targetTouchUnits == nil then
        local enemyCreeps = bot:GetNearbyCreeps(1600, true);
        targetTouchUnits = J.Utils.CombineTablesUnique(nEnemyHeroes, enemyCreeps)
    end

    if targetTouchUnits ~= nil then
        if #targetTouchUnits >= 1 and #touchedUnits < #targetTouchUnits then
            for i, enemy in pairs(targetTouchUnits)
            do
                if J.IsValid(enemy)
                and (not J.Utils.HasValue(touchedUnits, enemy))
                and J.Utils.GetLocationToLocationDistance(bot.theAstralSpirit:GetLocation(), enemy:GetLocation()) > 30 then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                else
                    table.remove(targetTouchUnits, i)
                    table.insert(touchedUnits, enemy)
                end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function ConsiderEarthSplitter()
	if not EarthSplitter:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    if bot:IsUsingAbility() or bot:IsCastingAbility() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = EarthSplitter:GetSpecialValueInt('AbilityCastRange')
    local crack_width = 300
    local crack_time = 3.14
    
	if J.IsInTeamFight(bot, 1600) or J.IsGoingOnSomeone(bot) or J.IsPushing(bot)
	then
		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, crack_width, crack_time, 1500)
        if #J.GetHeroesNearLocation(true, locationAoE.targetloc, 800) >= 3 then
            return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
        end

        if J.IsValidHero( botTarget )
			and #nEnemyHeroes >= #nAllyHeroes
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanKillTarget( botTarget, botTarget:GetMaxHealth() * 0.4, DAMAGE_TYPE_MAGICAL )
		then
            local loc = J.GetCorrectLoc(botTarget, crack_time)
			return BOT_ACTION_DESIRE_HIGH, loc
		end

	end
	return BOT_ACTION_DESIRE_NONE
end

function ConsiderReturnMinion()
    if bot:IsUsingAbility() or bot:IsCastingAbility() then return BOT_ACTION_DESIRE_NONE end

    if targetTouchUnits ~= nil and #touchedUnits >= #targetTouchUnits * 0.7 then
        return BOT_ACTION_DESIRE_HIGH
    end

	return BOT_ACTION_DESIRE_NONE
end

function ConsiderEchoStomp(eveluator)
	if not EchoStomp:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end

	local nRadius = EchoStomp:GetSpecialValueInt("radius");
	local nDamage = EchoStomp:GetSpecialValueInt("stomp_damage");

	if eveluator == nil then eveluator = bot end
	local nInEchoRangeEnemyHeroes = eveluator:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

	for _, npcEnemy in pairs(nInEchoRangeEnemyHeroes) do
		if npcEnemy:IsChanneling() -- 打断技能
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if #nInEchoRangeEnemyHeroes >= 3 then
        return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsRetreating(bot)
	then
		for _, npcEnemy in pairs(nInEchoRangeEnemyHeroes) do
			if J.IsValidHero(npcEnemy) and bot:WasRecentlyDamagedByHero(npcEnemy, 2)
			then
				if J.CanCastOnNonMagicImmune(npcEnemy)
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

	if J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot) or J.IsPushing(bot) or J.IsDefending(bot)
	then
		if J.IsValidHero(botTarget)
		and J.IsChasingTarget(bot, botTarget)
		and J.IsInRange(eveluator, botTarget, nRadius) then
			return BOT_ACTION_DESIRE_HIGH
		end

		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 0, nRadius, 0, 0)
		if locationAoE.count >= 3 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X