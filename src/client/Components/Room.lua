--[[
	Creates Rooms with correct bindings with different parts
]]
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local getApiFromComponent = require(clientSrc.getApiFromComponent)
local SurfaceBillboard = require(clientSrc.Components.common.SurfaceBillboard)
local ClockScreen = require(clientSrc.Components.ClockScreen)
local RoomLockScreen = require(clientSrc.Components.RoomLockScreen)
local DynamicTable = require(clientSrc.Components.common.DynamicTable)
local PlayersPlayingTableRow = require(clientSrc.Components.PlayersPlayingTableRow)
local NameValueTableRow = require(clientSrc.Components.NameValueTableRow)

local createElement = Roact.createElement

local Room = Roact.Component:extend('Room')

local Place = game.Workspace:WaitForChild('Place')
local RoomsFolder = Place:findFirstChild('Rooms')

function Room:init()
	self.api = getApiFromComponent(self)
	local roomId = self.props.roomId
	logger:d('Init room: ' .. roomId)
end

function Room:render()
	local children = {}
	local roomId = self.props.roomId
	local modelName = self.props.modelName
	if not RoomsFolder then
		logger:w('Rooms Folder does not exists!')
		return
	end

	local roomObj = RoomsFolder:findFirstChild(modelName)
	if not roomObj then
		logger:w('Room object for ' .. modelName .. ' does not exists!')
		return
	end

	local waitingPlaceholder = roomObj.placeholders:WaitForChild('WaitingPlaceholder')
	local playingPlaceholder = roomObj.placeholders:WaitForChild('PlayingPlaceholder')
	local timerPlaceholder = roomObj.placeholders:WaitForChild('TimerPlaceholder')
	local lockPlaceholder = roomObj.placeholders:FindFirstChild('LockPlaceholder')

	children['waitingPlaceholder'] = createElement(SurfaceBillboard, {
		item = waitingPlaceholder,
		title = 'Waiting',
		[Roact.Children] = createElement(DynamicTable, {
			items = self.props.playersWaiting,
			rowComponent = NameValueTableRow,
			rowProps = {
				startTime = self.props.startTime,
				nameField = 'name',
				noValueField = true,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			},
		}),
	})

	children['playingPlaceholder'] = createElement(SurfaceBillboard, {
		item = playingPlaceholder,
		title = 'PLAYERS',
		[Roact.Children] = createElement(DynamicTable, {
			items = self.props.playersPlaying,
			rowComponent = PlayersPlayingTableRow,
			rowProps = {
				startTime = self.props.startTime,
				endTime = self.props.endTime,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			},
		}),
	})

	children['timer'] = createElement(SurfaceBillboard, {
		item = timerPlaceholder,
		noTextListWithHeader = true,
		[Roact.Children] = createElement(
			'Frame',
			{
				Position = UDim2.new(0.5, 0, 0, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
			},
			{ Clock = createElement(ClockScreen, {
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
			}) }
		),
	})
	if lockPlaceholder then
		children['lock'] = createElement(SurfaceBillboard, {
			item = lockPlaceholder,
			noTextListWithHeader = true,
			[Roact.Children] = createElement(RoomLockScreen, {
				lockPlaceholder = lockPlaceholder,
				roomId = roomId,
			}),
		})
	end

	return createElement('Folder', nil, children)
end

Room = RoactRodux.connect(function(state, props)
	local roomId = props.roomId
	local room = state.rooms[roomId]
	return {
		roomId = roomId,
		startTime = room.startTime,
		modelName = room.modelName,
		playersWaiting = room.playersWaiting,
		playersPlaying = room.playersPlaying,
		countDownTime = room.countDownTime,
	}
end)(Room)

return Room