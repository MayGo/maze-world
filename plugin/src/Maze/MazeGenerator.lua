local Root = script:FindFirstAncestor('MazeGeneratorPlugin')

local M = require(Root:WaitForChild('M'))

local Models = Root:WaitForChild('Models')

local recursive_backtracker = require(script.Parent.MazeBacktrace)
local Maze = require(script.Parent.Maze)

local Prefabs = Models.Prefabs
local Misc = Models.Misc
local Money = Models.Money

local blockHeight = 20
local blockWidth = 25

local floorPartName = 'FloorPart'

function getCenterVector(width, height)
	return Vector3.new(width / 2, 0, height / 2)
end

function partToRegion3(obj)
	local abs = math.abs

	local cf = obj.CFrame -- this causes a LuaBridge invocation + heap alfolder to create CFrame object - expensive! - but no way around it. we need the cframe
	local size = obj.Size -- this causes a LuaBridge invocation + heap alfolder to create Vector3 object - expensive! - but no way around it
	local sx, sy, sz = size.X, size.Y, size.Z -- this causes 3 Lua->C++ invocations
	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components() -- this causes 1 Lua->C++ invocations and gets all components of cframe in one go, with no alfolders
	-- https://zeuxcg.org/2010/10/17/aabb-from-obb-with-component-wise-abs/
	local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz) -- this requires 3 Lua->C++ invocations to call abs, but no hash lookups since we cached abs value above; otherwise this is just a bunch of local ops
	local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz) -- same
	local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz) -- same
	-- just a bunch of local ops
	local minx = x - wsx
	local miny = y - wsy
	local minz = z - wsz

	local maxx = x + wsx
	local maxy = y + wsy
	local maxz = z + wsz

	local minv, maxv = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	return Region3.new(minv, maxv)
end

function dummyPart(position, folder)
	local newBlock = Instance.new('Part')

	newBlock.Anchored = true
	newBlock.Size = Vector3.new(0.5, blockHeight, 0.5)
	newBlock.Position = position
	newBlock.Parent = folder
end

local areaHalfWidth = (blockWidth - 5) / 2
local neg = M.range(5, areaHalfWidth)
local posr = M.range(-5, -areaHalfWidth)
local arr = M.append(neg, posr)

function randomPos()
	-- we are taking out center values

	local p = M.sample(arr)

	return p[1]
end

function randomRotation(position)
	return CFrame.new(position) * CFrame.fromOrientation(0, math.random(1, 360), 0)
end

