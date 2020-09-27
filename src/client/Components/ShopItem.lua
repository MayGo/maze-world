local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')

local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local TextLabel = require(clientSrc.Components.common.TextLabel)
local ModelViewport = require(clientSrc.Components.common.ModelViewport)
local logger = require(Modules.src.utils.Logger)
local M = require(Modules.M)
local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local ModelManager = require(Modules.src.ModelManager)
local RoundButton = require(clientSrc.Components.common.RoundButton)
local UICorner = require(clientSrc.Components.common.UICorner)
local Frame = require(clientSrc.Components.common.Frame)

local OBJECT_TYPES = InventoryObjects.OBJECT_TYPES
local GamePasses = require(Modules.src.GamePasses)
local DeveloperProducts = require(Modules.src.DeveloperProducts)
local Roact = require(Modules.Roact)
local RoactMaterial = require(Modules.RoactMaterial)

local createElement = Roact.createElement

local ShopItem = Roact.PureComponent:extend('ShopItem')

function ShopItem:render()
	local props = self.props
	local item = self.props.item
	local isDisabled = self.props.isDisabled
	local cellWidth = self.props.cellWidth
	local buttonHeight = self.props.buttonHeight
	local titleHeight = self.props.titleHeight

	local equippedItems = props.equippedItems
	local inventory = props.inventory
	local isEquipped = M.find(equippedItems, item.id) ~= nil
	local isOwned = inventory[item.id] ~= nil

	local isGhosting = props.isGhosting

	local buyItem = props.buyItem
	local equipItem = props.equipItem
	local unequipItem = props.unequipItem
	local startGhosting = props.startGhosting
	local stopGhosting = props.stopGhosting

	local onClick = function()
		if item.isDeveloperProduct then
			DeveloperProducts:promptPurchase(item.id)
		elseif item.isGamePass then
			if not isOwned then
				GamePasses:promptPurchase(item.id)
			elseif item.isGhost and isGhosting then
				stopGhosting()
			elseif item.isGhost then
				startGhosting()
			end
		elseif isEquipped then
			unequipItem(item.id)
		elseif isOwned then
			equipItem(item.id)
		else
			buyItem(item.id)
		end
	end

	if isDisabled then
		onClick = nil
	end

	local image
	local aspect

	if item.modelName and item.modelFolder and not item.icon then
		local model = ModelManager:findModel(item)

		if not model then
			logger:e('No model found with name: ' .. item.modelName)
		else
			image = createElement(ModelViewport, {
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				model = model:Clone(),
				Visible = true,
				BackgroundTransparency = 1,
				cameraOffset = item.cameraOffset,
				isRotating = item.isRotating,
			})
		end
	else
		aspect = createElement('UIAspectRatioConstraint')
		image = createElement('ImageButton', {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = item.icon,
			BackgroundTransparency = 1,
			ZIndex = 2,
		})
	end

	local nameLabel = createElement(
		TextLabel,
		{
			AnchorPoint = Vector2.new(0.5, 1.0),
			Position = UDim2.new(0.5, 0, 1, 0),
			Size = UDim2.new(1, 0, titleHeight, 0),
			TextScaled = true,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.5,
			Font = Enum.Font.Cartoon,
			TextColor3 = Color3.new(0.85, 0.85, 0.85),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextSize = 18,
			Text = item.name,
			LayoutOrder = 0,
		},
		{ UICorner = createElement(UICorner) }
	)

	local buttonText = '..'

	if item.type == OBJECT_TYPES.PET then
		if isEquipped then
			buttonText = 'Equipped (X)'
		elseif isOwned then
			buttonText = 'Equip'
		elseif item.price then
			buttonText = item.price .. ' Coins'
		end
	elseif item.type == OBJECT_TYPES.COLLECTABLE then
		buttonText = 'Collected'
	elseif item.type == OBJECT_TYPES.COIN_PACK then
		if item.price then
			buttonText = item.price .. ' Robux'
		end
	elseif item.type == OBJECT_TYPES.GAME_PASS then
		if item.isGhost and isGhosting then
			buttonText = 'Stop ghosting'
		elseif item.isGhost and isOwned then
			buttonText = 'Start ghosting'
		elseif item.isGamePass and isOwned then
			buttonText = 'Owned'
		elseif item.price then
			buttonText = item.price .. ' Robux'
		end
	else
		logger:w('No type found for item', item)
	end

	if isDisabled then
		buttonText = 'Buy tool first'
	end

	local amountLabel
	if item.amount then
		local outOfStock = item.amount == 0
		local color = outOfStock and Color3.fromRGB(199, 0, 0) or Color3.fromRGB(255, 255, 255)

		amountLabel = createElement(TextLabel, {
			Position = UDim2.new(0, -5, 0, 5),
			Size = UDim2.new(1, 0, 0, 20),
			TextScaled = true,
			Font = Enum.Font.Cartoon,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			Text = outOfStock and 'Out Of Stock' or item.amount .. 'x',
		})
	end

	local imageLabel = createElement(
		'Frame',
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(0.6, 0, 0.6, 0),
			LayoutOrder = 1,
		},
		{
			image = image,
			aspect = aspect,
			amountLabel = amountLabel,
		}
	)

	local children = {
		name = nameLabel,
		imageLabel = imageLabel,
	}

	local buttonProps = {
		Text = buttonText,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		TextScaled = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 0, buttonHeight, 0),
		onClicked = onClick,
		BackgroundColor3 = RoactMaterial.Colors.Blue500,
		LayoutOrder = 2,
	}

	if item.isGamePass and isOwned then
		buttonProps = M.extend({}, buttonProps, {
			BackgroundColor3 = RoactMaterial.Colors.Grey400,
			onClick = nil,
		})
	elseif isEquipped then
		buttonProps = M.extend({}, buttonProps, { BackgroundColor3 = RoactMaterial.Colors.Blue500 })
	elseif isOwned then
		buttonProps = M.extend({}, buttonProps, { BackgroundColor3 = RoactMaterial.Colors.Grey400 })
	end

	if isDisabled then
		buttonProps = M.extend({}, buttonProps, { BackgroundColor3 = RoactMaterial.Colors.Grey400 })
	end

	children['button'] = createElement(RoundButton, buttonProps)

	children['aspect'] = createElement('UIAspectRatioConstraint')

	return createElement(
		Frame,
		{
			Layout = 'List',
			Padding = UDim.new(0, 0),
			BackgroundTransparency = 0.7,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		},
		children
	)
end

return ShopItem