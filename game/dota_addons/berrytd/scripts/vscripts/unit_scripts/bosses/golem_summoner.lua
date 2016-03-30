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

	--find the golem boss (it might not have spawned yet)
	local golem = Entities:FindAllByName("boss_golem")

	if golem ~= nil then
		local ability = summoner:FindAbilityByName("ability_boss_golem_summoner")

		if ability ~= nil and ability:IsCooldownReady() then
			summoner:CastAbilityOnTarget(golem, ability, nil)
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
	local hp = golem:GetBaseMaxHealth()
	local modifier = keys.AbilityContext.modifier
	local stacks = golem:GetModifierStackCount(modifier, ab)

	local hp_increase = keys.AbilityContext.hp_increase * stacks

	golem:SetBaseMaxHealth(hp + hp_increase)
end