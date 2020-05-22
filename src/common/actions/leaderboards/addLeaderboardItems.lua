local function addLeaderboardItems(leaderboardKey, items)
	assert(typeof(items) == 'table')

	return {
		type = script.Name,
		leaderboardKey = leaderboardKey,
		items = items,
	}
end

return addLeaderboardItems