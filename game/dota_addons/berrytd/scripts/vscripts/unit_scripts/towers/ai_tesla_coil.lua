require("targetingHelper")

function Spawn(keys)	

	--set tower to face the camera
	thisEntity:SetAngles(0, 90, 0)	

	Timers:CreateTimer(function()
		return TeslaCoilThink(thisEntity)
	end)
end

function TeslaCoilThink(tower)
	--stop the timer if the tower is removed
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local ability = tower:GetAbilityByIndex(1)
	if ability ~= nil then

		local targets = TargetingHelper.FindDireInRadius(tower, ability:GetLevelSpecialValueFor("range", 1))
		if #targets > 0 then
			ability:CastAbility()	
		end
	end

	return 0.05
end

-- Destroys the particle when the modifier is destroyed
function EndTeslaCoilParticle0(keys)
    local target = keys.target
    ParticleManager:DestroyParticle(target.AmpDamageParticle,false)
end

function TeslaCoilUpgrade(keys)
	local caster = keys.caster
	local old_ab_name = keys.AbilityContext.old_ability
	local new_ab_name = keys.AbilityContext.new_ability

	caster:RemoveAbility(old_ab_name)
	local new_ability = caster:AddAbility(new_ab_name)
	new_ability:SetLevel(1)
end

function TeslaCoilLightningSingle(keys, target)
	local caster = keys.caster	
    local modifier_name = keys.AbilityContext.modifier
    local ab = keys.ability
    local particleName = keys.AbilityContext.particle 
    local range = ab:GetLevelSpecialValueFor("range", 1)   

    if target == nil then
		local targets = TargetingHelper.FindDireInRadius(caster, range)

		if #targets > 0 then 
			local rnd = math.random(1, #targets)
			target = targets[rnd]
		end
	end

	if target ~= nil then
		target.lightning_particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, target)
	    ParticleManager:SetParticleControl(target.lightning_particle, 0, target:GetAbsOrigin()+Vector(0,0,100))
	    ParticleManager:SetParticleControl(target.lightning_particle, 1, caster:GetAbsOrigin()+Vector(0,0,180))    

	    local modifier = target:FindModifierByName(modifier_name)
	    if modifier ~= nil then	        
	    	local duration = ab:GetLevelSpecialValueFor("duration", ab:GetLevel())
	        modifier:IncrementStackCount()
	        modifier:SetDuration(duration,true)	        
	    else
	        ab:ApplyDataDrivenModifier(caster, target, modifier_name, {})
	        target:SetModifierStackCount(modifier_name, ab, 1)
	    end

	    local dmg = ab:GetLevelSpecialValueFor("damage", 10)
	    ApplyDamage({
	    	victim = target,
	    	attacker = caster,
	    	damage = dmg,
	    	damage_type = DAMAGE_TYPE_PHYSICAL
	    })
	end
end

function TeslaCoilLightningMulti(keys)	
    local ab = keys.ability    
    local range = ab:GetLevelSpecialValueFor("range", 1)    
    local targets = TargetingHelper.FindDireInRadius(keys.caster, range)

    for i, target in pairs(targets) do
		TeslaCoilLightningSingle(keys, target)	    
	end   
end
