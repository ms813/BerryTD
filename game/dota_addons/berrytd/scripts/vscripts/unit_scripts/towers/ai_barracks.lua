function Spawn(entityKeyValues)

	--initiate an empty table to track the defenders
	thisEntity.defenders = {}
	thisEntity.upgrades = {}

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

	--some AI for the defenders in this barracks
	for i, defender in pairs (tower.defenders) do

		--this checks that the defenders are not dead
		if not defender:IsNull() then

			--check that the defenders haven't moved too far from the spawn flag	
			local d_pos = defender:GetAbsOrigin()		
			local dist = (tower.spawn_pos - d_pos):Length2D()
				
			--if they are too far from the spawn then deaggro and move back
			if dist > tower.max_aggro_dist then
				--print("defender too far from spawn, trying to move back")
				defender:MoveToPosition(tower.spawn_pos)

				--reset aggro
				creep:SetAttackCapability(creep.default_attack_capability)
				defender.aggro_target = nil
			end	

			if defender.aggro_target ~= nil and not defender.aggro_target:IsAlive() then
				defender.aggro_target = nil
			end

			if defender.aggro_target == nil then

				local creeps = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,
										defender:GetAbsOrigin(),
										nil,
										defender:GetAcquisitionRange(),
									    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
									    DOTA_UNIT_TARGET_ALL,
									    DOTA_UNIT_TARGET_FLAG_NONE,
									    FIND_CLOSEST,
										false)

				for i, creep in pairs(creeps) do
					
					--creep can't attack so hasn't been aggroed before
					if creep:GetAttackCapability() ~= DOTA_UNIT_CAP_MELEE_ATTACK then
						defender.aggro_target = creep
						creep:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
						AttackOrder(defender, creep)
						AttackOrder(creep, defender)
						break
					end
				end
			end
		end
	end
	return 0.1
end

function AttackOrder(attacker, target)
	ExecuteOrderFromTable({
		UnitIndex = attacker:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()
	})


end

function SpawnDefender(keys)
	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability	

	if #caster.defenders < caster.defender_cap then
		local defender = CreateUnitByName(keys.AbilityContext.defender_name,
											 caster.spawn_pos, 
											 true,
											 caster:GetOwner(),
											 caster:GetOwner(),
											 caster:GetTeamNumber())	

		defender.parent_barracks = caster

		--apply any upgrades to this defender
		if caster.upgrades ~= nil then

			--loop through the current list of upgrades
			for k, upgrade in pairs(caster.upgrades) do
				--print("adding ability to defender: ", upgrade.Ability)
				
				--add the ability and upgrade it to level 1
				defender:AddAbility(upgrade.Ability)
				local ab = defender:FindAbilityByName(upgrade.Ability):SetLevel(upgrade.Level)				
				
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
		--make the flag invisible as soon as a new one is placed
		caster:AddSpeechBubble(0, "New spawn point set", 5, 0, 0)
		caster.flag:AddNoDraw()
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
	
	--cache a list of upgrades here so we can apply them to each defender on spawn	
	table.insert(keys.caster.upgrades, keys.AbilityContext)

	--remove the regen_manager from the racks itself	
	if keys.AbilityContext.Ability == "ability_melee_defender_regen_manager" then
		keys.caster:RemoveAbility(keys.AbilityContext.Ability)
	end
end

function DisableRegen(keys)

	local defender = keys.caster
	local timeout = keys.ability:GetLevelSpecialValueFor("timeout")
	local regen_ability = keys.AbilityContext.Ability

	--unit has taken damage so remove the regen ability for %timeout
	if keys.Damage > 0 then
		if defender.regen_timer ~= nil then
		--stop any previous timers
			Timers:RemoveTimer(defender.regen_timer)				
		end

		--remove the regen ability immediately
		defender:RemoveAbility(regen_ability)

		--start a new timer that will re-add the regen mod after the timeout
		defender.regen_timer = Timers:CreateTimer({
		    endTime = timeout, 
		    callback = function()
			    defender:AddAbility(regen_ability)			    
			    defender:FindAbilityByName(regen_ability):SetLevel(keys.AbilityContext.Level)
		    end
		})
		end
	end
	
end