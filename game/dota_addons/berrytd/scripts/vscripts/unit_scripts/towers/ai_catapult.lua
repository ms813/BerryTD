function Spawn(keys)
	print(thisEntity:GetUnitName(), "spawned")
end

function CatapultRemoveAbility(keys)	
	keys.caster:RemoveAbility(keys.AbilityContext.remove_ability)
	keys.caster:RemoveModifierByName(keys.AbilityContext.remove_modifier)
end


--[[
	Death animation for catapults
	AddNoDraw() to the dying unit and play the explosion animation
]]
function OnDeath(keys)	
	keys.caster:AddNoDraw()	
	local particle = keys.AbilityContext.particle
	ParticleManager:CreateParticle(
		particle,
		PATTACH_CUSTOMORIGIN_FOLLOW,
		keys.caster)
end

function CatapultChangeProjectile(keys)
	print(keys.AbilityContext.particle)
	keys.caster:SetRangedProjectileName(keys.AbilityContext.particle)
end