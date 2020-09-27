local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local M = require(Modules.M)
local Maze = require(script.Parent.Maze)
local Models = ReplicatedStorage:WaitForChild('Models')
local Prefabs = Models.Prefabs
local Walls = Models.Walls
local Misc = Models.Misc
local Money = Models.Money
local recursive_backtracker = require(script.Parent.MazeBacktrace)

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

	local halfY  --height
	local halfX
	local halfZ

	if newBlock:IsA('BasePart') then
		halfY = newBlock.Size.Y / 2
		halfX = blockWidth / 2 - newBlock.Size.X / 2
		halfZ = blockWidth / 2 - newBlock.Size.Z / 2
	else
		halfY = newBlock.PrimaryPart.Size.Y / 2
		halfX = blockWidth / 2 - newBlock.PrimaryPart.Size.X / 2
		halfZ = blockWidth / 2 - newBlock.PrimaryPart.Size.Z / 2
	end

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

	local halfY  --height
	local halfX
	local halfZ
	if newBlock:IsA('BasePart') then
		halfY = newBlock.Size.Y / 2
		halfX = blockWidth / 2 - newBlock.Size.X / 2
		halfZ = blockWidth / 2 - newBlock.Size.Z / 2
	else
		halfY = newBlock.PrimaryPart.Size.Y / 2
		halfX = blockWidth / 2 - newBlock.PrimaryPart.Size.X / 2
		halfZ = blockWidth / 2 - newBlock.PrimaryPart.Size.Z / 2
	end

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

	AddCoinPart(x, y, z, folder)
	M.map(times, function()
		local willAdd = math.random(1, 10)
		if willAdd == 1 then
			AddRandomPart(x, y, z, folder)
		end
	end)
end

function DrawBlock(x, y, z, folder, vertical)
	local newBlock = Instance.new('Part')

	newBlock.Anchored = true
	newBlock.Size = Vector3.new(1, blockHeight, blockWidth)
	local halfWidth = newBlock.Size.Z / 2
	local halfHeight = newBlock.Size.Y / 2

	local position = CFrame.new(x, z + halfHeight, y + halfWidth)

	if vertical then
		local angle = math.rad(90)
		position = CFrame.new(x + halfWidth, z + halfHeight, y) * CFrame.Angles(0, angle, 0)
	end

	newBlock.CFrame = position

	local region = partToRegion3(newBlock)
	region = region:ExpandToGrid(4)

	game.Workspace.Terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(91, 154, 76))
	game.Workspace.Terrain:FillRegion(region, 4, Enum.Material.Grass)

	-- make top walls not walkable, by killing
	local killBlockName = 'Killbrick'
	local killBlock = Prefabs[killBlockName]:Clone()
	killBlock.Size = Vector3.new(3, 4, blockWidth)
	killBlock.CFrame = newBlock.CFrame + Vector3.new(0, blockHeight - 7, 0)
	killBlock.Transparency = 1
	killBlock.Parent = folder
end

