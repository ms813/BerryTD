function Spawn(keys)
	Timers:CreateTimer(0.5, function()
		return HiveThink(thisEntity)
	end)
end

function HiveThink(creep)
	--stop timer if creep is dead
	if creep:IsNull() or not creep:IsAlive() then
		return nil
	end

	local lay_egg = creep:FindAbilityByName("ability_creep_hive_lay_egg")
	if lay_egg~= nil and lay_egg:IsCooldownReady() then
		lay_egg:CastAbility()		
	end

	return 0.5
end

function HiveLayEgg(keys)
	local egg = CreateUnitByName(
		"creep_hive_egg",
		keys.caster:GetAbsOrigin() + RandomVector(50),
		true,
		nil,
		nil,
		DOTA_TEAM_BADGUYS)
	
	--set eggs next waypoint to the same as its parent so it can pass it on to the babies
	egg.next_waypoint = keys.caster.next_waypoint	
end