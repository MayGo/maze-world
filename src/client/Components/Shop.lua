local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local Roact = require(Modules.Roact)
local M = require(Modules.M)
local ShopItem = require(clientSrc.Components.ShopItem)
local ScrollingFrame = require(clientSrc.Components.common.ScrollingFrame)
local RoundButton = require(clientSrc.Components.common.RoundButton)
local Frame = require(clientSrc.Components.common.Frame)
local Support = require(Modules.src.utils.SupportLibrary)
local UIPadding = require(clientSrc.Components.common.UIPadding)
local EquipStatusCell = require(clientSrc.Components.EquipStatusCell)
local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local OBJECT_TYPES = InventoryObjects.OBJECT_TYPES

local createElement = Roact.createElement

local Shop = Roact.Component:extend('Shop')

function Shop:init()
	self:setState({ activeTab = nil })

	local props = self.props
	local items = props.items
	local tabs = props.tabs

	if tabs and items then
		local function findFirstNotEmpty(tabName)
			local itemsCount = M.countf(items, function(item)
				return item.type == tabName
			end)

			return itemsCount > 0
		end

		local firstTab = M.select(tabs, findFirstNotEmpty)

		self:setState({ activeTab = M.sort(firstTab)[1] })
	end
end

function Shop:render()
	local props = self.props
	local tabs = props.tabs
	local inventory = props.inventory
	local closeClick = props.closeClick
	local activeTab = self.state.activeTab

	local closeButton = createElement(RoundButton, {
		icon = 'close',
		onClicked = closeClick,
		Size = UDim2.new(0.08, 0, 0.08, 0),
	})

	local shopTabs = {}

	local function createTab(tabName)
		local function hasType(item)
			return item.type == tabName
		end

		local itemsCount = M.countf(props.items, hasType)

		if itemsCount > 0 then
			function OnClick()
				self:setState({ activeTab = tabName })
			end

			local isActive = activeTab == tabName

			local button = createElement(RoundButton, {
				Text = tabName,
				Position = UDim2.new(0.5, 0, 1, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				onClicked = OnClick,
				BackgroundColor3 = isActive and Color3.fromRGB(158, 46, 238) or nil,
				TextColor3 = isActive and Color3.fromRGB(
					255,
					255,
					255
				) or Color3.fromRGB(205, 203, 206),
				Size = UDim2.new(0.2, 0, 1, 0),
			})

			shopTabs[tabName] = button
		end
	end

	M.each(tabs, createTab)

	local function isVisible(item)
		return item.type == activeTab
	end

	local itemList = M.filter(props.items, isVisible)

	local isPetTab = activeTab == OBJECT_TYPES.PET
	local shopItems = {
		UIPadding = createElement(UIPadding, { padding = 10 }),
		isPetTab and createElement(EquipStatusCell) or nil,
	}

	local cellWidth = 0.2
	local buttonHeight = 0.2
	local titleHeight = 0.2
	local cellHeight = 0.2

	for index, item in ipairs(itemList) do
		local isDisabled = false
		if item.toolObjectId and not inventory[item.toolObjectId] then
			isDisabled = true
		end

		shopItems[item.id] = createElement(
			ShopItem,
			Support.Merge(
				{
					index = index,
					cellWidth = cellWidth,
					buttonHeight = buttonHeight,
					titleHeight = titleHeight,
					item = item,
					isDisabled = isDisabled,
				},
				props or {}
			)
		)
	end

	local shopTabsContainer = createElement(ScrollingFrame, {
		Layout = 'List',
		CanvasSize = 'WRAP_CONTENT',
		LayoutDirection = 'Horizontal',
		SortOrder = Enum.SortOrder.Name,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		ScrollBarThickness = 4,
		ScrollBarImageTransparency = 0.6,
		VerticalScrollBarInset = 'ScrollBar',
		LayoutOrder = 1,
		ElasticBehavior = Enum.ElasticBehavior.Always,
		Size = UDim2.new(1, 0, 0.08, 0),
		Padding = UDim.new(0, 10),
		[Roact.Children] = shopTabs,
	})

	local shopItemsContainer = createElement(ScrollingFrame, {
		Layout = 'Grid',
		CanvasSize = 'WRAP_CONTENT',
		ScrollingDirection = Enum.ScrollingDirection.Y,
		SortOrder = Enum.SortOrder.Name,
		CellSize = UDim2.new(cellWidth, 0, cellHeight, 0),
		CellPadding = UDim2.new(0.05, 0, 0.05, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		ScrollBarThickness = 4,
		ScrollBarImageTransparency = 0.6,
		VerticalScrollBarInset = 'ScrollBar',
		LayoutOrder = 2,
		ElasticBehavior = Enum.ElasticBehavior.Always,
		Size = UDim2.new(1, 0, 0.92, 0),
		Position = UDim2.new(0, 0, 0.08, 0),
		[Roact.Children] = shopItems,
	})

	return createElement(
		Frame,
		{ Size = UDim2.new(1, 0, 1, 0) },
		{
			closeButton = closeButton,
			tabsContainer = shopTabsContainer,
			itemsContainer = shopItemsContainer,
		}
	)
end

return Shop