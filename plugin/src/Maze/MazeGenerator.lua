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
local blockDepth = 0

local floorPartName = 'FloorPart'

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
local pos = M.range(-5, -areaHalfWidth)
local arr = M.append(neg, pos)

function randomPos()
	-- we are taking out center values

	local p = M.sample(arr)

	return p[1]
end

function randomRotation(position)
	return CFrame.new(position) * CFrame.fromOrientation(0, math.random(1, 360), 0)
end

function AddRandomPart(x, y, z, folder)
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

	local position = randomRotation(Vector3.new(x + halfX, y + halfY, z + halfZ) + randomPosition)

	if newBlock:IsA('BasePart') then
		newBlock.CFrame = position
	else
		newBlock:SetPrimaryPartCFrame(position)
	end

	newBlock.Parent = folder
end

function AddCoinPart(x, y, z, folder)
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

	local position = randomRotation(Vector3.new(x + halfX, y + halfY, z + halfZ))

	if newBlock:IsA('BasePart') then
		newBlock.CFrame = position
	else
		newBlock:SetPrimaryPartCFrame(position)
	end

	newBlock.Parent = folder
end

function AddRandomParts(x, y, z, folder)
	local times = M.range(1, 5)

	local fromGround = 2.5
	AddCoinPart(x, y + fromGround, z, folder)
	M.map(times, function()
		local willAdd = math.random(1, 10)
		if willAdd == 1 then
			AddRandomPart(x, y + fromGround, z, folder)
		end
	end)
end

function DrawBlock(x, y, z, folder, vertical, settings)
	local newBlock = Instance.new('Part')

	newBlock.Anchored = true
	newBlock.Size = Vector3.new(1, blockHeight, blockWidth)

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

	warn('Generating with wall material ', settings.wallMaterial)
	game.Workspace.Terrain:FillRegion(region, 4, settings.wallMaterial)

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

function DrawFloor(x, y, z, folder, width, height, settings)
	local floor = Instance.new('Part')
	floor.Parent = folder
	floor.Size = Vector3.new(width, 1, height)

	floor.Name = floorPartName
	floor.CanCollide = false
	floor.Transparency = 1
	floor.Anchored = true
	floor.CFrame = CFrame.new(x + width / 2, y, z + height / 2)

	workspace.Terrain:FillBlock(floor.CFrame, floor.Size, settings.groundMaterial)
end

function DrawCeiling(x, y, z, folder, width, height, settings)
	local floor = Instance.new('Part')
	floor.Parent = folder
	floor.Size = Vector3.new(width, 1, height)

	floor.Name = floorPartName
	floor.CanCollide = false
	floor.Transparency = 1
	floor.Anchored = true
	floor.CFrame = CFrame.new(x + width / 2, y, z + height / 2)

	workspace.Terrain:FillBlock(floor.CFrame, floor.Size, settings.wallMaterial)
end

function DrawStart(x, y, z, folder, width, depth)
	local block = 'SpawnPlaceholder'
	local newBlock = Prefabs[block]:Clone()

	local position = Vector3.new(x + width / 2, y, z + depth / 2)
	newBlock.Position = position
	newBlock.Parent = folder
end

function DrawFinish(x, y, z, folder, width, depth)
	local block = 'FinishPlaceholder'
	local newBlock = Prefabs[block]:Clone()

	local position = Vector3.new(x + width / 2, y, z + depth / 2)
	newBlock.Position = position
	newBlock.Parent = folder
end

local function draw_maze(maze, blockWidth, blockDepth, folder, position, settings)
	local maze_width = (blockWidth + blockDepth) * #maze[1] + blockDepth
	local maze_height = (blockWidth + blockDepth) * #maze + blockDepth

	local x = position.X
	local y = position.Y
	local z = position.Z

	warn('Positioning Maze: ' .. x .. ' ' .. y)
	-- part can have max size 2048
	warn('Size in studs:' .. tostring(maze_width) .. ', height:' .. tostring(maze_height))

	DrawFloor(x, y, z, folder, maze_width, maze_height, settings)

	if settings.addCeiling then
		DrawCeiling(x, y + blockHeight, z, folder, maze_width, maze_height, settings)
	end

	if settings.addStartAndFinish then
		DrawStart(x + 2, y + 6, z + 2, folder, blockWidth, blockWidth)

		local finisWidth = blockWidth - 2

		DrawFinish(
			x + maze_width - finisWidth,
			y,
			z + maze_height - finisWidth,
			folder,
			finisWidth,
			finisWidth
		)
	end

	for zi = 1, #maze do
		for xi = 1, #maze[1] do
			local pos_x = x + (blockWidth + blockDepth) * (xi - 1) + blockDepth
			local pos_z = z + (blockWidth + blockDepth) * (zi - 1) + blockDepth

			local cell = maze[zi][xi]

			if not cell.north:IsOpened() then
				DrawBlock(pos_x, y, pos_z - blockDepth, folder, true, settings)
			end

			if not cell.east:IsOpened() then
				DrawBlock(pos_x + blockWidth, y, pos_z, folder, false, settings)
			end

			if not cell.south:IsOpened() then
				DrawBlock(pos_x, y, pos_z + blockWidth, folder, true, settings)
			end

			if not cell.west:IsOpened() then
				DrawBlock(pos_x - blockDepth, y, pos_z, folder, false, settings)
			end

			if settings.addRandomModels then
				AddRandomParts(pos_x, y, pos_z, folder)
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

	draw_maze(maze, blockWidth, blockDepth, mazeFolder, position, settings)
end

return MazeGenerator