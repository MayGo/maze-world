local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local createElement = Roact.createElement
local Time = require(Modules.src.Time)
local Frame = require(clientSrc.Components.common.Frame)

--- Table row component
local LeaderboardTableRow = Roact.Component:extend'LeaderboardTableRow'
LeaderboardTableRow.defaultProps = { MaxHeight = 300 }

function LeaderboardTableRow:render()
	local props = self.props
	local item = props.item

	local text = item.value

	return createElement(
		Frame,
		{ LayoutOrder = -item.value },
		{
			Name = createElement('TextLabel', {
				LayoutOrder = 1,
				Size = UDim2.new(0.7, 0, 0, 40),
				Text = props.item.key,
				TextSize = 16,
				BackgroundTransparency = 1,
			}),
			Time = createElement('TextLabel', {
				LayoutOrder = 1,
				Size = UDim2.new(0.3, 0, 0, 40),
				Text = text,
				TextSize = 16,
				BackgroundTransparency = 1,
			}),
		}
	)
end

return LeaderboardTableRow