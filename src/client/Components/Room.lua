--[[
	Creates Rooms with correct bindings with different parts
]]
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local Maid = require(Modules.Knit.Util.Maid)

local TouchItem = require(Modules.src.TouchItem)
local M = require(Modules.M)
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local getApiFromComponent = require(clientSrc.getApiFromComponent)
local SurfaceBillboard = require(clientSrc.Components.common.SurfaceBillboard)
local RoomClockScreen = require(clientSrc.Components.RoomClockScreen)
local RoomLockScreen = require(clientSrc.Components.RoomLockScreen)
local DynamicTable = require(clientSrc.Components.common.DynamicTable)
local PlayersPlayingTableRow = require(clientSrc.Components.PlayersPlayingTableRow)
local NameValueTableRow = require(clientSrc.Components.NameValueTableRow)
local TextLabel = require(clientSrc.Components.common.TextLabel)

local createElement = Roact.createElement

local Room = Roact.PureComponent:extend('Room')

local Place = game.Workspace:WaitForChild('Place')
local RoomsFolder = Place:findFirstChild('Rooms')

function Room:init()
	self.maid = Maid.new()
	self.api = getApiFromComponent(self)
	local roomId = self.props.roomId
	logger:d('Init room: ' .. roomId)
end

function Room:willUnmount()
	self.maid:Destroy()
end

local activeColor = Color3.fromRGB(9, 255, 0)
local notActiveColor = Color3.fromRGB(255, 255, 255)

function Room:didMount()
	self.running = true

	-- We don't want to block the main thread, so we spawn a new one!
	-- We are using StreamingEnabled, so all rooms are not loaded all the time
	spawn(function()
		local modelName = self.props.modelName
		local roomId = self.props.roomId
		local config = self.props.config

		if not RoomsFolder then
			logger:w('Rooms Folder does not exists!')
			return
		end

		local roomObj = RoomsFolder:WaitForChild(modelName)
		if not roomObj then
			logger:w('Room object for ' .. modelName .. ' does not exists!')
			return
		end

		self.playingPlaceholder = roomObj.placeholders:WaitForChild('PlayingPlaceholder', math.huge)
		self.waitingPlaceholder = roomObj.placeholders:WaitForChild('WaitingPlaceholder', math.huge)

		if config.noTimer then
			logger:d('No TimerPlaceholder needed for ' .. modelName) -- Fires when a player enters the zone -- Fires when a player exits the zone
		else
			self.timerPlaceholder = roomObj.placeholders:WaitForChild('TimerPlaceholder', math.huge)

			local votingPlaceholders =
				roomObj.placeholders:WaitForChild('VotingPlaceholders', math.huge)
			local votingBooths = votingPlaceholders:GetChildren()

			self.votingPlaceholders = {}
			self.votingTouchPart = {}

			for _, votingBooth in ipairs(votingBooths) do
				local boothName = votingBooth.BoothName.Value
				local touchPart = votingBooth:WaitForChild('VoteTouch')

				self.votingPlaceholders[boothName] = votingBooth:WaitForChild('ScreenPlaceholder')
				self.votingTouchPart[boothName] = touchPart

				self.maid[boothName] = TouchItem.create(touchPart, function()
					logger:w('Entered voting ' .. boothName)

					self.api:roomVote(roomId, boothName)

					self:setState(function()
						return { selectedBooth = boothName }
					end)
				end)
			end
		end

		self:setState(function(state)
			return { roomLoaded = true }
		end)

		if config.noTimer then
			logger:d('No LockPlaceholder needed for ' .. modelName)
		else
			self.lockPlaceholder = roomObj.placeholders:WaitForChild('LockPlaceholder', math.huge)
		end

		self:setState(function(state)
			return {
				roomLoaded = state.roomLoaded,
				lockLoaded = true,
			}
		end)
	end)
end

function Room:render()
	local children = {}
	local roomId = self.props.roomId
	local startTime = self.props.startTime
	local mostPlayed = self.props.mostPlayed
	local config = self.props.config
	local playerVotes = self.props.playerVotes
	local selectedBooth = self.state.selectedBooth

	if not self.waitingPlaceholder and not self.playingPlaceholder and not self.timerPlaceholder then
		logger:d('Not rendering room')
		return
	end

	local votes = M.countBy(playerVotes, function(vote)
		return vote
	end)

	if self.votingPlaceholders then
		for boothName, votingPlaceholder in pairs(self.votingPlaceholders) do
			self.votingTouchPart[boothName].Color =
				boothName == selectedBooth and activeColor or notActiveColor

			children['voting_' .. boothName] = createElement(SurfaceBillboard, {
				item = votingPlaceholder,
				title = boothName,
				[Roact.Children] = createElement(TextLabel, {
					Text = votes[boothName] and votes[boothName] or 0,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					TextSize = 36,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					LayoutOrder = 2,
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}),
			})
		end
	else
		logger:d('No votingPlaceholders')
	end

	if self.waitingPlaceholder then
		children['waitingPlaceholder'] = createElement(SurfaceBillboard, {
			item = self.waitingPlaceholder,
			title = 'Most Games Finished',
			[Roact.Children] = createElement(DynamicTable, {
				items = mostPlayed,
				rowComponent = NameValueTableRow,
				rowProps = { TextColor3 = Color3.fromRGB(255, 255, 255) },
			}),
		})
	else
		logger:d('No waitingPlaceholder')
	end

	if self.playingPlaceholder then
		local waitingTable = createElement(SurfaceBillboard, {
			item = self.playingPlaceholder,
			title = config.noTimer and 'Inside of maze' or 'Waiting',
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

		local playingTable = createElement(SurfaceBillboard, {
			item = self.playingPlaceholder,
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

		if startTime then
			children['playing'] = playingTable
		else
			children['waiting'] = waitingTable
		end
	else
		logger:d('No playingPlaceholder')
	end

	if self.timerPlaceholder then
		children['timer'] = createElement(SurfaceBillboard, {
			item = self.timerPlaceholder,
			noTextListWithHeader = true,
			[Roact.Children] = createElement(RoomClockScreen, {
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				roomId = roomId,
			}),
		})
	else
		logger:d('No timerPlaceholder')
	end

	if self.lockPlaceholder then
		children['lock'] = createElement(SurfaceBillboard, {
			item = self.lockPlaceholder:WaitForChild('Display'),
			noTextListWithHeader = true,
			[Roact.Children] = createElement(RoomLockScreen, {
				lockPlaceholder = self.lockPlaceholder,
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
		mostPlayed = state.leaderboards[roomId],
		roomId = roomId,
		startTime = room.startTime,
		modelName = room.modelName,
		playersWaiting = room.playersWaiting,
		playersPlaying = room.playersPlaying,
		playerVotes = room.playerVotes,
		countDownTime = room.countDownTime,
		config = room.config,
	}
end)(Room)

return Room