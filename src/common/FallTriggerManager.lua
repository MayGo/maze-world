local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local src = Modules:WaitForChild('src')
local Models = ReplicatedStorage:WaitForChild('Models')

local Maid = require(Modules.Knit.Util.Maid)
local FallItems = Models.FallItems
local logger = require(src.utils.Logger)

local M = require(Modules.M)

local FallTriggerManager = {}

function dummyPart(position, folder)
	local newBlock = Instance.new('Part')

	newBlock.Anchored = false
	newBlock.CanCollide = true
	newBlock.Size = Vector3.new(0.5, 0.5, 0.5)
	newBlock.Position = position
	newBlock.Parent = folder
end

local cachedFolders = {}
function FallTriggerManager:fallStuff(triggerPart, waitFor)
	local maid = Maid.new()

	local folder = cachedFolders[triggerPart]
	if not folder then
		local folders = FallItems:GetChildren()
		folder = folders[math.random(1, #folders)]
		cachedFolders[triggerPart] = folder
	end

	local items = folder:GetChildren()

	local addMoreToTop = folder.Name == 'Blood' and 2 or 0

	local toTopSide = Vector3.new(0, triggerPart.Size.Y / 2 + addMoreToTop, 0)

	local diameter = math.min(triggerPart.Size.X, triggerPart.Size.Z)

	function randomNum()
		return math.random() * diameter - diameter / 2
	end

	local maxItems = 50
	local generatedItems = 0
	-- fall 2/3 at once and tripp rest of items
	while generatedItems < maxItems do
		local randomPos = Vector3.new(randomNum(), 0, randomNum())

		local part = items[math.random(1, #items)]:Clone()
		part.PrimaryPart.Position = triggerPart.Position + toTopSide + randomPos
		part.Parent = workspace

		maid:GiveTask(part)

		generatedItems = generatedItems + 1
	end

	wait(waitFor)
	maid:Destroy()
end

return FallTriggerManager