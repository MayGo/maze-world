local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local STORE_COINS = 'coins'
local STORE_EQUIPPED = 'equipped2'
local STORE_PURCHASE_HISTORY = 'purchase_history'
local STORE_INVENTORY = 'inventory'
local STORE_SLOTS_COUNT = 'slotsCount'
local STORE_LAST_LOGIN = 'lastLogin'

local DataStore2 = require(Modules.DataStore2)
local M = require(Modules.M)
local GlobalConfig = require(Modules.src.GlobalConfig)

-- Always "combine" any key you use! To understand why, read the "Gotchas" page.
DataStore2.Combine('DATA', STORE_COINS)
DataStore2.Combine('DATA', STORE_EQUIPPED)
DataStore2.Combine('DATA', STORE_INVENTORY)
DataStore2.Combine('DATA', STORE_SLOTS_COUNT)
DataStore2.Combine('DATA', STORE_LAST_LOGIN)
DataStore2.Combine('DATA', STORE_PURCHASE_HISTORY)

local GameDatastore = {}

function GameDatastore:getCoins(player)
	local datastore = DataStore2(STORE_COINS, player)
	local coins = datastore:Get(GlobalConfig.DEFAULT_PLAYER_COINS)

	logger:d('DataStore: Get player ' .. player.Name .. ' coins:' .. tonumber(coins))
	return coins
end

function GameDatastore:onCoinsUpdated(player, coinsUpdated)
	local datastore = DataStore2(STORE_COINS, player)
	logger:d('DataStore: Player ' .. player.Name .. ' coins updated')
	datastore:OnUpdate(coinsUpdated)
end
function GameDatastore:coinsAfterSave(player, coinsSaved)
	local datastore = DataStore2(STORE_COINS, player)
	logger:d('DataStore: Player ' .. player.Name .. ' coins after save')
	datastore:AfterSave(coinsSaved)
end

function GameDatastore:decrementCoins(player, coinsToSubtract)
	local datastore = DataStore2(STORE_COINS, player)

	if coinsToSubtract <= 0 then
		logger:e('Invalid amount subtracted:' .. tostring(coinsToSubtract))
	end

	local playerCoins = GameDatastore:getCoins(player)
	if playerCoins >= coinsToSubtract then
		logger:d(
			'DataStore: Player ' .. player.Name .. ' wallet subtracted ' .. tostring(
				coinsToSubtract
			)
		)
		datastore:Increment(-coinsToSubtract)
	else
		logger:d('DataStore: Player ' .. player.Name .. ' has not have enough money.')
	end

	return playerCoins - coinsToSubtract
end

function GameDatastore:incrementCoins(player, coinsToAdd)
	local datastore = DataStore2(STORE_COINS, player)

	if coinsToAdd <= 0 then
		logger:e('Invalid amount added:' .. tostring(coinsToAdd))
	end

	logger:d('DataStore: Player ' .. player.Name .. ' wallet added ' .. tostring(coinsToAdd))
	datastore:Increment(coinsToAdd)
end

----

function GameDatastore:getSlotsCount(player)
	local datastore = DataStore2(STORE_SLOTS_COUNT, player)
	local slotsCount = datastore:Get(GlobalConfig.DEFAULT_PLAYER_SLOTS)

	logger:d('DataStore: Get player ' .. player.Name .. ' slotsCount:', slotsCount)
	return slotsCount
end

----

function GameDatastore:onEquippedPetsUpdated(player, equippedUpdated)
	local datastore = DataStore2(STORE_EQUIPPED, player)
	logger:d('DataStore: player ' .. player.Name .. ' pets updated')
	datastore:OnUpdate(equippedUpdated)
end

function GameDatastore:getEquippedPets(player)
	local datastore = DataStore2(STORE_EQUIPPED, player)
	local petIds = datastore:Get({})

	logger:d('DataStore: player ' .. player.Name .. ' equipping pets', petIds)
	return petIds
end

function GameDatastore:setEquippedPet(player, id)
	local datastore = DataStore2(STORE_EQUIPPED, player)
	local playerSlotsCount = GameDatastore:getSlotsCount(player)

	if #GameDatastore:getEquippedPets(player) < playerSlotsCount then
		datastore:Update(function(currentPets)
			logger:d('DataStore: player ' .. player.Name .. ' equipping pet', id)
			return M.unique(M.push(currentPets, id))
		end)
	end
end

function GameDatastore:unsetEquippedPet(player, id)
	local datastore = DataStore2(STORE_EQUIPPED, player)

	datastore:Update(function(currentPets)
		logger:d('DataStore: player ' .. player.Name .. ' removing pet', id)
		return M.unique(M.pull(currentPets, id))
	end)
end

function GameDatastore:unsetAllEquippedPet(player)
	local datastore = DataStore2(STORE_EQUIPPED, player)

	datastore:Set({})
end

----

function GameDatastore:getLastLogin(player)
	local datastore = DataStore2(STORE_LAST_LOGIN, player)
	local lastLogin = datastore:Get(os.time())

	logger:d('DataStore: player ' .. player.Name .. ' Last login', lastLogin)
	return lastLogin
end

function GameDatastore:setLastLogin(player, id)
	local datastore = DataStore2(STORE_LAST_LOGIN, player)
	logger:d('DataStore: set player ' .. player.Name .. ' Last login')

	datastore:Set(os.time())
end

-- INVENTORY

function GameDatastore:setInventoryItem(player, id)
	local datastore = DataStore2(STORE_INVENTORY, player)

	datastore:Update(function(currentInventory)
		logger:d('DataStore: player ' .. player.Name .. ' updating inventory id', id)
		return M.unique(M.push(currentInventory, id))
	end)
end

function GameDatastore:unsetInventoryItem(player, id)
	local datastore = DataStore2(STORE_INVENTORY, player)

	datastore:Update(function(currentPets)
		logger:d('Removing inventory with id:', id)
		return M.unique(M.pull(currentPets, id))
	end)
end

function GameDatastore:getInventory(player)
	local datastore = DataStore2(STORE_INVENTORY, player)
	local inventory = datastore:Get(GlobalConfig.DEFAULT_PLAYER_INVENTORY)

	logger:d('DataStore: Get player ' .. player.Name .. ' inventory')
	return inventory
end

function GameDatastore:onInventoryUpdated(player, inventoryUpdated)
	local datastore = DataStore2(STORE_INVENTORY, player)

	logger:d('DataStore: player ' .. player.Name .. ' inventory updated')
	datastore:OnUpdate(inventoryUpdated)
end
-- Developer product purchase history

function GameDatastore:setProductPurchased(player, purchaseId)
	local datastore = DataStore2(STORE_PURCHASE_HISTORY, player, purchaseId)
	datastore:Update(function(current)
		logger:d('DataStore: player ' .. player.Name .. ' adding receipt', purchaseId)
		return M.push(current, purchaseId)
	end)
end

function GameDatastore:hasProductPurchased(player, purchaseId)
	local datastore = DataStore2(STORE_PURCHASE_HISTORY, player, purchaseId)
	local current = datastore:Get({})
	return M.include(current, purchaseId)
end

return GameDatastore