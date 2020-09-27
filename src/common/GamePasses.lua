local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PhysicsService = game:GetService('PhysicsService')

local Modules = ReplicatedStorage:WaitForChild('Modules')
local Players = game:GetService('Players')
local logger = require(Modules.src.utils.Logger)
local GhostAbility = require(Modules.src.GhostAbility)
local MarketplaceService = game:GetService('MarketplaceService')

local HIGH_JUMP_ID = '9544648'
local GHOST_MODE_ID = '9566643'
local GamePasses = {
	HIGH_JUMP_ID = HIGH_JUMP_ID,
	GHOST_MODE_ID = GHOST_MODE_ID,
}

function GamePasses:addAbility(player, productId)
	if player.Character then
		local char = player.Character
		local humanoid = char:FindFirstChild('Humanoid')
		if HIGH_JUMP_ID == productId then
			logger:i('Adding High Jump ability to player')
			humanoid.JumpPower = 100
		elseif GHOST_MODE_ID == productId then
			logger:d('Has ghost mode')
		end
	else
		logger:d('No Character found for player:' .. player.Name)
	end
end

function GamePasses:hasGamePass(player, productId)
	local hasPass = false

	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, productId)
	end)

	if not success then
		logger:w('Error while checking if player has pass: ' .. tostring(message))
		return
	end

	if hasPass == true then
		print(player.Name .. ' owns the game pass with ID ' .. productId)
		GamePasses:addAbility(player, productId)
		return true
	end
	return false
end

function GamePasses:promptPurchase(productId)
	local player = Players.LocalPlayer
	local hasPass = false

	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, productId)
	end)

	if not success then
		logger:w('Error while checking if player has productId: ' .. tostring(message))
		return
	end

	if hasPass then
		-- Player already owns the game pass; tell them somehow
		logger:e('Player ' .. player.Name .. ' already owns pass')
	else
		MarketplaceService:PromptGamePassPurchase(player, productId)
	end
end

function GamePasses:getGamePass(productId)
	local product = MarketplaceService:GetProductInfo(productId, Enum.InfoType.GamePass)

	return {
		icon = 'rbxassetid://' .. product.IconImageAssetId,
		name = product.Name,
		description = product.Description,
		price = product.PriceInRobux,
		isGhost = (productId == GHOST_MODE_ID),
		isGamePass = true,
	}
end

return GamePasses