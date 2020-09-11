local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PhysicsService = game:GetService('PhysicsService')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local CollisionGroup = {}

function CollisionGroup:setCollisionGroupRecursive(object, groupName)
	if object:IsA('BasePart') then
		PhysicsService:SetPartCollisionGroup(object, groupName)
	end
	for _, child in ipairs(object:GetChildren()) do
		CollisionGroup:setCollisionGroupRecursive(child, groupName)
	end
end

function CollisionGroup:getOrCreateGroupId(name)
	local ok, groupId = pcall(PhysicsService.GetCollisionGroupId, PhysicsService, name)
	if not ok then
		-- Create may fail if we have hit the maximum of 32 different groups
		ok, groupId = pcall(PhysicsService.CreateCollisionGroup, PhysicsService, name)
	end
	return ok and groupId or nil
end

return CollisionGroup