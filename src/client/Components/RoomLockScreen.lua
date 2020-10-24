local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local M = require(Modules.M)
local getApiFromComponent = require(clientSrc.getApiFromComponent)

local UICorner = require(clientSrc.Components.common.UICorner)
local Frame = require(clientSrc.Components.common.Frame)
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local TextLabel = require(clientSrc.Components.common.TextLabel)
local UIPadding = require(clientSrc.Components.common.UIPadding)
local BillboardBuyButton = require(clientSrc.Components.common.BillboardBuyButton)

local createElement = Roact.createElement
local RoomLockScreen = Roact.PureComponent:extend('RoomLockScreen')

local function StyledText(props)
	return createElement(
		TextLabel,
		M.extend(
			{},
			{
				LayoutOrder = 1,
				Size = UDim2.new(0.4, 0, 0.4, 0),
				TextScaled = true,
				TextSize = 30,
				AnchorPoint = Vector2.new(0.5, 0),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = props.BackgroundTransparency or 0.7,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(255, 255, 255),
			},
			props
		)
	)
end

function RoomLockScreen:init()
	self.api = getApiFromComponent(self)
end

function RoomLockScreen:render()
	local props = self.props
	local isLockActive = props.isLockActive

	local display = self.props.lockPlaceholder:WaitForChild('Display')

	if not isLockActive then
		display.Transparency = 1
		display.CanCollide = false
		logger:d('Removing lock')

		return
	end

	local price = props.price

	local lockedText = createElement(
		StyledText,
		{
			LayoutOrder = 1,
			Size = UDim2.new(0.3, 0, 0.3, 0),
			Text = isLockActive and 'Locked' or 'Open',
		},
		{
			UICorner = createElement(UICorner),
			UIPadding = createElement(UIPadding, { padding = 5 }),
		}
	)
	local priceText = createElement(
		StyledText,
		{
			LayoutOrder = 2,
			Size = UDim2.new(0.7, 0, 0.2, 0),
			Text = 'Unlock for:',
		},
		{
			UICorner = createElement(UICorner),
			UIPadding = createElement(UIPadding, { padding = 5 }),
		}
	)
	local priceAmountText = createElement(
		StyledText,
		{
			LayoutOrder = 3,
			Size = UDim2.new(0.7, 0, 0.2, 0),
			Text = tostring(price) .. ' coins',
		},
		{
			UICorner = createElement(UICorner),
			UIPadding = createElement(UIPadding, { padding = 5 }),
		}
	)

	local onClicked = function()
		local itemId = self.props.roomId
		self.api:buyItem(itemId)
	end

	local buyButton = createElement(BillboardBuyButton, {
		CFrame = display.CFrame,
		onClicked = onClicked,
	})

	return createElement(
		Frame,
		{
			Layout = 'List',
			LayoutDirection = 'Vertical',
			HorizontalAlignment = 'Center',
			Padding = UDim.new(0, 3),
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 0),
		},
		{
			lockedText = lockedText,
			priceText = priceText,
			priceAmountText = priceAmountText,
			buyButton = buyButton,
		}
	)
end

local RoomLockScreenConnected = RoactRodux.connect(function(state, props)
	local roomId = props.roomId
	local room = state.rooms[roomId]
	local hasRoom = state.inventory[roomId]

	return {
		isLockActive = not hasRoom,
		price = room.price,
	}
end)(RoomLockScreen)

return RoomLockScreenConnected