local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Place = game.Workspace:WaitForChild('Place')

local Portal = {}

Portal.__index = Portal

function Portal.new(teleportTo, portalFrom)
	local portalTo = teleportTo
	if type(teleportTo) == 'string' then
		local portalTo = Place.Lobby.Portals:FindFirstChild(teleportTo)
		if not portalTo then
			logger:e('Portal' .. teleportTo .. ' not found')
		end
	end

	return setmetatable(
		{
			teleportTo = teleportTo,
			portalTo = portalTo,
			portalFrom = portalFrom,
		},
		Portal
	)
end

function Portal:isHuman(hit)
	if hit.Parent == nil then
		return false
	end
	local humanoid = hit.Parent:FindFirstChild('HumanoidRootPart')
	if humanoid then
		return true
	end

	return false
end

function Portal:onTouch()
	return function(hit)
		if self:isHuman(hit) and self.portalFrom.Enabled.Value then
			local humanoid = hit.Parent.HumanoidRootPart
			-- self.portalFrom.Enabled.Value = false
			-- humanoid.CFrame = self.portalTo.CFrame
			humanoid.CFrame = CFrame.new(self.portalTo.CFrame.p - Vector3.new(0, -5, 5))
			-- wait(5)
			-- self.portalFrom.Enabled.Value = true
		end
	end
end

return Portal