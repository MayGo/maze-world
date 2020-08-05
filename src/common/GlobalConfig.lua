local RunService = game:GetService('RunService')

local isDev = RunService:IsStudio()

local GlobalConfig = {
	WAIT_TIME = isDev and 2 or 20,
	PLAY_TIME_EASY = 120,
	PLAY_TIME_MEDIUM = 300,
	PLAY_TIME_HARD = 600,
	DEFAULT_PLAYER_SLOTS = 3,
	DEFAULT_PLAYER_COINS = 100,
	DEFAULT_PLAYER_INVENTORY = {},
}

return GlobalConfig