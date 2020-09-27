local Root = script:FindFirstAncestor('MazeGenerator')
local Roact = require(Root.Roact)
local M = require(Root.M)

local createElement = Roact.createElement

local function UIPadding(props)
	local padding = props.padding

	local paddingProp = UDim.new(0, padding)

	return createElement(
		'UIPadding',
		M.extend(
			{
				PaddingBottom = paddingProp,
				PaddingLeft = paddingProp,
				PaddingRight = paddingProp,
				PaddingTop = paddingProp,
			},
			M.omit(props, 'padding')
		)
	)
end

return UIPadding