local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local InventoryObjects = require(Modules.src.objects.InventoryObjects)

local function shop(state, action)
	state = state or { items = InventoryObjects.ShopObjects }
	return state
end

return shop