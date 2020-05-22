local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local createElement = Roact.createElement
local Time = require(Modules.src.Time)
local Frame = require(clientSrc.Components.common.Frame)

--- Table row component
local PlayersPlayingTableRow = Roact.Component:extend'PlayersPlayingTableRow'
PlayersPlayingTableRow.defaultProps = { MaxHeight = 300 }

function PlayersPlayingTableRow:render()
	local props = self.props
	local startTime = props.startTime
	local item = props.item
	local coins = item.coins or ''

	local finishTime = item.finishTime
	if finishTime == nil then
		finishTime = tick()
	end

	local time = (finishTime - startTime)
	local timeText = Time.FormatTime(time)

	if finishTime == -1 then
		timeText = 'DNF'
	end

	return createElement(
		Frame,
		{ LayoutOrder = finishTime },
		{
			Name = createElement('TextLabel', {
				LayoutOrder = 1,
				Size = UDim2.new(0.6, 0, 0, 40),
				Text = props.item.name,
				TextSize = 16,
				BackgroundTransparency = 1,
			}),
			Time = createElement('TextLabel', {
				LayoutOrder = 2,
				Size = UDim2.new(0.2, 0, 0, 40),
				Text = timeText,
				TextSize = 16,
				BackgroundTransparency = 1,
			}),
			Coins = createElement('TextLabel', {
				LayoutOrder = 3,
				Size = UDim2.new(0.2, 0, 0, 40),
				Text = coins,
				TextSize = 16,
				BackgroundTransparency = 1,
			}),
		}
	)
end

return PlayersPlayingTableRow