--[[
	The wave table is the data structure that contains details of what waves are 
	made up of.

	Each wave has a bonus for completing it "bonusEndGold"
	
	Each wave also has a list of creepGroups that detail a group of creeps

	Each creepGroup lists the creep name, total number and details if they will
	spawn clumped together or spread apart (spawnGroupSize and spawnGroupInterval)

	All creepGroups start spawning at the same time, so in order to stagger them,
	a spawnDelay must be specified

  ]]

function CreateCreepGroup(creep, numTotal, spawnDelay, groupSize, groupInterval)
	local cg = {}
	cg.creep = creep
	cg.numTotal = numTotal
	cg.spawnDelay = spawnDelay
	cg.spawnGroupSize = groupSize
	cg.spawnGroupInterval = groupInterval
	return cg	
end

--initialise an empty list of waves
waveTable = {}

--[[
	GameMode.debug lives in GameMode:InitGameMode() near line ~158
	Switch it to true when debugging, put it on false when designing balance for launch
]]
if GameMode.debug then
	--put waves used in testing here
	waveTable[1] = {
		bonusEndGold = 50,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 10, 0, 1, 3),		
		}	
	}

else
	--put waves used in production here

	--[[
		WAVE 1
		10 warrior creeps one a time

		Easy intro
	]]
	waveTable[1] = {
		bonusEndGold = 50,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 10, 0, 1, 3)	
		}	
	}

	--[[
		WAVE 2
		12 warrior creeps in groups of 3

		Still easy but highlighting creeps can come bunched together
	]]
	waveTable[2] = {
		bonusEndGold = 50,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 12, 0, 3, 3)
		}	
	}	

	--[[
		WAVE 3
		8 warriors,	8 archers, come in pairs

		Archers sit behind warriors and kill defenders
		Demonstrate early multiple creep types per wave
	]]
	waveTable[3] = {
		bonusEndGold = 50,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 8, 0, 1, 4),
			CreateCreepGroup("creep_archer_0", 8, 0, 1, 4)
		}	
	}

	--[[
		WAVE 4
		10 sprinter creeps, spaced well apart

		Sprinters move fast and ignore defenders, let player understand that units
		can ignore defenders early
	]]
	waveTable[4] = {
		bonusEndGold = 50,
		creepGroups = {					
			CreateCreepGroup("creep_sprinter_0", 10, 0, 1, 4)
		}	
	}

	--[[
		WAVE 5
		12 warriors, 12 archers, come in groups of 4
		1 knight

		Larger groups to try and punch through
		Mini-boss knight at the end (should be quite tough at this stage)
	]]
	waveTable[5] = {
		bonusEndGold = 50,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 12, 0, 2, 5),
			CreateCreepGroup("creep_archer_0", 12, 0, 2, 5),
			CreateCreepGroup("creep_knight_0", 1, 35, 1, 1)
		}	
	}

	--[[
		WAVE 6
		100 critters

		Really weak but need AoE
	]]
	waveTable[6] = {
		bonusEndGold = 50,
		creepGroups = {					
			CreateCreepGroup("creep_critter_0", 100, 0, 4, 2),			
		}	
	}

end