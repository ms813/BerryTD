require("targetingHelper")

function Spawn(keys)	
	Timers:CreateTimer(function()
		return TeslaCoilThink(thisEntity)
	end)

end

function TeslaCoilThink(tower)

	local ability = tower:GetAbilityByIndex(1)
	if ability ~= nil then
		local range = ability:GetLevelSpecialValueFor("range", 1)
		local targets = TargetingHelper.FindDireInRadius(tower, range)

		for i, target in pairs(targets) do		
			if not target:HasModifier("modifier_minus_armour_0") then
				tower:CastAbilityOnTarget(target, ability, tower:GetPlayerOwnerID())
				return 0.5
			end
		end
	end

	return 0.5
end

function TeslaCoilAttachParticle_0(keys)
	local target = keys.target
    local location = target:GetAbsOrigin()
    local particleName = keys.AbilityContext.particle

-- Particle. Need to wait one frame for the older particle to be destroyed
    Timers:CreateTimer(0.01, function() 
        target.AmpDamageParticle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(target.AmpDamageParticle, 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.AmpDamageParticle, 1, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.AmpDamageParticle, 2, target:GetAbsOrigin())

        ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 1, target, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 2, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    end)
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



function TeslaCoilLightningHit(keys)
	local caster = keys.caster	
    local modifier = keys.AbilityContext.modifier
    local ab = keys.ability
    local particleName = keys.AbilityContext.particle    

    local range = ab:GetLevelSpecialValueFor("range", 1)
    local dmg = ab:GetLevelSpecialValueFor("damage", 1)
    local targets = TargetingHelper.FindDireInRadius(caster, range)

    for i, target in pairs(targets) do

	    target.lightning_particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, target)
	    ParticleManager:SetParticleControl(target.lightning_particle, 0, target:GetAbsOrigin()+Vector(0,0,100))
	    ParticleManager:SetParticleControl(target.lightning_particle, 1, caster:GetAbsOrigin()+Vector(0,0,280))    

	    if target:HasModifier(modifier) then
	        local stack_count = target:GetModifierStackCount(modifier, ab)
	        target:SetModifierStackCount(modifier, ab, stack_count + 1)
	    else
	        ab:ApplyDataDrivenModifier(caster, target, modifier, {})
	        target:SetModifierStackCount(modifier, ab, 1)
	    end

	    ApplyDamage({
	    	victim = target,
	    	attacker = caster,
	    	damage = dmg,
	    	damage_type = DAMAGE_TYPE_PHYSICAL
	    })
	end   
end
