local J = {}

local bDebugMode = ( 1 == 10 )
local tAllyIDList = GetTeamPlayers( GetTeam() )
local tAllyHeroList = {}
local tAllyHumanList = {}

local RadiantFountain = Vector( -6619, -6336, 384 )
local DireFountain = Vector( 6928, 6372, 392 )
local roshanRadiantLoc  = Vector(7625, -7511, 1092)
local roshanDireLoc = Vector(-7549, 7562, 1107)
local RadiantTormentorLoc = Vector(-8075, -1148, 1000)
local DireTormentorLoc = Vector(8132, 1102, 1000)

local fKeepManaPercent = 0.39

for i, id in pairs( tAllyIDList )
do

	local bHuman = not IsPlayerBot( id )
	local hHero = GetTeamMember( i )

	if hHero ~= nil
	then
		if bHuman then table.insert( tAllyHumanList, hHero ) end
		table.insert( tAllyHeroList, hHero )
	end

end

J.Site = require( GetScriptDirectory()..'/FunLib/aba_site' )
J.Item = require( GetScriptDirectory()..'/FunLib/aba_item' )
J.Buff = require( GetScriptDirectory()..'/FunLib/aba_buff' )
J.Role = require( GetScriptDirectory()..'/FunLib/aba_role' )
J.Skill = require( GetScriptDirectory()..'/FunLib/aba_skill' )
J.Chat = require( GetScriptDirectory()..'/FunLib/aba_chat' )
J.Utils = require( GetScriptDirectory()..'/FunLib/utils' )


function J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, sBuyList, sSellList )
	-- A place to change the bot setup.
	local bot = GetBot()
	local botName = bot:GetUnitName()
	local sBotDir, tBotSet = GetScriptDirectory() .. "/Customize/hero/" .. string.gsub(botName, "npc_dota_hero_", ""), nil
	local status, _ = xpcall(function() tBotSet = require( sBotDir ) end, function( err ) print( '[WARN] When loading customzed file: '..err ) end )
	if status and tBotSet and tBotSet.Enable then
		nAbilityBuildList = tBotSet.AbilityUpgrade
		nTalentBuildList = J.GetTalentBuildList( tBotSet.Talent )
		sBuyList = tBotSet.PurchaseList
		sSellList = tBotSet.SellList
	end
	return nAbilityBuildList, nTalentBuildList, sBuyList, sSellList
end

function J.GetTalentBuildList( nLocalList )
	local sTargetList = {}
	for i = 1, #nLocalList
    do
		local rawTalent = nLocalList[i] == 'l' and 10 or 0
		if rawTalent == 10
		then
			sTargetList[#sTargetList + 1] = i * 2
		else
			sTargetList[#sTargetList + 1] = i * 2 - 1
		end
	end
	for i = 1, #nLocalList
    do
		local rawTalent = nLocalList[i] == 'r' and 10 or 0
		if rawTalent ~= 10
		then
			sTargetList[#sTargetList + 1] = i * 2
		else
			sTargetList[#sTargetList + 1] = i * 2 - 1
		end
	end
	return sTargetList
end

function J.HasQueuedAction( bot )
	if bot ~= GetBot()
	then
		return false
	end
	return bot:NumQueuedActions() > 0
end

function J.IsTryingtoUseAbility(bot)
	return bot:IsCastingAbility()
	or bot:IsUsingAbility()
	or bot:IsChanneling()
end

function J.CanNotUseAction( bot )

	return not bot:IsAlive()
			or J.HasQueuedAction( bot )
			or bot:IsInvulnerable()
			or bot:IsCastingAbility()
			or bot:IsUsingAbility()
			or bot:IsChanneling()
			or bot:IsStunned()
			or bot:IsNightmared()
			or bot:HasModifier( 'modifier_ringmaster_the_box_buff' )
			or bot:HasModifier( 'modifier_item_forcestaff_active' )
			or bot:HasModifier( 'modifier_phantom_lancer_phantom_edge_boost' )
			or bot:HasModifier( 'modifier_tinker_rearm' )

end

function J.CanNotUseAbility( bot )

	return not bot:IsAlive()
			or J.HasQueuedAction( bot )
			or bot:IsInvulnerable()
			or bot:IsCastingAbility()
			or bot:IsUsingAbility()
			or bot:IsChanneling()
			or bot:IsSilenced()
			or bot:IsStunned()
			or bot:IsHexed()
			or bot:IsNightmared()
			or bot:HasModifier( 'modifier_ringmaster_the_box_buff' )
			or bot:HasModifier( "modifier_doom_bringer_doom" )
			or bot:HasModifier( 'modifier_item_forcestaff_active' )

end


local TempMovableModifierNames = {
    'modifier_abaddon_borrowed_time',
    'modifier_dazzle_shallow_grave',
    'modifier_wind_waker', -- movability depends on whether who uses the item.
    'modifier_item_wind_waker',
    'modifier_oracle_false_promise_timer',
    'modifier_item_aeon_disk_buff'
}
local MovableUndyingModifierRemain = 0

-- check if the target will still have at least one movable undying modifier after nDelay seconds.
function J.HasMovableUndyingModifier(botTarget, nDelay)
    for _, mName in pairs(TempMovableModifierNames)
    do
        if botTarget:HasModifier(mName) then
            MovableUndyingModifierRemain = J.GetModifierTime(botTarget, mName)
            -- print(DotaTime().." - Target has undying modifier "..mName..", the remaining time: " .. tostring(MovableUndyingModifierRemain) .. " seconds, check delay: "..tostring(nDelay))
            if MovableUndyingModifierRemain > 0 then
				if DotaTime() < DotaTime() + MovableUndyingModifierRemain - nDelay then
					return true
				end
				return false
            end
        end
    end
    return false
end


--友军生物数量
function J.GetUnitAllyCountAroundEnemyTarget( target, nRadius )

	local targetLoc = target:GetLocation()
	local heroCount = J.GetNearbyAroundLocationUnitCount( false, true, nRadius, targetLoc )
	local creepCount = J.GetNearbyAroundLocationUnitCount( false, false, nRadius, targetLoc )

	return heroCount + creepCount

end


--敌军生物数量
function J.GetAroundTargetEnemyUnitCount( target, nRadius )
	local targetLoc = target:GetLocation()
	return J.GetAroundTargetLocEnemyUnitCount( targetLoc, nRadius )
end

function J.GetAroundTargetLocEnemyUnitCount( targetLoc, nRadius )
	local heroCount = J.GetNearbyAroundLocationUnitCount( true, true, nRadius, targetLoc )
	local creepCount = J.GetNearbyAroundLocationUnitCount( true, false, nRadius, targetLoc )
	return heroCount + creepCount
end

--敌军英雄数量
function J.GetAroundTargetEnemyHeroCount( target, nRadius )

	return J.GetNearbyAroundLocationUnitCount( true, true, nRadius, target:GetLocation() )

end


--通用数量
function J.GetNearbyAroundLocationUnitCount( bEnemy, bHero, nRadius, vLoc )
	local cacheKey = tostring(bEnemy)..'-'..tostring(bHero)..'-'..tostring(nRadius)..'-'..tostring(vLoc.x)..'-'..tostring(vLoc.y)
	local cache = J.Utils.GetCachedVars('GetNearbyAroundLocationUnitCount'..cacheKey, 0.5)
	if cache ~= nil then return cache end

	local nCount = 0

	if bHero
	then
		if bEnemy then
			nCount = #J.GetEnemiesNearLoc(vLoc, nRadius)
		else
			nCount = #J.GetAlliesNearLoc( vLoc, nRadius )
		end
	else
		if bEnemy then
			for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
			do
				if J.IsValid(unit)
				and GetUnitToLocationDistance(unit, vLoc) <= nRadius
				then
					nCount = nCount + 1
				end
			end
		else
			for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
			do
				if J.IsValid(unit)
				and GetUnitToLocationDistance(unit, vLoc) <= nRadius
				then
					nCount = nCount + 1
				end
			end
		end
	end

	J.Utils.SetCachedVars('GetNearbyAroundLocationUnitCount'..cacheKey, nCount)
	return nCount

end


function J.GetAttackEnemysAllyCreepCount( target, nRadius )

	local bot = GetBot()
	local nAllyCreeps = bot:GetNearbyCreeps( nRadius, false )
	local nAttackEnemyCount = 0
	for _, creep in pairs( nAllyCreeps )
	do
		if creep:IsAlive()
			and creep:CanBeSeen()
			and creep:GetAttackTarget() == target
		then
			nAttackEnemyCount = nAttackEnemyCount + 1
		end
	end

	return nAttackEnemyCount

end

function J.GetVulnerableWeakestUnit( bot, bHero, bEnemy, nRadius )
	local unitList = {}
	if bHero
	then
		unitList = J.GetNearbyHeroes(bot, nRadius, bEnemy, BOT_MODE_NONE )
	else
		unitList = bot:GetNearbyLaneCreeps( nRadius, bEnemy )
	end
    return J.GetAttackableWeakestUnitFromList( bot, unitList )
end


function J.GetVulnerableUnitNearLoc( bot, bHero, bEnemy, nCastRange, nRadius, vLoc )

	local unitList = {}
	local weakest = nil
	local weakestHP = 10000

	if bHero
	then
		unitList = J.GetNearbyHeroes(bot, nCastRange, bEnemy, BOT_MODE_NONE )
	else
		unitList = bot:GetNearbyLaneCreeps( nCastRange, bEnemy )
	end

	for _, u in pairs( unitList )
	do
		if GetUnitToLocationDistance( u, vLoc ) < nRadius
			and u:GetHealth() < weakestHP
			and J.CanCastOnNonMagicImmune( u )
		then
			weakest = u
			weakestHP = u:GetHealth()
		end
	end

	return weakest

end


function J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, nCount )

	local nAoe = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )

	if nAoe.count >= nCount
	then
		local nEnemyHeroList = J.GetEnemyList( bot, 1600 )
		local nTrueCount = 0
		for _, enemy in pairs( nEnemyHeroList )
		do
			if GetUnitToLocationDistance( enemy, nAoe.targetloc ) <= nRadius
				and not enemy:IsMagicImmune()
			then
				nTrueCount = nTrueCount + 1
			end
		end

		if nTrueCount >= nCount
		then
			return nAoe.targetloc
		end
	end

	return nil

end


function J.IsWithoutTarget( bot )

	return bot:CanBeSeen()
			and bot:GetAttackTarget() == nil
			and ( bot:GetTeam() == GetBot():GetTeam() and bot:GetTarget() == nil ) 
end


function J.GetProperTarget( bot )

	local target = nil
	
	if ( bot:GetTeam() == GetBot():GetTeam() )
	then
		target = bot:GetTarget()
	end

	if target == nil and bot:CanBeSeen()
	then
		target = bot:GetAttackTarget()
	end

	if target ~= nil
		and target:GetTeam() == bot:GetTeam()
		and ( target:IsHero() or target:IsBuilding() )
	then
		target = nil
	end

	return target

end


function J.IsAllyCanKill( target )

	if target:GetHealth() / target:GetMaxHealth() > 0.38
	then
		return false
	end

	local nTotalDamage = 0
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nTeamMember = GetTeamPlayers( GetTeam() )
	for i = 1, #nTeamMember
	do
		local ally = GetTeamMember( i )
		if ally ~= nil and ally:IsAlive() and ally:CanBeSeen()
			and ( ally:GetAttackTarget() == target )
			and GetUnitToUnitDistance( ally, target ) <= ally:GetAttackRange() + 50
		then
			nTotalDamage = nTotalDamage + ally:GetAttackDamage()
		end
	end

	nTotalDamage = nTotalDamage * 2.44 + J.GetAttackProjectileDamageByRange( target, 1200 )

	if J.CanKillTarget( target, nTotalDamage, nDamageType )
	then
		return true
	end

	return false

end


function J.IsOtherAllyCanKillTarget( bot, target )
	if not J.IsValid(target) then
		return false
	end

	if target:GetHealth() / target:GetMaxHealth() > 0.38
	then
		return false
	end

	local nTotalDamage = 0
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nTeamMember = GetTeamPlayers( GetTeam() )

	for i = 1, #nTeamMember
	do
		local ally = GetTeamMember( i )
		if J.IsValidTarget(ally)
			and ally ~= bot
			and not J.IsDisabled( ally )
			and ally:GetHealth() / ally:GetMaxHealth() > 0.15
			and ally:IsFacingLocation( target:GetLocation(), 20 )
			and GetUnitToUnitDistance( ally, target ) <= ally:GetAttackRange() + 50
		then
			local allyTarget = J.GetProperTarget( ally )
			if allyTarget == nil or allyTarget == target or J.IsHumanPlayer( ally )
			then
				local allyDamageTime = J.IsHumanPlayer( ally ) and 6.0 or 2.0
				nTotalDamage = nTotalDamage + ally:GetEstimatedDamageToTarget( true, target, allyDamageTime, DAMAGE_TYPE_PHYSICAL )
			end
		end
	end

	if nTotalDamage > target:GetHealth()
	then
		return true
	end

	return false
end


function J.GetRetreatingAlliesNearLoc( vLoc, nRadius )

	local allies = {}
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member:IsAlive()
			and GetUnitToLocationDistance( member, vLoc ) <= nRadius
			and J.IsRetreating( member )
		then
			table.insert( allies, member )
		end
	end

	return allies

end

function J.GetAlliesNearLoc( vLoc, nRadius )

	local allies = {}
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member:IsAlive()
			and GetUnitToLocationDistance( member, vLoc ) <= nRadius
		then
			table.insert( allies, member )
		end
	end

	return allies

end

function J.GetEnemiesNearLoc(vLoc, nRadius)
	local enemies = {}
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and GetUnitToLocationDistance(enemyHero, vLoc) <= nRadius
		and not J.IsSuspiciousIllusion(enemyHero)
		and not J.IsMeepoClone(enemyHero)
		and not enemyHero:HasModifier('modifier_arc_warden_tempest_double')
		then
			table.insert(enemies, enemyHero)
		end
	end

	return enemies
end

function J.GetAnyEnemiesNearLoc(vLoc, nRadius)
	local enemies = {}
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and GetUnitToLocationDistance(enemyHero, vLoc) <= nRadius
		then
			table.insert(enemies, enemyHero)
		end
	end

	return enemies
end

function J.GetIllusionsNearLoc(vLoc, nRadius)
	local illusions = {}
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and GetUnitToLocationDistance(enemyHero, vLoc) <= nRadius
		and J.IsSuspiciousIllusion(enemyHero)
		and not J.IsMeepoClone(enemyHero)
		then
			table.insert(illusions, enemyHero)
		end
	end

	return illusions
end


function J.IsAllyHeroBetweenAllyAndEnemy( hAlly, hEnemy, vLoc, nRadius )

	local vStart = hAlly:GetLocation()
	local vEnd = vLoc
	local heroList = J.GetNearbyHeroes( hAlly, 1600, false, BOT_MODE_NONE )
	for i, hero in pairs( heroList )
	do
		if hero ~= hAlly
		then
			local tResult = PointToLineDistance( vStart, vEnd, hero:GetLocation() )
			if tResult ~= nil
				and tResult.within
				and tResult.distance <= nRadius + 50
			then
				return true
			end
		end
	end

	heroList = J.GetNearbyHeroes( hEnemy, 1600, true, BOT_MODE_NONE )
	for i, hero in pairs( heroList )
	do
		if hero ~= hAlly
		then
			local tResult = PointToLineDistance( vStart, vEnd, hero:GetLocation() )
			if tResult ~= nil
				and tResult.within
				and tResult.distance <= nRadius + 50
			then
				return true
			end
		end
	end

	return false

end

function J.IsUnderLongDurationStun(enemyHero)
    return enemyHero:HasModifier('modifier_bane_fiends_grip')
    or enemyHero:HasModifier('modifier_legion_commander_duel')
    or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
    or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
    or enemyHero:HasModifier('modifier_magnataur_reverse_polarity')
    or enemyHero:HasModifier('modifier_tidehunter_ravage')
	or enemyHero:HasModifier('modifier_winter_wyvern_winters_curse_aura')
end

function J.GetUltimateAbility( bot )

	return bot:GetAbilityInSlot( 5 )

end


function J.CanUseRefresherShard( bot )

	local ult = J.GetUltimateAbility( bot )

	if ult ~= nil
		and ult:IsPassive() == false
	then
		local ultCD = ult:GetCooldown()
		local manaCost = ult:GetManaCost()
		local ultInCooldownAtLeast = 2 -- don't directly use refresh if the ult was just use.

		if bot:GetMana() >= manaCost * 2
			and ult:GetCooldownTimeRemaining() >= ultCD / 2
			and ultCD - ult:GetCooldownTimeRemaining() >= ultInCooldownAtLeast
		then
			return true
		end
	end

	return false

end


function J.GetMostUltimateCDUnit()

	local unit = nil
	local maxCD = 0
	for i, id in pairs( GetTeamPlayers( GetTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local member = GetTeamMember( i )
			if member ~= nil and member:IsAlive()
				and member:GetUnitName() ~= "npc_dota_hero_nevermore"
				and member:GetUnitName() ~= "npc_dota_hero_arc_warden"
			then
				if member:GetUnitName() == "npc_dota_hero_silencer" or member:GetUnitName() == "npc_dota_hero_warlock"
				then
					return member
				end
				local ult = J.GetUltimateAbility( member )
				if ult ~= nil
					and ult:IsPassive() == false
					and ult:GetCooldown() >= maxCD
				then
					unit = member
					maxCD = ult:GetCooldown()
				end
			end
		end
	end

	return unit

end


function J.GetPickUltimateScepterUnit()

	local unit = nil
	local maxNetWorth = 0
	for i, id in pairs( GetTeamPlayers( GetTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local member = GetTeamMember( i )
			if member ~= nil and member:IsAlive()
				and not member:HasScepter()
				and ( member:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
					 or not member:IsBot() )
			then
				if not member:IsBot()
				then
					return member
				end

				if member:GetUnitName() ~= "npc_dota_hero_warlock"
					and member:GetUnitName() ~= "npc_dota_hero_zuus"
					and ( member:GetItemInSlot( 8 ) == nil or member:GetItemInSlot( 7 ) == nil )
				then
					local mNetWorth = member:GetNetWorth()
					if mNetWorth >= maxNetWorth
					then
						unit = member
						maxNetWorth = mNetWorth
					end
				end
			end
		end
	end

	return unit

end


function J.CanUseRefresherOrb( bot )

	local ult = J.GetUltimateAbility( bot )

	if ult ~= nil
		and ult:IsPassive() == false
	then
		local ultCD = ult:GetCooldown()
		local manaCost = ult:GetManaCost()
		if bot:GetMana() >= manaCost + 375
			and ult:GetCooldownTimeRemaining() >= ultCD / 2
		then
			return true
		end
	end

	return false
end


function J.IsSuspiciousIllusion( npcTarget )

	if npcTarget:CanBeSeen() and (
		not npcTarget:IsHero()
		or npcTarget:IsCastingAbility()
		or npcTarget:IsUsingAbility()
		or npcTarget:IsChanneling()
	)
		-- or npcTarget:HasModifier( "modifier_item_satanic_unholy" )
		-- or npcTarget:HasModifier( "modifier_item_mask_of_madness_berserk" )
		-- or npcTarget:HasModifier( "modifier_black_king_bar_immune" )
		-- or npcTarget:HasModifier( "modifier_rune_doubledamage" )
		-- or npcTarget:HasModifier( "modifier_rune_regen" )
		-- or npcTarget:HasModifier( "modifier_rune_haste" )
		-- or npcTarget:HasModifier( "modifier_rune_arcane" )
		-- or npcTarget:HasModifier( "modifier_item_phase_boots_active" )
	then
		return false
	end

	local bot = GetBot()

	if npcTarget:GetTeam() == bot:GetTeam()
	then
		return npcTarget:IsIllusion() or npcTarget:HasModifier( "modifier_arc_warden_tempest_double" )
	elseif npcTarget:GetTeam() == GetOpposingTeam()
	then

		if npcTarget:HasModifier( 'modifier_illusion' )
		or npcTarget:HasModifier( 'modifier_darkseer_wallofreplica_illusion' )
		or npcTarget:HasModifier( 'modifier_phantom_lancer_doppelwalk_illusion' )
		or npcTarget:HasModifier( 'modifier_phantom_lancer_juxtapose_illusion' )
		or npcTarget:HasModifier( 'modifier_skeleton_king_reincarnation_scepter_active' )
		or npcTarget:HasModifier( 'modifier_terrorblade_conjureimage' )
		then
			return true
		end

		local tID = npcTarget:GetPlayerID()

		if not IsHeroAlive( tID )
		then
			return true
		end

		if GetHeroLevel( tID ) > npcTarget:GetLevel()
		then
			return true
		end
		--[[
		if GetSelectedHeroName( tID ) ~= "npc_dota_hero_morphling"
			and GetSelectedHeroName( tID ) ~= npcTarget:GetUnitName()
		then
			return true
		end
		--]]
	end

	return false

end


function J.CanCastAbilityOnTarget( npcTarget, bIgnoreMagicImmune )

	return npcTarget:CanBeSeen()
			and ( bIgnoreMagicImmune or not npcTarget:IsMagicImmune() )
			and not npcTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcTarget )
			and not J.HasForbiddenModifier( npcTarget )
			-- and not J.IsAllyCanKill( npcTarget )

end

function J.CanCastAbility(ability)
	if ability == nil
	or ability:IsNull()
	or ability:IsPassive()
	or ability:IsHidden()
	or not ability:IsTrained()
	or not ability:IsFullyCastable()
	or not ability:IsActivated()
	then
		return false
	end

	return true
end

function J.IsTier1(tower)
	local nTower = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
	}

	for i = 1, #nTower do if GetTower( GetTeam(), nTower[i] ) == tower then return true end end

	return false
end

function J.IsTier2(tower)
	local nTower = {
		TOWER_TOP_2,
		TOWER_MID_2,
		TOWER_BOT_2,
	}

	for i = 1, #nTower do if GetTower( GetTeam(), nTower[i] ) == tower then return true end end

	return false
end

function J.IsTier3p(tower)
	local nTower = {
		TOWER_TOP_3,
		TOWER_MID_3,
		TOWER_BOT_3,
		TOWER_BASE_1,
		TOWER_BASE_2,
	}

	for i = 1, #nTower do if GetTower( GetTeam(), nTower[i] ) == tower then return true end end

	return false
end

function J.CanBlinkDagger(bot)
    local blink = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if item ~= nil
        and (item:GetName() == "item_blink" or item:GetName() == "item_overwhelming_blink" or item:GetName() == "item_arcane_blink" or item:GetName() == "item_swift_blink")
        then
			blink = item
			break
		end
	end

    if blink ~= nil and blink:IsFullyCastable()
	then
        bot.Blink = blink
        return true
	end

    return false
end

function J.CanBlackKingBar(bot)
    local bkb = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if item ~= nil and item:GetName() == "item_black_king_bar"
        then
			bkb = item
			break
		end
	end

    if bkb ~= nil and bkb:IsFullyCastable()
	then
        bot.BlackKingBar = bkb
        return true
	end

    return false
end

function J.CanCastOnMagicImmune( npcTarget )

	return npcTarget:CanBeSeen()
			and not npcTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcTarget )
			and not J.HasForbiddenModifier( npcTarget )
			-- and not J.IsAllyCanKill( npcTarget )

end


function J.CanCastOnNonMagicImmune( npcTarget )

	return npcTarget:CanBeSeen()
			and not npcTarget:IsMagicImmune()
			and not npcTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcTarget )
			and not J.HasForbiddenModifier( npcTarget )

end

function J.IsInEtherealForm( npcTarget )
	return npcTarget:HasModifier( "modifier_ghost_state" )
    or npcTarget:HasModifier( "modifier_item_ethereal_blade_ethereal" )
    or npcTarget:HasModifier( "modifier_necrolyte_death_seeker" )
    or npcTarget:HasModifier( "modifier_necrolyte_sadist_active" )
    or npcTarget:HasModifier( "modifier_pugna_decrepify" )
end

function J.CanCastOnTargetAdvanced( npcTarget )

	if npcTarget:GetUnitName() == 'npc_dota_hero_antimage' --and npcTarget:IsBot()
	then

		if npcTarget:HasModifier( "modifier_antimage_spell_shield" )
			and J.GetModifierTime( npcTarget, "modifier_antimage_spell_shield" ) > 0.27
		then
			return false
		end

		if npcTarget:IsSilenced()
			or npcTarget:IsStunned()
			or npcTarget:IsHexed()
			or npcTarget:IsNightmared()
			or npcTarget:IsChanneling()
			or J.IsTaunted( npcTarget )
			or npcTarget:GetMana() < 45
			or ( npcTarget:HasModifier( "modifier_antimage_spell_shield" )
				and J.GetModifierTime( npcTarget, "modifier_antimage_spell_shield" ) < 0.27 )
		then
			if not npcTarget:HasModifier( "modifier_item_sphere_target" )
				and not npcTarget:HasModifier( "modifier_item_lotus_orb_active" )
				and not npcTarget:HasModifier( "modifier_item_aeon_disk_buff" )
				and ( not npcTarget:HasModifier( "modifier_dazzle_shallow_grave" ) or npcTarget:GetHealth() > 300 )
			then
				return true
			end
		end

		return false
	end

	return not npcTarget:HasModifier( "modifier_item_sphere_target" )
			and not npcTarget:HasModifier( "modifier_antimage_spell_shield" )
			and not npcTarget:HasModifier( "modifier_item_lotus_orb_active" )
			and not npcTarget:HasModifier( "modifier_item_aeon_disk_buff" )
			and ( not npcTarget:HasModifier( "modifier_dazzle_shallow_grave" ) or npcTarget:GetHealth() > 300 )

end

--加入时间后的进阶函数
function J.CanCastUnitSpellOnTarget( npcTarget, nDelay )

	for _, modifier in pairs( J.Buff["hero_has_spell_shield"] )
	do
		if npcTarget:HasModifier( modifier )
			and J.GetModifierTime( npcTarget, modifier ) >= nDelay
		then
			return false
		end
	end

	return true

end


function J.CanKillTarget( npcTarget, dmg, dmgType )
	if dmgType == DAMAGE_TYPE_PURE then
		return dmg >= npcTarget:GetHealth()
	end

	return npcTarget:GetActualIncomingDamage( dmg, dmgType ) >= npcTarget:GetHealth()

end


--未计算技能增强
function J.WillKillTarget( npcTarget, dmg, dmgType, nDelay )

	local targetHealth = npcTarget:GetHealth() + npcTarget:GetHealthRegen() * nDelay + 0.8

	local nRealBonus = J.GetTotalAttackWillRealDamage( npcTarget, nDelay )

	local nTotalDamage = npcTarget:GetActualIncomingDamage( dmg, dmgType ) + nRealBonus

	return nTotalDamage > targetHealth and nRealBonus < targetHealth - 1

end


--未计算技能增强
function J.WillMixedDamageKillTarget( npcTarget, nPhysicalDamge, nMagicalDamage, nPureDamage, nDelay )

	local targetHealth = npcTarget:GetHealth() + npcTarget:GetHealthRegen() * nDelay + 0.8

	local nRealBonus = J.GetTotalAttackWillRealDamage( npcTarget, nDelay )

	local nRealPhysicalDamge = npcTarget:GetActualIncomingDamage( nPhysicalDamge, DAMAGE_TYPE_PHYSICAL )

	local nRealMagicalDamge = npcTarget:GetActualIncomingDamage( nMagicalDamage, DAMAGE_TYPE_MAGICAL )

	local nRealPureDamge = npcTarget:GetActualIncomingDamage( nPureDamage, DAMAGE_TYPE_PURE )

	local nTotalDamage = nRealPhysicalDamge + nRealMagicalDamge + nRealPureDamge + nRealBonus

	return nTotalDamage > targetHealth and nRealBonus < targetHealth - 1

end

--计算了技能增强
function J.WillMagicKillTarget( bot, npcTarget, dmg, nDelay )

	local nDamageType = DAMAGE_TYPE_MAGICAL

	local MagicResistReduce = 1 - npcTarget:GetMagicResist()

	if MagicResistReduce < 0.05 then MagicResistReduce = 0.05 end

	local HealthBack = npcTarget:GetHealthRegen() * nDelay

	local EstDamage = dmg * ( 1 + bot:GetSpellAmp() ) - HealthBack / MagicResistReduce

	if npcTarget:HasModifier( "modifier_medusa_mana_shield" )
	then
		local EstDamageMaxReduce = EstDamage * 0.98
		if npcTarget:GetMana() * 2.8 >= EstDamageMaxReduce
		then
			EstDamage = EstDamage * 0.04
		else
			EstDamage = EstDamage * 0.02 + EstDamageMaxReduce - npcTarget:GetMana() * 2.8
		end
	end

	if npcTarget:GetUnitName() == "npc_dota_hero_bristleback"
		and not npcTarget:IsFacingLocation( bot:GetLocation(), 120 )
	then
		EstDamage = EstDamage * 0.7
	end

	if npcTarget:HasModifier( "modifier_kunkka_ghost_ship_damage_delay" )
	then
		local buffTime = J.GetModifierTime( npcTarget, "modifier_kunkka_ghost_ship_damage_delay" )
		if buffTime >= nDelay then EstDamage = EstDamage * 0.55 end
	end

	if npcTarget:HasModifier( "modifier_templar_assassin_refraction_absorb" )
	then
		local buffTime = J.GetModifierTime( npcTarget, "modifier_templar_assassin_refraction_absorb" )
		if buffTime >= nDelay then EstDamage = 0 end
	end

	local nRealDamage = npcTarget:GetActualIncomingDamage( EstDamage, nDamageType )

	return nRealDamage >= npcTarget:GetHealth() --, nRealDamage

end


function J.HasForbiddenModifier( npcTarget )

	for _, mod in pairs( J.Buff['enemy_is_immune'] )
	do
		if npcTarget:HasModifier( mod )
		then
			return true
		end
	end

	if npcTarget:IsHero()
	then
		local enemies = J.GetNearbyHeroes(npcTarget, 800, false, BOT_MODE_NONE )
		if enemies ~= nil and #enemies >= 2
		then
			for _, mod in pairs( J.Buff['enemy_is_undead'] )
			do
				if npcTarget:HasModifier( mod )
				then
					return true
				end
			end
		end
		
		if not npcTarget:IsBot()
		then
			
			local nID = npcTarget:GetPlayerID()
			local nKillCount = GetHeroKills( nID )
			local nDeathCount = GetHeroDeaths( nID )
			
			if nDeathCount >= 6 
				and nKillCount <= 6
				and nKillCount / nDeathCount <= 0.5
			then
				return true
			end
		
		end
		
	else
		if npcTarget:HasModifier( "modifier_crystal_maiden_frostbite" )
			or npcTarget:HasModifier( "modifier_fountain_glyph" )
		then
			return true
		end
	end
	
	return false
end


function J.ShouldEscape( bot )

	local tableNearbyAttackAllies = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_ATTACK )

	if #tableNearbyAttackAllies > 0 and J.GetHP( bot ) > 0.16 then return false end

	local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE )
	if bot:WasRecentlyDamagedByAnyHero( 2.0 )
		or bot:WasRecentlyDamagedByTower( 2.0 )
		or #tableNearbyEnemyHeroes >= 2
	then
		return true
	end
