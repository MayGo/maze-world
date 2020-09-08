--[[
	A SurfaceGui-based billboard that only pivots on the Y axis.

	The primary UI container is rendered with Roact, but the pivoting is handled
	by manually changing the containing part's CFrame directly every frame.

	This file is a good example of mutating properties manually on an otherwise
	Roact-owned object. It's a very powerful way to get a performance boost at
	the cost of some readability and potentially some bugs.
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local AudioPlayer = require(Modules.src.AudioPlayer)
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')

local Roact = require(Modules.Roact)
local createElement = Roact.createElement

local YAxisBillboard = Roact.PureComponent:extend('YAxisBillboard')

function YAxisBillboard:init()
	self.partRef = Roact.createRef()
end

function YAxisBillboard:_updatePosition()
	-- This function gets invoked on initial mount, every time the component is
	-- updated via Roact, and every frame. That helps make sure that we won't
	-- be out-of-sync with our props.

	local cameraCFrame = Workspace.CurrentCamera.CFrame

	local angle =
		math.atan2(
			self.props.position.x - cameraCFrame.p.x,
			self.props.position.z - cameraCFrame.p.z
		)

	local uiLocation = CFrame.Angles(0, angle, 0) + self.props.position

	self.partRef.current.CFrame = uiLocation
end

function YAxisBillboard:render()
	local size = self.props.size

	return createElement(
		'Part',
		{
			-- When doing manual mutation alongside Roact, it's important to avoid
			-- setting the properties we're managing manually from inside render.
			-- Otherwise, the reconciler will fight you!

			Size = Vector3.new(size.X, size.Y, 0.1),
			Transparency = 1,
			Anchored = true,
			CanCollide = false,
			[Roact.Ref] = self.partRef,
		},
		{
			-- If we wanted interaction with our ScreenGui, this is where we could
			-- use Roact.Portal to jump into the local player's PlayerGui
			ClickDetector = createElement('ClickDetector', { [Roact.Event.MouseClick] = function()
				AudioPlayer.playAudio('Simple_Click')
				self.props.onClicked()
			end }),
			UI = createElement(
				'SurfaceGui',
				{
					Face = Enum.NormalId.Front,
					CanvasSize = 100 * size,
				},
				self.props[Roact.Children]
			),
		}
	)
end

function YAxisBillboard:didMount()
	self._connection = RunService.RenderStepped:Connect(function()
		self:_updatePosition()
	end)

	self:_updatePosition()
end

function YAxisBillboard:didUpdate()
	self:_updatePosition()
end

function YAxisBillboard:willUnmount()
	self._connection:Disconnect()
end

return YAxisBillboard