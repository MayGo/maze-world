local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Models = ReplicatedStorage:WaitForChild('Models')
local logger = require(Modules.src.utils.Logger)

local ModelManager = {}

function ModelManager:findModel(item)
	if not item.modelFolder then
		logger:e('No modelFolder for item', item)
	end

	local modelFolder = Models:FindFirstChild(item.modelFolder)
	if not modelFolder then
		logger:e('No modelFolder found with name: ' .. item.modelFolder)
		return
	end

	local model = modelFolder:FindFirstChild(item.modelName)

	if not model then
		logger:e('No model found with name: ' .. item.modelName)
		return
	end

	logger:d('Model found with name: ' .. item.modelName)

	return model
end

function ModelManager:setTransparency(model, transparency)
	local descendants = model:GetDescendants()
	for i = 1, #descendants do
		local descendant = descendants[i]
		-- PrimaryPart is usually invicible bounding box
		if descendant:IsA('BasePart') and model.PrimaryPart ~= descendant then
			descendant.Transparency = transparency
		end
	end
end
function ModelManager:setTransparencyAndCanCollide(model, transparency, canCollide)
	local descendants = model:GetDescendants()
	for i = 1, #descendants do
		local descendant = descendants[i]
		-- PrimaryPart is usually invicible bounding box
		if descendant:IsA('BasePart') and model.PrimaryPart ~= descendant then
			descendant.Transparency = transparency
			descendant.CanCollide = canCollide
		end
	end
end

function ModelManager:removePitch(cf, defaultCf)
	local _, RY, RZ = cf:ToOrientation()
	return CFrame.new(cf.Position) * CFrame.fromOrientation(0, RY, RZ)
end

function ModelManager:onlyDirection(cf)
	local _, RY, RZ = cf:ToOrientation()
	return CFrame.new(cf.Position) * CFrame.fromOrientation(0, RY, 0)
end

return ModelManager