local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local PlayerUtils = require(Modules.src.utils.PlayerUtils)

local CollectionService = game:GetService('CollectionService')

local TagItemOnce = {}

local bricks = {}

function TagItemOnce.create(roomId, tagName, touchedFn, untouchedFn)
	local addedSignal = CollectionService:GetInstanceAddedSignal(tagName)
	local removedSignal = CollectionService:GetInstanceRemovedSignal(tagName)

	local function makeBrick(part)
		local hasTouched = false

		local function onTouchStart(hit)
			if PlayerUtils:isHuman(hit) then
				local player = PlayerUtils:getPlayer(hit)
				if player then
					if not hasTouched then
						touchedFn(player, hit, part)
						hasTouched = true
					end
				end
			end
		end

		local data = {}
		data.touchedConn = part.Touched:Connect(onTouchStart)

		return data
	end

	local function undoBrick(data)
		data.touchedConn:Disconnect()
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

return TagItemOnce