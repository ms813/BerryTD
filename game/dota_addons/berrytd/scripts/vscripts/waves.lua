function Wave(creep, numTotal, bonusEndGold)
	local newWave = {}
	newWave.isBoss = false
	newWave.creep = creep
	newWave.numTotal = numTotal
	newWave.numPerSpawn = numPerSpawn
	newWave.bonusEndGold = bonusEndGold	
	newWave.lifePenalty = 1

	return newWave
end

waveTable = {}

waveTable[1] = Wave("creep_sheep", 10, 100)
waveTable[2] = Wave("creep_cluckles", 10, 110)
waveTable[3] = Wave("creep_donkey", 10, 120)
waveTable[4] = Wave("creep_beaver", 10, 130)
waveTable[5] = Wave("creep_facerex", 2, 140)
waveTable[6] = Wave("creep_goldwight", 25, 150)
waveTable[7] = Wave("creep_geodesic", 5, 150)
waveTable[8] = Wave("creep_crab", 10, 150)