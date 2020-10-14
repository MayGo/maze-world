local strict = require(script.Parent.strict)
local PluginFolderName = 'MazeGeneratorPlugin'

local ServerStorage = game:GetService('ServerStorage')
local devSource = ServerStorage:FindFirstChild(PluginFolderName)

local isDevBuild = true
if not devSource and script.Parent.Parent.Parent ~= nil then
	isDevBuild = script.Parent.Parent.Parent:FindFirstChild('DEV_BUILD') ~= nil
end

return strict('Config', {
	isDevBuild = isDevBuild,
	codename = 'Epiphany',
	version = { 1, 0, 3 },
	expectedServerVersionString = '1.0 or newer',
	protocolVersion = 3,
	defaultHeight = '10',
	defaultWidth = '10',
	defaultThickness = '3',
})