local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
--local logger = require(Modules.src.utils.Logger)

local Roact = require(Modules.Roact)
local Dict = require(Modules.src.utils.Dict)

local createElement = Roact.createElement

local function UICorner(props)
	local joinedProps = Dict.join({ CornerRadius = UDim.new(0, 4) }, props)

	return createElement('UICorner', joinedProps)
end

return UICorner