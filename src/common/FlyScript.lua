local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local M = require(Modules.M)
local RunService = game:GetService('RunService')
local camera = game.Workspace.CurrentCamera
local UserInputService = game:GetService('UserInputService')

local FlyScript = {}

FlyScript.__index = FlyScript

function FlyScript:create(humanoid)
	local BodyPosition = Instance.new('BodyPosition', humanoid)
	BodyPosition.MaxForce = Vector3.new()
	BodyPosition.D = 10
	BodyPosition.P = 10000

	local BodyGyro = Instance.new('BodyGyro', humanoid)
	BodyGyro.MaxTorque = Vector3.new()
	BodyGyro.D = 10

	local this = {
		humanoid = humanoid,
		flying = false,
		floating = true,
		speed = 0.5,
		BodyPosition = BodyPosition,
		BodyGyro = BodyGyro,
	}

	setmetatable(this, FlyScript)
	return this
end

function FlyScript:initInput()
	local inputTypes = { Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2 }

	UserInputService.InputBegan:Connect(function(inputObject)
		if not inputObject then return end

		if M.include(inputTypes, inputObject.UserInputType) then
			self:endFloating()
		end
	end)

	UserInputService.InputEnded:Connect(function(inputObject)
		if not inputObject then return end

		if M.include(inputTypes, inputObject.UserInputType) then
			self:startFloating()
		end
	end)
end

function FlyScript:startFlying()
	self.flying = true
	self.BodyPosition.MaxForce = Vector3.new(400000, 400000, 400000)
	self.BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
	while self.flying do
		local point = camera.CFrame.p
		if self.floating then
		else
			self.BodyPosition.Position = self.humanoid.Position + ((self.humanoid.Position - point).unit * self.speed)
		end

		self.BodyGyro.CFrame = CFrame.new(point, self.humanoid.Position)
		RunService.RenderStepped:wait()
	end
end

function FlyScript:endFlying()
	self.BodyPosition.MaxForce = Vector3.new()
	self.BodyGyro.MaxTorque = Vector3.new()
	self.flying = false
end

function FlyScript:startFloating()
	self.floating = true
end

function FlyScript:endFloating()
	self.floating = false
end

return FlyScript