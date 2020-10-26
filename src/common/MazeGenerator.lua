local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)
local M = require(Modules.M)

local Models = ReplicatedStorage:WaitForChild('Models')
local recursive_backtracker = require(script.Parent.MazeBacktrace)
local Maze = require(script.Parent.Maze)

local Prefabs = Models.Prefabs
local Misc = Models.Misc
local Money = Models.Money

local floorPartName = 'FloorPart'

function getCenterVector(width, height)
	return Vector3.new(width / 2, 0, height / 2)
end

function removePitch(cf, defaultCf)
	local RX, RY, RZ = cf:ToOrientation()
	return CFrame.new(cf.Position)
end
function getCorrectCframe(hingeCF, doorCF)
	local withoutRotation = CFrame.new(hingeCF.Position)

	local offset = withoutRotation:inverse() * doorCF
	return hingeCF * offset
end

function partToTerrain(newBlock, material)
	--[[
	local region = partToRegion3(newBlock)
	region = region:ExpandToGrid(4)
	game.Workspace.Terrain:FillRegion(region, 4, settings.wallMaterial)
	]]

	workspace.Terrain:FillBlock(newBlock.CFrame, newBlock.Size, material)
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

function randomPos(settings)
	local areaHalfWidth = settings.blockWidth / 2 - settings.partThickness
	local neg = M.range(2, areaHalfWidth)
	local posr = M.range(-2, -areaHalfWidth)
	local arr = M.append(neg, posr)

	local p = M.sample(arr)

	return p[1]
end

function randomRotation(position)
	return CFrame.new(position) * CFrame.fromOrientation(0, math.random(1, 360), 0)
end

