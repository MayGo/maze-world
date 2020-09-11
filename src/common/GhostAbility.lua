local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PhysicsService = game:GetService('PhysicsService')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local CollisionGroup = require(Modules.src.CollisionGroup)

local GhostAbility = {}
local GHOST_GROUP = 'Ghost'

function GhostAbility:initCollisionGroup()
	logger.d('Initializing Ghost collision group')
	CollisionGroup:getOrCreateGroupId(GHOST_GROUP)
	PhysicsService:CollisionGroupSetCollidable('Default', GHOST_GROUP, false)
end

function GhostAbility:getGhostCollisionGroupId()
	local ok, groupId = pcall(PhysicsService.GetCollisionGroupId, PhysicsService, GHOST_GROUP)
	return ok and groupId or nil
end
function GhostAbility:setGhostCollisionGroup(char)
	CollisionGroup:setCollisionGroupRecursive(char, GHOST_GROUP)
end

function GhostAbility:setCollisionGroupRecursive(object, groupName)
	if object:IsA('BasePart') then
		PhysicsService:SetPartCollisionGroup(object, groupName)
	end
	for _, child in ipairs(object:GetChildren()) do
		CollisionGroup:setCollisionGroupRecursive(child, groupName)
	end
end

function GhostAbility:makeGhostLike(char)
	for i, v in pairs(char:GetDescendants()) do
		if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' then
			v.Transparency = 0.5
		elseif v:IsA('Decal') then
			v.Transparency = 0.5
		end
	end
end

function GhostAbility:addGhostAbility(char)
	logger:i('Adding Ghost ability to player')
	GhostAbility:makeGhostLike(char)
	GhostAbility:setGhostCollisionGroup(char)
end

return GhostAbility