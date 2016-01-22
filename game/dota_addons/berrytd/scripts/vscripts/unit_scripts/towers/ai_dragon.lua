function Spawn(entityKeyValues)	
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
			local creeps = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,
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
				dragonfire:CastAbility()	
			end
		end		
	end

	return 0.1
end

function Dragonfire(keys)

	--[[
	keys:
		AbilityContext
		attacker
		caster
		ScriptFile
		unit
		Function
		ability
	]]

	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local ab = keys.ability
	local particle = keys.AbilityContext.projectile_particle

	local dist = ab:GetLevelSpecialValueFor("cast_range", 1)
	local dmg = ab:GetLevelSpecialValueFor("damage", 1)
	local speed = ab:GetLevelSpecialValueFor("projectile_speed", 1)
	local width_start = ab:GetLevelSpecialValueFor("width_start", 1)
	local width_end = ab:GetLevelSpecialValueFor("width_end", 1)
	
	local target_pos	
	if ab.next_target ~= nil then
		target_pos = GetGroundPosition(ab.next_target:GetAbsOrigin(), nil)
	end

	local dir = (target_pos - caster_pos):Normalized()		
	
	local projectile = {
		bGroundLock = true,
		fGroundOffset = 80,
		bZCheck = false,
		bIgnoreSource = true,
		draw = false,
		EffectName = particle,
		fDistance = dist,
		fStartRadius = width_start,
		fEndRadius = width_end,
		Source = caster,
		vSpawnOrigin = caster_pos + Vector(0,0,80),
		vVelocity = dir * speed,
		WallBehavior = PROJECTILES_NOTHING,
		TreeBehavior = PROJECTILES_NOTHING,
		bCutTrees = true,
		UnitBehavior = PROJECTILES_NOTHING,
		UnitTest = function(self, unit)
			return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber()
		end,
		OnUnitHit = function(self, unit)
			--print("hit unit", unit:GetUnitName())
			local dmgTable = {
                    victim = unit,
                    attacker = self.Source,
                    damage = dmg,
                    damage_type = DAMAGE_TYPE_MAGICAL
            }
            ApplyDamage(dmgTable)		
		end,	
		OnFinish = function (self, pos)
			self:Destroy()
		end		
	}
	
	Projectiles:CreateProjectile(projectile)	
end