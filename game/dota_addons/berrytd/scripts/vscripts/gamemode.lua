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
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
  ]]
  function GameMode:OnGameInProgress()
  	DebugPrint("[BAREBONES] The game has officially begun")
  	GameMode:PopulateWayPoints()

   local repeat_interval = 30 -- Rerun this timer every *repeat_interval* game-time seconds   

   Timers:CreateTimer(5, function()
   	return GameMode:TimedTick()
   	end)

   self.currentWave = 1
   GameMode:SpawnWave(self.currentWave)
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

  self.numCreepsAlive = 0
  self.numCreepsSpawned = 0
  self.currentWave = 0
  self.maxWave = #waveTable;
  self.currentLives = 50 
  self.players = {}
  self.base = Entities:FindByName(nil, "dota_goodguys_fort")

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

WAYPOINTS = {}
function GameMode:PopulateWayPoints()  
	local waypoint_count = 20

	for i=0, waypoint_count-1 do
		WAYPOINTS[i] = Entities:FindByName(nil, "creep_waypoint_" .. i):GetAbsOrigin()       		 
	end   
--[[
    for k,v in pairs(WAYPOINTS) do
        print(k,v)
    end
    --]]
end

function GameMode:SpawnWave(waveIndex)
  Notifications:TopToAll({text="Starting wave "..waveIndex, duration=5.0, color="yellow"})   
	local spawnLocation = Entities:FindByName(nil, "creep_spawner")
    --waveTable is defined in waves.lua

    local wave = waveTable[waveIndex]

    --start a timer for each group of creeps in the wave
    for i, group in pairs(wave.creepGroups) do

        for k,v in pairs(group) do print(k) end
        --keep track of the number of subgroups spawned
        group.subGroupCount = 0

        Timers:CreateTimer(group.spawnDelay, function()
            --spawn a subgroup of creeps from this group
            for i=0, group.spawnGroupSize -1 do
                local creep = CreateUnitByName(group.creep,
                                                spawnLocation:GetAbsOrigin(),
                                                true,
                                                nil,
                                                nil,
                                                DOTA_TEAM_NEUTRALS)

                --order the creep to run towards the throne
                creep:SetInitialGoalEntity(self.base)

                --cache the creeps attack capability for use in aggro AI later
                creep.default_attack_capability = creep:GetAttackCapability()

                --keep track of how many creeps are alive on the map at once
                self.numCreepsAlive = self.numCreepsAlive + 1
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

function GameMode:TimedTick()
	--print("timed tick, current wave:",self.currentWave, ", numCreepsSpawned:", self.numCreepsSpawned, ", numCreepsAlive:" , self.numCreepsAlive)	

    local unitsAtEnd = GameMode:checkCreepsReachedEnd()    
    for _, unit in pairs(unitsAtEnd) do
        unit:Kill(nil, self.base)
    end
	
	return 0.5
end

function GameMode:checkCreepsReachedEnd()
local endPos = self.base:GetAbsOrigin()
local radius = 500;


  local unitsAtEnd = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,
                    endPos, 
                    nil,
                    radius,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_CLOSEST,
                    false)   
    
    return unitsAtEnd
end