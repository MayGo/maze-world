local function clientSetGhosting(player)
	-- assert(typeof(playerId) == "string")

	return {
		type = script.Name,
		playerId = tostring(player.UserId),
		playerName = tostring(player.Name),
		replicateTo = tostring(player.UserId),
	}
end

return clientSetGhosting