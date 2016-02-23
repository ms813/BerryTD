require('targetingHelper')

function Spawn(keys)
	lvlUpUnitAbilities(thisEntity)
	Timers:CreateTimer(0.5, function()
		return SaintThink(thisEntity)
	end)
end

function SaintThink(creep)

	--if creep dies stop the timer
	if creep:IsNull() or not creep:IsAlive() then
		return nil
	end

	local repel = thisEntity:FindAbilityByName("ability_creep_saint_repel")
	local ga = thisEntity:FindAbilityByName("ability_creep_saint_guardian_angel")
	local range = repel:GetLevelSpecialValueFor("range", repel:GetLevel())	

	--cast repel
	if repel ~= nil and repel:IsCooldownReady() then
		
		--find highest level allies inside spell cast range
		local targets = TargetingHelper.HighestLevelAllies(creep, range)	

		--find a nearby target that hasn't already got the repel modifier
		local repel_target = nil	
		for i,t in pairs(targets) do
			if not t:HasModifier("modifier_creep_saint_repel") and t ~= creep then		
				repel_target = t
				break
			end
		end
		--only target self if no other eligible creeps
		if repel_target == nil and not creep:HasModifier("modifier_creep_saint_repel") then
			repel_target = creep
		end

		if repel_target~= nil then
			creep:CastAbilityOnTarget(repel_target, repel, creep:GetPlayerOwnerID())
			return 0.5		
		end
	end
	
	--cast ga
	if ga ~= nil and ga:IsCooldownReady() then		

		--find highest level allies inside spell cast range
		local targets = TargetingHelper.HighestLevelAllies(creep, range)

		--find a nearby target that hasn't already got the ga modifier
		local ga_target = nil
		for i,t in pairs(targets) do
			if not t:HasModifier("modifier_creep_saint_guardian_angel") and t ~= creep then		
				ga_target = t
				break
			end
		end
		--only target self if no other eligible creeps
		if ga_target == nil and not creep:HasModifier("modifier_creep_saint_guardian_angel") then
			ga_target = creep
		end
		
		if ga_target~= nil then
			creep:CastAbilityOnTarget(ga_target, ga, creep:GetPlayerOwnerID())
			return 0.5		
		end
	end

	return 0.5
end