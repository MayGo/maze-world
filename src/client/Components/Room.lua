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
local RoomTimer = require(clientSrc.Components.RoomTimer)
local TextList = require(clientSrc.Components.common.TextList)
local DynamicTable = require(clientSrc.Components.common.DynamicTable)
local PlayersPlayingTableRow = require(clientSrc.Components.PlayersPlayingTableRow)

local createElement = Roact.createElement

local Room = Roact.Component:extend('Room')

local RoomsFolder = game.workspace:findFirstChild('Rooms')

function Room:init()
	self.api = getApiFromComponent(self)
	local roomId = self.props.roomId
	logger:d('Init room: ' .. roomId)
end

function Room:render()
	local children = {}
	local roomId = self.props.roomId
	if not RoomsFolder then
		logger:w('Rooms Folder does not exists!')
		return
	end

	local roomObj = RoomsFolder:findFirstChild(roomId)
	if not roomObj then
		logger:w('Room object for ' .. roomId .. ' does not exists!')
		return
	end

	local waitingPlaceholder = roomObj.placeholders.WaitingPlaceholder
	local playingPlaceholder = roomObj.placeholders.PlayingPlaceholder
	local timerPlaceholder = roomObj.placeholders.TimerPlaceholder

	children['waitingPlaceholder'] = createElement(SurfaceBillboard, {
		item = waitingPlaceholder,
		title = 'Waiting',
		[Roact.Children] = createElement(TextList, { items = self.props.playersWaiting }),
	})
	children['playingPlaceholder'] = createElement(SurfaceBillboard, {
		item = playingPlaceholder,
		title = 'Playing',
		[Roact.Children] = createElement(DynamicTable, {
			items = self.props.playersPlaying,
			startTime = self.props.startTime,
			rowComponent = PlayersPlayingTableRow,
		}),
	})

	children['timer'] = createElement(RoomTimer, {
		item = timerPlaceholder,
		countDown = self.props.countDown,
	})

	return createElement('Folder', nil, children)
end

Room = RoactRodux.connect(function(state, props)
	local roomId = props.roomId
	return {
		roomId = roomId,
		startTime = state.rooms[roomId].startTime,
		playersWaiting = state.rooms[roomId].playersWaiting,
		playersPlaying = state.rooms[roomId].playersPlaying,
		countDown = state.rooms[roomId].countDown,
	}
end)(Room)

return Room