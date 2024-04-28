-- Enumerated types for attributing voiceover lines. Each line can have a single type or a table of types,
-- in addition to a single attitude or table of attitudes. These are mainly used for selecting a random sound from
-- a wider list.

local voAttitudes =
{
	ANGRY 					=	'ANGRY',
	COMPLIMENT				=	'COMPLIMENT',
	HAPPY					=	'HAPPY',
	NEUTRAL					=	'NEUTRAL',
	SAD 					= 	'SAD',
	TAUNT 					=	'TAUNT',
}
return voAttitudes