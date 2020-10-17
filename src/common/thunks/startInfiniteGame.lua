local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local playerFinishedRoom = require(Modules.src.thunks.playerFinishedRoom)
local TouchItem = require(Modules.src.TouchItem)

local Place = game.Workspace:WaitForChild('Place')
local MapsFolder = Place:findFirstChild('Maps')

local function startInfiniteGame(roomId)
	return function(store)
		logger:i('Starting infinite game for room:' .. roomId)

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

		local finishPlaceholder = mapObj:findFirstChild('FinishPlaceholder', true)
		if finishPlaceholder then
			local finishedPlayers = {}

			TouchItem.create(finishPlaceholder, function(player)
				if not finishedPlayers[player] then
					logger:d('Touched Finish for player:' .. player.Name)
					finishedPlayers[player] = true
					store:dispatch(playerFinishedRoom(player, roomId))
					spawn(function()
						wait(1)
						finishedPlayers[player] = false
					end)
				end
			end)
		else
			logger:w('FinishPlaceholder is missing from ' .. roomId .. ' map object!')
		end
	end
end

return startInfiniteGame