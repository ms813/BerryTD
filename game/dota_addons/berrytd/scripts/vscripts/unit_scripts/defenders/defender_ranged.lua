--[[
	Add stacks of a modifier to a unit when they land a successful attack
	(similar to Troll Warlord Fervor)

	If the unit stops attacking for a few seconds, the stack starts to rapidly decay
]]
function DefenderRangedSpeedStack(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.AbilityContext.modifier
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", 1)
	local stack_decay_delay = ability:GetLevelSpecialValueFor("stack_decay_delay", 1)
	local stack_decay_rate = ability:GetLevelSpecialValueFor("stack_decay_rate", 1)

	local max_stacks_modifier = keys.AbilityContext.max_stacks_modifier
	
	--check if the unit already has an instance of the modifier
	if caster:HasModifier(modifier) then
		
		--grab a reference to the number of stacks already on the unit
		local stack_count = caster:GetModifierStackCount(modifier, ability)

		--only add new stacks if the unit haven't already reached the cap
		if stack_count < max_stacks then		

			--increase the stack count	
			caster:SetModifierStackCount(modifier, ability, stack_count + 1)
		else
			if not caster:HasModifier(max_stacks_modifier) then
				ability:ApplyDataDrivenModifier(caster, caster, max_stacks_modifier, {})
			end
		end
	else
		--if the unit has no stacks, add a new instance of the modifier
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})

		--set the number of stacks of the modifier to 1
		caster:SetModifierStackCount(modifier, ability, 1)
	end

	--when an attack lands, kill the previous decay timers
	if caster.speed_stack_timer ~= nil then
		Timers:RemoveTimer(caster.speed_stack_timer)
	end

	--start a timer to remove stacks after the initial delay
	caster.speed_stack_timer = Timers:CreateTimer(stack_decay_delay,
		function()
			local stack_count = caster:GetModifierStackCount(modifier, ability)			
			caster:SetModifierStackCount(modifier, ability, stack_count - 1)

			if caster:HasModifier(max_stacks_modifier) then
				caster:RemoveModifierByName(max_stacks_modifier)
			end
			return stack_decay_rate
		end) 
end


--[[
	Similar to the above speed stack but for damage

	If the cap is reached, an additional modifier is applied that changes the units damage type
]]

function DefenderRangedDmgStack(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.AbilityContext.modifier
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", 1)
	local stack_decay_delay = ability:GetLevelSpecialValueFor("stack_decay_delay", 1)
	local stack_decay_rate = ability:GetLevelSpecialValueFor("stack_decay_rate", 1)
	local regular_projectile = keys.AbilityContext.regular_projectile

	local max_stacks_modifier = keys.AbilityContext.max_stacks_modifier
	local max_projectile = keys.AbilityContext.max_projectile

	--check if the unit already has an instance of the modifier
	if caster:HasModifier(modifier) then
		
		--grab a reference to the number of stacks already on the unit
		local stack_count = caster:GetModifierStackCount(modifier, ability)

		--only add new stacks if the unit haven't already reached the cap
		if stack_count < max_stacks then		

			--increase the stack count	
			caster:SetModifierStackCount(modifier, ability, stack_count + 1)
		else
			if not caster:HasModifier(max_stacks_modifier) then
				ability:ApplyDataDrivenModifier(caster, caster, max_stacks_modifier, {})

				caster:SetRangedProjectileName(max_projectile)	

			end
		end
	else
		--if the unit has no stacks, add a new instance of the modifier
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})

		--set the number of stacks of the modifier to 1
		caster:SetModifierStackCount(modifier, ability, 1)
	end

	--when an attack lands, kill the previous decay timers
	if caster.dmg_stack_timer ~= nil then
		Timers:RemoveTimer(caster.dmg_stack_timer)
	end

	--start a timer to remove stacks after the initial delay
	caster.dmg_stack_timer = Timers:CreateTimer(stack_decay_delay, 
		function()
			local stack_count = caster:GetModifierStackCount(modifier, ability)			
			caster:SetModifierStackCount(modifier, ability, stack_count - 1)

			if caster:HasModifier(max_stacks_modifier) then
				caster:RemoveModifierByName(max_stacks_modifier)
				caster:SetRangedProjectileName(regular_projectile)
			end
			return stack_decay_rate
		end) 
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