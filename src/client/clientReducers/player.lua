local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local Dict = require(Modules.src.utils.Dict)
local None = require(Modules.src.utils.None)
local Players = game:GetService('Players')
local AudioPlayer = require(Modules.src.AudioPlayer)

local LocalPlayer = Players.LocalPlayer

local function player(state, action)
	state = state or { isPlaying = false }

	if action.type == 'clientFinishGame' then
		logger:d('clientFinishGame:', action.playerId, action.roomId)

		AudioPlayer.playAudio('Finish')

		return Dict.join(state, {
			isPlaying = false,
			roomId = None,
			lastFinishedRoomId = action.roomId,
			isFinishScreenOpen = true,
		})
	elseif action.type == 'clientStartGame' then
		logger:d('clientStartGame:', action.playerId, LocalPlayer.UserId)

		return Dict.join(state, { isPlaying = true })
	elseif action.type == 'clientSetRoom' then
		return Dict.join(state, {
			roomId = action.roomId,
			lastFinishedRoomId = None,
			isFinishScreenOpen = false,
		})
	elseif action.type == 'clientSetGhosting' then
		logger:w('clientSetGhosting')
		return Dict.join(state, { isGhosting = true })
	elseif action.type == 'clientReset' then
		logger:w('clientReset.')
		return Dict.join(state, {
			roomId = None,
			isGhosting = false,
			isPlaying = false,
		})
	elseif action.type == 'clientEquipped' then
		return Dict.join(state, { equippedItems = action.itemIds })
	elseif action.type == 'clientSlotsCount' then
		return Dict.join(state, { playerSlotsCount = action.slotsCount })
	end

	return state
end

return player