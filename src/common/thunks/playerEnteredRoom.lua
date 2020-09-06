--[[
    This is a thunk for adding player to room!

]]
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local addPlayerToRoom = require(Modules.src.actions.rooms.addPlayerToRoom)
local clientSetRoom = require(Modules.src.actions.toClient.clientSetRoom)

local function playerEnteredRoom(player, roomId)
	return function(store)
		logger:d('Player entered room:', player.Name)
		store:dispatch(addPlayerToRoom(player, roomId))
		store:dispatch(clientSetRoom(player, roomId))
	end
end

return playerEnteredRoom