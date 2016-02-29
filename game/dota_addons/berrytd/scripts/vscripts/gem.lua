function GemDrop(keys)

	local holder = keys.caster	
	local gem = holder:GetItemInSlot(0)	

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
		
		--start a timer on the gem to return it if it is undisturbed
		gem.reset_timer = Timers:CreateTimer(GameMode.gem_return_timeout, function()
			print("Returning gem")			
			gem:LaunchLoot(false, 300, 1, gem.initial_position)		
			gem.position = gem.initial_position
		end)
	end
end