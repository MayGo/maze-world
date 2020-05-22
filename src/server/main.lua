local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local MarketplaceService = game:GetService('MarketplaceService')
local Players = game:GetService('Players')

local M = require(Modules.M)
local Rodux = require(Modules.Rodux)

local equipPlayer = require(Modules.src.thunks.equipPlayer)
local clientSlotsCount = require(Modules.src.actions.toClient.clientSlotsCount)

-- The Rodux DevTools aren't available yet! Check the README for more details.
-- local RoduxVisualizer = require(Modules.RoduxVisualizer)

local commonReducers = require(Modules.src.commonReducers)
local Dict = require(Modules.src.utils.Dict)
local Item = require(Modules.src.objects.Item)

-- These imports are pretty darn verbose.
local connectPlayer = require(Modules.src.thunks.connectPlayer)
local playerEnteredRoom = require(Modules.src.thunks.playerEnteredRoom)
local playerFinishedRoom = require(Modules.src.thunks.playerFinishedRoom)
local removePlayerFromRoom = require(Modules.src.actions.rooms.removePlayerFromRoom)
local addItemsToPlayerInventory = require(Modules.src.actions.inventory.addItemsToPlayerInventory)
local removeItemFromPlayerInventory = require(Modules.src.actions.inventory.removeItemFromPlayerInventory)

local TouchItem = require(Modules.src.TouchItem)

local serverReducers = require(script.Parent.serverReducers)
local ServerApi = require(script.Parent.ServerApi)
local networkMiddleware = require(script.Parent.networkMiddleware)

local InventoryObjects = require(Modules.src.objects.InventoryObjects)

local MazeGenerator = require(Modules.src.MazeGenerator)
local GameDatastore = require(Modules.src.GameDatastore)
local GamePasses = require(Modules.src.GamePasses)
local GhostAbility = require(Modules.src.GhostAbility)

GhostAbility:initCollisionGroup()

local MapsFolder = game.workspace:findFirstChild('Maps')
local RoomsFolder = game.workspace:findFirstChild('Rooms')

