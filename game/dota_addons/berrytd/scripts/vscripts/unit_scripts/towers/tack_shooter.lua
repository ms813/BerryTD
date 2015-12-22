function launchTacks(keys)

    local caster = keys.caster
    local caster_point = caster:GetOrigin()

    local projectile_distance = keys.ability:GetLevelSpecialValueFor('distance', keys.ability:GetLevel())
    local projectile_radius = keys.ability:GetLevelSpecialValueFor('radius', keys.ability:GetLevel())
    local projectile_speed = keys.ability:GetLevelSpecialValueFor('speed', keys.ability:GetLevel())
    local projectile_damage = keys.ability:GetLevelSpecialValueFor('damage', keys.ability:GetLevel())

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

function tackshooterUpgrade1(keys)
    local caster = keys.caster
    local shoot_tacks = caster:FindAbilityByName("ability_shoot_tacks")

    if shoot_tacks ~= nil then
        shoot_tacks:SetLevel(2)        
        print("level", shoot_tacks:GetLevel())
    end
end

function tackshooterUpgrade2(keys)
    local caster = keys.caster
    caster.fire16Ways = true   
end