local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local Roact = require(Modules.Roact)
local M = require(Modules.M)
local createElement = Roact.createElement

local AUTO_SPIN_STEP = math.rad(0.70)

local ModelViewport = Roact.PureComponent:extend('ModelViewport')

function ModelViewport:init()
	self.viewportFrameRef = Roact.createRef()
	self.xRotation = 0
	self.yRotation = 0
	self.rotationDeltaX = 0
	self.rotationDeltaY = 0
	self.delta = 0
	self.keys = {}
	self.lastPosition = Vector3.new(0, 0, 0)
	self.viewportCamera = Instance.new('Camera')
	self.viewportCamera.CameraType = Enum.CameraType.Scriptable
	self.model = self.props.model
	self.isRotating = self.props.isRotating == nil and true or self.props.isRotating
end

function ModelViewport:didMount()
	if self.model then
		self.viewportCamera.Parent = self.viewportFrameRef.current
		self.viewportFrameRef.current.CurrentCamera = self.viewportCamera
		self:setRotation()

		self.model.Parent = self.viewportFrameRef.current
	end

	self.isMounted = true
	self:handleSpin()
end

function ModelViewport:didUpdate()
	if self.props.visible and self.model then
		coroutine.wrap(function()
			self.model.Parent = self.viewportFrameRef.current
		end)()
	end

	self.viewportCamera.Parent = self.viewportFrameRef.current
	self.viewportFrameRef.current.CurrentCamera = self.viewportCamera
end

function ModelViewport:setRotation()
	local model = self.model

	if model then
		local isTool = model:IsA('Tool')
		local part = isTool and model.Box or model.PrimaryPart

		local partLenght = math.max(part.Size.X, part.Size.Y, part.Size.Z)
		local offset = self.props.cameraOffset or CFrame.new(0, partLenght, partLenght)

		local cameraPosition =
			(CFrame.new(part.Position) * CFrame.Angles(0, -self.yRotation, 0) * CFrame.Angles(
				self.xRotation,
				0,
				0
			) * offset).p

		self.viewportCamera.CFrame = CFrame.new(cameraPosition, part.Position)
	end
end

function ModelViewport:render()
	local props = self.props

	return createElement(
		'ViewportFrame',

		M.extend(
			{
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Active = true,
				[Roact.Ref] = self.viewportFrameRef,
			},
			M.omit(props, 'model', 'cameraOffset', 'isRotating')
		)
	)
end

function ModelViewport:handleSpin()
	spawn(function()
		while self.isMounted and self.isRotating do
			local function returnToDefaultPosition(current, maxStep)
				current = current % math.rad(360)
				if current > math.rad(180) then
					current = current + maxStep
					if current > math.rad(360) then
						return 0
					end
				else
					current = current - maxStep
					if current < 0 then
						return 0
					end
				end
				return current
			end

			self.xRotation = returnToDefaultPosition(self.xRotation, math.rad(2))
			self.yRotation = self.yRotation + AUTO_SPIN_STEP

			self:setRotation()
			self.delta = RunService.RenderStepped:wait()
		end
	end)
end

function ModelViewport:willUnmount()
	self.isMounted = false
end

return ModelViewport