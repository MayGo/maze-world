--[[
    This is a thunk that checks if game needs to be started  
]]
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local setRoomCountDown = require(Modules.src.actions.rooms.setRoomCountDown)
local startGame = require(Modules.src.thunks.startGame)
local M = require(Modules.M)

local GlobalConfig = require(Modules.src.GlobalConfig)

local function startRoomGameLoop(roomId)
	return function(store)
		logger:i('Starting game loop for room:' .. roomId)

		store:dispatch(setRoomCountDown(roomId, nil, 'Waiting players'))

		spawn(function()
			while true do
				local room = store:getState().rooms[roomId]
				local playersWaiting = room.playersWaiting

				local hasEnoughWaiting = M.count(playersWaiting) == 1
				local isGameRunningAlready = room.startTime ~= nil
				local canStartGame = hasEnoughWaiting and not isGameRunningAlready

				if canStartGame then
					logger:d('Almost starting game.')

					local gameStartedEvent = Instance.new('BindableEvent')

					store:dispatch(
						setRoomCountDown(roomId, GlobalConfig.WAIT_TIME, 'Starting game')
					)

					delay(GlobalConfig.WAIT_TIME, function()
						gameStartedEvent:Fire(true)
					end)

					spawn(function()
						while true do
							wait(0.1)

							local r = store:getState().rooms[roomId]

							if M.count(r.playersWaiting) == 0 then
								logger:d('No players waiting.')
								gameStartedEvent:Fire(false)
								break
							end
						end
					end)

					local gameWillStart = gameStartedEvent.event:Wait()

					if gameWillStart then
						logger:d('Game will start for room: ' .. roomId)
						store:dispatch(setRoomCountDown(roomId, nil, 'Loading maze'))
						wait(0.5)
						store:dispatch(startGame(roomId))
					else
						logger:d('Game will not start for room: ' .. roomId)
						store:dispatch(setRoomCountDown(roomId, nil, 'Waiting players'))
					end
				end

				wait(1)
			end
		end)
	end
end

return startRoomGameLoop