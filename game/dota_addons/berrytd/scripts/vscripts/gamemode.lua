-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
	DebugPrint( '[BAREBONES] creating barebones game mode' )
	_G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')


-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
require('waves')
require('abilities')

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
  ]]
  function GameMode:PostLoadPrecache()    
  	DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
  
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
  ]]
  function GameMode:OnFirstPlayerLoaded()
  	DebugPrint("[BAREBONES] First Player has loaded")    
  end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
  ]]
  function GameMode:OnAllPlayersLoaded()
  	DebugPrint("[BAREBONES] All Players have loaded into the game")    
  end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
  ]]
  function GameMode:OnHeroInGame(hero)
  	DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to the specified amount of unreliable gold
  hero:SetGold(10000, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  --local item = CreateItem("item_example_item", hero, hero)
  --hero:AddItem("item_blink")
  hero:AddItemByName("item_blink")


  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]

  lvlUpUnitAbilities(hero)
  hero:SetAbilityPoints(0)
  table.insert(self.players, hero)  
  
  GameMode:InitTowerSpawns(hero)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
  ]]
function GameMode:OnGameInProgress()  
    Timers:CreateTimer(function()
   	    return GameMode:CheckGems()
   	end)      

    self:StartInterwaveTimeout(self.currentWave)
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
	GameMode = self
	DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/gamemode to see/modify the exact code
    GameMode:_InitGameMode()

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  -- Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

    --initialise the list of waypoints
    self.WAYPOINTS = {}
    local waypoint = Entities:FindByName(nil, "creep_waypoint_0")
    local i = 0
    while waypoint ~= nil do
        table.insert(self.WAYPOINTS, waypoint)
        i = i + 1
        waypoint = Entities:FindByName(nil, "creep_waypoint_"..i)
    end

    self.numCreepsAlive = 0  
    self.currentWave = 0
    self.maxWave = #waveTable;  
    self.players = {}
    self.time_between_waves = 5
    self.creep_spawner = Entities:FindByName(nil, "creep_spawner")
    self.gem_return_timeout = 60

    local gemSpawn = self.WAYPOINTS[#self.WAYPOINTS]:GetAbsOrigin()
    GameMode:InitGems(gemSpawn)

    DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
	print( '******* Example Console Command ***************' )
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
            -- Do something here for the player who called this command
            PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
        end
    end

print( '*********************************************' )
end

function GameMode:SpawnWave(waveIndex)	
    --waveTable is defined in waves.lua
    local wave = waveTable[waveIndex]
    self.creep_kills = 0

    --calculate the total number of creeps in the wave
    for i, group in pairs(wave.creepGroups) do
        self.numCreepsAlive = self.numCreepsAlive + group.numTotal
    end
    
    --set up a quest to keep track of kills
    self.Quest = SpawnEntityFromTableSynchronous("quest", {name="wave", title= "#QuestWave"})    
    self.subQuest = SpawnEntityFromTableSynchronous(
        "subquest_base",
        {
            show_progress_bar = true,
            progress_bar_hue_shift = -119
        }
    )
    self.Quest.max_creeps = self.numCreepsAlive
    self.Quest:AddSubquest(self.subQuest)    
    self.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 0)
    self.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, self.Quest.max_creeps)
    self.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_ROUND, waveIndex)

    self.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 0)
    self.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, self.Quest.max_creeps)

    --start a timer for each group of creeps in the wave
    for i, group in pairs(wave.creepGroups) do       
        --keep track of the number of subgroups spawned
        group.subGroupCount = 0

        Timers:CreateTimer(group.spawnDelay, function()
            --spawn a subgroup of creeps from this group
            for i=0, group.spawnGroupSize -1 do
                local creep = CreateUnitByName(
                    group.creep,
                    self.creep_spawner:GetAbsOrigin(),
                    true,
                    nil,
                    nil,
                    DOTA_TEAM_BADGUYS)

                --order the creep to run towards the throne
                local path_start = Entities:FindByName(nil, "creep_waypoint_0")
                
                creep:SetInitialGoalEntity(path_start)           

                --cache the creeps attack capability for use in aggro AI later
                creep.default_attack_capability = creep:GetAttackCapability()
                if creep.default_attack_capability == DOTA_UNIT_CAP_MELEE_ATTACK then
                  creep:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
                end

                --apply phased modifier for a second so creeps can untangle themselves at the start
                creep:AddNewModifier(creep, nil, "modifier_phased", {})
                creep.next_waypoint = Entities:FindByName(nil, "creep_waypoint_0")
                creep.hasGem = false  
                creep:SetMustReachEachGoalEntity(true)                 
            end
            group.subGroupCount = group.subGroupCount + 1

            --if we have spawned all the creeps in this group stop the timer
            if group.subGroupCount >= (group.numTotal / group.spawnGroupSize) then
                return nil
            else
                --if there are still creeps in this group to spawn,
                --wait the specified interval then spawn the next subgroup
                return group.spawnGroupInterval
            end
        end) --timer
    end
