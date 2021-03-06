-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.
-- Do not remove the GameMode:_Function calls in these events as it will mess with the internal barebones systems.

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  DebugPrint("[BAREBONES] GameRules State Changed")
  DebugPrintTable(keys)

  -- This internal handling is used to set up main barebones functions
  GameMode:_OnGameRulesStateChange(keys)

  local newState = GameRules:State_Get()
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)

  -- This internal handling is used to set up main barebones functions
  GameMode:_OnNPCSpawned(keys)

  local npc = EntIndexToHScript(keys.entindex)
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --DebugPrint("[BAREBONES] Entity Hurt")
  --DebugPrintTable(keys)

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)

    -- The ability/item used to damage, or nil if not damaged by an item/ability
    local damagingAbility = nil

    if keys.entindex_inflictor ~= nil then
      damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
    end
  end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
    DebugPrint( '[BAREBONES] OnItemPickedUp' )
    DebugPrintTable(keys) 

    local unit = EntIndexToHScript(keys.UnitEntityIndex)
    local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
    
    --local itemname = keys.itemname


    --check if the item picked up is one of the TD gems
    if itemEntity:GetName() == "item_berrytd_gem" then    
        unit.hasGem = true
        unit.gem = itemEntity
        itemEntity.pickedUp = true

        --cancel the return timer on the gem
        if itemEntity.reset_timer ~= nil then
            Timers:RemoveTimer(itemEntity.reset_timer)
            itemEntity.reset_timer = nil
        end

        --make the creep carrying the gem follow the reverse path
        --by inverting the number of the current waypoint

        --check if unit is on the way back
        --if they are, switch them to the reverse path
        local isOnWayBack = string.find(unit.last_waypoint:GetName(), "reverse")
        if isOnWayBack == nil then
            local max_waypoint = #self.WAYPOINTS - 1   
            local waypoint_no = max_waypoint
            if unit.last_waypoint ~= nil then
                --creep_waypoint_
              waypoint_no = tonumber(string.sub(unit.last_waypoint:GetName(), 16))              
            end             

            -- minus one here is to make sure the creep doesnt skip a point on the way back
            local point_i = (max_waypoint - waypoint_no - 1)
            if point_i < 0 then point_i = 0 end
            local reverse_path_waypoint = "creep_waypoint_reverse_"..point_i        
            local exit = Entities:FindByName(nil, reverse_path_waypoint)            

            unit:Stop()
            unit:SetInitialGoalEntity(exit)
        else
            --if unit is already on the way out then just carry on            
            unit:SetInitialGoalEntity(unit.last_waypoint)
        end
    end  
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  DebugPrintTable(keys) 
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  DebugPrint( '[BAREBONES] OnItemPurchased' )
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityname = keys.abilityname
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  DebugPrint('[BAREBONES] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  DebugPrint('[BAREBONES] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  DebugPrint('[BAREBONES] OnPlayerLevelUp')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  DebugPrint('[BAREBONES] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  DebugPrint('[BAREBONES] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  DebugPrint('[BAREBONES] OnRuneActivated')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_BOUNTY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('[BAREBONES] OnPlayerPickHero')
  DebugPrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  DebugPrint('[BAREBONES] OnTeamKillCredit')
  DebugPrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
    DebugPrint( '[BAREBONES] OnEntityKilled Called' )
    DebugPrintTable( keys )

    GameMode:_OnEntityKilled( keys )  

    -- The Unit that was Killed
    local killedUnit = EntIndexToHScript( keys.entindex_killed )
    -- The Killing entity
    local killerEntity = nil

    if keys.entindex_attacker ~= nil then
        killerEntity = EntIndexToHScript( keys.entindex_attacker )
    end

    -- The ability/item used to kill, or nil if not killed by an item/ability
    local killerAbility = nil

    if keys.entindex_inflictor ~= nil then
        killerAbility = EntIndexToHScript( keys.entindex_inflictor )
    end

    local damagebits = keys.damagebits -- This might always be 0 and therefore useless

    -- Put code here to handle when an entity gets killed   

    --if killed unit was a defender
    if killedUnit:GetUnitLabel() == "defender" then
        local rax = killedUnit.parent_barracks

        --if the aggro target was melee then remove it's attack capability      
        if killedUnit.aggro_target ~= nil then
            local attack_capability = killedUnit.aggro_target.default_attack_capability
            if attack_capability == DOTA_UNIT_CAP_MELEE_ATTACK then
              killedUnit.aggro_target:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
            end
        end

        --remove killed defenders from barrack's list
        for k, defender in pairs(rax.defenders) do
            if defender == killedUnit then
              table.remove(rax.defenders, k)              
            end
        end  

        --remove killed defenders from global list
        for k, defender in pairs(self.defenders) do
            if defender == killedUnit then
              table.remove(self.defenders, k)              
            end
        end          
    end

    --if killed unit was a creep    
    if killedUnit:GetUnitLabel() == "creep" then         

          --remove killed creep from global list
          for k, creep in pairs(self.creeps) do
              if creep == killedUnit then
                table.remove(self.creeps, k)              
              end
          end  

          --tick up the creep kill quest counter     
          self.creep_kills = self.creep_kills + 1 
          self.total_creeps = self.total_creeps - 1
          self.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self.creep_kills)
          self.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self.creep_kills)
          
      if self.currentWave > 0 and self.total_creeps == 0 then  
        --no creeps are on the map, so lets give the reward for completing the wave
          for i, player in pairs(self.players) do          
            player:ModifyGold(waveTable[self.currentWave].bonusEndGold, true, DOTA_ModifyGold_Unspecified)
          end        

          --mark the creep killing quest as done
          self.Quest:CompleteQuest()           

          --check we are not on the last wave
          if self.currentWave <= self.maxWave then        
              --start a timeout before the next wave
              self:StartInterwaveTimeout(self.currentWave)                
          else
              --if there are no more waves then end the game with radiant victory
              --GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
          end
      end  
    end
