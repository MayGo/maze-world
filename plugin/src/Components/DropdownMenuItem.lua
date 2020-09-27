local Root = script:FindFirstAncestor('MazeGenerator')

local Roact = require(Root.Roact)

return function(props)
	local option = props.option
	local index = props.index
	local color = props.color

	local onActivated = props.onActivated

	return Roact.createElement('TextButton', {
		Text = '  ' .. option,
		Font = Enum.Font.GothamSemibold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = index,
		Size = UDim2.new(1, 0, 0, 32),
		BorderSizePixel = 0,
		BackgroundColor3 = color,
		[Roact.Event.Activated] = function()
			onActivated()
		end,
	})
end