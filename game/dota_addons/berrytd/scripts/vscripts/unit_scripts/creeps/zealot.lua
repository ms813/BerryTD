function Spawn(keys)

	--level up the speed ability to the level of the creep
	local speed = thisEntity:FindAbilityByName("ability_creep_zealot")
	local attack_speed = thisEntity:FindAbilityByName("ability_creep_zealot_attackspeed")
	--get the creeps level by trimming the last digit of the name
	thisEntity.creep_level = tonumber(string.sub(thisEntity:GetUnitName(), -1))
	speed:SetLevel(thisEntity.creep_level + 1)
	attack_speed:SetLevel(thisEntity.creep_level + 1)

	--add a modifier that raises the movespeed cap
	thisEntity:AddNewModifier(thisEntity, nil, "modifier_movespeed_cap", nil)
	thisEntity.base_speed = thisEntity:GetBaseMoveSpeed()
	thisEntity.base_attack_speed = thisEntity:GetAttackSpeed()
end

--calculate a speed increase based on current hp
function ZealotUpdateSpeed(keys)
	local caster = keys.caster
	local base_speed = caster.base_speed
	local ab = keys.ability
	local max_speed = ab:GetLevelSpecialValueFor("max_speed", ab:GetLevel() - 1)	
	local hp_percent = caster:GetHealthPercent()/100
	local speed = (max_speed - base_speed) * (1-hp_percent) + base_speed

	caster:SetBaseMoveSpeed(speed)	
end

--calculate aattack speed increase based on current hp
function ZealotUpdateAttackSpeed(keys)
	local caster = keys.caster
	local modifier = keys.AbilityContext.modifier
	local hp_trigger_percent = keys.ability:GetLevelSpecialValueFor("hp_trigger_percent", keys.ability:GetLevel())

	local hp_percent = caster:GetHealthPercent()
	local stacks = math.ceil((100 - hp_percent)/hp_trigger_percent)
	
	caster:RemoveModifierByName(modifier)
	keys.ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	caster:SetModifierStackCount(modifier, keys.ability, stacks)
end