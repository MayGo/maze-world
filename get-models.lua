local game = remodel.readPlaceFile('raw-assets/game-models-and-place.rbxlx')

-- If the directory does not exist yet, we'll create it.
remodel.createDirAll('models')

local folders = { 'Money', 'Pets', 'Prefabs', 'Walls', 'Collectables', 'Misc' }

for _, folder in ipairs(folders) do
	for _, model in ipairs(game.Workspace[folder]:GetChildren()) do
		remodel.createDirAll('models/' .. folder)
		-- Save out each child as an rbxmx model
		remodel.writeModelFile(model, 'models/' .. folder .. '/' .. model.Name .. '.rbxmx')
	end
end

remodel.writeModelFile(game.Workspace.Place, 'Place.rbxmx')