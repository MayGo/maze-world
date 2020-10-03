local Root = script:FindFirstAncestor('MazeGeneratorPlugin')

local Roact = require(Root:WaitForChild('Roact'))
local UIPadding = require(Root.Plugin.Components.UIPadding)
local e = Roact.createElement

return function(props)
	local option = props.option
	local index = props.index
	local color = props.color
	local image = option.image

	local onActivated = props.onActivated

	local img = e('ImageButton', {
		LayoutOrder = 1,
		Image = image,
		Size = UDim2.new(0, 40, 0, 40),
	})

	local text = e('TextButton', {
		Text = option.name,
		Font = Enum.Font.GothamSemibold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 45, 0, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = color,
		[Roact.Event.Activated] = function()
			onActivated()
		end,
	})

	return e(
		'Frame',
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 50),
			Name = option.name,
			LayoutOrder = index,
		},
		{
			UIPadding = e(UIPadding, { padding = 5 }),
			img = img,
			text = text,
		}
	)
end