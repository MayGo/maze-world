local Root = script:FindFirstAncestor('MazeGeneratorPlugin')
local Plugin = Root.Plugin

local Roact = require(Root:WaitForChild('Roact'))

local Theme = require(Plugin.Components.Theme)
local RoundButton = require(Plugin.Components.RoundButton)
local UIPadding = require(Plugin.Components.UIPadding)

local e = Roact.createElement

local function FormButton(props)
	local text = props.text
	local onClick = props.onClick
	local LayoutOrder = props.LayoutOrder

	local TextColor3
	local BackgroundColor3

	return Theme.with(function(theme)
		if props.secondary then
			TextColor3 = theme.Brand1
			BackgroundColor3 = theme.Background2
		else
			TextColor3 = theme.TextOnAccent
			BackgroundColor3 = theme.Brand1
		end

		local button = e(RoundButton, {
			Text = text,
			onClicked = onClick,
			TextColor3 = TextColor3,
			BackgroundColor3 = BackgroundColor3,
		})

		local frame = e(
			'Frame',
			{
				Size = UDim2.new(1, 0, 0, 60),
				BackgroundTransparency = 1,
				LayoutOrder = LayoutOrder,
			},
			{ button }
		)
		return frame
	end)
end

return FormButton