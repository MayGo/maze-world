local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local Support = require(Modules.src.utils.SupportLibrary)
local UserInputService = game:GetService('UserInputService')

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local RoactMaterial = require(Modules.RoactMaterial)

local Print = require(Modules.src.utils.Print)

local Shop = require(clientSrc.Components.Shop)
local Frame = require(clientSrc.Components.common.Frame)
local IconButton = require(clientSrc.Components.common.IconButton)
local TextLabel = require(clientSrc.Components.common.TextLabel)

local getApiFromComponent = require(clientSrc.getApiFromComponent)

local createElement = Roact.createElement

local InventoryAndShopButtons = Roact.Component:extend('InventoryAndShopButtons')

function InventoryAndShopButtons:init()
	self.state = {
		shopOpen = false,
		inventoryOpen = false,
	}

	self.api = getApiFromComponent(self)
end

function InventoryAndShopButtons:render()
	local playerSlotsCount = self.props.playerSlotsCount
	local isPlaying = self.props.isPlaying

	local equippedItems = self.props.equippedItems

	if isPlaying then return end

	local inventoryButton = createElement(IconButton, {
		onClick = function()
			self:setState(function(prevState)
				return { inventoryOpen = not prevState.inventoryOpen }
			end)
		end,
		icon = 'inbox',
	})

	local shopButton = createElement(IconButton, {
		onClick = function()
			self:setState(function(prevState)
				return { shopOpen = not prevState.shopOpen }
			end)
		end,
		icon = 'shop',
	})

	if not self.state.shopOpen and not self.state.inventoryOpen then
		return createElement(
			Frame,
			{
				Layout = 'List',
				LayoutDirection = 'Vertical',
				Padding = UDim.new(0, 20),
				Size = UDim2.new(0, 50, 0, 100),
				Position = UDim2.new(0, 0, 0, 20),
			},
			{ shopButton, inventoryButton }
		)
	end

	local closeButton = createElement(IconButton, {
		onClick = function()
			self:setState(function()
				return {
					inventoryOpen = false,
					shopOpen = false,
				}
			end)
		end,
		icon = 'close',
	})
	local slotsCount = createElement(TextLabel, {
		Size = UDim2.new(1, 0, 1, 0),
		TextSize = 30,
		AnchorPoint = Vector2.new(0, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = 'Equipped ' .. #equippedItems .. ' / ' .. playerSlotsCount,
	})

	local closeButtonWithCount = createElement(
		'Frame',
		{
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0),
			Size = UDim2.new(0, 100, 0, 100),
			ZIndex = 1,
		},
		{ closeButton, slotsCount }
	)

	local shopProps = {
		equippedItems = self.props.equippedItems,
		inventory = self.props.inventory,
		isGhosting = self.props.isGhosting,
		buyItem = function(itemId)
			self.api:buyItem(itemId)
		end,
		startGhosting = function()
			self.api:startGhosting()
		end,
		stopGhosting = function()
			self.api:stopGhosting()
		end,
		equipItem = function(itemId)
			self.api:equipItem(itemId)
		end,
		unequipItem = function(itemId)
			self.api:unequipItem(itemId)
		end,
		[Roact.Children] = { closeButtonWithCount },
	}

	if self.state.inventoryOpen then
		return createElement(Shop, Support.Merge({ items = self.props.inventory }, shopProps))
	else
		return createElement(Shop, Support.Merge({ items = self.props.items }, shopProps))
	end
end

function InventoryAndShopButtons:didMount()
	self._connection = UserInputService.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.Keyboard then return end

		if inputObject.keyCode == Enum.KeyCode.E then
			self:setState(function(state)
				return {
					inventoryOpen = not state.inventoryOpen,
					shopOpen = false,
				}
			end)
			return
		end
		if inputObject.keyCode == Enum.KeyCode.Q then
			self:setState(function(state)
				return {
					shopOpen = not state.shopOpen,
					inventoryOpen = false,
				}
			end)
			return
		end
	end)
end

function InventoryAndShopButtons:willUnmount()
	self._connection:Disconnect()
end

InventoryAndShopButtonsConnected = RoactRodux.connect(function(state)
	return {
		items = state.shop.items,
		equippedItems = state.player.equippedItems,
		isPlaying = state.player.isPlaying,
		playerSlotsCount = state.player.playerSlotsCount,
		isGhosting = state.player.isGhosting,
		inventory = state.inventory,
	}
end)(InventoryAndShopButtons)

return InventoryAndShopButtonsConnected