local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local Dict = require(Modules.src.utils.Dict)
local M = require(Modules.M)
local AudioPlayer = require(Modules.src.AudioPlayer)

local dummyNotifications = { {
	time = os.time(),
	text = 'Notifi 1',
	thumbnail = 'rbxasset://textures/ui/GuiImagePlaceholder.png',
	rectSize = Vector2.new(0, 0),
	rectOffset = Vector2.new(0, 0),
	statusColor = Color3.fromRGB(20, 20, 40),
	layoutIndex = 0,
}, {
	time = os.time() + 1,
	text = 'Notif 2',
	thumbnail = 'rbxasset://textures/ui/GuiImagePlaceholder.png',
	rectSize = Vector2.new(0, 0),
	rectOffset = Vector2.new(0, 0),
	statusColor = Color3.fromRGB(20, 20, 40),
	layoutIndex = 0,
} }

local function messages(state, action)
	state = state or {
		notifications = {},
	}

	if action.type == 'clientSendNotification' then
		logger:d('clientSendNotification:', action.playerId)
		-- TODO: Find better place to call this. not in reducer.
		AudioPlayer.playAudio('Notification')

		local notification = {
			time = action.time,
			text = action.text,
			thumbnail = action.thumbnail,
		}

		return Dict.join(state, { notifications = M.append(state.notifications, { notification }) })
	end

	return state
end

return messages