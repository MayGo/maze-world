local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Roact = require(Modules.Roact)
local Dict = require(Modules.src.utils.Dict)
local RoactMaterial = require(Modules.RoactMaterial)

local createElement = Roact.createElement

local function IconButton(props)
	local joinedProps = Dict.join(
		{
			Size = UDim2.new(0, 40, 0, 40),
			onClicked = props.onClick,
			[Roact.Children] = createElement(RoactMaterial.Icon, {
				Icon = props.icon,
				Size = UDim2.new(0, 30, 0, 30),
				Position = UDim2.new(0, 5, 0, 5),
				IconColor3 = Color3.new(1, 1, 1),
			}),
		},
		props
	)

	local menuButton = createElement(RoactMaterial.Button, joinedProps)
	return menuButton
end

return IconButton