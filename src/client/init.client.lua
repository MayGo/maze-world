--[[
	This is the entry-point for the client.

	It mostly just contains setup code for hot-reloading, which is used in
	development only.
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterPlayer = game:GetService('StarterPlayer')

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