end


function J.IsDisabled( npcTarget )

	if npcTarget:GetTeam() ~= GetTeam() and npcTarget:CanBeSeen()
	then
		return npcTarget:IsRooted()
				or npcTarget:IsStunned()
				or npcTarget:IsHexed()
				or npcTarget:IsNightmared()
				or J.IsTaunted( npcTarget )
	else

		if npcTarget:IsStunned() and J.GetRemainStunTime( npcTarget ) > 0.8
		then
			return true
		end

		if npcTarget:IsSilenced()
			and not npcTarget:HasModifier( "modifier_item_mask_of_madness_berserk" )
			and J.IsWithoutTarget( npcTarget )
		then
			return true
		end

		return npcTarget:IsRooted()
				or npcTarget:IsHexed()
				or npcTarget:IsNightmared()
				or J.IsTaunted( npcTarget )

	end

end


function J.IsTaunted( npcTarget )
	if not npcTarget:CanBeSeen() then
		return false
	end

	return npcTarget:HasModifier( "modifier_axe_berserkers_call" )
		or npcTarget:HasModifier( "modifier_legion_commander_duel" )
		or npcTarget:HasModifier( "modifier_winter_wyvern_winters_curse" )
		or npcTarget:HasModifier( "modifier_winter_wyvern_winters_curse_aura" )

end


function J.IsInRange( bot, npcTarget, nRadius )
	if npcTarget == nil or not npcTarget:CanBeSeen() then
		return false
	end

	return GetUnitToUnitDistance( bot, npcTarget ) <= nRadius

end


function J.IsInLocRange( npcTarget, nLoc, nRadius )
	if not npcTarget:CanBeSeen() then
		return false
	end

	return GetUnitToLocationDistance( npcTarget, nLoc ) <= nRadius

end


function J.IsInTeamFight( bot, nRadius )

	if nRadius == nil or nRadius > 1600 then nRadius = 1600 end

	local attackModeAllyList = J.GetNearbyHeroes(bot, nRadius, false, BOT_MODE_ATTACK )

	return #attackModeAllyList >= 2 -- and bot:GetActiveMode() ~= BOT_MODE_RETREAT

end


function J.IsRetreating( bot )

	local mode = bot:GetActiveMode()
	local modeDesire = bot:GetActiveModeDesire()
	local bDamagedByAnyHero = bot:WasRecentlyDamagedByAnyHero( 2.0 )

	return ( mode == BOT_MODE_RETREAT and modeDesire > BOT_MODE_DESIRE_MODERATE and bot:DistanceFromFountain() > 0 )
		 or ( mode == BOT_MODE_EVASIVE_MANEUVERS and bDamagedByAnyHero )
		 or ( bot:HasModifier( 'modifier_bloodseeker_rupture' ) and bDamagedByAnyHero )
		 or ( mode == BOT_MODE_FARM and modeDesire > BOT_MODE_DESIRE_ABSOLUTE )
		
end


