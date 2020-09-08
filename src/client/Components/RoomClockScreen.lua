local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local UICorner = require(clientSrc.Components.common.UICorner)
local Frame = require(clientSrc.Components.common.Frame)
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local UIPadding = require(clientSrc.Components.common.UIPadding)
local TextLabel = require(clientSrc.Components.common.TextLabel)
local Timer = require(clientSrc.Components.Timer)

local createElement = Roact.createElement
local RoomClockScreen = Roact.PureComponent:extend('RoomClockScreen')

function RoomClockScreen:render()
	local props = self.props
	local countDownTime = props.countDownTime

	local text = createElement(
		TextLabel,
		{
			Size = UDim2.new(1, 0, 0.5, 0),
			TextScaled = true,
			TextSize = 30,
			AnchorPoint = Vector2.new(0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Text = props.countDownText,
			TextColor3 = props.TextColor3,
			BackgroundTransparency = props.BackgroundTransparency or 0.5,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
		},
		{ UICorner = createElement(UICorner) }
	)

	local time = countDownTime and createElement(
		Timer,
		{
			key = props.countDownTime,
			increment = false,
			initialTime = props.countDownTime,
			TextColor3 = props.TextColor3,
			Size = UDim2.new(1, 0, 0.5, 0),
			TextScaled = true,
			TextSize = 30,
			AnchorPoint = Vector2.new(0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			BackgroundTransparency = props.BackgroundTransparency or 0.5,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
		},
		{ UICorner = createElement(UICorner) }
	)

	return createElement(
		Frame,
		{
			Layout = 'List',
			LayoutDirection = 'Vertical',
			HorizontalAlignment = 'Center',
			Padding = UDim.new(0, 3),
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 0),
		},
		{
			text = text,
			time = time,
			UIPadding = createElement(UIPadding, { padding = 10 }),
		}
	)
end

local RoomClockScreenConnected = RoactRodux.connect(function(state, props)
	local roomId = props.roomId
	local room = state.rooms[roomId]

	return {
		countDownTime = room.countDownTime,
		countDownText = room.countDownTextOther and room.countDownTextOther or room.countDownText,
	}
end)(RoomClockScreen)

return RoomClockScreenConnected