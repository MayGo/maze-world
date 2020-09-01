local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local ContextActionService = game:GetService('ContextActionService')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local getApiFromComponent = require(clientSrc.getApiFromComponent)

local UICorner = require(clientSrc.Components.common.UICorner)
local Frame = require(clientSrc.Components.common.Frame)
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local TouchItem = require(Modules.src.TouchItem)
local TextLabel = require(clientSrc.Components.common.TextLabel)

local createElement = Roact.createElement
local RoomLockScreen = Roact.Component:extend('RoomLockScreen')

function RoomLockScreen:init()
	self.api = getApiFromComponent(self)

	local touchPart = self.props.lockPlaceholder:WaitForChild('TouchPart')

	local function handleAction(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			print(actionName, inputObject)

			local itemId = self.props.roomId
			self.api:buyItem(itemId)
		end
	end

	TouchItem.create(
		touchPart,
		function(player)
			logger:w('Added Interact bind')
			ContextActionService:BindAction(
				'Interact',
				handleAction,
				true,
				Enum.KeyCode.T,
				Enum.KeyCode.ButtonR1
			)

			ContextActionService:SetTitle('Interact', 'Buy')
		end,
		function(player)
			logger:w('Removed Interact bind')
			ContextActionService:UnbindAction('Interact')
		end
	)
end
function RoomLockScreen:render()
	local props = self.props

	local price = 100

	local lockedText = createElement(
		TextLabel,
		{
			LayoutOrder = 1,
			Size = UDim2.new(0.4, 0, 0.4, 0),
			TextScaled = true,
			TextSize = 30,
			AnchorPoint = Vector2.new(0.5, 0.1),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Text = 'Locked',
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = props.BackgroundTransparency or 0.5,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
		},
		{ UICorner = createElement(UICorner) }
	)

	local priceText = createElement(
		TextLabel,
		{
			LayoutOrder = 2,
			Size = UDim2.new(0.7, 0, 0.2, 0),
			TextScaled = true,
			TextSize = 30,
			AnchorPoint = Vector2.new(0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Text = 'Price: ' .. tostring(price) .. ' coins',
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = props.BackgroundTransparency or 0.5,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
		},
		{ UICorner = createElement(UICorner) }
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
		}
	)
end

local RoomLockScreenConnected = RoactRodux.connect(function(state, props)
	local roomId = props.roomId
	local room = state.rooms[roomId]

	return {
		isFinishScreenOpen = state.player.isFinishScreenOpen,
		countDownTime = room.countDownTime,
		countDownText = room.countDownText,
		playersPlaying = room.playersPlaying,
		playersWaiting = room.playersWaiting,
	}
end)(RoomLockScreen)

return RoomLockScreenConnected