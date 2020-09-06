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
local TagItem = require(Modules.src.TagItem)
local AudioPlayer = require(Modules.src.AudioPlayer)

local Game = Roact.Component:extend('Game')

function Game:init(props)
	self.api = getApiFromComponent(self)
	TagItem.create(nil, 'KillBrick', function(player, hit)
		logger:d('Player killed with killbrick. Hit name:', hit.Name)
		hit.parent.Humanoid.Health = 0
	end)

	TagItem.create(nil, 'CoinBrick', function(player, hit, part)
		if part:FindFirstChild('itemId') then
			logger:d('Player got coin with value: ' .. part.itemId.Value)

			self.api:pickUpCoin(tostring(part.itemId.Value))
			AudioPlayer.playAudio('Coin_Collect')

			if part.Name == 'PrimaryPart' then
				local model = part:FindFirstAncestorOfClass('Model')
				model:Destroy()
			else
				part.Parent = nil
				wait(10)
				part.Parent = game.workspace
			end
		else
			logger:w('No itemId Value for coin part')
		end
	end)

	TagItem.create(nil, 'CollectableBrick', function(player, hit, part)
		if part.itemId then
			logger:d('Player got collectable with value: ' .. part.itemId.Value)
			self.api:pickUpItem(tostring(part.itemId.Value))
			--local coinClone = part:Clone()
			--part:Destroy()

			part.Parent = nil
			wait(10)
			part.Parent = game.workspace
		else
			logger:w('No itemId Value for collectable part')
		end
	end)
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
			Size = UDim2.new(0.8, 0, 0.6, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
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