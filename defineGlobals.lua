script = {}
plugin = {}
game = {}
workspace = {}

bit32 = {}
utf8 = {}

Instance = {}
CFrame = {}
Enum = {}
Color3 = {}
PhysicalProperties = {}
NumberSequence = {}
NumberSequenceKeypoint = {}
TweenInfo = {}
ColorSequence = {}
ColorSequenceKeypoint = {}
Vector2 = {}
Vector3 = {}
Region3 = {}
Vector3int16 = {}
Region3int16 = {}
UDim = {}
UDim2 = {}
Rect = {}
Ray = {}
Random = {}
BrickColor = {}

---@param func function()
spawn = function(func) end

---@param time number
wait = function(time) end

---@return number Local time since 1970
tick = function() end

---@return number Time since the start of the game
time = function() end

---@vararg any
warn = function(...) end

---@param obj any
---@return string Roblox object type
typeof = function(obj) end

---@param time number
---@param func function
delay = function(time, func) end

---@param tbl number
---@param start integer
unpack = function(tbl, start) end

---@return userdata
newproxy = function() end

settings = function() end
UserSettings = function() end

describe = function() end
expect = function() end
it = function() end