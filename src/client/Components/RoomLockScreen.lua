local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local ContextActionService = game:GetService('ContextActionService')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local M = require(Modules.M)
local getApiFromComponent = require(clientSrc.getApiFromComponent)

local UICorner = require(clientSrc.Components.common.UICorner)
local Frame = require(clientSrc.Components.common.Frame)
local YAxisBillboard = require(clientSrc.Components.common.YAxisBillboard)
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local TouchItem = require(Modules.src.TouchItem)
local TextLabel = require(clientSrc.Components.common.TextLabel)
local UIPadding = require(clientSrc.Components.common.UIPadding)

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
				AnchorPoint = Vector2.new(0.5, 0.1),
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

	local touchPart = self.props.lockPlaceholder:WaitForChild('TouchPart')

	local function handleAction(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			local itemId = self.props.roomId
			self.api:buyItem(itemId)
		end
	end

	self.connection = TouchItem.create(
		touchPart,
		function(player)
			logger:d('Added Interact bind')
			ContextActionService:BindAction(
				'Interact',
				handleAction,
				true,
				Enum.KeyCode.E,
				Enum.KeyCode.ButtonR1
			)

			self:setState(function(state)
				return { interactActive = true }
			end)
			ContextActionService:SetTitle('Interact', 'Buy')
		end,
		function(player)
			logger:d('Removed Interact bind')
			ContextActionService:UnbindAction('Interact')
			self:setState(function(state)
				return { interactActive = false }
			end)
		end
	)
end

function RoomLockScreen:render()
	local props = self.props
	local isLockActive = props.isLockActive

	local display = self.props.lockPlaceholder:WaitForChild('Display')

	if not isLockActive then
		display.Transparency = 1
		display.CanCollide = false
		logger:d('Removing lock')
		if self.connection then
			self.connection.Disconnect()
			self.connection = nil
		end

		return
	end

	local price = props.price

	local lockedText = createElement(
		StyledText,
		{
			LayoutOrder = 1,
			Size = UDim2.new(0.4, 0, 0.4, 0),
			Text = isLockActive and 'Locked' or 'Open',
		},
		{
			UICorner = createElement(UICorner),
			UIPadding = createElement(UIPadding, { padding = 10 }),
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
			LayoutOrder = 2,
			Size = UDim2.new(0.7, 0, 0.2, 0),
			Text = tostring(price) .. ' coins',
		},
		{
			UICorner = createElement(UICorner),
			UIPadding = createElement(UIPadding, { padding = 5 }),
		}
	)
	local eText = createElement(
		StyledText,
		{
			LayoutOrder = 2,
			Size = UDim2.new(0, 200, 0, 200),
			Text = 'E',
			Transparency = 0.2,
			TextColor3 = Color3.fromRGB(0, 0, 0),
		},
		{
			UICorner = createElement(UICorner, { CornerRadius = UDim.new(0, 100) }),
			UIPadding = createElement(UIPadding, { padding = 5 }),
		}
	)

	local labelE = createElement(
		YAxisBillboard,
		{
			position = (display.CFrame * CFrame.new(Vector3.new(0, 0, -3))).Position,
			size = Vector2.new(0.1, 0.1),
		},
		{ eText = eText }
	)

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
			labelE = self.state.interactActive and labelE or nil,
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