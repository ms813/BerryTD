function Spawn(keys)
	local ab = thisEntity:FindAbilityByName("ability_creep_hive_egg_hatch")

	--put the egg's hatch ability on cooldown
	local hatch = thisEntity:FindAbilityByName("ability_creep_hive_egg_hatch")
	local cd = hatch:GetCooldown(hatch:GetLevel()) 
	
	hatch:StartCooldown(cd)

	Timers:CreateTimer(0.1, function()		

		if ab:IsCooldownReady() then
			ab:CastAbility()			
			return nil
		else
			return 0.1
		end
	end)
end

function HiveEggHatch(keys)
	local ab = keys.ability
	local babies = ab:GetLevelSpecialValueFor("babies", ab:GetLevel() - 1)
	local next_waypoint = keys.caster.next_waypoint
	for i = 1, babies do
		local baby = CreateUnitByName(
		"creep_hive_baby",
		keys.caster:GetAbsOrigin() + RandomVector(50),
		true,
		nil,
		nil,
		DOTA_TEAM_BADGUYS)

		--make spiderling phased
		baby:AddNewModifier(baby, nil, "modifier_phased", {})

		--set the babies next waypoint
		if next_waypoint ~= nil then
			baby:SetInitialGoalEntity(next_waypoint)
		else
			baby:SetInitialGoalEntity(keys.caster.last_waypoint)
		end	

		--increase the total number of creeps for this wave and update the quest counter
		GameMode.total_creeps = GameMode.total_creeps + 1
		GameMode.Quest.max_creeps = GameMode.Quest.max_creeps + 1
		GameMode.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, GameMode.creep_kills)
		GameMode.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, GameMode.Quest.max_creeps)
        GameMode.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, GameMode.creep_kills)			
        GameMode.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, GameMode.Quest.max_creeps)			
	end

	--force kill the egg	
	keys.caster:AddNoDraw()
	local particle = "particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf"
	ParticleManager:CreateParticle(particle,PATTACH_ABSORIGIN,keys.caster)
	keys.caster:ForceKill(false)

end