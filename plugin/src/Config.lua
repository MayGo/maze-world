local strict = require(script.Parent.strict)
local isDevBuild = script.Parent.Parent.Parent ~= nil

return strict('Config', {
	isDevBuild = true,
	codename = 'Epiphany',
	version = { 1, 0, 0 },
	expectedServerVersionString = '1.0 or newer',
	protocolVersion = 3,
	defaultHeight = '10',
	defaultWidth = '10',
})