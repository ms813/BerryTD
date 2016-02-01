function Spawn(entityKeyValues)	

	lvlUpUnitAbilities(thisEntity)

	Timers:CreateTimer(function()
			return DragonThink(thisEntity)
		end)
end

function DragonThink(tower)
	--stop the timer if we sell the tower
	if tower:IsNull() or not tower:IsAlive() then
		return nil
	end

	local dragonfire = tower:FindAbilityByName("ability_dragonfire") or tower:FindAbilityByName("ability_golden_dragonfire")

	if dragonfire ~= nil then

		if dragonfire:GetCooldownTimeRemaining() <= 0.0 then
			local range = dragonfire:GetLevelSpecialValueFor("cast_range", 1)

			--fire at closest creep
			local creeps = FindUnitsInRadius(
				DOTA_TEAM_BADGUYS,
				tower:GetAbsOrigin(),
				nil,
				range - 50,
			    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			    DOTA_UNIT_TARGET_ALL,
			    DOTA_UNIT_TARGET_FLAG_NONE,
			    FIND_CLOSEST,
				false)
			if #creeps > 0 then							
				local target_pos = GetGroundPosition(creeps[1]:GetAbsOrigin(), nil)								
				tower:CastAbilityOnPosition(target_pos, dragonfire, tower:GetPlayerOwnerID())				
			end
		end		
	end

	return 0.1
end

--[[
	Deal a % of the targets current hp as damage
]]
function DragonBurnTick(keys)		
	local percent_dmg = keys.AbilityContext.currentHpPercentDmg	
	local dmg = keys.target:GetHealth() * percent_dmg	
	ApplyDamage({
		victim = keys.target,
		attacker = keys.caster,
		damage = dmg,
		damage_type = DAMAGE_TYPE_MAGICAL
	})	
end

--[[
	Remove the plain dragonfire ability and add a new one that applies different debuffs
]]
function DragonActivateGold(keys)
	local caster = keys.caster
	local new_model = keys.AbilityContext.model
		
	caster:RemoveAbility("ability_dragonfire")

	local new_ab = caster:AddAbility("ability_golden_dragonfire")
	new_ab:SetLevel(1)

	caster:SetOriginalModel(new_model)
	caster:SetModel(new_model)	
end

function DragonIncreaseBounty(keys)	
	local target = keys.target
	local bounty = target:GetMaximumGoldBounty()
	local gold_multiplier = keys.ability:GetLevelSpecialValueFor("gold_multiplier", 1)

	--if the default bounty has already been increased then don't increase it again
	if target.default_bounty == nil then

		--cache the default bounty so we can reset when the debuff wears off
		target.default_bounty = bounty
		target:SetMaximumGoldBounty(bounty * gold_multiplier)
		target:SetMinimumGoldBounty(bounty * gold_multiplier)
	end	
end

function DragonResetBounty(keys)
	local target = keys.target

	if target.default_bounty ~= nil then
		target:SetMaximumGoldBounty(target.default_bounty)
		target:SetMinimumGoldBounty(target.default_bounty)
		target.default_bounty = nil
	end
end

function DragonApplyCoinsParticle(keys)
	local target = keys.target or keys.unit	
	
	local target_pos = target:GetAbsOrigin()
	local particle_name = "particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf"
	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
end

function DragonGoldBurn(keys)	
	local gold_amt = keys.ability:GetLevelSpecialValueFor("gold_per_tick", 1)
	DragonApplyCoinsParticle(keys)
	PlayerResource:ModifyGold(keys.caster:GetOwner():GetPlayerID(), gold_amt, true, DOTA_ModifyGold_Unspecified)
end