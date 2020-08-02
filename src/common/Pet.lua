local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local GhostAbility = require(Modules.src.GhostAbility)

local Models = ReplicatedStorage:WaitForChild('Models')

local Pet = {}

Pet.__index = Pet

local PET_ATTRIBUTE = 'pet'

function Pet:create(petObject, character, slot)
	local this = {
		variableName = PET_ATTRIBUTE .. '_' .. petObject.id,
		slot = slot,
		petObject = petObject,
		petName = petObject.name,
		character = character,
		started = true,
	}

	setmetatable(this, Pet)
	return this
end

function Pet:init()
	self.petModel = self:addToCharacter()
	GhostAbility:setCollisionGroupRecursive(self.petModel)
	self:start(self.petModel)
end

function Pet:removeCurrentPet()
	local petModel = self.character:FindFirstChild(self.variableName)
	if petModel then
		petModel:Destroy()
	end
end

function Pet:delete()
	logger:d('Removing pet ', self.petName)
	self.started = false

	self:removeCurrentPet()
end

function Pet:addToCharacter()
	if not self.character then
		logger:w('No character to add pet to')
		return
	end

	-- self:removeCurrentPet()

	local petModel = Models.Pets[self.petName]:Clone()

	if petModel == nil then
		logger:w('No Pet')
		return
	end

	petModel.Name = self.variableName
	petModel.Parent = self.character

	return petModel
end

function Pet:start(petModel)
	logger:d('Init petModel')

	petModel.CanCollide = false
	petModel.Anchored = false
	for i, v in pairs(petModel:GetChildren()) do
		if v.ClassName == 'Part' or v.ClassName == 'WedgePart' or v.ClassName == 'TrussPart' or v.ClassName == 'CornerWedgePart' or v.ClassName == 'MeshPart' then
			v.Anchored = false
			v.CanCollide = false
		end
	end

	spawn(function()
		self:animate()
	end)
end

-- local RotationOffset = 360/#ducks
local function GetPointOnCircle(CircleRadius, Degrees)
	return Vector3.new(math.cos(math.rad(Degrees)) * CircleRadius, 0, math.sin(math.rad(Degrees)) * CircleRadius)
end

function Pet:animate()
	local maxFloat = 0.5
	local floatInc = 0.025
	local sw = false
	local fl = 0

	local petModel = self.petModel
	local character = self.character
	local head = character:FindFirstChild('Head')
	local humanoid = character:FindFirstChild('Humanoid')

	while self.started do
		if not sw then
			fl = fl + floatInc
			if fl >= maxFloat then
				sw = true
			end
		else
			fl = fl - floatInc
			if fl <= -maxFloat then
				sw = false
			end
		end
		if petModel ~= nil and humanoid ~= nil and head ~= nil then
			if humanoid.Health >= 0 then
				local cf = head.CFrame * CFrame.new(0, -0.5 + fl, 0)

				local rotationOffset = 360 / self.slot
				local circlePoint = GetPointOnCircle(5, rotationOffset)

				petModel.BodyPosition.Position = Vector3.new(cf.x, cf.y, cf.z) + circlePoint
				petModel.BodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
				petModel.BodyGyro.CFrame = head.CFrame * CFrame.new(3, 0, -3)
				--break
			else
				logger:i('Human died')
			end
		end
		wait()
	end
end

return Pet