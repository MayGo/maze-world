local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local M = require(Modules.M)
local Transporter = require(Modules.src.Transporter)
local RoomManager = require(Modules.src.RoomManager)
local assets = require(Modules.src.assets)
local initializePlayerInventory = require(Modules.src.actions.inventory.initializePlayerInventory)

local equipPlayer = require(Modules.src.thunks.equipPlayer)
local playerDied = require(Modules.src.actions.rooms.playerDied)
local clientReset = require(Modules.src.actions.toClient.clientReset)
local clientSendNotification = require(Modules.src.actions.toClient.clientSendNotification)

local addItemsToPlayerInventory = require(Modules.src.actions.inventory.addItemsToPlayerInventory)

local Leaderboards = require(Modules.src.Leaderboards)
local GameDatastore = require(Modules.src.GameDatastore)
local GamePasses = require(Modules.src.GamePasses)
local InventoryObjects = require(Modules.src.objects.InventoryObjects)

local function connectPlayer(player)
	return function(store)
		logger:i('Connecting player:' .. player.Name)
		local playerId = tostring(player.UserId)
		spawn(function()
			Leaderboards:connectPlayerVisits(player, store)
			Leaderboards:connectMostCoins(player)
		end)

		RoomManager:initPlayerCollisionGroup(playerId)

		player.CharacterAppearanceLoaded:Connect(function(character)
			logger:d('CharacterAppearanceLoaded:', character)
			local function getGamePass(obj, product)
				local productId = product.id
				local hasGamePass = GamePasses:hasGamePass(player, productId)
				if hasGamePass then
					logger:d('Add gamePass to inventory:' .. productId)
					obj[productId] = InventoryObjects.AllObjects[productId]
				end

				return obj
			end

			local inventoryItems = M.reduce(InventoryObjects.GamePassObjects, getGamePass, {})

			if M.count(inventoryItems) > 0 then
				store:dispatch(addItemsToPlayerInventory(tostring(player.UserId), inventoryItems))
			end

			local state = store:getState()
			local inventory = state.playerInventories[playerId]
			RoomManager:addToCharacter(character, inventory, playerId)

			local petIds = GameDatastore:getEquippedPets(player)

			logger:d('DataStore:Pet Equipped status updated to: ', petIds)
			store:dispatch(equipPlayer(player, petIds))
		end)

		player.CharacterAdded:Connect(function(character)
			logger:d('CharacterAdded:', character)

			character:WaitForChild('Humanoid').Died:Connect(function()
				logger:i(player.Name .. ' has died!')

				store:dispatch(playerDied(player))
				store:dispatch(clientReset(player))
				store:dispatch(
					clientSendNotification(player, 'You Died', assets.faces['cartoon-face-died'])
				)

				player:LoadCharacter()
			end)
		end)

		store:dispatch(initializePlayerInventory(tostring(player.UserId)))

		local l = Instance.new('Folder', player)
		l.Name = 'leaderstats'
		local coinStat = Instance.new('NumberValue', l)

		----------------------------------------
		-- Give money
		----------------------------------------
		coinStat.Name = 'Coins'

		local function updateCoinsInLeaderstats(value)
			logger:d('DataStore: Coin store updated with value:', value)
			coinStat.Value = value
		end

		updateCoinsInLeaderstats(GameDatastore:getCoins(player))
		GameDatastore:onCoinsUpdated(player, updateCoinsInLeaderstats)

		---------------------------------
		---- OHTER
		--------------------------------

		logger:d('Loading character for player:' .. player.Name)
		Transporter:placePlayerToHomeSpawn(player)
		player:LoadCharacter()
	end
end

return connectPlayer