TargetingHelper = {}

function TargetingHelper.FindNearbyFriendlies(unit, radius)
	return FindUnitsInRadius(		
		unit:GetTeamNumber(),
		unit:GetAbsOrigin(),
		nil,
		radius,
	    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	    DOTA_UNIT_TARGET_ALL,
	    --this flag lets us ignore buildings
	    DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
	    FIND_CLOSEST,
		false)
end