function J.IsGoingOnSomeone( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_ROAM
		or mode == BOT_MODE_TEAM_ROAM
		or mode == BOT_MODE_GANK
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY

end

function J.IsDefending( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT

end

function J.IsAnyAllyDefending(bot, lane)
	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and J.IsNotSelf(bot, allyHero)
		then
			local mode = allyHero:GetActiveMode()
			if (mode == BOT_MODE_DEFEND_TOWER_TOP and lane == LANE_TOP)
			or (mode == BOT_MODE_DEFEND_TOWER_MID and lane == LANE_MID)
			or (mode == BOT_MODE_DEFEND_TOWER_BOT and lane == LANE_BOT)
			then
				return true
			end
		end
	end
	return false
end

function J.IsPushing( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_PUSH_TOWER_TOP
		or mode == BOT_MODE_PUSH_TOWER_MID
		or mode == BOT_MODE_PUSH_TOWER_BOT

end

function J.MultipleAlliesArePushing()
	local pushingAlly = 0
	for i, id in pairs( GetTeamPlayers( GetTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local member = GetTeamMember( i )
			if J.IsValidHero(member) and J.IsPushing( member ) then
				pushingAlly = pushingAlly + 1
			end
		end
	end
	return pushingAlly >= 2
end

function J.IsLaning( bot )
	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_LANING

end

function J.IsDoingRoshan( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_ROSHAN

end


function J.IsFarming( bot )

	local mode = bot:GetActiveMode()
	local nTarget = J.GetProperTarget( bot )

	return mode == BOT_MODE_FARM
			or ( nTarget ~= nil
					and nTarget:IsAlive()
					and nTarget:GetTeam() == TEAM_NEUTRAL
					and not J.IsRoshan( nTarget ) )
end


function J.IsShopping( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_RUNE
		or mode == BOT_MODE_SECRET_SHOP
		or mode == BOT_MODE_SIDE_SHOP

end


function J.GetTeamFountain()

	local Team = GetTeam()
	if Team == TEAM_DIRE
	then
		return DireFountain
	else
		return RadiantFountain
	end

end


function J.GetEnemyFountain()

	local Team = GetTeam()

	if Team == TEAM_DIRE
	then
		return RadiantFountain
	else
		return DireFountain
	end

end


function J.GetComboItem( bot, sItemName )

	local Slot = bot:FindItemSlot( sItemName )

	if Slot >= 0 and Slot <= 5
	then
		return bot:GetItemInSlot( Slot )
	end

end


function J.HasItem( bot, sItemName )

	local Slot = bot:FindItemSlot( sItemName )

	if Slot >= 0 and Slot <= 5 then	return true end

	return false

end


function J.IsItemAvailable( sItemName )

	local bot = GetBot()

	local slot = bot:FindItemSlot( sItemName )

	if slot >= 0 and slot <= 5
	then
		return bot:GetItemInSlot( slot )
	end

end


function J.GetMostHpUnit( unitList )

	local mostHpUnit = nil
	local maxHP = 0
	for _, unit in pairs( unitList )
	do
		local uHp = unit:GetHealth()
		if unit ~= nil
		and not J.IsRoshan(unit)
		and not J.IsTormentor(unit)
		and uHp > maxHP
		then
			mostHpUnit = unit
			maxHP = uHp
		end
	end

	return mostHpUnit

end


function J.GetLeastHpUnit( unitList )

	local leastHpUnit = nil
	local minHP = 999999

	for _, unit in pairs( unitList )
	do
		local uHp = unit:GetHealth()
		if uHp < minHP
		then
			leastHpUnit = unit
			minHP = uHp
		end
	end

	return leastHpUnit

end


function J.IsAllowedToSpam( bot, nManaCost )

	if bot:HasModifier( "modifier_silencer_curse_of_the_silent" ) then return false end

	if bot:HasModifier( "modifier_rune_regen" ) then return true end

	return ( bot:GetMana() - nManaCost ) / bot:GetMaxMana() >= fKeepManaPercent

end


function J.IsAllyUnitSpell( sAbilityName )

	return J.Skill['sAllyUnitAbilityIndex'][sAbilityName] == true

end


function J.IsProjectileUnitSpell( sAbilityName )

	return J.Skill['sProjectileAbilityIndex'][sAbilityName] == true


end


function J.IsOnlyProjectileSpell( sAbilityName )

	return J.Skill['sOnlyProjectileAbilityIndex'][sAbilityName] == true

end


function J.IsStunProjectileSpell( sAbilityName )

	return J.Skill['sStunProjectileAbilityIndex'][sAbilityName] == true

end


function J.IsWillBeCastUnitTargetSpell( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	local enemyList = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	for _, npcEnemy in pairs( enemyList )
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
			and npcEnemy:IsFacingLocation( bot:GetLocation(), 20 )
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
				and nAbility:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET
			then
				local sAbilityName = nAbility:GetName()
				if not J.IsAllyUnitSpell( sAbilityName )
				then
					if J.IsInRange( npcEnemy, bot, 330 )
						or not J.IsProjectileUnitSpell( sAbilityName )
					then
						if not J.IsHumanPlayer( npcEnemy )
						then
							return true
						else
							local nCycle = npcEnemy:GetAnimCycle()
							local nPoint = nAbility:GetCastPoint()
							if nCycle > 0.1 and nPoint * ( 1 - nCycle ) < 0.27 --极限时机0.26
							then
								return true
							end
						end
					end
				end
			end
		end
	end

	return false

end


function J.IsWillBeCastPointSpell( bot, nRadius )

	local enemyList = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )

	for _, npcEnemy in pairs( enemyList )
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
			and npcEnemy:IsFacingLocation( bot:GetLocation(), 50 )
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
			then
				if nAbility:GetBehavior() == ABILITY_BEHAVIOR_POINT
					or nAbility:GetBehavior() == ABILITY_BEHAVIOR_NO_TARGET
					or nAbility:GetBehavior() == 48
				then
					return true
				end
			end
		end
	end

	return false

end


--可躲避敌方非攻击弹道
function J.IsProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_dodgeable
			and not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and ( p.caster == nil or p.caster:GetTeam() ~= GetTeam() )
			and ( p.ability ~= nil
					and not J.IsOnlyProjectileSpell( p.ability:GetName() )
					and ( p.ability:GetName() ~= "medusa_mystic_snake"
							or p.caster == nil
							or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) )
		then
			return true
		end
	end

	return false

end


--可反弹敌方非攻击弹道
function J.IsUnitTargetProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and ( p.caster == nil
				 or ( p.caster:GetTeam() ~= bot:GetTeam()
					 and p.caster:IsHero()
					 and p.caster:GetUnitName() ~= "npc_dota_hero_antimage"
					 and p.caster:GetUnitName() ~= "npc_dota_hero_templar_assassin" ) )
			and ( p.ability ~= nil
				 and ( p.ability:GetName() ~= "medusa_mystic_snake"
						or p.caster == nil
						or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) )
			and ( p.ability:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET
				 or not J.IsOnlyProjectileSpell( p.ability:GetName() ) )
		then
			return true
		end
	end

	return false

end


--将被眩晕的弹道
function J.IsStunProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and p.ability ~= nil
			and J.IsStunProjectileSpell( p.ability:GetName() )
		then
			return true
		end
	end

	return false

end


--攻击弹道
function J.IsAttackProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
		then
			return true
		end
	end

	return false

end


--非攻击敌方弹道
function J.IsNotAttackProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and ( p.caster == nil or p.caster:GetTeam() ~= bot:GetTeam() )
			and ( p.ability ~= nil
					and ( p.ability:GetName() ~= "medusa_mystic_snake"
							or p.caster == nil
							or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) )
		then
			return true
		end
	end

	return false

end


--以下可少算但不可多算
function J.GetAttackProDelayTime( bot, nCreep )
	if nCreep == nil then
		print('[ERROR] nil creep target')
		print("Stack Trace:", debug.traceback())
		return 0
	end

	local botName = bot:GetUnitName()
	local botAttackRange = bot:GetAttackRange()
	local botAttackPoint = bot:GetAttackPoint()
	local botAttackSpeed = bot:GetAttackSpeed()
	local botProSpeed = bot:GetAttackProjectileSpeed()
	local botMoveSpeed = bot:GetCurrentMovementSpeed()
	local botAttackPointTime = botAttackPoint / botAttackSpeed
	local botAttackIdleTime = bot:GetSecondsPerAttack() - botAttackPointTime
	local nLastAttackRemainIdleTime = 0

	if GameTime() - bot:GetLastAttackTime() < botAttackIdleTime
	then
		nLastAttackRemainIdleTime = botAttackIdleTime - ( GameTime() - bot:GetLastAttackTime() )
	end

	local nAttackDamageDelayTime = botAttackPointTime + nLastAttackRemainIdleTime * 0.98
	local nDist = GetUnitToUnitDistance( bot, nCreep )

	if bot:CanBeSeen()
		and bot:GetAttackTarget() == nCreep
		and bot:GetAnimActivity() == 1503
		and bot:GetAnimCycle() < botAttackPoint
	then
		nAttackDamageDelayTime = 0.9 * ( botAttackPoint - bot:GetAnimCycle() ) / botAttackSpeed
	end

	if botAttackRange > 320 or botName == "npc_dota_hero_templar_assassin"
	then

		local ignoreDist = 39
		if bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT then ignoreDist = 59 end

		local projectMoveDist = nDist - ignoreDist

		if projectMoveDist < 0 then projectMoveDist = 0 end

		if projectMoveDist > botAttackRange then projectMoveDist = botAttackRange - 32 end

		nAttackDamageDelayTime = nAttackDamageDelayTime + projectMoveDist / botProSpeed

		if nDist > botAttackRange + ignoreDist / 1.2 and botName ~= "npc_dota_hero_sniper"
		then
			nAttackDamageDelayTime = nAttackDamageDelayTime + ( nDist - botAttackRange - ignoreDist / 1.2 ) / botMoveSpeed
		end

	end

	if botAttackRange < 326
		and nDist > botAttackRange + 50
		and botName ~= "npc_dota_hero_templar_assassin"
	then
		nAttackDamageDelayTime = nAttackDamageDelayTime + ( nDist - botAttackRange - 50 ) / botMoveSpeed
	end

	return nAttackDamageDelayTime

end


--当前点 * 攻击间隔 / 1.0 = 当前时
function J.GetCreepAttackActivityWillRealDamage( nUnit, nTime )

	local bot = GetBot()
	local botLV = bot:GetLevel()
	local gameTime = GameTime()
	local nDamage = 0
	local othersBeEnemy = true

	if nUnit:GetTeam() ~= bot:GetTeam() then othersBeEnemy = false end

	local nCreeps = bot:GetNearbyLaneCreeps( 1600, othersBeEnemy )
	for _, creep in pairs( nCreeps )
	do
		if creep:CanBeSeen()
			and creep:GetAttackTarget() == nUnit
			and creep:GetAnimActivity() == 1503
			and creep:GetLastAttackTime() < gameTime - 0.2
		then
			local attackPoint	= creep:GetAttackPoint()
			local animCycle	 = creep:GetAnimCycle()
			local attackPerTime = creep:GetSecondsPerAttack()

			if J.IsKeyWordUnit( 'melee', creep )
				and animCycle < attackPoint
				and ( attackPoint - animCycle ) * attackPerTime < nTime * ( 0.99 - botLV / 300 )
			then
				nDamage = nDamage + creep:GetAttackDamage() * 1
			end

			if J.IsKeyWordUnit( 'ranged', creep )
				and animCycle < attackPoint
			then
				local nDist = GetUnitToUnitDistance( creep, nUnit ) - 22
				local nProjectSpeed = creep:GetAttackProjectileSpeed()
				local nProjectTime = nDist / ( nProjectSpeed + 1 )
				if ( attackPoint - animCycle ) * attackPerTime + nProjectTime < nTime * ( 0.98 - botLV / 200 )
				then
					nDamage = nDamage + creep:GetAttackDamage() * 1
				end
			end

			if J.IsKeyWordUnit( 'siege', creep )
				and animCycle < 0.292 --0.285
			then
				local nDist = GetUnitToUnitDistance( creep, nUnit ) - 28
				local nProjectSpeed = creep:GetAttackProjectileSpeed()
				local nProjectTime = nDist / ( nProjectSpeed + 1 )
				if ( 0.292 - animCycle ) * 0.699 / 0.292 + nProjectTime < nTime * ( 0.9 - botLV / 150 )
				then
					nDamage = nDamage + creep:GetAttackDamage() * 1
				end
			end

		end
	end

	return nUnit:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL )

end


function J.GetCreepAttackProjectileWillRealDamage( nUnit, nTime )

	local nDamage = 0
	local incProj = nUnit:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_attack
			and p.caster ~= nil
		then
			local nProjectSpeed = p.caster:GetAttackProjectileSpeed()
			if p.caster:IsTower() then nProjectSpeed = nProjectSpeed * 0.93 end
			local nProjectDist = nProjectSpeed * nTime * 0.95
			local nDistance	 = GetUnitToLocationDistance( nUnit, p.location )
			if nProjectDist > nDistance * 1.02
			then
				nDamage = nDamage + p.caster:GetAttackDamage() * 1
			end
		end
	end

	return nUnit:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL )

end


function J.GetTotalAttackWillRealDamage( nUnit, nTime )

	 return J.GetCreepAttackProjectileWillRealDamage( nUnit, nTime ) + J.GetCreepAttackActivityWillRealDamage( nUnit, nTime )

end


function J.GetAttackProjectileDamageByRange( nUnit, nRadius )

	local nDamage = 0
	local incProj = nUnit:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_attack and p.caster ~= nil
			and GetUnitToLocationDistance( nUnit, p.location ) < nRadius
		then
			nDamage = nDamage + p.caster:GetAttackDamage() * 1
		end
	end

	return nDamage

end


function J.GetCorrectLoc( npcTarget, fDelay )

	local nStability = npcTarget:GetMovementDirectionStability()

	local vFirst = npcTarget:GetLocation()
	local vFuture = npcTarget:GetExtrapolatedLocation( fDelay )
	local vMidFutrue = ( vFirst + vFuture ) * 0.5
	local vLowFutrue = ( vFirst + vMidFutrue ) * 0.5
	local vHighFutrue = ( vFuture + vMidFutrue ) * 0.5


	if nStability < 0.5
	then
		return vLowFutrue
	elseif nStability < 0.7
	then
		return vMidFutrue
	elseif nStability < 0.9
	then
		return vHighFutrue
	end

	return vFuture
end

function J.GetDistanceFromLaneFront(bot)
	return J.GetDistance(GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0), bot:GetLocation())
end

function J.GetEscapeLoc()

	local bot = GetBot()
	local team = GetTeam()

	if bot:DistanceFromFountain() > 2500
	then
		return GetAncient( team ):GetLocation()
	else
		if team == TEAM_DIRE
		then
			return DireFountain
		else
			return RadiantFountain
		end
	end

end


function J.IsStuck2( bot )

	if bot.stuckLoc ~= nil and bot.stuckTime ~= nil
	then
		local EAd = GetUnitToUnitDistance( bot, GetAncient( GetOpposingTeam() ) )
		if DotaTime() > bot.stuckTime + 5.0 and GetUnitToLocationDistance( bot, bot.stuckLoc ) < 25
			and bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and EAd > 2200
		then
			print( bot:GetUnitName().." is stuck" )
			--DebugPause()
			return true
		end
	end

	return false

end


function J.IsStuck( bot )

	if bot.stuckLoc ~= nil and bot.stuckTime ~= nil and bot:CanBeSeen()
	then
		local attackTarget = bot:GetAttackTarget()
		local EAd = GetUnitToUnitDistance( bot, GetAncient( GetOpposingTeam() ) )
		local TAd = GetUnitToUnitDistance( bot, GetAncient( GetTeam() ) )
		local Et = bot:GetNearbyTowers( 450, true )
		local At = bot:GetNearbyTowers( 450, false )
		if bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO
			and attackTarget == nil and EAd > 2200 and TAd > 2200 and #Et == 0 and #At == 0
			and DotaTime() > bot.stuckTime + 5.0
			and GetUnitToLocationDistance( bot, bot.stuckLoc ) < 25
		then
			print( bot:GetUnitName().." is stuck" )
			return true
		end
	end

	return false

end


function J.IsExistInTable( u, tUnit )

	for _, t in pairs( tUnit )
	do
		if u == t
		then
			return true
		end
	end

	return false

end


function J.CombineTwoTable( tableA, tableB )

	local targetTable = tableA
	local Num = #tableA

	for i, u in pairs( tableB )
	do
		targetTable[Num + i] = u
	end

	return targetTable
end


function J.GetInvUnitInLocCount( bot, nRadius, nFindRadius, vLocation, pierceImmune )

	local nUnits = 0
	if nRadius > 1600 then nRadius = 1600 end
	local unitList = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	for _, u in pairs( unitList ) do
		if ( ( pierceImmune and J.CanCastOnMagicImmune( u ) )
			 or ( not pierceImmune and J.CanCastOnNonMagicImmune( u ) ) )
			and GetUnitToLocationDistance( u, vLocation ) <= nFindRadius
		then
			nUnits = nUnits + 1
		end
	end

	return nUnits

end


function J.GetInLocLaneCreepCount( bot, nRadius, nFindRadius, vLocation )

	local nUnits = 0
	if nRadius > 1600 then nRadius = 1600 end
	local unitList = bot:GetNearbyLaneCreeps( nRadius, true )
	for _, u in pairs( unitList ) do
		if GetUnitToLocationDistance( u, vLocation ) <= nFindRadius
		then
			nUnits = nUnits + 1
		end
	end

	return nUnits

end


function J.GetInvUnitCount( pierceImmune, unitList )

	local nUnits = 0
	if unitList ~= nil
	then
		for _, u in pairs( unitList )
		do
			if ( pierceImmune and J.CanCastOnMagicImmune( u ) )
				or ( not pierceImmune and J.CanCastOnNonMagicImmune( u ) )
			then
				nUnits = nUnits + 1
			end
		end
	end

	return nUnits

end

function J.HasHealingItem(bot)
	return (J.HasItem(bot, "item_tango") or bot:HasModifier("modifier_tango_heal"))
		or (J.HasItem(bot, "item_flask") or bot:HasModifier("modifier_flask_healing"))
		or (J.HasItem(bot, "item_bottle") or bot:HasModifier("modifier_bottle_regeneration"))
end

function J.ShouldGoFarmDuringLaning(bot)
	-- laning is too hard for the bot, try go farming somewhere else.
	local lane = bot:GetAssignedLane()
	return J.IsInLaningPhase()
	and GetHeroDeaths(bot:GetPlayerID()) >= 4
	and (GetHeroKills(bot:GetPlayerID()) == 0 or GetHeroKills(bot:GetPlayerID()) / GetHeroDeaths(bot:GetPlayerID()) < 0.5)
	and J.IsCore(bot)
	and bot:GetLevel() >= 4
	and bot:GetLevel() < 10
	and J.GetEnemyCountInLane(lane) >= 1
end

--------------------------------------------------ew functions 2018.12.7

function J.GetDistanceFromEnemyFountain( bot )

	local EnemyFountain = J.GetEnemyFountain()
	local Distance = GetUnitToLocationDistance( bot, EnemyFountain )

	return Distance

end


function J.GetDistanceFromAllyFountain( bot )

	local OurFountain = J.GetTeamFountain()
	local Distance = GetUnitToLocationDistance( bot, OurFountain )

	return Distance

end


function J.GetDistanceFromAncient( bot, bEnemy )

	local targetAncient = GetAncient( GetTeam() )

	if bEnemy then targetAncient = GetAncient( GetOpposingTeam() ) end

	return GetUnitToUnitDistance( bot, targetAncient )

end


function J.GetAroundTargetAllyHeroCount( target, nRadius )

	local heroList = J.GetAlliesNearLoc( target:GetLocation(), nRadius )

	return #heroList

end


function J.GetAroundTargetOtherAllyHeroCount( bot, target, nRadius )

	local heroList = J.GetAlliesNearLoc( target:GetLocation(), nRadius )

	if GetUnitToUnitDistance( bot, target ) <= nRadius
	then
		return #heroList - 1
	end

	return #heroList

end


function J.GetAllyCreepNearLoc( bot, vLoc, nRadius )

	local AllyCreepsAll = bot:GetNearbyCreeps( 1600, false )
	local allyCreepList = { }

	for _, creep in pairs( AllyCreepsAll )
	do
		if creep ~= nil
			and creep:IsAlive()
			and GetUnitToLocationDistance( creep, vLoc ) <= nRadius
		then
			table.insert( allyCreepList, creep )
		end
	end

	return allyCreepList

end


function J.GetAllyUnitCountAroundEnemyTarget( bot, target, nRadius )

	local heroList = J.GetAlliesNearLoc( target:GetLocation(), nRadius )
	local creepList = J.GetAllyCreepNearLoc( bot, target:GetLocation(), nRadius )

	return #heroList + #creepList

end


-- local NearbyHeroMap = {
	-- 'hero_unit_name' = {
	-- 	'enemy' = {
	-- 		'1600' = { 
	-- 			'time' = DotaTime(),
	-- 			'heroes' = {}
	-- 		},
	-- 		'1000' = { },
	-- 	},
	-- 	'ally' = {
	-- 		'1600' = { },
	-- 		'1000' = { },
	-- 	}
	-- }
-- }
-- Cache duration in seconds
local nearByHeroCacheDuration = 0.1 -- 0.xxx = xxx ms. if you have 60 frames per second, it's 1000/60 = 16.7ms per frame. higher fps, smaller ms per frame.
-- Check the current time
local currentTime
local cacheNearbyTable
local printN = 0

-- Method to refresh and cache nearby hero lists for each hero unit
-- Unknown why but it seems to cause dota2 to crash due to changing the caching frequence, or maybe it's due to some nil exceptions.
function J.GetNearbyHeroes(bot, nRadius, bEnemy, bBotMode)
	if not bBotMode then bBotMode = BOT_MODE_NONE end
	-- local nearbyHeroes = bot:GetNearbyHeroes(nRadius, bEnemy, bBotMode)
	-- if printN <= 100000 then
	-- 	printN = printN + 1
	-- 	J.Utils.PrintTable(nearbyHeroes)
	-- end
	local nearby = bot:GetNearbyHeroes(nRadius, bEnemy, bBotMode)
	if not nearby then
		return nearby
	end

	local heroes = {}
	for _, hero in pairs( nearby )
	do
		if J.IsValidHero(hero)
		and not J.IsMeepoClone(hero)
		and not bot:HasModifier('modifier_arc_warden_tempest_double') then
			table.insert(heroes, hero)
		end
	end
	return heroes

    -- Cap the radius to a maximum value
    -- if nRadius > 1600 then nRadius = 1600 end

    -- -- Initialize the bot's cache table if it doesn't exist
    -- bot.nearbyHeroes = bot.nearbyHeroes or { ally = {}, enemy = {} }

    -- -- Select the appropriate cache based on whether we're looking for enemies or allies
    -- cacheNearbyTable = bEnemy and bot.nearbyHeroes.enemy or bot.nearbyHeroes.ally

    -- -- Check the current time
    -- currentTime = DotaTime()

    -- -- Initialize or update the cache for the specific radius
	-- if cacheNearbyTable[nRadius] == nil or
	-- 	currentTime - cacheNearbyTable[nRadius].time >= nearByHeroCacheDuration
	-- then
	-- 	cacheNearbyTable[nRadius] = {
	-- 		time = currentTime,
	-- 		heroes = bot:GetNearbyHeroes(nRadius, bEnemy, BOT_MODE_NONE)
	-- 	}
	-- end

	-- -- J.Utils.PrintTable(cacheNearbyTable[nRadius].heroes)
    -- -- Return the cached nearby heroes
    -- return cacheNearbyTable[nRadius].heroes
end

function J.GetAroundBotUnitList( bot, nRadius, bEnemy )

	if nRadius > 1600 then nRadius = 1600 end

	local heroList = J.GetNearbyHeroes(bot, nRadius, bEnemy, BOT_MODE_NONE )
	local creepList = bot:GetNearbyCreeps( nRadius, bEnemy )
	local unitList = {}

	if #heroList > 0 and #creepList > 0
	then
		unitList = heroList
		for i = 1, #creepList
		do
			table.insert( unitList, creepList[1] )
		end
	elseif #heroList == 0
	then
		unitList = creepList
	elseif #creepList == 0
	then
		unitList = heroList
	end

	return unitList

end

function J.GetLocationToLocationDistance( fLoc, sLoc )

	local x1 = fLoc.x
	local x2 = sLoc.x
	local y1 = fLoc.y
	local y2 = sLoc.y

	return math.sqrt( math.pow( ( y2-y1 ), 2 ) + math.pow( ( x2-x1 ), 2 ) )

end


function J.GetUnitTowardDistanceLocation( bot, towardTarget, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempVector = ( towardTarget:GetLocation() - npcBotLocation ) / GetUnitToUnitDistance( bot, towardTarget )

	return npcBotLocation + nDistance * tempVector

end


function J.GetLocationTowardDistanceLocation( bot, towardLocation, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempVector = ( towardLocation - npcBotLocation ) / GetUnitToLocationDistance( bot, towardLocation )

	return npcBotLocation + nDistance * tempVector

end


function J.GetFaceTowardDistanceLocation( bot, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempRadians = bot:GetFacing() * math.pi / 180
	local tempVector = Vector( math.cos( tempRadians ), math.sin( tempRadians ) )

	return npcBotLocation + nDistance * tempVector

end


function J.SetBotPing( vLoc )

	GetBot():ActionImmediate_Ping( vLoc.x, vLoc.y, false )

end


function J.SetBotPrint( sMessage, vLoc, bReport, bPing )

	local bot = GetBot()

	local nTime = J.GetOne( DotaTime() / 10 )* 10
	local sTime = ( J.GetOne( nTime / 600 )* 10 )..":"..( nTime%60 )
	local sTeam = GetTeam() == TEAM_DIRE and "夜魇" or "天辉"

	if bDebugMode
	then

		print( sTeam..sTime.." "..J.Chat.GetNormName( bot ).." "..sMessage )

		if bReport then bot:ActionImmediate_Chat( sTime.."_"..sMessage, true ) end

		if bPing then bot:ActionImmediate_Ping( vLoc.x, vLoc.y, false ) end

	end

end


function J.SetReportMotive( bDebugFile, sMotive )

	if bDebugMode and bDebugFile and sMotive ~= nil
	then

		local nTime = J.GetOne( DotaTime() / 10 ) * 10
		local sTime = ( J.GetOne( nTime / 600 ) * 10 )..":"..( nTime%60 )
		local sTeam = GetTeam() == TEAM_DIRE and "夜魇 " or "天辉 "

		GetBot():ActionImmediate_Chat( sTime.."_"..sMotive, true )

		print( sTeam..sTime.." "..J.Chat.GetNormName( GetBot() ).." "..sMotive )

	end

end


function J.GetCastLocation( bot, npcTarget, nCastRange, nRadius )

	local nDistance = GetUnitToUnitDistance( bot, npcTarget )

	if nDistance <= nCastRange
	then
		return npcTarget:GetLocation()
	end

	if nDistance <= nCastRange + nRadius - 120
	then
		return J.GetUnitTowardDistanceLocation( bot, npcTarget, nCastRange )
	end

	if nDistance < nCastRange + nRadius - 18
		and ( ( J.IsDisabled( npcTarget ) or npcTarget:GetCurrentMovementSpeed() <= 160 )
				or npcTarget:IsFacingLocation( bot:GetLocation(), 45 )
				or ( bot:IsFacingLocation( npcTarget:GetLocation(), 45 ) and npcTarget:GetCurrentMovementSpeed() <= 220 ) )
	then
		return J.GetUnitTowardDistanceLocation( bot, npcTarget, nCastRange +18 )
	end

	if nDistance < nCastRange + nRadius + 28
		and npcTarget:IsFacingLocation( bot:GetLocation(), 30 )
		and bot:IsFacingLocation( npcTarget:GetLocation(), 30 )
		and npcTarget:GetMovementDirectionStability() > 0.95
		and npcTarget:GetCurrentMovementSpeed() >= 300
	then
		return J.GetUnitTowardDistanceLocation( bot, npcTarget, nCastRange + 18 )
	end

	return nil

end


function J.GetDelayCastLocation( bot, npcTarget, nCastRange, nRadius, nTime )

	local nFutureLoc = J.GetCorrectLoc( npcTarget, nTime )
	local nDistance = GetUnitToLocationDistance( bot, nFutureLoc )

	if nDistance > nCastRange + nRadius - 16
	then
		return nil
	end

	if nDistance > nCastRange - nRadius * 0.38
	then
		return J.GetLocationTowardDistanceLocation( bot, nFutureLoc, nCastRange +8 )
	end

	return nFutureLoc

end


function J.GetOne( number )

	return math.floor( number * 10 ) / 10

end


function J.GetTwo( number )

	return math.floor( number * 100 ) / 100

end


function J.SetQueueToInvisible( bot )

	if bot:IsAlive()
		and not bot:IsInvisible()
		and not bot:HasModifier( "modifier_item_dustofappearance" )
	then
		local enemyTowerList = bot:GetNearbyTowers( 888, true )

		if enemyTowerList[1] ~= nil then return end

		local itemAmulet = J.IsItemAvailable( 'item_shadow_amulet' )
		if itemAmulet ~= nil
			and itemAmulet:IsFullyCastable()
		then
			bot:ActionQueue_UseAbilityOnEntity( itemAmulet, bot )
			return
		end
	
		local itemGlimer = J.IsItemAvailable( 'item_glimmer_cape' )
		if itemGlimer ~= nil and itemGlimer:IsFullyCastable()
		then
			bot:ActionQueue_UseAbilityOnEntity( itemGlimer, bot )
			return
		end

		local itemInvisSword = J.IsItemAvailable( 'item_invis_sword' )
		if itemInvisSword ~= nil and itemInvisSword:IsFullyCastable()
		then
			bot:ActionQueue_UseAbility( itemInvisSword )
			return
		end

		local itemSilverEdge = J.IsItemAvailable( 'item_silver_edge' )
		if itemSilverEdge ~= nil and itemSilverEdge:IsFullyCastable()
		then
			bot:ActionQueue_UseAbility( itemSilverEdge )
			return
		end

	end


end


function J.SetQueueSwitchPtToINT( bot )

	local pt = J.IsItemAvailable( "item_power_treads" )
	if pt ~= nil and pt:IsFullyCastable()
	then
		if pt:GetPowerTreadsStat() == ATTRIBUTE_INTELLECT
		then
			bot:ActionQueue_UseAbility( pt )
			bot:ActionQueue_UseAbility( pt )
			return
		elseif pt:GetPowerTreadsStat() == ATTRIBUTE_STRENGTH
			then
				bot:ActionQueue_UseAbility( pt )
				return
		end
	end

end


function J.SetQueueUseSoulRing( bot )

	local sr = J.IsItemAvailable( "item_soul_ring" )

	if sr ~= nil and sr:IsFullyCastable()
	then
		local nEnemyCount = J.GetEnemyCount( bot, 1600 )
		local botHP = J.GetHP( bot )
		local botMP = J.GetMP( bot )
		if botHP > 0.35 + 0.1 * nEnemyCount
			and botMP < 0.99 - 0.1 * nEnemyCount
			and ( nEnemyCount <= 2 or botHP > botMP * 2.5 )
		then
			bot:ActionQueue_UseAbility( sr )
			return
		end
	end

end


function J.SetQueuePtToINT( bot, bSoulRingUsed )

	bot:Action_ClearActions(false)

	if bSoulRingUsed then J.SetQueueUseSoulRing( bot ) end

	if not J.IsPTReady( bot, ATTRIBUTE_INTELLECT )
	then
		J.SetQueueSwitchPtToINT( bot )
	end

end

-- 动力鞋/假腿状态
function J.IsPTReady( bot, status )

	if not bot:IsAlive()
		or bot:IsMuted()
		or bot:IsChanneling()
		or bot:IsInvisible()
		or bot:GetHealth() / bot:GetMaxHealth() < 0.2
	then
		return true
	end

	if status == ATTRIBUTE_INTELLECT
	then
		status = ATTRIBUTE_AGILITY
	elseif status == ATTRIBUTE_AGILITY
		then
			status = ATTRIBUTE_INTELLECT
	end

	local pt = J.IsItemAvailable( "item_power_treads" )
	if pt ~= nil and pt:IsFullyCastable()
	then
		if pt:GetPowerTreadsStat() ~= status
		then
			return false
		end
	end

	return true

end


function J.ShouldSwitchPTStat( bot, pt )

	local ptStatus = pt:GetPowerTreadsStat()
	local botAttribute = bot:GetPrimaryAttribute()
	
	
	if ptStatus == ATTRIBUTE_INTELLECT
	then
		ptStatus = ATTRIBUTE_AGILITY
	elseif ptStatus == ATTRIBUTE_AGILITY
		then
			ptStatus = ATTRIBUTE_INTELLECT
	end
	
	if botAttribute ~= ATTRIBUTE_INTELLECT
		and botAttribute ~= ATTRIBUTE_STRENGTH
		and botAttribute ~= ATTRIBUTE_AGILITY
	then
		return ptStatus ~= ATTRIBUTE_STRENGTH
	end

	return botAttribute ~= ptStatus

end


function J.IsOtherAllysTarget( unit )

	local bot = GetBot()
	local hAllyList = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_NONE )

	if #hAllyList <= 1 then return false end

	for _, ally in pairs( hAllyList )
	do
		if J.IsValid( ally )
			and ally ~= bot
			and not ally:IsIllusion()
			and ( J.GetProperTarget( ally ) == unit
					or ( not ally:IsBot() and ally:IsFacingLocation( unit:GetLocation(), 20 ) ) )
		then
			return true
		end
	end

	return false

end


function J.IsAllysTarget( unit )

	local bot = GetBot()
	local hAllyList = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_NONE )

	for _, ally in pairs( hAllyList )
	do
		if J.IsValid( ally )
			and not ally:IsIllusion()
			and ( J.GetProperTarget( ally ) == unit
					or ( not ally:IsBot() and ally:IsFacingLocation( unit:GetLocation(), 12 ) ) )
		then
			return true
		end
	end

	return false

end


function J.IsKeyWordUnit( keyWord, uUnit )

	if string.find( uUnit:GetUnitName(), keyWord ) ~= nil
	then
		return true
	end

	return false
end


function J.IsHumanPlayer( nUnit )

	return not nUnit:IsBot() -- or IsPlayerBot( nUnit:GetPlayerID() )

end


function J.IsValid( nTarget )
	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and not nTarget:IsBuilding()
end

function J.IsValidTarget(nTarget)
	-- NOTE: return J.Utils.IsValidUnit(nTarget) -- ideally it should be IsValidUnit, but a lot of legacy usage causing some problems.
	return J.Utils.IsValidHero(nTarget)
end

function J.IsValidHero( nTarget )
	return J.Utils.IsValidHero(nTarget)
end

function J.IsValidBuilding( nTarget )
	return J.Utils.IsValidBuilding(nTarget)
end

function J.IsRoshan( nTarget )

	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and string.find( nTarget:GetUnitName(), "roshan" ) ~= nil

end


function J.IsMoving( bot )

	if not bot:IsAlive() then return false end

	local vLocation = bot:GetExtrapolatedLocation( 0.6 )
	if GetUnitToLocationDistance( bot, vLocation ) > bot:GetCurrentMovementSpeed() * 0.45
	then
		return true
	end

	return false

end


function J.IsRunning( bot )

	if not bot:IsAlive() then return false end

	return bot:GetAnimActivity() == ACTIVITY_RUN

end


function J.IsAttacking( bot )

	local nAnimActivity = bot:GetAnimActivity()

	if nAnimActivity ~= ACTIVITY_ATTACK
		and nAnimActivity ~= ACTIVITY_ATTACK2
	then
		return false
	end

	if bot:GetAttackPoint() > bot:GetAnimCycle() * 0.99
	then
		return true
	end

	return false
end


function J.IsChasingTarget( bot, nTarget )

	if J.IsRunning( bot )
		and J.IsRunning( nTarget )
		and bot:IsFacingLocation( nTarget:GetLocation(), 20 )
		and not nTarget:IsFacingLocation( bot:GetLocation(), 150 )
	then
		return true
	end

	return false

end


function J.IsRealInvisible( bot )

	local enemyTowerList = bot:GetNearbyTowers( 880, true )

	if bot:IsInvisible()
		and not bot:HasModifier( 'modifier_item_dustofappearance' )
		and not bot:HasModifier( 'modifier_bloodseeker_thirst_vision' )
		and not bot:HasModifier( 'modifier_slardar_amplify_damage' )
		and not bot:HasModifier( 'modifier_sniper_assassinate' )
		and not bot:HasModifier( 'modifier_bounty_hunter_track' )
		and not bot:HasModifier( 'modifier_faceless_void_chronosphere_freeze' )
		and #enemyTowerList == 0
	then
		return true
	end


	return false

end


function J.GetModifierTime( bot, sModifierName )

	if not bot:HasModifier( sModifierName ) then return 0 end

	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == sModifierName
		then
			return bot:GetModifierRemainingDuration( i )
		end
	end

	return 0

end


function J.GetModifierCount( bot, sModifierName )

	if not bot:HasModifier( sModifierName ) then return 0 end

	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == sModifierName
		then
			return bot:GetModifierStackCount( i )
		end
	end

	return 0

end




function J.GetRemainStunTime( bot )

	if not bot:HasModifier( "modifier_stunned" ) then return 0 end

	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == "modifier_stunned"
		then
			return bot:GetModifierRemainingDuration( i )
		end
	end

	return 0

end


function J.IsTeamActivityCount( bot, nCount )

	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		then
			if J.GetAllyCount( member, 1600 ) >= nCount
			then
				return true
			end
		end
	end

	return false

end


function J.GetSpecialModeAllies( bot, nDistance, nMode )

	local allyList = {}
	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		then
			if member:GetActiveMode() == nMode
				and GetUnitToUnitDistance( member, bot ) <= nDistance
			then
				table.insert( allyList, member )
			end
		end
	end

	return allyList

end


function J.GetSpecialModeAlliesCount( nMode )

	local allyList = J.GetSpecialModeAllies( GetBot(), 99999, nMode )

	return #allyList

end


function J.GetTeamFightLocation( bot )

	local team = GetTeam()

	local res = J.Utils.GetCachedVars('GetTeamFightLocation'..tostring(team), 0.5)
	if res ~= nil then return res end

	local targetLocation = nil
	local numPlayer = GetTeamPlayers( team )

	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
			and J.IsInTeamFight( member, 1500 )
			and J.GetEnemyCount( member, 1400 ) >= 2
		then
			local allyList = J.GetSpecialModeAllies( member, 1400, BOT_MODE_ATTACK )
			targetLocation = J.GetCenterOfUnits( allyList )
			break
		end
	end

	J.Utils.SetCachedVars('GetTeamFightLocation', targetLocation)
	return targetLocation

end


function J.GetTeamFightAlliesCount( bot )

	local numPlayer = GetTeamPlayers( GetTeam() )
	local nCount = 0
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
			and J.IsInTeamFight( member, 1200 )
			and J.GetEnemyCount( member, 1400 ) >= 2
		then
			nCount = J.GetSpecialModeAlliesCount( BOT_MODE_ATTACK )
			break
		end
	end

	return nCount

end


function J.GetCenterOfUnits( nUnits )

	if #nUnits == 0
	then
		return Vector( 0.0, 0.0 )
	end

	local sum = Vector( 0.0, 0.0 )
	local num = 0

	for _, unit in pairs( nUnits )
	do
		if J.IsValid(unit)
		then
			sum = sum + unit:GetLocation()
			num = num + 1
		end
	end

	if num == 0 then return Vector( 0.0, 0.0 ) end

	return sum / num

end

function J.GetMostFarmLaneDesire(bot)

	local nTopDesire = GetFarmLaneDesire( LANE_TOP )
	local nMidDesire = GetFarmLaneDesire( LANE_MID )
	local nBotDesire = GetFarmLaneDesire( LANE_BOT )

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	if DotaTime() < 8 * 60 then
		return bot:GetAssignedLane(), 0.667
	end

	return LANE_MID, nMidDesire

end


function J.GetMostDefendLaneDesire()

	local nTopDesire = J.GetDefendLaneDesire( LANE_TOP )
	local nMidDesire = J.GetDefendLaneDesire( LANE_MID )
	local nBotDesire = J.GetDefendLaneDesire( LANE_BOT )

	if nMidDesire > nTopDesire and nMidDesire > nBotDesire then
		return LANE_MID, nMidDesire
	end

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	return LANE_MID, nMidDesire

end

function J.GetDefendLaneDesire(lane)
	local defaultDefDesire, newDefDesire = GetDefendLaneDesire(lane), GetBot().DefendLaneDesire
	if newDefDesire ~= nil and newDefDesire[lane] > defaultDefDesire
	then
		return newDefDesire[lane]
	end
	return defaultDefDesire
end

function J.IsT3TowerDown(team, lane)
	local t3 = {
		[LANE_TOP] = TOWER_TOP_3,
		[LANE_MID] = TOWER_MID_3,
		[LANE_BOT] = TOWER_BOT_3,
	}

	return GetTower(team, t3[lane]) == nil
end

local tower_list = {
	[TOWER_TOP_1] = {lane = LANE_TOP, isTower = true},
	[TOWER_MID_1] = {lane = LANE_MID, isTower = true},
	[TOWER_BOT_1] = {lane = LANE_BOT, isTower = true},
	[TOWER_TOP_2] = {lane = LANE_TOP, isTower = true},
	[TOWER_MID_2] = {lane = LANE_MID, isTower = true},
	[TOWER_BOT_2] = {lane = LANE_BOT, isTower = true},
	[TOWER_TOP_3] = {lane = LANE_TOP, isTower = true},
	[TOWER_MID_3] = {lane = LANE_MID, isTower = true},
	[TOWER_BOT_3] = {lane = LANE_BOT, isTower = true},
	[TOWER_BASE_1] = {lane = LANE_MID, isTower = true},
	[TOWER_BASE_2] = {lane = LANE_MID, isTower = true},
	[BARRACKS_TOP_MELEE] = {lane = LANE_TOP, isTower = false},
	[BARRACKS_TOP_RANGED] = {lane = LANE_TOP, isTower = false},
	[BARRACKS_MID_MELEE] = {lane = LANE_MID, isTower = false},
	[BARRACKS_MID_RANGED] = {lane = LANE_MID, isTower = false},
	[BARRACKS_BOT_MELEE] = {lane = LANE_BOT, isTower = false},
	[BARRACKS_BOT_RANGED] = {lane = LANE_BOT, isTower = false},
	['ancient'] = {lane = LANE_MID, isTower = false},
}
function J.IsPingCloseToValidTower(team, ping)
	for k, v in pairs(tower_list)
	do
		local building = nil
		if k == 'ancient'
		then
			building = GetAncient(team)
		elseif v.isTower
		then
			building = GetTower(team, k)
		else
			building = GetBarracks(team, k)
		end

		if building ~= nil
		and building:CanBeSeen()
		and not building:IsInvulnerable()
		and not building:HasModifier('modifier_backdoor_protection')
		and not building:HasModifier('modifier_backdoor_protection_in_base')
		and not building:HasModifier('modifier_backdoor_protection_active')
		and J.GetDistance(building:GetLocation(), ping.location) <= 800
		then
			return true, v.lane
		end
	end
	return false, nil
end

function J.IsRoshanCloseToChangingSides()
    return DotaTime() % 300 >= 300 - 30
end

function J.GetMostPushLaneDesire()

	local nTopDesire = GetPushLaneDesire( LANE_TOP )
	local nMidDesire = GetPushLaneDesire( LANE_MID )
	local nBotDesire = GetPushLaneDesire( LANE_BOT )

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	return LANE_MID, nMidDesire

end

function J.GetClosestAlly(bot, nRadius)
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member:IsAlive()
		and member ~= bot
		and GetUnitToUnitDistance(bot, member) <= nRadius
		and not J.IsSuspiciousIllusion(member)
		then
			return member
		end
	end

	return nil
end

function J.GetNearestLaneFrontLocation( nUnitLoc, bEnemy, fDeltaFromFront )

	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	local nTopLoc = GetLaneFrontLocation( nTeam, LANE_TOP, fDeltaFromFront )
	local nMidLoc = GetLaneFrontLocation( nTeam, LANE_MID, fDeltaFromFront )
	local nBotLoc = GetLaneFrontLocation( nTeam, LANE_BOT, fDeltaFromFront )

	local nTopDist = J.GetLocationToLocationDistance( nUnitLoc, nTopLoc )
	local nMidDist = J.GetLocationToLocationDistance( nUnitLoc, nMidLoc )
	local nBotDist = J.GetLocationToLocationDistance( nUnitLoc, nBotLoc )

	if nTopDist < nMidDist and nTopDist < nBotDist
	then
		return nTopLoc
	end

	if nBotDist < nMidDist and nBotDist < nTopDist
	then
		return nBotLoc
	end

	return nMidLoc

end

function J.GetAttackableWeakestUnit( bot, nRadius, bHero, bEnemy )
    local unitList = {}
    if bHero then
        unitList = J.GetNearbyHeroes(bot, nRadius, bEnemy, BOT_MODE_NONE )
    else
        unitList = bot:GetNearbyLaneCreeps( nRadius, bEnemy )
    end
    return J.GetAttackableWeakestUnitFromList( bot, unitList )
end

-- The arg `bot` here can be nil
function J.GetAttackableWeakestUnitFromList( bot, unitList )
    local weakest = nil
    local bestScore = math.huge
	local attackRange = bot:GetAttackRange()

    for _, unit in pairs( unitList ) do
        local hp = unit:GetHealth()
        local offensivePower = 0
		local distance = GetUnitToUnitDistance(bot, unit)
        if J.IsValidHero(unit) then
            offensivePower = unit:GetRawOffensivePower()
        end
        if J.IsValid( unit )
            and not unit:IsAttackImmune()
            and not unit:IsInvulnerable()
            and not J.HasForbiddenModifier( unit )
            and not J.IsSuspiciousIllusion( unit )
			--and not J.IsAllyCanKill( unit )
            and not J.CannotBeKilled(bot, unit)
        then
            -- Calculate score: lower score is better
            -- Can adjust the weight factors for hp and offensive power to tune the behavior
            local hpWeight = 0.7
            local powerWeight = 0.3
            local score = (hp * hpWeight) - (offensivePower * powerWeight) - math.min(1, attackRange / distance) * 100

            -- If the new score is lower, choose this unit as the weakest
            if score < bestScore then
                bestScore = score
                weakest = unit
            end
        end
    end

    return weakest
end

function J.CannotBeKilled(bot, botTarget)
	return J.IsValidHero( botTarget )
	and (
		(J.GetModifierTime(botTarget, 'modifier_dazzle_shallow_grave') > 0.6 and J.GetHP(botTarget) < 0.15 and (bot == nil or bot:GetUnitName() ~= "npc_dota_hero_axe"))
		or J.GetModifierTime(botTarget, 'modifier_oracle_false_promise_timer') > 0.6
		or botTarget:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
		or botTarget:HasModifier('modifier_item_aeon_disk_buff')
		or botTarget:HasModifier('modifier_abaddon_borrowed_time')
	)
end

function J.CanIgnoreLowHp(bot)
	return J.GetModifierTime(bot, 'modifier_dazzle_shallow_grave') > 0.6
	or J.GetModifierTime(bot, 'modifier_oracle_false_promise_timer') > 0.6
end

function J.CanBeAttacked( unit )
	return  unit ~= nil
			and not J.HasForbiddenModifier( unit )
			and unit:IsAlive()
			and unit:CanBeSeen()
			and not unit:IsNull()
			and not unit:IsAttackImmune()
			and not unit:IsInvulnerable()
			and not unit:HasModifier("modifier_fountain_glyph")
			and not unit:HasModifier("modifier_omninight_guardian_angel")
			and not unit:HasModifier("modifier_winter_wyvern_cold_embrace")
			and (unit:GetTeam() == GetTeam() 
					or not unit:HasModifier("modifier_crystal_maiden_frostbite") )
			and (unit:GetTeam() ~= GetTeam() 
			     or ( unit:GetUnitName() ~= "npc_dota_wraith_king_skeleton_warrior" 
					  and unit:GetHealth()/unit:GetMaxHealth() < 0.5 ) )
end


function J.GetHP( unit )
	local nCurHealth = unit:GetHealth()
    local nMaxHealth = unit:GetMaxHealth()
	if GetTeam() == unit:GetTeam() then
		nCurHealth = unit:OriginalGetHealth()
		nMaxHealth = unit:OriginalGetMaxHealth()
	end
	if nCurHealth <= 0 then return 0 end
	return nCurHealth / nMaxHealth
end

function J.GetEffectiveHP( bot )
	if not J.IsValid(bot) then return 0 end

	local nCurHealth = bot:GetHealth()
	if nCurHealth <= 0 then return 0 end

	if bot:GetUnitName() == 'npc_dota_hero_medusa'
    then
		local mana = bot:GetMana()
		-- Assuming max level Mana Shield (95% absorption and 2.5 damage absorbed per point of mana)
		local manaAbsorptionRate = 0.95
		local damagePerMana = 2.6
		-- Calculate how much damage her current mana can absorb
		local manaEffectiveHP = mana * damagePerMana * manaAbsorptionRate
		-- Effective HP is her base HP plus the effective HP from her mana shield
		nCurHealth = nCurHealth + manaEffectiveHP
    end

	return nCurHealth
end


function J.GetMP( bot )
	if bot:GetUnitName() == 'npc_dota_hero_huskar' then
		return bot:GetHealth() / bot:GetMaxHealth()
	end
	return bot:GetMana() / bot:GetMaxMana()
end


function J.GetAllyList( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	local nRealAllyList = {}
	local nCandidate = J.GetNearbyHeroes(bot, nRadius, false, BOT_MODE_NONE )
	if #nCandidate <= 1 then return nCandidate end

	for _, ally in pairs( nCandidate )
	do
		if ally ~= nil and ally:IsAlive()
			and not ally:IsIllusion()
		then
			table.insert( nRealAllyList, ally )
		end
	end

	return nRealAllyList

end


function J.GetAllyCount( bot, nRadius )

	local nRealAllyList = J.GetAllyList( bot, nRadius )

	return #nRealAllyList

end


function J.GetAroundEnemyHeroList( nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	return J.GetNearbyHeroes(GetBot(), nRadius, true, BOT_MODE_NONE )

end


function J.GetAroundCreepList( nRadius, bEnemy, bNeutral, bLaneCreep )

	local bot = GetBot()
	if nRadius > 1600 then nRadius = 1600 end
	local creepList = {}

	if bNeutral
	then
		creepList = bot:GetNearbyNeutralCreeps( nRadius )
	elseif bLaneCreep
	then
		creepList = bot:GetNearbyLaneCreeps( nRadius, bEnemy )
	else
		creepList = bot:GetNearbyCreeps( nRadius, bEnemy )
	end

	return creepList

end


function J.GetAroundBuildingList( nRadius, bEnemy, bTower, bShrine, bFiller, bBarrack, bAcient )

	local bot = GetBot()
	if nRadius > 1600 then nRadius = 1600 end
	local buildingList = {}

	-- GetNearbyBarracks( nRadius, bEnemies )
	-- GetNearbyTowers( nRadius, bEnemies )
	-- GetNearbyShrines( nRadius, bEnemies )
	-- GetNearbyFillers( nRadius, bEnemies )
	-- GetAncient( nTeam )

	return buildingList

end


function J.GetEnemyList( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end
	local nRealEnemyList = {}
	local nCandidate = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	if nCandidate[1] == nil then return nCandidate end

	for _, enemy in pairs( nCandidate )
	do
		if enemy ~= nil and type(enemy) == "table" and enemy:IsAlive()
			and not J.IsSuspiciousIllusion( enemy )
		then
			table.insert( nRealEnemyList, enemy )
		end
	end

	return nRealEnemyList

end


function J.GetEnemyCount( bot, nRadius )

	local nRealEnemyList = J.GetEnemyList( bot, nRadius )

	return #nRealEnemyList

end

function J.ConsiderTarget()

	local bot = GetBot()

	if not J.IsRunning( bot )
		or bot:HasModifier( "modifier_item_hurricane_pike_range" )
	then return end

	local npcTarget = J.GetProperTarget( bot )
	if not J.IsValidHero( npcTarget ) then return end

	local nAttackRange = bot:GetAttackRange() + 69
	if nAttackRange > 1600 then nAttackRange = 1600 end
	if nAttackRange < 300 then nAttackRange = 350 end

	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, nAttackRange, true, true )

	if J.IsValidHero( nInAttackRangeWeakestEnemyHero )
		and ( GetUnitToUnitDistance( npcTarget, bot ) > nAttackRange or J.HasForbiddenModifier( npcTarget ) )
	then
		bot:SetTarget( nInAttackRangeWeakestEnemyHero )
		return
	end

end


function J.IsHaveAegis( bot )
	return bot:FindItemSlot( "item_aegis" ) >= 0
end

function J.DoesTeamHaveAegis()
	local cacheKey = tostring(GetTeam())
	local res = J.Utils.GetCachedVars('DoesTeamHaveAegis'..cacheKey, 1)
	if res ~= nil then return res end

	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember(i)
		if J.IsValidHero(member)
		and J.IsHaveAegis(member)
		then
			J.Utils.SetCachedVars('DoesTeamHaveAegis'..cacheKey, true)
			return true
		end
	end

	J.Utils.SetCachedVars('DoesTeamHaveAegis'..cacheKey, false)
	return false
end


function J.GetCoresAverageNetworth()
	local cacheKey = tostring(GetTeam())
	local cache = J.Utils.GetCachedVars('GetCoresAverageNetworth'..cacheKey, 2)
	if cache ~= nil then return cache end

	local totalNetWorth = 0
	local coreCount = 0
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)
		if J.IsValidHero(member)
		and J.IsCore(member)
		then
			totalNetWorth = totalNetWorth + member:GetNetWorth()
			coreCount = coreCount + 1
		end
	end

	local res = totalNetWorth / coreCount
	J.Utils.SetCachedVars('GetCoresAverageNetworth'..cacheKey, res)
	return res
end

function J.GetCoresMaxNetworth()
	local cacheKey = tostring(GetTeam())
	local cache = J.Utils.GetCachedVars('GetCoresMaxNetworth'..cacheKey, 2)
	if cache ~= nil then return cache end

	local maxNetWorth = 0
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)
		if J.IsValidHero(member)
		and J.IsCore(member) then
			local networth = member:GetNetWorth()
			if networth > maxNetWorth
			then
				maxNetWorth = networth
			end
		end
	end

	J.Utils.SetCachedVars('GetCoresMaxNetworth'..cacheKey, maxNetWorth)
	return maxNetWorth
end

function J.IsLocHaveTower( nRadius, bEnemy, nLoc )

	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	if ( not bEnemy and J.GetLocationToLocationDistance( nLoc, J.GetTeamFountain() ) < 2500 )
		or ( bEnemy and J.GetLocationToLocationDistance( nLoc, J.GetEnemyFountain() ) < 2500 )
	then
		return true
	end

	for i = 0, 10
	do
		local tower = GetTower( nTeam, i )
		if tower ~= nil and GetUnitToLocationDistance( tower, nLoc ) <= nRadius
		then
			 return true
		end
	end

	return false

end


function J.GetNearbyLocationToTp( nLoc )

	local nTeam = GetTeam()
	local nFountain = J.GetTeamFountain()

	if J.GetLocationToLocationDistance( nLoc, nFountain ) <= 2500
	then
		return nLoc
	end

	local targetTower = nil
	local minDist = 99999
	for i=0, 10, 1 do
		local tower = GetTower( nTeam, i )
		if tower ~= nil
			and GetUnitToLocationDistance( tower, nLoc ) < minDist
		then
			 targetTower = tower
			 minDist = GetUnitToLocationDistance( tower, nLoc )
		end
	end

	local watchTowerList = J.Site.GetAllWatchTower()
	for _, watchTower in pairs( watchTowerList )
	do
		if watchTower ~= nil
			and watchTower:GetTeam() == nTeam
			and GetUnitToLocationDistance( watchTower, nLoc ) < minDist - 1300
			and ( not J.IsEnemyHeroAroundLocation( watchTower:GetLocation(), 600 )
					or J.IsAllyHeroAroundLocation( watchTower:GetLocation(), 600 ) )
		then
			 targetTower = watchTower
			 minDist = GetUnitToLocationDistance( watchTower, nLoc ) + 1300
		end
	end

	if targetTower ~= nil
	then
		return J.GetLocationTowardDistanceLocation( targetTower, nLoc, 575 )
	end

	return nFountain

end


function J.IsEnemyFacingUnit( bot, nRadius, nDegrees )

	local nLoc = bot:GetLocation()

	if nRadius > 1600 then nRadius = 1600 end
	local nEnemyHeroes = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemyHeroes )
	do
		if J.IsValid( enemy )
			and enemy:IsFacingLocation( nLoc, nDegrees )
		then
			return true
		end
	end

	return false

end


function J.IsAllyFacingUnit( bot, nRadius, nDegrees )

	local nLoc = bot:GetLocation()
	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member ~= bot
			and GetUnitToUnitDistance( member, bot ) <= nRadius
			and member:IsFacingLocation( nLoc, nDegrees )
		then
			return true
		end
	end

	return false

end


function J.IsEnemyTargetUnit( nUnit, nRadius )

	if nRadius > 1600 then nRadius = 1600 end
	local nEnemyHeroes = J.GetNearbyHeroes(GetBot(), nRadius, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemyHeroes )
	do
		if J.IsValid( enemy )
			and J.GetProperTarget( enemy ) == nUnit
		then
			return true
		end
	end

	return false

end


function J.IsCastingUltimateAbility( bot )

	if bot:CanBeSeen() and (bot:IsCastingAbility() or bot:IsUsingAbility())
	then
		local nAbility = bot:GetCurrentActiveAbility()
		if nAbility ~= nil
			and nAbility:IsUltimate()
		then
			return true
		end
	end

	return false

end


function J.IsInAllyArea( bot )

	local hAllyAcient = GetAncient( GetTeam() )
	local hEnemyAcient = GetAncient( GetOpposingTeam() )
	
	if GetUnitToUnitDistance( bot, hAllyAcient ) + 768 < GetUnitToUnitDistance( bot, hEnemyAcient )
	then
		return true
	end
	
	return false

end


function J.IsInEnemyArea( bot )

	local hAllyAcient = GetAncient( GetTeam() )
	local hEnemyAcient = GetAncient( GetOpposingTeam() )
	
	if GetUnitToUnitDistance( bot, hEnemyAcient ) + 1280 < GetUnitToUnitDistance( bot, hAllyAcient )
	then
		return true
	end
	
	return false

end


function J.IsAnyAllyHeroSurroundedByManyAllies()

	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and #J.GetNearbyHeroes(npcAlly, 1600, false, BOT_MODE_NONE) >= 3
		then
			return true
		end
	end

	return false

end

function J.IsAllyHeroAroundLocation( vLoc, nRadius )

	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and GetUnitToLocationDistance( npcAlly, vLoc ) <= nRadius
		then
			return true
		end
	end

	return false

end


function J.IsEnemyHeroAroundLocation( vLoc, nRadius )
	local cacheKey = tostring(vLoc.x)..'-'..tostring(vLoc.y)..'-'..tostring(nRadius)
	local cache = J.Utils.GetCachedVars('IsEnemyHeroAroundLocation'..cacheKey, 0.5)
	if cache ~= nil then return cache end

	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id ) then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
					and J.GetLocationToLocationDistance( vLoc, dInfo.location ) <= nRadius
					and dInfo.time_since_seen < 2.0
				then
					J.Utils.SetCachedVars('IsEnemyHeroAroundLocation'..cacheKey, true)
					return true
				end
			end
		end
	end

	J.Utils.SetCachedVars('IsEnemyHeroAroundLocation'..cacheKey, false)
	return false

end

function J.GetLastSeenEnemiesNearLoc(vLoc, nRadius)
	local cacheKey = tostring(vLoc.x)..'-'..tostring(vLoc.y)..'-'..tostring(nRadius)
	local cache = J.Utils.GetCachedVars('GetLastSeenEnemiesNearLoc'..cacheKey, 0.5)
	if cache ~= nil then return cache end

	local enemies = {}

	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id ) then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
					and J.GetLocationToLocationDistance( vLoc, dInfo.location ) <= nRadius
					and dInfo.time_since_seen < 5.0
				then
					table.insert(enemies, id)
				end
			end
		end
	end

	J.Utils.SetCachedVars('GetLastSeenEnemiesNearLoc'..cacheKey, count)
	return enemies
end

function J.GetNumOfAliveHeroes( bEnemy )
	local count = 0
	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	local cacheKey = tostring(nTeam)
	local cache = J.Utils.GetCachedVars('GetNumOfAliveHeroes'..cacheKey, 0.5)
	if cache ~= nil then return cache end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		if IsHeroAlive( id )
		then
			count = count + 1
		end
	end

	J.Utils.SetCachedVars('GetNumOfAliveHeroes'..cacheKey, count)
	return count

end

function J.GetNumOfHeroesNearLocation( bEnemy, location, distance )
	local count = 0
	local heroList = bEnemy and GetUnitList( UNIT_LIST_ENEMY_HEROES ) or GetUnitList( UNIT_LIST_ALLIED_HEROES )
	for _, hero in pairs( heroList )
	do
		if hero ~= nil and hero:IsAlive() and hero:CanBeSeen() and GetUnitToLocationDistance(hero, location) <= distance then
			count = count + 1
		end
	end
	return count
end

function J.GetHeroesNearLocation( bEnemy, location, distance )
	local heroes = { }
	local heroList = bEnemy and GetUnitList( UNIT_LIST_ENEMY_HEROES ) or GetUnitList( UNIT_LIST_ALLIED_HEROES )
	for _, hero in pairs( heroList )
	do
		if hero ~= nil and hero:IsAlive() and hero:CanBeSeen() and GetUnitToLocationDistance(hero, location) <= distance then
			table.insert(heroes, hero)
		end
	end
	return heroes

end

function J.GetAverageLevel( bEnemy )
	local count = 0
	local sum = 0
	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	local cacheKey = 'GetAverageLevel'..tostring(nTeam)
	local cache = J.Utils.GetCachedVars(cacheKey, 1)
	if cache ~= nil then return cache end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		sum = sum + GetHeroLevel( id )
		count = count + 1
	end

	local res = sum / count

	J.Utils.SetCachedVars(cacheKey, res)
	return res

end

function J.GetNumOfTeamTotalKills( bEnemy )

	local count = 0
	local nTeam = GetOpposingTeam()
	if bEnemy then nTeam = GetTeam() end

	local cacheKey = 'GetNumOfTeamTotalKills'..tostring(nTeam)
	local cache = J.Utils.GetCachedVars(cacheKey, 1)
	if cache ~= nil then return cache end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		count = count + GetHeroDeaths( id )
	end

	J.Utils.SetCachedVars(cacheKey, count)
	return count

end

function J.IsEarlyGame()
	if DotaTime() < (J.IsModeTurbo() and 8 * 60 or 15 * 60) then
		return true
	end
	return false
end

function J.IsMidGame()
	if DotaTime() > (J.IsModeTurbo() and 8 * 60 or 15 * 60) and DotaTime() < (J.IsModeTurbo() and 18 * 60 or 30 * 60) then
		return true
	end
	return false
end

function J.IsLateGame()
	if DotaTime() > (J.IsModeTurbo() and 18 * 60 or 30 * 60) then
		return true
	end
	return false
end

function J.DotProduct(A, B)
	return A.x * B.x + A.y * B.y + A.z * B.z
end

function J.ConsiderForMkbDisassembleMask( bot )

	if bot.maskDismantleDone == nil then bot.maskDismantleDone = false end
	if bot.staffUnlockDone == nil then bot.staffUnlockDone = false end
	if bot.lifestealUnlockDone == nil then bot.lifestealUnlockDone = false end
	if bot.dismantleCheckTime == nil then bot.dismantleCheckTime = 600 end

	if bot.staffUnlockDone then return end

	if bot.dismantleCheckTime < DotaTime() + 1.0
	then
		bot.dismantleCheckTime = DotaTime()

		local mask	 = bot:FindItemSlot( "item_mask_of_madness" )
		local claymore = bot:FindItemSlot( "item_claymore" )
		local reaver	= bot:FindItemSlot( "item_reaver" )

		if not bot.maskDismantleDone
			and ( bot:GetItemInSlot( 6 ) == nil or bot:GetItemInSlot( 7 ) == nil or bot:GetItemInSlot( 8 ) == nil )
		then

			if mask >= 0 and mask <= 8
				and ( ( reaver >= 0 and reaver <= 8 ) or ( claymore >= 0 and claymore <= 8 ) )
				and ( bot:GetGold() >= 1400 or bot:GetStashValue() >= 1400 or bot:GetCourierValue() >= 1400 )
			then
				if bDebugMode then print( bot:GetUnitName().." mask Dismantle1" ) end
				bot.maskDismantleDone = true
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot( mask ) )
				return
			end

			if mask >= 0 and mask <= 8
				and claymore >= 0 and reaver >= 0
			then
				if bDebugMode then print( bot:GetUnitName().." mask Dismantle2" ) end
				bot.maskDismantleDone = true
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot( mask ) )
				return
			end
		end

		if not bot.maskDismantleDone then return end

		local lifesteal = bot:FindItemSlot( "item_lifesteal" )
		local staff = bot:FindItemSlot( "item_quarterstaff" )

		if lifesteal >= 0
			and not bot.lifestealUnlockDone
		then
			if bDebugMode then print( bot:GetUnitName().." lifestealUnlockDone" ) end
			bot.lifestealUnlockDone = true
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot( lifesteal ), false )
			return
		end

		local satanic = bot:FindItemSlot( "item_satanic" )

		if satanic >= 0 and staff >= 0 and not bot.staffUnlockDone
		then
			if bDebugMode then print( bot:GetUnitName().." staffUnlockDone" ) end
			bot.staffUnlockDone = true
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot( staff ), false )
			return
		end

	end
