local X = {}

local bot = GetBot()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not string.find(bot:GetUnitName(), "hero") then return end

local U = require(GetScriptDirectory()..'/FunLib/minion_lib/utils')

local AttackingWards = dofile(GetScriptDirectory()..'/FunLib/minion_lib/attacking_wards')
local PrimalSplit = dofile(GetScriptDirectory()..'/FunLib/minion_lib/primal_split')
local Familiars = dofile(GetScriptDirectory()..'/FunLib/minion_lib/familiars')
local Illusion = dofile(GetScriptDirectory()..'/FunLib/minion_lib/illusions')
local MinionWithSkill = dofile(GetScriptDirectory()..'/FunLib/minion_lib/minion_with_skill')
local VengefulSprit = dofile(GetScriptDirectory()..'/FunLib/minion_lib/vengeful_spirit')
local Jugg = dofile(GetScriptDirectory()..'/FunLib/minion_lib/jugg')
local Customize = require(GetScriptDirectory()..'/Customize/general')

-- For now
function X.IllusionThink(hMinionUnit)
	return X.MinionThink(hMinionUnit)
end

function X.IsValidUnit(hMinionUnit)
	return U.IsValidUnit(hMinionUnit)
end

function X.HealingWardThink(minion)
	Jugg.HealingWardThink(minion)
end

-- MINION THINK
function X.MinionThink(hMinionUnit)
	if not hMinionUnit or hMinionUnit:IsNull() or not hMinionUnit:IsAlive() then return end
	if hMinionUnit.lastItemFrameProcessTime == nil then hMinionUnit.lastItemFrameProcessTime = 0 end
	if DotaTime() - hMinionUnit.lastItemFrameProcessTime < 0.5 * (1 + Customize.ThinkLess) then return end
	hMinionUnit.lastItemFrameProcessTime = DotaTime()

	if bot == nil then bot = GetBot() end

	if U.IsValidUnit(hMinionUnit)
	then
		if U.CantBeControlled(hMinionUnit)
		or U.IsShamanFowlPlayChicken(hMinionUnit)
		then
			return
		end

		-- Illusions; No Spells
		if (hMinionUnit:IsHero() and hMinionUnit:IsIllusion() and hMinionUnit:GetUnitName() ~= 'npc_dota_hero_vengefulspirit')
		or U.IsMinionWithNoSkill(hMinionUnit)
		then
			Illusion.Think(bot, hMinionUnit)
			return
		end

		-- Vengeful Spirit Aghanim's Scepter Illusion
		if hMinionUnit:IsHero() and hMinionUnit:IsIllusion()
		and hMinionUnit:GetUnitName() == 'npc_dota_hero_vengefulspirit'
		then
			VengefulSprit.Think(bot, hMinionUnit)
			return
		end

		-- Attacking Wards
		if U.IsAttackingWard(hMinionUnit) then
			AttackingWards.Think(bot, hMinionUnit)
			return
		end

		-- Brewmaster's PrimalSplit
		if U.IsPrimalSplit(hMinionUnit) then
			PrimalSplit.MinionThink(bot, hMinionUnit)
			return
		end

		-- [BROKEN (7.37+)] Visage's Familiars
		if U.IsFamiliar(hMinionUnit) then
			Familiars.Think(bot, hMinionUnit)
			return
		end

		-- Spell Casting Minions
		MinionWithSkill.Think(bot, hMinionUnit)
		return
	end
end

return X
