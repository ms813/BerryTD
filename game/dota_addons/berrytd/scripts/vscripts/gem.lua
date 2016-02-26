function GemDrop(keys)

	local holder = keys.caster	
	local gem = holder:GetItemInSlot(0)
	local return_timeout = keys.ability:GetLevelSpecialValueFor("return_timeout", 1)

	local waypoint = holder.last_waypoint
	local w_name = nil
	if holder.last_waypoint ~= nil then
		w_name = holder.last_waypoint:GetName()
	end	
	
	--drop the gem on death, but not if the creep is escaping	
	local last_waypoint = "creep_waypoint_reverse_"..#GameMode.WAYPOINTS - 1
	if gem ~= nil and w_name ~= last_waypoint then		
		holder:DropItemAtPositionImmediate(gem, holder:GetAbsOrigin())
		gem.pickedUp = false
		gem.position = holder:GetAbsOrigin()	

		local dummy = CreateUnitByName(
			"npc_dummy_unit", 
			holder:GetAbsOrigin(), 
			false, 
			nil, 
			nil, 
			DOTA_TEAM_NEUTRALS)

		local speech_duration = 5
		dummy:AddSpeechBubble(0, "Gem will return in "..return_timeout.." seconds", speech_duration, 0, 0)

		Timers:CreateTimer(speech_duration, function()
			dummy:ForceKill(false)
		end)
		--start a timer on the gem
		gem.reset_timer = Timers:CreateTimer(return_timeout, function()
			print("Returning gem")			
			gem:LaunchLoot(false, 300, 1, gem.initial_position)		
			gem.position = gem.initial_position
		end)
	end
end