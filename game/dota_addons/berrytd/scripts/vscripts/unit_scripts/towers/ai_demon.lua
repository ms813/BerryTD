require('targetingHelper')

function Spawn(keys)
	print(thisEntity:GetUnitName(), "spawned")
	lvlUpUnitAbilities(thisEntity)
end

function DemonAttack(keys)
	local ab = keys.ability
	local speed = ab:GetLevelSpecialValueFor("speed", ab:GetLevel())
	local range = ab:GetLevelSpecialValueFor("range", ab:GetLevel())
	
	local vel = (keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()):Normalized() * speed
	print(keys.AbilityContext.particle)

	keys.caster.projectile = DemonProj{
		particle = keys.AbilityContext.particle,
		origin = keys.caster:GetAbsOrigin() + Vector(0,0,100),
		dist = range,
		width = ab:GetLevelSpecialValueFor("width", ab:GetLevel()),
		source = keys.caster,
		velocity = vel,
		dmg = ab:GetLevelSpecialValueFor("damage", ab:GetLevel()),
		target = keys.target,
		--pierce = ab:GetLevelSpecialValueFor("pierce", ab:GetLevel())
		pierce = 1
	}

	Projectiles:CreateProjectile(keys.caster.projectile)
end

function DemonProj(args)

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
			if args.pierce > -1 then
				print("Unit hit", unit:GetUnitName())
				--damage the target
				ApplyDamage({
			    	attacker = args.source,
			    	victim = unit,
			    	damage = args.dmg,
			    	damage_type = DAMAGE_TYPE_PHYSICAL
			    })   
			    args.pierce = args.pierce - 1
			end
			if args.pierce < 0 then
				self.UnitBehavior = PROJECTILES_DESTROY
			end
		end,
		--OnTreeHit = function(self, tree) ... end,
		--OnWallHit = function(self, gnvPos) ... end,
		--OnGroundHit = function(self, groundPos) ... end,
		--OnFinish = function(self, pos) ... end,
	}
end