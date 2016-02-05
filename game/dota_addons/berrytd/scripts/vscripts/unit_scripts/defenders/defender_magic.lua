function Spawn(keys)
	thisEntity.thinker = Timers:CreateTimer(function()
			return DefenderMagicThink(thisEntity)
		end)
end

function DefenderMagicThink(defender)

	--if caster is dead stop the thinker
	if defender:IsNull() or not defender:IsAlive() then
		return nil
	end

	local main_ability = defender:GetAbilityByIndex(0)
	if main_ability:IsCooldownReady() then
		local range = main_ability:GetLevelSpecialValueFor("range", main_ability:GetLevel())
		local targets = FindUnitsInRadius(
			DOTA_TEAM_BADGUYS,
			defender:GetAbsOrigin(),
			nil,
			range,
		    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		    DOTA_UNIT_TARGET_ALL,
		    DOTA_UNIT_TARGET_FLAG_NONE,
		    FIND_CLOSEST,
			false)
		

		if #targets > 0 then			
			defender:CastAbilityOnTarget(targets[1], main_ability, defender:GetPlayerOwnerID())
		end
	end

	return 1
end

DefenderMagic1Particles = {}
DefenderMagic1Particles[1] = "particles/defender_magic/ability_0/white.vpcf"
DefenderMagic1Particles[2] = "particles/neutral_fx/satyr_hellcaller.vpcf"
DefenderMagic1Particles[3] = "particles/defender_magic/ability_0/yellow.vpcf"
DefenderMagic1Particles[4] = "particles/defender_magic/ability_0/orange.vpcf"
DefenderMagic1Particles[5] = "particles/defender_magic/ability_0/red.vpcf"
DefenderMagic1Particles[6] = "particles/defender_magic/ability_0/blue.vpcf"
DefenderMagic1Particles[7] = "particles/defender_magic/ability_0/green.vpcf"
DefenderMagic1Particles[8] = "particles/defender_magic/ability_0/black.vpcf"
function DefenderMagicTrishot(keys)
	local caster = keys.caster
	local caster_pos = GetGroundPosition(caster:GetAbsOrigin(), nil)
	local target = keys.target
	local target_pos = GetGroundPosition(target:GetAbsOrigin(), nil)
	local ability = keys.ability

	local dist = ability:GetLevelSpecialValueFor("range", 1)
	local dmg = ability:GetLevelSpecialValueFor("dmg", 1)
	local width = ability:GetLevelSpecialValueFor("width", 1)
	local speed = ability:GetLevelSpecialValueFor("speed", 1)
	local spread = ability:GetLevelSpecialValueFor("spread", 1)

	local dirs = {}
	dirs[1] = (target_pos - caster_pos):Normalized()

	local perpendicular = Vector(-dirs[1].y, dirs[1].x)
	dirs[2] = (dirs[1]*dist + (perpendicular * spread)):Normalized()
	dirs[3] = (dirs[1]*dist + (perpendicular * -spread)):Normalized()	

	for i=1,3 do		
		local projectile = {	  
			EffectName = DefenderMagic1Particles[math.random(1, 8)],	  
			vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,80),
			fDistance = dist,
			fStartRadius = width,
			fEndRadius = width,
			Source = caster,	  
			vVelocity = dirs[i] * speed,
			UnitBehavior = PROJECTILES_NOTHING,
			bMultipleHits = false,
			bIgnoreSource = true,
			TreeBehavior = PROJECTILES_NOTHING,
			bCutTrees = true,
			bTreeFullCollision = false,
			WallBehavior = PROJECTILES_NOTHING,
			GroundBehavior = PROJECTILES_NOTHING,
			fGroundOffset = 80,	
			bZCheck = false,
			bGroundLock = true,
			draw = false,

			UnitTest = function(self, unit)
				return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber()
			end,
			OnUnitHit = function(self, unit) 			  
			    ApplyDamage({
                    victim = unit,
                    attacker = self.Source,
                    damage = dmg,
                    damage_type = DAMAGE_TYPE_MAGICAL
                })
			end,
			--OnFinish = function(self, pos) ... end,
		}
		Projectiles:CreateProjectile(projectile)
	end
end