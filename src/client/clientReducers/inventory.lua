--[[
	A client's view of their inventory uses a different reducer than the
	server's view of all client's inventories.
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Dict = require(Modules.src.utils.Dict)
local None = require(Modules.src.utils.None)

local function inventory(state, action)
	state = state or {}

	if action.type == 'addItemsToPlayerInventory' then
		return Dict.join(state, action.items)
	elseif action.type == 'removeItemFromPlayerInventory' then
		return Dict.join(state, { [action.itemId] = None })
	end

	return state
end

return inventory