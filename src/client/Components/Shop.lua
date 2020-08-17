local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
--local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local Roact = require(Modules.Roact)
local ShopItem = require(clientSrc.Components.ShopItem)
local ScrollingFrame = require(clientSrc.Components.common.ScrollingFrame)
local Support = require(Modules.src.utils.SupportLibrary)

local createElement = Roact.createElement

local function Shop(props)
	local items = props.items
	local inventory = props.inventory
	-- The order that items appear must be deterministic, so we create a list!
	local itemList = {}

	for _, item in pairs(items) do
		table.insert(itemList, item)
	end

	table.sort(itemList, function(a, b)
		return a.name < b.name
	end)

	-- It's easy to dynamically build up children in Roact since the description
	-- of our UI is just a function returning objects.
	local children = props[Roact.Children]

	local cellWidth = 0.2
	local buttonHeight = 0.2
	local titleHeight = 0.2
	local cellHeight = 0.3

	for index, item in ipairs(itemList) do
		local isDisabled = false
		if item.toolObjectId and not inventory[item.toolObjectId] then
			isDisabled = true
		end

		children[item.id] = createElement(
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

	return createElement(ScrollingFrame, {
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
		LayoutOrder = 100,
		ElasticBehavior = Enum.ElasticBehavior.Always,
		[Roact.Children] = children,
	})
end

return Shop