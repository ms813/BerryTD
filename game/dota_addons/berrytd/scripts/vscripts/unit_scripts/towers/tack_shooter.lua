function launchTacks(keys)

    local caster = keys.caster
    local caster_point = caster:GetOrigin()

    local projectile_distance = keys.ability:GetLevelSpecialValueFor('distance', keys.ability:GetLevel())
    local projectile_radius = keys.ability:GetLevelSpecialValueFor('radius', keys.ability:GetLevel())
    local projectile_speed = keys.ability:GetLevelSpecialValueFor('speed', keys.ability:GetLevel())
    local projectile_damage = keys.ability:GetLevelSpecialValueFor('damage', keys.ability:GetLevel())

    local directions = {
        --Vector(x, y, z)
        Vector( 1,  0,  0),  --E
        Vector( 1,  1,  0),  --SE
        Vector( 0,  1,  0),  --S
        Vector(-1,  1,  0),  --SW
        Vector(-1,  0,  0),  --W
        Vector(-1, -1,  0),  --NW
        Vector( 0, -1,  0),  --N
        Vector( 1, -1,  0)  --NE
    }

    for i = 1, #directions do
        local projectile = {
            bGroundLock = true,
            bZCheck = false,
            bIgnoreSource = true,
            draw = false, --{rad = projectile_radius}
            EffectName = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf",
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
            print("hit unit", unit:GetUnitName())
                local dmgTable = {
                    victim = unit,
                    attacker = self.Source,
                    damage = projectile_damage,
                    damage_type = DAMAGE_TYPE_PHYSICAL
                }

                ApplyDamage(dmgTable)
            end
        }

        Projectiles:CreateProjectile(projectile)
    end

    

    
     
end