-- Instantiate the class
if Flags == nil then
	Flags = {}
end

-- Set up global flags
function Flags:Initialize()
	-- Global flags
	Flags.isEntityKilledRegistered 				= false
	Flags.isStatsInitialized 					= false
	Flags.isEntityHurtRegistered 				= false
	Flags.isSettingsInitialized					= false
	Flags.isSettingsFinalized  					= false
	Flags.isDebugBuffed 						= false
	Flags.isPlayerChatRegistered 				= false
	Flags.isFretBotsInitialized 				= false
	Flags.isBonusTimersInitialized 				= false
	Flags.isRoleDeterminationTimerInitialized	= false
	Flags.isDynamicDifficultyInitialized		= false
	Flags.isDynamicDifficultyFinalized  		= false
	Flags.isInventoryItemAddedRegistered		= false
end

-- Create flags
Flags:Initialize()