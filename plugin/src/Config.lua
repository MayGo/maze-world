local strict = require(script.Parent.strict)

return strict('Config', {
	isDevBuild = true,
	codename = 'Epiphany',
	version = { 1, 0, 0 },
	expectedServerVersionString = '1.0 or newer',
	protocolVersion = 3,
	defaultHost = 'localhost',
	defaultPort = 34872,
})