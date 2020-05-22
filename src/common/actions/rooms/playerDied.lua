local function playerDied(player)
	-- assert(typeof(playerId) == "string")

	return {
		type = script.Name,
		playerId = tostring(player.UserId),
		playerName = tostring(player.Name),
	}
end

return playerDied