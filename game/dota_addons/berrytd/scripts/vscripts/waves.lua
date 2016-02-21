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


function CreateEmptyWave(bonusEndGold)
	local wave = {}
	wave.bonusEndGold = bonusEndGold
	wave.creepGroups = {}
	return wave
end

function AddCreepGroup(wave, creepGroup)
	wave.creepGroups = wave.creepGroups or {}
	table.insert(wave.creepGroups, creepGroup)	
end

function CreateCreepGroup(creep, numTotal, spawnDelay, groupSize, groupInterval)
	local cg = {}
	cg.creep = creep
	cg.numTotal = numTotal
	cg.spawnDelay = spawnDelay
	cg.spawnGroupSize = groupSize
	cg.spawnGroupInterval = groupInterval

	return cg	
end


function CreepExampleWaveBuilder()
	--make an empty wave with 
	local wave = CreateEmptyWave(100)

	AddCreepGroup(wave, CreateCreepGroup("creep_sheep", 6, 0, 1, 3))
	AddCreepGroup(wave, CreateCreepGroup("creep_geodesic", 2, 3, 2, 1))
	AddCreepGroup(wave, CreateCreepGroup("creep_constructradiant", 4, 3, 1, 2))
	AddCreepGroup(wave, CreateCreepGroup("creep_cluckles", 6, 0, 1, 3))

	return wave
end

waveTable = {}

waveTable[1] = {
	bonusEndGold = 50,
	creepGroups = {		
		CreateCreepGroup("creep_zealot_0", 1, 0, 1, 1),		
		CreateCreepGroup("creep_zealot_1", 1, 0, 1, 1),		
		--CreateCreepGroup("creep_healer_0", 10, 0, 1, 5),
		--CreateCreepGroup("creep_cluckles", 10, 0, 1, 5),
	}
}

--[[
waveTable[2] = CreepExampleWaveBuilder()

waveTable[3] = {
	bonusEndGold = 200,
	creepGroups = {
		CreateCreepGroup("creep_donkey", 10, 0, 2, 2),
		CreateCreepGroup("creep_sheep", 100, 0, 5, 1)
	}
}
]]