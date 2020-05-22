local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local PlayerUtils = require(Modules.src.utils.PlayerUtils)

local TouchItem = {}
local isTouchingPlayer = {}
local isUntouchingPlayer = {}

function TouchItem.create(roomPart, touchedFn, untouchedFn)
	local function addTouchListeners(part)
		local function onTouchStart(hit)
			local player = PlayerUtils:getPlayerFromHuman(hit)
			if player then
				if not isTouchingPlayer[player] then
					touchedFn(player)
					isTouchingPlayer[player] = true
					wait(1)
					isTouchingPlayer[player] = false
				end
			end
		end

		local function onTouchEnd(hit)
			local player = PlayerUtils:getPlayer(hit)
			if player then
				wait(0.5)
				local isStillTouching = false
				for i, part in pairs(part:GetTouchingParts()) do
					local playerCheck = PlayerUtils:getPlayerFromHuman(part)
					if playerCheck then
						if playerCheck.Name == player.Name then
							isStillTouching = true
							break
						end
					end
				end

				if not isStillTouching and not isUntouchingPlayer[player] then
					if untouchedFn then
						untouchedFn(player)
						isUntouchingPlayer[player] = true
						wait(1)
						isUntouchingPlayer[player] = false
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

	addTouchListeners(roomPart)
end

return TouchItem