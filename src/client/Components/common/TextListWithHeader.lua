local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc
local Frame = require(clientSrc.Components.common.Frame)

local Roact = require(Modules.Roact)

local createElement = Roact.createElement

local function TextListWithHeader(props)
	local title = props.title

	return createElement(
		Frame,
		{
			Layout = 'List',
			LayoutDirection = 'Vertical',
			Padding = UDim.new(0, 0),
			Size = UDim2.new(1, 0, 1, -40),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
		},
		{
			TextTitle = Roact.createElement('TextLabel', {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				Text = title,
				TextSize = 18,
				BackgroundColor3 = Color3.fromRGB(100, 255, 200),
				BorderColor3 = Color3.fromRGB(100, 255, 200),
				BackgroundTransparency = 0,
			}),
			Children = props[Roact.Children],
		}
	)
end

return TextListWithHeader