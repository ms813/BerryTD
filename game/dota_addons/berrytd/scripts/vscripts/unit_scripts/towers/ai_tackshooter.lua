function Spawn(entityKeyValues)	

	for i = 0, thisEntity:GetAbilityCount()-1 do
    	local a = thisEntity:GetAbilityByIndex(i)

    	if a ~= nil then
      	a:SetLevel(1)
  		end
	end

	Timers:CreateTimer(function()
			return TackShooterThink(thisEntity)
		end)
end

function TackShooterThink(tower)

	--stop the timer if we sell the tower
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local shoot_tacks = tower:FindAbilityByName("ability_shoot_tacks")

	if shoot_tacks ~= nil then
		if shoot_tacks:GetCooldownTimeRemaining() > 0.0 then
			return shoot_tacks:GetCooldownTimeRemaining()
		end

		local targets = FindUnitsInRadius(
					DOTA_TEAM_NEUTRALS,
					tower:GetAbsOrigin(),
					nil,
					tower:GetAcquisitionRange(), --range of tackshooter ability
					DOTA_UNIT_TARGET_TEAM_FRIENDLY,
					DOTA_UNIT_TARGET_ALL,
					DOTA_DAMAGE_FLAG_NONE,
					FIND_ANY_ORDER,
					false
				)

		if #targets > 0 then
			shoot_tacks:CastAbility()
		end
	end

	return 0.5
end

function launchTacks(keys)

    local caster = keys.caster
    local caster_point = caster:GetOrigin()

    local projectile_distance = keys.ability:GetLevelSpecialValueFor('distance', keys.ability:GetLevel())
    local projectile_radius = keys.ability:GetLevelSpecialValueFor('radius', keys.ability:GetLevel())
    local projectile_speed = keys.ability:GetLevelSpecialValueFor('speed', keys.ability:GetLevel())
    local projectile_damage = keys.ability:GetLevelSpecialValueFor('damage', keys.ability:GetLevel())
    local projectile_particle = keys.AbilityContext.projectile_particle

    local directions = {
        --Vector(x, y, z)
        Vector( 1,  0,  0):Normalized(),  --E
        Vector( 1,  1,  0):Normalized(),  --SE
        Vector( 0,  1,  0):Normalized(),  --S
        Vector(-1,  1,  0):Normalized(),  --SW
        Vector(-1,  0,  0):Normalized(),  --W
        Vector(-1, -1,  0):Normalized(),  --NW
        Vector( 0, -1,  0):Normalized(),  --N
        Vector( 1, -1,  0):Normalized()   --NE
    }

    if caster.fire16Ways == true then       
        local newDirections = {
        Vector( 2.415,  1,  0):Normalized(),  --SEE
        Vector( 1,  2.415,  0):Normalized(),  --SSE
        Vector(-1,  2.415,  0):Normalized(),  --SSW
        Vector(-2.415,  1,  0):Normalized(),  --SWW
        Vector(-2.415, -1,  0):Normalized(),  --NWW
        Vector(-1, -2.415,  0):Normalized(),  --NNW
        Vector( 1, -2.415,  0):Normalized(),  --NNE
        Vector( 2.415, -1,  0):Normalized()   --NEE
        }

        for i = 1, #newDirections do
            directions[#directions + 1] = newDirections[i]
        end
    end

    for i = 1, #directions do

        local projectile = {
            bGroundLock = true,
            bZCheck = false,
            bIgnoreSource = true,
            draw = false, --{rad = projectile_radius}
            EffectName = projectile_particle,
            fDistance = projectile_distance,
            fStartRadius = projectile_radius,
            fEndRadius = projectile_radius,
            Source = caster,            
            vSpawnOrigin = caster_point,
            vVelocity = directions[i] * projectile_speed,
            WallBehaviour = PROJECTILES_NOTHING,
            TreeBehavior = PROJECTILES_NOTHING,
            UnitBehavior = PROJECTILES_DESTROY,

            UnitTest = function(self, unit)
                return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber()
            end,
            OnUnitHit = function(self, unit)
            --print("hit unit", unit:GetUnitName())
                local dmgTable = {
                    victim = unit,
                    attacker = self.Source,
                    damage = projectile_damage,
                    damage_type = DAMAGE_TYPE_PHYSICAL
                }

                ApplyDamage(dmgTable)
            end,

            OnFinish = function(self, position)
               self:Destroy() 
            end
        }

        Projectiles:CreateProjectile(projectile)
    end    
end