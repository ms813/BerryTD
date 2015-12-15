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
waveTable[2] = Wave("creep_cluckles", 10, 100)
waveTable[3] = Wave("creep_donkey", 10, 100)
waveTable[4] = Wave("creep_beaver", 10, 100)

