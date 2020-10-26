local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local MarketplaceService = game:GetService('MarketplaceService')
local Players = game:GetService('Players')

local M = require(Modules.M)
local Rodux = require(Modules.Rodux)

local ZonePlus = require(4664437268) --require(Modules.ZonePlus)
local ZoneService = require(ZonePlus.ZoneService)

local equipPlayer = require(Modules.src.thunks.equipPlayer)
local clientSlotsCount = require(Modules.src.actions.toClient.clientSlotsCount)
local clientStartGame = require(Modules.src.actions.toClient.clientStartGame)
local clientReset = require(Modules.src.actions.toClient.clientReset)
local GlobalConfig = require(Modules.src.GlobalConfig)

-- The Rodux DevTools aren't available yet! Check the README for more details.
-- local RoduxVisualizer = require(Modules.RoduxVisualizer)

local commonReducers = require(Modules.src.commonReducers)
local Dict = require(Modules.src.utils.Dict)
local DeveloperProducts = require(Modules.src.DeveloperProducts)
local clientSendNotification = require(Modules.src.actions.toClient.clientSendNotification)
local assets = require(Modules.src.assets)
-- These imports are pretty darn verbose.
local connectPlayer = require(Modules.src.thunks.connectPlayer)
local playerEnteredRoom = require(Modules.src.thunks.playerEnteredRoom)
local playerFinishedRoom = require(Modules.src.thunks.playerFinishedRoom)
local startRoomGameLoop = require(Modules.src.thunks.startRoomGameLoop)
local startInfiniteGame = require(Modules.src.thunks.startInfiniteGame)
local removePlayerFromRoom = require(Modules.src.actions.rooms.removePlayerFromRoom)
local playerDied = require(Modules.src.actions.rooms.playerDied)
local addVoteToRoom = require(Modules.src.actions.rooms.addVoteToRoom)
local addItemsToPlayerInventory = require(Modules.src.actions.inventory.addItemsToPlayerInventory)
local removeItemFromPlayerInventory =
	require(Modules.src.actions.inventory.removeItemFromPlayerInventory)

local serverReducers = require(script.Parent.serverReducers)
local ServerApi = require(script.Parent.ServerApi)
local networkMiddleware = require(script.Parent.networkMiddleware)

local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local BuyObjects = InventoryObjects.BuyObjects

local GameDatastore = require(Modules.src.GameDatastore)
local GamePasses = require(Modules.src.GamePasses)
local GhostAbility = require(Modules.src.GhostAbility)
local RoomManager = require(Modules.src.RoomManager)
local FallTriggerManager = require(Modules.src.FallTriggerManager)
local SoundTriggerManager = require(Modules.src.SoundTriggerManager)
local LogicTriggerManager = require(Modules.src.LogicTriggerManager)

GhostAbility:initCollisionGroup()
RoomManager:initCollisionGroups()

local Place = game.Workspace:WaitForChild('Place')

local Leaderboards = require(Modules.src.Leaderboards)
local addLeaderboardItems = require(Modules.src.actions.leaderboards.addLeaderboardItems)
local RoomsFolder = Place:findFirstChild('Rooms')

