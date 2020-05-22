local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local M = require(Modules.M)
local InventoryObjects = require(Modules.src.objects.InventoryObjects)

local OBJECT_TYPES = InventoryObjects.OBJECT_TYPES
local GamePasses = require(Modules.src.GamePasses)
local Roact = require(Modules.Roact)
local Dict = require(Modules.src.utils.Dict)
local RoactMaterial = require(Modules.RoactMaterial)

local createElement = Roact.createElement

local ShopItem = Roact.Component:extend('ShopItem')

function ShopItem:render()
	local props = self.props
	local item = self.props.item

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
		if item.isGamePass then
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

	local layout = createElement('UIListLayout', {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local imageLabel = createElement('ImageButton', {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 100, 0, 100),
		Image = item.icon,
		BackgroundTransparency = 1,
		ZIndex = 2,
	})

	local nameLabel = createElement('TextLabel', {
		AnchorPoint = Vector2.new(0.5, 1.0),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 0.2, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		Font = Enum.Font.Cartoon,
		TextColor3 = Color3.new(0.85, 0.85, 0.85),
		TextSize = 18,
		Text = item.name,
	})

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
	elseif item.type == OBJECT_TYPES.COIN then
		buttonText = 'UNUSED'
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

	-- Have to create all 3 buttons, because they animate and switching bg color brakes that
	local buttonProps = {
		Text = buttonText,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 0, 0.2, 0),
		onClicked = onClick,
		BackgroundColor3 = RoactMaterial.Colors.Blue200,
	}

	local children = { layout, nameLabel, imageLabel }

	local buyButton = createElement(RoactMaterial.Button, buttonProps)
	local equipButton = createElement(RoactMaterial.Button, Dict:join(buttonProps, { BackgroundColor3 = RoactMaterial.Colors.Grey400 }))
	local gamePassButton = createElement(
		RoactMaterial.Button,
		Dict:join(buttonProps, {
			BackgroundColor3 = RoactMaterial.Colors.Grey400,
			onClick = nil,
		})
	)
	local equippedButton = createElement(RoactMaterial.Button, Dict:join(buttonProps, { BackgroundColor3 = RoactMaterial.Colors.Blue500 }))

	if item.isGamePass and isOwned then
		children['gamePassButton'] = gamePassButton
	elseif isEquipped then
		children['equipButton'] = equipButton
	elseif isOwned then
		children['equippedButton'] = equippedButton
	else
		children['buyButton'] = buyButton
	end

	return createElement(
		'Frame',
		{
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.7,
		},
		children
	)
end

return ShopItem