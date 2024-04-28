----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------


local X = {}


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

	local sAbilityList = {}
	for slot = 0, 6
	do
		table.insert( sAbilityList, bot:GetAbilityInSlot( slot ):GetName() )
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

	local sSkillList = {
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
						[18] = sTalentList[nTalentBuildList[3]],
						[19] = sTalentList[nTalentBuildList[4]],
						[20] = sTalentList[nTalentBuildList[5]],
						[21] = sTalentList[nTalentBuildList[6]],
						[22] = sTalentList[nTalentBuildList[7]],
						[23] = sTalentList[nTalentBuildList[8]],
					}

	if GetBot():GetUnitName() == 'npc_dota_hero_invoker'
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
