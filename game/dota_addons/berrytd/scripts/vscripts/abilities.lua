function sellTower(keys)
	GameMode:sellTower(keys)
end

function GameMode:sellTower(keys)
	local caster =  keys.caster
	local owner = caster:GetOwner()

	local refundAmount = caster:GetManaRegen()	

	caster:ForceKill(false)
	owner:ModifyGold(refundAmount, true, DOTA_ModifyGold_SellItem)

	Notifications:Top(caster:GetPlayerOwner():GetPlayerID(), {text = "Sold tower for "..refundAmount.." gold" , duration = 5})
end

function upgradeTower(keys)

	local caster = keys.caster
	local ability_name = keys.ability:GetAbilityName()
	local ability_gold_cost = keys.ability:GetGoldCost(keys.ability:GetLevel())

	if caster.upgradePath == nil then
		caster.upgradePath = {}	
		for i=1, 6 do
			caster.upgradePath[i] = "available"
		end
	end	

	--[[
		upgrade_number is used to check the upgrade paths by trimming the number off the end of the ability name:
			e.g. ability_sniper_upgrade_1 
		towers can upgrade 1 & 2  but only 3 & 5 or 4 & 6
	Upgrade paths:

		1 -> 3 -> 5
		2 -> 4 -> 6
		]]

	--grab the upgrade number from the ability name
	local upgrade_number = tonumber(string.sub(ability_name, -1))	

	--remove the upgrade button
	caster:RemoveAbility(ability_name)
	
	--check an upgrade is specified in the ability file and that we haven't already upgraded it
	if keys.AddAbility1 ~= nil and caster.upgradePath[upgrade_number] == "available" then
		
		caster:AddAbility(keys.AddAbility1.Ability)
		ability_to_add = caster:FindAbilityByName(keys.AddAbility1.Ability)

		--take a note that we've purchased this number
		caster.upgradePath[upgrade_number] = "purchased";		

		--upgrade the new ability to the level specified in the ability file
		ability_to_add:SetLevel(keys.AddAbility1.Level)

		--toggle autocast on if specified in the ability file
		if keys.AddAbility1.AutoCast ~= nil and keys.AddAbility1.AutoCast == "true" then
			ability_to_add:ToggleAutoCast()
		end

		local next_upgrade_number = upgrade_number + 2
		if upgrade_number < 5 and caster.upgradePath[next_upgrade_number] == "available" then		

			--get the name of the next upgrade in the tree
			local next_upgrade_name = string.sub(ability_name,0,-2)..next_upgrade_number
			
			--add the ability to purchase the next upgrade in the tree	
			caster:AddAbility(next_upgrade_name)

			local next_upgrade = caster:FindAbilityByName(next_upgrade_name)
			next_upgrade:SetLevel(1)	

			--for upgrades 3 or 4, block 4 & 6 or 3 & 5 respectively
			
			if upgrade_number == 3 then
				caster.upgradePath[4] = "blocked" 
				caster.upgradePath[6] = "blocked"

				local ability_4 = caster:FindAbilityByName(string.sub(ability_name, 0, -2).."4")
				if  ability_4 == nil then				
					caster:AddAbility(string.sub(ability_name, 0, -2).."4")
					ability_4 = caster:FindAbilityByName(string.sub(ability_name, 0, -2).."4")
				end
				ability_4:SetLevel(0)
			elseif upgrade_number == 4 then
					caster.upgradePath[3] = "blocked" 
					caster.upgradePath[5] = "blocked"

					local ability_3 = caster:FindAbilityByName(string.sub(ability_name, 0, -2).."3")
					if  ability_3 == nil then				
						caster:AddAbility(string.sub(ability_name, 0, -2).."3")
						ability_3 = caster:FindAbilityByName(string.sub(ability_name, 0, -2).."3")
					end
					ability_3:SetLevel(0)
			end
		end				

		--this adds half the upgrade cost to the sell value using the mana regen hack
		caster:SetBaseManaRegen(caster:GetManaRegen() + (ability_gold_cost / 2))

	end
end