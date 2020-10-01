local Root = script:FindFirstAncestor('MazeGeneratorPlugin')
local Roact = require(Root:WaitForChild('Roact'))
local M = require(Root.M)

local createElement = Roact.createElement

local function UICorner(props)
	local joinedProps = M.extend({}, { CornerRadius = UDim.new(0, 4) }, props)

	return createElement('UICorner', joinedProps)
end

return UICorner