end


local LastActionTime = {}
function J.HasNotActionLast( nCD, nNumber )

	if LastActionTime[nNumber] == nil then LastActionTime[nNumber] = -90 end

	if DotaTime() > LastActionTime[nNumber] + nCD
	then
		LastActionTime[nNumber] = DotaTime()
		return true
	end

	return false

end


function J.GetCastDelay( bot, unit, nPointTime, nProjectSpeed )

	local nDist = GetUnitToUnitDistance( bot, unit )

	local nDistTime = 0
	if nProjectSpeed ~= 0 then nDistTime = nDist / nProjectSpeed end

	return nPointTime + nDistTime

end


function J.CanBreakTeleport( bot, unit, nPointTime, nProjectSpeed )

	if unit:HasModifier( "modifier_teleporting" )
	then
		return J.GetCastPoint( bot, unit, nPointTime, nProjectSpeed ) < J.GetModifierTime( unit, "modifier_teleporting" )
	end

	return true

end

-- NEWLY ADDED FUNCTIONS FOR NEW HEROES AND BEHAVIOUR

function J.CanBeCast(ability)
	return ability:IsTrained() and ability:IsFullyCastable() and ability:IsHidden() == false;
end

function J.CanSpamSpell(bot, manaCost)
	local initialRatio = 1.0;
	if manaCost < 100 then
		initialRatio = 0.6;
	end
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( initialRatio - bot:GetLevel()/(3*30) );
end

