--[[

	NOTE: This script should be in game.ServerScriptService

--]]

local ServerStorage = game:GetService('ServerStorage')
local GameAnalytics = require(ServerStorage.serverStorageSrc.GameAnalytics)

GameAnalytics:initialize({

--debug is by default enabled in studio only
	build = '0.3',
	gameKey = 'f092b8e655b764eae60693cc09b92f34',
	secretKey = '056ce4058c7aad1cb59884b5dd1e480cdce0af9f',
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