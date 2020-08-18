local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local clientSrc = game:GetService('StarterPlayer'):WaitForChild('StarterPlayerScripts').clientSrc

local Roact = require(Modules.Roact)

local TextListWithHeader = require(clientSrc.Components.common.TextListWithHeader)

local createElement = Roact.createElement

local function SurfaceBillboard(props)
	local item = props.item
	local noTextListWithHeader = props.noTextListWithHeader
	local size = Vector2.new(item.Size.X, item.Size.Y)

	return createElement(
		'Part',
		{
			CFrame = item.cFrame,
			Size = Vector3.new(size.X, size.Y, 0.5),
			Transparency = 1,
			Anchored = true,
			CanCollide = false,
		},
		{ SurfaceGui = createElement(
			'SurfaceGui',
			{
				Face = Enum.NormalId.Front,
				CanvasSize = 15 * size,
			},
			noTextListWithHeader and props[Roact.Children] or createElement(
				TextListWithHeader,
				props
			)
		) }
	)
end

return SurfaceBillboard