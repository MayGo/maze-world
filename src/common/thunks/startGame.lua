local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local Players = game:GetService('Players')
local setRoomCountDown = require(Modules.src.actions.rooms.setRoomCountDown)
local setRoomStartTime = require(Modules.src.actions.rooms.setRoomStartTime)
local setRoomEndTime = require(Modules.src.actions.rooms.setRoomEndTime)
local resetRoom = require(Modules.src.actions.rooms.resetRoom)
local clientStartGame = require(Modules.src.actions.toClient.clientStartGame)
local playerFinishedRoom = require(Modules.src.thunks.playerFinishedRoom)

local Transporter = require(Modules.src.Transporter)
local M = require(Modules.M)
local TouchItem = require(Modules.src.TouchItem)
local MazeGenerator = require(Modules.src.MazeGenerator)

local GlobalConfig = require(Modules.src.GlobalConfig)

local Place = game.Workspace:WaitForChild('Place')
local MapsFolder = Place:findFirstChild('Maps')

local function isPlayerPlaying(player)
	return player.finishTime == nil
end

local function startGame(roomId)
	return function(store)
		logger:i('Starting game for room:' .. roomId)

		local room = store:getState().rooms[roomId]

		if not MapsFolder then
			logger:w('Maps folder does not exists!')
			return
		end

		local mapObj = MapsFolder:findFirstChild(room.modelName)

		if not mapObj then
			logger:w('Maps folder  is missing ' .. room.modelName .. ' object!')
			return
		end

		local location = mapObj:FindFirstChild('LocationPart')

		local defaultSettings = {
			width = room.config.width,
			height = room.config.height,
			wallMaterial = Enum.Material.Grass,
			groundMaterial = Enum.Material.Sand,
			onlyBlocks = false,
			addRandomModels = true,
			addStartAndFinish = true,
			addKillBlocks = true,
			addCeiling = false,
			partThickness = 3,
			ceilingFloorThickness = 1,
			location = location,
			blockHeight = 20,
			blockWidth = 25,
			randomStuffFolder = 'Light',
		}

		local darkSettings = {
			width = room.config.width,
			height = room.config.height,
			wallMaterial = Enum.Material.Basalt,
			groundMaterial = Enum.Material.Mud,
			onlyBlocks = false,
			addRandomModels = true,
			addStartAndFinish = true,
			addKillBlocks = false,
			addCeiling = true,
			partThickness = 5,
			ceilingFloorThickness = 5,
			location = location,
			blockHeight = 25,
			blockWidth = 30,
			randomStuffFolder = 'Dark',
		}

		local initialVotes = {
			nil_1 = 'Dark',
			nil_2 = 'Light',
		}
		local playerVotes = M.extend({}, room.playerVotes, initialVotes)
		local votes = M.countBy(playerVotes, function(vote)
			return vote
		end)

		local isDark = votes.Dark > votes.Light

		local settings = isDark and darkSettings or defaultSettings
		MazeGenerator:generate(settings)

		local playTime = isDark and room.config.playTime * 3 or room.config.playTime

		local finishPlaceholder = location:findFirstChild('FinishPlaceholder', true)

		if finishPlaceholder then
			local finishedPlayers = {}

			TouchItem.create(finishPlaceholder, function(player)
				--	self.api:endRoomGame(roomId)
				if not finishedPlayers[player] then
					logger:d('Touched Finish for player:' .. player.Name)
					finishedPlayers[player] = true
					store:dispatch(playerFinishedRoom(player, roomId))
				end
			end)
		else
			logger:w('FinishPlaceholder is missing from ' .. roomId .. ' map object!')
		end

		local playersWaiting = room.playersWaiting

		store:dispatch(setRoomStartTime(roomId, os.time(), playersWaiting))

		local function getPlayerInstance(player)
			return Players:GetPlayerByUserId(player.id)
		end

		local LevelSpawn = mapObj:findFirstChild('SpawnPlaceholder', true)

		if LevelSpawn then
			local playersWaitingInstances = M.map(playersWaiting, getPlayerInstance)

			local function sendToClient(player)
				store:dispatch(clientStartGame(player, roomId))
			end

			M.each(playersWaitingInstances, sendToClient)

			Transporter:transportPlayers(playersWaitingInstances, LevelSpawn)
			--[[	M.each(playersWaitingInstances, function(player)
				addPlayerDiedListener(store, roomId, player)
			end)]]
		else
			logger:w('SpawnPlaceholder is missing from ' .. roomId .. ' map object!')
		end

		spawn(function()
			local gameEndedEvent = Instance.new('BindableEvent')
			store:dispatch(setRoomCountDown(roomId, playTime, 'Find exit', 'Wait'))

			delay(playTime, function()
				gameEndedEvent:Fire(true)
			end)

			spawn(function()
				while true do
					wait(0.1)

					local room = store:getState().rooms[roomId]
					local playersPlaying = M.select(room.playersPlaying, isPlayerPlaying)

					if M.count(playersPlaying) == 0 then
						gameEndedEvent:Fire(false)
						break
					end
				end
			end)

			local gameWillEnd = gameEndedEvent.event:Wait()

			if gameWillEnd then
				logger:d('Game will ended with timer for room ' .. roomId)
				local state = store:getState()
				local room = state.rooms[roomId]
				local playersPlaying = M.select(room.playersPlaying, isPlayerPlaying)
				local playersPlayingInstances = M.map(playersPlaying, getPlayerInstance)

				Transporter:transportByKillingPlayers(playersPlayingInstances)
			else
				logger:d('Game will end with all player finished for room ' .. roomId)
			end

			store:dispatch(setRoomEndTime(roomId, os.time()))

			MazeGenerator:clean(settings)

			store:dispatch(
				setRoomCountDown(roomId, GlobalConfig.afterFinishWaitTime, 'Finished - Cooldown')
			)
			wait(GlobalConfig.afterFinishWaitTime)

			store:dispatch(resetRoom(roomId))
			store:dispatch(setRoomCountDown(roomId, nil, 'Waiting players'))
		end)
	end
end

return startGame