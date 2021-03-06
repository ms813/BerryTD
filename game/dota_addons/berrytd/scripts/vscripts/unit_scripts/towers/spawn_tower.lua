function SpawnTower(keys)
	local caster = keys.caster

	--owner is the player's hero, used to credit kill gold
	local owner = caster:GetOwner()
	local pID = owner:GetPlayerID()

	local tower = CreateUnitByName(
		keys.AbilityContext.tower_name,
		caster:GetAbsOrigin(),
		false,
		owner,
		owner,
		DOTA_TEAM_GOODGUYS)

	tower:SetControllableByPlayer(pID, false)

	--kill and stop drawing the tower spawn site
	caster:ForceKill(false)
	caster:AddNoDraw()
end
