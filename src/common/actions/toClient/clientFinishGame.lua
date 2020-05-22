local function clientFinishGame(player, roomId, finishTime, coins)
	-- assert(typeof(playerId) == "string")

	return {
		type = script.Name,
		playerId = tostring(player.UserId),
		playerName = tostring(player.Name),
		roomId = roomId,
		coins = coins,
		finishTime = finishTime,
		replicateTo = tostring(player.UserId),
	}
end

return clientFinishGame