local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local Roact = require(Modules.Roact)
local ShopItem = require(clientSrc.Components.ShopItem)
local ScrollingFrame = require(clientSrc.Components.common.ScrollingFrame)
local Support = require(Modules.src.utils.SupportLibrary)

local createElement = Roact.createElement

local function Shop(props)
	local items = props.items
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

	for index, item in ipairs(itemList) do
		children[item.id] = Roact.createElement(
			ShopItem,
			Support.Merge(
				{
					index = index,
					item = item,
				},
				props or {}
			)
		)
	end

	return createElement(ScrollingFrame, {
		Layout = 'Grid',
		SortOrder = Enum.SortOrder.Name,
		CellSize = UDim2.new(0, 170, 0, 170),
		CellPadding = UDim2.new(0, 10, 0, 10),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		CanvasSize = UDim2.new(1, 0, 1, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ScrollBarThickness = 4,
		ScrollBarImageTransparency = 0.6,
		VerticalScrollBarInset = 'ScrollBar',
		BackgroundColor3 = Color3.new(0.6, 0.6, 0.6),
		BackgroundTransparency = 0.2,
		LayoutOrder = 100,
		[Roact.Children] = children,
	})
end

return Shop