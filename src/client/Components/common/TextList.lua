local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)

local Roact = require(Modules.Roact)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local TextLabel = require(clientSrc.Components.common.TextLabel)

local createElement = Roact.createElement

local ITEM_PADDING = 4
local ITEM_HEIGHT = 40

local function TextList(props)
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
	local children = {}

	children.Layout = createElement('UIListLayout', { SortOrder = Enum.SortOrder.LayoutOrder })

	for index, item in ipairs(itemList) do
		local playerName = createElement(TextLabel, {
			Text = item.name,
			TextColor3 = Color3.new(0.9, 0.9, 0.9),
			TextSize = 32,
			Size = UDim2.new(1, -ITEM_PADDING * 2, 1, -ITEM_PADDING * 2),
			Position = UDim2.new(0, ITEM_PADDING, 0, ITEM_PADDING),
			Font = Enum.Font.SourceSans,
			BorderSizePixel = 0,
		})
		local slot = createElement(
			'Frame',
			{
				Size = UDim2.new(1, 0, 0, ITEM_HEIGHT),
				LayoutOrder = index,
			},
			{ Inner = playerName }
		)

		children[item.id] = slot
	end

	return createElement(
		'ScrollingFrame',
		{
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(1, 0, 0, ITEM_HEIGHT * #itemList),
			LayoutOrder = 100,
		},
		children
	)
end

return TextList