--[[
	This Roact component represents our entire game.
]]
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Workspace = game:GetService('Workspace')

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
local RoomsConfig = require(Modules.src.RoomsConfig)
local TagItem = require(Modules.src.TagItem)

local Game = Roact.Component:extend('Game')

function Game:init(props)
	self.api = getApiFromComponent(self)
	TagItem.create(nil, 'KillBrick', function(player, hit)
		logger:d('Player killed with killbrick. Hit name:', hit.Name)
		hit.parent.Humanoid.Health = 0
	end)
	TagItem.create(nil, 'CoinBrick', function(player, hit, part)
		if part.itemId then
			logger:d('Player got coin with value: ' .. part.itemId.Value)
			self.api:pickUpCoin(tostring(part.itemId.Value))
			--local coinClone = part:Clone()
			--part:Destroy()

			part.Parent = nil
			wait(10)
			part.Parent = game.workspace
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
	return Roact.createElement(
		RoactMaterial.ThemeProvider,
		{ Theme = RoactMaterial.Themes.Light },
		{ createElement(
			'ScreenGui',
			{
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				ResetOnSpawn = false,
			},
			{
				InventoryContainer = createElement(
					'Frame',
					{
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						BorderSizePixel = 5,
						BorderMode = Enum.BorderMode.Inset,
						ZIndex = 2,
					},
					{ Inventory = createElement(InventoryAndShopButtons) }
				),
				ClockScreenContainer = createElement(
					'Frame',
					{
						Position = UDim2.new(0.5, 0, -0.1, 0),
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
					},
					{ Clock = createElement(ClockScreen) }
				),
				FinishScreenContainer = createElement(
					'Frame',
					{
						Size = UDim2.new(0.8, 0, 0.6, 0),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
					},
					{ Finish = createElement(FinishScreen) }
				),
				Notifications = createElement(Notifications),
				-- Even through our UI is being rendered inside a PlayerGui, we can
				-- always take advantage of a feature called portals to put instances
				-- elsewhere.

				-- Portals are a feature that makes having a virtual tree worthwhile,
				-- since implementing them without having formalized destructors is
				-- bug-prone!

				RoomEasy = createElement(
					Roact.Portal,
					{ target = Workspace },
					{ Room = createElement(Room, { roomId = RoomsConfig.EASY }) }
				),
				RoomMedium = createElement(
					Roact.Portal,
					{ target = Workspace },
					{ Room = createElement(Room, { roomId = RoomsConfig.MEDIUM }) }
				),
				RoomHard = createElement(
					Roact.Portal,
					{ target = Workspace },
					{ Room = createElement(Room, { roomId = RoomsConfig.HARD }) }
				),
				LeaderboardsA = createElement(
					Roact.Portal,
					{ target = Workspace },
					{ Leaderboards = createElement(LeaderboardsConnect) }
				),
			}
		) }
	)
end

return Game