end



-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  DebugPrint('[BAREBONES] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  DebugPrint('[BAREBONES] OnConnectFull')
  DebugPrintTable(keys)

  GameMode:_OnConnectFull(keys)
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
  DebugPrint('[BAREBONES] OnItemCombined')
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  local player = PlayerResource:GetPlayer(plyID)

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
  DebugPrint('[BAREBONES] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
  DebugPrint('[BAREBONES] OnNPCGoalReached')
  DebugPrintTable(keys)

  local goalEntity = EntIndexToHScript(keys.goal_entindex)
  local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
  local npc = EntIndexToHScript(keys.npc_entindex)

  --cache the last/next waypoint on the creep
  npc.last_waypoint = goalEntity  
  npc.next_waypoint = nextGoalEntity   

  local end_waypoint = self.WAYPOINTS[#self.WAYPOINTS]:GetName()

    --if creep has reached the end, turn around and start running back towards the entrance
    if goalEntity:GetName() == end_waypoint  then

        --print(npc:GetUnitName(), "reached the end", end_waypoint)
        npc:Stop()
        local exit = Entities:FindByName(nil, "creep_waypoint_reverse_0")
        npc:SetInitialGoalEntity(exit)        
    end

    --check for creeps exiting the map carrying gems
    local max_waypoint = #self.WAYPOINTS - 1
    

    if goalEntity:GetName() == "creep_waypoint_reverse_"..max_waypoint then

        if npc.hasGem then        
            local toRemove = nil
            for i, gem in pairs(self.gems) do
              if npc.gem == gem then
                toRemove = i
              end
            end

            table.remove(self.gems, toRemove)           

            Notifications:TopToAll({text=npc:GetUnitName().. " escaped with a gem! Gems left: " ..#self.gems, duration=5.0})             
            self.GemQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, #self.gems)
            self.gemSubQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, #self.gems)

             if #self.gems == 0 then
                GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
                Timers:RemoveTimers(true)
            end
        end

        --kill any creep that makes it all the way back to the start
        npc:AddNoDraw()
        npc:ForceKill(false)
    end
end

-- This function is called whenever any player sends a chat message to team or All
function GameMode:OnPlayerChat(keys)
  local teamonly = keys.teamonly
  local userID = keys.userid
  local playerID = self.vUserIds[userID]:GetPlayerID()

  local text = keys.text
end