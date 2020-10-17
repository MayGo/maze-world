local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Print = require(Modules.src.utils.Print)
local RunService = game:GetService('RunService')

local logger = {
	_infoLogEnabled = true,
	_infoLogAdvancedEnabled = false,
	_debugEnabled = RunService:IsStudio(),
}

function logger:setDebugLog(enabled)
	self._debugEnabled = enabled
end

function logger:setInfoLog(enabled)
	self._infoLogEnabled = enabled
end

function logger:setVerboseLog(enabled)
	self._infoLogAdvancedEnabled = enabled
end
function argsToString(...)
	local args = table.pack(...)

	local string = ''
	for i = 1, args.n do
		if type(args[i]) == 'table' then
			string = string .. Print.prettyPrint(args[i]) .. '. '
		else
			string = string .. tostring(args[i]) .. '. '
		end
	end
	return string
end

function logger:i(format, ...)
	if not self._infoLogEnabled then return end

	local m = 'Info: ' .. format
	print(m, argsToString(...))
end

function logger:w(format, ...)
	local m = 'Warning: ' .. format
	warn(m, argsToString(...))
end

function logger:e(format, ...)
	spawn(function()
		local m = 'Error: ' .. format
		error(m, 0)
	end)
end

function logger:d(format, ...)
	if not self._debugEnabled then return end

	local m = 'Debug: ' .. format

	print(m, argsToString(...))
end

function logger:ii(format, ...)
	if not self._infoLogAdvancedEnabled then return end

	local m = 'Verbose: ' .. format
	print(m, arg == nil and '' or arg)
end

return logger