local maxAddedRange = 200
local maxGetRange = 1600
function J.GetProperCastRange(bIgnore, hUnit, abilityCR)
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + maxAddedRange;
	elseif abilityCR + maxAddedRange <= maxGetRange then
		return abilityCR + maxAddedRange;
	elseif abilityCR > maxGetRange then
		return maxGetRange;
	else
		return abilityCR;
	end
end

function J.GetLowestHPUnit(tUnits, bIgnoreImmune)
	local lowestHP   = 100000;
	local lowestUnit = nil; 
	for _,unit in pairs(tUnits)
	do
		local hp = unit:GetHealth()
		if hp < lowestHP and ( bIgnoreImmune or ( not bNotMagicImmune and not unit:IsMagicImmune() ) ) then
			lowestHP   = hp;
			lowestUnit = unit;
		end
	end
	return lowestUnit;
end

local maxLevel = 30
function J.AllowedToSpam(bot, manaCost)
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( 1.0 - bot:GetLevel()/(2*maxLevel) );
end

function J.CountVulnerableUnit(tUnits, locAOE, nRadius, nUnits)
	local count = 0;
	if locAOE.count >= nUnits then
		for _,unit in pairs(tUnits)
		do
			if GetUnitToLocationDistance(unit, locAOE.targetloc) <= nRadius and not unit:IsInvulnerable() then
				count = count + 1;
			end
		end
	end
	return count;
