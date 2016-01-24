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

	local ab_name = "ability_barracks_spawn_"..thisEntity.barracks_type.."_defender"
	thisEntity.spawn_ability = thisEntity:FindAbilityByName(ab_name)
	thisEntity.defender_name = "defender_"..thisEntity.barracks_type.."_0"

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

	if tower.spawn_ability ~= nil then
		if tower.spawn_ability:GetCooldownTimeRemaining() <= 0.0 then			
			if #tower.defenders < tower.defender_cap then			
				tower.spawn_ability:CastAbility()	
			end
		end
	end	

	--some AI for the defenders in this barracks
	for i, defender in pairs (tower.defenders) do

		--this checks that the defenders are not dead
		if not defender:IsNull() then

			--try toggling on any toggle abilties if the cooldowns are ready
			local regen_ability = defender:FindAbilityByName("ability_melee_defender_regen")
			if  regen_ability ~= nil then				
				if not regen_ability:GetToggleState() then					
					if regen_ability:IsCooldownReady() then						
						regen_ability:ToggleAbility()
					end
				end
			end

			--check that the defenders haven't moved too far from the spawn flag	
			local d_pos = defender:GetAbsOrigin()		
			local dist = (tower.spawn_pos - d_pos):Length2D()
				
			--if they are too far from the spawn then deaggro and move back
			if dist > tower.max_aggro_dist then
				--print("defender too far from spawn, trying to move back")
				defender:MoveToPosition(tower.spawn_pos)

				--reset aggro
				local creep =defender.aggro_target
				creep:SetAttackCapability(creep.default_attack_capability)
				defender.aggro_target = nil
			end	

			--defender aggro AI
			if defender.aggro_target ~= nil and not defender.aggro_target:IsAlive() then
				defender.aggro_target = nil
			end

			--if defender has no target, look around for one
			if defender.aggro_target == nil then

				local creeps = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
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

function SetDefenderSpawn(keys)
	local rax = keys.caster
	local rax_pos = rax:GetAbsOrigin()
	local ability = keys.ability

	--the target vector is passed from the KV "OnAbilityStart"{"RunScript" {"Target" "POINT"}}
	local target_pos = keys.target_points[1]		
	local ability_cast_range = ability:GetLevelSpecialValueFor("cast_range", 1)
	local cast_dist = (rax_pos - target_pos):Length2D();

	if cast_dist > ability_cast_range then  
		--move the flag to the edge of the ring on the same bearing as the target_point
		target_pos = rax_pos + (target_pos - rax_pos):Normalized() * ability_cast_range
	end

 	--get rid of the old flag if there is one
	if rax.flag ~= nil and IsValidEntity(rax.flag) then
		--make the flag invisible as soon as a new one is placed
		rax:AddSpeechBubble(0, "New spawn point set", 5, 0, 0)
		rax.flag:AddNoDraw()
		rax.flag:ForceKill(false)
		rax.flag = nil	
		rax.spawn_pos = nil	
	end

	rax.flag = CreateUnitByName("barracks_spawn_flag",
										target_pos,
										true,
										rax,
										rax,
										rax:GetTeamNumber())  
	rax.flag:SetHullRadius(0.1)
	rax.spawn_pos = rax.flag:GetAbsOrigin()
end

function SpawnDefender(keys)
	local rax = keys.caster	
	local ability = keys.ability	

	if #rax.defenders < rax.defender_cap then
		local defender = CreateUnitByName(rax.defender_name,
											 rax.spawn_pos, 
											 true,
											 rax:GetOwner(),
											 rax:GetOwner(),
											 DOTA_TEAM_GOODGUYS)	

		defender.parent_barracks = rax
		defender.default_attack_capability = defender:GetAttackCapability()				
		
		--finally add this defender to this racks' table
		table.insert(rax.defenders, defender)
	end		
end

function Upgrade(keys)	
	keys.caster.defender_name = keys.AbilityContext.defender_name
end

function DisableRegen(keys)			
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