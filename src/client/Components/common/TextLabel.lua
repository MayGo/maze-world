local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Roact = require(Modules.Roact)
local Dict = require(Modules.src.utils.Dict)

local function TextLabel(props)
	return Roact.createElement(
		'TextLabel',
		Dict.join(
			{
				Text = '',
				Font = Enum.Font.SourceSans,
				TextSize = 24,
				TextColor3 = Color3.fromRGB(27, 42, 53),
				TextTruncate = Enum.TextTruncate.None,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				BackgroundTransparency = 1,
			},
			props
		)
	)
end

return TextLabel