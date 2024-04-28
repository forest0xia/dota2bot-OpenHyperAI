local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local BerserkersCall
local BattleHunger
local CullingBlade

local botTarget

local nMP, hEnemyList, hAllyList

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    nMP = bot:GetMana() / bot:GetMaxMana()
    hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

    if abilityName == 'axe_culling_blade'
    then
        CullingBlade = ability
        CullingBladeDesire, CullingBladeTarget = X.ConsiderCullingBlade()
        if CullingBladeDesire > 0
        then
            bot:Action_UseAbilityOnEntity(CullingBlade, CullingBladeTarget)
            return
        end
    end

    if abilityName == 'axe_berserkers_call'
    then
        BerserkersCall = ability
        BerserkersCallDesire = X.ConsiderBerserkersCall()
        if BerserkersCallDesire > 0
        then
            bot:Action_UseAbility(BerserkersCall)
            return
        end
    end

    if abilityName == 'axe_battle_hunger'
    then
        BattleHunger = ability
        BattleHungerDesire, BattleHungerTarget = X.ConsiderBattleHunger()
        if BattleHungerDesire > 0
        then
            bot:Action_UseAbilityOnEntity(BattleHunger, BattleHungerTarget)
            return
        end
    end
end

function X.ConsiderBerserkersCall()
	if not BerserkersCall:IsFullyCastable() then return 0 end

	local nRadius = BerserkersCall:GetSpecialValueInt( 'radius' )
	local nManaCost = BerserkersCall:GetManaCost()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius - 50 )

	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if npcEnemy:IsChanneling()
			and not npcEnemy:IsMagicImmune()
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nRadius - 90 )
			and J.CanCastOnNonMagicImmune( botTarget )			
			and not J.IsDisabled( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and bot:GetAttackTarget() ~= nil
		and DotaTime() > 6 * 60
		and #hAllyList <= 2 
		and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nRadius - 50, true )
		if #laneCreepList >= 4
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	then
		if J.IsRoshan( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
			and J.IsInRange( botTarget, bot, nRadius )
            and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	

	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderBattleHunger()
	if not BattleHunger:IsFullyCastable() then return 0 end

	local nSkillLV = BattleHunger:GetLevel()
	local nCastRange = J.GetProperCastRange(false, bot, BattleHunger:GetCastRange())
	local nManaCost = BattleHunger:GetManaCost()
	local nDuration = BattleHunger:GetSpecialValueInt( 'duration' )
	local nDamage = BattleHunger:GetSpecialValueInt( 'damage_per_second' ) * nDuration
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )

	for _, npcEnemy in pairs( nInRangeEnemyList )
	do 
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage , nDuration )
			and not npcEnemy:HasModifier( 'modifier_axe_battle_hunger_self' )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	
	end
	
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )			
			and J.CanCastOnTargetAdvanced( botTarget )
			and not botTarget:HasModifier( 'modifier_axe_battle_hunger_self' )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end
	
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 100000

		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_axe_battle_hunger_self' )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				if ( npcEnemyHealth < npcWeakestEnemyHealth )
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = npcEnemy
				end
			end
		end

		if npcWeakestEnemy ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy
		end
	end

	if J.IsLaning( bot ) and nMP > 0.5
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do 
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and npcEnemy:GetAttackTarget() == nil
				and not npcEnemy:HasModifier( 'modifier_axe_battle_hunger_self' )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		
		end	
	end
	
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_axe_battle_hunger_self' )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	if J.IsFarming( bot )
		and nSkillLV >= 2
		and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		local neutralCreepList = bot:GetNearbyNeutralCreeps( nCastRange + 100 )

		local targetCreep = J.GetMostHpUnit( neutralCreepList )

		if J.IsValid( targetCreep )
			and not J.IsRoshan( targetCreep )
			and not targetCreep:HasModifier( 'modifier_axe_battle_hunger_self' )
			and ( targetCreep:GetMagicResist() < 0.3 )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 2.88, DAMAGE_TYPE_PHYSICAL )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep
	    end
	end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	then
		if J.IsRoshan( botTarget )
			and not J.IsDisabled( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and not botTarget:HasModifier( 'modifier_axe_battle_hunger_self' )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderCullingBlade()


	if not CullingBlade:IsFullyCastable() then return 0 end

	local nSkillLV = CullingBlade:GetLevel()
	local nCastRange = J.GetProperCastRange(false, bot, CullingBlade:GetCastRange())

	local nKillDamage = 150 + 100 * nSkillLV

	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )

	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and npcEnemy:CanBeSeen()
			and npcEnemy:GetHealth() + npcEnemy:GetHealthRegen() * 0.8 < nKillDamage
			and not J.IsHaveAegis( npcEnemy )
			and not npcEnemy:IsInvulnerable()
			and not npcEnemy:IsMagicImmune()
			and not X.HasSpecialModifier( npcEnemy )
			and not X.IsKillBotAntiMage( npcEnemy )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.HasSpecialModifier( npcEnemy )

	if npcEnemy:HasModifier( 'modifier_winter_wyvern_winters_curse' )
		or npcEnemy:HasModifier( 'modifier_winter_wyvern_winters_curse_aura' )
		or npcEnemy:HasModifier( 'modifier_antimage_spell_shield' )
		or npcEnemy:HasModifier( 'modifier_item_lotus_orb_active' )
		or npcEnemy:HasModifier( 'modifier_item_aeon_disk_buff' )
		or npcEnemy:HasModifier( 'modifier_item_sphere_target' )
		or npcEnemy:HasModifier( 'modifier_illusion' )
	then
		return true
	else
		return false	
	end

end

function X.IsKillBotAntiMage( npcEnemy )

	if not npcEnemy:IsBot() 
		or npcEnemy:GetUnitName() ~= 'npc_dota_hero_antimage'
		or npcEnemy:IsStunned()
		or npcEnemy:IsHexed()
		or npcEnemy:IsNightmared()
		or npcEnemy:IsChanneling()
		or J.IsTaunted( npcEnemy )
	then
		return false
	end
	
	return true

end

return X