end

function J.GetProperLocation(hUnit, nDelay)
	if hUnit:GetMovementDirectionStability() >= 0 then
		return hUnit:GetExtrapolatedLocation(nDelay);
	end
	return hUnit:GetLocation();
end

function J.CountNotStunnedUnits(tUnits, locAOE, nRadius, nUnits)
	local count = 0;
	if locAOE.count >= nUnits then
		for _,unit in pairs(tUnits)
		do
			if GetUnitToLocationDistance(unit, locAOE.targetloc) <= nRadius and not unit:IsInvulnerable() and not J.IsDisabled(unit) then
				count = count + 1;
			end
		end
	end
	return count;
end

function J.CountInvUnits(pierceImmune, units)
	local nUnits = 0;
	if units ~= nil then
		for _,u in pairs(units) do
			if ( pierceImmune and J.CanCastOnMagicImmune(u) ) or ( not pierceImmune and J.CanCastOnNonMagicImmune(u) )  then
				nUnits = nUnits + 1;
			end
		end
	end
	return nUnits;
end

function J.GetMostHPPercent(listUnits, magicImmune)
	local mostPHP = 0;
	local mostPHPUnit = nil;
	for _,unit in pairs(listUnits)
	do
		local uPHP = unit:GetHealth() / unit:GetMaxHealth()
		if ( ( magicImmune and J.CanCastOnMagicImmune(unit) ) or ( not magicImmune and J.CanCastOnNonMagicImmune(unit) ) ) 
			and uPHP > mostPHP  
		then
			mostPHPUnit = unit;
			mostPHP = uPHP;
		end
	end
	return mostPHPUnit;
end

function J.HasAghanimsShard(bot)
	return bot:HasModifier("modifier_item_aghanims_shard")
end

function J.GetCanBeKilledUnit(units, nDamage, nDmgType, magicImmune)
	local target = nil
	for _,unit in pairs(units)
	do
		if ((magicImmune and J.CanCastOnMagicImmune(unit) ) or ( not magicImmune and J.CanCastOnNonMagicImmune(unit)))
			   and J.CanKillTarget(unit, nDamage, nDmgType)
		then
			target = unit
		end
	end
	return target
end

function J.GetClosestUnit(units)
	local target = nil;
	if units ~= nil and #units >= 1 then
		return units[1];
	end
	return target;
end

function J.IsModeTurbo()
	for _, u in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if u ~= nil
		and u:GetUnitName() == 'npc_dota_courier'
		then
			if u:GetCurrentMovementSpeed() == 1100
			then
				return true
			end
		end
	end

    return false
end

function J.IsCore(bot)
	return J.GetPosition(bot) <= 3
end

function J.GetCoresTotalNetworth()
	local totalNetworth = GetTeamMember(1):GetNetWorth()
				  	    + GetTeamMember(2):GetNetWorth()
				  		+ GetTeamMember(3):GetNetWorth()
	return totalNetworth
end

-- returns 1, 2, 3, 4, or 5 as the position of the hero in the team
function J.GetPosition(bot)
	local role = J.Role.GetPosition(bot)
	if role == nil then
		-- print('[ERROR] Failed to get role for bot: '..bot:GetUnitName())
		role = 2
	end
	return role
end

function J.WeAreStronger(bot, radius)
	if radius > 1600 then radius = 1600 end

	local cacheKey = tostring(bot:GetPlayerID())..'-'..tostring(radius)
	local cache = J.Utils.GetCachedVars('WeAreStronger'..cacheKey, 0.5)
	if cache ~= nil then return cache end

    local mates = J.GetNearbyHeroes(bot,radius, false, BOT_MODE_NONE);
    local enemies = J.GetNearbyHeroes(bot,radius, true, BOT_MODE_NONE);

    local ourPower = 0;
    local enemyPower = 0;

    for _, h in pairs(mates) do
		if J.IsValid(h) and not J.IsSuspiciousIllusion(h) then
			ourPower = ourPower + h:GetOffensivePower();
		end
    end

    for _, h in pairs(enemies) do
		if J.IsValid(h) and not J.IsSuspiciousIllusion(h) then
        	enemyPower = enemyPower + h:GetRawOffensivePower();
		end
    end

    local res = #mates > #enemies and ourPower > enemyPower
	J.Utils.SetCachedVars('WeAreStronger'..cacheKey, res)
    return res
end

function J.RandomForwardVector(length)

    local offset = RandomVector(length)

    if GetTeam() == TEAM_RADIANT then
        offset.x = offset.x > 0 and offset.x or -offset.x
        offset.y = offset.y > 0 and offset.y or -offset.y
    end

    if GetTeam() == TEAM_DIRE then
        offset.x = offset.x < 0 and offset.x or -offset.x
        offset.y = offset.y < 0 and offset.y or -offset.y
    end

    return offset
end

function J.GetUnitWithMinDistanceToLoc(hUnit, hUnits, cUnits, fMinDist, vLoc)
	local minUnit = cUnits;
	local minVal = fMinDist;
	
	for i=1, #hUnits do
		if hUnits[i] ~= nil and hUnits[i] ~= hUnit and J.CanCastOnNonMagicImmune(hUnits[i]) 
		then
			local dist = GetUnitToLocationDistance(hUnits[i], vLoc);
			if dist < minVal then
				minVal = dist;
				minUnit = hUnits[i];	
			end
		end	
	end
	
	return minVal, minUnit;
end

function J.GetUnitWithMaxDistanceToLoc(hUnit, hUnits, cUnits, fMinDist, vLoc)
	local maxUnit = cUnits
	local maxVal = fMinDist
	
	for i=1, #hUnits do
		if hUnits[i] ~= nil and hUnits[i] ~= hUnit and J.CanCastOnNonMagicImmune(hUnits[i])
		then
			local dist = GetUnitToLocationDistance(hUnits[i], vLoc)
			if dist > maxVal then
				maxVal = dist
				maxUnit = hUnits[i]
			end
		end	
	end
	
	return maxVal, maxUnit
end

function J.GetFurthestUnitToLocationFrommAll(hUnit, nRange, vLoc)
	local aHeroes = J.GetNearbyHeroes(hUnit,nRange, false, BOT_MODE_NONE)
	local eHeroes = J.GetNearbyHeroes(hUnit,nRange, true, BOT_MODE_NONE)
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false)
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true)

	local botDist = GetUnitToLocationDistance(hUnit, vLoc)
	local furthestUnit = hUnit
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, aHeroes, furthestUnit, botDist, vLoc)
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, eHeroes, furthestUnit, botDist, vLoc)
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, aCreeps, furthestUnit, botDist, vLoc)
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, eCreeps, furthestUnit, botDist, vLoc)

	if furthestUnit ~= hUnit then
		return furthestUnit
	end

	return nil

end

function J.GetClosestUnitToLocationFrommAll(hUnit, nRange, vLoc)
	local aHeroes = J.GetNearbyHeroes(hUnit,nRange, false, BOT_MODE_NONE);
	local eHeroes = J.GetNearbyHeroes(hUnit,nRange, true, BOT_MODE_NONE);
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = GetUnitToLocationDistance(hUnit, vLoc);
	local closestUnit = hUnit;
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aCreeps, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= hUnit then
		return closestUnit;
	end
	
	return nil;
	
end

function J.GetClosestUnitToLocationFrommAll2(hUnit, nRange, vLoc)
	local aHeroes = J.GetNearbyHeroes(hUnit,nRange, false, BOT_MODE_NONE);
	local eHeroes = J.GetNearbyHeroes(hUnit,nRange, true, BOT_MODE_NONE);
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = 10000;
	local closestUnit = nil;
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aCreeps, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= nil then
		return closestUnit;
	end
	
	return nil;
	
end

function J.CheckTimeOfDay()
    local cycle = 600
    local time = DotaTime() % cycle
    local night = 300

    if time < night then return "day", time
    else return "night", time
    end
end

function J.GetArmorReducers(hero)
	local reducedArmor = 0

	-- Items (Passives for now)
	if J.HasItem(hero, "item_desolator")
	and (hero:GetItemInSlot (6) ~= "item_desolator" or hero:GetItemInSlot(7) ~= "item_desolator" or hero:GetItemInSlot(8) ~= "item_desolator")
	then
		reducedArmor = reducedArmor + 6
	end

	if J.HasItem(hero, "item_assault")
	and (hero:GetItemInSlot (6) ~= "item_assault" or hero:GetItemInSlot(7) ~= "item_assault" or hero:GetItemInSlot(8) ~= "item_assault")
	then
		reducedArmor = reducedArmor + 5
	end

	if J.HasItem(hero, "item_blight_stone")
	and (hero:GetItemInSlot (6) ~= "item_blight_stone" or hero:GetItemInSlot(7) ~= "item_blight_stone" or hero:GetItemInSlot(8) ~= "item_blight_stone")
	then
		reducedArmor = reducedArmor + 2
	end

	-- Abilities (Passives for now)
	local NevermoreDarkLord = hero:GetAbilityByName("nevermore_dark_lord")
	if hero:GetUnitName() == "npc_dota_hero_nevermore"
	and NevermoreDarkLord ~= nil
	and NevermoreDarkLord:GetLevel() > 0
	then
		reducedArmor = reducedArmor + NevermoreDarkLord:GetSpecialValueInt("presence_armor_reduction")
	end

	local NagaSirenRiptide = hero:GetAbilityByName("naga_siren_rip_tide")
	if hero:GetUnitName() == "npc_dota_hero_naga_siren"
	and NagaSirenRiptide ~= nil
	and NagaSirenRiptide:GetLevel() > 0 then
		reducedArmor = reducedArmor + NagaSirenRiptide:GetSpecialValueInt("armor_reduction")
	end

	return reducedArmor
end

local killTime = 0.0
function J.IsRoshanAlive()
	if GetRoshanKillTime() > killTime
    then
        killTime = GetRoshanKillTime()
    end

    if GetRoshanKillTime() == 0
	or DotaTime() - killTime > (J.IsModeTurbo() and (6 * 60) or (11 * 60))
    then
        return true
    end

    return false
end

function J.HasEnoughDPSForRoshan(heroes)
    local DPS = 0
    local DPSThreshold = 0
    local plannedTimeToKill = 60

    -- Roshan Stats
    local baseHealth = 6000
    local baseArmor = 30
    local armorPerInterval = 0.375
    local maxHealthBonusPerInterval = 130 * 2

    local roshanHealth = baseHealth + maxHealthBonusPerInterval * math.floor(DotaTime() / 60)

    for _, h in pairs(heroes) do
        local roshanArmor = baseArmor + armorPerInterval * math.floor(DotaTime() / 60) - J.GetArmorReducers(h)

        -- Only right click damage for now
        local attackDamage = h:GetAttackDamage()
        local attackSpeed = h:GetAttackSpeed()

        local dps = attackDamage * attackSpeed * (1 - roshanArmor / (roshanArmor + 20))
        DPS = DPS + dps
    end

    DPS =  DPS / #heroes

    DPSThreshold = roshanHealth / plannedTimeToKill
    return DPS >= DPSThreshold
end

function J.IsNotSelf(bot, ally)
	if bot:GetUnitName() ~= ally:GetUnitName()
	then
		return true
	end

	return false
end

function J.IsThereNonSelfCoreNearby(nRadius)
	local selfBot = GetBot()
    local nAllyHeroes = J.GetNearbyHeroes(selfBot,nRadius, false, BOT_MODE_NONE)

    for _, ally in pairs(nAllyHeroes) do
        if J.IsCore(ally) and selfBot ~= ally
        then
            return true
        end
    end

    return false
end

function J.GetAliveAllyCoreCount()
	local count = 0
	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and J.IsCore(allyHero)
		and not allyHero:IsIllusion()
		then
			count = count + 1
		end
	end

	return count
end

function J.GetStrongestUnit(nRange, hUnit, bEnemy, bMagicImune, fTime)
	local units = J.GetNearbyHeroes(hUnit,nRange, bEnemy, BOT_MODE_NONE)
	local strongest = nil
	local maxPower = 0

	for i = 1, #units do
		if J.IsValidTarget(units[i])
		and J.IsValidTarget(hUnit)
		and ((bMagicImune == true and J.CanCastOnMagicImmune(units[i]) == true) or (bMagicImune == false and J.CanCastOnNonMagicImmune(units[i]) == true))
		then
			local power = units[i]:GetEstimatedDamageToTarget(true, hUnit, fTime, DAMAGE_TYPE_ALL)

			if power > maxPower
			then
				maxPower = power
				strongest = units[i]
			end
		end
	end
	return strongest
end

