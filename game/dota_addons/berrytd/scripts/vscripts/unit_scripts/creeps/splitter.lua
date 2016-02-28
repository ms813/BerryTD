function Spawn(keys)	
	local split_ab = thisEntity:FindAbilityByName("ability_creep_splitter_split")	
	local lvl = string.sub(thisEntity:GetUnitName(), -1)	

	split_ab:SetLevel(tonumber(lvl))
end

function Split(keys)	
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
				shard:SetInitialGoalEntity(Entities:FindByName(nil, "gem_spawner"))
			end

			--increase the total number of creeps for this wave and update the quest counter
			GameMode.numCreepsAlive = GameMode.numCreepsAlive + 1
			GameMode.Quest.max_creeps = GameMode.Quest.max_creeps + 1
			GameMode.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, GameMode.creep_kills)
			GameMode.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, GameMode.Quest.max_creeps)
			GameMode.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, GameMode.creep_kills)
			GameMode.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, GameMode.Quest.max_creeps)	        							
		end
	end
end