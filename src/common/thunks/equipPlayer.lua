local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local PetManager = require(Modules.src.PetManager)
local Print = require(Modules.src.utils.Print)
local clientEquipped = require(Modules.src.actions.toClient.clientEquipped)
local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local M = require(Modules.M)

local playerSlotsCount = 3

local function equipPlayer(player, petIds)
	return function(store)
		local function getShopObjects(petId)
			return InventoryObjects.PetObjects[petId]
		end
		local petObjects = M.map(petIds, getShopObjects)

		if petObjects then
			PetManager:addToCharacter(petObjects, player.Character, playerSlotsCount)
			store:dispatch(clientEquipped(tostring(player.UserId), petIds))
		else
			logger:w('No pet object found')
		end
	end
end

return equipPlayer