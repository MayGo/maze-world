local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local GhostAbility = require(Modules.src.GhostAbility)
local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local PET_TYPES = InventoryObjects.PET_TYPES
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
	GhostAbility:setGhostCollisionGroup(self.petModel)
	self:start(self.petModel)

	if self.petObject.ability == PET_TYPES.TRAIL then
		self:addTrailToCharacter()
	end
end

function Pet:removeCurrentPet()
	local petModel = self.character:FindFirstChild(self.variableName)
	if petModel then
		petModel:Destroy()
	end
	if self.petObject.ability == PET_TYPES.TRAIL then
		self:removeTrailFromCharacter()
	end
end

function Pet:delete()
	logger:d('Removing pet ', self.petName)
	self.started = false

	self:removeCurrentPet()
end

function Pet:addToCharacter()
	if not self.character then
		logger:w('Noself.character to add pet to')
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
	return Vector3.new(
		math.cos(math.rad(Degrees)) * CircleRadius,
		0,
		math.sin(math.rad(Degrees)) * CircleRadius
	)
end

function Pet:animate()
	local maxFloat = 0.5
	local floatInc = 0.025
	local sw = false
	local fl = 0

	local part = self.petModel.PrimaryPart
	part.BodyGyro.MaxTorque = Vector3.new(4000000, 4000000, 4000000)
	part.BodyPosition.P = 100000

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
		if part ~= nil and humanoid ~= nil and head ~= nil then
			if humanoid.Health >= 0 then
				local cf = head.CFrame * CFrame.new(0, -0.5 + fl, 0)

				local rotationOffset = 360 / self.slot
				local circlePoint = GetPointOnCircle(5, rotationOffset)

				part.BodyPosition.Position = Vector3.new(cf.x, cf.y, cf.z) + circlePoint

				part.BodyGyro.CFrame = head.CFrame * CFrame.new(3, 0, -3)
				--break
			else
				logger:i('Human died')
			end
		end
		wait()
	end
end

function Pet:addTrailToCharacter()
	local name = self.petObject.trailModelName
	logger:w('Add trail ' .. self.petObject.trailModelName .. ' to character.')
	local trail = Models.Trails[name]:Clone()
	local plrTrail = trail:Clone()

	local character = self.character
	plrTrail.Name = name
	plrTrail.Parent = character.HumanoidRootPart

	if self.character:FindFirstChild('UpperTorso') then
		plrTrail.Attachment0 = character.Head.FaceFrontAttachment
		plrTrail.Attachment1 = character.UpperTorso.WaistRigAttachment
	else
		plrTrail.Attachment0 = character.Head.FaceFrontAttachment
		plrTrail.Attachment1 = character.Torso.WaistBackAttachment
	end
end

function Pet:removeTrailFromCharacter()
	local trail = self.character.HumanoidRootPart:FindFirstChild(self.petObject.trailModelName)
	if trail then
		trail:Destroy()
	end
end

return Pet