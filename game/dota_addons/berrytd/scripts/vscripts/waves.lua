function Wave(creep, numTotal, bonusEndGold, spawnGroupSize, spawnGroupInterval)
	local newWave = {}
	newWave.isBoss = false
	newWave.creep = creep
	newWave.numTotal = numTotal
	newWave.numPerSpawn = numPerSpawn
	newWave.bonusEndGold = bonusEndGold	
	newWave.lifePenalty = 1
	newWave.spawnGroupSize = spawnGroupSize
	newWave.spawnGroupInterval = spawnGroupInterval

	return newWave
end

waveTable = {}

waveTable[1] = Wave("creep_sheep", 10, 100, 2, 2)
waveTable[2] = Wave("creep_cluckles", 10, 110, 1, 0.5)
waveTable[3] = Wave("creep_donkey", 10, 120, 1, 0.5)
waveTable[4] = Wave("creep_beaver", 10, 130, 1, 0.5)
waveTable[5] = Wave("creep_facerex", 2, 140, 1, 0.5)
waveTable[6] = Wave("creep_goldwight", 25, 150, 1, 0.5)
waveTable[7] = Wave("creep_geodesic", 5, 150, 1, 0.5)
waveTable[8] = Wave("creep_crab", 10, 150, 1, 0.5)

