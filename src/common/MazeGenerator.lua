local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Maze = require(script.Parent.Maze)
local prefabs = game.ServerStorage.Prefabs
local recursive_backtracker = require(script.Parent.MazeBacktrace)

function DrawBlock(x, y, z, location, vertical, wallsFolder)
	local walls = wallsFolder:GetChildren()
	local randomWall = walls[math.random(1, #walls)]
	local newBlock = randomWall:Clone()

	newBlock.Parent = location
	-- newBlock.Size = Vector3.new(3,3,3)
	-- newBlock.Orientation = Vector3.new(0, 0, 90)

	local halfWidth = newBlock.Size.Z / 2
	local halfHeight = newBlock.Size.Y / 2
	local position = CFrame.new(x, z + halfHeight, y + halfWidth)

	if vertical then
		local angle = math.rad(90)
		position = CFrame.new(x + halfWidth, z + halfHeight, y) * CFrame.Angles(0, angle, 0)
	end

	-- we are flipping y an z here, using x and y for Maze is simpler to read, z is height
	-- x, y, z is correct order
	newBlock.CFrame = position
end

function DrawFloor(x, y, z, location, width, height)
	local block = 'Wall'
	local newBlock = prefabs[block]:Clone()
	newBlock.Parent = location
	newBlock.Size = Vector3.new(width, 1, height)

	local position = CFrame.new(x + width / 2, z, y + height / 2)
	newBlock.CFrame = position
end

function DrawStart(x, y, z, location, width, height)
	local block = 'SpawnPlaceholder'
	local newBlock = prefabs[block]:Clone()
	newBlock.Parent = location
	newBlock.Size = Vector3.new(width, 1, height)

	local position = CFrame.new(x + width / 2, z, y + height / 2)
	newBlock.CFrame = position
end

function DrawFinish(x, y, z, location, width, height)
	local block = 'FinishPlaceholder'
	local newBlock = prefabs[block]:Clone()
	newBlock.Parent = location
	newBlock.Size = Vector3.new(width, 1, height)

	local position = CFrame.new(x + width / 2, z, y + height / 2)
	newBlock.CFrame = position
end

local function draw_maze(maze, blockWidth, blockDepth, location, primaryPart, wallFolder, wallKillbrickFolder)
	local halfWidth = primaryPart.Size.X / 2
	local halfDepth = primaryPart.Size.Z / 2
	local halfHeight = primaryPart.Size.Y / 2

	local blockHeight = 20
	local x = primaryPart.Position.X - halfWidth
	local y = primaryPart.Position.Z - halfDepth
	local z = primaryPart.Position.Y + halfHeight
	local zKill = z + blockHeight

	logger:d('Positioning Maze: ' .. x .. ' ' .. y)
	local maze_width = (blockWidth + blockDepth) * #maze[1] + blockDepth
	local maze_height = (blockWidth + blockDepth) * #maze + blockDepth

	DrawFloor(x, y, z, location, maze_width, maze_height)
	DrawStart(x, y, z + 1, location, blockWidth, blockWidth)

	local finisWidth = blockWidth - 2
	DrawFinish(x + maze_width - finisWidth, y + maze_height - finisWidth, z + 1, location, finisWidth, finisWidth)

	for yi = 1, #maze do
		for xi = 1, #maze[1] do
			local pos_x = x + (blockWidth + blockDepth) * (xi - 1) + blockDepth
			local pos_y = y + (blockWidth + blockDepth) * (yi - 1) + blockDepth

			local cell = maze[yi][xi]

			if not cell.north:IsOpened() then
				DrawBlock(pos_x, pos_y - blockDepth, z, location, true, wallFolder)
				DrawBlock(pos_x, pos_y - blockDepth, zKill, location, true, wallKillbrickFolder)
			end

			if not cell.east:IsOpened() then
				DrawBlock(pos_x + blockWidth, pos_y, z, location, false, wallFolder)
				DrawBlock(pos_x + blockWidth, pos_y, zKill, location, false, wallKillbrickFolder)
			end

			if not cell.south:IsOpened() then
				DrawBlock(pos_x, pos_y + blockWidth, z, location, true, wallFolder)
				DrawBlock(pos_x, pos_y + blockWidth, zKill, location, true, wallKillbrickFolder)
			end

			if not cell.west:IsOpened() then
				DrawBlock(pos_x - blockDepth, pos_y, z, location, false, wallFolder)
				DrawBlock(pos_x - blockDepth, pos_y, zKill, location, false, wallKillbrickFolder)
			end
		end
	end
end

local MazeGenerator = {}

local mazeFolderName = 'Maze'

function MazeGenerator:generate(map, width, height)
	logger:d('Generating maze  width:' .. width .. ', height:' .. height)

	--local blockHeight = 20
	local blockWidth = 15
	local blockDepth = 0

	local maze = Maze:new(width, height, true)

	recursive_backtracker(maze)

	local mazeFolder = map:FindFirstChild(mazeFolderName)

	if mazeFolder then
		mazeFolder:Destroy()
	end

	mazeFolder = Instance.new('Folder', map)
	mazeFolder.Name = mazeFolderName

	local primaryPart = map.PrimaryPart
	local wallFolder = game.ServerStorage.Walls_1
	local wallKillbrickFolder = game.ServerStorage.Walls_1_killbrick
	draw_maze(maze, blockWidth, blockDepth, mazeFolder, primaryPart, wallFolder, wallKillbrickFolder)
end

return MazeGenerator