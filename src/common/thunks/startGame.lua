local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local Players = game:GetService('Players')
local setRoomCountDown = require(Modules.src.actions.rooms.setRoomCountDown)
local setRoomStartTime = require(Modules.src.actions.rooms.setRoomStartTime)
local clientStartGame = require(Modules.src.actions.toClient.clientStartGame)
local playerFinishedRoom = require(Modules.src.thunks.playerFinishedRoom)
local RoomsConfig = require(Modules.src.RoomsConfig)
local GlobalConfig = require(Modules.src.GlobalConfig)
local Transporter = require(Modules.src.Transporter)
local Player = require(Modules.src.Player)
local M = require(Modules.M)
local TouchItem = require(Modules.src.TouchItem)
local MazeGenerator = require(Modules.src.MazeGenerator)

local Place = game.Workspace:WaitForChild('Place')
local MapsFolder = Place:findFirstChild('Maps')

local function startGame(roomId)
	return function(store)
		logger:i('Starting game for room:' .. roomId)

		local room = store:getState().rooms[roomId]

		if not MapsFolder then
			logger:w('Maps folder does not exists!')
			return
		end

		local mapObj = MapsFolder:findFirstChild(roomId)

		if not mapObj then
			logger:w('Maps folder  is missing ' .. roomId .. ' object!')
			return
		end

		MazeGenerator:generate(mapObj, room.config.width, room.config.height)

		local finishPlaceholder = mapObj:findFirstChild('FinishPlaceholder', true)
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
		store:dispatch(setRoomCountDown(roomId, room.playTime))
		store:dispatch(setRoomStartTime(roomId, tick(), playersWaiting))

		local function getPlayerInstance(player)
			return Players:GetPlayerByUserId(player.id)
		end

		local LevelEasySpawn = mapObj:findFirstChild('SpawnPlaceholder', true)

		if LevelEasySpawn then
			local playersWaitingInstances = M.map(playersWaiting, getPlayerInstance)

			local function sendToClient(player)
				store:dispatch(clientStartGame(player, roomId))
			end

			M.each(playersWaitingInstances, sendToClient)

			Transporter:transportPlayers(playersWaitingInstances, LevelEasySpawn)
		else
			logger:w('SpawnPlaceholder is missing from ' .. roomId .. ' map object!')
		end

		spawn(function()
			while true do
				local state = store:getState()
				local room = state.rooms[roomId]
				local countDown = room.countDown

				wait(1)

				local newCountDown = countDown - 1
				store:dispatch(setRoomCountDown(roomId, newCountDown))

				local function isPlayerPlaying(player)
					return player.finishTime == nil
				end

				local playersPlaying = M.select(room.playersPlaying, isPlayerPlaying)

				-- ending game if time expires or players have finished
				if newCountDown <= 0 or M.count(playersPlaying) == 0 then
					-- ending game and transporting players who are still playing
					-- not transporting already finished players

					local playersPlayingInstances = M.map(playersPlaying, getPlayerInstance)
					store:dispatch(setRoomCountDown(roomId, GlobalConfig.WAIT_TIME))
					Transporter:transportByKillingPlayers(playersPlayingInstances)
					break
				end
			end
		end)
	end
end

return startGame