function DrawBlock2(x, y, z, folder, vertical, wallsFolder)
	local walls = wallsFolder:GetChildren()
	local randomWall = walls[math.random(1, #walls)]
	local newBlock = randomWall:Clone()

	newBlock.Parent = folder
	-- newBlock.Size = Vector3.new(3,3,3)
	-- newBlock.Orientation = Vector3.new(0, 0, 90)

	local halfWidth = newBlock.PrimaryPart.Size.Z / 2
	local halfHeight = newBlock.PrimaryPart.Size.Y / 2
	local position = CFrame.new(x, z + halfHeight, y + halfWidth)

	if vertical then
		local angle = math.rad(90)
		position = CFrame.new(x + halfWidth, z + halfHeight, y) * CFrame.Angles(0, angle, 0)
	end

	-- we are flipping y an z here, using x and y for Maze is simpler to read, z is height
	-- x, y, z is correct order
	newBlock:SetPrimaryPartCFrame(position)

	local region = partToRegion3(newBlock.PrimaryPart)
	region = region:ExpandToGrid(4)

	game.Workspace.Terrain:FillRegion(region, 4, Enum.Material.Grass)
	--[[
	workspace.Terrain:FillBlock(
		newBlock.PrimaryPart.CFrame,
		newBlock.PrimaryPart.Size,
		Enum.Material.WoodPlanks
	)]]
end

function DrawFloor(x, y, z, folder, width, height)
	local floor = Instance.new('Part')
	floor.Parent = folder
	floor.Size = Vector3.new(width, 1, height)

	floor.Name = floorPartName
	floor.CanCollide = false
	floor.Transparency = 1
	floor.Anchored = true
	floor.CFrame = CFrame.new(x + width / 2, z, y + height / 2)

	workspace.Terrain:FillBlock(floor.CFrame, floor.Size, Enum.Material.Sand)
end

function DrawStart(x, y, z, folder, width, height)
	local block = 'SpawnPlaceholder'
	local newBlock = Prefabs[block]:Clone()

	local position = Vector3.new(x + width / 2, z + 4, y + height / 2)
	newBlock.Position = position
	newBlock.Parent = folder
end

function DrawFinish(x, y, z, folder, width, height)
	local block = 'FinishPlaceholder'
	local newBlock = Prefabs[block]:Clone()

	local position = Vector3.new(x + width / 2, z, y + height / 2)
	newBlock.Position = position
	newBlock.Parent = folder
end

local function draw_maze(maze, blockWidth, blockDepth, folder, locationPart, wallFolder)
	local blockHeight = 20

	local maze_width = (blockWidth + blockDepth) * #maze[1] + blockDepth
	local maze_height = (blockWidth + blockDepth) * #maze + blockDepth
	locationPart.Size = Vector3.new(maze_width, 1, maze_height)

	local halfWidth = locationPart.Size.X / 2
	local halfDepth = locationPart.Size.Z / 2
	local halfHeight = locationPart.Size.Y / 2

	local x = locationPart.Position.X - halfWidth
	local y = locationPart.Position.Z - halfDepth
	local z = locationPart.Position.Y + halfHeight

	logger:d('Positioning Maze: ' .. x .. ' ' .. y)
	-- part can have max size 2048
	logger:d('Size in studs:' .. tostring(maze_width) .. ', height:' .. tostring(maze_height))

	DrawFloor(x, y, z, folder, maze_width, maze_height)
	DrawStart(x, y, z + 1, folder, blockWidth, blockWidth)

	local finisWidth = blockWidth - 2

	DrawFinish(
		x + maze_width - finisWidth,
		y + maze_height - finisWidth,
		z + 1,
		folder,
		finisWidth,
		finisWidth
	)

	for yi = 1, #maze do
		for xi = 1, #maze[1] do
			local pos_x = x + (blockWidth + blockDepth) * (xi - 1) + blockDepth
			local pos_y = y + (blockWidth + blockDepth) * (yi - 1) + blockDepth

			local cell = maze[yi][xi]

			if not cell.north:IsOpened() then
				DrawBlock(pos_x, pos_y - blockDepth, z, folder, true, wallFolder)
			end

			if not cell.east:IsOpened() then
				DrawBlock(pos_x + blockWidth, pos_y, z, folder, false, wallFolder)
			end

			if not cell.south:IsOpened() then
				DrawBlock(pos_x, pos_y + blockWidth, z, folder, true, wallFolder)
			end

			if not cell.west:IsOpened() then
				DrawBlock(pos_x - blockDepth, pos_y, z, folder, false, wallFolder)
			end

			AddRandomParts(pos_x, z, pos_y, folder)
		end
	end
end

local MazeGenerator = {}

local mazeFolderName = 'Maze'

function MazeGenerator:generate(map, width, height)
	logger:d('Generating maze  width:' .. width .. ', height:' .. height)
	local locationPart = map.PrimaryPart
	locationPart.CanCollide = false
	locationPart.Transparency = 1

	local maze = Maze:new(width, height, true)

	recursive_backtracker(maze)

	local mazeFolder = map:FindFirstChild(mazeFolderName)

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
	mazeFolder.Parent = map

	local wallFolder = Walls.Walls_1
	draw_maze(maze, blockWidth, blockDepth, mazeFolder, locationPart, wallFolder)
end

return MazeGenerator