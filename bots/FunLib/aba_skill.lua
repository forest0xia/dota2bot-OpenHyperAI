local Utils = require( GetScriptDirectory()..'/FunLib/utils' )

local X = {}

local generic_hidden = 'generic_hidden'

if DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE == nil then DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE = 64 end
X['sAllyUnitAbilityIndex'] = {

		["bloodseeker_bloodrage"] = true,
		["omniknight_purification"] = true,
		["omniknight_repel"] = true,
		["medusa_mana_shield"] = true,
		["grimstroke_spirit_walk"] = true,
		["dazzle_shallow_grave"] = true,
		["dazzle_shadow_wave"] = true,
		["ogre_magi_bloodlust"] = true,
		["lich_frost_shield"] = true,

}


X['sProjectileAbilityIndex'] = {

		["chaos_knight_chaos_bolt"] = true,
		["grimstroke_ink_creature"] = true,
		["lich_chain_frost"] = true,
		["medusa_mystic_snake"] = true,
		["phantom_assassin_stifling_dagger"] = true,
		["phantom_lancer_spirit_lance"] = true,
		["skeleton_king_hellfire_blast"] = true,
		["skywrath_mage_arcane_bolt"] = true,
		["sven_storm_bolt"] = true,
		["vengefulspirit_magic_missile"] = true,
		["viper_viper_strike"] = true,
		["witch_doctor_paralyzing_cask"] = true,

}


X['sOnlyProjectileAbilityIndex'] = {

		["necrolyte_death_pulse"] = true,
		["arc_warden_spark_wraith"] = true,
		["tinker_heat_seeking_missile"] = true,
		["skywrath_mage_concussive_shot"] = true,
		["rattletrap_battery_assault"] = true,
		["queenofpain_scream_of_pain"] = true,

}


X['sStunProjectileAbilityIndex'] = {

		["chaos_knight_chaos_bolt"] = true,
		["skeleton_king_hellfire_blast"] = true,
		["sven_storm_bolt"] = true,
		["vengefulspirit_magic_missile"] = true,
		["witch_doctor_paralyzing_cask"] = true,
		["dragon_knight_dragon_tail"] = true,

}



function X.GetTalentList( bot )

	local sTalentList = {}
	for i = 0, 23
	do
		local hAbility = bot:GetAbilityInSlot( i )
		if hAbility ~= nil and hAbility:IsTalent()
		then
			table.insert( sTalentList, hAbility:GetName() )
		end
	end

	return sTalentList

end

function X.GetAbilityList( bot )
	local sAbilityList = { }
	local totalUpgradeableAbilities = 7
	local unitName = bot:GetUnitName()
	for slot = 0, totalUpgradeableAbilities
	do
		local ability = bot:GetAbilityInSlot(slot)
		if ability then
			local name = ability:GetName()
			--print(unitName..' has ability name= '..name..', at slot idx= '..slot)
			if name == generic_hidden then
				-- if we dont check slots but just dropping generic_hidden, it can cause some others fail to learn abilities correctly, e.g. chen.
				if slot ~= 0 then
					--print('[WARN] The ability '..name..' on slot '..slot..' cannot be accessed for hero: '..unitName)
					table.insert(sAbilityList, generic_hidden)
				else
					print('[WARN] The ability '..name..' on slot '..slot..' does not make sense. Check if there is anything wrong with this hero: '..unitName)
				end
			elseif Utils.AbilityBehaviorHasFlag(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) and ability:IsHidden() then
				--print('[WARN] The ability '..name..' on slot '..slot..' is not learnable (e.g. innate like) for hero: '..unitName)
			elseif ability:IsUltimate() and slot >= 4 then
				-- print('[INFO] The ability '..name..' on slot '..slot..' is the ultimate for hero: '..unitName)
				if Utils.AbilityBehaviorHasFlag(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) or ability:IsHidden() then
					print('[WARN] The ability '..name..' on slot '..slot..' seems to be an ultimate for hero: '..unitName..'. But it is not learnable OR hidden. Check if there is anything wrong with this hero.')
				else
					sAbilityList[6] = name
					--print(unitName..' loaded ultimate ability with name= '..name..', at idx= '..slot)
				end
				-- if slot > 5 then
				-- 	print('[WARN] The ability '..name..' on slot '..slot..' is another ultimate for hero: '..unitName..'. Wrong slot detected. Check if there is anything wrong with this hero.')
				-- end
			elseif not ability:IsTalent() then
				table.insert(sAbilityList, name)
				--print(unitName..' loaded ability with name= '..name..', at idx= '..slot)
			else
				print(unitName..' failed to load ability with name= '..name..', at idx= '..slot)
			end
		else
			print('[WARN] It seems there is no ability on slot '..slot..' for '..unitName)
		end
	end

	return sAbilityList
end


