local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local PlayerUtils = require(Modules.src.utils.PlayerUtils)

local TouchItem = {}
local isTouchingPlayer = {}
local isUntouchingPlayer = {}
local Players = game:GetService('Players')

local localPlayer = Players.LocalPlayer

function TouchItem.create(roomPart, touchedFn, untouchedFn)
	local function addTouchListeners(part)
		local function onTouchStart(hit)
			local player = PlayerUtils:getPlayerFromHuman(hit)
			-- if TouchItem is runned in local script, then we check if trigger was localPlayer otherwise just player
			if (player and player == localPlayer) or (player and not localPlayer) then
				if not isTouchingPlayer[player] then
					isTouchingPlayer[player] = true
					touchedFn(player)
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
						isUntouchingPlayer[player] = true
						untouchedFn(player)
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

	local data = addTouchListeners(roomPart)

	local function Disconnect()
		data.touchedConn:Disconnect()
		data.untouchedConn:Disconnect()
	end

	return { Disconnect = Disconnect }
end

return TouchItem