CritterModels = {
	"models/props_gameplay/pig.vmdl",
	"models/props_gameplay/frog.vmdl",
	"models/props_gameplay/roquelaire/roquelaire.vmdl",
	"models/props_gameplay/sheep01.vmdl",
	"models/props_gameplay/chicken.vmdl",
	"models/props_wildlife/wildlife_turtle001.vmdl",
	"models/props_wildlife/wildlife_rat001.vmdl",
	"models/props_wildlife/wildlife_spider001.vmdl",		
	"models/props_wildlife/wildlife_birdsmall002.vmdl",
	"models/props_wildlife/wildlife_birdlarge001.vmdl",
	"models/props_wildlife/wildlife_bat002.vmdl",
	"models/props_wildlife/wildlife_butterfly003.vmdl",
	"models/props_wildlife/wildlife_butterfly002.vmdl",
	"models/props_wildlife/wildlife_butterfly001.vmdl",
	"models/props_wildlife/wildlife_dragonfly001.vmdl",
	"models/props_wildlife/wildlife_caterpillar001.vmdl",
	"models/props_wildlife/wildlife_frog002.vmdl"
}


function Spawn(keys)
	local count = #CritterModels
	local rnd = math.random(1, count)
	local model = CritterModels[rnd]
	
	Timers:CreateTimer(0.1, function()
		if model == nil then print(rnd) end
		print("critter spawned with model", model)
		thisEntity:SetOriginalModel(model)
		thisEntity:SetModel(model)	
		thisEntity:SetModelScale(1.0)			
	end)
	
end