function X.GetRandomBuild( tBuildList )

	return tBuildList[RandomInt( 1, #tBuildList )]

end


function X.GetTalentBuild( tTalentTreeList )

	local nTalentBuildList = {
							[1] = ( tTalentTreeList['t10'][1] == 0 and 1 or 2 ),
							[2] = ( tTalentTreeList['t15'][1] == 0 and 3 or 4 ),
							[3] = ( tTalentTreeList['t20'][1] == 0 and 5 or 6 ),
							[4] = ( tTalentTreeList['t25'][1] == 0 and 7 or 8 ),
							[5] = ( tTalentTreeList['t10'][1] == 0 and 2 or 1 ),
							[6] = ( tTalentTreeList['t15'][1] == 0 and 4 or 3 ),
							[7] = ( tTalentTreeList['t20'][1] == 0 and 6 or 5 ),
							[8] = ( tTalentTreeList['t25'][1] == 0 and 8 or 7 ),
						  }

	return nTalentBuildList

end


function X.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
	local botName = GetBot():GetUnitName()
	-- build it to not hard code here anymore as it's annoying patch changes
	local sSkillList = {}
	-- Default dynamic mapping for heroes with standard progressions
	local talent_idx = 1
	local ability_idx = 1
	-- Calculate total slots based on available abilities and talents.
	local totalSlots = #nAbilityBuildList + #nTalentBuildList
	for i = 1, totalSlots do
		-- Insert a talent when it's a talent slot or when all abilities have been used.
		if (i >= 10 and (i % 5 == 0 or ability_idx > #nAbilityBuildList)) then
			sSkillList[i] = sTalentList[nTalentBuildList[talent_idx]]
			talent_idx = talent_idx + 1
		else
			if ability_idx <= #nAbilityBuildList then
				sSkillList[i] = sAbilityList[nAbilityBuildList[ability_idx]]
				ability_idx = ability_idx + 1
			end
		end
	end

	if botName == 'npc_dota_hero_meepo'
	then
		sSkillList = {
						[1] = sAbilityList[nAbilityBuildList[1]],
						[2] = sAbilityList[nAbilityBuildList[2]],
						[3] = sAbilityList[nAbilityBuildList[3]],
						[4] = sAbilityList[nAbilityBuildList[4]],
						[5] = sAbilityList[nAbilityBuildList[5]],
						[6] = sAbilityList[nAbilityBuildList[6]],
						[7] = sAbilityList[nAbilityBuildList[7]],
						[8] = sAbilityList[nAbilityBuildList[8]],
						[9] = sAbilityList[nAbilityBuildList[9]],
						[10] = sAbilityList[nAbilityBuildList[10]],
						[11] = sTalentList[nTalentBuildList[1]],
						[12] = sAbilityList[nAbilityBuildList[11]],
						[13] = sAbilityList[nAbilityBuildList[12]],
						[14] = sAbilityList[nAbilityBuildList[13]],
						[15] = sTalentList[nTalentBuildList[2]],
						[16] = sAbilityList[nAbilityBuildList[14]],
						[17] = sAbilityList[nAbilityBuildList[15]],
						[18] = sTalentList[nTalentBuildList[3]],
						[19] = sTalentList[nTalentBuildList[4]],
						[20] = sTalentList[nTalentBuildList[5]],
						[21] = sTalentList[nTalentBuildList[6]],
						[22] = sTalentList[nTalentBuildList[7]],
						[23] = sTalentList[nTalentBuildList[8]],
						[24] = sAbilityList[nAbilityBuildList[16]],
						[25] = sTalentList[nTalentBuildList[3]],
						[26] = sTalentList[nTalentBuildList[4]],
						[27] = sTalentList[nTalentBuildList[5]],
						[28] = sTalentList[nTalentBuildList[6]],
						[29] = sTalentList[nTalentBuildList[7]],
						[30] = sTalentList[nTalentBuildList[8]],
		}
	end
	if botName == 'npc_dota_hero_invoker'
	then
		sSkillList = {
						[1] = sAbilityList[nAbilityBuildList[1]],
						[2] = sAbilityList[nAbilityBuildList[2]],
						[3] = sAbilityList[nAbilityBuildList[3]],
						[4] = sAbilityList[nAbilityBuildList[4]],
						[5] = sAbilityList[nAbilityBuildList[5]],
						[6] = sAbilityList[nAbilityBuildList[6]],
						[7] = sAbilityList[nAbilityBuildList[7]],
						[8] = sAbilityList[nAbilityBuildList[8]],
						[9] = sAbilityList[nAbilityBuildList[9]],
						[10] = sTalentList[nTalentBuildList[1]],
						[11] = sAbilityList[nAbilityBuildList[10]],
						[12] = sAbilityList[nAbilityBuildList[11]],
						[13] = sAbilityList[nAbilityBuildList[12]],
						[14] = sAbilityList[nAbilityBuildList[13]],
						[15] = sTalentList[nTalentBuildList[2]],
						[16] = sAbilityList[nAbilityBuildList[14]],
						[17] = sAbilityList[nAbilityBuildList[15]],
						[18] = sAbilityList[nAbilityBuildList[16]],
						[19] = sAbilityList[nAbilityBuildList[17]],
						[20] = sTalentList[nTalentBuildList[3]],
						[21] = sAbilityList[nAbilityBuildList[18]],
						[22] = sAbilityList[nAbilityBuildList[19]],
						[23] = sAbilityList[nAbilityBuildList[20]],
						[24] = sAbilityList[nAbilityBuildList[21]],
						[25] = sTalentList[nTalentBuildList[4]],
						[26] = sTalentList[nTalentBuildList[5]],
						[27] = sTalentList[nTalentBuildList[6]],
						[28] = sTalentList[nTalentBuildList[7]],
						[29] = sTalentList[nTalentBuildList[8]],
					}
	end

	print("Aba list for: "..botName)
    Utils.PrintTable(sSkillList)
	return sSkillList
end


function X.IsHeroInEnemyTeam( sHero )

	for _, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if GetSelectedHeroName( id ) == sHero
		then
			return true
		end
	end

	return false

end


function X.GetOutfitName( bot )

	return 'item_'..string.gsub( bot:GetUnitName(), 'npc_dota_hero_', '' )..'_outfit'

end


return X
-- dota2jmz@163.com QQ:2462331592..
