local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Dict = require(Modules.src.utils.Dict)
local None = require(Modules.src.utils.None)

local function playerInventories(state, action)
	state = state or {}

	if action.type == 'initializePlayerInventory' then
		local existingPlayer = state[action.playerId]

		if existingPlayer ~= nil then
			return state
		end

		return Dict.join(state, {
			[action.playerId] = {},
		})
	elseif action.type == 'addItemsToPlayerInventory' then
		local inventory = state[action.playerId]

		if inventory == nil then
			local message = ('No player with the ID %q'):format(tostring(action.playerId))
			warn(message)

			return state
		end

		return Dict.join(state, { [action.playerId] = Dict.join(inventory, action.items) })
	elseif action.type == 'removeItemFromPlayerInventory' then
		local inventory = state[action.playerId]

		if inventory == nil then
			local message = ('No player with the ID %q'):format(tostring(action.playerId))
			warn(message)

			return state
		end

		return Dict.join(state, { [action.playerId] = Dict.join(inventory, { [action.itemId] = None }) })
	end

	return state
end

return playerInventories