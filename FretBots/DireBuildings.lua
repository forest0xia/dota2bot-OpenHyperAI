-- Dire Building names and their point scores
-- Buildings and their values for determining game state
-- (i.e. which team is winning)
-- I'm leaving these here for now because I don't anticipate
-- the determination of the game state to depend on the difficulty,
-- just what we do as a result of it
local direBuildings =
{
	{
		name 	= 'dota_badguys_tower1_top',
		value	= 1,
	},
	{
		name 	= 'dota_badguys_tower1_mid',
		value	= 1,
	},
	{
		name 	= 'dota_badguys_tower1_bot',
		value	= 1,
	},
	{
		name 	= 'dota_badguys_tower2_top',
		value	= 2,
	},
	{
		name 	= 'dota_badguys_tower2_mid',
		value	= 2,
	},
	{
		name 	= 'dota_badguys_tower2_bot',
		value	= 2,
	},
	{
		name 	= 'dota_badguys_tower3_top',
		value	= 3,
	},
	{
		name 	= 'dota_badguys_tower3_mid',
		value	= 3,
	},
	{
		name 	= 'dota_badguys_tower3_bot',
		value	= 3,
	},
	{
		name 	= 'bad_rax_melee_top',
		value	= 4,
	},
	{
		name 	= 'bad_rax_range_top',
		value	= 2,
	},
	{
		name 	= 'bad_rax_melee_mid',
		value	= 4,
	},
	{
		name 	= 'bad_rax_range_mid',
		value	= 2,
	},
	{
		name 	= 'bad_rax_melee_bot',
		value	= 4,
	},
	{
		name 	= 'bad_rax_range_bot',
		value	= 2,
	},
	{
		name 	= 'dota_badguys_tower4_top',
		value	= 5,
	},
	{
		name 	= 'dota_badguys_tower4_bot',
		value	= 5,
	},
}

return direBuildings