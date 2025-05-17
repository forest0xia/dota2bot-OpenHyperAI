local X = {}

local nTeamAncient = GetAncient(GetTeam());
local vTeamAncientLoc = nil;
if nTeamAncient ~= nil then vTeamAncientLoc = nTeamAncient:GetLocation() end;

function X.HealingWardThink(minion)
	local nEnemyHeroes = minion:GetNearbyHeroes( 1200, true, BOT_MODE_DESIRE_NONE )

	local targetLocation = nil
	local weakestHero = nil
	local weakestHP = 0.99
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local allyHero = GetTeamMember( i )
		if allyHero ~= nil
			and allyHero:IsAlive()
			and GetUnitToUnitDistance( allyHero, minion ) <= 1200
		then
			local allyHP = allyHero:GetHealth()/allyHero:GetMaxHealth()
			if allyHP < weakestHP
			then
				weakestHP = allyHP
				weakestHero = allyHero
			end
		end
	end

	if #nEnemyHeroes == 0
	then
		local nAoeHeroTable = minion:FindAoELocation( false, true, minion:GetLocation(), 1000, 400 , 0, 0);
		if nAoeHeroTable.count >= 2
		then
			targetLocation = nAoeHeroTable.targetloc
		end

		if targetLocation == nil
		then
			if weakestHero ~= nil
			then
				targetLocation = weakestHero:GetLocation()
			end
		end

		if targetLocation == nil
		then
			local nAoeCreepTable = minion:FindAoELocation( false, false, minion:GetLocation(), 800, 400 , 0, 0);
			if nAoeCreepTable.count >= 1
			then
				targetLocation = nAoeCreepTable.targetloc
			end
		end
	else
		if weakestHero ~= nil
		then
			targetLocation = weakestHero:GetLocation()
		end
	end

	if targetLocation ~= nil
	then
		if targetLocation == GetBot():GetLocation()
		then
            --自动人棒合一
            return
		else
			minion:Action_MoveToLocation( targetLocation )
		end
	else
		minion:Action_MoveToLocation( vTeamAncientLoc )
	end

end

return X