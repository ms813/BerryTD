function Spawn(entityKeyValues)	
	Timers:CreateTimer(function()
			return DragonThink(thisEntity)
		end)

	print("Dragon tower AI initiated")
end

function DragonThink(tower)
	--stop the timer if we sell the tower
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local liquid_fire = tower:FindAbilityByName("jakiro_liquid_fire")

	if liquid_fire ~= nil then

		if liquid_fire:GetAutoCastState() == false then
			liquid_fire:ToggleAutoCast()
		end
	end

	return 0.5
end