function Spawn(entityKeyValues)	

	lvlUpUnitAbilities(thisEntity)

	Timers:CreateTimer(function()
			return DragonThink(thisEntity)
		end)
end

function DragonThink(tower)
	--stop the timer if we sell the tower
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local dragonfire = tower:FindAbilityByName("ability_dragonfire")

	if dragonfire ~= nil then

		if dragonfire:GetCooldownTimeRemaining() <= 0.0 then
			local range = dragonfire:GetLevelSpecialValueFor("cast_range", 1)

			--fire at closest creep
			local creeps = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
											tower:GetAbsOrigin(),
											nil,
											range - 50,
										    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
										    DOTA_UNIT_TARGET_ALL,
										    DOTA_UNIT_TARGET_FLAG_NONE,
										    FIND_CLOSEST,
											false)
			if #creeps > 0 then				
				dragonfire.next_target = creeps[1]
				--dragonfire:CastAbility()

				local target_pos = GetGroundPosition(creeps[1]:GetAbsOrigin(), nil)								
				tower:CastAbilityOnPosition(target_pos, dragonfire, tower:GetPlayerOwnerID())				
			end
		end		
	end

	return 0.1
end

--[[
	Deal a % of the targets current hp as damage
]]
function BurnTick(keys)
	local percent_dmg = keys.AbilityContext.currentHpPercentDmg	
	local dmg = keys.target:GetHealth() * percent_dmg	
	ApplyDamage({
		victim = keys.target,
		attacker = keys.caster,
		damage = dmg,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end