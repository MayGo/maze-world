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
local RoomsConfig = require(Modules.src.RoomsConfig)
local GlobalConfig = require(Modules.src.GlobalConfig)
local M = require(Modules.M)
local Print = require(Modules.src.utils.Print)

local function playerEnteredRoom(player, roomId)
	return function(store)
		logger:d('Player entered room:', player.Name)
		local playersWaiting = store:getState().rooms[roomId].playersWaiting
		store:dispatch(addPlayerToRoom(player, roomId))
		store:dispatch(clientSetRoom(player, roomId))

		if M.count(playersWaiting) == 0 then
			spawn(function()
				while true do
					local state = store:getState()
					local countDown = state.rooms[roomId].countDown

					wait(1)

					local newCountDown = countDown - 1
					store:dispatch(setRoomCountDown(roomId, newCountDown))

					-- reset timer if there are no players waiting and just in case check if any are already playing
					local room = store:getState().rooms[roomId]

					if M.count(room.playersWaiting) == 0 and M.count(room.playersPlaying) == 0 then
						logger:d('No players waiting or playing. Reseting room countdown.')
						store:dispatch(setRoomCountDown(roomId, GlobalConfig.WAIT_TIME))
						break
					end

					if newCountDown <= 0 then
						store:dispatch(startGame(roomId))
						break
					end
				end
			end)
		end
	end
end

return playerEnteredRoom