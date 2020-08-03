local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
-- local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local TextLabel = require(clientSrc.Components.common.TextLabel)
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
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			BorderMode = Enum.BorderMode.Inset,
			BorderSizePixel = 2,
			Padding = UDim.new(0, 0),
			Size = UDim2.new(1, 0, 1, -40),
			BackgroundTransparency = 1,
		},
		{
			TextTitle = createElement(TextLabel, {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 40),
				Text = title,
				TextSize = 26,
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
			Line = createElement('Frame', {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0,
			}),
			Children = props[Roact.Children],
		}
	)
end

return TextListWithHeader