function J.GetDistance(s, t)
    return math.sqrt((s[1] - t[1]) * (s[1]-t[1]) + (s[2] - t[2]) * (s[2] - t[2]))
end

function J.IsHeroBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local bot = GetBot()

	local nAllyHeroes = J.GetNearbyHeroes(bot,1600, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
    do
		if allyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, allyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
		if enemyHero ~= hSource
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end

function J.IsEnemyBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local bot = GetBot()

	local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
		if enemyHero ~= hSource
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end

function J.IsHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyHeroes = J.GetNearbyHeroes(hSource,1600, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
    do
		if allyHero ~= hTarget and allyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, allyHero:GetLocation())
			if tResult ~= nil and tResult.within == true and tResult.distance < nRadius then return true end
		end
	end

	local nEnemyHeroes = J.GetNearbyHeroes(hSource,1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
		if enemyHero ~= hTarget and enemyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end

function J.IsCreepBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local bot = GetBot()

	local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
	for _, creep in pairs(nAllyLaneCreeps)
    do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
	end

	local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, false)
	for _, creep in pairs(nEnemyLaneCreeps)
    do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())

		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
	end

	return false
end

function J.IsUnitBetweenMeAndLocation(hSource, hTarget, vTargetLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vTargetLoc

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALL))
	do
		if J.IsValid(unit)
		and GetUnitToUnitDistance(GetBot(), unit) <= 1600
		and not unit:IsBuilding()
		and not string.find(unit:GetUnitName(), 'ward')
		and hSource ~= unit
		and hTarget ~= unit
		then
			local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius then return true end
		end
	end

	return false
end

function J.IsNonSiegeCreepBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, true)
	for _, creep in pairs(nAllyLaneCreeps)
    do
		if J.IsValid(creep)
		and not J.IsKeyWordUnit('siege', creep)
		then
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	local nEnemyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, false)
	for _, creep in pairs(nEnemyLaneCreeps)
    do
		if J.IsValid(creep)
		and not J.IsKeyWordUnit('siege', creep)
		then
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end

function J.IsThereCoreNearby(nRadius)
	for i = 1, 5
	do
		local allyHero = GetTeamMember(i)
		if allyHero ~= nil
		and allyHero ~= GetBot()
		and J.IsCore(allyHero)
		and J.IsInRange(GetBot(), allyHero, nRadius)
		then
			return true
		end
	end

    return false
end

function J.GetClosestCore(bot, nRadius)
	for i = 1, 5
	do
		local member = GetTeamMember(i)

		if  member ~= nil
		and member:IsAlive()
		and member ~= bot
		and J.IsCore(bot)
		and GetUnitToUnitDistance(bot, member) <= nRadius
		and not J.IsSuspiciousIllusion(member)
		then
			return member
		end
	end

	return nil
end

function J.IsCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local creeps = hSource:GetNearbyCreeps(1600, false)
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
			return true
		end
	end
	
	if hTarget:IsHero() then
		creeps = hTarget:GetNearbyCreeps(1600, true)
		for i,creep in pairs(creeps) do
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
				return true
			end
		end
	end
	
	creeps = hSource:GetNearbyCreeps(1600, true)
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
			return true
		end
	end
	
	if hTarget:IsHero() then
		creeps = hTarget:GetNearbyCreeps(1600, false)
		for i,creep in pairs(creeps) do
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
				return true
			end
		end
	end
	
	return false
end

-- function J.IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
-- 	local vStart = hSource:GetLocation()
-- 	local vEnd = vLoc

-- 	local nAllyLaneCreeps = hTarget:GetNearbyLaneCreeps(1600, false)
-- 	for _, creep in pairs(nAllyLaneCreeps)
-- 	do
-- 		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
-- 		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
-- 	end

-- 	local nEnemyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, true)
-- 	for _, creep in pairs(nEnemyLaneCreeps)
-- 	do
-- 		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
-- 		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
-- 	end

-- 	return false
-- end

-- function J.IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
-- 	local vStart = hSource:GetLocation()
-- 	local vEnd = vLoc

-- 	local nAllyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, false)
-- 	for _, creep in pairs(nAllyLaneCreeps)
-- 	do
-- 		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
-- 		if tResult ~= nil and tResult.within and tResult.distance < nRadius then
-- 			return true
-- 		end
-- 	end

-- 	local nEnemyLaneCreeps = hTarget:GetNearbyLaneCreeps(1600, true)
-- 	for _, creep in pairs(nEnemyLaneCreeps)
-- 	do
-- 		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
-- 		if tResult ~= nil and tResult.within and tResult.distance < nRadius then
-- 			return true
-- 		end
-- 	end

-- 	return false
-- end

