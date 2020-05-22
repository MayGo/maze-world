local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local Players = game:GetService('Players')

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Time = require(Modules.src.Time)
local Print = require(Modules.src.utils.Print)

local TextLabel = require(clientSrc.Components.common.TextLabel)

local createElement = Roact.createElement
local ClockScreen = Roact.Component:extend('ClockScreen')

local player = Players.LocalPlayer

function ClockScreen(props)
	if props.countDown == nil then
		return nil
	end
	if props.isFinishScreenOpen == true then
		return nil
	end

	local hasPlayer = props.playersPlaying[tostring(player.UserId)]

	if hasPlayer == nil then
		return nil
	end

	local label = createElement(TextLabel, {
		Size = UDim2.new(0, 400, 0, 300),
		TextSize = 30,
		Position = UDim2.new(0.5, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = Time.FormatTime(props.countDown),
	})

	return label
end

local ClockScreenConnected = RoactRodux.connect(function(state)
	local roomId = state.player.roomId
	if roomId == nil then
		return {}
	end

	local room = state.rooms[roomId]
	return {
		isFinishScreenOpen = state.player.isFinishScreenOpen,
		countDown = room.countDown,
		playersPlaying = room.playersPlaying,
	}
end)(ClockScreen)

return ClockScreenConnected