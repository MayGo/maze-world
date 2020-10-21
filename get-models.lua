local gameModels = remodel.readPlaceFile('./raw-assets/game-models.rbxlx')
local gamePlace = remodel.readPlaceFile('./raw-assets/game-place.rbxlx')

-- If the directory does not exist yet, we'll create it.
local modelDir = './models'
remodel.createDirAll(modelDir)

local folders =
	{ 'Money', 'Pets', 'Prefabs', 'Walls', 'Collectables', 'Misc', 'Trails', 'FallItems' }

for _, folder in ipairs(folders) do
	for _, model in ipairs(gameModels.Workspace[folder]:GetChildren()) do
		remodel.createDirAll(modelDir .. '/' .. folder)
		-- Save out each child as an rbxmx model
		remodel.writeModelFile(model, modelDir .. '/' .. folder .. '/' .. model.Name .. '.rbxmx')
	end
end

remodel.writeModelFile(gamePlace.Workspace.Terrain, './PlaceTerrain.rbxmx')
remodel.writeModelFile(gamePlace.Workspace.Place, './Place.rbxmx')