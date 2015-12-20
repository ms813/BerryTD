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
waveTable[2] = Wave("creep_cluckles", 10, 150, 1, 0.5)
waveTable[3] = Wave("creep_donkey", 10, 160, 1, 0.5)
waveTable[4] = Wave("creep_beaver", 10, 180, 1, 0.5)
waveTable[5] = Wave("creep_facerex", 2, 200, 1, 0.5)
waveTable[6] = Wave("creep_goldwight", 25, 200, 1, 0.5)
waveTable[7] = Wave("creep_geodesic", 5, 200, 1, 0.5)
waveTable[8] = Wave("creep_crab", 10, 200, 1, 0.5)
waveTable[9] = Wave("creep_constructradiant", 10, 200, 1, 0.5)
waveTable[10] = Wave("creep_ancestralspirit", 1, 400, 1, 0.5)