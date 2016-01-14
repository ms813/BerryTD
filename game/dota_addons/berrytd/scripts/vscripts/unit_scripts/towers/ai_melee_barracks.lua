function Spawn(entityKeyValues)	
	--initialise the barracks defender cap and count
	if caster.defender_cap == nil then
		caster.defender_cap = ability:GetSpecialValueFor("defender_cap")
		caster.defender_count = 0
	end

	--start a timer to auto spawn units
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

	--check cooldown and cast ability if ready
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
	local cast_range = caster:FindAbilityByName("ability_barracks_set_spawn"):GetSpecialValueFor("cast_range")	

	local dmg = ability:GetSpecialValueFor("damage")
	local health = ability:GetSpecialValueFor("health")

	--get the spawn position by checking for the spawn flag
	--otherwise spawn at random position on the edge of the max range
	local spawnPos;
	if not caster.flag == nil and IsValidEntity(caster.flag) then
		local spawnPos =  caster.flag:GetAbsOrigin() + RandomVector(100)
	else 
		spawnPos = caster_pos + (RandomVector(1)*cast_range)
	end

	--check this barracks hasn't reached its unit cap
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
		Say(defender, "gt fkd m9", false)
		ShowGenericPopup("Message 4 u", "Defender Spawned","", "", 1)
	end	

	--ResolveNPCPositions()
end

function SetDefenderSpawn(keys)
	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability

	--the target vector is passed from the KV "RunScript" {"Target" "POINT"}
	--and is stored in keys.target_points[]
	local target_pos = keys.target_points[1]		
	local ability_cast_range = ability:GetSpecialValueFor("cast_range")
	local cast_dist = (caster_pos - target_pos):Length2D();

	--check if the spell is cast within the allowed cast range
	if cast_dist > ability_cast_range then

		Warning("Trying to place spawn flag out of range")

		--move the target point to the max allowed range on the same bearing
		--as the original click
		target_pos = (target_pos - caster_pos):Normalized() * ability_cast_range
	end

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
	caster.flag:SetHullRadius(0.1)
	--ResolveNPCPositions()
end