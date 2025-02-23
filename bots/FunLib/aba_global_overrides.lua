
local Utils = require( GetScriptDirectory()..'/FunLib/utils')

-- Override this func for the script to use
local orig_GetTeamPlayers = GetTeamPlayers
local direTeamPlaters = nil
function GetTeamPlayers(nTeam, bypass)
	if bypass then return orig_GetTeamPlayers(nTeam) end
	local cacheKey = 'GetTeamPlayers'..tostring(nTeam)
	local cache = Utils.GetCachedVars(cacheKey, 5)
	if cache ~= nil then return cache end

	local nIDs = orig_GetTeamPlayers(nTeam)
	if nTeam == TEAM_DIRE then
		if direTeamPlaters ~= nil then
			return direTeamPlaters
		end
		
		local sHuman = {}
		for idx, id in pairs(nIDs) do
			if not IsPlayerBot(id)
			then
				table.insert(sHuman, id)
			end
		end

		if #sHuman > 0 then
			local nBotIDs = {5, 6, 7, 8, 9}
			nIDs = {}

			for i = 1, #nBotIDs do table.insert(nIDs, nBotIDs[i]) end

			-- Map it directly
			for i = 1, #sHuman do
				for j = 1, 5 do
					if sHuman[i] + 5 == nBotIDs[j]
					then
						nIDs[j] = sHuman[i]
					end
				end
			end

			-- "Shift" > 4
			for i = #nIDs, 1, -1 do
				local hCount = 0
				if nIDs[i] > 4 then
					for j = 1, #nIDs do
						if nIDs[j + i] ~= nil and nIDs[j + i] < 5 then
							hCount = hCount + 1
						end
					end
					nIDs[i] = nIDs[i] + hCount
				end
			end
		end
		direTeamPlaters = nIDs
	end
	Utils.SetCachedVars(cacheKey, nIDs)
	return nIDs
end

-- Override the print function
local orig_print = print
function print(...)
    if not Utils.DebugMode then return end

    local args = {...}
    for i, v in ipairs(args) do
        args[i] = tostring(v) -- Convert all arguments to strings
    end
    local output = table.concat(args, "\t") -- Concatenate with tab as separator

    orig_print(output)
end

local original_GetUnitToUnitDistance = GetUnitToUnitDistance
function GetUnitToUnitDistance(unit1, unit2)
	if not unit1 then
		print("[Error] GetUnitToUnitDistance called with invalid unit 1")
		print("Stack Trace:", debug.traceback())
	end
	if unit2 == nil or unit2:GetLocation() == nil then
		if unit1 then
			print("[Error] GetUnitToUnitDistance called with invalid unit 2, the unit 1 is: " .. unit1:GetUnitName())
			print("Stack Trace:", debug.traceback())
		end
	end
	return original_GetUnitToUnitDistance(unit1, unit2)
end

local originalWasRecentlyDamagedByAnyHero = CDOTA_Bot_Script.WasRecentlyDamagedByAnyHero
function CDOTA_Bot_Script:WasRecentlyDamagedByAnyHero(fInterval)
    if not self:IsHero() then
		-- print("WasRecentlyDamagedByAnyHero has been called on non hero")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalWasRecentlyDamagedByAnyHero(self, fInterval)
end

local originalGetNearbyTowers = CDOTA_Bot_Script.GetNearbyTowers
function CDOTA_Bot_Script:GetNearbyTowers(nRadius, bEnemies)
    if not self:IsHero() then
		-- print("GetNearbyTowers has been called on non hero")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalGetNearbyTowers(self, math.min(nRadius, 1600), bEnemies)
end

local originalIsIllusion = CDOTA_Bot_Script.IsIllusion
function CDOTA_Bot_Script:IsIllusion()
    if not self:IsHero() then
		-- print("IsIllusion has been called on non hero")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    if not self:CanBeSeen() then
		-- print("IsIllusion has been called on non hero")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end

	-- TODO: add is-teammate check.
    return originalIsIllusion(self)
end

