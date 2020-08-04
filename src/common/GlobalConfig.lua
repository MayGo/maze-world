local RunService = game:GetService('RunService')

local isDev = RunService:IsStudio()

local GlobalConfig = {
	WAIT_TIME = isDev and 2 or 20,
	PLAY_TIME_EASY = 60,
	PLAY_TIME_MEDIUM = 200,
	PLAY_TIME_HARD = 300,
	DEFAULT_PLAYER_SLOTS = 3,
	DEFAULT_PLAYER_COINS = 100,
	DEFAULT_PLAYER_INVENTORY = {},
}

return GlobalConfig