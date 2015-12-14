function Wave(creep, numTotal, goldPerKill, bonusEndGold)
	local newWave = {}
	newWave.isBoss = false
	newWave.creep = creep
	newWave.numTotal = numTotal
	newWave.numPerSpawn = numPerSpawn
	newWave.bonusEndGold = bonusEndGold
	newWave.goldPerKill = goldPerKill
	newWave.lifePenalty = 1

	return newWave
end

waveTable = {}

waveTable[1] = Wave("creep_sheep", 10, 5, 100)
waveTable[2] = Wave("creep_cluckles", 10, 10, 100)
waveTable[5] = Wave("creep_facerex", 10, 40, 100)