return function(context)
	local reducer = Rodux.combineReducers(Dict.join(commonReducers, serverReducers))

	local api

	--[[
		This function contains our custom replication logic for Rodux actions.

		Using the Redux pattern as a way to sychronize replicated data is a new
		idea. Vocksel introduced the idea to me, and I used this project partly
		as a test bed to try it out.
	]]
	local function replicate(action, beforeState, afterState)
		-- Create a version of each action that's explicitly flagged as
		-- replicated so that clients can handle them explicitly.
		local replicatedAction = Dict.join(action, { replicated = true })

		-- This is an action that everyone should see!
		if action.replicateBroadcast then
			return api:storeAction(ServerApi.AllPlayers, replicatedAction)
		end

		-- This is an action that we want a specific player to see.
		if action.replicateTo ~= nil then
			local player = Players:GetPlayerByUserId(action.replicateTo)

			if player == nil then return end

			return api:storeAction(player, replicatedAction)
		end

		-- We should probably replicate any actions that modify data shared
		-- between the client and server.
		for key in pairs(commonReducers) do
			if beforeState[key] ~= afterState[key] then
				return api:storeAction(ServerApi.AllPlayers, replicatedAction)
			end
		end

		return
	end

	--[[
		For hot-reloading, we want to save a list of every action that gets run
		through the store. This lets us iterate on our reducers, but otherwise
		keep any state we want across reloads.
	]]
	local function saveActionsMiddleware(nextDispatch)
		return function(action)
			table.insert(context.savedActions, action)

			return nextDispatch(action)
		end
	end

	-- This is a case where the simplicify of reducers shines!
	-- We produce the state that this store should start at based on the actions
	-- that the previous store had executed.
	local initialState = nil
	for _, action in ipairs(context.savedActions) do
		initialState = reducer(initialState, action)
	end

	-- local devTools = RoduxVisualizer.createDevTools({
	-- 	mode = RoduxVisualizer.Mode.Plugin,
	-- })

	local middleware = { -- Our minimal middleware to save actions to our context.
	Rodux.thunkMiddleware, saveActionsMiddleware, networkMiddleware(replicate) }
	--, Rodux.loggerMiddleware
	-- Rodux has a built-in logger middleware to print to the console
	-- whenever actions are dispatched to show the store.
	-- callback defined above.
	-- Middleware to replicate actions to the client, using the replicate

	-- Once the Rodux DevTools are available, this will be revisited!
	-- devTools.middleware,

	local store = Rodux.Store.new(reducer, initialState, middleware)

	local clientStart = function(player)
		store:dispatch(connectPlayer(player))

		local state = store:getState()
		local commonState = {}

		for key, value in pairs(state) do
			if commonReducers[key] ~= nil then
				commonState[key] = value
			end
		end

		logger:i('Client is starting. Initializing store and Datastore.')
		api:initialStoreState(player, commonState)

		----------------------------------------------------------------
		----- Setup DataStore to Store sync
		----------------------------------------------------------------

		local function updetePetsEquippedInState(petIds)
			logger:d('DataStore:Pet Equipped status updated to: ', petIds)
			store:dispatch(equipPlayer(player, petIds))
		end

		updetePetsEquippedInState(GameDatastore:getEquippedPets(player))

		GameDatastore:onEquippedPetsUpdated(player, updetePetsEquippedInState)

		local function slotsCountUpdated(slotsCount)
			logger:d('DataStore: Slots updated: ', slotsCount)
			store:dispatch(clientSlotsCount(tostring(player.UserId), slotsCount))
		end
		slotsCountUpdated(GameDatastore:getSlotsCount(player))

		----
		---- inventory
		----

		local function updateInventoryInState(inventoryItemIds)
			logger:d('DataStore:Inventory updated to:', inventoryItemIds)

			local function getInventoryObject(obj, itemId)
				obj[itemId] = InventoryObjects.AllObjects[itemId]
				return obj
			end

			local inventoryItems = M.reduce(inventoryItemIds, getInventoryObject, {})
			logger:d('Add inventory items:', inventoryItems)
			store:dispatch(addItemsToPlayerInventory(tostring(player.UserId), inventoryItems))
		end

		updateInventoryInState(GameDatastore:getInventory(player))

		GameDatastore:onInventoryUpdated(player, updateInventoryInState)
	end

	-- Construct our ServerApi, which creates RemoteEvent objects for our
	-- clients to listen to.
	api = ServerApi.create({
	-- We need to make sure not to replicate anything secret!
	--local newPosition = root.Position + root.CFrame.lookVector * 4
	--local newItem = Dict.join(item, { position = newPosition })
	--store:dispatch(addItemsToWorld({ [itemId] = newItem }))
		clientStart = clientStart,
		startRoomGame = function(player, roomId)
			warn('NOT USED??????Room ' .. roomId .. ' started for player ' .. player.Name)
		end,
		endRoomGame = function(player, roomId)
			warn('NOT USED??????Room ' .. roomId .. ' ended for player ' .. player.Name)
			store:dispatch(playerFinishedRoom(player, roomId))
		end,
		pickUpItem = function(player, itemId)
			local state = store:getState()

			logger:d('Player ' .. player.Name .. ' picked up item ' .. itemId)

			GameDatastore:setInventoryItem(player, itemId)
		end,
		pickUpCoin = function(player, itemId)
			local state = store:getState()

			logger:d('Player ' .. player.Name .. ' picked up coin ' .. itemId)
			local coinItem = InventoryObjects.CoinObjects[itemId]
			if coinItem then
				GameDatastore:incrementCoins(player, coinItem.value)
			else
				logger:e('No coinItem found', itemId)
			end
		end,
		dropItem = function(player, itemId)
			local playerId = tostring(player.UserId)
			local state = store:getState()
			local inventory = state.playerInventories[playerId]

			if inventory == nil then
				logger:w("Couldn't find player inventory " .. playerId)
				return
			end

			local item = inventory[itemId]

			if item == nil then
				logger:w("Player can't drop item " .. itemId)
				return
			end

			logger:d('Player ' .. player.Name .. ' dropped item ' .. itemId)

			local character = player.Character

			if character == nil then
				logger:w("Can't drop item for player, no character: " .. playerId)
				return
			end

			local root = character:FindFirstChild('HumanoidRootPart')

			if root == nil then
				logger:w('No HumanoidRootPart in character from ' .. playerId)
				return
			end

			store:dispatch(removeItemFromPlayerInventory(playerId, itemId))

			logger:warn('Should drop item to world')
			GameDatastore:unsetInventoryItem(player, itemId)
		end,
		buyItem = function(player, productId)
			logger:d('Player ' .. player.Name .. ' bought item ' .. productId)

			local items = store:getState().shop.items
			local product = items[productId]
			if not product then
				logger:w('No product')
				return
			end

			local productPrice = product.price

			if GameDatastore:decrementCoins(player, productPrice) then
				logger:d('Buying product', productId)
				GameDatastore:setEquippedPet(player, product.id)
				GameDatastore:setInventoryItem(player, productId)

				store:dispatch(addItemsToPlayerInventory(tostring(player.UserId), { [productId] = product }))
			else
				logger:w('Not enough money')
			end
		end,
		startGhosting = function(player)
			logger:d('Player ' .. player.Name .. ' started ghosting ')

			if GamePasses:hasGamePass(player, GamePasses.GHOST_MODE_ID) then
				GhostAbility:addGhostAbility(player.Character)

				api:clientStartGhosting(player)
			else
				logger:e('Player ' .. player.Name .. ' does not have ghosting ability: ')
			end
		end,
		stopGhosting = function(player)
			logger:d('Player ' .. player.Name .. ' stop ghosting ')

			player.Character.Humanoid.Health = 0
		end,
		equipItem = function(player, productId)
			logger:d('Player ' .. player.Name .. ' equipped item ' .. productId)

			local items = store:getState().shop.items
			local product = items[productId]
			if not product then
				logger:w('No product')
				return
			end

			GameDatastore:setEquippedPet(player, product.id)
		end,
		unequipItem = function(player, productId)
			logger:d('Player ' .. player.Name .. ' unequipped item ' .. productId)

			local items = store:getState().shop.items
			local product = items[productId]
			if not product then
				logger:w('No product')
				return
			end

			GameDatastore:unsetEquippedPet(player, product.id)
		end,
	})

	-- The hot-reloading shim has a place for us to stick destructors, since we
	-- need to clean up everything on the server before unloading.
	table.insert(context.destructors, function()
		store:destruct()
	end)

	table.insert(context.destructors, function()
		api:destroy()
	end)

	logger:i('Server started!')
	logger:i('Initializing rooms')

	if MapsFolder then
		if RoomsFolder then
			for roomId, room in pairs(store:getState().rooms) do
				logger:i('Initializing room ', roomId, room)

				local mapObj = MapsFolder:findFirstChild(roomId)

				if mapObj then
					MazeGenerator:generate(mapObj, room.config.width, room.config.height)

					local roomObj = RoomsFolder:findFirstChild(roomId)
					if roomObj then
						local roomPlaceholder = roomObj.placeholders.RoomPlaceholder
						TouchItem.create(
							roomPlaceholder,
							function(player)
								store:dispatch(playerEnteredRoom(player, roomId))
							end,
							function(player)
								store:dispatch(removePlayerFromRoom(player, roomId))
							end
						)
					else
						logger:w('Rooms folder is missing ' .. roomId .. ' object!!')
					end
				else
					logger:w('Maps folder is missing ' .. roomId .. ' object!!')
				end
			end
		else
			logger:w('Rooms Folder does not exists!!')
		end
	else
		logger:w('Maps Folder does not exists!!')
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, purchaseSuccess)
		local productId = tostring(id)
		if purchaseSuccess then
			logger:i(player.Name .. ' purchased the game pass with ID ' .. productId)
			GamePasses:addAbility(player, productId)

			store:dispatch(addItemsToPlayerInventory(tostring(player.UserId), { [productId] = InventoryObjects.AllObjects[productId] }))
		else
			logger:d(player.Name .. ' did not purchase game pass with ID ' .. productId)
		end
	end)
end