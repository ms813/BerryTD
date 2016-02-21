

function Spawn(keys)

	--level up the speed ability to the level of the creep
	local ab = thisEntity:FindAbilityByName("ability_creep_zealot")
	--get the creeps level by trimming the last digit of the name
	thisEntity.creep_level = tonumber(string.sub(thisEntity:GetUnitName(), -1))
	ab:SetLevel(thisEntity.creep_level + 1)

	thisEntity:AddNewModifier(thisEntity, nil, "modifier_movespeed_cap", nil)
	thisEntity.base_speed = thisEntity:GetBaseMoveSpeed()
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