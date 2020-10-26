local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local getApiFromComponent = require(clientSrc.getApiFromComponent)

local UICorner = require(clientSrc.Components.common.UICorner)
local RoundButton = require(clientSrc.Components.common.RoundButton)
local DynamicTable = require(clientSrc.Components.common.DynamicTable)
local TextListWithHeader = require(clientSrc.Components.common.TextListWithHeader)
local TextLabel = require(clientSrc.Components.common.TextLabel)
local PlayersPlayingTableRow = require(clientSrc.Components.PlayersPlayingTableRow)
local M = require(Modules.M)

local createElement = Roact.createElement

local FinishScreen = Roact.PureComponent:extend('FinishScreen')

function FinishScreen:init()
	self.state = { open = true }

	self.api = getApiFromComponent(self)
end

function FinishScreen:render()
	local playersPlaying = self.props.playersPlaying
	local noTimer = self.props.noTimer

	local noPlayers = M.count(playersPlaying) == 0

	if not self.props.isFinishScreenOpen or not self.state.open then
		return nil
	end

	if not noTimer and noPlayers then
		return nil
	end

	local title
	local playersList

	if noTimer then
		title = 'You Finished'
		logger:w('finished')
		playersList = createElement(TextListWithHeader, {
			title = title,
			[Roact.Children] = createElement(TextLabel, {
				Text = 'Congratulations!!',
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				TextSize = 36,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				LayoutOrder = 2,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}),
		})
	else
		title = 'FINISHERS'

		playersList = createElement(TextListWithHeader, {
			title = title,
			[Roact.Children] = createElement(DynamicTable, {
				items = playersPlaying,
				rowComponent = PlayersPlayingTableRow,
				rowProps = {
					TextColor3 = Color3.fromRGB(255, 255, 255),
					ghostPlayerId = self.props.ghostPlayerId,
					startTime = self.props.startTime,
					endTime = self.props.endTime,
				},
			}),
		})
	end

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
		noTimer = room.config.noTimer,
	}
end)(FinishScreen)

return FinishScreenConnected