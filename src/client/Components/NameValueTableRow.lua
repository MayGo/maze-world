local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)
local createElement = Roact.createElement
local Frame = require(clientSrc.Components.common.Frame)

--- Table row component
local NameValueTableRow = Roact.Component:extend'NameValueTableRow'

function NameValueTableRow:render()
	local props = self.props
	local item = props.item
	local noValueField = props.noValueField or false
	local nameField = props.nameField or 'key'
	local valueField = props.valueField or 'value'

	local nameText = item[nameField] or ''
	local valueText = item[valueField] or ''

	local order = item[valueField] or 1

	local children = {}

	children.Name = createElement('TextLabel', {
		LayoutOrder = 1,
		Size = UDim2.new(noValueField and 1 or 0.7, 0, 0, 40),
		Text = nameText,
		TextSize = 16,
		BackgroundTransparency = 1,
	})

	if not noValueField then
		children.Value = createElement('TextLabel', {
			LayoutOrder = 1,
			Size = UDim2.new(0.3, 0, 0, 40),
			Text = valueText,
			TextSize = 16,
			BackgroundTransparency = 1,
		})
	end
	return createElement(Frame, { LayoutOrder = -order }, children)
end

return NameValueTableRow