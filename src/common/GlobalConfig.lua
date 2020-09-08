local RunService = game:GetService('RunService')

local isDev = RunService:IsStudio()

local GlobalConfig = {
	WAIT_TIME = isDev and 4 or 20,
	afterFinishWaitTime = 10,
	refreshLeaderboards = 5 * 60,
	DEFAULT_PLAYER_SLOTS = 3,
	DEFAULT_PLAYER_COINS = 100,
	DEFAULT_PLAYER_INVENTORY = {},
}

return GlobalConfig