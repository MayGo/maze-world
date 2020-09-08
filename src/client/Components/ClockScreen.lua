local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local UICorner = require(clientSrc.Components.common.UICorner)
local Frame = require(clientSrc.Components.common.Frame)
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local TextLabel = require(clientSrc.Components.common.TextLabel)
local Timer = require(clientSrc.Components.Timer)

local createElement = Roact.createElement
local ClockScreen = Roact.PureComponent:extend('ClockScreen')

local Players = game:GetService('Players')
local localPlayer = Players.LocalPlayer

function ClockScreen:render()
	local props = self.props
	local waitingText = props.countDownTextOther
	local playingText = props.countDownText

	if props.countDownTime == nil then
		return nil
	end

	local uid = tostring(localPlayer.UserId)
	local isWaiting = props.playersWaiting[uid]
	local isPlaying = props.playersPlaying[uid]
	local hasPlayer = isWaiting or isPlaying

	if hasPlayer == nil then
		return nil
	end

	local text = waitingText and waitingText or playingText
	if isPlaying then
		text = playingText
	end

	local textEl = createElement(
		TextLabel,
		{
			Size = UDim2.new(0.4, 0, 0.5, 0),
			TextScaled = true,
			TextSize = 30,
			AnchorPoint = Vector2.new(0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Text = text,
			TextColor3 = props.TextColor3,
			BackgroundTransparency = props.BackgroundTransparency or 0.5,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
		},
		{ UICorner = createElement(UICorner) }
	)
	local time = createElement(
		Timer,
		{
			key = props.countDownTime,
			increment = false,
			initialTime = props.countDownTime,
			TextColor3 = props.TextColor3,
			Size = UDim2.new(0.2, 0, 0.5, 0),
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
			Size = UDim2.new(0, 500, 0, 40),
			AnchorPoint = Vector2.new(0.5, 0),
		},
		{
			textEl = textEl,
			time = time,
		}
	)
end

local ClockScreenConnected = RoactRodux.connect(function(state)
	local roomId = state.player.roomId
	if roomId == nil then
		return {}
	end

	local room = state.rooms[roomId]

	return {
		isFinishScreenOpen = state.player.isFinishScreenOpen,
		countDownTime = room.countDownTime,
		countDownText = room.countDownText,
		countDownTextOther = room.countDownTextOther,
		playersPlaying = room.playersPlaying,
		playersWaiting = room.playersWaiting,
	}
end)(ClockScreen)

return ClockScreenConnected