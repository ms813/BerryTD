TackshooterHelper = {}
TackshooterHelper.directions_8 = 
{
    --Vector(x, y, z)
    E = Vector( 1,  0,  0):Normalized(),  --E
    SE = Vector( 1,  1,  0):Normalized(),  --SE
    S = Vector( 0,  1,  0):Normalized(),  --S
    SW = Vector(-1,  1,  0):Normalized(),  --SW
    W = Vector(-1,  0,  0):Normalized(),  --W
    NW = Vector(-1, -1,  0):Normalized(),  --NW
    N = Vector( 0, -1,  0):Normalized(),  --N
    NE = Vector( 1, -1,  0):Normalized()   --NE
}

TackshooterHelper.directions_16 = 
{
    SEE = Vector( 2.415,  1,  0):Normalized(),  --SEE
    SSE = Vector( 1,  2.415,  0):Normalized(),  --SSE
    SSW = Vector(-1,  2.415,  0):Normalized(),  --SSW
    SWW = Vector(-2.415,  1,  0):Normalized(),  --SWW
    NWW = Vector(-2.415, -1,  0):Normalized(),  --NWW
    NNW = Vector(-1, -2.415,  0):Normalized(),  --NNW
    NNE = Vector( 1, -2.415,  0):Normalized(),  --NNE
    NEE = Vector( 2.415, -1,  0):Normalized()   --NEE
}

function Spawn(entityKeyValues)	

	lvlUpUnitAbilities(thisEntity)

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
        
    --for upgrade 5 a different ability is granted
    if shoot_tacks == nil then
        shoot_tacks = tower:FindAbilityByName("ability_ring_of_poison")
    end

	if shoot_tacks ~= nil then
		if shoot_tacks:GetCooldownTimeRemaining() > 0.0 then
			return shoot_tacks:GetCooldownTimeRemaining()
		end

		local targets = FindUnitsInRadius(
					DOTA_TEAM_BADGUYS,
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

    tackshooterFire{
        source = caster,
        dmg = projectile_damage,
        dist = projectile_distance,
        radius = projectile_radius,
        speed = projectile_speed,
        particle = projectile_particle,
        dirs = TackshooterHelper.directions_8,
        IsChild = false
    }
    
    if caster.fire16Ways == true then
        tackshooterFire{
            source = caster,
            dmg = projectile_damage,
            dist = projectile_distance,
            radius = projectile_radius,
            speed = projectile_speed,
            particle = projectile_particle,
            dirs = TackshooterHelper.directions_16,
            IsChild = false
        }
    end
       
end

function tackshooterFire(args)
    --source, dmg, dist, radius, speed, particle, dirs

    if not args.source_pos then 
        args.source_pos = args.source:GetAbsOrigin()
    end

    for k, dir in pairs(args.dirs) do
        local projectile = {
            bGroundLock = true,
            fGroundOffset = 80,
            bZCheck = false,
            bIgnoreSource = true,
            draw = false, --{rad = projectile_radius}
            EffectName = args.particle,
            fDistance = args.dist,
            fStartRadius = args.radius,
            fEndRadius = args.radius,
            Source = args.source,            
            vSpawnOrigin = args.source_pos,
            vVelocity = dir * args.speed,
            WallBehavior = PROJECTILES_NOTHING,
            TreeBehavior = PROJECTILES_NOTHING,
            UnitBehavior = PROJECTILES_DESTROY,

            UnitTest = function(self, unit)
                return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= args.source:GetTeamNumber()
            end,
            OnUnitHit = function(self, unit)
            --print("hit unit", unit:GetUnitName())
                local dmgTable = {
                    victim = unit,
                    attacker = self.Source,
                    damage = args.dmg,
                    damage_type = DAMAGE_TYPE_PHYSICAL
                }

                ApplyDamage(dmgTable)
            end,

            OnFinish = function(self, position)
                if args.source.split ~= nil and not args.IsChild then
                    tackshooterFireSplit(args.source, position)
                end
               self:Destroy() 
            end
        }

        Projectiles:CreateProjectile(projectile)
    end 
end

function tackshooterFireSplit(caster, position)
    --source, dmg, dist, radius, speed, particle, dirs
    tackshooterFire{
        source = caster, 
        source_pos = position,    
        dmg = caster.split.damage,
        dist = caster.split.distance,
        radius = caster.split.radius,
        speed = caster.split.speed,
        particle = "particles/frostivus_gameplay/drow_linear_arrow.vpcf",
        IsChild = true,
        dirs = {
            TackshooterHelper.directions_8.NE,
            TackshooterHelper.directions_8.SE,
            TackshooterHelper.directions_8.NW,
            TackshooterHelper.directions_8.SW,
        }
    }    
end

function tackshooterSet16(keys)    
    keys.caster.fire16Ways = true   
end

function tackshooterSetSplit(keys)   
    keys.caster.split = {}
    keys.caster.split.radius = keys.ability:GetLevelSpecialValueFor("split_radius", 1)
    keys.caster.split.damage = keys.ability:GetLevelSpecialValueFor("split_dmg", 1)
    keys.caster.split.distance = keys.ability:GetLevelSpecialValueFor("split_dist", 1)
    keys.caster.split.speed = keys.ability:GetLevelSpecialValueFor("split_speed", 1)
end

function tackshooterPoison(keys)
    local caster = keys.caster
    caster:RemoveAbility(keys.AbilityContext.old_ability)
    local new_ab = caster:AddAbility(keys.AbilityContext.new_ability)
    new_ab:SetLevel(1)
end

function tackshooterAddPoisonStack(keys)
    local caster = keys.caster
    local target = keys.target
    local modifier = keys.AbilityContext.modifier
    local ab = keys.ability

    if target:HasModifier(modifier) then
        local stack_count = target:GetModifierStackCount(modifier, ab)
        target:SetModifierStackCount(modifier, ab, stack_count + 1)
    else
        ab:ApplyDataDrivenModifier(caster, target, modifier, {})
        target:SetModifierStackCount(modifier, ab, 1)
    end
end

function tackshooterPoisonTick(keys)  
    local modifier = keys.AbilityContext.modifier
    local poison_stacks = keys.target:GetModifierStackCount(modifier,ab)

    local tick_dmg = keys.ability:GetLevelSpecialValueFor("tick_dmg", 1)
    local dmg = tick_dmg * math.pow(2, poison_stacks - 1)

    ApplyDamage({
        victim = keys.target,
        attacker = keys.caster,
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL
    })
end