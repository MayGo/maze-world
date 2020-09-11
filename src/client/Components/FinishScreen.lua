local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local getApiFromComponent = require(clientSrc.getApiFromComponent)

local UICorner = require(clientSrc.Components.common.UICorner)
local RoundButton = require(clientSrc.Components.common.RoundButton)
local DynamicTable = require(clientSrc.Components.common.DynamicTable)
local TextListWithHeader = require(clientSrc.Components.common.TextListWithHeader)
local PlayersPlayingTableRow = require(clientSrc.Components.PlayersPlayingTableRow)

local createElement = Roact.createElement

local FinishScreen = Roact.PureComponent:extend('FinishScreen')

function FinishScreen:init()
	self.state = { open = true }

	self.api = getApiFromComponent(self)
end

function FinishScreen:render()
	if not self.props.isFinishScreenOpen or not self.state.open then
		return nil
	end

	local title = 'FINISHERS'

	local playersList = createElement(TextListWithHeader, {
		title = title,
		[Roact.Children] = createElement(DynamicTable, {
			items = self.props.playersPlaying,
			rowComponent = PlayersPlayingTableRow,
			rowProps = {
				TextColor3 = Color3.fromRGB(255, 255, 255),
				ghostPlayerId = self.props.ghostPlayerId,
				startTime = self.props.startTime,
				endTime = self.props.endTime,
			},
		}),
	})

	function OnClick()
		self:setState({ open = false })
	end

	local button = createElement(RoundButton, {
		Text = 'CLOSE',
		Position = UDim2.new(0.5, 0, 1, 10),
		AnchorPoint = Vector2.new(0.5, 0),
		onClicked = OnClick,
	})

	return createElement(
		'Frame',
		{
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(124, 0, 215),
		},
		{
			UICorner = createElement(UICorner),
			PlayersList = playersList,
			Button = button,
		}
	)
end
--[[
function FinishScreen:shouldUpdate(newProps, newState)
	return newProps.isFinishScreenOpen ~= self.props.isFinishScreenOpen or newState.open ~= self.state.open
end
]]

function FinishScreen:didUpdate(previousProps, previousState)
	if not previousProps.isFinishScreenOpen and not previousState.open then
		self:setState(function()
			return { open = true }
		end)
	end
end

local FinishScreenConnected = RoactRodux.connect(function(state)
	local roomId = state.player.lastFinishedRoomId
	if roomId == nil then
		return {}
	end

	local room = state.rooms[roomId]

	return {
		isFinishScreenOpen = state.player.isFinishScreenOpen,
		startTime = room.startTime,
		endTime = room.endTime,
		playersPlaying = room.playersPlaying,
		countDownTime = room.countDownTime,
	}
end)(FinishScreen)

return FinishScreenConnected