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
	Darkness_bg = 265292123,
	Desert_Sands = 1848350335,
	Simple_Click = 3061551819,
	Notification = 2296072875,
	Finish = 5105488525,
	Evil_Laugh = 4515583231,
	Charlie_Head = 1051288871,
	Coin_Collect = 930700226,
	Effect_Mouse = 1329112776,
	Effect_Scream1 = 932049501,
	Effect_Scream2 = 3382463374,
	Effect_Scream3 = 3806051152,
	Effect_Scream4 = 1492382312,
	Effect_Scream5 = 3382463374,
	Effect_Chainsaw1 = 5593083406,
	Effect_Chainsaw2 = 3698278783,
	Effect_Whisper1 = 244480574,
	Effect_Whisper2 = 5362062455,
	Effect_Whisper3 = 441243549,
	Effect_ISeeYou = 913821443,
	Effect_Fart = 251309043,
	Effect_Barking = 4058571629,
	Effect_WindHowl = 131104992,
	Effect_WolfHowl = 345091806,
	Effect_Snarl = 1843130339,
	Effect_WolfSnarl = 357353759,
	Effect_ZombieSnarl = 4974305427,
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