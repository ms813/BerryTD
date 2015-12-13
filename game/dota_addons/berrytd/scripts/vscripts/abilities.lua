function sellTower(keys)
	GameMode:sellTower(keys)
end

function GameMode:sellTower(keys)
	local caster =  keys.caster
	local owner = caster:GetOwner()

	local refundAmount = caster:GetManaRegen()
	print("gold bounty check",refundAmount)

	caster:ForceKill(false)
	owner:ModifyGold(refundAmount, true, DOTA_ModifyGold_SellItem)

end