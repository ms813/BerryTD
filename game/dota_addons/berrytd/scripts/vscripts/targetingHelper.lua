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

function TargetingHelper.FindDireInRadius(unit, radius)		
	return FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		unit:GetAbsOrigin(),
		nil,
		radius,
	    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	    DOTA_UNIT_TARGET_ALL,
	    DOTA_UNIT_TARGET_FLAG_NONE,
	    FIND_CLOSEST,
		false)
end

function TargetingHelper.HighestLevelAllies(unit, radius)
	local allies = FindUnitsInRadius(		
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

	--find the highest level
	local highest_level = -1
	for i, ally in pairs(allies) do		
		local level = ally.upgrade_level
		if level > highest_level then
			highest_level = level
		end
	end

	--find nearby allies at this high level
	local high_level_allies = {}	
	for i, ally in pairs(allies) do
		if ally.upgrade_level == highest_level then
			table.insert(high_level_allies, ally)
		end
	end

	return high_level_allies
end

function TargetingHelper.LowestHpAlly(unit, radius)
	local allies = FindUnitsInRadius(		
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

	local unhealthiest
	local lowest_hp = math.huge
	for i, ally in pairs(allies) do
		local hp = ally:GetHealth()
		if hp < lowest_hp then
			unhealthiest = ally
			lowest_hp = hp
		end
	end

	return unhealthiest
end

function TargetingHelper.LowestHPPercentAlly(unit, radius)
	local allies = FindUnitsInRadius(		
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

	

	local unhealthiest
	local lowest_hp = math.huge
	for i, ally in pairs(allies) do
		local hp_pc = ally:GetHealth() / ally:GetMaxHealth()
		if hp_pc < lowest_hp then
			unhealthiest = ally
			lowest_hp = hp_pc
		end
	end

	return unhealthiest
end