function J.IsAllyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyHeroes = J.GetNearbyHeroes(hSource, 1600, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
	do
		if allyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, allyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then return true end
		end
	end

	local nEnemyHeroes = J.GetNearbyHeroes(hTarget, 1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if enemyHero ~= hSource
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then return true end
		end
	end

	return false
end

local sIgnoreAbilityIndex = {
	["antimage_blink"] = true,
	["arc_warden_magnetic_field"] = true,
	["arc_warden_spark_wraith"] = true,
	["arc_warden_tempest_double"] = true,
	["chaos_knight_phantasm"] = true,
	["clinkz_burning_army"] = true,
	["death_prophet_exorcism"] = true,
	["dragon_knight_elder_dragon_form"] = true,
	["juggernaut_healing_ward"] = true,
	["necrolyte_death_pulse"] = true,
	["necrolyte_sadist"] = true,
	["omniknight_guardian_angel"] = true,
	["phantom_assassin_blur"] = true,
	["pugna_nether_ward"] = true,
	["skeleton_king_mortal_strike"] = true,
	["sven_warcry"] = true,
	["sven_gods_strength"] = true,
	["templar_assassin_refraction"] = true,
	["templar_assassin_psionic_trap"] = true,
	["windrunner_windrun"] = true,
	["witch_doctor_voodoo_restoration"] = true,
}
function J.DidEnemyCastAbility()
	local bot = GetBot()
	local nEnemyHeroes = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

	for _, npcEnemy in pairs(nEnemyHeroes)
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
		and npcEnemy:IsFacingLocation(bot:GetLocation(), 30)
		and (npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility())
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
			then
				local nAbilityBehavior = nAbility:GetBehavior()
				local sAbilityName = nAbility:GetName()

				if nAbilityBehavior ~= ABILITY_BEHAVIOR_UNIT_TARGET
				and (npcEnemy:IsBot() or npcEnemy:GetLevel() >= 5)
				and not sIgnoreAbilityIndex[sAbilityName]
				then
					return true
				end

				if nAbilityBehavior == ABILITY_BEHAVIOR_UNIT_TARGET
				and npcEnemy:GetLevel() >= 6
				and not npcEnemy:IsBot()
				and not J.IsAllyUnitSpell(sAbilityName)
				and (not J.IsProjectileUnitSpell(sAbilityName) or J.IsInRange(bot, npcEnemy, 400))
				then
					return true
				end
			end
		end
	end

	return false
end

function J.GetWeakestUnit(nEnemyUnits)
	return J.GetAttackableWeakestUnitFromList( nil, nEnemyUnits )
end

function J.HasInvisibilityOrItem( npcEnemy )

	if npcEnemy:HasInvisibility( false )
		or J.HasItem( npcEnemy, "item_shadow_amulet" )
		or J.HasItem( npcEnemy, "item_glimmer_cape" )
		or J.HasItem( npcEnemy, "item_invis_sword" )
		or J.HasItem( npcEnemy, "item_silver_edge" )
	then
		return true
	end

	return false

end

function J.HasEnemyIceSpireNearby(bot, nRange)
	local cacheKey = 'HasEnemyIceSpireNearby'..tostring(bot:GetPlayerID())
	local cache = J.Utils.GetCachedVars(cacheKey, 2)
	if cache ~= nil then return cache end

	-- should also consider neutral creeps etc. tba.
	for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
        if J.IsValid(enemy)
		and enemy:GetUnitName() == "npc_dota_lich_ice_spire"
		and J.IsInRange(bot, enemy, nRange) then
			J.Utils.SetCachedVars(cacheKey, true)
			return enemy
		end
	end
	J.Utils.SetCachedVars(cacheKey, false)
	return false
end

function J.AnyAllyAffectedByChainFrost(bot, nRange)
	local cacheKey = 'AnyAllyAffectedByChainFrost'..tostring(bot:GetPlayerID())
	local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	if cache ~= nil then return cache end

	-- ally heroes, creeps, units.
	for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
        if J.IsValid(ally)
        and J.IsInRange(bot, ally, nRange)
		and ally ~= bot
        and ally:HasModifier('modifier_lich_chainfrost_slow') then
			J.Utils.SetCachedVars(cacheKey, true)
            return true
        end
    end
	J.Utils.SetCachedVars(cacheKey, false)
	return false
end

function J.AdjustLocationWithOffset(vLoc, offset, target)
	local targetLoc = vLoc

	local facingDir = target:GetFacing()
	local offsetX = offset * math.cos(facingDir)
	local offsetY = offset * math.sin(facingDir)

	targetLoc = targetLoc + Vector(offsetX, offsetY)

	return targetLoc
end

function J.AdjustLocationWithOffsetTowardsFountain(loc, distance)
	return J.Utils.GetOffsetLocationTowardsTargetLocation(loc, J.GetTeamFountain(), distance)
end

function J.IsInLaningPhase()
	return (
		(J.IsModeTurbo() and DotaTime() < 8 * 60)
		or DotaTime() < 12 * 60
	)
	and GetBot():GetNetWorth() < 5000
end

function J.IsTormentor(nTarget)
	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and string.find(nTarget:GetUnitName(), 'miniboss') ~= nil
end

function J.IsDoingTormentor(bot)
	return bot:GetActiveMode() == BOT_MODE_SIDE_SHOP
end

function J.IsLocationInChrono(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 300
		and enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			return true
		end
	end

	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and not allyHero:IsIllusion()
		and GetUnitToLocationDistance(allyHero, loc) < 300
		and (allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze'))
		then
			return true
		end
	end

	return false
end

function J.IsLocationInBlackHole(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 300
		and (enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			or enemyHero:HasModifier('modifier_enigma_black_hole_pull_scepter'))
		then
			return true
		end
	end

	return false
end

function J.IsEnemyChronosphereInLocation(loc)
	local nRadius = 500

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if J.IsValid(unit)
		and GetUnitToLocationDistance(unit, loc) <= nRadius
		and unit:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			return true
		end
	end

	return false
end

function J.IsEnemyBlackHoleInLocation(loc)
	local nRadius = 500

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if J.IsValid(unit)
		and GetUnitToLocationDistance(unit, loc) <= nRadius
		and (unit:HasModifier('modifier_enigma_black_hole_pull') or unit:HasModifier('modifier_enigma_black_hole_pull_scepter'))
		then
			return true
		end
	end

	return false
end


function J.IsLocationInArena(loc, radius)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < radius
		and (enemyHero:HasModifier('modifier_mars_arena_of_blood_leash')
			or enemyHero:HasModifier('modifier_mars_arena_of_blood_animation'))
		then
			return true
		end
	end

	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and not allyHero:IsIllusion()
		and GetUnitToLocationDistance(allyHero, loc) < radius
		and (allyHero:HasModifier('modifier_mars_arena_of_blood_animation'))
		then
			return true
		end
	end

	return false
end

function J.GetMeepos()
	local Meepos = {}

	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and allyHero:GetUnitName() == 'npc_dota_hero_meepo'
		and not J.IsSuspiciousIllusion(allyHero)
		then
			table.insert(Meepos, allyHero)
		end
	end

	return Meepos
end

function J.IsMeepoClone(hero)
	if J.IsValidHero(hero)
	and hero:GetUnitName() == 'npc_dota_hero_meepo'
	then
		for i = 0, 5
		do
			local hItem = hero:GetItemInSlot(i)

			if hItem ~= nil
			and not (hItem:GetName() == 'item_boots'
					or hItem:GetName() == 'item_tranquil_boots'
					or hItem:GetName() == 'item_arcane_boots'
					or hItem:GetName() == 'item_power_treads'
					or hItem:GetName() == 'item_phase_boots'
					or hItem:GetName() == 'item_travel_boots'
					or hItem:GetName() == 'item_boots_of_bearing'
					or hItem:GetName() == 'item_guardian_greaves'
					or hItem:GetName() == 'item_travel_boots_2'
				)  
			then
				return false
			end
		end

		return true
    end
end

function J.DoesSomeoneHaveModifier(nUnitList, modifierName)
	for _, unit in pairs(nUnitList)
	do
		if J.IsValid(unit)
		and unit:HasModifier(modifierName)
		then
			return true
		end
	end

	return false
end

IsHumanPlayerInTheTeam = {
	TEAM_RADIANT = nil,
	TEAM_DIRE = nil
}

function J.IsHumanPlayerInTeam()
	local sTeamName = GetTeam() == TEAM_RADIANT and 'TEAM_RADIANT' or 'TEAM_DIRE'

	if IsHumanPlayerInTheTeam[sTeamName] ~= nil then
		return IsHumanPlayerInTheTeam[sTeamName]
	end

	for _, member in pairs(GetTeamPlayers(GetTeam()))
	do
		if not IsPlayerBot(member)
		then
			IsHumanPlayerInTheTeam[sTeamName] = true
			return true
		end
	end

	IsHumanPlayerInTheTeam[sTeamName] = false
	return false
end

-- count the number of human vs bot players in the team. returns: #humen, #bots
function J.NumHumanBotPlayersInTeam()
	local nHuman, nBot = 0, 0
	for _, member in pairs(GetTeamPlayers(GetTeam()))
	do
		if not IsPlayerBot(member)
		then
			nHuman = nHuman + 1
		else
			nBot = nBot + 1
		end
	end

	return nHuman, nBot
end

function J.GetEnemiesAroundAncient(bot, nRadius)
	return J.GetEnemiesAroundLoc(GetAncient(bot:GetTeam()):GetLocation(), nRadius)
end

function J.GetEnemiesAroundLoc(vLoc, nRadius)
	if not nRadius then nRadius = 2000 end
	local cacheKey = tostring(vLoc.x)..'-'..tostring(vLoc.y)..'-'..tostring(nRadius)..'-'..tostring(GetOpposingTeam())
	local cache = J.Utils.GetCachedVars('GetEnemiesAroundLoc'..cacheKey, 0.5)
	if cache ~= nil then return cache end

	local nUnitCount = 0
	local ancientLoc = GetAncient(GetBot():GetTeam()):GetLocation()

	-- Check Heroes. 
	for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
				and J.GetLocationToLocationDistance(vLoc, dInfo.location) <= nRadius
				and dInfo.time_since_seen < 5.0
				then
					nUnitCount = nUnitCount + GetHeroLevel(id) / 3
					if J.GetLocationToLocationDistance(ancientLoc, vLoc) < 1600 then
						nUnitCount = nUnitCount + 2 -- Increase weight for critical defense.
					end
				end
			end
		end
	end

	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
	do
		if J.IsValid(unit)
		and GetUnitToLocationDistance(unit, vLoc) <= nRadius
		then
			local unitName = unit:GetUnitName()
			if unit:IsCreep() then
				nUnitCount = nUnitCount + 1
				if unit:IsAncientCreep()
				or unit:HasModifier('modifier_chen_holy_persuasion')
				or unit:HasModifier('modifier_dominated') then
					nUnitCount = nUnitCount + 1
				end
			elseif string.find(unit:GetUnitName(), 'spiderling') then nUnitCount = nUnitCount + 0.1
			elseif string.find(unit:GetUnitName(), 'eidolon') then nUnitCount = nUnitCount + 0.3
			elseif string.find(unitName, 'siege') and not string.find(unitName, 'upgraded') then
				nUnitCount = nUnitCount + 0.6
			elseif string.find(unitName, 'upgraded') then nUnitCount = nUnitCount + 1
			elseif string.find(unitName, 'warlock_golem') then
				if DotaTime() < 10 * 60 then nUnitCount = nUnitCount + 3
				elseif DotaTime() < 20 * 60 then nUnitCount = nUnitCount + 2.5
				elseif DotaTime() < 30 * 60 then nUnitCount = nUnitCount + 2
				else nUnitCount = nUnitCount + 1.5 end
			elseif string.find(unitName, 'lone_druid_bear') then nUnitCount = nUnitCount + 3
			elseif string.find(unitName, 'shadow_shaman_ward') then nUnitCount = nUnitCount + 2
			elseif string.find(unit:GetUnitName(), "tombstone") then nUnitCount = nUnitCount + 2
			elseif J.IsSuspiciousIllusion(unit) then
				if unit:HasModifier('modifier_arc_warden_tempest_double')
					or string.find(unit:GetUnitName(), 'chaos_knight')
					or string.find(unit:GetUnitName(), 'naga_siren') then nUnitCount = nUnitCount + 2 end
			elseif not (string.find(unitName, 'observer_wards') or string.find(unitName, 'sentry_wards')) then nUnitCount = nUnitCount + 1 end
			if J.GetLocationToLocationDistance(ancientLoc, vLoc) < 1600 then nUnitCount = nUnitCount + 2 end
		end
	end

	J.Utils.SetCachedVars('GetEnemiesAroundLoc'..cacheKey, nUnitCount)
	return nUnitCount
end

function J.FindEnemyUnit(name)
	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
	do
		if J.IsValid(unit)
		then
			if string.find(unit:GetUnitName(), name) then
				return unit
			end
		end
	end
	return nil
end

function J.GetHumanPing()
	local ping = nil

	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)
		if  member ~= nil
		and not member:IsBot()
		then
			return member, member:GetMostRecentPing()
		end
	end

	return nil, ping
end

function J.HasAbility(bot, abilityName)
	for i = 0, 23
	do
		local ability = bot:GetAbilityInSlot(i)
		if  ability ~= nil
		and ability:GetName() == abilityName
		then
			return true, ability
		end
	end

	return false, nil
end

function J.IsHumanInLoc(vLoc, nRadius)
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)

		if  member ~= nil and member:IsAlive() and not member:IsBot() and not member:IsIllusion()
		and not member:HasModifier("modifier_arc_warden_tempest_double")
		and not J.IsMeepoClone(member)
		and GetUnitToLocationDistance(member, vLoc) <= nRadius
		then
			return true
		end
	end

	return false
end

function J.GetCurrentRoshanLocation()
	local timeOfDay = J.CheckTimeOfDay()

	if timeOfDay == 'day'
	then
		return roshanRadiantLoc
	else
		return roshanDireLoc
	end
end

function J.GetTormentorLocation(team)
	if team == TEAM_RADIANT
	then
		return RadiantTormentorLoc
	else
		return DireTormentorLoc
	end
end

local AllyPIDs = nil
function J.IsClosestToDustLocation(bot, loc)
	if AllyPIDs == nil then AllyPIDs = GetTeamPlayers(GetTeam()) end

	local closest = nil
	local closestDist = 100000

	for _, id in pairs(AllyPIDs)
	do
		local member = GetTeamMember(id)

		if J.IsValidHero(member)		
		and member:GetItemSlotType(member:FindItemSlot('item_dust')) == ITEM_SLOT_TYPE_MAIN
		and member:GetItemInSlot(member:FindItemSlot('item_dust')):IsFullyCastable()
		and not J.IsSuspiciousIllusion(member)
		then
			local dist = GetUnitToLocationDistance(member, loc)

			if dist < closestDist
			then
				closest = member
				closestDist = dist
			end
		end
	end

	if closest ~= nil
	then
		return closest == bot
	end
end

function J.GetXUnitsTowardsLocation2(iLoc, tLoc, nUnits)
    local dir = (tLoc - iLoc):Normalized()
    return iLoc + dir * nUnits
end

function J.IsUnitWillGoInvisible(unit)
	return unit:HasModifier('modifier_sandking_sand_storm')
		or unit:HasModifier('modifier_bounty_hunter_wind_walk')
		or unit:HasModifier('modifier_clinkz_wind_walk')
		or unit:HasModifier('modifier_weaver_shukuchi')
		or (unit:HasModifier('modifier_oracle_false_promise') and unit:HasModifier('modifier_oracle_false_promise_invis'))
		or (unit:HasModifier('modifier_windrunner_windrun') and unit:HasModifier('modifier_windrunner_windrun_invis'))
		or unit:HasModifier('modifier_item_invisibility_edge')
		or unit:HasModifier('modifier_item_invisibility_edge_windwalk')
		or unit:HasModifier('modifier_item_silver_edge')
		or unit:HasModifier('modifier_item_silver_edge_windwalk')
		or unit:HasModifier('modifier_item_glimmer_cape_fade')
		or unit:HasModifier('modifier_item_glimmer_cape')
		or unit:HasModifier('modifier_item_shadow_amulet')
		or unit:HasModifier('modifier_item_shadow_amulet_fade')
		or unit:HasModifier('modifier_item_trickster_cloak_invis')
end

function J.HasInvisCounterBuff(unit)
	if unit:HasModifier('modifier_item_dustofappearance')
	or unit:HasModifier('modifier_bounty_hunter_track')
	or unit:HasModifier('modifier_bloodseeker_thirst_vision')
	or unit:HasModifier('modifier_slardar_amplify_damage')
	or unit:HasModifier('modifier_sniper_assassinate')
	or unit:HasModifier( 'modifier_faceless_void_chronosphere_freeze' )
	then
		return true
	end

	return false
end

function J.GetUnderlordPortal()
	local portal = {}

	for _, u in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if u:GetUnitName() == 'npc_dota_unit_underlord_portal'
		then
			if #portal == 1
			and portal[1] ~= u
			then
				table.insert(portal, u)
			end

			if #portal == 2
			then
				break
			end

			table.insert(portal, u)
		end
	end

	if #portal == 2
	then
		return portal
	end

	return nil
end

function J.GetTotalEstimatedDamageToTarget(nUnits, target)
	local dmg = 0

	for _, unit in pairs(nUnits)
	do
		if J.IsValid(unit)
		and J.IsValid(target)
		and not J.IsSuspiciousIllusion(unit)
		then
			dmg = dmg + unit:GetEstimatedDamageToTarget(true, target, 5, DAMAGE_TYPE_ALL)
		end
	end

	return dmg
end

function J.GetAliveCoreCount(nEnemy)
	local team = GetTeam()
	local count = 0

	if nEnemy
	then
		team = GetOpposingTeam()
	end

	local cacheKey = tostring(team)
	local cache = J.Utils.GetCachedVars('GetAliveCoreCount'..cacheKey, 0.5)
	if cache ~= nil then return cache end

	local heroID = GetTeamPlayers(team)
	if IsHeroAlive(heroID[1]) then count = count + 1 end
	if IsHeroAlive(heroID[2]) then count = count + 1 end
	if IsHeroAlive(heroID[3]) then count = count + 1 end

	J.Utils.SetCachedVars('GetAliveCoreCount'..cacheKey, count)
	return count
end

function J.GetEnemyCountInLane(lane)
	local count = 0
	local laneFront = GetLaneFrontLocation(GetTeam(), lane, 0)
	for _, id in pairs( GetTeamPlayers( GetOpposingTeam()))
	do
		if IsHeroAlive(id)
		then
			local info = GetHeroLastSeenInfo(id)

			if info ~= nil
			then
				local dInfo = info[1]

				if dInfo ~= nil
				and J.GetDistance(laneFront, dInfo.location) < 1600
				and dInfo.time_since_seen < 6
				then
					count = count + 1
				end
			end
		end
	end

	return count
end

function J.GetAllyCountInLane(lane, nRadius) -- not including self.
	local count = 0
	local laneFront = GetLaneFrontLocation(GetTeam(), lane, 0)
	for i, id in pairs(GetTeamPlayers(GetTeam()))
	do
		local member = GetTeamMember(i)
		if member:IsAlive()
		and member ~= GetBot()
		and not member:IsIllusion()
		and GetUnitToLocationDistance(member, laneFront) <= nRadius
		then
			count = count + 1
		end
	end
	return count
end

function J.GetManaAfter(manaCost)
	local bot = GetBot()
	return (bot:GetMana() - manaCost) / bot:GetMaxMana()
end
function J.GetHealthAfter(hpCost)
	local bot = GetBot()
	return (bot:GetHealth() - hpCost) / bot:GetMaxHealth()
end

function J.GetCreepListAroundTargetCanKill(target, nRadius, damage, bEnemy, bNeutral, bLaneCreep)
	if nRadius > 1600 then nRadius = 1600 end
	local creepList = {}

	if target ~= nil
	then
		if bNeutral
		then
			for _, creep in pairs(GetUnitList(UNIT_LIST_NEUTRAL_CREEPS))
			do
				if J.IsValid(creep)
				and target ~= creep
				and GetUnitToUnitDistance(target, creep) <= nRadius
				and creep:GetHealth() <= damage
				then
					table.insert(creepList, creep)
				end
			end
		elseif bLaneCreep
		then
			local unitList = GetUnitList(UNIT_LIST_ALLIED_CREEPS)
			if bEnemy
			then
				unitList = GetUnitList(UNIT_LIST_ENEMY_CREEPS)
			end

			for _, creep in pairs(unitList)
			do
				if J.IsValid(creep)
				and target ~= creep
				and GetUnitToUnitDistance(target, creep) <= nRadius
				and creep:GetHealth() <= damage
				then
					table.insert(creepList, creep)
				end
			end
		else
			local unitList = GetUnitList(UNIT_LIST_ALLIED_CREEPS)
			if bEnemy
			then
				unitList = GetUnitList(UNIT_LIST_ENEMY_CREEPS)
			end

			for _, creep in pairs(unitList)
			do
				if J.IsValid(creep)
				and target ~= creep
				and GetUnitToUnitDistance(target, creep) <= nRadius
				and creep:GetHealth() <= damage
				then
					table.insert(creepList, creep)
				end
			end

			unitList = GetUnitList(UNIT_LIST_NEUTRAL_CREEPS)
			for _, creep in pairs(unitList)
			do
				if J.IsValid(creep)
				and target ~= creep
				and GetUnitToUnitDistance(target, creep) <= nRadius
				and creep:GetHealth() <= damage
				then
					table.insert(creepList, creep)
				end
			end			
		end
	end

	return creepList
end

function J.GetPushTPLocation(nLane)
	local laneFront = GetLaneFrontLocation(GetTeam(), nLane, 0)
	local bestTpLoc = J.GetNearbyLocationToTp(laneFront)
	if J.GetLocationToLocationDistance(laneFront, bestTpLoc) < 1600
	then
		return bestTpLoc
	end
end

function J.GetDefendTPLocation(nLane)
	return GetLaneFrontLocation(GetTeam(), nLane, -950)
end

function J.GetRandomLocationWithinDist(sLoc, minDist, maxDist)
	local randomAngle = math.random() * 2 * math.pi
	local randomDist = math.random(minDist, maxDist)
	local newX = sLoc.x + randomDist * math.cos(randomAngle)
	local newY = sLoc.y + randomDist * math.sin(randomAngle)
	return Vector(newX, newY, sLoc.z)
end

function J.GetItem(itemName)
	for i = 0, 5
    do
		local item = GetBot():GetItemInSlot(i)

		if item ~= nil
        and item:GetName() == itemName
        then
			return item
		end
	end

	return nil
end

function J.GetItem2(bot, sItemName)
	for i = 0, 16
	do
		local item = bot:GetItemInSlot(i)
		if item ~= nil
		then
			if string.find(item:GetName(), sItemName)
			then
				return item
			end
		end
	end

	return nil
end

function J.GetHeroCountAttackingTarget(nUnits, target)
	local count = 0
	for _, hero in pairs(nUnits)
	do
		if J.IsValidHero(hero)
		and J.IsInRange(hero, target, 1600)
		and J.IsGoingOnSomeone(hero)
		and hero:CanBeSeen()
		and (hero:GetAttackTarget() == hero or hero:GetTarget() == hero)
		and not J.IsSuspiciousIllusion(hero)
		then
			count = count + 1
		end
	end

	return count
end

function J.GetHighestRightClickDamageHero(nUnits)
	local target = nil
	local dmg = 0
	for _, hero in pairs(nUnits)
	do
		if J.IsValidHero(hero)
		and not J.IsMeepoClone(hero)
		and not J.IsSuspiciousIllusion(hero)
		then
			if dmg < hero:GetAttackDamage()
			then
				dmg = hero:GetAttackDamage()
				target = hero
			end
		end
	end

	return target
end

function J.IsBigCamp(nUnits)
	for _, creep in pairs(nUnits)
	do
		if J.IsValid(creep)
		then
			if creep:GetUnitName() == 'npc_dota_neutral_satyr_hellcaller'
			or creep:GetUnitName() == 'npc_dota_neutral_polar_furbolg_ursa_warrior'
			or creep:GetUnitName() == 'npc_dota_neutral_dark_troll_warlord'
			or creep:GetUnitName() == 'npc_dota_neutral_centaur_khan'
			or creep:GetUnitName() == 'npc_dota_neutral_enraged_wildkin'
			or creep:GetUnitName() == 'npc_dota_neutral_warpine_raider'
			then
				return true
			end
		end
	end
end

function J.GetETAWithAcceleration(dist, speed, accel)
	return (math.sqrt(2 * accel * dist + speed * speed) - speed) / accel
end

function J.GetTechiesMines()
	local nMinesList = {}

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
		if unit ~= nil
        and unit:GetUnitName() == 'npc_dota_techies_land_mine'
        then
			table.insert(nMinesList, unit)
		end
	end

	return nMinesList
end

function J.GetTechiesMinesInLoc(loc, nRadius)
	local nMinesList = {}

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
		if unit ~= nil
        and unit:GetUnitName() == 'npc_dota_techies_land_mine'
		and GetUnitToLocationDistance(unit, loc) <= nRadius
        then
			table.insert(nMinesList, unit)
		end
	end

	return nMinesList
end

function J.CheckBitfieldFlag(bitfield, flag)
    return ((bitfield / flag) % 2) >= 1
end

function J.GetPowerCogsCountInLoc(loc, nRadius)
	local count = 0
	for _, unit in pairs(GetUnitList(UNIT_LIST_ALL))
	do
		if J.IsValid(unit)
		and string.find(unit:GetUnitName(), 'rattletrap_cog')
		and GetUnitToLocationDistance(unit, loc) <= nRadius
		then
			count = count + 1
		end
	end

	return count
end

function J.HasPowerTreads(bot)
	if J.HasItem(bot, 'item_power_treads')
	or J.HasItem(bot, 'item_power_treads_agi')
	or J.HasItem(bot, 'item_power_treads_int')
	or J.HasItem(bot, 'item_power_treads_str')
	then
		return true
	end

	return false
end

function J.GetLanePartner(bot)
	if bot:GetAssignedLane() == LANE_MID
	then
		return nil
	end

	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member:IsAlive()
		and member ~= bot
		and member:GetAssignedLane() == bot:GetAssignedLane()
		then
			return member
		end
	end

	return nil
end

function J.IsEnemyHero(hero)
	if hero ~= nil
	and hero:GetTeam() ~= GetBot():GetTeam()
	then
		return true
	else
		return false
	end
end

-- Adds an avoidance zone for use with GeneratePath(). Takes a Vector with x and y as a 2D location, and z as as radius. Returns a handle to the avoidance zone.
-- location as Vector(-7174.0, -6671.0, 10.0)
function J.AddAvoidanceZone(locationR, durationSec)
	local zone = AddAvoidanceZone(locationR, durationSec)
	-- J.Utils.StartCoroutine(function()
	-- 	local endTime = DotaTime() + durationSec
	-- 	while endTime >= DotaTime() do
	-- 		print('AddAvoidanceZone...'..' endtime='..endTime..', time='..DotaTime())
	-- 		coroutine.yield()
	-- 	end
	-- 	return RemoveAvoidanceZone(zone)
	-- end)
	return zone
end

function J.GetClosestAllyHero(bot)
	local closestHeroDistance = 999999
	local closestHero = nil
	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and J.IsNotSelf(bot, allyHero)
		then
			local diffDistance = J.GetLocationToLocationDistance(allyHero:GetLocation(), bot:GetLocation())
			if diffDistance < closestHeroDistance then
				closestHero = allyHero
				closestHeroDistance = diffDistance
			end
		end
	end
	return closestHero, closestHeroDistance
end

-- check if a table contains a value
function J.hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- Check if any bot is stuck/idle for some time.
local botIdelStateTimeThreshold = 3 -- relatively big number in case it's things like casting/being casted with long durating spells, in base healing, or other unexpected stuff.
local deltaIdleDistance = 5
local botIdleStateTracker = { }

function J.CheckBotIdleState()
	if DotaTime() <= 0 then return false end

	local bot = GetBot()
	if not bot:IsAlive() then return false end

	local botName = bot:GetUnitName();
	local botId = bot:GetPlayerID();

	-- print('Checking bot '..botName..' idle state.')
	local botState = botIdleStateTracker[botId]
	if botState then
		if DotaTime() - botState.lastCheckTime >= botIdelStateTimeThreshold then
			local diffDistance = J.GetLocationToLocationDistance( botState.botLocation, bot:GetLocation())
			if not bot:IsCastingAbility()
			and not bot:IsUsingAbility()
			and not bot:IsChanneling()
			and not bot:WasRecentlyDamagedByAnyHero(3)
			and diffDistance <= deltaIdleDistance -- normally a bot gets stuck if it stopped moving.
			then
				botState.idleCount = botState.idleCount + 1
				if bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE
				or bot:GetActiveMode() == BOT_MODE_ITEM then
					local nActions = bot:NumQueuedActions()
					if nActions > 0 then
						for i=1, nActions do
							local aType = bot:GetQueuedActionType(i)
							print('Bot '..botName.." has enqueued actions i="..i..", type="..tostring(aType))
						end
					end
					bot:Action_ClearActions(true);

					-- Should send it to most desire farming lane, if in laning or send it to desire push lane.
					local frontLoc = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0);
					bot:ActionQueue_AttackMove(frontLoc)
					print('[ERROR] Relocating the idle bot: '..botName..'. Sending it to the lane# it was originally assigned: '..tostring(bot:GetAssignedLane()))
				else
					print('Bot '..botName..' is in idle state for unknown reasons.')
				end
				return true
			else
				botState.idleCount = 0
				-- print('Bot '..botName..' is not in idle state.')
			end

			botState.botLocation = bot:GetLocation()
			botState.lastCheckTime = DotaTime()
		end
	else
		local botIdleState = {
			botLocation = bot:GetLocation(),
			lastCheckTime = DotaTime(),
			idleCount = 0
		}
		botIdleStateTracker[botId] = botIdleState
	end
	return false
end

function J.AreTreesBetween(bot, loc, r)
	local nTrees = bot:GetNearbyTrees(GetUnitToLocationDistance(bot, loc))

	for _, tree in pairs(nTrees)
	do
		local x = GetTreeLocation(tree)
		local y = bot:GetLocation()
		local z = loc

		if x ~= y
		then
			local a = 1
			local b = 1
			local c = 0

			if x.x - y.x == 0
			then
				b = 0
				c = -x.x
			else
				a = -(x.y - y.y) / (x.x - y.x)
				c = -(x.y + x.x * a)
			end

			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b))

			if d <= r
			and GetUnitToLocationDistance(bot,loc) > J.GetDistance(x, loc) + 50
			then
				return true
			end
		end
	end

	return false
end

function J.VectorTowards(s, t, d)
	local f = t - s

	f = f / J.GetDistance(f, Vector(0, 0))

	return s + (f * d)
end

function J.GetBestRetreatTree(bot, nCastRange)
	local nTrees = bot:GetNearbyTrees(nCastRange)
	local dest = J.VectorTowards(bot:GetLocation(), J.GetTeamFountain(), 1000)

	local bestRetreatTree = nil
	local maxDist = 0

	for _, tree in pairs(nTrees)
	do
		local nTreeLoc = GetTreeLocation(tree)

		if not J.AreTreesBetween(bot, nTreeLoc, 100)
		and GetUnitToLocationDistance(bot, nTreeLoc) > maxDist
		and GetUnitToLocationDistance(bot, nTreeLoc) < nCastRange
		and J.GetDistance(nTreeLoc, dest) < 880
		then
			maxDist = GetUnitToLocationDistance(bot, nTreeLoc)
			bestRetreatTree = loc
		end
	end

	if bestRetreatTree ~= nil
	and maxDist > bot:GetAttackRange()
	then
		return bestRetreatTree
	end

	return bestRetreatTree
end

function J.GetBestTree(bot, enemyLoc, enemy, nCastRange, hitRadios)
	local bestTree = nil
	local nTrees = bot:GetNearbyTrees(nCastRange)
	local dist = 10000

	for _, tree in pairs(nTrees)
	do
		local x = GetTreeLocation(tree)
		local y = bot:GetLocation()
		local z = enemyLoc

		if x ~= y
		then
			local a = 1
			local b = 1
			local c = 0

			if x.x - y.x == 0
			then
				b = 0
				c = -x.x
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end

			local d = math.abs((a * z.x + b * z.y + c) / math.sqrt(a * a + b * b))
			if d <= hitRadios
			and dist > GetUnitToLocationDistance(enemy, x)
			and (GetUnitToLocationDistance(enemy, x) <= GetUnitToLocationDistance(bot, x))
			then
				bestTree = tree
				dist = GetUnitToLocationDistance(enemy, x)
			end
		end
	end

	return bestTree
end

function J.GetUltLoc(bot, target, nManaCost, nCastRange, s)
	local v = target:GetVelocity()
	local sv = J.GetDistance(Vector(0,0), v)
	if sv > 800
	then
		v = (v / sv) * target:GetCurrentMovementSpeed()
	end

	local x= bot:GetLocation()
	local y= target:GetLocation()

	local a = v.x * v.x + v.y * v.y - s * s
	local b = -2 * (v.x * (x.x - y.x) + v.y * (x.y - y.y))
	local c = (x.x - y.x) * (x.x - y.x) + (x.y - y.y) * (x.y - y.y)

	local t = math.max((-b + math.sqrt(b * b - 4 * a * c)) / (2 * a), (-b - math.sqrt(b * b - 4 * a * c)) / (2 * a))
	local dest = (t + 0.35) * v + y

	if GetUnitToLocationDistance(bot, dest) > nCastRange
	or bot:GetMana() < 100 + nManaCost
	then
		return nil
	end

	if target:GetMovementDirectionStability() < 0.4
	or not bot:IsFacingLocation(target:GetLocation(), 60)
	then
		dest = J.VectorTowards(y, J.GetEnemyFountain(), 180)
	end

	if J.IsDisabled(target)
	then
		dest = target:GetLocation()
	end

	return dest
end


return J