local originalHasModifier = CDOTA_Bot_Script.HasModifier
function CDOTA_Bot_Script:HasModifier(sModifierName)
    if not self:CanBeSeen() then
		return false
		-- print("HasModifier has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
	end
    -- if not self:IsHero() then
	-- 	print("HasModifier has been called on non hero")
	-- 	print("Stack Trace:", debug.traceback())
	-- end
    return originalHasModifier(self, sModifierName)
end

local originalGetLocation = CDOTA_Bot_Script.GetLocation
function CDOTA_Bot_Script:GetLocation()
    if self == nil or (not self:IsBuilding() and not self:CanBeSeen()) then
		return nil
		-- print("GetLocation has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
	end
    return originalGetLocation(self)
end
local originalGetMagicResist = CDOTA_Bot_Script.GetMagicResist
function CDOTA_Bot_Script:GetMagicResist()
    if self == nil or not self:CanBeSeen() then
		return 1
		-- print("GetMagicResist has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
	end
    return originalGetMagicResist(self)
end

local originalIsInvulnerable = CDOTA_Bot_Script.IsInvulnerable
function CDOTA_Bot_Script:IsInvulnerable()
    if not self:CanBeSeen() then
		-- print("IsInvulnerable has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return false
	end
    return originalIsInvulnerable(self)
end

local originalIsAttackImmune = CDOTA_Bot_Script.IsAttackImmune
function CDOTA_Bot_Script:IsAttackImmune()
    if not self:CanBeSeen() then
		-- print("IsAttackImmune has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return false
	end
    return originalIsAttackImmune(self)
end

local originalIsUsingAbility = CDOTA_Bot_Script.IsUsingAbility
function CDOTA_Bot_Script:IsUsingAbility()
    if not self:CanBeSeen() or not self:IsHero() then
		-- print("IsUsingAbility has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return false
	end
    return originalIsUsingAbility(self)
end

local originalIsChanneling = CDOTA_Bot_Script.IsChanneling
function CDOTA_Bot_Script:IsChanneling()
    if not self:CanBeSeen() then
		-- print("IsChanneling has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return false
	end
    return originalIsChanneling(self)
end

local originalGetAttackTarget = CDOTA_Bot_Script.GetAttackTarget
function CDOTA_Bot_Script:GetAttackTarget()
    if not self:CanBeSeen() then
		-- print("GetAttackTarget has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalGetAttackTarget(self)
end

local originalGetNearbyHeroes = CDOTA_Bot_Script.GetNearbyHeroes
function CDOTA_Bot_Script:GetNearbyHeroes(nRadius, bEnemies, nMode)
    if not self:CanBeSeen() then
		-- print("GetNearbyHeroes has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalGetNearbyHeroes(self, math.min(nRadius, 1600), bEnemies, nMode)
end

local originalIsMagicImmune = CDOTA_Bot_Script.IsMagicImmune
function CDOTA_Bot_Script:IsMagicImmune()
	if not self then return false end
	local cacheKey = 'IsMagicImmune'..self:GetUnitName()
	local cache = Utils.GetCachedVars(cacheKey, 0.15)
	if cache ~= nil then return cache end

	if self:CanBeSeen() then
        if originalIsMagicImmune(self)
        or self:HasModifier('modifier_magic_immune')
        or self:HasModifier('modifier_juggernaut_blade_fury')
        or self:HasModifier('modifier_life_stealer_rage')
        or self:HasModifier('modifier_black_king_bar_immune')
        or self:HasModifier('modifier_huskar_life_break_charge')
        or self:HasModifier('modifier_grimstroke_scepter_buff')
        or self:HasModifier('modifier_pangolier_rollup')
        or self:HasModifier('modifier_lion_mana_drain_immunity')
        or self:HasModifier('modifier_dawnbreaker_fire_wreath_magic_immunity_tooltip')
        or self:HasModifier('modifier_rattletrap_cog_immune')
        or self:HasModifier('modifier_legion_commander_press_the_attack_immunity')
        then
			Utils.SetCachedVars(cacheKey, true)
            return true
        end
    end
	Utils.SetCachedVars(cacheKey, false)
    return false
end

local originalGetNearbyNeutralCreeps = CDOTA_Bot_Script.GetNearbyNeutralCreeps
function CDOTA_Bot_Script:GetNearbyNeutralCreeps( nRadius)
    return originalGetNearbyNeutralCreeps(self, math.min(nRadius, 1600))
end

local originalGetNearbyLaneCreeps = CDOTA_Bot_Script.GetNearbyLaneCreeps
function CDOTA_Bot_Script:GetNearbyLaneCreeps( nRadius, bEnemies)
    -- if not self or not self:IsBot() then
	-- 	print("GetNearbyLaneCreeps has been called on unit is not a bot")
	-- 	print("Stack Trace:", debug.traceback())
	-- 	return nil
	-- end
    return originalGetNearbyLaneCreeps(self, math.min(nRadius, 1600), bEnemies)
end

local originalGetNearbyCreeps = CDOTA_Bot_Script.GetNearbyCreeps
function CDOTA_Bot_Script:GetNearbyCreeps( nRadius, bEnemies)
    return originalGetNearbyCreeps(self, math.min(nRadius, 1600), bEnemies)
end

local originalGetUnitName = CDOTA_Bot_Script.GetUnitName
function CDOTA_Bot_Script:GetUnitName()
	local uName = originalGetUnitName(self)
	if string.find( uName, "lone_druid_bear" ) then
		uName = 'npc_dota_hero_lone_druid_bear'
	end
	return uName
end

local originalAction_UseAbility = CDOTA_Bot_Script.Action_UseAbility
function CDOTA_Bot_Script:Action_UseAbility(hAbility)
    if hAbility == nil or hAbility:IsHidden() then
		print("Action_UseAbility has been called on ability that's hidden")
		print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalAction_UseAbility(self, hAbility)
end

local originalActionPush_UseAbility = CDOTA_Bot_Script.ActionPush_UseAbility
function CDOTA_Bot_Script:ActionPush_UseAbility(hAbility)
    if hAbility == nil or hAbility:IsHidden() then
		print("ActionPush_UseAbility has been called on ability that's hidden")
		print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalActionPush_UseAbility(self, hAbility)
end

-- local originalAction_AttackUnit = CDOTA_Bot_Script.Action_AttackUnit
-- function CDOTA_Bot_Script:Action_AttackUnit(hUnit, bOnce)
--     if hUnit:GetUnitName() == 'npc_dota_warlock_minor_imp' then
-- 		print("Action_AttackUnit has been called on entity npc_dota_warlock_minor_imp")
-- 		print("Stack Trace:", debug.traceback())
-- 		return nil
-- 	end
--     return originalAction_AttackUnit(self, hUnit, bOnce)
-- end

local originalGetTarget = CDOTA_Bot_Script.GetTarget
function CDOTA_Bot_Script:GetTarget()
    if not self or not self:IsBot() then
		-- print("GetTarget has been called on unit is not a bot")
		-- print("Stack Trace:", debug.traceback())
		return nil
	end
    return originalGetTarget(self)
end

local originalGetAttackRange = CDOTA_Bot_Script.GetAttackRange
function CDOTA_Bot_Script:GetAttackRange()
    if not self:CanBeSeen() then
		-- print("GetAttackRange has been called on unit can't be seen")
		-- print("Stack Trace:", debug.traceback())
		return 200
	end
    return originalGetAttackRange(self)
end

-- local original_Action_AttackMove = CDOTA_Bot_Script.Action_AttackMove
-- function CDOTA_Bot_Script:Action_AttackMove(vLocation)
-- 	if self.isBuggyHero == nil then
-- 		self.isBuggyHero = Utils.BuggyHeroesDueToValveTooLazy[self:GetUnitName()] ~= nil
-- 	end
-- 	if self.isBuggyHero
-- 	then
-- 		self:Action_ClearActions(true);
-- 		print('Override buggy hero movement, make it go assigned lane front with Action_AttackMove.'..self:GetUnitName())
-- 		local assignedLaneLoc = GetLaneFrontLocation(GetTeam(), self:GetAssignedLane(), 0)
-- 		if Utils.GetLocationToLocationDistance(assignedLaneLoc, vLocation) > 1000 and DotaTime() < 2*60 then
-- 			return original_Action_AttackMove(self, assignedLaneLoc )
-- 		end
-- 	end
--     return original_Action_AttackMove(self, vLocation )
-- end


-- CDOTA_AttackRecordManager::GetRecordByIndex - Could not find attack record (-1)!
-- local originalGetRecordByIndex = CDOTA_AttackRecordManager.GetRecordByIndex
-- function CDOTA_AttackRecordManager:GetRecordByIndex(idx)
--     if idx < 0 then
-- 		print("GetRecordByIndex has been called on unit can't be seen")
-- 		print("Stack Trace:", debug.traceback())
-- 	end
--     return originalGetRecordByIndex(self)
-- end

local originalActionImmediate_SwapItems = CDOTA_Bot_Script.ActionImmediate_SwapItems
local itemSwapGapTime = 6 + 5 -- 6s item cd after swap, 5s delta time for item usage reaction.
function CDOTA_Bot_Script:ActionImmediate_SwapItems(intnSlot1, intnSlot2)
	local unitName = self:GetUnitName()
	-- print(unitName.." swaps items: "..tostring(intnSlot1)..', '..tostring(intnSlot2))
	if self.itemSwapTime == nil then
		self.itemSwapTime = 0
	end
	-- print("ActionImmediate_SwapItems has been called on unit: "..unitName)
	-- print("Stack Trace:", debug.traceback())
	if #self:GetNearbyHeroes(1000, true, BOT_MODE_NONE) == 0 and DotaTime() - self.itemSwapTime > itemSwapGapTime then
		self.itemSwapTime = DotaTime()
		return originalActionImmediate_SwapItems(self, intnSlot1, intnSlot2)
	else
		-- print('[WARN] '..unitName..' failed to swap items due to trying too frequently.')
	end
    return nil
end

local originalGetUnitToLocationDistance = CDOTA_Bot_Script.GetUnitToLocationDistance
-- Override the GetUnitToLocationDistance function with caching
function CDOTA_Bot_Script:GetUnitToLocationDistance(unit, location)
    if location == nil then
		print("GetUnitToLocationDistance error arg.")
		print("Stack Trace:", debug.traceback())
		return 200
	end
    return originalGetUnitToLocationDistance(self, unit, location)
end

local original_GetHealth = CDOTA_Bot_Script.GetHealth
function CDOTA_Bot_Script:GetHealth()
    if self == nil or not self:CanBeSeen() then
		return 666
	end

	local nCurHealth = original_GetHealth(self)
    if self ~= nil and self:GetUnitName() == 'npc_dota_hero_medusa' and nCurHealth > 0
    then
		local mana = self:GetMana()
		-- Assuming max level Mana Shield (95% absorption and 2.5 damage absorbed per point of mana)
		local manaAbsorptionRate = 0.95
		if self:GetLevel() < 12 then manaAbsorptionRate = 0.5 end -- workaround e.g. to not retreat too often due to low mana.
		local damagePerMana = 2.6
		-- Calculate how much damage her current mana can absorb
		local manaEffectiveHP = mana * damagePerMana * manaAbsorptionRate
		-- Effective HP is her base HP plus the effective HP from her mana shield
		return nCurHealth + manaEffectiveHP
    end
    return nCurHealth
end

local originalGetMaxHealth = CDOTA_Bot_Script.GetMaxHealth
function CDOTA_Bot_Script:GetMaxHealth()
    if self ~= nil and self:GetUnitName() == 'npc_dota_hero_medusa'
    then
		-- Assuming max level Mana Shield (95% absorption and 2.5 damage absorbed per point of mana)
		local manaAbsorptionRate = 0.95
		if self:GetLevel() < 12 then manaAbsorptionRate = 0.5 end -- workaround e.g. to not retreat too often due to low mana.
		local damagePerMana = 2.6
		local maxManaEffectiveHP = self:GetMaxMana() * damagePerMana * manaAbsorptionRate
		-- Total max effective HP
        return originalGetMaxHealth(self) + maxManaEffectiveHP
    end
    return originalGetMaxHealth(self)
end
function CDOTA_Bot_Script:OriginalGetHealth()
    return original_GetHealth(self)
end
function CDOTA_Bot_Script:OriginalGetMaxHealth()
    return originalGetMaxHealth(self)
end

local originalGetMana = CDOTA_Bot_Script.GetMana
function CDOTA_Bot_Script:GetMana()
    if self ~= nil and (self:GetUnitName() == 'npc_dota_hero_huskar')
    then
        return 0
    end
    return originalGetMana(self)
end
local originalGetMaxMana = CDOTA_Bot_Script.GetMaxMana
function CDOTA_Bot_Script:GetMaxMana()
    if self ~= nil and (self:GetUnitName() == 'npc_dota_hero_huskar')
    then
        return 0
    end
    return originalGetMaxMana(self)
end

local X = {
	orig_GetTeamPlayers = orig_GetTeamPlayers,
	GetTeamPlayers = GetTeamPlayers
}

return X