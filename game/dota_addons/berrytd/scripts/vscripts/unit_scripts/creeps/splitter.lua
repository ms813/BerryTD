function Spawn(keys)	
	local split_ab = thisEntity:FindAbilityByName("ability_creep_splitter_split")	
	local lvl = string.sub(thisEntity:GetUnitName(), -1)	

	split_ab:SetLevel(tonumber(lvl))
end

function Split(keys)
	print("splitting")
	local ab = keys.ability
	local split_count = ab:GetLevelSpecialValueFor("splits", ab:GetLevel() - 1)
	local next_waypoint = keys.caster.next_waypoint
	
	for i=1, 2 do
		if split_count > 0 then
			local shard = CreateUnitByName(
				"creep_splitter_"..(split_count - 1),
				keys.caster:GetAbsOrigin() + RandomVector(200),
				true,
				nil,
				nil,
				DOTA_TEAM_BADGUYS) 

			
			if next_waypoint ~= nil then
				shard:SetInitialGoalEntity(next_waypoint)
			else
				shard:SetInitialGoalEntity(Entities:FindByName(nil, "dota_goodguys_fort"))
			end
		end
	end
end