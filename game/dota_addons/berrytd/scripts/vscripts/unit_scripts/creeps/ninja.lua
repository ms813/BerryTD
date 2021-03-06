function Spawn(keys)
	--level up the invis ability to the level of the creep
	local ab = thisEntity:FindAbilityByName("ability_creep_ninja_invis")
	--get the creeps level by trimming the last digit of the name
	thisEntity.creep_level = tonumber(string.sub(thisEntity:GetUnitName(), -1))
	ab:SetLevel(thisEntity.creep_level + 1)
end

function NinjaInvis(keys)
	local lvl = keys.caster.creep_level
	print(lvl)
	local duration = keys.ability:GetLevelSpecialValueFor("invis_duration", lvl)
	local timeout = keys.ability:GetLevelSpecialValueFor("invis_timeout", lvl)

	if keys.ability:IsCooldownReady() then
		keys.ability:StartCooldown(timeout)
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_creep_ninja_invis", {})
	end	
end