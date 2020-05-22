local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local getApiFromComponent = require(clientSrc.getApiFromComponent)

local DynamicTable = require(clientSrc.Components.common.DynamicTable)
local TextListWithHeader = require(clientSrc.Components.common.TextListWithHeader)
local PlayersPlayingTableRow = require(clientSrc.Components.PlayersPlayingTableRow)

local createElement = Roact.createElement

local FinishScreen = Roact.Component:extend('FinishScreen')

local Print = require(Modules.src.utils.Print)

function FinishScreen:init()
	self.state = { open = true }

	self.api = getApiFromComponent(self)
end

function FinishScreen:render()
	if not self.props.isFinishScreenOpen or not self.state.open then
		return nil
	end

	local size = Vector2.new(200, 200)
	local title = 'Finishers'

	local playersList = createElement(TextListWithHeader, {
		size = size,
		title = title,
		[Roact.Children] = createElement(DynamicTable, {
			items = self.props.playersPlaying,
			startTime = self.props.startTime,
			rowComponent = PlayersPlayingTableRow,
		}),
	})

	function OnClick()
		self:setState({ open = false })
	end

	local button = createElement('TextButton', {
		Text = 'Close',
		Size = UDim2.new(0.5, 0, 0, 50),
		Position = UDim2.new(0.5, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		[Roact.Event.Activated] = OnClick,
	})

	return createElement(
		'Frame',
		{ Size = UDim2.new(1, 0, 1, 0) },
		{
			PlayersList = playersList,
			Button = button,
		}
	)
end

local FinishScreenConnected = RoactRodux.connect(function(state)
	local roomId = state.player.roomId
	if roomId == nil then
		return {}
	end

	local room = state.rooms[roomId]
	return {
		isFinishScreenOpen = state.player.isFinishScreenOpen,
		startTime = room.startTime,
		playersPlaying = room.playersPlaying,
		countDown = room.countDown,
	}
end)(FinishScreen)

return FinishScreenConnected