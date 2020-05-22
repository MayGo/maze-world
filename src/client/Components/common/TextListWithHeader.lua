local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Roact = require(Modules.Roact)

local createElement = Roact.createElement

local function TextListWithHeader(props)
	local title = props.title

	return createElement(
		'ScrollingFrame',
		{
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 100),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0,
		},
		{
			UIListLayout = createElement('UIListLayout', { SortOrder = Enum.SortOrder.LayoutOrder }),
			UIPadding = createElement('UIPadding', {
				PaddingLeft = UDim.new(0, 0),
				PaddingTop = UDim.new(0, 0),
			}),
			TextTitle = Roact.createElement('TextLabel', {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				Text = title,
				TextSize = 18,
				BackgroundTransparency = 1,
			}),
			Children = props[Roact.Children],
		}
	)
end

return TextListWithHeader