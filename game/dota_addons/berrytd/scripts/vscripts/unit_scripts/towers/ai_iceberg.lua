function Spawn(entityKeyValues)
	for i = 0, thisEntity:GetAbilityCount()-1 do
    	local a = thisEntity:GetAbilityByIndex(i)

    	if a ~= nil then
      	a:SetLevel(1)
  		end
	end

	Timers:CreateTimer(function()
			return IcebergThink(thisEntity)
		end)
end

function IcebergThink(tower)
	--stop the timer if we sell the tower
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local iceberg_aoe_slow = tower:FindAbilityByName("ability_iceberg_aoe_slow")

	if iceberg_aoe_slow ~= nil then
		if iceberg_aoe_slow:GetCooldownTimeRemaining() > 0.0 then
			return iceberg_aoe_slow:GetCooldownTimeRemaining()
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

		if #targets > 0 then
			iceberg_aoe_slow:CastAbility()
		end
	end

	return 0.5
end

function icebergUpgrade1(keys)
	local iceberg_aoe_slow = keys.caster:FindAbilityByName("ability_iceberg_aoe_slow")
	if iceberg_aoe_slow ~= nil then
		iceberg_aoe_slow:SetLevel(2)
	end
end

function icebergUpgrade2(keys)
	local iceberg_aoe_slow = keys.caster:FindAbilityByName("ability_iceberg_aoe_slow")
	if iceberg_aoe_slow ~= nil then
		iceberg_aoe_slow:SetLevel(3)
	end
end
