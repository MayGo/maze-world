-- Recursive Backtracker algorithm
-- Detailed description: http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
local random = math.random

local function backtrack(maze, x, y)
	maze[y][x].visited = true

	-- while there are possible travel directions from this cell
	local directions = maze:DirectionsFrom(x, y, function(cell)
		return not cell.visited
	end)
	while #directions ~= 0 do
		-- choose random direction
		local rand_i = random(#directions)
		local dirn = directions[rand_i]

		directions[rand_i] = directions[#directions]
		directions[#directions] = nil

		-- if this direction leads to an unvisited cell:
		-- carve and recurse into this new cell
		if not maze[dirn.y][dirn.x].visited then
			maze[y][x][dirn.name]:Open()
			backtrack(maze, dirn.x, dirn.y)
		end
	end
end

local function recursive_backtracker(maze, x, y)
	maze:ResetDoors(true)
	x, y = random(maze:width()), random(maze:height())

	-- start recursive maze carving
	backtrack(maze, x, y)

	maze:ResetVisited()
end

return recursive_backtracker