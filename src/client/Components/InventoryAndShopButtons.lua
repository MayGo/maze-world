local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local Support = require(Modules.src.utils.SupportLibrary)
local ContextActionService = game:GetService('ContextActionService')

local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local M = require(Modules.M)
local Shop = require(clientSrc.Components.Shop)
local UICorner = require(clientSrc.Components.common.UICorner)

local RoundButton = require(clientSrc.Components.common.RoundButton)
local Frame = require(clientSrc.Components.common.Frame)

local getApiFromComponent = require(clientSrc.getApiFromComponent)

local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local OBJECT_TYPES = InventoryObjects.OBJECT_TYPES

local createElement = Roact.createElement

local InventoryAndShopButtons = Roact.PureComponent:extend('InventoryAndShopButtons')

function InventoryAndShopButtons:init()
	self.state = {
		shopOpen = false,
		inventoryOpen = false,
	}

	self.api = getApiFromComponent(self)
end

function InventoryAndShopButtons:render()
	local props = self.props
	local isPlaying = props.isPlaying
	local inventory = props.inventory

	if isPlaying then return end

	local toggleInventory = function()
		self:setState(function(prevState)
			return { inventoryOpen = not prevState.inventoryOpen }
		end)
	end
	local toggleShop = function()
		self:setState(function(prevState)
			return { shopOpen = not prevState.shopOpen }
		end)
	end

	local inventoryButton = createElement(RoundButton, {
		icon = 'inbox',
		onClicked = toggleInventory,
	})
	local shopButton = createElement(RoundButton, {
		icon = 'shop',
		onClicked = toggleShop,
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

	local closeInventoryAndShop = function()
		self:setState(function()
			return {
				inventoryOpen = false,
				shopOpen = false,
			}
		end)
	end

	local shopProps = {
		tabs = OBJECT_TYPES,
		closeClick = closeInventoryAndShop,
		equippedItems = self.props.equippedItems,
		isGhosting = self.props.isGhosting,
		inventory = inventory,
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
	}

	return createElement(
		Frame,
		{
			BackgroundColor3 = Color3.fromRGB(179, 216, 236),
			BackgroundTransparency = 0.1,
		},
		{
			UICorner = createElement(UICorner),
			Inventory = createElement(
				Shop,

				Support.Merge(
					{ items = self.state.inventoryOpen and inventory or self.props.items },
					shopProps
				)
			),
		}
	)
end

function InventoryAndShopButtons:didMount()
	local function openShop(actionName, inputState)
		if inputState == Enum.UserInputState.Begin then
			self:setState(function(state)
				return {
					shopOpen = not state.shopOpen,
					inventoryOpen = false,
				}
			end)
		end
	end

	local function openInventory(actionName, inputState)
		if inputState == Enum.UserInputState.Begin then
			self:setState(function(state)
				return {
					inventoryOpen = not state.inventoryOpen,
					shopOpen = false,
				}
			end)
		end
	end

	ContextActionService:BindAction('openShop', openShop, false, Enum.KeyCode.Q)

	ContextActionService:BindAction('openInventory', openInventory, false, Enum.KeyCode.R)
end

local InventoryAndShopButtonsConnected = RoactRodux.connect(function(state)
	local function isVisible(item)
		return item.type ~= OBJECT_TYPES.ROOM
	end
	local function byId(item)
		return item.id, item
	end

	return {
		items = state.shop.items,
		equippedItems = state.player.equippedItems,
		isPlaying = state.player.isPlaying,
		playerSlotsCount = state.player.playerSlotsCount,
		isGhosting = state.player.isGhosting,
		inventory = M.map(M.filter(state.inventory, isVisible), byId),
	}
end)(InventoryAndShopButtons)

return InventoryAndShopButtonsConnected