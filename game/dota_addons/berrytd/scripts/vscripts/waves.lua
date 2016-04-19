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

--initialise an empty list of waves
waveTable = {}

--set this to false when working on production waves
waveTable.debug = true

function CreateCreepGroup(creep, numTotal, spawnDelay, groupSize, groupInterval)
	local cg = {}
	cg.creep = creep
	cg.numTotal = numTotal
	cg.spawnDelay = spawnDelay
	cg.spawnGroupSize = groupSize
	cg.spawnGroupInterval = groupInterval
	return cg	
end

if waveTable.debug then
	--put waves used in testing here
	waveTable[1] = {
		bonusEndGold = 50,
		creepGroups = {			
			CreateCreepGroup("boss_golem_summoner", 2, 0, 2, 0),	
			CreateCreepGroup("boss_golem", 1, 1, 1, 0),						
			CreateCreepGroup("boss_golem_summoner", 2, 2, 2, 0),	
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
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 8, 0, 1, 3)	
		}	
	}

	--[[
		WAVE 2
		12 warrior creeps in groups of 3

		Still easy but highlighting creeps can come bunched together
	]]
	waveTable[2] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 10, 0, 3, 3)
		}	
	}	

	--[[
		WAVE 3
		8 warriors,	8 archers, come in alternating pairs

		Archers sit behind warriors and kill defenders
		Demonstrate early multiple creep types per wave
	]]
	waveTable[3] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 16, 0, 2, 3),
			CreateCreepGroup("creep_archer_0", 16, 2, 2, 3)
		}	
	}

	--[[
		WAVE 4
		10 sprinter creeps, spaced well apart

		Sprinters move fast and ignore defenders, let player understand that units
		can ignore defenders early
	]]
	waveTable[4] = {
		bonusEndGold = 200,
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
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 12, 0, 2, 5),
			CreateCreepGroup("creep_archer_0", 12, 0, 2, 5),
			CreateCreepGroup("creep_knight_0", 1, 30, 1, 1)
		}	
	}

	--[[
		WAVE 6
		100 critters

		Really weak but need AoE
	]]
	waveTable[6] = {
		bonusEndGold = 150,
		creepGroups = {					
			CreateCreepGroup("creep_critter_0", 50, 0, 5, 1),			
		}	
	}

	--[[
		WAVE 7
		Sprinters and warriors staggered		
	]]
	waveTable[7] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_sprinter_0", 18, 0, 2, 2),			
			CreateCreepGroup("creep_warrior_0", 27, 1, 3, 2),			
		}	
	}

	--[[
		WAVE 8
		Groups of 2 warriors surrounded by 3 archers on each side
		Trying to break through defenders
	]]
	waveTable[8] = {
		bonusEndGold = 200,
		creepGroups = {		
			CreateCreepGroup("creep_archer_0", 20, 0, 3, 3),			
			CreateCreepGroup("creep_warrior_1", 12, 0.5, 2, 3),								
			CreateCreepGroup("creep_archer_0", 20, 1, 3, 3),
		}	
	}

	--[[
		WAVE 9
		Warrior rush wave
	]]
	waveTable[9] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 20, 0, 5, 1),
			CreateCreepGroup("creep_warrior_1", 10, 0, 5, 1),								
		}	
	}

	--[[
		WAVE 10
		Placeholder boss wave
	]]
	waveTable[10] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("boss_golem_summoner", 2, 0, 2, 0),	
			CreateCreepGroup("boss_golem", 1, 1.5, 1, 0),						
			CreateCreepGroup("boss_golem_summoner", 2, 3, 2, 0),		
		}	
	}

	--[[
		WAVE 11
		Simple healer wave, surrounded by warriors
	]]
	waveTable[11] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 20, 0, 2, 3),								
			CreateCreepGroup("creep_healer_0", 10, 0.5, 1, 3),								
			CreateCreepGroup("creep_warrior_0", 20, 1.0, 2, 3),								
		}	
	}

	--[[
		WAVE 12
		Healer with archers and warriors
	]]
	waveTable[12] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_warrior_0", 10, 0, 2, 3),								
			CreateCreepGroup("creep_healer_0", 10, 0.5, 1, 3),								
			CreateCreepGroup("creep_archer_0", 30, 1.0, 3, 3),								
		}	
	}

	--[[
		WAVE 13
		Knights
	]]
	waveTable[13] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_knight_0", 10, 0, 1, 3),										
		}	
	}

	--[[
		WAVE 14
		Knights surrounded by warriors
	]]
	waveTable[14] = {
		bonusEndGold = 200,
		creepGroups = {							
			CreateCreepGroup("creep_warrior_0", 16, 0, 2, 4),	
			CreateCreepGroup("creep_knight_0", 8, 0.5, 1, 4),										
			CreateCreepGroup("creep_warrior_0", 16, 1, 2, 4),	
		}	
	}

	--[[
		WAVE 15
		Mini boss
		Zealot + saint
		This should be balanced so that it is quite hard when faced,
		but so that there can be waves of these later
	]]
	waveTable[15] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_zealot_0", 1, 0, 1, 1),		
			CreateCreepGroup("creep_saint_0", 1, 0.5, 1, 1),					
		}	
	}

	--[[
		WAVE 16
		Splitters
		note: splitter_2 -> 2x splitter_1 -> 2x splitter_0
	]]
	waveTable[16] = {
		bonusEndGold = 200,
		creepGroups = {							
			CreateCreepGroup("creep_splitter_2", 5, 0, 1, 5),										
		}	
	}

	--[[
		WAVE 17
		Knights, archers, healers
	]]
	waveTable[17] = {
		bonusEndGold = 200,
		creepGroups = {							
			CreateCreepGroup("creep_knight_0", 10, 0, 1, 4),	
			CreateCreepGroup("creep_healer_0", 10, 0.25, 1, 4),										
			CreateCreepGroup("creep_archer_0", 40, 0.5, 4, 4),	
		}	
	}

	--[[
		WAVE 18
		Splitters surrounded by archers
	]]
	waveTable[18] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_archer_0", 15, 0, 3, 4),		
			CreateCreepGroup("creep_splitter_2", 5, 0.5, 1, 4),										
			CreateCreepGroup("creep_archer_0", 15, 1, 3, 4),		
		}	
	}

	--[[
		WAVE 19
		Sprinters + healers
	]]
	waveTable[19] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_sprinter_0", 24, 0, 3, 4),	
			CreateCreepGroup("creep_healer_0", 10, 0.5, 1, 4),									
			CreateCreepGroup("creep_sprinter_0", 30, 1, 3, 4),					
		}	
	}	

	--[[
		WAVE 20
		Placeholder boss wave
	]]
	waveTable[20] = {
		bonusEndGold = 200,
		creepGroups = {					
			CreateCreepGroup("creep_knight_1", 1, 0, 1, 1),								
		}	
	}

	--[[
		WAVE 21
		Ninjas (invisible!)
	]]
	waveTable[21] = {
		bonusEndGold = 50,
		creepGroups = {					
			CreateCreepGroup("creep_ninja_0", 12, 0, 1, 1),								
		}	
	}
end