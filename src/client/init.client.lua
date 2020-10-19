--[[
	This is the entry-point for the client.

	It mostly just contains setup code for hot-reloading, which is used in
	development only.
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local StarterPlayer = game:GetService('StarterPlayer')

local AudioPlayer = require(Modules.src.AudioPlayer)

AudioPlayer.preloadAudio({
--Lucid_Dream = 1837103530,
	Scary_bg = 1838699126,
	Desert_Sands = 1848350335,
	Simple_Click = 3061551819,
	Notification = 2296072875,
	Finish = 5105488525,
	Coin_Collect = 930700226,
})

AudioPlayer.playBackgroundAudio('Desert_Sands')

local loadingScreen = require(Modules.src.gui.LoadingScreen)
local Players = game:GetService('Players')
local localPlayer = Players.LocalPlayer

loadingScreen:show(localPlayer)

local HotReloadClient = require(ReplicatedStorage.HotReloadClient)

local savedState = HotReloadClient.getSavedState()
local savedActions = {}

if savedState ~= nil then
	savedActions = savedState.savedActions
end

local context = {
	destructors = {},
	savedActions = savedActions,
	running = true,
	wasReloaded = savedState ~= nil,
}

HotReloadClient.start({
	getNext = function()
		return StarterPlayer.StarterPlayerScripts.clientSrc:Clone()
	end,
	getCurrent = function()
		return script
	end,
	beforeUnload = function()
		context.running = false

		for _, destructor in ipairs(context.destructors) do
			local ok, result = pcall(destructor)

			if not ok then
				warn('Failure during destruction: ' .. result)
			end
		end

		return { savedActions = context.savedActions }
	end,
})

local main = require(script.main)
main(context)

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

loadingScreen:hide(character)