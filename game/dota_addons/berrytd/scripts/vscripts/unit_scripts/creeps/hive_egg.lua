function Spawn(keys)
	local ab = thisEntity:FindAbilityByName("ability_creep_hive_egg_hatch")

	--put the egg's hatch ability on cooldown
	local hatch = thisEntity:FindAbilityByName("ability_creep_hive_egg_hatch")
	local cd = hatch:GetCooldown(hatch:GetLevel()) 
	print("cooldown", cd)
	hatch:StartCooldown(cd)

	Timers:CreateTimer(0.1, function()

		thisEntity.attacks_to_destroy = ab:GetLevelSpecialValueFor("attacks_to_destroy", ab:GetLevel() - 1 )

		if ab:IsCooldownReady() then
			ab:CastAbility()			
			return nil
		else
			return 0.1
		end
	end)
end

function HiveEggHatch(keys)
	local ab = keys.ability
	local babies = ab:GetLevelSpecialValueFor("babies", ab:GetLevel() - 1)
	local next_waypoint = keys.caster.next_waypoint
	for i = 0, babies do
		local baby = CreateUnitByName(
		"creep_hive_baby",
		keys.caster:GetAbsOrigin() + RandomVector(50),
		true,
		keys.caster:GetOwner(),
		keys.caster:GetOwner(),
		DOTA_TEAM_BADGUYS)

		--set the babies next waypoint
		if next_waypoint ~= nil then
			baby:SetInitialGoalEntity(next_waypoint)
		else
			baby:SetInitialGoalEntity(Entities:FindByName(nil, "dota_goodguys_fort"))
		end		
	end

	--force kill the egg	
	keys.caster:AddNoDraw()
	local particle = "particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf"
	ParticleManager:CreateParticle(particle,PATTACH_ABSORIGIN,keys.caster)
	for i=1, keys.caster.attacks_to_destroy do
		keys.caster:ForceKill(false)
	end
end