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

	--add alacrity to the spell rotation if defender has it
	local alacrity = defender:FindAbilityByName("ability_utility_defender_2")
	if alacrity ~= nil and alacrity:IsCooldownReady() then
		local range = alacrity:GetLevelSpecialValueFor("range", 1)
		local targets = TargetingHelper.FindNearbyFriendlies(defender, range)

		local highest_level = -1
		--find highest level target
		for i, target in pairs(targets) do
			if target.upgrade_level > highest_level then
				highest_level = target.upgrade_level
			end
		end
		--check highest level targets first, then
		--check the target doesnt already have this buff
		for i = highest_level, 0, -1 do
			for j, target in pairs(targets) do
				if target.upgrade_level == i and not target:HasModifier("modifier_utility_defender_alacrity") then
					defender:CastAbilityOnTarget(target, alacrity, defender:GetPlayerOwnerID())
					return 1
				end
			end
		end
	end

	--add frost armour to the spell rotation if defender has it
	local armour_ab = defender:FindAbilityByName("ability_utility_defender_1")
	if armour_ab ~= nil and armour_ab:IsCooldownReady() then		
		
		local range = armour_ab:GetLevelSpecialValueFor("range", 1)
		local targets = TargetingHelper.FindNearbyFriendlies(defender, range)

		local highest_level = -1
		--find highest level target
		for i, target in pairs(targets) do
			if target.upgrade_level > highest_level then
				highest_level = target.upgrade_level
			end
		end
		--check highest level targets first, then
		--check the target doesnt already have this buff
		for i = highest_level, 0, -1 do
			for j, target in pairs(targets) do
				if target.upgrade_level == i and not target:HasModifier("modifier_utility_defender_frost_armour") then
					defender:CastAbilityOnTarget(target, armour_ab, defender:GetPlayerOwnerID())
					return 1
				end
			end
		end

		return 1	
	end

	--add heal to the spell rotation if defender has it
	local heal_ab_0 = defender:FindAbilityByName("ability_utility_defender_0")
	if heal_ab_0 ~= nil and heal_ab_0:IsCooldownReady() then	
		local range = heal_ab_0:GetLevelSpecialValueFor("range", 1)
		local target = TargetingHelper.LowestHPPercentAlly(defender, range)
		defender:CastAbilityOnTarget(target, heal_ab_0, defender:GetPlayerOwnerID())	
		return 1
	end

	return 0.5
end