function AddRandomPart(pos, cframe, folder, settings)
	local parts = Misc[settings.randomStuffFolder]:GetChildren()
	local randomPart = parts[math.random(1, #parts)]
	local newBlock = randomPart:Clone()

	local randomPosition = Vector3.new(randomPos(settings), 0, randomPos(settings))

	local partSize
	if newBlock:IsA('BasePart') then
		partSize = newBlock.Size
	else
		partSize = newBlock.PrimaryPart.Size
	end

	local halfX = settings.blockWidth / 2 - partSize.X / 2
	local halfY = partSize.Y / 2
	local halfZ = settings.blockWidth / 2 - partSize.Z / 2

	local cf = randomRotation(pos + Vector3.new(halfX, halfY, halfZ) + randomPosition)

	local newCf = getCorrectCframe(cframe, cf)

	if newBlock:IsA('BasePart') then
		newBlock.CFrame = newCf
	else
		newBlock:SetPrimaryPartCFrame(newCf)
	end

	newBlock.Parent = folder
end

function AddCoinPart(pos, cframe, folder, settings)
	local parts = Money:GetChildren()
	local randomPart = parts[math.random(1, #parts)]
	local newBlock = randomPart:Clone()

	local partSize
	if newBlock:IsA('BasePart') then
		partSize = newBlock.Size
	else
		partSize = newBlock.PrimaryPart.Size
	end

	local halfX = settings.blockWidth / 2 - partSize.X / 2
	local halfY = partSize.Y / 2
	local halfZ = settings.blockWidth / 2 - partSize.Z / 2

	local cf = randomRotation(pos + Vector3.new(halfX, halfY, halfZ))

	local newCf = getCorrectCframe(cframe, cf)

	if newBlock:IsA('BasePart') then
		newBlock.CFrame = newCf
	else
		newBlock:SetPrimaryPartCFrame(newCf)
	end

	newBlock.Parent = folder
end

function AddRandomParts(pos, cframe, folder, settings)
	AddCoinPart(pos, cframe, folder, settings)

	local willAdd = math.random(1, 2)
	if willAdd == 1 then
		AddRandomPart(pos, cframe, folder, settings)
	end
end

function MakeBlock(settings)
	local newBlock = Instance.new('Part')

	newBlock.Anchored = true
	newBlock.Size = Vector3.new(settings.partThickness, settings.blockHeight, settings.blockWidth)

	return newBlock
end

function DrawBlock(pos, cframe, folder, vertical, settings)
	local newBlock = MakeBlock(settings)

	local x = pos.X
	local y = pos.Y
	local z = pos.Z

	local halfHeight = newBlock.Size.Y / 2
	local halfWidth = newBlock.Size.Z / 2

	local cf = CFrame.new(x, y + halfHeight, z + halfWidth)

	if vertical then
		local angle = math.rad(90)
		cf = CFrame.new(x + halfWidth, y + halfHeight, z) * CFrame.Angles(0, angle, 0)
	end

	newBlock.CFrame = cf

	newBlock.CFrame = getCorrectCframe(cframe, newBlock.CFrame)

	if not settings.onlyBlocks then
		partToTerrain(newBlock, settings.wallMaterial)
	else
		newBlock.Parent = folder
	end

	if settings.addKillBlocks then
		-- make top walls not walkable, by killing
		local killBlockName = 'Killbrick'
		local killBlock = Prefabs[killBlockName]:Clone()
		killBlock.Size = Vector3.new(3, 4, settings.blockWidth)
		killBlock.CFrame = newBlock.CFrame + Vector3.new(0, settings.blockHeight - 7, 0)
		killBlock.Transparency = 1
		killBlock.Parent = folder
	end
end

function DrawDummyFloor(floor, folder, settings)
	local floor2 = floor:Clone()
	floor2.Size =
		floor2.Size + Vector3.new(
			settings.blockWidth * 3,
			settings.blockHeight * 3,
			settings.blockWidth * 3
		)
	floor2.Transparency = 0.9
	floor2.Parent = folder
	floor2.CanCollide = false
end

function DrawPart(pos, cframe, folder, width, height, settings, name, material)
	local floor = Instance.new('Part')

	floor.Size = Vector3.new(width, settings.ceilingFloorThickness, height)

	floor.Name = name
	floor.CanCollide = true
	floor.Anchored = true

	floor.CFrame = CFrame.new(pos + getCenterVector(width, height))

	floor.CFrame = getCorrectCframe(cframe, floor.CFrame)

	if not settings.onlyBlocks then
		floor.Parent = folder
		floor.Transparency = 1
		floor.CanCollide = false
		partToTerrain(floor, material)
	else
		floor.Parent = folder
	end
end

function DrawFloor(pos, cframe, folder, width, height, settings)
	DrawPart(pos, cframe, folder, width, height, settings, floorPartName, settings.groundMaterial)
end

function DrawCeiling(pos, cframe, folder, width, height, settings)
	DrawPart(pos, cframe, folder, width, height, settings, 'Ceiling', settings.wallMaterial)
end

function DrawStart(pos, cframe, folder)
	local block = 'SpawnPlaceholder'
	local newBlock = Prefabs[block]:Clone()

	newBlock.CFrame = CFrame.new(pos)
	newBlock.CFrame = getCorrectCframe(cframe, newBlock.CFrame)
	newBlock.Parent = folder
end

function DrawFinish(pos, cframe, folder)
	local block = 'FinishPlaceholder'
	local newBlock = Prefabs[block]:Clone()

	newBlock.CFrame = CFrame.new(pos)
	newBlock.CFrame = getCorrectCframe(cframe, newBlock.CFrame)
	newBlock.Parent = folder
end

local function draw_maze(maze, folder, pos, cframe, settings)
	local maze_width = settings.blockWidth * #maze[1]
	local maze_height = settings.blockWidth * #maze

	warn('Positioning Maze: ', pos)
	-- part can have max size 2048
	local maxPartSize = 2048
	warn('Size in studs:' .. tostring(maze_width) .. ', height:' .. tostring(maze_height))

	if maxPartSize < maze_width or maxPartSize < maze_height then
		warn('Floor or Ceiling part is over max size:' .. tostring(maxPartSize))
	end

	DrawFloor(
		pos + Vector3.new(0, -settings.ceilingFloorThickness / 2, 0),
		cframe,
		folder,
		maze_width,
		maze_height,
		settings
	)

	if settings.addCeiling then
		DrawCeiling(
			pos + Vector3.new(0, settings.blockHeight + settings.ceilingFloorThickness / 2, 0),
			cframe,
			folder,
			maze_width,
			maze_height,
			settings
		)
	end

	if settings.addStartAndFinish then
		local offset = Vector3.new(settings.blockWidth / 2, 0, settings.blockWidth / 2)
		DrawStart(pos + Vector3.new(2, 6, 2) + offset, cframe, folder)

		local finisWidth = settings.blockWidth - 2
		local finishOffset = Vector3.new(finisWidth / 2, 2, finisWidth / 2)
		local farCorner = Vector3.new(maze_width - finisWidth, 0, maze_height - finisWidth)
		DrawFinish(pos + farCorner + finishOffset, cframe, folder)
	end

	local blockDepth = 0

	local parts = {}
	-- TODO: remove duplicate walls

	function cachePart(p, vertical)
		local key = tostring(p) .. tostring(vertical)
		if not parts[key] then
			parts[key] = true
			DrawBlock(p, cframe, folder, vertical, settings)
			-- warn('Has same part already')
		else
		end
	end

	for zi = 1, #maze do
		for xi = 1, #maze[1] do
			local pos_x = (settings.blockWidth + blockDepth) * (xi - 1) + blockDepth
			local pos_z = (settings.blockWidth + blockDepth) * (zi - 1) + blockDepth

			local cell = maze[zi][xi]

			if not cell.north:IsOpened() then
				local p = Vector3.new(pos_x, 0, pos_z)
				cachePart(pos + p, true)
			end

			if not cell.east:IsOpened() then
				local p = Vector3.new(pos_x + settings.blockWidth, 0, pos_z)
				cachePart(pos + p, false)
			end

			if not cell.south:IsOpened() then
				local p = Vector3.new(pos_x, 0, pos_z + settings.blockWidth)
				cachePart(pos + p, true)
			end

			if not cell.west:IsOpened() then
				local p = Vector3.new(pos_x, 0, pos_z)
				cachePart(pos + p, false)
			end

			if settings.addRandomModels then
				local p = Vector3.new(pos_x, settings.ceilingFloorThickness / 2.5, pos_z)
				AddRandomParts(pos + p, cframe, folder, settings)
			end
		end
	end
end

local MazeGenerator = {}

local mazeFolderName = 'Maze'

function MazeGenerator:clean(settings)
	warn('Clean maze from location:', settings.location)
	local location = settings.location
	local mazeFolder = location:FindFirstChild(mazeFolderName)

	if mazeFolder then
		local floor = mazeFolder:FindFirstChild(floorPartName)
		floor.Size =
			floor.Size + Vector3.new(
				settings.blockWidth * 3,
				settings.blockHeight * 5,
				settings.blockWidth * 3
			)

		workspace.Terrain:FillBlock(floor.CFrame, floor.Size, Enum.Material.Air)
		mazeFolder:Destroy()
	end
end

function MazeGenerator:generate(settings)
	local width = settings.width
	local height = settings.height
	local location = settings.location
	warn('Generating maze  width:' .. width .. ', height:' .. height)

	local maze = Maze:new(width, height, true)

	recursive_backtracker(maze)

	local mazeFolder = Instance.new('Folder')
	mazeFolder.Name = mazeFolderName
	mazeFolder.Parent = location

	local position = Vector3.new(0, 0, 0)
	local cframe = CFrame.new(0, 0, 0)
	if location:IsA('BasePart') then
		position = location.Position
		cframe = location.CFrame
		warn('Using part location')
	end

	draw_maze(maze, mazeFolder, position, cframe, settings)
end

return MazeGenerator