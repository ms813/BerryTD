function MeleeDefenderDisableRegen(keys)			
	local cd = keys.AbilityContext.Cooldown	
	local regen_ability = keys.ability	

	--if defender takes damage, put his regen on cooldown
	regen_ability:StartCooldown(cd)	

	--if regen ability is on...
	if regen_ability:GetToggleState() then
		--...toggle it off
		regen_ability:ToggleAbility()
	end
end

function MeleeDefenderResCreep(keys)
	local caster = keys.caster
	local unit = keys.unit
	local ability = keys.ability
	local res_duration = keys.ability:GetLevelSpecialValueFor("res_duration", 1)
	local particle = keys.AbilityContext.particle
	

	local zombie = CreateUnitByName(
		unit:GetUnitName(),
		unit:GetAbsOrigin(),
		true, 
		caster:GetOwner(), 
		caster:GetOwner(), 
		DOTA_TEAM_GOODGUYS)

	zombie:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

	zombie:AddNewModifier(caster, nil, "modifier_kill", {duration = res_duration})	
	ability:ApplyDataDrivenModifier(
		caster, 
		zombie, 
		"modifier_melee_defender_5_ghost", 
		{})	

	ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW, zombie)

	local rnd = math.random(100)	
	if rnd < 20 then
		EmitSoundOn(keys.AbilityContext.sound, zombie)
	end
	
end

function MeleeDefenderAttachParticles(keys)
	local particle = keys.AbilityContext.particle
	ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW, keys.target)
end

function MeleeDefenderZombieDeath(keys) 
	keys.unit:AddNoDraw()
end