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
		local new_ability = caster:FindAbilityByName(keys.AddAbility1.Ability)

		--take a note that we've purchased this number
		caster.upgradePath[upgrade_number] = "purchased";		

		--upgrade the new ability to the level specified in the ability file
		new_ability:SetLevel(keys.AddAbility1.Level)

		--toggle autocast on if specified in the ability file
		if keys.AddAbility1.AutoCast ~= nil and keys.AddAbility1.AutoCast == "true" then
			new_ability:ToggleAutoCast()
		end

		local next_upgrade_number = upgrade_number + 1
		if upgrade_number < 5 and caster.upgradePath[next_upgrade_number] == "available" then		

			--get the name of the next upgrade in the tree
			local next_upgrade_name = string.sub(ability_name,0,-2)..next_upgrade_number
			
			--add the ability to purchase the next upgrade in the tree	
			caster:AddAbility(next_upgrade_name)

			local next_upgrade = caster:FindAbilityByName(next_upgrade_name)
			next_upgrade:SetLevel(1)

			--put logic here to branch at ability 3/4
		end				

		--this adds half the upgrade cost to the sell value using the mana regen hack
		caster:SetBaseManaRegen(caster:GetManaRegen() + (ability_gold_cost / 2))

	end
end

function goToPage(keys)
	GameMode:goToPage(keys)
end

function GameMode:goToPage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_name = ability:GetAbilityName()

	clearUnitAbilities(caster)

	caster:AddAbility("ability_return_to_start_page")

	if ability_name == "ability_open_page_one" then
		caster:AddAbility("ability_spawn_sniper_tower")
	elseif ability_name == "ability_open_page_two" then

	elseif ability_name == "ability_open_page_three" then

	elseif ability_name == "ability_open_page_four" then

	end

	lvlUpUnitAbilities(caster)
end

function returnToStartPage(keys)
	GameMode:returnToStartPage(keys)
end

function GameMode:returnToStartPage(keys)
	local caster = keys.caster
	local ability = keys.ability

	clearUnitAbilities(caster)
	
	caster:AddAbility("ability_open_page_one")
	caster:AddAbility("ability_open_page_two")
	caster:AddAbility("ability_open_page_three")
	caster:AddAbility("ability_open_page_four")

	lvlUpUnitAbilities(caster)
end

function clearUnitAbilities(unit)
  	for i = 0, unit:GetAbilityCount()-1 do
    	local a = unit:GetAbilityByIndex(i)

    	if a ~= nil then
      	unit:RemoveAbility(a:GetAbilityName())
  		end
	end
end

function lvlUpUnitAbilities(unit)
 	for i = 0, unit:GetAbilityCount()-1 do
    	local a = unit:GetAbilityByIndex(i)

    	if a ~= nil then
      	a:SetLevel(1)
  		end
	end
end