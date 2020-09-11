local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local TextLabel = require(clientSrc.Components.common.TextLabel)
local Roact = require(Modules.Roact)
local createElement = Roact.createElement
local Time = require(Modules.src.Time)
local Frame = require(clientSrc.Components.common.Frame)
local Timer = require(clientSrc.Components.Timer)

--- Table row component
local PlayersPlayingTableRow = Roact.PureComponent:extend'PlayersPlayingTableRow'
PlayersPlayingTableRow.defaultProps = { MaxHeight = 300 }

function PlayersPlayingTableRow:render()
	local props = self.props
	local startTime = props.startTime
	local endTime = props.endTime
	local item = props.item
	local coins = item.coins or ''

	local finishTime = item.finishTime

	local timeText
	local timer

	local showTimer = finishTime == nil and startTime ~= nil and endTime == nil

	if showTimer then
		timer = createElement(Timer, {
			key = startTime,
			increment = true,
			initialTime = startTime,
			LayoutOrder = 2,
			Size = UDim2.new(0.2, 0, 0, 40),
			TextSize = 26,
			BackgroundTransparency = 1,
			TextColor3 = props.TextColor3,
		})
	elseif startTime ~= nil and finishTime ~= nil then
		local time = (finishTime - startTime)
		timeText = Time.FormatTime(time)
	elseif finishTime == nil then
		timeText = 'DNF'
	end

	if startTime == nil then
		timeText = 'Starting'
	end

	if item.isKilled then
		timeText = 'Killed'
	end

	local timeElement = createElement(TextLabel, {
		LayoutOrder = 2,
		Size = UDim2.new(0.2, 0, 0, 40),
		Text = timeText,
		TextSize = 26,
		BackgroundTransparency = 1,
		TextColor3 = props.TextColor3,
	})

	local playerName = props.item.name

	return createElement(
		Frame,
		{ LayoutOrder = finishTime and finishTime or 1999999999 },
		{
			Name = createElement(TextLabel, {
				LayoutOrder = 1,
				Size = UDim2.new(0.6, 0, 0, 40),
				Text = playerName,
				TextSize = 26,
				BackgroundTransparency = 1,
				TextColor3 = props.TextColor3,
			}),
			Time = timer or timeElement,
			Coins = createElement(TextLabel, {
				LayoutOrder = 3,
				Size = UDim2.new(0.2, 0, 0, 40),
				Text = coins,
				TextSize = 26,
				BackgroundTransparency = 1,
				TextColor3 = props.TextColor3,
			}),
		}
	)
end

return PlayersPlayingTableRow