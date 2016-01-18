function Spawn(entityKeyValues)

	--initiate an empty table to track the defenders
	thisEntity.defenders = {}

	--pick a random spawn location when this racks is placed
	thisEntity.spawn_pos = thisEntity:GetAbsOrigin() + RandomVector(1)*500

	local barracks_name = thisEntity:GetUnitName()	
	if barracks_name == "barracks_melee" then
		thisEntity.barracks_type = "melee"		
	elseif barracks_name == "barracks_ranged" then
		thisEntity.barracks_type = "ranged"
	end

	--grab the spawn ability and cache the defender cap
	local ability_name = "ability_barracks_spawn_"..thisEntity.barracks_type.."_defender"
	local spawn_ability = thisEntity:FindAbilityByName(ability_name)
	thisEntity.defender_cap = spawn_ability:GetLevelSpecialValueFor("defender_cap", 1)

	--grab the max aggro distance from the ability KV
	thisEntity.max_aggro_dist = spawn_ability:GetLevelSpecialValueFor("max_aggro_dist", 1)	

	local spawn_start_delay = 5
	Timers:CreateTimer(spawn_start_delay, function()
			return BarracksThink(thisEntity)
		end)
end

function BarracksThink(tower)

	--stop the timer if we sell the tower
	if tower:IsNull() or not tower:IsAlive() then		
		return nil
	end

	local ab_name = "ability_barracks_spawn_"..tower.barracks_type.."_defender"
	local spawn_ability = tower:FindAbilityByName(ab_name)

	if spawn_ability ~= nil then
		if spawn_ability:GetCooldownTimeRemaining() <= 0.0 then			
			if #tower.defenders < tower.defender_cap then			
				spawn_ability:CastAbility()	
			end
		end
	end	

	--check that the defenders haven't moved too far from the spawn flag	
	for i, defender in pairs (tower.defenders) do
		local d_pos = defender:GetAbsOrigin()		
		local dist = (tower.spawn_pos - d_pos):Length2D()
		
		if dist > tower.max_aggro_dist then
			print("defender too far from spawn, trying to move back")
			defender:MoveToPosition(tower.spawn_pos)
		end
	end


	return 0.5
end

function SpawnDefender(keys)
	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability	

	if #caster.defenders < caster.defender_cap then
		local defender = CreateUnitByName(keys.AbilityContext.defender_name,
											 caster.spawn_pos, 
											 true,
											 caster,
											 caster,
											 caster:GetTeamNumber())	

		--apply any upgrades to this defender
		if caster.upgrades ~= nil then

			--loop through the current list of upgrades
			for k, upgrade in pairs(caster.upgrades) do
				print("adding ability to defender: ", upgrade.Ability)
				
				--add the ability and upgrade it to level 1
				defender:AddAbility(upgrade.Ability)
				local ab = defender:FindAbilityByName(upgrade.Ability)
				ab:SetLevel(upgrade.Level)
				
				if upgrade.Model ~= nil then
					defender:SetModel(upgrade.Model)
				end

				--hack here to increase HP as the MODIFIER_PROPERTY_HEALTH_BONUS KV doesnt work
				local hp_increase = ab:GetLevelSpecialValueFor("hp_increase", 1)
				if hp_increase ~= nil then
					defender:SetMaxHealth(defender:GetMaxHealth() + hp_increase)
					defender:SetHealth(defender:GetMaxHealth())
				end
			end
		end	

		--finally add this defender to the racks table
		table.insert(caster.defenders, defender)

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
		caster.spawn_pos = nil	
	end

	caster.flag = CreateUnitByName("barracks_spawn_flag",
										target_pos,
										true,
										caster,
										caster,
										caster:GetTeamNumber())  
	caster.flag:SetHullRadius(0.1)
	caster.spawn_pos = caster.flag:GetAbsOrigin()
end

function Upgrade(keys)
	--AbilityContext has the following fields:
		--Ability
		--Level
		--Model		
	if keys.caster.upgrades == nil then
		keys.caster.upgrades = {}
	end
	table.insert(keys.caster.upgrades, keys.AbilityContext)
end