local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local InventoryObjects = require(Modules.src.objects.InventoryObjects)
local RoomObjects = InventoryObjects.RoomObjects
local PhysicsService = game:GetService('PhysicsService')
local CollisionGroup = require(Modules.src.CollisionGroup)

local M = require(Modules.M)

local Place = game.Workspace:WaitForChild('Place')
local RoomsFolder = Place:findFirstChild('Rooms')

local RoomManager = {}

function RoomManager:initCollisionGroups()
	logger.d('Initializing Rooms collision group')

	function initRoomGroups(room)
		local groupName = RoomManager:getRoomCollisionGroup(room)

		CollisionGroup:getOrCreateGroupId(groupName)
		PhysicsService:CollisionGroupSetCollidable('Default', groupName, true)

		local roomPart = RoomManager:findRoomPart(room)

		if roomPart then
			local lockPlaceholder = roomPart.placeholders:FindFirstChild('LockPlaceholder')

			if lockPlaceholder then
				local lockPart = lockPlaceholder:FindFirstChild('Lock')

				CollisionGroup:setCollisionGroupRecursive(lockPart, groupName)
			end
		end
	end

	M.each(RoomObjects, initRoomGroups)
end

function RoomManager:initPlayerCollisionGroup(playerId)
	logger:d('Init player collisigon group ' .. playerId)
	CollisionGroup:getOrCreateGroupId(playerId)
end

function RoomManager:removePlayerCollisionGroup(playerId)
	logger:d('Remove player collisigon group ' .. playerId)
	PhysicsService:RemoveCollisionGroup(playerId)
end

-- TODO use this everywehere else also
function RoomManager:findRoomPart(room)
	local modelName = room.modelName
	if not RoomsFolder then
		logger:w('Rooms Folder does not exists!')
		return
	end

	local roomObj = RoomsFolder:findFirstChild(modelName)
	if not roomObj then
		logger:w('Room object for ' .. modelName .. ' does not exists!')
		return
	end

	return roomObj
end
function RoomManager:getRoomCollisionGroup(room)
	return 'room_' .. tostring(room.id)
end

function RoomManager:addToCharacter(character, inventory, playerId)
	if not character then
		logger:d('No Character found for player:' .. tostring(playerId))
		return
	end

	CollisionGroup:setCollisionGroupRecursive(character, playerId)

	function applyRoomLocks(room)
		local hasRoom = inventory[room.id]

		local groupName = RoomManager:getRoomCollisionGroup(room, playerId)

		if hasRoom then
			logger:d('Remove room ' .. room.name .. ' lock for player.')
			PhysicsService:CollisionGroupSetCollidable(playerId, groupName, false)
		end
	end
	M.each(RoomObjects, applyRoomLocks)
end

return RoomManager