--[[
	This Roact component represents our entire game.
]]
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Workspace = game:GetService('Workspace')
local M = require(Modules.M)
local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local RoomObjects = InventoryObjects.RoomObjects
local Roact = require(Modules.Roact)
local RoactMaterial = require(Modules.RoactMaterial)

local createElement = Roact.createElement

local getApiFromComponent = require(clientSrc.getApiFromComponent)

local InventoryAndShopButtons = require(clientSrc.Components.InventoryAndShopButtons)
local FinishScreen = require(clientSrc.Components.FinishScreen)
local Notifications = require(clientSrc.Components.common.Notifications)
local ClockScreen = require(clientSrc.Components.ClockScreen)
local Room = require(clientSrc.Components.Room)
local LeaderboardsConnect = require(clientSrc.Components.LeaderboardsConnect)

local Game = Roact.PureComponent:extend('Game')

function Game:init(props)
	self.api = getApiFromComponent(self)
end

function Game:render(props)
	local children = {}
	function createRoom(roomObject)
		children[roomObject.name] =
			createElement(
				Roact.Portal,
				{ target = Workspace },
				{ ['Room' .. roomObject.name] = createElement(Room, { roomId = roomObject.id }) }
			)
	end

	M.each(RoomObjects, createRoom)

	children['InventoryContainer'] = createElement(
		'Frame',
		{
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 5,
			BorderMode = Enum.BorderMode.Inset,
			ZIndex = 2,
		},
		{ Inventory = createElement(InventoryAndShopButtons) }
	)
	children['ClockScreenContainer'] = createElement(
		'Frame',
		{
			Position = UDim2.new(0.5, 0, 0, -30),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		},
		{ Clock = createElement(ClockScreen) }
	)
	children['FinishScreenContainer'] = createElement(
		'Frame',
		{
			Size = UDim2.new(0.8, 0, 0.9, 0),
			Position = UDim2.new(0.5, 0, 0.5, -50),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		},
		{ Finish = createElement(FinishScreen) }
	)
	children['NotificationsContainer'] = createElement(Notifications)
	children['LeaderboardsContainer'] =
		createElement(
			Roact.Portal,
			{ target = Workspace },
			{ Leaderboards = createElement(LeaderboardsConnect) }
		)

	return Roact.createElement(
		RoactMaterial.ThemeProvider,
		{ Theme = RoactMaterial.Themes.Light },
		{ createElement(
			'ScreenGui',
			{
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				ResetOnSpawn = false,
			},
			children
		) }
	)
end

return Game