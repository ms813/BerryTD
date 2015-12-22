function Spawn(entityKeyValues)	

	print("start origin", thisEntity:GetAbsOrigin())
	local newpos = thisEntity:GetAbsOrigin() + Vector(0,0, 1000)
	print("newpos", newpos)

	thisEntity:MoveToPosition(newpos)

	print("new abs origin", thisEntity:GetAbsOrigin())

	

	Timers:CreateTimer(function()
			return TackShooterThink(thisEntity)
		end)

	print("Tackshooter tower AI initiated")
end

function TackShooterThink(tower)

	--stop the timer if we sell the tower
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local shoot_tacks = tower:FindAbilityByName("ability_shoot_tacks")

	if shoot_tacks ~= nil then
		if shoot_tacks:GetCooldownTimeRemaining() > 0.0 then
			return shoot_tacks:GetCooldownTimeRemaining()
		end

		local targets = FindUnitsInRadius(
					DOTA_TEAM_NEUTRALS,
					tower:GetAbsOrigin(),
					nil,
					tower:GetAcquisitionRange(), --range of tackshooter ability
					DOTA_UNIT_TARGET_TEAM_FRIENDLY,
					DOTA_UNIT_TARGET_ALL,
					DOTA_DAMAGE_FLAG_NONE,
					FIND_ANY_ORDER,
					false
				)

		for k,v in pairs(targets) do
			print("targets", k, v)
		end

		if #targets > 0 then
			shoot_tacks:CastAbility()
		end
	end

	return 0.5
end