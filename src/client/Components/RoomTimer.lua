local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Time = require(Modules.src.Time)

local Roact = require(Modules.Roact)
local createElement = Roact.createElement

local function RoomTimer(props)
	local item = props.item
	local countDown = props.countDown
	local size = Vector2.new(item.Size.X, item.Size.Y)

	local countDownTextLabel = createElement('TextLabel', {
		Font = Enum.Font.Arcade,
		Position = UDim2.new(0, 0, 0, 0),
		Text = Time.FormatTime(countDown),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		TextColor3 = Color3.fromRGB(66, 255, 83),
		TextStrokeColor3 = Color3.fromRGB(0, 4, 255),
		TextScaled = true,
		TextSize = 114,
		Size = UDim2.new(1, 0, 1, 0),
	})

	return createElement(
		'Part',
		{
			CFrame = item.cFrame,
			Color = item.color,
			Size = Vector3.new(size.X, size.Y, 0.5),
			Transparency = 1,
			Anchored = true,
			CanCollide = false,
		},
		{ UI = createElement(
			'SurfaceGui',
			{
				Face = Enum.NormalId.Front,
				CanvasSize = 10 * size,
			},
			{ coundDown = countDownTextLabel }
		) }
	)
end

return RoomTimer