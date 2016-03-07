require('targetingHelper')

function Spawn(keys)
	Timers:CreateTimer(0.5, function()
		return LaserTowerThink(thisEntity)
	end)
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
	local p_name = keys.AbilityContext.particle
	local particle = ParticleManager:CreateParticle(p_name,PATTACH_CUSTOMORIGIN,keys.caster)	
	ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 9, keys.caster:GetAbsOrigin() + Vector(0,0,320))	

	if keys.ability:GetLevel() > 2 then		
		keys.target:Purge(true, false, false, false, false)
	end
end