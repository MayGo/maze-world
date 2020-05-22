local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local logger = require(Modules.src.utils.Logger)

local Dict = require(Modules.src.utils.Dict)
local None = require(Modules.src.utils.None)

local function leaderboards(state, action)
	state = state or {
		mostVisited = {},
		mostPlayed = {},
		mostCoins = {},
	}

	if action.type == 'addLeaderboardItems' then
		local items = action.items
		local leaderboardKey = action.leaderboardKey

		return Dict.join(state, { [leaderboardKey] = items })
	end

	return state
end

return leaderboards