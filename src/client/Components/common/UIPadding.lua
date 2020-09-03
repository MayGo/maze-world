local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
--local logger = require(Modules.src.utils.Logger)

local Roact = require(Modules.Roact)
local M = require(Modules.M)

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