require ("targetingHelper")

function Spawn(keys)
	print("Soul siphon spawned", thisEntity)	

	--add this to the model's position to lift it above the ground
	local z_offset = Vector(0, 0, 250)

	lvlUpUnitAbilities(thisEntity)

	Timers:CreateTimer(0.001, function()
		local pos = thisEntity:GetAbsOrigin()
		thisEntity:SetAbsOrigin(pos + z_offset)	
				
	end)	

	Timers:CreateTimer(0.5, function()		
		return SoulSiphonThink(thisEntity)
	end)	

	--slowly rotate the skull
	local period = 20
	Timers:CreateTimer(0.1, function()
		local angle = thisEntity:GetAngles()
		thisEntity:SetAngles(angle.x, angle.y + period * FrameTime(), angle.z)
		if not thisEntity:IsNull() then
			return FrameTime()
		end
	end)
end

function SoulSiphonThink(tower)	
	local ability = tower:GetAbilityByIndex(1)
	local range = ability:GetLevelSpecialValueFor("range", ability:GetLevel())
	
	if not tower:IsAlive() or tower:IsNull() then
		return nil
	end

	if ability ~= nil and ability:IsCooldownReady() then
		local targets = TargetingHelper.FindDireInRadius(thisEntity, range)
		if #targets > 0 then	
			ability:CastAbility()
			return 0.5		
		end
	end

	return 0.5
end

function SoulSiphonDrain(keys)
	local ab_level = keys.ability:GetLevel()
	local range = keys.ability:GetLevelSpecialValueFor("range", ab_level)
	local max_targets = keys.ability:GetLevelSpecialValueFor("max_targets", ab_level-1)
	
	local targets = TargetingHelper.FindDireInRadius(keys.caster, range)

	--shoot at as many targets as we can
	local target_count = #targets
	if target_count > max_targets then
		target_count = max_targets
	end
	
	if target_count > 0 then
		for i=1, target_count do
			SoulSiphonProjectile{
				target = targets[i],
				caster = keys.caster,
				ability = keys.ability,
				particle = keys.AbilityContext.particle,
				speed = keys.ability:GetLevelSpecialValueFor("projectile_speed", keys.ability:GetLevel())
			}	
		end	
	end
end

function SoulSiphonReturn(keys)		
	
	if keys.caster ~= keys.target then	
		SoulSiphonProjectile{
			target = keys.caster,
			caster = keys.target,
			ability = keys.ability,
			particle = keys.AbilityContext.particle,
			speed = keys.ability:GetLevelSpecialValueFor("projectile_speed", keys.ability:GetLevel())
		}

		ApplyDamage({
			attacker = keys.caster,
			victim = keys.target,
			damage = keys.ability:GetLevelSpecialValueFor("damage", keys.ability:GetLevel()),
			damage_type = DAMAGE_TYPE_MAGICAL
		})
	end
end

function SoulSiphonProjectile(args) 
	local projectile = 
	{
		Target = args.target,
		Source = args.caster,
		Ability = args.ability,
		EffectName = args.particle,
        iMoveSpeed = args.speed	
	}

	ProjectileManager:CreateTrackingProjectile(projectile)
end