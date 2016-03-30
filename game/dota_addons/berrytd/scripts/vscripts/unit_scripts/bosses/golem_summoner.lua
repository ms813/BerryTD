require('targetingHelper')

--[[
	Called when the golem's summoners spawn

	Start casting their ability to increase the golem's max HP
]]
function Spawn()
	Timers:CreateTimer(0.1, function()
		return GolemSummonerThink(thisEntity)
	end)
end

function GolemSummonerThink(summoner)

	if summoner:IsNull() or not summoner:IsAlive() then
		return nil
	end

	--find the golem boss (it might not have spawned yet)
	local units = TargetingHelper.FindNearbyFriendlies(summoner, 10000)
	summoner.golem  = nil

	for i, unit in pairs(units) do
		if unit:GetUnitName() == "boss_golem" then
			summoner.golem = unit
			break
		end
	end

	if summoner.golem ~= nil then
		local ability = summoner:FindAbilityByName("ability_boss_golem_summoner")

		if ability ~= nil and ability:IsCooldownReady() then			
			summoner:CastAbilityOnTarget(summoner.golem, ability, summoner:GetPlayerOwnerID())
			return 2
		end
	end

	return 0.1
end

--[[
	On cast, add a stack of the ability to the golem
]]
function GolemSummonerCast(keys)	
	local caster = keys.caster
    local target = keys.target
    local modifier = keys.AbilityContext.modifier
    local ab = keys.ability

	if target:HasModifier(modifier) then
        local stack_count = target:GetModifierStackCount(modifier, ab)
        target:SetModifierStackCount(modifier, ab, stack_count + 1)
    else
        ab:ApplyDataDrivenModifier(caster, target, modifier, {})
        target:SetModifierStackCount(modifier, ab, 1)
    end
end

--[[
	Each tick of the modifier, increase the golem's max hp 
	depending on the number of stacks of the modifier
]]
function GolemSummonerTick(keys)		
	local golem = keys.target
	local summoner = keys.caster
	local max_hp = golem:GetBaseMaxHealth()
	local modifier = keys.AbilityContext.modifier
	local stacks = golem:GetModifierStackCount(modifier, ab)	
	local hp_per_tick = tonumber(keys.AbilityContext.hp_increase)	

	local new_max_hp = max_hp + hp_per_tick * stacks

	--increase MaxHealth then BaseMaxHealth as weird things happen if you only use one or the other	
	golem:SetMaxHealth(new_max_hp)	
	golem:SetBaseMaxHealth(new_max_hp)

	local current_hp = golem:GetHealth()
	golem:SetHealth(current_hp + hp_per_tick * stacks)
end

function GolemSummonerOnDeath(keys)
	local caster = keys.caster
	local target = caster.golem
	local modifier = keys.AbilityContext.modifier
	if target ~= nil then
		if target:HasModifier(modifier) then
	        local stack_count = target:GetModifierStackCount(modifier, ab)
	        target:SetModifierStackCount(modifier, ab, stack_count - 1)
	    end
	end
    
end