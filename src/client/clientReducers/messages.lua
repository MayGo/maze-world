local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local Dict = require(Modules.src.utils.Dict)
local None = require(Modules.src.utils.None)
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer

local dummyNotifications = { {
	time = tick(),
	text = 'Notifi 1',
	thumbnail = 'rbxasset://textures/ui/GuiImagePlaceholder.png',
	rectSize = Vector2.new(0, 0),
	rectOffset = Vector2.new(0, 0),
	statusColor = Color3.fromRGB(20, 20, 40),
	layoutIndex = 0,
}, {
	time = tick() + 1,
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

		local notification = {
			time = action.time,
			text = action.text,
		}

		return Dict.join(state, {
			notifications = Dict.join(state.notifications, { notification }),
		})
	end

	return state
end

return messages