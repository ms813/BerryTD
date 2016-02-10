require('targetingHelper')

function Spawn(keys)
	print(thisEntity:GetUnitName(), "spawned")

	Timers:CreateTimer(0.5, function()
		return LaserTowerThink(thisEntity)
	end)

	thisEntity.laser_particle = "particles/units/heroes/hero_tinker/tinker_laser.vpcf"
end

function LaserTowerThink(tower)

	--if tower dies stop the timer
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local ability = tower:GetAbilityByIndex(1)
	if ability ~= nil and ability:IsCooldownReady() then
		local range = ability:GetLevelSpecialValueFor("range", 1)
		local targets = TargetingHelper.FindDireInRadius(tower, range)
		if #targets > 0 then
			tower:CastAbilityOnTarget(targets[1], ability, tower:GetPlayerOwnerID())
		end
	end
	return 0,5
end

function LaserTowerLaserParticle(keys)
	local p_name = keys.caster.laser_particle
	local particle = ParticleManager:CreateParticle(p_name,PATTACH_CUSTOMORIGIN,keys.caster)	
	ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 9, keys.caster:GetAbsOrigin() + Vector(0,0,320))
	--ParticleManager:SetParticleControlEnt(int int_1, int int_2, handle handle_3, int int_4, string string_5, Vector Vector_6, bool bool_7)
end