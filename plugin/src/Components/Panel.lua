local Roact = require(script:FindFirstAncestor('MazeGeneratorPlugin').Roact)

local Plugin = script:FindFirstAncestor('Plugin')

local Footer = require(Plugin.Components.Footer)
local Theme = require(Plugin.Components.Theme)

local e = Roact.createElement

local Panel = Roact.Component:extend('Panel')

function Panel:init()
	self.footerSize, self.setFooterSize = Roact.createBinding(Vector2.new())
end

function Panel:render()
	return Theme.with(function(theme)
		return e(
			'Frame',
			{
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = theme.Background1,
				BorderSizePixel = 1,
			},
			{
				Layout = Roact.createElement('UIListLayout', {
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Body = e(
					'Frame',
					{
						Size = UDim2.new(1, 0, 1, -32),
						BackgroundTransparency = 1,
					},
					self.props[Roact.Children]
				),
				Footer = e(Footer),
			}
		)
	end)
end

return Panel