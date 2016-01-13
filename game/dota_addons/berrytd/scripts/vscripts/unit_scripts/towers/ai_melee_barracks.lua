function Spawn(entityKeyValues)	
	local abil = thisEntity:FindAbilityByName("ability_barracks_spawn_melee_defender"):CastAbility()

	Timers:CreateTimer(function()
			return MeleeBarracksThink(thisEntity)
		end)
end

function MeleeBarracksThink(tower)

	--stop the timer if we sell the tower
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local spawn_ability = tower:FindAbilityByName("ability_barracks_spawn_melee_defender")

	if spawn_ability ~= nil then
		if spawn_ability:GetCooldownTimeRemaining() > 0.0 then
			return spawn_ability:GetCooldownTimeRemaining()
		else

			if tower.defender_count < tower.defender_cap then			
				spawn_ability:CastAbility()	
			end
		end
	end
	return 0.5
end

function SpawnDefender(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local ability = keys.ability	

	if caster.defender_cap == nil then
		caster.defender_cap = ability:GetLevelSpecialValueFor("defender_cap", 1)
		caster.defender_count = 0
	end

	local dmg = ability:GetLevelSpecialValueFor("damage", 1)
	local health = ability:GetLevelSpecialValueFor("health", 1)

	if caster.defender_count < caster.defender_cap then
		local defender = CreateUnitByName("defender_melee",
											 casterPos + RandomVector(100), 
											 true,
											 caster,
											 caster,
											 caster:GetTeamNumber())					
		defender:SetBaseDamageMax(dmg)
		defender:SetBaseDamageMin(dmg)
		defender:SetBaseMaxHealth(health)
		caster.defender_count = caster.defender_count + 1			
	end
end