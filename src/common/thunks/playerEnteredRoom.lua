--[[
    This is a thunk for adding player to room!
    It also checks if game needs to be started  
]]
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local addPlayerToRoom = require(Modules.src.actions.rooms.addPlayerToRoom)
local clientSetRoom = require(Modules.src.actions.toClient.clientSetRoom)
local setRoomCountDown = require(Modules.src.actions.rooms.setRoomCountDown)
local startGame = require(Modules.src.thunks.startGame)
local GlobalConfig = require(Modules.src.GlobalConfig)
local M = require(Modules.M)

local function playerEnteredRoom(player, roomId)
	return function(store)
		logger:d('Player entered room:', player.Name)
		local playersWaiting = store:getState().rooms[roomId].playersWaiting
		local endTime = store:getState().rooms[roomId].endTime
		store:dispatch(addPlayerToRoom(player, roomId))
		store:dispatch(clientSetRoom(player, roomId))

		if M.count(playersWaiting) == 0 and not endTime then
			local gameStartedEvent = Instance.new('BindableEvent')

			store:dispatch(setRoomCountDown(roomId, GlobalConfig.WAIT_TIME, 'Starting game'))

			delay(GlobalConfig.WAIT_TIME, function()
				gameStartedEvent:Fire(true)
			end)

			spawn(function()
				while true do
					wait(0.1)

					local room = store:getState().rooms[roomId]

					if M.count(room.playersWaiting) == 0 then
						logger:d('No players waiting.')
						gameStartedEvent:Fire(false)
						break
					end
				end
			end)

			local gameWillStart = gameStartedEvent.event:Wait()

			if gameWillStart then
				logger:d('Game will start for room ' .. roomId)
				store:dispatch(startGame(roomId))
			else
				logger:d('Game will not start for room ' .. roomId)
			end
		end
	end
end

return playerEnteredRoom