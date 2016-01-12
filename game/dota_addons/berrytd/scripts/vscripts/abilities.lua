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
	Upgrade paths:

				     ---> 3 ---> 5
		1 ---> 2 ---|
				     ---> 4 ---> 6
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


		--if upgrade 3 is picked, block 4 and 6 and remove 4 from the bar
		if upgrade_number == 3 then
			caster.upgradePath[4] = "blocked"
			caster.upgradePath[6] = "blocked"

			local check4 = caster:FindAbilityByName(string.sub(ability_name,0,-2).."4")
			if check4 ~= nil then
				caster:RemoveAbility(check4:GetAbilityName())
			end
		--if upgrade 4 is picked, block 3 and 5 and remove 3 from the bar
		elseif	upgrade_number == 4 then
			caster.upgradePath[3] = "blocked"
			caster.upgradePath[5] = "blocked"

			local check3 = caster:FindAbilityByName(string.sub(ability_name,0,-2).."3")
			if check3 ~= nil then
				caster:RemoveAbility(check3:GetAbilityName())
			end
		end

		--upgrade the new ability to the level specified in the ability file
		new_ability:SetLevel(keys.AddAbility1.Level)

		--toggle autocast on if specified in the ability file
		if keys.AddAbility1.AutoCast ~= nil and keys.AddAbility1.AutoCast == "true" then
			new_ability:ToggleAutoCast()
		end

		--cache the level of the next upgrade
		local next_upgrade_number = upgrade_number + 1

		--this block adds the ability to purchase the next upgrade
		if upgrade_number < 5 and caster.upgradePath[next_upgrade_number] == "available" then		

			--get the name of the next upgrade in the path
			--by trimming the start of the current ability and adding the next upgrade number
			local next_upgrade_name = string.sub(ability_name,0,-2)..next_upgrade_number
			
			--add the ability to purchase the next upgrade in the path	
			caster:AddAbility(next_upgrade_name)

			--set the new upgrade to level 1 so that it can actually be clicked on			
			if caster:FindAbilityByName(next_upgrade_name) ~= nil then
				caster:FindAbilityByName(next_upgrade_name):SetLevel(1)
			end
			
			--display upgrades 3 and 4 at the same time, only let the user pick one
			if upgrade_number == 2 then
				local lvl4_upgrade = string.sub(ability_name, 0, -2)..(next_upgrade_number+1)				
				if caster:FindAbilityByName(lvl) ~= nil then
					caster:AddAbility(lvl4_upgrade)
					caster:FindAbilityByName(lvl4_upgrade):SetLevel(1)
				end
			end


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
		caster:AddAbility("ability_spawn_dragon_tower")
		caster:AddAbility("ability_spawn_tackshooter_tower")
		caster:AddAbility("ability_spawn_iceberg_tower")

	elseif ability_name == "ability_open_page_two" then

		caster:AddAbility("ability_spawn_melee_barracks")

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