function Spawn(keys)
	local ab = thisEntity:FindAbilityByName("ability_creep_heal")

	if not ab:GetToggleState() then
		ab:ToggleAbility()
	end

	Timers:CreateTimer(0.5, function()
		local level = string.sub(thisEntity:GetUnitName(), -1)
		ab:SetLevel(level + 1)
	end)
end

function HealerAttachParticle(keys)		
	local radius = keys.ability:GetLevelSpecialValueFor("aoe_radius", 1)
	local caster = keys.caster
	local particle_name = keys.Particle
	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(radius,radius,radius))
	ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_staff", caster:GetAbsOrigin(),true)
end