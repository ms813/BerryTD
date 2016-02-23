function Spawn(entityKeyValues)	
	Timers:CreateTimer(function()
		return VoidwalkerThink(thisEntity)
	end)

	local refraction = thisEntity:FindAbilityByName("templar_assassin_refraction")
	local creep_lvl = string.sub(thisEntity:GetUnitName(), -1)
	refraction:SetLevel(creep_lvl + 2)	
end

function VoidwalkerThink(creep)

	--stop the timer if the creep dies
	if creep:IsNull() or not creep:IsAlive() then
		return nil
	end

	local refraction = creep:FindAbilityByName("templar_assassin_refraction")

	if refraction ~= nil and refraction:IsCooldownReady() then					
		refraction:CastAbility()
	end

	return 0.5
end