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
local ClockScreen = Roact.Component:extend('ClockScreen')

function ClockScreen:render()
	local props = self.props

	if props.countDownTime == nil then
		return nil
	end

	--[[
	local hasPlayer = props.playersPlaying[tostring(player.UserId)]

	if hasPlayer == nil then
		return nil
	end
]]
	local text = createElement(
		TextLabel,
		{
			Size = UDim2.new(0, 500, 0, 40),
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
	local label = createElement(
		Timer,
		{
			key = props.countDownText,
			increment = false,
			initialTime = props.countDownTime,
			TextColor3 = props.TextColor3,
			Size = UDim2.new(0, 100, 0, 40),
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
			text = text,
			label = label,
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
		countDownTime = room.countDown,
		playersPlaying = state.gameState.playersPlaying,
	}
end)(ClockScreen)

return ClockScreenConnected