--[[
	This file  contains generic abilities that apply to all towers,
	including selling and upgrading.

	There are also a couple of helper functions for removing and leveling 
	all of a unit's abilities
  ]]


--[[
	Handle to call sellTower from KV files

	Returns: void
	Params: KV ability keys
  ]]
function sellTower(keys)
	GameMode:sellTower(keys)
end

--[[
	Sells the tower that casts this ability

	Refunds the owner some the sell value (1/2 tower + upgrades cost)
	Kills any child units if the tower is a barracks

	Returns: void
	Params: KV ability keys
  ]]
function GameMode:sellTower(keys)
	local caster =  keys.caster
	local owner = caster:GetOwner()
	local pos = caster:GetAbsOrigin()

	--sell value uses mana regen as a hack as GetGoldBounty() doesn't work
	local refundAmount = caster:GetManaRegen()	

	--if the sold tower is a barracks, kill its defenders
	if caster:GetUnitLabel() == "barracks" then
		for i, defender in pairs(caster.defenders) do
			defender:ForceKill(false)
		end
	end

	--kill the tower
	caster:ForceKill(false)

	--refund the owner for the sell value of the tower
	owner:ModifyGold(refundAmount, true, DOTA_ModifyGold_SellItem)

	--send a message to the owner of the tower
	Notifications:Top(caster:GetPlayerOwner():GetPlayerID(), {text = "Sold tower for "..refundAmount.." gold" , duration = 5})

	--rebuild a tower spawn site
	GameMode:BuildTowerSpawn(pos, owner) 
end

--[[
	Should be called from the KV file every time a tower upgrade ability is cast

	Removes the 'upgrade' ability, adds the ability the upgrade provides
	Checks for upgrade abilities higher in the tree and adds them to the unit
	Increments the 'sell cost' of the tower

	Returns: void
	Params: KV ability keys
  ]]
function upgradeTower(keys)

	local caster = keys.caster
	local ability_name = keys.ability:GetAbilityName()
	local ability_gold_cost = keys.ability:GetGoldCost(keys.ability:GetLevel())
	local next_upgrade = keys.AbilityContext.nextUpgrade
	local split_upgrade = keys.AbilityContext.splitUpgrade

	keys.ability:SetHidden(true)
	local new_ab = caster:AddAbility(next_upgrade)

	--not all upgrades are implemented yet so defend here
	if new_ab ~= nil then new_ab:SetLevel(1) end

	if split_upgrade ~= nil then		
		local ab = caster:AddAbility(split_upgrade)
		--not all upgrades are implemented yet so defend here
		if ab ~= nil then ab:SetLevel(1) end 
	end

	--grab the upgrade number from the ability name
	local upgrade_number = tonumber(string.sub(ability_name, -1))	

	if upgrade_number == 3 then
		caster:RemoveAbility(string.sub(ability_name,0,-2).."4")
	else if upgrade_number == 4 then
		caster:RemoveAbility(string.sub(ability_name,0,-2).."3")
	end
		

	--this adds half the upgrade cost to the sell value using the mana regen hack
	caster:SetBaseManaRegen(caster:GetManaRegen() + (ability_gold_cost / 2))

	end
end

function goToPage(keys)
	GameMode:goToPage(keys)
end

--[[
	Replace unit's current abilities with a new set from the specified page
	Returns: void
	Params: KV ability keys
  ]]
function GameMode:goToPage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_name = ability:GetAbilityName()

	clearUnitAbilities(caster)

	--add the ability to return to the overview page
	caster:AddAbility("ability_return_to_start_page")

	--depending on which page we open, populate it with some abilities	
	if ability_name == "ability_open_page_one" then

		--page one has physical DPS towers
		caster:AddAbility("ability_spawn_sniper_tower")		
		caster:AddAbility("ability_spawn_tackshooter_tower")
		

	elseif ability_name == "ability_open_page_two" then

		--page two has magical DPS towers
		caster:AddAbility("ability_spawn_dragon_tower")	
		caster:AddAbility("ability_spawn_laser_tower")
		caster:AddAbility("ability_spawn_soul_siphon_tower")	

	elseif ability_name == "ability_open_page_three" then

		--page three has unit spawning barracks
		caster:AddAbility("ability_spawn_melee_barracks")
		caster:AddAbility("ability_spawn_ranged_barracks")
		caster:AddAbility("ability_spawn_magic_barracks")
		caster:AddAbility("ability_spawn_utility_barracks")

	elseif ability_name == "ability_open_page_four" then

		--page four has utility towers
		caster:AddAbility("ability_spawn_iceberg_tower")
		caster:AddAbility("ability_spawn_tesla_coil_tower")
	end

	--finally level up all the abilities on the caster so we can actually cast them
	lvlUpUnitAbilities(caster)
end

--[[
	Used to call GameMode:returnToStartPage from KV files
	Returns: void
	Params: KV ability keys
  ]]
function returnToStartPage(keys)
	GameMode:returnToStartPage(keys)
end

--[[
	Return the hero from a page of abilities to the "open page" set of abilities
	Returns: void
	Params: KV ability keys
  ]]
function GameMode:returnToStartPage(keys)
	local caster = keys.caster
	local ability = keys.ability

	--clear whatever page of abilities we were on
	clearUnitAbilities(caster)
	
	--add the 'open page' abilities
	caster:AddAbility("ability_open_page_one")
	caster:AddAbility("ability_open_page_two")
	caster:AddAbility("ability_open_page_three")
	caster:AddAbility("ability_open_page_four")

	--level them up so they are castable
	lvlUpUnitAbilities(caster)
end

--[[
	Loop over this unit's current abilities and remove them all
	Returns: void
	Params: CBaseEntity unit
  ]]
function clearUnitAbilities(unit)	
  	for i = 0, unit:GetAbilityCount()-1 do
    	local a = unit:GetAbilityByIndex(i)

    	if a ~= nil then
      		unit:RemoveAbility(a:GetAbilityName())
  		end
	end
end

--[[
	Loop over this unit's current abilities and set them all to level 1
	Returns: void
	Params: CBaseEntity unit
  ]]
function lvlUpUnitAbilities(unit)
 	for i = 0, unit:GetAbilityCount()-1 do
    	local a = unit:GetAbilityByIndex(i)

    	if a ~= nil then
      	a:SetLevel(a:GetLevel() + 1)
  		end
	end
end