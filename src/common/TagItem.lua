local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local PlayerUtils = require(Modules.src.utils.PlayerUtils)

local CollectionService = game:GetService('CollectionService')

local TagItem = {}

local bricks = {}
local isTouchingPlayer = {}
local isUntouchingPlayer = {}

function TagItem.create(roomId, tagName, touchedFn, untouchedFn, waitFor)
	local addedSignal = CollectionService:GetInstanceAddedSignal(tagName)
	local removedSignal = CollectionService:GetInstanceRemovedSignal(tagName)

	local function makeBrick(part)
		local function onTouchStart(hit)
			if PlayerUtils:isHuman(hit) then
				local player = PlayerUtils:getPlayer(hit)
				if player then
					if not isTouchingPlayer[player] then
						isTouchingPlayer[player] = true
						touchedFn(player, hit, part)

						wait(waitFor and waitFor or 1)

						isTouchingPlayer[player] = false
					end
				end
			end
		end

		local function onTouchEnd(hit)
			if PlayerUtils:isHuman(hit) then
				local player = PlayerUtils:getPlayer(hit)
				if player then
					wait(0.5)
					local isStillTouching = false
					for i, part in pairs(part:GetTouchingParts()) do
						if PlayerUtils:isHuman(part) then
							isStillTouching = true
							break
						end
					end

					if not isStillTouching and not isUntouchingPlayer[player] then
						if untouchedFn then
							isUntouchingPlayer[player] = true
							untouchedFn(player)
							wait(1)
							isUntouchingPlayer[player] = false
						end
					end
				end
			end
		end

		local data = {}
		data.touchedConn = part.Touched:Connect(onTouchStart)
		data.untouchedConn = part.TouchEnded:Connect(onTouchEnd)

		return data
	end

	local function undoBrick(data)
		data.touchedConn:Disconnect()
		data.untouchedConn:Disconnect()
	end

	local function onAdded(brick)
		bricks[brick] = makeBrick(brick)
	end

	local function onRemoved(brick)
		if bricks[brick] then
			undoBrick(bricks[brick])
			bricks[brick] = nil
		end
	end

	for _, brick in pairs(CollectionService:GetTagged(tagName)) do
		if roomId then
			local MapConfig = require(brick.Config)

			if MapConfig.roomId == roomId then
				onAdded(brick)
			end
		else
			onAdded(brick)
		end
	end

	addedSignal:Connect(onAdded)
	removedSignal:Connect(onRemoved)
end

return TagItem