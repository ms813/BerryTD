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
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability	

	if caster.defender_cap == nil then
		caster.defender_cap = ability:GetLevelSpecialValueFor("defender_cap", 1)
		caster.defender_count = 0
	end

	local dmg = ability:GetLevelSpecialValueFor("damage", 1)
	local health = ability:GetLevelSpecialValueFor("health", 1)


	local spawnPos;
	if not caster.flag == nil and IsValidEntity(caster.flag) then
		local spawnPos =  caster.flag:GetAbsOrigin() + RandomVector(100)
	else 
		spawnPos = caster_pos + (RandomVector(1)*500)
	end

	if caster.defender_count < caster.defender_cap then
		local defender = CreateUnitByName("defender_melee",
											 spawnPos, 
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

function SetDefenderSpawn(keys)
	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability

	--the target vector is passed from the KV "RunScript" {"Target" "POINT"}
	--and is stored in keys.target_points[]
	local target_pos = keys.target_points[1]		
	local ability_cast_range = ability:GetSpecialValueFor("cast_range")
	local cast_dist = (caster_pos - target_pos):Length();

	--check if the spell is cast within the allowed cast range
	if cast_dist < ability_cast_range then

		--get rid of the old flag if there is one
		if not caster.flag == nil and IsValidEntity(caster.flag) then
			caster.flag:ForceKill(false)
			caster.flag = nil
		end

		caster.flag = CreateUnitByName("barracks_spawn_flag",
											target_pos,
											true,
											caster,
											caster,
											caster:GetTeamNumber())


	else
		print("Cant place here - outside range")
	end

end