function Spawn(entityKeyValues)	
	Timers:CreateTimer(function()
			return GeodesicThink(thisEntity)
		end)
end

function GeodesicThink(creep)

	--stop the timer if the creep dies
	if creep:IsNull() or not creep:IsAlive() then
		return nil
	end

	local refraction = creep:GetAbilityByIndex(0)

	if refraction ~= nil then
		if refraction:GetCooldownTimeRemaining() > 0.0 then
			return refraction:GetCooldownTimeRemaining()
		end

		refraction:CastAbility()
	end

	return 0.5
end