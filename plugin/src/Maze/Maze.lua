local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs

local Maze = {
	directions = {
		north = {
			x = 0,
			y = -1,
		},
		east = {
			x = 1,
			y = 0,
		},
		south = {
			x = 0,
			y = 1,
		},
		west = {
			x = -1,
			y = 0,
		},
	},
}

function Maze:new(width, height, closed, obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	-- Actual maze setup
	for y = 1, height do
		obj[y] = {}
		for x = 1, width do
			obj[y][x] = {
				east = obj:CreateDoor(closed),
				south = obj:CreateDoor(closed),
			}

			-- Doors are shared beetween the cells to avoid out of sync conditions and data dublication
			if x ~= 1 then
				obj[y][x].west = obj[y][x - 1].east
			else
				obj[y][x].west = obj:CreateDoor(closed)
			end

			if y ~= 1 then
				obj[y][x].north = obj[y - 1][x].south
			else
				obj[y][x].north = self:CreateDoor(closed)
			end
		end
	end

	return obj
end

function Maze:width()
	return #self[1]
end

function Maze:height()
	return #self
end

function Maze:DirectionsFrom(x, y, validator)
	local directions = {}
	validator = validator or function()
		return true
	end

	for name, shift in pairs(self.directions) do
		local x, y = x + shift.x, y + shift.y

		if self[y] and self[y][x] and validator(self[y][x], x, y) then
			directions[#directions + 1] = {
				name = name,
				x = x,
				y = y,
			}
		end
	end

	return directions
end

function Maze:ResetDoors(close, borders)
	for y = 1, #self do
		for i, cell in ipairs(self[y]) do
			cell.north:SetClosed(close or y == 1 and not borders)
			cell.west:SetClosed(close)
		end

		self[y][1].west:SetClosed(close or not borders)
		self[y][#self[1]].east:SetClosed(close or not borders)
	end

	for i, cell in ipairs(self[#self]) do
		cell.south:SetClosed(close or not borders)
	end
end

function Maze:ResetVisited()
	for y = 1, #self do
		for x = 1, #self[1] do
			self[y][x].visited = nil
		end
	end
end

function Maze.tostring(maze, wall, passage)
	wall = wall or '#'
	passage = passage or ' '

	local result = ''

	local verticalBorder = ''
	for i = 1, #maze[1] do
		verticalBorder = verticalBorder .. wall .. (maze[1][i].north:IsClosed() and wall or passage)
	end
	verticalBorder = verticalBorder .. wall
	result = result .. verticalBorder .. '\n'

	for y, row in ipairs(maze) do
		local line = row[1].west:IsClosed() and wall or passage
		local underline = wall
		for x, cell in ipairs(row) do
			line = line .. ' ' .. (cell.east:IsClosed() and wall or passage)
			underline = underline .. (cell.south:IsClosed() and wall or passage) .. wall
		end
		result = result .. line .. '\n' .. underline .. '\n'
	end

	return result
end

Maze.__tostring = Maze.tostring

function Maze:CreateDoor(closed)
	local door = {}
	door.closed = closed and true or false

	function door:IsClosed()
		return self.closed
	end

	function door:IsOpened()
		return not self.closed
	end

	function door:Close()
		self.closed = true
	end

	function door:Open()
		self.closed = false
	end

	function door:SetOpened(opened)
		if opened then
			self:Open()
		else
			self:Close()
		end
	end

	function door:SetClosed(closed)
		self:SetOpened(not closed)
	end

	return door
end

return Maze