end

function GameMode:CheckGems()
	
    --check if creeps are near any of the gems
    local radius = 300
    for i, gem in pairs(self.gems) do
        local unitsNearGem = FindUnitsInRadius(
            DOTA_TEAM_BADGUYS,
            gem.position, 
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false) 

        if #unitsNearGem > 0 then                        
            for i, unit in pairs(unitsNearGem) do
                if not unit.hasGem and not gem.pickedUp then
                    unit:PickupDroppedItem(gem:GetContainer())
                end
            end            
        end
    end   

	return 0.5
end

function GameMode:InitTowerSpawns(owner)
    local spawns = Entities:FindAllByName("tower_spawn_site")
    for i, spawn_site in pairs(spawns) do        
        local tower_stub = GameMode:BuildTowerSpawn(spawn_site:GetAbsOrigin(), owner)         
    end
end

function GameMode:BuildTowerSpawn(pos, owner)
    local spawn = CreateUnitByName(
        "tower_spawn_site",
        pos,
        true,
        owner,
        owner,
        DOTA_TEAM_GOODGUYS)
    spawn:SetControllableByPlayer(owner:GetPlayerID(), false)
    return spawn
end

--initialises the gems, places them on the map and sets up the quest keeping track of how many are left
function GameMode:InitGems(spawnPos)
    self.gems = {}
    local max_gems = 10
    local radius = 150
    for i=1, max_gems do
        --create the item
        local gem = CreateItem("item_berrytd_gem", nil, nil)
        gem:SetPurchaseTime(0)
        
        --put the gems in a circle around the spawn
        local x = math.sin((i/max_gems) * 2 * math.pi) * radius
        local y = math.cos((i/max_gems) * 2 * math.pi) * radius
        local destination = spawnPos + Vector(x,y,0)
        --actually create the physical item container
        local drop = CreateItemOnPositionForLaunch(spawnPos, gem)        
        gem:LaunchLoot(false, 300, 1, destination)

        --cache some values so we can reset the gem later
        gem.position = destination
        gem.initial_position = destination
        gem.pickedUp = false        

        table.insert(self.gems, gem)        
    end

    --set up the quest bar keeping track of remaining gems
    self.GemQuest = SpawnEntityFromTableSynchronous("quest", {name="QuestGems", title = "#QuestGemsRemaining"})    
    self.gemSubQuest = SpawnEntityFromTableSynchronous(
        "subquest_base",
        {
            show_progress_bar = true,
            progress_bar_hue_shift = 50
        }
    )

    self.GemQuest:AddSubquest(self.gemSubQuest)
    self.GemQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, max_gems)
    self.GemQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, max_gems)
    self.gemSubQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, max_gems)
    self.gemSubQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, max_gems)

end

--starts a countdown until the next wave spawns
function GameMode:StartInterwaveTimeout(waveNumber)
    self.Quest = SpawnEntityFromTableSynchronous("quest", {name="interwave", title = "#QuestWaveTimeout"})
    
    self.Quest.EndTime = self.time_between_waves
    self.subQuest = SpawnEntityFromTableSynchronous(
        "subquest_base",
        {
            show_progress_bar = true,
            progress_bar_hue_shift = -119
        }
    )
    self.Quest:AddSubquest(self.subQuest)

    self.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self.time_between_waves)
    self.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, self.time_between_waves)

    --plus one is so the quest displays the next round
    self.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_ROUND, waveNumber + 1)

    self.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self.time_between_waves)
    self.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, self.time_between_waves)

    local interval = 1
    Timers:CreateTimer(1, function()        
        self.Quest.EndTime = self.Quest.EndTime - interval
        self.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self.Quest.EndTime)
        self.subQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self.Quest.EndTime)

        --finish timeout quest when countdown hits 0
        if self.Quest.EndTime <= 0 then
            EmitGlobalSound("Tutorial.Quest.complete_01")            
            self.Quest:CompleteQuest()

            --increment the current wave by one and start the next wave
            self.currentWave = self.currentWave + 1
            self:SpawnWave(self.currentWave)              
            return nil
        else
            return interval
        end
    end) 
end
