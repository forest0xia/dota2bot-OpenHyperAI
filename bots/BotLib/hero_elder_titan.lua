local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {--pos4,5
                        ['t25'] = {10, 10},
                        ['t20'] = {10, 10},
                        ['t15'] = {10, 10},
                        ['t10'] = {10, 10},
}

local tAllAbilityBuildList = {
    {2,3,2,3,2,3,2,3,6,1,1,1,1,6,6},--pos1
    {2,1,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos3
}


local nAbilityBuildList

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

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
    "item_veil_of_discord",
    "item_shivas_guard",--
	"item_assault",--
	"item_travel_boots",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_heart",--
	"item_travel_boots_2",--
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_3']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_3']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_power_treads",
	"item_quelling_blade",

	"item_vanguard",
	"item_assault",
	"item_magic_wand",
	
	"item_abyssal_blade",
	"item_magic_wand",
	
	"item_assault",
	"item_ancient_janggo",

    "item_quelling_blade",
    "item_bracer",
    "item_soul_ring",
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

local ReturnDesire = 0

local botTarget

local lastCastSpirit = 0 -- fallback to prevent idle
local touchedUnits = { }
bot.theAstralSpirit = nil
local targetTouchUnits = nil

function X.MinionThink(hMinionUnit, aBot)
	if J.Utils.IsUnitWithName(hMinionUnit, 'elder_titan_ancestral_spirit') and SpiritShouldBeAvailable() then
        bot.theAstralSpirit = hMinionUnit

		if EchoStomp:IsInAbilityPhase() or bot:IsChanneling() then bot:Action_ClearActions(false); return end
		if bot:IsUsingAbility() or bot:IsCastingAbility() then return end
		if hMinionUnit:IsUsingAbility() or hMinionUnit:IsCastingAbility() then return end

        if ConsiderEchoStomp(hMinionUnit) > 0 then
            bot:Action_UseAbility(EchoStomp)
            return
        end

		if ConsiderReturnMinion() > 0 then
			bot:Action_UseAbility(ReturnAstralSpirit)
            return
        end
	end

    Minion.MinionThink(hMinionUnit, bot)
end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    local AstralSpiritDesire, AstralSpiritLocation = ConsiderAstralSpirit()
    if AstralSpiritDesire > 0 then
		J.SetQueuePtToINT(bot, false)
		touchedUnits = { }
		lastCastSpirit = DotaTime()
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

	local nCastRange = AstralSpirit:GetSpecialValueInt('AbilityCastRange')
    
	if J.IsValidTarget(botTarget) and (J.IsInTeamFight(bot, 1600) or J.IsGoingOnSomeone(bot) or J.IsPushing(bot))
	then
        if J.IsInRange(bot, botTarget, nCastRange) then
            local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
            if #J.GetHeroesNearLocation(true, targetLoc, 800) >= 1 then
                return BOT_ACTION_DESIRE_HIGH, targetLoc
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

    if targetTouchUnits == nil then
        local nInRangeEnemy = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
        local enemyCreeps = bot:GetNearbyCreeps(1600, true);
        targetTouchUnits = J.Utils.CombineTablesUnique(nInRangeEnemy, enemyCreeps)
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
			and J.CanCastOnNonMagicImmune( botTarget )
			and X.IsWithoutSpellShield( botTarget )
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

	-- there seems to be a bug where the spirit can not be moved, so return it.
    -- if #touchedUnits >= 1 or lastCastSpirit > 2 then
    --     return BOT_ACTION_DESIRE_MODERATE
    -- end

	return BOT_ACTION_DESIRE_NONE
end

function ConsiderEchoStomp(hMinionUnit)
	if not EchoStomp:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end

	local nRadius = EchoStomp:GetSpecialValueInt("radius");
	local nDamage = EchoStomp:GetSpecialValueInt("stomp_damage");

	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
	for _, npcEnemy in pairs(tableNearbyEnemyHeroes) do
		if npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsRetreating(bot)
	then
		for _, npcEnemy in pairs(tableNearbyEnemyHeroes) do
			if bot:WasRecentlyDamagedByHero(npcEnemy, 2)
			then
				if J.CanCastOnNonMagicImmune(npcEnemy)
				then
					return BOT_ACTION_DESIRE_MODERATE
				end
			end
		end
	end

	if J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot) or J.IsPushing(bot) or J.IsDefending(bot)
	then
		local locationAoE = hMinionUnit:FindAoELocation(true, true, hMinionUnit:GetLocation(), 0, nRadius, 0, 0)
		if locationAoE.count >= 3 then
            if bot:GetMana() / bot:GetMaxMana() < 0.7 and J.IsInLaningPhase() then
                return BOT_ACTION_DESIRE_NONE
            end
            return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X