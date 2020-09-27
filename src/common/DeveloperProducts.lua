local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Modules = ReplicatedStorage:WaitForChild('Modules')
local Players = game:GetService('Players')
local logger = require(Modules.src.utils.Logger)

local GameDatastore = require(Modules.src.GameDatastore)
local MarketplaceService = game:GetService('MarketplaceService')

local COINS_1 = 966181357
local COINS_2 = 1086783078
local COINS_3 = 1086783194
local COINS_4 = 1086783346

local DeveloperProducts = {
	COINS_1 = COINS_1,
	COINS_2 = COINS_2,
	COINS_3 = COINS_3,
	COINS_4 = COINS_4,
}

local rewards = {
	[COINS_1] = 1000,
	[COINS_2] = 10000,
	[COINS_3] = 100000,
	[COINS_4] = 1000000,
}

local productFunctions = {}

productFunctions[COINS_1] = function(receipt, player)
	GameDatastore:incrementCoins(player, rewards[COINS_1])
	return true
end
productFunctions[COINS_2] = function(receipt, player)
	GameDatastore:incrementCoins(player, rewards[COINS_2])
	return true
end
productFunctions[COINS_3] = function(receipt, player)
	GameDatastore:incrementCoins(player, rewards[COINS_3])
	return true
end
productFunctions[COINS_4] = function(receipt, player)
	GameDatastore:incrementCoins(player, rewards[COINS_4])
	return true
end

function DeveloperProducts:promptPurchase(productId)
	local player = Players.LocalPlayer

	MarketplaceService:PromptProductPurchase(player, productId)
end

function DeveloperProducts:getProduct(productId)
	local product = MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product)

	return {
		name = product.Name,
		description = product.Description,
		price = product.PriceInRobux,
		isDeveloperProduct = true,
	}
end

function DeveloperProducts.processReceipt(receiptInfo)
	-- Find the player who made the purchase in the server
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- The player probably left the game
		-- If they come back, the callback will be called again
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Determine if the product was already granted by checking the data store

	local purchased = GameDatastore:hasProductPurchased(player, receiptInfo.PurchaseId)

	if purchased then
		logger:d('Already purchased product ' .. tostring(receiptInfo.PurchaseId))
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local applyProductHandler = productFunctions[receiptInfo.ProductId]

	if not applyProductHandler then
		logger:e('No product handler for ' .. tostring(receiptInfo.ProductId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- Call the handler function and catch any errors
	local success, result = pcall(applyProductHandler, receiptInfo, player)
	if not success or not result then
		logger:w(
			'Error occurred while processing a product purchase. ProductId:' .. tostring(
				receiptInfo.ProductId
			) .. '. Player:' .. tostring(player.UserId),
			result
		)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Record transaction in data store so it isn't granted again
	GameDatastore:setProductPurchased(player, receiptInfo.PurchaseId)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

return DeveloperProducts