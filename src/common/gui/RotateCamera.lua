local TweenService = game:GetService('TweenService')

local RunService = game:GetService('RunService')

local newBlock = Instance.new('Part')
newBlock.Position = Vector3.new(0, 0, 0)
local target = newBlock
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable
local rotationAngle = Instance.new('NumberValue')
local tweenComplete = false

local cameraOffset = Vector3.new(120, 43, -40)
local rotationTime = 15 -- Time in seconds
local rotationDegrees = 360
local rotationRepeatCount = -1 -- Use -1 for infinite repeats
local lookAtTarget = true -- Whether the camera tilts to point directly at the target
local RotateCamera = {}

RotateCamera.__index = RotateCamera

function RotateCamera:blur()
	local blurEffect = Instance.new('BlurEffect')
	blurEffect.Parent = camera
	blurEffect.Size = 32
	self.blurEffect = blurEffect
end
function RotateCamera:unblur()
	self.blurEffect:Destroy()
end

function RotateCamera:updateCamera()
	if not target then return end
	camera.Focus = target.CFrame
	local rotatedCFrame = CFrame.Angles(0, math.rad(rotationAngle.Value), 0)
	rotatedCFrame = CFrame.new(target.Position) * rotatedCFrame
	camera.CFrame = rotatedCFrame:ToWorldSpace(CFrame.new(cameraOffset))
	if lookAtTarget == true then
		camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
	end
end

function RotateCamera:start()
	self:blur()
	-- Set up and start rotation tween
	local tweenInfo =
		TweenInfo.new(
			rotationTime,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut,
			rotationRepeatCount
		)
	local tween = TweenService:Create(rotationAngle, tweenInfo, { Value = rotationDegrees })

	tween.Completed:Connect(function()
		tweenComplete = true
	end)

	tween:Play()

	-- Update camera position while tween runs
	self.connection = RunService.RenderStepped:Connect(function()
		if tweenComplete == false then
			self:updateCamera()
		end
	end)
end

function RotateCamera:stop()
	self.connection:disconnect()
	self:unblur()
end

return RotateCamera