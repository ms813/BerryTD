-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)

  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheResource("model_folder", "particles/heroes/antimage", context)
  PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  PrecacheModel("models/heroes/viper/viper.vmdl", context)

  -- Sounds can precached here like anything else
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)

  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)

  PrecacheResource("particle", "particles/golden_dragonfire/lina_spell_dragon_slave.vpcf", context)

  --Precache towers
  for i, tower in pairs(GameMode.TowerList) do    
    PrecacheUnitByNameSync(tower, context)
  end

  --Precache defenders
  for i, defender in pairs(GameMode.DefenderList) do
    for j=0,6 do  
      PrecacheUnitByNameSync(defender..j, context)      
    end
  end

  --Precache creeps
  for i, creep in pairs(GameMode.CreepList) do
    PrecacheUnitByNameSync(creep, context)
  end
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:InitGameMode()

  LinkLuaModifier("modifier_movespeed_cap", "unit_scripts/movespeed_cap.lua", LUA_MODIFIER_MOTION_NONE)
end

GameMode.TowerList = {
  "tower_sniper",
  "tower_tackshooter",
  "tower_demon",
  "tower_catapult",
  "tower_dragon",
  "tower_laser",
  "tower_soul_siphon",
  "barracks_melee",
  "barracks_magic",
  "barracks_ranged",
  "barracks_utility",
  "tower_iceberg",
  "tower_tesla_coil",
  "tower_tombstone"
}

GameMode.DefenderList = {
  "defender_melee_" ,
  "defender_ranged_",
  "defender_magic_",
  "defender_utility_"
}

GameMode.CreepList = {
  "creep_warrior_0",
  "creep_warrior_1",
  "creep_archer_0",
  "creep_archer_1",
  "creep_sprinter_0",
  "creep_sprinter_1",
  "creep_knight_0",
  "creep_knight_1",
  "creep_critter_0",
  "creep_hive_0",
  "creep_splitter_0",
  "creep_splitter_1",
  "creep_splitter_2",
  "creep_splitter_3",
  "creep_saint_0",
  "creep_saint_1",
  "creep_healer_0",
  "creep_healer_1",
  "creep_voidwalker_0",
  "creep_voidwalker_1",
  "creep_ninja_0",
  "creep_ninja_1",
  "creep_zealot_0",
  "creep_zealot_1"
}