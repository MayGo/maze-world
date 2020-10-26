--[[
	Creates Leaderboards with correct bindings with different parts
]]
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local getApiFromComponent = require(clientSrc.getApiFromComponent)
local SurfaceBillboard = require(clientSrc.Components.common.SurfaceBillboard)
local DynamicTable = require(clientSrc.Components.common.DynamicTable)
local NameValueTableRow = require(clientSrc.Components.NameValueTableRow)

local createElement = Roact.createElement

local LeaderboardsConnect = Roact.PureComponent:extend('LeaderboardsConnect')

local Place = game.Workspace:WaitForChild('Place')
local leaderboards = Place.Leaderboards

function LeaderboardsConnect:init()
	self.api = getApiFromComponent(self)
	logger:d('Init LeaderboardsConnect')
end

function LeaderboardsConnect:render()
	local children = {}

	if not leaderboards then
		logger:w('Leaderboards folder with placeholders does not exists!')
		return
	end

	local visitorsPlaceholder =
		leaderboards.placeholders:WaitForChild('VisitorsPlaceholder', math.huge)
	local coinsPlaceholder = leaderboards.placeholders:WaitForChild('CoinsPlaceholder', math.huge)
	local playedPlaceholder = leaderboards.placeholders:WaitForChild('PlayedPlaceholder', math.huge)

	children['playedPlaceholder'] = createElement(SurfaceBillboard, {
		item = playedPlaceholder,
		title = 'Most Games Finished',
		[Roact.Children] = createElement(DynamicTable, {
			items = self.props.mostPlayed,
			rowComponent = NameValueTableRow,
			rowProps = { TextColor3 = Color3.fromRGB(255, 255, 255) },
		}),
	})

	children['visitorsPlaceholder'] = createElement(SurfaceBillboard, {
		item = visitorsPlaceholder,
		title = 'Top Visitors',
		[Roact.Children] = createElement(DynamicTable, {
			items = self.props.mostVisited,
			rowComponent = NameValueTableRow,
			rowProps = { TextColor3 = Color3.fromRGB(255, 255, 255) },
		}),
	})

	logger:w('self.props.mostCoins', self.props.mostCoins)
	children['coinsPlaceholder'] = createElement(SurfaceBillboard, {
		item = coinsPlaceholder,
		title = 'Top Coins',
		[Roact.Children] = createElement(DynamicTable, {
			items = self.props.mostCoins,
			rowComponent = NameValueTableRow,
			rowProps = { TextColor3 = Color3.fromRGB(255, 255, 255) },
		}),
	})
	return createElement('Folder', nil, children)
end

LeaderboardsConnect = RoactRodux.connect(function(state)
	return {
		mostVisited = state.leaderboards.mostVisited,
		mostCoins = state.leaderboards.mostCoins,
		mostPlayed = state.leaderboards.mostPlayed,
	}
end)(LeaderboardsConnect)

return LeaderboardsConnect