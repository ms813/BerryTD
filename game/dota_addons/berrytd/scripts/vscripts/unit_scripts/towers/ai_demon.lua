require('targetingHelper')

function Spawn(keys)
	lvlUpUnitAbilities(thisEntity)
	thisEntity.spear_count = 1

	Timers:CreateTimer(0.5, function()
		return DemonThink(thisEntity)
	end)
end

function DemonThink(tower)
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local ab = tower:GetAbilityByIndex(1)
	
	if ab ~= nil and ab:IsCooldownReady() then
		local targeting_range = ab:GetLevelSpecialValueFor("targeting_range", ab:GetLevel())
		local targets = TargetingHelper.FindDireInRadius(tower, targeting_range)

		if #targets > 0 then
			tower:CastAbilityOnTarget(targets[1], ab, tower:GetPlayerOwnerID())
		end
	end

	return 0.5
end

function DemonAttack(keys)
	local ab = keys.ability
	local speed = ab:GetLevelSpecialValueFor("speed", ab:GetLevel())
	local range = ab:GetLevelSpecialValueFor("range", ab:GetLevel())	
	
	local origin = {}
	local vel = (keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()):Normalized() * speed
	if keys.caster.spear_count == 1 or keys.caster.spear_count == 5 then
		
		origin[1] = keys.caster:GetAbsOrigin() + Vector(0,0,100)
	elseif keys.caster.spear_count == 2 then
		local dir = (keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()):Normalized()
		local perp = Vector(-dir.y, dir.x, 0)
		local offset_dist = 25
		local offset = perp * offset_dist
		origin[1] = keys.caster:GetAbsOrigin() + offset
		origin[2] = keys.caster:GetAbsOrigin() - offset
	end

	if keys.caster.spear_count == 5 then
		local dir = (keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()):Normalized()
		local perp = Vector(-dir.y, dir.x, 0)
		local offset_dist = 15
		local offset = perp * offset_dist		
		origin[2] = keys.caster:GetAbsOrigin() - offset
		origin[3] = keys.caster:GetAbsOrigin() + offset
		origin[4] = keys.caster:GetAbsOrigin() - 2*offset
		origin[5] = keys.caster:GetAbsOrigin() + 2*offset
	end

	if keys.caster.bounce then	
		for i=1, #origin do
			DemonTrackingProj{
				target = keys.target,
				source = keys.caster,
				ability = ab,
				particle = keys.AbilityContext.particle,
				speed = speed,
				origin = keys.caster:GetAbsOrigin()
			}						
		end
		keys.caster.max_pierce = ab:GetLevelSpecialValueFor("pierce", ab:GetLevel()) * #origin
		keys.caster.pierce = keys.caster.max_pierce
	else
		for i=1,#origin do
			keys.caster.projectile = DemonLinearProj{
				particle = keys.AbilityContext.particle,
				origin = origin[i],
				dist = range,
				width = ab:GetLevelSpecialValueFor("width", ab:GetLevel()),
				source = keys.caster,
				velocity = vel,
				dmg = ab:GetLevelSpecialValueFor("damage", ab:GetLevel()),
				target = keys.target,
				pierce = ab:GetLevelSpecialValueFor("pierce", ab:GetLevel())
			}		
			Projectiles:CreateProjectile(keys.caster.projectile)
		end		
	end
end

function DemonOnBounce(keys)

	if keys.caster.prev_target == nil then
		keys.caster.prev_target = keys.target
	end

	if keys.caster.pierce == keys.caster.max_pierce then
		keys.caster.prev_target = keys.target
	end

	keys.caster.pierce = keys.caster.pierce - 1	
    if keys.caster.pierce > 0 then   	    
		local targets = TargetingHelper.FindDireInRadius(keys.caster.prev_target, 500)    	
		
    	--find the nearest target without a low bounce priority modifier
    	local new_target = keys.caster.prev_target
    	if #targets > 1 then    
    		--choose a random target that is not the current target
    		--i.e. can't hit same target twice in a row			    
    		while new_target == keys.caster.prev_target do
    			new_target = targets[math.random(1, #targets)]
    		end	    	
	    end
    	
    	if new_target ~= nil then    		
    		local ab = keys.ability
    		DemonTrackingProj{
				target = new_target,
				source = keys.caster.prev_target,
				ability = ab,
				particle = "",
				speed = ab:GetLevelSpecialValueFor("speed",ab:GetLevel())				
			}			
		keys.caster.prev_target = new_target					
    	end 	    	   	    			
    end
end

function DemonTrackingProj(args)
	--[[
		args = {
			target = entity,
			source = entity,
			ability = ability,
			particle = string,
			speed = int,
			origin = Vector
		}
	]]
	local proj =   
	{
		Target = args.target,
		Source = args.source,
		Ability = args.ability,	
		--EffectName = args.particle,
		EffectName = "particles/econ/items/bounty_hunter/bounty_hunter_shuriken_creeper/bounty_hunter_suriken_toss_creepers_cruel.vpcf",
	    iMoveSpeed = args.speed		
	}
	ProjectileManager:CreateTrackingProjectile(proj)
end

function DemonLinearProj(args)

	--[[
		args = {
			particle = string,
			origin = Vector,
			dist = int,
			width = int,
			source = entity,
			velocity = Vector,
			dmg = int,
			target = entity,
			pierce = int
		}
	]]

	return {
		EffectName = args.particle,			
		vSpawnOrigin = args.origin,
		fDistance = args.dist,
		fStartRadius = args.width,
		fEndRadius = args.width,
		Source = args.source,		  
		vVelocity = args.velocity,
		UnitBehavior = PROJECTILES_NOTHING,
		bMultipleHits = false,
		bIgnoreSource = true,
		TreeBehavior = PROJECTILES_NOTHING,
		bCutTrees = false,
		bTreeFullCollision = false,
		WallBehavior = PROJECTILES_NOTHING,
		GroundBehavior = PROJECTILES_NOTHING,
		fGroundOffset = 80,	
		bZCheck = false,
		bGroundLock = true,
		bProvidesVision = false,
		draw = true,		
		ControlPoints = {[1]=args.target:GetAbsOrigin()},
        UnitTest = function(self, unit)
        	return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= args.source:GetTeamNumber()
        end,
		OnUnitHit = function(self, unit)
			if args.pierce > 0 then
				--damage the target
				ApplyDamage({
			    	attacker = args.source,
			    	victim = unit,
			    	damage = args.dmg,
			    	damage_type = DAMAGE_TYPE_PHYSICAL
			    })   
			    args.pierce = args.pierce - 1			   
			end

			if args.pierce <= 0 then
				self:Destroy()
			end
		end,
		--OnTreeHit = function(self, tree) ... end,
		--OnWallHit = function(self, gnvPos) ... end,
		--OnGroundHit = function(self, groundPos) ... end,
		--OnFinish = function(self, pos) ... end,
	}
end

function DemonUpgradeSpearCount(keys)
	keys.caster.spear_count = keys.SpearCount
end

function DemonUpgradeBounce(keys)
	keys.caster.bounce = true
end