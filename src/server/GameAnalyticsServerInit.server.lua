--[[

	NOTE: This script should be in game.ServerScriptService

--]]

local ServerStorage = game:GetService('ServerStorage')
local GameAnalytics = require(ServerStorage.serverStorageSrc.GameAnalytics)

GameAnalytics:initialize({

--debug is by default enabled in studio only
	build = '0.3',
	gameKey = '',
	secretKey = '',
	enableInfoLog = true,
	enableVerboseLog = false,
	enableDebugLog = nil,
	automaticSendBusinessEvents = true,
	reportErrors = true,
	availableCustomDimensions01 = {},
	availableCustomDimensions02 = {},
	availableCustomDimensions03 = {},
	availableResourceCurrencies = {},
	availableResourceItemTypes = {},
	availableGamepasses = {},
})