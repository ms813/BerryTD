function Spawn(keys)
	thisEntity.thinker = Timers:CreateTimer(function()
			return DefenderMagicThink(thisEntity)
		end)
end

function DefenderMagicThink(defender)
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
			print("firing ability")
			defender:CastAbilityOnTarget(targets[1], main_ability, defender:GetPlayerOwnerID())
		end
	end

	return 1
end