function AddRandomPart(pos, folder)
	local parts = Misc:GetChildren()
	local randomPart = parts[math.random(1, #parts)]
	local newBlock = randomPart:Clone()

	local randomPosition = Vector3.new(randomPos(), 0, randomPos())

	local partSize
	if newBlock:IsA('BasePart') then
		partSize = newBlock.Size
	else
		partSize = newBlock.PrimaryPart.Size
	end

	local halfX = blockWidth / 2 - partSize.X / 2
	local halfY = partSize.Y / 2
	local halfZ = blockWidth / 2 - partSize.Z / 2

	local position = randomRotation(pos + Vector3.new(halfX, halfY, halfZ) + randomPosition)

	if newBlock:IsA('BasePart') then
		newBlock.CFrame = position
	else
		newBlock:SetPrimaryPartCFrame(position)
	end

	newBlock.Parent = folder
end

function AddCoinPart(pos, folder)
	local parts = Money:GetChildren()
	local randomPart = parts[math.random(1, #parts)]
	local newBlock = randomPart:Clone()

	local partSize
	if newBlock:IsA('BasePart') then
		partSize = newBlock.Size
	else
		partSize = newBlock.PrimaryPart.Size
	end

	local halfX = blockWidth / 2 - partSize.X / 2
	local halfY = partSize.Y / 2
	local halfZ = blockWidth / 2 - partSize.Z / 2

	local position = randomRotation(pos + Vector3.new(halfX, halfY, halfZ))

	if newBlock:IsA('BasePart') then
		newBlock.CFrame = position
	else
		newBlock:SetPrimaryPartCFrame(position)
	end

	newBlock.Parent = folder
end

function AddRandomParts(pos, folder)
	local times = M.range(1, 5)

	local fromGround = Vector3.new(0, 2.5, 0)

	AddCoinPart(pos + fromGround, folder)
	M.map(times, function()
		local willAdd = math.random(1, 10)
		if willAdd == 1 then
			AddRandomPart(pos + fromGround, folder)
		end
	end)
end

function MakeBlock()
	local newBlock = Instance.new('Part')

	newBlock.Anchored = true
	newBlock.Size = Vector3.new(1, blockHeight, blockWidth)

	return newBlock
end

function DrawBlock(pos, folder, vertical, settings)
	local newBlock = MakeBlock()

	local x = pos.X
	local y = pos.Y
	local z = pos.Z

	local halfHeight = newBlock.Size.Y / 2
	local halfWidth = newBlock.Size.Z / 2

	local position = CFrame.new(x, y + halfHeight, z + halfWidth)

	if vertical then
		local angle = math.rad(90)
		position = CFrame.new(x + halfWidth, y + halfHeight, z) * CFrame.Angles(0, angle, 0)
	end

	newBlock.CFrame = position

	local region = partToRegion3(newBlock)
	region = region:ExpandToGrid(4)

	if not settings.onlyBlocks then
		warn('Generating with wall material ', settings.wallMaterial)
		game.Workspace.Terrain:FillRegion(region, 4, settings.wallMaterial)
	else
		newBlock.Parent = folder
	end

	if settings.addKillBlocks then
		-- make top walls not walkable, by killing
		local killBlockName = 'Killbrick'
		local killBlock = Prefabs[killBlockName]:Clone()
		killBlock.Size = Vector3.new(3, 4, blockWidth)
		killBlock.CFrame = newBlock.CFrame + Vector3.new(0, blockHeight - 7, 0)
		killBlock.Transparency = 1
		killBlock.Parent = folder
	end
end

function DrawFloor(pos, folder, width, height, settings)
	local floor = Instance.new('Part')
	floor.Parent = folder
	floor.Size = Vector3.new(width, 1, height)

	floor.Name = floorPartName
	floor.CanCollide = true
	floor.Anchored = true

	floor.CFrame = CFrame.new(pos + getCenterVector(width, height))

	if not settings.onlyBlocks then
		workspace.Terrain:FillBlock(floor.CFrame, floor.Size, settings.groundMaterial)
	else
		floor.Parent = folder
	end
end

function DrawCeiling(pos, folder, width, height, settings)
	local floor = Instance.new('Part')
	floor.Parent = folder
	floor.Size = Vector3.new(width, 1, height)

	floor.Name = 'Ceiling'
	floor.CanCollide = true
	floor.Anchored = true
	floor.CFrame = CFrame.new(pos + getCenterVector(width, height))

	if not settings.onlyBlocks then
		workspace.Terrain:FillBlock(floor.CFrame, floor.Size, settings.wallMaterial)
	else
		floor.Parent = folder
	end
end

function DrawStart(pos, folder)
	local block = 'SpawnPlaceholder'
	local newBlock = Prefabs[block]:Clone()

	newBlock.Position = pos
	newBlock.Parent = folder
end

function DrawFinish(pos, folder)
	local block = 'FinishPlaceholder'
	local newBlock = Prefabs[block]:Clone()

	newBlock.Position = pos
	newBlock.Parent = folder
end

local function draw_maze(maze, folder, pos, settings)
	local maze_width = blockWidth * #maze[1]
	local maze_height = blockWidth * #maze

	warn('Positioning Maze: ', pos)
	-- part can have max size 2048
	local maxPartSize = 2048
	warn('Size in studs:' .. tostring(maze_width) .. ', height:' .. tostring(maze_height))
	if maxPartSize < maze_width or maxPartSize < maze_height then
		warn('Floor or Ceiling part is over max size:' .. tostring(maxPartSize))
	end

	DrawFloor(pos, folder, maze_width, maze_height, settings)

	if settings.addCeiling then
		DrawCeiling(pos + Vector3.new(0, blockHeight, 0), folder, maze_width, maze_height, settings)
	end

	if settings.addStartAndFinish then
		local offset = Vector3.new(blockWidth / 2, 0, blockWidth / 2)
		DrawStart(pos + Vector3.new(2, 6, 2) + offset, folder)

		local finisWidth = blockWidth - 2
		local finishOffset = Vector3.new(finisWidth / 2, 0, finisWidth / 2)
		local farCorner = Vector3.new(maze_width - finisWidth, 0, maze_height - finisWidth)
		DrawFinish(pos + farCorner + finishOffset, folder)
	end

	local blockDepth = 0

	for zi = 1, #maze do
		for xi = 1, #maze[1] do
			local pos_x = pos.X + (blockWidth + blockDepth) * (xi - 1) + blockDepth
			local pos_z = pos.Z + (blockWidth + blockDepth) * (zi - 1) + blockDepth

			local cell = maze[zi][xi]

			if not cell.north:IsOpened() then
				DrawBlock(Vector3.new(pos_x, 0, pos_z), folder, true, settings)
			end

			if not cell.east:IsOpened() then
				DrawBlock(Vector3.new(pos_x + blockWidth, 0, pos_z), folder, false, settings)
			end

			if not cell.south:IsOpened() then
				DrawBlock(Vector3.new(pos_x, 0, pos_z + blockWidth), folder, true, settings)
			end

			if not cell.west:IsOpened() then
				DrawBlock(Vector3.new(pos_x, 0, pos_z), folder, false, settings)
			end

			if settings.addRandomModels then
				AddRandomParts(Vector3.new(pos_x, pos.Y, pos_z), folder)
			end
		end
	end
end

local MazeGenerator = {}

local mazeFolderName = 'Maze'

function MazeGenerator:generate(settings)
	local width = settings.width
	local height = settings.height
	local location = settings.location
	warn('Generating maze  width:' .. width .. ', height:' .. height)

	local maze = Maze:new(width, height, true)

	recursive_backtracker(maze)

	local mazeFolder = location:FindFirstChild(mazeFolderName)

	if mazeFolder then
		local floor = mazeFolder:FindFirstChild(floorPartName)
		workspace.Terrain:FillBlock(
			floor.CFrame,
			floor.Size + Vector3.new(10, blockHeight * 3, 10),
			Enum.Material.Air
		)
		mazeFolder:Destroy()
	end

	mazeFolder = Instance.new('Folder')
	mazeFolder.Name = mazeFolderName
	mazeFolder.Parent = location

	local position = Vector3.new(0, 0, 0)
	if location:IsA('BasePart') then
		position = location.Position
		warn('Using part location')
	end

	draw_maze(maze, mazeFolder, position, settings)
end

return MazeGenerator