local TagItem = require(Modules.src.TagItem)
local TagItemOnce = require(Modules.src.TagItemOnce)

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

			local function getInventoryObject(objects, itemId)
				local object = InventoryObjects.AllObjects[itemId]

				if not object then
					logger:d('No object found in InventoryObjects', itemId)
				else
					objects[itemId] = object
				end
				return objects
			end

			local inventoryItems = M.reduce(inventoryItemIds, getInventoryObject, {})
			logger:d('Add inventory items:', inventoryItems)
			local playerId = tostring(player.UserId)
			store:dispatch(addItemsToPlayerInventory(playerId, inventoryItems))

			RoomManager:addToCharacter(player.Character, inventoryItems, playerId)
		end

		updateInventoryInState(GameDatastore:getInventory(player))

		GameDatastore:onInventoryUpdated(player, updateInventoryInState)
	end

	-- Construct our ServerApi, which creates RemoteEvent objects for our
	-- clients to listen to.
	api = ServerApi.create({
	-- We need to make sure not to replicate anything secret!
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

			local product = BuyObjects[productId]
			if not product then
				logger:w('No product')
				return
			end

			local productPrice = product.price

			local afterCoins = GameDatastore:decrementCoins(player, productPrice)
			if afterCoins >= 0 then
				logger:d('Buying product', productId)
				GameDatastore:setEquippedPet(player, product.id)
				GameDatastore:setInventoryItem(player, productId)

				store:dispatch(
					addItemsToPlayerInventory(tostring(player.UserId), { [productId] = product })
				)
			else
				logger:w('Not enough money')
				store:dispatch(
					clientSendNotification(
						player,
						'Not enough coins. Missing ' .. math.abs(afterCoins) .. ' coins',
						assets.money['coins-pile']
					)
				)
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
			if player.Character then
				player.Character.Humanoid.Health = 0
			else
				logger:d('No Character found for player:' .. player.Name)
			end
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
		roomVote = function(player, roomId, vote)
			logger:d('Player ' .. player.Name .. ' voted in room ' .. roomId, vote)

			local items = store:getState().rooms
			local room = items[roomId]
			if not room then
				logger:w('No room', roomId)
				return
			end
			store:dispatch(addVoteToRoom(player, roomId, vote))
			api:clientPlaySound(player, 'Simple_Click')
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
		unequipAll = function(player)
			logger:d('Player ' .. player.Name .. ' unequipped all')

			GameDatastore:unsetAllEquippedPet(player)
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

	spawn(function()
		logger:i('Getting Leaderboards!')
		while true do
			local mostPlayed = Leaderboards:getMostPlayed()
			local mostVisited = Leaderboards:getMostVisited()
			local mostCoins = Leaderboards:getMostCoins()

			store:dispatch(addLeaderboardItems('mostPlayed', mostPlayed))
			store:dispatch(addLeaderboardItems('mostVisited', mostVisited))
			store:dispatch(addLeaderboardItems('mostCoins', mostCoins))

			function refreshRoomLeaderboards(roomObject)
				local roomId = roomObject.id
				local mostPlayedRoom = Leaderboards:getMostPlayed(roomId)
				store:dispatch(addLeaderboardItems(roomId, mostPlayedRoom))
			end

			M.each(store:getState().rooms, refreshRoomLeaderboards)

			wait(GlobalConfig.refreshLeaderboards)
		end
	end)

	logger:i('Initializing rooms')
	if RoomsFolder then
		for roomId, room in pairs(store:getState().rooms) do
			logger:i('Initializing room:', roomId, room)

			if room.config.noTimer then
				logger:i('Init no timer room. Start infinite room')

				store:dispatch(startInfiniteGame(roomId))
			else
				store:dispatch(startRoomGameLoop(roomId))
			end

			local roomObj = RoomsFolder:findFirstChild(room.modelName)

			if roomObj then
				local roomPlaceholder = roomObj.placeholders:WaitForChild('RoomPlaceholder')
				logger:w('Creating zone', roomPlaceholder)
				local zone = ZoneService:createZone('Zone' .. room.modelName, roomPlaceholder)

				zone.playerAdded:Connect(function(player) -- Fires when a player enters the zone
					logger:w(player.Name .. ' entered room ' .. tostring(roomId))
					store:dispatch(playerEnteredRoom(player, roomId))

					if room.name == 'HorrorMaze' then
						store:dispatch(clientStartGame(player, roomId))
						logger:d(
							'No pets allowed in HorrorMaze. Player ' .. player.Name .. ' unequipped all'
						)

						GameDatastore:unsetAllEquippedPet(player)
						api:clientPlayBackgroundSound(player, 'Scary_bg')
					end
				end)

				zone.playerRemoving:Connect(function(player) -- Fires when a player exits the zone
					logger:d(player.Name .. ' left room ' .. tostring(roomId))
					store:dispatch(removePlayerFromRoom(player, roomId))
					if room.name == 'HorrorMaze' then
						store:dispatch(clientReset(player))

						api:clientPlayBackgroundSound(player, 'Desert_Sands')
					end
				end)

				zone:initLoop() -- Initiates loop (default 0.5) which enables the events to work
			else
				logger:w('Rooms folder is missing ' .. roomId .. ' object!!')
			end
		end
	else
		logger:w('Rooms Folder does not exists!!')
	end

	logger:d('Initializing TagItems')

	TagItem.create(nil, 'KillBrick', function(player, hit)
		logger:d('Player killed with killbrick. Hit name:', hit.Name)
		hit.parent.Humanoid.Health = 0
	end)

	local collectedByPlayer = {}

	TagItem.create(nil, 'CoinBrick', function(player, hit, part)
		if part:FindFirstChild('itemId') then
			logger:d('Player got coin with value: ' .. part.itemId.Value)

			local itemId = tostring(part.itemId.Value)

			logger:d('Player ' .. player.Name .. ' picked up coin ' .. itemId)
			local coinItem = InventoryObjects.CoinObjects[itemId]

			if coinItem then
				if coinItem.onePerPlayer then
					local key = tostring(coinItem.id) .. '_' .. tostring(player.UserId)

					if not collectedByPlayer[key] then
						collectedByPlayer[key] = true
						GameDatastore:incrementCoins(player, coinItem.value)
						api:clientPlaySound(player, 'Coin_Collect')
						store:dispatch(
							clientSendNotification(
								player,
								'Collected treasure with ' .. tostring(coinItem.value) .. ' coins',
								assets.money['coins-pile']
							)
						)
					end
				else
					GameDatastore:incrementCoins(player, coinItem.value)
					api:clientPlaySound(player, 'Coin_Collect')
				end
			else
				logger:e('No coinItem found', itemId)
			end

			if not coinItem.onePerPlayer then
				if part.Name == 'PrimaryPart' then
					local model = part:FindFirstAncestorOfClass('Model')
					model:Destroy()
				else
					part.Parent = nil
					wait(10)
					part.Parent = game.workspace
				end
			end
		else
			logger:w('No itemId Value for coin part')
		end
	end)

	local soundTriggerWaitFor = 10
	TagItem.create(nil, 'SoundTriggerBrick', function(player, hit, part)
		function playSound(soundName, triggerPart)
			api:clientPlaySound(player, soundName, triggerPart)
		end

		SoundTriggerManager:makeSound(part, soundTriggerWaitFor, playSound)
	end)

	local fallStuffRunner = {}
	local fallStuffWaitFor = 10
	TagItem.create(
		nil,
		'FallTriggerBrick',
		function(player, hit, part)
			if not fallStuffRunner[part] then
				fallStuffRunner[part] = true
				spawn(function()
					FallTriggerManager:fallStuff(part, fallStuffWaitFor)
					fallStuffRunner[part] = false
				end)
			end
		end,
		nil
	)

	TagItem.create(
		nil,
		'LogicTriggerBrick',
		function(player, hit, part)
			function playSound(soundName, triggerPart)
				api:clientPlaySound(player, soundName, triggerPart)
			end

			LogicTriggerManager:trigger(part, player, playSound, store)
		end,
		nil
	)

	TagItem.create(nil, 'CollectableBrick', function(player, hit, part)
		if part.itemId then
			logger:d('Player got collectable with value: ' .. part.itemId.Value)

			local itemId = tostring(part.itemId.Value)
			logger:d('Player ' .. player.Name .. ' picked up item ' .. itemId)

			GameDatastore:setInventoryItem(player, itemId)
			--local coinClone = part:Clone()
			--part:Destroy()

			part.Parent = nil
			wait(10)
			part.Parent = game.workspace
		else
			logger:w('No itemId Value for collectable part')
		end
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, purchaseSuccess)
		local productId = tostring(id)
		if purchaseSuccess then
			logger:i(player.Name .. ' purchased the game pass with ID ' .. productId)
			GamePasses:addAbility(player, productId)

			store:dispatch(
				addItemsToPlayerInventory(
					tostring(player.UserId),
					{ [productId] = InventoryObjects.AllObjects[productId] }
				)
			)
		else
			logger:d(player.Name .. ' did not purchase game pass with ID ' .. productId)
		end
	end)

	-- Set Developer Products purchase callback
	MarketplaceService.ProcessReceipt = DeveloperProducts.processReceipt

	Players.PlayerRemoving:Connect(function(player)
		logger:d(player.Name .. ' left the game. Remove from rooms!')
		local playerId = tostring(player.UserId)
		store:dispatch(playerDied(player))
		RoomManager:removePlayerCollisionGroup(playerId)
	end)
end