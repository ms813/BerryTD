require('targetingHelper')

function Spawn(keys)

	Timers:CreateTimer(0.5, function()
		return DefenderUtilityThink(thisEntity)
	end)
end

function DefenderUtilityThink(defender)	
	
	--if defender is dead stop the thinker
	if defender:IsNull() or not defender:IsAlive() then
		return nil
	end

	local heal_ab_0 = defender:FindAbilityByName("ability_utility_defender_0")

	if heal_ab_0 ~= nil then		
		DefenderUtilitySingleHeal(defender, heal_ab_0)
	end

	return 0.5
end

function DefenderUtilitySingleHeal(defender, ability)
	--get a list of nearby friendly units from the target helper
	local targets = TargetingHelper.FindNearbyFriendlies(defender, ability:GetLevelSpecialValueFor("range",1))
	local target
	local lowest_hp = math.huge

	--find the nearby ally with the lowest hp
	--note this could be changed into lowest % hp
	for i, friendly in pairs(targets) do		
		if friendly:GetHealth() < lowest_hp then
			target = friendly
			lowest_hp = target:GetHealth()
		end
	end
	--cast the heal ability on the target
	defender:CastAbilityOnTarget(target, ability, defender:GetPlayerOwnerID())
end