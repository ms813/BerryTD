require("targetingHelper")

function Spawn(keys)
	print("minus armour tower spawned at:", thisEntity:GetAbsOrigin())
	Timers:CreateTimer(function()
		return MinusArmourThink(thisEntity)
	end)

end

function MinusArmourThink(tower)

	local ability = tower:GetAbilityByIndex(1)
	print(ability:GetName())
	if ability ~= nil then
		local range = ability:GetLevelSpecialValueFor("range", 1)
		local targets = TargetingHelper.FindDireInRadius(tower, range)

		for i, target in pairs(targets) do
			print("minus armour target", target:GetUnitName())
			if not target:HasModifier("modifier_minus_armour_0") then
				tower:CastAbilityOnTarget(target, ability, tower:GetPlayerOwnerID())
				return 0.5
			end
		end
	end

	return 0.5
end