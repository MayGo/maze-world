local AudioPlayer = {}

-- Roblox services
local ContentProvider = game:GetService('ContentProvider')

-- Function to preload audio assets
AudioPlayer.preloadAudio = function(assetArray)
	local audioAssets = {}

	-- Add new "Sound" assets to "audioAssets" array
	for name, audioID in pairs(assetArray) do
		local audioInstance = Instance.new('Sound')
		audioInstance.SoundId = 'rbxassetid://' .. audioID
		audioInstance.Name = name
		audioInstance.Parent = game.Workspace
		table.insert(audioAssets, audioInstance)
	end

	local success, assets = pcall(function()
		ContentProvider:PreloadAsync(audioAssets)
	end)
end

-- Function to play an audio asset
AudioPlayer.playAudio = function(assetName)
	local audio = game.Workspace:FindFirstChild(assetName)
	if not audio then
		warn('Could not find audio asset: ' .. assetName)
		return
	end
	if not audio.IsLoaded then
		audio.Loaded:wait()
	end
	audio:Play()
end

return AudioPlayer