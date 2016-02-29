function Spawn(keys)
	local ab = thisEntity:FindAbilityByName("ability_creep_sergeant")
	local lvl = tonumber(string.sub(thisEntity:GetUnitName(), -1))
	ab:SetLevel(lvl + 1)

	Timers:CreateTimer(1, function()
		return SergeantThink(thisEntity)
	end)
end

function SergeantThink(creep)
	--if creep dies stop the timer
	if creep:IsNull() or not creep:IsAlive() then
		return nil
	end

	local ab = thisEntity:FindAbilityByName("ability_creep_sergeant")
	if ab ~= nil and ab:IsCooldownReady() then
		ab:CastAbility()
	end

	return 0.5
end

--purge units in aoe
function CreepSergeantPurge(keys)	
	local ab = keys.ability
	local radius = ab:GetLevelSpecialValueFor("radius", ab:GetLevel() - 1)
	local targets = FindUnitsInRadius(
		keys.caster:GetTeamNumber(), 
		keys.caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST, 
		false)

	for i,target in pairs(targets) do
		target:Purge(false, true, false, true, false)
	end
end