function Spawn(entityKeyValues)		

	local ability_spawn_flag = thisEntity:FindAbilityByName("ability_barracks_spawn_melee_defender")
	local defender_cap = ability_spawn_flag:GetLevelSpecialValueFor("defender_cap", 1)

	if thisEntity.defender_cap == nil then
		thisEntity.defender_cap = defender_cap
		thisEntity.defender_count = 0
	end

	local spawn_start_delay = 5
	Timers:CreateTimer(spawn_start_delay, function()
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
	local dmg = ability:GetLevelSpecialValueFor("damage", 1)
	local health = ability:GetLevelSpecialValueFor("health", 1)

	local spawnPos
 	if caster.flag ~= nil and IsValidEntity(caster.flag) then
 		--if flag has been placed spawn the defender on the flag
 		spawnPos =  caster.flag:GetAbsOrigin() 		
 	else 
 		--if the flag has not been placed spawn randomly on the edge of the max range
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

		if caster.upgrade1 ~= nil then
			print("adding ability to defender: ", caster.upgrade1)
			defender:AddAbility(caster.upgrade1.Ability)	
			defender:FindAbilityByName(caster.upgrade1.Ability):SetLevel(caster.upgrade1.Level)
			defender:SetModel(caster.upgrade1.Model)
		end		
	end		
end

function SetDefenderSpawn(keys)
	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability

	--the target vector is passed from the KV "OnAbilityStart"{"RunScript" {"Target" "POINT"}}
	local target_pos = keys.target_points[1]		
	local ability_cast_range = ability:GetLevelSpecialValueFor("cast_range", 1)
	local cast_dist = (caster_pos - target_pos):Length2D();

	if cast_dist > ability_cast_range then  
		--move the flag to the edge of the ring on the same bearing as the target_point
		target_pos = caster_pos + (target_pos - caster_pos):Normalized() * ability_cast_range
	end

 	--get rid of the old flag if there is one
	if caster.flag ~= nil and IsValidEntity(caster.flag) then
		caster.flag:ForceKill(false)
		caster.flag = nil		
	end

	caster.flag = CreateUnitByName("barracks_spawn_flag",
										target_pos,
										true,
										caster,
										caster,
										caster:GetTeamNumber())  
	caster.flag:SetHullRadius(0.1)
end

function Upgrade1(keys)
	--AddAbility1 has the following fields:
		--Ability
		--Level
		--Model
	keys.caster.upgrade1 = keys.AddAbility1	
end