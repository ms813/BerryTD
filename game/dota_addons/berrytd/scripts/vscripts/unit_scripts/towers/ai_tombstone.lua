require('targetingHelper')

function Spawn(keys)	
	Timers:CreateTimer(0.5, function()
		return TombstoneThink(thisEntity)
	end)
end

function TombstoneThink(tower)
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local ability = tower:GetAbilityByIndex(1)
	local range = ability:GetLevelSpecialValueFor("range",ability:GetLevel())

	local targets = TargetingHelper.FindDireInRadius(tower, range)

	if #targets > 0 then
		if ability:IsCooldownReady() then
			tower:CastAbilityOnTarget(targets[1], ability, tower:GetPlayerOwnerID())
		end
	end

	return 0.5
end

function TombstoneDecay(keys)
	local ab = keys.ability
	local dist = ab:GetLevelSpecialValueFor("range", ab:GetLevel())
	local width = ab:GetLevelSpecialValueFor("width", ab:GetLevel())
	local tick = ab:GetLevelSpecialValueFor("tick", ab:GetLevel())
	local dmg = ab:GetLevelSpecialValueFor("damage", ab:GetLevel())
	local speed = ab:GetLevelSpecialValueFor("speed", ab:GetLevel())
	local caster = keys.caster
	local mod_name = keys.AbilityContext.modifier

	local dir = (keys.target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	
	local projectile = {
		EffectName = keys.AbilityContext.particle,			
		vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,80),
		fDistance = dist,
		fStartRadius = width,
		fEndRadius = width,
		Source = caster,		  
		vVelocity = dir * speed, -- RandomVector(1000),
		UnitBehavior = PROJECTILES_NOTHING,
		bMultipleHits = true,
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
		draw = false,		
		iVelocityCP = 1,		
		fRehitDelay = tick,
        UnitTest = function(self, unit)
        	return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber()
        end,
		OnUnitHit = function(self, unit)
			--damage the target
			ApplyDamage({
		    	attacker = caster,
		    	victim = unit,
		    	damage = dmg,
		    	damage_type = DAMAGE_TYPE_MAGICAL
		    })
		    --apply a slow
		    if not unit:HasModifier(mod_name) then
		    	ab:ApplyDataDrivenModifier(caster, unit, mod_name, {})
		    end
		    --emit the decay sound
			EmitSoundOn(keys.AbilityContext.sound, unit)
		end,
		--OnTreeHit = function(self, tree) ... end,
		--OnWallHit = function(self, gnvPos) ... end,
		--OnGroundHit = function(self, groundPos) ... end,
		--OnFinish = function(self, pos) ... end,
	}

	Projectiles:CreateProjectile(projectile)
end